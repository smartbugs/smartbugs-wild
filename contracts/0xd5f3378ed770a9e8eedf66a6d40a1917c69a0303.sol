pragma solidity ^0.4.25;

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Distribute {
    function multisend(address _tokenAddr, address[] memory _to, uint256[] memory _value) public
    returns (bool _success) {
        assert(_to.length == _value.length);
        assert(_to.length <= 150);
                // loop through to addresses and send value
        for (uint8 i = 0; i < _to.length; i++) {
            assert((ERC20Interface(_tokenAddr).transferFrom(msg.sender, _to[i], _value[i])) == true);
        }
        return true;
    }
}