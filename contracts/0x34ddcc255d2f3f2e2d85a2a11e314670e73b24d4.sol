pragma solidity ^0.4.25;

contract ERC20Interface 
{
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    mapping(address => mapping(address => uint)) allowed;
}

contract lottrygame{
    //base setting
    uint256 public people;
    uint numbers;
    uint256 public tickamount = 100;
    uint256 public winnergetETH1 = 0.05 ether;
    uint256 public winnergetETH2 = 0.03 ether;
    uint256 public winnergetETH3 = 0.02 ether;
    uint public gamecount = 0;
    uint public inputsbt = 100;
    uint  black=1;
    uint  red=2;
    uint  yellow=3;
    
    address[] public tickplayers;
    address public owner;
    address tokenAddress = 0x503F9794d6A6bB0Df8FBb19a2b3e2Aeab35339Ad;//ttt
    address poolwallet;
    
    bool public tickgamelock = true;
    bool public full = true;
    event tickwinner(uint,address,address,address,uint,uint,uint);
    event ticksell(uint gettick,uint paytick);   
    
    modifier ownerOnly() {
    require(msg.sender == owner);
    _;
}
    constructor() public {
        owner = msg.sender;
}
    //function can get ETH
function () external payable ownerOnly{
    tickgamelock=false;
    owner = msg.sender;
    poolwallet = msg.sender;
}
    //change winner can get ETH
function changewinnerget(uint ethamount) public ownerOnly{
    require(ethamount!=0);
    require(msg.sender==owner);
    if(ethamount==1){
    winnergetETH1 = 0.05 ether;
    winnergetETH2 = 0.03 ether;
    winnergetETH3 = 0.02 ether;
    inputsbt = 100;
    }
    else if(ethamount==10){
    winnergetETH1 = 0.12 ether;
    winnergetETH2 = 0.08 ether;
    winnergetETH3 = 0.05 ether;
    inputsbt = 250;
    }
    else if(ethamount==100){
    winnergetETH1 = 1 ether;
    winnergetETH2 = 0.6 ether;
    winnergetETH3 = 0.4 ether;
    inputsbt = 1500;
    }
}
    //change tick amount
function changetickamount(uint256 _tickamount) public ownerOnly{
    require(msg.sender==poolwallet);
    tickamount = _tickamount;
}

    //players joingame
function jointickgame(uint gettick) public {
    require(tickgamelock == false);
    require(gettick<=tickamount&&gettick>0);
    require(gettick<=10&&people<=100);
    if(people<tickamount){
        uint paytick=uint(inputsbt)*1e18*gettick;
        uint i;
        ERC20Interface(tokenAddress).transferFrom(msg.sender,address(this),paytick);
        for (i=0 ;i<gettick;i++){
        tickplayers.push(msg.sender);
        people ++;}
        emit ticksell(gettick,paytick);
    }
    else if (people<=tickamount){
        paytick=uint(inputsbt)*1e18*gettick;
        ERC20Interface(tokenAddress).transferFrom(msg.sender,address(this),paytick);
        for (i=0 ;i<gettick;i++){
        tickplayers.push(msg.sender);
        people ++;}
        emit ticksell(gettick,paytick);
        require(full==false);
        pictickWinner();
    }
}

//===================random====================\\
function changerandom(uint b,uint y,uint r)public ownerOnly{
    require(msg.sender==owner);
    black=b;
    yellow=y;
    red=r;
}
function tickrandom()private view returns(uint) {
    return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp,tickamount+black))); 
}
function tickrandom1()private view returns(uint) {
    return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp,tickamount+yellow)));
}
function tickrandom2()private view returns(uint) {
    return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp,tickamount+red))); 
}
//===============================================\\

    //get winner in players
function pictickWinner()public ownerOnly{
    require(msg.sender==poolwallet);
    require(tickgamelock == false);
    require(people>0);
    uint tickindex = tickrandom() % (tickplayers.length);
    uint tickindex1 = tickrandom1() % (tickplayers.length);
    uint tickindex2 = tickrandom2() % (tickplayers.length);
    address sendwiner = tickplayers[tickindex];
    address sendwiner1 = tickplayers[tickindex1];
    address sendwiner2 = tickplayers[tickindex2];
    address(sendwiner).transfer(winnergetETH1);
    address(sendwiner1).transfer(winnergetETH2);
    address(sendwiner2).transfer(winnergetETH3);
    tickplayers = new address[](0);
    people = 0;
    tickamount = 100;
    gamecount++;
    emit tickwinner(gamecount,sendwiner,sendwiner1,sendwiner2,tickindex,tickindex1,tickindex2);
    
    
}
    //destory game
function killgame()public ownerOnly {
    require(msg.sender==poolwallet);
    selfdestruct(owner);
}
function changefull()public ownerOnly{
    require(msg.sender==poolwallet);
    if(full== true){
        full=false;
    }else if(full==false){
        full=true;
    }
}

    //setgamelock true=lock,false=unlock
function settickgamelock() public ownerOnly{
    require(msg.sender==poolwallet);
       if(tickgamelock == true){
        tickgamelock = false;
       }
       else if(tickgamelock==false){
           tickgamelock =true;
       }
    }
    //transfer contract inside tokens to owner
function transferanyERC20token(address _tokenAddress,uint tokens)public ownerOnly{
    require(msg.sender==poolwallet);
    ERC20Interface(_tokenAddress).transfer(owner, tokens);
}
}