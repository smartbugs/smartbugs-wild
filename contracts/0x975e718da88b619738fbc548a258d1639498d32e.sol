pragma solidity ^0.4.18;

// SafeMath
contract SafeMath {
    function safeMul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
}

// Standard token interface (ERC 20)
// https://github.com/ethereum/EIPs/issues/20
// Token
contract Token is SafeMath {
    // Functions:
    /// @return total amount of tokens
    function totalSupply() public constant returns (uint256 supply);

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    function transferTo(address _to, uint256 _value) public returns (bool);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    // Events:
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
//StdToken
contract StdToken is Token {
    // Fields:
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    uint public supply = 0;

    // Functions:
    function transferTo(address _to, uint256 _value) public returns (bool) {
        require(balances[msg.sender] >= _value);
        require(balances[_to] + _value > balances[_to]);

        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);

        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
        require(balances[_from] >= _value);
        require(allowed[_from][msg.sender] >= _value);
        require(balances[_to] + _value > balances[_to]);

        balances[_to] = safeAdd(balances[_to], _value);
        balances[_from] = safeSub(balances[_from], _value);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);

        Transfer(_from, _to, _value);
        return true;
    }

    function totalSupply() public constant returns (uint256) {
        return supply;
    }

    function balanceOf(address _owner) public constant returns (uint256) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256) {
        return allowed[_owner][_spender];
    }
}
// EvoNineToken
contract EvoNineToken is StdToken
{
    /// Fields:
    string public name = "";
    string public symbol = "EVG";
    string public website = "https://evonine.co";
    uint public decimals = 18;

    uint public constant TOTAL_SUPPLY = 19000000 * (1 ether / 1 wei);
    uint public constant DEVELOPER_BONUS = 4500000 * (1 ether / 1 wei);
    uint public constant TEAM_BONUS = 3800000 * (1 ether / 1 wei);
    uint public constant ECO_SYSTEM_BONUS = 5700000 * (1 ether / 1 wei);
    uint public constant CONTRACT_HOLDER_BONUS = 5000000 * (1 ether / 1 wei);

    uint public constant ICO_PRICE1 = 2000;     // per 1 Ether
    uint public constant ICO_PRICE2 = 1818;     // per 1 Ether
    uint public constant ICO_PRICE3 = 1666;     // per 1 Ether
    uint public constant ICO_PRICE4 = 1538;     // per 1 Ether
    uint public constant ICO_PRICE5 = 1250;     // per 1 Ether
    uint public constant ICO_PRICE6 = 1000;     // per 1 Ether
    uint public constant ICO_PRICE7 = 800;     // per 1 Ether
    uint public constant ICO_PRICE8 = 666;     // per 1 Ether

    enum State{
        Init,
        Paused,
        ICORunning,
        ICOFinished
    }

    State public currentState = State.Init;
    bool public enableTransfers = true;

    // Token manager has exclusive priveleges to call administrative
    // functions on this contract.
    address public tokenManagerAddress = 0;

    // Gathered funds can be withdrawn only to escrow's address.
    address public escrowAddress = 0;

    // Team bonus address
    address public teamAddress = 0;

    // Development holder address
    address public developmentAddress = 0;

    // Eco system holder address
    address public ecoSystemAddress = 0;

    // Contract holder address
    address public contractHolderAddress = 0;


    uint public icoSoldTokens = 0;
    uint public totalSoldTokens = 0;

    /// Modifiers:
    modifier onlytokenManagerAddress()
    {
        require(msg.sender == tokenManagerAddress);
        _;
    }

    modifier onlyTokenCrowner()
    {
        require(msg.sender == escrowAddress);
        _;
    }

    modifier onlyInState(State state)
    {
        require(state == currentState);
        _;
    }

    /// Events:
    event LogBuy(address indexed owner, uint value);
    event LogBurn(address indexed owner, uint value);

    /// Functions:
    /// @dev Constructor
    /// @param _tokenManagerAddress Token manager address: 0x911AA92E796b10A2c79049FbACA219875a7fd1c9
    /// @param _escrowAddress Escrow address: 0x14522Ed2EcecA9059e5EC2700C3A715CF7d5b69e
    /// @param _teamAddress Team address: 0xfB03a82b11E0BB61f2DFA4eDcFadd6A841eD1496
    /// @param _developmentAddress Development address: 0x0814288347dA7fbA44a6ecEBD5Be2dCeDe035D91
    /// @param _ecoSystemAddress Eco system address: 0x0230a2b2F79274014E7FC71aD04c22188908F69B
    /// @param _contractHolderAddress Contract holder address: 0x4E8eC6420e529819b5A2cD477A083E5459d7A566
    function EvoNineToken(string _name, address _tokenManagerAddress, address _escrowAddress, address _teamAddress, address _developmentAddress, address _ecoSystemAddress, address _contractHolderAddress) public
    {
        name = _name;
        tokenManagerAddress = _tokenManagerAddress;
        escrowAddress = _escrowAddress;
        teamAddress = _teamAddress;
        developmentAddress = _developmentAddress;
        ecoSystemAddress = _ecoSystemAddress;
        contractHolderAddress = _contractHolderAddress;

        balances[_contractHolderAddress] += TOTAL_SUPPLY;
        supply += TOTAL_SUPPLY;
    }

    function buyTokens() public payable returns (uint256)
    {
        require(msg.value >= ((1 ether / 1 wei) / 100));
        uint newTokens = msg.value * getPrice();
        balances[msg.sender] += newTokens;
        supply += newTokens;
        icoSoldTokens += newTokens;
        totalSoldTokens += newTokens;

        LogBuy(msg.sender, newTokens);
    }

    function getPrice() public constant returns (uint)
    {
        if (icoSoldTokens < (4100000 * (1 ether / 1 wei))) {
            return ICO_PRICE1;
        }
        if (icoSoldTokens < (4300000 * (1 ether / 1 wei))) {
            return ICO_PRICE2;
        }
        if (icoSoldTokens < (4700000 * (1 ether / 1 wei))) {
            return ICO_PRICE3;
        }
        if (icoSoldTokens < (5200000 * (1 ether / 1 wei))) {
            return ICO_PRICE4;
        }
        if (icoSoldTokens < (6000000 * (1 ether / 1 wei))) {
            return ICO_PRICE5;
        }
        if (icoSoldTokens < (7000000 * (1 ether / 1 wei))) {
            return ICO_PRICE6;
        }
        if (icoSoldTokens < (8000000 * (1 ether / 1 wei))) {
            return ICO_PRICE7;
        }
        return ICO_PRICE8;
    }

    function setState(State _nextState) public onlytokenManagerAddress
    {
        //setState() method call shouldn't be entertained after ICOFinished
        require(currentState != State.ICOFinished);

        currentState = _nextState;
        // enable/disable transfers
        //enable transfers only after ICOFinished, disable otherwise
        //enableTransfers = (currentState==State.ICOFinished);
    }

    function DisableTransfer() public onlytokenManagerAddress
    {
        enableTransfers = false;
    }


    function EnableTransfer() public onlytokenManagerAddress
    {
        enableTransfers = true;
    }

    function withdrawEther() public onlytokenManagerAddress
    {
        if (this.balance > 0)
        {
            escrowAddress.transfer(this.balance);
        }
    }

    /// Overrides:
    function transferTo(address _to, uint256 _value) public returns (bool){
        require(enableTransfers);
        return super.transferTo(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
        require(enableTransfers);
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require(enableTransfers);
        return super.approve(_spender, _value);
    }

    // Setters/getters
    function ChangetokenManagerAddress(address _mgr) public onlytokenManagerAddress
    {
        tokenManagerAddress = _mgr;
    }

    // Setters/getters
    function ChangeCrowner(address _mgr) public onlyTokenCrowner
    {
        escrowAddress = _mgr;
    }
}