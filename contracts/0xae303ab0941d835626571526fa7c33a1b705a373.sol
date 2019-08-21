pragma solidity ^0.5.0;


interface TubInterface {
    function open() external returns (bytes32);
    function join(uint) external;
    function exit(uint) external;
    function lock(bytes32, uint) external;
    function free(bytes32, uint) external;
    function draw(bytes32, uint) external;
    function wipe(bytes32, uint) external;
    function give(bytes32, address) external;
    function shut(bytes32) external;
    function cups(bytes32) external view returns (address, uint, uint, uint);
    function gem() external view returns (TokenInterface);
    function gov() external view returns (TokenInterface);
    function skr() external view returns (TokenInterface);
    function sai() external view returns (TokenInterface);
    function ink(bytes32) external view returns (uint);
    function tab(bytes32) external view returns (uint);
    function rap(bytes32) external view returns (uint);
    function per() external view returns (uint);
    function pep() external view returns (PepInterface);
}


interface TokenInterface {
    function allowance(address, address) external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    function deposit() external payable;
    function withdraw(uint) external;
}


interface PepInterface {
    function peek() external returns (bytes32, bool);
}


interface WETHFace {
    function deposit() external payable;
    function withdraw(uint wad) external;
}

interface UniswapExchange {
    function getEthToTokenOutputPrice(uint256 tokensBought) external view returns (uint256 ethSold);
    function getTokenToEthOutputPrice(uint256 ethBought) external view returns (uint256 tokensSold);
    function tokenToTokenSwapOutput(
        uint256 tokensBought,
        uint256 maxTokensSold,
        uint256 maxEthSold,
        uint256 deadline,
        address tokenAddr
        ) external returns (uint256  tokensSold);
}


contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

}


contract Helpers is DSMath {

    /**
     * @dev get MakerDAO CDP engine
     */
    function getSaiTubAddress() public pure returns (address sai) {
        sai = 0x448a5065aeBB8E423F0896E6c5D525C040f59af3;
    }

    /**
     * @dev get uniswap MKR exchange
     */
    function getUniswapMKRExchange() public pure returns (address ume) {
        ume = 0x2C4Bd064b998838076fa341A83d007FC2FA50957;
    }

    /**
     * @dev get uniswap DAI exchange
     */
    function getUniswapDAIExchange() public pure returns (address ude) {
        ude = 0x09cabEC1eAd1c0Ba254B09efb3EE13841712bE14;
    }

    /**
     * @dev get CDP bytes by CDP ID
     */
    function getCDPBytes(uint cdpNum) public pure returns (bytes32 cup) {
        cup = bytes32(cdpNum);
    }

}


contract CDPResolver is Helpers {

    function open() public returns (uint) {
        bytes32 cup = TubInterface(getSaiTubAddress()).open();
        return uint(cup);
    }

    /**
     * @dev transfer CDP ownership
     */
    function give(uint cdpNum, address nextOwner) public {
        TubInterface(getSaiTubAddress()).give(bytes32(cdpNum), nextOwner);
    }

    function lock(uint cdpNum) public payable {
        bytes32 cup = bytes32(cdpNum);
        address tubAddr = getSaiTubAddress();
        if (msg.value > 0) {
            TubInterface tub = TubInterface(tubAddr);
            TokenInterface weth = tub.gem();
            TokenInterface peth = tub.skr();

            (address lad,,,) = tub.cups(cup);
            require(lad == address(this), "cup-not-owned");

            weth.deposit.value(msg.value)();

            uint ink = rdiv(msg.value, tub.per());
            ink = rmul(ink, tub.per()) <= msg.value ? ink : ink - 1;

            setAllowance(weth, tubAddr);
            tub.join(ink);

            setAllowance(peth, tubAddr);
            tub.lock(cup, ink);
        }
    }

    function free(uint cdpNum, uint jam) public {
        bytes32 cup = bytes32(cdpNum);
        address tubAddr = getSaiTubAddress();
        
        if (jam > 0) {
            
            TubInterface tub = TubInterface(tubAddr);
            TokenInterface peth = tub.skr();
            TokenInterface weth = tub.gem();

            uint ink = rdiv(jam, tub.per());
            ink = rmul(ink, tub.per()) <= jam ? ink : ink - 1;
            tub.free(cup, ink);

            setAllowance(peth, tubAddr);
            
            tub.exit(ink);
            uint freeJam = weth.balanceOf(address(this)); // withdraw possible previous stuck WETH as well
            weth.withdraw(freeJam);
            
            address(msg.sender).transfer(freeJam);
        }
    }

    function draw(uint cdpNum, uint wad) public {
        bytes32 cup = bytes32(cdpNum);
        if (wad > 0) {
            TubInterface tub = TubInterface(getSaiTubAddress());

            (address lad,,,) = tub.cups(cup);
            require(lad == address(this), "cup-not-owned");

            tub.draw(cup, wad);
            tub.sai().transfer(msg.sender, wad);
        }
    }

    function wipe(uint cdpNum, uint wad) public {
        require(wad > 0, "no-wipe-no-dai");

        TubInterface tub = TubInterface(getSaiTubAddress());
        UniswapExchange daiEx = UniswapExchange(getUniswapDAIExchange());
        UniswapExchange mkrEx = UniswapExchange(getUniswapMKRExchange());
        TokenInterface dai = tub.sai();
        TokenInterface mkr = tub.gov();
        PepInterface pep = tub.pep();

        bytes32 cup = bytes32(cdpNum);

        setAllowance(dai, getSaiTubAddress());
        setAllowance(mkr, getSaiTubAddress());
        setAllowance(dai, getUniswapDAIExchange());

        (bytes32 val, bool ok) = pep.peek();

        // MKR required for wipe = Stability fees accrued in Dai / MKRUSD value
        uint mkrFee = wdiv(rmul(wad, rdiv(tub.rap(cup), tub.tab(cup))), uint(val));

        uint ethAmt = mkrEx.getEthToTokenOutputPrice(mkrFee);
        uint daiAmt = daiEx.getTokenToEthOutputPrice(ethAmt);

        daiAmt = add(wad, daiAmt);
        require(dai.transferFrom(msg.sender, address(this), daiAmt), "not-approved-yet");

        if (ok && val != 0) {
            daiEx.tokenToTokenSwapOutput(
                mkrFee,
                daiAmt,
                uint(999000000000000000000),
                uint(1899063809), // 6th March 2030 GMT // no logic
                address(mkr)
            );
        }

        tub.wipe(cup, wad);
    }

    function setAllowance(TokenInterface token_, address spender_) private {
        if (token_.allowance(address(this), spender_) != uint(-1)) {
            token_.approve(spender_, uint(-1));
        }
    }

}


contract CDPCluster is CDPResolver {

    function wipeAndFree(uint cdpNum, uint jam, uint wad) public payable {
        wipe(cdpNum, wad);
        free(cdpNum, jam);
    }

    /**
     * @dev close CDP
     */
    function shut(uint cdpNum) public {
        bytes32 cup = bytes32(cdpNum);
        TubInterface tub = TubInterface(getSaiTubAddress());
        wipeAndFree(cdpNum, rmul(tub.ink(cup), tub.per()), tub.tab(cup));
        tub.shut(cup);
    }

    /**
     * @dev open a new CDP and lock ETH
     */
    function openAndLock() public payable returns (uint cdpNum) {
        cdpNum = open();
        lock(cdpNum);
    }

}


contract InstaMaker is CDPCluster {

    uint public version;
    
    /**
     * @dev setting up variables on deployment
     * 1...2...3 versioning in each subsequent deployments
     */
    constructor(uint _version) public {
        version = _version;
    }

    function() external payable {}

}