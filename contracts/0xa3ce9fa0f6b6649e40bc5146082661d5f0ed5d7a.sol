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
/**
 * @title Token contract represents any asset in digital economy
 */
contract Token is Mortal {
    event Transfer(address indexed _from,  address indexed _to,      uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /* Short description of token */
    string public name;
    string public symbol;

    /* Total count of tokens exist */
    uint public totalSupply;

    /* Fixed point position */
    uint8 public decimals;
    
    /* Token approvement system */
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
 
    /**
     * @return available balance of `sender` account (self balance)
     */
    function getBalance() constant returns (uint)
    { return balanceOf[msg.sender]; }
 
    /**
     * @dev This method returns non zero result when sender is approved by
     *      argument address and target address have non zero self balance
     * @param _address target address 
     * @return available for `sender` balance of given address
     */
    function getBalance(address _address) constant returns (uint) {
        return allowance[_address][msg.sender]
             > balanceOf[_address] ? balanceOf[_address]
                                   : allowance[_address][msg.sender];
    }
 
    /* Token constructor */
    function Token(string _name, string _symbol, uint8 _decimals, uint _count) {
        name     = _name;
        symbol   = _symbol;
        decimals = _decimals;
        totalSupply           = _count;
        balanceOf[msg.sender] = _count;
    }
 
    /**
     * @dev Transfer self tokens to given address
     * @param _to destination address
     * @param _value amount of token values to send
     * @notice `_value` tokens will be sended to `_to`
     * @return `true` when transfer done
     */
    function transfer(address _to, uint _value) returns (bool) {
        if (balanceOf[msg.sender] >= _value) {
            balanceOf[msg.sender] -= _value;
            balanceOf[_to]        += _value;
            Transfer(msg.sender, _to, _value);
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
    function transferFrom(address _from, address _to, uint _value) returns (bool) {
        var avail = allowance[_from][msg.sender]
                  > balanceOf[_from] ? balanceOf[_from]
                                     : allowance[_from][msg.sender];
        if (avail >= _value) {
            allowance[_from][msg.sender] -= _value;
            balanceOf[_from] -= _value;
            balanceOf[_to]   += _value;
            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    /**
     * @dev Give to target address ability for self token manipulation without sending
     * @param _address target address
     * @param _value amount of token values for approving
     */
    function approve(address _address, uint _value) {
        allowance[msg.sender][_address] += _value;
        Approval(msg.sender, _address, _value);
    }

    /**
     * @dev Reset count of tokens approved for given address
     * @param _address target address
     */
    function unapprove(address _address)
    { allowance[msg.sender][_address] = 0; }
}
/**
 * @title Ethereum crypto currency extention for Token contract
 */
contract TokenEther is Token {
    function TokenEther(string _name, string _symbol)
             Token(_name, _symbol, 18, 0)
    {}

    /**
     * @dev This is the way to withdraw money from token
     * @param _value how many tokens withdraw from balance
     */
    function withdraw(uint _value) {
        if (balanceOf[msg.sender] >= _value) {
            balanceOf[msg.sender] -= _value;
            totalSupply           -= _value;
            if(!msg.sender.send(_value)) throw;
        }
    }

    /**
     * @dev This is the way to refill your token balance by ethers
     */
    function refill() payable returns (bool) {
        balanceOf[msg.sender] += msg.value;
        totalSupply           += msg.value;
        return true;
    }

    /**
     * @dev This method is called when money sended to contract address,
     *      a synonym for refill()
     */
    function () payable {
        balanceOf[msg.sender] += msg.value;
        totalSupply           += msg.value;
    }
    
    /**
     * @dev By security issues token that holds ethers can not be killed
     */
    function kill() onlyOwner { throw; }
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

contract AiraEtherFunds is TokenEther {
    function AiraEtherFunds(address _bot_reg, string _name, string _symbol)
            TokenEther(_name, _symbol) {
        reg = AiraRegistrarService(_bot_reg);
    }

    /**
     * @dev Event spawned when activation request received
     */
    event ActivationRequest(address indexed sender, bytes32 indexed code);

    // Balance limit
    uint public limit;
    
    function setLimit(uint _limit) onlyOwner
    { limit = _limit; }

    // Account activation fee
    uint public fee;
    
    function setFee(uint _fee) onlyOwner
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
            balanceOf[owner] += fee;
            value            -= fee;
        }

        // Refund over limit
        if (limit > 0 && value > limit) {
            var refund = value - limit;
            if (!msg.sender.send(refund)) throw;
            value = limit;
        }

        // Refill account balance
        balanceOf[msg.sender] += value;
        totalSupply           += value;

        // Activation event
        ActivationRequest(msg.sender, stringToBytes32(_code));
    }

    /**
     * @dev String to bytes32 conversion helper
     */
    function stringToBytes32(string memory source) constant returns (bytes32 result)
    { assembly { result := mload(add(source, 32)) } }

    /**
     * @dev This is the way to refill your token balance by ethers
     */
    function refill() payable returns (bool) {
        // Throw when over limit
        if (balanceOf[msg.sender] + msg.value > limit) throw;

        // Refill
        balanceOf[msg.sender] += msg.value;
        totalSupply           += msg.value;
        return true;
    }

    /**
     * @dev This is the way to refill token balance by ethers
     * @param _dest is destination address
     */
    function refill(address _dest) payable returns (bool) {
        // Throw when over limit
        if (balanceOf[_dest] + msg.value > limit) throw;

        // Refill
        balanceOf[_dest] += msg.value;
        totalSupply      += msg.value;
        return true;
    }

    /**
     * @dev This method is called when money sended to contract address,
     *      a synonym for refill()
     */
    function () payable {
        // Throw when over limit
        if (balanceOf[msg.sender] + msg.value > limit) throw;

        // Refill
        balanceOf[msg.sender] += msg.value;
        totalSupply           += msg.value;
    }

    /**
     * @dev Outgoing transfer (send) with allowance
     * @param _from source address
     * @param _to destination address
     * @param _value amount of token values to send 
     */
    function sendFrom(address _from, address _to, uint _value) {
        var avail = allowance[_from][msg.sender]
                  > balanceOf[_from] ? balanceOf[_from]
                                     : allowance[_from][msg.sender];
        if (avail >= _value) {
            allowance[_from][msg.sender] -= _value;
            balanceOf[_from]             -= _value;
            totalSupply                  -= _value;
            if (!_to.send(_value)) throw;
        }
    }

    AiraRegistrarService public reg;
    modifier onlySecure { if (msg.sender != reg.addr("AiraSecure")) throw; _; }

    /**
     * @dev Increase approved token values for AiraEthBot
     * @param _client is a client address
     * @param _value is amount of tokens
     */
    function secureApprove(address _client, uint _value) onlySecure {
        var ethBot = reg.addr("AiraEth");
        if (ethBot != 0)
            allowance[_client][ethBot] += _value;
    }

    /**
     * @dev Close allowance for AiraEthBot
     */
    function secureUnapprove(address _client) onlySecure {
        var ethBot = reg.addr("AiraEth");
        if (ethBot != 0)
            allowance[_client][ethBot] = 0;
    }
}