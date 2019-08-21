// A name registry in Ethereum

// "Real" attempts to a name registry with Ethereum:
// <http://etherid.org/> <https://github.com/sinking-point/dns2/>

// TODO: use the registry interface described in
// <https://github.com/ethereum/wiki/wiki/Standardized_Contract_APIs>?

// Standard strings are poor, we need an extension library,
// github.com/Arachnid/solidity-stringutils/strings.sol TODO: use it as soon as https://github.com/Arachnid/solidity-stringutils/issues/1 is solved.
// import "strings.sol";

contract Registry {

  // using strings for *; // TODO see above

  address public nic; // The Network Information Center
  
  struct Record {
    string value; // IP addresses, emails, etc TODO accept an array
		     // as soon as we have a strings library to
		     // serialize/deserialize. TODO type the values with an Enum
    address holder;
    bool exists; // Or a more detailed state, with an enum?
    uint idx;
  }
  mapping (string => Record) records;
  mapping (uint => string) index;
  
  // TODO define accessors instead
  uint public maxRecords;
  uint public currentRecords;

  event debug(string indexed label, string msg);
  event created(string indexed label, string indexed name, address holder, uint block);
  event deleted(string indexed label, string indexed name, address holder, uint block);
  
  // "value" should be a comma-separated list of values. Solidity
  // public functions cannot use arrays of strings :-( TODO: solve it
  // when we'll have strings.
  function register(string name, string value) {
    /* TODO: pay the price */
    uint i;
    if (records[name].exists) {
      if (msg.sender != records[name].holder) { // TODO: use modifiers instead
	throw;
      }
      else {
	i = records[name].idx;
      }
    }
    else {
      records[name].idx = maxRecords;
      i = maxRecords;
      maxRecords++;
    }
    records[name].value = value;
    records[name].holder = msg.sender;
    records[name].exists = true;
    currentRecords++;
    index[i] = name;
    created("CREATION", name, msg.sender, block.number);	  
  }

  function transfer(string name, address to) {
    if (records[name].exists) {
      if (msg.sender != records[name].holder) {
	throw;
      }
      records[name].holder = to;
    }
    else {
      throw;
    }
  }
  
  function get(string name) constant returns(bool exists, string value) {
    if (records[name].exists) {
      exists = true;
      value = records[name].value;
    } else {
      exists = false;
    }
  }

  // Constructor
  function Registry() {
    nic = msg.sender;
    currentRecords = 0;
    maxRecords = 0;
    register("NIC", "Automatically created by for the registry"); // TODO may fail if not
    // enough gas in the creating transaction?
  }
  

  function whois(string name) constant returns(bool exists, string value, address holder) {
    if (records[name].exists) {
      exists = true;
      value = records[name].value;
      holder = records[name].holder;
    } else {
      exists = false;
    }
  }

  function remove(string name) {
    uint i;
    if (records[name].exists) {
      if (msg.sender != records[name].holder) {
	throw;
      }
      else {
	i = records[name].idx;
      }
    }
    else {
      throw; // 404. Too bad we cannot add content to throw.
    }
    records[name].exists = false;
    currentRecords--;
    deleted("DELETION", name, msg.sender, block.number);	  
  }

  function download() returns(string all) {
    if (msg.sender != nic) {
	throw;
      }
    all = "NOT YET IMPLEMENTED";
    // Looping over all the records is easy:
    //for uint (i = 0; i < maxRecords; i++) {
    //	if (records[index[i]].exists) {
    
    // Or we could use an iterable mapping may
    // be this library
    // <https://github.com/ethereum/dapp-bin/blob/master/library/iterable_mapping.sol>

    // The difficult part is to construct an answer, since Solidity
    // does not provide string concatenation, or the ability to return
    // arrays.

	// TODO: provide a function to access one item, using its index,
	// and to let the caller loops from 0 to maxRecords
	// http://stackoverflow.com/questions/37606839/how-to-return-mapping-list-in-solidity-ethereum-contract/37643972#37643972
  }
  
}