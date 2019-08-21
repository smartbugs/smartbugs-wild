pragma solidity ^0.4.24;

contract ERC20Interface 
{
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address froms, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    mapping(address => mapping(address => uint)) allowed;
}

contract classSend {
    
    address public owner=msg.sender;
    uint amount;
    address sbttokenaddress = 0x503f9794d6a6bb0df8fbb19a2b3e2aeab35339ad;//sbttoken
    address lctokenaddress = 0x32d5a1b48168fdfff42d854d5eb256f914ae5b2d;//lctoken
    address ttttokenaddress = 0x4e1bb58a40f34d8843f61030fe4257c11d09a2c5;//ttttoken
    
    event TransferToken(address);
    
    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
    
    function () external payable {}
    
    function sendairdrop(address[] student) onlyOwner public {
        uint256 i = 0;
        while (i < student.length) {
        sendInternally(student[i]);
        i++;
         }
    }
    
    function sendInternally(address student) onlyOwner internal {
      ERC20Interface(sbttokenaddress).transfer(student, 100*1e18);//token1
      ERC20Interface(lctokenaddress).transfer(student, 80*1e18);//token2
      ERC20Interface(ttttokenaddress).transfer(student, 200*1e18);//token3
      emit TransferToken(student);
    }
    
    function changeowner(address newowner) onlyOwner public{
        owner=newowner;
    }
    
    function transferanyERC20token(address _tokenAddress,uint tokens)public onlyOwner{
    require(msg.sender==owner);
    ERC20Interface(_tokenAddress).transfer(owner, tokens*1e18);
}
 
    function destroy() onlyOwner {
    selfdestruct(owner);
  }
}