pragma solidity 0.4.18;

/// @title Ownable
/// @dev The Ownable contract has an owner address, and provides basic authorization control functions,
/// this simplifies the implementation of "user permissions".
/// @dev Based on OpenZeppelin's Ownable.

contract Ownable {
    address public owner;
    address public newOwnerCandidate;

    event OwnershipRequested(address indexed _by, address indexed _to);
    event OwnershipTransferred(address indexed _from, address indexed _to);

    /// @dev Constructor sets the original `owner` of the contract to the sender account.
    function Ownable() public {
        owner = msg.sender;
    }

    /// @dev Reverts if called by any account other than the owner.
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyOwnerCandidate() {
        require(msg.sender == newOwnerCandidate);
        _;
    }

    /// @dev Proposes to transfer control of the contract to a newOwnerCandidate.
    /// @param _newOwnerCandidate address The address to transfer ownership to.
    function requestOwnershipTransfer(address _newOwnerCandidate) external onlyOwner {
        require(_newOwnerCandidate != address(0));

        newOwnerCandidate = _newOwnerCandidate;

        OwnershipRequested(msg.sender, newOwnerCandidate);
    }

    /// @dev Accept ownership transfer. This method needs to be called by the perviously proposed owner.
    function acceptOwnership() external onlyOwnerCandidate {
        address previousOwner = owner;

        owner = newOwnerCandidate;
        newOwnerCandidate = address(0);

        OwnershipTransferred(previousOwner, owner);
    }
}

/// @title Math operations with safety checks
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // require(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // require(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function toPower2(uint256 a) internal pure returns (uint256) {
        return mul(a, a);
    }

    function sqrt(uint256 a) internal pure returns (uint256) {
        uint256 c = (a + 1) / 2;
        uint256 b = a;
        while (c < b) {
            b = c;
            c = (a / c + c) / 2;
        }
        return b;
    }
}

/// @title ERC Token Standard #20 Interface (https://github.com/ethereum/EIPs/issues/20)
contract ERC20 {
    uint public totalSupply;
    function balanceOf(address _owner) constant public returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint remaining);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}



/// @title ERC Token Standard #677 Interface (https://github.com/ethereum/EIPs/issues/677)
contract ERC677 is ERC20 {
    function transferAndCall(address to, uint value, bytes data) public returns (bool ok);

    event TransferAndCall(address indexed from, address indexed to, uint value, bytes data);
}

/// @title ERC223Receiver Interface
/// @dev Based on the specs form: https://github.com/ethereum/EIPs/issues/223
contract ERC223Receiver {
    function tokenFallback(address _sender, uint _value, bytes _data) external returns (bool ok);
}




/// @title Basic ERC20 token contract implementation.
/// @dev Based on OpenZeppelin's StandardToken.
contract BasicToken is ERC20 {
    using SafeMath for uint256;

    uint256 public totalSupply;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) balances;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    /// @param _spender address The address which will spend the funds.
    /// @param _value uint256 The amount of tokens to be spent.
    function approve(address _spender, uint256 _value) public returns (bool) {
        // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#approve (see NOTE)
        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) {
            revert();
        }

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }

    /// @dev Function to check the amount of tokens that an owner allowed to a spender.
    /// @param _owner address The address which owns the funds.
    /// @param _spender address The address which will spend the funds.
    /// @return uint256 specifying the amount of tokens still available for the spender.
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }


    /// @dev Gets the balance of the specified address.
    /// @param _owner address The address to query the the balance of.
    /// @return uint256 representing the amount owned by the passed address.
    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }

    /// @dev Transfer token to a specified address.
    /// @param _to address The address to transfer to.
    /// @param _value uint256 The amount to be transferred.
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);

        return true;
    }

    /// @dev Transfer tokens from one address to another.
    /// @param _from address The address which you want to send tokens from.
    /// @param _to address The address which you want to transfer to.
    /// @param _value uint256 the amount of tokens to be transferred.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        var _allowance = allowed[_from][msg.sender];

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = _allowance.sub(_value);

        Transfer(_from, _to, _value);

        return true;
    }
}






/// @title Standard677Token implentation, base on https://github.com/ethereum/EIPs/issues/677

contract Standard677Token is ERC677, BasicToken {

  /// @dev ERC223 safe token transfer from one address to another
  /// @param _to address the address which you want to transfer to.
  /// @param _value uint256 the amount of tokens to be transferred.
  /// @param _data bytes data that can be attached to the token transation
  function transferAndCall(address _to, uint _value, bytes _data) public returns (bool) {
    require(super.transfer(_to, _value)); // do a normal token transfer
    TransferAndCall(msg.sender, _to, _value, _data);
    //filtering if the target is a contract with bytecode inside it
    if (isContract(_to)) return contractFallback(_to, _value, _data);
    return true;
  }

  /// @dev called when transaction target is a contract
  /// @param _to address the address which you want to transfer to.
  /// @param _value uint256 the amount of tokens to be transferred.
  /// @param _data bytes data that can be attached to the token transation
  function contractFallback(address _to, uint _value, bytes _data) private returns (bool) {
    ERC223Receiver receiver = ERC223Receiver(_to);
    require(receiver.tokenFallback(msg.sender, _value, _data));
    return true;
  }

  /// @dev check if the address is contract
  /// assemble the given address bytecode. If bytecode exists then the _addr is a contract.
  /// @param _addr address the address to check
  function isContract(address _addr) private constant returns (bool is_contract) {
    // retrieve the size of the code on target address, this needs assembly
    uint length;
    assembly { length := extcodesize(_addr) }
    return length > 0;
  }
}





/// @title Token holder contract.
contract TokenHolder is Ownable {
    /// @dev Allow the owner to transfer out any accidentally sent ERC20 tokens.
    /// @param _tokenAddress address The address of the ERC20 contract.
    /// @param _amount uint256 The amount of tokens to be transferred.
    function transferAnyERC20Token(address _tokenAddress, uint256 _amount) public onlyOwner returns (bool success) {
        return ERC20(_tokenAddress).transfer(owner, _amount);
    }
}






/// @title Colu Local Network contract.
/// @author Tal Beja.
contract ColuLocalNetwork is Ownable, Standard677Token, TokenHolder {
    using SafeMath for uint256;

    string public constant name = "Colu Local Network";
    string public constant symbol = "CLN";

    // Using same decimals value as ETH (makes ETH-CLN conversion much easier).
    uint8 public constant decimals = 18;

    // States whether token transfers is allowed or not.
    // Used during token sale.
    bool public isTransferable = false;

    event TokensTransferable();

    modifier transferable() {
        require(msg.sender == owner || isTransferable);
        _;
    }

    /// @dev Creates all tokens and gives them to the owner.
    function ColuLocalNetwork(uint256 _totalSupply) public {
        totalSupply = _totalSupply;
        balances[msg.sender] = totalSupply;
    }

    /// @dev start transferable mode.
    function makeTokensTransferable() external onlyOwner {
        if (isTransferable) {
            return;
        }

        isTransferable = true;

        TokensTransferable();
    }

    /// @dev Same ERC20 behavior, but reverts if not transferable.
    /// @param _spender address The address which will spend the funds.
    /// @param _value uint256 The amount of tokens to be spent.
    function approve(address _spender, uint256 _value) public transferable returns (bool) {
        return super.approve(_spender, _value);
    }

    /// @dev Same ERC20 behavior, but reverts if not transferable.
    /// @param _to address The address to transfer to.
    /// @param _value uint256 The amount to be transferred.
    function transfer(address _to, uint256 _value) public transferable returns (bool) {
        return super.transfer(_to, _value);
    }

    /// @dev Same ERC20 behavior, but reverts if not transferable.
    /// @param _from address The address to send tokens from.
    /// @param _to address The address to transfer to.
    /// @param _value uint256 the amount of tokens to be transferred.
    function transferFrom(address _from, address _to, uint256 _value) public transferable returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    /// @dev Same ERC677 behavior, but reverts if not transferable.
    /// @param _to address The address to transfer to.
    /// @param _value uint256 The amount to be transferred.
    /// @param _data bytes data to send to receiver if it is a contract.
    function transferAndCall(address _to, uint _value, bytes _data) public transferable returns (bool success) {
      return super.transferAndCall(_to, _value, _data);
    }
}