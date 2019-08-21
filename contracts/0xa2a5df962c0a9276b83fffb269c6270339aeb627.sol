// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
// input  C:\Projects\BANKEX\bankex-arbitration-service\smart-contract\contracts\Board.sol
// flattened :  Wednesday, 05-Dec-18 11:16:27 UTC
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract EIP20 {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    // solhint-disable-next-line no-simple-event-func-name  
    event Transfer(address indexed _from, address indexed _to, uint256 _value); 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract BkxToken is EIP20 {
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success);
    function decreaseApproval (address _spender, uint _subtractedValue)public returns (bool success);
}

library Utils {
     /* Not secured random number generation, but it's enough for the perpose of implementaion particular case*/
    function almostRnd(uint min, uint max) internal view returns(uint)
    {
        return uint(keccak256(block.timestamp, block.blockhash(block.number))) % (max - min) + min;
    }
}

contract Token {
    function balanceOf(address owner) public view returns (uint256 balance);

    function transfer(address to, uint256 value) public returns (bool success);

    function transferFrom(address from, address to, uint256 value) public returns (bool success);

    function approve(address spender, uint256 value) public returns (bool success);

    function allowance(address owner, address spender) public view returns (uint256 remaining);
}

contract EternalStorage {

    /**** Storage Types *******/

    address public owner;

    mapping(bytes32 => uint256)    private uIntStorage;
    mapping(bytes32 => uint8)      private uInt8Storage;
    mapping(bytes32 => string)     private stringStorage;
    mapping(bytes32 => address)    private addressStorage;
    mapping(bytes32 => bytes)      private bytesStorage;
    mapping(bytes32 => bool)       private boolStorage;
    mapping(bytes32 => int256)     private intStorage;
    mapping(bytes32 => bytes32)    private bytes32Storage;


    /*** Modifiers ************/

    /// @dev Only allow access from the latest version of a contract in the Rocket Pool network after deployment
    modifier onlyLatestContract() {
        require(addressStorage[keccak256("contract.address", msg.sender)] != 0x0 || msg.sender == owner);
        _;
    }

    /// @dev constructor
    function EternalStorage() public {
        owner = msg.sender;
        addressStorage[keccak256("contract.address", msg.sender)] = msg.sender;
    }

    function setOwner() public {
        require(msg.sender == owner);
        addressStorage[keccak256("contract.address", owner)] = 0x0;
        owner = msg.sender;
        addressStorage[keccak256("contract.address", msg.sender)] = msg.sender;
    }

    /**** Get Methods ***********/

    /// @param _key The key for the record
    function getAddress(bytes32 _key) external view returns (address) {
        return addressStorage[_key];
    }

    /// @param _key The key for the record
    function getUint(bytes32 _key) external view returns (uint) {
        return uIntStorage[_key];
    }

      /// @param _key The key for the record
    function getUint8(bytes32 _key) external view returns (uint8) {
        return uInt8Storage[_key];
    }


    /// @param _key The key for the record
    function getString(bytes32 _key) external view returns (string) {
        return stringStorage[_key];
    }

    /// @param _key The key for the record
    function getBytes(bytes32 _key) external view returns (bytes) {
        return bytesStorage[_key];
    }

    /// @param _key The key for the record
    function getBytes32(bytes32 _key) external view returns (bytes32) {
        return bytes32Storage[_key];
    }

    /// @param _key The key for the record
    function getBool(bytes32 _key) external view returns (bool) {
        return boolStorage[_key];
    }

    /// @param _key The key for the record
    function getInt(bytes32 _key) external view returns (int) {
        return intStorage[_key];
    }

    /**** Set Methods ***********/

    /// @param _key The key for the record
    function setAddress(bytes32 _key, address _value) onlyLatestContract external {
        addressStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setUint(bytes32 _key, uint _value) onlyLatestContract external {
        uIntStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setUint8(bytes32 _key, uint8 _value) onlyLatestContract external {
        uInt8Storage[_key] = _value;
    }

    /// @param _key The key for the record
    function setString(bytes32 _key, string _value) onlyLatestContract external {
        stringStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setBytes(bytes32 _key, bytes _value) onlyLatestContract external {
        bytesStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setBytes32(bytes32 _key, bytes32 _value) onlyLatestContract external {
        bytes32Storage[_key] = _value;
    }

    /// @param _key The key for the record
    function setBool(bytes32 _key, bool _value) onlyLatestContract external {
        boolStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setInt(bytes32 _key, int _value) onlyLatestContract external {
        intStorage[_key] = _value;
    }

    /**** Delete Methods ***********/

    /// @param _key The key for the record
    function deleteAddress(bytes32 _key) onlyLatestContract external {
        delete addressStorage[_key];
    }

    /// @param _key The key for the record
    function deleteUint(bytes32 _key) onlyLatestContract external {
        delete uIntStorage[_key];
    }

     /// @param _key The key for the record
    function deleteUint8(bytes32 _key) onlyLatestContract external {
        delete uInt8Storage[_key];
    }

    /// @param _key The key for the record
    function deleteString(bytes32 _key) onlyLatestContract external {
        delete stringStorage[_key];
    }

    /// @param _key The key for the record
    function deleteBytes(bytes32 _key) onlyLatestContract external {
        delete bytesStorage[_key];
    }

    /// @param _key The key for the record
    function deleteBytes32(bytes32 _key) onlyLatestContract external {
        delete bytes32Storage[_key];
    }

    /// @param _key The key for the record
    function deleteBool(bytes32 _key) onlyLatestContract external {
        delete boolStorage[_key];
    }

    /// @param _key The key for the record
    function deleteInt(bytes32 _key) onlyLatestContract external {
        delete intStorage[_key];
    }
}

library RefereeCasesLib {

    function setRefereesToCase(address storageAddress, address[] referees, bytes32 caseId) public {
        for (uint i = 0; i < referees.length; i++) {
            setRefereeToCase(storageAddress, referees[i], caseId, i);
        }
        setRefereeCountForCase(storageAddress, caseId, referees.length);
    }

    function isRefereeVoted(address storageAddress, address referee, bytes32 caseId) public view returns (bool) {
        return EternalStorage(storageAddress).getBool(keccak256("case.referees.voted", caseId, referee));
    }

    function setRefereeVote(address storageAddress, bytes32 caseId, address referee, bool forApplicant) public {
        uint index = getRefereeVotesFor(storageAddress, caseId, forApplicant);
        EternalStorage(storageAddress).setAddress(keccak256("case.referees.vote", caseId, forApplicant, index), referee);
        setRefereeVotesFor(storageAddress, caseId,  forApplicant, index + 1);
    }

    function getRefereeVoteForByIndex(address storageAddress, bytes32 caseId, bool forApplicant, uint index) public view returns (address) {
        return EternalStorage(storageAddress).getAddress(keccak256("case.referees.vote", caseId, forApplicant, index));
    }

    function getRefereeVotesFor(address storageAddress, bytes32 caseId, bool forApplicant) public view returns (uint) {
        return EternalStorage(storageAddress).getUint(keccak256("case.referees.votes.count", caseId, forApplicant));
    }

    function setRefereeVotesFor(address storageAddress, bytes32 caseId, bool forApplicant, uint votes) public {
        EternalStorage(storageAddress).setUint(keccak256("case.referees.votes.count", caseId, forApplicant), votes);
    }

    function getRefereeCountByCase(address storageAddress, bytes32 caseId) public view returns (uint) {
        return EternalStorage(storageAddress).getUint(keccak256("case.referees.count", caseId));
    }

    function setRefereeCountForCase(address storageAddress, bytes32 caseId, uint value) public {
        EternalStorage(storageAddress).setUint(keccak256("case.referees.count", caseId), value);
    }

    function getRefereeByCase(address storageAddress, bytes32 caseId, uint index) public view returns (address) {
        return EternalStorage(storageAddress).getAddress(keccak256("case.referees", caseId, index));
    }

    function isRefereeSetToCase(address storageAddress, address referee, bytes32 caseId) public view returns(bool) {
        return EternalStorage(storageAddress).getBool(keccak256("case.referees", caseId, referee));
    }
    
    function setRefereeToCase(address storageAddress, address referee, bytes32 caseId, uint index) public {
        EternalStorage st = EternalStorage(storageAddress);
        st.setAddress(keccak256("case.referees", caseId, index), referee);
        st.setBool(keccak256("case.referees", caseId, referee), true);
    }

    function getRefereeVoteHash(address storageAddress, bytes32 caseId, address referee) public view returns (bytes32) {
        return EternalStorage(storageAddress).getBytes32(keccak256("case.referees.vote.hash", caseId, referee));
    }

    function setRefereeVoteHash(address storageAddress, bytes32 caseId, address referee, bytes32 voteHash) public {
        uint caseCount = getRefereeVoteHashCount(storageAddress, caseId);
        EternalStorage(storageAddress).setBool(keccak256("case.referees.voted", caseId, referee), true);
        EternalStorage(storageAddress).setBytes32(keccak256("case.referees.vote.hash", caseId, referee), voteHash);
        EternalStorage(storageAddress).setUint(keccak256("case.referees.vote.hash.count", caseId), caseCount + 1);
    }

    function getRefereeVoteHashCount(address storageAddress, bytes32 caseId) public view returns(uint) {
        return EternalStorage(storageAddress).getUint(keccak256("case.referees.vote.hash.count", caseId));
    }

    function getRefereesFor(address storageAddress, bytes32 caseId, bool forApplicant)
    public view returns(address[]) {
        uint n = getRefereeVotesFor(storageAddress, caseId, forApplicant);
        address[] memory referees = new address[](n);
        for (uint i = 0; i < n; i++) {
            referees[i] = getRefereeVoteForByIndex(storageAddress, caseId, forApplicant, i);
        }
        return referees;
    }

    function getRefereesByCase(address storageAddress, bytes32 caseId)
    public view returns (address[]) {
        uint n = getRefereeCountByCase(storageAddress, caseId);
        address[] memory referees = new address[](n);
        for (uint i = 0; i < n; i++) {
            referees[i] = getRefereeByCase(storageAddress, caseId, i);
        }
        return referees;
    }

}

library VoteTokenLib  {

    function getVotes(address storageAddress, address account) public view returns(uint) {
        return EternalStorage(storageAddress).getUint(keccak256("vote.token.balance", account));
    }

    function increaseVotes(address storageAddress, address account, uint256 diff) public {
        setVotes(storageAddress, account, getVotes(storageAddress, account) + diff);
    }

    function decreaseVotes(address storageAddress, address account, uint256 diff) public {
        setVotes(storageAddress, account, getVotes(storageAddress, account) - diff);
    }

    function setVotes(address storageAddress, address account, uint256 value) public {
        EternalStorage(storageAddress).setUint(keccak256("vote.token.balance", account), value);
    }

}

library RefereesLib {

    struct Referees {
        address[] addresses;
    }

    function addReferee(address storageAddress, address referee) public {
        uint id = getRefereeCount(storageAddress);
        setReferee(storageAddress, referee, id, true);
        setRefereeCount(storageAddress, id + 1);
    }

    function getRefereeCount(address storageAddress) public view returns(uint) {
        return EternalStorage(storageAddress).getUint(keccak256("referee.count"));
    }

    function setRefereeCount(address storageAddress, uint value) public {
        EternalStorage(storageAddress).setUint(keccak256("referee.count"), value);
    }

    function setReferee(address storageAddress, address referee, uint id, bool applied) public {
        EternalStorage st = EternalStorage(storageAddress);
        st.setBool(keccak256("referee.applied", referee), applied);
        st.setAddress(keccak256("referee.address", id), referee);
    }

    function isRefereeApplied(address storageAddress, address referee) public view returns(bool) {
        return EternalStorage(storageAddress).getBool(keccak256("referee.applied", referee));
    }

    function setRefereeApplied(address storageAddress, address referee, bool applied) public {
        EternalStorage(storageAddress).setBool(keccak256("referee.applied", referee), applied);
    }

    function getRefereeAddress(address storageAddress, uint id) public view returns(address) {
        return EternalStorage(storageAddress).getAddress(keccak256("referee.address", id));
    }
    
    function getRandomRefereesToCase(address storageAddress, address applicant, address respondent, uint256 targetCount) 
    public view returns(address[] foundReferees)  {
        uint refereesCount = getRefereeCount(storageAddress);
        require(refereesCount >= targetCount);
        foundReferees = new address[](targetCount);
        uint id = Utils.almostRnd(0, refereesCount);
        uint found = 0;
        for (uint i = 0; i < refereesCount; i++) {
            address referee = getRefereeAddress(storageAddress, id);
            id = id + 1;
            id = id % refereesCount;
            uint voteBalance = VoteTokenLib.getVotes(storageAddress, referee);
            if (referee != applicant && referee != respondent && voteBalance > 0) {
                foundReferees[found] = referee;
                found++;
            }
            if (found == targetCount) {
                break;
            }
        }
        require(found == targetCount);
    }
}

contract IBoard is Ownable {

    event CaseOpened(bytes32 caseId, address applicant, address respondent, bytes32 deal, uint amount, uint refereeAward, bytes32 title, string applicantDescription, uint[] dates, uint refereeCountNeed, bool isEthRefereeAward);
    event CaseCommentedByRespondent(bytes32 caseId, address respondent, string comment);
    event CaseVoting(bytes32 caseId);
    event CaseVoteCommitted(bytes32 caseId, address referee, bytes32 voteHash);
    event CaseRevealingVotes(bytes32 caseId);
    event CaseVoteRevealed(bytes32 caseId, address referee, uint8 voteOption, bytes32 salt);
    event CaseClosed(bytes32 caseId, bool won);
    event CaseCanceled(bytes32 caseId, uint8 causeCode);

    event RefereesAssignedToCase(bytes32 caseId, address[] referees);
    event RefereeVoteBalanceChanged(address referee, uint balance);
    event RefereeAwarded(address referee, bytes32 caseId, uint award);

    address public lib;
    uint public version;
    IBoardConfig public config;
    BkxToken public bkxToken;
    address public admin;
    address public paymentHolder;
    address public refereePaymentHolder;

    modifier onlyOwnerOrAdmin() {
        require(msg.sender == admin || msg.sender == owner);
        _;
    }

    function withdrawEth(uint value) external;

    function withdrawBkx(uint value) external;

    function setStorageAddress(address storageAddress) external;

    function setConfigAddress(address configAddress) external;

    function setBkxToken(address tokenAddress) external;

    function setPaymentHolder(address paymentHolder) external;

    function setRefereePaymentHolder(address referePaymentHolder) external;

    function setAdmin(address admin) external;

    function applyForReferee() external;

    function addVoteTokens(address referee) external;

    function openCase(address respondent, bytes32 deal, uint amount, uint refereeAward, bytes32 title, string description) external payable;

    function setRespondentDescription(bytes32 caseId, string description) external;

    function startVotingCase(bytes32 caseId) external;

    function createVoteHash(uint8 voteOption, bytes32 salt) public view returns(bytes32);

    function commitVote(bytes32 caseId, bytes32 voteHash) external;

    function verifyVote(bytes32 caseId, address referee, uint8 voteOption, bytes32 salt) public view returns(bool);

    function startRevealingVotes(bytes32 caseId) external;

    function revealVote(bytes32 caseId, address referee, uint8 voteOption, bytes32 salt) external;

    function revealVotes(bytes32 caseId, address[] referees, uint8[] voteOptions, bytes32[] salts) external;

    function verdict(bytes32 caseId) external;
}

contract Withdrawable is Ownable {
    function withdrawEth(uint value) external onlyOwner {
        require(address(this).balance >= value);
        msg.sender.transfer(value);
    }

    function withdrawToken(address token, uint value) external onlyOwner {
        require(Token(token).balanceOf(address(this)) >= value, "Not enough tokens");
        require(Token(token).transfer(msg.sender, value));
    }
}

library CasesLib {

    enum CaseStatus {OPENED, VOTING, REVEALING, CLOSED, CANCELED}
    enum CaseCanceledCode { NOT_ENOUGH_VOTES, EQUAL_NUMBER_OF_VOTES }

    function getCase(address storageAddress, bytes32 caseId)
    public view returns ( address applicant, address respondent,
        bytes32 deal, uint amount,
        uint refereeAward,
        bytes32 title, uint8 status, uint8 canceledCode,
        bool won, bytes32 applicantDescriptionHash,
        bytes32 respondentDescriptionHash, bool isEthRefereeAward)
    {
        EternalStorage st = EternalStorage(storageAddress);
        applicant = st.getAddress(keccak256("case.applicant", caseId));
        respondent = st.getAddress(keccak256("case.respondent", caseId));
        deal = st.getBytes32(keccak256("case.deal", caseId));
        amount = st.getUint(keccak256("case.amount", caseId));
        won = st.getBool(keccak256("case.won", caseId));
        status = st.getUint8(keccak256("case.status", caseId));
        canceledCode = st.getUint8(keccak256("case.canceled.cause.code", caseId));
        refereeAward = st.getUint(keccak256("case.referee.award", caseId));
        title = st.getBytes32(keccak256("case.title", caseId));
        applicantDescriptionHash = st.getBytes32(keccak256("case.applicant.description", caseId));
        respondentDescriptionHash = st.getBytes32(keccak256("case.respondent.description", caseId));
        isEthRefereeAward = st.getBool(keccak256("case.referee.award.eth", caseId));
    }

    function getCaseDates(address storageAddress, bytes32 caseId)
    public view returns (uint date, uint votingDate, uint revealingDate, uint closeDate)
    {
        EternalStorage st = EternalStorage(storageAddress);
        date = st.getUint(keccak256("case.date", caseId));
        votingDate = st.getUint(keccak256("case.date.voting", caseId));
        revealingDate = st.getUint(keccak256("case.date.revealing", caseId));
        closeDate = st.getUint(keccak256("case.date.close", caseId));
    }

    function addCase(
        address storageAddress, address applicant, 
        address respondent, bytes32 deal, 
        uint amount, uint refereeAward,
        bytes32 title, string applicantDescription,
        uint[] dates, uint refereeCountNeed, bool isEthRefereeAward
    )
    public returns(bytes32 caseId)
    {
        EternalStorage st = EternalStorage(storageAddress);
        caseId = keccak256(applicant, respondent, deal, dates[0], title, amount);
        st.setAddress(keccak256("case.applicant", caseId), applicant);
        st.setAddress(keccak256("case.respondent", caseId), respondent);
        st.setBytes32(keccak256("case.deal", caseId), deal);
        st.setUint(keccak256("case.amount", caseId), amount);
        st.setUint(keccak256("case.date", caseId), dates[0]);
        st.setUint(keccak256("case.date.voting", caseId), dates[1]);
        st.setUint(keccak256("case.date.revealing", caseId), dates[2]);
        st.setUint(keccak256("case.date.close", caseId), dates[3]);
        st.setUint8(keccak256("case.status", caseId), 0);//OPENED
        st.setUint(keccak256("case.referee.award", caseId), refereeAward);
        st.setBytes32(keccak256("case.title", caseId), title);
        st.setBytes32(keccak256("case.applicant.description", caseId), keccak256(applicantDescription));
        st.setBool(keccak256("case.referee.award.eth", caseId), isEthRefereeAward);
        st.setUint(keccak256("case.referee.count.need", caseId), refereeCountNeed);
    }

    function setCaseWon(address storageAddress, bytes32 caseId, bool won) public
    {
        EternalStorage st = EternalStorage(storageAddress);
        st.setBool(keccak256("case.won", caseId), won);
    }

    function setCaseStatus(address storageAddress, bytes32 caseId, CaseStatus status) public
    {
        uint8 statusCode = uint8(status);
        require(statusCode >= 0 && statusCode <= uint8(CaseStatus.CANCELED));
        EternalStorage(storageAddress).setUint8(keccak256("case.status", caseId), statusCode);
    }

    function getCaseStatus(address storageAddress, bytes32 caseId) public view returns(CaseStatus) {
        return CaseStatus(EternalStorage(storageAddress).getUint8(keccak256("case.status", caseId)));
    }

    function setCaseCanceledCode(address storageAddress, bytes32 caseId, CaseCanceledCode cause) public
    {
        uint8 causeCode = uint8(cause);
        require(causeCode >= 0 && causeCode <= uint8(CaseCanceledCode.EQUAL_NUMBER_OF_VOTES));
        EternalStorage(storageAddress).setUint8(keccak256("case.canceled.cause.code", caseId), causeCode);
    }

    function getCaseDate(address storageAddress, bytes32 caseId) public view returns(uint) {
        return EternalStorage(storageAddress).getUint(keccak256("case.date", caseId));
    }

    function getRespondentDescription(address storageAddress, bytes32 caseId) public view returns(bytes32) {
        return EternalStorage(storageAddress).getBytes32(keccak256("case.respondent.description", caseId));
    }

    function setRespondentDescription(address storageAddress, bytes32 caseId, string description) public {
        EternalStorage(storageAddress).setBytes32(keccak256("case.respondent.description", caseId), keccak256(description));
    }

    function getApplicant(address storageAddress, bytes32 caseId) public view returns(address) {
        return EternalStorage(storageAddress).getAddress(keccak256("case.applicant", caseId));
    }

    function getRespondent(address storageAddress, bytes32 caseId) public view returns(address) {
        return EternalStorage(storageAddress).getAddress(keccak256("case.respondent", caseId));
    }

    function getRefereeAward(address storageAddress, bytes32 caseId) public view returns(uint) {
        return EternalStorage(storageAddress).getUint(keccak256("case.referee.award", caseId));
    }

    function getVotingDate(address storageAddress, bytes32 caseId) public view returns(uint) {
        return EternalStorage(storageAddress).getUint(keccak256("case.date.voting", caseId));
    }

    function getRevealingDate(address storageAddress, bytes32 caseId) public view returns(uint) {
        return EternalStorage(storageAddress).getUint(keccak256("case.date.revealing", caseId));
    }

    function getCloseDate(address storageAddress, bytes32 caseId) public view returns(uint) {
        return EternalStorage(storageAddress).getUint(keccak256("case.date.close", caseId));
    }

    function getRefereeCountNeed(address storageAddress, bytes32 caseId) public view returns(uint) {
        return EternalStorage(storageAddress).getUint(keccak256("case.referee.count.need", caseId));
    }

    function isEthRefereeAward(address storageAddress, bytes32 caseId) public view returns(bool) {
        return EternalStorage(storageAddress).getBool(keccak256("case.referee.award.eth", caseId));
    }
}

contract IBoardConfig is Ownable {

    uint constant decimals = 10 ** uint(18);
    uint8 public version;

    function resetValuesToDefault() external;

    function setStorageAddress(address storageAddress) external;

    function getRefereeFee() external view returns (uint);
    function getRefereeFeeEth() external view returns(uint);

    function getVoteTokenPrice() external view returns (uint);
    function setVoteTokenPrice(uint value) external;

    function getVoteTokenPriceEth() external view returns (uint);
    function setVoteTokenPriceEth(uint value) external;

    function getVoteTokensPerRequest() external view returns (uint);
    function setVoteTokensPerRequest(uint voteTokens) external;

    function getTimeToStartVotingCase() external view returns (uint);
    function setTimeToStartVotingCase(uint value) external;

    function getTimeToRevealVotesCase() external view returns (uint);
    function setTimeToRevealVotesCase(uint value) external;

    function getTimeToCloseCase() external view returns (uint);
    function setTimeToCloseCase(uint value) external;

    function getRefereeCountPerCase() external view returns(uint);
    function setRefereeCountPerCase(uint refereeCount) external;

    function getRefereeNeedCountPerCase() external view returns(uint);
    function setRefereeNeedCountPerCase(uint refereeCount) external;

    function getFullConfiguration()
    external view returns(
        uint voteTokenPrice, uint voteTokenPriceEth, uint voteTokenPerRequest,
        uint refereeCountPerCase, uint refereeNeedCountPerCase,
        uint timeToStartVoting, uint timeToRevealVotes, uint timeToClose
    );

    function getCaseDatesFromNow() public view returns(uint[] dates);

}

contract PaymentHolder is Ownable {

    modifier onlyAllowed() {
        require(allowed[msg.sender]);
        _;
    }

    modifier onlyUpdater() {
        require(msg.sender == updater);
        _;
    }

    mapping(address => bool) public allowed;
    address public updater;

    /*-----------------MAINTAIN METHODS------------------*/

    function setUpdater(address _updater)
    external onlyOwner {
        updater = _updater;
    }

    function migrate(address newHolder, address[] tokens, address[] _allowed)
    external onlyOwner {
        require(PaymentHolder(newHolder).update.value(address(this).balance)(_allowed));
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            uint256 balance = Token(token).balanceOf(this);
            if (balance > 0) {
                require(Token(token).transfer(newHolder, balance));
            }
        }
    }

    function update(address[] _allowed)
    external payable onlyUpdater returns(bool) {
        for (uint256 i = 0; i < _allowed.length; i++) {
            allowed[_allowed[i]] = true;
        }
        return true;
    }

    /*-----------------OWNER FLOW------------------*/

    function allow(address to) 
    external onlyOwner { allowed[to] = true; }

    function prohibit(address to)
    external onlyOwner { allowed[to] = false; }

    /*-----------------ALLOWED FLOW------------------*/

    function depositEth()
    public payable onlyAllowed returns (bool) {
        //Default function to receive eth
        return true;
    }

    function withdrawEth(address to, uint256 amount)
    public onlyAllowed returns(bool) {
        require(address(this).balance >= amount, "Not enough ETH balance");
        to.transfer(amount);
        return true;
    }

    function withdrawToken(address to, uint256 amount, address token)
    public onlyAllowed returns(bool) {
        require(Token(token).balanceOf(this) >= amount, "Not enough token balance");
        require(Token(token).transfer(to, amount));
        return true;
    }
}

contract Board is IBoard {

    using SafeMath for uint;
    using VoteTokenLib for address;
    using CasesLib for address;
    using RefereesLib for address;
    using RefereeCasesLib for address;

    modifier onlyRespondent(bytes32 caseId) {
        require(msg.sender == lib.getRespondent(caseId));
        _;
    }

    modifier hasStatus(bytes32 caseId, CasesLib.CaseStatus state) {
        require(state == lib.getCaseStatus(caseId));
        _;
    }

    modifier before(uint date) {
        require(now <= date);
        _;
    }

    modifier laterOn(uint date) {
        require(now >= date);
        _;
    }

    function Board(address storageAddress, address configAddress, address _paymentHolder) public {
        version = 2;
        config = IBoardConfig(configAddress);
        lib = storageAddress;
        //check real BKX address https://etherscan.io/token/0x45245bc59219eeaAF6cD3f382e078A461FF9De7B
        bkxToken = BkxToken(0x45245bc59219eeaAF6cD3f382e078A461FF9De7B);
        admin = 0xE0b6C095D722961C2C11E55b97fCd0C8bd7a1cD2;
        paymentHolder = _paymentHolder;
        refereePaymentHolder = msg.sender;
    }

    function withdrawEth(uint value) external onlyOwner {
        require(address(this).balance >= value);
        msg.sender.transfer(value);
    }

    function withdrawBkx(uint value) external onlyOwner {
        require(bkxToken.balanceOf(address(this)) >= value);
        require(bkxToken.transfer(msg.sender, value));
    }

    /* configuration */
    function setStorageAddress(address storageAddress) external onlyOwner {
        lib = storageAddress;
    }

    function setConfigAddress(address configAddress) external onlyOwner {
        config = IBoardConfig(configAddress);
    }

    /* dependency tokens */
    function setBkxToken(address tokenAddress) external onlyOwner {
        bkxToken = BkxToken(tokenAddress);
    }

    function setPaymentHolder(address _paymentHolder) external onlyOwner {
        paymentHolder = _paymentHolder;
    }

    function setRefereePaymentHolder(address _refereePaymentHolder) external onlyOwner {
        refereePaymentHolder = _refereePaymentHolder;
    }

    function setAdmin(address newAdmin) external onlyOwner {
        admin = newAdmin;
    }

    function applyForReferee() external {
        uint refereeFee = config.getRefereeFee();
        require(bkxToken.allowance(msg.sender, address(this)) >= refereeFee);
        require(bkxToken.balanceOf(msg.sender) >= refereeFee);
        require(bkxToken.transferFrom(msg.sender, refereePaymentHolder, refereeFee));
        addVotes(msg.sender);
    }

    function addVoteTokens(address referee) external onlyOwnerOrAdmin {
        addVotes(referee);
    }

    function addVotes(address referee) private {
        uint refereeTokens = config.getVoteTokensPerRequest();
        if (!lib.isRefereeApplied(referee)) {
            lib.addReferee(referee);
        }
        uint balance = refereeTokens.add(lib.getVotes(referee));
        lib.setVotes(referee, balance);
        emit RefereeVoteBalanceChanged(referee, balance);
    }

    function openCase(address respondent, bytes32 deal, uint amount, uint refereeAward, bytes32 title, string description)
    external payable {
        require(msg.sender != respondent);
        withdrawPayment(refereeAward);
        uint[] memory dates = config.getCaseDatesFromNow();
        uint refereeCountNeed = config.getRefereeNeedCountPerCase();
        bytes32 caseId = lib.addCase(msg.sender, respondent, deal, amount, refereeAward, title, description, dates, refereeCountNeed, msg.value != 0);
        emit CaseOpened(caseId, msg.sender, respondent, deal, amount, refereeAward, title, description, dates, refereeCountNeed, msg.value != 0);
        assignRefereesToCase(caseId, msg.sender, respondent);
    }

    function withdrawPayment(uint256 amount) private {
        if(msg.value != 0) {
            require(msg.value == amount, "ETH amount must be equal amount");
            require(PaymentHolder(paymentHolder).depositEth.value(msg.value)());
        } else {
            require(bkxToken.allowance(msg.sender, address(this)) >= amount);
            require(bkxToken.balanceOf(msg.sender) >= amount);
            require(bkxToken.transferFrom(msg.sender, paymentHolder, amount));
        }
    }

    function assignRefereesToCase(bytes32 caseId, address applicant, address respondent) private  {
        uint targetCount = config.getRefereeCountPerCase();
        address[] memory foundReferees = lib.getRandomRefereesToCase(applicant, respondent, targetCount);
        for (uint i = 0; i < foundReferees.length; i++) {
            address referee = foundReferees[i];
            uint voteBalance = lib.getVotes(referee);
            voteBalance -= 1;
            lib.setVotes(referee, voteBalance);
            emit RefereeVoteBalanceChanged(referee, voteBalance);
        }
        lib.setRefereesToCase(foundReferees, caseId);
        emit RefereesAssignedToCase(caseId, foundReferees);
    }

    function setRespondentDescription(bytes32 caseId, string description)
    external onlyRespondent(caseId) hasStatus(caseId, CasesLib.CaseStatus.OPENED) before(lib.getVotingDate(caseId)) {
        require(lib.getRespondentDescription(caseId) == 0);
        lib.setRespondentDescription(caseId, description);
        lib.setCaseStatus(caseId, CasesLib.CaseStatus.VOTING);
        emit CaseCommentedByRespondent(caseId, msg.sender, description);
        emit CaseVoting(caseId);
    }

    function startVotingCase(bytes32 caseId)
    external hasStatus(caseId, CasesLib.CaseStatus.OPENED) laterOn(lib.getVotingDate(caseId)) {
        lib.setCaseStatus(caseId, CasesLib.CaseStatus.VOTING);
        emit CaseVoting(caseId);
    }

    function commitVote(bytes32 caseId, bytes32 voteHash)
    external hasStatus(caseId, CasesLib.CaseStatus.VOTING) before(lib.getRevealingDate(caseId))
    {
        require(lib.isRefereeSetToCase(msg.sender, caseId)); //referee must be set to case
        require(!lib.isRefereeVoted(msg.sender, caseId)); //referee can not vote twice
        lib.setRefereeVoteHash(caseId, msg.sender, voteHash);
        emit CaseVoteCommitted(caseId, msg.sender, voteHash);
        if (lib.getRefereeVoteHashCount(caseId) == lib.getRefereeCountByCase(caseId)) {
            lib.setCaseStatus(caseId, CasesLib.CaseStatus.REVEALING);
            emit CaseRevealingVotes(caseId);
        }
    }

    function startRevealingVotes(bytes32 caseId)
    external hasStatus(caseId, CasesLib.CaseStatus.VOTING) laterOn(lib.getRevealingDate(caseId))
    {
        lib.setCaseStatus(caseId, CasesLib.CaseStatus.REVEALING);
        emit CaseRevealingVotes(caseId);
    }

    function revealVote(bytes32 caseId, address referee, uint8 voteOption, bytes32 salt)
    external hasStatus(caseId, CasesLib.CaseStatus.REVEALING) before(lib.getCloseDate(caseId))
    {
        doRevealVote(caseId, referee, voteOption, salt);
        checkShouldMakeVerdict(caseId);
    }

    function revealVotes(bytes32 caseId, address[] referees, uint8[] voteOptions, bytes32[] salts)
    external hasStatus(caseId, CasesLib.CaseStatus.REVEALING) before(lib.getCloseDate(caseId))
    {
        require((referees.length == voteOptions.length) && (referees.length == salts.length));
        for (uint i = 0; i < referees.length; i++) {
            doRevealVote(caseId, referees[i], voteOptions[i], salts[i]);
        }
        checkShouldMakeVerdict(caseId);
    }

    function checkShouldMakeVerdict(bytes32 caseId)
    private {
        if (lib.getRefereeVotesFor(caseId, true) + lib.getRefereeVotesFor(caseId, false) == lib.getRefereeVoteHashCount(caseId)) {
            makeVerdict(caseId);
        }
    }

    function doRevealVote(bytes32 caseId, address referee, uint8 voteOption, bytes32 salt) private {
        require(verifyVote(caseId, referee, voteOption, salt));
        lib.setRefereeVote(caseId, referee,  voteOption == 0);
        emit CaseVoteRevealed(caseId, referee, voteOption, salt);
    }

    function createVoteHash(uint8 voteOption, bytes32 salt)
    public view returns(bytes32) {
        return keccak256(voteOption, salt);
    }

    function verifyVote(bytes32 caseId, address referee, uint8 voteOption, bytes32 salt)
    public view returns(bool){
        return lib.getRefereeVoteHash(caseId, referee) == keccak256(voteOption, salt);
    }

    function verdict(bytes32 caseId)
    external hasStatus(caseId, CasesLib.CaseStatus.REVEALING) laterOn(lib.getCloseDate(caseId)) {
        makeVerdict(caseId);
    }

    function makeVerdict(bytes32 caseId)
    private {
        uint forApplicant = lib.getRefereeVotesFor(caseId, true);
        uint forRespondent = lib.getRefereeVotesFor(caseId, false);
        uint refereeAward = lib.getRefereeAward(caseId);
        bool isNotEnoughVotes = (forApplicant + forRespondent) < lib.getRefereeCountNeed(caseId);
        bool isEthRefereeAward = lib.isEthRefereeAward(caseId);
        if (isNotEnoughVotes || (forApplicant == forRespondent)) {
            withdrawTo(isEthRefereeAward, lib.getApplicant(caseId), refereeAward);
            lib.setCaseStatus(caseId, CasesLib.CaseStatus.CANCELED);
            CasesLib.CaseCanceledCode causeCode = isNotEnoughVotes ?
                CasesLib.CaseCanceledCode.NOT_ENOUGH_VOTES : CasesLib.CaseCanceledCode.EQUAL_NUMBER_OF_VOTES;
            lib.setCaseCanceledCode(caseId, causeCode);
            emit CaseCanceled(caseId, uint8(causeCode));
            withdrawAllRefereeVotes(caseId);
            return;
        }
        bool won = false;
        uint awardPerReferee;
        if (forApplicant > forRespondent) {
            won = true;
            awardPerReferee = refereeAward / forApplicant;
        } else {
            awardPerReferee = refereeAward / forRespondent;
        }
        lib.setCaseStatus(caseId, CasesLib.CaseStatus.CLOSED);
        lib.setCaseWon(caseId, won);
        emit CaseClosed(caseId, won);
        address[] memory wonReferees = lib.getRefereesFor(caseId, won);
        for (uint i = 0; i < wonReferees.length; i++) {
            withdrawTo(isEthRefereeAward, wonReferees[i], awardPerReferee);
            emit RefereeAwarded(wonReferees[i], caseId, awardPerReferee);
        }
        withdrawRefereeVotes(caseId);
    }

    function withdrawTo(bool isEth, address to, uint amount) private {
        if (isEth) {
            require(PaymentHolder(paymentHolder).withdrawEth(to, amount));
        } else {
            require(PaymentHolder(paymentHolder).withdrawToken(to, amount, address(bkxToken)));
        }
    } 

    function withdrawAllRefereeVotes(bytes32 caseId) private {
        address[] memory referees = lib.getRefereesByCase(caseId);
        for (uint i = 0; i < referees.length; i++) {
            withdrawRefereeVote(referees[i]);
        }
    }

    function withdrawRefereeVotes(bytes32 caseId)
    private {
        address[] memory referees = lib.getRefereesByCase(caseId);
        for (uint i = 0; i < referees.length; i++) {
            if (!lib.isRefereeVoted(referees[i], caseId)) {
                withdrawRefereeVote(referees[i]);
            }
        }
    }

    function withdrawRefereeVote(address referee)
    private {
        uint voteBalance = lib.getVotes(referee);
        voteBalance += 1;
        lib.setVotes(referee, voteBalance);
        emit RefereeVoteBalanceChanged(referee, voteBalance);
    }
}