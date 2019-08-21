pragma solidity >=0.4.22 <0.6.0;

/*
* EthCC Playing Cards
* Well done, Yes! there was a smart contract address hidden in the game. 
* The good news is that you can leave your nickname to say "I was there". 
* The bad news is that there is nothing to gain except the pleasure of participating :)
*/

contract EthCCPlayingCards {

    mapping (address => bool) public addressFound;

    event LogAddressFound(address indexed whoAddress, bytes32 whoName);

    function addressFoundBy(bytes32 name) public {
        addressFound[msg.sender] = true;
        emit LogAddressFound(msg.sender, name);
    }
}