pragma solidity ^0.4.16;

contract IERC20Token {
    // these functions aren't abstract since the compiler emits automatically generated getter functions as external
    function name() public constant returns (string);
    function symbol() public constant returns (string);
    function decimals() public constant returns (uint8);
    function totalSupply() public constant returns (uint256);
    function balanceOf(address _owner) public constant returns (uint256);
    function allowance(address _owner, address _spender) public constant returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}

contract BancorConverter {
    function quickConvert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) payable public returns (uint256);
}

contract BancorMarketMaker {
    BancorConverter public constant bancorConverterAddress = BancorConverter(0x578f3c8454F316293DBd31D8C7806050F3B3E2D8);

    IERC20Token public constant dai = IERC20Token(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);
    IERC20Token public constant bancorErc20Eth = IERC20Token(0xc0829421C1d260BD3cB3E0F06cfE2D52db2cE315);
    IERC20Token public constant bancorToken = IERC20Token(0x1F573D6Fb3F13d689FF844B4cE37794d79a7FF1C);
    IERC20Token public constant bancorDaiSmartTokenRelay = IERC20Token(0xee01b3AB5F6728adc137Be101d99c678938E6E72);
    // sell dai price, will be less than normal conversion, _minReturn should be 1/(Dai/Eth price) * .95
    function sellDaiForEth(uint256 _amountDai, uint256 _minReturn) external returns (uint256) {
        require(_amountDai > 0);
        
        IERC20Token(dai).transferFrom(msg.sender, address(this), _amountDai);
        require(IERC20Token(dai).approve(address(bancorConverterAddress), _amountDai));
        
        IERC20Token[] memory daiToEthConversionPath;
        daiToEthConversionPath[0] = dai;
        daiToEthConversionPath[1] = bancorDaiSmartTokenRelay;
        daiToEthConversionPath[2] = bancorDaiSmartTokenRelay;
        daiToEthConversionPath[3] = bancorDaiSmartTokenRelay;
        daiToEthConversionPath[4] = bancorToken;
        daiToEthConversionPath[5] = bancorToken;
        daiToEthConversionPath[6] = bancorErc20Eth;
        bancorConverterAddress.quickConvert(daiToEthConversionPath, _amountDai, _minReturn);
        msg.sender.transfer(this.balance);
        
    }

    // buy dai price, will be more than normal conversion, _minReturn should be 1/(Dai/Eth price) * 1.05
    function buyDaiWithEth(uint256 _minReturn) payable external returns (uint256) {
        require(msg.value > 0);
        IERC20Token[] memory ethToDaiConversionPath;
        ethToDaiConversionPath[0] = bancorErc20Eth;
        ethToDaiConversionPath[1] = bancorToken;
        ethToDaiConversionPath[2] = bancorToken;
        ethToDaiConversionPath[3] = bancorDaiSmartTokenRelay;
        ethToDaiConversionPath[4] = bancorDaiSmartTokenRelay;
        ethToDaiConversionPath[5] = bancorDaiSmartTokenRelay;
        ethToDaiConversionPath[6] = dai;
        bancorConverterAddress.quickConvert.value(msg.value)(ethToDaiConversionPath, msg.value, _minReturn);
        dai.transfer(msg.sender, dai.balanceOf(address(this)));
        
    }
}