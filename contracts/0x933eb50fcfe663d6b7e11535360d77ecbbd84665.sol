pragma solidity ^0.4.24;

contract ICollectable {

    function mint(uint32 delegateID, address to) public returns (uint);

    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

    function safeTransferFrom(address from, address to, uint256 tokenId) public;

}

contract Ownable {

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

}

contract SimpleNonceMinter is Ownable {

    ICollectable collectable;
    uint32 delegateID;
    mapping(uint => bool) public nonces;
    mapping(address => bool) public signers;

    constructor(ICollectable _collectable, uint32 _delegateID) public {
        collectable = _collectable;
        delegateID = _delegateID;
    }

    function setCanSign(address _signer, bool _can) public onlyOwner {
        signers[_signer] = _can;
    }

    function mint(bytes memory sig, address to, uint nonce, bool add27) public returns (uint) {
        require(!nonces[nonce], "can only claim once");
        bytes32 message = prefixed(keccak256(abi.encodePacked(address(this), nonce)));
        require(signers[getSigner(message, sig, add27)], "must be signed by approved signer");
        nonces[nonce] = true;
        return collectable.mint(delegateID, to);
    }

    function getSigner(bytes32 message, bytes memory sig, bool add27) internal pure returns (address) {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        if (add27) {
            v += 27;
        }

        return ecrecover(message, v, r, s);
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65, "incorrect signature length");

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

}