pragma solidity ^0.4.0;

contract HelpYouHateEth{
    address me;
    hate max_hate;
    
    struct hate{
        address you;
        uint256 how_much_you_hate;
        string your_words;
    }
   
    constructor() public {
        me = msg.sender;
    }
    
    function sayYouHateEth(string words) public payable {
        if (msg.value > max_hate.how_much_you_hate){
            hate memory your_hate;
            your_hate.you = msg.sender;
            your_hate.how_much_you_hate = msg.value;
            your_hate.your_words = words;
        
            max_hate = your_hate;
        }
    }
    
    function listen() public {
        if (msg.sender == me) {
            address(me).transfer(address(this).balance);
        }
    }
    
    function whoHateMost() constant public returns (address, uint256, string){
        return (max_hate.you,max_hate.how_much_you_hate,max_hate.your_words);
    }
    
    function () public payable {
    }
}