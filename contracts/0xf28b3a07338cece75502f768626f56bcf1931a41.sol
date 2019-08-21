pragma solidity ^0.4.23;

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
contract DarkLord {

using SafeMath for uint256;
event NewZombie(uint zombieId, string name, uint dna);

mapping(address => uint) playerExp;
mapping (address => bool) private inwitness;
address[] public winnerAdd;

modifier onlyWit() {
require(inwitness[msg.sender]);
_;
}

struct Battlelog {
uint id1;
uint id2;
uint result;
address witness;
}

Battlelog[] battleresults;


struct BMBattlelog {
uint id1;
uint id2;
uint id3;
uint id4;
uint result;
address witness;
}

BMBattlelog[] bmbattleresults;


function _addWit (address _inwitness) private {
inwitness[_inwitness] = true;
}

function _delWit (address _inwitness) private {
delete inwitness[_inwitness];
}

function initialWittness() public {
_addWit(msg.sender);

}

function clearwit(address _inwitness) public{
if(_inwitness==msg.sender){
delete inwitness[_inwitness];
}
}

function initialCard(uint total) public view returns(uint i) {

i = uint256(sha256(abi.encodePacked(block.timestamp, block.number-i-1))) % total +1;

}

function initialBattle(uint id1,uint total1,uint id2,uint total2) onlyWit() public returns (uint wid){
uint darklord;
if(total1.mul(2)>5000){
darklord=total1.mul(2);
}else{
darklord=5000;
}

uint256 threshold = dataCalc(total1.add(total2),darklord);

uint256 i = uint256(sha256(abi.encodePacked(block.timestamp, block.number-i-1))) % 100 +1;
if(i <= threshold){
wid = 0;
winnerAdd.push(msg.sender);
}else{
wid = 1;
}
battleresults.push(Battlelog(id1,id2,wid,msg.sender));
_delWit(msg.sender);
}


function initialBM(uint id1,uint total1,uint id2,uint total2,uint id3,uint total3,uint id4,uint total4) onlyWit() public returns (uint wid){
uint teamETH;
uint teamTron;
teamETH=total1+total2;
teamTron=total3+total4;

uint256 threshold = dataCalc(teamETH,teamTron);

uint256 i = uint256(sha256(abi.encodePacked(block.timestamp, block.number-i-1))) % 100 +1;
if(i <= threshold){
wid = 0;
winnerAdd.push(msg.sender);
}else{
wid = 1;
}
bmbattleresults.push(BMBattlelog(id1,id2,id3,id4,wid,msg.sender));
_delWit(msg.sender);
}

function dataCalc(uint _total1, uint _total2) public pure returns (uint256 _threshold){

// We can just leave the other fields blank:

uint256 threshold = _total1.mul(100).div(_total1+_total2);

if(threshold > 90){
threshold = 90;
}
if(threshold < 10){
threshold = 10;
}

return threshold;

}

function getBattleDetails(uint _battleId) public view returns (
uint _id1,
uint _id2,
uint256 _result,
address _witadd
) {
Battlelog storage _battle = battleresults[_battleId];

_id1 = _battle.id1;
_id2 = _battle.id2;
_result = _battle.result;
_witadd = _battle.witness;
}

function getBMBattleDetails(uint _battleId) public view returns (
uint _id1,
uint _id2,
uint _id3,
uint _id4,
uint256 _result,
address _witadd
) {
BMBattlelog storage _battle = bmbattleresults[_battleId];

_id1 = _battle.id1;
_id2 = _battle.id2;
_id3 = _battle.id3;
_id4 = _battle.id4;
_result = _battle.result;
_witadd = _battle.witness;
}


function totalSupply() public view returns (uint256 _totalSupply) {
return battleresults.length;
}

function totalBmSupply() public view returns (uint256 _totalSupply) {
return bmbattleresults.length;
}


}