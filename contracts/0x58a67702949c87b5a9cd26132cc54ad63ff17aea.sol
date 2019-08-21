pragma solidity ^0.5.0;

/**
 * @title MerkleProof
 * @dev Merkle proof verification based on
 * https://github.com/ameensol/merkle-tree-solidity/blob/master/src/MerkleProof.sol
 */
library MerkleProof {
  /**
   * @dev Verifies a Merkle proof proving the existence of a leaf in a Merkle tree. Assumes that each pair of leaves
   * and each pair of pre-images are sorted.
   * @param proof Merkle proof containing sibling hashes on the branch from the leaf to the root of the Merkle tree
   * @param root Merkle root
   * @param leaf Leaf of Merkle tree
   */
  function verify(
    bytes32[] memory proof,
    bytes32 root,
    bytes32 leaf
  )
    internal
    pure
    returns (bool)
  {
    bytes32 computedHash = leaf;

    for (uint256 i = 0; i < proof.length; i++) {
      bytes32 proofElement = proof[i];

      if (computedHash < proofElement) {
        // Hash(current computed hash + current element of the proof)
        computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
      } else {
        // Hash(current element of the proof + current computed hash)
        computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
      }
    }

    // Check if the computed hash (root) is equal to the provided root
    return computedHash == root;
  }
}


interface IERC20 {
  function transfer(address to, uint256 value) external returns (bool);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);
}

/**
 * @title MerkleProof
 * @dev Merkle proof verification based on
 * https://github.com/ameensol/merkle-tree-solidity/blob/master/src/MerkleProof.sol
 */
contract MerkleProofAirdrop {
  event Drop(string ipfs, address indexed rec, uint amount);

  struct Airdrop {
    address owner;
    bytes32 root;
    address tokenAddress;
    uint total;
    uint claimed;
    mapping(address => bool) claimedRecipients;
  }

  mapping(bytes32 => Airdrop) public airdrops;
  address payable public owner;

  constructor(address payable _owner) public {
    owner = _owner;
  }

  function createNewAirdrop(
      bytes32 _root,
      address _tokenAddress,
      uint _total,
      string memory _ipfs
    ) public payable {
    require(msg.value >= 0.2 ether);
    bytes32 ipfsHash = keccak256(abi.encodePacked(_ipfs));
    IERC20 token = IERC20(_tokenAddress);
    require(token.allowance(msg.sender, address(this)) >= _total, "this contract must be allowed to spend tokens");

    airdrops[ipfsHash] = Airdrop({
      owner: msg.sender,
      root: _root,
      tokenAddress: _tokenAddress,
      total: _total,
      claimed: 0
    });
    owner.transfer(address(this).balance);
  }

  function cancelAirdrop(string memory _ipfs) public {
    bytes32 ipfsHash = keccak256(abi.encodePacked(_ipfs));
    Airdrop storage airdrop = airdrops[ipfsHash];
    require(msg.sender == airdrop.owner);
    uint left = airdrop.total - airdrop.claimed;
    require(left > 0);

    IERC20 token = IERC20(airdrop.tokenAddress);
    require(token.balanceOf(address(this)) >= left, "not enough tokens");
    token.transfer(msg.sender, left);

  }

  function drop(bytes32[] memory proof, address _recipient, uint256 _amount, string memory _ipfs) public {
    bytes32 hash = keccak256(abi.encode(_recipient, _amount));
    bytes32 leaf = keccak256(abi.encode(hash));
    bytes32 ipfsHash = keccak256(abi.encodePacked(_ipfs));
    Airdrop storage airdrop = airdrops[ipfsHash];

    require(verify(proof, airdrop.root, leaf));
    require(airdrop.claimedRecipients[_recipient] == false, "double spend");
    airdrop.claimedRecipients[_recipient] = true;
    airdrop.claimed += _amount;

    IERC20 token = IERC20(airdrop.tokenAddress);
    require(token.allowance(airdrop.owner, address(this)) >= _amount, "this contract must be allowed to spend tokens");
    token.transferFrom(airdrop.owner, _recipient, _amount);

    // transfer tokens
    emit Drop(_ipfs, _recipient, _amount);
  }

  function verify(
    bytes32[] memory proof,
    bytes32 root,
    bytes32 leaf
  )
    public
    pure
    returns (bool)
  {
    return MerkleProof.verify(proof, root, leaf);
  }

}