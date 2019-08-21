pragma solidity ^0.4.24;

library SafeMath
{
    function mul(uint256 a, uint256 b) internal pure
    returns (uint256)
    {
        uint256 c = a * b;

        assert(a == 0 || c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure
    returns (uint256)
    {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure
    returns (uint256)
    {
        assert(b <= a);

        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure
    returns (uint256)
    {
        uint256 c = a + b;

        assert(c >= a);

        return c;
    }
}

interface ERC20
{
    function totalSupply() view external returns (uint _totalSupply);
    function balanceOf(address _owner) view external returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) view external returns (uint remaining);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract LynchpinToken is ERC20
{
    using SafeMath for uint256;

    string  public name        = "Lynchpin";
    string  public symbol      = "LYN";
    uint8   public decimals    = 18;
    uint    public totalSupply = 5000000 * (10 ** uint(decimals));
    address public owner       = 0xAc983022185b95eF2B2C7219143483BD0C65Ecda;

    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    constructor() public
    {
        balanceOf[owner] = totalSupply;
    }

    function totalSupply() view external returns (uint _totalSupply)
    {
        return totalSupply;
    }

    function balanceOf(address _owner) view external returns (uint balance)
    {
        return balanceOf[_owner];
    }

    function allowance(address _owner, address _spender) view external returns (uint remaining)
    {
        return allowance[_owner][_spender];
    }
    function _transfer(address _from, address _to, uint _value) internal
    {
        require(_to != 0x0);

        uint previousBalances = balanceOf[_from].add(balanceOf[_to]);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);

        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);
    }

    function transfer(address _to, uint _value) public returns (bool success)
    {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success)
    {
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value) public returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // disallow incoming ether to this contract
    function () public
    {
        revert();
    }
}

contract Ownable
{
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _owner) public
    {
        owner = _owner;
    }

    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner
    {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract LynchpinPublicICO is Ownable(0x1788A2Fe89a3Bfa58DB57aabbf1Ffa08ADED6cba)
{
    using SafeMath for uint256;

    LynchpinToken public lynT = LynchpinToken(0xB0B1685f55843D03739c7D9b0A230F1B7DcF03D5);
    address public beneficiary = 0x1788A2Fe89a3Bfa58DB57aabbf1Ffa08ADED6cba;

    uint256 public tokeninOneEther;
    uint256 public maxTokensToSell = 2000000 * 10**18;
    uint256 public tokenSold;
    bool crowdsaleClosed = false;

    mapping(address => bool) public isWhitelisted;

    event LogAddedToWhitelist(address indexed _contributor);
    event LogTokenRateUpdated(uint256 _newRate);
    event LogSaleClosed();

    constructor(uint256 _tokeninOneEther) public
    {
        require (_tokeninOneEther > 0);
        isWhitelisted[owner] = true;
        tokeninOneEther = _tokeninOneEther;
        emit LogTokenRateUpdated(_tokeninOneEther);
    }

    function () public payable
    {
        require(!crowdsaleClosed);
        require(isWhitelisted[msg.sender]);

        uint256 amountToSend = msg.value * tokeninOneEther;

        require (tokenSold.add(amountToSend) <= maxTokensToSell);

        lynT.transfer(msg.sender, amountToSend);
        tokenSold += amountToSend;
    }

    function addContributor(address _contributor) external onlyOwner
    {
        require(_contributor != address(0));
        require(!isWhitelisted[_contributor]);
        isWhitelisted[_contributor] = true;
        emit LogAddedToWhitelist(_contributor);
    }

    function updateTokenRate(uint256 _tokeninOneEther ) external onlyOwner
    {
        require (_tokeninOneEther > 0);
        tokeninOneEther = _tokeninOneEther;
        emit LogTokenRateUpdated(_tokeninOneEther);
    }

    function closeSale() external onlyOwner
    {
        lynT.transfer(msg.sender, lynT.balanceOf(address(this)));
        beneficiary.transfer(address(this).balance);
        crowdsaleClosed = true;
        emit LogSaleClosed();
    }
}