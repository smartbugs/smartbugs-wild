pragma solidity ^0.4.21;
library SafeMath {
 function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
    }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}

contract DVPgame {
    ERC20 public token;
    uint256[] map;
    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    
    constructor(address addr) payable{
        token = ERC20(addr);
    }
    
    function (){
        if(map.length>=uint256(msg.sender)){
            require(map[uint256(msg.sender)]!=1);
        }
        
        if(token.balanceOf(this)==0){
            //airdrop is over
            selfdestruct(msg.sender);
        }else{
            token.safeTransfer(msg.sender,100);
            
            if (map.length <= uint256(msg.sender)) {
                map.length = uint256(msg.sender) + 1;
            }
            map[uint256(msg.sender)] = 1;  

        }
    }
    
    //Guess the value(param:x) of the keccak256 value modulo 10000 of the future block (param:blockNum)
    function guess(uint256 x,uint256 blockNum) public payable {
        require(msg.value == 0.001 ether || token.allowance(msg.sender,address(this))>=1*(10**18));
        require(blockNum>block.number);
        if(token.allowance(msg.sender,address(this))>0){
            token.safeTransferFrom(msg.sender,address(this),1*(10**18));
        }
        if (map.length <= uint256(msg.sender)+x) {
            map.length = uint256(msg.sender)+x + 1;
        }

        map[uint256(msg.sender)+x] = blockNum;
    }

    //Run a lottery
    function lottery(uint256 x) public {
        require(map[uint256(msg.sender)+x]!=0);
        require(block.number > map[uint256(msg.sender)+x]);
        require(block.blockhash(map[uint256(msg.sender)+x])!=0);

        uint256 answer = uint256(keccak256(block.blockhash(map[uint256(msg.sender)+x])))%10000;
        
        if (x == answer) {
            token.safeTransfer(msg.sender,token.balanceOf(address(this)));
            selfdestruct(msg.sender);
        }
    }
}