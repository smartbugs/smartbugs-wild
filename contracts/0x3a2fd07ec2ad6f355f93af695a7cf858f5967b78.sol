pragma solidity ^0.4.24;

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts/MTVote.sol

contract TVCrowdsale {
    uint256 public currentRate;
    function buyTokens(address _beneficiary) public payable;
}

contract TVToken {
    function transfer(address _to, uint256 _value) public returns (bool);
    function safeTransfer(address _to, uint256 _value, bytes _data) public;
}


contract MTVote is Ownable {
    address public TVTokenAddress;
    address public TVCrowdsaleAddress;
    address public manager;
    address public wallet;
    address internal checkAndBuySender;
    bytes4 constant TOKEN_RECEIVED = bytes4(keccak256("onTokenReceived(address,uint256,bytes)"));
    bool pause = false;

    mapping(uint => uint) public targets;
    uint public targetIdsSize = 0;
    uint[] public targetIds;

    modifier onlyOwnerOrManager() {
        require(msg.sender == owner || manager == msg.sender);
        _;
    }

    event TokenReceived(address from, uint value, uint targetId);
    event changeAndVoteEvent(address voter, uint rate, uint value, uint targetId);

    constructor(
        address _TVTokenAddress,
        address _TVCrowdsaleAddress,
        address _manager,
        address _wallet) public {

        manager = _manager;
        wallet = _wallet;
        TVTokenAddress = _TVTokenAddress;
        TVCrowdsaleAddress = _TVCrowdsaleAddress;
    }

    function changeAndVote(uint targetId) public payable {
        require(!pause);
        uint rate = TVCrowdsale(TVCrowdsaleAddress).currentRate();

        TVCrowdsale(TVCrowdsaleAddress).buyTokens.value(msg.value)(this);
        bytes memory data = toBytes(targetId);
        checkAndBuySender = msg.sender;
        TVToken(TVTokenAddress).safeTransfer(this, msg.value * rate, data);

        emit changeAndVoteEvent(msg.sender, rate, msg.value, targetId);
    }

    function onTokenReceived(address _from, uint256 _value, bytes _data) public returns (bytes4) {
        require(msg.sender == TVTokenAddress);
        require(!pause);
        uint targetId = uint256(convertBytesToBytes32(_data));
        targets[targetId] += _value;
        TVToken(TVTokenAddress).transfer(wallet, _value);
        _from = this == _from ? checkAndBuySender : _from;
        checkAndBuySender = address(0);

        bool inList = false;
        for (uint i = 0; i < targetIdsSize; i++) {
            if (targetIds[i] == targetId) {
                inList = true;
            }
        }
        if (!inList) {
            targetIds.push(targetId);
            targetIdsSize++;
        }

        emit TokenReceived(_from, _value, targetId);
        return TOKEN_RECEIVED;
    }

    function setPause(bool isPaused) public onlyOwnerOrManager {
        pause = isPaused;
    }

    function clear() public onlyOwnerOrManager {
        targetIdsSize = 0;
    }

    function changeTVTokenAddress(address newAddress) public onlyOwnerOrManager {
        TVTokenAddress = newAddress;
    }

    function changeTVCrowdsaleAddress(address newAddress) public onlyOwnerOrManager {
        TVCrowdsaleAddress = newAddress;
    }

    function setManager(address _manager) public onlyOwner {
        manager = _manager;
    }

    function convertBytesToBytes32(bytes inBytes) internal pure returns (bytes32 out) {
        if (inBytes.length == 0) {
            return 0x0;
        }

        assembly {
            out := mload(add(inBytes, 32))
        }
    }

    function bytesToUint(bytes32 b) internal pure returns (uint number){
        for (uint i = 0; i < b.length; i++) {
            number = number + uint(b[i]) * (2 ** (8 * (b.length - (i + 1))));
        }
    }

    function toBytes(uint256 x) internal pure returns (bytes b) {
        b = new bytes(32);
        assembly {mstore(add(b, 32), x)}
    }
}