pragma solidity ^0.5.1;

contract Token {
  function transfer(address to, uint256 value) public returns (bool success);
  function transferFrom(address from, address to, uint256 value) public returns (bool success);
     function balanceOf(address account) external view returns(uint256);
     function allowance(address _owner, address _spender)external view returns(uint256);
}


contract KryptoniexDEX {

    
    address admin;

    constructor(address _admin) public{
    admin = _admin;
    }




    function deposit() public payable returns(bool) {
        require(msg.value > 0);
        return true;
    }

     function withdraw(address payable to,uint256 amount) public payable returns(bool) {
        require(admin==msg.sender);
        require(address(this).balance > 0);
        to.transfer(amount);
        return true;
    }


    function tokenDeposit(address tokenaddr,address fromaddr,uint256 tokenAmount) public returns(bool)
    {
        require(tokenAmount > 0);
        require(tokenallowance(tokenaddr,fromaddr) > 0);
              Token(tokenaddr).transferFrom(fromaddr,address(this), tokenAmount);
              return true;
        
    }
  

    function tokenWithdraw(address tokenAddr,address withdrawaddr, uint256 tokenAmount) public returns(bool)
    {
         require(admin==msg.sender);
         Token(tokenAddr).transfer(withdrawaddr, tokenAmount);
         return true;

    }
    
     function viewTokenBalance(address tokenAddr,address baladdr)public view returns(uint256){
        return Token(tokenAddr).balanceOf(baladdr);
    }
    
    function tokenallowance(address tokenAddr,address owner) public view returns(uint256){
        return Token(tokenAddr).allowance(owner,address(this));
    }
    



}