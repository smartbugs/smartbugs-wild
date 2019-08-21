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

contract Governance {
    using SafeMath for uint256;
    mapping(bytes32 => Proposal) public proposals;
    bytes32[] public allProposals;
    mapping(address => bool) public isVoter;
    uint256 public voters;

    struct Proposal {
        bool finished;
        uint256 yesVotes;
        uint256 noVotes;
        mapping(address => bool) voted;
        address targetContract;
        bytes transaction;
    }

    event ProposalStarted(bytes32 proposalHash);
    event ProposalFinished(bytes32 proposalHash);
    event ProposalExecuted(bytes32 proposalHash);
    event Vote(bytes32 proposalHash, bool vote, uint256 yesVotes, uint256 noVotes, uint256 voters);
    event VoterAdded(address voter);
    event VoterDeleted(address voter);

    constructor() public {
        isVoter[msg.sender] = true;
        voters = 1;
    }

    modifier onlyVoter() {
        require(isVoter[msg.sender], "Should be voter");
        _;
    }

    modifier onlyMe() {
        require(msg.sender == address(this), "Call via Governance");
        _;
    }

    function newProposal( address _targetContract, bytes memory _transaction ) public onlyVoter {
        require(_targetContract != address(0), "Address must be non-zero");
        require(_transaction.length >= 4, "Tx must be 4+ bytes");
        bytes32 _proposalHash = keccak256(abi.encodePacked(_targetContract, _transaction, now));
        require(proposals[_proposalHash].transaction.length == 0, "The poll has already been initiated");
        proposals[_proposalHash].targetContract = _targetContract;
        proposals[_proposalHash].transaction = _transaction;
        allProposals.push(_proposalHash);
        emit ProposalStarted(_proposalHash);
    }

    function vote(bytes32 _proposalHash, bool _yes) public onlyVoter { // solhint-disable code-complexity
        require(!proposals[_proposalHash].voted[msg.sender], "Already voted");
        require(!proposals[_proposalHash].finished, "Already finished");
        require(voters > 0, "Should have one or more voters");
        if (_yes) {
            proposals[_proposalHash].yesVotes = proposals[_proposalHash].yesVotes.add(1);
        } else {
            proposals[_proposalHash].noVotes = proposals[_proposalHash].noVotes.add(1);
        }
        emit Vote(_proposalHash, _yes, proposals[_proposalHash].yesVotes, proposals[_proposalHash].noVotes, voters);
        proposals[_proposalHash].voted[msg.sender] = true;
        if (voters == 1) {
            if (proposals[_proposalHash].yesVotes > 0) {
                executeProposal(_proposalHash);
            }
            finishProposal(_proposalHash);
            return();
        }
        if (voters == 2) {
            if (proposals[_proposalHash].yesVotes == 2) {
                executeProposal(_proposalHash);
                finishProposal(_proposalHash);
            } else if (proposals[_proposalHash].noVotes == 1) {
                finishProposal(_proposalHash);
            }
            return();
        }
        if (proposals[_proposalHash].yesVotes > voters.div(2)) {
            executeProposal(_proposalHash);
            finishProposal(_proposalHash);
            return();
        } else if (proposals[_proposalHash].noVotes > voters.div(2)) {
            finishProposal(_proposalHash);
            return();
        }
    }

    function addVoter(address _address) public onlyMe {
        require(_address != address(0), "Need non-zero address");
        require(!isVoter[_address], "Already in voters list");
        isVoter[_address] = true;
        voters = voters.add(1);
        emit VoterAdded(_address);
    }

    function delVoter(address _address) public onlyMe {
        require(msg.sender == address(this), "Call via Governance procedure");
        require(isVoter[_address], "Not in voters list");
        isVoter[_address] = false;
        voters = voters.sub(1);
        emit VoterDeleted(_address);
    }

    function executeProposal(bytes32 _proposalHash) internal {
        require(!proposals[_proposalHash].finished, "Already finished");
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returnData) = address(
            proposals[_proposalHash].targetContract).call(proposals[_proposalHash].transaction
        );
        require(success, string(returnData));
        emit ProposalExecuted(_proposalHash);
    }

    function finishProposal(bytes32 _proposalHash) internal {
        require(!proposals[_proposalHash].finished, "Already finished");
        proposals[_proposalHash].finished = true;
        emit ProposalFinished(_proposalHash);
    }
}