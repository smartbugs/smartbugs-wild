//
// Our shop contract acts as a payment provider for our in-game shop system. 
// Coin packages that are purchased here are being picked up by our offchain 
// sync network and are then translated into in-game assets. This happens with
// minimal delay and enables a fluid gameplay experience. An in-game notification
// informs players about the successful purchase of coins.
// 
// Prices are scaled against the current USD value of ETH courtesy of
// MAKERDAO (https://developer.makerdao.com/feeds/) 
// This enables us to match our native In-App-Purchase prices from e.g. Apple's AppStore
// We can also reduce the price of packages temporarily for e.g. events and promotions.
//

pragma solidity ^0.4.21;


contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) constant returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    function DSAuth() {
        owner = msg.sender;
        LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        auth
    {
        owner = owner_;
        LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        auth
    {
        authority = authority_;
        LogSetAuthority(authority);
    }

    modifier auth {
        assert(isAuthorized(msg.sender, msg.sig));
        _;
    }

    modifier authorized(bytes4 sig) {
        assert(isAuthorized(msg.sender, sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }

    function assert(bool x) internal {
        if (!x) throw;
    }
}

contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
	uint	 	  wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }

        LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}

contract DSMath {
    
    /*
    standard uint256 functions
     */

    function add(uint256 x, uint256 y) constant internal returns (uint256 z) {
        assert((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) constant internal returns (uint256 z) {
        assert((z = x - y) <= x);
    }

    function mul(uint256 x, uint256 y) constant internal returns (uint256 z) {
        assert((z = x * y) >= x);
    }

    function div(uint256 x, uint256 y) constant internal returns (uint256 z) {
        z = x / y;
    }

    function min(uint256 x, uint256 y) constant internal returns (uint256 z) {
        return x <= y ? x : y;
    }
    function max(uint256 x, uint256 y) constant internal returns (uint256 z) {
        return x >= y ? x : y;
    }

    /*
    uint128 functions (h is for half)
     */


    function hadd(uint128 x, uint128 y) constant internal returns (uint128 z) {
        assert((z = x + y) >= x);
    }

    function hsub(uint128 x, uint128 y) constant internal returns (uint128 z) {
        assert((z = x - y) <= x);
    }

    function hmul(uint128 x, uint128 y) constant internal returns (uint128 z) {
        assert((z = x * y) >= x);
    }

    function hdiv(uint128 x, uint128 y) constant internal returns (uint128 z) {
        z = x / y;
    }

    function hmin(uint128 x, uint128 y) constant internal returns (uint128 z) {
        return x <= y ? x : y;
    }
    function hmax(uint128 x, uint128 y) constant internal returns (uint128 z) {
        return x >= y ? x : y;
    }


    /*
    int256 functions
     */

    function imin(int256 x, int256 y) constant internal returns (int256 z) {
        return x <= y ? x : y;
    }
    function imax(int256 x, int256 y) constant internal returns (int256 z) {
        return x >= y ? x : y;
    }

    /*
    WAD math
     */

    uint128 constant WAD = 10 ** 18;

    function wadd(uint128 x, uint128 y) constant internal returns (uint128) {
        return hadd(x, y);
    }

    function wsub(uint128 x, uint128 y) constant internal returns (uint128) {
        return hsub(x, y);
    }

    function wmul(uint128 x, uint128 y) constant internal returns (uint128 z) {
        z = cast((uint256(x) * y + WAD / 2) / WAD);
    }

    function wdiv(uint128 x, uint128 y) constant internal returns (uint128 z) {
        z = cast((uint256(x) * WAD + y / 2) / y);
    }

    function wmin(uint128 x, uint128 y) constant internal returns (uint128) {
        return hmin(x, y);
    }
    function wmax(uint128 x, uint128 y) constant internal returns (uint128) {
        return hmax(x, y);
    }

    /*
    RAY math
     */

    uint128 constant RAY = 10 ** 27;

    function radd(uint128 x, uint128 y) constant internal returns (uint128) {
        return hadd(x, y);
    }

    function rsub(uint128 x, uint128 y) constant internal returns (uint128) {
        return hsub(x, y);
    }

    function rmul(uint128 x, uint128 y) constant internal returns (uint128 z) {
        z = cast((uint256(x) * y + RAY / 2) / RAY);
    }

    function rdiv(uint128 x, uint128 y) constant internal returns (uint128 z) {
        z = cast((uint256(x) * RAY + y / 2) / y);
    }

    function rpow(uint128 x, uint64 n) constant internal returns (uint128 z) {
        // This famous algorithm is called "exponentiation by squaring"
        // and calculates x^n with x as fixed-point and n as regular unsigned.
        //
        // It's O(log n), instead of O(n) for naive repeated multiplication.
        //
        // These facts are why it works:
        //
        //  If n is even, then x^n = (x^2)^(n/2).
        //  If n is odd,  then x^n = x * x^(n-1),
        //   and applying the equation for even x gives
        //    x^n = x * (x^2)^((n-1) / 2).
        //
        //  Also, EVM division is flooring and
        //    floor[(n-1) / 2] = floor[n / 2].

        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }

    function rmin(uint128 x, uint128 y) constant internal returns (uint128) {
        return hmin(x, y);
    }
    function rmax(uint128 x, uint128 y) constant internal returns (uint128) {
        return hmax(x, y);
    }

    function cast(uint256 x) constant internal returns (uint128 z) {
        assert((z = uint128(x)) == x);
    }

}

contract DSThing is DSAuth, DSNote, DSMath {
}

contract DSValue is DSThing {
    bool    has;
    bytes32 val;
    function peek() constant returns (bytes32, bool) {
        return (val,has);
    }
    function read() constant returns (bytes32) {
        var (wut, has) = peek();
        assert(has);
        return wut;
    }
    function poke(bytes32 wut) note auth {
        val = wut;
        has = true;
    }
    function void() note auth { // unset the value
        has = false;
    }
}

contract Medianizer is DSValue {
    mapping (bytes12 => address) public values;
    mapping (address => bytes12) public indexes;
    bytes12 public next = 0x1;

    uint96 public min = 0x1;

    function set(address wat) auth {
        bytes12 nextId = bytes12(uint96(next) + 1);
        assert(nextId != 0x0);
        set(next, wat);
        next = nextId;
    }

    function set(bytes12 pos, address wat) note auth {
        if (pos == 0x0) throw;

        if (wat != 0 && indexes[wat] != 0) throw;

        indexes[values[pos]] = 0; // Making sure to remove a possible existing address in that position

        if (wat != 0) {
            indexes[wat] = pos;
        }

        values[pos] = wat;
    }

    function setMin(uint96 min_) note auth {
        if (min_ == 0x0) throw;
        min = min_;
    }

    function setNext(bytes12 next_) note auth {
        if (next_ == 0x0) throw;
        next = next_;
    }

    function unset(bytes12 pos) {
        set(pos, 0);
    }

    function unset(address wat) {
        set(indexes[wat], 0);
    }

    function poke() {
        poke(0);
    }

    function poke(bytes32) note {
        (val, has) = compute();
    }

    function compute() constant returns (bytes32, bool) {
        bytes32[] memory wuts = new bytes32[](uint96(next) - 1);
        uint96 ctr = 0;
        for (uint96 i = 1; i < uint96(next); i++) {
            if (values[bytes12(i)] != 0) {
                var (wut, wuz) = DSValue(values[bytes12(i)]).peek();
                if (wuz) {
                    if (ctr == 0 || wut >= wuts[ctr - 1]) {
                        wuts[ctr] = wut;
                    } else {
                        uint96 j = 0;
                        while (wut >= wuts[j]) {
                            j++;
                        }
                        for (uint96 k = ctr; k > j; k--) {
                            wuts[k] = wuts[k - 1];
                        }
                        wuts[j] = wut;
                    }
                    ctr++;
                }
            }
        }

        if (ctr < min) return (val, false);

        bytes32 value;
        if (ctr % 2 == 0) {
            uint128 val1 = uint128(wuts[(ctr / 2) - 1]);
            uint128 val2 = uint128(wuts[ctr / 2]);
            value = bytes32(wdiv(hadd(val1, val2), 2 ether));
        } else {
            value = wuts[(ctr - 1) / 2];
        }

        return (value, true);
    }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * via OpenZeppelin
 */
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }

}


contract ChainmonstersMedianizer is Ownable {

    address medianizerBase;
    Medianizer makerMed;

    constructor(address _medianizerContract) public {
        owner = msg.sender;

        medianizerBase = _medianizerContract;

        makerMed = Medianizer(medianizerBase);
    }

    function updateMedianizerBase(address _medianizerContract) public onlyOwner {
        medianizerBase = _medianizerContract;
        makerMed = Medianizer(medianizerBase);
    }

    function getUSDPrice() public view returns (uint256) {
        return bytesToUint(toBytes(makerMed.read()));
    }
    
    function isMedianizer() public view returns (bool) {
        return true;
    }
    
    

    function toBytes(bytes32 _data) public pure returns (bytes) {
        return abi.encodePacked(_data);
    }

    function bytesToUint(bytes b) public pure returns (uint256){
        uint256 number;
        for(uint i=0;i<b.length;i++){
            number = number + uint(b[i])*(2**(8*(b.length-(i+1))));
        }
        return number;
    }

}

/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/
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
    * @dev Substracts two numbers, returns 0 if it would go into minus range.
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b >= a) {
            return 0;
        }
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

contract ChainmonstersShop {
    using SafeMath for uint256; 
    
    // static
    address public owner;
    
    // start auction manually at given time
    bool started;

    uint256 public totalCoinsSold;

    address medianizer;
    uint256 shiftValue = 100; // double digit shifting to support prices like $29.99
    uint256 multiplier = 10000; // internal multiplier

    struct Package {
        // price in USD
        uint256 price;
        // reference to in-game equivalent e.g. "100 Coins"
        string packageReference;
        // available for purchase?
        bool isActive;
        // amount of coins
        uint256 coinsAmount;
    }

    
    event LogPurchase(address _from, uint256 _price, string _packageReference);

    mapping(address => uint256) public addressToCoinsPurchased;
    Package[] packages;

    constructor() public {
        owner = msg.sender;

        started = false;
    }

    function startShop() public onlyOwner {
        require(started == false);

    }

    // in case of contract switch or adding new packages
    function pauseShop() public onlyOwner {
        require(started == true);
    }

    function isStarted() public view returns (bool success) {
        return started;
    }

    function purchasePackage(uint256 _id) public
        payable
        returns (bool success)
        {
            require(started == true);
            require(packages[_id].isActive == true);
            require(msg.sender != owner);
            require(msg.value == priceOf(packages[_id].price)); // only accept 100% accurate prices

            addressToCoinsPurchased[msg.sender] += packages[_id].coinsAmount;
            totalCoinsSold += packages[_id].coinsAmount;
            emit LogPurchase(msg.sender, msg.value, packages[_id].packageReference);
        }

    function addPackage(uint256 _price, string _packageReference, bool _isActive, uint256 _coinsAmount)
        external
        onlyOwner
        {
            require(_price > 0);
            Package memory _package = Package({
            price: uint256(_price),
            packageReference: string(_packageReference),
            isActive: bool(_isActive),
            coinsAmount: uint256(_coinsAmount)
        });

        uint256 newPackageId = packages.push(_package);

        }

    function setPrice(uint256 _packageId, uint256 _newPrice)
        external
        onlyOwner
        {
            require(packages[_packageId].price > 0);
            packages[_packageId].price = _newPrice;
        }

    function getPackage(uint256 _id)
        external 
        view
        returns (uint256 priceInETH, uint256 priceInUSD, string packageReference, uint256 coinsAmount )
        {
            Package storage package = packages[_id];
            priceInETH = priceOf(_id);
            priceInUSD = package.price;
            packageReference = package.packageReference;
            coinsAmount = package.coinsAmount;
        
        }

 
  function priceOf(uint256 _packageId)
    public
    view
    returns (uint256) 
    {

        // if no medianizer is set then return fixed price(!)
        if (medianizer == address(0x0)) {
          return packages[_packageId].price;
        }
        else {
          // the price of usd/eth gets returned from medianizer
          uint256 USDinWei = ChainmonstersMedianizer(medianizer).getUSDPrice();
    
          uint256 multValue = (packages[_packageId].price.mul(multiplier)).div(USDinWei.div(1 ether));
          uint256 inWei = multValue.mul(1 ether);
          uint256 result = inWei.div(shiftValue.mul(multiplier));
          return result;
        }
    
  }
  
  function getPackagesCount()
    public
    view
    returns (uint256)
    {
        return packages.length;
    }

  function setMedianizer(ChainmonstersMedianizer _medianizer)
     public
    onlyOwner 
    {
    require(_medianizer.isMedianizer(), "given address is not a medianizer contract!");
    medianizer = _medianizer;
  }

    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }


    
   
    
}