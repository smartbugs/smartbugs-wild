/*
-----------------------------------------------------------------
FILE INFORMATION
-----------------------------------------------------------------
file:       Docsigner.sol
version:    0.1
author:     Block8 Technologies

            Samuel Brooks

date:       2018-02-01

checked:    Anton Jurisevic
approved:   Samuel Brooks

-----------------------------------------------------------------
MODULE DESCRIPTION
-----------------------------------------------------------------



-----------------------------------------------------------------
LICENCE INFORMATION
-----------------------------------------------------------------

Copyright (c) 2018 Redenbach Lee Lawyers

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

-----------------------------------------------------------------
RELEASE NOTES
-----------------------------------------------------------------

-----------------------------------------------------------------
Block8 Technologies is accelerating blockchain technology
by incubating meaningful next-generation businesses.
Find out more at https://www.block8.io/
-----------------------------------------------------------------
*/

pragma solidity ^0.4.19;

contract DocSigner {

// -------------------------------------------------------------
// STATE DECLARATION
// -------------------------------------------------------------

    address public owner;// Redenbach-Lee address
    uint constant maxSigs = 10; // maximum number of counterparties
    uint numSigs = 0; // number of signatures for the next signing
    string public docHash; // current document hash
    address[10] signatories; // signatory addresses
    mapping(address => string) public messages;

// -------------------------------------------------------------
// CONSTRUCTOR
// -------------------------------------------------------------

    function DocSigner()
        public
    {
        owner = msg.sender;
    }

// -------------------------------------------------------------
// EVENTS
// -------------------------------------------------------------

    event Signature(address signer, string docHash, string message);

// -------------------------------------------------------------
// FUNCTIONS
// -------------------------------------------------------------

    /*
      This is the initialisation function for a new legal contract.
      The contract owner sets the new agreement hash and the
      number of signatories.
    */

    function setup( string   newDocHash,
                    address[] newSigs )
        external
        onlyOwner
    {
        require( newSigs.length <= maxSigs ); // bound array

        docHash = newDocHash;
        numSigs = newSigs.length;

        for( uint i = 0; i < numSigs; i++ ){
            signatories[i] = newSigs[i];
        }
    }

    /*
      This is the function used by signatories to confirm
      their agreement over the document hash.
    */

    function sign( string signingHash,
                   string message )
        external
        onlySigner
    {
        require(keccak256(signingHash) == keccak256(docHash));

        // save the message to state so that it can be easily queried
        messages[msg.sender] = message;

        Signature(msg.sender, docHash, message);
    }

    /*
      Check if the address is within the approved signatories list.
    */

    function checkSig(address addr)
        internal
        view
        returns (bool)
    {
        for( uint i = 0; i < numSigs; i++ ){
            if( signatories[i] == addr )
                return true;
        }

        return false;
    }

// -------------------------------------------------------------
// MODIFIERS
// -------------------------------------------------------------

    modifier onlyOwner
    {
        require(msg.sender == owner);
        _;
    }

    modifier onlySigner
    {
        require(checkSig(msg.sender));
        _;
    }
}