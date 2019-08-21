pragma solidity 0.4.24;

/**
 * Simple Public Voting/Poll Demo
 *
 * This is a DEMO contract. Please carefully inspect the source code and
 * understand what it is doing before using any of this in production.
 *
 *
 * Disclaimer of Warranty:
 * THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.
 * EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
 * PROVIDE THE PROGRAM “AS IS” WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE
 * PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
 * NECESSARY SERVICING, REPAIR OR CORRECTION.
 *
 */



// File: contracts/ownership/Ownable.sol

/**
 * @title Ownable
 *
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor()
    public {
        _owner = msg.sender;
    }

    /**
     * @return the address of the owner.
     */
    function owner()
    public
    view
    returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Only the owner can do this.");
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner()
    public
    view
    returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership()
    public
    onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner)
    public
    onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner)
    internal {
        require(newOwner != address(0), "New owner cannot be 0x0.");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/lifecycle/Destructible.sol

/**
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {

    /**
     * @notice Destructs this contract (removes it from the blockchain) and sends all funds in it
     *     to the owner.
     *
     * @dev Transfers the current balance to the owner and terminates the contract.
     */
    function destroy()
    public
    onlyOwner {
        selfdestruct(owner());
    }

    /**
     * @notice Destructs this contract (removes it from the blockchain) and sends all funds in it
     *     to the specified recipient address.
     *
     * @dev Transfers the current balance to the specified recipient and terminates the contract.
     */
    function destroyAndSend(address _recipient)
    public
    onlyOwner {
        selfdestruct(_recipient);
    }
}

// File: contracts/interfaces/IERC20.sol

/**
 * @title ERC20 interface
 *
 * @notice Used to call methods in ERC-20 contracts.
 *
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {

    function transfer(address to, uint256 value)
    external
    returns (bool);

    function balanceOf(address who)
    external
    view
    returns (uint256);

    function totalSupply()
    external
    view
    returns (uint256);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

}

// File: contracts/tokenutils/CanRescueERC20.sol

/**
 * @title CanRescueERC20
 *
 * Provides a function to recover ERC-20 tokens which are accidentally sent
 * to the address of this contract (the owner can rescue ERC-20 tokens sent
 * to this contract back to himself).
 */
contract CanRescueERC20 is Ownable {

    /**
     * Enable the owner to rescue ERC20 tokens, which are sent accidentally
     * to this contract.
     *
     * @dev This will be invoked by the owner, when owner wants to rescue tokens
     * @notice Recover tokens accidentally sent to this contract. They will be sent to the
     *     contract owner. Can only be called by the owner.
     * @param token Token which will we rescue to the owner from the contract
     */
    function recoverTokens(IERC20 token)
    public
    onlyOwner {
        uint256 balance = token.balanceOf(this);
        // Caution: ERC-20 standard doesn't require to throw exception on failures
        // (although most ERC-20 tokens do so), but instead returns a bool value.
        // Therefore let's check if it really returned true, and throw otherwise.
        require(token.transfer(owner(), balance), "Token transfer failed, transfer() returned false.");
    }

}

// File: contracts/Voting.sol

contract Voting is Ownable, Destructible, CanRescueERC20 {

    /**
     * @dev number of possible choices. Constant set at compile time.
     */
    uint8 internal constant NUMBER_OF_CHOICES = 4;

    /**
     * @notice Number of total cast votes (uint40 is enough as at most
     *     we support 4 choices and 2^32 votes per choice).
     */
    uint40 public voteCountTotal;

    /**
     * @notice Number of votes, summarized per choice.
     *
     * @dev uint32 allows 4,294,967,296 possible votes per choice, should be enough,
     *     and still allows 8 entries to be packed in a single storage slot
     *     (EVM wordsize is 256 bit). And of course we check for overflows.
     */
    uint32[NUMBER_OF_CHOICES] internal currentVoteResults;

    /**
     * @notice Mapping of address to vote details
     */
    mapping(address => Voter) public votersInfo;

    /**
     * @notice Event gets emitted every time when a new vote is cast.
     *
     * @param addedVote choice in the vote
     * @param allVotes array containing updated intermediate result
     */
    event NewVote(uint8 indexed addedVote, uint32[NUMBER_OF_CHOICES] allVotes);

    /**
     * @dev Represent info about a single voter.
     */
    struct Voter {
        bool exists;
        uint8 choice;
        string name;
    }

    /**
     * @notice Fallback function. Will be called whenever the contract receives ether, or
     *     when is called without data or with unknown function signature.
     */
    function()
    public {
    }

    /**
     * @notice Cast your note. In a real world scenario, you might want to have address
     *     voting only once. In this DEMO we allow unlimited number of votes per address.
     * @param voterName Name of the voter, will be publicly visible on the blockchain
     * @param givenVote choice the caller has voted for
     */
    function castVote(string voterName, uint8 givenVote)
    external {
        // answer must be given
        require(givenVote < numberOfChoices(), "Choice must be less than contract configured numberOfChoices.");

        // DEMO MODE: FOR EASIER TESTING, WE ALLOW UNLIMITED VOTES PER ADDRESS.
        // check if already voted
        //require(!votersInfo[msg.sender].exists, "This address has already voted. Vote denied.");

        //  voter name has to have at least 3 bytes (note: with utf8 some chars have
        // more than 1 byte, so this check is not fully accurate but ok here)
        require(bytes(voterName).length > 2, "Name of voter is too short.");

        // everything ok, add voter
        votersInfo[msg.sender] = Voter(true, givenVote, voterName);
        voteCountTotal = safeAdd40(voteCountTotal, 1);
        currentVoteResults[givenVote] = safeAdd32(currentVoteResults[givenVote], 1);

        // emit a NewVote event at this point in time, so that a web3 Dapp
        // can react it to it immediately. Emit full current vote state, as
        // events are cheaper for light clients than querying the state.
        emit NewVote(givenVote, currentVoteResults);
    }

    /**
    * @notice checks if this address has already cast a vote
    *  this is required to find out if it is safe to call the other "thisVoters..." views.
    */
    function thisVoterExists()
    external
    view
    returns (bool) {
        return votersInfo[msg.sender].exists;
    }

    /**
     * @notice Returns the vote details of calling address or throws
     *    if address has not voted yet.
     */
    function thisVotersChoice()
    external
    view
    returns (uint8) {
        // check if msg sender exists in voter mapping
        require(votersInfo[msg.sender].exists, "No vote so far.");
        return votersInfo[msg.sender].choice;
    }

    /**
     * @notice Returns the entered voter name of the calling address or throws
     *    if address has not voted yet.
     */
    function thisVotersName()
    external
    view
    returns (string) {
        // check if msg sender exists in voter mapping
        require(votersInfo[msg.sender].exists, "No vote so far.");
        return votersInfo[msg.sender].name;
    }

    /**
     * @notice Return array with sums of votes per choice.
     *
     * @dev Note that this only will work for external callers, and not
     *      for other contracts (as of solidity 0.4.24 returning of dynamically
     *      sized data is still not in stable, it's only available with the
     *      experimental "ABIEncoderV2" pragma). Also some block-explorers,
     *      like etherscan, will have problems to display this correctly.
     */
    function currentResult()
    external
    view
    returns (uint32[NUMBER_OF_CHOICES]) {
        return currentVoteResults;
    }

    /**
     * @notice Return number of votes for one of the options.
     */
    function votesPerChoice(uint8 option)
    external
    view
    returns (uint32) {
        require(option < numberOfChoices(), "Choice must be less than contract configured numberOfChoices.");
        return currentVoteResults[option];
    }

    /**
     * @notice Returns the number of possible choices, which can be voted for.
     */
    function numberOfChoices()
    public
    view
    returns (uint8) {
        // save as we only initialize array length in constructor
        // and there we check it's never larger than uint8.
        return uint8(currentVoteResults.length);
    }

    /**
     * @dev Adds two uint40 numbers, throws on overflow.
     */
    function safeAdd40(uint40 _a, uint40 _b)
    internal
    pure
    returns (uint40 c) {
        c = _a + _b;
        assert(c >= _a);
        return c;
    }

    /**
     * @dev Adds two uint32 numbers, throws on overflow.
     */
    function safeAdd32(uint32 _a, uint32 _b)
    internal
    pure
    returns (uint32 c) {
        c = _a + _b;
        assert(c >= _a);
        return c;
    }
}