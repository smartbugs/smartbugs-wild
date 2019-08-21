pragma solidity ^0.4.24;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract Z_ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract Z_ERC20 is Z_ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

/**
 * @title Basic token implementation
 * @dev Basic version of StandardToken, with no allowances.
 */
contract Z_BasicToken is Z_ERC20Basic {
   
  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] -= _value;
    balances[_to] += _value;
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token, implementing  transfer by agents 
 *
 * @dev Implementation of the basic standard token with allowances.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract Z_StandardToken is Z_ERC20, Z_BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;
 
  /**
   * @dev Transfer tokens from one address to another by agents within allowance limit 
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   * @return true
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] -= _value;
    balances[_to] += _value;
    allowed[_from][msg.sender] -= _value;
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to  by admin , without any allowance limit
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   * @return true
   */
  function transferFromByAdmin(address _from, address _to, uint256 _value) internal returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    //require(_value <= 100000);

    balances[_from] -= _value;
    balances[_to] += _value;

    emit Transfer(_from, _to, _value);
    return true;
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
   * @return true
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Approve the passed address to spend the specified *additional* amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _addedValue The additional amount of tokens to be spent.
   * @return true
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender] + (_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the allownance quota by the specified amount of tokens
   *
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to be decreased
   * @return true
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue - (_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and multiple admin addresses, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Z_Ownable {
  address public owner;
  mapping (address => bool) internal admin_accounts;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    // set msg.sender as owner
    owner = msg.sender;
    // set msg.sender as first administrator
    admin_accounts[msg.sender]= true;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner );
    _;
  }

  /**
   * @dev check if msg.sender is owner
   * @return true  if msg.sender is owner
   */
  function  isOwner() internal view returns (bool) {
    return (msg.sender == owner );
    
  }
  
  /**
   * @dev Throws if called by any account other than admins.
   */
  modifier onlyAdmin() {
    require (admin_accounts[msg.sender]==true);
    _;
  }

  /**
   * @dev check if msg.sender is admin
   * @return true  if msg.sender is admin
   */
  function  isAdmin() internal view returns (bool) {
    return  (admin_accounts[msg.sender]==true);
    
  }
 
}


/** @title main contract for NOW token. we should deploy this contract. needs about 5,500,000 gas */

contract NOWToken is Z_StandardToken, Z_Ownable {
    string  public  constant name = "NOW Token";
    string  public  constant symbol = "NOW";
    uint8   public  constant decimals = 18; // token traded in integer amounts, no period

    // total token supply: 3 billion NOW
    uint256 internal constant _totalTokenAmount = 3 * (10 ** 9) * (10 ** 18);

    uint256 internal constant WEI_PER_ETHER= 1000000000000000000; // 10^18 wei = 1 ether
    uint256 internal constant NUM_OF_SALE_STAGES= 5; // support upto five sale stages

    // enum type definition for sale status (0 ~ 13)
    enum Sale_Status {
      Initialized_STATUS, // 0
      Stage0_Sale_Started_STATUS, // 1, stage0
      Stage0_Sale_Stopped_STATUS, // 2, stage0
      Stage1_Sale_Started_STATUS, // 3, stage1
      Stage1_Sale_Stopped_STATUS, // 4, stage1
      Stage2_Sale_Started_STATUS, // 5, stage2
      Stage2_Sale_Stopped_STATUS, // 6, stage2
      Stage3_Sale_Started_STATUS, // 7, stage3
      Stage3_Sale_Stopped_STATUS, // 8, stage3
      Stage4_Sale_Started_STATUS, // 9,  stage4
      Stage4_Sale_Stopped_STATUS, // 10, stage4
      Public_Allowed_To_Trade_STATUS, // 11
      Stage0_Allowed_To_Trade_STATUS, // 12
      Closed_STATUS  // 13
    }

    // sale status variable: 0 ~ 13 (enum Sale_Status )
    Sale_Status  public  sale_status= Sale_Status.Initialized_STATUS;

    // sale stage index : 0 ~ 4 ( 0:1~2,  1:3~4, 2:5~6, 3:7~8, 4:9~10) 
    uint256   public  sale_stage_index= 0; // 0 ~ 4 for stage0 ~ 4

    // initiazlied time
    uint256  public  when_initialized= 0;

    // timestamp when public trade begins except stage0
    uint256  public  when_public_allowed_to_trade_started= 0;

    // timestamp when *all* tokens trade begins including stage0
    uint256  public  when_stage0_allowed_to_trade_started= 0;

    // array of sale starting time's timestamp
    uint256 [NUM_OF_SALE_STAGES] public  when_stageN_sale_started;

    // array of sale stopping time's timestamp
    uint256 [NUM_OF_SALE_STAGES] public  when_stageN_sale_stopped;

    // sum of all sold tokens
    uint256 public sold_tokens_total= 0;

    // sum of ethers received during all token sale stages
    uint256 public raised_ethers_total= 0;

    // array of sold tokens per sale stage
    uint256[NUM_OF_SALE_STAGES] public sold_tokens_per_stage;

    // array of received ethers per sale stage
    uint256[NUM_OF_SALE_STAGES] public raised_ethers_per_stage;

    // target ether amount to gather in each sale stage, when fullfilled, the sale stage automatically forced to stop
    uint256[NUM_OF_SALE_STAGES] public target_ethers_per_stage= [
       1000 * WEI_PER_ETHER, // stage0 for staff
       9882 * WEI_PER_ETHER, // stage1 for black sale
      11454 * WEI_PER_ETHER, // stage2 for private sale
      11200 * WEI_PER_ETHER, // stage3 for public sale
      11667 * WEI_PER_ETHER  // stage4 for crowd sale
    ];

    // array of token sale price for each stage (wei per now)
    uint256[NUM_OF_SALE_STAGES] internal  sale_price_per_stage_wei_per_now = [
      uint256(1000000000000000000/ uint256(100000)),// stage0 for staff
      uint256(1000000000000000000/ uint256(38000)), // stage1 for black sale
      uint256(1000000000000000000/ uint256(23000)), // stage2 for private sale
      uint256(1000000000000000000/ uint256(17000)), // stage3 for public sale
      uint256(1000000000000000000/ uint256(10000))  // stage4 for crowd sale
    ];

    // struct definition for token sale history
    struct history_token_sale_obj {
      address _buyer;
      uint256 _ether_value; // in wei
      uint256 _token_value; // in now token
      uint256 _when; 
    }

    // struct definition for token transfer history
    struct history_token_transfer_obj {
      address _from;
      address _to;
      uint256 _token_value; // in now token
      uint256 _when; 
    }

    // struct definition for token burning history
    struct history_token_burning_obj {
      address _from;
      uint256 _token_value_burned; // in now token
      uint256 _when; 
    }

    // token sale history for stage 0 ~ 4
    history_token_sale_obj[]  internal history_token_sale_stage0;
    history_token_sale_obj[]  internal history_token_sale_stage1;
    history_token_sale_obj[]  internal history_token_sale_stage2;
    history_token_sale_obj[]  internal history_token_sale_stage3;
    history_token_sale_obj[]  internal history_token_sale_stage4;

    // token transfer history
    history_token_transfer_obj[] internal history_token_transfer;

    // token burning history
    history_token_burning_obj[]  internal history_token_burning;

    // token sale amount for each account per stage 0 ~ 4
    mapping (address => uint256) internal sale_amount_stage0_account;
    mapping (address => uint256) internal sale_amount_stage1_account;
    mapping (address => uint256) internal sale_amount_stage2_account;
    mapping (address => uint256) internal sale_amount_stage3_account;
    mapping (address => uint256) internal sale_amount_stage4_account;

    
    // array for list of  holders and their receiving amounts
    mapping (address => uint256) internal holders_received_accumul;

    // array for list of holders accounts (including even inactive holders) 
    address[] public holders;

    // array for list of sale holders accounts for each sale stage
    address[] public holders_stage0_sale;
    address[] public holders_stage1_sale;
    address[] public holders_stage2_sale;
    address[] public holders_stage3_sale;
    address[] public holders_stage4_sale;
    
    // array for list of trading holders which are not sale holders
    address[] public holders_trading;

    // array for list of burning holders accounts
    address[] public holders_burned;

    // array for list of frozen holders accounts
    address[] public holders_frozen;

    // burned tokens for each holders account
    mapping (address => uint256) public burned_amount;

    // sum of all burned tokens
    uint256 public totalBurned= 0;

    // total ether value withdrawed from this contract by contract owner
    uint256 public totalEtherWithdrawed= 0;

    // addess to timestamp mapping  to  mark the account freezing time ( 0 means later unfreezed )
    mapping (address => uint256) internal account_frozen_time;

    // unused
    mapping (address => mapping (string => uint256)) internal traded_monthly;

    // cryptocurrency exchange office  ether address, for monitorig purpose
    address[] public cryptocurrency_exchange_company_accounts;

    
    /////////////////////////////////////////////////////////////////////////
 
    event AddNewAdministrator(address indexed _admin, uint256 indexed _when);
    event RemoveAdministrator(address indexed _admin, uint256 indexed _when);
  
    /**
     *  @dev   add new admin accounts 
     *        (run by admin, public function) 
     *  @param _newAdmin   new admin address
     */
    function z_admin_add_admin(address _newAdmin) public onlyOwner {
      require(_newAdmin != address(0));
      admin_accounts[_newAdmin]=true;
    
      emit AddNewAdministrator(_newAdmin, block.timestamp);
    }
  
    /**
     *  @dev   remove old admin accounts
     *        (run by admin, public function) 
     *  @param _oldAdmin   old admin address
     */
    function z_admin_remove_admin(address _oldAdmin) public onlyOwner {
      require(_oldAdmin != address(0));
      require(admin_accounts[_oldAdmin]==true);
      admin_accounts[_oldAdmin]=false;
    
      emit RemoveAdministrator(_oldAdmin, block.timestamp);
    }


  
    event AddNewExchangeAccount(address indexed _exchange_account, uint256 indexed _when);

    /**
     *  @dev   add new exchange office accounts
     *        (run by admin, public function) 
     *  @param _exchange_account   new exchange address
     */
    function z_admin_add_exchange(address _exchange_account) public onlyAdmin {
      require(_exchange_account != address(0));
      cryptocurrency_exchange_company_accounts.push(_exchange_account);
    
      emit AddNewExchangeAccount(_exchange_account, block.timestamp);
    }
 

 
    event SaleTokenPriceSet(uint256 _stage_index, uint256 _wei_per_now_value, uint256 indexed _when);

    /**
     * @dev  set new token sale price for current sale stage
     *       (run buy admin, public function)
     * return  _how_many_wei_per_now   new token sale price (wei per now)
     */
    function z_admin_set_sale_price(uint256 _how_many_wei_per_now) public
        onlyAdmin 
    {
        if(_how_many_wei_per_now == 0) revert();
        if(sale_stage_index >= 5) revert();
        sale_price_per_stage_wei_per_now[sale_stage_index] = _how_many_wei_per_now;
        emit SaleTokenPriceSet(sale_stage_index, _how_many_wei_per_now, block.timestamp);
    }

    /**
     * @dev  return current or last token sale price
     *       (public view function)
     * return  _sale_price   get current token sale price (wei per now)
     * return  _current_sale_stage_index   get current sale stage index ( 0 ~ 4)
     */
    function CurrentSalePrice() public view returns (uint256 _sale_price, uint256 _current_sale_stage_index)  {
        if(sale_stage_index >= 5) revert();
        _current_sale_stage_index= sale_stage_index;
        _sale_price= sale_price_per_stage_wei_per_now[sale_stage_index];
    }




    event InitializedStage(uint256 indexed _when);
    event StartStage0TokenSale(uint256 indexed _when);
    event StartStage1TokenSale(uint256 indexed _when);
    event StartStage2TokenSale(uint256 indexed _when);
    event StartStage3TokenSale(uint256 indexed _when);
    event StartStage4TokenSale(uint256 indexed _when);

    /**
     * @dev  start _new_sale_stage_index sale stage
     *    (run by admin )
     */
    function start_StageN_Sale(uint256 _new_sale_stage_index) internal
    {
        if(sale_status==Sale_Status.Initialized_STATUS || sale_stage_index+1<= _new_sale_stage_index)
           sale_stage_index= _new_sale_stage_index;
        else
           revert();
        sale_status= Sale_Status(1 + sale_stage_index * 2); // 0=>1, 1=>3, 2=>5, 3=>7, 4=>9
        when_stageN_sale_started[sale_stage_index]= block.timestamp;
        if(sale_stage_index==0) emit StartStage0TokenSale(block.timestamp); 
        if(sale_stage_index==1) emit StartStage1TokenSale(block.timestamp); 
        if(sale_stage_index==2) emit StartStage2TokenSale(block.timestamp); 
        if(sale_stage_index==3) emit StartStage3TokenSale(block.timestamp); 
        if(sale_stage_index==4) emit StartStage4TokenSale(block.timestamp); 
    }



    event StopStage0TokenSale(uint256 indexed _when);
    event StopStage1TokenSale(uint256 indexed _when);
    event StopStage2TokenSale(uint256 indexed _when);
    event StopStage3TokenSale(uint256 indexed _when);
    event StopStage4TokenSale(uint256 indexed _when);

    /**
     * @dev  stop this [_old_sale_stage_index] sale stage
     *     (run by admin )
     */
    function stop_StageN_Sale(uint256 _old_sale_stage_index) internal 
    {
        if(sale_stage_index != _old_sale_stage_index)
           revert();
        sale_status= Sale_Status(2 + sale_stage_index * 2); // 0=>2, 1=>4, 2=>6, 3=>8, 4=>10
        when_stageN_sale_stopped[sale_stage_index]= block.timestamp;
        if(sale_stage_index==0) emit StopStage0TokenSale(block.timestamp); 
        if(sale_stage_index==1) emit StopStage1TokenSale(block.timestamp); 
        if(sale_stage_index==2) emit StopStage2TokenSale(block.timestamp); 
        if(sale_stage_index==3) emit StopStage3TokenSale(block.timestamp); 
        if(sale_stage_index==4) emit StopStage4TokenSale(block.timestamp); 
    }



    event StartTradePublicSaleTokens(uint256 indexed _when);

    /**
     *  @dev  allow stage1~4 token trading 
     *      (run by admin )
     */
    function start_Public_Trade() internal
        onlyAdmin
    {
        // if current sale stage had not been stopped, first stop current active sale stage 
        Sale_Status new_sale_status= Sale_Status(2 + sale_stage_index * 2);
        if(new_sale_status > sale_status)
          stop_StageN_Sale(sale_stage_index);

        sale_status= Sale_Status.Public_Allowed_To_Trade_STATUS;
        when_public_allowed_to_trade_started= block.timestamp;
        emit StartTradePublicSaleTokens(block.timestamp); 
    }

    event StartTradeStage0SaleTokens(uint256 indexed _when);

    /**
     *  @dev  allow stage0 token trading
     *        (run by admin )
     */
    function start_Stage0_Trade() internal
        onlyAdmin
    {
        if(sale_status!= Sale_Status.Public_Allowed_To_Trade_STATUS) revert();
        
        // allowed 1 year later after stage1 tokens trading is enabled

        uint32 stage0_locked_year= 1;
 
        bool is_debug= false; // change to false if this contract source  is release version 
        if(is_debug==false && block.timestamp <  stage0_locked_year*365*24*60*60
            + when_public_allowed_to_trade_started  )  
	      revert();
        if(is_debug==true  && block.timestamp <  stage0_locked_year*10*60
            + when_public_allowed_to_trade_started  )  
	      revert();
	      
        sale_status= Sale_Status.Stage0_Allowed_To_Trade_STATUS;
        when_stage0_allowed_to_trade_started= block.timestamp;
        emit StartTradeStage0SaleTokens(block.timestamp); 
    }




    event CreateTokenContract(uint256 indexed _when);

    /**
     *  @dev  token contract constructor(), initialized tokens supply and sale status variables
     *         (run by owner when contract deploy)
     */
    constructor() public
    {
        totalSupply = _totalTokenAmount;
        balances[msg.sender] = _totalTokenAmount;

        sale_status= Sale_Status.Initialized_STATUS;
        sale_stage_index= 0;

        when_initialized= block.timestamp;

        holders.push(msg.sender); 
        holders_received_accumul[msg.sender] += _totalTokenAmount;

        emit Transfer(address(0x0), msg.sender, _totalTokenAmount);
        emit InitializedStage(block.timestamp);
        emit CreateTokenContract(block.timestamp); 
    }




    /**
     * @dev check if specified token transfer request is valid 
     *           ( internal modifier function).
     *           revert  if transfer should be NOT allowed, otherwise do nothing
     * @param _from   source account from whom tokens should be transferred
     * @param _to   destination account to whom tokens should be transferred
     * @param _value   number of tokens to be transferred
     */
    modifier validTransaction( address _from, address _to, uint256 _value)
    {
        require(_to != address(0x0));
        require(_to != _from);
        require(_value > 0);
        if(isAdmin()==false)  {
	    // if _from is frozen account, disallow this request
	    if(account_frozen_time[_from] > 0) revert();
	    if(_value == 0 ) revert();

            // if token trading is not enabled yet, disallow this request
            if(sale_status < Sale_Status.Public_Allowed_To_Trade_STATUS) revert();

            // if stage0 token trading is not enabled yet, disallow this request
            if( sale_amount_stage0_account[_from] > 0 ) {
                if(sale_status < Sale_Status.Stage0_Allowed_To_Trade_STATUS)  
                    revert();
            }  else {
            }
  	 }
        _;
    }


    event TransferToken(address indexed _from_whom,address indexed _to_whom,
         uint _token_value, uint256 indexed _when);
    event TransferTokenFrom(address indexed _from_whom,address indexed _to_whom, address _agent,
	 uint _token_value, uint256 indexed _when);
    event TransferTokenFromByAdmin(address indexed _from_whom,address indexed _to_whom, address _admin, 
 	 uint _token_value, uint256 indexed _when);

    /**
     * @dev transfer specified amount of tokens from my account to _to account 
     *     (run by self, public function)
     * @param _to   destination account to whom tokens should be transferred
     * @param _value   number of tokens to be transferred
     * @return _success   report if transfer was successful, on failure revert()
     */
    function transfer(address _to, uint _value) public 
        validTransaction(msg.sender, _to,  _value)
    returns (bool _success) 
    {
        _success= super.transfer(_to, _value);
        if(_success==false) revert();

  	emit TransferToken(msg.sender,_to,_value,block.timestamp);

	// check if new trading holder
        if(holders_received_accumul[_to]==0x0) {
	   // new holder comes
           holders.push(_to); 
           holders_trading.push(_to);
	   emit NewHolderTrading(_to, block.timestamp);
        }
        holders_received_accumul[_to] += _value;

	// leave a transfer history entry
        history_token_transfer.push( history_token_transfer_obj( {
	       _from: msg.sender,
	       _to: _to,
	       _token_value: _value,
	       _when: block.timestamp
        } ) );
    }

    /**
     * @dev transfer specified amount of tokens from _from account to _to account
     *     (run by agent, public function)
     * @param _from   client account who approved transaction performed by this sender as agent
     * @param _to   destination account to whom tokens should be transferred
     * @param _value   number of tokens to be transferred
     * @return _success   report if transfer was successful, on failure revert()
     */
    function transferFrom(address _from, address _to, uint _value) public 
        validTransaction(_from, _to, _value)
    returns (bool _success) 
    {
        if(isAdmin()==true) {
            // admins can transfer tokens of **ANY** accounts
            emit TransferTokenFromByAdmin(_from,_to,msg.sender,_value,block.timestamp);
            _success= super.transferFromByAdmin(_from,_to, _value);
        }
        else {
            // approved agents can transfer tokens of their clients (clients shoukd 'approve()' agents first)
            emit TransferTokenFrom(_from,_to,msg.sender,_value,block.timestamp);
            _success= super.transferFrom(_from, _to, _value);
        }

        if(_success==false) revert();
        
	// check if new trading holder
        if(holders_received_accumul[_to]==0x0) {
	   // new holder comes
           holders.push(_to); 
           holders_trading.push(_to); 
	   emit NewHolderTrading(_to, block.timestamp);
        }
        holders_received_accumul[_to] += _value;

	// leave a transfer history entry
        history_token_transfer.push( history_token_transfer_obj( {
	       _from: _from,
	       _to: _to,
	       _token_value: _value,
	       _when: block.timestamp
        } ) );

    }




    
    event IssueTokenSale(address indexed _buyer, uint _ether_value, uint _token_value,
           uint _exchange_rate_now_per_wei, uint256 indexed _when);

    /**
     * @dev  fallback function for incoming ether, receive ethers and give tokens back
     */
    function () public payable {
        buy();
    }

    event NewHolderTrading(address indexed _new_comer, uint256 indexed _when);
    event NewHolderSale(address indexed _new_comer, uint256 indexed _when);
    
    /**
     *  @dev   buy now tokens by sending some ethers  to this contract address
     *       (payable public function )
     */
    function buy() public payable {
        if(sale_status < Sale_Status.Stage0_Sale_Started_STATUS) 
           revert();
        
        if(sale_status > Sale_Status.Stage4_Sale_Stopped_STATUS) 
           revert();
        
        if((uint256(sale_status)%2)!=1)  revert(); // not in started sale status
        if(isAdmin()==true)  revert(); // admins are not allowed to buy tokens
	  
        uint256 tokens;
        
        uint256 wei_per_now= sale_price_per_stage_wei_per_now[sale_stage_index];

        // if sent ether value is less than exch_rate, revert
        if (msg.value <  wei_per_now) revert();

        // calculate num of bought tokens based on sent ether value (in wei)
	tokens = uint256( msg.value /  wei_per_now );
      
        if (tokens + sold_tokens_total > totalSupply) revert();

        // update token sale statistics  per stage
	if(sale_stage_index==0) sale_amount_stage0_account[msg.sender] += tokens; else	
	if(sale_stage_index==1) sale_amount_stage1_account[msg.sender] += tokens; else	
	if(sale_stage_index==2) sale_amount_stage2_account[msg.sender] += tokens; else	
	if(sale_stage_index==3) sale_amount_stage3_account[msg.sender] += tokens; else	
	if(sale_stage_index==4) sale_amount_stage4_account[msg.sender] += tokens;	
	sold_tokens_per_stage[sale_stage_index] += tokens;
        sold_tokens_total += tokens;

        // update ether statistics
	raised_ethers_per_stage[sale_stage_index] +=  msg.value;
        raised_ethers_total +=  msg.value;

        super.transferFromByAdmin(owner, msg.sender, tokens);

	// check if this holder is new
        if(holders_received_accumul[msg.sender]==0x0) {
	   // new holder comes
           holders.push(msg.sender); 
	   if(sale_stage_index==0) holders_stage0_sale.push(msg.sender); else 
	   if(sale_stage_index==1) holders_stage1_sale.push(msg.sender); else 
	   if(sale_stage_index==2) holders_stage2_sale.push(msg.sender); else 
	   if(sale_stage_index==3) holders_stage3_sale.push(msg.sender); else 
	   if(sale_stage_index==4) holders_stage4_sale.push(msg.sender); 
	   emit NewHolderSale(msg.sender, block.timestamp);
        }
        holders_received_accumul[msg.sender] += tokens;
    
        // leave a token sale history entry
        history_token_sale_obj memory history = history_token_sale_obj( {
	       _buyer: msg.sender,
	       _ether_value: msg.value,
	       _token_value: tokens,
	       _when: block.timestamp
        } );
        if(sale_stage_index==0) history_token_sale_stage0.push( history ); else
        if(sale_stage_index==1) history_token_sale_stage1.push( history ); else
        if(sale_stage_index==2) history_token_sale_stage2.push( history ); else
        if(sale_stage_index==3) history_token_sale_stage3.push( history ); else
        if(sale_stage_index==4) history_token_sale_stage4.push( history );

        emit IssueTokenSale(msg.sender, msg.value, tokens, wei_per_now, block.timestamp);
        
        // if target ether is reached, stop this sale stage 
	if( target_ethers_per_stage[sale_stage_index] <= raised_ethers_per_stage[sale_stage_index])
    	    stop_StageN_Sale(sale_stage_index);
    }


    event FreezeAccount(address indexed _account_to_freeze, uint256 indexed _when);
    event UnfreezeAccount(address indexed _account_to_unfreeze, uint256 indexed _when);
    
    /**
     * @dev freeze a holder account, prohibit further token transfer 
     *     (run by ADMIN, public function)
     * @param _account_to_freeze   account to freeze
     */
    function z_admin_freeze(address _account_to_freeze) public onlyAdmin   {
        account_frozen_time[_account_to_freeze]= block.timestamp;
        holders_frozen.push(_account_to_freeze);
        emit FreezeAccount(_account_to_freeze,block.timestamp); 
    }

    /**
     * @dev unfreeze a holder account 
     *     (run by ADMIN, public function)
     * @param _account_to_unfreeze   account to unfreeze (previously frozen)
     */
    function z_admin_unfreeze(address _account_to_unfreeze) public onlyAdmin   {
        account_frozen_time[_account_to_unfreeze]= 0; // reset time to zero
        emit UnfreezeAccount(_account_to_unfreeze,block.timestamp); 
    }




    event CloseTokenContract(uint256 indexed _when);

    /**
     * @dev close this contract after burning all tokens 
     *     (run by ADMIN, public function )
     */
    function closeContract() onlyAdmin internal {
	if(sale_status < Sale_Status.Stage0_Allowed_To_Trade_STATUS)  revert();
	if(totalSupply > 0)  revert();
    	address ScAddress = this;
        emit CloseTokenContract(block.timestamp); 
        emit WithdrawEther(owner,ScAddress.balance,block.timestamp); 
	selfdestruct(owner);
    } 



    /**
     * @dev retrieve contract's ether balance info 
     *     (public view function)
     * @return _current_ether_balane   current contract ethereum balance ( in wei unit)
     * @return _ethers_withdrawn   withdrawen ethers in wei
     * @return _ethers_raised_total   total ethers gathered from token sale
     */
    function ContractEtherBalance() public view
    returns (
      uint256 _current_ether_balance,
      uint256 _ethers_withdrawn,
      uint256 _ethers_raised_total 
     ) {
	_current_ether_balance= address(this).balance;
	_ethers_withdrawn= totalEtherWithdrawed;
	_ethers_raised_total= raised_ethers_total;
    } 

    event WithdrawEther(address indexed _addr, uint256 _value, uint256 indexed _when);

    /**
     * @dev transfer this contract ether balance to owner's account 
     *    ( public function )
     * @param _withdraw_wei_value   amount to widthdraw ( in wei unit)
     */
    function z_admin_withdraw_ether(uint256 _withdraw_wei_value) onlyAdmin public {
    	address ScAddress = this;
    	if(_withdraw_wei_value > ScAddress.balance) revert();
    	//if(owner.call.value(_withdraw_wei_value).gas(5000)()==false) revert();
    	if(owner.send(_withdraw_wei_value)==false) revert();
        totalEtherWithdrawed += _withdraw_wei_value;
        emit WithdrawEther(owner,_withdraw_wei_value,block.timestamp); 
    } 




    /**
     * @dev return  list of active holders accounts and their balances 
     *     ( public view function )
     * @param _max_num_of_items_to_display   Max Number of latest accounts items to display ( 0 means 1 )
     * @return  _num_of_active_holders   number of latest holders accounts
     * @return  _active_holders   array of active( balance > 0) holders
     * @return  _token_balances   array of token balances 
     */
    function list_active_holders_and_balances(uint _max_num_of_items_to_display) public view 
      returns (uint _num_of_active_holders,address[] _active_holders,uint[] _token_balances){
      uint len = holders.length;
      _num_of_active_holders = 0;
      if(_max_num_of_items_to_display==0) _max_num_of_items_to_display=1;
      for (uint i = len-1 ; i >= 0 ; i--) {
         if( balances[ holders[i] ] != 0x0) _num_of_active_holders++;
         if(_max_num_of_items_to_display == _num_of_active_holders) break;
      }
      _active_holders = new address[](_num_of_active_holders);
      _token_balances = new uint[](_num_of_active_holders);
      uint num=0;
      for (uint j = len-1 ; j >= 0 && _num_of_active_holders > num ; j--) {
         address addr = holders[j];
         if( balances[ addr ] == 0x0) continue; // assure balance > 0
         _active_holders[num] = addr;
         _token_balances[num] = balances[addr];
         num++;
      }
    }

    /**
     * @dev return  list of recent stage0 token sale history
     *      ( public view function )
     * @param _max_num_of_items_to_display   Max Number of latest history items to display ( 0 means 1 )
     * @return  _num   number of latest token sale history items
     * @return  _sale_holders   array of holders
     * @return  _ethers   array of ethers paid
     * @return  _tokens   array of tokens bought
     * @return  _whens   array of sale times
     */
    function list_history_of_stage0_sale(uint _max_num_of_items_to_display) public view 
      returns (uint _num,address[] _sale_holders,uint[] _ethers,uint[] _tokens,uint[] _whens){
      uint len = history_token_sale_stage0.length;
      uint n= len; 
      if(_max_num_of_items_to_display == 0) _max_num_of_items_to_display= 1;
      if(_max_num_of_items_to_display <  n) n= _max_num_of_items_to_display;
      _sale_holders = new address[](n);
      _ethers = new uint[](n);
      _tokens = new uint[](n);
      _whens = new uint[](n);
      _num=0;
      for (uint j = len-1 ; j >= 0 && n > _num ; j--) {
         history_token_sale_obj storage obj= history_token_sale_stage0[j];
         _sale_holders[_num]= obj._buyer;
         _ethers[_num]=  obj._ether_value;
         _tokens[_num]=  obj._token_value;
         _whens[_num]=   obj._when;
         _num++;
      }
    }


    /**
     * @dev return  list of recent stage1 token sale history 
     *     ( public view function )
     * @param _max_num_of_items_to_display   Max Number of latest history items to display ( 0 means 1 )
     * @return  _num   number of latest token sale history items
     * @return  _sale_holders   array of holders
     * @return  _ethers   array of ethers paid
     * @return  _tokens   array of tokens bought
     * @return  _whens   array of sale times
     */
    function list_history_of_stage1_sale(uint _max_num_of_items_to_display) public view 
      returns (uint _num,address[] _sale_holders,uint[] _ethers,uint[] _tokens,uint[] _whens){
      uint len = history_token_sale_stage1.length;
      uint n= len; 
      if(_max_num_of_items_to_display == 0) _max_num_of_items_to_display= 1;
      if(_max_num_of_items_to_display <  n) n= _max_num_of_items_to_display;
      _sale_holders = new address[](n);
      _ethers = new uint[](n);
      _tokens = new uint[](n);
      _whens = new uint[](n);
      _num=0;
      for (uint j = len-1 ; j >= 0 && n > _num ; j--) {
         history_token_sale_obj storage obj= history_token_sale_stage1[j];
         _sale_holders[_num]= obj._buyer;
         _ethers[_num]=  obj._ether_value;
         _tokens[_num]=  obj._token_value;
         _whens[_num]=   obj._when;
         _num++;
      }
    }


    /**
     * @dev return  list of recent stage2 token sale history 
     *     ( public view function )
     * @param _max_num_of_items_to_display   Max Number of latest history items to display ( 0 means 1 )
     * @return  _num   number of latest token sale history items
     * @return  _sale_holders   array of holders
     * @return  _ethers   array of ethers paid
     * @return  _tokens   array of tokens bought
     * @return  _whens   array of sale times
     */
    function list_history_of_stage2_sale(uint _max_num_of_items_to_display) public view 
      returns (uint _num,address[] _sale_holders,uint[] _ethers,uint[] _tokens,uint[] _whens){
      uint len = history_token_sale_stage2.length;
      uint n= len; 
      if(_max_num_of_items_to_display == 0) _max_num_of_items_to_display= 1;
      if(_max_num_of_items_to_display <  n) n= _max_num_of_items_to_display;
      _sale_holders = new address[](n);
      _ethers = new uint[](n);
      _tokens = new uint[](n);
      _whens = new uint[](n);
      _num=0;
      for (uint j = len-1 ; j >= 0 && n > _num ; j--) {
         history_token_sale_obj storage obj= history_token_sale_stage2[j];
         _sale_holders[_num]= obj._buyer;
         _ethers[_num]=  obj._ether_value;
         _tokens[_num]=  obj._token_value;
         _whens[_num]=   obj._when;
         _num++;
      }
    }


    /**
     * @dev return  list of recent stage3 token sale history 
     *     ( public view function )
     * @param _max_num_of_items_to_display   Max Number of latest history items to display ( 0 means 1 )
     * @return  _num   number of latest token sale history items
     * @return  _sale_holders   array of holders
     * @return  _ethers   array of ethers paid
     * @return  _tokens   array of tokens bought
     * @return  _whens   array of sale times
     */
    function list_history_of_stage3_sale(uint _max_num_of_items_to_display) public view 
      returns (uint _num,address[] _sale_holders,uint[] _ethers,uint[] _tokens,uint[] _whens){
      uint len = history_token_sale_stage3.length;
      uint n= len; 
      if(_max_num_of_items_to_display == 0) _max_num_of_items_to_display= 1;
      if(_max_num_of_items_to_display <  n) n= _max_num_of_items_to_display;
      _sale_holders = new address[](n);
      _ethers = new uint[](n);
      _tokens = new uint[](n);
      _whens = new uint[](n);
      _num=0;
      for (uint j = len-1 ; j >= 0 && n > _num ; j--) {
         history_token_sale_obj storage obj= history_token_sale_stage3[j];
         _sale_holders[_num]= obj._buyer;
         _ethers[_num]=  obj._ether_value;
         _tokens[_num]=  obj._token_value;
         _whens[_num]=   obj._when;
         _num++;
      }
    }


    /**
     * @dev return  list of recent stage4 token sale history
     *      ( public view function )
     * @param _max_num_of_items_to_display   Max Number of latest history items to display ( 0 means 1 )
     * @return  _num   number of latest token sale history items
     * @return  _sale_holders   array of holders
     * @return  _ethers   array of ethers paid
     * @return  _tokens   array of tokens bought
     * @return  _whens   array of sale times
     */
    function list_history_of_stage4_sale(uint _max_num_of_items_to_display) public view 
      returns (uint _num,address[] _sale_holders,uint[] _ethers,uint[] _tokens,uint[] _whens){
      uint len = history_token_sale_stage4.length;
      uint n= len; 
      if(_max_num_of_items_to_display == 0) _max_num_of_items_to_display= 1;
      if(_max_num_of_items_to_display <  n) n= _max_num_of_items_to_display;
      _sale_holders = new address[](n);
      _ethers = new uint[](n);
      _tokens = new uint[](n);
      _whens = new uint[](n);
      _num=0;
      for (uint j = len-1 ; j >= 0 && n > _num ; j--) {
         history_token_sale_obj storage obj= history_token_sale_stage4[j];
         _sale_holders[_num]= obj._buyer;
         _ethers[_num]=  obj._ether_value;
         _tokens[_num]=  obj._token_value;
         _whens[_num]=   obj._when;
         _num++;
      }
    }


    /**
     * @dev return  list of latest #N transfer history
     *      ( public view function )
     * @param _max_num_of_items_to_display   Max Number of latest history items to display ( 0 means 1 )
     * @return  _num   number of latest transfer history items
     * @return  _senders   array of senders
     * @return  _receivers   array of receivers
     * @return  _tokens   array of tokens transferred
     * @return  _whens   array of transfer times
     */
    function list_history_of_token_transfer(uint _max_num_of_items_to_display) public view 
      returns (uint _num,address[] _senders,address[] _receivers,uint[] _tokens,uint[] _whens){
      uint len = history_token_transfer.length;
      uint n= len;
      if(_max_num_of_items_to_display == 0) _max_num_of_items_to_display= 1;
      if(_max_num_of_items_to_display <  n) n= _max_num_of_items_to_display;
      _senders = new address[](n);
      _receivers = new address[](n);
      _tokens = new uint[](n);
      _whens = new uint[](n);
      _num=0;
      for (uint j = len-1 ; j >= 0 && n > _num ; j--) {
         history_token_transfer_obj storage obj= history_token_transfer[j];
         _senders[_num]= obj._from;
         _receivers[_num]= obj._to;
         _tokens[_num]=  obj._token_value;
         _whens[_num]=   obj._when;
         _num++;
      }
    }

    /**
     * @dev return  list of latest address-filtered #N transfer history 
     *     ( public view function )
     * @param _addr   address as filter for transfer history (default 0x0)
     * @return  _num   number of latest transfer history items
     * @return  _senders   array of senders
     * @return  _receivers   array of receivers
     * @return  _tokens   array of tokens transferred
     * @return  _whens   array of transfer times
     */
    function list_history_of_token_transfer_filtered_by_addr(address _addr) public view 
      returns (uint _num,address[] _senders,address[] _receivers,uint[] _tokens,uint[] _whens){
      uint len = history_token_transfer.length;
      uint _max_num_of_items_to_display= 0;
      history_token_transfer_obj storage obj= history_token_transfer[0];
      uint j;
      for (j = len-1 ; j >= 0 ; j--) {
         obj= history_token_transfer[j];
         if(obj._from== _addr || obj._to== _addr) _max_num_of_items_to_display++;
      }
      if(_max_num_of_items_to_display == 0) _max_num_of_items_to_display= 1;
      _senders = new address[](_max_num_of_items_to_display);
      _receivers = new address[](_max_num_of_items_to_display);
      _tokens = new uint[](_max_num_of_items_to_display);
      _whens = new uint[](_max_num_of_items_to_display);
      _num=0;
      for (j = len-1 ; j >= 0 && _max_num_of_items_to_display > _num ; j--) {
         obj= history_token_transfer[j];
         if(obj._from!= _addr && obj._to!= _addr) continue;
         _senders[_num]= obj._from;
         _receivers[_num]= obj._to;
         _tokens[_num]=  obj._token_value;
         _whens[_num]=   obj._when;
         _num++;
      }
    }

    /**
     * @dev return frozen accounts and their balances 
     *     ( public view function )
     * @param _max_num_of_items_to_display   Max Number of items to display ( 0 means 1 )
     * @return  _num   number of currently frozen accounts
     * @return  _frozen_holders   array of frozen accounts
     * @return  _whens   array of frozen times
     */
    function list_frozen_accounts(uint _max_num_of_items_to_display) public view
      returns (uint _num,address[] _frozen_holders,uint[] _whens){
      uint len = holders_frozen.length;
      uint num_of_frozen_holders = 0;
      if(_max_num_of_items_to_display==0) _max_num_of_items_to_display=1;
      for (uint i = len-1 ; i >= 0 ; i--) {
         // assure currently in frozen state
         if( account_frozen_time[ holders_frozen[i] ] > 0x0) num_of_frozen_holders++;
         if(_max_num_of_items_to_display == num_of_frozen_holders) break;
      }
      _frozen_holders = new address[](num_of_frozen_holders);
      _whens = new uint[](num_of_frozen_holders);
      _num=0;
      for (uint j = len-1 ; j >= 0 && num_of_frozen_holders > _num ; j--) {
         address addr= holders_frozen[j];
         uint256 when= account_frozen_time[ addr ];
         if( when == 0x0) continue; // assure if frozen true
         _frozen_holders[_num]= addr;
         _whens[_num]= when;
         _num++;
      }
    }

    /**
     * @dev Token sale sumilation for current sale stage 
     *     ( public view function )
     * @param _ether_or_wei_value  input ethereum value (in wei or ether unit)
     * @return _num_of_tokens  number of tokens that can be bought with the input value
     * @return _exch_rate  current sale stage exchange rate (wei per now)
     * @return _current_sale_stage_index  current sale stage index
     */
    function simulate_token_sale(uint _ether_or_wei_value) public view 
	returns (uint256 _num_of_tokens, uint256 _exch_rate, uint256 _current_sale_stage_index) {
	if(sale_stage_index >=5 ) return (0,0,0);
	_exch_rate= sale_price_per_stage_wei_per_now[sale_stage_index];
        _current_sale_stage_index= sale_stage_index;
        // determine whether the input value is in ether unit or in wei unit
	if(_ether_or_wei_value>=1000000) 
	   _num_of_tokens= uint256( _ether_or_wei_value /  _exch_rate ); // guess it is in wei
        else
	   _num_of_tokens= uint256( _ether_or_wei_value * WEI_PER_ETHER / _exch_rate ); // guess it is in ether
    }


    /**
     * @dev Admin menu: Token Sale Status management
     *      (run by admin, public function)
     * @param _next_status  next status index (1 ~ 13). refer to enum Sale_Status 
     */
    function z_admin_next_status(Sale_Status _next_status) onlyAdmin public {
      if(_next_status== Sale_Status.Stage0_Sale_Started_STATUS) { start_StageN_Sale(0); return;} // 1
      if(_next_status== Sale_Status.Stage0_Sale_Stopped_STATUS) { stop_StageN_Sale(0); return;} // 2
      if(_next_status== Sale_Status.Stage1_Sale_Started_STATUS) { start_StageN_Sale(1); return;} // 3
      if(_next_status== Sale_Status.Stage1_Sale_Stopped_STATUS) { stop_StageN_Sale(1); return;} // 4
      if(_next_status== Sale_Status.Stage2_Sale_Started_STATUS) { start_StageN_Sale(2); return;} // 5
      if(_next_status== Sale_Status.Stage2_Sale_Stopped_STATUS) { stop_StageN_Sale(2); return;} // 6
      if(_next_status== Sale_Status.Stage3_Sale_Started_STATUS) { start_StageN_Sale(3); return;} // 7
      if(_next_status== Sale_Status.Stage3_Sale_Stopped_STATUS) { stop_StageN_Sale(3); return;} // 8
      if(_next_status== Sale_Status.Stage4_Sale_Started_STATUS) { start_StageN_Sale(4); return;} // 9
      if(_next_status== Sale_Status.Stage4_Sale_Stopped_STATUS) { stop_StageN_Sale(4); return;} // 10
      if(_next_status== Sale_Status.Public_Allowed_To_Trade_STATUS) { start_Public_Trade(); return;} //11
      if(_next_status== Sale_Status.Stage0_Allowed_To_Trade_STATUS) { start_Stage0_Trade(); return;} //12
      if(_next_status== Sale_Status.Closed_STATUS) { closeContract(); return;} //13
      revert();
    } 

}