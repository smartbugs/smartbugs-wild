pragma solidity ^0.5.3;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract RelayRegistry is Ownable {
    
    event AddedRelay(address relay);
    event RemovedRelay(address relay);
    
    mapping (address => bool) public relays;
    
    constructor(address initialRelay) public {
        relays[initialRelay] = true;
    }
    
    function triggerRelay(address relay, bool value) onlyOwner public returns (bool) {
        relays[relay] = value;
        if(value) {
            emit AddedRelay(relay);
        } else {
            emit RemovedRelay(relay);
        }
        return true;
    }
    
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
}

// All functions of SmartWallet Implementations should be called using delegatecall
contract SmartWallet {

    event Upgrade(address indexed newImplementation);

    // Shared key value store. Data should be encoded and decoded using abi.encode()/abi.decode() by different implementations
    mapping (bytes32 => bytes) public store;
    
    modifier onlyRelay {
        RelayRegistry registry = RelayRegistry(0xd23e2F482005a90FC2b8dcDd58affc05D5776cb7); // relay registry address
        require(registry.relays(msg.sender));
        _;
    }
    
    modifier onlyOwner {
        require(msg.sender == abi.decode(store["owner"], (address)) || msg.sender == abi.decode(store["factory"], (address)));
        _;
    }
    
    function initiate(address owner) public returns (bool) {
        // this function can only be called by the factory
        if(msg.sender != abi.decode(store["factory"], (address))) return false;
        // store current owner in key store
        store["owner"] = abi.encode(owner);
        store["nonce"] = abi.encode(0);
        return true;
    }
    
    // Called by factory to initiate state if deployment was relayed
    function initiate(address owner, address relay, uint fee, address token) public returns (bool) {
        require(initiate(owner), "internal initiate failed");
        // Access ERC20 token
        IERC20 tokenContract = IERC20(token);
        // Send fee to relay
        require(tokenContract.transfer(relay, fee), "fee transfer failed");
        return true;
    }
    
    function pay(address to, uint value, uint fee, address tokenContract, uint8 v, bytes32 r, bytes32 s) onlyRelay public returns (bool) {
        uint currentNonce = abi.decode(store["nonce"], (uint));
        require(abi.decode(store["owner"], (address)) == recover(keccak256(abi.encodePacked(msg.sender, to, tokenContract, abi.decode(store["factory"], (address)), value, fee, tx.gasprice, currentNonce)), v, r, s));
        IERC20 token = IERC20(tokenContract);
        store["nonce"] = abi.encode(currentNonce+1);
        require(token.transfer(to, value));
        require(token.transfer(msg.sender, fee));
        return true;
    }
    
    function pay(address to, uint value, address tokenContract) onlyOwner public returns (bool) {
        IERC20 token = IERC20(tokenContract);
        require(token.transfer(to, value));
        return true;
    }
    
    function pay(address[] memory to, uint[] memory value, address[] memory tokenContract) onlyOwner public returns (bool) {
        for (uint i; i < to.length; i++) {
            IERC20 token = IERC20(tokenContract[i]);
            require(token.transfer(to[i], value[i]));
        }
        return true;
    }
    
    function upgrade(address implementation, uint fee, address feeContract, uint8 v, bytes32 r, bytes32 s) onlyRelay public returns (bool) {
        uint currentNonce = abi.decode(store["nonce"], (uint));
        address owner = abi.decode(store["owner"], (address));
        address factory = abi.decode(store["factory"], (address));
        require(owner == recover(keccak256(abi.encodePacked(msg.sender, implementation, feeContract, factory, fee, tx.gasprice, currentNonce)), v, r, s));
        store["nonce"] = abi.encode(currentNonce+1);
        store["fallback"] = abi.encode(implementation);
        IERC20 feeToken = IERC20(feeContract);
        require(feeToken.transfer(msg.sender, fee));
        emit Upgrade(implementation);
        return true;
        
    }
    
    function upgrade(address implementation) onlyOwner public returns (bool) {
        store["fallback"] = abi.encode(implementation);
        emit Upgrade(implementation);
        return true;
    }
    
    
    function recover(bytes32 messageHash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedMessageHash = keccak256(abi.encodePacked(prefix, messageHash));
        return ecrecover(prefixedMessageHash, v, r, s);
    }
    
}

contract Proxy {
    
    // Shared key value store. Data should be encoded and decoded using abi.encode()/abi.decode() by different implementations
    mapping (bytes32 => bytes) public store;
    
    constructor() public {
        // set implementation address in storage
        store["fallback"] = abi.encode(0x09892527914356473380b3Aebe1F96ce0DC6982C); // SmartWallet address
        // set factory address in storage
        store["factory"] = abi.encode(msg.sender);
    }
    
    // forwards everything as a delegatecall to appropriate address
    function() external {
        address impl = abi.decode(store["fallback"], (address));
        assembly {
          let ptr := mload(0x40)
        
          // (1) copy incoming call data
          calldatacopy(ptr, 0, calldatasize)
        
          // (2) forward call to logic contract
          let result := delegatecall(gas, impl, ptr, calldatasize, 0, 0)
          let size := returndatasize
        
          // (3) retrieve return data
          returndatacopy(ptr, 0, size)

          // (4) forward return data back to caller
          switch result
          case 0 { revert(ptr, size) }
          default { return(ptr, size) }
        }
    }
}

contract Factory {
    
    event Deployed(address indexed addr, address indexed owner);

    modifier onlyRelay {
        RelayRegistry registry = RelayRegistry(0xd23e2F482005a90FC2b8dcDd58affc05D5776cb7); // Relay Registry address
        require(registry.relays(msg.sender));
        _;
    }

    // internal create2 deployer
    function deployCreate2(address owner) internal returns (address) {
        bytes memory code = type(Proxy).creationCode;
        address addr;
        assembly {
            // create2
            addr := create2(0, add(code, 0x20), mload(code), owner)
            // revert if contract was not created
            if iszero(extcodesize(addr)) {revert(0, 0)}
        }
        return addr;
    }

    // create2 with a relayer
    function deployWallet(uint fee, address token, uint8 v, bytes32 r, bytes32 s) onlyRelay public returns (address) {
        address signer = recover(keccak256(abi.encodePacked(address(this), msg.sender, token, tx.gasprice, fee)), v, r, s);
        address addr = deployCreate2(signer);
        SmartWallet wallet = SmartWallet(uint160(addr));
        require(wallet.initiate(signer, msg.sender, fee, token));
        emit Deployed(addr, signer);
        return addr;
    }
    
    function deployWallet(uint fee, address token, address to, uint value, uint8 v, bytes32 r, bytes32 s) onlyRelay public returns (address addr) {
        address signer = recover(keccak256(abi.encodePacked(address(this), msg.sender, token, to, tx.gasprice, fee, value)), v, r, s);
        addr = deployCreate2(signer);
        SmartWallet wallet = SmartWallet(uint160(addr));
        require(wallet.initiate(signer, msg.sender, fee, token));
        require(wallet.pay(to, value, token));
        emit Deployed(addr, signer);
    }
    
    // create2 directly from owner
    function deployWallet() public returns (address) {
        address addr = deployCreate2(msg.sender);
        SmartWallet wallet = SmartWallet(uint160(addr));
        require(wallet.initiate(msg.sender));
        emit Deployed(addr, msg.sender);
        return addr;
        
    }

    // get create2
    function getCreate2Address(address owner) public view returns (address) {
        bytes32 temp = keccak256(abi.encodePacked(bytes1(0xff), address(this), uint(owner), bytes32(keccak256(type(Proxy).creationCode))));
        address ret;
        uint mask = 2 ** 160 - 1;
        assembly {
            ret := and(temp, mask)
        }
        return ret;
    }
    
    function getCreate2Address() public view returns (address) {
        return getCreate2Address(msg.sender);
    }
    
    function canDeploy(address owner) public view returns (bool inexistent) {
        address wallet = getCreate2Address(owner);
        assembly {
            inexistent := eq(extcodesize(wallet), 0)
        }
    }
    
    function canDeploy() public view returns (bool) {
        return canDeploy(msg.sender);
    }
    
    function recover(bytes32 messageHash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedMessageHash = keccak256(abi.encodePacked(prefix, messageHash));
        return ecrecover(prefixedMessageHash, v, r, s);
    }

}