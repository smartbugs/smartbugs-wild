contract SmartVerifying{
    function SmartVerifying(){

    }

    function() payable
    {
        if(msg.sender.send(msg.value)==false) throw;
    }
}