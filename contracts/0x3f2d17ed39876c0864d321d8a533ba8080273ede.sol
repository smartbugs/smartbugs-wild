contract NoxonFund {

    address public owner;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply; //18160ddd for rpc call https://api.etherscan.io/api?module=proxy&data=0x18160ddd&to=0xContractAdress&apikey={eserscan api}&action=eth_call
    uint256 public Entropy;
    uint256 public ownbalance; //d9c7041b

	uint256 public sellPrice; //4b750334
    uint256 public buyPrice; //8620410b
    
    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    
    
    /* Initializes cont ract with initial supply tokens to the creator of the contract */
    function token()  {
    
        if (owner!=0) throw;
        buyPrice = msg.value;
        balanceOf[msg.sender] = 1;    // Give the creator all initial tokens
        totalSupply = 1;              // Update total supply
        Entropy = 1;
        name = 'noxonfund.com';       // Set the name for display purposes
        symbol = '? SHARE';             // Set the symbol for display purposes
        decimals = 0;                 // Amount of decimals for display purposes
        owner = msg.sender;
        setPrices();
    }
    

    
     /* Send shares function */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;    
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }
	

    function setPrices() {
        ownbalance = this.balance; //own contract balance
        sellPrice = ownbalance/totalSupply;
        buyPrice = sellPrice*2; 
    }
    
    
   function () returns (uint buyreturn) {
       
        uint256 amount = msg.value / buyPrice;                // calculates the amount
        balanceOf[msg.sender] += amount;                   // adds the amount to buyer's balance
       
        totalSupply += amount;
        Entropy += amount;
        
        Transfer(0, msg.sender, amount);
        
        owner.send(msg.value/2);
        //set next price
        setPrices();
        return buyPrice;
   }
   

    
    function sell(uint256 amount) {
        setPrices();
        if (balanceOf[msg.sender] < amount ) throw;        // checks if the sender has enough to sell
        Transfer(msg.sender, this, amount);                 //return shares to contract
        totalSupply -= amount;
        balanceOf[msg.sender] -= amount;                   // subtracts the amount from seller's balance
        msg.sender.send(amount * sellPrice);               // sends ether to the seller
        setPrices();

    }
	
	//All incomse will send using newIncome method
	event newincomelog(uint amount,string description);
	function newIncome(
        string JobDescription
    )
        returns (string result)
    {
        if (msg.value <= 1 ether/100) throw;
        newincomelog(msg.value,JobDescription);
        return JobDescription;
    }
    
    
    
    //some democracy
    
    uint votecount;
    uint voteno; 
    uint voteyes;
    
    mapping (address => uint256) public voters;
    
    function newProposal(
        string JobDescription
    )
        returns (string result)
    {
        if (msg.sender == owner) {
            votecount = 0;
            newProposallog(JobDescription);
            return "ok";
        } else {
            return "Only admin can do this";
        }
    }
    

    
    
    function ivote(bool myposition) returns (uint result) {
        votecount += balanceOf[msg.sender];
        
        if (voters[msg.sender]>0) throw;
        voters[msg.sender]++;
        votelog(myposition,msg.sender,balanceOf[msg.sender]);
        return votecount;
    }

    
    event newProposallog(string description);
    event votelog(bool position, address voter, uint sharesonhand);
   
    
}