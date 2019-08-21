pragma solidity ^0.4.0;
contract onchain{
    string onChainData;
    function set (string x) public{
        onChainData = x;
    }
    
    function get() public constant returns (string){
        return onChainData;
    }
}