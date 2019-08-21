pragma solidity ^0.5.0;


interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
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


contract KyberSwap {

    address public kyberAddress;
    address public daiAddress;
    address public ethAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public admin;
    uint public fees;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Permission Denied");
        _;
    }

    function getExpectedPrice(
        address src,
        address dest,
        uint srcAmt
    ) public view returns (uint, uint)
    {
        Kyber kyberFunctions = Kyber(kyberAddress);
        return kyberFunctions.getExpectedRate(
            src,
            dest,
            srcAmt
        );
    }

}


contract PayModel is KyberSwap {

    event Paid(address payer, address receiver, uint amount, address token);

    function payETH(
        uint daiToPay, // max amount of dest token
        address payTo
    ) public payable returns (uint destAmt)
    {
        Kyber kyberFunctions = Kyber(kyberAddress); // Interacting with Kyber Proxy Contract

        uint minConversionRate;
        (, minConversionRate) = kyberFunctions.getExpectedRate(
            ethAddress,
            daiAddress,
            msg.value
        );
        
        destAmt = kyberFunctions.trade.value(msg.value)(
            ethAddress, // src is ETH
            msg.value, // srcAmt
            daiAddress, // dest is DAI
            address(this), // destAmt receiver
            daiToPay, // max destAmt
            minConversionRate, // min accepted conversion rate
            admin // affiliate
        );
        require(daiToPay == destAmt, "Can't pay less.");

        IERC20 daiToken = IERC20(daiAddress);
        daiToken.transfer(payTo, daiToPay * fees / 1000);
        
        // maxDestAmt usecase implementated (only works with ETH)
        msg.sender.transfer(address(this).balance);

        emit Paid(
            msg.sender, payTo, daiToPay, ethAddress
        );
    }

    function payDAI(address payTo, uint daiToPay) public {
        IERC20 daiToken = IERC20(daiAddress);
        daiToken.transferFrom(msg.sender, payTo, daiToPay * fees / 1000);
        emit Paid(
            msg.sender, payTo, daiToPay, daiAddress
        );
    }

}


contract PayDApp is PayModel {

    constructor(address proxyAddr, address daiAddr) public {
        kyberAddress = proxyAddr;
        daiAddress = daiAddr;
        admin = msg.sender;
        fees = 995;
    }

    function () external payable {}

    function setFees(uint newFee) public onlyAdmin {
        fees = newFee;
    }

    function collectFees(uint amount) public onlyAdmin {
        IERC20 daiToken = IERC20(daiAddress);
        daiToken.transfer(admin, amount);
    }

    function setAdmin(address newAdmin) public onlyAdmin {
        admin = newAdmin;
    }

}