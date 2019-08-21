pragma solidity >=0.4.24 <0.6.0;

/**
 * Cryptonomica EthID Tokens smart contract
 * developed by Cryptonomica Ltd., 2018
 * https://cryptonomica.net
 * github: https://github.com/Cryptonomica/
 * deployed using compiler version: 0.4.24+commit.e67f0147.Emscripten.clang
 */


/* ---- Libraries */
/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 * see: https://openzeppelin.org/api/docs/math_SafeMath.html
 * source: https://github.com/OpenZeppelin/openzeppelin-solidity/blob/v2.0.0/contracts/math/SafeMath.sol
 * (e7aa8de on Oct 21 2018)
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

// << end of SafeMath

/* --- "Interfaces" */

//  this is expected from another contracts
//  if it wants to spend tokens of behalf of the token owner in our contract
contract allowanceRecipient {
    function receiveApproval(address _from, uint256 _value, address _inContract, bytes _extraData) public returns (bool);
}

// see: https://github.com/ethereum/EIPs/issues/677
contract tokenRecipient {
    function tokenFallback(address _from, uint256 _value, bytes _extraData) public returns (bool);
}

/* -------- ///////// Main Contract /////// ----------- */

contract EthIdTokens {

    using SafeMath for uint256;

    /* --- ERC-20 variables */

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#name
    // function name() constant returns (string name)
    string public name = "EthID Tokens";

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#symbol
    // function symbol() constant returns (string symbol)
    string public symbol = "EthID";

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#decimals
    // function decimals() constant returns (uint8 decimals)
    uint8 public decimals = 0;

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#totalsupply
    // function totalSupply() constant returns (uint256 totalSupply)
    uint256 public totalSupply;

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#balanceof
    // function balanceOf(address _owner) constant returns (uint256 balance)
    mapping(address => uint256) public balanceOf;

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#allowance
    // function allowance(address _owner, address _spender) constant returns (uint256 remaining)
    mapping(address => mapping(address => uint256)) public allowance;

    /* --- ERC-20 events */

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#events

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#transfer-1
    event Transfer(address indexed from, address indexed to, uint256 value);

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#approval
    event Approval(address indexed _owner, address indexed spender, uint256 value);

    /* --- Events for interaction with other smart contracts */
    event DataSentToAnotherContract(address indexed _from, address indexed _toContract, bytes _extraData);


    /* --- administrative variable and functions */

    address public owner; // smart contract owner (super admin)

    // to avoid mistakes: owner (super admin) should be changed in two steps
    // change is valid when accepted from new owner address
    address private newOwner;

    function changeOwnerStart(address _newOwner) public {
        // only owner
        require(msg.sender == owner);

        newOwner = _newOwner;
        emit ChangeOwnerStarted(msg.sender, _newOwner);
    } //
    event ChangeOwnerStarted (address indexed startedBy, address indexed newOwner);

    function changeOwnerAccept() public {
        // only by new owner
        require(msg.sender == newOwner);
        // event here:
        emit OwnerChanged(owner, newOwner);
        owner = newOwner;
    } //
    event OwnerChanged(address indexed from, address indexed to);

    /* --- Constructor */

    constructor() public {
        // can be hardcoded in production:
        owner = msg.sender;
        // 100M :
        totalSupply = 100 * 1000000;
        balanceOf[owner] = totalSupply;
    }


    /* --- Dividends */
    event DividendsPaid(address indexed to, uint256 tokensBurned, uint256 sumInWeiPaid);

    // valueInTokens : tokens to burn to get dividends
    function takeDividends(uint256 valueInTokens) public returns (bool) {

        require(address(this).balance > 0);
        require(totalSupply > 0);

        uint256 sumToPay = (address(this).balance / totalSupply).mul(valueInTokens);

        totalSupply = totalSupply.sub(valueInTokens);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(valueInTokens);

        msg.sender.transfer(sumToPay);

        emit DividendsPaid(msg.sender, valueInTokens, sumToPay);

        return true;
    }

    // only if all tokens are burned:
    event WithdrawalByOwner(uint256 value, address indexed to); //
    function withdrawAllByOwner() public {
        // only owner:
        require(msg.sender == owner);
        // only if all tokens burned:
        require(totalSupply == 0);

        uint256 sumToWithdraw = address(this).balance;
        owner.transfer(sumToWithdraw);
        emit WithdrawalByOwner(sumToWithdraw, owner);
    }

    /* --- ERC-20 Functions */
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#methods

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#transfer
    function transfer(address _to, uint256 _value) public returns (bool){
        if (_to == address(this)) {
            return takeDividends(_value);
        } else {
            return transferFrom(msg.sender, _to, _value);
        }
    }

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#transferfrom
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool){

        // Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event (ERC-20)
        require(_value >= 0);

        // The function SHOULD throw unless the _from account has deliberately authorized the sender of the message via some mechanism
        require(msg.sender == _from || _value <= allowance[_from][msg.sender]);

        // check if _from account have required amount
        require(_value <= balanceOf[_from]);

        // Subtract from the sender
        // balanceOf[_from] = balanceOf[_from] - _value;
        balanceOf[_from] = balanceOf[_from].sub(_value);
        // Add the same to the recipient
        // balanceOf[_to] = balanceOf[_to] + _value;
        balanceOf[_to] = balanceOf[_to].add(_value);

        // If allowance used, change allowances correspondingly
        if (_from != msg.sender) {
            // allowance[_from][msg.sender] = allowance[_from][msg.sender] - _value;
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        }

        // event
        emit Transfer(_from, _to, _value);

        return true;
    } // end of transferFrom

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#approve
    // there is and attack, see:
    // https://github.com/CORIONplatform/solidity/issues/6,
    // https://drive.google.com/file/d/0ByMtMw2hul0EN3NCaVFHSFdxRzA/view
    // but this function is required by ERC-20
    function approve(address _spender, uint256 _value) public returns (bool){
        require(_value >= 0);
        allowance[msg.sender][_spender] = _value;
        // event
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /*  ---------- Interaction with other contracts  */

    /* User can allow another smart contract to spend some tokens in his behalf
    *  (this function should be called by user itself)
    *  @param _spender another contract's address
    *  @param _value number of tokens
    *  @param _extraData Data that can be sent from user to another contract to be processed
    *  bytes - dynamically-sized byte array,
    *  see http://solidity.readthedocs.io/en/v0.4.15/types.html#dynamically-sized-byte-array
    *  see possible attack information in comments to function 'approve'
    *  > this may be used, for example, to convert pre-ICO tokens to ICO tokens, or
    *    to convert some tokens to other tokens
    */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool) {

        approve(_spender, _value);

        // 'spender' is another contract that implements code as prescribed in 'allowanceRecipient' above
        allowanceRecipient spender = allowanceRecipient(_spender);

        // our contract calls 'receiveApproval' function of another contract ('allowanceRecipient') to send information about
        // allowance and data sent by user
        // 'this' is this (our) contract address
        if (spender.receiveApproval(msg.sender, _value, this, _extraData)) {
            emit DataSentToAnotherContract(msg.sender, _spender, _extraData);
            return true;
        }
        return false;
    } // end of approveAndCall

    // for convenience:
    function approveAllAndCall(address _spender, bytes _extraData) public returns (bool success) {
        return approveAndCall(_spender, balanceOf[msg.sender], _extraData);
    }

    /* https://github.com/ethereum/EIPs/issues/677
    * transfer tokens with additional info to another smart contract, and calls its correspondent function
    * @param address _to - another smart contract address
    * @param uint256 _value - number of tokens
    * @param bytes _extraData - data to send to another contract
    *  > this may be used, for example, to convert pre-ICO tokens to ICO tokens, or
    *    to convert some tokens to other tokens
    */
    function transferAndCall(address _to, uint256 _value, bytes _extraData) public returns (bool success){

        transferFrom(msg.sender, _to, _value);

        tokenRecipient receiver = tokenRecipient(_to);

        if (receiver.tokenFallback(msg.sender, _value, _extraData)) {
            emit DataSentToAnotherContract(msg.sender, _to, _extraData);
            return true;
        }
        return false;
    } // end of transferAndCall

    // for example for converting ALL tokens on user account to another tokens
    function transferAllAndCall(address _to, bytes _extraData) public returns (bool success){
        return transferAndCall(_to, balanceOf[msg.sender], _extraData);
    }

    /* ---- (!) Receive payments */
    function() public payable {
        // no code here, so we can use standard transfer function
    }

}