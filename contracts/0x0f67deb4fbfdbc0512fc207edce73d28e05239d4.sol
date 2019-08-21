pragma solidity ^0.4.16;

interface Token {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract DBXCrowdsale {
    
    Token public tokenReward;
    address public creator;
    address public owner = 0x096684f06d46465eD23d44407DF4BD05aB6CF5A0;

    uint256 public price;
    uint256 public startDate;
    uint256 public endDate;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function DBXCrowdsale() public {
        creator = msg.sender;
        startDate = 1518220800;
        endDate = 1519862400;
        price = 10000;
        tokenReward = Token(0xA0e3060bbFD4F3665F914C966B489c79E74fDC96);
    }

    function setOwner(address _owner) public {
        require(msg.sender == creator);
        owner = _owner;      
    }

    function setCreator(address _creator) public {
        require(msg.sender == creator);
        creator = _creator;      
    }

    function setStartDate(uint256 _startDate) public {
        require(msg.sender == creator);
        startDate = _startDate;      
    }

    function setEndtDate(uint256 _endDate) public {
        require(msg.sender == creator);
        endDate = _endDate;      
    }
    
    function setPrice(uint256 _price) public {
        require(msg.sender == creator);
        price = _price;      
    }

    function setToken(address _token) public {
        require(msg.sender == creator);
        tokenReward = Token(_token);      
    }
    
    function kill() public {
        require(msg.sender == creator);
        selfdestruct(owner);
    }

    function () payable public {
        require(msg.value > 0);
        require(now > startDate);
        require(now < endDate);
	    uint amount = msg.value * price;
        uint _amount = amount / 20;
        
        // period 1 : 35%
        if(now > 1518220800 && now < 1518652800) {
            amount += _amount * 7;
        }
        
        // period 2 : 10%
        if(now > 1518652800 && now < 1519862400) {
            amount += _amount * 2;
        }

        tokenReward.transferFrom(owner, msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}