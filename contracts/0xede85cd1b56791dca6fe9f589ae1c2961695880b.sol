/*
Binks Bucks Solidity Code:
Created for Doug Polk
Authored by Chris Digirolamo
**/
pragma solidity ^0.4.18;

contract BinksBucksToken {
    /*
    This class implements the ERC20 Functionality for Binks Bucks
    along with other standard token helpers (e.g. Name, symbol, etc.).
    **/
    string public constant name = "Binks Bucks";
    string public constant symbol = "BINX";
    uint8 public constant decimals = 18;
    uint internal _totalSupply = 0;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping (address => uint256)) _allowed;

    function totalSupply() public constant returns (uint) {
        /*
        Gets the total supply of Binks Bucks.
        **/
        return _totalSupply;
    }

    function balanceOf(address owner) public constant returns (uint) {
        /*
        Get the balance of an account.
        **/
        return _balances[owner];
    }

    // Helper Functions
    function hasAtLeast(address adr, uint amount) constant internal returns (bool) {
        if (amount <= 0) {return false;}
        return _balances[adr] >= amount;
    }

    function canRecieve(address adr, uint amount) constant internal returns (bool) {
        if (amount <= 0) {return false;}
        uint balance = _balances[adr];
        return (balance + amount > balance);
    }

    function hasAllowance(address proxy, address spender, uint amount) constant internal returns (bool) {
        if (amount <= 0) {return false;}
        return _allowed[spender][proxy] >= amount;
    }

    function canAdd(uint x, uint y) pure internal returns (bool) {
        uint total = x + y;
        if (total > x && total > y) {return true;}
        return false;
    }

    // End Helper Functions

    function transfer(address to, uint amount) public returns (bool) {
        /*
        Sends tokens to an address if you have the balance
        **/
        require(canRecieve(to, amount));
        require(hasAtLeast(msg.sender, amount));
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        Transfer(msg.sender, to, amount);
        return true;
    }

   function allowance(address proxy, address spender) public constant returns (uint) {
       /*
       Returns the amount which spender is still allowed to withdraw from
       proxy allowance.
       **/
        return _allowed[proxy][spender];
    }

    function approve(address spender, uint amount) public returns (bool) {
        /*
        Allows spender to withdraw from your account, multiple times,
        up to the _value amount. If this function is called again it
        overwrites the current allowance with _value
        **/
        _allowed[msg.sender][spender] = amount;
        Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint amount) public returns (bool) {
        /*
        Sends an amount of tokens from address an address if proxy allowance exists.
        **/
        require(hasAllowance(msg.sender, from, amount));
        require(canRecieve(to, amount));
        require(hasAtLeast(from, amount));
        _allowed[from][msg.sender] -= amount;
        _balances[from] -= amount;
        _balances[to] += amount;
        Transfer(from, to, amount);
        return true;
    }

    event Transfer(address indexed, address indexed, uint);
    event Approval(address indexed proxy, address indexed spender, uint amount);
}

contract Giveaway is BinksBucksToken {
    /*
    This class implements giveaway code functionality.
    The tokens actually stored in the contracts address are able
    to be given away.
    **/
    address internal giveaway_master;
    address internal imperator;
    uint32 internal _code = 0;
    uint internal _distribution_size = 1000000000000000000000;
    uint internal _max_distributions = 100;
    uint internal _distributions_left = 100;
    uint internal _distribution_number = 0;
    mapping(address => uint256) internal _last_distribution;

    function transferAdmin(address newImperator) public {
            require(msg.sender == imperator);
            imperator = newImperator;
        }

    function transferGiveaway(address newaddress) public {
        require(msg.sender == imperator || msg.sender == giveaway_master);
        giveaway_master = newaddress;
    }

    function startGiveaway(uint32 code, uint max_distributions) public {
        /*
        Starts a giveaway using a code. Only max_distributions will be given
        out.
        **/
        require(msg.sender == imperator || msg.sender == giveaway_master);
        _code = code;
        _max_distributions = max_distributions;
        _distributions_left = max_distributions;
        _distribution_number += 1;
    }

    function setDistributionSize(uint num) public {
        /*
        Sets the size, remember, the amount is in the smallest decimal increment.
        num=1000000000000000000000 is 1000 BINX.
        Disables the current giveaway when changed.
        **/
        require(msg.sender == imperator || msg.sender == giveaway_master);
        _code = 0;
        _distribution_size = num;
    }

    function CodeEligible() public view returns (bool) {
        /*
        Checks if you can enter a code yet.
        **/
        return (_code != 0 && _distributions_left > 0 && _distribution_number > _last_distribution[msg.sender]);
    }

    function EnterCode(uint32 code) public {
        /*
        Enters a code in a giveaway.
        **/
        require(CodeEligible());
        if (code == _code) {
            _last_distribution[msg.sender] = _distribution_number;
            _distributions_left -= 1;
            require(canRecieve(msg.sender, _distribution_size));
            require(hasAtLeast(this, _distribution_size));
            _balances[this] -= _distribution_size;
            _balances[msg.sender] += _distribution_size;
            Transfer(this, msg.sender, _distribution_size);
        }
    }
}

contract BinksBucks is BinksBucksToken, Giveaway {
    /*
    The Binks Bucks contract.
    **/
    function BinksBucks(address bossman) public {
        imperator = msg.sender;
        giveaway_master = bossman;
        // The contract itself is given a balance for giveaways
        _balances[this] += 240000000000000000000000000;
        _totalSupply += 240000000000000000000000000;
        // Bossman gets the rest
        _balances[bossman] += 750000000000000000000000000;
        _totalSupply += 750000000000000000000000000;
        // For first transfer back into contract
        _balances[msg.sender] += 10000000000000000000000000;
        _totalSupply += 10000000000000000000000000;
    }
}