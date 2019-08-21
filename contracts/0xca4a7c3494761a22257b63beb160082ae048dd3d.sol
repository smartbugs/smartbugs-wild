pragma solidity ^0.4.24;

contract ERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address _who) public view returns (uint256);
}

contract Distribution {
    address public owner;
    ERC20 public token;

    address[] holders;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0));
        owner = _newOwner;
    }

    constructor(address _ERC20) public {
        owner = msg.sender;
        token = ERC20(_ERC20);
    }

    function() external payable {
    }

    function payDividends(uint _value) external onlyOwner {
        for (uint i = 0; i < holders.length; i++) {
            holders[i].transfer(_value * token.balanceOf(holders[i]) / token.totalSupply());
        }
    }

    function addHolder(address _address) external onlyOwner {
        holders.push(_address);
    }

    function addListOfHolders(address[] _addresses) external onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            holders.push(_addresses[i]);
        }
    }

    function emptyListOfHolders() external onlyOwner {
        for (uint i = 0; i < holders.length; i++) {
            delete holders[i];
        }
        holders.length = 0;
    }

    function getLengthOfList() external view returns(uint) {
        return holders.length;
    }

    function getHolder(uint _number) external view returns(address) {
        return holders[_number];
    }

    function withdrawBalance() external onlyOwner {
        owner.transfer(address(this).balance);
    }
}