pragma solidity ^0.4.11;

// ==== DISCLAIMER ====
//
// ETHEREUM IS STILL AN EXPEREMENTAL TECHNOLOGY.
// ALTHOUGH THIS SMART CONTRACT WAS CREATED WITH GREAT CARE AND IN THE HOPE OF BEING USEFUL, NO GUARANTEES OF FLAWLESS OPERATION CAN BE GIVEN.
// IN PARTICULAR - SUBTILE BUGS, HACKER ATTACKS OR MALFUNCTION OF UNDERLYING TECHNOLOGY CAN CAUSE UNINTENTIONAL BEHAVIOUR.
// YOU ARE STRONGLY ENCOURAGED TO STUDY THIS SMART CONTRACT CAREFULLY IN ORDER TO UNDERSTAND POSSIBLE EDGE CASES AND RISKS.
// DON'T USE THIS SMART CONTRACT IF YOU HAVE SUBSTANTIAL DOUBTS OR IF YOU DON'T KNOW WHAT YOU ARE DOING.
//
// THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
// AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
// OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// ====
// all this file is based on code from open zepplin
// https://github.com/OpenZeppelin/zeppelin-solidity/tree/master/contracts/token
// Standard ERC20 token Clickle.de
// @author Chainsulting.de - Blockchain Consulting 
// ==== DISCLAIMER ====

 // @title SafeMath
 // @dev Math operations with safety checks that throw on error

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


 // @title ERC20Basic
 // @dev Simpler version of ERC20 interface
 // @dev see https://github.com/ethereum/EIPs/issues/179

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
 
 // @title ERC20 interface
 // @dev see https://github.com/ethereum/EIPs/issues/20

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
 // @title Basic token
 // @dev Basic version of StandardToken, with no allowances.
 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  
  // @dev transfer token for a specified address
  // @param _to The address to transfer to.
  // @param _value The amount to be transferred.
 
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  
  // @dev Gets the balance of the specified address.
  // @param _owner The address to query the the balance of.
  // @return An uint256 representing the amount owned by the passed address.
 
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

 // @title Standard ERC20 token
 // @dev Implementation of the basic standard token.
 // @dev https://github.com/ethereum/EIPs/issues/20
 // @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  
   // @dev Transfer tokens from one address to another
   // @param _from address The address which you want to send tokens from
   // @param _to address The address which you want to transfer to
   // @param _value uint256 the amount of tokens to be transferred
   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

   // @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   //
   // Beware that changing an allowance with this method brings the risk that someone may use both the old
   // and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   // race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   // @param _spender The address which will spend the funds.
   // @param _value The amount of tokens to be spent.
   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

 
   // @dev Function to check the amount of tokens that an owner allowed to a spender.
   // @param _owner address The address which owns the funds.
   // @param _spender address The address which will spend the funds.
   // @return A uint256 specifying the amount of tokens still available for the spender.
  
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }


   // approve should be called when allowed[_spender] == 0. To increment
   // allowed value is better to use this function to avoid 2 calls (and wait until
   // the first transaction is mined)
   // From MonolithDAO Token.sol

  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

 // @title CLICKLE Token
 // @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 // Note they can later distribute these tokens as they wish using `transfer` and other
 // StandardToken functions. 20.000.000 CLICK

contract CLICKLEToken is StandardToken {

    string public name = "Clickle Token";
    string public symbol = "CLICK";
    uint public decimals = 8;
    uint public INITIAL_SUPPLY = 2000000000000000; // Initial supply is 20,000,000 CLICK

    function CLICKLEToken() {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY; // Give the creator all initial tokens
    }
}