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

// File: contracts/whitelisting/FixedPriceOracle.sol

/**
 * @title An Ether-ERC20 token price oracle with an unmutable price
 * 
 * @dev The prices are initialized when configuring the contract, then you 
 *  freeze the contract disallowing any further modification.
 */

contract FixedPriceOracle {
    mapping(address => Price) public prices;
    bool public frozen;
    address public owner;
    TokenWhitelist public whitelist;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can do the operation");
        _;
    }

    modifier notFrozen() {
        require(!frozen, "The contract is frozen, not changes are allowed");
        _;
    }

    struct Price {
        uint numerator;
        uint denominator;
    }

    event PriceSet(address indexed token, uint numerator, uint denominator);

    event Freeze();

    constructor(address whitelistAddress) public {
        owner = msg.sender;
        whitelist = TokenWhitelist(whitelistAddress);
    }

    function hasReliablePrice(address token) public view returns (bool) {
        return prices[token].denominator != 0;
    }

    function getPrice(address token) public view returns (uint, uint) {
        bool approvedToken = whitelist.approvedTokens(token);

        if (approvedToken) {
            return getPriceValue(token);
        } else {
            return (0, 0);
        }

    }

    function getPriceValue(address token) public view returns (uint, uint) {
        Price memory price = prices[token];
        return (price.numerator, price.denominator);
    }

    function setPrices(address[] memory tokens, uint[] memory numerators, uint[] memory denominators)
        public
        onlyOwner
        notFrozen
    {
        for (uint i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            uint numerator = numerators[i];
            uint denominator = denominators[i];

            prices[token] = Price(numerator, denominator);
            emit PriceSet(token, numerator, denominator);
        }
    }

    function setPrice(address token, uint numerator, uint denominator) public onlyOwner notFrozen {
        prices[token] = Price(numerator, denominator);
        emit PriceSet(token, numerator, denominator);
    }

    function freeze() public onlyOwner {
        frozen = true;
        emit Freeze();
    }
}