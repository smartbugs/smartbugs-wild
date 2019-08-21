pragma solidity ^0.4.4;

//copyright 2017 NewAlchemy
//Written by Dennis Peterson

contract AbstractSweeper {
    //abstract:
    function sweep(address token, uint amount) returns (bool);

    //concrete:
    function () { throw; }

    Controller controller;

    function AbstractSweeper(address _controller) {
        controller = Controller(_controller);
    }

    modifier canSweep() {
        if (msg.sender != controller.authorizedCaller() && msg.sender != controller.owner()) throw;
        if (controller.halted()) throw;
        _;
    }
}

contract Token {
    function balanceOf(address a) returns (uint) {return 0;}
    function transfer(address a, uint val) returns (bool) {return false;}
}

contract DefaultSweeper is AbstractSweeper {
    function DefaultSweeper(address controller) 
             AbstractSweeper(controller) {}

    function sweep(address _token, uint _amount)  
    canSweep
    returns (bool) {
        Token token = Token(_token);
        uint amount = _amount;
        if (amount > token.balanceOf(this)) amount = token.balanceOf(this);

        address destination = controller.destination();

	// Because sweep is called with delegatecall, this typically
	// comes from the UserWallet.
        bool success = token.transfer(destination, amount); 
        if (success) { 
            controller.logSweep(this, _token, _amount);
        } else { 
	    controller.logFailedSweep(msg.sender, _token, _amount);
	}
        return success;
    }
}

contract UserWallet {
    AbstractSweeperList c;
    function UserWallet(address _sweeperlist) {
        c = AbstractSweeperList(_sweeperlist);
    }

    function sweep(address _token, uint _amount) 
    returns (bool) {
        return c.sweeperOf(_token).delegatecall(msg.data);
    }
}

contract AbstractSweeperList {
    function sweeperOf(address _token) returns (address);
}

contract Controller is AbstractSweeperList {
    address public owner;
    address public authorizedCaller;

    //destination defaults to same as owner
    //but is separate to allow never exposing cold storage
    address public destination; 

    bool public halted;

    event LogNewWallet(uint _customer, address receiver);
    event LogSweep(address from, address token, uint amount);
    event LogFailedSweep(address from, address token, uint amount);
    
    modifier onlyOwner() {
        if (msg.sender != owner) throw; 
        _;
    }

    modifier onlyAuthorizedCaller() {
        if (msg.sender != authorizedCaller) throw; 
        _;
    }

    modifier onlyAdmins() {
        if (msg.sender != authorizedCaller && msg.sender != owner) throw; 
        _;
    }

    function Controller() 
    {
        owner = msg.sender;
        destination = msg.sender;
        authorizedCaller = msg.sender;
    }

    function changeAuthorizedCaller(address _newCaller) onlyOwner {
        authorizedCaller = _newCaller;
    }

    function changeDestination(address _dest) onlyOwner {
        destination = _dest;
    }

    function changeOwner(address _owner) onlyOwner {
        owner = _owner;
    }

    function makeWallet(uint _customer) onlyAdmins returns (address wallet)  {
        wallet = address(new UserWallet(this));
        LogNewWallet(_customer, wallet);
    }

    //assuming halt because caller is compromised
    //so let caller stop for speed, only owner can restart

    function halt() onlyAdmins {
        halted = true;
    }

    function start() onlyOwner {
        halted = false;
    }

    //***********
    //SweeperList
    //***********
    address public defaultSweeper = address(new DefaultSweeper(this));
    mapping (address => address) sweepers;

    function addSweeper(address _token, address _sweeper) onlyOwner {
        sweepers[_token] = _sweeper;
    }

    function sweeperOf(address _token) returns (address) {
        address sweeper = sweepers[_token];
        if (sweeper == 0) sweeper = defaultSweeper;
        return sweeper;
    }

    function logSweep(address from, address token, uint amount) {
        LogSweep(from, token, amount);
    }
    function logFailedSweep(address from, address token, uint amount) {
        LogFailedSweep(from, token, amount);
    }
}