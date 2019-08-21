/** Orgon Token Smart Contract.  Copyright © 2019 by Oris.Space. v25 */
pragma solidity ^0.4.25;

library SafeMath {
 
  /**
   * Add two uint256 values, throw in case of overflow.
   * @param x first value to add
   * @param y second value to add
   * @return x + y
   */
  function safeAdd (uint256 x, uint256 y) internal pure returns (uint256) {
    uint256 z = x + y;
    require(z >= x);
    return z;
  }

  /**
   * Subtract one uint256 value from another, throw in case of underflow.
   * @param x value to subtract from
   * @param y value to subtract
   * @return x - y
   */
  function safeSub (uint256 x, uint256 y) internal pure returns (uint256) {
    require (x >= y);
    uint256 z = x - y;
    return z;
  }
}

contract Token {
  /**
   * Get total number of tokens in circulation.
   *
   * @return total number of tokens in circulation
   */
  function totalSupply () public view returns (uint256 supply);

  /**
   * Get number of tokens currently belonging to given owner.
   *
   * @param _owner address to get number of tokens currently belonging to the
   *        owner of
   * @return number of tokens currently belonging to the owner of given address
   */
  function balanceOf (address _owner) public view returns (uint256 balance);

  /**
   * Transfer given number of tokens from message sender to given recipient.
   *
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer to the owner of given address
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transfer (address _to, uint256 _value)
  public returns (bool success);

  /**
   * Transfer given number of tokens from given owner to given recipient.
   *
   * @param _from address to transfer tokens from the owner of
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer from given owner to given
   *        recipient
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transferFrom (address _from, address _to, uint256 _value)
  public returns (bool success);

  /**
   * Allow given spender to transfer given number of tokens from message sender.
   *
   * @param _spender address to allow the owner of to transfer tokens from
   *        message sender
   * @param _value number of tokens to allow to transfer
   * @return true if token transfer was successfully approved, false otherwise
   */
  function approve (address _spender, uint256 _value)
  public returns (bool success);

  /**
   * Tell how many tokens given spender is currently allowed to transfer from
   * given owner.
   *
   * @param _owner address to get number of tokens allowed to be transferred
   *        from the owner of
   * @param _spender address to get number of tokens allowed to be transferred
   *        by the owner of
   * @return number of tokens given spender is currently allowed to transfer
   *         from given owner
   */
  function allowance (address _owner, address _spender)
  public view returns (uint256 remaining);

  /**
   * Logged when tokens were transferred from one owner to another.
   *
   * @param _from address of the owner, tokens were transferred from
   * @param _to address of the owner, tokens were transferred to
   * @param _value number of tokens transferred
   */
  event Transfer (address indexed _from, address indexed _to, uint256 _value);

  /**
   * Logged when owner approved his tokens to be transferred by some spender.
   *
   * @param _owner owner who approved his tokens to be transferred
   * @param _spender spender who were allowed to transfer the tokens belonging
   *        to the owner
   * @param _value number of tokens belonging to the owner, approved to be
   *        transferred by the spender
   */
  event Approval (
    address indexed _owner, address indexed _spender, uint256 _value);
}

/** Orgon Token smart contract */
contract OrgonToken is Token {
    
using SafeMath for uint256;

/* Maximum allowed number of tokens in circulation (2^256 - 1). */
uint256 constant MAX_TOKEN_COUNT =
0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

/* Full life start time (2021-10-18 18:10:21 UTC) */
uint256 private constant LIFE_START_TIME = 1634559021;

/* Number of tokens to be send for Full life start 642118523.280000000000000000 */
uint256 private constant LIFE_START_TOKENS = 642118523280000000000000000;
  
/** Deploy Orgon Token smart contract and make message sender to be the owner
   of the smart contract */
/* *********************************************** */
constructor() public {
    owner = msg.sender;
    mint = msg.sender;
}
  
  
/** Get name,symbol of this token, number of decimals for this token  
 * @return name of this token */
/* *********************************************** */
function name () public pure returns (string) {
    
    return "ORGON";
}

/* *********************************************** */
function symbol () public pure returns (string) {
    
    return "ORGON";
}
/* *********************************************** */
function decimals () public pure returns (uint8) {
    
    return 18;
}

/** Get total number of tokens in circulation
 * @return total number of tokens in circulation */
 
/* *********************************************** */ 
function totalSupply () public view returns (uint256 supply) {
     
     return tokenCount;
 }

/* *********************************************** */
function totalICO () public view returns (uint256) {
     
     return tokenICO;
 }

/* *********************************************** */
function theMint () public view returns (address) {
     
     return mint;
 }
 
 /* *********************************************** */
function theStage () public view returns (Stage) {
     
     return stage;
 }
 
 /* *********************************************** */
function theOwner () public view returns (address) {
     
     return owner;
 }
 
 
/** Get balance */

/* *********************************************** */
function balanceOf (address _owner) public view returns (uint256 balance) {

    return accounts [_owner];
}


/** Transfer given number of tokens from message sender to given recipient.
 * @param _to address to transfer tokens to the owner of
 * @param _value number of tokens to transfer to the owner of given address
 * @return true if tokens were transferred successfully, false otherwise */
 
 /* *********************************************** */
 function transfer (address _to, uint256 _value)
 public validDestination(_to) returns (bool success) {
    
    require (accounts [msg.sender]>=_value);
    
    uint256 fromBalance = accounts [msg.sender];
    if (fromBalance < _value) return false;
    
    if (stage != Stage.ICO){
        accounts [msg.sender] = fromBalance.safeSub(_value);
        accounts [_to] = accounts[_to].safeAdd(_value);
    }
    else if (msg.sender == owner){ // stage == Stage.ICO
        accounts [msg.sender] = fromBalance.safeSub(_value);
        accounts [_to] = accounts[_to].safeAdd(_value);
        tokenICO = tokenICO.safeAdd(_value);
    }
    else if (_to == owner){ // stage == Stage.ICO
        accounts [msg.sender] = fromBalance.safeSub(_value);
        accounts [_to] = accounts[_to].safeAdd(_value);
        tokenICO = tokenICO.safeSub(_value);
    }
    else if (forPartners[msg.sender] >= _value){ // (sender is Partner)
        accounts [msg.sender] = fromBalance.safeSub(_value);
        forPartners [msg.sender] = forPartners[msg.sender].safeSub(_value);
        accounts [_to] = accounts[_to].safeAdd(_value);
    }
    else revert();
    
    emit Transfer (msg.sender, _to, _value);
    return true;
}


/** Transfer given number of tokens from given owner to given recipient.
 * @param _from address to transfer tokens from the owner of
 * @param _to address to transfer tokens to the owner of
 * @param _value number of tokens to transfer from given owner to given
 *        recipient
 * @return true if tokens were transferred successfully, false otherwise */
 
/* *********************************************** */
function transferFrom (address _from, address _to, uint256 _value)
public validDestination(_to) returns (bool success) {

    require (stage != Stage.ICO);
    require(_from!=_to);
    uint256 spenderAllowance = allowances [_from][msg.sender];
    if (spenderAllowance < _value) return false;
    uint256 fromBalance = accounts [_from];
    if (fromBalance < _value) return false;

    allowances [_from][msg.sender] =  spenderAllowance.safeSub(_value);

    if (_value > 0) {
      accounts [_from] = fromBalance.safeSub(_value);
      accounts [_to] = accounts[_to].safeAdd(_value);
    }
    emit Transfer (_from, _to, _value);
    return true;
}


/** Allow given spender to transfer given number of tokens from message sender
 * @param _spender address to allow the owner of to transfer tokens from
 *        message sender
 * @param _value number of tokens to allow to transfer
 * @return true if token transfer was successfully approved, false otherwise */
 
/* *********************************************** */
function approve (address _spender, uint256 _value)
public returns (bool success) {
    require(_spender != address(0));
    
    allowances [msg.sender][_spender] = _value;
    emit Approval (msg.sender, _spender, _value);
    return true;
}


/** Allow Partner to transfer given number of tokens 
 * @param _partner Partner address 
 * @param _value number of tokens to allow to transfer
 * @return true if token transfer was successfully approved, false otherwise */
 
/* *********************************************** */
function addToPartner (address _partner, uint256 _value)
public returns (bool success) {
    
    require (msg.sender == owner);
    forPartners [_partner] = forPartners[_partner].safeAdd(_value);
    return true;
}

/** Disallow Partner to transfer given number of tokens 
 * @param _partner Partner address
 * @param _value number of tokens to allow to transfer
 * @return true if token transfer was successfully approved, false otherwise */

/* *********************************************** */
function subFromPartner (address _partner, uint256 _value)
public returns (bool success) {
    
    require (msg.sender == owner);
    if (forPartners [_partner] < _value) {
        forPartners [_partner] = 0;
    }
    else {
        forPartners [_partner] = forPartners[_partner].safeSub(_value);
    }
    return true;
}

/** Tell how many tokens given partner is currently allowed to transfer from
  given him.
  @param _partner address to get number of tokens allowed to be transferred         
  @return number of tokens given spender is currently allowed to transfer
  from given owner */
  
/* *********************************************** */
function partners (address _partner)
public view returns (uint256 remaining) {

    return forPartners [_partner];
  }


/** Create _value new tokens and give new created tokens to msg.sender.
 * May only be called by smart contract owner.
 * @param _value number of tokens to create
 * @return true if tokens were created successfully, false otherwise*/
 
/* *********************************************** */
function createTokens (uint256 _value) public returns (bool) {

    require (msg.sender == mint);
    
    if (_value > 0) {
        if (_value > MAX_TOKEN_COUNT.safeSub(tokenCount)) return false;
        accounts [msg.sender] = accounts[msg.sender].safeAdd(_value);
        tokenCount = tokenCount.safeAdd(_value);
        emit Transfer (address (0), msg.sender, _value);
    }
    return true;
}


/** Burn given number of tokens belonging to owner.
 * May only be called by smart contract owner.
 * @param _value number of tokens to burn
 * @return true on success, false on error */
 
/* *********************************************** */
function burnTokens (uint256 _value) public returns (bool) {

    require (msg.sender == mint);
    require (accounts [msg.sender]>=_value);
    
    if (_value > accounts [mint]) return false;
    else if (_value > 0) {
        accounts [mint] = accounts[mint].safeSub(_value);
        tokenCount = tokenCount.safeSub(_value);
        emit Transfer (mint, address (0), _value);
        return true;
    }
    else return true;
}


/** Set new owner for the smart contract.
 * May only be called by smart contract owner.
 * @param _newOwner address of new owner of the smart contract */
 
/* *********************************************** */
function setOwner (address _newOwner) public validDestination(_newOwner) {
 
    require (msg.sender == owner);
    
    owner = _newOwner;
    uint256 fromBalance = accounts [msg.sender];
    if (fromBalance > 0 && msg.sender != _newOwner) {
        accounts [msg.sender] = fromBalance.safeSub(fromBalance);
        accounts [_newOwner] = accounts[_newOwner].safeAdd(fromBalance);
        emit Transfer (msg.sender, _newOwner, fromBalance);
    }
}

/** Set new owner for the smart contract.
 * May only be called by smart contract owner.
 * @param _newMint address of new owner of the smart contract */

/* *********************************************** */
function setMint (address _newMint) public {
 
 if (stage != Stage.LIFE && (msg.sender == owner || msg.sender == mint )){
    mint = _newMint;
 }
 else if (msg.sender == mint){
    mint = _newMint;
 }
 else revert();
}

/** Chech and Get current stage
 * @return current stage */
 
/* *********************************************** */
function checkStage () public returns (Stage) {

    require (stage != Stage.LIFE);
    
    Stage currentStage = stage;
    if (currentStage == Stage.ICO) {
        if (block.timestamp >= LIFE_START_TIME || tokenICO > LIFE_START_TOKENS) {
            currentStage = Stage.LIFE;
            stage = Stage.LIFE;
        }
    else return currentStage;
    }
    return currentStage;
}

/** Change stage by Owner */

/* *********************************************** */
function changeStage () public {
    
    require (msg.sender == owner);
    require (stage != Stage.LIFE);
    if (stage == Stage.ICO) {stage = Stage.LIFEBYOWNER;}
    else stage = Stage.ICO;
}



/** Tell how many tokens given spender is currently allowed to transfer from
 * given owner.
 * @param _owner address to get number of tokens allowed to be transferred
 *        from the owner of
 * @param _spender address to get number of tokens allowed to be transferred
 *        by the owner of
 * @return number of tokens given spender is currently allowed to transfer
 *         from given owner */
 
/* *********************************************** */
function allowance (address _owner, address _spender)
public view returns (uint256 remaining) {

    return allowances [_owner][_spender];
  }

/**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
   
/* *********************************************** */
function increaseAllowance(address spender, uint256 addedValue) public returns (bool)
  {
    require(spender != address(0));

    allowances[msg.sender][spender] = allowances[msg.sender][spender].safeAdd(addedValue);
    emit Approval(msg.sender, spender, allowances[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    allowances[msg.sender][spender] = allowances[msg.sender][spender].safeSub(subtractedValue);
    emit Approval(msg.sender, spender, allowances[msg.sender][spender]);
    return true;
  }



/** Get current time in seconds since epoch.
 * @return current time in seconds since epoch */
function currentTime () public view returns (uint256) {
    return block.timestamp;
}

/** Total number of tokens in circulation */
uint256 private  tokenCount;

/** Total number of tokens in ICO */
uint256 private  tokenICO;

/** Owner of the smart contract */
address private  owner;

/** Mint of the smart contract */
address private  mint;


  
enum Stage {
    ICO, // 
    LIFEBYOWNER,
    LIFE// 
}
  
/** Last known stage of token*/
Stage private stage = Stage.ICO;
  
/** Mapping from addresses of token holders to the numbers of tokens belonging
 * to these token holders */
mapping (address => uint256) private accounts;

/** Mapping from addresses of partners to the numbers of tokens belonging
 * to these partners. */
mapping (address => uint256) private forPartners;

/** Mapping from addresses of token holders to the mapping of addresses of
 * spenders to the allowances set by these token holders to these spenders */
mapping (address => mapping (address => uint256)) private allowances;

modifier validDestination (address to) {
    require (to != address(0x0));
    require (to != address(this));
    _;
}

}