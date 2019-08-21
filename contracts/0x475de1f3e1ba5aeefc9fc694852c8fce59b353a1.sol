pragma solidity ^0.4.13;

interface EtherShare {
    function NewShare(string nickname, bool AllowUpdated, string content);
}

//Enable user to share information for free (using donation) on Ethereum
contract EtherShareDonation {

    EtherShare ES = EtherShare(0xc86bdf9661c62646194ef29b1b8f5fe226e8c97e);
    
    struct oneDonation {
        address donator;
        string nickname;
        uint amount;
    }
    oneDonation[] public donations;

    function Donate(string nickname) payable public {
        donations.push(oneDonation(msg.sender, nickname, msg.value));	//record the donation
    }

    function FreeShare(string nickname, string content) public {
        uint startGasLeft = gasleft();
        ES.NewShare(nickname, false, content); 
        uint endGasLeft = gasleft();
        msg.sender.send( tx.gasprice*(startGasLeft-endGasLeft+35000) );	//return the fee of NewShare, 35000 gas for other transaction fee.
    }

    //TODO: SenderRecord(), FreeReply(), FreeUpdate()
}