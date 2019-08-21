pragma solidity ^0.4.8;

contract SmartpoolVersion {
    address    public poolContract;
    bytes32    public clientVersion;
    
    mapping (address=>bool) owners;
    
    function SmartpoolVersion( address[3] _owners ) {
        owners[_owners[0]] = true;
        owners[_owners[1]] = true;
        owners[_owners[2]] = true;        
    }
    
    function updatePoolContract( address newAddress ) {
        if( ! owners[msg.sender] ) throw;
        
        poolContract = newAddress;
    }
    
    function updateClientVersion( bytes32 version ) {
        if( ! owners[msg.sender] ) throw;
        
        clientVersion = version;
    }
}