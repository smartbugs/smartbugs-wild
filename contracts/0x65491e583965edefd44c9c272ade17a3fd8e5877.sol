pragma solidity ^0.4.18;


// Interface for contracts with buying functionality, for example, crowdsales.
contract Buyable {
  function buy (address receiver) public payable;
}

 /// @title Ownable contract - base contract with an owner
contract Ownable {
  address public owner;

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}

contract TokenAdrTokenSaleProxy is Ownable {

  /// Target contract
  Buyable public targetContract;

  /// Gas limit for buy transaction
  uint public buyGasLimit = 200000;

  /// Is sale stopped or not
  bool public stopped = false;

  /// Total volume of weis passed through this proxy
  uint public totalWeiVolume = 0;

  /// @dev Constructor
  /// @param _targetAddress Address of the target Buyable contract
  function TokenAdrTokenSaleProxy(address _targetAddress) public {
    require(_targetAddress > 0);
    targetContract = Buyable(_targetAddress);
  }

  /// @dev Fallback function - forward investment request to the target contract
  function() public payable {
    require(msg.value > 0);
    require(!stopped);
    totalWeiVolume += msg.value;
    targetContract.buy.value(msg.value).gas(buyGasLimit)(msg.sender);
  }

  /// @dev Change target address where investment requests are forwarded
  /// @param newTargetAddress New target address to forward investments
  function changeTargetAddress(address newTargetAddress) public onlyOwner {
    require(newTargetAddress > 0);
    targetContract = Buyable(newTargetAddress);
  }

  /// @dev Change gas limit for buy() method call
  /// @param newGasLimit New gas limit
  function changeGasLimit(uint newGasLimit) public onlyOwner {
    require(newGasLimit > 0);
    buyGasLimit = newGasLimit;
  }

  /// @dev Stop the sale
  function stop() public onlyOwner {
    require(!stopped);
    stopped = true;
  }

  /// @dev Resume the sale
  function resume() public onlyOwner {
    require(stopped);
    stopped = false;
  }
}