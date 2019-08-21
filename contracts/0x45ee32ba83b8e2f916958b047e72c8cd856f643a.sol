pragma solidity ^0.5.0;


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


contract IERC20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


contract TubInterface {
    function open() public returns (bytes32);
    function join(uint) public;
    function exit(uint) public;
    function lock(bytes32, uint) public;
    function free(bytes32, uint) public;
    function draw(bytes32, uint) public;
    function wipe(bytes32, uint) public;
    function give(bytes32, address) public;
    function shut(bytes32) public;
    function cups(bytes32) public view returns (address, uint, uint, uint);
    function gem() public view returns (TokenInterface);
    function gov() public view returns (TokenInterface);
    function skr() public view returns (TokenInterface);
    function sai() public view returns (TokenInterface);
    function ink(bytes32) public view returns (uint);
    function tab(bytes32) public view returns (uint);
    function rap(bytes32) public view returns (uint);
    function per() public view returns (uint);
    function pep() public view returns (PepInterface);
}


contract TokenInterface {
    function allowance(address, address) public view returns (uint);
    function balanceOf(address) public view returns (uint);
    function approve(address, uint) public;
    function transfer(address, uint) public returns (bool);
    function transferFrom(address, address, uint) public returns (bool);
    function deposit() public payable;
    function withdraw(uint) public;
}


contract PepInterface {
    function peek() public returns (bytes32, bool);
}


contract WETHFace {
    function deposit() external payable;
    function withdraw(uint wad) external;
}


contract UniswapExchange {
    // Get Prices
    function getEthToTokenInputPrice(uint256 ethSold) external view returns (uint256 tokensBought);
    function getTokenToEthInputPrice(uint256 tokensSold) external view returns (uint256 ethBought);
    // Trade ETH to ERC20
    function ethToTokenSwapOutput(uint256 tokensBought, uint256 deadline) external payable returns (uint256  ethSold);
    // Trade ERC20 to ERC20
    function tokenToExchangeSwapOutput(
        uint256 tokensBought,
        uint256 maxTokensSold,
        uint256 maxEthSold,
        uint256 deadline,
        address exchangeAddr
        ) external returns (uint256  tokensSold);
}


contract Helpers is DSMath {

    /**
     * @dev get MakerDAO CDP engine
     */
    function getPriceFeedAddress() public pure returns (address eth) {
        eth = 0x729D19f657BD0614b4985Cf1D82531c67569197B;
    }

    /**
     * @dev get ETH price feed
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
     * @dev get DAI address
     */
    function getDAIAddress() public pure returns (address ude) {
        ude = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;
    }

    /**
     * @dev get admin address
     */
    function getAddressAdmin() public pure returns (address admin) {
        admin = 0x7284a8451d9a0e7Dc62B3a71C0593eA2eC5c5638;
    }

    /**
     * @dev get onchain ethereum price
     */
    function getRate() public returns (uint) {
        (bytes32 ethrate, ) = PepInterface(getPriceFeedAddress()).peek();
        return uint(ethrate);
    }

    /**
     * @dev get CDP owner by CDP IDs
     */
    function getCDPOwner(uint cdpNum) public view returns (address lad) {
        bytes32 cup = bytes32(cdpNum);
        TubInterface tub = TubInterface(getSaiTubAddress());
        (lad,,,) = tub.cups(cup);
    }

    /**
     * @dev get CDP bytes by CDP ID
     */
    function getCDPBytes(uint cdpNum) public pure returns (bytes32 cup) {
        cup = bytes32(cdpNum);
    }

    /**
     * @dev get stability fees in DAI
     * @param wad is the DAI to wipe
     */
    function getStabilityFees(uint cdpNum, uint wad) public view returns (uint saiDebtFee) {
        bytes32 cup = bytes32(cdpNum);
        TubInterface tub = TubInterface(getSaiTubAddress());
        saiDebtFee = rmul(wad, rdiv(tub.rap(cup), tub.tab(cup)));
    }

    /**
     * @dev get ETH required to buy MKR fees
     * @param feesMKR is the stability fee needs to paid in MKR
     */
    function getETHRequired(uint feesMKR) public view returns (uint reqETH) {
        UniswapExchange mkrExchange = UniswapExchange(getUniswapMKRExchange());
        reqETH = mkrExchange.getTokenToEthInputPrice(feesMKR);
    }

    /**
     * @dev get DAI required to buy MKR fees
     * @param feesMKR is the stability fee needs to paid in MKR
     */
    function getDAIRequired(uint feesMKR) public view returns (uint reqDAI) {
        UniswapExchange mkrExchange = UniswapExchange(getUniswapMKRExchange());
        UniswapExchange daiExchange = UniswapExchange(getUniswapDAIExchange());
        uint ethBought = mkrExchange.getTokenToEthInputPrice(feesMKR);
        reqDAI = daiExchange.getEthToTokenInputPrice(ethBought);
    }

    /**
     * @dev swapping given DAI with MKR
     */
    function swapMKR(TubInterface tub, uint feesMKR) public returns (uint daiSold) {
        address uniDAIDEX = getUniswapDAIExchange();
        UniswapExchange daiExchange = UniswapExchange(uniDAIDEX);
        if (tub.sai().allowance(address(this), uniDAIDEX) != uint(-1)) {
            tub.sai().approve(uniDAIDEX, uint(-1));
        }
        daiSold = daiExchange.tokenToExchangeSwapOutput(
            feesMKR, // total MKR to buy
            2**255, // max DAI to sell
            2**255, // max ETH to sell - http://tinyimg.io/i/2Av1L2j.png
            add(now, 100), // deadline is 100 seconds after this txn gets confirmed (i.e. no deadline)
            getUniswapMKRExchange()
        );
    }

    /**
     * @dev handling stability fees payment
     */
    function handleGovFee(TubInterface tub, uint saiDebtFee) internal {
        address _otc = getUniswapMKRExchange();
        (bytes32 val, bool ok) = tub.pep().peek();
        if (ok && val != 0) {
            uint govAmt = wdiv(saiDebtFee, uint(val)); // Fees in MKR
            uint saiGovAmt = getDAIRequired(govAmt); // get price
            if (tub.sai().allowance(address(this), _otc) != uint(-1)) {
                tub.sai().approve(_otc, uint(-1));
            }
            tub.sai().transferFrom(msg.sender, address(this), saiGovAmt);
            swapMKR(tub, saiGovAmt); // swap DAI with MKR
        }
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

            (address lad,,,) = tub.cups(cup);
            require(lad == address(this), "cup-not-owned");

            tub.gem().deposit.value(msg.value)();

            uint ink = rdiv(msg.value, tub.per());
            ink = rmul(ink, tub.per()) <= msg.value ? ink : ink - 1;

            if (tub.gem().allowance(address(this), tubAddr) != uint(-1)) {
                tub.gem().approve(tubAddr, uint(-1));
            }
            tub.join(ink);

            if (tub.skr().allowance(address(this), tubAddr) != uint(-1)) {
                tub.skr().approve(tubAddr, uint(-1));
            }
            tub.lock(cup, ink);
        }
    }

    function free(uint cdpNum, uint jam) public {
        bytes32 cup = bytes32(cdpNum);
        address tubAddr = getSaiTubAddress();
        if (jam > 0) {
            TubInterface tub = TubInterface(tubAddr);
            uint ink = rdiv(jam, tub.per());
            ink = rmul(ink, tub.per()) <= jam ? ink : ink - 1;
            tub.free(cup, ink);
            if (tub.skr().allowance(address(this), tubAddr) != uint(-1)) {
                tub.skr().approve(tubAddr, uint(-1));
            }
            tub.exit(ink);
            uint freeJam = tub.gem().balanceOf(address(this)); // Withdraw possible previous stuck WETH as well
            tub.gem().withdraw(freeJam);
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
        bytes32 cup = bytes32(cdpNum);
        address tubAddr = getSaiTubAddress();
        if (wad > 0) {
            TubInterface tub = TubInterface(tubAddr);

            tub.sai().transferFrom(msg.sender, address(this), wad);
            handleGovFee(tub, rmul(wad, rdiv(tub.rap(cup), tub.tab(cup))));

            if (tub.sai().allowance(address(this), tubAddr) != uint(-1)) {
                tub.sai().approve(tubAddr, uint(-1));
            }
            if (tub.gov().allowance(address(this), tubAddr) != uint(-1)) {
                tub.gov().approve(tubAddr, uint(-1));
            }
            tub.wipe(cup, wad);
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


contract InstaMaker is CDPResolver {

    uint public version;
    
    /**
     * @dev setting up variables on deployment
     * 1...2...3 versioning in each subsequent deployments
     */
    constructor(uint _version) public {
        version = _version;
    }

}