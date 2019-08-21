contract AmIOnTheFork {
    function forked() constant returns(bool);
}

contract Owned{

    //Address of owner
    address Owner;

    //Add modifier
    modifier OnlyOwner{
        if(msg.sender != Owner){
            throw;
        }
        _
    }

    //Contruction function
    function Owned(){
        Owner = msg.sender;
    }

}

//Ethereum Safely Transfer Contract
//https://github.com/etcrelay/ether-transfer
contract EtherTransfer is Owned{

    //"If you are good at something, never do it for free" - Joker
    //Fee is 0.1% (it's mean you send 1 ETH fee is 0.001 ETH)
    //Notice Fee is not include transaction fee
    uint constant Fee = 1;
    uint constant Decs = 1000;

    bool public IsEthereum = false; 

    //Events log
    event ETHTransfer(address indexed From,address indexed To, uint Value);
    event ETCReturn(address indexed Return, uint Value);

    event ETCTransfer(address indexed From,address indexed To, uint Value);
    event ETHReturn(address indexed Return, uint Value);
    
    //Is Vitalik Buterin on the Fork ? >_<
    AmIOnTheFork IsHeOnTheFork = AmIOnTheFork(0x2bd2326c993dfaef84f696526064ff22eba5b362);

    //Construction function
    function EtherTransfer(){
        IsEthereum = IsHeOnTheFork.forked();
    }

    //Only send ETH
    function SendETH(address ETHAddress) returns(bool){
        uint Value = msg.value - (msg.value*Fee/Decs);
        //It is forked chain ETH
        if(IsEthereum && ETHAddress.send(Value)){
            ETHTransfer(msg.sender, ETHAddress, Value);
            return true;
        }else if(!IsEthereum && msg.sender.send(msg.value)){
            ETCReturn(msg.sender, msg.value);
            return true;
        }
        //No ETC is trapped
        throw;
    }

    //Only send ETC
    function SendETC(address ETCAddress) returns(bool){
        uint Value = msg.value - (msg.value*Fee/Decs);
        //It is non-forked chain ETC
        if(!IsEthereum && ETCAddress.send(Value)){
            ETCTransfer(msg.sender, ETCAddress, Value);
            return true;
        } else if(IsEthereum && msg.sender.send(msg.value)){
            ETHReturn(msg.sender, msg.value);
            return true;
        }
        //No ETH is trapped
        throw;
    }

    //Protect user from ETC/ETH trapped
    function (){
        throw;
    }

    //I get rich lol, ez
    function WithDraw() OnlyOwner returns(bool){
        if(this.balance > 0 && Owner.send(this.balance)){
            return true;
        }
        throw;
    }

}