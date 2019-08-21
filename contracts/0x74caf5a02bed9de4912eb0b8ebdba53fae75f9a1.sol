pragma solidity ^0.4.16;

interface Token {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract ROIcrowdsale {
    
    Token public tokenReward;
    address public creator;
    address public owner = 0xc0c026e307B1B74f8d307181Db00CBe2A1B412e0;

    uint256 public price;
    uint256 public tokenSold;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function ROIcrowdsale() public {
        creator = msg.sender;
        price = 26000;
        tokenReward = Token(0x15DE05E084E4C0805d907fcC2Dc5651023c57A48);
    }

    function setOwner(address _owner) public {
        require(msg.sender == creator);
        owner = _owner;      
    }

    function setCreator(address _creator) public {
        require(msg.sender == creator);
        creator = _creator;      
    }

    function setPrice(uint256 _price) public {
        require(msg.sender == creator);
        price = _price;      
    }
    
    function kill() public {
        require(msg.sender == creator);
        selfdestruct(owner);
    }
    
    function () payable public {
        require(msg.value > 0);
        require(tokenSold < 138216001);
        uint256 _price = price / 10;
        if(tokenSold < 45136000) {
            _price *= 4;
            _price += price; 
        }
        if(tokenSold > 45135999 && tokenSold < 92456000) {
            _price *= 3;
            _price += price;
        }
        if(tokenSold > 92455999 && tokenSold < 138216000) {
            _price += price; 
        }
        uint amount = msg.value * _price;
        tokenSold += amount / 1 ether;
        tokenReward.transferFrom(owner, msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}