contract Rental {
    enum ItemState {
        Idle, Busy
    }
    
    struct Item {
        address owner;
        string name;
        string serialNumber;
        ItemState state;
    }
    
    enum RequestState {
        Pending, Canceled, Accepted, Finished
    }
    
    struct Request {
        address client;
        uint itemId;
        uint fee;
        string start;
        string end;
        RequestState state;
    }
    
    Item[] public items;
    Request[] public requests;
    
    function getItemsLength() public constant returns (uint) {
        return items.length;
    }
    
    function getRequestsLength() public constant returns (uint) {
        return requests.length;
    }
    
    function addItem(string _name, string _serialNumber) public returns (uint) {
        Item memory newItem = Item({
          owner: msg.sender,
          name: _name,
          serialNumber: _serialNumber,
          state: ItemState.Idle
        });
        return items.push(newItem) - 1;
    }
    
    function addRequest(uint _itemId, string _start, string _end) public payable returns (uint) {
        Request memory newRequest = Request({
           client: msg.sender,
           itemId: _itemId,
           fee: msg.value,
           start: _start,
           end: _end,
           state: RequestState.Pending
        });
        return requests.push(newRequest) - 1;
    }
    
    function cancelRequest(uint _requestId) public {
        Request storage req = requests[_requestId];
        require(req.client == msg.sender);
        require(req.state == RequestState.Pending);
        req.state = RequestState.Canceled;
        msg.sender.transfer(req.fee);
    }
    
    function acceptRequest(uint _requestId) public {
        Request storage req = requests[_requestId];
        require(req.state == RequestState.Pending);
        Item storage item = items[req.itemId];
        require(item.owner == msg.sender);
        require(item.state == ItemState.Idle);
        item.state = ItemState.Busy;
        req.state = RequestState.Accepted;
        msg.sender.transfer(req.fee);
    }
    
    function acceptReturning(uint _requestId) public {
        Request storage req = requests[_requestId];
        require(req.state == RequestState.Accepted);
        Item storage item = items[req.itemId];
        require(item.owner == msg.sender);
        require(item.state == ItemState.Busy);
        item.state = ItemState.Idle;
        req.state = RequestState.Finished;
    }
}