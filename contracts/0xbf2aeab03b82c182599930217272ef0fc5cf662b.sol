pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

library ECTools {

    // @dev Recovers the address which has signed a message
    // @thanks https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
    function recoverSigner(bytes32 _hashedMsg, string _sig) public pure returns (address) {
        require(_hashedMsg != 0x00);

        // need this for test RPC
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, _hashedMsg));

        if (bytes(_sig).length != 132) {
            return 0x0;
        }
        bytes32 r;
        bytes32 s;
        uint8 v;
        bytes memory sig = hexstrToBytes(substring(_sig, 2, 132));
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        if (v < 27) {
            v += 27;
        }
        if (v < 27 || v > 28) {
            return 0x0;
        }
        return ecrecover(prefixedHash, v, r, s);
    }

    // @dev Verifies if the message is signed by an address
    function isSignedBy(bytes32 _hashedMsg, string _sig, address _addr) public pure returns (bool) {
        require(_addr != 0x0);

        return _addr == recoverSigner(_hashedMsg, _sig);
    }

    // @dev Converts an hexstring to bytes
    function hexstrToBytes(string _hexstr) public pure returns (bytes) {
        uint len = bytes(_hexstr).length;
        require(len % 2 == 0);

        bytes memory bstr = bytes(new string(len / 2));
        uint k = 0;
        string memory s;
        string memory r;
        for (uint i = 0; i < len; i += 2) {
            s = substring(_hexstr, i, i + 1);
            r = substring(_hexstr, i + 1, i + 2);
            uint p = parseInt16Char(s) * 16 + parseInt16Char(r);
            bstr[k++] = uintToBytes32(p)[31];
        }
        return bstr;
    }

    // @dev Parses a hexchar, like 'a', and returns its hex value, in this case 10
    function parseInt16Char(string _char) public pure returns (uint) {
        bytes memory bresult = bytes(_char);
        // bool decimals = false;
        if ((bresult[0] >= 48) && (bresult[0] <= 57)) {
            return uint(bresult[0]) - 48;
        } else if ((bresult[0] >= 65) && (bresult[0] <= 70)) {
            return uint(bresult[0]) - 55;
        } else if ((bresult[0] >= 97) && (bresult[0] <= 102)) {
            return uint(bresult[0]) - 87;
        } else {
            revert();
        }
    }

    // @dev Converts a uint to a bytes32
    // @thanks https://ethereum.stackexchange.com/questions/4170/how-to-convert-a-uint-to-bytes-in-solidity
    function uintToBytes32(uint _uint) public pure returns (bytes b) {
        b = new bytes(32);
        assembly {mstore(add(b, 32), _uint)}
    }

    // @dev Hashes the signed message
    // @ref https://github.com/ethereum/go-ethereum/issues/3731#issuecomment-293866868
    function toEthereumSignedMessage(string _msg) public pure returns (bytes32) {
        uint len = bytes(_msg).length;
        require(len > 0);
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        return keccak256(abi.encodePacked(prefix, uintToString(len), _msg));
    }

    // @dev Converts a uint in a string
    function uintToString(uint _uint) public pure returns (string str) {
        uint len = 0;
        uint m = _uint + 0;
        while (m != 0) {
            len++;
            m /= 10;
        }
        bytes memory b = new bytes(len);
        uint i = len - 1;
        while (_uint != 0) {
            uint remainder = _uint % 10;
            _uint = _uint / 10;
            b[i--] = byte(48 + remainder);
        }
        str = string(b);
    }


    // @dev extract a substring
    // @thanks https://ethereum.stackexchange.com/questions/31457/substring-in-solidity
    function substring(string _str, uint _startIndex, uint _endIndex) public pure returns (string) {
        bytes memory strBytes = bytes(_str);
        require(_startIndex <= _endIndex);
        require(_startIndex >= 0);
        require(_endIndex <= strBytes.length);

        bytes memory result = new bytes(_endIndex - _startIndex);
        for (uint i = _startIndex; i < _endIndex; i++) {
            result[i - _startIndex] = strBytes[i];
        }
        return string(result);
    }
}
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ChannelManager {
    using SafeMath for uint256;

    string public constant NAME = "Channel Manager";
    string public constant VERSION = "0.0.1";

    address public hub;
    uint256 public challengePeriod;
    ERC20 public approvedToken;

    uint256 public totalChannelWei;
    uint256 public totalChannelToken;

    event DidHubContractWithdraw (
        uint256 weiAmount,
        uint256 tokenAmount
    );

    // Note: the payload of DidUpdateChannel contains the state that caused
    // the update, not the state post-update (ex, if the update contains a
    // deposit, the event's ``pendingDeposit`` field will be present and the
    // event's ``balance`` field will not have been updated to reflect that
    // balance).
    event DidUpdateChannel (
        address indexed user,
        uint256 senderIdx, // 0: hub, 1: user
        uint256[2] weiBalances, // [hub, user]
        uint256[2] tokenBalances, // [hub, user]
        uint256[4] pendingWeiUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
        uint256[4] pendingTokenUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
        uint256[2] txCount, // [global, onchain]
        bytes32 threadRoot,
        uint256 threadCount
    );

    // Note: unlike the DidUpdateChannel event, the ``DidStartExitChannel``
    // event will contain the channel state after any state that has been
    // applied as part of startExitWithUpdate.
    event DidStartExitChannel (
        address indexed user,
        uint256 senderIdx, // 0: hub, 1: user
        uint256[2] weiBalances, // [hub, user]
        uint256[2] tokenBalances, // [hub, user]
        uint256[2] txCount, // [global, onchain]
        bytes32 threadRoot,
        uint256 threadCount
    );

    event DidEmptyChannel (
        address indexed user,
        uint256 senderIdx, // 0: hub, 1: user
        uint256[2] weiBalances, // [hub, user]
        uint256[2] tokenBalances, // [hub, user]
        uint256[2] txCount, // [global, onchain]
        bytes32 threadRoot,
        uint256 threadCount
    );

    event DidStartExitThread (
        address user,
        address indexed sender,
        address indexed receiver,
        uint256 threadId,
        address senderAddress, // either hub or user
        uint256[2] weiBalances, // [sender, receiver]
        uint256[2] tokenBalances, // [sender, receiver]
        uint256 txCount
    );

    event DidChallengeThread (
        address indexed sender,
        address indexed receiver,
        uint256 threadId,
        address senderAddress, // can be either hub, sender, or receiver
        uint256[2] weiBalances, // [sender, receiver]
        uint256[2] tokenBalances, // [sender, receiver]
        uint256 txCount
    );

    event DidEmptyThread (
        address user,
        address indexed sender,
        address indexed receiver,
        uint256 threadId,
        address senderAddress, // can be anyone
        uint256[2] channelWeiBalances,
        uint256[2] channelTokenBalances,
        uint256[2] channelTxCount,
        bytes32 channelThreadRoot,
        uint256 channelThreadCount
    );

    event DidNukeThreads(
        address indexed user,
        address senderAddress, // can be anyone
        uint256 weiAmount, // amount of wei sent
        uint256 tokenAmount, // amount of tokens sent
        uint256[2] channelWeiBalances,
        uint256[2] channelTokenBalances,
        uint256[2] channelTxCount,
        bytes32 channelThreadRoot,
        uint256 channelThreadCount
    );

    enum ChannelStatus {
       Open,
       ChannelDispute,
       ThreadDispute
    }

    struct Channel {
        uint256[3] weiBalances; // [hub, user, total]
        uint256[3] tokenBalances; // [hub, user, total]
        uint256[2] txCount; // persisted onchain even when empty [global, pending]
        bytes32 threadRoot;
        uint256 threadCount;
        address exitInitiator;
        uint256 channelClosingTime;
        ChannelStatus status;
    }

    struct Thread {
        uint256[2] weiBalances; // [sender, receiver]
        uint256[2] tokenBalances; // [sender, receiver]
        uint256 txCount; // persisted onchain even when empty
        uint256 threadClosingTime;
        bool[2] emptied; // [sender, receiver]
    }

    mapping(address => Channel) public channels;
    mapping(address => mapping(address => mapping(uint256 => Thread))) threads; // threads[sender][receiver][threadId]

    bool locked;

    modifier onlyHub() {
        require(msg.sender == hub);
        _;
    }

    modifier noReentrancy() {
        require(!locked, "Reentrant call.");
        locked = true;
        _;
        locked = false;
    }

    constructor(address _hub, uint256 _challengePeriod, address _tokenAddress) public {
        hub = _hub;
        challengePeriod = _challengePeriod;
        approvedToken = ERC20(_tokenAddress);
    }

    function hubContractWithdraw(uint256 weiAmount, uint256 tokenAmount) public noReentrancy onlyHub {
        require(
            getHubReserveWei() >= weiAmount,
            "hubContractWithdraw: Contract wei funds not sufficient to withdraw"
        );
        require(
            getHubReserveTokens() >= tokenAmount,
            "hubContractWithdraw: Contract token funds not sufficient to withdraw"
        );

        hub.transfer(weiAmount);
        require(
            approvedToken.transfer(hub, tokenAmount),
            "hubContractWithdraw: Token transfer failure"
        );

        emit DidHubContractWithdraw(weiAmount, tokenAmount);
    }

    function getHubReserveWei() public view returns (uint256) {
        return address(this).balance.sub(totalChannelWei);
    }

    function getHubReserveTokens() public view returns (uint256) {
        return approvedToken.balanceOf(address(this)).sub(totalChannelToken);
    }

    function hubAuthorizedUpdate(
        address user,
        address recipient,
        uint256[2] weiBalances, // [hub, user]
        uint256[2] tokenBalances, // [hub, user]
        uint256[4] pendingWeiUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
        uint256[4] pendingTokenUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
        uint256[2] txCount, // [global, onchain] persisted onchain even when empty
        bytes32 threadRoot,
        uint256 threadCount,
        uint256 timeout,
        string sigUser
    ) public noReentrancy onlyHub {
        Channel storage channel = channels[user];

        _verifyAuthorizedUpdate(
            channel,
            txCount,
            weiBalances,
            tokenBalances,
            pendingWeiUpdates,
            pendingTokenUpdates,
            timeout,
            true
        );

        _verifySig(
            [user, recipient],
            weiBalances,
            tokenBalances,
            pendingWeiUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
            pendingTokenUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
            txCount,
            threadRoot,
            threadCount,
            timeout,
            "", // skip hub sig verification
            sigUser,
            [false, true] // [checkHubSig?, checkUser] <- only need to check user
        );

        _updateChannelBalances(channel, weiBalances, tokenBalances, pendingWeiUpdates, pendingTokenUpdates);

        // transfer wei and token to recipient
        recipient.transfer(pendingWeiUpdates[3]);
        require(approvedToken.transfer(recipient, pendingTokenUpdates[3]), "user token withdrawal transfer failed");

        // update state variables
        channel.txCount = txCount;
        channel.threadRoot = threadRoot;
        channel.threadCount = threadCount;

        emit DidUpdateChannel(
            user,
            0, // senderIdx
            weiBalances,
            tokenBalances,
            pendingWeiUpdates,
            pendingTokenUpdates,
            txCount,
            threadRoot,
            threadCount
        );
    }

    function userAuthorizedUpdate(
        address recipient,
        uint256[2] weiBalances, // [hub, user]
        uint256[2] tokenBalances, // [hub, user]
        uint256[4] pendingWeiUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
        uint256[4] pendingTokenUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
        uint256[2] txCount, // persisted onchain even when empty
        bytes32 threadRoot,
        uint256 threadCount,
        uint256 timeout,
        string sigHub
    ) public payable noReentrancy {
        require(msg.value == pendingWeiUpdates[2], "msg.value is not equal to pending user deposit");

        Channel storage channel = channels[msg.sender];

        _verifyAuthorizedUpdate(
            channel,
            txCount,
            weiBalances,
            tokenBalances,
            pendingWeiUpdates,
            pendingTokenUpdates,
            timeout,
            false
        );

        _verifySig(
            [msg.sender, recipient],
            weiBalances,
            tokenBalances,
            pendingWeiUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
            pendingTokenUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
            txCount,
            threadRoot,
            threadCount,
            timeout,
            sigHub,
            "", // skip user sig verification
            [true, false] // [checkHubSig?, checkUser] <- only need to check hub
        );

        // transfer user token deposit to this contract
        require(approvedToken.transferFrom(msg.sender, address(this), pendingTokenUpdates[2]), "user token deposit failed");

        _updateChannelBalances(channel, weiBalances, tokenBalances, pendingWeiUpdates, pendingTokenUpdates);

        // transfer wei and token to recipient
        recipient.transfer(pendingWeiUpdates[3]);
        require(approvedToken.transfer(recipient, pendingTokenUpdates[3]), "user token withdrawal transfer failed");

        // update state variables
        channel.txCount = txCount;
        channel.threadRoot = threadRoot;
        channel.threadCount = threadCount;

        emit DidUpdateChannel(
            msg.sender,
            1, // senderIdx
            weiBalances,
            tokenBalances,
            pendingWeiUpdates,
            pendingTokenUpdates,
            channel.txCount,
            channel.threadRoot,
            channel.threadCount
        );
    }

    /**********************
     * Unilateral Functions
     *********************/

    // start exit with onchain state
    function startExit(
        address user
    ) public noReentrancy {
        require(user != hub, "user can not be hub");
        require(user != address(this), "user can not be channel manager");

        Channel storage channel = channels[user];
        require(channel.status == ChannelStatus.Open, "channel must be open");

        require(msg.sender == hub || msg.sender == user, "exit initiator must be user or hub");

        channel.exitInitiator = msg.sender;
        channel.channelClosingTime = now.add(challengePeriod);
        channel.status = ChannelStatus.ChannelDispute;

        emit DidStartExitChannel(
            user,
            msg.sender == hub ? 0 : 1,
            [channel.weiBalances[0], channel.weiBalances[1]],
            [channel.tokenBalances[0], channel.tokenBalances[1]],
            channel.txCount,
            channel.threadRoot,
            channel.threadCount
        );
    }

    // start exit with offchain state
    function startExitWithUpdate(
        address[2] user, // [user, recipient]
        uint256[2] weiBalances, // [hub, user]
        uint256[2] tokenBalances, // [hub, user]
        uint256[4] pendingWeiUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
        uint256[4] pendingTokenUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
        uint256[2] txCount, // [global, onchain] persisted onchain even when empty
        bytes32 threadRoot,
        uint256 threadCount,
        uint256 timeout,
        string sigHub,
        string sigUser
    ) public noReentrancy {
        Channel storage channel = channels[user[0]];
        require(channel.status == ChannelStatus.Open, "channel must be open");

        require(msg.sender == hub || msg.sender == user[0], "exit initiator must be user or hub");

        require(timeout == 0, "can't start exit with time-sensitive states");

        _verifySig(
            user,
            weiBalances,
            tokenBalances,
            pendingWeiUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
            pendingTokenUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
            txCount,
            threadRoot,
            threadCount,
            timeout,
            sigHub,
            sigUser,
            [true, true] // [checkHubSig?, checkUser] <- check both sigs
        );

        require(txCount[0] > channel.txCount[0], "global txCount must be higher than the current global txCount");
        require(txCount[1] >= channel.txCount[1], "onchain txCount must be higher or equal to the current onchain txCount");

        // offchain wei/token balances do not exceed onchain total wei/token
        require(weiBalances[0].add(weiBalances[1]) <= channel.weiBalances[2], "wei must be conserved");
        require(tokenBalances[0].add(tokenBalances[1]) <= channel.tokenBalances[2], "tokens must be conserved");

        // pending onchain txs have been executed - force update offchain state to reflect this
        if (txCount[1] == channel.txCount[1]) {
            _applyPendingUpdates(channel.weiBalances, weiBalances, pendingWeiUpdates);
            _applyPendingUpdates(channel.tokenBalances, tokenBalances, pendingTokenUpdates);

        // pending onchain txs have *not* been executed - revert pending deposits and withdrawals back into offchain balances
        } else { //txCount[1] > channel.txCount[1]
            _revertPendingUpdates(channel.weiBalances, weiBalances, pendingWeiUpdates);
            _revertPendingUpdates(channel.tokenBalances, tokenBalances, pendingTokenUpdates);
        }

        // update state variables
        // only update txCount[0] (global)
        // - txCount[1] should only be updated by user/hubAuthorizedUpdate
        channel.txCount[0] = txCount[0];
        channel.threadRoot = threadRoot;
        channel.threadCount = threadCount;

        channel.exitInitiator = msg.sender;
        channel.channelClosingTime = now.add(challengePeriod);
        channel.status = ChannelStatus.ChannelDispute;

        emit DidStartExitChannel(
            user[0],
            msg.sender == hub ? 0 : 1,
            [channel.weiBalances[0], channel.weiBalances[1]],
            [channel.tokenBalances[0], channel.tokenBalances[1]],
            channel.txCount,
            channel.threadRoot,
            channel.threadCount
        );
    }

    // party that didn't start exit can challenge and empty
    function emptyChannelWithChallenge(
        address[2] user,
        uint256[2] weiBalances, // [hub, user]
        uint256[2] tokenBalances, // [hub, user]
        uint256[4] pendingWeiUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
        uint256[4] pendingTokenUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
        uint256[2] txCount, // persisted onchain even when empty
        bytes32 threadRoot,
        uint256 threadCount,
        uint256 timeout,
        string sigHub,
        string sigUser
    ) public noReentrancy {
        Channel storage channel = channels[user[0]];
        require(channel.status == ChannelStatus.ChannelDispute, "channel must be in dispute");
        require(now < channel.channelClosingTime, "channel closing time must not have passed");

        require(msg.sender != channel.exitInitiator, "challenger can not be exit initiator");
        require(msg.sender == hub || msg.sender == user[0], "challenger must be either user or hub");

        require(timeout == 0, "can't start exit with time-sensitive states");

        _verifySig(
            user,
            weiBalances,
            tokenBalances,
            pendingWeiUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
            pendingTokenUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
            txCount,
            threadRoot,
            threadCount,
            timeout,
            sigHub,
            sigUser,
            [true, true] // [checkHubSig?, checkUser] <- check both sigs
        );

        require(txCount[0] > channel.txCount[0], "global txCount must be higher than the current global txCount");
        require(txCount[1] >= channel.txCount[1], "onchain txCount must be higher or equal to the current onchain txCount");

        // offchain wei/token balances do not exceed onchain total wei/token
        require(weiBalances[0].add(weiBalances[1]) <= channel.weiBalances[2], "wei must be conserved");
        require(tokenBalances[0].add(tokenBalances[1]) <= channel.tokenBalances[2], "tokens must be conserved");

        // pending onchain txs have been executed - force update offchain state to reflect this
        if (txCount[1] == channel.txCount[1]) {
            _applyPendingUpdates(channel.weiBalances, weiBalances, pendingWeiUpdates);
            _applyPendingUpdates(channel.tokenBalances, tokenBalances, pendingTokenUpdates);

        // pending onchain txs have *not* been executed - revert pending deposits and withdrawals back into offchain balances
        } else { //txCount[1] > channel.txCount[1]
            _revertPendingUpdates(channel.weiBalances, weiBalances, pendingWeiUpdates);
            _revertPendingUpdates(channel.tokenBalances, tokenBalances, pendingTokenUpdates);
        }

        // deduct hub/user wei/tokens from total channel balances
        channel.weiBalances[2] = channel.weiBalances[2].sub(channel.weiBalances[0]).sub(channel.weiBalances[1]);
        channel.tokenBalances[2] = channel.tokenBalances[2].sub(channel.tokenBalances[0]).sub(channel.tokenBalances[1]);

        // transfer hub wei balance from channel to reserves
        totalChannelWei = totalChannelWei.sub(channel.weiBalances[0]).sub(channel.weiBalances[1]);
        // transfer user wei balance to user
        user[0].transfer(channel.weiBalances[1]);
        channel.weiBalances[0] = 0;
        channel.weiBalances[1] = 0;

        // transfer hub token balance from channel to reserves
        totalChannelToken = totalChannelToken.sub(channel.tokenBalances[0]).sub(channel.tokenBalances[1]);
        // transfer user token balance to user
        require(approvedToken.transfer(user[0], channel.tokenBalances[1]), "user token withdrawal transfer failed");
        channel.tokenBalances[0] = 0;
        channel.tokenBalances[1] = 0;

        // update state variables
        // only update txCount[0] (global)
        // - txCount[1] should only be updated by user/hubAuthorizedUpdate
        channel.txCount[0] = txCount[0];
        channel.threadRoot = threadRoot;
        channel.threadCount = threadCount;

        if (channel.threadCount > 0) {
            channel.status = ChannelStatus.ThreadDispute;
        } else {
            channel.channelClosingTime = 0;
            channel.status = ChannelStatus.Open;
        }

        channel.exitInitiator = address(0x0);

        emit DidEmptyChannel(
            user[0],
            msg.sender == hub ? 0 : 1,
            [channel.weiBalances[0], channel.weiBalances[1]],
            [channel.tokenBalances[0], channel.tokenBalances[1]],
            channel.txCount,
            channel.threadRoot,
            channel.threadCount
        );
    }

    // after timer expires - anyone can call; even before timer expires, non-exit-initiating party can call
    function emptyChannel(
        address user
    ) public noReentrancy {
        require(user != hub, "user can not be hub");
        require(user != address(this), "user can not be channel manager");

        Channel storage channel = channels[user];
        require(channel.status == ChannelStatus.ChannelDispute, "channel must be in dispute");

        require(
          channel.channelClosingTime < now ||
          msg.sender != channel.exitInitiator && (msg.sender == hub || msg.sender == user),
          "channel closing time must have passed or msg.sender must be non-exit-initiating party"
        );

        // deduct hub/user wei/tokens from total channel balances
        channel.weiBalances[2] = channel.weiBalances[2].sub(channel.weiBalances[0]).sub(channel.weiBalances[1]);
        channel.tokenBalances[2] = channel.tokenBalances[2].sub(channel.tokenBalances[0]).sub(channel.tokenBalances[1]);

        // transfer hub wei balance from channel to reserves
        totalChannelWei = totalChannelWei.sub(channel.weiBalances[0]).sub(channel.weiBalances[1]);
        // transfer user wei balance to user
        user.transfer(channel.weiBalances[1]);
        channel.weiBalances[0] = 0;
        channel.weiBalances[1] = 0;

        // transfer hub token balance from channel to reserves
        totalChannelToken = totalChannelToken.sub(channel.tokenBalances[0]).sub(channel.tokenBalances[1]);
        // transfer user token balance to user
        require(approvedToken.transfer(user, channel.tokenBalances[1]), "user token withdrawal transfer failed");
        channel.tokenBalances[0] = 0;
        channel.tokenBalances[1] = 0;

        if (channel.threadCount > 0) {
            channel.status = ChannelStatus.ThreadDispute;
        } else {
            channel.channelClosingTime = 0;
            channel.status = ChannelStatus.Open;
        }

        channel.exitInitiator = address(0x0);

        emit DidEmptyChannel(
            user,
            msg.sender == hub ? 0 : 1,
            [channel.weiBalances[0], channel.weiBalances[1]],
            [channel.tokenBalances[0], channel.tokenBalances[1]],
            channel.txCount,
            channel.threadRoot,
            channel.threadCount
        );
    }

    // **********************
    // THREAD DISPUTE METHODS
    // **********************

    // either party starts exit with initial state
    function startExitThread(
        address user,
        address sender,
        address receiver,
        uint256 threadId,
        uint256[2] weiBalances, // [sender, receiver]
        uint256[2] tokenBalances, // [sender, receiver]
        bytes proof,
        string sig
    ) public noReentrancy {
        Channel storage channel = channels[user];
        require(channel.status == ChannelStatus.ThreadDispute, "channel must be in thread dispute phase");
        require(msg.sender == hub || msg.sender == user, "thread exit initiator must be user or hub");
        require(user == sender || user == receiver, "user must be thread sender or receiver");

        require(weiBalances[1] == 0 && tokenBalances[1] == 0, "initial receiver balances must be zero");

        Thread storage thread = threads[sender][receiver][threadId];

        require(thread.threadClosingTime == 0, "thread closing time must be zero");

        _verifyThread(sender, receiver, threadId, weiBalances, tokenBalances, 0, proof, sig, channel.threadRoot);

        thread.weiBalances = weiBalances;
        thread.tokenBalances = tokenBalances;
        thread.threadClosingTime = now.add(challengePeriod);

        emit DidStartExitThread(
            user,
            sender,
            receiver,
            threadId,
            msg.sender,
            thread.weiBalances,
            thread.tokenBalances,
            thread.txCount
        );
    }

    // either party starts exit with offchain state
    function startExitThreadWithUpdate(
        address user,
        address[2] threadMembers, //[sender, receiver]
        uint256 threadId,
        uint256[2] weiBalances, // [sender, receiver]
        uint256[2] tokenBalances, // [sender, receiver]
        bytes proof,
        string sig,
        uint256[2] updatedWeiBalances, // [sender, receiver]
        uint256[2] updatedTokenBalances, // [sender, receiver]
        uint256 updatedTxCount,
        string updateSig
    ) public noReentrancy {
        Channel storage channel = channels[user];
        require(channel.status == ChannelStatus.ThreadDispute, "channel must be in thread dispute phase");
        require(msg.sender == hub || msg.sender == user, "thread exit initiator must be user or hub");
        require(user == threadMembers[0] || user == threadMembers[1], "user must be thread sender or receiver");

        require(weiBalances[1] == 0 && tokenBalances[1] == 0, "initial receiver balances must be zero");

        Thread storage thread = threads[threadMembers[0]][threadMembers[1]][threadId];
        require(thread.threadClosingTime == 0, "thread closing time must be zero");

        _verifyThread(threadMembers[0], threadMembers[1], threadId, weiBalances, tokenBalances, 0, proof, sig, channel.threadRoot);

        // *********************
        // PROCESS THREAD UPDATE
        // *********************

        require(updatedTxCount > 0, "updated thread txCount must be higher than 0");
        require(updatedWeiBalances[0].add(updatedWeiBalances[1]) == weiBalances[0], "sum of updated wei balances must match sender's initial wei balance");
        require(updatedTokenBalances[0].add(updatedTokenBalances[1]) == tokenBalances[0], "sum of updated token balances must match sender's initial token balance");

        // Note: explicitly set threadRoot == 0x0 because then it doesn't get checked by _isContained (updated state is not part of root)
        _verifyThread(threadMembers[0], threadMembers[1], threadId, updatedWeiBalances, updatedTokenBalances, updatedTxCount, "", updateSig, bytes32(0x0));

        thread.weiBalances = updatedWeiBalances;
        thread.tokenBalances = updatedTokenBalances;
        thread.txCount = updatedTxCount;
        thread.threadClosingTime = now.add(challengePeriod);

        emit DidStartExitThread(
            user,
            threadMembers[0],
            threadMembers[1],
            threadId,
            msg.sender == hub ? 0 : 1,
            thread.weiBalances,
            thread.tokenBalances,
            thread.txCount
        );
    }

    // either hub, sender, or receiver can update the thread state in place
    function challengeThread(
        address sender,
        address receiver,
        uint256 threadId,
        uint256[2] weiBalances, // updated weiBalances
        uint256[2] tokenBalances, // updated tokenBalances
        uint256 txCount,
        string sig
    ) public noReentrancy {
        require(msg.sender == hub || msg.sender == sender || msg.sender == receiver, "only hub, sender, or receiver can call this function");

        Thread storage thread = threads[sender][receiver][threadId];
        //verify that thread settlement period has not yet expired
        require(now < thread.threadClosingTime, "thread closing time must not have passed");

        // assumes that the non-sender has a later thread state than what was being proposed when the thread exit started
        require(txCount > thread.txCount, "thread txCount must be higher than the current thread txCount");
        require(weiBalances[0].add(weiBalances[1]) == thread.weiBalances[0].add(thread.weiBalances[1]), "updated wei balances must match sum of thread wei balances");
        require(tokenBalances[0].add(tokenBalances[1]) == thread.tokenBalances[0].add(thread.tokenBalances[1]), "updated token balances must match sum of thread token balances");

        require(weiBalances[1] >= thread.weiBalances[1] && tokenBalances[1] >= thread.tokenBalances[1], "receiver balances may never decrease");

        // Note: explicitly set threadRoot == 0x0 because then it doesn't get checked by _isContained (updated state is not part of root)
        _verifyThread(sender, receiver, threadId, weiBalances, tokenBalances, txCount, "", sig, bytes32(0x0));

        // save the thread balances and txCount
        thread.weiBalances = weiBalances;
        thread.tokenBalances = tokenBalances;
        thread.txCount = txCount;

        emit DidChallengeThread(
            sender,
            receiver,
            threadId,
            msg.sender,
            thread.weiBalances,
            thread.tokenBalances,
            thread.txCount
        );
    }

    //After the thread state has been finalized onchain, emptyThread can be called to withdraw funds for each channel separately.
    function emptyThread(
        address user,
        address sender,
        address receiver,
        uint256 threadId,
        uint256[2] weiBalances, // [sender, receiver] -> initial balances
        uint256[2] tokenBalances, // [sender, receiver] -> initial balances
        bytes proof,
        string sig
    ) public noReentrancy {
        Channel storage channel = channels[user];
        require(channel.status == ChannelStatus.ThreadDispute, "channel must be in thread dispute");
        require(msg.sender == hub || msg.sender == user, "only hub or user can empty thread");
        require(user == sender || user == receiver, "user must be thread sender or receiver");

        require(weiBalances[1] == 0 && tokenBalances[1] == 0, "initial receiver balances must be zero");

        Thread storage thread = threads[sender][receiver][threadId];

        // We check to make sure that the thread state has been finalized
        require(thread.threadClosingTime != 0 && thread.threadClosingTime < now, "Thread closing time must have passed");

        // Make sure user has not emptied before
        require(!thread.emptied[user == sender ? 0 : 1], "user cannot empty twice");

        // verify initial thread state.
        _verifyThread(sender, receiver, threadId, weiBalances, tokenBalances, 0, proof, sig, channel.threadRoot);

        require(thread.weiBalances[0].add(thread.weiBalances[1]) == weiBalances[0], "sum of thread wei balances must match sender's initial wei balance");
        require(thread.tokenBalances[0].add(thread.tokenBalances[1]) == tokenBalances[0], "sum of thread token balances must match sender's initial token balance");

        // deduct sender/receiver wei/tokens about to be emptied from the thread from the total channel balances
        channel.weiBalances[2] = channel.weiBalances[2].sub(thread.weiBalances[0]).sub(thread.weiBalances[1]);
        channel.tokenBalances[2] = channel.tokenBalances[2].sub(thread.tokenBalances[0]).sub(thread.tokenBalances[1]);

        // deduct wei balances from total channel wei and reset thread balances
        totalChannelWei = totalChannelWei.sub(thread.weiBalances[0]).sub(thread.weiBalances[1]);

        // if user is receiver, send them receiver wei balance
        if (user == receiver) {
            user.transfer(thread.weiBalances[1]);
        // if user is sender, send them remaining sender wei balance
        } else if (user == sender) {
            user.transfer(thread.weiBalances[0]);
        }

        // deduct token balances from channel total balances and reset thread balances
        totalChannelToken = totalChannelToken.sub(thread.tokenBalances[0]).sub(thread.tokenBalances[1]);

        // if user is receiver, send them receiver token balance
        if (user == receiver) {
            require(approvedToken.transfer(user, thread.tokenBalances[1]), "user [receiver] token withdrawal transfer failed");
        // if user is sender, send them remaining sender token balance
        } else if (user == sender) {
            require(approvedToken.transfer(user, thread.tokenBalances[0]), "user [sender] token withdrawal transfer failed");
        }

        // Record that user has emptied
        thread.emptied[user == sender ? 0 : 1] = true;

        // decrement the channel threadCount
        channel.threadCount = channel.threadCount.sub(1);

        // if this is the last thread being emptied, re-open the channel
        if (channel.threadCount == 0) {
            channel.threadRoot = bytes32(0x0);
            channel.channelClosingTime = 0;
            channel.status = ChannelStatus.Open;
        }

        emit DidEmptyThread(
            user,
            sender,
            receiver,
            threadId,
            msg.sender,
            [channel.weiBalances[0], channel.weiBalances[1]],
            [channel.tokenBalances[0], channel.tokenBalances[1]],
            channel.txCount,
            channel.threadRoot,
            channel.threadCount
        );
    }


    // anyone can call to re-open an account stuck in threadDispute after 10x challengePeriods from channel state finalization
    function nukeThreads(
        address user
    ) public noReentrancy {
        require(user != hub, "user can not be hub");
        require(user != address(this), "user can not be channel manager");

        Channel storage channel = channels[user];
        require(channel.status == ChannelStatus.ThreadDispute, "channel must be in thread dispute");
        require(channel.channelClosingTime.add(challengePeriod.mul(10)) < now, "channel closing time must have passed by 10 challenge periods");

        // transfer any remaining channel wei to user
        totalChannelWei = totalChannelWei.sub(channel.weiBalances[2]);
        user.transfer(channel.weiBalances[2]);
        uint256 weiAmount = channel.weiBalances[2];
        channel.weiBalances[2] = 0;

        // transfer any remaining channel tokens to user
        totalChannelToken = totalChannelToken.sub(channel.tokenBalances[2]);
        require(approvedToken.transfer(user, channel.tokenBalances[2]), "user token withdrawal transfer failed");
        uint256 tokenAmount = channel.tokenBalances[2];
        channel.tokenBalances[2] = 0;

        // reset channel params
        channel.threadCount = 0;
        channel.threadRoot = bytes32(0x0);
        channel.channelClosingTime = 0;
        channel.status = ChannelStatus.Open;

        emit DidNukeThreads(
            user,
            msg.sender,
            weiAmount,
            tokenAmount,
            [channel.weiBalances[0], channel.weiBalances[1]],
            [channel.tokenBalances[0], channel.tokenBalances[1]],
            channel.txCount,
            channel.threadRoot,
            channel.threadCount
        );
    }

    function() external payable {}

    // ******************
    // INTERNAL FUNCTIONS
    // ******************

    function _verifyAuthorizedUpdate(
        Channel storage channel,
        uint256[2] txCount,
        uint256[2] weiBalances,
        uint256[2] tokenBalances, // [hub, user]
        uint256[4] pendingWeiUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
        uint256[4] pendingTokenUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
        uint256 timeout,
        bool isHub
    ) internal view {
        require(channel.status == ChannelStatus.Open, "channel must be open");

        // Usage:
        // 1. exchange operations to protect user from exchange rate fluctuations
        // 2. protects hub against user delaying forever
        require(timeout == 0 || now < timeout, "the timeout must be zero or not have passed");

        require(txCount[0] > channel.txCount[0], "global txCount must be higher than the current global txCount");
        require(txCount[1] >= channel.txCount[1], "onchain txCount must be higher or equal to the current onchain txCount");

        // offchain wei/token balances do not exceed onchain total wei/token
        require(weiBalances[0].add(weiBalances[1]) <= channel.weiBalances[2], "wei must be conserved");
        require(tokenBalances[0].add(tokenBalances[1]) <= channel.tokenBalances[2], "tokens must be conserved");

        // hub has enough reserves for wei/token deposits for both the user and itself (if isHub, user deposit comes from hub)
        if (isHub) {
            require(pendingWeiUpdates[0].add(pendingWeiUpdates[2]) <= getHubReserveWei(), "insufficient reserve wei for deposits");
            require(pendingTokenUpdates[0].add(pendingTokenUpdates[2]) <= getHubReserveTokens(), "insufficient reserve tokens for deposits");
        // hub has enough reserves for only its own wei/token deposits
        } else {
            require(pendingWeiUpdates[0] <= getHubReserveWei(), "insufficient reserve wei for deposits");
            require(pendingTokenUpdates[0] <= getHubReserveTokens(), "insufficient reserve tokens for deposits");
        }

        // wei is conserved - the current total channel wei + both deposits > final balances + both withdrawals
        require(channel.weiBalances[2].add(pendingWeiUpdates[0]).add(pendingWeiUpdates[2]) >=
                weiBalances[0].add(weiBalances[1]).add(pendingWeiUpdates[1]).add(pendingWeiUpdates[3]), "insufficient wei");

        // token is conserved - the current total channel token + both deposits > final balances + both withdrawals
        require(channel.tokenBalances[2].add(pendingTokenUpdates[0]).add(pendingTokenUpdates[2]) >=
                tokenBalances[0].add(tokenBalances[1]).add(pendingTokenUpdates[1]).add(pendingTokenUpdates[3]), "insufficient token");
    }

    function _applyPendingUpdates(
        uint256[3] storage channelBalances,
        uint256[2] balances,
        uint256[4] pendingUpdates
    ) internal {
        // update hub balance
        // If the deposit is greater than the withdrawal, add the net of deposit minus withdrawal to the balances.
        // Assumes the net has *not yet* been added to the balances.
        if (pendingUpdates[0] > pendingUpdates[1]) {
            channelBalances[0] = balances[0].add(pendingUpdates[0].sub(pendingUpdates[1]));
        // Otherwise, if the deposit is less than or equal to the withdrawal,
        // Assumes the net has *already* been added to the balances.
        } else {
            channelBalances[0] = balances[0];
        }

        // update user balance
        // If the deposit is greater than the withdrawal, add the net of deposit minus withdrawal to the balances.
        // Assumes the net has *not yet* been added to the balances.
        if (pendingUpdates[2] > pendingUpdates[3]) {
            channelBalances[1] = balances[1].add(pendingUpdates[2].sub(pendingUpdates[3]));

        // Otherwise, if the deposit is less than or equal to the withdrawal,
        // Assumes the net has *already* been added to the balances.
        } else {
            channelBalances[1] = balances[1];
        }
    }

    function _revertPendingUpdates(
        uint256[3] storage channelBalances,
        uint256[2] balances,
        uint256[4] pendingUpdates
    ) internal {
        // If the pending update has NOT been executed AND deposits > withdrawals, offchain state was NOT updated with delta, and is thus correct
        if (pendingUpdates[0] > pendingUpdates[1]) {
            channelBalances[0] = balances[0];

        // If the pending update has NOT been executed AND deposits < withdrawals, offchain state should have been updated with delta, and must be reverted
        } else {
            channelBalances[0] = balances[0].add(pendingUpdates[1].sub(pendingUpdates[0])); // <- add withdrawal, sub deposit (opposite order as _applyPendingUpdates)
        }

        // If the pending update has NOT been executed AND deposits > withdrawals, offchain state was NOT updated with delta, and is thus correct
        if (pendingUpdates[2] > pendingUpdates[3]) {
            channelBalances[1] = balances[1];

        // If the pending update has NOT been executed AND deposits > withdrawals, offchain state should have been updated with delta, and must be reverted
        } else {
            channelBalances[1] = balances[1].add(pendingUpdates[3].sub(pendingUpdates[2])); // <- add withdrawal, sub deposit (opposite order as _applyPendingUpdates)
        }
    }

    function _updateChannelBalances(
        Channel storage channel,
        uint256[2] weiBalances,
        uint256[2] tokenBalances,
        uint256[4] pendingWeiUpdates,
        uint256[4] pendingTokenUpdates
    ) internal {
        _applyPendingUpdates(channel.weiBalances, weiBalances, pendingWeiUpdates);
        _applyPendingUpdates(channel.tokenBalances, tokenBalances, pendingTokenUpdates);

        totalChannelWei = totalChannelWei.add(pendingWeiUpdates[0]).add(pendingWeiUpdates[2]).sub(pendingWeiUpdates[1]).sub(pendingWeiUpdates[3]);
        totalChannelToken = totalChannelToken.add(pendingTokenUpdates[0]).add(pendingTokenUpdates[2]).sub(pendingTokenUpdates[1]).sub(pendingTokenUpdates[3]);

        // update channel total balances
        channel.weiBalances[2] = channel.weiBalances[2].add(pendingWeiUpdates[0]).add(pendingWeiUpdates[2]).sub(pendingWeiUpdates[1]).sub(pendingWeiUpdates[3]);
        channel.tokenBalances[2] = channel.tokenBalances[2].add(pendingTokenUpdates[0]).add(pendingTokenUpdates[2]).sub(pendingTokenUpdates[1]).sub(pendingTokenUpdates[3]);
    }

    function _verifySig (
        address[2] user, // [user, recipient]
        uint256[2] weiBalances, // [hub, user]
        uint256[2] tokenBalances, // [hub, user]
        uint256[4] pendingWeiUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
        uint256[4] pendingTokenUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
        uint256[2] txCount, // [global, onchain] persisted onchain even when empty
        bytes32 threadRoot,
        uint256 threadCount,
        uint256 timeout,
        string sigHub,
        string sigUser,
        bool[2] checks // [checkHubSig?, checkUserSig?]
    ) internal view {
        require(user[0] != hub, "user can not be hub");
        require(user[0] != address(this), "user can not be channel manager");

        // prepare state hash to check hub sig
        bytes32 state = keccak256(
            abi.encodePacked(
                address(this),
                user, // [user, recipient]
                weiBalances, // [hub, user]
                tokenBalances, // [hub, user]
                pendingWeiUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
                pendingTokenUpdates, // [hubDeposit, hubWithdrawal, userDeposit, userWithdrawal]
                txCount, // persisted onchain even when empty
                threadRoot,
                threadCount,
                timeout
            )
        );

        if (checks[0]) {
            require(hub == ECTools.recoverSigner(state, sigHub), "hub signature invalid");
        }

        if (checks[1]) {
            require(user[0] == ECTools.recoverSigner(state, sigUser), "user signature invalid");
        }
    }

    function _verifyThread(
        address sender,
        address receiver,
        uint256 threadId,
        uint256[2] weiBalances,
        uint256[2] tokenBalances,
        uint256 txCount,
        bytes proof,
        string sig,
        bytes32 threadRoot
    ) internal view {
        require(sender != receiver, "sender can not be receiver");
        require(sender != hub && receiver != hub, "hub can not be sender or receiver");
        require(sender != address(this) && receiver != address(this), "channel manager can not be sender or receiver");

        bytes32 state = keccak256(
            abi.encodePacked(
                address(this),
                sender,
                receiver,
                threadId,
                weiBalances, // [sender, receiver]
                tokenBalances, // [sender, receiver]
                txCount // persisted onchain even when empty
            )
        );
        require(ECTools.isSignedBy(state, sig, sender), "signature invalid");

        if (threadRoot != bytes32(0x0)) {
            require(_isContained(state, proof, threadRoot), "initial thread state is not contained in threadRoot");
        }
    }

    function _isContained(bytes32 _hash, bytes _proof, bytes32 _root) internal pure returns (bool) {
        bytes32 cursor = _hash;
        bytes32 proofElem;

        for (uint256 i = 64; i <= _proof.length; i += 32) {
            assembly { proofElem := mload(add(_proof, i)) }

            if (cursor < proofElem) {
                cursor = keccak256(abi.encodePacked(cursor, proofElem));
            } else {
                cursor = keccak256(abi.encodePacked(proofElem, cursor));
            }
        }

        return cursor == _root;
    }

    function getChannelBalances(address user) constant public returns (
        uint256 weiHub,
        uint256 weiUser,
        uint256 weiTotal,
        uint256 tokenHub,
        uint256 tokenUser,
        uint256 tokenTotal
    ) {
        Channel memory channel = channels[user];
        return (
            channel.weiBalances[0],
            channel.weiBalances[1],
            channel.weiBalances[2],
            channel.tokenBalances[0],
            channel.tokenBalances[1],
            channel.tokenBalances[2]
        );
    }

    function getChannelDetails(address user) constant public returns (
        uint256 txCountGlobal,
        uint256 txCountChain,
        bytes32 threadRoot,
        uint256 threadCount,
        address exitInitiator,
        uint256 channelClosingTime,
        ChannelStatus status
    ) {
        Channel memory channel = channels[user];
        return (
            channel.txCount[0],
            channel.txCount[1],
            channel.threadRoot,
            channel.threadCount,
            channel.exitInitiator,
            channel.channelClosingTime,
            channel.status
        );
    }
}