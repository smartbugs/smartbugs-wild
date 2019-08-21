pragma solidity ^0.4.24;

interface Token {
    function transfer(address _to, uint256 _value) external;
}

contract AENCrowdsale {
    
    Token public tokenReward;
    address public creator;
    address public owner;
    uint256 public totalSold;

    event FundTransfer(address beneficiaire, uint amount);

    constructor() public {
        creator = msg.sender;
        owner = 0xF82C31E4df853ff36F2Fc6F61F93B4CAda46E306;
        tokenReward = Token(0xBd11eaE443eF0E96C1CC565Db5c0b51f6c829C0b);
    }

    function setOwner(address _owner) public {
        require(msg.sender == creator);
        owner = _owner;      
    }

    function setCreator(address _creator) public {
        require(msg.sender == creator);
        creator = _creator;      
    }

    function setToken(address _token) public {
        require(msg.sender == creator);
        tokenReward = Token(_token);      
    }
    
    function sendToken(address _to, uint256 _value) public {
        require(msg.sender == creator);
        tokenReward.transfer(_to, _value);      
    }
    
    function kill() public {
        require(msg.sender == creator);
        selfdestruct(owner);
    }

    function () payable public {
        require(msg.value > 0 && msg.value < 5.1 ether);
	    uint amount = msg.value * 5000;
	    amount = amount / 20;
        
        // 13 October 2018 - 19 October 2018: 30% bonus 
        if(now > 1539385200 && now < 1539990000) {
            amount = amount * 26;
        }
        
        // 20 October 2018 - 26 October 2018: 25% bonus
        if(now > 1539990000 && now < 1540594800) {
            amount = amount * 25;
        }
        
        // 27 October 2018 - 02 November 2018: 20% bonus 
        if(now > 1540594800 && now < 1541203200) {
            amount = amount * 24;
        }
        
        // 03 October 2018 - 09 October 2018: 15% bonus 
        if(now > 1541203200 && now < 1541808000) {
            amount = amount * 23;
        }

        // 10 November 2018 - 31 November 2018: 10% bonus
        if(now > 1541808000 && now < 1543622400) {
            amount = amount * 22;
        }

        // 31 November 2018
        if(now > 1543622400) {
            amount = amount * 20;
        }
        
        totalSold += amount / 1 ether;
        tokenReward.transfer(msg.sender, amount);
        emit FundTransfer(msg.sender, amount);
        owner.transfer(msg.value);
    }
}