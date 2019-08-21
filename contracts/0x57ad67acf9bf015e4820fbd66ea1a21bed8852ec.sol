/*
 *  The Lympo Token contract complies with the ERC20 standard (see https://github.com/ethereum/EIPs/issues/20).
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

contract LympoToken {
    using SafeMath for uint;
    // Public variables of the token
    string constant public standard = "ERC20";
    string constant public name = "Lympo tokens";
    string constant public symbol = "LYM";
    uint8 constant public decimals = 18;
    uint _totalSupply = 1000000000e18; // Total supply of 1 billion Lympo Tokens
    uint constant public tokensPreICO = 265000000e18; // 26.5%
    uint constant public tokensICO = 385000000e18; // 38.5%
    uint constant public teamReserve = 100000000e18; // 10%
    uint constant public advisersReserve = 30000000e18; // 3%
    uint constant public ecosystemReserve = 220000000e18; // 22%
    uint constant public ecoLock23 = 146652000e18; // 2/3 of ecosystem reserve
    uint constant public ecoLock13 = 73326000e18; // 1/3 of ecosystem reserve
    uint constant public startTime = 1519815600; // Time after ICO, when tokens became transferable. Wednesday, 28 February 2018 11:00:00 GMT
    uint public lockReleaseDate1year;
    uint public lockReleaseDate2year;
    address public ownerAddr;
    address public ecosystemAddr;
    address public advisersAddr;
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
    function totalSupply() constant returns (uint totalSupply) {
        totalSupply = _totalSupply;
    }

    // Initializes contract with initial supply tokens to the creator of the contract
    function LympoToken(address _ownerAddr, address _advisersAddr, address _ecosystemAddr) {
        ownerAddr = _ownerAddr;
        advisersAddr = _advisersAddr;
        ecosystemAddr = _ecosystemAddr;
        lockReleaseDate1year = startTime + 1 years; // 2019
        lockReleaseDate2year = startTime + 2 years; // 2020
        balances[ownerAddr] = _totalSupply; // Give the owner all initial tokens
    }
	
    // Send some of your tokens to a given address
    function transfer(address _to, uint _value) returns(bool) {
        require(now >= startTime); // Check if the crowdsale is already over

        // prevent the owner of spending his share of tokens for team within first the two year
        if (msg.sender == ownerAddr && now < lockReleaseDate2year)
            require(balances[msg.sender].sub(_value) >= teamReserve);

        // prevent the ecosystem owner of spending 2/3 share of tokens for the first year, 1/3 for the next year
        if (msg.sender == ecosystemAddr && now < lockReleaseDate1year)
            require(balances[msg.sender].sub(_value) >= ecoLock23);
        else if (msg.sender == ecosystemAddr && now < lockReleaseDate2year)
            require(balances[msg.sender].sub(_value) >= ecoLock13);

        balances[msg.sender] = balances[msg.sender].sub(_value); // Subtract from the sender
        balances[_to] = balances[_to].add(_value); // Add the same to the recipient
        Transfer(msg.sender, _to, _value); // Notify anyone listening that this transfer took place
        return true;
    }
	
    // A contract or person attempts to get the tokens of somebody else.
    // This is only allowed if the token holder approved.
    function transferFrom(address _from, address _to, uint _value) returns(bool) {
        if (now < startTime)  // Check if the crowdsale is already over
            require(_from == ownerAddr);

        // prevent the owner of spending his share of tokens for team within the first two year
        if (_from == ownerAddr && now < lockReleaseDate2year)
            require(balances[_from].sub(_value) >= teamReserve);

        // prevent the ecosystem owner of spending 2/3 share of tokens for the first year, 1/3 for the next year
        if (_from == ecosystemAddr && now < lockReleaseDate1year)
            require(balances[_from].sub(_value) >= ecoLock23);
        else if (_from == ecosystemAddr && now < lockReleaseDate2year)
            require(balances[_from].sub(_value) >= ecoLock13);

        var _allowed = allowed[_from][msg.sender];
        balances[_from] = balances[_from].sub(_value); // Subtract from the sender
        balances[_to] = balances[_to].add(_value); // Add the same to the recipient
        allowed[_from][msg.sender] = _allowed.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }
	
    // Approve the passed address to spend the specified amount of tokens
    // on behalf of msg.sender.
    function approve(address _spender, uint _value) returns (bool) {
        //https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    // Called when ICO is closed. Burns the remaining tokens except the tokens reserved:
    // Anybody may burn the tokens after ICO ended, but only once (in case the owner holds more tokens in the future).
    // this ensures that the owner will not posses a majority of the tokens.
    function burn() {
        // If tokens have not been burned already and the crowdsale ended
        if (!burned && now > startTime) {
            uint totalReserve = ecosystemReserve.add(teamReserve);
            totalReserve = totalReserve.add(advisersReserve);
            uint difference = balances[ownerAddr].sub(totalReserve);
            balances[ownerAddr] = teamReserve;
            balances[advisersAddr] = advisersReserve;
            balances[ecosystemAddr] = ecosystemReserve;
            _totalSupply = _totalSupply.sub(difference);
            burned = true;
            Burned(difference);
        }
    }
}