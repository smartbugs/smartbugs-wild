pragma solidity ^0.4.2;
contract Deed {
    address public owner;
    address public previousOwner;
}
contract Registry {
    function owner(bytes32 _hash) public constant returns (address);
}
contract Registrar {
    function transfer(bytes32 _hash, address newOwner) public;
    function entries(bytes32 _hash) public constant returns (uint, Deed, uint, uint, uint);
}
contract Permissioned {
    mapping(address=>mapping(bytes32=>bool)) internal permissions;
    bytes32 internal constant PERM_SUPERUSER = keccak256("_superuser");
    function Permissioned() public {
        permissions[msg.sender][PERM_SUPERUSER] = true;
    }
    modifier ifPermitted(address addr, bytes32 permission) {
        require(permissions[addr][permission] || permissions[addr][PERM_SUPERUSER]);
        _;
    }
    function isPermitted(address addr, bytes32 permission) public constant returns (bool) {
        return(permissions[addr][permission] || permissions[addr][PERM_SUPERUSER]);
    }
    function setPermission(address addr, bytes32 permission, bool allowed) public ifPermitted(msg.sender, PERM_SUPERUSER) {
        permissions[addr][permission] = allowed;
    }
}
contract RegistryRef {
    function owner(bytes32 node) public constant returns (address);
}
contract ReverseRegistrarRef {
    function setName(string name) public returns (bytes32 node);
}
contract ENSReverseRegister {
    function ENSReverseRegister(address registry, string name) public {
        if (registry != 0) {
            var reverseRegistrar = RegistryRef(registry).owner(0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2);
            if (reverseRegistrar != 0) {
                ReverseRegistrarRef(reverseRegistrar).setName(name);
            }
        }
    }
}
contract Pausable is Permissioned {
    event Pause();
    event Unpause();
    bool public paused = false;
    bytes32 internal constant PERM_PAUSE = keccak256("_pausable");
    modifier ifNotPaused() {
        require(!paused);
        _;
    }
    modifier ifPaused {
        require(paused);
        _;
    }
    function pause() public ifPermitted(msg.sender, PERM_PAUSE) ifNotPaused returns (bool) {
        paused = true;
        Pause();
        return true;
    }
    function unpause() public ifPermitted(msg.sender, PERM_PAUSE) ifPaused returns (bool) {
        paused = false;
        Unpause();
        return true;
    }
}
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
contract DomainSale is ENSReverseRegister, Pausable {
    using SafeMath for uint256;
    Registrar public registrar;
    mapping (string => Sale) private sales;
    mapping (address => uint256) private balances;
    uint256 private constant AUCTION_DURATION = 24 hours;
    uint256 private constant HIGH_BID_KICKIN = 7 days;
    uint256 private constant NORMAL_BID_INCREASE_PERCENTAGE = 10;
    uint256 private constant HIGH_BID_INCREASE_PERCENTAGE = 50;
    uint256 private constant SELLER_SALE_PERCENTAGE = 90;
    uint256 private constant START_REFERRER_SALE_PERCENTAGE = 5;
    uint256 private constant BID_REFERRER_SALE_PERCENTAGE = 5;
    string private constant CONTRACT_ENS = "domainsale.eth";
    bytes32 private constant NAMEHASH_ETH = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;
    struct Sale {
        uint256 price;
        uint256 reserve;
        uint256 lastBid;
        address lastBidder;
        uint256 auctionStarted;
        uint256 auctionEnds;
        address startReferrer;
        address bidReferrer;
    }
    event Offer(address indexed seller, string name, uint256 price, uint256 reserve);
    event Bid(address indexed bidder, string name, uint256 bid);
    event Transfer(address indexed seller, address indexed buyer, string name, uint256 value);
    event Cancel(string name);
    event Withdraw(address indexed recipient, uint256 amount);
    modifier onlyNameSeller(string _name) {
        Deed deed;
        (,deed,,,) = registrar.entries(keccak256(_name));
        require(deed.owner() == address(this));
        require(deed.previousOwner() == msg.sender);
        _;
    }
    modifier deedValid(string _name) {
        address deed;
        (,deed,,,) = registrar.entries(keccak256(_name));
        require(deed != 0);
        _;
    }
    modifier auctionNotStarted(string _name) {
        require(sales[_name].auctionStarted == 0);
        _;
    }
    modifier canBid(string _name) {
        require(sales[_name].reserve != 0);
        _;
    }
    modifier canBuy(string _name) {
        require(sales[_name].price != 0);
        _;
    }
    function DomainSale(address _registry) public ENSReverseRegister(_registry, CONTRACT_ENS) {
        registrar = Registrar(Registry(_registry).owner(NAMEHASH_ETH));
    }
    function sale(string _name) public constant returns (uint256, uint256, uint256, address, uint256, uint256) {
        Sale storage s = sales[_name];
        return (s.price, s.reserve, s.lastBid, s.lastBidder, s.auctionStarted, s.auctionEnds);
    }
    function isAuction(string _name) public constant returns (bool) {
        return sales[_name].reserve != 0;
    }
    function isBuyable(string _name) public constant returns (bool) {
        return sales[_name].price != 0 && sales[_name].auctionStarted == 0;
    }
    function auctionStarted(string _name) public constant returns (bool) {
        return sales[_name].lastBid != 0;
    }
    function auctionEnds(string _name) public constant returns (uint256) {
        return sales[_name].auctionEnds;
    }
    function minimumBid(string _name) public constant returns (uint256) {
        Sale storage s = sales[_name];
        if (s.auctionStarted == 0) {
            return s.reserve;
        } else if (s.auctionStarted.add(HIGH_BID_KICKIN) > now) {
            return s.lastBid.add(s.lastBid.mul(NORMAL_BID_INCREASE_PERCENTAGE).div(100));
        } else {
            return s.lastBid.add(s.lastBid.mul(HIGH_BID_INCREASE_PERCENTAGE).div(100));
        }
    }
    function price(string _name) public constant returns (uint256) {
        return sales[_name].price;
    }
    function balance(address addr) public constant returns (uint256) {
        return balances[addr];
    }
    function offer(string _name, uint256 _price, uint256 reserve, address referrer) onlyNameSeller(_name) auctionNotStarted(_name) deedValid(_name) ifNotPaused public {
        require(_price == 0 || _price > reserve);
        require(_price != 0 || reserve != 0);
        Sale storage s = sales[_name];
        s.reserve = reserve;
        s.price = _price;
        s.startReferrer = referrer;
        Offer(msg.sender, _name, _price, reserve);
    }
    function cancel(string _name) onlyNameSeller(_name) auctionNotStarted(_name) deedValid(_name) ifNotPaused public {
        delete sales[_name];
        registrar.transfer(keccak256(_name), msg.sender);
        Cancel(_name);
    }
    function buy(string _name, address bidReferrer) canBuy(_name) deedValid(_name) ifNotPaused public payable {
        Sale storage s = sales[_name];
        require(msg.value >= s.price);
        require(s.auctionStarted == 0);
        Deed deed;
        (,deed,,,) = registrar.entries(keccak256(_name));
        address previousOwner = deed.previousOwner();
        registrar.transfer(keccak256(_name), msg.sender);
        Transfer(previousOwner, msg.sender, _name, msg.value);
        distributeFunds(msg.value, previousOwner, s.startReferrer, bidReferrer);
        delete sales[_name];
        withdraw();
    }
    function bid(string _name, address bidReferrer) canBid(_name) deedValid(_name) ifNotPaused public payable {
        require(msg.value >= minimumBid(_name));
        Sale storage s = sales[_name];
        require(s.auctionStarted == 0 || now < s.auctionEnds);
        if (s.auctionStarted == 0) {
          s.auctionStarted = now;
        } else {
          balances[s.lastBidder] = balances[s.lastBidder].add(s.lastBid);
        }
        s.lastBidder = msg.sender;
        s.lastBid = msg.value;
        s.auctionEnds = now.add(AUCTION_DURATION);
        s.bidReferrer = bidReferrer;
        Bid(msg.sender, _name, msg.value);
        withdraw();
    }
    function finish(string _name) deedValid(_name) ifNotPaused public {
        Sale storage s = sales[_name];
        require(now > s.auctionEnds);
        Deed deed;
        (,deed,,,) = registrar.entries(keccak256(_name));
        address previousOwner = deed.previousOwner();
        registrar.transfer(keccak256(_name), s.lastBidder);
        Transfer(previousOwner, s.lastBidder, _name, s.lastBid);
        distributeFunds(s.lastBid, previousOwner, s.startReferrer, s.bidReferrer);
        delete sales[_name];
        withdraw();
    }
    function withdraw() ifNotPaused public {
        uint256 amount = balances[msg.sender];
        if (amount > 0) {
            balances[msg.sender] = 0;
            msg.sender.transfer(amount);
            Withdraw(msg.sender, amount);
        }
    }
    function invalidate(string _name) ifNotPaused public {
        address deed;
        (,deed,,,) = registrar.entries(keccak256(_name));
        require(deed == 0);
        Sale storage s = sales[_name];
        balances[s.lastBidder] = balances[s.lastBidder].add(s.lastBid);
        delete sales[_name];
        Cancel(_name);
        withdraw();
    }
    function distributeFunds(uint256 amount, address seller, address startReferrer, address bidReferrer) internal {
        uint256 startReferrerFunds = amount.mul(START_REFERRER_SALE_PERCENTAGE).div(100);
        balances[startReferrer] = balances[startReferrer].add(startReferrerFunds);
        uint256 bidReferrerFunds = amount.mul(BID_REFERRER_SALE_PERCENTAGE).div(100);
        balances[bidReferrer] = balances[bidReferrer].add(bidReferrerFunds);
        uint256 sellerFunds = amount.sub(startReferrerFunds).sub(bidReferrerFunds);
        balances[seller] = balances[seller].add(sellerFunds);
    }
}