pragma solidity ^0.4.19;
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
contract HAND{
    using SafeMath for uint256;

    uint256 constant MAX_UINT256 = 2**256 - 1;
    uint256 _initialAmount = 0;
    uint256 public publicToken = 4*10**11;                // 40% of total, for public sale
    uint256 public maxSupply = 10**12;
    address  public contract_owner;
    uint256 public exchangeRate = 3900000;                    // exchangeRate for public sale, token per ETH
    bool public icoOpen = false;                           // whether ICO is open and accept public investment


    address privateSaleAdd = 0x85e4FE33c590b8A5812fBF926a0f9fe64E6d8b35;
    
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    
      
    // lock struct for founder
    struct founderLock {
        uint256 amount;
        uint256 startTime;
        uint remainRound;
        uint totalRound;
        uint256 period;
    }
    
    mapping (address => founderLock) public founderLockance;
    mapping (address => bool) isFreezed;
    

    
    // uint256 totalSupply;
    event Transfer(address indexed _from, address indexed _to, uint256 _value); 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event FounderUnlock(address _sender, uint256 _amount);
            
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    */
    string public name = "ShowHand";               //fancy name: eg Simon Bucks
    uint8 public decimals = 0;                     //How many decimals to show.
    string public symbol = "HAND";                 //An identifier: eg SBX

    /**
      * @dev Fix for the ERC20 short address attack.
      */
      modifier onlyPayloadSize(uint size) {
          require(msg.data.length >= size + 4);
          _;
      }
      modifier  onlyOwner() { 
          require(msg.sender == contract_owner); 
          _; 
      }
      modifier inIco() { 
          require(icoOpen==true); 
          _; 
      }
      
      
    // token distribution, 60% in this part
        address address1 = 0x85e4FE33c590b8A5812fBF926a0f9fe64E6d8b35;
        address address2 = 0x5af6353F2BB222DF6FCD82065ed2e6db1bB12291;
        address address3 = 0x6c24A6EfdfF15230EE284E2E72D86656ac752e48;
        address address4 = 0xCB946d83617eDb6fbCa19148AD83e17Ea7B67294;
        address address5 = 0x76360A75dC6e4bC5c6C0a20A4B74b8823fAFad8C;
        address address6 = 0x356399eE0ebCB6AfB13dF33168fD2CC54Ba219C2;
        address address7 = 0x8b46b43cA5412311A5Dfa08EF1149B5942B5FE22;
        address address8 = 0xA51551B57CB4e37Ea20B3226ceA61ebc7135a11a;
        address address9 = 0x174bC643442bE89265500E6C2c236D32248A4FaE;
        address address10 = 0x0D78E82ECEd57aC3CE65fE3B828f4d52fF712f31;
        address address11 = 0xe31062592358Cd489Bdc09e8217543C8cc3D5C1C;
        address address12 = 0x0DB8c855C4BB0efd5a1c32de2362c5ABCFa4CA33;
        address address13 = 0xF25A3ccDC54A746d56A90197d911d9a1f27cF512;
        address address14 = 0x102d36210d312FB9A9Cf5f5c3A293a8f6598BD50;

        address address15 = 0x8Dd1cDD513b05D07726a6F8C75b57602991a9c34;
        address address16 = 0x9d566BCc1BDda779a00a1D44E0b4cA07FB68EFEF;
        address address17 = 0x1cfCe9A13aBC3381100e85BFA21160C98f8B103D;
        address address18 = 0x61F0c924C0F91f4d17c82C534cfaF716A7893c13;
        address address19 = 0xE76c0618Dd52403ad1907D3BCbF930226bFEa46B;
        address address20 = 0xeF2f04dbd3E3aD126979646383c94Fd29E29de9F;

    function HAND() public {
        // set sender as contract_owner
        contract_owner = msg.sender;
        _initialAmount += publicToken;

        

        setFounderLock(address1, 800*10**8, 4, 180 days);
        setFounderLock(address2, 40*10**8, 4, 180 days);
        setFounderLock(address3, 5*10**8, 4, 180 days);
        setFounderLock(address4, 5*10**8, 4, 180 days);
        setFounderLock(address5, 300*10**8, 4, 180 days);
        setFounderLock(address6, 200*10**8, 4, 180 days);
        setFounderLock(address7, 100*10**8, 4, 180 days);
        setFounderLock(address8, 50*10**8, 4, 180 days);
        setFounderLock(address9, 600*10**8, 4, 180 days);
        setFounderLock(address10, 150*10**8, 4, 180 days);
        setFounderLock(address11, 100*10**8, 4, 180 days);
        setFounderLock(address12, 800*10**8, 4, 180 days);
        setFounderLock(address13, 2400*10**8, 4, 180 days);
        setFounderLock(address14, 100*10**8, 4, 180 days);

        setFounderLock(address15, 135*10**8, 4, 180 days);
        setFounderLock(address16, 25*10**8, 4, 180 days);
        setFounderLock(address17, 20*10**8, 4, 180 days);
        setFounderLock(address18, 40*10**8, 4, 180 days);
        setFounderLock(address19, 20*10**8, 4, 180 days);
        setFounderLock(address20, 110*10**8, 4, 180 days);
    }
    function totalSupply() constant returns (uint256 _totalSupply){
        _totalSupply = _initialAmount;
      }
    function transfer(address _to, uint256 _value) public returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(balances[msg.sender] >= _value);
        require(isFreezed[msg.sender]==false);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
        }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
        }

    function balanceOf(address _owner) view public returns (uint256 balance) {
        return balances[_owner];
        }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(isFreezed[msg.sender]==false);
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
        }

    function allowance(address _owner, address _spender)
    view public returns (uint256 remaining) {
      return allowed[_owner][_spender];
        }

    function multisend(address[] addrs,  uint256 _value)
    {
        uint length = addrs.length;
        require(_value * length <= balances[msg.sender]);
        uint i = 0;
        while (i < length) {
           transfer(addrs[i], _value);
           i ++;
        }
        
      }
    
    
    
    // lock token of founder for periodically release
    // _address: founder address; 
    // _value: totoal locked token; 
    // _round: rounds founder could withdraw; 
    // _period: interval time between two rounds
    function setFounderLock(address _address, uint256 _value, uint _round, uint256 _period)  internal onlyOwner{
        founderLockance[_address].amount = _value;
        founderLockance[_address].startTime = now;
        founderLockance[_address].remainRound = _round;
        founderLockance[_address].totalRound = _round;
        founderLockance[_address].period = _period;
    }
    
    
    // allow locked token to be obtained for founder 
    function unlockFounder () {
        require(now >= founderLockance[msg.sender].startTime + (founderLockance[msg.sender].totalRound - founderLockance[msg.sender].remainRound + 1) * founderLockance[msg.sender].period);
        require(founderLockance[msg.sender].remainRound > 0);
        uint256 changeAmount = founderLockance[msg.sender].amount.div(founderLockance[msg.sender].remainRound);
        balances[msg.sender] += changeAmount;
        founderLockance[msg.sender].amount -= changeAmount;
        _initialAmount += changeAmount;
        founderLockance[msg.sender].remainRound --;
        FounderUnlock(msg.sender, changeAmount);
    }
    
    function freezeAccount (address _target) onlyOwner {
        isFreezed[_target] = true;
    }
    function unfreezeAccount (address _target) onlyOwner {
        isFreezed[_target] = false;
    }
    function ownerUnlock (address _target, uint256 _value) onlyOwner {
        require(founderLockance[_target].amount >= _value);
        founderLockance[_target].amount -= _value;
        balances[_target] += _value;
        _initialAmount += _value;
    }
    
    // starts ICO
    function openIco () onlyOwner{
        icoOpen = true;
      }
    // ends ICO 
    function closeIco () onlyOwner inIco{
        icoOpen = false;
      }

    // transfer all unsold token to bounty balance;
    function weAreClosed () onlyOwner{
        balances[contract_owner] += publicToken;
        transfer(privateSaleAdd, publicToken);
        publicToken = 0;
    }
    // change rate of public sale
    function changeRate (uint256 _rate) onlyOwner{
        exchangeRate = _rate;
    }    
    
    //  withdraw ETH from contract
    function withdraw() onlyOwner{
        contract_owner.transfer(this.balance);
      }
    // fallback function for receive ETH during ICO
    function () payable inIco{
        require(msg.value >= 10**18);
        uint256 tokenChange = (msg.value * exchangeRate).div(10**18);
        require(tokenChange <= publicToken);
        balances[msg.sender] += tokenChange;
        publicToken = publicToken.sub(tokenChange);
      }
}