/*
This file is part of the DAO.
000000000000000000000000bb9bc244d798123fde783fcc1c72d3bb8c189413

Account 0xB3267B3B37a1C153Ca574c3A50359f9d1613F95d
dthPool 0xB256D572885A5246DDbF548F39da57f5f8074b9a

Hello all! I just deployed the first DTHPool (Delegate) in the real net.
The delegate in this contract is myself. My intention is not to be a stable delegate but to construct a repository of delegates where DTH’s can choose.
I tested to delegate and undelegate some tokens. I also set up the votes for the proposals made to the DAO until now. 
If any body wants to delegate me some tokens, he will be wellcome!. You can also check the votes set up and his motivations. 
I'll appreciate any feedback.
If any body wants to be a delegate, I’m absolutely open to help him to deploy the contract.


The DAO is free software: you can redistribute it and/or modify
it under the terms of the GNU lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The DAO is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the DAO.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
This file is part of the DAO.

The DAO is free software: you can redistribute it and/or modify
it under the terms of the GNU lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The DAO is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the DAO.  If not, see <http://www.gnu.org/licenses/>.
*/


// <ORACLIZE_API>
/*
Copyright (c) 2015-2016 Oraclize srl, Thomas Bertani



Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:



The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

contract OraclizeI {
    address public cbAddress;
    function query(uint _timestamp, string _datasource, string _arg) returns (bytes32 _id);
    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) returns (bytes32 _id);
    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) returns (bytes32 _id);
    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) returns (bytes32 _id);
    function getPrice(string _datasource) returns (uint _dsprice);
    function getPrice(string _datasource, uint gaslimit) returns (uint _dsprice);
    function useCoupon(string _coupon);
    function setProofType(byte _proofType);
}
contract OraclizeAddrResolverI {
    function getAddress() returns (address _addr);
}
contract usingOraclize {
    uint constant day = 60*60*24;
    uint constant week = 60*60*24*7;
    uint constant month = 60*60*24*30;
    byte constant proofType_NONE = 0x00;
    byte constant proofType_TLSNotary = 0x10;
    byte constant proofStorage_IPFS = 0x01;
    uint8 constant networkID_auto = 0;
    uint8 constant networkID_mainnet = 1;
    uint8 constant networkID_testnet = 2;
    uint8 constant networkID_morden = 2;
    uint8 constant networkID_consensys = 161;

    OraclizeAddrResolverI OAR;

    OraclizeI oraclize;
    modifier oraclizeAPI {
        address oraclizeAddr = OAR.getAddress();
        if (oraclizeAddr == 0){
            oraclize_setNetwork(networkID_auto);
            oraclizeAddr = OAR.getAddress();
        }
        oraclize = OraclizeI(oraclizeAddr);
        _
    }
    modifier coupon(string code){
        oraclize = OraclizeI(OAR.getAddress());
        oraclize.useCoupon(code);
        _
    }

    function oraclize_setNetwork(uint8 networkID) internal returns(bool){
        if (getCodeSize(0x1d3b2638a7cc9f2cb3d298a3da7a90b67e5506ed)>0){
            OAR = OraclizeAddrResolverI(0x1d3b2638a7cc9f2cb3d298a3da7a90b67e5506ed);
            return true;
        }
        if (getCodeSize(0x9efbea6358bed926b293d2ce63a730d6d98d43dd)>0){
            OAR = OraclizeAddrResolverI(0x9efbea6358bed926b293d2ce63a730d6d98d43dd);
            return true;
        }
        if (getCodeSize(0x20e12a1f859b3feae5fb2a0a32c18f5a65555bbf)>0){
            OAR = OraclizeAddrResolverI(0x20e12a1f859b3feae5fb2a0a32c18f5a65555bbf);
            return true;
        }
        return false;
    }

    function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(0, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(timestamp, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(0, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(0, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(timestamp, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_cbAddress() oraclizeAPI internal returns (address){
        return oraclize.cbAddress();
    }
    function oraclize_setProof(byte proofP) oraclizeAPI internal {
        return oraclize.setProofType(proofP);
    }

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
    }


    function parseAddr(string _a) internal returns (address){
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i=2; i<2+2*20; i+=2){
            iaddr *= 256;
            b1 = uint160(tmp[i]);
            b2 = uint160(tmp[i+1]);
            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
            iaddr += (b1*16+b2);
        }
        return address(iaddr);
    }


    function strCompare(string _a, string _b) internal returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
   }

    function indexOf(string _haystack, string _needle) internal returns (int)
    {
        bytes memory h = bytes(_haystack);
        bytes memory n = bytes(_needle);
        if(h.length < 1 || n.length < 1 || (n.length > h.length))
            return -1;
        else if(h.length > (2**128 -1))
            return -1;
        else
        {
            uint subindex = 0;
            for (uint i = 0; i < h.length; i ++)
            {
                if (h[i] == n[0])
                {
                    subindex = 1;
                    while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex])
                    {
                        subindex++;
                    }
                    if(subindex == n.length)
                        return int(i);
                }
            }
            return -1;
        }
    }

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat(string _a, string _b, string _c, string _d) internal returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c) internal returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string _a, string _b) internal returns (string) {
        return strConcat(_a, _b, "", "", "");
    }

    // parseInt
    function parseInt(string _a) internal returns (uint) {
        return parseInt(_a, 0);
    }

    // parseInt(parseFloat*10^_b)
    function parseInt(string _a, uint _b) internal returns (uint) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i=0; i<bresult.length; i++){
            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){
                if (decimals){
                   if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        return mint;
    }


}
// </ORACLIZE_API>


/*
Basic, standardized Token contract with no "premine". Defines the functions to
check token balances, send tokens, send tokens on behalf of a 3rd party and the
corresponding approval process. Tokens need to be created by a derived
contract (e.g. TokenCreation.sol).

Thank you ConsenSys, this contract originated from:
https://github.com/ConsenSys/Tokens/blob/master/Token_Contracts/contracts/Standard_Token.sol
Which is itself based on the Ethereum standardized contract APIs:
https://github.com/ethereum/wiki/wiki/Standardized_Contract_APIs
*/

/// @title Standard Token Contract.

contract TokenInterface {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    /// Public variables of the token, all used for display 
    string public name;
    string public symbol;
    uint8 public decimals;
    string public standard = 'Token 0.1';

    /// Total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _amount) returns (bool success);

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    /// is approved by `_from`
    /// @param _from The address of the origin of the transfer
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _amount) returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    /// its behalf
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _amount) returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed
    /// to spend
    function allowance(
        address _owner,
        address _spender
    ) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
    );
}

contract tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); 
}

contract Token is TokenInterface {
    // Protects users by preventing the execution of method calls that
    // inadvertently also transferred ether
    modifier noEther() {if (msg.value > 0) throw; _}

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _amount) noEther returns (bool success) {
        if (balances[msg.sender] >= _amount && _amount > 0) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
           return false;
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) noEther returns (bool success) {

        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0) {

            balances[_to] += _amount;
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
    
    /// Allow another contract to spend some tokens in your behalf 
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        tokenRecipient spender = tokenRecipient(_spender);
        spender.receiveApproval(msg.sender, _value, this, _extraData);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}


/*
This file is part of the DAO.

The DAO is free software: you can redistribute it and/or modify
it under the terms of the GNU lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The DAO is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the DAO.  If not, see <http://www.gnu.org/licenses/>.
*/

/////////////////////
// There is a solidity bug in the return parameters that it's not solved
// when the bug is solved, the import from DAO is more clean.
// In the meantime, a workaround proxy is defined

// Uncoment this line when error fixed
// import "./DAO.sol";

// Workaround proxy remove when fixed
contract DAO {
    function proposals(uint _proposalID) returns(
        address recipient,
        uint amount,
        uint descriptionIdx,
        uint votingDeadline,
        bool open,
        bool proposalPassed,
        bytes32 proposalHash,
        uint proposalDeposit,
        bool newCurator
    );

    function transfer(address _to, uint256 _amount) returns (bool success);

    function transferFrom(address _from, address _to, uint256 _amount) returns (bool success);

    function vote(
        uint _proposalID,
        bool _supportsProposal
    ) returns (uint _voteID);

    function balanceOf(address _owner) constant returns (uint256 balance);
}
// End of workaround proxy
////////////////////


contract DTHPoolInterface {

    // delegae url
    string public delegateUrl;

    // Max time the tokens can be blocked.
    // The real voting in the DAO will be called in the last moment in order
    // to block the tokens for the minimum time. This parameter defines the
    // seconds before the voting period ends that the vote can be performed
    uint maxTimeBlocked;


    // Address of the delegate
    address public delegate;

    // The DAO contract
    address public daoAddress;

    struct ProposalStatus {

        // True when the delegate sets the vote
        bool voteSet;

        // True if the proposal should ve voted
        bool willVote;

        // True if the proposal should be accepted.
        bool suportProposal;

        // True when the vote is performed;
        bool executed;

        // Proposal votingDeadline
        uint votingDeadline;

        // String set by the delegator with the motivation
        string motivation;
    }

    // Statuses of the diferent proposal
    mapping (uint => ProposalStatus) public proposalStatuses;


    // Index of proposals by oraclizeId
    mapping (bytes32 => uint) public oraclizeId2proposalId;

    /// @dev Constructor setting the dao address and the delegate
    /// @param _daoAddress address of the DAO
    /// @param _delegate adddress of the delegate.
    /// @param _maxTimeBlocked the maximum time the tokens will be blocked
    /// @param _delegateName Name of the delegate
    /// @param _delegateUrl Url of the delegate
    /// @param _tokenSymbol token  symbol.
    // DTHPool(address _daoAddress, address _delegate, uint _maxTimeBlocked, string _delegateName, string _delegateUrl, string _tokenSymbol);


    /// @notice send votes to this contract.
    /// @param _amount Tokens that will be transfered to the pool.
    /// @return Whether the transfer was successful or not
    function delegateDAOTokens(uint _amount) returns (bool _success);

    /// Returns DAO tokens to the original
    /// @param _amount that will be transfered back to the owner.
    /// @return Whether the transfer was successful or not
    function undelegateDAOTokens(uint _amount) returns (bool _success);


    /// @notice This method will be called by the delegate to publish what will
    /// be his vote in a specific proposal.
    /// @param _proposalID The proposal to set the vote.
    /// @param _willVote true If the proposal will be voted.
    /// @param _supportsProposal What will be the vote.
    function setVoteIntention(
        uint _proposalID,
        bool _willVote,
        bool _supportsProposal,
        string _motivation
    ) returns (bool _success);

    /// @notice This method will be doing the actual voting in the DAO
    /// for the _proposalID
    /// @param _proposalID The proposal to set the vote.
    /// @return _finalized true if this vote Proposal must not be executed again.
    function executeVote(uint _proposalID) returns (bool _finalized);


    /// @notice This function is intended because if some body sends tokens
    /// directly to this contract, the tokens can be sent to the delegate
    function fixTokens() returns (bool _success);


    /// @notice If some body sends ether to this contract, the delegate will be
    /// able to extract it.
    function getEther() returns (uint _amount);

    /// @notice Called when some body delegates token to the pool
    event Delegate(address indexed _from, uint256 _amount);

    /// @notice Called when some body undelegates token to the pool
    event Undelegate(address indexed _from, uint256 _amount);

    /// @notice Called when the delegate set se vote intention
    event VoteIntentionSet(uint indexed _proposalID, bool _willVote, bool _supportsProposal);

    /// @notice Called when the vote is executed in the DAO
    event VoteExecuted(uint indexed _proposalID);

}

contract DTHPool is DTHPoolInterface, Token, usingOraclize {

    modifier onlyDelegate() {if (msg.sender != delegate) throw; _}

    // DTHPool(address _daoAddress, address _delegate, uint _maxTimeBlocked, string _delegateName, string _delegateUrl, string _tokenSymbol);

    function DTHPool(
        address _daoAddress,
        address _delegate,
        uint _maxTimeBlocked,
        string _delegateName,
        string _delegateUrl,
        string _tokenSymbol
    ) {
        daoAddress = _daoAddress;
        delegate = _delegate;
        delegateUrl = _delegateUrl;
        maxTimeBlocked = _maxTimeBlocked;
        name = _delegateName;
        symbol = _tokenSymbol;
        decimals = 16;
        oraclize_setNetwork(networkID_auto);
    }

    function delegateDAOTokens(uint _amount) returns (bool _success) {
        DAO dao = DAO(daoAddress);
        if (!dao.transferFrom(msg.sender, address(this), _amount)) {
            throw;
        }

        balances[msg.sender] += _amount;
        totalSupply += _amount;
        Delegate(msg.sender, _amount);
        return true;
    }

    function undelegateDAOTokens(uint _amount) returns (bool _success) {
        DAO dao = DAO(daoAddress);
        if (_amount > balances[msg.sender]) {
            throw;
        }

        if (!dao.transfer(msg.sender, _amount)) {
            throw;
        }

        balances[msg.sender] -= _amount;
        totalSupply -= _amount;
        Undelegate(msg.sender, _amount);
        return true;
    }

    function setVoteIntention(
        uint _proposalID,
        bool _willVote,
        bool _supportsProposal,
        string _motivation
    ) onlyDelegate returns (bool _success) {
        DAO dao = DAO(daoAddress);

        ProposalStatus proposalStatus = proposalStatuses[_proposalID];

        if (proposalStatus.voteSet) {
            throw;
        }

        var (,,,votingDeadline, ,,,,newCurator) = dao.proposals(_proposalID);

        if (votingDeadline < now || newCurator ) {
            throw;
        }

        proposalStatus.voteSet = true;
        proposalStatus.willVote = _willVote;
        proposalStatus.suportProposal = _supportsProposal;
        proposalStatus.votingDeadline = votingDeadline;
        proposalStatus.motivation = _motivation;

        VoteIntentionSet(_proposalID, _willVote, _supportsProposal);

        if (!_willVote) {
            proposalStatus.executed = true;
            VoteExecuted(_proposalID);
        }

        bool finalized = executeVote(_proposalID);

        if ((!finalized)&&(address(OAR) != 0)) {
            bytes32 oraclizeId = oraclize_query(votingDeadline - maxTimeBlocked +15, "URL", "");

            oraclizeId2proposalId[oraclizeId] = _proposalID;
        }

        return true;
    }

    function executeVote(uint _proposalID) returns (bool _finalized) {
        DAO dao = DAO(daoAddress);
        ProposalStatus proposalStatus = proposalStatuses[_proposalID];

        if (!proposalStatus.voteSet
            || now > proposalStatus.votingDeadline
            || !proposalStatus.willVote
            || proposalStatus.executed) {

            return true;
        }

        if (now < proposalStatus.votingDeadline - maxTimeBlocked) {
            return false;
        }

        dao.vote(_proposalID, proposalStatus.suportProposal);
        proposalStatus.executed = true;
        VoteExecuted(_proposalID);

        return true;
    }

    function __callback(bytes32 oid, string result) {
        uint proposalId = oraclizeId2proposalId[oid];
        executeVote(proposalId);
        oraclizeId2proposalId[oid] = 0;
    }

    function fixTokens() returns (bool _success) {
        DAO dao = DAO(daoAddress);
        uint ownedTokens = dao.balanceOf(this);
        if (ownedTokens < totalSupply) {
            throw;
        }
        uint fixTokens = ownedTokens - totalSupply;

        if (fixTokens == 0) {
            return true;
        }

        balances[delegate] += fixTokens;
        totalSupply += fixTokens;

        return true;
    }

    function getEther() onlyDelegate returns (uint _amount) {
        uint amount = this.balance;

        if (!delegate.call.value(amount)()) {
            throw;
        }

        return amount;
    }

}