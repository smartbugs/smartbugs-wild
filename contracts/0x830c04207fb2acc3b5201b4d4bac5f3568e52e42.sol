pragma solidity ^0.4.21;

// Donate all your ethers to poorguy 
// Made by EtherGuy (etherguy@mail.com)
// CryptoGaming Discord https://discord.gg/gjrHXFr
// UI @ https://poorguy.surge.sh

contract PoorguyDonation{ 
    address constant public Donated = 0x26581d1983ced8955C170eB4d3222DCd3845a092;
    
    event Quote(address Sent, string Text, uint256 AmtDonate);
 
    string public DonatedBanner = "";
    

    
    function Donate(string quote) public payable {
        require(msg.sender != Donated); // GTFO dont donate to yourself
        
        emit Quote(msg.sender, quote, msg.value);
    }
    
    function Withdraw() public {
        if (msg.sender != Donated){
            emit Quote(msg.sender, "OMG CHEATER ATTEMPTING TO WITHDRAW", 0);
            return;
        }
        address contr = this;
        msg.sender.transfer(contr.balance);
    }   
    
    function DonatorInteract(string text) public {
        require(msg.sender == Donated);
        emit Quote(msg.sender, text, 0);
    }
    
    function DonatorSetBanner(string img) public {
        require(msg.sender == Donated);
        DonatedBanner = img;
    }
    
    function() public payable{
        require(msg.sender != Donated); // Nice cheat but no donating to yourself 
    }
    
}