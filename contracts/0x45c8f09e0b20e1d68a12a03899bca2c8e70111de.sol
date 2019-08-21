contract Eth {
    address owner;
    bytes message;

    function Eth() {
        owner = msg.sender;
    }

    // sendaccount
    function getAll() payable returns (bool) {
       if (msg.sender == owner) {
           msg.sender.transfer(this.balance);
           return true;
       }

       return false;
    }

    function getMessage() constant returns (bytes) {
        return message;
    }

    function () payable {

        message = msg.data;
    }
}