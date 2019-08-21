pragma solidity ^ 0.4.21;

/**
 *   @title SafeMath
 *   @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


/**
 *   @title ERC20
 *   @dev Standart ERC20 token interface
 */
contract ERC20 {
    function balanceOf(address _owner) public constant returns(uint256);
    function transfer(address _to, uint256 _value) public returns(bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool);
    function approve(address _spender, uint256 _value) public returns(bool);
    function allowance(address _owner, address _spender) public constant returns(uint256);
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/**
 *   @dev CRET token contract
 */
contract WbcToken is ERC20 {
    using SafeMath for uint256;
    string public name = "WhizBizCoin";
    string public symbol = "WB";
    uint256 public decimals = 18;
    uint256 public totalSupply = 888000000 * 1e18;
    uint256 public timeStamp = 0;
    uint256 constant fundPartYear = 44400000 * 1e18; 
    uint256 constant trioPartYear = 8880000 * 1e18; //1% of tokens for CrowdSale, Film Comany and Investors in one year for 6 years
    uint256 constant minimumAge = 30 days; // minimum age for coins
    uint256 constant oneYear = 360 days;
    uint256 public minted = 0;
    address public teamCSN;
    address public teamFilmCompany;
    address public teamInvestors;
    address public teamFund;
    address public manager;
    address public reserveFund;
    
    struct transferStruct{
    uint128 amount;
    uint64 time;
    }
    
    mapping(uint8 => bool) trioChecker;
    mapping(uint8 => bool) fundChecker;
    mapping(uint256 => bool) priceChecker;
    mapping(address => transferStruct[]) transferSt;
    mapping(uint256 => uint256) coinPriceNow;

    // Ico contract address
    address public owner;

    // Allows execution by the owner only
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyManager {
        require(msg.sender == manager);
        _;
    }
    
    
    
    constructor (address _owner, address _teamCSN, address _teamFilmCompany, address _teamInvestors, address _fund, address _manager, address _reserveFund) public {
        owner = _owner;
        teamCSN = _teamCSN;
        teamFilmCompany = _teamFilmCompany;
        teamInvestors = _teamInvestors;
        teamFund = _fund;
        manager = _manager;
        reserveFund = _reserveFund;

    }
    
    
    function doTimeStamp(uint256 _value) external onlyOwner {
        timeStamp = _value;
    }
    
    

   /**
    *   @dev Mint tokens
    *   @param _investor     address the tokens will be issued to
    *   @param _value        number of tokens
    */
    function mintTokens(address _investor, uint256 _value) external onlyOwner {
        require(_value > 0);
        require(minted.add(_value) <= totalSupply);
        balances[_investor] = balances[_investor].add(_value);
        minted = minted.add(_value);
        transferSt[_investor].push(transferStruct(uint128(_value),uint64(now)));
        emit Transfer(0x0, _investor, _value);
    }
    
    
    
    function mintTrio() external onlyManager {
        require(now > (timeStamp + 360 days));
        if(now > (timeStamp + 360 days) && now <= (timeStamp + 720 days)){
            require(trioChecker[1] != true);
            partingTrio(1);
        }
        if(now > (timeStamp + 720 days) && now <= (timeStamp + 1080 days)){
            require(trioChecker[2] != true);
            partingTrio(2);
        }
        if(now > (timeStamp + 1080 days) && now <= (timeStamp + 1440 days)){
            require(trioChecker[3] != true);
            partingTrio(3);
        }
        if(now > (timeStamp + 1440 days) && now <= (timeStamp + 1800 days)){
            require(trioChecker[4] != true);
            partingTrio(4);
        }
        if(now > (timeStamp + 1800 days) && now <= (timeStamp + 2160 days)){
            require(trioChecker[5] != true);
            partingTrio(5);
        }
        if(now > (timeStamp + 2160 days) && now <= (timeStamp + 2520 days)){
            require(trioChecker[6] != true);
            partingTrio(6);
        }
    }
    
    
    function mintFund() external onlyManager {
        require(now > (timeStamp + 360 days));
        if(now > (timeStamp + 360 days) && now <= (timeStamp + 720 days)){
            require(fundChecker[1] != true);
            partingFund(1);
        }
        if(now > (timeStamp + 720 days) && now <= (timeStamp + 1080 days)){
            require(fundChecker[2] != true);
            partingFund(2);
        }
        if(now > (timeStamp + 1080 days) && now <= (timeStamp + 1440 days)){
            require(fundChecker[3] != true);
            partingFund(3);
        }
        if(now > (timeStamp + 1440 days) && now <= (timeStamp + 1800 days)){
            require(fundChecker[4] != true);
            partingFund(4);
        }
        if(now > (timeStamp + 1800 days) && now <= (timeStamp + 2160 days)){
            require(fundChecker[5] != true);
            partingFund(5);
        }
        if(now > (timeStamp + 2160 days) && now <= (timeStamp + 2520 days)){
            require(fundChecker[6] != true);
            partingFund(6);
        }
        if(now > (timeStamp + 2520 days) && now <= (timeStamp + 2880 days)){
            require(fundChecker[7] != true);
            partingFund(7);
        }
    
    }
    
    
    function partingFund(uint8 _x) internal {
        require(_x > 0 && _x <= 7);
        balances[teamFund] = balances[teamFund].add(fundPartYear);
        fundChecker[_x] = true;
        minted = minted.add(fundPartYear);
        transferSt[teamFund].push(transferStruct(uint128(fundPartYear),uint64(now)));
            
        emit Transfer(0x0, teamFund, fundPartYear);
    }
    
    
    function partingTrio(uint8 _x) internal {
        require(_x > 0 && _x <= 6);
        balances[teamCSN] = balances[teamCSN].add(trioPartYear);
        balances[teamFilmCompany] = balances[teamFilmCompany].add(trioPartYear);
        balances[teamInvestors] = balances[teamInvestors].add(trioPartYear);
        trioChecker[_x] = true;
        minted = minted.add(trioPartYear.mul(3));
        transferSt[teamCSN].push(transferStruct(uint128(trioPartYear),uint64(now)));
        transferSt[teamFilmCompany].push(transferStruct(uint128(trioPartYear),uint64(now)));
        transferSt[teamInvestors].push(transferStruct(uint128(trioPartYear),uint64(now)));
            
        emit Transfer(0x0, teamCSN, trioPartYear);
        emit Transfer(0x0, teamFilmCompany, trioPartYear);
        emit Transfer(0x0, teamInvestors, trioPartYear);
    }


   /**
    *   @dev Get balance of investor
    *   @param _owner        investor's address
    *   @return              balance of investor
    */
    function balanceOf(address _owner) public constant returns(uint256) {
      return balances[_owner];
    }

   /**
    *   @return true if the transfer was successful
    */
    function transfer(address _to, uint256 _amount) public returns(bool) {
        if(msg.sender == _to) {return POSMint();}
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        if(transferSt[msg.sender].length > 0) {delete transferSt[msg.sender];}
        uint64 _now = uint64(now);
        transferSt[msg.sender].push(transferStruct(uint128(balances[msg.sender]),_now));
        transferSt[_to].push(transferStruct(uint128(_amount),_now));
        return true;
    }

   /**
    *   @return true if the transfer was successful
    */
    function transferFrom(address _from, address _to, uint256 _amount) public returns(bool) {
        require(_amount <= allowed[_from][msg.sender]);
        require(_amount <= balances[_from]);
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
        if(transferSt[_from].length > 0) {delete transferSt[_from];}
        uint64 _now = uint64(now);
        transferSt[_from].push(transferStruct(uint128(balances[_from]),_now));
        transferSt[_to].push(transferStruct(uint128(_amount),_now));
        return true;
    }
    
    
    function POSMint() internal returns (bool) {
        require(now > (timeStamp + minimumAge));
        if(balances[msg.sender] <= 0) {return false;}
        if(transferSt[msg.sender].length <= 0) {return false;}

        uint256 _now = now;
        uint256 _year = getYear();
        uint256 _phase = getPhase(_year);
        uint256 _coinsAmount = getCoinsAmount(msg.sender, _now);
        if(_coinsAmount <= 0) {return false;}
        uint256 _coinsPrice = getCoinPrice(_year, _phase);
        if(_coinsPrice <= 0) {return false;}
        uint256 reward = (_coinsAmount.mul(_coinsPrice)).div(100000);
        if(reward <= 0) {return false;}
        if(reward > 0) {require(minted.add(reward) <= totalSupply);}
        minted = minted.add(reward);
        balances[msg.sender] = balances[msg.sender].add(reward);
        delete transferSt[msg.sender];
        transferSt[msg.sender].push(transferStruct(uint128(balances[msg.sender]),uint64(now)));

        emit Transfer(0x0, msg.sender, reward);
        return true;
    }
    
    
    function getCoinsAmount(address _address, uint _now) internal view returns (uint256) {
        if(transferSt[_address].length <= 0) {return 0;}
        uint256 Coins = 0;
        for (uint256 i = 0; i < transferSt[_address].length; i++){
            if( _now < uint(transferSt[_address][i].time).add(minimumAge) ) {return Coins;}
            Coins = Coins.add(uint256(transferSt[_address][i].amount));
        }
        return Coins;
    }
    
    
    function getYear() internal view returns (uint256) {
        require(timeStamp > 0);
        for(uint256 i = 0; i <= 99; i++) {
        if(now >= ((timeStamp + minimumAge).add((i.mul(oneYear)))) && now < ((timeStamp + minimumAge).add(((i+1).mul(oneYear))))) {
            return (i);    // how many years gone
            }
        }
        if(now >= ((timeStamp + minimumAge).add((oneYear.mul(100))))) {return (100);}
    
    }


    function getPhase(uint256 _x) internal pure returns (uint256) {
        require(_x >= 0);
        if(_x >= 0 && _x < 3) {return 1;}
        if(_x >= 3 && _x < 6) {return 2;}
        if(_x >= 6 && _x < 9) {return 3;}
        if(_x >= 9 && _x < 12) {return 4;}
        if(_x >= 12) {return 5;}        // last phase which include 18*3 years
    
    }
    
    
    function getMonthLimit(uint256 _x) internal pure returns (uint256) {
        require(_x > 0 && _x <=5);
        if(_x == 1) {return (2220000 * 1e18);} //limit in month in this phase for all
        if(_x == 2) {return (1480000 * 1e18);}
        if(_x == 3) {return (740000 * 1e18);}
        if(_x == 4) {return (370000 * 1e18);}
        if(_x == 5) {return (185000 * 1e18);}
    }
    
 

    
    function getCoinPrice(uint256 _year, uint256 _phase) internal returns (uint256) {
    require(_year >= 0);
    uint256 _monthLimit = getMonthLimit(_phase);
    uint256 _sumToAdd = _year.mul(oneYear);
    uint256 _monthInYear = _year.mul(12);

    for(uint256 i = 0; i <= 11; i++) {
    if(now >= (timeStamp + minimumAge).add(_sumToAdd).add(minimumAge.mul(i)) && now < (timeStamp + minimumAge).add(_sumToAdd).add(minimumAge.mul(i+1))) {
        uint256 _num = _monthInYear.add(i);
        if(priceChecker[_num] != true) {
            coinPriceNow[_num] = minted;
            priceChecker[_num] = true;
            return (_monthLimit.mul(100000)).div(minted);} 
        if(priceChecker[_num] == true) {
            return (_monthLimit.mul(100000)).div(coinPriceNow[_num]);}
    }
    }
}

   /**
    *   @dev Allows another account/contract to spend some tokens on its behalf
    * approve has to be called twice in 2 separate transactions - once to
    *   change the allowance to 0 and secondly to change it to the new allowance value
    *   @param _spender      approved address
    *   @param _amount       allowance amount
    *
    *   @return true if the approval was successful
    */
    function approve(address _spender, uint256 _amount) public returns(bool) {
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

   /**
    *   @dev Function to check the amount of tokens that an owner allowed to a spender.
    *
    *   @param _owner        the address which owns the funds
    *   @param _spender      the address which will spend the funds
    *
    *   @return              the amount of tokens still avaible for the spender
    */
    function allowance(address _owner, address _spender) public constant returns(uint256) {
        return allowed[_owner][_spender];
    }
}