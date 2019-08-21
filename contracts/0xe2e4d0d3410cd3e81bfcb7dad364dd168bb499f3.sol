/* A contract to store a state of goods (single item). Buy orders obtainable as events. */

/* Deployment:
*/

contract goods {

    address public owner;
    //status of the goods: Available, Pending, Sold, Canceled
    uint16 public status;
    //how many for sale
    uint16 public count;
    //price per item
    uint public price;

    uint16 public availableCount;
    uint16 public pendingCount;

    event log_event(string message);
    event content(string datainfo, uint indexed version, uint indexed datatype, address indexed sender, uint count, uint payment);
    modifier onlyowner { if (msg.sender == owner) _ } 
    
    function goods(uint16 _count, uint _price) {
        owner = msg.sender;
        //status = Available
        status = 1;
        count = _count;
        price = _price;

        availableCount = count;
        pendingCount = 0;
    }
    
    function kill() onlyowner { suicide(owner); }

    function flush() onlyowner {
        owner.send(this.balance);
    }

    function log(string message) private {
        log_event(message);
    }

    function buy(string datainfo, uint _version, uint16 _count) {
        if(status != 1) { log("status != 1"); throw; }
        if(msg.value < (price * _count)) { log("msg.value < (price * _count)"); throw; }
        if(_count > availableCount) { log("_count > availableCount"); throw; }

        pendingCount += _count;

        //Buy order to event log
        content(datainfo, _version, 1, msg.sender, _count, msg.value);
    }

    function accept(string datainfo, uint _version, uint16 _count) onlyowner {
        if(_count > availableCount) { log("_count > availableCount"); return; }
        if(_count > pendingCount) { log("_count > pendingCount"); return; }
        
        pendingCount -= _count;
        availableCount -= _count;

        //Accept order to event log
        content(datainfo, _version, 2, msg.sender, _count, 0);
    }

    function reject(string datainfo, uint _version, uint16 _count, address recipient, uint amount) onlyowner {
        if(_count > pendingCount) { log("_count > pendingCount"); return; }

        pendingCount -= _count;
        //send money back
        recipient.send(amount);

        //Reject order to event log
        content(datainfo, _version, 3, msg.sender, _count, amount);
    }

    function cancel(string datainfo, uint _version) onlyowner {
        //Canceled status
        status = 2;

        //Cancel order to event log
        content(datainfo, _version, 4, msg.sender, availableCount, 0);
    }
}