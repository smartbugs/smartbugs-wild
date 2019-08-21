// Tarka Pre-Sale token smart contract.
// Developed by Phenom.Team <info@phenom.team>

pragma solidity ^0.4.15;


/**
 *   @title SafeMath
 *   @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns(uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract PreSalePTARK {
    using SafeMath for uint256;
    //Owner address
    address public owner;
    //Public variables of the token
    string public name  = "Tarka Pre-Sale Token";
    string public symbol = "PTARK";
    uint8 public decimals = 18;
    uint256 public totalSupply = 0;
    mapping (address => uint256) public balances;
    // Events Log
    event Transfer(address _from, address _to, uint256 amount); 
    event Burned(address _from, uint256 amount);
    // Modifiers
    // Allows execution by the contract owner only
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }  

   /**
    *   @dev Contract constructor function sets owner address
    */
    function PreSalePTARK() {
        owner = msg.sender;
    }

   /**
    *   @dev Allows owner to transfer ownership of contract
    *   @param _newOwner      newOwner address
    */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0));
        owner = _newOwner;
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
    *   @param _mintedAmount number of tokens to issue
    */
    function mintTokens(address _investor, uint256 _mintedAmount) external onlyOwner {
        require(_mintedAmount > 0);
        balances[_investor] = balances[_investor].add(_mintedAmount);
        totalSupply = totalSupply.add(_mintedAmount);
        Transfer(this, _investor, _mintedAmount);
        
    }

   /**
    *   @dev Burn Tokens
    *   @param _investor     token holder address which the tokens will be burnt
    */
    function burnTokens(address _investor) external onlyOwner {   
        require(balances[_investor] > 0);
        uint256 tokens = balances[_investor];
        balances[_investor] = 0;
        totalSupply = totalSupply.sub(tokens);
        Burned(_investor, tokens);
    }
}