pragma solidity ^0.5.2;

// File: @gnosis.pm/dx-contracts/contracts/base/AuctioneerManaged.sol

contract AuctioneerManaged {
    // auctioneer has the power to manage some variables
    address public auctioneer;

    function updateAuctioneer(address _auctioneer) public onlyAuctioneer {
        require(_auctioneer != address(0), "The auctioneer must be a valid address");
        auctioneer = _auctioneer;
    }

    // > Modifiers
    modifier onlyAuctioneer() {
        // Only allows auctioneer to proceed
        // R1
        // require(msg.sender == auctioneer, "Only auctioneer can perform this operation");
        require(msg.sender == auctioneer, "Only the auctioneer can nominate a new one");
        _;
    }
}

// File: @gnosis.pm/dx-contracts/contracts/base/TokenWhitelist.sol

contract TokenWhitelist is AuctioneerManaged {
    // Mapping that stores the tokens, which are approved
    // Only tokens approved by auctioneer generate frtToken tokens
    // addressToken => boolApproved
    mapping(address => bool) public approvedTokens;

    event Approval(address indexed token, bool approved);

    /// @dev for quick overview of approved Tokens
    /// @param addressesToCheck are the ERC-20 token addresses to be checked whether they are approved
    function getApprovedAddressesOfList(address[] calldata addressesToCheck) external view returns (bool[] memory) {
        uint length = addressesToCheck.length;

        bool[] memory isApproved = new bool[](length);

        for (uint i = 0; i < length; i++) {
            isApproved[i] = approvedTokens[addressesToCheck[i]];
        }

        return isApproved;
    }
    
    function updateApprovalOfToken(address[] memory token, bool approved) public onlyAuctioneer {
        for (uint i = 0; i < token.length; i++) {
            approvedTokens[token[i]] = approved;
            emit Approval(token[i], approved);
        }
    }

}

// File: contracts/whitelisting/BasicTokenWhitelist.sol

contract BasicTokenWhitelist is TokenWhitelist {
    constructor() public {
        auctioneer = msg.sender;
    }
}