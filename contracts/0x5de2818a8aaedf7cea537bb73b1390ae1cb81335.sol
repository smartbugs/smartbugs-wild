pragma solidity ^0.4.18;

interface CornFarm
{
    function buyObject(address _beneficiary) public payable;
}

interface Corn
{
    function transfer(address to, uint256 value) public returns (bool);
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract TaxManFarmer {
    using SafeMath for uint256;
    
    bool private reentrancy_lock = false;
    
    address public taxMan = 0xd5048F05Ed7185821C999e3e077A3d1baed0952c;
    address[9] public shop = [0x225e5E680358FaE78216A9C0A17793c2d2A85fC2, 0xf9208661ffE1607D96cF386B84B2BE621620097C, 
    0x28bdDb555AdF1Bb71ce21cAb60566956bbFB0f08, 0xc8Ac76785C6b413753f6bFEdD9953785876B8a5c, 0x71e7a455991Cd9f60148720e2EB0Bc823014dB32, 
    0xC946a2351eA574676f5e21043F05A33c2ceaBC59, 0x0B2DA98ab93207CE1367d63947A20E24372D9Ab5, 0x0029b494669cfE56E8cDBCafF074940CC107a970,
    0xbD4282E6b2Bf8eef232eD211e53b54E560D71a2B];
    address[9] public object = [0x339Cd902D6F2e50717b114f0837280ce56f36020, 0x56021b1b327eBE1eed2182A74d5f6a9a04eB2C73, 0x67BE1A7555A7D38D837F6587530FFc33d89F5a90,
    0x7249fd2B946cAeD7D6C695e1656434A063723926, 0xAc4A1553e1e80222D6BF9f66D8FeF629aa8dBE74, 0x94b10291AA26f29994cF944da0Db6F03D4b407e1,
    0x234FcB7f91fC353fefAd092b393850803A261cf9, 0xab87f28E10E3b0942EB27596Cc73B4031C9856e9, 0xFc1082B4d80651d9948b58ffCce45A5e6586AFE6];
    
    mapping(address => uint256) public workDone;
    
    modifier nonReentrant() {
        require(!reentrancy_lock);
        reentrancy_lock = true;
        _;
        reentrancy_lock = false;
    }
    
    function pepFarm() nonReentrant external {
        // buy 11 of each item
        for (uint8 i = 0; i < 9; i++) { // 9 objects
            for (uint8 j = 0; j < 11; j++) { // 11 times
                CornFarm(shop[i]).buyObject(this);
            }
            
            // 10 for sender, 1 for taxMan
            workDone[msg.sender] = workDone[msg.sender].add(uint256(10 ether));
            workDone[taxMan] = workDone[taxMan].add(uint256(1 ether));
        }
        
    }
    
    function reapFarm() nonReentrant external {
        require(workDone[msg.sender] > 0);
        for (uint8 i = 0; i < 9; i++) {
            Corn(object[i]).transfer(msg.sender, workDone[msg.sender]);
            Corn(object[i]).transfer(taxMan, workDone[taxMan]);
        }
        workDone[msg.sender] = 0;
        workDone[taxMan] = 0;
    }
}