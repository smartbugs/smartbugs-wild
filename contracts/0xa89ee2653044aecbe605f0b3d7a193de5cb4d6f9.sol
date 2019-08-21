pragma solidity 0.4.20;

contract QQQTokenBase {
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    
    event Transfer( address indexed from, address indexed to, uint256 value);

    function QQQTokenBase() public {    }
    
    function totalSupply() public view returns (uint256) {
        return _supply;
    }
    function balanceOf(address src) public view returns (uint256) {
        return _balances[src];
    }
    
    function transfer(address dst, uint256 wad) public returns (bool) {
        require(_balances[msg.sender] >= wad);
        
        _balances[msg.sender] = sub(_balances[msg.sender], wad);
        _balances[dst] = add(_balances[dst], wad);
        
        Transfer(msg.sender, dst, wad);
        
        return true;
    }
    
    function add(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x + y;
        require(z >= x && z>=y);
        return z;
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x - y;
        require(x >= y && z <= x);
        return z;
    }
}

contract QQQToken is QQQTokenBase {
    string  public  symbol = "QQQ";
    string  public name = "QQQ";
    uint256 public  decimals = 18; 
    uint256 public freezedValue = 700000000*(10**18);
    uint256 public eachUnfreezeValue = 50000000*(10**18);
    uint256 public releaseTime = 1543593600; 
    uint256 public latestReleaseTime = 1543593600; // 2018/12/1 0:0:0
    address public owner;

    struct FreezeStruct {
        uint256 unfreezeTime;
        bool freezed;
    }

    FreezeStruct[] public unfreezeTimeMap;
         

    function QQQToken() public {
        _supply = 10*(10**8)*(10**18);
        _balances[0x01] = freezedValue;
        _balances[msg.sender] = sub(_supply,freezedValue);
        owner = msg.sender;

        unfreezeTimeMap.push(FreezeStruct({unfreezeTime:1575129600, freezed: true})); // 2019/12/01 0:0:0
        unfreezeTimeMap.push(FreezeStruct({unfreezeTime:1575129610, freezed: true})); // 2019/12/01 0:0:10
        unfreezeTimeMap.push(FreezeStruct({unfreezeTime:1606752000, freezed: true})); // 2020/12/01 0:0:0
        unfreezeTimeMap.push(FreezeStruct({unfreezeTime:1606752010, freezed: true})); // 2020/12/01 0:0:10
		unfreezeTimeMap.push(FreezeStruct({unfreezeTime:1638288000, freezed: true})); // 2021/12/01 0:0:0
        unfreezeTimeMap.push(FreezeStruct({unfreezeTime:1669824000, freezed: true})); // 2022/12/01 0:0:0
        unfreezeTimeMap.push(FreezeStruct({unfreezeTime:1701360000, freezed: true})); // 2023/12/01 0:0:0
        unfreezeTimeMap.push(FreezeStruct({unfreezeTime:1732982400, freezed: true})); // 2024/12/01 0:0:0
		unfreezeTimeMap.push(FreezeStruct({unfreezeTime:1764518400, freezed: true})); // 2025/12/01 0:0:0
        unfreezeTimeMap.push(FreezeStruct({unfreezeTime:1796054400, freezed: true})); // 2026/12/01 0:0:0
		unfreezeTimeMap.push(FreezeStruct({unfreezeTime:1827590400, freezed: true})); // 2027/12/01 0:0:0
        unfreezeTimeMap.push(FreezeStruct({unfreezeTime:1859212800, freezed: true})); // 2028/12/01 0:0:0
        unfreezeTimeMap.push(FreezeStruct({unfreezeTime:1890748800, freezed: true})); // 2029/12/01 0:0:0
        unfreezeTimeMap.push(FreezeStruct({unfreezeTime:1922284800, freezed: true})); // 2030/12/01 0:0:0
    }

    function transfer(address dst, uint256 wad) public returns (bool) {
        require (now >= releaseTime || now >= latestReleaseTime);

        return super.transfer(dst, wad);
    }

    function distribute(address dst, uint256 wad) public returns (bool) {
        require(msg.sender == owner);

        return super.transfer(dst, wad);
    }

    function setRelease(uint256 _release) public {
        require(msg.sender == owner);
        require(_release <= latestReleaseTime);

        releaseTime = _release;
    }

    function unfreeze(uint256 i) public {
        require(msg.sender == owner);
        require(i>=0 && i<unfreezeTimeMap.length);
        require(now >= unfreezeTimeMap[i].unfreezeTime && unfreezeTimeMap[i].freezed);
        require(_balances[0x01] >= eachUnfreezeValue);

        _balances[0x01] = sub(_balances[0x01], eachUnfreezeValue);
        _balances[owner] = add(_balances[owner], eachUnfreezeValue);

        freezedValue = sub(freezedValue, eachUnfreezeValue);
        unfreezeTimeMap[i].freezed = false;

        Transfer(0x01, owner, eachUnfreezeValue);
    }
	
	modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
	
}