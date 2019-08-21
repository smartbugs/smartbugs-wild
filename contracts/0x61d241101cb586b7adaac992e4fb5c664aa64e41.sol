// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
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

// File: contracts/uniswap/UniswapExchangeInterface.sol

pragma solidity ^0.5.0;

contract UniswapExchangeInterface {
    // Address of ERC20 token sold on this exchange
    function tokenAddress() external view returns (address token);
    // Address of Uniswap Factory
    function factoryAddress() external view returns (address factory);
    // Provide Liquidity
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);
    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
    // Get Prices
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);
    // Trade ETH to ERC20
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);
    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);
    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);
    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);
    // Trade ERC20 to ETH
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_tokens, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);
    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);
    // Trade ERC20 to ERC20
    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);
    // Trade ERC20 to Custom Pool
    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);
    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);
    // ERC20 comaptibility for liquidity tokens
    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    // Never use
    function setup(address token_addr) external;
}

// File: contracts/uniswap/UniswapFactoryInterface.sol

pragma solidity ^0.5.0;

contract UniswapFactoryInterface {
    // Public Variables
    address public exchangeTemplate;
    uint256 public tokenCount;
    // Create Exchange
    function createExchange(address token) external returns (address exchange);
    // Get Exchange and Token Info
    function getExchange(address token) external view returns (address exchange);
    function getToken(address exchange) external view returns (address token);
    function getTokenWithId(uint256 tokenId) external view returns (address token);
    // Never use
    function initializeFactory(address template) external;
}

// File: contracts/PaymentProcessor.sol

pragma solidity ^0.5.0;





contract PaymentProcessor is Ownable {
    uint256 constant UINT256_MAX = ~uint256(0);

    address public fundManager;
    UniswapFactoryInterface public uniswapFactory;
    address public intermediaryToken;
    UniswapExchangeInterface public intermediaryTokenExchange;

    constructor(UniswapFactoryInterface uniswapFactory_)
        public {
        uniswapFactory = uniswapFactory_;
    }

    function setFundManager(address fundManager_)
        onlyOwner
        public {
        fundManager = fundManager_;
    }

    function isFundManager()
        public view
        returns (bool) {
        return isOwner() || msg.sender == fundManager;
    }

    function setIntermediaryToken(address token)
        onlyFundManager
        external {
        intermediaryToken = token;
        if (token != address(0)) {
            intermediaryTokenExchange = UniswapExchangeInterface(uniswapFactory.getExchange(token));
            require(address(intermediaryTokenExchange) != address(0), "The token does not have an exchange");
        } else {
            intermediaryTokenExchange = UniswapExchangeInterface(address(0));
        }
    }

    function depositEther(uint64 orderId)
        payable
        external {
        require(msg.value > 0, "Minimal deposit is 0");
        uint256 amountBought = 0;
        if (intermediaryToken != address(0)) {
            amountBought = intermediaryTokenExchange.ethToTokenSwapInput.value(msg.value)(
                1 /* min_tokens */,
                UINT256_MAX /* deadline */);
        }
        emit EtherDepositReceived(orderId, msg.value, intermediaryToken, amountBought);
    }

    function withdrawEther(uint256 amount, address payable to)
        onlyFundManager
        external {
        to.transfer(amount);
        emit EtherDepositWithdrawn(to, amount);
    }

    function withdrawToken(IERC20 token, uint256 amount, address to)
        onlyFundManager
        external {
        require(token.transfer(to, amount), "Withdraw token failed");
        emit TokenDepositWithdrawn(address(token), to, amount);
    }


    function depositToken(uint64 orderId, address depositor, IERC20 inputToken, uint256 amount)
        hasExchange(address(inputToken))
        onlyFundManager
        external {
        require(address(inputToken) != address(0), "Input token cannont be ZERO_ADDRESS");
        UniswapExchangeInterface tokenExchange = UniswapExchangeInterface(uniswapFactory.getExchange(address(inputToken)));
        require(inputToken.allowance(depositor, address(this)) >= amount, "Not enough allowance");
        inputToken.transferFrom(depositor, address(this), amount);
        uint256 amountBought = 0;
        if (intermediaryToken != address(0)) {
            if (intermediaryToken != address(inputToken)) {
                inputToken.approve(address(tokenExchange), amount);
                amountBought = tokenExchange.tokenToTokenSwapInput(
                    amount /* (input) tokens_sold */,
                    1 /* (output) min_tokens_bought */,
                    1 /*  min_eth_bought */,
                    UINT256_MAX /* deadline */,
                    intermediaryToken /* (input) token_addr */);
            } else {
                // same token
                amountBought = amount;
            }
        } else {
            inputToken.approve(address(tokenExchange), amount);
            amountBought = tokenExchange.tokenToEthSwapInput(
                amount /* tokens_sold */,
                1 /* min_eth */,
                UINT256_MAX /* deadline */);
        }
        emit TokenDepositReceived(orderId, address(inputToken), amount, intermediaryToken, amountBought);
    }

    event EtherDepositReceived(uint64 indexed orderId, uint256 amount, address intermediaryToken, uint256 amountBought);
    event EtherDepositWithdrawn(address to, uint256 amount);
    event TokenDepositReceived(uint64 indexed orderId, address indexed inputToken, uint256 amount, address intermediaryToken, uint256 amountBought);
    event TokenDepositWithdrawn(address indexed token, address to, uint256 amount);

    modifier hasExchange(address token) {
        address tokenExchange = uniswapFactory.getExchange(token);
        require(tokenExchange != address(0), "Token doesn't have an exchange");
        _;
    }

    modifier onlyFundManager() {
        require(isFundManager(), "Only fund manager allowed");
        _;
    }
}