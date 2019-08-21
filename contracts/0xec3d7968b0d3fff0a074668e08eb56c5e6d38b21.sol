pragma solidity ^0.4.25;

/**
 * @title Ownable contract - base contract with an owner
 */
contract Ownable {
  
  address public owner;
  address public newOwner;

  event OwnershipTransferred(address indexed _from, address indexed _to);
  
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
    assert(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    assert(_newOwner != address(0));      
    newOwner = _newOwner;
  }

  /**
   * @dev Accept transferOwnership.
   */
  function acceptOwnership() public {
    if (msg.sender == newOwner) {
      emit OwnershipTransferred(owner, newOwner);
      owner = newOwner;
    }
  }
}


/**
 * @title SDADI - Interface
 */
interface SDADI  {	
  function AddToken(address token) external;
  function DelToken(address token) external;
}


/**
 * @title DAppDEXI - Interface 
 */
interface DAppDEXI {

    function updateAgent(address _agent, bool _status) external;

    function setAccountType(address user_, uint256 type_) external;
    function getAccountType(address user_) external view returns(uint256);
    function setFeeType(uint256 type_ , uint256 feeMake_, uint256 feeTake_) external;
    function getFeeMake(uint256 type_ ) external view returns(uint256);
    function getFeeTake(uint256 type_ ) external view returns(uint256);
    function changeFeeAccount(address feeAccount_) external;
    
    function setWhitelistTokens(address token) external;
    function setWhitelistTokens(address token, bool active, uint256 timestamp, bytes32 typeERC) external;
    function depositToken(address token, uint amount) external;
    function tokenFallback(address owner, uint256 amount, bytes data) external returns (bool success);

    function withdraw(uint amount) external;
    function withdrawToken(address token, uint amount) external;

    function balanceOf(address token, address user) external view returns (uint);

    function order(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce) external;
    function trade(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount) external;    
    function cancelOrder(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, uint8 v, bytes32 r, bytes32 s) external;
    function testTrade(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount, address sender) external view returns(bool);
    function availableVolume(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) external view returns(uint);
    function amountFilled(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user) external view returns(uint);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface ERC20I {

  function balanceOf(address _owner) external view returns (uint256);

  function totalSupply() external view returns (uint256);
  function transfer(address _to, uint256 _value) external returns (bool success);
  
  function allowance(address _owner, address _spender) external view returns (uint256);
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
  function approve(address _spender, uint256 _value) external returns (bool success);
  
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {

    /**
    * @dev Subtracts two numbers, reverts on overflow.
    */
    function safeSub(uint256 x, uint256 y) internal pure returns (uint256) {
        assert(y <= x);
        uint256 z = x - y;
        return z;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function safeAdd(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x + y;
        assert(z >= x);
        return z;
    }
	
	/**
    * @dev Integer division of two numbers, reverts on division by zero.
    */
    function safeDiv(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x / y;
        return z;
    }
    
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */	
    function safeMul(uint256 x, uint256 y) internal pure returns (uint256) {    
        if (x == 0) {
            return 0;
        }
    
        uint256 z = x * y;
        assert(z / x == y);
        return z;
    }

    /**
    * @dev Returns the integer percentage of the number.
    */
    function safePerc(uint256 x, uint256 y) internal pure returns (uint256) {
        if (x == 0) {
            return 0;
        }
        
        uint256 z = x * y;
        assert(z / x == y);    
        z = z / 10000; // percent to hundredths
        return z;
    }

    /**
    * @dev Returns the minimum value of two numbers.
    */	
    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x <= y ? x : y;
        return z;
    }

    /**
    * @dev Returns the maximum value of two numbers.
    */
    function max(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x >= y ? x : y;
        return z;
    }
}


/**
 * @title Agent contract - base contract with an agent
 */
contract Agent is Ownable {

  address public defAgent;

  mapping(address => bool) public Agents;
  
  constructor() public {    
    Agents[msg.sender] = true;
  }
  
  modifier onlyAgent() {
    assert(Agents[msg.sender]);
    _;
  }
  
  function updateAgent(address _agent, bool _status) public onlyOwner {
    assert(_agent != address(0));
    Agents[_agent] = _status;
  }  
}


/**
 * @title DAppsDEX - Decentralized exchange for DApps
 */
contract DAppDEX is DAppDEXI, SafeMath, Agent {
    
    address public feeAccount;
    mapping (address => mapping (address => uint)) public tokens;
    mapping (address => mapping (bytes32 => bool)) public orders;
    mapping (address => mapping (bytes32 => uint)) public orderFills;

    uint public feeListing = 100; // 1.00%

    struct whitelistToken {
        bool active;
        uint256 timestamp;
    }
    
    struct Fee {
        uint256 feeMake;
        uint256 feeTake;
    }
    
    mapping (address => whitelistToken) public whitelistTokens;
    mapping (address => uint256) public accountTypes;
    mapping (uint256 => Fee) public feeTypes;
  
    event Deposit(address token, address user, uint amount, uint balance);
    event PayFeeListing(address token, address user, uint amount, uint balance);
    event Withdraw(address token, address user, uint amount, uint balance);
    event Order(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user);
    event Cancel(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, bytes32 hash);
    event Trade(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, address user, address recipient, bytes32 hash, uint256 timestamp);
    event WhitelistTokens(address token, bool active, uint256 timestamp, bytes32 typeERC);
  
    constructor (address feeAccount_) public {
        feeAccount = feeAccount_;
        feeTypes[0] = Fee(1000000000000000, 2000000000000000);
        whitelistTokens[0] = whitelistToken(true, 1);
        emit WhitelistTokens(0, true, 1, 0x0);
    }

    function setFeeListing(uint _feeListing) external onlyAgent {
        feeListing = _feeListing;
    }
    
    function setAccountType(address user_, uint256 type_) external onlyAgent {
        accountTypes[user_] = type_;
    }

    function getAccountType(address user_) external view returns(uint256) {
        return accountTypes[user_];
    }
  
    function setFeeType(uint256 type_ , uint256 feeMake_, uint256 feeTake_) external onlyAgent {
        feeTypes[type_] = Fee(feeMake_,feeTake_);
    }

    function getFeeMake(uint256 type_ ) external view returns(uint256) {
        return (feeTypes[type_].feeMake);
    }
    
    function getFeeTake(uint256 type_ ) external view returns(uint256) {
        return (feeTypes[type_].feeTake);
    }
    
    function changeFeeAccount(address feeAccount_) external onlyAgent {
        require(feeAccount_ != address(0));
        feeAccount = feeAccount_;
    }

    function setWhitelistTokens(address token) external onlyOwner {
        whitelistTokens[token].active = true;
        whitelistTokens[token].timestamp = now;
        SDADI(feeAccount).AddToken(token);
        emit WhitelistTokens(token, true, now, "ERC20");
    }    
    
    function setWhitelistTokens(address token, bool active, uint256 timestamp, bytes32 typeERC) external onlyAgent {
        if (active) {
            uint fee = safePerc(ERC20I(token).totalSupply(), feeListing);
            require(fee > 0);
            require(tokens[token][feeAccount] >= fee);
            SDADI(feeAccount).AddToken(token);
        } else {
            SDADI(feeAccount).DelToken(token);
        }
        whitelistTokens[token].active = active;
        whitelistTokens[token].timestamp = timestamp;
        emit WhitelistTokens(token, active, timestamp, typeERC);
    }
    
    /**
    * deposit ETH
    */
    function() public payable {
        require(msg.value > 0);
        deposit(msg.sender);
    }
  
    /**
    * Make deposit.
    *
    * @param receiver The Ethereum address who make deposit
    *
    */
    function deposit(address receiver) private {
        tokens[0][receiver] = safeAdd(tokens[0][receiver], msg.value);
        emit Deposit(0, receiver, msg.value, tokens[0][receiver]);
    }
  
    /**
    * Deposit token.
    *
    * @param token Token address
    * @param amount Deposit amount
    *
    */
    function depositToken(address token, uint amount) external {
        require(token != address(0));
        if (whitelistTokens[token].active) {
            require(whitelistTokens[token].timestamp <= now);
            require(ERC20I(token).transferFrom(msg.sender, this, amount));
            tokens[token][msg.sender] = safeAdd(tokens[token][msg.sender], amount);
            emit Deposit(token, msg.sender, amount, tokens[token][msg.sender]);
        } else {
            require(ERC20I(token).transferFrom(msg.sender, this, amount));
            tokens[token][feeAccount] = safeAdd(tokens[token][feeAccount], amount);
            emit PayFeeListing(token, msg.sender, amount, tokens[msg.sender][feeAccount]);
        }
        
    }

    /**
    * tokenFallback ERC223.
    *
    * @param owner owner token
    * @param amount Deposit amount
    * @param data payload  
    *
    */
    function tokenFallback(address owner, uint256 amount, bytes data) external returns (bool success) {      

        if (data.length == 0) {
            assert(whitelistTokens[msg.sender].active && whitelistTokens[msg.sender].timestamp <= now);            
            tokens[msg.sender][owner] = safeAdd(tokens[msg.sender][owner], amount);
            emit Deposit(msg.sender, owner, amount, tokens[msg.sender][owner]);
            return true;
        } else {
            tokens[msg.sender][feeAccount] = safeAdd(tokens[msg.sender][feeAccount], amount);
            emit PayFeeListing(msg.sender, owner, amount, tokens[msg.sender][feeAccount]);
            return true;
        }
    }

    /**
    * Withdraw deposit.
    *
    * @param amount Withdraw amount
    *
    */
    function withdraw(uint amount) external {
        require(tokens[0][msg.sender] >= amount);
        tokens[0][msg.sender] = safeSub(tokens[0][msg.sender], amount);
        msg.sender.transfer(amount);
        emit Withdraw(0, msg.sender, amount, tokens[0][msg.sender]);
    }  
    
    /**
    * Withdraw token.
    *
    * @param token Token address
    * @param amount Withdraw amount
    *
    */
    function withdrawToken(address token, uint amount) external {
        require(token != address(0));
        require(tokens[token][msg.sender] >= amount);
        tokens[token][msg.sender] = safeSub(tokens[token][msg.sender], amount);
        require(ERC20I(token).transfer(msg.sender, amount));
        emit Withdraw(token, msg.sender, amount, tokens[token][msg.sender]);
    }
  
    function balanceOf(address token, address user) external view returns (uint) {
        return tokens[token][user];
    }
  
    function order(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce) external {
        bytes32 hash = keccak256(abi.encodePacked(this, tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, msg.sender));
        orders[msg.sender][hash] = true;
        emit Order(tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, msg.sender);
    }
  
    function trade(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount) external {
        bytes32 hash = keccak256(abi.encodePacked(this, tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, user));
        if (!(
            (orders[user][hash] || ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)),v,r,s) == user) &&
            block.timestamp <= expires &&
            safeAdd(orderFills[user][hash], amount) <= amountBuy
        )) revert();
        tradeBalances(tokenBuy, amountBuy, tokenSell, amountSell, user, amount);
        orderFills[user][hash] = safeAdd(orderFills[user][hash], amount);
        emit Trade(tokenBuy, amount, tokenSell, amountSell * amount / amountBuy, user, msg.sender, hash, block.timestamp);
    }

    function tradeBalances(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, address user, uint amount) private {
        uint feeMakeXfer = safeMul(amount, feeTypes[accountTypes[user]].feeMake) / (10**18);
        uint feeTakeXfer = safeMul(amount, feeTypes[accountTypes[msg.sender]].feeTake) / (10**18);
        tokens[tokenBuy][msg.sender] = safeSub(tokens[tokenBuy][msg.sender], safeAdd(amount, feeTakeXfer));
        tokens[tokenBuy][user] = safeAdd(tokens[tokenBuy][user], safeSub(amount, feeMakeXfer));
        tokens[tokenBuy][feeAccount] = safeAdd(tokens[tokenBuy][feeAccount], safeAdd(feeMakeXfer, feeTakeXfer));
        tokens[tokenSell][user] = safeSub(tokens[tokenSell][user], safeMul(amountSell, amount) / amountBuy);
        tokens[tokenSell][msg.sender] = safeAdd(tokens[tokenSell][msg.sender], safeMul(amountSell, amount) / amountBuy);
    }
  
    function cancelOrder(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 hash = keccak256(abi.encodePacked(this, tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, msg.sender));
        if (!(orders[msg.sender][hash] || ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)),v,r,s) == msg.sender)) revert();
        orderFills[msg.sender][hash] = amountBuy;
        emit Cancel(tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, msg.sender, v, r, s, hash);
    }
  
    function testTrade(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount, address sender) external view returns(bool) {
        if (!(
            tokens[tokenBuy][sender] >= amount &&
            availableVolume(tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, user, v, r, s) >= amount
        )) return false;
        return true;
    }

    function availableVolume(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) public view returns(uint) {
        bytes32 hash = keccak256(abi.encodePacked(this, tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, user));
        if (!(
            (orders[user][hash] || ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)),v,r,s) == user) &&
            block.timestamp <= expires
        )) return 0;
        uint available1 = safeSub(amountBuy, orderFills[user][hash]);
        uint available2 = safeMul(tokens[tokenSell][user], amountBuy) / amountSell;
        if (available1<available2) return available1;
        return available2;
    }

    function amountFilled(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user) external view returns(uint) {
        bytes32 hash = keccak256(abi.encodePacked(this, tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, user));
        return orderFills[user][hash];
    }
}