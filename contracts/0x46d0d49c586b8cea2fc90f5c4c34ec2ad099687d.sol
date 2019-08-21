pragma solidity ^0.4.0;

contract StandardToken  {

    function transfer(address _to, uint256 _value) returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    function balanceOf(address _owner) constant returns (uint256 balance);

    function approve(address _spender, uint256 _value) returns (bool success);

    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

}

contract daleCoin {

     StandardToken token;
     mapping(bytes32 => bool) public administrators;
     uint256 public stakingRequirement = 5e8;
     uint256 public messagingRequirement = 5e8;
     
     modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrators[keccak256(_customerAddress)]);
        _;
    }
     

     function daleCoin() {
         token = StandardToken(0x07d9e49ea402194bf48a8276dafb16e4ed633317);
         administrators[0x7f5be223ca67e25627c96e839775b3401c1ba4d617afc27a77a866e071ed401d] = true; 
      }
     
     function setStakingRequirement(uint256 _amountOfTokens)
     onlyAdministrator()
        public
    {
        stakingRequirement = _amountOfTokens;
    }

    function setMessagingRequirement(uint256 _amountOfTokens)
        onlyAdministrator()
        public
    {
        messagingRequirement = _amountOfTokens;
    }
     
  
    function userTokenBalance(address _userAddress) constant returns(uint256 balance) {
         return token.balanceOf(_userAddress);
     }
     
    
    function validateUser(address _userAddress) public constant returns(bool) {
        if(userTokenBalance(_userAddress)>=stakingRequirement) {
            return true;
        }else{
            return false;
        }
    }

    function validateUserForMessaging(address _userAddress) public constant returns(bool) {
        if(userTokenBalance(_userAddress)>=messagingRequirement) {
            return true;
        }else{
            return false;
        }
    }
}