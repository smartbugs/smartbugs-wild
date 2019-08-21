pragma solidity ^0.4.15;

library SafeMath {

  function mul(uint a, uint b) internal constant returns (uint) {
    if (a == 0) {
      return 0;
    }
    uint c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint a, uint b) internal constant returns(uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function sub(uint a, uint b) internal constant returns(uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal constant returns(uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20 {
    uint public totalSupply = 0;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    function balanceOf(address _owner) constant returns (uint);
    function transfer(address _to, uint _value) returns (bool);
    function transferFrom(address _from, address _to, uint _value) returns (bool);
    function approve(address _spender, uint _value) returns (bool);
    function allowance(address _owner, address _spender) constant returns (uint);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

} // Functions of ERC20 standard



contract DatariusICO {
    using SafeMath for uint;

    uint public constant Tokens_For_Sale = 146000000*1e18; // Tokens for Sale without bonuses(HardCap)
    uint public constant Total_Amount = 200000000*1e18; // Fixed total supply
    uint public Sold = 0;

    uint CONST_DEL = 1000;

    uint public Tokens_Per_Dollar = 2179;
    uint public Rate_Eth = 446; // Rate USD per ETH
    uint public Token_Price = Tokens_Per_Dollar * Rate_Eth / CONST_DEL; // DAT per ETH

    event LogStartPreICO();
    event LogStartICO();
    event LogPause();
    event LogFinishPreICO();
    event LogFinishICO(address ReserveFund);
    event LogBuyForInvestor(address investor, uint datValue, string txHash);

    DAT public dat = new DAT(this);

    address public Company;
    address public BountyFund;
    address public SupportFund;
    address public ReserveFund;
    address public TeamFund;

    address public Manager; // Manager controls contract
    address public Controller_Address1; // First address that is used to buy tokens for other cryptos
    address public Controller_Address2; // Second address that is used to buy tokens for other cryptos
    address public Controller_Address3; // Third address that is used to buy tokens for other cryptos
    modifier managerOnly { require(msg.sender == Manager); _; }
    modifier controllersOnly {
      require((msg.sender == Controller_Address1) || (msg.sender == Controller_Address2) || (msg.sender == Controller_Address3));
      _;
    }

    uint startTime = 0;
    uint bountyAmount = 4000000*1e18;
    uint supportAmount = 10000000*1e18;
    uint reserveAmount = 24000000*1e18;
    uint teamAmount = 16000000*1e18;

    enum Status {
                  Created,
                  PreIcoStarted,
                  PreIcoFinished,
                  PreIcoPaused,
                  IcoPaused,
                  IcoStarted,
                  IcoFinished
                  }
    Status status = Status.Created;

    function DatariusICO(
                          address _Company,
                          address _BountyFund,
                          address _SupportFund,
                          address _ReserveFund,
                          address _TeamFund,
                          address _Manager,
                          address _Controller_Address1,
                          address _Controller_Address2,
                          address _Controller_Address3
                          ) public {
       Company = _Company;
       BountyFund = _BountyFund;
       SupportFund = _SupportFund;
       ReserveFund = _ReserveFund;
       TeamFund = _TeamFund;
       Manager = _Manager;
       Controller_Address1 = _Controller_Address1;
       Controller_Address2 = _Controller_Address2;
       Controller_Address3 = _Controller_Address3;
    }

// function for changing rate of ETH and price of token


    function setRate(uint _RateEth) external managerOnly {
       Rate_Eth = _RateEth;
       Token_Price = Tokens_Per_Dollar*Rate_Eth/CONST_DEL;
    }


//ICO status functions

    function startPreIco() external managerOnly {
       require(status == Status.Created || status == Status.PreIcoPaused);
       if(status == Status.Created) {
           dat.mint(BountyFund, bountyAmount);
           dat.mint(SupportFund, supportAmount);
           dat.mint(ReserveFund, reserveAmount);
           dat.mint(TeamFund, teamAmount);
       }
       status = Status.PreIcoStarted;
       LogStartPreICO();
    }

    function finishPreIco() external managerOnly { // Funds for minting of tokens
       require(status == Status.PreIcoStarted || status == Status.PreIcoPaused);

       status = Status.PreIcoFinished;
       LogFinishPreICO();
    }


    function startIco() external managerOnly {
       require(status == Status.PreIcoFinished || status == Status.IcoPaused);
       if(status == Status.PreIcoFinished) {
         startTime = now;
       }
       status = Status.IcoStarted;
       LogStartICO();
    }

    function finishIco() external managerOnly { // Funds for minting of tokens

       require(status == Status.IcoStarted || status == Status.IcoPaused);

       uint alreadyMinted = dat.totalSupply(); //=PublicICO+PrivateOffer

       dat.mint(ReserveFund, Total_Amount.sub(alreadyMinted)); //

       dat.defrost();

       status = Status.IcoFinished;
       LogFinishICO(ReserveFund);
    }

    function pauseIco() external managerOnly {
       require(status == Status.IcoStarted);
       status = Status.IcoPaused;
       LogPause();
    }
    function pausePreIco() external managerOnly {
       require(status == Status.PreIcoStarted);
       status = Status.PreIcoPaused;
       LogPause();
    }

// function that buys tokens when investor sends ETH to address of ICO
    function() external payable {

       buy(msg.sender, msg.value * Token_Price);
    }

// function for buying tokens to investors who paid in other cryptos

    function buyForInvestor(address _investor, uint _datValue, string _txHash) external controllersOnly {
       buy(_investor, _datValue);
       LogBuyForInvestor(_investor, _datValue, _txHash);
    }

// internal function for buying tokens

    function buy(address _investor, uint _datValue) internal {
       require((status == Status.PreIcoStarted) || (status == Status.IcoStarted));
       require(_datValue > 0);

       uint bonus = getBonus(_datValue);

       uint total = _datValue.add(bonus);

       require(Sold + total <= Tokens_For_Sale);
       dat.mint(_investor, total);
       Sold = Sold.add(_datValue);
    }

// function that calculates bonus
    function getBonus(uint _value) public constant returns (uint) {
       uint bonus = 0;
       uint time = now;
       if(status == Status.PreIcoStarted) {
            bonus = _value.mul(35).div(100);
            return bonus;
       } else {
            if(time <= startTime + 6 hours)
            {

                  bonus = _value.mul(30).div(100);
                  return bonus;
            }

            if(time <= startTime + 12 hours)
            {
                  bonus = _value.mul(25).div(100);
                  return bonus;
            }

            if(time <= startTime + 24 hours)
            {

                  bonus = _value.mul(20).div(100);
                  return bonus;
            }

            if(time <= startTime + 48 hours)
            {

                  bonus = _value.mul(10).div(100);
                  return bonus;
            }
       }
       return bonus;
    }

//function to withdraw ETH from smart contract

    function withdrawEther(uint256 _value) external managerOnly {
       require((status == Status.PreIcoFinished) || (status == Status.IcoFinished));
       Company.transfer(_value);
    }

}

contract DAT  is ERC20 {
    using SafeMath for uint;

    string public name = "Datarius Token";
    string public symbol = "DAT";
    uint public decimals = 18;

    address public ico;

    event Burn(address indexed from, uint256 value);

    bool public tokensAreFrozen = true;

    modifier icoOnly { require(msg.sender == ico); _; }

    function DAT(address _ico) public {
       ico = _ico;
    }


    function mint(address _holder, uint _value) external icoOnly {
       require(_value > 0);
       balances[_holder] = balances[_holder].add(_value);
       totalSupply = totalSupply.add(_value);
       Transfer(0x0, _holder, _value);
    }


    function defrost() external icoOnly {
       tokensAreFrozen = false;
    }

    function burn(uint256 _value) {
       require(!tokensAreFrozen);
       balances[msg.sender] = balances[msg.sender].sub(_value);
       totalSupply = totalSupply.sub(_value);
       Burn(msg.sender, _value);
    }


    function balanceOf(address _owner) constant returns (uint256) {
         return balances[_owner];
    }


    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(!tokensAreFrozen);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        require(!tokensAreFrozen);
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(_from, _to, _amount);
        return true;
     }


    function approve(address _spender, uint256 _amount) public returns (bool) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }


    function allowance(address _owner, address _spender) constant returns (uint256) {
        return allowed[_owner][_spender];
    }
}