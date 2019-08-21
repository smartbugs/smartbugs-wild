/***********************************************************
* This file is part of the Slock.it IoT Layer.             *
* The Slock.it IoT Layer contains:                         *
*   - USN (Universal Sharing Network)                      *
*   - INCUBED (Trustless INcentivized remote Node Network) *
************************************************************
* Copyright (C) 2016 - 2018 Slock.it GmbH                  *
* All Rights Reserved.                                     *
************************************************************
* You may use, distribute and modify this code under the   *
* terms of the license contract you have concluded with    *
* Slock.it GmbH.                                           *
* For information about liability, maintenance etc. also   *
* refer to the contract concluded with Slock.it GmbH.      *
************************************************************
* For more information, please refer to https://slock.it    *
* For questions, please contact info@slock.it              *
***********************************************************/

pragma solidity ^0.4.25;

/// @title Registry for IN3-Servers
contract ServerRegistry {

    /// server has been registered or updated its registry props or deposit
    event LogServerRegistered(string url, uint props, address owner, uint deposit);

    ///  a caller requested to unregister a server.
    event LogServerUnregisterRequested(string url, address owner, address caller);

    /// the owner canceled the unregister-proccess
    event LogServerUnregisterCanceled(string url, address owner);

    /// a Server was convicted
    event LogServerConvicted(string url, address owner);

    /// a Server is removed
    event LogServerRemoved(string url, address owner);

    struct In3Server {
        string url;  // the url of the server
        address owner; // the owner, which is also the key to sign blockhashes
        uint deposit; // stored deposit
        uint props; // a list of properties-flags representing the capabilities of the server

        // unregister state
        uint128 unregisterTime; // earliest timestamp in to to call unregister
        uint128 unregisterDeposit; // Deposit for unregistering
        address unregisterCaller; // address of the caller requesting the unregister
    }

    /// server list of incubed nodes    
    In3Server[] public servers;

    // index for unique url and owner
    mapping (address => bool) ownerIndex;
    mapping (bytes32 => bool) urlIndex;
    
    /// length of the serverlist
    function totalServers() public view returns (uint)  {
        return servers.length;
    }

    /// register a new Server with the sender as owner    
    function registerServer(string _url, uint _props) public payable {
        checkLimits();

        bytes32 urlHash = keccak256(bytes(_url));

        // make sure this url and also this owner was not registered before.
        require (!urlIndex[urlHash] && !ownerIndex[msg.sender], "a Server with the same url or owner is already registered");

        // add new In3Server
        In3Server memory m;
        m.url = _url;
        m.props = _props;
        m.owner = msg.sender;
        m.deposit = msg.value;
        servers.push(m);

        // make sure they are used
        urlIndex[urlHash] = true;
        ownerIndex[msg.sender] = true;

        // emit event
        emit LogServerRegistered(_url, _props, msg.sender,msg.value);
    }

    /// updates a Server by adding the msg.value to the deposit and setting the props    
    function updateServer(uint _serverIndex, uint _props) public payable {
        checkLimits();

        In3Server storage server = servers[_serverIndex];
        require(server.owner == msg.sender, "only the owner may update the server");

        if (msg.value>0) 
          server.deposit += msg.value;

        if (_props!=server.props)
          server.props = _props;
        emit LogServerRegistered(server.url, _props, msg.sender,server.deposit);
    }

    /// this should be called before unregistering a server.
    /// there are 2 use cases:
    /// a) the owner wants to stop offering the service and remove the server.
    ///    in this case he has to wait for one hour before actually removing the server. 
    ///    This is needed in order to give others a chance to convict it in case this server signs wrong hashes
    /// b) anybody can request to remove a server because it has been inactive.
    ///    in this case he needs to pay a small deposit, which he will lose 
    //       if the owner become active again 
    //       or the caller will receive 20% of the deposit in case the owner does not react.
    function requestUnregisteringServer(uint _serverIndex) payable public {

        In3Server storage server = servers[_serverIndex];

        // this can only be called if nobody requested it before
        require(server.unregisterCaller == address(0x0), "Server is already unregistering");

        if (server.unregisterCaller == server.owner) 
           server.unregisterTime = uint128(now + 1 hours);
        else {
            server.unregisterTime = uint128(now + 28 days); // 28 days are always good ;-) 
            // the requester needs to pay the unregisterDeposit in order to spam-protect the server
            require(msg.value == calcUnregisterDeposit(_serverIndex), "the exact calcUnregisterDeposit is required to request unregister");
            server.unregisterDeposit = uint128(msg.value);
        }
        server.unregisterCaller = msg.sender;
        emit LogServerUnregisterRequested(server.url, server.owner, msg.sender);
    }
    
    /// this function must be called by the caller of the requestUnregisteringServer-function after 28 days
    /// if the owner did not cancel, the caller will receive 20% of the server deposit + his own deposit.
    /// the owner will receive 80% of the server deposit before the server will be removed.
    function confirmUnregisteringServer(uint _serverIndex) public {
        In3Server storage server = servers[_serverIndex];
        // this can only be called if somebody requested it before
        require(server.unregisterCaller != address(0x0) && server.unregisterTime < now, "Only the caller is allowed to confirm");

        uint payBackOwner = server.deposit;
        if (server.unregisterCaller != server.owner) {
            payBackOwner -= server.deposit / 5;  // the owner will only receive 80% of his deposit back.
            server.unregisterCaller.transfer(server.unregisterDeposit + server.deposit - payBackOwner);
        }

        if (payBackOwner > 0)
            server.owner.transfer(payBackOwner);

        removeServer(_serverIndex);
    }

    /// this function must be called by the owner to cancel the unregister-process.
    /// if the caller is not the owner, then he will also get the deposit paid by the caller.
    function cancelUnregisteringServer(uint _serverIndex) public {
        In3Server storage server = servers[_serverIndex];

        // this can only be called by the owner and if somebody requested it before
        require(server.unregisterCaller != address(0) && server.owner == msg.sender, "only the owner is allowed to cancel unregister");

        // if this was requested by somebody who does not own this server,
        // the owner will get his deposit
        if (server.unregisterCaller != server.owner) 
            server.owner.transfer(server.unregisterDeposit);

        // set back storage values
        server.unregisterCaller = address(0);
        server.unregisterTime = 0;
        server.unregisterDeposit = 0;

        /// emit event
        emit LogServerUnregisterCanceled(server.url, server.owner);
    }


    /// convicts a server that signed a wrong blockhash
    function convict(uint _serverIndex, bytes32 _blockhash, uint _blocknumber, uint8 _v, bytes32 _r, bytes32 _s) public {
        bytes32 evm_blockhash = blockhash(_blocknumber);
        
        // if the blockhash is correct you cannot convict the server
        require(evm_blockhash != 0x0 && evm_blockhash != _blockhash, "the block is too old or you try to convict with a correct hash");

        // make sure the hash was signed by the owner of the server
        require(
            ecrecover(keccak256(_blockhash, _blocknumber), _v, _r, _s) == servers[_serverIndex].owner, 
            "the block was not signed by the owner of the server");

        // remove the deposit
        if (servers[_serverIndex].deposit > 0) {
            uint payout = servers[_serverIndex].deposit / 2;
            // send 50% to the caller of this function
            msg.sender.transfer(payout);

            // and burn the rest by sending it to the 0x0-address
            // this is done in order to make it useless trying to convict your own server with a second account
            // and this getting all the deposit back after signing a wrong hash.
            address(0).transfer(servers[_serverIndex].deposit-payout);
        }

        // emit event
        emit LogServerConvicted(servers[_serverIndex].url, servers[_serverIndex].owner );
        
        removeServer(_serverIndex);
    }

    /// calculates the minimum deposit you need to pay in order to request unregistering of a server.
    function calcUnregisterDeposit(uint _serverIndex) public view returns(uint128) {
         // cancelUnregisteringServer costs 22k gas, we took about twist that much due to volatility of gasPrices
        return uint128(servers[_serverIndex].deposit / 50 + tx.gasprice * 50000);
    }

    // internal helper functions
    
    function removeServer(uint _serverIndex) internal {
        // trigger event
        emit LogServerRemoved(servers[_serverIndex].url, servers[_serverIndex].owner);

        // remove from unique index
        urlIndex[keccak256(bytes(servers[_serverIndex].url))] = false;
        ownerIndex[servers[_serverIndex].owner] = false;

        uint length = servers.length;
        if (length>0) {
            // move the last entry to the removed one.
            In3Server memory m = servers[length - 1];
            servers[_serverIndex] = m;
        }
        servers.length--;
    }

    function checkLimits() internal view {
        // within the next 6 months this contract may never hold more than 50 ETH
        if (now < 1560808800)
           require(address(this).balance < 50 ether, "Limit of 50 ETH reached");
    }

}