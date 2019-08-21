pragma solidity ^0.4.13;

contract token { 
    function transfer(address _to, uint256 _value);
    function balanceOf(address _owner) constant returns (uint256 balance);
}

contract stopScamHolder {
    
    token public sharesTokenAddress;
    address public owner;
    uint public endTime = 1510664400;////10 symbols
    uint256 public tokenFree;

modifier onlyOwner() {
    require(msg.sender == owner);
    _;
}

function stopScamHolder(address _tokenAddress) {
    sharesTokenAddress = token(_tokenAddress);
    owner = msg.sender;
}

function tokensBack() onlyOwner public {
    if(now > endTime){
        sharesTokenAddress.transfer(owner, sharesTokenAddress.balanceOf(this));
    }
    tokenFree = sharesTokenAddress.balanceOf(this);
}	

}