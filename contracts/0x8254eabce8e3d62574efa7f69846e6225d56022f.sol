contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender != owner) {
      throw;
    }
    _;
  }

}

///This is the blockchain side of the notifier. Here so that payment, registering,etc is painless async and
/// most importantly *trustless* since you can exit at any time taking your funds having lost nothing

///@author kingcocomango@gmail.com
///@title Price notifier
contract Tracker is Ownable{
    // This represents a client in the simplest form
    // Only tracks a single currency pair, hardcoded
    struct SimpleClient{
        uint8 ratio;// ratio trigger
        uint dosh;// Clients dosh
        string Hash;// phone number as a utf-8 string, or a hash of one from webservice
        uint time;// last time client was debited. Starts as creation time
    }
    
    // This is the mapping between eth addr and client structs
    mapping(address => SimpleClient) public Clients;
    // This is used to store the current total obligations to clients
    uint public obligations;
    
    // Events for clients registering and leaving
    // This means recognizing the set of current clients, for sending and debiting can be done off-chain
    event ClientRegistered(address Client);
    event ClientExited(address Client);
    
    // Constants used for configuration
    uint constant Period = 1 days; // amount of time between debits ERROR set these values for release
    uint constant Fee = 0.4 finney; // amount debited per period
    uint8 constant MininumPercent = 3; // this is the minimum ratio allowed. TODO set to 5 for sms contract

    
    // This function registers a new client, and can be used to add funds or change ratio
    function Register(uint8 ratio, string Hash) payable external {
        var NewClient = SimpleClient(ratio>=MininumPercent?ratio:MininumPercent, msg.value, Hash, now); // create new client
        // note that ratio is not allowed to be smaller than MininumPercent%
        // In case someone registers over themselves, keep their money around
        NewClient.dosh += Clients[msg.sender].dosh; // keep their old account running
        Clients[msg.sender] = NewClient; // register them
        // notify the listners
        ClientRegistered(msg.sender);
        // and increment current total obligations
        obligations += msg.value;
        
    }
    // This function is used to stop using the service
    function Exit() external {
        uint tosend = Clients[msg.sender].dosh;
        // And remove the money they withdrew from our obligations
        obligations -= tosend;
        // if the sending fails, all of this unwinds.
        Clients[msg.sender].dosh= 0; // we set it here to its safe to send money
        // Notify listners client has left
        ClientExited(msg.sender);
        // send to the caller the money their structure says they have
        msg.sender.transfer(tosend);
        
    }
    // This function is used to change the phone number in the service
    function ChangeNumber(string NewHash) external { // The way this modifies state is invisible to the contract,so no problemo
        Clients[msg.sender].Hash = NewHash;
        ClientExited(msg.sender);
        ClientRegistered(msg.sender); // This cheap sequence of events changes the number, and notifies the backend service
    }
    // Used to charge a client
    function DebitClient(address client) external{// since owner is provable an EOC, cant abuse reentrancy
        uint TotalFee;
        uint timedif = now-Clients[client].time; // how long since last call on this client
        uint periodmulti = timedif/Period; // How many periods passed
        if(periodmulti>0){ // timedif is >= Period
          TotalFee = Fee*periodmulti; // 1 period fee per multiple of period
        }else{// it was smaller than period. Wasted gas
          throw;
        }
        if(Clients[client].dosh < TotalFee){ // not enough
          throw;
        }
        Clients[client].dosh -= TotalFee;
        obligations -= TotalFee;
        Clients[client].time += Period*periodmulti; // client got charged for periodmulti periods, so add that to their time paid
    }
    // used to charge for a single time period, in case client doesnt have enough dosh to pay all fees 
    function DebitClientOnce(address client) external{// since owner is provable an EOC, cant abuse reentrancy
        uint timedif = now-Clients[client].time; // how long since last call on this client
        if(timedif<Period){ // too soon, wasted.
          throw;
        }
        if(Clients[client].dosh < Fee){ // not enough
          throw;
        }
        Clients[client].dosh -= Fee;
        obligations -= Fee;
        Clients[client].time += Period; // client got charged for 1 period, so add that to their time paid
    }
    
    // This function is used to withdraw ether
    function Withdraw(uint amount) onlyOwner external{ // since owner is provable an EOC, cant abuse reentrancy
        if(this.balance <= obligations){ // this should probably be removed from production code. But theoretically it can never happen
            throw; // Somehow, we cant even cover our obligations. This means something very wrong has happened
            selfdestruct(owner);// This should be impossible, but it means I can manually reimburse if SHTF
        }
        if((this.balance - obligations) <= amount ){// available balance doesnt cover withdrawal
            throw; // not allowed
        }
        owner.transfer(amount);// All checks passed, take the money
    }
}