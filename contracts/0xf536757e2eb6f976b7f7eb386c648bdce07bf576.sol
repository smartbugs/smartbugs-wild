pragma solidity ^0.4.13;

contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

/**
 * Math operations with safety checks
 */
contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
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

}

contract StandardToken is ERC20, SafeMath {

    /* Token supply got increased and a new owner received these tokens */
    event Minted(address receiver, uint amount);

    /* Actual balances of token holders */
    mapping(address => uint) balances;

    /* approve() allowances */
    mapping (address => mapping (address => uint)) allowed;

    /* Interface declaration */
    function isToken() public constant returns (bool weAre) {
        return true;
    }

    /**
     * Reviewed:
     * - Interger overflow = OK, checked
     */
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        else {return false;}
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        }
        else {return false;}
    }

    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) returns (bool success) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    /*
    * Fix for the ERC20 short address attack
    */
    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length >= size + 4);
        _;
    }
}

contract LGBiT is StandardToken {

    string public name = "LGBiT";
    string public symbol = "LGBiT";

    uint public decimals = 8;
    uint public multiplier = 100000000; // decimals to the left

    /**
     * Boolean contract states
     */
    bool public halted = false; //the founder address can set this to true to halt the crowdsale due to emergency
    bool public preIco = true; //Pre-ico state

    /**
     * Initial founder address (set in constructor)
     * All deposited ETH will be forwarded to this address.
     * Address is a multisig  wallet.
     */
    address public founder = 0x0;
    address public owner = 0x0;

    /**
     * Token count
     */
    uint public totalTokens = 50750000;

    uint public bounty = 200000; // Bounty count

    /**
     * Ico and pre-ico cap
     */
    uint public preIcoCap = 550000 * multiplier; // Max amount raised during pre ico 17500 ether (10%)
    uint public icoCap = 50000000 * multiplier; // Max amount raised during crowdsale 175000 ether

    /**
     * Statistic values
     */
    uint public presaleTokenSupply = 0; // This will keep track of the token supply created during the crowdsale
    uint public presaleEtherRaised = 0; // This will keep track of the Ether raised during the crowdsale
    uint public preIcoTokenSupply = 0; // This will keep track of the token supply created during the pre-ico

    event Buy(address indexed sender, uint eth, uint fbt);

    /* This generates a public event on the blockchain that will notify clients */
    event TokensSent(address indexed to, uint256 value);
    event ContributionReceived(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    function LGBiT() payable {
        owner = msg.sender;
        founder = 0x00A691299526E4DC3754F8e2A0d6788F27c0dc7e;

        // Sub from total tokens bounty pool
        totalTokens = safeSub(totalTokens, bounty);
        totalSupply = safeMul(totalTokens, multiplier);
        balances[owner] = safeMul(totalSupply, multiplier);
    }

    /**
     * Price count
     */
    function price() constant returns (uint256){
        if (preIco) {
            return safeDiv(1 ether, 800);
        } else {
            if (presaleEtherRaised < 4999 ether) {
                return safeDiv(1 ether, 700);
            } else if (presaleEtherRaised >= 5000 ether && presaleEtherRaised < 9999 ether) {
                return safeDiv(1 ether, 685);
            } else if (presaleEtherRaised >= 10000 ether && presaleEtherRaised < 19999 ether) {
                return safeDiv(1 ether, 660);
            } else {
                return safeDiv(1 ether, 600);
            }
        }
    }

    /**
      * The basic entry point to participate the crowdsale process.
      *
      * Pay for funding, get invested tokens back in the sender address.
       */
    function buy() public payable returns(bool) {
        processBuy(msg.sender, msg.value);

        return true;
    }

    function processBuy(address _to, uint256 _value) internal returns(bool) {
        // Buy allowed if contract is not on halt
        require(!halted);
        // Amount of wei should be more that 0
        require(_value>0);

        // Count expected tokens price
        uint tokens = _value / price();

        if (_value > 99 ether && _value < 1000 ether) {
            // Add 10% if you send > 100 but < 1000 eth
            tokens = tokens + (tokens / 10);
        } else if (_value > 999 ether) {
            // Add 25% if you send > 1000
            tokens = tokens + (tokens / 4);
        }

        // Total tokens should be more than user want's to buy
        require(balances[owner]>safeMul(tokens, multiplier));

        // Check how much tokens already sold
        if (preIco) {
            // Check that required tokens count are less than tokens already sold on pre-ico
            require(safeAdd(presaleTokenSupply, tokens) < preIcoCap);
        } else {
            // Check that required tokens count are less than tokens already sold on ico sub pre-ico
            require(safeAdd(presaleTokenSupply, tokens) < safeSub(icoCap, preIcoTokenSupply));
        }

        // Send wei to founder address
        founder.transfer(_value);

        // Add tokens to user balance and remove from totalSupply
        balances[_to] = safeAdd(balances[_to], safeMul(tokens, multiplier));
        // Remove sold tokens from total supply count
        balances[owner] = safeSub(balances[owner], safeMul(tokens, multiplier));

        // Update stats
        if (preIco) {
            preIcoTokenSupply  = safeAdd(preIcoTokenSupply, tokens);
        }

        presaleTokenSupply = safeAdd(presaleTokenSupply, tokens);
        presaleEtherRaised = safeAdd(presaleEtherRaised, _value);

        // Send buy token action
        Buy(_to, _value, safeMul(tokens, multiplier));

        // /* Emit log events */
        TokensSent(_to, safeMul(tokens, multiplier));
        ContributionReceived(_to, _value);
        Transfer(owner, _to, safeMul(tokens, multiplier));

        return true;
    }

    /**
     * Pre-ico state.
     */
    function setPreIco() onlyOwner() {
        preIco = true;
    }

    function unPreIco() onlyOwner() {
        preIco = false;
    }

    /**
     * Emergency Stop ICO.
     */
    function halt() onlyOwner() {
        halted = true;
    }

    function unHalt() onlyOwner() {
        halted = false;
    }

    /**
     * Transfer bounty tokens to target address
     */
    function sendBounty(address _to, uint256 _value) onlyOwner() {
        require(bounty>_value);

        bounty = safeSub(bounty, _value);
        balances[_to] = safeAdd(balances[_to], safeMul(_value, multiplier));

        // Emit log events
        TokensSent(_to, safeMul(_value, multiplier));
        Transfer(owner, _to, safeMul(_value, multiplier));
    }

    /**
     * ERC 20 Standard Token interface transfer function
     *
     * Prevent transfers until halt period is over.
     */
    function transfer(address _to, uint256 _value) isAvailable() returns (bool success) {
        return super.transfer(_to, _value);
    }

    /**
     * ERC 20 Standard Token interface transfer function
     *
     * Prevent transfers until halt period is over.
     */
    function transferFrom(address _from, address _to, uint256 _value) isAvailable() returns (bool success) {
        return super.transferFrom(_from, _to, _value);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier isAvailable() {
        require(!halted);
        _;
    }

    /**
     * Just being sent some cash? Let's buy tokens
     */
    function() payable {
        buy();
    }

    /**
     * Replaces an owner
     */
    function changeOwner(address _to) onlyOwner() {
        balances[_to] = balances[owner];
        balances[owner] = 0;
        owner = _to;
    }

    /**
     * Replaces a founder, transfer team pool to new founder balance
     */
    function changeFounder(address _to) onlyOwner() {
        balances[_to] = balances[founder];
        balances[founder] = 0;
        founder = _to;
    }
}