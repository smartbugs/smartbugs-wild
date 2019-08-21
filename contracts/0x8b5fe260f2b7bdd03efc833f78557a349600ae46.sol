pragma solidity ^0.4.19;

/*
* LooksCoin token sale contract
*
* Refer to https://lookscoin.com for more information.
* 
* Developer: LookRev
*
*/

/*
 * ERC20 Token Standard
 */
contract ERC20 {
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);

uint256 public totalSupply;
function balanceOf(address _owner) constant public returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) constant public returns (uint256 remaining);
}

/**
* Provides methods to safely add, subtract and multiply uint256 numbers.
*/
library SafeMath {
    /**
     * Add two uint256 values, revert in case of overflow.
     *
     * @param a first value to add
     * @param b second value to add
     * @return a + b
     */
    function add(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    /**
     * Subtract one uint256 value from another, throw in case of underflow.
     *
     * @param a value to subtract from
     * @param b value to subtract
     * @return a - b
     */
    function sub(uint256 a, uint256 b) internal returns (uint256) {
        assert(a >= b);
        return a - b;
    }

    /**
     * Multiply two uint256 values, throw in case of overflow.
     *
     * @param a first value to multiply
     * @param b second value to multiply
     * @return a * b
     */
    function mul(uint256 a, uint256 b) internal returns (uint256) {
        if (a == 0 || b == 0) return 0;
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * Divid uint256 values, throw in case of overflow.
     *
     * @param a first value numerator
     * @param b second value denominator
     * @return a / b
     */
    function div(uint256 a, uint256 b) internal returns (uint256) {
        assert(b != 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
}

/*
    Provides support and utilities for contract ownership
*/
contract Ownable {
    address owner;
    address newOwner;

    function Ownable() {
        owner = msg.sender;
    }

    /**
     * Allows execution by the owner only.
     */
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    /**
     * Transferring the contract ownership to the new owner.
     *
     * @param _newOwner new contractor owner
     */
    function transferOwnership(address _newOwner) onlyOwner {
        if (_newOwner != 0x0) {
          newOwner = _newOwner;
        }
    }

    /**
     * Accept the contract ownership by the new owner.
     */
    function acceptOwnership() {
        require(msg.sender == newOwner);
        owner = newOwner;
        OwnershipTransferred(owner, newOwner);
        newOwner = 0x0;
    }
    event OwnershipTransferred(address indexed _from, address indexed _to);
}

/**
* Standard Token Smart Contract
*/
contract StandardToken is ERC20 {
    using SafeMath for uint256;

    /**
     * Mapping from addresses of token holders to the numbers of tokens belonging
     * to these token holders.
     */
    mapping (address => uint256) balances;

    /**
     * Mapping from addresses of token holders to the mapping of addresses of
     * spenders to the allowances set by these token holders to these spenders.
     */
    mapping (address => mapping (address => uint256)) internal allowed;

    /**
     * Mapping from addresses of token holders to the mapping of token amount spent.
     * Use by the token holders to spend their utility tokens.
     */
    mapping (address => mapping (address => uint256)) spentamount;

    /**
     * Mapping of the addition of patrons.
     */
    mapping (address => bool) patronAppended;

    /**
     * Mapping of the addresses of patrons.
     */
    address[] patrons;

    /**
     * Mapping of the addresses of VIP token holders.
     */
    address[] vips;

    /**
    * Mapping for VIP rank for qualified token holders
    * Higher VIP rank (with earlier timestamp) has higher bidding priority when
    * competing for the same product or service on platform.
    */
    mapping (address => uint256) viprank;

    /**
     * Get number of tokens currently belonging to given owner.
     *
     * @param _owner address to get number of tokens currently belonging to its owner
     *
     * @return number of tokens currently belonging to the owner of given address
     */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    /**
     * Transfer given number of tokens from message sender to given recipient.
     *
     * @param _to address to transfer tokens to the owner of
     * @param _value number of tokens to transfer to the owner of given address
     * @return true if tokens were transferred successfully, false otherwise
     */
    function transfer(address _to, uint256 _value) returns (bool success) {
        require(_to != 0x0);
        if (balances[msg.sender] < _value) return false;
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * Transfer given number of tokens from given owner to given recipient.
     *
     * @param _from address to transfer tokens from the owner of
     * @param _to address to transfer tokens to the owner of
     * @param _value number of tokens to transfer from given owner to given
     *        recipient
     * @return true if tokens were transferred successfully, false otherwise
     */
    function transferFrom(address _from, address _to, uint256 _value) 
        returns (bool success) {
        require(_to != 0x0);
        if(_from == _to) return false;
        if (balances[_from] < _value) return false;
        if (_value > allowed[_from][msg.sender]) return false;

        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * Allow given spender to transfer given number of tokens from message sender.
     *
     * @param _spender address to allow the owner of to transfer tokens from
     *        message sender
     * @param _value number of tokens to allow to transfer
     * @return true if token transfer was successfully approved, false otherwise
     */
    function approve(address _spender, uint256 _value) returns (bool success) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling approve(_spender, 0) if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) {
           return false;
        }
        if (balances[msg.sender] < _value) {
            return false;
        }
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
     }

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
     function allowance(address _owner, address _spender) constant 
        returns (uint256 remaining) {
       return allowed[_owner][_spender];
     }
}

/**
 * LooksCoin Token
 *
 * LooksCoin Token is an utility token that can be purchased through crowdsale or earned on
 * the LookRev platform. It can be spent to purchase creative products and services on
 * LookRev platform.
 *
 * VIP rank is used to calculate priority when competing with other bids
 * for the same product or service on the platform. 
 * Higher VIP rank (with earlier timestamp) has higher priority.
 * Higher VIP rank wallet address owner can outbid other lower ranking owners only once
 * per selling window or promotion period.
 * VIP rank is recorded at the time when the wallet address first reach VIP LooksCoin 
 * holding level for a token purchaser.
 * VIP rank is valid for the lifetime of a wallet address on the platform, as long as it 
 * meets the VIP holding level.

 * Usage of the LooksCoin, VIP rank and token utilities are described on the website
 * https://lookscoin.com.
 *
 */
contract LooksCoin is StandardToken, Ownable {

    /**
     * Number of decimals of the smallest unit
     */
    uint256 public constant decimals = 18;

    /**
     * VIP Holding Level. Minimium token holding amount to record a VIP rank.
     * Token holding address needs have at least 24000 LooksCoin to be ranked as VIP
     * VIP rank can only be set through purchasing tokens
     */
    uint256 public constant VIP_MINIMUM = 24000e18;

    /**
     * Initial number of tokens.
     */
    uint256 constant INITIAL_TOKENS_COUNT = 100000000e18;

    /**
     * Crowdsale contract address.
     */
    address public tokenSaleContract = 0x0;

    /**
     * Init Placeholder
     */
    address coinmaster = address(0xd3c79e4AD654436d59AfD61363Bc2B927d2fb680);

    /**
     * Create new LooksCoin token smart contract.
     */
    function LooksCoin() {
        owner = coinmaster;
        balances[owner] = INITIAL_TOKENS_COUNT;
        totalSupply = INITIAL_TOKENS_COUNT;
    }

    /**
     * Get name of this token.
     *
     * @return name of this token
     */
    function name() constant returns (string name) {
      return "LooksCoin";
    }

    /**
     * Get symbol of this token.
     *
     * @return symbol of this token
     */
    function symbol() constant returns (string symbol) {
      return "LOOKS";
    }

    /**
     * @dev Set new token sale contract.
     * May only be called by owner.
     *
     * @param _newTokenSaleContract new token sale manage contract.
     */
    function setTokenSaleContract(address _newTokenSaleContract) {
        require(msg.sender == owner);
        assert(_newTokenSaleContract != 0x0);
        tokenSaleContract = _newTokenSaleContract;
    }

    /**
     * Get VIP rank of a given owner.
     * VIP rank is valid for the lifetime of a token wallet address, 
     * as long as it meets VIP holding level.
     *
     * @param _to participant address to get the vip rank
     * @return vip rank of the owner of given address
     */
    function getVIPRank(address _to) constant public returns (uint256 rank) {
        if (balances[_to] < VIP_MINIMUM) {
            return 0;
        }
        return viprank[_to];
    }

    /**
     * Check and update VIP rank of a given token buyer.
     * Contribution timestamp is recorded for VIP rank.
     * Recorded timestamp for VIP rank should always be earlier than the current time.
     *
     * @param _to address to check the vip rank.
     * @return rank vip rank of the owner of given address if any
     */
    function updateVIPRank(address _to) returns (uint256 rank) {
        // Contribution timestamp is recorded for VIP rank
        // Recorded timestamp for VIP rank should always be earlier than current time
        if (balances[_to] >= VIP_MINIMUM && viprank[_to] == 0) {
            viprank[_to] = now;
            vips.push(_to);
        }
        return viprank[_to];
    }

    event TokenRewardsAdded(address indexed participant, uint256 balance);
    /**
     * Reward participant the tokens they purchased or earned
     *
     * @param _to address to credit tokens to the 
     * @param _value number of tokens to transfer to given recipient
     *
     * @return true if tokens were transferred successfully, false otherwise
     */
    function rewardTokens(address _to, uint256 _value) {
        require(msg.sender == tokenSaleContract || msg.sender == owner);
        assert(_to != 0x0);
        require(_value > 0);

        balances[_to] = balances[_to].add(_value);
        totalSupply = totalSupply.add(_value);
        updateVIPRank(_to);
        TokenRewardsAdded(_to, _value);
    }

    event SpentTokens(address indexed participant, address indexed recipient, uint256 amount);
    /**
     * Spend given number of tokens for a usage.
     *
     * @param _to address to spend utility tokens at
     * @param _value number of tokens to spend
     * @return true on success, false on error
     */
    function spend(address _to, uint256 _value) public returns (bool success) {
        require(_value > 0);
        assert(_to != 0x0);
        if (balances[msg.sender] < _value) return false;

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        spentamount[msg.sender][_to] = spentamount[msg.sender][_to].add(_value);

        SpentTokens(msg.sender, _to, _value);
        if(!patronAppended[msg.sender]) {
            patronAppended[msg.sender] = true;
            patrons.push(msg.sender);
        }
        return true;
    }

    event Burn(address indexed burner, uint256 value);
    /**
     * Burn given number of tokens belonging to message sender.
     * It can be applied by account with address this.tokensaleContract
     *
     * @param _value number of tokens to burn
     * @return true on success, false on error
     */
    function burnTokens(address burner, uint256 _value) public returns (bool success) {
        require(msg.sender == burner || msg.sender == owner);
        assert(burner != 0x0);
        if (_value > totalSupply) return false;
        if (_value > balances[burner]) return false;
        
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
        return true;
    }

    /**
     * Get the VIP owner at the index.
     *
     * @param index of the VIP owner on the VIP list
     * @return address of the VIP owner
     */
    function getVIPOwner(uint256 index) constant returns (address vipowner) {
        return (vips[index]);
    }

    /**
     * Get the count of VIP owners.
     *
     * @return count of VIP owners list.
     */
    function getVIPCount() constant returns (uint256 count) {
        return vips.length;
    }

    /**
     * Get the patron at the index.
     *
     * @param index of the patron on the patron list
     * @return address of the patron
     */
    function getPatron(uint256 index) constant returns (address patron) {
        return (patrons[index]);
    }

    /**
     * Get the count of patrons.
     *
     * @return number of patrons.
     */
    function getPatronsCount() constant returns (uint256 count) {
        return patrons.length;
    }
}