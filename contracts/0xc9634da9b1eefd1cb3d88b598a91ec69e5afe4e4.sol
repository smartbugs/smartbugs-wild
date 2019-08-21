pragma solidity 0.5.10;

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
    uint256 c = a / b;
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

  function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
    uint256 c = add(a,m);
    uint256 d = sub(c,1);
    return mul(div(d,m),m);
  }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract MaxumToken is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 public _burnRate;
    uint256 private _totalSupply;
    

    string public constant name = "Maxum";
    string public constant symbol = "MUM";
    uint256 public constant decimals = 0;

    uint256 public constant INITIAL_SUPPLY = 200000000000 * 10**decimals;

  /**
   * @dev Contructor
   */
  constructor() public {
    _totalSupply = INITIAL_SUPPLY;
    _balances[0x7C1A414C71D2dCc7440901c0Adf49c34039E496b ] = INITIAL_SUPPLY;
    emit Transfer(address(0), 0x7C1A414C71D2dCc7440901c0Adf49c34039E496b ,_totalSupply);
    
  }


    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }


    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        
        uint256 tokensToBurn = _tokenToBurn(amount);
        uint256 tokensToTransfer = amount.sub(tokensToBurn);
        
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(tokensToTransfer);

        _totalSupply = _totalSupply.sub(tokensToBurn);
        
        emit Transfer(sender, recipient, tokensToTransfer);
        emit Transfer(sender, address(0), tokensToBurn);
    }
    

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    
    function burnRate() public returns(uint256) {
        if (_totalSupply > 180000000000) {
            _burnRate = 2;
        } else if(_totalSupply <= 180000000000 && _totalSupply > 160000000000) {
            _burnRate = 4;
        } else if(_totalSupply <= 160000000000 && _totalSupply > 140000000000) {
            _burnRate = 6;
        } else if(_totalSupply <= 140000000000 && _totalSupply > 120000000000) {
            _burnRate = 8;
        } else if(_totalSupply <= 120000000000 && _totalSupply > 100000000000) {
            _burnRate = 10;
        } else if(_totalSupply <= 100000000000 && _totalSupply > 80000000000) {
            _burnRate = 12;
        } else if(_totalSupply <= 80000000000 && _totalSupply > 60000000000) {
            _burnRate = 14;
        } else if(_totalSupply <= 60000000000 && _totalSupply > 30000000000) {
            _burnRate = 16;
        } else if(_totalSupply <= 30000000000 && _totalSupply > 10000000000) {
            _burnRate = 20;
        }  else if(_totalSupply <= 10000000000 && _totalSupply > 1000000000) {
            _burnRate = 24;
        } else if(_totalSupply <= 1000000000) {
            _burnRate = 30;
        } 
        
        return _burnRate;
    }

    
    function _tokenToBurn(uint256 value) public returns(uint256){ 
        uint256 _burnerRate = burnRate();
        uint256 roundValue = value.ceil(_burnerRate);
        uint256 _myTokensToBurn = roundValue.mul(_burnerRate).div(100);
        return _myTokensToBurn;
    }
    
}