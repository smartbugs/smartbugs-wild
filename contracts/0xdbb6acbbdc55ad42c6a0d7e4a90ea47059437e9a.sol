pragma solidity ^0.5.6;
pragma experimental ABIEncoderV2;

contract ERC20 {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Structs {
    struct Hmmm {
        uint256 value;
    }

    struct TotalPar {
        uint128 borrow;
        uint128 supply;
    }

    enum ActionType {
        Deposit,   // supply tokens
        Withdraw,  // borrow tokens
        Transfer,  // transfer balance between accounts
        Buy,       // buy an amount of some token (externally)
        Sell,      // sell an amount of some token (externally)
        Trade,     // trade tokens against another account
        Liquidate, // liquidate an undercollateralized or expiring account
        Vaporize,  // use excess tokens to zero-out a completely negative account
        Call       // send arbitrary data to an address
    }

    enum AssetDenomination {
        Wei, // the amount is denominated in wei
        Par  // the amount is denominated in par
    }

    enum AssetReference {
        Delta, // the amount is given as a delta from the current value
        Target // the amount is given as an exact number to end up at
    }

    struct AssetAmount {
        bool sign; // true if positive
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }

    struct ActionArgs {
        ActionType actionType;
        uint256 accountId;
        AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }

    struct Info {
        address owner;  // The address that owns the account
        uint256 number; // A nonce that allows a single address to control many accounts
    }

    struct Wei {
        bool sign; // true if positive
        uint256 value;
    }
}

contract DyDx is Structs {
    function getEarningsRate() public view returns (Hmmm memory);
    function getMarketInterestRate(uint256 marketId) public view returns (Hmmm memory);
    function getMarketTotalPar(uint256 marketId) public view returns (TotalPar memory);
    function getAccountWei(Info memory account, uint256 marketId) public view returns (Wei memory);
    function operate(Info[] memory, ActionArgs[] memory) public;
}

contract Compound {
    struct Market {
        bool isSupported;
        uint blockNumber;
        address interestRateModel;

        uint totalSupply;
        uint supplyRateMantissa;
        uint supplyIndex;

        uint totalBorrows;
        uint borrowRateMantissa;
        uint borrowIndex;
    }

    function supply(address asset, uint amount) public returns (uint);
    function withdraw(address asset, uint requestedAmount) public returns (uint);
    function getSupplyBalance(address account, address asset) view public returns (uint);
    function markets(address) public view returns(Market memory);
    function supplyRatePerBlock() public view returns (uint);
    function mint(uint mintAmount) public returns (uint);
    function redeem(uint redeemTokens) public returns (uint);
    function balanceOf(address account) public view returns (uint);
}

contract Defimanager is Structs {

    uint256 DECIMAL = 10 ** 18;
    // address dydxAddr       = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    // address compoundAddr   = 0x61bbd7Bd5EE2A202d7e62519750170A52A8DFD45;
    // address daiAddr        = 0xC4375B7De8af5a38a93548eb8453a498222C4fF2;
    //0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359; //0x4e17c87c52d0E9a0cAd3Fbc53b77d9514F003807

    // MAINNET ADDRESSES
    address dydxAddr       = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    address compoundAddr   = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;
    address daiAddr        = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;

    // KOVAN ADDRESSES
    // address dydxAddr       = 0x4EC3570cADaAEE08Ae384779B0f3A45EF85289DE;
    // address compoundAddr   = 0xb6b09fBffBa6A5C4631e5F7B2e3Ee183aC259c0d;
    // address daiAddr        = 0xC4375B7De8af5a38a93548eb8453a498222C4fF2;

    uint256 public balancePrev           = 10 ** 18; // at least this much dai must be sent to the contract on creation
    uint256 public benchmarkBalancePrev  = 10 ** 18;

    struct Account {
        uint256 userBalanceLast;
        uint256 benchmarkBalanceLast;
    }

    mapping (address => Account) accounts;

    enum CurrentLender {
        NONE,
        DYDX,
        COMPOUND
    }

    DyDx dydx      = DyDx(dydxAddr);
    Compound comp  = Compound(compoundAddr);
    ERC20 dai      = ERC20(daiAddr);

    CurrentLender public lender;

    function approveDai() public {
        dai.approve(compoundAddr, uint(-1)); //also add to constructor
        dai.approve(dydxAddr, uint(-1));
    }

    function poke() public {
        uint move = which();
        require(move != 999, "Something went wrong finding the best rate");
        if (move == 0 && lender == CurrentLender.DYDX) {
            supplyDyDx(balanceDai());
        } else if (move == 0 && lender == CurrentLender.COMPOUND) {
            compToDyDx();
        } else if (move == 1 && lender == CurrentLender.COMPOUND) {
            supplyComp(balanceDai());
        } else if (move == 1 && lender == CurrentLender.DYDX) {
            dydxToComp();
        }
    }

    function which() public view returns(uint) {
        uint aprDyDx = pokeDyDx();
        uint aprComp = pokeCompound();
        if (aprDyDx > aprComp) return 0;
        if (aprComp > aprDyDx) return 1;
        return 999;
    }

    function dydxToComp() internal {
        withdrawDyDx(balanceDyDx());
        supplyComp(balanceDai());
    }

    function compToDyDx() internal {
        withdrawComp(balanceComp());
        supplyDyDx(balanceDai());
    }

    function pokeDyDx() public view returns(uint256) {
        uint256 rate      = dydx.getMarketInterestRate(1).value;
        uint256 aprBorrow = rate * 31622400;
        uint256 borrow    = dydx.getMarketTotalPar(1).borrow;
        uint256 supply    = dydx.getMarketTotalPar(1).supply;
        uint256 usage     = (borrow * DECIMAL) / supply;
        uint256 apr       = (((aprBorrow * usage) / DECIMAL) * dydx.getEarningsRate().value) / DECIMAL;
        return apr;
    }

    function pokeCompound() public view returns(uint256) {
        uint interestRate = comp.supplyRatePerBlock();
        uint apr          = interestRate * 2108160;
        return apr;
    }

    function balanceDyDx() public view returns(uint256) {
        Wei memory bal = dydx.getAccountWei(Info(address(this), 0), 1);
        return bal.value;
    }

    function balanceComp() public view returns(uint) {
        return comp.balanceOf(address(this));
    }

    function balanceDai() public view returns(uint) {
        return dai.balanceOf(address(this));
    }

    function balanceDaiCurrent() public view returns (uint) {
        if (lender == CurrentLender.COMPOUND) {
            return balanceComp() + balanceDai();
        }
        if (lender == CurrentLender.DYDX) { 
            return balanceDyDx() + balanceDai();
        }
        return balanceDai();
    }

    function supplyDyDx(uint256 amount) public returns(uint) {
        Info[] memory infos = new Info[](1);
        infos[0] = Info(address(this), 0);

        AssetAmount memory amt = AssetAmount(true, AssetDenomination.Wei, AssetReference.Delta, amount);
        ActionArgs memory act;
        act.actionType = ActionType.Deposit;
        act.accountId = 0;
        act.amount = amt;
        act.primaryMarketId = 1;
        act.otherAddress = address(this);

        ActionArgs[] memory args = new ActionArgs[](1);
        args[0] = act;

        dydx.operate(infos, args);

        lender = CurrentLender.DYDX;
    }

    function withdrawDyDx(uint256 amount) public {
        Info[] memory infos = new Info[](1);
        infos[0] = Info(address(this), 0);

        AssetAmount memory amt = AssetAmount(true, AssetDenomination.Wei, AssetReference.Delta, amount);
        ActionArgs memory act;
        act.actionType = ActionType.Withdraw;
        act.accountId = 0;
        act.amount = amt;
        act.primaryMarketId = 1;
        act.otherAddress = address(this);

        ActionArgs[] memory args = new ActionArgs[](1);
        args[0] = act;

        dydx.operate(infos, args);
        // lender = CurrentLender.NONE; - only if amount = entire dydx balance
    }

    function supplyComp(uint amount) public {
        require(comp.mint(amount) == 0, "COMPOUND: mint fail");

        lender = CurrentLender.COMPOUND;
    }

    function withdrawComp(uint amount) public {
        require(comp.redeem(amount) == 0, "COMPOUND: redeem fail");
        // lender = CurrentLender.NONE;
    }

    function initializeNewUser() public {
        accounts[msg.sender].userBalanceLast = 0;
        accounts[msg.sender].benchmarkBalanceLast = (benchmarkBalancePrev * balanceDaiCurrent()) / balancePrev;
    }

    function depositDai(uint amount) public returns(uint) {

        dai.approve(compoundAddr, uint(-1)); //also add to constructor
        dai.approve(dydxAddr, uint(-1));

        //figure out current benchmark account balance
        uint256 benchmarkCurrentBalance = (benchmarkBalancePrev * balanceDaiCurrent()) / balancePrev;
        
        //figure out how much the user actually has right now

        uint256 userCurrentBalance = benchmarkCurrentBalance * accounts[msg.sender].userBalanceLast / accounts[msg.sender].benchmarkBalanceLast;

        //update user's balance to add the amount being deposited
        accounts[msg.sender].userBalanceLast = userCurrentBalance + amount;

        //update the global benchmark balance
        benchmarkBalancePrev = benchmarkCurrentBalance;

        //track the benchmark balance for the user
        accounts[msg.sender].benchmarkBalanceLast = benchmarkCurrentBalance;

        balancePrev = balanceDaiCurrent() + amount;
        require(dai.transferFrom(msg.sender, address(this), amount), 'balance too low');

        if (lender == CurrentLender.DYDX) {
            supplyDyDx(amount);
        }
        if (lender == CurrentLender.COMPOUND) {
            supplyComp(amount);
        }
    }

    function withdrawDai(uint amount) public returns(uint) {
        uint256 benchmarkCurrentBalance = (benchmarkBalancePrev * balanceDaiCurrent()) / balancePrev;
        uint256 userCurrentBalance = benchmarkCurrentBalance * accounts[msg.sender].userBalanceLast / accounts[msg.sender].benchmarkBalanceLast;
        require(amount <= userCurrentBalance, 'cannot withdraw'); 

        accounts[msg.sender].userBalanceLast = userCurrentBalance - amount;
        benchmarkBalancePrev = benchmarkCurrentBalance;
        accounts[msg.sender].benchmarkBalanceLast = benchmarkCurrentBalance;

        balancePrev = balanceDaiCurrent() + amount;

        //do withdrawal
        if (lender == CurrentLender.DYDX) {
            withdrawDyDx(amount);
        }

        if (lender == CurrentLender.COMPOUND) {
            withdrawComp(amount);
        }

        require(dai.transferFrom(address(this), msg.sender, amount), 'transfer failed');

    }

}