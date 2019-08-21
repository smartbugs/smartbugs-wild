/**
 *  NTRY Cointract contract, ERC20 compliant (see https://github.com/ethereum/EIPs/issues/20)
 *
 *  Code is based on multiple sources:
 *  https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20.sol
 *  https://github.com/ConsenSys/Tokens/blob/master/Token_Contracts/contracts/Token.sol
 */

pragma solidity ^0.4.8;

contract Token {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/**
 *  NTRY Cointract contract, ERC20 compliant (see https://github.com/ethereum/EIPs/issues/20)
 *
 *  Code is based on multiple sources:
 *  https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20.sol
 *  https://github.com/ConsenSys/Tokens/blob/master/Token_Contracts/contracts/HumanStandardToken.sol
 */

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

/**
 *  NTRY Cointract contract, ERC20 compliant (see https://github.com/ethereum/EIPs/issues/20)
 *
 *  Code is based on multiple sources:
 *  https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20.sol
 *  https://github.com/ConsenSys/Tokens/blob/master/Token_Contracts/contracts/HumanStandardToken.sol
 */
 
contract NotaryToken is StandardToken{

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }
    
    address owner;
    mapping (address => bool) associateContracts;

    modifier onlyOwner { if (msg.sender != owner) throw; _; }

    /* Public variables of the token */
    string public name = "Notary Platform Token";
    uint8 public decimals = 18;
    string public symbol = "NTRY";
    string public version = 'NTRY-1.0';

    function NotaryToken() {
        owner = 0x1538EF80213cde339A333Ee420a85c21905b1b2D;
        /* Total supply is One hundred and fifty million (150,000,000)*/
        balances[0x1538EF80213cde339A333Ee420a85c21905b1b2D] = 150000000 * 1 ether;
        totalSupply = 150000000 * 1 ether;

        balances[0x1538EF80213cde339A333Ee420a85c21905b1b2D] -= teamAllocations;
        unlockedAt =  now + 365 * 1 days;   // Freeze notary team funds for one year
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) {
            throw; 
        }
        return true;
    }

    /* In certain cases associated contracts can recover NTRY they have distributed */
    function takeBackNTRY(address _from,address _to, uint256 _value) returns (bool) {
        if (associateContracts[msg.sender]){
            balances[_from] -= _value;
            balances[_to] += _value;
            return true;
        }else{
            return false;
        }
        
    }

    function newAssociate(address _addressOfAssociate) onlyOwner {
        associateContracts[_addressOfAssociate] = true;
    }

    /* Expire association with NTRY Token*/
    function expireAssociate(address _addressOfAssociate) onlyOwner {
        delete associateContracts[_addressOfAssociate];
    }
    
    /* Verify contract association with NTRY Token*/
    function isAssociated(address _addressOfAssociate) returns(bool){
        return associateContracts[_addressOfAssociate]; 
    }

    function transferOwnership(address _newOwner) onlyOwner {
        balances[_newOwner] = balances[owner];
        balances[owner] = 0;
        owner = _newOwner;
    }


    uint256 constant teamAllocations = 15000000 * 1 ether;
    uint256 unlockedAt;
    mapping (address => uint256) allocations;
    function allocate() onlyOwner {
        allocations[0xab1cb1740344A9280dC502F3B8545248Dc3045eA] = 2500000 * 1 ether;
        allocations[0x330709A59Ab2D1E1105683F92c1EE8143955a357] = 2500000 * 1 ether;
        allocations[0xAa0887fc6e8896C4A80Ca3368CFd56D203dB39db] = 2500000 * 1 ether;
        allocations[0x1fbA1d22435DD3E7Fa5ba4b449CC550a933E72b3] = 2500000 * 1 ether;
        allocations[0xC9d5E2c7e40373ae576a38cD7e62E223C95aBFD4] = 500000 * 1 ether;
        allocations[0xabc0B64a38DE4b767313268F0db54F4cf8816D9C] = 500000 * 1 ether;
        allocations[0x5d85bCDe5060C5Bd00DBeDF5E07F43CE3Ccade6f] = 250000 * 1 ether;
        allocations[0xecb1b0231CBC0B04015F9e5132C62465C128B578] = 250000 * 1 ether;
        allocations[0xF9b1Cfc7fe3B63bEDc594AD20132CB06c18FD5F2] = 250000 * 1 ether;
        allocations[0xDbb89a87d9f91EA3f0Ab035a67E3A951A05d0130] = 250000 * 1 ether;
        allocations[0xC1530645E21D27AB4b567Bac348721eE3E244Cbd] = 200000 * 1 ether;
        allocations[0xcfb44162030e6CBca88e65DffA21911e97ce8533] = 200000 * 1 ether;
        allocations[0x64f748a5C5e504DbDf61d49282d6202Bc1311c3E] = 200000 * 1 ether;
        allocations[0xFF22FA2B3e5E21817b02a45Ba693B7aC01485a9C] = 200000 * 1 ether;
        allocations[0xC9856112DCb8eE449B83604438611EdCf61408AF] = 200000 * 1 ether;
        allocations[0x689CCfEABD99081D061aE070b1DA5E1f6e4B9fB2] = 2000000 * 1 ether;
    }
   
    function withDraw(){
        if(now < unlockedAt){ 
            return;
        }
        if(allocations[msg.sender] > 0){
            balances[msg.sender] += allocations[msg.sender];
            allocations[msg.sender] = 0;
        }
    }
}