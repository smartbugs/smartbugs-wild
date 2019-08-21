pragma solidity ^0.4.15;

//import "./AuthAdmin.sol";
//import "./SingleTokenCoin.sol";
//import "./SafeMath.sol";

contract IcoManagement {
    
    using SafeMath for uint256;
    
    uint256 price = 1E17; // wei per 1 token
    uint256 fract_price = 1E11;  // wei per 0.000001 token
    //uint256 public icoStartTime = now;
    uint256 public icoStartTime = 1512864000; //10 dec 2017 00:00
    uint256 public icoEndTime = 1518220800; // 10 feb 2018 00:00
    //uint256 public icoEndTime = now + 60 days; // for testing
    // uint256 public icoEndTime = 1517270400; 
    uint256 public min_inv = 1E17;
    uint256 public minCap = 3000E18;
    uint256 public funded;
    // uint256 public tokenHolders;
    
    bool public icoPhase = true;
    bool public ico_rejected = false;
    // bool token_valid = false;

    mapping(address => uint256) public contributors;
    

    SingleTokenCoin public token;
    AuthAdmin authAdmin ;

    event Icoend();
    event Ico_rejected(string details);
    
    modifier onlyDuringIco {
        require (icoPhase);
        require(now < icoEndTime && now > icoStartTime);
        _;
    }

    modifier adminOnly {
        require (authAdmin.isCurrentAdmin(msg.sender));
        _;
    }
    
    /*modifier usersOnly {
        require(authAdmin.isCurrentUser(msg.sender));
        _;
    }*/
    
    function () onlyDuringIco public payable {
        invest(msg.sender);
    }
    
    function invest(address _to) public onlyDuringIco payable {
        uint256 purchase = msg.value;
        contributors[_to] = contributors[_to].add(purchase);
        require (purchase >= min_inv);
        uint256 change = purchase.mod(fract_price);
        uint256 clean_purchase = purchase.sub(change);
	    funded = funded.add(clean_purchase);
        uint256 token_amount = clean_purchase.div(fract_price);
        require (_to.send(change));
        token.mint(_to, token_amount);
    }
    
    function IcoManagement(address admin_address) public {
        require (icoStartTime <= icoEndTime);
        authAdmin = AuthAdmin(admin_address);
    }

    function set_token(address _addr) public adminOnly {
        token = SingleTokenCoin(_addr);
    }

    function end() public adminOnly {
        require (now >= icoEndTime);
        icoPhase = false;
        Icoend();
    }
    
    
    function withdraw_funds (uint256 amount) public adminOnly {
        require (this.balance >= amount);
        msg.sender.transfer(amount);
    }

    function withdraw_all_funds () public adminOnly {
        msg.sender.transfer(this.balance);
    }
    
    function withdraw_if_failed() public {
        require(now > icoEndTime);
	    require(funded<minCap);
        require(!icoPhase);
        require (contributors[msg.sender] != 0);
        require (this.balance >= contributors[msg.sender]);
        uint256 amount = contributors[msg.sender];
        contributors[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
    // function reject (string details) adminOnly {
    //     // require (now > icoEndTime);
    //     // require (!ico_rejected);
    //     strlog("gone");
    //     uint256 dividend_per_token = this.balance / token.totalSupply();
    //     log(dividend_per_token);
    //     log(this.balance);
    //     log(token.totalSupply());
    //     uint numberTokenHolders = token.count_token_holders();
    //     log(numberTokenHolders);
    //     uint256 total_rejected = 0;
    //     for (uint256 i = 0; i < numberTokenHolders; i++) {
    //         address addr = token.tokenHolder(i);
    //         adlog(addr);
    //         uint256 etherToSend = dividend_per_token * token.balanceOf(addr);
    //         log(etherToSend);
    //         // require (etherToSend < 1E18);
    //         rejectedIcoBalances[addr] = rejectedIcoBalances[addr].add(etherToSend);
    //         log(rejectedIcoBalances[addr]);
    //         total_rejected = total_rejected.add(etherToSend);
    //         log(total_rejected);
    //     }
    //     ico_rejected = true;
    //     Ico_rejected(details);
    //     uint256 remainder = this.balance.sub(total_rejected);
    //     log(remainder);
    //     require (remainder > 0);
    //     require (msg.sender.send(remainder));
    //     strlog("gone");
    //     rejectedIcoBalances[msg.sender] = rejectedIcoBalances[msg.sender].add(remainder);
    // }

    // function rejectedFundWithdrawal() {
    //     
    // }
}

contract AuthAdmin {
    
    address[] admins_array;
    address[] users_array;
    
    mapping (address => bool) admin_addresses;
    mapping (address => bool) user_addresses;

    event NewAdmin(address addedBy, address admin);
    event RemoveAdmin(address removedBy, address admin);
    event NewUserAdded(address addedBy, address account);
    event RemoveUser(address removedBy, address account);

    function AuthAdmin() public {
        admin_addresses[msg.sender] = true;
        NewAdmin(0, msg.sender);
        admins_array.push(msg.sender);
    }

    function addAdmin(address _address) public {
        require (isCurrentAdmin(msg.sender));
        require (!admin_addresses[_address]);
        admin_addresses[_address] = true;
        NewAdmin(msg.sender, _address);
        admins_array.push(_address);
    }

    function removeAdmin(address _address) public {
        require(isCurrentAdmin(msg.sender));
        require (_address != msg.sender);
        require (admin_addresses[_address]);
        admin_addresses[_address] = false;
        RemoveAdmin(msg.sender, _address);
    }

    function add_user(address _address) public {
        require (isCurrentAdmin(msg.sender));
        require (!user_addresses[_address]);
        user_addresses[_address] = true;
        NewUserAdded(msg.sender, _address);
        users_array.push(_address);
    }

    function remove_user(address _address) public {
        require (isCurrentAdmin(msg.sender));
        require (user_addresses[_address]);
        user_addresses[_address] = false;
        RemoveUser(msg.sender, _address);
    }
                    /*----------------------------
                                Getters
                    ----------------------------*/
    
    function isCurrentAdmin(address _address) public constant returns (bool) {
        return admin_addresses[_address];
    }

    function isCurrentOrPastAdmin(address _address) public constant returns (bool) {
        for (uint256 i = 0; i < admins_array.length; i++)
            require (admins_array[i] == _address);
                return true;
        return false;
    }

    function isCurrentUser(address _address) public constant returns (bool) {
        return user_addresses[_address];
    }

    function isCurrentOrPastUser(address _address) public constant returns (bool) {
        for (uint256 i = 0; i < users_array.length; i++)
            require (users_array[i] == _address);
                return true;
        return false;
    }
}
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
  function mod(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a % b;
    //uint256 z = a / b;
    assert(a == (a / b) * b + c); // There is no case in which this doesn't hold
    return c;
  }
}

contract BasicToken is ERC20Basic {
    using SafeMath for uint256;
    mapping(address => uint256) public balances;
    mapping(address => bool) public holders;
    address[] public token_holders_array;
    
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        if (!holders[_to]) {
            holders[_to] = true;
            token_holders_array.push(_to);
        }

        balances[_to] = balances[_to].add(_value);
        balances[msg.sender] = balances[msg.sender].sub(_value);


        /*if (balances[msg.sender] == 0) {
            uint id = get_index(msg.sender);
            delete token_holders_array[id];
            token_holders_array[id] = token_holders_array[token_holders_array.length - 1];
            delete token_holders_array[token_holders_array.length-1];
            token_holders_array.length--;
        }*/

        Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function get_index (address _whom) constant internal returns (uint256) {
        for (uint256 i = 0; i<token_holders_array.length; i++) {
            if (token_holders_array[i] == _whom) {
                return i;
            }
            //require (token_holders_array[i] == _whom);
        }
    }
    
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
    
    function count_token_holders () public constant returns (uint256) {
        return token_holders_array.length;
    }
    
    function tokenHolder(uint256 _index) public constant returns (address) {
        return token_holders_array[_index];
    }
      
}

contract StandardToken is ERC20, BasicToken {
  mapping (address => mapping (address => uint256)) internal allowed;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    if (!holders[_to]) {
        holders[_to] = true;
        token_holders_array.push(_to);
    }
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
  
  function approve(address _spender, uint256 _value) public returns (bool) {
    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  function increaseApproval (address _spender, uint256 _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
  function decreaseApproval (address _spender, uint256 _subtractedValue) public returns (bool success) {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}

contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
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

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  bool public mintingFinished = false;
  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    if (!holders[_to]) {
        holders[_to] = true;
        token_holders_array.push(_to);
    } 
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

contract SingleTokenCoin is MintableToken {
  string public constant name = "Symmetry Fund Token";
  string public constant symbol = "SYMM";
  uint256 public constant decimals = 6;
 }