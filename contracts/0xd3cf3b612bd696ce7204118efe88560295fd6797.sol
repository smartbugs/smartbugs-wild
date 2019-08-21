/*
    xgr_fork.sol
    2.0.0
    
    Rajci 'iFA' Andor @ ifa@fusionwallet.io
*/
pragma solidity 0.4.18;

contract Owned {
    /* Variables */
    address public owner = msg.sender;
    /* Externals */
    function replaceOwner(address newOwner) external returns(bool success) {
        require( isOwner() );
        owner = newOwner;
        return true;
    }
    /* Internals */
    function isOwner() internal view returns(bool) {
        return owner == msg.sender;
    }
    /* Modifiers */
    modifier onlyForOwner {
        require( isOwner() );
        _;
    }
}

contract Token {
    /*
        This is just an abstract contract with the necessary functions
    */
    function mint(address owner, uint256 value) external returns (bool success) {}
}

contract Fork is Owned {
    /* Variables */
    address public uploader;
    address public tokenAddress;
    /* Constructor */
    function Fork(address _uploader) public {
        uploader = _uploader;
    }
    /* Externals */
    function changeTokenAddress(address newTokenAddress) external onlyForOwner {
        tokenAddress = newTokenAddress;
    }
    function upload(address[] addr, uint256[] amount) external onlyForUploader {
        require( addr.length == amount.length );
        for ( uint256 a=0 ; a<addr.length ; a++ ) {
            require( Token(tokenAddress).mint(addr[a], amount[a]) );
        }
    }
    /* Modifiers */
    modifier onlyForUploader {
        require( msg.sender == uploader );
        _;
    }
}