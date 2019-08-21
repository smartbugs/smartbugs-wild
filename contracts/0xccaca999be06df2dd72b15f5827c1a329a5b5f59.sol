pragma solidity ^0.5.2;

// File: /Users/anxo/code/gnosis/dx-price-oracle/contracts/IDutchX.sol

interface DutchX {

    function approvedTokens(address)
        external
        view
        returns (bool);

    function getAuctionIndex(
        address token1,
        address token2
    )
        external
        view
        returns (uint auctionIndex);

    function getClearingTime(
        address token1,
        address token2,
        uint auctionIndex
    )
        external
        view
        returns (uint time);

    function getPriceInPastAuction(
        address token1,
        address token2,
        uint auctionIndex
    )
        external
        view
        // price < 10^31
        returns (uint num, uint den);
}

// File: /Users/anxo/code/gnosis/dx-price-oracle/contracts/DutchXPriceOracle.sol

/// @title A contract that uses the DutchX platform to provide a reliable price oracle for any token traded on the DutchX
/// @author Dominik Teiml - dominik@gnosis.pm

contract DutchXPriceOracle {

    DutchX public dutchX;
    address public ethToken;
    
    /// @notice constructor takes DutchX proxy address and WETH token address
    /// @param _dutchX address of DutchX proxy
    /// @param _ethToken address of WETH token
    constructor(DutchX _dutchX, address _ethToken)
        public
    {
        dutchX = _dutchX;
        ethToken = _ethToken;
    }

    /// @notice Get price, in ETH, of an ERC-20 token `token.address()`
    /// @param token address of ERC-20 token in question
    /// @return The numerator of the price of the token
    /// @return The denominator of the price of the token
    function getPrice(address token)
        public
        view
        returns (uint num, uint den)
    {
        (num, den) = getPriceCustom(token, 0, true, 4.5 days, 9);
    }

    /// @dev More fine-grained price oracle for token `token.address()`
    /// @param token address of ERC-20 token in question
    /// @param time 0 for current price, a Unix timestamp for a price at any point in time
    /// @param requireWhitelisted Require the token be whitelisted on the DutchX? (Unwhitelisted addresses might not conform to the ERC-20 standard and/or might be malicious)
    /// @param maximumTimePeriod maximum time period between clearing time of last auction and `time`
    /// @param numberOfAuctions how many auctions to consider. Contract is safe only for odd numbers.
    /// @return The numerator of the price of the token
    /// @return The denominator of the price of the token
    function getPriceCustom(
        address token,
        uint time,
        bool requireWhitelisted,
        uint maximumTimePeriod,
        uint numberOfAuctions
    )
        public
        view
        returns (uint num, uint den)
    {
        // Whitelist check
        if (requireWhitelisted && !isWhitelisted(token)) {
            return (0, 0);
        }

        address ethTokenMem = ethToken;

        uint auctionIndex;
        uint latestAuctionIndex = dutchX.getAuctionIndex(token, ethTokenMem);

        if (time == 0) {
            auctionIndex = latestAuctionIndex;
            time = now;
        } else {
            // We need to add one at the end, because the way getPricesAndMedian works, it starts from 
            // the previous auction (see below for why it does that)
            auctionIndex = computeAuctionIndex(token, 1, 
                latestAuctionIndex - 1, latestAuctionIndex - 1, time) + 1;
        }

        // Activity check
        uint clearingTime = dutchX.getClearingTime(token, ethTokenMem, auctionIndex - numberOfAuctions - 1);

        if (time - clearingTime > maximumTimePeriod) {
            return (0, 0);
        } else {
            (num, den) = getPricesAndMedian(token, numberOfAuctions, auctionIndex);
        }
    }

    /// @notice gets prices, starting 
    /// @dev search starts at auctionIndex - 1. The reason for this is we expect the most common use case to be the latest auction index and for that the clearingTime is not available yet. So we need to start at the one before
    /// @param token address of ERC-20 token in question
    /// @param numberOfAuctions how many auctions to consider. Contract is safe only for add numbers
    /// @param auctionIndex search will begin at auctionIndex - 1
    /// @return The numerator of the price of the token
    /// @return The denominator of the price of the token
    function getPricesAndMedian(
        address token,
        uint numberOfAuctions,
        uint auctionIndex
    )
        public
        view
        returns (uint, uint)
    {
        // This function repeatedly calls dutchX.getPriceInPastAuction
        // (which is a weighted average of the two closing prices for one auction pair)
        // and saves them in nums[] and dens[]
        // It keeps a linked list of indices of the sorted prices so that there is no array shifting
        // Whenever a new price is added, we traverse the indices until we find a smaller price
        // then we update the linked list in O(1)
        // (It could be viewed as a linked list version of insertion sort)

        uint[] memory nums = new uint[](numberOfAuctions);
        uint[] memory dens = new uint[](numberOfAuctions);
        uint[] memory linkedListOfIndices = new uint[](numberOfAuctions);
        uint indexOfSmallest;

        for (uint i = 0; i < numberOfAuctions; i++) {
            // Loop begins by calling auctionIndex - 1 and ends by calling auctionIndex - numberOfAcutions
            // That gives numberOfAuctions calls
            (uint num, uint den) = dutchX.getPriceInPastAuction(token, ethToken, auctionIndex - 1 - i);

            (nums[i], dens[i]) = (num, den);

            // We begin by comparing latest price to smallest price
            // Smallest price is given by prices[linkedListOfIndices.indexOfLargest]
            uint previousIndex;
            uint index = linkedListOfIndices[indexOfSmallest];

            for (uint j = 0; j < i; j++) {
                if (isSmaller(num, den, nums[index], dens[index])) {

                    // Update new term to point to next term
                    linkedListOfIndices[i] = index;

                    if (j == 0) {
                        // Loop is at first iteration
                        linkedListOfIndices[indexOfSmallest] = i;
                    } else {
                        // Update current term to point to new term
                        // Current term is given by 
                        linkedListOfIndices[previousIndex] = i;
                    }

                    break;
                }

                if (j == i - 1) {
                    // Loop is at last iteration
                    linkedListOfIndices[i] = linkedListOfIndices[indexOfSmallest];
                    linkedListOfIndices[index] = i;
                    indexOfSmallest = i;
                } else {
                    // Nothing happened, update temp vars and run body again
                    previousIndex = index;
                    index = linkedListOfIndices[index];
                }
            }
        }

        // Array is fully sorted

        uint index = indexOfSmallest;

        // Traverse array to find median
        for (uint i = 0; i < (numberOfAuctions + 1) / 2; i++) {
            index = linkedListOfIndices[index];
        }

        // We return floor-of-half value 
        // The reason is if we computed arithmetic average of the two middle values
        // as a traditional median does, that would increase the order of the numbers
        // DutchX price oracle gives a fraction with num & den at an order of 10^30
        // If instead of a/b we do (a/b + c/d)/2 = (ad+bc)/(2bd), we see the order
        // would become 10^60. That would increase chance of overflow in contracts 
        // that depend on this price oracle
        // This also means the Price Oracle is safe only for odd values of numberOfAuctions!

        return (nums[index], dens[index]);
    }

    /// @dev compute largest auctionIndex with clearing time smaller than desired time. Use case: user provides a time and this function will find the largest auctionIndex that had a cleared auction before that time. It is used to get historical price oracle values
    /// @param token address of ERC-20 token in question
    /// @param lowerBound lowerBound of result. Recommended that it is > 0, because 0th price is set by whoever adds token pair
    /// @param initialUpperBound initial upper bound when this recursive fn is called for the first time
    /// @param upperBound current upper bound of result
    /// @param time desired time
    /// @return largest auctionIndex s.t. clearingTime[auctionIndex] <= time
    function computeAuctionIndex(
        address token,
        uint lowerBound, 
        uint initialUpperBound,
        uint upperBound,
        uint time
    )
        public
        view
        returns (uint)
    {
        // computeAuctionIndex works by recursively lowering lower and upperBound
        // The result begins in [lowerBound, upperBound] (invariant)
        // If we never decrease the upperBound, it will stay in that range
        // If we ever decrease it, the result will be in [lowerBound, upperBound - 1]

        uint clearingTime;

        if (upperBound - lowerBound == 1) {
            // Recursion base case

            if (lowerBound <= 1) {
                clearingTime = dutchX.getClearingTime(token, ethToken, lowerBound); 

                if (time < clearingTime) {
                    revert("time too small");
                }
            }

            if (upperBound == initialUpperBound) {
                clearingTime = dutchX.getClearingTime(token, ethToken, upperBound);

                if (time < clearingTime) {
                    return lowerBound;
                } else {
                    // Can only happen if answer is initialUpperBound
                    return upperBound;
                }            
            } else {
                // In most cases, we'll have bounds [loweBound, loweBound + 1), which results in lowerBound
                return lowerBound;
            }
        }

        uint mid = (lowerBound + upperBound) / 2;
        clearingTime = dutchX.getClearingTime(token, ethToken, mid);

        if (time < clearingTime) {
            // Answer is in lower half
            return computeAuctionIndex(token, lowerBound, initialUpperBound, mid, time);
        } else if (time == clearingTime) {
            // We found answer
            return mid;
        } else {
            // Answer is in upper half
            return computeAuctionIndex(token, mid, initialUpperBound, upperBound, time);
        }
    }

    /// @notice compares two fractions and returns if first is smaller
    /// @param num1 Numerator of first fraction
    /// @param den1 Denominator of first fraction
    /// @param num2 Numerator of second fraction
    /// @param den2 Denominator of second fraction
    /// @return bool - whether first fraction is (strictly) smaller than second
    function isSmaller(uint num1, uint den1, uint num2, uint den2)
        public
        pure
        returns (bool)
    {
        // Safe math
        require(den1 != 0, "undefined fraction");
        require(den2 != 0, "undefined fraction");
        require(num1 * den2 / den2 == num1, "overflow");
        require(num2 * den1 / den1 == num2, "overflow");

        return (num1 * den2 < num2 * den1);
    }

    /// @notice determines whether token has been approved (whitelisted) on DutchX
    /// @param token address of ERC-20 token in question
    /// @return bool - whether token has been approved (whitelisted)
    function isWhitelisted(address token) 
        public
        view
        returns (bool) 
    {
        return dutchX.approvedTokens(token);
    }
}

// File: /Users/anxo/code/gnosis/dx-price-oracle/node_modules/@gnosis.pm/dx-contracts/contracts/base/AuctioneerManaged.sol

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

// File: contracts/WhitelistPriceOracle.sol

/// @title A DutchXPriceOracle that uses it's own whitelisted tokens instead of the ones of the DutchX
/// @author Angel Rodriguez - angel@gnosis.pm
contract WhitelistPriceOracle is TokenWhitelist, DutchXPriceOracle {
    constructor(DutchX _dutchX, address _ethToken, address _auctioneer)
        DutchXPriceOracle(_dutchX, _ethToken)
        public
    {
        auctioneer = _auctioneer;
    }

    function isWhitelisted(address token) 
        public
        view
        returns (bool) 
    {
        return approvedTokens[token];
    }
}