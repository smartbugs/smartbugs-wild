pragma solidity ^0.4.24;

contract ERC20 {
    uint public totalSupply;
    function balanceOf(address who) public constant returns (uint);

    function allowance(address owner, address spender) public constant returns (uint);

    function transfer(address to, uint value) public returns (bool ok);

    function transferFrom(address from, address to, uint value) public returns (bool ok);

    function approve(address spender, uint value) public returns (bool ok);

    function mintToken(address to, uint256 value) public returns (uint256);

    function changeTransfer(bool allowed) public;
}

contract SaleCandle {
    address public creator;

    uint256 private totalMinted;

    ERC20 public Candle;
    uint256 public candleCost;

    uint256 public minCost;
    uint256 public maxCost;

    address public FOG;//25%
    address public SUN;//25%
    address public GOD;//40%
    address public APP;//10%

    event Contribution(address from, uint256 amount);

    constructor() public {
        creator = msg.sender;
        totalMinted = 0;
    }

    function changeCreator(address _creator) external {
        require(msg.sender == creator);
        creator = _creator;
    }

    function changeParams(address _candle, uint256 _candleCost, address _fog, address _sun, address _god, address _app) external {
        require(msg.sender == creator);

        Candle = ERC20(_candle);
        candleCost = _candleCost;

        minCost=fromPercentage(_candleCost, 97);
        maxCost=fromPercentage(_candleCost, 103);

        FOG = _fog;
        SUN = _sun;
        GOD = _god;
        APP = _app;
    }

    function getTotalMinted() public constant returns (uint256) {
        require(msg.sender == creator);
        return totalMinted;
    }

    function() public payable {
        require(msg.value > 0);
        require(msg.value >= minCost);

        uint256 forProcess = 0;
        uint256 forReturn = 0;
        if(msg.value>maxCost){
            forProcess = maxCost;
            forReturn = msg.value - maxCost;
        }else{
            forProcess = msg.value;
        }

        totalMinted += 1;

        uint256 forFog = fromPercentage(forProcess, 25);
        uint256 forSun = fromPercentage(forProcess, 25);
        uint256 forGod = fromPercentage(forProcess, 40);
        uint256 forApp = forProcess - (forFog+forSun+forGod);

        APP.transfer(forApp);
        GOD.transfer(forGod);
        SUN.transfer(forSun);
        FOG.transfer(forFog);

        if(forReturn>0){
            msg.sender.transfer(forReturn);
        }

        Candle.mintToken(msg.sender, 1);
        emit Contribution(msg.sender, 1);
    }

    function fromPercentage(uint256 value, uint256 percentage) internal returns (uint256) {
        return (value * percentage) / 100;
    }
}