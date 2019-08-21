pragma solidity ^0.4.19;

/*
Game: MylittleProgram
Dev: WhiteMatrix
*/

library SafeMath {

/**
* @dev Multiplies two numbers, throws on overflow.
*/
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
return c;
}

/**
* @dev Integer division of two numbers, truncating the quotient.
*/
function div(uint256 a, uint256 b) internal pure returns (uint256) {
// assert(b > 0); // Solidity automatically throws when dividing by 0
uint256 c = a / b;
// assert(a == b * c + a % b); // There is no case in which this doesn't hold
return c;
}

/**
* @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
*/
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}

/**
* @dev Adds two numbers, throws on overflow.
*/
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}

contract MylittleProgram {
using SafeMath for uint256;
mapping (address => bool) private admins;
mapping (uint => uint256) public levels;
mapping (uint => bool) private lock;
address contractCreator;
address winnerAddress;
uint256 prize;
function MylittleProgram () public {

contractCreator = msg.sender;
//hint = "7a3829d0d61b43e2e6868025a4cd2fa5324fe4bc9cc7a161a5ad076d11c0b8a7";
admins[contractCreator] = true;
}

struct Pokemon {
string pokemonName;
address ownerAddress;
uint256 currentPrice;
}
Pokemon[] pokemons;

//modifiers
modifier onlyContractCreator() {
require (msg.sender == contractCreator);
_;
}
modifier onlyAdmins() {
require(admins[msg.sender]);
_;
}

//Owners and admins

/* Owner */
function setOwner (address _owner) onlyContractCreator() public {
contractCreator = _owner;
}

function addAdmin (address _admin) public {
admins[_admin] = true;
}

function removeAdmin (address _admin) onlyContractCreator() public {
delete admins[_admin];
}

// Adresses
function setPrizeAddress (address _WinnerAddress) onlyAdmins() public {
winnerAddress = _WinnerAddress;
}

bool isPaused;
/*
When countdowns and events happening, use the checker.
*/
function pauseGame() public onlyContractCreator {
isPaused = true;
}
function unPauseGame() public onlyContractCreator {
isPaused = false;
}
function GetGamestatus() public view returns(bool) {
return(isPaused);
}

function addLock (uint _pokemonId) onlyContractCreator() public {
lock[_pokemonId] = true;
}



function getPokemonLock(uint _pokemonId) public view returns(bool) {
return(lock[_pokemonId]);
}

/*
This function allows users to purchase PokeMon.
The price is automatically multiplied by 1.5 after each purchase.
Users can purchase multiple PokeMon.
*/
function putPrize() public payable {

require(msg.sender != address(0));
prize = prize + msg.value;

}


function withdraw () onlyAdmins() public {

winnerAddress.transfer(prize);

}
function pA() public view returns (address _pA ) {
return winnerAddress;
}

function totalPrize() public view returns (uint256 _totalSupply) {
return prize;
}

}