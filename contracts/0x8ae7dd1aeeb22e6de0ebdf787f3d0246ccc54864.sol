pragma solidity ^0.4.19;

/**
 *  MXL PRE SALE CONTRACTS
 * 
 *  Adapted from SIKOBA PRE SALE CONTRACTS
 *
**/

/**
 * SIKOBA PRE SALE CONTRACTS
 *
 * Version 0.1
 *
 * Author Roland Kofler, Alex Kampa, Bok 'BokkyPooBah' Khoo
 *
 * MIT LICENSE Copyright 2017 Sikoba Ltd
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 **/

/**
 *
 * Important information about the MXL Token pre sale
 *
 * For details about the MXL token pre sale, and in particular to find out
 * about risks and limitations, please visit:
 *
 * https://marketxl.io/en/pre-sale/
 *
 **/


contract Owned {
    address public owner;

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }
}

/// ----------------------------------------------------------------------------------------
/// @title MXL PRE SALE CONTRACT
/// @author Carlos Afonso
/// @dev Changes to this contract will invalidate any security audits done before.
/// It is MANDATORY to protocol audits in the "Security reviews done" section
///  # Security checklists to use in each review:
///  - Consensys checklist https://github.com/ConsenSys/smart-contract-best-practices
///  - Roland Kofler's checklist https://github.com/rolandkofler/ether-security
///  - Read all of the code and use creative and lateral thinking to discover bugs
///  # Security reviews done:
///  Date         Auditors       Short summary of the review executed
///  Mar 03 2017 - Roland Kofler  - NO SECURITY REVIEW DONE
///  Mar 07 2017 - Roland Kofler, - Informal Security Review; added overflow protections;
///                Alex Kampa       fixed wrong inequality operators; added maximum amount
///                                 per transactions
///  Mar 07 2017 - Alex Kampa     - Some code clean up; removed restriction of
///                                 MINIMUM_PARTICIPATION_AMOUNT for preallocations
///  Mar 08 2017 - Bok Khoo       - Complete security review and modifications
///  Mar 09 2017 - Roland Kofler  - Check the diffs between MAR 8 and MAR 7 versions
///  Mar 12 2017 - Bok Khoo       - Renamed TOTAL_PREALLOCATION_IN_WEI
///                                 to TOTAL_PREALLOCATION.
///                                 Removed isPreAllocation from addBalance(...)
///  Mar 13 2017 - Bok Khoo       - Made dates in comments consistent
///  Apr 05 2017 - Roland Kofler  - removed the necessity of pre sale end before withdrawing
///                                 thus price drops during pre sale can be mitigated
///  Apr 24 2017 - Alex Kampa     - edited constants and added pre allocation amounts
///
///  Dec 22 2017 - Carlos Afonso  - edited constants removed pre allocation amounts
///                                 
/// ----------------------------------------------------------------------------------------
contract MXLPresale is Owned {
    // -------------------------------------------------------------------------------------
    // TODO Before deployment of contract to Mainnet
    // 1. Confirm MINIMUM_PARTICIPATION_AMOUNT and MAXIMUM_PARTICIPATION_AMOUNT below
    // 2. Adjust PRESALE_MINIMUM_FUNDING and PRESALE_MAXIMUM_FUNDING to desired EUR
    //    equivalents
    // 3. Adjust PRESALE_START_DATE and confirm the presale period
    // 4. Test the deployment to a dev blockchain or Testnet to confirm the constructor
    //    will not run out of gas as this will vary with the number of preallocation
    //    account entries
    // 5. A stable version of Solidity has been used. Check for any major bugs in the
    //    Solidity release announcements after this version.    
    // -------------------------------------------------------------------------------------

    // Keep track of the total funding amount
    uint256 public totalFunding;

    // Minimum and maximum amounts per transaction for public participants
    uint256 public constant MINIMUM_PARTICIPATION_AMOUNT = 0.009 ether; 
    uint256 public constant MAXIMUM_PARTICIPATION_AMOUNT = 90 ether;

    // Minimum and maximum goals of the pre sale
	// Based on Budget of 300k€ to 450k€ at 614€ per ETH on 2018-12-28
    uint256 public constant PRESALE_MINIMUM_FUNDING = 486 ether;
    uint256 public constant PRESALE_MAXIMUM_FUNDING = 720 ether;
	

    // Total preallocation in wei
    //uint256 public constant TOTAL_PREALLOCATION = 999.999 ether; // no preallocation

    // Public pre sale periods  
	// Starts 2018-01-03T00:00:00+00:00 in ISO 8601
    uint256 public constant PRESALE_START_DATE = 1514937600;
	
	// Ends 2018-03-27T18:00:00+00:00 in ISO 8601
    uint256 public constant PRESALE_END_DATE = 1522173600;
	
	// Limit 30% Bonus 2018-02-18T00:00:00+00:00 in ISO 8601
	//uint256 public constant PRESALE_30BONUS_END = 1518912000;  // for reference only
	// Limit 15% Bonus 2018-03-09T00:00:00+00:00 in ISO 8601
	//uint256 public constant PRESALE_15BONUS_END = 1520553000;  // for reference only
	

    // Owner can clawback after a date in the future, so no ethers remain
    // trapped in the contract. This will only be relevant if the
    // minimum funding level is not reached
    // 2018-04-27T00:00:00+00:00 in ISO 8601
    uint256 public constant OWNER_CLAWBACK_DATE = 1524787200; 

    /// @notice Keep track of all participants contributions, including both the
    ///         preallocation and public phases
    /// @dev Name complies with ERC20 token standard, etherscan for example will recognize
    ///      this and show the balances of the address
    mapping (address => uint256) public balanceOf;

    /// @notice Log an event for each funding contributed during the public phase
    /// @notice Events are not logged when the constructor is being executed during
    ///         deployment, so the preallocations will not be logged
    event LogParticipation(address indexed sender, uint256 value, uint256 timestamp);

    function MXLPresale () public payable {
		// no preallocated 
        //assertEquals(TOTAL_PREALLOCATION, msg.value);
        // Pre-allocations
        //addBalance(0xe902741cD4666E4023b7E3AB46D3DE2985c996f1, 0.647 ether);
        //addBalance(0x98aB52E249646cA2b013aF8F2E411bB90C1c9b4d, 66.98333494 ether);
        //addBalance(0x96050f871811344Dd44C2F5b7bc9741Dff296f5e, 10 ether);
        //assertEquals(TOTAL_PREALLOCATION, totalFunding);
    }

    /// @notice A participant sends a contribution to the contract's address
    ///         between the PRESALE_STATE_DATE and the PRESALE_END_DATE
    /// @notice Only contributions between the MINIMUM_PARTICIPATION_AMOUNT and
    ///         MAXIMUM_PARTICIPATION_AMOUNT are accepted. Otherwise the transaction
    ///         is rejected and contributed amount is returned to the participant's
    ///         account
    /// @notice A participant's contribution will be rejected if the pre sale
    ///         has been funded to the maximum amount
    function () public payable {
        // A participant cannot send funds before the pre sale start date
        if (now < PRESALE_START_DATE) revert();
        // A participant cannot send funds after the pre sale end date
        if (now > PRESALE_END_DATE) revert();
        // A participant cannot send less than the minimum amount
        if (msg.value < MINIMUM_PARTICIPATION_AMOUNT) revert();
        // A participant cannot send more than the maximum amount
        if (msg.value > MAXIMUM_PARTICIPATION_AMOUNT) revert();
        // A participant cannot send funds if the pres ale has been reached the maximum
        // funding amount
        if (safeIncrement(totalFunding, msg.value) > PRESALE_MAXIMUM_FUNDING) revert();
        // Register the participant's contribution
        addBalance(msg.sender, msg.value);
    }

    /// @notice The owner can withdraw ethers already during pre sale,
    ///         only if the minimum funding level has been reached
    function ownerWithdraw(uint256 _value) external onlyOwner {
        // The owner cannot withdraw if the pre sale did not reach the minimum funding amount
        if (totalFunding < PRESALE_MINIMUM_FUNDING) revert();
        // Withdraw the amount requested
        if (!owner.send(_value)) revert();
    }

    /// @notice The participant will need to withdraw their funds from this contract if
    ///         the pre sale has not achieved the minimum funding level
    function participantWithdrawIfMinimumFundingNotReached(uint256 _value) external {
        // Participant cannot withdraw before the pre sale ends
        if (now <= PRESALE_END_DATE) revert();
        // Participant cannot withdraw if the minimum funding amount has been reached
        if (totalFunding >= PRESALE_MINIMUM_FUNDING) revert();
        // Participant can only withdraw an amount up to their contributed balance
        if (balanceOf[msg.sender] < _value) revert();
        // Participant's balance is reduced by the claimed amount.
        balanceOf[msg.sender] = safeDecrement(balanceOf[msg.sender], _value);
        // Send ethers back to the participant's account
        if (!msg.sender.send(_value)) revert();
    }

    /// @notice The owner can clawback any ethers after a date in the future, so no
    ///         ethers remain trapped in this contract. This will only be relevant
    ///         if the minimum funding level is not reached
    function ownerClawback() external onlyOwner {
        // The owner cannot withdraw before the clawback date
        if (now < OWNER_CLAWBACK_DATE) revert();
        // Send remaining funds back to the owner
        if (!owner.send(this.balance)) revert();
    }

    /// @dev Keep track of participants contributions and the total funding amount
    function addBalance(address participant, uint256 value) private {
        // Participant's balance is increased by the sent amount
        balanceOf[participant] = safeIncrement(balanceOf[participant], value);
        // Keep track of the total funding amount
        totalFunding = safeIncrement(totalFunding, value);
        // Log an event of the participant's contribution
        LogParticipation(participant, value, now);
    }

    /// @dev Throw an exception if the amounts are not equal
    function assertEquals(uint256 expectedValue, uint256 actualValue) private pure {
        if (expectedValue != actualValue) revert();
    }

    /// @dev Add a number to a base value. Detect overflows by checking the result is larger
    ///      than the original base value.
    function safeIncrement(uint256 base, uint256 increment) private pure returns (uint256) {
        uint256 result = base + increment;
        if (result < base) revert();
        return result;
    }

    /// @dev Subtract a number from a base value. Detect underflows by checking that the result
    ///      is smaller than the original base value
    function safeDecrement(uint256 base, uint256 increment) private pure returns (uint256) {
        uint256 result = base - increment;
        if (result > base) revert();
        return result;
    }
}