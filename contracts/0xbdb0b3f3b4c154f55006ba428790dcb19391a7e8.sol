pragma solidity ^0.4.11;


/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}


/*
 * Ownable
 *
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */
contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender != owner) {
      throw;
    }
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}


/*
 * ERC20Basic
 * Simpler version of ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Basic {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function transfer(address to, uint value);
  event Transfer(address indexed from, address indexed to, uint value);
}


/*
 * Basic token
 * Basic version of StandardToken, with no allowances
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint;

  mapping(address => uint) balances;

  /*
   * Fix for the ERC20 short address attack  
   */
  modifier onlyPayloadSize(uint size) {
     if(msg.data.length < size + 4) {
       throw;
     }
     _;
  }

  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }
}


/**
 * @title FundableToken - accounts for funds to stand behind it
 * @author Dmitry Kochin <k@ubermensch.store>
 * We need to store this data to be able to know how much funds are standing behind the tokens
 * It may come handy in token transformation. For example if prefund would not be successful we
 * will be able to refund all the invested money
 */
contract FundableToken is BasicToken {
    ///Invested funds
    mapping(address => uint) public funds;

    ///Total funds behind the tokens
    uint public totalFunds;

    function FundableToken() {}
}


/**
 * Transform agent transfers tokens to a new contract. It may transform them to another tokens or refund
 * Transform agent itself can be the token contract, or just a middle man contract doing the heavy lifting.
 */
contract TransformAgent {
    ///The original supply of tokens to be transformed
    uint256 public originalSupply;
    ///The original funds behind the tokens to be transformed
    uint256 public originalFunds;

    /** Interface marker */
    function isTransformAgent() public constant returns (bool) {
        return true;
    }

    function transformFrom(address _from, uint256 _tokens, uint256 _funds) public;

}


/**
 * A token transform mechanism where users can opt-in amount of tokens to the next smart contract revision.
 *
 * First envisioned by Golem and Lunyr projects.
 */
contract TransformableToken is FundableToken, Ownable {

    /** The next contract where the tokens will be migrated. */
    TransformAgent public transformAgent;

    /** How many tokens we have transformed by now. */
    uint256 public totalTransformedTokens;

    /**
     * Transform states.
     *
     * - NotAllowed: The child contract has not reached a condition where the transform can bgun
     * - WaitingForAgent: Token allows transform, but we don't have a new agent yet
     * - ReadyToTransform: The agent is set, but not a single token has been transformed yet, so we
            still have a chance to reset agent to another value
     * - Transforming: Transform agent is set and the balance holders can transform their tokens
     *
     */
    enum TransformState {Unknown, NotAllowed, WaitingForAgent, ReadyToTransform, Transforming}

    /**
     * Somebody has transformd some of his tokens.
     */
    event Transform(address indexed _from, address indexed _to, uint256 _tokens, uint256 _funds);

    /**
     * New transform agent available.
     */
    event TransformAgentSet(address agent);

    /**
     * Allow the token holder to transform all of their tokens to a new contract.
     */
    function transform() public {

        TransformState state = getTransformState();
        require(state == TransformState.ReadyToTransform || state == TransformState.Transforming);

        uint tokens = balances[msg.sender];
        uint investments = funds[msg.sender];
        require(tokens > 0); // Validate input value.

        balances[msg.sender] = 0;
        funds[msg.sender] = 0;

        // Take tokens out from circulation
        totalSupply = totalSupply.sub(tokens);
        totalFunds = totalFunds.sub(investments);

        totalTransformedTokens = totalTransformedTokens.add(tokens);

        // Transform agent reissues the tokens
        transformAgent.transformFrom(msg.sender, tokens, investments);
        Transform(msg.sender, transformAgent, tokens, investments);

        //Once transformation is finished the contract is not needed anymore
        if(totalSupply == 0)
            selfdestruct(owner);
    }

    /**
     * Set an transform agent that handles
     */
    function setTransformAgent(address agent) onlyOwner external {
        require(agent != 0x0);
        // Transform has already begun for an agent
        require(getTransformState() != TransformState.Transforming);

        transformAgent = TransformAgent(agent);

        // Bad interface
        require(transformAgent.isTransformAgent());
        // Make sure that token supplies match in source and target
        require(transformAgent.originalSupply() == totalSupply);
        require(transformAgent.originalFunds() == totalFunds);

        TransformAgentSet(transformAgent);
    }

    /**
     * Get the state of the token transform.
     */
    function getTransformState() public constant returns(TransformState) {
        if(address(transformAgent) == 0x00) return TransformState.WaitingForAgent;
        else if(totalTransformedTokens == 0) return TransformState.ReadyToTransform;
        else return TransformState.Transforming;
    }
}


/**
 * Mintable token
 *
 * Simple ERC20 Token example, with mintable token creation
 * Issue:
 * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet:
 * https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is BasicToken {
    /**
      Crowdsale contract allowed to mint tokens
    */

    function mint(address _to, uint _amount) internal {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        //Announce that we have minted some tokens
        Transfer(0x0, _to, _amount);
    }
}


/// @title Token contract - Implements Standard Token Interface with Ubermensch features.
/// @author Dmitry Kochin - <k@ubermensch.store>
contract UbermenschPrefundToken is MintableToken, TransformableToken {
    string constant public name = "Ubermensch Prefund";
    string constant public symbol = "UMP";
    uint constant public decimals = 8;

    //The price of 1 token in Ether
    uint constant public TOKEN_PRICE = 0.0025 * 1 ether;
    //The maximum number of tokens to be sold in crowdsale
    uint constant public TOKEN_CAP = 20000000 * (10 ** decimals);

    uint public investorCount;
    address public multisigWallet;
    bool public stopped;

    // A new investment was made
    event Invested(address indexed investor, uint weiAmount, uint tokenAmount);

    function UbermenschPrefundToken(address multisig){
        //We require that the owner should be multisig wallet
        //Because owner can make important decisions like stopping prefund
        //and setting TransformAgent
        //However this contract can be created by any account. After creation
        //it automatically transfers ownership to multisig wallet
        transferOwnership(multisig);
        multisigWallet = multisig;
    }

    modifier onlyActive(){
        require(!stopped);
        //Setting the transfer agent effectively stops prefund
        require(getTransformState() == TransformState.WaitingForAgent);
        _;
    }

    /**
     * Returns bonuses based on the current totalSupply in percents
     * An investor gets the bonus based on the current totalSupply value
     * even if the resulting totalSupply after an investment corresponds to different bonus
     */
    function getCurrentBonus() public constant returns (uint){
        if(totalSupply < 7000000 * (10 ** decimals))
            return 180;
        if(totalSupply < 14000000 * (10 ** decimals))
            return 155;
        return 140;
    }

    /// @dev main function to buy tokens to specified address
    /// @param to The address of token recipient
    function invest(address to) onlyActive public payable {
        uint amount = msg.value;
        //Bonuses are in percents so the final value must be divided by 100
        uint tokenAmount = getCurrentBonus().mul(amount).mul(10 ** decimals / 100).div(TOKEN_PRICE);

        require(tokenAmount >= 0);

        if(funds[to] == 0) {
            // A new investor
            ++investorCount;
        }

        // Update investor
        funds[to] = funds[to].add(amount);
        totalFunds = totalFunds.add(amount);

        //mint tokens
        mint(to, tokenAmount);

        //We also should not break the token cap
        //This is exactly "require' and not 'assert' because it depends on msg.value - a user supplied parameters
        //While 'assert' should correspond to a broken business logic
        require(totalSupply <= TOKEN_CAP);

        // Pocket the money
        multisigWallet.transfer(amount);

        // Tell us invest was success
        Invested(to, amount, tokenAmount);
    }

    function buy() public payable {
        invest(msg.sender);
    }

    function transfer(address _to, uint _value){
        throw; //This prefund token can not be transferred
    }

    //Stops the crowdsale forever
    function stop() onlyOwner {
        stopped = true;
    }

    //We'll try to accept sending ether on the contract address, hope the gas supplied would be enough
    function () payable{
        buy();
    }
}