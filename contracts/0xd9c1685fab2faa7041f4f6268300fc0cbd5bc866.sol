pragma solidity ^0.4.25;

interface Snip3DInterface  {
    function() payable external;
   
    function sendInSoldier(address masternode) external payable;
    function fetchdivs(address toupdate) external;
    function shootSemiRandom() external;
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
        owner = _newOwner;
    }
    
}
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
// Snip3dbridge contract
contract Snip3D is  Owned {
    using SafeMath for uint;
    Snip3DInterface constant Snip3Dcontract_ = Snip3DInterface(0x6D534b48835701312ebc904d4b37e54D4f7D039f);
    
    function soldierUp () onlyOwner public payable {
       
        Snip3Dcontract_.sendInSoldier.value(0.1 ether)(msg.sender);
    }
    function shoot () onlyOwner public {
       
        Snip3Dcontract_.shootSemiRandom();
    }
    function fetchdivs () onlyOwner public {
      
        Snip3Dcontract_.fetchdivs(address(this));
    }
    function fetchBalance () onlyOwner public {
      
        msg.sender.transfer(address(this).balance);
    }
}