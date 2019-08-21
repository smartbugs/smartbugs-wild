pragma solidity ^ 0.4 .25;

contract BSAFEWhiteList  {
    
    address public owner;
    
    mapping ( address => bool ) public whitelist;
    mapping ( address => bool ) public blacklist;
    
    event AddressWhiteListed(address _whitelisted);
    event AddressDeWhiteListed(address _dewhitelisted);
    event AddressBlackListed(address _blacklisted);
    event AddressDeBlackListed(address _dewhitelisted);
    
    
    
    modifier onlyOwner {
		require( msg.sender == owner );
		_;
	}
    
   
    constructor(){
        
        owner = msg.sender;
        
    }
   
   
   function whitelistAddress( address _address ) public onlyOwner{
       
       whitelist[ _address ] = true;
       emit AddressWhiteListed( _address);
       
       
   }
   
   
   function blacklistAddress( address _address ) public onlyOwner{
       
       blacklist[ _address ] = true;
       emit AddressBlackListed( _address);
       
   }
   
   
   function dewhitelistAddress( address _address ) public onlyOwner{
       
       whitelist[ _address ] = false;
       emit AddressDeWhiteListed( _address);
       
       
   }
   
   
   function deblacklistAddress( address _address ) public onlyOwner{
       
       blacklist[ _address ] = false;
       emit AddressDeBlackListed( _address);
       
       
   }
   
   
   function checkAddress ( address _address ) constant public returns(bool) {
       
       if ( whitelist [ _address ] == true && blacklist[ _address ] == false ) return true;
       
       return false;
       
   }
   
   
   function changeOwner( address _newowner ) public onlyOwner {
       
       owner = _newowner;
       
   }
   
}