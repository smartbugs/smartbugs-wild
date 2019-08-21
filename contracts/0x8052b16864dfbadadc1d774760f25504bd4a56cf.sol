pragma solidity 0.4.18;

interface ERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IMaker {
    function sai() public view returns (ERC20);
    function skr() public view returns (ERC20);
    function gem() public view returns (ERC20);

    function open() public returns (bytes32 cup);
    function give(bytes32 cup, address guy) public;

    function ask(uint wad) public view returns (uint);

    function join(uint wad) public;
    function lock(bytes32 cup, uint wad) public;
    function free(bytes32 cup, uint wad) public;
    function draw(bytes32 cup, uint wad) public;
    function cage(uint fit_, uint jam) public;
}

interface IWETH {
    function deposit() public payable;
    function withdraw(uint wad) public;
}


contract DaiMaker {
    IMaker public maker;
    ERC20 public weth;
    ERC20 public peth;
    ERC20 public dai;

    event MakeDai(address indexed daiOwner, address indexed cdpOwner, uint256 ethAmount, uint256 daiAmount);

    function DaiMaker(IMaker _maker) {
        maker = _maker;
        weth = maker.gem();
        peth = maker.skr();
        dai = maker.sai();
    }

    function makeDai(uint256 daiAmount, address cdpOwner, address daiOwner) payable public returns (bytes32 cdpId) {
        IWETH(weth).deposit.value(msg.value)();     // wrap eth in weth token
        weth.approve(maker, msg.value);             // allow maker to pull weth

        maker.join(maker.ask(msg.value));           // convert weth to peth
        uint256 pethAmount = peth.balanceOf(this);
        peth.approve(maker, pethAmount);            // allow maker to pull peth

        cdpId = maker.open();                       // create cdp in maker
        maker.lock(cdpId, pethAmount);              // lock peth into cdp
        maker.draw(cdpId, daiAmount);               // create dai from cdp

        dai.transfer(daiOwner, daiAmount);          // transfer dai to owner
        maker.give(cdpId, cdpOwner);                // transfer cdp to owner

        MakeDai(daiOwner, cdpOwner, msg.value, daiAmount);
    }
}