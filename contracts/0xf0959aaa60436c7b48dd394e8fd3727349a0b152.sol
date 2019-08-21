pragma solidity ^0.4.11;

contract ERC20 {
    function transfer(address to, uint tokens) public returns (bool success);
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


contract RocketsICO is owned {
    using SafeMath for uint;
    bool public ICOOpening = true;
    uint256 public USD;
    uint256 public ICORate = 1;
    uint256 public ICOBonus = 0;
    address public ROK = 0xca2660F10ec310DF91f3597574634A7E51d717FC;

    function updateUSD(uint256 usd) onlyOwner public {
        USD = usd;
    }

    function updateRate(uint256 rate, uint256 bonus) onlyOwner public {
        ICORate = rate;
        ICOBonus = bonus;
    }

    function updateOpen(bool opening) onlyOwner public{
        ICOOpening = opening;
    }

    constructor() public {
    }

    function() public payable {
        buy();
    }

    function getAmountToBuy(uint256 ethAmount) public view returns (uint256){
        uint256 tokensToBuy;
        tokensToBuy = ethAmount.mul(USD).mul(ICORate);
        if(ICOBonus > 0){
            uint256 bonusAmount;
            bonusAmount = tokensToBuy.div(100).mul(ICOBonus);
            tokensToBuy = tokensToBuy.add(bonusAmount);
        }
        return tokensToBuy;
    }

    function buy() public payable {
        require(ICOOpening == true);
        uint256 tokensToBuy;
        uint256 ethAmount = msg.value;
        tokensToBuy = ethAmount.mul(USD).mul(ICORate);
        if(ICOBonus > 0){
            uint256 bonusAmount;
            bonusAmount = tokensToBuy.div(100).mul(ICOBonus);
            tokensToBuy = tokensToBuy.add(bonusAmount);
        }
        ERC20(ROK).transfer(msg.sender, tokensToBuy);
    }

    function withdrawROK(uint256 amount, address sendTo) onlyOwner public {
        ERC20(ROK).transfer(sendTo, amount);
    }

    function withdrawEther(uint256 amount, address sendTo) onlyOwner public {
        address(sendTo).transfer(amount);
    }

    function withdrawToken(ERC20 token, uint256 amount, address sendTo) onlyOwner public {
        require(token.transfer(sendTo, amount));
    }
}