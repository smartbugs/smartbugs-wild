pragma solidity ^0.4.16;

  contract ERC20 {
     function totalSupply() constant returns (uint256 totalsupply);
     function balanceOf(address _owner) constant returns (uint256 balance);
     function transfer(address _to, uint256 _value) returns (bool success);
     function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
     function approve(address _spender, uint256 _value) returns (bool success);
     function allowance(address _owner, address _spender) constant returns (uint256 remaining);
     event Transfer(address indexed _from, address indexed _to, uint256 _value);
     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  }
  
  contract TCASH is ERC20 {
     string public constant symbol = "TCASH";
     string public constant name = "Tcash";
     uint8 public constant decimals = 8;
     uint256 _totalSupply = 88000000 * 10**8;
     

     address public owner;
  
     mapping(address => uint256) balances;
  
     mapping(address => mapping (address => uint256)) allowed;
     
  
     function TCASH() {
         owner = msg.sender;
         balances[owner] = 88000000 * 10**8;
     }
     
     modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
     
     
    function distributeTCASH(address[] addresses) onlyOwner {
         for (uint i = 0; i < addresses.length; i++) {
             balances[owner] -= 245719916000;
             balances[addresses[i]] += 245719916000;
             Transfer(owner, addresses[i], 245719916000);
         }
     }
     
  
     function totalSupply() constant returns (uint256 totalsupply) {
         totalsupply = _totalSupply;
     }
  

     function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
     }
 
     function transfer(address _to, uint256 _amount) returns (bool success) {
         if (balances[msg.sender] >= _amount 
            && _amount > 0
             && balances[_to] + _amount > balances[_to]) {
             balances[msg.sender] -= _amount;
             balances[_to] += _amount;
             Transfer(msg.sender, _to, _amount);
            return true;
         } else {
             return false;
         }
     }
     
     
     function transferFrom(
         address _from,
         address _to,
         uint256 _amount
     ) returns (bool success) {
         if (balances[_from] >= _amount
             && allowed[_from][msg.sender] >= _amount
             && _amount > 0
             && balances[_to] + _amount > balances[_to]) {
             balances[_from] -= _amount;
             allowed[_from][msg.sender] -= _amount;
             balances[_to] += _amount;
             Transfer(_from, _to, _amount);
             return true;
         } else {
            return false;
         }
     }
 
     function approve(address _spender, uint256 _amount) returns (bool success) {
         allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
         return true;
     }
  
     function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
         return allowed[_owner][_spender];
    }
  }

contract TcashCrowdsale {
    address public founder;
    address public target;
    uint256 public weiRaised;
    uint256 public tokenIssued;
    uint256 public contributors;
    TCASH public tokenReward;
    uint256 public phase = 0;
    bool public halted = false;
    bool crowdsaleClosed = false;

    uint256[10] public priceToken = [
        2600,
        2500,
        2400,
        2300,
        2200,
        2100,
        2000,
        2000,
        2000,
        2000
    ];

    uint256 public constant HARDCAP = 20000 ether;
    uint256 public constant MULTIPLIER = 10 ** 10;

     /*
     * MODIFIERS
     */
     modifier onlyFounder() {
        require(msg.sender == founder);
        _;
     }

    /**
     * Constrctor function
     *
     * Setup the escrow account address, all ethers will be sent to this address.
     *
     *
     * addressOfToken address Of Token Used As Reward
     *
     */
    function TcashCrowdsale (
        address _target,
        address addressOfToken
    ) {
        require(msg.sender != 0x0);
        require(_target != 0x0);
        require(addressOfToken != 0x0);
        target = _target;
        founder = msg.sender;
        tokenReward = TCASH(addressOfToken);
    }

    function safeAdd(uint256 a, uint256 b) internal constant returns (uint256) {
      uint256 c = a + b;
      require(c >= a);
      return c;
    }

    function safeMul(uint256 a, uint256 b) internal constant returns (uint256) {
      uint256 c = a * b;
      require(a == 0 || c / a == b);
      return c;
    }

    function safeDiv(uint256 a, uint256 b) internal constant returns (uint256) {
      // require(b > 0); // Solidity automatically throws when dividing by 0
      uint256 c = a / b;
      // require(a == b * c + a % b); // There is no case in which this doesn't hold
      return c;
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is
     * called whenever anyone sends funds to a contract
     */
    function () payable {
        buyToken(msg.sender);
    }

    function buyToken(address receiver) payable {
        require(!halted);
        require(!crowdsaleClosed);
        require(receiver != 0x0);
        require(receiver != target);
        require(msg.value >= 0.01 ether);
        require(weiRaised <= HARDCAP);
        uint256 weiAmount = msg.value;
        uint256 tokens = computeTokenAmount(weiAmount);
        if (tokenReward.transfer(receiver, tokens)) {
           tokenIssued = safeAdd(tokenIssued, tokens);
        } else {
           revert();
        }
        weiRaised = safeAdd(weiRaised, weiAmount);
        contributors = safeAdd(contributors, 1);
        if (!target.send(weiAmount)) {
           revert();
        }
    }

    function price() constant returns (uint256 tokens) {
        tokens = priceToken[phase];
    }

    function computeTokenAmount(uint256 weiAmount) internal constant returns (uint256 tokens) {
        tokens = safeMul(safeDiv(weiAmount, MULTIPLIER), priceToken[phase]);
    }

    /**
     * Emergency Stop crowdsale.
     *
     */
    function halt() onlyFounder {
        halted = true;
    }

    /**
     * Resume crowdsale.
     *
     */
    function unhalt() onlyFounder {
        halted = false;
    }

    /**
     * set crowdsale phase
     *
     */
    function setPhase(uint256 nPhase) onlyFounder {
        require((nPhase < priceToken.length) && (nPhase >= 0));
        phase = nPhase;
    }

    /**
     * Withdraw unsale Token
     *
     */
    function tokenWithdraw(address receiver, uint256 tokens) onlyFounder {
        require(receiver != 0x0);
        require(tokens > 0);
        if (!tokenReward.transfer(receiver, tokens)) {
           revert();
        }
    }

    /**
     * close Crowdsale
     *
     * Close the crowdsale
     */
    function closeCrowdsale() onlyFounder {
        crowdsaleClosed = true;
    }

}