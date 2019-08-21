// A life-log, done for Charlyn Greeff, born 18 April 2016 @ 15h30 (1460993400)
//    Mother: Mirana Hotz, 16 December 1977 (251078400)
//    Father: Jaco Greeff, 11 June 1973 (108604800)
//
// version: 1.0.0
// source: https://github.com/jacogr/ethcontracts/tree/master/src/LifeLog

contract CharlyLifeLog {
  // allow a maximum 20% withdrawal at any time
  uint private constant MAX_WITHDRAW_DIV = 5; // 100/20

  // allow one withdrawal every 6 months/180 days
  uint private constant WITHDRAW_INTERVAL = 180 days;

  // all the actual events that can be created
  event LogDonation(address indexed by, uint loggedAt, uint amount);
  event LogWithdrawal(address indexed by, uint loggedAt, uint amount);
  event LogPersonNew(address indexed by, uint loggedAt, uint index);
  event LogPersonUpdate(address indexed by, uint loggedAt, uint index, string field);
  event LogWhitelistAdd(address indexed by, uint loggedAt, address addr);
  event LogWhitelistRemove(address indexed by, uint loggedAt);
  event LogEvent(address indexed by, uint loggedAt, uint when, string description);

  // a structure describing a person
  struct Person {
    bool active;
    uint activatedAt;
    uint deactivatedAt;
    int dateOfBirth;
    int dateOfDeath;
    string name;
    string relation;
  }

  // next time whitelist address is allowed to get some funds
  uint public nextWithdrawal = now + WITHDRAW_INTERVAL;

  // totals of received and withdrawn amounts
  uint public totalDonated = 0;
  uint public totalWithdrawn = 0;

  // people in the life of ([0] == 'self')
  Person[] public people;

  // donations received
  mapping(address => uint) public donations;

  // whitelisted modifier accounts
  mapping(address => bool) public whitelist;

  // modifier to allow only the whitelisted addresses
  modifier isOnWhitelist {
    // if not in the whitelist, throw error
    if (!whitelist[msg.sender]) {
      throw;
    }

    // if any value attached, don't accept it
    if (msg.value > 0) {
      throw;
    }

    // original code executes in here
    _
  }

  // construct a lifelog for this specific person
  function CharlyLifeLog(string name, int dateOfBirth) {
    // creator should go on the whitelist
    whitelist[msg.sender] = true;

    // add the first person
    personAdd(name, dateOfBirth, 0, 'self');

    // any donations?
    if (msg.value > 0) {
      donate();
    }
  }

  // log an event
  function log(string description, uint _when) public isOnWhitelist {
    // infer timestamp or use specified
    uint when = _when;
    if (when == 0) {
      when = now;
    }

    // create the event
    LogEvent(msg.sender, now, when, description);
  }

  // add a specific person
  function personAdd(string name, int dateOfBirth, int dateOfDeath, string relation) public isOnWhitelist {
    // create the event
    LogPersonNew(msg.sender, now, people.length);

    // add the person
    people.push(
      Person({
        active: true,
        activatedAt: now,
        deactivatedAt: 0,
        dateOfBirth: dateOfBirth,
        dateOfDeath: dateOfDeath,
        name: name,
        relation: relation
      })
    );
  }

  // activate/deactivate a specific person
  function personUpdateActivity(uint index, bool active) public isOnWhitelist {
    // set the flag
    people[index].active = active;

    // activate/deactivate
    if (active) {
      // create the event
      LogPersonUpdate(msg.sender, now, index, 'active');

      // make it so
      people[index].activatedAt = now;
      people[index].deactivatedAt = 0;
    } else {
      // create the event
      LogPersonUpdate(msg.sender, now, index, 'inactive');

      // make it so
      people[index].deactivatedAt = now;
    }
  }

  // update a person's name
  function personUpdateName(uint index, string name) public isOnWhitelist {
    // create the event
    LogPersonUpdate(msg.sender, now, index, 'name');

    // update
    people[index].name = name;
  }

  // update a person's relation
  function personUpdateRelation(uint index, string relation) public isOnWhitelist {
    // create the event
    LogPersonUpdate(msg.sender, now, index, 'relation');

    // update
    people[index].relation = relation;
  }

  // update a person's DOB
  function personUpdateDOB(uint index, int dateOfBirth) public isOnWhitelist {
    // create the event
    LogPersonUpdate(msg.sender, now, index, 'dateOfBirth');

    // update
    people[index].dateOfBirth = dateOfBirth;
  }

  // update a person's DOD
  function personUpdateDOD(uint index, int dateOfDeath) public isOnWhitelist {
    // create the event
    LogPersonUpdate(msg.sender, now, index, 'dateOfDeath');

    // update
    people[index].dateOfDeath = dateOfDeath;
  }

  // add a whitelist address
  function whitelistAdd(address addr) public isOnWhitelist {
    // create the event
    LogWhitelistAdd(msg.sender, now, addr);

    // update
    whitelist[addr] = true;
  }

  // remove a whitelist address
  function whitelistRemove(address addr) public isOnWhitelist {
    // we can only remove ourselves, double-validate failsafe
    if (msg.sender != addr) {
      throw;
    }

    // create the event
    LogWhitelistRemove(msg.sender, now);

    // remove
    whitelist[msg.sender] = false;
  }

  // withdraw funds as/when needed
  function withdraw(uint amount) public isOnWhitelist {
    // the maximum we are allowed to take out right now
    uint max = this.balance / MAX_WITHDRAW_DIV;

    // see that we are in range and the timing matches
    if (amount > max || now < nextWithdrawal) {
      throw;
    }

    // update the event log with the action
    LogWithdrawal(msg.sender, now, amount);

    // set the next withdrawal date/time & totals
    nextWithdrawal = now + WITHDRAW_INTERVAL;
    totalWithdrawn += amount;

    // send and throw if not ok
    if (!msg.sender.send(amount)) {
      throw;
    }
  }

  // accept donations from anywhere and give credit
  function donate() public {
    // there needs to be something here
    if (msg.value == 0) {
      throw;
    }

    // update the event log with the action
    LogDonation(msg.sender, now, msg.value);

    // store the donation
    donations[msg.sender] += msg.value;
    totalDonated += msg.value;
  }

  // fallback is a donation
  function() public {
    donate();
  }
}