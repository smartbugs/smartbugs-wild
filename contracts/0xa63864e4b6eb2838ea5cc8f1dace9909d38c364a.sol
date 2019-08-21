pragma solidity ^0.4.19;

/* Function required from STCn main contract */
contract ERC20Token {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {}
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
    
}

contract MultiSend {
    ERC20Token public _STCnContract;
    address public _multiSendOwner;
    uint256 public tokensApproved;
    
    function MultiSend () {
        address c = 0x420C42cE1370c0Ec3ca87D9Be64A7002E78e6709; // set STCn contract address
        _STCnContract = ERC20Token(c); 
        _multiSendOwner = msg.sender;
        tokensApproved = 0; // set to 0 first as allowance to contract can't be set yet
    }
    
    /* Before first sending, make sure to allow this contract spending from token contract with function approve(address _spender, uint256 _value)
    ** and to update tokensApproved with function updateTokensApproved () */
    
    function dropCoinsSingle(address[] dests, uint256 tokens) {
        require(msg.sender == _multiSendOwner && tokensApproved >= (dests.length * tokens));
        uint256 i = 0;
        while (i < dests.length) {
            _STCnContract.transferFrom(_multiSendOwner, dests[i], tokens);
            i += 1;
        }
        updateTokensApproved();
    }
    
    /* Be careful to this function to be sure you approved enough before you send as contract can't check first total amount in array
    ** If not enough amount is approved, transaction will fail */
    
    function dropCoinsMulti(address[] dests, uint256[] tokens) {
        require(msg.sender == _multiSendOwner);
        uint256 i = 0;
        while (i < dests.length) {
            _STCnContract.transferFrom(_multiSendOwner, dests[i], tokens[i]);
            i += 1;
        }
        updateTokensApproved();
    }
    
    function updateTokensApproved () {
        tokensApproved = _STCnContract.allowance(_multiSendOwner, this);
    }
    
}