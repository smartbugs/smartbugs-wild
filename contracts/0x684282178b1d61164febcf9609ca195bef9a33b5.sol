/*
Corporation SmartContract.
developed by: cryptonomica.net, 2016

used sources:
https://www.ethereum.org/token // example of the token standart
https://github.com/ethereum/EIPs/issues/20 // token standart description
https://www.ethereum.org/dao // voting example
*/

/*
How to deploy (estimated: 1,641,268 gas):
1) For development: use https://ethereum.github.io/browser-solidity/
2) For testing on Testnet: Open the default ('Mist') wallet (if you are only testing, go to the menu develop > network > testnet), go to the Contracts tab and then press deploy contract, and on the solidity code box, paste the code above.
3) For prodaction, like in 2) but on Main Network.
To verify your deployed smartcontract source code for public go to:
https://etherscan.io/verifyContract
*/

// 'interface':
//  this is expected from another contract,
//  if it wants to spend tokens (shares) of behalf of the token owner
//  in our contract
//  f.e.: a 'multisig' SmartContract for transfering shares from seller
//  to buyer
contract tokenRecipient {
    function receiveApproval(address _from,     // sharehoder
                             uint256 _value,    // number of shares
                             address _share,    // - will be this contract
                             bytes _extraData); //
}

contract Corporation {

    /* Standard public variables of the token */
    string public standard = 'Token 0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    /* ------------------- Corporate Stock Ledger ---------- */
    // Shares, shareholders, balances ect.

    // list of all sharehoders (represented by Ethereum accounts)
    // in this Corporation's history, # is ID
    address[] public shareholder;
    // this helps to find address by ID without loop
    mapping (address => uint256) public shareholderID;
    // list of adresses, that who currently own at least share
    // not public, use getCurrentShareholders()
    address[] activeShareholdersArray;
    // balances:
    mapping (address => uint256) public balanceOf;
    // shares that have to be managed by external contract
    mapping (address => mapping (address => uint256)) public allowance;

    /*  --------------- Constructor --------- */
    // Initializes contract with initial supply tokens to the creator of the contract
    function Corporation () { // - truffle compiles only no args Constructor
        uint256 initialSupply = 12000; // shares quantity, constant
        balanceOf[msg.sender] = initialSupply; // Give the creator all initial tokens
        totalSupply = initialSupply;  // Update total supply
        name = "shares"; //tokenName; // Set the name for display purposes
        symbol = "sh"; // tokenSymbol; // Set the symbol for display purposes
        decimals = 0; // Amount of decimals for display purposes

        // -- start corporate stock ledger
        shareholderID[this] = shareholder.push(this)-1; // # 0
        shareholderID[msg.sender] = shareholder.push(msg.sender)-1; // #1
        activeShareholdersArray.push(msg.sender); // add to active shareholders
    }

    /* --------------- Shares management ------ */

    // This generates a public event on the blockchain that will notify clients. In 'Mist' SmartContract page enable 'Watch contract events'
    event Transfer(address indexed from, address indexed to, uint256 value);

    function getCurrentShareholders() returns (address[]){
        delete activeShareholdersArray;
        for (uint256 i=0; i < shareholder.length; i++){
            if (balanceOf[shareholder[i]] > 0){
                activeShareholdersArray.push(shareholder[i]);
            }
            } return activeShareholdersArray;
        }

    /*  -- can be used to transfer shares to new contract
    together with getCurrentShareholders() */
    function getBalanceByAdress(address _address) returns (uint256) {
        return balanceOf[_address];
    }

    function getMyShareholderID() returns (uint256) {
        return shareholderID[msg.sender];
    }

    function getShareholderAdressByID(uint256 _id) returns (address){
        return shareholder[_id];
    }

    function getMyShares() returns (uint256) {
        return balanceOf[msg.sender];
    }


    /* ---- Transfer shares to another adress ----
    (shareholder's address calls this)
    */
    function transfer(address _to, uint256 _value) {
        // check arguments:
        if (_value < 1) throw;
        if (this == _to) throw; // do not send shares to contract itself;
        if (balanceOf[msg.sender] < _value) throw; // Check if the sender has enough

        // make transaction
        balanceOf[msg.sender] -= _value; // Subtract from the sender
        balanceOf[_to] += _value;       // Add the same to the recipient

        // if new address, add it to shareholders history (stock ledger):
        if (shareholderID[_to] == 0){ // ----------- check if works
            shareholderID[_to] = shareholder.push(_to)-1;
        }

        // Notify anyone listening that this transfer took place
        Transfer(msg.sender, _to, _value);
    }

    /* Allow another contract to spend some shares in your behalf
    (shareholder calls this) */
    function approveAndCall(address _spender, // another contract's adress
                            uint256 _value, // number of shares
                            bytes _extraData) // data for another contract
    returns (bool success) {
        // msg.sender - account owner who gives allowance
        // _spender   - address of another contract
        // it writes in "allowance" that this owner allows another
        // contract (_spender) to spend thi amont (_value) of shares
        // in his behalf
        allowance[msg.sender][_spender] = _value;
        // 'spender' is another contract that implements code
        //  prescribed in 'shareRecipient' above
        tokenRecipient spender = tokenRecipient(_spender);
        // this contract calls 'receiveApproval' function
        // of another contract to send information about
        // allowance
        spender.receiveApproval(msg.sender, // shares owner
                                _value,     // number of shares
                                this,       // this contract's adress
                                _extraData);// data from shares owner
        return true;
    }

    /* this function can be called from another contract, after it
    have allowance to transfer shares in behalf of sharehoder  */
    function transferFrom(address _from,
                          address _to,
                          uint256 _value)
    returns (bool success) {

        // Check arguments:
        // should one share or more
        if (_value < 1) throw;
        // do not send shares to this contract itself;
        if (this == _to) throw;
        // Check if the sender has enough
        if (balanceOf[_from] < _value) throw;

        // Check allowance
        if (_value > allowance[_from][msg.sender]) throw;

        // if transfer to new address -- add him to ledger
        if (shareholderID[_to] == 0){
            shareholderID[_to] = shareholder.push(_to)-1; // push function returns the new length
        }

        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;

        // Change allowances correspondingly
        allowance[_from][msg.sender] -= _value;
        // Notify anyone listening that this transfer took place
        Transfer(_from, _to, _value);

        return true;
    }

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }

    /*  --------- Voting  --------------  */
    // we only count 'yes' votes, not voting 'yes'
    // considered as voting 'no' (as stated in Bylaws)

    // each proposal should contain it's text
    // index of text in this array is a proposal ID
    string[] public proposalText;
    // proposalID => (shareholder => "if already voted for this proposal")
    mapping (uint256 => mapping (address => bool)) voted;
    // proposalID => addresses voted 'yes'
    // exact number of votes according to shares will be counted
    // after deadline
    mapping (uint256 => address[]) public votes;
    // proposalID => deadline
    mapping (uint256 => uint256) public deadline;
    // proposalID => final 'yes' votes
    mapping (uint256 => uint256) public results;
    // proposals of every shareholder
    mapping (address => uint256[]) public proposalsByShareholder;


    event ProposalAdded(uint256 proposalID,
                        address initiator,
                        string description,
                        uint256 deadline);

    event VotingFinished(uint256 proposalID, uint256 votes);

    function makeNewProposal(string _proposalDescription,
                             uint256 _debatingPeriodInMinutes)
    returns (uint256){
        // only shareholder with one or more shares can make a proposal
        // !!!! can be more then one share required
        if (balanceOf[msg.sender] < 1) throw;

        uint256 id = proposalText.push(_proposalDescription)-1;
        deadline[id] = now + _debatingPeriodInMinutes * 1 minutes;

        // add to proposals of this shareholder:
        proposalsByShareholder[msg.sender].push(id);

        // initiator always votes 'yes'
        votes[id].push(msg.sender);
        voted[id][msg.sender] = true;

        ProposalAdded(id, msg.sender, _proposalDescription, deadline[id]);

        return id; // returns proposal id
    }

    function getMyProposals() returns (uint256[]){
        return proposalsByShareholder[msg.sender];
    }

    function voteForProposal(uint256 _proposalID) returns (string) {

        // if no shares currently owned - no right to vote
        if (balanceOf[msg.sender] < 1) return "no shares, vote not accepted";

        // if already voted - throw, else voting can be spammed
        if (voted[_proposalID][msg.sender]){
            return "already voted, vote not accepted";
        }

        // no votes after deadline
        if (now > deadline[_proposalID] ){
            return "vote not accepted after deadline";
        }

        // add to list of voted 'yes'
        votes[_proposalID].push(msg.sender);
        voted[_proposalID][msg.sender] = true;
        return "vote accepted";
    }

    // to count votes this transaction should be started manually
    // from _any_ Ethereum address after deadline
    function countVotes(uint256 _proposalID) returns (uint256){

        // if not after deadline - throw
        if (now < deadline[_proposalID]) throw;

        // if already counted return result;
        if (results[_proposalID] > 0) return results[_proposalID];

        // else should count results and store in public variable
        uint256 result = 0;
        for (uint256 i = 0; i < votes[_proposalID].length; i++){

            address voter = votes[_proposalID][i];
            result = result + balanceOf[voter];
        }

        // Log and notify anyone listening that this voting finished
        // with 'result' - number of 'yes' votes
        VotingFinished(_proposalID, result);

        return result;
    }

}