pragma solidity >=0.4.22 <0.6.0;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;       
    }       

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract OwnerHelper
{
    address public owner;
    
    modifier onlyOwner
    {
        require(msg.sender == owner);
        _;
    }
    function OwnerHelper() public
    {
        owner = msg.sender;
    }
    function transferOwnership(address _to, uint _value) public returns (bool)
    {
        require(_to != owner);
        require(_to != address(0x0));
        owner = _to;
        //OwnerTransferPropose(owner, _to);

    }
}

contract Crowdsale is OwnerHelper {
    using SafeMath for uint;
    
    uint public saleEthCount = 0;
    uint public maxSaleEth = 2 ether;
    uint constant public minEth = 1;
    uint constant public maxEth = 10;


    constructor() public {
        owner = msg.sender;
    }
    
    

    function () payable public
    {
        //require(msg.value.div(1) == 0);
        require(msg.value >= minEth && msg.value <= maxEth);
        require(msg.value.add(saleEthCount) <= maxSaleEth);
   
        saleEthCount = saleEthCount.add(msg.value);
    }

    function withdraw() public onlyOwner {
        
        owner.transfer(saleEthCount);
        
    }

}