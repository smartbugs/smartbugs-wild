pragma solidity 0.4.19;


contract Ownable {
address public owner;


event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


/**
* @dev The Ownable constructor sets the original `owner` of the contract to the sender
* account.
*/
function Ownable() public {
owner = msg.sender;
}


/**
* @dev Throws if called by any account other than the owner.
*/
modifier onlyOwner() {
require(msg.sender == owner);
_;
}


/**
* @dev Allows the current owner to transfer control of the contract to a newOwner.
* @param newOwner The address to transfer ownership to.
*/
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}

}

/**
* @title Pausable
* @dev Base contract which allows children to implement an emergency stop mechanism.
*/
contract Pausable is Ownable {
event Pause();
event Unpause();

bool public paused = false;


/**
* @dev Modifier to make a function callable only when the contract is not paused.
*/
modifier whenNotPaused() {
require(!paused);
_;
}

/**
* @dev Modifier to make a function callable only when the contract is paused.
*/
modifier whenPaused() {
require(paused);
_;
}

/**
* @dev called by the owner to pause, triggers stopped state
*/
function pause() onlyOwner whenNotPaused public {
paused = true;
Pause();
}

/**
* @dev called by the owner to unpause, returns to normal state
*/
function unpause() onlyOwner whenPaused public {
paused = false;
Unpause();
}
}


contract BetContract is Pausable{

//This contract is owned and desgined by etherbets.io

//Our contract has only 5 transfer function calls,
//the first two are used to return all bets without collecting a fee
//in case something goes wrong.
//The next two are used to pay to the A team or B team respectively and after everything is payed,
//the left over balance (fee) is sent in the last transfer function call.

//Its also important to note that we have to other contracts that are used to receive funds
//and send them directly to the main contract to the correct team, the main contract owns this two other contracts.
//This was made to make it easier to place bets.



uint minAmount;
uint feePercentage;
uint AteamAmount = 0;
uint BteamAmount = 0;

address Acontract;
address Bcontract;
address fundCollection;
uint public transperrun;

team[] public AteamBets;
team[] public BteamBets;

struct team{
address betOwner;
uint amount;
uint date;


}



function BetContract() public {

minAmount = 0.02 ether;
feePercentage = 9500;

fundCollection = owner;
transperrun = 25;
Acontract = new BetA(this,minAmount,"A");
Bcontract = new BetB(this,minAmount,"B");

}



function changeFundCollection(address _newFundCollection) public onlyOwner{
fundCollection = _newFundCollection;
}

function contractBalance () public view returns(uint balance){

return this.balance;

}


function contractFeeMinAmount () public view returns (uint _feePercentage, uint _minAmount){
return (feePercentage, minAmount);
}

function betALenght() public view returns(uint lengthA){
return AteamBets.length;
}

function betBLenght() public view returns(uint lengthB){
return BteamBets.length;
}

function teamAmounts() public view returns(uint A,uint B){
return(AteamAmount,BteamAmount);
}
function BetAnB() public view returns(address A, address B){
return (Acontract,Bcontract);
}

function setTransperRun(uint _transperrun) public onlyOwner{
transperrun = _transperrun;
}

function cancelBet() public onlyOwner returns(uint _balance){
require(this.balance > 0);
//uint i;
team memory tempteam;
uint p;


if (AteamBets.length < transperrun)
p = AteamBets.length;
else
p = transperrun;

//i = 0;
while (p > 0){

tempteam = AteamBets[p-1];
AteamBets[p-1] = AteamBets[AteamBets.length -1];
delete AteamBets[AteamBets.length - 1 ];
AteamBets.length --;
p --;
//i ++;
AteamAmount = AteamAmount - tempteam.amount;
//****************TRANSFER***************
tempteam.betOwner.transfer(tempteam.amount);
tempteam.amount = 0;


}

if (BteamBets.length < transperrun)
p = BteamBets.length;
else
p = transperrun;
//i= 0;
while (p > 0){

tempteam = BteamBets[p-1];
BteamBets[p-1] = BteamBets[BteamBets.length - 1];
delete BteamBets[BteamBets.length - 1];
BteamBets.length --;
p--;
//i++;
BteamAmount = BteamAmount - tempteam.amount;
//****************TRANSFER***************
tempteam.betOwner.transfer(tempteam.amount);
tempteam.amount = 0;


}


return this.balance;



}

function result(uint _team) public onlyOwner returns (uint _balance){
require(this.balance > 0);
require(checkTeamValue(_team));

//uint i;
uint transferAmount = 0;
team memory tempteam;
uint p;

if(_team == 1){



if (AteamBets.length < transperrun)
p = AteamBets.length;
else
p = transperrun;

//i = 0;
while (p > 0){
transferAmount = AteamBets[p-1].amount + (AteamBets[p-1].amount * BteamAmount / AteamAmount);
tempteam = AteamBets[p-1];

AteamBets[p-1] = AteamBets[AteamBets.length -1];
delete AteamBets[AteamBets.length - 1 ];
AteamBets.length --;
p --;
//i++;

//AteamAmount = AteamAmount - tempteam.amount;

//****************TRANSFER***************
tempteam.betOwner.transfer(transferAmount * feePercentage/10000);
tempteam.amount = 0;
transferAmount = 0;

}


}else{

if (BteamBets.length < transperrun)
p = BteamBets.length;
else
p = transperrun;
//i = 0;
while (p > 0){
transferAmount = BteamBets[p-1].amount + (BteamBets[p-1].amount * AteamAmount / BteamAmount);
tempteam = BteamBets[p-1];
BteamBets[p-1] = BteamBets[BteamBets.length - 1];
delete BteamBets[BteamBets.length - 1];
BteamBets.length --;
p--;
//i++;
//BteamAmount = BteamAmount - tempteam.amount;
//****************TRANSFER***************
tempteam.betOwner.transfer(transferAmount * feePercentage/10000);
tempteam.amount = 0;
transferAmount = 0;

}


}



//****************TRANSFER***************
if (AteamBets.length == 0 || BteamBets.length == 0){
fundCollection.transfer(this.balance);
}

if(this.balance == 0){
delete AteamBets;
delete BteamBets;
AteamAmount = 0;
BteamAmount = 0;
}
return this.balance;



}

function checkTeamValue(uint _team) private pure returns (bool ct){
bool correctteam = false;
if (_team == 1){
correctteam = true;
}else{
if (_team == 2){
correctteam = true;
}
}
return correctteam;
}


function bet(uint _team,address _betOwner) payable public returns (bool success){
require(paused == false);
require(msg.value >= minAmount);


require(checkTeamValue(_team));

bool _success = false;


uint finalBetAmount = msg.value;

if (_team == 1){
AteamBets.push(team(_betOwner,finalBetAmount,now));
AteamAmount = AteamAmount + finalBetAmount;
_success = true;
}

if(_team == 2){
BteamBets.push(team(_betOwner,finalBetAmount,now));
BteamAmount = BteamAmount + finalBetAmount;
_success = true;
}

return _success;

}
}
contract TeamBet{
uint minAmount;

string teamName;


BetContract ownerContract;

function showTeam() public view returns(string team){
return teamName;
}

function showOwnerContract() public view returns(address _ownerContract) {

return ownerContract;
}


}
contract BetA is TeamBet{

function BetA(BetContract _BetContract,uint _minAmount, string _teamName) public{

ownerContract = _BetContract;
minAmount = _minAmount;
teamName = _teamName;
}


function() public payable {
//****************TRANSFER TO MAIN CONTRACT***************
require(ownerContract.bet.value(msg.value)(1,msg.sender));

}

}

contract BetB is TeamBet{

function BetB(BetContract _BetContract,uint _minAmount, string _teamName) public{

ownerContract = _BetContract;
minAmount = _minAmount;
teamName = _teamName;
}

function() public payable {
//****************TRANSFER TO MAIN CONTRACT***************
require(ownerContract.bet.value(msg.value)(2,msg.sender));

}
}