pragma solidity ^0.4.24;


contract owned {
    constructor() public { owner = msg.sender; }

    address owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}


contract ERC20 {
    function balanceOf(address tokenOwner) public constant returns (uint256 balance);
    function transfer(address to, uint256 tokens) public returns (bool success);
}


contract GasManager is owned {

    function () payable public {}

    function sendInBatch(address[] toAddressList, uint256[] amountList) public onlyOwner {
        require(toAddressList.length == amountList.length);

        for (uint i = 0; i < toAddressList.length; i++) {
            toAddressList[i].transfer(amountList[i]);
        }
    }
}