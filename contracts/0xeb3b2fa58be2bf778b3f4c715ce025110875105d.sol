pragma solidity ^0.4.11;


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
    function Ownable() {
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
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}



/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;

    function balanceOf(address who) public constant returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}








/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}









/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping (address => uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

}








/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        uint256 _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
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
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint _addedValue)
    returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue)
    returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        }
        else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}





/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        if (a != 0 && c / a != b) revert();
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        if (b > a) revert();
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        if (c < a) revert();
        return c;
    }
}


/**
 * @title VLBTokens
 * @dev VLB Token contract based on Zeppelin StandardToken contract
 */
contract VLBToken is StandardToken, Ownable {
    using SafeMath for uint256;

    /**
     * @dev ERC20 descriptor variables
     */
    string public constant name = "VLB Tokens";
    string public constant symbol = "VLB";
    uint8 public decimals = 18;

    /**
     * @dev 220 millions is the initial Tokensale supply
     */
    uint256 public constant publicTokens = 220 * 10 ** 24;

    /**
     * @dev 20 millions for the team
     */
    uint256 public constant teamTokens = 20 * 10 ** 24;

    /**
     * @dev 10 millions as a bounty reward
     */
    uint256 public constant bountyTokens = 10 * 10 ** 24;

    /**
     * @dev 2.5 millions as an initial wings.ai reward reserv
     */
    uint256 public constant wingsTokensReserv = 25 * 10 ** 23;
    
    /**
     * @dev wings.ai reward calculated on tokensale finalization
     */
    uint256 public wingsTokensReward = 0;

    // TODO: TestRPC addresses, replace to real
    address public constant teamTokensWallet = 0x6a6AcA744caDB8C56aEC51A8ce86EFCaD59989CF;
    address public constant bountyTokensWallet = 0x91A7DE4ce8e8da6889d790B7911246B71B4c82ca;
    address public constant crowdsaleTokensWallet = 0x5e671ceD703f3dDcE79B13F82Eb73F25bad9340e;
    
    /**
     * @dev wings.ai wallet for reward collecting
     */
    address public constant wingsWallet = 0xcbF567D39A737653C569A8B7dFAb617E327a7aBD;


    /**
     * @dev Address of Crowdsale contract which will be compared
     *       against in the appropriate modifier check
     */
    address public crowdsaleContractAddress;

    /**
     * @dev variable that holds flag of ended tokensake 
     */
    bool isFinished = false;

    /**
     * @dev Modifier that allow only the Crowdsale contract to be sender
     */
    modifier onlyCrowdsaleContract() {
        require(msg.sender == crowdsaleContractAddress);
        _;
    }

    /**
     * @dev event for the burnt tokens after crowdsale logging
     * @param tokens amount of tokens available for crowdsale
     */
    event TokensBurnt(uint256 tokens);

    /**
     * @dev event for the tokens contract move to the active state logging
     * @param supply amount of tokens left after all the unsold was burned
     */
    event Live(uint256 supply);

    /**
     * @dev event for bounty tone transfer logging
     * @param from the address of bounty tokens wallet
     * @param to the address of beneficiary tokens wallet
     * @param value amount of tokens
     */
    event BountyTransfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Contract constructor
     */
    function VLBToken() {
        // Issue team tokens
        balances[teamTokensWallet] = balanceOf(teamTokensWallet).add(teamTokens);
        Transfer(address(0), teamTokensWallet, teamTokens);

        // Issue bounty tokens
        balances[bountyTokensWallet] = balanceOf(bountyTokensWallet).add(bountyTokens);
        Transfer(address(0), bountyTokensWallet, bountyTokens);

        // Issue crowdsale tokens minus initial wings reward.
        // see endTokensale for more details about final wings.ai reward
        uint256 crowdsaleTokens = publicTokens.sub(wingsTokensReserv);
        balances[crowdsaleTokensWallet] = balanceOf(crowdsaleTokensWallet).add(crowdsaleTokens);
        Transfer(address(0), crowdsaleTokensWallet, crowdsaleTokens);

        // 250 millions tokens overall
        totalSupply = publicTokens.add(bountyTokens).add(teamTokens);
    }

    /**
     * @dev back link VLBToken contract with VLBCrowdsale one
     * @param _crowdsaleAddress non zero address of VLBCrowdsale contract
     */
    function setCrowdsaleAddress(address _crowdsaleAddress) onlyOwner external {
        require(_crowdsaleAddress != address(0));
        crowdsaleContractAddress = _crowdsaleAddress;

        // Allow crowdsale contract 
        uint256 balance = balanceOf(crowdsaleTokensWallet);
        allowed[crowdsaleTokensWallet][crowdsaleContractAddress] = balance;
        Approval(crowdsaleTokensWallet, crowdsaleContractAddress, balance);
    }

    /**
     * @dev called only by linked VLBCrowdsale contract to end crowdsale.
     *      all the unsold tokens will be burned and totalSupply updated
     *      but wings.ai reward will be secured in advance
     */
    function endTokensale() onlyCrowdsaleContract external {
        require(!isFinished);
        uint256 crowdsaleLeftovers = balanceOf(crowdsaleTokensWallet);
        
        if (crowdsaleLeftovers > 0) {
            totalSupply = totalSupply.sub(crowdsaleLeftovers).sub(wingsTokensReserv);
            wingsTokensReward = totalSupply.div(100);
            totalSupply = totalSupply.add(wingsTokensReward);

            balances[crowdsaleTokensWallet] = 0;
            Transfer(crowdsaleTokensWallet, address(0), crowdsaleLeftovers);
            TokensBurnt(crowdsaleLeftovers);
        } else {
            wingsTokensReward = wingsTokensReserv;
        }
        
        balances[wingsWallet] = balanceOf(wingsWallet).add(wingsTokensReward);
        Transfer(crowdsaleTokensWallet, wingsWallet, wingsTokensReward);

        isFinished = true;

        Live(totalSupply);
    }
}