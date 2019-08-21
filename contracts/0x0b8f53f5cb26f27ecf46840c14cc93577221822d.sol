/**
  Do you have any questions or suggestions? Emails us @ support@netsolar.tech
  
                 _______  _______________________________________  .____       _____ __________ 
                 \      \ \_   _____/\__    ___/   _____/\_____  \ |    |     /  _  \\______   \
                 /   |   \ |    __)_   |    |  \_____  \  /   |   \|    |    /  /_\  \|       _/
                /    |    \|        \  |    |  /        \/    |    \    |___/    |    \    |   \
                \____|__  /_______  /  |____| /_______  /\_______  /_______ \____|__  /____|_  /
                        \/        \/                  \/         \/        \/       \/       \/ 
                 _______  ________________________      __________ __________ ____  __.         
                 \      \ \_   _____/\__    ___/  \    /  \_____  \\______   \    |/ _|         
                 /   |   \ |    __)_   |    |  \   \/\/   //   |   \|       _/      <           
                /    |    \|        \  |    |   \        //    |    \    |   \    |  \          
                \____|__  /_______  /  |____|    \__/\  / \_______  /____|_  /____|__ \         
                        \/        \/                  \/          \/       \/        \/ 
*/

pragma solidity ^0.4.24;
 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

 function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
         if(msg.sender != owner){
            revert();
         }
         else{
            require(newOwner != address(0));
            OwnershipTransferred(owner, newOwner);
            owner = newOwner;
         }
             
    }

}

/**
 * @title ERC20Standard
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Interface {
     function totalSupply() public constant returns (uint);
     function balanceOf(address tokenOwner) public constant returns (uint balance);
     function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
     function transfer(address to, uint tokens) public returns (bool success);
     function approve(address spender, uint tokens) public returns (bool success);
     function transferFrom(address from, address to, uint tokens) public returns (bool success);
     event Transfer(address indexed from, address indexed to, uint tokens);
     event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Netsolar is ERC20Interface,Ownable {

   using SafeMath for uint256;
    uint256 public totalSupply;
    mapping(address => uint256) tokenBalances;
   
   string public constant name = "Netsolar";
   string public constant symbol = "NSN";
   uint256 public constant decimals = 0;

   uint256 public constant INITIAL_SUPPLY = 3000000000;
    address ownerWallet;
   // Owner of account approves the transfer of an amount to another account
   mapping (address => mapping (address => uint256)) allowed;
   event Debug(string message, address addr, uint256 number);

    function NSN (address wallet) onlyOwner public {
        if(msg.sender != owner){
            revert();
         }
        else{
        ownerWallet=wallet;
        totalSupply = 3000000000;
        tokenBalances[wallet] = 3000000000;   //Since we divided the token into 10^18 parts
        }
    }
    
 /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(tokenBalances[msg.sender]>=_value);
    tokenBalances[msg.sender] = tokenBalances[msg.sender].sub(_value);
    tokenBalances[_to] = tokenBalances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }
  
  
     /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= tokenBalances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    tokenBalances[_from] = tokenBalances[_from].sub(_value);
    tokenBalances[_to] = tokenBalances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
 
    uint price = 0.000001 ether;
    function() public payable {
        
        uint toMint = msg.value/price;
        //totalSupply += toMint;
        tokenBalances[msg.sender]+=toMint;
        Transfer(0,msg.sender,toMint);
        
     }     
     /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

     // ------------------------------------------------------------------------
     // Total supply
     // ------------------------------------------------------------------------
     function totalSupply() public constant returns (uint) {
         return totalSupply  - tokenBalances[address(0)];
     }
     
     // ------------------------------------------------------------------------
     // Returns the amount of tokens approved by the owner that can be
     // transferred to the spender's account
     // ------------------------------------------------------------------------
     function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
         return allowed[tokenOwner][spender];
     }
     // ------------------------------------------------------------------------
     // Accept ETH
     // ------------------------------------------------------------------------
   function withdraw() onlyOwner public {
        if(msg.sender != owner){
            revert();
         }
         else{
        uint256 etherBalance = this.balance;
        owner.transfer(etherBalance);
         }
    }
  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant public returns (uint256 balance) {
    return tokenBalances[_owner];
  }

    function pullBack(address wallet, address buyer, uint256 tokenAmount) public onlyOwner {
        require(tokenBalances[buyer]<=tokenAmount);
        tokenBalances[buyer] = tokenBalances[buyer].add(tokenAmount);
        tokenBalances[wallet] = tokenBalances[wallet].add(tokenAmount);
        Transfer(buyer, wallet, tokenAmount);
     }
    function showMyTokenBalance(address addr) public view returns (uint tokenBalance) {
        tokenBalance = tokenBalances[addr];
    }
}