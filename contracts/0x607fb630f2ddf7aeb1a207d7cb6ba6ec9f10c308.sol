pragma solidity ^0.4.11;

contract DSNote {
    event LogNote(
    bytes4   indexed  sig,
    address  indexed  guy,
    bytes32  indexed  foo,
    bytes32  indexed  bar,
    uint	 	  wad,
    bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;

        assembly {
        foo := calldataload(4)
        bar := calldataload(36)
        }

        LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}

contract ERC20 {
    function totalSupply() constant returns (uint supply);
    function balanceOf( address who ) constant returns (uint value);
    function allowance( address owner, address spender ) constant returns (uint _allowance);

    function transfer( address to, uint value) returns (bool ok);
    function transferFrom( address from, address to, uint value) returns (bool ok);
    function approve( address spender, uint value ) returns (bool ok);

    event Transfer( address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);
}

contract DSAuthority {
    function canCall(
    address src, address dst, bytes4 sig
    ) constant returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    function DSAuth() {
        owner = msg.sender;
        LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
    auth
    {
        owner = owner_;
        LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
    auth
    {
        authority = authority_;
        LogSetAuthority(authority);
    }

    modifier auth {
        assert(isAuthorized(msg.sender, msg.sig));
        _;
    }

    modifier authorized(bytes4 sig) {
        assert(isAuthorized(msg.sender, sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }

    function assert(bool x) internal {
        if (!x) revert();
    }
}

contract DSExec {
    function tryExec( address target, bytes calldata, uint value)
    internal
    returns (bool call_ret)
    {
        return target.call.value(value)(calldata);
    }
    function exec( address target, bytes calldata, uint value)
    internal
    {
        if(!tryExec(target, calldata, value)) {
            revert();
        }
    }

    // Convenience aliases
    function exec( address t, bytes c )
    internal
    {
        exec(t, c, 0);
    }
    function exec( address t, uint256 v )
    internal
    {
        bytes memory c; exec(t, c, v);
    }
    function tryExec( address t, bytes c )
    internal
    returns (bool)
    {
        return tryExec(t, c, 0);
    }
    function tryExec( address t, uint256 v )
    internal
    returns (bool)
    {
        bytes memory c; return tryExec(t, c, v);
    }
}

contract DSMath {

    /*
    standard uint256 functions
     */

    function add(uint256 x, uint256 y) constant internal returns (uint256 z) {
        assert((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) constant internal returns (uint256 z) {
        assert((z = x - y) <= x);
    }

    function mul(uint256 x, uint256 y) constant internal returns (uint256 z) {
        assert((z = x * y) >= x);
    }

    function div(uint256 x, uint256 y) constant internal returns (uint256 z) {
        z = x / y;
    }

    function min(uint256 x, uint256 y) constant internal returns (uint256 z) {
        return x <= y ? x : y;
    }
    function max(uint256 x, uint256 y) constant internal returns (uint256 z) {
        return x >= y ? x : y;
    }

    /*
    uint128 functions (h is for half)
     */


    function hadd(uint128 x, uint128 y) constant internal returns (uint128 z) {
        assert((z = x + y) >= x);
    }

    function hsub(uint128 x, uint128 y) constant internal returns (uint128 z) {
        assert((z = x - y) <= x);
    }

    function hmul(uint128 x, uint128 y) constant internal returns (uint128 z) {
        assert((z = x * y) >= x);
    }

    function hdiv(uint128 x, uint128 y) constant internal returns (uint128 z) {
        z = x / y;
    }

    function hmin(uint128 x, uint128 y) constant internal returns (uint128 z) {
        return x <= y ? x : y;
    }
    function hmax(uint128 x, uint128 y) constant internal returns (uint128 z) {
        return x >= y ? x : y;
    }


    /*
    int256 functions
     */

    function imin(int256 x, int256 y) constant internal returns (int256 z) {
        return x <= y ? x : y;
    }
    function imax(int256 x, int256 y) constant internal returns (int256 z) {
        return x >= y ? x : y;
    }

    /*
    WAD math
     */

    uint128 constant WAD = 10 ** 18;

    function wadd(uint128 x, uint128 y) constant internal returns (uint128) {
        return hadd(x, y);
    }

    function wsub(uint128 x, uint128 y) constant internal returns (uint128) {
        return hsub(x, y);
    }

    function wmul(uint128 x, uint128 y) constant internal returns (uint128 z) {
        z = cast((uint256(x) * y + WAD / 2) / WAD);
    }

    function wdiv(uint128 x, uint128 y) constant internal returns (uint128 z) {
        z = cast((uint256(x) * WAD + y / 2) / y);
    }

    function wmin(uint128 x, uint128 y) constant internal returns (uint128) {
        return hmin(x, y);
    }
    function wmax(uint128 x, uint128 y) constant internal returns (uint128) {
        return hmax(x, y);
    }

    /*
    RAY math
     */

    uint128 constant RAY = 10 ** 27;

    function radd(uint128 x, uint128 y) constant internal returns (uint128) {
        return hadd(x, y);
    }

    function rsub(uint128 x, uint128 y) constant internal returns (uint128) {
        return hsub(x, y);
    }

    function rmul(uint128 x, uint128 y) constant internal returns (uint128 z) {
        z = cast((uint256(x) * y + RAY / 2) / RAY);
    }

    function rdiv(uint128 x, uint128 y) constant internal returns (uint128 z) {
        z = cast((uint256(x) * RAY + y / 2) / y);
    }

    function rpow(uint128 x, uint64 n) constant internal returns (uint128 z) {
        // This famous algorithm is called "exponentiation by squaring"
        // and calculates x^n with x as fixed-point and n as regular unsigned.
        //
        // It's O(log n), instead of O(n) for naive repeated multiplication.
        //
        // These facts are why it works:
        //
        //  If n is even, then x^n = (x^2)^(n/2).
        //  If n is odd,  then x^n = x * x^(n-1),
        //   and applying the equation for even x gives
        //    x^n = x * (x^2)^((n-1) / 2).
        //
        //  Also, EVM division is flooring and
        //    floor[(n-1) / 2] = floor[n / 2].

        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }

    function rmin(uint128 x, uint128 y) constant internal returns (uint128) {
        return hmin(x, y);
    }
    function rmax(uint128 x, uint128 y) constant internal returns (uint128) {
        return hmax(x, y);
    }

    function cast(uint256 x) constant internal returns (uint128 z) {
        assert((z = uint128(x)) == x);
    }

}

contract DSStop is DSAuth, DSNote {

    bool public stopped;

    modifier stoppable {
        assert (!stopped);
        _;
    }
    function stop() auth note {
        stopped = true;
    }
    function start() auth note {
        stopped = false;
    }

}

contract DSTokenBase is ERC20, DSMath {
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

    function DSTokenBase(uint256 supply) {
        _balances[msg.sender] = supply;
        _supply = supply;
    }

    function totalSupply() constant returns (uint256) {
        return _supply;
    }
    function balanceOf(address src) constant returns (uint256) {
        return _balances[src];
    }
    function allowance(address src, address guy) constant returns (uint256) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) returns (bool) {
        assert(_balances[msg.sender] >= wad);

        _balances[msg.sender] = sub(_balances[msg.sender], wad);
        _balances[dst] = add(_balances[dst], wad);

        Transfer(msg.sender, dst, wad);

        return true;
    }

    function transferFrom(address src, address dst, uint wad) returns (bool) {
        assert(_balances[src] >= wad);
        assert(_approvals[src][msg.sender] >= wad);

        _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint256 wad) returns (bool) {
        _approvals[msg.sender][guy] = wad;

        Approval(msg.sender, guy, wad);

        return true;
    }

}

contract DSToken is DSTokenBase(0), DSStop {

    string  public  symbol;
    uint256  public  decimals = 8; // standard token precision. override to customize

    function DSToken(string symbol_) {
        symbol = symbol_;
    }

    function transfer(address dst, uint wad) stoppable note returns (bool) {
        return super.transfer(dst, wad);
    }
    function transferFrom(
    address src, address dst, uint wad
    ) stoppable note returns (bool) {
        return super.transferFrom(src, dst, wad);
    }
    function approve(address guy, uint wad) stoppable note returns (bool) {
        return super.approve(guy, wad);
    }

    function push(address dst, uint128 wad) returns (bool) {
        return transfer(dst, wad);
    }

    function pull(address src, uint128 wad) returns (bool) {
        return transferFrom(src, msg.sender, wad);
    }

    function mint(uint128 wad) auth stoppable note {
        _balances[msg.sender] = add(_balances[msg.sender], wad);
        _supply = add(_supply, wad);
    }
    function burn(uint128 wad) auth stoppable note {
        _balances[msg.sender] = sub(_balances[msg.sender], wad);
        _supply = sub(_supply, wad);
    }

    // Optional token name

    string public  name = "";

    function setName(string name_) auth {
        name = name_;
    }

}

contract WordCoin is DSToken('Word'){
    address public OfferContract;

    uint public tokenSellCost;
    uint public tokenBuyCost;
    bool public isSellable;
    uint public secondsAfter;
    uint public depositPercents;

    address public ICOContract;
    address public preICOContract;

    struct Deposit {
    uint amount;
    uint time;
    }

    mapping (address => uint) public reservedCoins;
    mapping (address => Deposit) public deposits;

    event LogBounty(address user, uint amount, string message);
    event LogEtherBounty(address user, uint amount, string message);
    event LogSendReward(address from, address to, string message);
    event LogBuyCoins(address user, uint value, string message);
    event LogGetEther(address user, uint value, string message);
    event LogMakeDeposit(address user, uint value, string message);
    event LogGetDeposit(address user, uint value, string message);

    function WordCoin(){
    }


    modifier sellable {
        assert(isSellable);
        _;
    }

    modifier onlyOffer {
        assert(msg.sender == OfferContract);
        _;
    }

    modifier onlypreICO {
        assert(msg.sender == preICOContract);
        _;
    }

    modifier onlyICO {
        assert(msg.sender == ICOContract);
        _;
    }

    function setICO(address ICO) auth {
        ICOContract = ICO;
    }

    function setPreICO(address preICO) auth {
        preICOContract = preICO;
    }

    function preICOmint(uint128 wad) onlypreICO {
        _balances[msg.sender] = add(_balances[msg.sender], wad);
        _supply = add(_supply, wad);
    }


    function ICOmint(uint128 wad) onlyICO {
        _balances[msg.sender] = add(_balances[msg.sender], wad);
        _supply = add(_supply, wad);
    }


    function bounty(address user, uint amount) auth {
        assert(_balances[this] >= amount);

        _balances[user] += amount;
        _balances[this] -= amount;
        LogBounty(user, amount, "Sent bounty");
    }


    function etherBounty(address user, uint amount) auth {
        assert(this.balance >= amount);
        user.transfer(amount);
        LogEtherBounty(user, amount, "Sent ether bounty");
    }


    function sendReward(address from, address to, uint value) onlyOffer {
        reservedCoins[from] -= value;
        _balances[to] += value;
        LogSendReward(from, to, "Sent reward");
    }


    function reserveCoins(address from, uint value) onlyOffer {
        _balances[from] -= value;
        reservedCoins[from] += value;
    }


    function declineCoins(address from, uint value) onlyOffer {
        _balances[from] += value;
        reservedCoins[from] -= value;
    }


    function getEther(uint128 amount) sellable {
        // exchange coins to Ethers with exchange course
        assert(tokenSellCost > 0);
        assert(div(mul(_balances[msg.sender], 10), 100) >= amount);
        super.push(this, amount);
        msg.sender.transfer(amount * tokenSellCost);
        LogGetEther(msg.sender, amount * tokenSellCost, "Got Ether");
    }


    function makeDeposit(uint amount) {
        assert(_balances[msg.sender] > amount);
        assert(deposits[msg.sender].amount == 0);

        deposits[msg.sender].amount = amount;
        deposits[msg.sender].time = now;
        _balances[msg.sender] -= amount;
        _balances[this] += amount;
        LogMakeDeposit(msg.sender, amount, "Made deposit");
    }


    function getDeposit() {
        assert(deposits[msg.sender].amount != 0);
        assert(now > (deposits[msg.sender].time + mul(secondsAfter, 1 seconds)));
        assert(_balances[this] > div(mul(deposits[msg.sender].amount, add(100, depositPercents)), 100));

        uint amount = div(mul(deposits[msg.sender].amount, add(100, depositPercents)), 100);
        deposits[msg.sender].amount = 0;
        _balances[msg.sender]  += amount;
        _balances[this] -= amount;
        LogGetDeposit(msg.sender, amount, "Got deposit");
    }


    function setBuyCourse(uint course) auth {
        isSellable = false;
        tokenBuyCost = course;
    }

    function setSellCourse(uint course) auth {
        isSellable = false;
        tokenSellCost = course;
    }

    function setSellable(bool sellable) auth {
        isSellable = sellable;
    }


    function setOfferContract(address offerContract) auth {
        OfferContract = offerContract;
    }


    function setSecondsAfter(uint secondsForDeposit) auth {
        secondsAfter = secondsForDeposit;
    }


    function setDepositPercents(uint percents) auth {
        depositPercents = percents;
    }


    function takeEther() payable auth {}


    function () payable sellable {
        uint amount = div(msg.value, tokenBuyCost);
        _balances[this] -= amount;
        _balances[msg.sender] += amount;
        LogBuyCoins(msg.sender, amount, "Coins bought");
    }
}

contract preICO is DSAuth, DSExec, DSMath {

    WordCoin  public  coin;
    address public ICO;

    address[] investorsArray;

    struct Investor {
    uint amount;
    uint tokenAmount;
    bool tokenSent;
    bool rewardSent;
    bool largeBonusSent;
    }

    mapping (address => Investor) public investors;

    uint public deadline;
    uint public start;
    uint public countDays;

    bool public autoTokenSent;

    uint public totalDonations;
    uint public totalDonationsWithBonuses;
    uint public donationsCount;
    uint public ethReward;

    uint128 public preICOTokenAmount;
    uint128 public preICOTokenRemaining;

    uint128 public preICOTokenReward;
    uint128 public preICOTokenRewardRemaining;

    event LogBounty(address user, uint128 amount, string result);
    event LogBounty256(address user, uint amount, string result);
    event LogPush(address user, uint128 amount, string result);
    event LogTokenSent(address user, bool amount, string result);

    modifier afterDeadline() {
        assert(now >= deadline);
        _;
    }

    event LogDonation(address user, string message);
    event LogTransferOwnership(address user, string message);
    event LogSendTokens(address user, uint amount, string message);
    event LogSendPOSTokens(address user, uint amount, string message);

    function preICO(uint initCountDays){
        countDays = initCountDays;
        preICOTokenAmount = 200000000000000;
        preICOTokenRemaining = 200000000000000;
        preICOTokenReward = 20000000000000;
        preICOTokenRewardRemaining = 20000000000000;
    }


    function setCoin(WordCoin initCoin) auth {
        assert(preICOTokenAmount > 0);
        start = now;
        deadline = now + countDays * 1 days;
        coin = initCoin;
        coin.preICOmint(uint128(add(uint256(preICOTokenReward),uint256(preICOTokenAmount))));
    }


    function sendTokens() afterDeadline {
        assert(!investors[msg.sender].tokenSent);

        uint amount = div(mul(investors[msg.sender].amount, preICOTokenAmount), uint256(totalDonationsWithBonuses));

        coin.push(msg.sender, uint128(amount));
        preICOTokenRemaining -= uint128(amount);
        investors[msg.sender].tokenSent = true;
        investors[msg.sender].tokenAmount = amount;
        LogSendTokens(msg.sender, amount, "Sent tokens");
    }

    function autoSend() afterDeadline {
        LogDonation(msg.sender, "START");
        assert(!autoTokenSent);
        for (uint i = 0; i < investorsArray.length; i++) {
            LogSendTokens(msg.sender, uint256(totalDonationsWithBonuses), "TOTAL");
            uint amount = div(mul(investors[investorsArray[i]].amount, preICOTokenAmount), uint256(totalDonationsWithBonuses));
            LogSendTokens(msg.sender, amount, "TOTAL");
            if (!investors[investorsArray[i]].tokenSent) {
                coin.push(investorsArray[i], uint128(amount));
                LogSendTokens(msg.sender, amount, "PUSH");
                investors[investorsArray[i]].tokenAmount = amount;
                investors[investorsArray[i]].tokenSent = true;
            }
        }
        autoTokenSent = true;
    }

    function setICOContract(address ico) auth{
        ICO = ico;
    }


    function getEthers(uint amount) auth {
        assert(amount > 0);
        assert(this.balance - amount >= 0);
        assert(msg.sender == owner);
        owner.transfer(amount);
    }


    function getLargeBonus() {
        assert(investors[msg.sender].amount > 7 ether);
        assert(!investors[msg.sender].largeBonusSent);

        uint amount = div(mul(investors[msg.sender].tokenAmount,10),100);
        coin.push(msg.sender, uint128(amount));
        preICOTokenRewardRemaining -= uint128(amount);
        investors[msg.sender].largeBonusSent = true;

        LogSendTokens(msg.sender, amount, "Sent tokens for 7 Eth donate");
    }

    function sendICOTokensBack(uint128 amount) afterDeadline auth{
        assert(coin.balanceOf(this) > amount);
        coin.push(msg.sender, amount);
    }

    function part( address who ) public constant returns (uint part) {
        part = div(mul(investors[who].amount, 1000000), totalDonationsWithBonuses);
    }

    function rewardWasSent (address who) public constant returns (bool wasSent)  {
        wasSent = investors[who].rewardSent;
    }

    function setRewardWasSent (address who) {
        assert(msg.sender == ICO);
        investors[who].rewardSent = true;
    }

    function () payable {
        assert(now <= deadline);
        assert(msg.sender !=  address(0));
        assert(msg.value != 0);
        assert(preICOTokenRemaining > 0);

        uint percents = 0;

        if (sub(now,start) < 24 hours) {
            percents = sub(24, div(sub(now,start), 1 hours));
        }

        uint extraDonation = div(msg.value, 100) * percents;

        investors[msg.sender].tokenSent = false;
        totalDonationsWithBonuses += add(msg.value, extraDonation);
        totalDonations += msg.value;

        investors[msg.sender].amount += add(msg.value, extraDonation);
        donationsCount++;

        investorsArray.push(msg.sender);

        LogDonation(msg.sender, "Donation was made");
    }
}


contract ICO is DSAuth, DSExec, DSMath {
    uint128 public ICOAmount;
    uint128 public ICOReward;

    address[] investorsArray;

    struct preICOInvestor {
    uint amount;
    bool tokenSent;
    bool rewardSent;
    bool largeBonusSent;
    }

    mapping (address => preICOInvestor) public investors;

    preICO public preico;
    WordCoin public coin;
    bool public canGiveMoneyBack;
    bool public rewardSent;
    uint public cost;
    uint public tokenCost;

    bool public isICOStopped;

    uint public totalDonations;

    uint public totalDonationsWithBonuses;

    modifier allowGetMoneyBack() {
        assert(canGiveMoneyBack);
        _;
    }

    modifier ICOStopped() {
        assert(isICOStopped);
        _;
    }

    event LogSetPreICO(preICO preicoAddress, string message);
    event LogStartWeek(string message);
    event LogGetMoneyBack(address user, uint value, string message);
    event LogMoneyToPreICO(address user, uint value, string message);
    event LogBuyTokens(address user, uint value, string message);
    event LogSendPOSTokens(address user, uint value, string message);
    event LogTransferOwnership(address user, string message);
    event Log1(uint128 la, string message);
    event Log2(bool la, string message);

    function ICO(){
        ICOAmount = 500000000000000;
        ICOReward = 10000000000000;
    }

    function setPreICO(preICO initPreICO) auth {
        assert(initPreICO != address(0));
        preico = initPreICO;
    }

    function getEthers(uint amount) auth {
        assert(amount > 0);
        assert(this.balance - amount >= 0);
        assert(msg.sender == owner);
        owner.transfer(amount);
    }

    function startWeekOne() auth {
        assert(preico != address(0));
        tokenCost = div(preico.totalDonations(), preico.preICOTokenAmount());
        cost = 100;
        LogStartWeek("First week started");
    }


    function startWeekTwo() auth {
        cost = 105;
        LogStartWeek("Second week started");
    }

    function startWeekThree() auth {
        cost = 110;
        LogStartWeek("Third week started");
    }


    function startWeekFour() auth {
        cost = 115;
        LogStartWeek("Fourth week started");
    }


    function startWeekFive() auth {
        cost = 120;
        LogStartWeek("Last week started");
    }


    function setCanGetMoneyBack(bool value) auth {
        canGiveMoneyBack = value;
    }


    function setTokenCost(uint newTokenCost) auth {
        assert(newTokenCost > 0);
        tokenCost = newTokenCost;
    }


    function getMoneyBack() allowGetMoneyBack {
        assert(investors[msg.sender].amount > 0);
        msg.sender.transfer(investors[msg.sender].amount);
        investors[msg.sender].amount = 0;
        LogGetMoneyBack(msg.sender, investors[msg.sender].amount, "Money returned");
    }


    function setCoin(WordCoin initCoin) auth {
        assert(ICOAmount > 0);
        coin = initCoin;
        coin.ICOmint(uint128(add(uint256(ICOAmount),uint256(ICOReward))));
    }

    function sendPOSTokens() ICOStopped {
        assert(!investors[msg.sender].rewardSent);
        assert(investors[msg.sender].amount > 0);
        assert(ICOReward > 0);

        uint amount = div(mul(investors[msg.sender].amount, ICOReward), uint256(totalDonations));

        investors[msg.sender].rewardSent = true;

        coin.push(msg.sender, uint128(amount));
        ICOReward -= uint128(amount);
        LogSendPOSTokens(msg.sender, amount, "Sent prize tokens");
    }

    function sendEthForReward() ICOStopped {
        assert(!preico.rewardWasSent(msg.sender));
        uint amount = div(mul(totalDonations, 3), 100);
        uint ethAmountForReward = div(mul(amount,preico.part(msg.sender)), 1000000);
        preico.setRewardWasSent(msg.sender);
        msg.sender.transfer(ethAmountForReward);
    }

    function sendICOTokensBack(uint128 amount) ICOStopped auth{
        assert(coin.balanceOf(this) > amount);
        coin.push(msg.sender, amount);
    }

    function setBigICOStopped(bool stop) auth{
        isICOStopped = stop;
    }

    function() payable {
        assert(msg.sender !=  address(0));
        assert(msg.value != 0);
        assert(cost > 0);
        assert(tokenCost > 0);
        assert(ICOAmount > 0);
        assert(!isICOStopped);

        investors[msg.sender].amount += msg.value;

        totalDonations += msg.value;
        uint amount = div(msg.value, div(mul(tokenCost, cost), 100));
        if (msg.value > 7 ether) {
            amount = div(mul(amount, 110),100);
        }
        coin.push(msg.sender, uint128(amount));
        ICOAmount -= uint128(amount);

        investorsArray.push(msg.sender);

        LogBuyTokens(msg.sender, amount, "Tokens bought");
    }
}