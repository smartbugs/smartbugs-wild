pragma solidity ^0.4.16;

interface Token {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract SCAMTokenICO {
    
    Token public tokenReward;
    address public creator;
    address public owner = 0xCe2493aA04FE2c146EEe00Fc6B39e39d9504272f;

    uint256 public price;
    uint256 public startDate;
    uint256 public endDate;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function SCAMTokenICO() public {
        creator = msg.sender;
        startDate = 1517184000;     // 29/01/2018
        endDate = 57522;       // 20/03/2018
        price = 10000;
        tokenReward = Token(0x419fab1b55b94e96425674a700b7c44c1d240c35);
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
        tokenReward.transferFrom(owner, msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}