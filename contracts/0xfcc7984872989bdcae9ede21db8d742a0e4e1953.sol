pragma solidity ^0.4.24;

interface IERC20 {
    function balanceOf(address who) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
}

interface AddressRegistry {
    function getAddr(string name) external view returns(address);
}

interface Kyber {
    function trade(
        address src,
        uint srcAmount,
        address dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId
    ) external payable returns (uint);

    function getExpectedRate(
        address src,
        address dest,
        uint srcQty
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


contract Trade is Registry {

    event KyberTrade(
        address src,
        uint srcAmt,
        address dest,
        uint destAmt,
        address beneficiary,
        uint minConversionRate
    );

    function approveDAIKyber() public {
        IERC20 tokenFunctions = IERC20(getAddress("dai"));
        tokenFunctions.approve(getAddress("kyber"), 2**255);
    }

    function expectedETH(uint srcDAI) public view returns (uint, uint) {
        Kyber kyberFunctions = Kyber(getAddress("kyber"));
        return kyberFunctions.getExpectedRate(getAddress("dai"), getAddress("eth"), srcDAI);
    }

    function dai2eth(uint srcDAI) public returns (uint destAmt) {
        address src = getAddress("dai");
        address dest = getAddress("eth");
        uint minConversionRate;
        (, minConversionRate) = expectedETH(srcDAI);

        // Interacting with Kyber Proxy Contract
        Kyber kyberFunctions = Kyber(getAddress("kyber"));
        destAmt = kyberFunctions.trade.value(0)(
            src,
            srcDAI,
            dest,
            msg.sender,
            2**255,
            minConversionRate,
            getAddress("admin")
        );

        emit KyberTrade(
            src, srcDAI, dest, destAmt, msg.sender, minConversionRate
        );

    }

}


contract DAI2ETH is Trade {

    constructor(address rAddr) public {
        addressRegistry = rAddr;
        approveDAIKyber();
    }

    function () public payable {}

}