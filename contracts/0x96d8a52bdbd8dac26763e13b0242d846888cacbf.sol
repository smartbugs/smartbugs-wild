pragma solidity ^0.5.0;

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

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address previousOwner, address newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/// @title Admin contract for KittyBounties. Holds owner-only functions to adjust contract-wide fees, change owners, etc.
/// @dev The owner is not capable of changing the address of the CryptoKitties Core contract once the contract has been deployed.
///  This prevents an attack vector where the owner could change the kittyCore contract once users had already deposited funds.
contract KittyBountiesAdmin is Ownable, Pausable {

    /* ****** */
    /* EVENTS */
    /* ****** */

    /// @dev This event is fired whenever the owner changes the successfulBountyFeeInBasisPoints.
    /// @param newSuccessfulBountyFeeInBasisPoints  The SuccessfulFee is expressed in basis points (hundredths of a percantage), 
    ///  and is charged when a bounty is successfully completed.
    event SuccessfulBountyFeeInBasisPointsUpdated(uint256 newSuccessfulBountyFeeInBasisPoints);

    /// @dev This event is fired whenever the owner changes the unsuccessfulBountyFeeInWei. 
    /// @param newUnsuccessfulBountyFeeInWei  The UnsuccessfulBountyFee is paid by the original bounty creator if the bounty expires 
    ///  without being completed. When a bounty is created, the bounty creator specifies how long the bounty is valid for. If the 
    ///  bounty is not fulfilled by this expiration date, the original creator can then freely withdraw their funds, minus the 
    ///  UnsuccessfulBountyFee, although the bounty is still fulfillable until the bounty creator withdraws their funds.
    event UnsuccessfulBountyFeeInWeiUpdated(uint256 newUnsuccessfulBountyFeeInWei);

    /// @dev This event is fired whenever the owner changes the maximumLockupDurationInBlocks. 
    /// @param newMaximumLockoutDurationInBlocks  To prevent users from accidentally locking up ether for an eternity, the lockout 
    ///  period of all bounties is capped using this variable, which is inially set to 4 weeks. This is measured in blocks, which 
    ///  are created roughly once every 15 seconds. If the community expresses that they would like a longer maximumLockoutDuration,
    ///  the creator will adjust this variable.
    event MaximumLockoutDurationInBlocksUpdated(uint256 newMaximumLockoutDurationInBlocks);

    /* ******* */
    /* STORAGE */
    /* ******* */

    /// @dev The total amount that the contract creator has earned from fees since they last withdrew. Storing the owner's earnings
    ///  saves gas rather than performing an additional transfer() call on every successful bounty.
    uint256 public totalOwnerEarningsInWei = 0;

    /// @dev If a bounty is successfully fulfilled, this fee applies before the remaining funds are sent to the successful bounty
    ///  hunter. This fee is measured in basis points (hundredths of a percent), and is taken out of the total value that the bounty
    ///  creator locked up in the contract when they created the bounty.
    uint256 public successfulBountyFeeInBasisPoints = 375;

    /// @dev If a bounty is not fulfilled after the lockup period has completed, a bounty creator can withdraw their funds and
    ///  invalidate the bounty, but they are charged this flat fee to do so. This fee is measured in wei.
    uint256 public unsuccessfulBountyFeeInWei = 0.008 ether;

    /// @dev To prevent users from accidentally locking up ether for an eternity, the lockout period of all bounties is capped
    ///  using this variable, which is inially set to 4 weeks. This is measured in blocks, which are created roughly once every 15 seconds. 
    ///  If the community expresses that they would like a longer maximumLockoutDuration, the creator will adjust this variable.
    /// @notice This is initalized to 4 weeks in blocks (161280 = 4 (weeks) * 7 (days) * 24 (hours) * 60 (minutes) * 4 (blocks per minute))
    ///  Note that this rests on the assumption that each block takes 15 seconds to propagate. This maximum lockout can be changed by the owner
    ///  if this assumption is invalidated.
    uint256 public maximumLockoutDurationInBlocks = 161280; 

    /* ********* */
    /* CONSTANTS */
    /* ********* */

    /// @dev The owner is not capable of changing the address of the CryptoKitties Core contract once the contract has been deployed.
    ///  This prevents an attack vector where the owner could change the kittyCore contract once users had already deposited funds.
    ///  Since the CryptoKitties Core contract has the ability to migrate to a new contract, if Dapper Labs Inc. ever chooses to migrate
    ///  contract, this contract will have to be frozen, and users will be allowed to withdraw their funds without paying any fees.
    address public kittyCoreAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    KittyCore kittyCore;

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /// @dev The owner is not capable of changing the address of the CryptoKitties Core contract once the contract has been deployed.
    ///  This prevents an attack vector where the owner could change the kittyCore contract once users had already deposited funds.
    constructor() internal {
        kittyCore = KittyCore(kittyCoreAddress);
    }

    /// @notice Sets the successfulBountyFeeInBasisPoints value (in basis points). Any bounties that are successfully fulfilled 
    ///  will have this fee deducted from amount sent to the bounty hunter.
    /// @notice Only callable by the owner.
    /// @dev As this configuration is a basis point, the value to set must be less than or equal to 10000.
    /// @param _newSuccessfulBountyFeeInBasisPoints  The successfulBountyFeeInBasisPoints value to set (measured in basis points).
    function setSuccessfulBountyFeeInBasisPoints(uint256 _newSuccessfulBountyFeeInBasisPoints) external onlyOwner {
        require(_newSuccessfulBountyFeeInBasisPoints <= 10000, 'new successful bounty fee must be in basis points (hundredths of a percent), not wei');
        successfulBountyFeeInBasisPoints = _newSuccessfulBountyFeeInBasisPoints;
        emit SuccessfulBountyFeeInBasisPointsUpdated(_newSuccessfulBountyFeeInBasisPoints);
    }

    /// @notice Sets the unsuccessfulBountyFeeInWei value. If a bounty is still unfulfilled once the minimum number of blocks has passed,
    ///  an owner can withdraw the locked ETH. If they do so, this fee is deducted from the amount that they withdraw.
    /// @notice Only callable by the owner.
    /// @param _newUnsuccessfulBountyFeeInWei  The unsuccessfulBountyFeeInWei value to set (measured in wei).
    function setUnsuccessfulBountyFeeInWei(uint256 _newUnsuccessfulBountyFeeInWei) external onlyOwner {
        unsuccessfulBountyFeeInWei = _newUnsuccessfulBountyFeeInWei;
        emit UnsuccessfulBountyFeeInWeiUpdated(_newUnsuccessfulBountyFeeInWei);
    }

    /// @notice Sets the maximumLockoutDurationInBlocks value. To prevent users from accidentally locking up ether for an eternity, the 
    ///  lockout period of all bounties is capped using this variable, which is inially set to 4 weeks. This is measured in blocks, which 
    ///  are created roughly once every 15 seconds. If the assumption of 1 block every 15 seconds is ever invalidated, the owner is able
    ///  to change the maximumLockoutDurationInBlocks using this function.
    /// @notice Only callable by the owner.
    /// @param _newMaximumLockoutDurationInBlocks  The maximumLockoutDurationInBlocks value to set (measured in blocks).
    function setMaximumLockoutDurationInBlocks(uint256 _newMaximumLockoutDurationInBlocks) external onlyOwner {
        maximumLockoutDurationInBlocks = _newMaximumLockoutDurationInBlocks;
        emit MaximumLockoutDurationInBlocksUpdated(_newMaximumLockoutDurationInBlocks);
    }

    /// @notice Withdraws the fees that have been earned by the contract owner.
    /// @notice Only callable by the owner.
    function withdrawOwnerEarnings() external onlyOwner {
        uint256 balance = totalOwnerEarningsInWei;
        totalOwnerEarningsInWei = 0;
        msg.sender.transfer(balance);
    }

    /// @dev By calling 'revert' in the fallback function, we prevent anyone from accidentally sending funds directly to this contract.
    function() external payable {
        revert();
    }
}

/// @title Interface for interacting with the CryptoKitties Core contract created by Dapper Labs Inc.
contract KittyCore {
    function getKitty(uint _id) public returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
    );
    function ownerOf(uint256 _tokenId) public view returns (address owner);
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    mapping (uint256 => address) public kittyIndexToApproved;
}

/// @title Main contract for KittyBounties. This contract manages funds from creation to fulfillment for bounties.
/// @notice Once created, a bounty locks up ether. Optionally, the bounty creator may specify a number of blocks 
///  to "lock" their bounty, thus preventing them from being able to cancel their bounty or withdraw their ether 
///  until that number of blocks have passed. This guarantees a time period for bounty hunters to attempt to 
///  breed for a cat with the specified cattributes, generation, and/or cooldown. This option is included since 
///  perhaps many breeders will not chase a bounty without this guarantee. After that point, the bounty creator 
///  can withdraw their funds if they wish and invalidate the bounty, or they can continue to leave the bounty 
///  active.
/// @notice The bounty hunter must first call approve() in the Cryptokitties Core contract before calling 
///  fulfillBountyAndClaimFunds(). There is no danger of this contract overreaching its approval, since the 
///  CryptoKitties Core contract's approve() function only approves this contract for a single Cryptokitty. 
///  Calling approve() allows this contract to transfer the specified kitty in the fulfillOfferAndClaimFunds() 
///  function.
contract KittyBounties is KittyBountiesAdmin {

    // OpenZeppelin's SafeMath library is used for all arithmetic operations to avoid overflows/underflows.
    using SafeMath for uint256;

	/* ********** */
    /* DATA TYPES */
    /* ********** */

    /// @dev The main Bounty struct. The struct fits in four 256-bits words due to Solidity's rules for struct 
    ///  packing.
	struct Bounty {
		// A bounty creator specifies which portion of the CryptoKitties genome is relevant to this bounty.
		// This is a bitwise mask, that zeroes out all other portions of the Cryptokitties genome besides
        // those that the bounty creator is interested in. If a bounty creator does not wish to specify 
        // genes (perhaps they want to specify generation, but don't have a preference for genes), they can 
        // submit a geneMask of uint256(0) and genes of uint256(0).
		uint256 geneMask;
        // A bounty creator specifies which cattributes they are seeking. If a user possesses a cat that 
        // has both the specified cattributes, the specified generation, and the specified cooldown, then 
        // they can trade that cat for the bounty. If a bounty creator does not wish to specify genes 
        // (perhaps they want to specify generation, but don't have a preference for genes), they can 
        // submit a geneMask of uint256(0) and genes of uint256(0).
        uint256 genes;
		// The price (in wei) that a user will receive if they successfully fulfill this bounty.
		uint128 bountyPrice;
		// The total value (in wei) that the bounty creator originally sent to the contract to create this 
        // bounty. This includes the potential fees to be paid to the contract creator.
		uint128 totalValueIncludingFees;
		// The fee that is paid if the bounty is not fulfilled and the owner withdraws their funds. This 
        // is stored in the Bounty struct to ensure that users are charged the fee that existed at the 
        // time of a bounty's creation, in case the contract owner changes the fees between when the bounty 
        // is created and when the bounty creator withdraws their funds.
		uint128 unsuccessfulBountyFeeInWei;
		// Optionally, a bounty creator can set a minimum number of blocks that must pass before they can 
        // cancel a bounty and withdraw their funds (in order to guarantee a time period for bounty hunters 
        // to attempt to breed for the specified cat). After the time period has passed, the owner can 
        // withdraw their funds if they wish, but the bounty stays valid until they do so. This allows for 
        // the possiblity of leaving a bounty open indefinitely until it is filled if the bounty creator 
        // wishes to do so.
		uint64 minBlockBountyValidUntil;
        // A bounty creator can specify the exact generation that they are seeking. If they are willing to 
        // accept cats of any generation that have the cattributes specified above, they may submit 
        // UINT16_MAX for this variable for it to be ignored.
        uint16 generation;
		// A bounty creator can specify the highest cooldownIndex that they are seeking, allowing users to 
        // place bounties on virgin cats or cats with a sufficient cooldown to be useful in a fancy chase. 
        // If they are willing to accept cats of any cooldown, they may submit a cooldownIndex of 13 (which 
        // is the highest cooldown index that the Cryptokitties Core contract allows) for this variable to 
        // be ignored.
        uint16 highestCooldownIndexAccepted;
        // The creator of the bounty. This address receives the specified cat if the bounty is fulfilled, 
        // or receives their money back (minus unsuccessfulBountyFee) if the bounty is not fulfilled.
		address bidder;
    }

    /* ****** */
    /* EVENTS */
    /* ****** */

    /// @dev This event is fired whenever a user creates a new bounty for a cat with a particular set of 
    ///  cattributes, generation, and/or cooldown that they are seeking.
    /// @param bountyId  A unique identifier for the Bounty Struct for this bounty, found in the 
    ///  bountyIdToBounty mapping.
    /// @param bidder  The creator of the bounty. This address receives the specified cat if the bounty 
    ///  is fulfilled, or receives their money back (minus unsuccessfulBountyFee) if the bounty is not 
    ///  fulfilled.
    /// @param bountyPrice  The price (in wei) that a user will receive if they successfully fulfill 
    ///  this bounty.
    /// @param minBlockBountyValidUntil  Every bounty is valid until at least a specified block. Before 
    ///  that point, the owner cannot withdraw their funds (in order to guarantee a time period for bounty 
    ///  hunters to attempt to breed for the specified cat). After the time period has passed, the owner 
    ///  can withdraw their funds if they wish, but the bounty stays valid until they do so. This allows 
    ///  for the possiblity of leaving a bounty open indefinitely until it is filled if the bounty creator 
    ///  wishes to do so.
    /// @param geneMask  A bounty creator specifies which portion of the CryptoKitties genome is relevant 
    ///  to this bounty. This is a bitwise mask, that zeroes out all other portions of the Cryptokitties 
    ///  genome besides those that the bounty creator is interested in. 
    /// @param genes  A bounty creator specifies which cattributes they are seeking. If a user possesses 
    ///  a cat that has both the specified cattributes and the specified generation, then they can trade 
    ///  that cat for the bounty.
    /// @param generation  A bounty creator can specify the exact generation that they are seeking. If 
    ///  they are willing to accept cats of any generation that have the cattributes specified above, 
    ///  they may submit UINT16_MAX for this variable for it to be ignored.
    /// @param highestCooldownIndexAccepted  A bounty creator can specify the highest cooldownIndex that 
    ///  they are seeking, allowing users to place bounties on virgin cats or cats with a sufficient 
    ///  cooldown to be useful in a fancy chase. If they are willing to accept cats of any cooldown, they 
    ///  may submit a cooldownIndex of 13 (which is the highest cooldown index that the Cryptokitties 
    ///  Core contract allows) for this variable to be ignored.
    /// @param unsuccessfulBountyFeeInWei  The fee that is paid if the bounty is not fulfilled and the 
    ///  owner withdraws their funds. This is stored in the Bounty struct to ensure that users are charged 
    ///  the fee that existed at the time of a bounty's creation, in case the contract owner changes the 
    ///  fees between when the bounty is created and when the bounty creator withdraws their funds.
    event CreateBountyAndLockFunds(
    	uint256 bountyId,
        address bidder,
		uint256 bountyPrice,
		uint256 minBlockBountyValidUntil,
        uint256 geneMask,
        uint256 genes,
        uint256 generation,
        uint256 highestCooldownIndexAccepted,
        uint256 unsuccessfulBountyFeeInWei
    );

    /// @dev This event is fired if a bounty hunter trades in a cat with the specified 
    ///  cattributes/generation/cooldown and claims the funds locked within the bounty.
    /// @notice The bounty hunter must first call approve() in the Cryptokitties Core contract before 
    ///  calling fulfillBountyAndClaimFunds(). There is no danger of this contract overreaching its 
    ///  approval, since the CryptoKitties Core contract's approve() function only approves this 
    ///  contract for a single Cryptokitty. Calling approve() allows this contract to transfer the 
    ///  specified kitty in the fulfillOfferAndClaimFunds() function.
    /// @param bountyId  A unique identifier for the Bounty Struct for this bounty, found in the 
    ///  bountyIdToBounty mapping.
    /// @param kittyId  The id of the CryptoKitty that fulfills the bounty requirements. 
    /// @param bidder  The creator of the bounty. This address receives the specified cat if the 
    ///  bounty is fulfilled, or receives their money back (minus unsuccessfulBountyFee) if the 
    ///  bounty is not fulfilled.
    /// @param bountyPrice  The price (in wei) that a user will receive if they successfully 
    ///  fulfill this bounty.
    /// @param geneMask  A bounty creator specifies which portion of the CryptoKitties genome is 
    ///  relevant to this bounty. This is a bitwise mask, that zeroes out all other portions of the 
    ///  Cryptokitties genome besides those that the bounty creator is interested in. 
    /// @param genes  A bounty creator specifies which cattributes they are seeking. If a user 
    ///  possesses a cat that has both the specified cattributes and the specified generation, then 
    ///  they can trade that cat for the bounty.
    /// @param generation  A bounty creator can specify the exact generation that they are seeking. 
    ///  If they are willing to accept cats of any generation that have the cattributes specified 
    ///  above, they may submit UINT16_MAX for this variable for it to be ignored.
    /// @param highestCooldownIndexAccepted  A bounty creator can specify the highest cooldownIndex 
    ///  that they are seeking, allowing users to place bounties on virgin cats or cats with a 
    ///  sufficient cooldown to be useful in a fancy chase. If they are willing to accept cats of 
    ///  any cooldown, they may submit a cooldownIndex of 13 (which is the highest cooldown index 
    ///  that the Cryptokitties Core contract allows) for this variable to be ignored.
    /// @param successfulBountyFeeInWei  The fee that is paid when the bounty is fulfilled. This 
    ///  fee is calculated from totalValueIncludingFees and bountyPrice, which are both stored in 
    ///  the Bounty struct to ensure that users are charged the fee that existed at the time of a 
    ///  bounty's creation, in case the owner changes the fees between when the bounty is created 
    ///  and when the bounty is fulfilled.
    event FulfillBountyAndClaimFunds(
        uint256 bountyId,
        uint256 kittyId,
        address bidder,
		uint256 bountyPrice,
        uint256 geneMask,
        uint256 genes,
        uint256 generation,
        uint256 highestCooldownIndexAccepted,
        uint256 successfulBountyFeeInWei
    );

    /// @dev This event is fired when a bounty creator wishes to invalidate a bounty. The bounty 
    ///  creator withdraws the funds and cancels the bounty, preventing anybody from fulfilling 
    ///  that particular bounty.
    /// @notice If a bounty creator specified a lock time, a bounty creator cannot withdraw funds 
    ///  or invalidate a bounty until at least the originally specified number of blocks have 
    ///  passed. This guarantees a time period for bounty hunters to attempt to breed for a cat 
    ///  with the specified cattributes/generation/cooldown. However, if the contract is frozen, 
    ///  a bounty creator may withdraw their funds immediately with no fees taken by the contract 
    ///  owner, since the bounty creator would only freeze the contract if a vulnerability was found.
    /// @param bountyId  A unique identifier for the Bounty Struct for this bounty, found in the 
    ///  bountyIdToBounty mapping.
    /// @param bidder  The creator of the bounty. This address receives the specified cat if the 
    ///  bounty is fulfilled, or receives their money back (minus unsuccessfulBountyFee) if the 
    ///  bounty is not fulfilled.
    /// @param withdrawnAmount  The amount returned to the bounty creator (in wei). If the contract
    ///  is not frozen, then this is the total value originally sent to the contract minus 
    ///  unsuccessfulBountyFeeInWei. However, if the contract is frozen, no fees are taken, and the 
    ///  entire amount is returned to the bounty creator.
    event WithdrawBounty(
        uint256 bountyId,
        address bidder,
		uint256 withdrawnAmount
    );

    /* ******* */
    /* STORAGE */
    /* ******* */

    /// @dev A mapping that tracks bounties that have been created, regardless of whether they have 
    ///  been cancelled or claimed thereafter. See the activeBounties mapping to determine whether 
    ///  a particular bounty is still active.
    mapping (uint256 => Bounty) public bountyIdToBounty;

    /// @dev An index that increments with each Bounty created. Allows the ability to jump directly 
    ///  to a specified bounty.
    uint256 public bountyId = 0;

    /// @dev A flag indicating that the contract still contains funds for this particular bounty. 
    ///  This flag is set to false if the bounty is fulfilled, if the funds are withdrawn by the 
    ///  original owner, or if this bounty has not yet been created. In all of these cases, the 
    ///  contract no longer holds funds for this specific bounty. Solidity initializes variables 
    ///  to zero, so there is no concern that the mapping will have been erroneously initialized 
    ///  with any values set to true.
    mapping (uint256 => bool) public activeBounties;

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /// @notice Allows a user to create a new bounty for a cat with a particular set of cattributes, 
    ///  generation, and/or cooldown. This optionally involves locking up a specified amount of eth 
    ///  for at least a specified number of blocks, in order to guarantee a time period for bounty 
    ///  hunters to attempt to breed for a cat with the specified cattributes and generation. 
	/// @param _geneMask  A bounty creator specifies which portion of the CryptoKitties genome is 
    ///  relevant to this bounty. This is a bitwise mask, that zeroes out all other portions of the 
    ///  Cryptokitties genome besides those that the bounty creator is interested in. If a bounty 
    ///  creator does not wish to specify genes (perhaps they want to specify generation, but don't 
    ///  have a preference for genes), they can submit a geneMask of uint256(0).
    /// @param _genes  A bounty creator specifies which cattributes they are seeking. If a user 
    ///  possesses a cat that has the specified cattributes, the specified generation, and the 
    ///  specified cooldown, then they can trade that cat for the bounty.
    /// @param _generation  A bounty creator can specify the exact generation that they are seeking. 
    ///  If they are willing to accept cats of any generation that have the cattributes specified 
    ///  above, they may submit UINT16_MAX for this variable for it to be ignored.
    /// @param _highestCooldownIndexAccepted  A bounty creator can specify the highest cooldownIndex 
    ///  that they are seeking, allowing users to place bounties on virgin cats or cats with a 
    ///  sufficient cooldown to be useful in a fancy chase. If they are willing to accept cats of 
    ///  any cooldown, they may submit  a cooldownIndex of 13 (which is the highest cooldown index 
    ///  that the Cryptokitties Core contract allows) for this variable to be ignored.
    /// @param _minNumBlocksBountyIsValidFor  The bounty creator specifies the minimum number of 
    ///  blocks that this bounty is valid for. Every bounty is valid until at least a specified 
    ///  block. Before that point, the owner cannot withdraw their funds (in order to guarantee a 
    ///  time period for bounty hunters to attempt to breed for the specified cat). After the time 
    ///  period has passed, the owner can withdraw their funds if they wish, but the bounty stays 
    ///  valid until they do so. This allows for the possiblity of leaving a bounty open indefinitely 
    ///  until it is filled if the bounty creator wishes to do so.
    /// @notice This function is payable, and any eth sent to this function is interpreted as the 
    ///  value that the user wishes to lock up for this bounty.
    function createBountyAndLockFunds(uint256 _geneMask, uint256 _genes, uint256 _generation, uint256 _highestCooldownIndexAccepted, uint256 _minNumBlocksBountyIsValidFor) external payable whenNotPaused {
    	require(msg.value >= unsuccessfulBountyFeeInWei.mul(uint256(2)), 'the value of your bounty must be at least twice as large as the unsuccessful bounty fee');
    	require(_minNumBlocksBountyIsValidFor <= maximumLockoutDurationInBlocks, 'you cannot lock eth into a bounty for longer than the maximumLockoutDuration');
    	require(_highestCooldownIndexAccepted <= uint256(13), 'you cannot specify an invalid cooldown index');
    	require(_generation <= uint256(~uint16(0)), 'you cannot specify an invalid generation');
        require(_genes & ~_geneMask == uint256(0), 'your geneMask must fully cover any genes that you are seeeking');

    	uint256 bountyPrice = _computeBountyPrice(msg.value, successfulBountyFeeInBasisPoints);
    	uint256 minBlockBountyValidUntil = uint256(block.number).add(_minNumBlocksBountyIsValidFor);

    	Bounty memory bounty = Bounty({
            geneMask: _geneMask,
            genes: _genes,
            bountyPrice: uint128(bountyPrice),
            totalValueIncludingFees: uint128(msg.value),
            unsuccessfulBountyFeeInWei: uint128(unsuccessfulBountyFeeInWei),
            minBlockBountyValidUntil: uint64(minBlockBountyValidUntil),
            generation: uint16(_generation),
            highestCooldownIndexAccepted: uint16(_highestCooldownIndexAccepted),
            bidder: msg.sender
        });

        bountyIdToBounty[bountyId] = bounty;
        activeBounties[bountyId] = true;
        
        emit CreateBountyAndLockFunds(
            bountyId,
	        msg.sender,
			bountyPrice,
			minBlockBountyValidUntil,
	        bounty.geneMask,
	        bounty.genes,
	        _generation,
	        _highestCooldownIndexAccepted,
	        unsuccessfulBountyFeeInWei
        );

        bountyId = bountyId.add(uint256(1));
    }

    /// @notice After calling approve() in the CryptoKitties Core contract, a bounty hunter can 
    ///  submit the id of a kitty that they own and a bounty that they would like to fulfill. If
    ///  the kitty fits the requirements of the bounty, and if the bounty hunter owns the kitty,
    ///  then this function transfers the kitty to the original bounty creator and transfers the 
    ///  locked eth to the bounty hunter.
    /// @param _bountyId  A unique identifier for the Bounty Struct for this bounty, found in 
    ///  the bountyIdToBounty mapping.
    /// @param _kittyId  The id of the CryptoKitty that fulfills the bounty requirements.
    /// @notice The bounty hunter must first call approve() in the Cryptokitties Core contract 
    ///  before calling fulfillBountyAndClaimFunds(). There is no danger of this contract 
    ///  overreaching its approval, since the CryptoKitties Core contract's approve() function 
    /// only approves this contract for a single Cryptokitty. Calling approve() allows this 
    /// contract to transfer the specified kitty in the fulfillOfferAndClaimFunds() function.
    function fulfillBountyAndClaimFunds(uint256 _bountyId, uint256 _kittyId) external whenNotPaused {
    	require(activeBounties[_bountyId], 'this bounty has either already completed or has not yet begun');
    	require(msg.sender == kittyCore.ownerOf(_kittyId), 'you do not own the cat that you are trying to use to fulfill this bounty');
    	require(kittyCore.kittyIndexToApproved(_kittyId) == address(this), 'you must approve the bounties contract for this cat before you can fulfill a bounty');

    	Bounty storage bounty = bountyIdToBounty[_bountyId];
    	uint256 cooldownIndex;
    	uint256 generation;
    	uint256 genes;
        ( , , cooldownIndex, , , , , , generation, genes) = kittyCore.getKitty(_kittyId);

        // By submitting ~uint16(0) as the target generation (which is uint16_MAX), a bounty creator can specify that they do not have a preference for generation.
    	require((uint16(bounty.generation) == ~uint16(0) || uint16(generation) == uint16(bounty.generation)), 'your cat is not the correct generation to fulfill this bounty');
    	// By submitting uint256(0) as the target genemask and submitting uint256(0) for the target genes, a bounty creator can specify that they do not have 
    	// a preference for genes.
    	require((genes & bounty.geneMask) == (bounty.genes & bounty.geneMask), 'your cat does not have the correct genes to fulfill this bounty');
    	// By submitting 13 as the target highestCooldownIndexAccepted, a bounty creator can specify that they do not have a preference for cooldown (since
    	// all Cryptokitties have a cooldown index less than or equal to 13).
    	require(uint16(cooldownIndex) <= uint16(bounty.highestCooldownIndexAccepted), 'your cat does not have a low enough cooldown index to fulfill this bounty');

    	activeBounties[_bountyId] = false;
    	kittyCore.transferFrom(msg.sender, bounty.bidder, _kittyId);
    	uint256 successfulBountyFeeInWei = uint256(bounty.totalValueIncludingFees).sub(uint256(bounty.bountyPrice));
    	totalOwnerEarningsInWei = totalOwnerEarningsInWei.add(successfulBountyFeeInWei);
    	msg.sender.transfer(uint256(bounty.bountyPrice));

    	emit FulfillBountyAndClaimFunds(
            _bountyId,
            _kittyId,
	        msg.sender,
			uint256(bounty.bountyPrice),
	        bounty.geneMask,
	        bounty.genes,
	        uint256(bounty.generation),
	        uint256(bounty.highestCooldownIndexAccepted),
	        successfulBountyFeeInWei
        );
    }

    /// @notice Allows a bounty creator to withdraw the funds locked within a bounty, but only 
    ///  once a specified time period (measured in blocks) has passed. Prohibiting the bounty 
    ///  creator from withdrawing their funds until this point guarantees a time period for 
    ///  bounty hunters to attempt to breed for a cat with the specified cattributes and 
    ///  generation. If a bounty creator withdraws their funds, then the bounty is invalidated 
    ///  and bounty hunters can no longer try to fulfill it. A flat fee is taken from the bounty 
    ///  creator's original deposit, specified by unsuccessfulBountyFeeInWei.
    /// @param _bountyId  A unique identifier for the Bounty Struct for this bounty, found in 
    ///  the bountyIdToBounty mapping.
    function withdrawUnsuccessfulBounty(uint256 _bountyId) external whenNotPaused {
    	require(activeBounties[_bountyId], 'this bounty has either already completed or has not yet begun');
    	Bounty storage bounty = bountyIdToBounty[_bountyId];
    	require(msg.sender == bounty.bidder, 'you cannot withdraw the funds for someone elses bounty');
    	require(block.number >= uint256(bounty.minBlockBountyValidUntil), 'this bounty is not withdrawable until the minimum number of blocks that were originally specified have passed');
    	activeBounties[_bountyId] = false;
    	totalOwnerEarningsInWei = totalOwnerEarningsInWei.add(uint256(bounty.unsuccessfulBountyFeeInWei));
    	uint256 amountToReturn = uint256(bounty.totalValueIncludingFees).sub(uint256(bounty.unsuccessfulBountyFeeInWei));
    	msg.sender.transfer(amountToReturn);

    	emit WithdrawBounty(
            _bountyId,
            bounty.bidder,
            amountToReturn
        );
    }

    /// @notice Allows a bounty creator to withdraw the funds locked within a bounty, even if 
    ///  the time period that the bounty was guaranteed to be locked for has not passed. This 
    ///  function can only be called when the contract is frozen, and would be used as an 
    ///  emergency measure to allow users to withdraw their funds immediately. No fees are 
    ///  taken when this function is called.
    /// @notice Only callable when the contract is frozen.
    /// @param _bountyId  A unique identifier for the Bounty Struct for this bounty, found 
    ///  in the bountyIdToBounty mapping.
    function withdrawBountyWithNoFeesTakenIfContractIsFrozen(uint256 _bountyId) external whenPaused {
    	require(activeBounties[_bountyId], 'this bounty has either already completed or has not yet begun');
    	Bounty storage bounty = bountyIdToBounty[_bountyId];
    	require(msg.sender == bounty.bidder, 'you cannot withdraw the funds for someone elses bounty');
    	activeBounties[_bountyId] = false;
    	msg.sender.transfer(uint256(bounty.totalValueIncludingFees));

    	emit WithdrawBounty(
            _bountyId,
            bounty.bidder,
            uint256(bounty.totalValueIncludingFees)
        );
    }

    /// @notice Computes the bounty price given a total value sent when creating a bounty, 
    ///  and the current successfulBountyFee in percentage basis points. 
    /// @dev 10000 is not a magic number, but is the maximum number of basis points that 
    ///  can exist (with basis points being hundredths of a percent).
    /// @param _totalValueIncludingFees The amount of ether (in wei) that was sent to 
    ///  create a bounty
    /// @param _successfulBountyFeeInBasisPoints The percentage (in basis points) of that 
    ///  total amount that will be taken as a fee if the bounty is successfully completed.
    /// @return The amount of ether (in wei) that will be rewarded if the bounty is 
    ///  successfully fulfilled
    function _computeBountyPrice(uint256 _totalValueIncludingFees, uint256 _successfulBountyFeeInBasisPoints) internal pure returns (uint256) {
    	return (_totalValueIncludingFees.mul(uint256(10000).sub(_successfulBountyFeeInBasisPoints))).div(uint256(10000));
    }

    /// @dev By calling 'revert' in the fallback function, we prevent anyone from 
    ///  accidentally sending funds directly to this contract.
    function() external payable {
        revert();
    }
}