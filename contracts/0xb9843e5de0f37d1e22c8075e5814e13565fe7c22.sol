/**
 * Lucky Block Network Project Smart-Contracts
 * @authors https://grox.solutions
 */

pragma solidity 0.5.7;

library SafeMath {

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
}

contract MultiOwnable {

    mapping (address => bool) _owner;

    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }

    function isOwner(address addr) public view returns (bool) {
        return _owner[addr];
    }

}

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * See https://eips.ethereum.org/EIPS/eip-20
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    modifier whenPaused() {
        require(_paused);
        _;
    }

    function pause() public whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 */
contract ERC20Pausable is ERC20, Pausable {
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {
        return super.decreaseAllowance(spender, subtractedValue);
    }
}

/**
 * @title ApproveAndCall Interface.
 * @dev ApproveAndCall system hepls to communicate with smart-contracts.
 */
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 amount, address token, bytes calldata extraData) external;
}

/**
 * @title The main project contract.
 * @author https://grox.solutions
 */
contract LBNToken is ERC20Pausable, MultiOwnable {

    // name of the token
    string private _name = "Lucky Block Network";
    // symbol of the token
    string private _symbol = "LBN";
    // decimals of the token
    uint8 private _decimals = 18;

    // initial supply
    uint256 public constant INITIAL_SUPPLY = 99990000 * (10 ** 18);

    // an amount of votes required to process an action
    uint8 public consensusValue = 1;

    // struct for proposals
    struct Proposal {
        // amount of votes
        uint8 votes;
        // count of proposals
        uint256 count;
        // double mapping to prevent the error of repeating the same proposal
        mapping (uint256 => mapping (address => bool)) voted;
    }

    // mapping to implement muptiple owners
    mapping (address => bool) _owner;

    // boolean value if minting is finished of not
    bool public mintingIsFinished;

    /**
     * @dev Throws if called while minting is finished.
     */
    modifier isNotFinished {
        require(!mintingIsFinished);
        _;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }

    // events
    event LogProposal(string indexed method, address param1, address param2, uint256 param3, string param4, address indexed voter, uint8 votes, uint8 consensusValue);
    event LogAction(string indexed method, address param1, address param2, uint256 param3, string param4);

    /**
      * @dev constructor function that is called once at deployment of the contract.
      * @param owners 5 initial owners to set.
      * @param recipient Address to receive initial supply.
      */
    constructor(address[] memory owners, address recipient) public {

        for (uint8 i = 0; i < 5; i++) {
            _owner[owners[i]] = true;
        }

        _mint(recipient, INITIAL_SUPPLY);

    }

    /**
      * @dev Internal function that process voting in a given proposal, returns `true` if the voting has succesfully ended.
      * @param props The proposal storage.
      * @notice Every next parameter is given only to emit events.
      * @param method Name of the called method.
      * @param param1 First address parameter.
      * @param param2 Second address parameter.
      * @param param3 uint256 parameter.
      * @param param4 string parameter.
      */
    function _vote(Proposal storage props, string memory method, address param1, address param2, uint256 param3, string memory param4) internal returns(bool) {

        // if that is the new proposal add a number to count to prevent the error of repeating the same proposal
        if (props.votes == 0) {
            props.count++;
        }

        // if msg.sender hasn't voted yet, do this
        if (!props.voted[props.count][msg.sender]) {
            props.votes++;
            props.voted[props.count][msg.sender] = true;
            emit LogProposal(method, param1, param2, param3, param4, msg.sender, props.votes, consensusValue);
        }

        // if an amount of votes is equal or more than consensusValue renew the proposal and return `true` to process the action
        if (props.votes >= consensusValue) {
            props.votes = 0;
            emit LogAction(method, param1, param2, param3, param4);
            return true;
        }

    }

    /**
     * @dev Storage for owner proposals.
     */
    mapping (address => mapping(address => Proposal)) public ownerProp;

    /**
     * @dev Vote to transfer control of the contract from one account to another.
     * @param previousOwner The address to remove ownership from.
     * @param newOwner The address to transfer ownership to.
     * @notice There are only 5 owners of this contract
     */
    function changeOwner(address previousOwner, address newOwner) public onlyOwner {
        require(isOwner(previousOwner) && !isOwner(newOwner));

        if (_vote(ownerProp[previousOwner][newOwner], "changeOwner", previousOwner, newOwner, 0, "")) {
            _owner[previousOwner] = false;
            _owner[newOwner] = true;
        }

    }

    /**
     * @dev Storage for consensus proposals.
     */
    mapping (uint8 => Proposal) public consProp;

    /**
     * @dev Vote to change the consensusValue.
     * @param newConsensusValue new value.
     */
    function setConsensusValue(uint8 newConsensusValue) public onlyOwner {

        if (_vote(consProp[newConsensusValue], "setConsensusValue", address(0), address(0), newConsensusValue, "")) {
            consensusValue = newConsensusValue;
        }

    }

    /**
     * @dev Storage for minting finalize proposal.
     */
    Proposal public finMintProp;

    /**
     * @dev Vote to stop minting of tokens forever.
     */
    function finalizeMinting() public onlyOwner {

        if (_vote(finMintProp, "finalizeMinting", address(0), address(0), 0, "")) {
            mintingIsFinished = true;
        }

    }

    /**
     * @dev Storage for mint proposals.
     */
    mapping (address => mapping (uint256 => mapping (string => Proposal))) public mintProp;

    /**
     * @dev Vote to mint an amount of the token and assigns it to
     * an account.
     * @param to The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function mint(address to, uint256 value) public isNotFinished onlyOwner returns (bool) {

        if (_vote(mintProp[to][value]["mint"], "mint", to, address(0), value, "")) {
            _mint(to, value);
        }

    }

    /**
     * @dev Storage for burn proposals.
     */
    mapping (address => mapping (uint256 => mapping (string => Proposal))) public burnProp;


    /**
     * @dev Vote to burn an amount of the token of a given
     * account.
     * @param from The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function burnFrom(address from, uint256 value) public onlyOwner {

        if (_vote(burnProp[from][value]["burnFrom"], "burnFrom", from, address(0), value, "")) {
            _burn(from, value);
        }

    }

    /**
     * @dev Storage for pause proposals.
     */
    Proposal public pauseProp;

    /**
     * @dev Vote to pause any transfer of tokens.
     * Called by a owner to pause, triggers stopped state.
     */
    function pause() public onlyOwner {

        if (_vote(pauseProp, "pause", address(0), address(0), 0, "")) {
            super.pause();
        }

    }

    /**
     * @dev Storage for unpause proposals.
     */
    Proposal public unpauseProp;

    /**
     * @dev Vote to pause any transfer of tokens.
     * Called by a owner to unpause, triggers normal state.
     */
    function unpause() public onlyOwner {

        if (_vote(unpauseProp, "unpause", address(0), address(0), 0, "")) {
            super.unpause();
        }

    }

    /**
     * @dev Storage for name proposals.
     */
    mapping (string => mapping (string => Proposal)) public nameProp;

    /**
    * @dev Change the name of the token.
    * @param newName New name of the token.
    */
    function changeName(string memory newName) public onlyOwner {

        if (_vote(nameProp[newName]["name"], "changeName", address(0), address(0), 0, newName)) {
            _name = newName;
        }

    }

    /**
     * @dev Storage for symbol proposals.
     */
    mapping (string => mapping (string => Proposal)) public symbolProp;

    /**
    * @dev Change the symbol of the token.
    * @param newSymbol New symbol of the token.
    */
    function changeSymbol(string memory newSymbol) public onlyOwner {

        if (_vote(symbolProp[newSymbol]["symbol"], "changeSymbol", address(0), address(0), 0, newSymbol)) {
            _symbol = newSymbol;
        }

    }

    /**
    * @dev Allows to send tokens (via Approve and TransferFrom) to other smart contract.
    * @param spender Address of smart contracts to work with.
    * @param amount Amount of tokens to send.
    * @param extraData Any extra data.
    */
    function approveAndCall(address spender, uint256 amount, bytes calldata extraData) external returns (bool) {
        require(approve(spender, amount));

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, amount, address(this), extraData);

        return true;
    }

    /**
    * @dev Allows to any owner of the contract withdraw needed ERC20 token from this contract (promo or bounties for example).
    * @param ERC20Token Address of ERC20 token.
    * @param recipient Account to receive tokens.
    */
    function withdrawERC20(address ERC20Token, address recipient) external onlyOwner {

        uint256 amount = IERC20(ERC20Token).balanceOf(address(this));
        IERC20(ERC20Token).transfer(recipient, amount);

    }

    /**
    * @return true if `addr` is the owner of the contract.
    */
    function isOwner(address addr) public view returns (bool) {
        return _owner[addr];
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

}