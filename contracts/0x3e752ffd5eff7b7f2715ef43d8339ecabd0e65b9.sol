pragma solidity ^0.4.25;

interface Snip3DInterface  {
    function() payable external;
   function offerAsSacrifice(address MN)
        external
        payable
        ;
         function withdraw()
        external
        ;
        function myEarnings()
        external
        view
       
        returns(uint256);
        function tryFinalizeStage()
        external;
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
contract Slaughter3D is  Owned {
    using SafeMath for uint;
    Snip3DInterface constant Snip3Dcontract_ = Snip3DInterface(0xb172BB8BAae74F27Ade3211E0c145388d3b4f8d8);// change to real address
    uint256 public toSlaughter;
    function harvestableBalance()
        view
        public
        returns(uint256)
    {
        uint256 toReturn = address(this).balance.sub(toSlaughter);
        return ( toReturn)  ;
    }
    function unfetchedVault()
        view
        public
        returns(uint256)
    {
        return ( Snip3Dcontract_.myEarnings())  ;
    }
    function sacUp ()  public payable {
       
        toSlaughter = toSlaughter.add(msg.value);
    }
    function sacUpto (address masternode)  public {
        require(toSlaughter> 0.1 ether);
        toSlaughter = toSlaughter.sub(0.1 ether);
        Snip3Dcontract_.offerAsSacrifice.value(0.1 ether)(masternode);
    }
    function validate ()  public {
       
        Snip3Dcontract_.tryFinalizeStage();
    }
    function fetchvault () public {
      
        Snip3Dcontract_.withdraw();
    }
    function fetchBalance () onlyOwner public {
      uint256 tosend = address(this).balance.sub(toSlaughter);
        msg.sender.transfer(tosend);
    }
    function () external payable{} // needs for divs
}