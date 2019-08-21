pragma solidity ^0.4.15;

/* TODO: change this to an interface definition as soon as truffle accepts it. See https://github.com/trufflesuite/truffle/issues/560 */
contract ITransferable {
    function transfer(address _to, uint256 _value) public returns (bool success);
}

/**
@title PLAY Token

ERC20 Token with additional mint functionality.
A "controller" (initialized to the contract creator) has exclusive permission to mint.
The controller address can be changed until locked.

Implementation based on https://github.com/ConsenSys/Tokens
*/
contract PlayToken {
    uint256 public totalSupply = 0;
    string public name = "PLAY";
    uint8 public decimals = 18;
    string public symbol = "PLY";
    string public version = '1';

    address public controller;
    bool public controllerLocked = false;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    modifier onlyController() {
        require(msg.sender == controller);
        _;
    }

    /** @dev constructor */
    function PlayToken(address _controller) {
        controller = _controller;
    }

    /** Sets a new controller address if the current controller isn't locked */
    function setController(address _newController) onlyController {
        require(! controllerLocked);
        controller = _newController;
    }

    /** Locks the current controller address forever */
    function lockController() onlyController {
        controllerLocked = true;
    }

    /**
    Creates new tokens for the given receiver.
    Can be called only by the contract creator.
    */
    function mint(address _receiver, uint256 _value) onlyController {
        balances[_receiver] += _value;
        totalSupply += _value;
        // (probably) recommended by the standard, see https://github.com/ethereum/EIPs/pull/610/files#diff-c846f31381e26d8beeeae24afcdf4e3eR99
        Transfer(0, _receiver, _value);
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        /* Additional Restriction: don't accept token payments to the contract itself and to address 0 in order to avoid most
         token losses by mistake - as is discussed in https://github.com/ethereum/EIPs/issues/223 */
        require((_to != 0) && (_to != address(this)));

        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
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

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        /* call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead. */
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }

    /**
    Withdraws tokens held by the contract to a given account.
    Motivation: see https://github.com/ethereum/EIPs/issues/223#issuecomment-317987571
    */
    function withdrawTokens(ITransferable _token, address _to, uint256 _amount) onlyController {
        _token.transfer(_to, _amount);
    }
}