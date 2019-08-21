pragma solidity ^0.4.13;

contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract NoboToken is Ownable {

    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 totalSupply_;

    constructor() public {
        name = "Nobotoken";
        symbol = "NBX";
        decimals = 18;
        totalSupply_ = 0;
    }

    // -----------------------------------------------------------------------
    // ------------------------- GENERAL ERC20 -------------------------------
    // -----------------------------------------------------------------------
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    /*
    * @dev tracks token balances of users
    */
    mapping (address => uint256) balances;

    /*
    * @dev transfer token for a specified address
    */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /*
    * @dev total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
    /*
    * @dev gets the balance of the specified address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }



    // -----------------------------------------------------------------------
    // ------------------------- ALLOWANCE RELEATED --------------------------
    // -----------------------------------------------------------------------

    /*
    * @dev tracks the allowance an address has from another one
    */
    mapping (address => mapping (address => uint256)) internal allowed;

    /*
    * @dev transfers token from one address to another, must have allowance
    */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool success)
    {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /*
    * @dev gives allowance to spender, works together with transferFrom
    */
    function approve(
        address _spender,
        uint256 _value
    )
        public
        returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /*
    * @dev used to increase the allowance a spender has
    */
    function increaseApproval(
        address _spender,
        uint _addedValue
    )
        public
        returns (bool success)
    {
        allowed[msg.sender][_spender] =
            allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /*
    * @dev used to decrease the allowance a spender has
    */
    function decreaseApproval(
        address _spender,
        uint _subtractedValue
    )
        public
        returns (bool success)
    {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /*
    * @dev used to check what allowance a spender has from the owner
    */
    function allowance(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    // -----------------------------------------------------------------------
    //--------------------------- MINTING RELEATED ---------------------------
    // -----------------------------------------------------------------------
    /*
    * @title Mintable token
    * @dev instead of another contract, all mintable functionality goes here
    */
    event Mint(
        address indexed to,
        uint256 amount
    );
    event MintFinished();

    /*
    * @dev signifies whether or not minting process is over
    */
    bool public mintingFinished = false;

    modifier canMint() {
        require(!mintingFinished);
        _;
    }


    /*
    * @dev minting of tokens, restricted to owner address (crowdsale)
    */
    function mint(
        address _to,
        uint256 _amount
    )
        public
        onlyOwner
        canMint
        returns (bool success)
    {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    /*
    * @dev Function to stop minting new tokens.
    */
    function finishMinting() onlyOwner canMint public returns (bool success) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }
}

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}