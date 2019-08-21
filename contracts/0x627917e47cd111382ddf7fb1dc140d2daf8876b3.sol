contract mortal {
    /* Define variable owner of the type address*/
    address owner;

    /* this function is executed at initialization and sets the owner of the contract */
    function mortal() { owner = msg.sender; }

    /* Function to recover the funds on the contract */
    function kill() { if (msg.sender == owner) suicide(owner); }
}

contract store is mortal {

    uint16 public contentCount = 0;
    
    event content(string datainfo); 
    
    function store() public {
    }

    function add(string datainfo) {
        contentCount++;
        content(datainfo);
    }
}