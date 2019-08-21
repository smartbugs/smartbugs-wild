pragma solidity 0.4.25;

interface Token {
  function transfer(address _to, uint256 _value) external returns (bool);
}

contract onlyOwner {
  address public owner;
  /** 
  * @dev The Ownable constructor sets the original `owner` of the contract to the sender
  * account.
  */
  constructor() public {
    owner = msg.sender;
  }
  modifier isOwner {
    require(msg.sender == owner);
    _;
  }
}

contract Campaigns is onlyOwner{

  Token token;
  event TransferredToken(address indexed to, uint256 value);
  address distTokens;

  constructor(address _contract) public{
      distTokens = _contract;
      token = Token(_contract);
  }
  
  function setTokenContract(address _contract) isOwner public{
      distTokens = _contract;
      token = Token(_contract);
  } 
  
  function getTokenContract() public view returns(address){
      return distTokens;
  }


    function sendResidualAmount(uint256 value) isOwner public returns(bool){
        token.transfer(owner, value);
        emit TransferredToken(msg.sender, value);
        return true;
    }    
    
    function sendAmount(address[] _user, uint256 value, uint256 decimal) isOwner public returns(bool){
        require(_user.length <= 240);
        for(uint i=0; i< _user.length; i++)
        token.transfer(_user[i], value*10**decimal);
        return true;
    }
	
	function sendIndividualAmount(address[] _user, uint256[] value, uint256 decimal) isOwner public returns(bool){
	    require(_user.length <= 240);
        for(uint i=0; i< _user.length; i++)
        token.transfer(_user[i], value[i]*10**decimal);
        return true;
    }
  
}