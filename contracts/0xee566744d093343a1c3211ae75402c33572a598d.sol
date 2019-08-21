/**
  * The Movement
  * Decentralized Autonomous Organization
  */
  
pragma solidity ^0.4.18;

contract MovementVoting {
    mapping(address => int256) public votes;
    address[] public voters;
    uint256 public endBlock;
	address public admin;
	
    event onVote(address indexed voter, int256 indexed proposalId);
    event onUnVote(address indexed voter, int256 indexed proposalId);

    function MovementVoting(uint256 _endBlock) {
        endBlock = _endBlock;
		admin = msg.sender;
    }

	function changeEndBlock(uint256 _endBlock)
	onlyAdmin {
		endBlock = _endBlock;
	}

    function vote(int256 proposalId) {

        require(msg.sender != address(0));
        require(proposalId > 0);
        require(endBlock == 0 || block.number <= endBlock);
        if (votes[msg.sender] == 0) {
            voters.push(msg.sender);
        }

        votes[msg.sender] = proposalId;

        onVote(msg.sender, proposalId);
    }

    function unVote() {

        require(msg.sender != address(0));
        require(votes[msg.sender] > 0);
        int256 proposalId = votes[msg.sender];
		votes[msg.sender] = -1;
        onUnVote(msg.sender, proposalId);
    }

    function votersCount()
    constant
    returns(uint256) {
        return voters.length;
    }

    function getVoters(uint256 offset, uint256 limit)
    constant
    returns(address[] _voters, int256[] _proposalIds) {

        if (offset < voters.length) {
            uint256 resultLength = limit;
            uint256 index = 0;

         
            if (voters.length - offset < limit) {
                resultLength = voters.length - offset;
            }

            _voters = new address[](resultLength);
            _proposalIds = new int256[](resultLength);

            for(uint256 i = offset; i < offset + resultLength; i++) {
                _voters[index] = voters[i];
                _proposalIds[index] = votes[voters[i]];
                index++;
            }

            return (_voters, _proposalIds);
        }
    }

	modifier onlyAdmin() {
		if (msg.sender != admin) revert();
		_;
	}
}