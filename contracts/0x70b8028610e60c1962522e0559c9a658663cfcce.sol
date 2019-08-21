pragma solidity ^0.4.25;

contract Olympus {
    using SafeMath for uint;
    
    address private constant supportAddress = 0x0bD47808d4A09aD155b00C39dBb101Fb71e1C0f0;
    uint private constant supportPercent = 1;
    
    mapping(address => uint) private shares;
    uint private totalShares;
    uint private totalPersons;
    
    function getBalance(address _account) public constant returns (uint) {
        if (totalShares == 0)
            return 0;
        uint contractBalance = address(this).balance;
        uint profitPercent = calculateProfitPercent(contractBalance, totalPersons);
        return contractBalance.mul(shares[_account]).mul(profitPercent).div(totalShares).div(100);
    }
    
    function() public payable {
        address sender = msg.sender;
        uint amount = msg.value;
        if (amount > 0) {
            if (totalPersons > 10)
                supportAddress.transfer(calculateSupportPercent(amount));
            if (totalShares > 0)
                amount = amount.mul(totalShares).div(address(this).balance.sub(amount));
            if (shares[sender] == 0)
                totalPersons++;
            shares[sender] = shares[sender].add(amount);
            totalShares = totalShares.add(amount);
        } else {
            amount = getBalance(sender);
            totalShares = totalShares.sub(shares[sender]);
            shares[sender] = 0;
            totalPersons--;
            uint percent = calculateSupportPercent(amount);
            supportAddress.transfer(percent);
            sender.transfer(amount - percent);
            if (totalPersons == 0)
                supportAddress.transfer(address(this).balance);
        }
    }
    
    function calculateProfitPercent(uint _balance, uint _totalPersons) private pure returns (uint) {
        if (_balance >= 8e20 || _totalPersons == 1) // 800 ETH
            return 95;
        else if (_balance >= 4e20) // 400 ETH
            return 94;
        else if (_balance >= 2e20) // 200 ETH
            return 93;
        else if (_balance >= 1e20) // 100 ETH
            return 92;
        else if (_balance >= 5e19) // 50 ETH
            return 91;
        else
            return 90;
    }
    
    function calculateSupportPercent(uint _amount) private pure returns (uint) {
        return _amount * supportPercent / 100;
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
          return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}