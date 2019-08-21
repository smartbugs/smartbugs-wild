pragma solidity >=0.5;
pragma experimental ABIEncoderV2;

/**
 * @title DexStatus
 * @dev Status for Dex  
 */ 
contract DexStatus {
    string constant ONLY_RELAYER    = "ONLY_RELAYER";
    string constant ONLY_AIRDROP    = "ONLY_AIRDROP"; 
    string constant ONLY_INACTIVITY = "ONLY_INACTIVITY";
    string constant ONLY_WITHDRAWALAPPROVED = "ONLY_WITHDRAWALAPPROVED";

    string constant INVALID_NONCE  = "INVALID_NONCE";  
    string constant INVALID_PERIOD = "INVALID_PERIOD";
    string constant INVALID_AMOUNT = "INVALID_AMOUNT";
    string constant INVALID_TIME   = "INVALID_TIME";
    string constant INVALID_GASTOKEN = "INVALID_GASTOKEN";

    string constant TRANSFER_FAILED = "TRANSFER_FAILED";
    string constant ECRECOVER_FAILED  = "ECRECOVER_FAILED";

    string constant INSUFFICIENT_FOUND = "INSUFFICIENT";  
    string constant TRADE_EXISTS       = "TRADED";
    string constant WITHDRAW_EXISTS    = "WITHDRAWN";

    string constant MAX_VALUE_LIMIT = "MAX_LIMIT";

    string constant AMOUNT_EXCEEDED = "AMOUNT_EXCEEDED"; 
}



/**
 * @title IGasStorage
 * @dev  GasStorage interface to burn and mint gastoken
 */
interface IGasStorage
{
    function mint(uint256 value) external;
    function burn(uint256 value) external;
    function balanceOf() external view returns (uint256 balance);
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = tx.origin;
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

/** 
 * @dev ERC20 interface
 */
interface ERC20 {  
    function balanceOf(address _owner) external view returns (uint256 balance); 
    function transfer(address _to, uint256 _value) external returns (bool success) ; 
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success); 
    function approve(address _spender, uint256 _value) external returns (bool success); 
    function allowance(address _owner, address _spender) view external returns (uint256 remaining); 
}
 
/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

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
  
 

 

/**
 * @title Dex
 * @dev Smart contract for https://www.dex.io
 */ 
contract Dex is Ownable,DexStatus {  
    using SafeMath for uint256;     
    
    struct Order
    {
        address token;
        address baseToken; 
        address user;  
        uint256 tokenAmount;
        uint256 baseTokenAmount;
        uint    nonce;
        uint    expireTime;  
        uint    maxGasFee;  
        uint    timestamp;
        address gasToken;  
        bool    sell;
        uint8   V;
        bytes32 R;
        bytes32 S;  
        uint    signType;
    } 

    struct TradeInfo {
        uint256 tradeTokenAmount;   
        uint256 tradeTakerFee;
        uint256 tradeMakerFee;    
        uint256 tradeGasFee;
        uint    tradeNonce; 
        address tradeGasToken;  
    }    

    mapping (address => mapping (address => uint256)) public _balances;  

    mapping (address => uint)     public _invalidOrderNonce;     

    mapping (bytes32 => uint256)  public _orderFills;

    mapping (address => bool)     public _relayers;

    mapping (bytes32 => bool)     public _traded;
    mapping (bytes32 => bool)     public _withdrawn;   
     
    mapping (bytes32 => uint256)  public _orderGasFee; 
  
    mapping (address => uint)     public _withdrawalApplication;

    address public       _feeAccount; 
    address public       _airdropContract;  
    address public       _gasStorage;

    uint256 public _withdrawalApplicationPeriod = 10 days;
 
    uint256 public _takerFeeRate   = 0.002 ether;
    uint256 public _makerFeeRate   = 0.001 ether;    
 
    string  private constant EIP712DOMAIN_TYPE  = "EIP712Domain(string name)";
    bytes32 private constant EIP712DOMAIN_TYPEHASH = keccak256(abi.encodePacked(EIP712DOMAIN_TYPE)); 
    bytes32 private constant DOMAIN_SEPARATOR = keccak256(abi.encode(EIP712DOMAIN_TYPEHASH,keccak256(bytes("Dex.io"))));
 
    string  private constant  ORDER_TYPE = "Order(address token,address baseToken,uint256 tokenAmount,uint256 baseTokenAmount,uint256 nonce,bool sell,uint256 expireTime,uint256 maxGasFee,address gasToken,uint timestamp)";    
    bytes32 private constant  ORDER_TYPEHASH = keccak256(abi.encodePacked(ORDER_TYPE)); 
    
    string  private constant  WITHDRAW_TYPE = "Withdraw(address token,uint256 tokenAmount,address to,uint256 nonce,address feeToken,uint256 feeWithdrawal,uint timestamp)";    
    bytes32 private constant  WITHDRAW_TYPEHASH = keccak256(abi.encodePacked(WITHDRAW_TYPE));

    event Trade(bytes32 takerHash,bytes32 makerHash,uint256 tradeAmount,uint256 tradeBaseTokenAmount,uint256 tradeNonce,uint256 takerCostFee,
          uint makerCostFee,bool sellerIsMaker,uint256 gasFee);

    event Balance(uint256 takerBaseTokenBalance,uint256 takerTokenBalance,uint256 makerBaseTokenBalance,uint256 makerTokenBalance); 

    event Deposit(address indexed token, address indexed user, uint256 amount, uint256 balance);
    event Withdraw(address indexed token,address indexed from,address indexed to, uint256 amount, uint256 balance); 
    event Transfer(address indexed token,address indexed from,address indexed to, uint256 amount, uint256 fromBalance,uint256 toBalance); 
    event Airdrop(address indexed to, address indexed token,uint256 amount); 

    event WithdrawalApplication(address user,uint timestamp);

    modifier onlyRelayer {
        if (msg.sender != owner && !_relayers[msg.sender]) revert(ONLY_RELAYER);
        _;
    } 

    modifier onlyAirdropContract {
        if (msg.sender != _airdropContract) revert(ONLY_AIRDROP);
        _;
    }   
 
    /** 
    *  @dev approved in 10 days 
    */  
    modifier onlyWithdrawalApplicationApproved  {
        require (
             _withdrawalApplication[msg.sender] != uint(0) &&
             block.timestamp - _withdrawalApplicationPeriod > _withdrawalApplication[msg.sender],
             ONLY_WITHDRAWALAPPROVED);
        _;
    }   

  
    /** 
    *  @param feeAccount  account to receive the fee
    */  
    constructor(address feeAccount) public { 
        _feeAccount = feeAccount;  
    }

    /** 
    *  @dev do no send eth to dex contract directly.
    */
    function() external {
        revert();
    }  
  
    /** 
    *  @dev set a relayer
    */ 
    function setRelayer(address relayer, bool isRelayer) public onlyOwner {
        _relayers[relayer] = isRelayer;
    } 
 
    /** 
    *  @dev check a relayer
    */ 
    function isRelayer(address relayer) public view returns(bool)  {
        return _relayers[relayer];
    } 
 
    /** 
    *  @dev set account that receive the fee
    */ 
    function setFeeAccount(address feeAccount) public onlyOwner {
        _feeAccount = feeAccount;
    }
 
    /** 
    *  @dev set set maker and taker fee rate
    *  @param makerFeeRate maker fee rate can't be more than 0.5%
    *  @param takerFeeRate taker fee rate can't be more than 0.5%
    */ 
    function setFee(uint256 makerFeeRate,uint256 takerFeeRate) public onlyOwner { 

        require(makerFeeRate <=  0.005 ether && takerFeeRate <=  0.005 ether,MAX_VALUE_LIMIT); 

        _makerFeeRate = makerFeeRate;
        _takerFeeRate = takerFeeRate; 
    }   
  
    /** 
    *  @dev set gasStorage contract to save gas
    */ 
    function setGasStorage(address gasStorage) public onlyOwner {
        _gasStorage = gasStorage;
    }
 
    /** 
    *  @dev set airdrop contract to implement airdrop function
    */ 
    function setAirdrop(address airdrop) public onlyOwner{
        _airdropContract = airdrop;
    }
 
    /** 
    *  @dev set withdraw application period
    *  @param period the period can't be more than 10 days
    */ 
    function setWithdrawalApplicationPeriod(uint period) public onlyOwner {

        if(period > 10 days ){
            return;
        }

        _withdrawalApplicationPeriod = period; 
    }
 
    /** 
    *  @dev invalid the orders before nonce
    */ 
    function invalidateOrdersBefore(address user, uint256 nonce) public onlyRelayer {
        if (nonce < _invalidOrderNonce[user]) {
            revert(INVALID_NONCE);   
        }

        _invalidOrderNonce[user] = nonce;
    } 
  
    /** 
    *  @dev deposit token 
    */ 
    function depositToken(address token, uint256 amount)  public {  
        require(ERC20(token).transferFrom(msg.sender, address(this), amount),TRANSFER_FAILED); 
        _deposit(msg.sender,token,amount); 
    }
 
    /** 
    *  @dev deposit token from msg.sender to someone
    */ 
    function depositTokenTo(address to,address token, uint256 amount)  public {  
        require(ERC20(token).transferFrom(msg.sender, address(this), amount),TRANSFER_FAILED); 
        _deposit(to,token,amount); 
    }

    /** 
    *  @dev deposit eth
    */ 
    function deposit() public payable { 
        _deposit(msg.sender,address(0),msg.value); 
    }
 
    /** 
    *  @dev deposit eth from msg.sender to someone
    */ 
    function depositTo(address to) public payable {
        _deposit(to,address(0),msg.value);
    } 
 
    /** 
    *  @dev _deposit
    */ 
    function _deposit(address user,address token,uint256 amount) internal {
    
        _balances[token][user] = _balances[token][user].add(amount);   
        
        emit Deposit(token, user, amount, _balances[token][user]);
    } 
     
    /** 
    *  @dev submit a withdrawal application, user can not place any orders after submit a withdrawal application
    */ 
    function submitWithdrawApplication() public {
        _withdrawalApplication[msg.sender] = block.timestamp;
        emit WithdrawalApplication(msg.sender,block.timestamp);
    }
 
    /** 
    *  @dev cancel withdraw application
    */ 
    function cancelWithdrawApplication() public {
        _withdrawalApplication[msg.sender] = 0; 
        emit WithdrawalApplication(msg.sender,0);
    }
 
    /** 
    *  @dev check user withdraw application status
    */ 
    function isWithdrawApplication(address user) view public returns(bool) {
        if(_withdrawalApplication[user] == uint(0)) {
            return false;
        }
        return true;
    }   

    /** 
    *  @dev withdraw token 
    */ 
    function _withdraw(address from,address payable to,address token,uint256 amount) internal {    

        if ( _balances[token][from] < amount) { 
            revert(INSUFFICIENT_FOUND);
        }  
        
        _balances[token][from] = _balances[token][from].sub(amount);

        if(token == address(0)) {  
            to.transfer(amount);
        }else{    
            require(ERC20(token).transfer(to, amount),TRANSFER_FAILED); 
        }  

        emit Withdraw(token, from, to, amount, _balances[token][from]);
    }  


    /** 
    *  @dev user withdraw token 
    */ 
    function withdraw(address token) public onlyWithdrawalApplicationApproved { 
        uint256 amount = _balances[token][msg.sender];
        if(amount != 0){ 
            _withdraw(msg.sender,msg.sender,token,amount);
        }
    } 
         
    /** 
    *  @dev user withdraw many tokens 
    */ 
    function withdrawAll(address[] memory tokens) public onlyWithdrawalApplicationApproved { 
        
        for(uint256 i = 0; i< tokens.length ;i++){ 

            uint256 amount = _balances[tokens[i]][msg.sender];
            
            if(amount == 0){
                continue;
            }

            _withdraw(msg.sender,msg.sender,tokens[i],amount); 
        }
    }
  
    /** 
    *  @dev user send withdraw request with relayer's authorized signature 
    */ 
    function authorizedWithdraw(address payable to,address token,uint256 amount,
            uint256 nonce,uint expiredTime,address relayer,uint8 v, bytes32 r,bytes32 s) public
    {  
        require(_withdrawalApplication[msg.sender] == uint(0));
        require(expiredTime >= block.timestamp,INVALID_TIME);
        require(_relayers[relayer] == true,ONLY_RELAYER);

        bytes32 hash = keccak256(abi.encodePacked(msg.sender,to, token, amount, nonce, expiredTime));
        
        if (_withdrawn[hash]) {
            revert(WITHDRAW_EXISTS);    
        }   

        _withdrawn[hash] = true;  

        if (ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), v, r, s) != relayer) {
            revert(ECRECOVER_FAILED);
        } 

        _withdraw(msg.sender,to,token,amount);  
    }
 
    /** 
    *  @dev withdraw the token from Dex Wallet to Etheruem Wallet,signType [0 = signTypeDataV3, 1 = eth_sign] 
    */ 
    function adminWithdraw(address from,address payable to,address token,uint256 amount,uint256 nonce,uint8 v,bytes32[2] memory rs, 
            address feeToken,uint256 feeWithdrawal,uint timestamp,uint signType) public onlyRelayer  { 

        bytes32 hash = ecrecoverWithdraw(from,to,token,amount,nonce,v,rs,feeToken,feeWithdrawal,timestamp,signType);     

        if (_withdrawn[hash]) {
            revert(WITHDRAW_EXISTS);    
        }    

        _withdrawn[hash] = true;   

        _transfer(from,to,token,amount,feeToken,feeWithdrawal,false);
    } 
 
    /** 
    *  @dev transfer the token between Dex Wallet,signType [0 = signTypeDataV3, 1 = eth_sign] 
    */ 
    function adminTransfer(address from,address payable to,address token,uint256 amount,uint256 nonce,uint8 v,bytes32[2] memory rs, 
            address feeToken,uint256 feeWithdrawal,uint timestamp,uint signType) public onlyRelayer  { 

        bytes32 hash = ecrecoverWithdraw(from,to,token,amount,nonce,v,rs,feeToken,feeWithdrawal,timestamp,signType);     

        if (_withdrawn[hash]) {
            revert(WITHDRAW_EXISTS);    
        }    
        _withdrawn[hash] = true;  


        _transfer(from,to,token,amount,feeToken,feeWithdrawal,true);
    }  
 
    /** 
    *  @dev   transfer the token 
    *  @param from   token sender
    *  @param to     token receiver  
    *  @param token   The address of token to transfer
    *  @param amount   The amount to transfer 
    *  @param feeToken   The address of token  to pay the fee
    *  @param feeWithdrawal  The amount of feeToken to pay the fee
    *  @param isInternal  True is transfer token from a Dex Wallet to a Dex Wallet, False is transfer a token from Dex wallet to a Etheruem Wallet
    */ 
    function _transfer(address from,address payable to,address token,uint256 amount, address feeToken,uint256 feeWithdrawal, bool isInternal) internal  { 
  
        if (feeWithdrawal > 0)
        { 
            require(_balances[feeToken][from] >= feeWithdrawal,  INSUFFICIENT_FOUND ); 
            _balances[feeToken][from]        = _balances[feeToken][from].sub(feeWithdrawal);
            _balances[feeToken][_feeAccount] = _balances[feeToken][_feeAccount].add(feeWithdrawal); 
        }   

        if ( _balances[token][from] < amount) {  revert(INSUFFICIENT_FOUND); }  
        
        _balances[token][from] = _balances[token][from].sub(amount);  
        
        if(isInternal)
        {
            _balances[token][to] = _balances[token][to].add(amount);

            emit Transfer(token, from, to, amount, _balances[token][from], _balances[token][to]);

        }else{
            if(token == address(0)) {  
                to.transfer(amount);
            }else{    
                require(ERC20(token).transfer(to, amount),TRANSFER_FAILED); 
            }  

            emit Withdraw(token, from, to, amount, _balances[token][from]);
        }  
    }       
 
    /** 
    *  @dev  mirgate function will withdraw all user token balances to wallet
    */ 
    function adminWithdrawAll(address payable user,address[] memory tokens) public onlyOwner { 

        for(uint256 i = 0; i< tokens.length ;i++){

            address token = tokens[i];
            uint256 amount = _balances[token][user];

            if(amount == 0){
                continue;
            }

            _withdraw(user,user,token,amount);
        }
    }
 
    /** 
    *  @dev  get the balance of the account 
    */  
    function balanceOf(address token, address user) public view returns (uint256) {
        return _balances[token][user];
    }   
 
    /** 
    *  @dev  trade order only call by relayer, ti.signType: 0 = signTypeDataV3, 1 = eth_sign 
    */ 
    function tradeOrder(Order memory taker,Order memory maker, TradeInfo memory ti) public onlyRelayer 
    {
        uint256 gasInitial = gasleft();

        bytes32 takerHash = ecrecoverOrder(taker,taker.signType); 
        bytes32 makerHash = ecrecoverOrder(maker,maker.signType);
    
        bytes32 tradeHash = keccak256(abi.encodePacked(takerHash ,makerHash)); 

        require(_traded[tradeHash] == false,TRADE_EXISTS);  

        _traded[tradeHash] = true;     

        _tradeOrder(taker,maker,ti,takerHash,makerHash);     

        uint256 gasUsed = gasInitial - gasleft();
        
        _burnGas(gasUsed);
    }
 
    /** 
    *  @dev  trade order internal
    */ 
    function _tradeOrder(Order memory taker,Order memory maker, TradeInfo memory ti, bytes32 takerHash,bytes32 makerHash) internal
    {   
        require(taker.baseToken == maker.baseToken && taker.token == maker.token);
        require(ti.tradeTokenAmount > 0 , INVALID_AMOUNT );
        require((block.timestamp <= taker.expireTime) && (block.timestamp <= maker.expireTime)  ,  INVALID_TIME ); 
        require( (_invalidOrderNonce[taker.user] < taker.nonce) &&(_invalidOrderNonce[maker.user] < maker.nonce),INVALID_NONCE) ; 

        require( (taker.tokenAmount.sub(_orderFills[takerHash]) >= ti.tradeTokenAmount) &&
                (maker.tokenAmount.sub(_orderFills[makerHash]) >= ti.tradeTokenAmount), AMOUNT_EXCEEDED); 

        require(taker.gasToken == ti.tradeGasToken, INVALID_GASTOKEN);

        uint256 tradeBaseTokenAmount = ti.tradeTokenAmount.mul(maker.baseTokenAmount).div(maker.tokenAmount);     
 
        (uint256 takerFee,uint256 makerFee) = calcMaxFee(ti,tradeBaseTokenAmount,maker.sell);    

        uint  gasFee = ti.tradeGasFee;

        if(gasFee != 0)
        {  
            if( taker.maxGasFee < _orderGasFee[takerHash].add(gasFee))
            {
                gasFee = taker.maxGasFee.sub(_orderGasFee[takerHash]);
            } 

            if(gasFee != 0)
            {
                _orderGasFee[takerHash] = _orderGasFee[takerHash].add(gasFee); 
                _balances[taker.gasToken][taker.user]   = _balances[taker.gasToken][taker.user].sub(gasFee); 
            } 
        } 
         
        if( maker.sell)
        {  
            //maker is seller 
            _updateOrderBalance(taker.user,maker.user,taker.baseToken,taker.token,
                            tradeBaseTokenAmount,ti.tradeTokenAmount,takerFee,makerFee);
        }else
        {
            //maker is buyer
            _updateOrderBalance(maker.user,taker.user,taker.baseToken,taker.token,
                            tradeBaseTokenAmount,ti.tradeTokenAmount,makerFee,takerFee); 
        }

        //fill order
        _orderFills[takerHash] = _orderFills[takerHash].add(ti.tradeTokenAmount);  
        _orderFills[makerHash] = _orderFills[makerHash].add(ti.tradeTokenAmount);     

        emit Trade(takerHash,makerHash,ti.tradeTokenAmount,tradeBaseTokenAmount,ti.tradeNonce,takerFee,makerFee, maker.sell ,gasFee);
 
        emit Balance(_balances[taker.baseToken][taker.user],_balances[taker.token][taker.user],_balances[maker.baseToken][maker.user],_balances[maker.token][maker.user]); 
    }  
   
    /** 
    *  @dev  update the balance after each order traded
    */ 
    function _updateOrderBalance(address buyer,address seller,address base,address token,uint256 baseAmount,uint256 amount,uint256 buyFee,uint256 sellFee) internal
    {
        _balances[base][seller]    = _balances[base][seller].add(baseAmount.sub(sellFee));    
        _balances[base][buyer]     = _balances[base][buyer].sub(baseAmount);

        _balances[token][buyer]    = _balances[token][buyer].add(amount.sub(buyFee));  
        _balances[token][seller]   = _balances[token][seller].sub(amount);    
    
        _balances[base][_feeAccount]    = _balances[base][_feeAccount].add(sellFee);  
        _balances[token][_feeAccount]    = _balances[token][_feeAccount].add(buyFee);   
    }
 
    /** 
    *  @dev  calc max fee for maker and taker
    *  @return return a taker and maker fee limit by _takerFeeRate and _makerFeeRate
    */ 
    function calcMaxFee(TradeInfo memory ti,uint256 tradeBaseTokenAmount,bool sellerIsMaker)  view public returns (uint256 takerFee,uint256 makerFee) { 
   
        uint maxTakerFee;
        uint maxMakerFee;

        takerFee     = ti.tradeTakerFee;
        makerFee      = ti.tradeMakerFee; 
        
        if(sellerIsMaker)
        { 
            // taker is buyer
            maxTakerFee = (ti.tradeTokenAmount * _takerFeeRate) / 1 ether; 
            maxMakerFee = (tradeBaseTokenAmount * _makerFeeRate) / 1 ether; 
        }else{
            // maker is buyer
            maxTakerFee = (tradeBaseTokenAmount * _takerFeeRate) / 1 ether; 
            maxMakerFee = (ti.tradeTokenAmount  * _makerFeeRate) / 1 ether; 
        } 

        if(ti.tradeTakerFee > maxTakerFee)
        {
            takerFee = maxTakerFee;
        }  

        if(ti.tradeMakerFee > maxMakerFee)
        {
            makerFee = maxMakerFee;
        }  
    } 
 
    /** 
    *  @dev  get fee Rate 
    */ 
    function getFeeRate() view public  returns(uint256 makerFeeRate,uint256 takerFeeRate)
    {
        return (_makerFeeRate,_takerFeeRate);
    } 
 
    /** 
    *  @dev get order filled amount
    *  @param orderHash   the order hash  
    *  @return return the filled amount for a order
    */ 
    function getOrderFills(bytes32 orderHash) view public returns(uint256 filledAmount)
    {
        return _orderFills[orderHash];
    }

    ///@dev check orders traded
    function isTraded(bytes32 buyOrderHash,bytes32 sellOrderHash) view public returns(bool traded)
    {
        return _traded[keccak256(abi.encodePacked(buyOrderHash, sellOrderHash))];
    }   
 
    /** 
    *  @dev Airdrop the token directly to Dex user's walle,only airdrop contract can call this function.
    *  @param to   the recipient
    *  @param token  the ERC20 token to send  
    *  @param amount  the token amount to send 
    */ 
    function airdrop(address to,address token,uint256 amount) public onlyAirdropContract  
    {  
        //Not EOA
        require(tx.origin != msg.sender);
        require(_balances[token][msg.sender] >= amount ,INSUFFICIENT_FOUND);

        _balances[token][msg.sender] = _balances[token][msg.sender].sub(amount); 
        _balances[token][to] = _balances[token][to].add(amount);  

        emit Airdrop(to,token,amount);
    }   

    /** 
    *  @dev ecreover the order sign   
    *  @return return a order hash
    */ 
    function ecrecoverOrder(Order memory order,uint signType) public pure returns (bytes32 orderHash) {  
 
        if(signType == 0 )
        {
            orderHash = keccak256(abi.encode(
                ORDER_TYPEHASH,
                order.token,order.baseToken,order.tokenAmount,order.baseTokenAmount,order.nonce,order.sell,order.expireTime,order.maxGasFee,order.gasToken,order.timestamp));
            if (ecrecover(keccak256(abi.encodePacked("\x19\x01",DOMAIN_SEPARATOR,orderHash)),order.V,order.R, order.S) != order.user) {
                    revert(ECRECOVER_FAILED);
            }  
        }else {   

            orderHash = keccak256(abi.encodePacked(order.token,order.baseToken,order.tokenAmount,order.baseTokenAmount,order.nonce,order.sell,order.expireTime,order.maxGasFee,order.gasToken,order.timestamp)); 
            if(ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",orderHash)),order.V,order.R, order.S) != order.user) {
                revert(ECRECOVER_FAILED);
            }  
        } 
    }   

    /** 
    *  @dev ecrecover the withdraw sign
    *  @return return a withdraw hash
    */
    function ecrecoverWithdraw(address from,address payable to,address token,uint256 amount,uint256 nonce,uint8 v,bytes32[2] memory rs, 
            address feeToken,uint256 feeWithdrawal,uint timestamp,uint signType) public pure returns (bytes32 orderHash) {  
  
        if(signType == 1 ) {

            orderHash = keccak256(abi.encodePacked(token, amount, to, nonce,feeToken,feeWithdrawal,timestamp));

            if (ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", orderHash)), v, rs[0], rs[1]) != from) {
                revert(ECRECOVER_FAILED);
            }
 
        } else {
            orderHash = keccak256(abi.encode(WITHDRAW_TYPEHASH,token, amount, to, nonce,feeToken,feeWithdrawal,timestamp));

            if (ecrecover(keccak256(abi.encodePacked("\x19\x01",DOMAIN_SEPARATOR,orderHash)), v, rs[0], rs[1]) != from) {
                revert(ECRECOVER_FAILED);
            }  
        } 
    }  
  
    /**
   * @dev burn the stored gastoken
   * @param gasUsed The gas uesed to calc the gastoken to burn
   */
    function _burnGas(uint gasUsed) internal {

        if(_gasStorage == address(0x0)){
            return;
        } 

        IGasStorage(_gasStorage).burn(gasUsed); 
    }

}