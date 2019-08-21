pragma solidity ^0.4.24;

contract Moods{

address public owner;
string public currentMood;
mapping(string => bool) possibleMoods;
string[] public listMoods;

constructor() public{
    owner = msg.sender;
    possibleMoods['?'] = true;
    possibleMoods['?'] = true;
    possibleMoods['?'] = true;
    listMoods.push('?');
    listMoods.push('?');
    listMoods.push('?');
    currentMood = '?';
}

event moodChanged(address _sender, string _moodChange);
event moodAdded( string _newMood);

function changeMood(string _mood) public payable{
    
    require(possibleMoods[_mood] == true);
    
    currentMood = _mood;
    
    emit moodChanged(msg.sender, _mood);
}

function addMood(string newMood) public{
    
    require(msg.sender == owner);
    
    possibleMoods[newMood] = true;
    listMoods.push(newMood);
    
    emit moodAdded(newMood);
}

function numberOfMoods() public view returns(uint256){
    return(listMoods.length);
}

function withdraw() public {
    require (msg.sender == owner);
    msg.sender.transfer(address(this).balance);
}

function() public payable {}

}