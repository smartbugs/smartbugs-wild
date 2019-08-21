pragma solidity ^0.4.16;

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



contract RTDAirDrop is owned {
    address public token_address;
    string public detail;
    string public website;

    event AirDropCoin(address target, uint256 amount);

    constructor() public {
        owner = msg.sender;
    }

    function setToken(address tokenAddress) onlyOwner public {
        token_address = tokenAddress;
    }

    function setWebsite(string airdropWebsite) onlyOwner public {
        website = airdropWebsite;
    }

    function setDetail(string airdropDetail) onlyOwner public {
        detail = airdropDetail;
    }

    function() payable public {}

    function withdrawEther() onlyOwner public {
        owner.transfer(address(this).balance);
    }

    function airDrop(address _user, uint256 _value)  onlyOwner public {
            _user.transfer(_value);
            emit AirDropCoin(_user, _value);
    }
}