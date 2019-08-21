pragma solidity ^0.4.8;

//This contract is backed by the constitution of superDAO deployed at : .
//The constitution of the superDAO is the social contract, terms, founding principles and definitions of the vision,
//mission, anti-missions, rules and operation guidelines of superDAO.
//The total number of 3,000,000 represents 3% of 100,000,000 immutable number of superDAO tokens,
//which is the alloted budget of operation for the earliest funding activities.
//Every prommissory token is exchangeable for the real superDAO tokens on a one on one basis.
//Promissiory contract will be deployed with the actual superDAO token contract.
//Early backers can call the "redeem" function on the actual token contract to exchange promissory tokens for the final tokens.

/**
 * @title Promisory Token Contract
 * @author ola
 * --- Collaborators ---
 * @author zlatinov
 * @author panos
 * @author yemi
 * @author archil
 * @author anthony
 */
contract PromissoryToken {

    event FounderSwitchRequestEvent(address _newFounderAddr);
    event FounderSwitchedEvent(address _newFounderAddr);
    event CofounderSwitchedEvent(address _newCofounderAddr);

    event AddedPrepaidTokensEvent(address backer, uint index, uint price, uint amount);
    event PrepaidTokensClaimedEvent(address backer, uint index, uint price, uint amount);
    event TokensClaimedEvent(address backer, uint index, uint price, uint amount);

    event RedeemEvent(address backer, uint amount);

    event WithdrawalCreatedEvent(uint withdrawalId, uint amount, bytes reason);
    event WithdrawalVotedEvent(uint withdrawalId, address backer, uint backerStakeWeigth, uint totalStakeWeight);
    event WithdrawalApproved(uint withdrawalId, uint stakeWeight, bool isMultiPayment, uint amount, bytes reason);

    address founder; //deployer of constitution and PromissoryToken
    bytes32 founderHash; // hash must be confirmed in order to replace founder address
    mapping(address => bytes32) tempHashes; // structure to contain new address to hash storage,
    address cofounder;//helper to aid founder key exchange in case of key loss
    address [] public previousFounders; //list of addresses replaced using the switching process.
    uint constant discountAmount = 60; //discount amount
    uint constant divisor = 100; //divisor to get discount value

    uint public constant minimumPrepaidClaimedPercent = 65;
    uint public promissoryUnits = 3000000; //amount of tokens contants set
    uint public prepaidUnits = 0; //prepaid and set by founder out of 3 million tokens
    uint public claimedUnits = 0; //claimed tokens out of 3 million tokens
    uint public claimedPrepaidUnits = 0; //claimed tokens out of the early backer's tokens/prepaidUnits
    uint public redeemedTokens = 0; //number of tokens out of claimed tokens, redeemed by superDAO token call
    uint public lastPrice = 0; //latest price of token acquired by backer in Wei
    uint public numOfBackers; //number of early backers

    struct backerData {
       uint tokenPrice;
       uint tokenAmount;
       bytes32 privateHash;
       bool prepaid;
       bool claimed;
       uint backerRank;
    }

    address[] public earlyBackerList; //addresses of earliest backers
    address[] public backersAddresses; //addresses of all backers
    mapping(address => backerData[]) public backers;// backer address to backer info mapping
    mapping(address => bool) public backersRedeemed;

    struct withdrawalData {
       uint Amount;
       bool approved;
       bool spent;
       bytes reason;
       address[] backerApprovals;
       uint totalStake;
       address[] destination;
    }

    withdrawalData[] public withdrawals; // Data structure specifying withdrawal
    mapping(address => mapping(uint => bool)) public withdrawalsVotes;

    /**
    * @notice Deploy PromissoryToken contract with `msg.sender.address()` as founder with `_prepaidBackers.number()` prepaid backers
    * @dev This is the constructor of the promisory token contract
    * @param _founderHash Founders password hash, preferable a message digest to further obfuscate duplicaion
    * @param _cofounderAddress The helper cofounder to aid founder key exchange in case of key loss/
    * @param _numOfBackers The number of Early backers. Will be used to control setting early backers
    */
    function PromissoryToken( bytes32 _founderHash, address _cofounderAddress, uint _numOfBackers){
        founder = msg.sender;
        founderHash = sha3(_founderHash);
        cofounder = _cofounderAddress;
        numOfBackers = _numOfBackers;
    }

    /**
    * @notice `msg.sender.address()` updating cofounder address to `_newFounderAddr.address()`
    * @dev allows cofounder to switch out addres for a new one.Can be repeated as many times as needed
    * @param _newCofounderAddr New Address of Cofounder
    * @return True if the coFounder address successfully updated
    */
    function cofounderSwitchAddress(address _newCofounderAddr) external returns (bool success){
        if (msg.sender != cofounder) throw;

        cofounder = _newCofounderAddr;
        CofounderSwitchedEvent(_newCofounderAddr);

        return true;
    }

    /**
    * @notice Founder address update to `_newFounderAddr.address()` is being requested
    * @dev founderSwitchAddress founder indicates intent to switch addresses with new address,
    * hash of pass phrase and a "onetime shared phrase shared with coufounder"
    * @param _founderHash Secret Key to be used to confirm Address update
    * @param _oneTimesharedPhrase Shared pre-hashed Secret key for offline trust to be shared with coFounder to approve Address update
    * @return True if Address switch request successfully created and Temporary hash Values set
    */
    function founderSwitchRequest(bytes32 _founderHash, bytes32 _oneTimesharedPhrase) returns (bool success){
        if(sha3(_founderHash) != founderHash) throw;

        tempHashes[msg.sender] = sha3(msg.sender, founderHash, _oneTimesharedPhrase);
        FounderSwitchRequestEvent(msg.sender);

        return true;
    }

   /**
    * @notice `msg.sender.address()` approving `_newFounderAddr.address()` as new founder address
    * @dev CofounderSwitchAddress which allows previously set cofounder to approve address
    * switch by founder. Must have a one time shared phrase thats is shared with founder that corresponding with a
    * hashed value.
    * @param _newFounderAddr The address of Founder to be newly set
    * @param _oneTimesharedPhrase Shared pre-hashed Secret key for offline trust, to provide access to the approval function
    * @return True if new Founder address successfully approved
    */
    function cofounderApproveSwitchRequest(address _newFounderAddr, bytes32 _oneTimesharedPhrase) external returns (bool success){
        if(msg.sender != cofounder || sha3(_newFounderAddr, founderHash, _oneTimesharedPhrase) != tempHashes[_newFounderAddr]) throw;

        previousFounders.push(founder);
        founder = _newFounderAddr;
        FounderSwitchedEvent(_newFounderAddr);

        return true;
    }

    /**
    * @notice Adding `_backer.address()` as an early backer
    * @dev Add Early backers to Contract setting the transacton details
    * @param _backer The address of the superDAO backer
    * @param _tokenPrice The price/rate at which the superDAO tokens were bought
    * @param _tokenAmount The total number of superDAO token purcgased at the indicated rate
    * @param _privatePhrase Shared pre-hashed Secret key for offline price negotiation to online attestation of SuperDAO tokens ownership
    * @param _backerRank Rank of the backer in the backers list
    * @return Thre index of _backer  in the backers list
    */
    function setPrepaid(address _backer, uint _tokenPrice, uint _tokenAmount, string _privatePhrase, uint _backerRank)
        external
        founderCall
        returns (uint)
    {
        if (_tokenPrice == 0 || _tokenAmount == 0 || claimedPrepaidUnits>0 ||
            _tokenAmount + prepaidUnits + claimedUnits > promissoryUnits) throw;
        if (earlyBackerList.length == numOfBackers && backers[_backer].length == 0) throw ;
        if (backers[_backer].length == 0) {
            earlyBackerList.push(_backer);
            backersAddresses.push(_backer);
        }
        backers[_backer].push(backerData(_tokenPrice, _tokenAmount, sha3(_privatePhrase, _backer), true, false, _backerRank));

        prepaidUnits +=_tokenAmount;
        lastPrice = _tokenPrice;

        AddedPrepaidTokensEvent(_backer, backers[_backer].length - 1, _tokenPrice, _tokenAmount);

        return backers[_backer].length - 1;
    }

    /**
    * @notice Claiming `_tokenAmount.number()` superDAO tokens by `msg.sender.address()`
    * @dev Claim superDAO Early backer tokens
    * @param _index index of tokens to claim
    * @param _boughtTokensPrice Price at which the superDAO tokens were bought
    * @param _tokenAmount Number of superDAO tokens to be claimed
    * @param _privatePhrase Shared pre-hashed Secret key for offline price negotiation to online attestation of SuperDAO tokens ownership
    * @param _backerRank Backer rank of the backer in the superDAO
    */
    function claimPrepaid(uint _index, uint _boughtTokensPrice, uint _tokenAmount, string _privatePhrase, uint _backerRank)
        external
        EarliestBackersSet
    {
        if(backers[msg.sender][_index].prepaid == true &&
           backers[msg.sender][_index].claimed == false &&
           backers[msg.sender][_index].tokenAmount == _tokenAmount &&
           backers[msg.sender][_index].tokenPrice == _boughtTokensPrice &&
           backers[msg.sender][_index].privateHash == sha3( _privatePhrase, msg.sender) &&
           backers[msg.sender][_index].backerRank == _backerRank)
        {
            backers[msg.sender][_index].claimed = true;
            claimedPrepaidUnits += _tokenAmount;

            PrepaidTokensClaimedEvent(msg.sender, _index, _boughtTokensPrice, _tokenAmount);
        } else {
            throw;
        }
    }

    /**
    * @notice `msg.sender.address()` is Purchasing `(msg.value / lastPrice).toFixed(0)` superDAO Tokens at `lastPrice`
    * @dev Purchase new superDAO Tokens if the amount of tokens are still available for purchase
    */
    function claim()
        payable
        external
        MinimumBackersClaimed
   {
        if (lastPrice == 0) throw;

        //don`t accept transactions with zero value
        if (msg.value == 0) throw;


        //Effective discount for Pre-crowdfunding backers of 40% Leaving effective rate of 60%
        uint discountPrice = lastPrice * discountAmount / divisor;

        uint tokenAmount = (msg.value / discountPrice);//Effect the discount rate 0f 40%

        if (tokenAmount + claimedUnits + prepaidUnits > promissoryUnits) throw;

        if (backers[msg.sender].length == 0) {
            backersAddresses.push(msg.sender);
        }
        backers[msg.sender].push(backerData(discountPrice, tokenAmount, sha3(msg.sender), false, true, 0));

        claimedUnits += tokenAmount;

        TokensClaimedEvent(msg.sender, backers[msg.sender].length - 1, discountPrice, tokenAmount);
    }

    /**
     * @notice checking `_backerAddress.address()` superDAO Token balance: `index`
     * @dev Check Token balance by index of backer, return values can be used to instantiate a backerData struct
     * @param _backerAddress The Backer's address
     * @param index The balance to check
     * @return tokenPrice The Price at which the tokens were bought
     * @return tokenAmount The number of tokens that were bought
     * @return Shared pre-hashed Secret key for offline price negotiation 
     * @return prepaid True if backer is an early backer
     * @return claimed True if the Token has already been claimed by the backer
     */
    function checkBalance(address _backerAddress, uint index) constant returns (uint, uint, bytes32, bool, bool){
        return (
            backers[_backerAddress][index].tokenPrice,
            backers[_backerAddress][index].tokenAmount,
            backers[_backerAddress][index].privateHash,
            backers[_backerAddress][index].prepaid,
            backers[_backerAddress][index].claimed
            );
    }

    /**
    * @notice Approving withdrawal `_withdrawalID`
    * @dev Approve a withdrawal from the superDAO and mark the withdrawal as spent
    * @param _withdrawalID The ID of the withdrawal
    */
    function approveWithdraw(uint _withdrawalID)
        external
        backerCheck(_withdrawalID)
    {
        withdrawalsVotes[msg.sender][_withdrawalID] = true;

        uint backerStake = 0;
        for (uint i = 0; i < backers[msg.sender].length; i++) {
            backerStake += backers[msg.sender][i].tokenAmount;
        }
        withdrawals[_withdrawalID].backerApprovals.push(msg.sender);
        withdrawals[_withdrawalID].totalStake += backerStake;

        WithdrawalVotedEvent(_withdrawalID, msg.sender, backerStake, withdrawals[_withdrawalID].totalStake);

        if(withdrawals[_withdrawalID].totalStake >= (claimedPrepaidUnits + claimedUnits) / 3) {
            uint amountPerAddr;
            bool isMultiPayment = withdrawals[_withdrawalID].destination.length > 1;

            if(isMultiPayment == false){
                amountPerAddr = withdrawals[_withdrawalID].Amount;
            }
            else {
                amountPerAddr = withdrawals[_withdrawalID].Amount / withdrawals[_withdrawalID].destination.length;
            }

            withdrawals[_withdrawalID].approved = true;
            withdrawals[_withdrawalID].spent = true;

            for(i = 0; i < withdrawals[_withdrawalID].destination.length; i++){
                if(!withdrawals[_withdrawalID].destination[i].send(amountPerAddr)) throw;
            }

            WithdrawalApproved(_withdrawalID,
                withdrawals[_withdrawalID].totalStake,
                isMultiPayment,
                withdrawals[_withdrawalID].Amount,
                withdrawals[_withdrawalID].reason);
        }
    }

    /**
    * @notice Requestng withdrawal of `_totalAmount` to `_destination.address()`
    * @dev Create a new withdrawal request
    * @param _totalAmount The total amount of tokens to be withdrawan, should be equal to the total number of owned tokens
    * @param _reason Reason/Description for the withdrawal
    * @param _destination The receiving address
    */
    function withdraw(uint _totalAmount, bytes _reason, address[] _destination)
        external
        founderCall
    {
        if (this.balance < _totalAmount) throw;

        uint withdrawalID = withdrawals.length++;

        withdrawals[withdrawalID].Amount = _totalAmount;
        withdrawals[withdrawalID].reason = _reason;
        withdrawals[withdrawalID].destination = _destination;
        withdrawals[withdrawalID].approved = false;
        withdrawals[withdrawalID].spent = false;

        WithdrawalCreatedEvent(withdrawalID, _totalAmount, _reason);
    }

    /**
    * @notice Backer `_bacherAddr.address()` is redeeming `_amount` superDAO Tokens
    * @dev Check if backer tokens have been claimed but not redeemed, then redeem them
    * @param _amount The total number of redeemable tokens
    * @param _backerAddr The address of the backer
    * @return True if tokens were successfully redeemed else false
    */
    function redeem(uint _amount, address _backerAddr) returns(bool){
        if (backersRedeemed[_backerAddr] == true) {
            return false;
        }

        uint totalTokens = 0;

        for (uint i = 0; i < backers[_backerAddr].length; i++) {
            if (backers[_backerAddr][i].claimed == false) {
                return false;
            }
            totalTokens += backers[_backerAddr][i].tokenAmount;
        }

        if (totalTokens == _amount){
            backersRedeemed[_backerAddr] = true;

            RedeemEvent(_backerAddr, totalTokens);

            return true;
        }
        else {
            return false;
        }
    }

    /**
    * @notice check withdrawal status of `_withdrawalID`
    * @dev Get the withdrawal of a withdrawal. Return values can be used to instantiate a withdrawalData struct
    * @param _withdrawalID The ID of the withdrawal
    * @return Amount The Amount requested in the withdrawal
    * @return approved True if the withdrawal has been approved
    * @return reason Reason/Description of the Withdrawal
    * @return backerApprovals Addresses of backers who approved the withdrawal
    * @return totalStake Total number of tokens which backed the withdrawal(Total number of tokens owned by backers who approved the withdrawal)
    * @return destination Receiving address of the withdrawal
    */
    function getWithdrawalData(uint _withdrawalID) constant public returns (uint, bool, bytes, address[], uint, address[]){
        return (
            withdrawals[_withdrawalID].Amount,
            withdrawals[_withdrawalID].approved,
            withdrawals[_withdrawalID].reason,
            withdrawals[_withdrawalID].backerApprovals,
            withdrawals[_withdrawalID].totalStake,
            withdrawals[_withdrawalID].destination);
    }

    modifier founderCall{
        if (msg.sender != founder) throw;
        _;
    }

    modifier backerCheck(uint _withdrawalID){
        if(backers[msg.sender].length == 0 || withdrawals[_withdrawalID].spent == true || withdrawalsVotes[msg.sender][_withdrawalID] == true) throw;
        _;
    }

    modifier EarliestBackersSet{
       if(earlyBackerList.length < numOfBackers) throw;
       _;
    }

    modifier MinimumBackersClaimed(){
      if(prepaidUnits == 0 ||
        claimedPrepaidUnits == 0 ||
        (claimedPrepaidUnits * divisor / prepaidUnits) < minimumPrepaidClaimedPercent) {
            throw;
        }
      _;
    }

    /*
     * Safeguard function.
     * This function gets executed if a transaction with invalid data is sent to
     * the contract or just ether without data.
     */
    function () {
        throw;
    }

}