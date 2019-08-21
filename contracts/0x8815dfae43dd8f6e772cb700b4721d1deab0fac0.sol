pragma solidity ^0.4.19;

// Vicent Nos & Enrique Santos


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

    function Ownable() internal {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


//////////////////////////////////////////////////////////////
//                                                          //
//  Lescovex, Shareholder's ERC20                           //
//                                                          //
//////////////////////////////////////////////////////////////

contract LescovexERC20 is Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) holded;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    uint256 public constant blockEndICO = 1524182460;

    /* Public variables for the ERC20 token */
    string public constant standard = "ERC20 Lescovex";
    uint8 public constant decimals = 8; // hardcoded to be a constant
    uint256 public totalSupply;
    string public name;
    string public symbol;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function holdedOf(address _owner) public view returns (uint256 balance) {
        return holded[_owner];
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(block.timestamp > blockEndICO || msg.sender == owner);
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        holded[_to] = block.number;
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        holded[_to] = block.number;
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        Transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public onlyOwner returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addedValue) public onlyOwner returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public onlyOwner returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /* Approve and then communicate the approved contract in a single tx */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public onlyOwner returns (bool success) {    
        tokenRecipient spender = tokenRecipient(_spender);

        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
}


interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public ; 
}

    
contract Lescovex is LescovexERC20 {

    // Contract variables and constants
    uint256 constant initialSupply = 0;
    string constant tokenName = "Lescovex Shareholder's";
    string constant tokenSymbol = "LCX";

    address public LescovexAddr = 0xD26286eb9E6E623dba88Ed504b628F648ADF7a0E;
    uint256 public constant minPrice = 7500000000000000;
    uint256 public buyPrice = minPrice;
    uint256 public tokenReward = 0;
    // constant to simplify conversion of token amounts into integer form
    uint256 public tokenUnit = uint256(10)**decimals;

    //Declare logging events
    event LogDeposit(address sender, uint amount);
    event LogWithdrawal(address receiver, uint amount);
  
    /* Initializes contract with initial supply tokens to the creator of the contract */
    function Lescovex() public {
        totalSupply = initialSupply;  // Update total supply
        name = tokenName;             // Set the name for display purposes
        symbol = tokenSymbol;         // Set the symbol for display purposes
    }

    function () public payable {
        buy();   // Allow to buy tokens sending ether directly to contract
    }

    modifier status() {
        _;  // modified function code should go before prices update

        if (block.timestamp < 1519862460){          //until 1 march 2018
            if (totalSupply < 50000000000000){
                buyPrice = 7500000000000000;

            } else {
                buyPrice = 8000000000000000;
            }
        } else if (block.timestamp < 1520640060){   // until 10 march 2018
          buyPrice = 8000000000000000;

        } else if (block.timestamp<1521504060){     //until 20 march 2018
          buyPrice = 8500000000000000;

        } else if (block.timestamp < 1522368060){   //until 30 march 2018

          buyPrice = 9000000000000000;

        } else if (block.timestamp < 1523232060){   //until 9 april 2018
          buyPrice = 9500000000000000;

        } else {

          buyPrice = 10000000000000000;
        }
    }

    function deposit() public payable onlyOwner returns(bool success) {
        // Check for overflows;

        assert (this.balance + msg.value >= this.balance); // Check for overflows
        tokenReward = this.balance / totalSupply;

        //executes event to reflect the changes
        LogDeposit(msg.sender, msg.value);
        
        return true;
    }

    function withdrawReward() public status {
        require (block.number - holded[msg.sender] > 172800); //1 month

        holded[msg.sender] = block.number;
        uint256 ethAmount = tokenReward * balances[msg.sender];

        //send eth to owner address
        msg.sender.transfer(ethAmount);
          
        //executes event to register the changes
        LogWithdrawal(msg.sender, ethAmount);
    }

    function withdraw(uint value) public onlyOwner {
        //send eth to owner address
        msg.sender.transfer(value);

        //executes event to register the changes
        LogWithdrawal(msg.sender, value);
    }

    function buy() public payable status {
        require (totalSupply <= 1000000000000000);
        require(block.timestamp < blockEndICO);

        uint256 tokenAmount = (msg.value / buyPrice)*tokenUnit ;  // calculates the amount

        transferBuy(msg.sender, tokenAmount);
        LescovexAddr.transfer(msg.value);
    }

    function transferBuy(address _to, uint256 _value) internal returns (bool) {
        require(_to != address(0));

        // SafeMath.add will throw if there is not enough balance.
        totalSupply = totalSupply.add(_value*2);
        holded[_to] = block.number;
        balances[LescovexAddr] = balances[LescovexAddr].add(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(this, _to, _value);
        Transfer(this, LescovexAddr, _value);
        return true;
    }

  function burn(address addr) public onlyOwner{
    totalSupply=totalSupply.sub(balances[addr]);
    balances[addr]=0;

  }

}