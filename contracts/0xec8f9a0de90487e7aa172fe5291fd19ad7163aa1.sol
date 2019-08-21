pragma solidity ^0.4.13;

contract token { 
    function transfer(address _to, uint256 _value);
    function balanceOf(address _owner) constant returns (uint256 balance);
}

contract BDSMAirdrop {
    
    token public sharesTokenAddress;
    uint256 public tokenFree = 0;
    address owner;
    uint256 public defValue = 5000000;

modifier onlyOwner() {
    require(msg.sender == owner);
    _;
}
    
function BDSMAirdrop(address _tokenAddress) {
    sharesTokenAddress = token(_tokenAddress);
    owner = msg.sender;
}

function multiSend(address[] _dests) onlyOwner public {
    
    uint256 i = 0;

    while (i < _dests.length) {
        sharesTokenAddress.transfer(_dests[i], defValue);
        i += 1;
    }
    
    tokenFree = sharesTokenAddress.balanceOf(this);
}

function tokensBack() onlyOwner public {    
    sharesTokenAddress.transfer(owner, sharesTokenAddress.balanceOf(this));
    tokenFree = 0;
}	

function changeAirdropValue(uint256 _value) onlyOwner public {
    defValue = _value;
}

}