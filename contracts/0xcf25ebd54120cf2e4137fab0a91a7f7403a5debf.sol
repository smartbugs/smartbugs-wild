pragma solidity ^0.4.25;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value)
    external returns (bool);

    function transferFrom(address from, address to, uint256 value)
    external returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
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
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
* @dev Library to perform safe calls to standard method for ERC20 tokens.
*
* Why Transfers: transfer methods could have a return value (bool), throw or revert for insufficient funds or
* unathorized value.
*
* Why Approve: approve method could has a return value (bool) or does not accept 0 as a valid value (BNB token).
* The common strategy used to clean approvals.
*
* We use the Solidity call instead of interface methods because in the case of transfer, it will fail
* for tokens with an implementation without returning a value.
* Since versions of Solidity 0.4.22 the EVM has a new opcode, called RETURNDATASIZE.
* This opcode stores the size of the returned data of an external call. The code checks the size of the return value
* after an external call and reverts the transaction in case the return data is shorter than expected
*/
library SafeERC20 {

    using SafeMath for uint256;

    /**
    * @dev Transfer token for a specified address
    * @param _token erc20 The address of the ERC20 contract
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the _value of tokens to be transferred
    * @return bool whether the transfer was successful or not
    */
    function safeTransfer(IERC20 _token, address _to, uint256 _value) internal returns (bool) {
        uint256 prevBalance = _token.balanceOf(address(this));

        if (prevBalance < _value) {
            // Insufficient funds
            return false;
        }

        address(_token).call(
            abi.encodeWithSignature("transfer(address,uint256)", _to, _value)
        );

        if (prevBalance.sub(_value) != _token.balanceOf(address(this))) {
            // Transfer failed
            return false;
        }

        return true;
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param _token erc20 The address of the ERC20 contract
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the _value of tokens to be transferred
    * @return bool whether the transfer was successful or not
    */
    function safeTransferFrom(
        IERC20 _token,
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool)
    {
        uint256 prevBalance = _token.balanceOf(_from);

        if (prevBalance < _value) {
            // Insufficient funds
            return false;
        }

        if (_token.allowance(_from, address(this)) < _value) {
            // Insufficient allowance
            return false;
        }

        address(_token).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", _from, _to, _value)
        );

        if (prevBalance.sub(_value) != _token.balanceOf(_from)) {
            // Transfer failed
            return false;
        }

        return true;
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    *
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    *
    * @param _token erc20 The address of the ERC20 contract
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    * @return bool whether the approve was successful or not
    */
    function safeApprove(IERC20 _token, address _spender, uint256 _value) internal returns (bool) {
        address(_token).call(
            abi.encodeWithSignature("approve(address,uint256)", _spender, _value)
        );

        if (_token.allowance(address(this), _spender) != _value) {
            // Approve failed
            return false;
        }

        return true;
    }

}

/**
 * @title SEEDDEX
 * @dev This is the main contract for the SEEDDEX exchange.
 */
contract SEEDDEX {

    using SafeERC20 for IERC20;

    /// Variables
    address public admin; // the admin address
    address constant public FicAddress = 0x0DD83B5013b2ad7094b1A7783d96ae0168f82621;  // FloraFIC token address
    address public manager; // the manager address
    address public feeAccount; // the account that will receive fees
    uint public feeTakeMaker; // For Maker fee x% *10^18
    uint public feeTakeSender; // For Sender fee x% *10^18
    uint public feeTakeMakerFic;
    uint public feeTakeSenderFic;
    bool private depositingTokenFlag; // True when Token.safeTransferFrom is being called from depositToken
    mapping(address => mapping(address => uint)) public tokens; // mapping of token addresses to mapping of account balances (token=0 means Ether)
    mapping(address => mapping(bytes32 => bool)) public orders; // mapping of user accounts to mapping of order hashes to booleans (true = submitted by user, equivalent to offchain signature)
    mapping(address => mapping(bytes32 => uint)) public orderFills; // mapping of user accounts to mapping of order hashes to uints (amount of order that has been filled)
    address public predecessor; // Address of the previous version of this contract. If address(0), this is the first version
    address public successor; // Address of the next version of this contract. If address(0), this is the most up to date version.
    uint16 public version; // This is the version # of the contract

    /// Logging Events
    event Order(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address indexed user, bytes32 hash, uint amount);
    event Cancel(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address indexed user, uint8 v, bytes32 r, bytes32 s);
    event Trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, address get, address give, uint256 timestamp);
    event Deposit(address token, address indexed user, uint amount, uint balance);
    event Withdraw(address token, address indexed user, uint amount, uint balance);
    event FundsMigrated(address indexed user, address newContract);

    /// This is a modifier for functions to check if the sending user address is the same as the admin user address.
    modifier isAdmin() {
        require(msg.sender == admin);
        _;
    }

    /// this is manager can only change feeTakeMaker feeTakeMaker and change manager address (accept only Ethereum address)
    modifier isManager() {
        require(msg.sender == manager || msg.sender == admin);
        _;
    }

    /// Constructor function. This is only called on contract creation.
    function SEEDDEX(address admin_, address manager_, address feeAccount_, uint feeTakeMaker_, uint feeTakeSender_, uint feeTakeMakerFic_, uint feeTakeSenderFic_, address predecessor_) public {
        admin = admin_;
        manager = manager_;
        feeAccount = feeAccount_;
        feeTakeMaker = feeTakeMaker_;
        feeTakeSender = feeTakeSender_;
        feeTakeMakerFic = feeTakeMakerFic_;
        feeTakeSenderFic = feeTakeSenderFic_;
        depositingTokenFlag = false;
        predecessor = predecessor_;

        if (predecessor != address(0)) {
            version = SEEDDEX(predecessor).version() + 1;
        } else {
            version = 1;
        }
    }

    /// The fallback function. Ether transfered into the contract is not accepted.
    function() public {
        revert();
    }

    /// Changes the official admin user address. Accepts Ethereum address.
    function changeAdmin(address admin_) public isAdmin {
        require(admin_ != address(0));
        admin = admin_;
    }

    /// Changes the manager user address. Accepts Ethereum address.
    function changeManager(address manager_) public isManager {
        require(manager_ != address(0));
        manager = manager_;
    }

    /// Changes the account address that receives trading fees. Accepts Ethereum address.
    function changeFeeAccount(address feeAccount_) public isAdmin {
        feeAccount = feeAccount_;
    }

    /// Changes the fee on takes. Can only be changed to a value less than it is currently set at.
    function changeFeeTakeMaker(uint feeTakeMaker_) public isManager {
        feeTakeMaker = feeTakeMaker_;
    }

    function changeFeeTakeSender(uint feeTakeSender_) public isManager {
        feeTakeSender = feeTakeSender_;
    }

    function changeFeeTakeMakerFic(uint feeTakeMakerFic_) public isManager {
        feeTakeMakerFic = feeTakeMakerFic_;
    }

    function changeFeeTakeSenderFic(uint feeTakeSenderFic_) public isManager {
        feeTakeSenderFic = feeTakeSenderFic_;
    }

    /// Changes the successor. Used in updating the contract.
    function setSuccessor(address successor_) public isAdmin {
        require(successor_ != address(0));
        successor = successor_;
    }

    ////////////////////////////////////////////////////////////////////////////////
    // Deposits, Withdrawals, Balances
    ////////////////////////////////////////////////////////////////////////////////

    /**
    * This function handles deposits of Ether into the contract.
    * Emits a Deposit event.
    * Note: With the payable modifier, this function accepts Ether.
    */
    function deposit() public payable {
        tokens[0][msg.sender] = SafeMath.add(tokens[0][msg.sender], msg.value);
        Deposit(0, msg.sender, msg.value, tokens[0][msg.sender]);
    }

    /**
    * This function handles withdrawals of Ether from the contract.
    * Verifies that the user has enough funds to cover the withdrawal.
    * Emits a Withdraw event.
    * @param amount uint of the amount of Ether the user wishes to withdraw
    */
    function withdraw(uint amount) {
        if (tokens[0][msg.sender] < amount) throw;
        tokens[0][msg.sender] = SafeMath.sub(tokens[0][msg.sender], amount);
        if (!msg.sender.call.value(amount)()) throw;
        Withdraw(0, msg.sender, amount, tokens[0][msg.sender]);
    }

    /**
    * This function handles deposits of Ethereum based tokens to the contract.
    * Does not allow Ether.
    * If token transfer fails, transaction is reverted and remaining gas is refunded.
    * Emits a Deposit event.
    * Note: Remember to call IERC20(address).safeApprove(this, amount) or this contract will not be able to do the transfer on your behalf.
    * @param token Ethereum contract address of the token or 0 for Ether
    * @param amount uint of the amount of the token the user wishes to deposit
    */
    function depositToken(address token, uint amount) {
        //remember to call IERC20(address).safeApprove(this, amount) or this contract will not be able to do the transfer on your behalf.
        if (token == 0) throw;
        if (!IERC20(token).safeTransferFrom(msg.sender, this, amount)) throw;
        tokens[token][msg.sender] = SafeMath.add(tokens[token][msg.sender], amount);
        Deposit(token, msg.sender, amount, tokens[token][msg.sender]);
    }

    /**
    * This function provides a fallback solution as outlined in ERC223.
    * If tokens are deposited through depositToken(), the transaction will continue.
    * If tokens are sent directly to this contract, the transaction is reverted.
    * @param sender Ethereum address of the sender of the token
    * @param amount amount of the incoming tokens
    * @param data attached data similar to msg.data of Ether transactions
    */
    function tokenFallback(address sender, uint amount, bytes data) public returns (bool ok) {
        if (depositingTokenFlag) {
            // Transfer was initiated from depositToken(). User token balance will be updated there.
            return true;
        } else {
            // Direct ECR223 Token.safeTransfer into this contract not allowed, to keep it consistent
            // with direct transfers of ECR20 and ETH.
            revert();
        }
    }

    /**
    * This function handles withdrawals of Ethereum based tokens from the contract.
    * Does not allow Ether.
    * If token transfer fails, transaction is reverted and remaining gas is refunded.
    * Emits a Withdraw event.
    * @param token Ethereum contract address of the token or 0 for Ether
    * @param amount uint of the amount of the token the user wishes to withdraw
    */
    function withdrawToken(address token, uint amount) {
        if (token == 0) throw;
        if (tokens[token][msg.sender] < amount) throw;
        tokens[token][msg.sender] = SafeMath.sub(tokens[token][msg.sender], amount);
        if (!IERC20(token).safeTransfer(msg.sender, amount)) throw;
        Withdraw(token, msg.sender, amount, tokens[token][msg.sender]);
    }

    /**
    * Retrieves the balance of a token based on a user address and token address.
    * @param token Ethereum contract address of the token or 0 for Ether
    * @param user Ethereum address of the user
    * @return the amount of tokens on the exchange for a given user address
    */
    function balanceOf(address token, address user) public constant returns (uint) {
        return tokens[token][user];
    }

    ////////////////////////////////////////////////////////////////////////////////
    // Trading
    ////////////////////////////////////////////////////////////////////////////////

    /**
    * Stores the active order inside of the contract.
    * Emits an Order event.
    *
    *
    * Note: tokenGet & tokenGive can be the Ethereum contract address.
    * @param tokenGet Ethereum contract address of the token to receive
    * @param amountGet uint amount of tokens being received
    * @param tokenGive Ethereum contract address of the token to give
    * @param amountGive uint amount of tokens being given
    * @param expires uint of block number when this order should expire
    * @param nonce arbitrary random number
    */
    function order(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce) public {
        bytes32 hash = keccak256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
        uint amount;
        orders[msg.sender][hash] = true;
        Order(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, msg.sender, hash, amount);
    }

    /**
    * Facilitates a trade from one user to another.
    * Requires that the transaction is signed properly, the trade isn't past its expiration, and all funds are present to fill the trade.
    * Calls tradeBalances().
    * Updates orderFills with the amount traded.
    * Emits a Trade event.
    * Note: tokenGet & tokenGive can be the Ethereum contract address.
    * Note: amount is in amountGet / tokenGet terms.
    * @param tokenGet Ethereum contract address of the token to receive
    * @param amountGet uint amount of tokens being received
    * @param tokenGive Ethereum contract address of the token to give
    * @param amountGive uint amount of tokens being given
    * @param expires uint of block number when this order should expire
    * @param nonce arbitrary random number
    * @param user Ethereum address of the user who placed the order
    * @param v part of signature for the order hash as signed by user
    * @param r part of signature for the order hash as signed by user
    * @param s part of signature for the order hash as signed by user
    * @param amount uint amount in terms of tokenGet that will be "buy" in the trade
    */
    function trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount) public {
        bytes32 hash = keccak256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
        require((
            (orders[user][hash] || ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) == user) &&
            block.number <= expires &&
            SafeMath.add(orderFills[user][hash], amount) <= amountGet
            ));
        tradeBalances(tokenGet, amountGet, tokenGive, amountGive, user, amount);
        orderFills[user][hash] = SafeMath.add(orderFills[user][hash], amount);
        Trade(tokenGet, amount, tokenGive, amountGive * amount / amountGet, user, msg.sender, now);
    }

    /**
    * This is a private function and is only being called from trade().
    * Handles the movement of funds when a trade occurs.
    * Takes fees.
    * Updates token balances for both buyer and seller.
    * Note: tokenGet & tokenGive can be the Ethereum contract address.
    * Note: amount is in amountGet / tokenGet terms.
    * @param tokenGet Ethereum contract address of the token to receive
    * @param amountGet uint amount of tokens being received
    * @param tokenGive Ethereum contract address of the token to give
    * @param amountGive uint amount of tokens being given
    * @param user Ethereum address of the user who placed the order
    * @param amount uint amount in terms of tokenGet that will be "buy" in the trade
    */
    function tradeBalances(address tokenGet, uint amountGet, address tokenGive, uint amountGive, address user, uint amount) private {
        if (tokenGet == FicAddress || tokenGive == FicAddress) {
            tokens[tokenGet][msg.sender] = SafeMath.sub(tokens[tokenGet][msg.sender], amount);
            tokens[tokenGet][user] = SafeMath.add(tokens[tokenGet][user], SafeMath.mul(amount, ((1 ether) - feeTakeMakerFic)) / (1 ether));
            tokens[tokenGet][feeAccount] = SafeMath.add(tokens[tokenGet][feeAccount], SafeMath.mul(amount, feeTakeMakerFic) / (1 ether));
            tokens[tokenGive][user] = SafeMath.sub(tokens[tokenGive][user], SafeMath.mul(amountGive, amount) / amountGet);
            tokens[tokenGive][msg.sender] = SafeMath.add(tokens[tokenGive][msg.sender], SafeMath.mul(SafeMath.mul(((1 ether) - feeTakeSenderFic), amountGive), amount) / amountGet / (1 ether));
            tokens[tokenGive][feeAccount] = SafeMath.add(tokens[tokenGive][feeAccount], SafeMath.mul(SafeMath.mul(feeTakeSenderFic, amountGive), amount) / amountGet / (1 ether));
        }
        else {
            tokens[tokenGet][msg.sender] = SafeMath.sub(tokens[tokenGet][msg.sender], amount);
            tokens[tokenGet][user] = SafeMath.add(tokens[tokenGet][user], SafeMath.mul(amount, ((1 ether) - feeTakeMaker)) / (1 ether));
            tokens[tokenGet][feeAccount] = SafeMath.add(tokens[tokenGet][feeAccount], SafeMath.mul(amount, feeTakeMaker) / (1 ether));
            tokens[tokenGive][user] = SafeMath.sub(tokens[tokenGive][user], SafeMath.mul(amountGive, amount) / amountGet);
            tokens[tokenGive][msg.sender] = SafeMath.add(tokens[tokenGive][msg.sender], SafeMath.mul(SafeMath.mul(((1 ether) - feeTakeSender), amountGive), amount) / amountGet / (1 ether));
            tokens[tokenGive][feeAccount] = SafeMath.add(tokens[tokenGive][feeAccount], SafeMath.mul(SafeMath.mul(feeTakeSender, amountGive), amount) / amountGet / (1 ether));
        }
    }

    /**
    * This function is to test if a trade would go through.
    * Note: tokenGet & tokenGive can be the Ethereum contract address.
    * Note: amount is in amountGet / tokenGet terms.
    * @param tokenGet Ethereum contract address of the token to receive
    * @param amountGet uint amount of tokens being received
    * @param tokenGive Ethereum contract address of the token to give
    * @param amountGive uint amount of tokens being given
    * @param expires uint of block number when this order should expire
    * @param nonce arbitrary random number
    * @param user Ethereum address of the user who placed the order
    * @param v part of signature for the order hash as signed by user
    * @param r part of signature for the order hash as signed by user
    * @param s part of signature for the order hash as signed by user
    * @param amount uint amount in terms of tokenGet that will be "buy" in the trade
    * @param sender Ethereum address of the user taking the order
    * @return bool: true if the trade would be successful, false otherwise
    */
    function testTrade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount, address sender) public constant returns (bool) {
        if (!(
        tokens[tokenGet][sender] >= amount &&
        availableVolume(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, user, v, r, s) >= amount
        )) {
            return false;
        } else {
            return true;
        }
    }

    /**
    * This function checks the available volume for a given order.
    * Note: tokenGet & tokenGive can be the Ethereum contract address.
    * @param tokenGet Ethereum contract address of the token to receive
    * @param amountGet uint amount of tokens being received
    * @param tokenGive Ethereum contract address of the token to give
    * @param amountGive uint amount of tokens being given
    * @param expires uint of block number when this order should expire
    * @param nonce arbitrary random number
    * @param user Ethereum address of the user who placed the order
    * @param v part of signature for the order hash as signed by user
    * @param r part of signature for the order hash as signed by user
    * @param s part of signature for the order hash as signed by user
    * @return uint: amount of volume available for the given order in terms of amountGet / tokenGet
    */
    function availableVolume(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) public constant returns (uint) {
        bytes32 hash = keccak256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
        if (!(
        (orders[user][hash] || ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) == user) &&
        block.number <= expires
        )) {
            return 0;
        }
        uint[2] memory available;
        available[0] = SafeMath.sub(amountGet, orderFills[user][hash]);
        available[1] = SafeMath.mul(tokens[tokenGive][user], amountGet) / amountGive;
        if (available[0] < available[1]) {
            return available[0];
        } else {
            return available[1];
        }
    }

    /**
    * This function checks the amount of an order that has already been filled.
    * Note: tokenGet & tokenGive can be the Ethereum contract address.
    * @param tokenGet Ethereum contract address of the token to receive
    * @param amountGet uint amount of tokens being received
    * @param tokenGive Ethereum contract address of the token to give
    * @param amountGive uint amount of tokens being given
    * @param expires uint of block number when this order should expire
    * @param nonce arbitrary random number
    * @param user Ethereum address of the user who placed the order
    * @param v part of signature for the order hash as signed by user
    * @param r part of signature for the order hash as signed by user
    * @param s part of signature for the order hash as signed by user
    * @return uint: amount of the given order that has already been filled in terms of amountGet / tokenGet
    */
    function amountFilled(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) public constant returns (uint) {
        bytes32 hash = keccak256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
        return orderFills[user][hash];
    }

    /**
    * This function cancels a given order by editing its fill data to the full amount.
    * Requires that the transaction is signed properly.
    * Updates orderFills to the full amountGet
    * Emits a Cancel event.
    * Note: tokenGet & tokenGive can be the Ethereum contract address.
    * @param tokenGet Ethereum contract address of the token to receive
    * @param amountGet uint amount of tokens being received
    * @param tokenGive Ethereum contract address of the token to give
    * @param amountGive uint amount of tokens being given
    * @param expires uint of block number when this order should expire
    * @param nonce arbitrary random number
    * @param v part of signature for the order hash as signed by user
    * @param r part of signature for the order hash as signed by user
    * @param s part of signature for the order hash as signed by user
    * @return uint: amount of the given order that has already been filled in terms of amountGet / tokenGet
    */
    function cancelOrder(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, uint8 v, bytes32 r, bytes32 s) public {
        bytes32 hash = keccak256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
        require((orders[msg.sender][hash] || ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) == msg.sender));
        orderFills[msg.sender][hash] = amountGet;
        Cancel(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, msg.sender, v, r, s);
    }



    ////////////////////////////////////////////////////////////////////////////////
    // Contract Versioning / Migration
    ////////////////////////////////////////////////////////////////////////////////

    /**
    * User triggered function to migrate funds into a new contract to ease updates.
    * Emits a FundsMigrated event.
    * @param newContract Contract address of the new contract we are migrating funds to
    * @param tokens_ Array of token addresses that we will be migrating to the new contract
    */
    function migrateFunds(address newContract, address[] tokens_) public {

        require(newContract != address(0));

        SEEDDEX newExchange = SEEDDEX(newContract);

        // Move Ether into new exchange.
        uint etherAmount = tokens[0][msg.sender];
        if (etherAmount > 0) {
            tokens[0][msg.sender] = 0;
            newExchange.depositForUser.value(etherAmount)(msg.sender);
        }

        // Move Tokens into new exchange.
        for (uint16 n = 0; n < tokens_.length; n++) {
            address token = tokens_[n];
            require(token != address(0));
            // Ether is handled above.
            uint tokenAmount = tokens[token][msg.sender];

            if (tokenAmount != 0) {
                if (!IERC20(token).safeApprove(newExchange, tokenAmount)) throw;
                tokens[token][msg.sender] = 0;
                newExchange.depositTokenForUser(token, tokenAmount, msg.sender);
            }
        }

        FundsMigrated(msg.sender, newContract);
    }


    /**
    * This function handles deposits of Ether into the contract, but allows specification of a user.
    * Note: This is generally used in migration of funds.
    * Note: With the payable modifier, this function accepts Ether.
    */
    function depositForUser(address user) public payable {
        require(user != address(0));
        require(msg.value > 0);
        tokens[0][user] = SafeMath.add(tokens[0][user], (msg.value));
    }

    /**
    * This function handles deposits of Ethereum based tokens into the contract, but allows specification of a user.
    * Does not allow Ether.
    * If token transfer fails, transaction is reverted and remaining gas is refunded.
    * Note: This is generally used in migration of funds.
    * Note: Remember to call Token(address).safeApprove(this, amount) or this contract will not be able to do the transfer on your behalf.
    * @param token Ethereum contract address of the token
    * @param amount uint of the amount of the token the user wishes to deposit
    */
    function depositTokenForUser(address token, uint amount, address user) public {
        require(token != address(0));
        require(user != address(0));
        require(amount > 0);
        depositingTokenFlag = true;
        if (!IERC20(token).safeTransferFrom(msg.sender, this, amount)) throw;
        depositingTokenFlag = false;
        tokens[token][user] = SafeMath.add(tokens[token][user], (amount));
    }
}