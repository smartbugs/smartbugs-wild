pragma solidity ^0.4.23;

contract ERC20Interface {
  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function allowance(address _owner, address _spender) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * support ERC677
 * reference: https://github.com/ethereum/EIPs/issues/677
 * |--------------|            |-----------------------|            |-------------------------|
 * |    Sender    |            | ERC677SenderInterface |            | ERC677ReceiverInterface |
 * |--------------|            |-----------------------|            |-------------------------|
 *        |       transferAndCall()        |                                      |
 *        |------------------------------->|            tokenFallback()           |
 *        |                                |------------------------------------->|
 *        |                                |                                      |
 */
contract ERC677ReceiverInterface {
    function tokenFallback(address _sender, uint256 _value, bytes _extraData) 
        public returns (bool);
}

contract ERC677SenderInterface {
    function transferAndCall(address _recipient, uint256 _value, bytes _extraData) 
        public returns (bool);
}

/**
 *    __             ___      _       
 *   /__\_ _  __ _  / __\___ (_)_ __  
 *  /_\/ _` |/ _` |/ /  / _ \| | '_ \ 
 * //_| (_| | (_| / /__| (_) | | | | |
 * \__/\__, |\__, \____/\___/|_|_| |_|
 *     |___/ |___/                    
 * Egg Coin is an internal token that play game developed by LEGG team.
 * Actually, this token has no total supply limit, when minting, the total supply will increase.
 * */

contract EggCoin is ERC20Interface, ERC677SenderInterface {
    
    using SafeMath for *;
    
    constructor()
        public
    {
        owner_ = msg.sender;
        // no supply any token after deploying contract.
        totalSupply_ = 0;
    }
    
    address public owner_;
    
    string public name = "Egg Coin";
    string public symbol = "EGG";
    uint8 public decimals = 18;
    
    mapping(address => uint256) private balances_;
    mapping(address => mapping(address => uint256)) private allowed_;
    uint256 private totalSupply_;
 
    /**
     *                   _ _  __ _               
     *   /\/\   ___   __| (_)/ _(_) ___ _ __ ___ 
     *  /    \ / _ \ / _` | | |_| |/ _ \ '__/ __|
     * / /\/\ \ (_) | (_| | |  _| |  __/ |  \__ \
     * \/    \/\___/ \__,_|_|_| |_|\___|_|  |___/
     * 
     * */   
     
    modifier onlyOwner(
        address _address
    )
    {
        require(_address == owner_, "This action not allowed because of permission.");
        _;
    }
    
    /**
     *     __                 _       
     *    /__\_   _____ _ __ | |_ ___   
     *   /_\ \ \ / / _ \ '_ \| __/ __|
     *  //__  \ V /  __/ | | | |_\__ \
     *  \__/   \_/ \___|_| |_|\__|___/
     * */
    event Mint(
        address miner,
        uint256 totalSupply
    );
    
    event TransferOwnership(
        address newOwner
    );
    
    /**
     *      __  __    ___ ____   ___      ___                 _   _                 
     *     /__\/__\  / __\___ \ / _ \    / __\   _ _ __   ___| |_(_) ___  _ __  ___  
     *    /_\ / \// / /    __) | | | |  / _\| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
     *   //__/ _  \/ /___ / __/| |_| | / /  | |_| | | | | (__| |_| | (_) | | | \__ \
     *   \__/\/ \_/\____/|_____|\___/  \/    \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
     *  ERC20 Functions
     * */
     
    function totalSupply()
        view
        public
        returns
        (uint256)
    {
        return totalSupply_;
    }
    
    function balanceOf(
        address _address
    )
        view
        public 
        returns
        (uint256)
    {
        return balances_[_address];
    }
    
    function allowance(
        address _who,
        address _spender
    )
        view
        public
        returns
        (uint256)
    {
        return allowed_[_who][_spender];
    }
    
    function transfer(
        address _to,
        uint256 _value
    )
        public
        returns
        (bool)
    {
        require(balances_[msg.sender] >= _value, "Insufficient balance");
        require(_to != address(0), "Don't burn the token please!");
        
        balances_[msg.sender] = balances_[msg.sender].sub(_value);
        balances_[_to] = balances_[_to].add(_value);
        
        emit Transfer(
            msg.sender,
            _to,
            _value
        );
        
        return true;
    }
    
    function approve(
        address _spender, 
        uint256 _value
    ) 
        public 
        returns 
        (bool)
    {
        allowed_[msg.sender][_spender] = _value;
        emit Approval(
            msg.sender,
            _spender,
            _value
        );
        
        return true;
    }
    
    function transferFrom(
        address _from, 
        address _to,
        uint256 _value
    ) 
        public 
        returns 
        (bool)
    {
        require(balances_[_from] >= _value, "Owner Insufficient balance");
        require(allowed_[_from][msg.sender] >= _value, "Spender Insufficient balance");
        require(_to != address(0), "Don't burn the coin.");
        
        balances_[_from] = balances_[_from].sub(_value);
        balances_[_to] = balances_[_to].add(_value);
        allowed_[_from][msg.sender] = allowed_[_from][msg.sender].sub(_value);
        
        emit Transfer(
            _from,
            _to,
            _value
        );
        
        return true;
    }
    
    function increaseApproval(
        address _spender,
        uint256 _addValue
    )
        public
        returns
        (bool)
    {
        allowed_[msg.sender][_spender] = 
            allowed_[msg.sender][_spender].add(_addValue);
        
        emit Approval(
            msg.sender,
            _spender,
            allowed_[msg.sender][_spender]
        );
        
        return true;
    }
    
    function decreaseApproval(
        address _spender,
        uint256 _substractValue
    )
        public
        returns
        (bool)
    {
        uint256 _oldValue = allowed_[msg.sender][_spender];
        if(_oldValue >= _substractValue) {
            allowed_[msg.sender][_spender] = _oldValue.sub(_substractValue);
        } 
        else {
            allowed_[msg.sender][_spender] = 0;    
        }
        
        emit Approval(
            msg.sender,
            _spender,
            allowed_[msg.sender][_spender]
        );
        
        return true;
    }
    
    /**
     * @dev ERC677 support
     * 
     * */
    function transferAndCall(address _recipient,
                    uint256 _value,
                    bytes _extraData)
        public
        returns
        (bool)
    {
        transfer(_recipient, _value);
        if(isContract(_recipient)) {
            require(ERC677ReceiverInterface(_recipient).tokenFallback(msg.sender, _value, _extraData));
        }
        return true;
    }
    
    function isContract(address _addr) private view returns (bool) {
        uint len;
        assembly {
            len := extcodesize(_addr)
        }
        return len > 0;
    }
    
    /**
     
     *    ___                                            _       
     *   /___\__      ___ __   ___ _ __       ___  _ __ | |_   _ 
     *  //  //\ \ /\ / / '_ \ / _ \ '__|____ / _ \| '_ \| | | | |
     * / \_//  \ V  V /| | | |  __/ | |_____| (_) | | | | | |_| |
     * \___/    \_/\_/ |_| |_|\___|_|        \___/|_| |_|_|\__, |
     *                                                     |___/                                               
     * The functions that owner can call.
     */
     
    function transferOwnership(
        address _newOwner
    )
        public
        onlyOwner(msg.sender)
    {
        owner_ = _newOwner;
        emit TransferOwnership(_newOwner);
    }
    
    function mint(
        uint256 _amount
    )
        public
        onlyOwner(msg.sender)
    {
        totalSupply_ = totalSupply_.add(_amount);
        balances_[msg.sender] = balances_[msg.sender].add(_amount);
        emit Transfer(
            address(0),
            msg.sender,
            _amount
        );
    }
}

/**
 *   __        __                      _   _     
    / _\ __ _ / _| ___ _ __ ___   __ _| |_| |__  
    \ \ / _` | |_ / _ \ '_ ` _ \ / _` | __| '_ \ 
    _\ \ (_| |  _|  __/ | | | | | (_| | |_| | | |
    \__/\__,_|_|  \___|_| |_| |_|\__,_|\__|_| |_|
      
    SafeMath library, thanks to openzeppelin solidity.
    https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 * */

library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}