pragma solidity 0.4.24;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Assertion Failed");
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "Assertion Failed");
        uint256 c = a / b;
        return c;
    }

}

interface IERC20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface AddressRegistry {
    function getAddr(string name) external view returns(address);
}

interface MakerCDP {
    function open() external returns (bytes32 cup);
    function join(uint wad) external; // Join PETH
    function exit(uint wad) external; // Exit PETH
    function give(bytes32 cup, address guy) external;
    function lock(bytes32 cup, uint wad) external;
    function free(bytes32 cup, uint wad) external;
    function draw(bytes32 cup, uint wad) external;
    function wipe(bytes32 cup, uint wad) external;
    function per() external view returns (uint ray);
    function lad(bytes32 cup) external view returns (address);
}

interface PriceInterface {
    function peek() external view returns (bytes32, bool);
}

interface WETHFace {
    function deposit() external payable;
    function withdraw(uint wad) external;
}

interface InstaKyber {
    function executeTrade(
        address src,
        address dest,
        uint srcAmt,
        uint minConversionRate,
        uint maxDestAmt
    ) external payable returns (uint destAmt);

    function getExpectedPrice(
        address src,
        address dest,
        uint srcAmt
    ) external view returns (uint, uint);
}


contract Registry {

    address public addressRegistry;
    modifier onlyAdmin() {
        require(
            msg.sender == getAddress("admin"),
            "Permission Denied"
        );
        _;
    }
    
    function getAddress(string name) internal view returns(address) {
        AddressRegistry addrReg = AddressRegistry(addressRegistry);
        return addrReg.getAddr(name);
    }

}


contract GlobalVar is Registry {

    using SafeMath for uint;
    using SafeMath for uint256;

    bytes32 blankCDP = 0x0000000000000000000000000000000000000000000000000000000000000000;
    address cdpAddr; // cups
    mapping (address => bytes32) cdps; // borrower >>> CDP Bytes
    bool public freezed;

}


contract IssueLoan is GlobalVar {

    event LockedETH(address borrower, uint lockETH, uint lockPETH, address lockedBy);
    event LoanedDAI(address borrower, uint loanDAI, address payTo);
    event NewCDP(address borrower, bytes32 cdpBytes);

    function pethPEReth(uint ethNum) public view returns (uint rPETH) {
        MakerCDP loanMaster = MakerCDP(cdpAddr);
        rPETH = (ethNum.mul(10 ** 27)).div(loanMaster.per());
    }

    function borrow(uint daiDraw, address beneficiary) public payable {
        if (msg.value > 0) {lockETH(msg.sender);}
        if (daiDraw > 0) {drawDAI(daiDraw, beneficiary);}
    }

    function lockETH(address borrower) public payable {
        MakerCDP loanMaster = MakerCDP(cdpAddr);
        if (cdps[borrower] == blankCDP) {
            require(msg.sender == borrower, "Creating CDP for others is not permitted at the moment.");
            cdps[msg.sender] = loanMaster.open();
            emit NewCDP(msg.sender, cdps[msg.sender]);
        }
        WETHFace wethTkn = WETHFace(getAddress("weth"));
        wethTkn.deposit.value(msg.value)(); // ETH to WETH
        uint pethToLock = pethPEReth(msg.value);
        loanMaster.join(pethToLock); // WETH to PETH
        loanMaster.lock(cdps[borrower], pethToLock); // PETH to CDP
        emit LockedETH(
            borrower, msg.value, pethToLock, msg.sender
        );
    }

    function drawDAI(uint daiDraw, address beneficiary) public {
        require(!freezed, "Operation Disabled");
        MakerCDP loanMaster = MakerCDP(cdpAddr);
        loanMaster.draw(cdps[msg.sender], daiDraw);
        IERC20 daiTkn = IERC20(getAddress("dai"));
        address payTo = msg.sender;
        if (payTo != address(0)) {
            payTo = beneficiary;
        }
        daiTkn.transfer(payTo, daiDraw);
        emit LoanedDAI(msg.sender, daiDraw, payTo);
    }

}


contract RepayLoan is IssueLoan {

    event WipedDAI(address borrower, uint daiWipe, uint mkrCharged, address wipedBy);
    event UnlockedETH(address borrower, uint ethFree);

    function repay(uint daiWipe, uint ethFree) public payable {
        if (daiWipe > 0) {wipeDAI(daiWipe, msg.sender);}
        if (ethFree > 0) {unlockETH(ethFree);}
    }

    function wipeDAI(uint daiWipe, address borrower) public payable {
        address dai = getAddress("dai");
        address mkr = getAddress("mkr");
        address eth = getAddress("eth");

        IERC20 daiTkn = IERC20(dai);
        IERC20 mkrTkn = IERC20(mkr);

        uint contractMKR = mkrTkn.balanceOf(address(this)); // contract MKR balance before wiping
        daiTkn.transferFrom(msg.sender, address(this), daiWipe); // get DAI to pay the debt
        MakerCDP loanMaster = MakerCDP(cdpAddr);
        loanMaster.wipe(cdps[borrower], daiWipe); // wipe DAI
        uint mkrCharged = contractMKR - mkrTkn.balanceOf(address(this)); // MKR fee = before wiping bal - after wiping bal

        // claiming paid MKR back
        if (msg.value > 0) { // Interacting with Kyber to swap ETH with MKR
            swapETHMKR(
                eth, mkr, mkrCharged, msg.value
            );
        } else { // take MKR directly from address
            mkrTkn.transferFrom(msg.sender, address(this), mkrCharged); // user paying MKR fees
        }

        emit WipedDAI(
            borrower, daiWipe, mkrCharged, msg.sender
        );
    }

    function unlockETH(uint ethFree) public {
        require(!freezed, "Operation Disabled");
        uint pethToUnlock = pethPEReth(ethFree);
        MakerCDP loanMaster = MakerCDP(cdpAddr);
        loanMaster.free(cdps[msg.sender], pethToUnlock); // CDP to PETH
        loanMaster.exit(pethToUnlock); // PETH to WETH
        WETHFace wethTkn = WETHFace(getAddress("weth"));
        wethTkn.withdraw(ethFree); // WETH to ETH
        msg.sender.transfer(ethFree);
        emit UnlockedETH(msg.sender, ethFree);
    }

    function swapETHMKR(
        address eth,
        address mkr,
        uint mkrCharged,
        uint ethQty
    ) internal 
    {
        InstaKyber instak = InstaKyber(getAddress("InstaKyber"));
        uint minRate;
        (, minRate) = instak.getExpectedPrice(eth, mkr, ethQty);
        uint mkrBought = instak.executeTrade.value(ethQty)(
            eth, mkr, ethQty, minRate, mkrCharged
        );
        require(mkrCharged == mkrBought, "ETH not sufficient to cover the MKR fees.");
        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
    }

}


contract BorrowTasks is RepayLoan {

    event TranferCDP(bytes32 cdp, address owner, address nextOwner);
    event CDPClaimed(bytes32 cdp, address owner);

    function transferCDP(address nextOwner) public {
        require(nextOwner != 0, "Invalid Address.");
        MakerCDP loanMaster = MakerCDP(cdpAddr);
        loanMaster.give(cdps[msg.sender], nextOwner);
        cdps[msg.sender] = blankCDP;
        emit TranferCDP(cdps[msg.sender], msg.sender, nextOwner);
    }

    function claimCDP(uint cdpNum) public {
        bytes32 cdpBytes = bytes32(cdpNum);
        MakerCDP loanMaster = MakerCDP(cdpAddr);
        address cdpOwner = loanMaster.lad(cdpBytes);
        require(cdps[cdpOwner] == blankCDP, "More than 1 CDP is not allowed.");
        cdps[cdpOwner] = cdpBytes;
        emit CDPClaimed(cdpBytes, msg.sender);
    }

    function getETHRate() public view returns (uint) {
        PriceInterface ethRate = PriceInterface(getAddress("ethfeed"));
        bytes32 ethrate;
        (ethrate, ) = ethRate.peek();
        return uint(ethrate);
    }

    function getCDP(address borrower) public view returns (uint, bytes32) {
        return (uint(cdps[borrower]), cdps[borrower]);
    }

    function approveERC20() public {
        IERC20 wethTkn = IERC20(getAddress("weth"));
        wethTkn.approve(cdpAddr, 2**256 - 1);
        IERC20 pethTkn = IERC20(getAddress("peth"));
        pethTkn.approve(cdpAddr, 2**256 - 1);
        IERC20 mkrTkn = IERC20(getAddress("mkr"));
        mkrTkn.approve(cdpAddr, 2**256 - 1);
        IERC20 daiTkn = IERC20(getAddress("dai"));
        daiTkn.approve(cdpAddr, 2**256 - 1);
    }

}


contract InstaMaker is BorrowTasks {

    event MKRCollected(uint amount);

    constructor(address rAddr) public {
        addressRegistry = rAddr;
        cdpAddr = getAddress("cdp");
        approveERC20();
    }

    function () public payable {}

    function freeze(bool stop) public onlyAdmin {
        freezed = stop;
    }

    // collecting MKR token kept as balance to pay fees
    function collectMKR(uint amount) public onlyAdmin {
        IERC20 mkrTkn = IERC20(getAddress("mkr"));
        mkrTkn.transfer(msg.sender, amount);
        emit MKRCollected(amount);
    }

}