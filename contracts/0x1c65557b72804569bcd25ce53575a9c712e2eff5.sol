// Play2LivePromo token smart contract.
// Developed by Phenom.Team <info@phenom.team>

pragma solidity ^0.4.18;

contract Play2LivePromo {
    //Owner address
    address public owner;
    //Public variables of the token
    string public constant name  = "Level Up Coin Diamond | play2live.io";
    string public constant symbol = "LUCD";
    uint8 public constant decimals = 18;
    uint public totalSupply = 0; 
    uint256 promoValue = 777 * 1e18;
    mapping(address => uint) balances;
    mapping(address => mapping (address => uint)) allowed;
    // Events Log
    event Transfer(address _from, address _to, uint256 amount); 
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    // Modifiers
    // Allows execution by the contract owner only
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }  

   /**
    *   @dev Contract constructor function sets owner address
    */
    function Play2LivePromo() {
        owner = msg.sender;
    }

    /**
    *   @dev Allows owner to change promo value
    *   @param _newValue      new   
    */
    function setPromo(uint256 _newValue) external onlyOwner {
        promoValue = _newValue;
    }

   /**
    *   @dev Get balance of investor
    *   @param _investor     investor's address
    *   @return              balance of investor
    */
    function balanceOf(address _investor) public constant returns(uint256) {
        return balances[_investor];
    }


   /**
    *   @dev Mint tokens
    *   @param _investor     beneficiary address the tokens will be issued to
    */
    function mintTokens(address _investor) external onlyOwner {
        balances[_investor] +=  promoValue;
        totalSupply += promoValue;
        Transfer(0x0, _investor, promoValue);
        
    }


   /**
    *   @dev Send coins
    *   throws on any error rather then return a false flag to minimize
    *   user errors
    *   @param _to           target address
    *   @param _amount       transfer amount
    *
    *   @return true if the transfer was successful
    */
    function transfer(address _to, uint _amount) public returns (bool) {
        balances[msg.sender] -= _amount;
        balances[_to] -= _amount;
        Transfer(msg.sender, _to, _amount);
        return true;
    }

   /**
    *   @dev An account/contract attempts to get the coins
    *   throws on any error rather then return a false flag to minimize user errors
    *
    *   @param _from         source address
    *   @param _to           target address
    *   @param _amount       transfer amount
    *
    *   @return true if the transfer was successful
    */
    function transferFrom(address _from, address _to, uint _amount) public returns (bool) {
        balances[_from] -= _amount;
        allowed[_from][msg.sender] -= _amount;
        balances[_to] -= _amount;
        Transfer(_from, _to, _amount);
        return true;
     }


   /**
    *   @dev Allows another account/contract to spend some tokens on its behalf
    *   throws on any error rather then return a false flag to minimize user errors
    *
    *   also, to minimize the risk of the approve/transferFrom attack vector
    *   approve has to be called twice in 2 separate transactions - once to
    *   change the allowance to 0 and secondly to change it to the new allowance
    *   value
    *
    *   @param _spender      approved address
    *   @param _amount       allowance amount
    *
    *   @return true if the approval was successful
    */
    function approve(address _spender, uint _amount) public returns (bool) {
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

   /**
    *   @dev Function to check the amount of tokens that an owner allowed to a spender.
    *
    *   @param _owner        the address which owns the funds
    *   @param _spender      the address which will spend the funds
    *
    *   @return              the amount of tokens still avaible for the spender
    */
    function allowance(address _owner, address _spender) constant returns (uint) {
        return allowed[_owner][_spender];
    }
}