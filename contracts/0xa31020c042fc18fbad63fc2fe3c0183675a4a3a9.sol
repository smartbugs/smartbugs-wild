pragma solidity ^0.4.18;

/**
 * CoinCrowd Token (XCC) multi send contract. More info www.coincrowd.it
 */
 
contract Ownable {
  address public owner;
  
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  function Ownable() internal {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
 
contract tokenInterface {
    function originTransfer(address _to, uint256 _value) public returns (bool);
}

contract MultiSendCoinCrowd is Ownable {
	address public tokenAddress;
	
	function MultiSendCoinCrowd(address _tokenAddress) public {
		tokenAddress = _tokenAddress;
	}
	
	function updateTokenContract(address _tokenAddress) public onlyOwner {
        tokenAddress = _tokenAddress;
    }
	
    function multisend(address[] _dests, uint256[] _values) public onlyOwner returns(uint256) {
        uint256 i = 0;
        while (i < _dests.length) {
           tokenInterface(tokenAddress).originTransfer(_dests[i], _values[i]);
           i += 1;
        }
        return(i);
    }
	
	function airdrop( uint256 _value, address[] _dests ) public onlyOwner returns(uint256) {
        uint256 i = 0;
        while (i < _dests.length) {
           tokenInterface(tokenAddress).originTransfer(_dests[i], _value);
           i += 1;
        }
        return(i);
    }
}