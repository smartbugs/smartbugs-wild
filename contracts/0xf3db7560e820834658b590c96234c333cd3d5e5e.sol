/*
 *  The CoinPoker Token contract complies with the ERC20 standard (see https://github.com/ethereum/EIPs/issues/20).
 *  All tokens not being sold during the crowdsale but the reserved token
 *  for tournaments future financing are burned.
 *  Author: Justas Kregzde
 */
 
pragma solidity ^0.4.19;

library SafeMath {
    function mul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal returns (uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }
}

contract CoinPokerToken {
    using SafeMath for uint;
    // Public variables of the token
    string constant public standard = "ERC20";
    string constant public name = "Poker Chips";
    string constant public symbol = "CHP";
    uint8 constant public decimals = 18;
    uint _totalSupply = 500000000e18; // Total supply of 500 Million CoinPoker Tokens
    uint constant public tokensPreICO = 100000000e18; // 20% for pre-ICO
    uint constant public tokensICO = 275000000e18; // 55% for ICO
    uint constant public teamReserve = 50000000e18; // 10% for team/advisors/exchanges
    uint constant public tournamentsReserve = 75000000e18; // 15% for tournaments, released by percentage of total tokens sale
    uint public startTime = 1516960800; // Time after ICO, when tokens may be transferred. Friday, 26 January 2018 10:00:00 GMT
    address public ownerAddr;
    address public preIcoAddr; // pre-ICO token holder
    address public tournamentsAddr; // tokens for tournaments
    address public cashierAddr; // CoinPoker main cashier/game wallet
    bool burned;

    // Array with all balances
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;

    // Public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed _owner, address indexed spender, uint value);
    event Burned(uint amount);

    // What is the balance of a particular account?
    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }

    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    // Get the total token supply
    function totalSupply() constant returns (uint) {
        return _totalSupply;
    }

    //  Initializes contract with initial supply tokens to the creator of the contract
    function CoinPokerToken(address _ownerAddr, address _preIcoAddr, address _tournamentsAddr, address _cashierAddr) {
        ownerAddr = _ownerAddr;
        preIcoAddr = _preIcoAddr;
        tournamentsAddr = _tournamentsAddr;
        cashierAddr = _cashierAddr;
        balances[ownerAddr] = _totalSupply; // Give the owner all initial tokens
    }

    //  Send some of your tokens to a given address
    function transfer(address _to, uint _value) returns(bool) {
        if (now < startTime)  // Check if the crowdsale is already over
            require(_to == cashierAddr); // allow only to transfer CHP (make a deposit) to game/cashier wallet
        balances[msg.sender] = balances[msg.sender].sub(_value); // Subtract from the sender
        balances[_to] = balances[_to].add(_value); // Add the same to the recipient
        Transfer(msg.sender, _to, _value); // Notify anyone listening that this transfer took place
        return true;
    }

    //  A contract or person attempts to get the tokens of somebody else.
    //  This is only allowed if the token holder approved.
    function transferFrom(address _from, address _to, uint _value) returns(bool) {
        if (now < startTime)  // Check if the crowdsale is already over
            require(_from == ownerAddr || _to == cashierAddr);
        var _allowed = allowed[_from][msg.sender];
        balances[_from] = balances[_from].sub(_value); // Subtract from the sender
        balances[_to] = balances[_to].add(_value); // Add the same to the recipient
        allowed[_from][msg.sender] = _allowed.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }
	
    //   Approve the passed address to spend the specified amount of tokens
    //   on behalf of msg.sender.
    function approve(address _spender, uint _value) returns (bool) {
        //https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function percent(uint numerator, uint denominator, uint precision) public constant returns(uint quotient) {
        uint _numerator = numerator.mul(10 ** (precision.add(1)));
        uint _quotient =  _numerator.div(denominator).add(5).div(10);
        return (_quotient);
    }

    //  Called when ICO is closed. Burns the remaining tokens except the tokens reserved:
    //  - for tournaments (released by percentage of total token sale, max 75'000'000)
    //  - for pre-ICO (100'000'000)
    //  - for team/advisors/exchanges (50'000'000).
    //  Anybody may burn the tokens after ICO ended, but only once (in case the owner holds more tokens in the future).
    //  this ensures that the owner will not posses a majority of the tokens.
    function burn() {
        // If tokens have not been burned already and the crowdsale ended
        if (!burned && now > startTime) {
            // Calculate tournament release amount (tournament_reserve * proportion_how_many_sold)
            uint total_sold = _totalSupply.sub(balances[ownerAddr]);
            total_sold = total_sold.add(tokensPreICO);
            uint total_ico_amount = tokensPreICO.add(tokensICO);
            uint percentage = percent(total_sold, total_ico_amount, 8);
            uint tournamentsAmount = tournamentsReserve.mul(percentage).div(100000000);

            // Calculate what's left
            uint totalReserve = teamReserve.add(tokensPreICO);
            totalReserve = totalReserve.add(tournamentsAmount);
            uint difference = balances[ownerAddr].sub(totalReserve);

            // Distribute tokens
            balances[preIcoAddr] = balances[preIcoAddr].add(tokensPreICO);
            balances[tournamentsAddr] = balances[tournamentsAddr].add(tournamentsAmount);
            balances[ownerAddr] = teamReserve;

            // Burn what's left
            _totalSupply = _totalSupply.sub(difference);
            burned = true;
            Burned(difference);
        }
    }
}