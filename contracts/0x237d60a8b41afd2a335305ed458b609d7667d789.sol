pragma solidity ^0.4.2;
/**
 * @title Contract for object that have an owner
 */
contract Owned {
    /**
     * Contract owner address
     */
    address public owner;

    /**
     * @dev Store owner on creation
     */
    function Owned() { owner = msg.sender; }

    /**
     * @dev Delegate contract to another person
     * @param _owner is another person address
     */
    function delegate(address _owner) onlyOwner
    { owner = _owner; }

    /**
     * @dev Owner check modifier
     */
    modifier onlyOwner { if (msg.sender != owner) throw; _; }
}
/**
 * @title Contract for objects that can be morder
 */
contract Mortal is Owned {
    /**
     * @dev Destroy contract and scrub a data
     * @notice Only owner can kill me
     */
    function kill() onlyOwner
    { suicide(owner); }
}

// Standard token interface (ERC 20)
// https://github.com/ethereum/EIPs/issues/20
contract ERC20 
{
// Functions:
    /// @return total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256);

// Events:
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/**
 * @title Token compatible contract represents any asset in digital economy
 * @dev Accounting based on sha3 hashed identifiers
 */
contract TokenHash is Mortal, ERC20 {
    /* Short description of token */
    string public name;
    string public symbol;

    /* Fixed point position */
    uint8 public decimals;

    /* Token approvement system */
    mapping(bytes32 => uint256) balances;
    mapping(bytes32 => mapping(bytes32 => uint256)) allowances;
 
    /**
     * @dev Get balance of plain address
     * @param _owner is a target address
     * @return amount of tokens on balance
     */
    function balanceOf(address _owner) constant returns (uint256)
    { return balances[sha3(_owner)]; }

    /**
     * @dev Get balance of ident
     * @param _owner is a target ident
     * @return amount of tokens on balance
     */
    function balanceOf(bytes32 _owner) constant returns (uint256)
    { return balances[_owner]; }

    /**
     * @dev Take allowed tokens
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) constant returns (uint256)
    { return allowances[sha3(_owner)][sha3(_spender)]; }

    /**
     * @dev Take allowed tokens
     * @param _owner The ident of the account owning tokens
     * @param _spender The ident of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(bytes32 _owner, bytes32 _spender) constant returns (uint256)
    { return allowances[_owner][_spender]; }

    /* Token constructor */
    function TokenHash(string _name, string _symbol, uint8 _decimals, uint256 _count) {
        name        = _name;
        symbol      = _symbol;
        decimals    = _decimals;
        totalSupply = _count;
        balances[sha3(msg.sender)] = _count;
    }
 
    /**
     * @dev Transfer self tokens to given address
     * @param _to destination address
     * @param _value amount of token values to send
     * @notice `_value` tokens will be sended to `_to`
     * @return `true` when transfer done
     */
    function transfer(address _to, uint256 _value) returns (bool) {
        var sender = sha3(msg.sender);

        if (balances[sender] >= _value) {
            balances[sender]    -= _value;
            balances[sha3(_to)] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    /**
     * @dev Transfer self tokens to given address
     * @param _to destination ident
     * @param _value amount of token values to send
     * @notice `_value` tokens will be sended to `_to`
     * @return `true` when transfer done
     */
    function transfer(bytes32 _to, uint256 _value) returns (bool) {
        var sender = sha3(msg.sender);

        if (balances[sender] >= _value) {
            balances[sender] -= _value;
            balances[_to]    += _value;
            TransferHash(sender, _to, _value);
            return true;
        }
        return false;
    }


    /**
     * @dev Transfer with approvement mechainsm
     * @param _from source address, `_value` tokens shold be approved for `sender`
     * @param _to destination address
     * @param _value amount of token values to send 
     * @notice from `_from` will be sended `_value` tokens to `_to`
     * @return `true` when transfer is done
     */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        var to    = sha3(_to);
        var from  = sha3(_from);
        var sender= sha3(msg.sender);
        var avail = allowances[from][sender]
                  > balances[from] ? balances[from]
                                   : allowances[from][sender];
        if (avail >= _value) {
            allowances[from][sender] -= _value;
            balances[from] -= _value;
            balances[to]   += _value;
            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    /**
     * @dev Transfer with approvement mechainsm
     * @param _from source ident, `_value` tokens shold be approved for `sender`
     * @param _to destination ident
     * @param _value amount of token values to send 
     * @notice from `_from` will be sended `_value` tokens to `_to`
     * @return `true` when transfer is done
     */
    function transferFrom(bytes32 _from, bytes32 _to, uint256 _value) returns (bool) {
        var sender= sha3(msg.sender);
        var avail = allowances[_from][sender]
                  > balances[_from] ? balances[_from]
                                    : allowances[_from][sender];
        if (avail >= _value) {
            allowances[_from][sender] -= _value;
            balances[_from] -= _value;
            balances[_to]   += _value;
            TransferHash(_from, _to, _value);
            return true;
        }
        return false;
    }

    /**
     * @dev Give to target address ability for self token manipulation without sending
     * @param _spender target address (future requester)
     * @param _value amount of token values for approving
     */
    function approve(address _spender, uint256 _value) returns (bool) {
        allowances[sha3(msg.sender)][sha3(_spender)] += _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
 
    /**
     * @dev Give to target ident ability for self token manipulation without sending
     * @param _spender target ident (future requester)
     * @param _value amount of token values for approving
     */
    function approve(bytes32 _spender, uint256 _value) returns (bool) {
        allowances[sha3(msg.sender)][_spender] += _value;
        ApprovalHash(sha3(msg.sender), _spender, _value);
        return true;
    }

    /**
     * @dev Reset count of tokens approved for given address
     * @param _spender target address
     */
    function unapprove(address _spender)
    { allowances[sha3(msg.sender)][sha3(_spender)] = 0; }
 
    /**
     * @dev Reset count of tokens approved for given ident
     * @param _spender target ident
     */
    function unapprove(bytes32 _spender)
    { allowances[sha3(msg.sender)][_spender] = 0; }
 
    /* Hash driven events */
    event TransferHash(bytes32 indexed _from,  bytes32 indexed _to,      uint256 _value);
    event ApprovalHash(bytes32 indexed _owner, bytes32 indexed _spender, uint256 _value);
}


//sol Registrar
// Simple global registrar.
// @authors:
//   Gav Wood <g@ethdev.com>

contract Registrar {
	event Changed(string indexed name);

	function owner(string _name) constant returns (address o_owner);
	function addr(string _name) constant returns (address o_address);
	function subRegistrar(string _name) constant returns (address o_subRegistrar);
	function content(string _name) constant returns (bytes32 o_content);
}

//sol OwnedRegistrar
// Global registrar with single authoritative owner.
// @authors:
//   Gav Wood <g@ethdev.com>

contract AiraRegistrarService is Registrar, Mortal {
	struct Record {
		address addr;
		address subRegistrar;
		bytes32 content;
	}
	
    function owner(string _name) constant returns (address o_owner)
    { return 0; }

	function disown(string _name) onlyOwner {
		delete m_toRecord[_name];
		Changed(_name);
	}

	function setAddr(string _name, address _a) onlyOwner {
		m_toRecord[_name].addr = _a;
		Changed(_name);
	}
	function setSubRegistrar(string _name, address _registrar) onlyOwner {
		m_toRecord[_name].subRegistrar = _registrar;
		Changed(_name);
	}
	function setContent(string _name, bytes32 _content) onlyOwner {
		m_toRecord[_name].content = _content;
		Changed(_name);
	}
	function record(string _name) constant returns (address o_addr, address o_subRegistrar, bytes32 o_content) {
		o_addr = m_toRecord[_name].addr;
		o_subRegistrar = m_toRecord[_name].subRegistrar;
		o_content = m_toRecord[_name].content;
	}
	function addr(string _name) constant returns (address) { return m_toRecord[_name].addr; }
	function subRegistrar(string _name) constant returns (address) { return m_toRecord[_name].subRegistrar; }
	function content(string _name) constant returns (bytes32) { return m_toRecord[_name].content; }

	mapping (string => Record) m_toRecord;
}

contract AiraEtherFunds is TokenHash {
    function AiraEtherFunds(address _bot_reg, string _name, string _symbol)
            TokenHash(_name, _symbol, 18, 0) {
        reg = AiraRegistrarService(_bot_reg);
    }

    /**
     * @dev Event spawned when activation request received
     */
    event ActivationRequest(address indexed ident, bytes32 indexed code);

    // Balance limit
    uint256 public limit;
    
    function setLimit(uint256 _limit) onlyOwner
    { limit = _limit; }

    // Account activation fee
    uint256 public fee;
    
    function setFee(uint256 _fee) onlyOwner
    { fee = _fee; }

    /**
     * @dev Refill balance and activate it by code
     * @param _code is activation code
     */
    function activate(string _code) payable {
        var value = msg.value;
 
        // Get a fee
        if (fee > 0) {
            if (value < fee) throw;
            balances[sha3(owner)] += fee;
            value                 -= fee;
        }

        // Refund over limit
        if (limit > 0 && value > limit) {
            var refund = value - limit;
            if (!msg.sender.send(refund)) throw;
            value = limit;
        }

        // Refill account balance
        balances[sha3(msg.sender)] += value;
        totalSupply                += value;

        // Activation event
        ActivationRequest(msg.sender, stringToBytes32(_code));
    }

    /**
     * @dev String to bytes32 conversion helper
     */
    function stringToBytes32(string memory source) constant returns (bytes32 result)
    { assembly { result := mload(add(source, 32)) } }

    /**
     * @dev This is the way to refill token balance by ethers
     * @param _dest is destination address
     */
    function refill(address _dest) payable returns (bool)
    { return refill(sha3(_dest)); }

    /**
     * @dev This method is called when money sended to contract address,
     *      a synonym for refill()
     */
    function () payable
    { refill(msg.sender); }

    /**
     * @dev This is the way to refill token balance by ethers
     * @param _dest is destination identifier
     */
    function refill(bytes32 _dest) payable returns (bool) {
        // Throw when over limit
        if (balances[_dest] + msg.value > limit) throw;

        // Refill
        balances[_dest] += msg.value;
        totalSupply     += msg.value;
        return true;
    }

    /**
     * @dev Outgoing transfer (send) with allowance
     * @param _from source identifier
     * @param _to external destination address
     * @param _value amount of token values to send 
     */
    function sendFrom(bytes32 _from, address _to, uint256 _value) {
        var sender = sha3(msg.sender);
        var avail = allowances[_from][sender]
                  > balances[_from] ? balances[_from]
                                    : allowances[_from][sender];
        if (avail >= _value) {
            allowances[_from][sender] -= _value;
            balances[_from]           -= _value;
            totalSupply               -= _value;
            if (!_to.send(_value)) throw;
        }
    }

    AiraRegistrarService public reg;
    modifier onlySecure { if (msg.sender != reg.addr("AiraSecure")) throw; _; }

    /**
     * @dev Increase approved token values for AiraEthBot
     * @param _client is a client ident
     * @param _value is amount of tokens
     */
    function secureApprove(bytes32 _client, uint256 _value) onlySecure {
        var ethBot = reg.addr("AiraEth");
        if (ethBot != 0) {
            allowances[_client][sha3(ethBot)] += _value;
            ApprovalHash(_client, sha3(ethBot), _value);
        }
    }

    /**
     * @dev Close allowance for AiraEthBot
     * @param _client is a client ident
     */
    function secureUnapprove(bytes32 _client) onlySecure {
        var ethBot = reg.addr("AiraEth");
        if (ethBot != 0)
            allowances[_client][sha3(ethBot)] = 0;
    }

    // By security issues deny to kill this by owner
    function kill() onlyOwner { throw; }
}