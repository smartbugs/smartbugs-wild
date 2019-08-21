pragma solidity ^0.4.11;

contract ERC20 {
    function balanceOf(address tokenOwner) public view returns (uint256);
    function transfer(address to, uint tokens) public;
    function transferFrom(address from, address to, uint256 value) public;
}

contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

library SafeMath {
    function mul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}


contract BitchipWallet is owned{
    address private ETH = 0x0000000000000000000000000000000000000000;
    using SafeMath for uint;
    constructor() public {
    }
    

    function() external payable {
    }

    function withdrawToken(ERC20 token, uint amount, address sendTo) public onlyOwner {
        token.transfer(sendTo, amount);
    }

    function withdrawEther(uint amount, address sendTo) public onlyOwner {
        address(sendTo).transfer(amount);
    }
    function withdraw(address[] _to, address[] _token, uint[] _amount) public onlyOwner{
        for(uint x = 0; x < _amount.length ; ++x){
            require(_amount[x] > 0);
        }
        for(uint i = 0; i < _amount.length ; ++i){
            _withdraw(_token[i], _amount[i], _to[i]);
        }
    }

    function withdrawFrom(address[] _from, address[] _to, address[] _token, uint256[] _amount) public onlyOwner{
        for(uint x = 0; x < _from.length ; ++x){
            require(_amount[x] > 0);
        }
        for(uint i = 0; i < _from.length ; ++i){
            ERC20(_token[i]).transferFrom(_from[i], _to[i], _amount[i]);
        }
    }
    
    function balanceOf(address coin) public view returns (uint balance){
        if (coin == ETH) {
            return address(this).balance;
        }else{
            return ERC20(coin).balanceOf(address(this));
        }
    }

    function _withdraw(address coin, uint amount, address to) internal{
        if (coin == ETH) {
            to.transfer(amount);
        }else{
            ERC20(coin).transfer(to, amount);
        }
    }

}