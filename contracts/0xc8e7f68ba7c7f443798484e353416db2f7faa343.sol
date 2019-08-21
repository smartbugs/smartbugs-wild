pragma solidity ^0.4.24;
// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = 0x0B0eFad4aE088a88fFDC50BCe5Fb63c6936b9220;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract Crowdfund is Owned {
     using SafeMath for uint;
     
    //mapping
    mapping(address => uint256) public Holdings;
    mapping(uint256 => address) public ContributorsList;
    uint256 listPointer;
    uint256 totalethfunded;
    mapping(address => bool) public isInList;
    bool crowdSaleOpen;
    bool crowdSaleFail;
    uint256 CFTsToSend;
    
    constructor() public{
        crowdSaleOpen = true;
    }
    
    modifier onlyWhenOpen() {
        require(crowdSaleOpen == true);
        _;
    }
    function amountOfCFTtoSend(address Holder)
        view
        public
        returns(uint256)
    {
        uint256 amount = CFTsToSend.mul( Holdings[Holder]).div(1 ether).div(totalethfunded);
        return ( amount)  ;
    }
    function setAmountCFTsBought(uint256 amount) onlyOwner public{
        CFTsToSend = amount;
    }
    function() external payable onlyWhenOpen {
        require(msg.value > 0);
        Holdings[msg.sender].add(msg.value);
        if(isInList[msg.sender] == false){
            ContributorsList[listPointer] = msg.sender;
            listPointer++;
            isInList[msg.sender] = true;
        }
    }
    function balanceToOwner() onlyOwner public{
        require(crowdSaleOpen == false);
        totalethfunded = address(this).balance;
        owner.transfer(address(this).balance);
    }
    function CloseCrowdfund() onlyOwner public{
        crowdSaleOpen = false;
    }
    function failCrowdfund() onlyOwner public{
        crowdSaleFail = true;
    }
    function retreiveEthuponFail () public {
        require(crowdSaleFail == true);
        require(Holdings[msg.sender] > 0);
        uint256 getEthback = Holdings[msg.sender];
        Holdings[msg.sender] = 0;
        msg.sender.transfer(getEthback);
    }
}