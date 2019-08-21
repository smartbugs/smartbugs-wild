pragma solidity 0.4.25;



interface ERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);  
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool ok);
    function transferFrom(address from, address to, uint256 value) external returns (bool ok);
    function approve(address spender, uint256 value) external returns (bool ok);  
    function totalSupply() external view returns(uint256);
}
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
contract Ownable {    
    address public owner;
    address public tempOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferRequest(address indexed previousOwner, address indexed newOwner);
    
    // Constructor which will assing the admin to the contract deployer.
    constructor() public {
        owner = msg.sender;
    }

    // Modifier which will make sure only admin can call a particuler function.
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // This method is used to transfer ownership to a new admin. This is the first of the two stesps.
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        emit OwnershipTransferRequest(owner, newOwner);
        tempOwner = newOwner;
    }
  
    // This is the second of two steps of ownership transfer, new admin has to call to confirm transfer.
    function acceptOwnership() public {  
        require(tempOwner==msg.sender);
        emit OwnershipTransferred(owner,msg.sender);
        owner = msg.sender;
    }
}



/*
* The HITT token contract, it is a standard ERC20 contract with a small updates to accomodate 
* our conditions of adding, validating the stakes.
* 
* Author : Vikas
* Auditor : Darryl Morris
*/
contract HITT is ERC20,Ownable {    
    using SafeMath for uint256;
    string public constant name = "Health Information Transfer Token";
    string public constant symbol = "HITT";
    uint8 public constant decimals = 18;
    uint256 private constant totalSupply1 = 1000000000 * 10 ** uint256(decimals);
    address[] public founders = [
        0x89Aa30ca3572eB725e5CCdcf39d44BAeD5179560, 
        0x1c61461794df20b0Ed8C8D6424Fd7B312722181f];
    address[] public advisors = [
        0xc83eDeC2a4b6A992d8fcC92484A82bC312E885B5, 
        0x9346e8A0C76825Cd95BC3679ab83882Fd66448Ab, 
        0x3AA2958c7799faAEEbE446EE5a5D90057fB5552d, 
        0xF90f4D2B389D499669f62F3a6F5E0701DFC202aF, 
        0x45fF9053b44914Eedc90432c3B6674acDD400Cf1, 
        0x663070ab83fEA900CB7DCE7c92fb44bA9E0748DE];
    mapping (address => uint256)  balances;
    mapping (address => mapping (address => uint256))  allowed;
    mapping (address => uint64) lockTimes;
    
    /*
    * 31104000 = 360 Days in seconds. We're not using whole 365 days for `tokenLockTime` 
    * because we have used multiple of 90 for 3M, 6M, 9M and 12M in the Hodler Smart contract's time calculation as well.
    * We shall use it to lock the tokens of Advisors and Founders. 
    */
    uint64 public constant tokenLockTime = 31104000;
    
    /*
    * Need to update the actual value during deployement. update needed.
    * This is HODL pool. It shall be distributed for the whole year as a 
    * HODL bonus among the people who shall not move their ICO tokens for 
    * 3,6,9 and 12 months respectively. 
    */
    uint256 public constant hodlerPoolTokens = 15000000 * 10 ** uint256(decimals) ; 
    Hodler public hodlerContract;

    /*
    * The constructor method which will initialize the token supply.
    * We've multiple `Transfer` events emitting from the Constructor so that Etherscan can pick 
    * it as the contributor's address and can show correct informtaion on the site.
    * We're deliberately choosing the manual transfer of the tokens to the advisors and the founders over the 
    * internal `_transfer()` because the admin might use the same account for deploying this Contract and as an founder address.
    * which will have `locktime`.
    */
    constructor() public {
        uint8 i=0 ;
        balances[0x60Bf75BB47cbD4cD1eeC7Cd48eab1F16Ebe822c6] = totalSupply1;
        emit Transfer(0x0,0x60Bf75BB47cbD4cD1eeC7Cd48eab1F16Ebe822c6,totalSupply1);
        uint256 length = founders.length ;
        for( ; i < length ; i++ ){
            /*
            * These 45 days shall be used to distribute the tokens to the contributors of the ICO.
            */
            lockTimes[founders[i]] = uint64(block.timestamp + 365 days + tokenLockTime );
        }
        length = advisors.length ;
        for( i=0 ; i < length ; i++ ){
            lockTimes[advisors[i]] = uint64(block.timestamp +  365 days + tokenLockTime); 
            balances[0x60Bf75BB47cbD4cD1eeC7Cd48eab1F16Ebe822c6] = balances[0x60Bf75BB47cbD4cD1eeC7Cd48eab1F16Ebe822c6].sub(40000 * 10 ** uint256(decimals));
            balances[advisors[i]] = 40000 * 10 ** uint256(decimals) ;
            emit Transfer( 0x60Bf75BB47cbD4cD1eeC7Cd48eab1F16Ebe822c6, advisors[i], 40000 * 10 ** uint256(decimals) );
        }
        balances[0x60Bf75BB47cbD4cD1eeC7Cd48eab1F16Ebe822c6] = balances[0x60Bf75BB47cbD4cD1eeC7Cd48eab1F16Ebe822c6].sub(130000000 * 10 ** uint256(decimals));
        balances[founders[0]] = 100000000 * 10 ** uint256(decimals) ;
        balances[founders[1]] =  30000000 * 10 ** uint256(decimals) ; 
        emit Transfer( 0x60Bf75BB47cbD4cD1eeC7Cd48eab1F16Ebe822c6, founders[0], 100000000 * 10 ** uint256(decimals) );
        emit Transfer( 0x60Bf75BB47cbD4cD1eeC7Cd48eab1F16Ebe822c6, founders[1],  30000000 * 10 ** uint256(decimals) );
        hodlerContract = new Hodler(hodlerPoolTokens, msg.sender); 
        balances[0x60Bf75BB47cbD4cD1eeC7Cd48eab1F16Ebe822c6] = balances[0x60Bf75BB47cbD4cD1eeC7Cd48eab1F16Ebe822c6].sub(hodlerPoolTokens);
        balances[address(hodlerContract)] = hodlerPoolTokens; // giving the total hodler bonus to the HODLER contract to distribute.        
        assert(totalSupply1 == balances[0x60Bf75BB47cbD4cD1eeC7Cd48eab1F16Ebe822c6].add(hodlerPoolTokens.add((130000000 * 10 ** uint256(decimals)).add(length.mul(40000 * 10 ** uint256(decimals))))));
        emit Transfer( 0x60Bf75BB47cbD4cD1eeC7Cd48eab1F16Ebe822c6, address(hodlerContract), hodlerPoolTokens );
    }
    

    /*
    * Constant function to return the total supply of the HITT contract
    */
    function totalSupply() public view returns(uint256) {
        return totalSupply1;
    }

    /* 
    * Transfer amount from one account to another. The code takes care that it doesn't transfer the tokens to contracts. 
    * This function trigger the action to invalidate the participant's right to get the
    *  HODL rewards if they make any transaction within the hodl period.
    * Getting into the HODL club is optional by not moving their tokens after receiving tokens in their wallet for 
    * pre-defined period like 3,6,9 or 12 months.
    * More details are here about the HODL T&C : https://medium.com/@Vikas1188/lets-hodl-with-emrify-bc5620a14237
    */
    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
        require(!isContract(_to));
        require(block.timestamp > lockTimes[_from]);
        uint256 prevBalTo = balances[_to] ;
        uint256 prevBalFrom = balances[_from];
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(hodlerContract.isValid(_from)) {
            require(hodlerContract.invalidate(_from));
        }
        emit Transfer(_from, _to, _value);
        assert(_value == balances[_to].sub(prevBalTo));
        assert(_value == prevBalFrom.sub(balances[_from]));
        return true;
    }
	
    /*
    * Standard token transfer method.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        return _transfer(msg.sender, _to, _value);
    }

    /*
    * This method will allow a 3rd person to spend tokens (requires `approval()` 
    * to be called before with that 3rd person's address)
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_value <= allowed[_from][msg.sender]); 
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        return _transfer(_from, _to, _value);
    }

    /*
    * Approve `_spender` to move `_value` tokens from owner's account
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(block.timestamp>lockTimes[msg.sender]);
        allowed[msg.sender][_spender] = _value; 
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /*
    * Returns balance
    */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    /*
    * Returns whether the `_spender` address is allowed to move the coins of the `_owner` 
    */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }
    
    /*
    * This method will be used by the admin to allocate tokens to multiple contributors in a single shot.
    */
    function saleDistributionMultiAddress(address[] _addresses,uint256[] _values) public onlyOwner returns (bool) {    
        require( _addresses.length > 0 && _addresses.length == _values.length); 
        uint256 length = _addresses.length ;
        for(uint8 i=0 ; i < length ; i++ )
        {
            if(_addresses[i] != address(0) && _addresses[i] != owner) {
                require(hodlerContract.addHodlerStake(_addresses[i], _values[i]));
                _transfer( msg.sender, _addresses[i], _values[i]) ;
            }
        }
        return true;
    }
     
    /*
    * This method will be used to send tokens to multiple addresses.
    */
    function batchTransfer(address[] _addresses,uint256[] _values) public  returns (bool) {    
        require(_addresses.length > 0 && _addresses.length == _values.length);
        uint256 length = _addresses.length ;
        for( uint8 i = 0 ; i < length ; i++ ){
            
            if(_addresses[i] != address(0)) {
                _transfer(msg.sender, _addresses[i], _values[i]);
            }
        }
        return true;
    }   
    
    /*
    * This method checks whether the address is a contract or not. 
    */
    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
    
}


contract Hodler is Ownable {
    using SafeMath for uint256;
    bool istransferringTokens = false;
    address public admin; // getting updated in constructor
    
    /* 
    * HODLER reward tracker
    * stake amount per address
    * Claim flags for 3,6,9 & 12 months respectiviely.
    * It shall be really useful to get the details whether a particular address got his claims.
    */
    struct HODL {
        uint256 stake;
        bool claimed3M;
        bool claimed6M;
        bool claimed9M;
        bool claimed12M;
    }

    mapping (address => HODL) public hodlerStakes;

    /* 
    * Total current staking value & count of hodler addresses.
    * hodlerTotalValue = ∑ all the valid distributed tokens. 
    * This shall be the reference in which we shall distribute the HODL bonus.
    * hodlerTotalCount = count of the different addresses who is still HODLing their intial distributed tokens.
    */
    uint256 public hodlerTotalValue;
    uint256 public hodlerTotalCount;

    /*
    * To keep the snapshot of the tokens for 3,6,9 & 12 months after token sale.
    * Since people shall invalidate their stakes during the HODL period, we shall keep 
    * decreasing their share from the `hodlerTotalValue`. it shall always have the 
    * user's ICO contribution who've not invalidated their stakes.
    */
    uint256 public hodlerTotalValue3M;
    uint256 public hodlerTotalValue6M;
    uint256 public hodlerTotalValue9M;
    uint256 public hodlerTotalValue12M;

    /*
    * This shall be set deterministically to 45 days in the constructor itself 
    * from the deployment date of the Token Contract. 
    */
    uint256 public hodlerTimeStart;
 
    /*
    * Reward HITT token amount for 3,6,9 & 12 months respectively, which shall be 
    * calculated deterministically in the contructor
    */
    uint256 public TOKEN_HODL_3M;
    uint256 public TOKEN_HODL_6M;
    uint256 public TOKEN_HODL_9M;
    uint256 public TOKEN_HODL_12M;

    /* 
    * Total amount of tokens claimed so far while the HODL period
    */
    uint256 public claimedTokens;
    
    event LogHodlSetStake(address indexed _beneficiary, uint256 _value);
    event LogHodlClaimed(address indexed _beneficiary, uint256 _value);

    ERC20 public tokenContract;
    
    /*
    * Modifier: before hodl is started
    */
    modifier beforeHodlStart() {
        require(block.timestamp < hodlerTimeStart);
        _;
    }

    /*
    * Constructor: It shall set values deterministically
    * It should be created by a token distribution contract
    * Because we cannot multiply rational with integer, 
    * we are using 75 instead of 7.5 and dividing with 1000 instaed of 100.
    */
    constructor(uint256 _stake, address _admin) public {
        TOKEN_HODL_3M = (_stake*75)/1000;
        TOKEN_HODL_6M = (_stake*15)/100;
        TOKEN_HODL_9M = (_stake*30)/100;
        TOKEN_HODL_12M = (_stake*475)/1000;
        tokenContract = ERC20(msg.sender);
        hodlerTimeStart = block.timestamp.add(365 days) ; // These 45 days shall be used to distribute the tokens to the contributors of the ICO
        admin = _admin;
    }
    
    /*
    * This method will only be called by the `saleDistributionMultiAddress()` 
    * from the Token Contract. 
    */
    function addHodlerStake(address _beneficiary, uint256 _stake) public onlyOwner beforeHodlStart returns (bool) {
        // real change and valid _beneficiary is needed
        if (_stake == 0 || _beneficiary == address(0))
            return false;
        
        // add stake and maintain count
        if (hodlerStakes[_beneficiary].stake == 0)
            hodlerTotalCount = hodlerTotalCount.add(1);
        hodlerStakes[_beneficiary].stake = hodlerStakes[_beneficiary].stake.add(_stake);
        hodlerTotalValue = hodlerTotalValue.add(_stake);
        emit LogHodlSetStake(_beneficiary, hodlerStakes[_beneficiary].stake);
        return true;
    }
   
    /* 
    * This method can only be called by HITT token contract.
    * This will return true: when we successfully invalidate a stake
    * false: When we try to invalidate the stake of either already
    * invalidated or not participated stake holder in Pre-ico
    */ 
    function invalidate(address _account) public onlyOwner returns (bool) {
        if (hodlerStakes[_account].stake > 0 ) {
            hodlerTotalValue = hodlerTotalValue.sub(hodlerStakes[_account].stake); 
            hodlerTotalCount = hodlerTotalCount.sub(1);
            updateAndGetHodlTotalValue();
            delete hodlerStakes[_account];
            return true;
        }
        return false;
    }

    /* 
    * This method will be used whether the particular user has HODL stake or not.   
    */
    function isValid(address _account) view public returns (bool) {
        if (hodlerStakes[_account].stake > 0) {
            return true;
        }
        return false;
    }
    
    /*
    * Claiming HODL reward for an address.
    * Ideally it shall be called by Admin. But it can be called by anyone 
    * by passing the beneficiery address.
    */
    function claimHodlRewardFor(address _beneficiary) public returns (bool) {
        require(block.timestamp.sub(hodlerTimeStart)<= 450 days ); 
        // only when the address has a valid stake
        require(hodlerStakes[_beneficiary].stake > 0);
        updateAndGetHodlTotalValue();
        uint256 _stake = calculateStake(_beneficiary);
        if (_stake > 0) {
            if (istransferringTokens == false) {
            // increasing claimed tokens
            claimedTokens = claimedTokens.add(_stake);
                istransferringTokens = true;
            // Transferring tokens
            require(tokenContract.transfer(_beneficiary, _stake));
                istransferringTokens = false ;
            emit LogHodlClaimed(_beneficiary, _stake);
            return true;
            }
        } 
        return false;
    }

    /* 
    * This method is to calculate the HODL stake for a particular user at a time.
    */
    function calculateStake(address _beneficiary) internal returns (uint256) {
        uint256 _stake = 0;
                
        HODL memory hodler = hodlerStakes[_beneficiary];
        
        if(( hodler.claimed3M == false ) && ( block.timestamp.sub(hodlerTimeStart)) >= 90 days){ 
            _stake = _stake.add(hodler.stake.mul(TOKEN_HODL_3M).div(hodlerTotalValue3M));
            hodler.claimed3M = true;
        }
        if(( hodler.claimed6M == false ) && ( block.timestamp.sub(hodlerTimeStart)) >= 180 days){ 
            _stake = _stake.add(hodler.stake.mul(TOKEN_HODL_6M).div(hodlerTotalValue6M));
            hodler.claimed6M = true;
        }
        if(( hodler.claimed9M == false ) && ( block.timestamp.sub(hodlerTimeStart)) >= 270 days ){ 
            _stake = _stake.add(hodler.stake.mul(TOKEN_HODL_9M).div(hodlerTotalValue9M));
            hodler.claimed9M = true;
        }
        if(( hodler.claimed12M == false ) && ( block.timestamp.sub(hodlerTimeStart)) >= 360 days){ 
            _stake = _stake.add(hodler.stake.mul(TOKEN_HODL_12M).div(hodlerTotalValue12M));
            hodler.claimed12M = true;
        }
        
        hodlerStakes[_beneficiary] = hodler;
        return _stake;
    }
    
    /*
    * This method is to complete HODL period. Any leftover tokens will 
    * return to admin and then will be added to the growth pool after 450 days .
    */
    function finalizeHodler() public returns (bool) {
        require(msg.sender == admin);
        require(block.timestamp >= hodlerTimeStart.add( 450 days ) ); 
        uint256 amount = tokenContract.balanceOf(this);
        require(amount > 0);
        if (istransferringTokens == false) {
            istransferringTokens = true;
            require(tokenContract.transfer(admin,amount));
            istransferringTokens = false;
            return true;
        }
        return false;
    }
    
    

    /*
    * `claimHodlRewardsForMultipleAddresses()` for multiple addresses.
    * Anyone can call this function and distribute hodl rewards.
    * `_beneficiaries` is the array of addresses for which we want to claim HODL rewards.
    */
    function claimHodlRewardsForMultipleAddresses(address[] _beneficiaries) external returns (bool) {
        require(block.timestamp.sub(hodlerTimeStart) <= 450 days ); 
        uint8 length = uint8(_beneficiaries.length);
        for (uint8 i = 0; i < length ; i++) {
            if(hodlerStakes[_beneficiaries[i]].stake > 0 && (hodlerStakes[_beneficiaries[i]].claimed3M == false || hodlerStakes[_beneficiaries[i]].claimed6M == false || hodlerStakes[_beneficiaries[i]].claimed9M == false || hodlerStakes[_beneficiaries[i]].claimed12M == false)) { 
                require(claimHodlRewardFor(_beneficiaries[i]));
            }
        }
        return true;
    }
    
    /* 
    * This method is used to set the amount of `hodlerTotalValue` remaining.
    * `hodlerTotalValue` will keep getting lower as the people shall be invalidating their stakes over the period of 12 months.
    * Setting 3, 6, 9 & 12 months total staked token value.
    */
    function updateAndGetHodlTotalValue() public returns (uint) {
        if (block.timestamp >= hodlerTimeStart+ 90 days && hodlerTotalValue3M == 0) {   
            hodlerTotalValue3M = hodlerTotalValue;
        }

        if (block.timestamp >= hodlerTimeStart+ 180 days && hodlerTotalValue6M == 0) { 
            hodlerTotalValue6M = hodlerTotalValue;
        }

        if (block.timestamp >= hodlerTimeStart+ 270 days && hodlerTotalValue9M == 0) { 
            hodlerTotalValue9M = hodlerTotalValue;
        }
        if (block.timestamp >= hodlerTimeStart+ 360 days && hodlerTotalValue12M == 0) { 
            hodlerTotalValue12M = hodlerTotalValue;
        }

        return hodlerTotalValue;
    }
}