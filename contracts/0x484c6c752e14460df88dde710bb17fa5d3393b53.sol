pragma solidity ^0.4.17;

contract I {
    function transfer(address to, uint256 val) public returns (bool);
    function balanceOf(address who) constant public returns (uint256);
}

contract GenTokenAddress {
    function GenTokenAddress(address token, address to) {
        I(token).transfer(to, I(token).balanceOf(address(this)));
    }
}

contract GenTokens {
    address public owner = msg.sender;
    modifier onlyOwner { require(msg.sender == owner); _; }
    uint public tip = 0.00077 ether;
    
    function create(address token, uint numberOfNewAddresses) payable {
        require(msg.value >= tip); 
        for (uint i = 0; i < numberOfNewAddresses; i++)
            address t = new GenTokenAddress(token, msg.sender);
    }
    
    function() payable { }
    
    function withdraw() onlyOwner { owner.transfer(this.balance); }
    
    function withdrawToken(address token) onlyOwner {
        uint bal = I(token).balanceOf(address(this));
        if (bal > 0) I(token).transfer(owner, bal);
    }
    
    function setTip(uint val) onlyOwner { tip = val; }
    function transferOwner(address to) onlyOwner { owner = to; }
}