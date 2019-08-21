pragma solidity >=0.5.7 <0.6.0;

/*
*  xEuro.sol
*  xEUR tokens smart contract
*  implements [ERC-20 Token Standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)
*  ver. 1.0.0
*  2019-04-15
*  https://xeuro.online
*  https://etherscan.io/address/0xC31C61cf55fB5E646684AD8E8517793ec9A22c5e
*  deployed on block: 7571826
*  solc version :  0.5.7+commit.6da8b019
**/

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

/* "Interfaces" */

// see: https://github.com/ethereum/EIPs/issues/677
contract tokenRecipient {
    function tokenFallback(address _from, uint256 _value, bytes memory _extraData) public returns (bool);
}

contract xEuro {

    // see: https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC20/BasicToken.sol
    using SafeMath for uint256;

    /* --- ERC-20 variables ----- */

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#name
    // function name() constant returns (string name)
    string public name = "xEuro";

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#symbol
    // function symbol() constant returns (string symbol)
    string public symbol = "xEUR";

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#decimals
    // function decimals() constant returns (uint8 decimals)
    uint8 public decimals = 0; // 1 token = €1, no smaller unit

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#totalsupply
    // function totalSupply() constant returns (uint256 totalSupply)
    // we start with zero
    uint256 public totalSupply = 0;

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#balanceof
    // function balanceOf(address _owner) constant returns (uint256 balance)
    mapping(address => uint256) public balanceOf;

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#allowance
    // function allowance(address _owner, address _spender) constant returns (uint256 remaining)
    mapping(address => mapping(address => uint256)) public allowance;

    /* --- administrative variables  */

    // admins
    mapping(address => bool) public isAdmin;

    // addresses allowed to mint tokens:
    mapping(address => bool) public canMint;

    // addresses allowed to transfer tokens from contract's own address:
    mapping(address => bool) public canTransferFromContract;

    // addresses allowed to burn tokens (on contract's own address):
    mapping(address => bool) public canBurn;

    /* ---------- Constructor */
    // do not forget about:
    // https://medium.com/@codetractio/a-look-into-paritys-multisig-wallet-bug-affecting-100-million-in-ether-and-tokens-356f5ba6e90a
    constructor() public {// Constructor must be public or internal
        isAdmin[msg.sender] = true;
        canMint[msg.sender] = true;
        canTransferFromContract[msg.sender] = true;
        canBurn[msg.sender] = true;
    }

    /* --- ERC-20 events */
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#events

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#transfer-1
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* --- Interaction with other contracts events */
    event DataSentToAnotherContract(address indexed _from, address indexed _toContract, bytes _extraData);

    /* --- ERC-20 Functions */
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#methods

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#transfer
    function transfer(address _to, uint256 _value) public returns (bool){
        return transferFrom(msg.sender, _to, _value);
    }

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#transferfrom
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool){

        // Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event (ERC-20)
        require(_value >= 0);

        // The function SHOULD throw unless the _from account has deliberately authorized the sender of the message via some mechanism
        require(msg.sender == _from || _value <= allowance[_from][msg.sender] || (_from == address(this) && canTransferFromContract[msg.sender]));

        // check if _from account have required amount
        require(_value <= balanceOf[_from]);

        if (_to == address(this)) {
            // (!) only token holder can send tokens to smart contract to get fiat, not using allowance
            require(_from == msg.sender);
        }

        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);

        // If allowance used, change allowances correspondingly
        if (_from != msg.sender && _from != address(this)) {
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        }

        if (_to == address(this) && _value > 0) {

            require(_value >= minExchangeAmount);

            tokensInEventsCounter++;
            tokensInTransfer[tokensInEventsCounter].from = _from;
            tokensInTransfer[tokensInEventsCounter].value = _value;
            tokensInTransfer[tokensInEventsCounter].receivedOn = now;

            emit TokensIn(
                _from,
                _value,
                tokensInEventsCounter
            );
        }

        emit Transfer(_from, _to, _value);

        return true;
    }

    /*  ---------- Interaction with other contracts  */

    /* https://github.com/ethereum/EIPs/issues/677
    * transfer tokens with additional info to another smart contract, and calls its correspondent function
    * @param address _to - another smart contract address
    * @param uint256 _value - number of tokens
    * @param bytes _extraData - data to send to another contract
    * > this may be used to convert pre-ICO tokens to ICO tokens
    */
    function transferAndCall(address _to, uint256 _value, bytes memory _extraData) public returns (bool){

        tokenRecipient receiver = tokenRecipient(_to);

        if (transferFrom(msg.sender, _to, _value)) {

            if (receiver.tokenFallback(msg.sender, _value, _extraData)) {

                emit DataSentToAnotherContract(msg.sender, _to, _extraData);

                return true;

            }

        }
        return false;
    }

    // the same as above, but for all tokens on user account
    // for example for converting ALL tokens of user account to another tokens
    function transferAllAndCall(address _to, bytes memory _extraData) public returns (bool){
        return transferAndCall(_to, balanceOf[msg.sender], _extraData);
    }

    /* --- Administrative functions */

    /* --- isAdmin */
    event AdminAdded(address indexed by, address indexed newAdmin);//
    function addAdmin(address _newAdmin) public returns (bool){
        require(isAdmin[msg.sender]);

        isAdmin[_newAdmin] = true;
        emit AdminAdded(msg.sender, _newAdmin);
        return true;
    } //
    event AdminRemoved(address indexed by, address indexed _oldAdmin);//
    function removeAdmin(address _oldAdmin) public returns (bool){
        require(isAdmin[msg.sender]);

        // prevents from deleting the last admin (can be multisig smart contract) by itself:
        require(msg.sender != _oldAdmin);
        isAdmin[_oldAdmin] = false;
        emit AdminRemoved(msg.sender, _oldAdmin);
        return true;
    }

    uint256 minExchangeAmount = 12; // xEuro tokens
    event minExchangeAmountChanged (address indexed by, uint256 from, uint256 to); //
    function changeMinExchangeAmount(uint256 _minExchangeAmount) public returns (bool){
        require(isAdmin[msg.sender]);

        uint256 from = minExchangeAmount;
        minExchangeAmount = _minExchangeAmount;
        emit minExchangeAmountChanged(msg.sender, from, minExchangeAmount);
        return true;
    }

    /* --- canMint */
    event AddressAddedToCanMint(address indexed by, address indexed newAddress); //
    function addToCanMint(address _newAddress) public returns (bool){
        require(isAdmin[msg.sender]);

        canMint[_newAddress] = true;
        emit AddressAddedToCanMint(msg.sender, _newAddress);
        return true;
    }//
    event AddressRemovedFromCanMint(address indexed by, address indexed removedAddress);//
    function removeFromCanMint(address _addressToRemove) public returns (bool){
        require(isAdmin[msg.sender]);

        canMint[_addressToRemove] = false;
        emit AddressRemovedFromCanMint(msg.sender, _addressToRemove);
        return true;
    }

    /* --- canTransferFromContract*/
    event AddressAddedToCanTransferFromContract(address indexed by, address indexed newAddress); //
    function addToCanTransferFromContract(address _newAddress) public returns (bool){
        require(isAdmin[msg.sender]);

        canTransferFromContract[_newAddress] = true;
        emit AddressAddedToCanTransferFromContract(msg.sender, _newAddress);
        return true;
    }//
    event AddressRemovedFromCanTransferFromContract(address indexed by, address indexed removedAddress);//
    function removeFromCanTransferFromContract(address _addressToRemove) public returns (bool){
        require(isAdmin[msg.sender]);

        canTransferFromContract[_addressToRemove] = false;
        emit AddressRemovedFromCanTransferFromContract(msg.sender, _addressToRemove);
        return true;
    }

    /* --- canBurn */
    event AddressAddedToCanBurn(address indexed by, address indexed newAddress); //
    function addToCanBurn(address _newAddress) public returns (bool){
        require(isAdmin[msg.sender]);

        canBurn[_newAddress] = true;
        emit AddressAddedToCanBurn(msg.sender, _newAddress);
        return true;
    }//
    event AddressRemovedFromCanBurn(address indexed by, address indexed removedAddress);//
    function removeFromCanBurn(address _addressToRemove) public returns (bool){
        require(isAdmin[msg.sender]);

        canBurn[_addressToRemove] = false;
        emit AddressRemovedFromCanBurn(msg.sender, _addressToRemove);
        return true;
    }

    /* ---------- Create and burn tokens  */

    /* -- Accounting: exchange fiat to tokens (fiat sent to our bank acc with eth acc in reference > tokens ) */
    uint public mintTokensEventsCounter = 0;//
    struct MintTokensEvent {
        address mintedBy; //
        uint256 fiatInPaymentId;
        uint value;   //
        uint on;    // UnixTime
        uint currentTotalSupply;
    } //
    //  keep all fiat tx ids, to prevent minting tokens twice (or more times) for the same fiat tx
    mapping(uint256 => bool) public fiatInPaymentIds;

    // here we can find a MintTokensEvent by fiatInPaymentId,
    // so we now if tokens were minted for given incoming fiat payment
    mapping(uint256 => MintTokensEvent) public fiatInPaymentsToMintTokensEvent;

    // here we store MintTokensEvent with its ordinal numbers
    mapping(uint256 => MintTokensEvent) public mintTokensEvent; //
    event TokensMinted(
        address indexed by,
        uint256 indexed fiatInPaymentId,
        uint value,
        uint currentTotalSupply,
        uint indexed mintTokensEventsCounter
    );

    // tokens should be minted to contracts own address, (!) after that tokens should be transferred using transferFrom
    function mintTokens(uint256 value, uint256 fiatInPaymentId) public returns (bool){

        require(canMint[msg.sender]);

        // require that this fiatInPaymentId was not used before:
        require(!fiatInPaymentIds[fiatInPaymentId]);

        require(value >= 0);
        // <<< this is the moment when new tokens appear in the system
        totalSupply = totalSupply.add(value);
        // first token holder of fresh minted tokens is the contract itself
        balanceOf[address(this)] = balanceOf[address(this)].add(value);

        mintTokensEventsCounter++;
        mintTokensEvent[mintTokensEventsCounter].mintedBy = msg.sender;
        mintTokensEvent[mintTokensEventsCounter].fiatInPaymentId = fiatInPaymentId;
        mintTokensEvent[mintTokensEventsCounter].value = value;
        mintTokensEvent[mintTokensEventsCounter].on = block.timestamp;
        mintTokensEvent[mintTokensEventsCounter].currentTotalSupply = totalSupply;
        //
        fiatInPaymentsToMintTokensEvent[fiatInPaymentId] = mintTokensEvent[mintTokensEventsCounter];

        emit TokensMinted(msg.sender, fiatInPaymentId, value, totalSupply, mintTokensEventsCounter);

        fiatInPaymentIds[fiatInPaymentId] = true;

        return true;

    }

    // requires msg.sender be both 'canMint' and 'canTransferFromContract'
    function mintAndTransfer(
        uint256 _value,
        uint256 fiatInPaymentId,
        address _to
    ) public returns (bool){

        if (mintTokens(_value, fiatInPaymentId) && transferFrom(address(this), _to, _value)) {
            return true;
        }
        return false;
    }

    /* -- Accounting: exchange tokens to fiat (tokens sent to contract owns address > fiat payment) */
    uint public tokensInEventsCounter = 0;//
    struct TokensInTransfer {// <<< used in 'transfer'
        address from; //
        uint value;   //
        uint receivedOn; // UnixTime
    } //
    mapping(uint256 => TokensInTransfer) public tokensInTransfer; //
    event TokensIn(
        address indexed from,
        uint256 value,
        uint256 indexed tokensInEventsCounter
    );//

    uint public burnTokensEventsCounter = 0;//
    struct burnTokensEvent {
        address by; //
        uint256 value;   //
        uint256 tokensInEventId;
        uint256 fiatOutPaymentId;
        uint256 burnedOn; // UnixTime
        uint256 currentTotalSupply;
    } //
    mapping(uint => burnTokensEvent) public burnTokensEvents;

    // we count every fiat payment id used when burn tokens to prevent using it twice
    mapping(uint256 => bool) public fiatOutPaymentIdsUsed; //

    event TokensBurned(
        address indexed by,
        uint256 value,
        uint256 indexed tokensInEventId,
        uint256 indexed fiatOutPaymentId,
        uint burnedOn, // UnixTime
        uint currentTotalSupply
    );

    // (!) only contract's own tokens (balanceOf[this]) can be burned
    function burnTokens(
        uint256 value,
        uint256 tokensInEventId,
        uint256 fiatOutPaymentId
    ) public returns (bool){

        require(canBurn[msg.sender]);

        require(value >= 0);
        require(balanceOf[address(this)] >= value);

        // require(!tokensInEventIdsUsed[tokensInEventId]);
        require(!fiatOutPaymentIdsUsed[fiatOutPaymentId]);

        balanceOf[address(this)] = balanceOf[address(this)].sub(value);
        totalSupply = totalSupply.sub(value);

        burnTokensEventsCounter++;
        burnTokensEvents[burnTokensEventsCounter].by = msg.sender;
        burnTokensEvents[burnTokensEventsCounter].value = value;
        burnTokensEvents[burnTokensEventsCounter].tokensInEventId = tokensInEventId;
        burnTokensEvents[burnTokensEventsCounter].fiatOutPaymentId = fiatOutPaymentId;
        burnTokensEvents[burnTokensEventsCounter].burnedOn = block.timestamp;
        burnTokensEvents[burnTokensEventsCounter].currentTotalSupply = totalSupply;

        emit TokensBurned(msg.sender, value, tokensInEventId, fiatOutPaymentId, block.timestamp, totalSupply);

        fiatOutPaymentIdsUsed[fiatOutPaymentId];

        return true;
    }

}