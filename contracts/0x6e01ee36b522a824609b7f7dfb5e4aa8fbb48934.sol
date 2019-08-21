//https://github.com/codetract/ethToken

pragma solidity ^0.4.6;

/**
@title StandardToken
@author https://github.com/ConsenSys/Tokens/tree/master/Token_Contracts/contracts
*/
contract StandardToken {
    uint256 public totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /**
    @notice Function transfers '_value' tokens from 'msg.sender' to '_to'
    @param _to The address of the destination account
    @param _value The number of tokens to be transferred
    @return success Whether the transfer is successful
    */
    function transfer(address _to, uint256 _value) returns(bool success) {
        if(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /**
    @notice Function transfers '_value' tokens from '_from' to '_to' if there is allowance
    @param _from The address of the source account
    @param _to The address of the destination account
    @param _value The number of tokens to be transferred
    @return success Whether the transfer is successful
    */
    function transferFrom(address _from, address _to, uint256 _value) returns(bool success) {
        if(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /**
   	@notice Returns the balance associated with the relevant address
   	@param _owner address of account owner
   	@return { "balance" : "token balance of _owner" }
   	*/
    function balanceOf(address _owner) constant returns(uint256 balance) {
        return balances[_owner];
    }

    /**
    @notice Function approves `_addr` to spend `_value` tokens of msg.sender
    @param _spender The address of the account able to transfer the tokens
    @param _value The amount of wei to be approved for transfer
    @return success Whether the approval was successful or not
    */
    function approve(address _spender, uint256 _value) returns(bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    @notice Returns the amount for _spender left approved by _owner
    @param _owner The address of the account owning tokens
    @param _spender The address of the account able to transfer the tokens
    @return remaining Amount of remaining tokens allowed to spent
    */
    function allowance(address _owner, address _spender) constant returns(uint256 remaining) {
        return allowed[_owner][_spender];
    }

}

/**
@title HumanStandardToken
@author https://github.com/ConsenSys/Tokens/tree/master/Token_Contracts/contracts
*/
contract HumanStandardToken is StandardToken {
    string public name; //fancy name: eg Simon Bucks
    uint8 public decimals; //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol; //An identifier: eg SBX
    string public version; //human 0.1 standard. Just an arbitrary versioning scheme.
}

/**
@title EthToken
@author https://codetract.io
*/
contract EthToken is HumanStandardToken {
    /**
    @notice Constructor function for the EthToken contract
    @dev Contract to trade ether to tokens at 1 to 1
    */
    function EthToken() {
        balances[msg.sender] = 0;
        totalSupply = 0;
        name = 'ETH Token';
        decimals = 18;
        symbol = 'Ξ';
        version = '0.2';
    }

    event LogCreateToken(address indexed _from, uint256 _value);
    event LogRedeemToken(address indexed _from, uint256 _value);

    /**
    @notice Creates ether tokens corresponding to the amount of ether received 'msg.value'. Updates account token balance
    @return success Whether the transfer is successful
    */
    function createToken() payable returns(bool success) {
        if(msg.value == 0) {
            throw;
        }
        if((balances[msg.sender] + msg.value) > balances[msg.sender] && (totalSupply + msg.value) > totalSupply) {
            totalSupply += msg.value;
            balances[msg.sender] += msg.value;
            LogCreateToken(msg.sender, msg.value);
            return true;
        } else {
            throw;
        }
    }

    /**
    @notice Converts token quantity defined by '_token' into ether and sends back to msg.sender
    @param _tokens The number of tokens to be converted to ether
    @return success Whether the transfer is successful
    */
    function redeemToken(uint256 _tokens) returns(bool success) {
        if(this.balance < totalSupply) {
            throw;
        }
        if(_tokens == 0) {
            throw;
        }
        if(balances[msg.sender] >= _tokens && totalSupply >= _tokens) {
            balances[msg.sender] -= _tokens;
            totalSupply -= _tokens;
            if(msg.sender.send(_tokens)) {
                LogRedeemToken(msg.sender, _tokens);
                return true;
            } else {
                throw;
            }
        } else {
            throw;
        }
    }

    function() payable {
        createToken();
    }
}