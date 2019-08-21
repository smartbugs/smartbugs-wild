contract IToken {
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address _owner) constant returns (uint256 balance) {}
    function transferViaProxy(address _from, address _to, uint _value) returns (uint error) {}
    function transferFromViaProxy(address _source, address _from, address _to, uint256 _amount) returns (uint error) {}
    function approveViaProxy(address _source, address _spender, uint256 _value) returns (uint error) {}
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {} 
    function mint(address _destination, uint _amount) returns (uint error){}
    function destroy(address _destination, uint _amount) returns (uint error) {}
}


contract MacroDestructionContract{
    
    address public curator;
    address public dev;

    IToken tokenContract;

    function MacroDestructionContract(){
        dev = msg.sender;
    }

    function destroy(uint _amount){
        if (msg.sender != curator) throw;
        tokenContract.destroy(msg.sender, _amount);
    }

    function setCurator(address _curatorAddress){
        if (msg.sender != dev) throw;
        curator = _curatorAddress;
    }

    function setTokenContract(address _contractAddress){
        if (msg.sender != curator) throw;
        tokenContract = IToken(_contractAddress);
    }

    function killContract() {
        if (msg.sender != dev) throw;
        selfdestruct(dev);
    }

    function tokenAddress() constant returns (address tokenAddress){
        return address(tokenContract);
    }

    function () {
        throw;
    }
}