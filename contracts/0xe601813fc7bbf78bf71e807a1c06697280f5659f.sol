pragma solidity ^0.4.23;

 /*
 * Contract that is working with ERC223 tokens
 * https://github.com/ethereum/EIPs/issues/223
 */

/// @title ERC223ReceivingContract - Standard contract implementation for compatibility with ERC223 tokens.
contract ERC223ReceivingContract {

    /// @dev Function that is called when a user or another contract wants to transfer funds.
    /// @param _from Transaction initiator, analogue of msg.sender
    /// @param _value Number of tokens to transfer.
    /// @param _data Data containig a function signature and/or parameters
    function tokenFallback(address _from, uint256 _value, bytes _data) public;
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b != 0);
        return a % b;
    }
}

/// @title Base Token contract
contract Token {
    /*
     * Implements ERC 20 standard.
     * https://github.com/ethereum/EIPs/blob/f90864a3d2b2b45c4decf95efd26b3f0c276051a/EIPS/eip-20-token-standard.md
     * https://github.com/ethereum/EIPs/issues/20
     *
     *  Added support for the ERC 223 "tokenFallback" method in a "transfer" function with a payload.
     *  https://github.com/ethereum/EIPs/issues/223
     */
    uint256 public totalSupply;

    /*
     * ERC 20
     */
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    /*
     * ERC 223
     */
    function transfer(address _to, uint256 _value, bytes _data) public returns (bool success);

    /*
     * Events
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/// @title Standard token contract - Standard token implementation.
contract StandardToken is Token {

    /*
     * Data structures
     */
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    /// @notice Allows `_spender` to transfer `_value` tokens from `msg.sender` to any address.
    /// @dev Sets approved amount of tokens for spender. Returns success.
    /// @param _spender Address of allowed account.
    /// @param _value Number of approved tokens.
    /// @return Returns success of function call.
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != 0x0);

        // To change the approve amount you first have to reduce the addresses`
        // allowance to zero by calling `approve(_spender, 0)` if it is not
        // already 0 to mitigate the race condition described here:
        // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require(_value == 0 || allowed[msg.sender][_spender] == 0);

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /*
     * Read functions
     */
    /// @dev Returns number of allowed tokens that a spender can transfer on
    /// behalf of a token owner.
    /// @param _owner Address of token owner.
    /// @param _spender Address of token spender.
    /// @return Returns remaining allowance for spender.
    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    /// @dev Returns number of tokens owned by the given address.
    /// @param _owner Address of token owner.
    /// @return Returns balance of owner.
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
}


/// @title Vitalik2X Token
contract Vitalik2XToken is StandardToken {
    using SafeMath for uint256;

    /*
     *  Token metadata
     */
    string constant public symbol = "V2X";
    string constant public name = "Vitalik2X";
    uint256 constant public decimals = 18;
    uint256 constant public multiplier = 10 ** decimals;

    address public owner;

    uint256 public creationBlock;
    uint256 public mainPotTokenBalance;
    uint256 public mainPotETHBalance;

    mapping (address => uint256) blockLock;

    event Mint(address indexed to, uint256 amount);
    event DonatedTokens(address indexed donator, uint256 amount);
    event DonatedETH(address indexed donator, uint256 amount);
    event SoldTokensFromPot(address indexed seller, uint256 amount);
    event BoughtTokensFromPot(address indexed buyer, uint256 amount);
    /*
     *  Public functions
     */
    /// @dev Function create the token and distribute to the deploying address
    constructor() public {
        owner = msg.sender;
        totalSupply = 10 ** decimals;
        balances[msg.sender] = totalSupply;
        creationBlock = block.number;

        emit Transfer(0x0, msg.sender, totalSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /*
     * External Functions
     */
    /// @dev Adds the tokens to the main Pot.
    function donateTokensToMainPot(uint256 amount) external returns (bool){
        require(_transfer(this, amount));
        mainPotTokenBalance = mainPotTokenBalance.add(amount);
        emit DonatedTokens(msg.sender, amount);
        return true;
    }

    function donateETHToMainPot() external payable returns (bool){
        require(msg.value > 0);
        mainPotETHBalance = mainPotETHBalance.add(msg.value);
        emit DonatedETH(msg.sender, msg.value);
        return true;
    }

    /// @dev Automatically sends a proportional percent of the ETH balance from the pot for proportion of the Tokens deposited.
    function sellTokensToPot(uint256 amount) external returns (bool) {
        uint256 amountBeingPaid = ethSliceAmount(amount);
        require(amountBeingPaid <= ethSliceCap(), "Token amount sent is above the cap.");
        require(_transfer(this, amount));
        mainPotTokenBalance = mainPotTokenBalance.add(amount);
        mainPotETHBalance = mainPotETHBalance.sub(amountBeingPaid);
        msg.sender.transfer(amountBeingPaid);
        emit SoldTokensFromPot(msg.sender, amount);
        return true;
    }

    /// @dev Automatically sends a proportional percent of the VTK2X token balance from the pot for proportion of the ETH deposited.
    function buyTokensFromPot() external payable returns (uint256) {
        require(msg.value > 0);
        uint256 amountBuying = tokenSliceAmount(msg.value);
        require(amountBuying <= tokenSliceCap(), "Msg.value is above the cap.");
        require(mainPotTokenBalance >= 1 finney, "Pot does not have enough tokens.");
        mainPotETHBalance = mainPotETHBalance.add(msg.value);
        mainPotTokenBalance = mainPotTokenBalance.sub(amountBuying);
        balances[address(this)] = balances[address(this)].sub(amountBuying);
        balances[msg.sender] = balances[msg.sender].add(amountBuying);
        emit Transfer(address(this), msg.sender, amountBuying);
        emit BoughtTokensFromPot(msg.sender, amountBuying);
        return amountBuying;
    }

    /// @dev Returns the block number the given address is locked until.
    /// @param _owner Address of token owner.
    /// @return Returns block number the lock is released.
    function blockLockOf(address _owner) external view returns (uint256) {
        return blockLock[_owner];
    }

    /// @dev external function to retrieve ETH sent to the contract.
    function withdrawETH() external onlyOwner {
        owner.transfer(address(this).balance.sub(mainPotETHBalance));
    }

    /// @dev external function to retrieve tokens accidentally sent to the contract.
    function withdrawToken(address token) external onlyOwner {
        require(token != address(this));
        Token erc20 = Token(token);
        erc20.transfer(owner, erc20.balanceOf(this));
    }

    /*
     * Public Functions
     */
    /// @dev public function to retrieve the ETH amount.
    function ethSliceAmount(uint256 amountOfTokens) public view returns (uint256) {
        uint256 amountBuying = mainPotETHBalance.mul(amountOfTokens).div(mainPotTokenBalance);
        amountBuying = amountBuying.sub(amountBuying.mul(amountOfTokens).div(mainPotTokenBalance));
        return amountBuying;
    }

    /// @dev public function to retrieve the max ETH slice allotted.
    function ethSliceCap() public view returns (uint256) {
        return mainPotETHBalance.mul(30).div(100);
    }

    /// @dev public function to retrieve the percentage of ETH user wants from pot.
    function ethSlicePercentage(uint256 amountOfTokens) public view returns (uint256) {
        uint256 amountOfTokenRecieved = ethSliceAmount(amountOfTokens);
        return amountOfTokenRecieved.mul(100).div(mainPotETHBalance);
    }

    /// @dev public function to retrieve the current pot reward amount.
    function tokenSliceAmount(uint256 amountOfETH) public view returns (uint256) {
        uint256 amountBuying = mainPotTokenBalance.mul(amountOfETH).div(mainPotETHBalance);
        amountBuying = amountBuying.sub(amountBuying.mul(amountOfETH).div(mainPotETHBalance));
        return amountBuying;
    }

    /// @dev public function to retrieve the max token slice allotted.
    function tokenSliceCap() public view returns (uint256) {
        return mainPotTokenBalance.mul(30).div(100);
    }
    /// @dev public function to retrieve the percentage of ETH user wants from pot.
    function tokenSlicePercentage(uint256 amountOfEth) public view returns (uint256) {
        uint256 amountOfEthRecieved = tokenSliceAmount(amountOfEth);
        return amountOfEthRecieved.mul(100).div(mainPotTokenBalance);
    }

    /// @dev public function to check the status of account's lock.
    function accountLocked() public view returns (bool) {
        return (block.number < blockLock[msg.sender]);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(block.number >= blockLock[msg.sender], "Address is still locked.");
        if (_to == address(this)) {
            return _vitalikize(msg.sender, _value);
        } else {
            return _transfer(_to, _value);
        }
    }


    /// @notice Send `_value` tokens to `_to` from `msg.sender` and trigger
    /// tokenFallback if sender is a contract.
    /// @dev Function that is called when a user or another contract wants to transfer funds.
    /// @param _to Address of token receiver.
    /// @param _value Number of tokens to transfer.
    /// @param _data Data to be sent to tokenFallback
    /// @return Returns success of function call.
    function transfer(
        address _to,
        uint256 _value,
        bytes _data)
        public
        returns (bool)
    {
        require(_to != address(this));
        // Transfers tokens normally as per ERC20 standards
        require(transfer(_to, _value));

        uint codeLength;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly.
            codeLength := extcodesize(_to)
        }

        // If codeLength is > 0, it means it is a contract, handle fallback
        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }

        return true;
    }

    /// @notice Transfer `_value` tokens from `_from` to `_to` if `msg.sender` is allowed.
    /// @dev Allows for an approved third party to transfer tokens from one
    /// address to another. Returns success.
    /// @param _from Address from where tokens are withdrawn.
    /// @param _to Address to where tokens are sent.
    /// @param _value Number of tokens to transfer.
    /// @return Returns success of function call.
    function transferFrom(address _from, address _to, uint256 _value)
        public
        returns (bool)
    {
        require(block.number >= blockLock[_from], "Address is still locked.");
        require(_from != 0x0);
        require(_to != 0x0);
        require(_to != address(this));
        // Balance of sender is legit
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    /*
     * Internal functions
     */
    /// @notice Send `_value` tokens to `_to` from `msg.sender`.
    /// @dev Transfers sender's tokens to a given address. Returns success.
    /// @param _to Address of token receiver.
    /// @param _value Number of tokens to transfer.
    /// @return Returns success of function call.
    function _transfer(address _to, uint256 _value) internal returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /// @dev Mints the amount of token passed and sends it to the sender
    function _vitalikize(address _sender, uint256 _value) internal returns (bool) {
        require(balances[_sender] >= _value, "Owner doesnt have enough tokens.");
        uint256 calcBlockLock = (block.number - creationBlock)/5;
        blockLock[_sender] = block.number + (calcBlockLock > 2600 ? calcBlockLock : 2600);
        require(mint(_sender, _value), "Minting failed");
        emit Transfer(address(0), _sender, _value);
        return true;
    }

    function mint(address _address, uint256 _amount) internal returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_address] = balances[_address].add(_amount);
        return true;
    }
}