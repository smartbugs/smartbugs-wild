// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.2;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts/MerkleProof.sol

pragma solidity 0.5.8;

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
    ) internal pure returns (bool) {
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

// File: contracts/V12Voting.sol

pragma solidity 0.5.8;



/**
 * @title VGT (Vault Guardian Token) voting smart contract.
 * @author https://peppersec.com
 * @notice This smart contract implements voting based on ERC20 token. One token equals one vote.
 * The voting goes up to date chosen by a voting creator. During the voting time, each token holder
 * can cast for one of three options: "No Change", "Dual token" and "Transaction Split". Read more
 * about options at https://voting.vault12.com.
 * @dev Voting creator deploys the contract Merkle Tree root and expiration date.
 * And then, each VGT holder whose included in the Merkle Tree can vote via `vote` method.
 */
contract V12Voting {
    using SafeMath for uint256;

    // soliditySha3('No Change')
    bytes32 constant public NO_CHANGE = 0x9c7e52ebd85b19725c2fa45fea14ef32d24aa2665b667e9be796bb2811b936fc;
    // soliditySha3('Dual Token')
    bytes32 constant public DUAL_TOKEN = 0x0524f98cf62601e849aa545adff164c0f9b0303697043eddaf6d59d4fb4e4736;
    // soliditySha3('Transaction Split')
    bytes32 constant public TX_SPLIT = 0x84501b56c2648bdca07999c3b30e6edba0fa8c3178028b395e92f9bb53b4beba;

    /// @dev The voting offers tree options only. Read more here https://voting.vault12.com
    mapping(bytes32 => bool) public votingOption;

    /// @dev IPFS hash of the published Merkle Tree that contains VGT holders.
    string public ipfs;

    /// @dev Stores vote of each holder.
    mapping (address => bytes32) public votes;
    mapping (bytes32 => uint256) public votingResult;

    /// @dev Date up to which votes are accepted (timestamp).
    uint256 public expirationDate;

    /// @dev Merkle Tree root loaded by the voting creator, which is base for voters' proofs.
    bytes32 public merkleTreeRoot;

    /// @dev The event is fired when a holder makes a choice.
    event NewVote(address indexed who, string vote, uint256 amount);

    /**
    * @dev V12Voting contract constructor.
    * @param _merkleTreeRoot Merkle Tree root of token holders.
    * @param _ipfs IPFS hash where the Merkle Tree is stored.
    * @param _expirationDate Date up to which votes are accepted (timestamp).
    */
    constructor(
      bytes32 _merkleTreeRoot,
      string memory _ipfs,
      uint256 _expirationDate
    ) public {
        require(_expirationDate > block.timestamp, "wrong expiration date");
        merkleTreeRoot = _merkleTreeRoot;
        ipfs = _ipfs;
        expirationDate = _expirationDate;

        votingOption[NO_CHANGE] = true;
        votingOption[DUAL_TOKEN] = true;
        votingOption[TX_SPLIT] = true;
    }

    /**
    * @dev V12Voting vote function.
    * @param _vote Holder's vote decision.
    * @param _amount Holder's voting power (VGT token amount).
    * @param _proof Array of hashes that proofs that a sender is in the Merkle Tree.
    */
    function vote(string calldata _vote, uint256 _amount, bytes32[] calldata _proof) external {
        require(canVote(msg.sender), "already voted");
        require(isVotingOpen(), "voting finished");
        bytes32 hashOfVote = keccak256(abi.encodePacked(_vote));
        require(votingOption[hashOfVote], "invalid vote option");
        bytes32 _leaf = keccak256(abi.encodePacked(keccak256(abi.encode(msg.sender, _amount))));
        require(verify(_proof, merkleTreeRoot, _leaf), "the proof is wrong");

        votes[msg.sender] = hashOfVote;
        votingResult[hashOfVote] = votingResult[hashOfVote].add(_amount);

        emit NewVote(msg.sender, _vote, _amount);
    }

    /**
    * @dev Returns current results of the voting. All the percents have 2 decimal places.
    * e.g. value 1337 has to be interpreted as 13.37%
    * @param _expectedVotingAmount Total amount of tokens of all the holders.
    * @return noChangePercent Percent of votes casted for "No Change" option.
    * @return noChangeVotes Amount of tokens casted for "No Change" option.
    * @return dualTokenPercent Percent of votes casted for "Dual Token" option.
    * @return dualTokenVotes Amount of tokens casted for "Dual Token" option.
    * @return txSplitPercent Percent of votes casted for "Transaction Split" option.
    * @return txSplitVotes Amount of tokens casted for "Transaction Split" option.
    * @return totalVoted Total amount of tokens voted.
    * @return turnoutPercent Percent of votes casted so far.
    */
    function votingPercentages(uint256 _expectedVotingAmount) external view returns(
        uint256 noChangePercent,
        uint256 noChangeVotes,
        uint256 dualTokenPercent,
        uint256 dualTokenVotes,
        uint256 txSplitPercent,
        uint256 txSplitVotes,
        uint256 totalVoted,
        uint256 turnoutPercent
    ) {
        noChangeVotes = votingResult[NO_CHANGE];
        dualTokenVotes = votingResult[DUAL_TOKEN];
        txSplitVotes = votingResult[TX_SPLIT];
        totalVoted = noChangeVotes.add(dualTokenVotes).add(txSplitVotes);

        uint256 oneHundredPercent = 10000;
        noChangePercent = noChangeVotes.mul(oneHundredPercent).div(totalVoted);
        dualTokenPercent = dualTokenVotes.mul(oneHundredPercent).div(totalVoted);
        txSplitPercent = oneHundredPercent.sub(noChangePercent).sub(dualTokenPercent);

        turnoutPercent = totalVoted.mul(oneHundredPercent).div(_expectedVotingAmount);

    }

    /**
    * @dev Returns true if the voting is open.
    * @return if the holders still can vote.
    */
    function isVotingOpen() public view returns(bool) {
        return block.timestamp <= expirationDate;
    }

    /**
    * @dev Returns true if the holder has not voted yet. Notice, it does not check
    the `_who` in the Merkle Tree.
    * @param _who Holder address to check.
    * @return if the holder can vote.
    */
    function canVote(address _who) public view returns(bool) {
        return votes[_who] == bytes32(0);
    }

    /**
    * @dev Allows to verify Merkle Tree proof.
    * @param _proof Array of hashes that proofs that the `_leaf` is in the Merkle Tree.
    * @param _root Merkle Tree root.
    * @param _leaf Bottom element of the Merkle Tree.
    * @return verification result (true of false).
    */
    function verify(bytes32[] memory _proof, bytes32 _root, bytes32 _leaf) public pure returns (bool) {
        return MerkleProof.verify(_proof, _root, _leaf);
    }
}