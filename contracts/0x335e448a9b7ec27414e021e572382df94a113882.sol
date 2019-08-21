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



contract RTDReward is owned {
    address public token;
    string public detail;
    string public website;

    event Reward(address target, uint256 amount);

    constructor() public {
        owner = msg.sender;
    }

    function setContract(address _token,string _website, string _detail) onlyOwner public {
        token = _token;
        website = _website;
        detail = _detail;
    }

    function() payable public {}

    function withdrawEther() onlyOwner public {
        owner.transfer(address(this).balance);
    }

    function sendReward(address _user, uint256 _value)  onlyOwner public {
            _user.transfer(_value);
            emit Reward(_user, _value);
    }
}