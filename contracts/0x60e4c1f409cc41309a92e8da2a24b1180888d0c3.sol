pragma solidity ^0.4.16;


contract ERC20Token {
    function transferFrom(address, address, uint256) public returns (bool);
}

contract YMtest_airdrop{
function transfer(address _token, address[] _dsts, uint256[] _values) 
    public
    payable
{
    ERC20Token token = ERC20Token(_token);
    for (uint256 i = 0; i < _dsts.length; i++) {
        token.transferFrom(msg.sender, _dsts[i], _values[i]);
    }
}

}