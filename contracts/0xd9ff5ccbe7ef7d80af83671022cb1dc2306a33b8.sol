pragma solidity ^0.5.0;


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
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
}

interface AddressRegistry {
    function getAddr(string calldata name) external view returns (address);
}

interface MakerCDP {
    function open() external returns (bytes32 cup);
    function join(uint wad) external; // Join PETH
    function give(bytes32 cup, address guy) external;
    function lock(bytes32 cup, uint wad) external;
    function draw(bytes32 cup, uint wad) external;
    function per() external view returns (uint ray);
}

interface PriceInterface {
    function peek() external view returns (bytes32, bool);
}

interface WETHFace {
    function deposit() external payable;
}

interface Swap {
    function dai2eth(uint srcDAI) external returns (uint destETH);
}

interface InstaBank {
    function claimCDP(uint cdpNum) external;
    function transferCDPInternal(uint cdpNum, address nextOwner) external;
}


contract Registry {
    address public addressRegistry;
    modifier onlyAdmin() {
        require(msg.sender == getAddress("admin"), "Permission Denied");
        _;
    }
    function getAddress(string memory name) internal view returns (address) {
        AddressRegistry addrReg = AddressRegistry(addressRegistry);
        return addrReg.getAddr(name);
    }
}


contract GlobalVar is Registry {
    using SafeMath for uint;
    using SafeMath for uint256;

    address public cdpAddr; // SaiTub
    bool public freezed;

    function getETHRate() public view returns (uint) {
        PriceInterface ethRate = PriceInterface(getAddress("ethfeed"));
        bytes32 ethrate;
        (ethrate, ) = ethRate.peek();
        return uint(ethrate);
    }

    function approveERC20() public {
        IERC20 wethTkn = IERC20(getAddress("weth"));
        wethTkn.approve(cdpAddr, 2 ** 256 - 1);
        IERC20 pethTkn = IERC20(getAddress("peth"));
        pethTkn.approve(cdpAddr, 2 ** 256 - 1);
        IERC20 mkrTkn = IERC20(getAddress("mkr"));
        mkrTkn.approve(cdpAddr, 2 ** 256 - 1);
        IERC20 daiTkn = IERC20(getAddress("dai"));
        daiTkn.approve(cdpAddr, 2 ** 256 - 1);
    }

}


contract LoopNewCDP is GlobalVar {
    event LevNewCDP(uint cdpNum, address borrower, uint ethLocked, uint daiMinted);

    function pethPEReth(uint ethNum) public view returns (uint rPETH) {
        MakerCDP loanMaster = MakerCDP(cdpAddr);
        rPETH = (ethNum.mul(10 ** 27)).div(loanMaster.per());
    }

    // useETH = msg.sender + personal ETH used to assist the operation
    function riskNewCDP(uint eth2Lock, uint dai2Mint, bool isCDP2Sender) public payable {
        require(!freezed, "Operation Disabled");

        uint contractETHBal = address(this).balance - msg.value;

        MakerCDP loanMaster = MakerCDP(cdpAddr);
        bytes32 cup = loanMaster.open(); // New CDP

        WETHFace wethTkn = WETHFace(getAddress("weth"));
        wethTkn.deposit.value(eth2Lock)(); // ETH to WETH
        uint pethToLock = pethPEReth(eth2Lock); // PETH : ETH
        loanMaster.join(pethToLock); // WETH to PETH
        loanMaster.lock(cup, pethToLock); // PETH to CDP

        loanMaster.draw(cup, dai2Mint);
        address dai2ethContract = getAddress("dai2eth");
        IERC20 daiTkn = IERC20(getAddress("dai"));
        daiTkn.transfer(dai2ethContract, dai2Mint); // DAI >>> dai2eth
        Swap resolveSwap = Swap(dai2ethContract);
        resolveSwap.dai2eth(dai2Mint); // DAI >>> ETH

        uint nowBal = address(this).balance;
        if (nowBal > contractETHBal) {
            msg.sender.transfer(nowBal - contractETHBal);
        }
        require(contractETHBal == address(this).balance, "No Refund of Contract ETH");

        if (isCDP2Sender) {
            // CDP >>> msg.sender
            loanMaster.give(cup, msg.sender);
        } else {
            // CDP >>> InstaBank
            InstaBank resolveBank = InstaBank(getAddress("bankv2"));
            resolveBank.claimCDP(uint(cup));
            resolveBank.transferCDPInternal(uint(cup), msg.sender);
        }

        emit LevNewCDP(uint(cup), msg.sender, eth2Lock, dai2Mint);
    }

}


contract LeverageCDP is LoopNewCDP {
    constructor(address rAddr) public {
        addressRegistry = rAddr;
        cdpAddr = getAddress("cdp");
        approveERC20();
    }

    function() external payable {}

    function collectETH(uint ethQty) public onlyAdmin {
        msg.sender.transfer(ethQty);
    }

    function freeze(bool stop) public onlyAdmin {
        freezed = stop;
    }

}