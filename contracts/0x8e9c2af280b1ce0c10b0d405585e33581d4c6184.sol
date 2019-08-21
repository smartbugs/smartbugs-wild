pragma solidity ^0.4.25;

contract Token {
    string  public name;
    string  public symbol;
    //string  public standard = "Token v1.0";
    uint256 public totalSupply;
    //
    address public minter;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor (uint256 _initialSupply, string memory _name, string memory _symbol, address _minter) public {
        balanceOf[_minter] = _initialSupply;
        totalSupply = _initialSupply;
        name = _name;
        symbol =_symbol;
        //
        minter =_minter;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function getTokenDetails() public view returns(address _minter, string memory _name, string memory _symbol, uint256 _totalsupply) {
        return(minter, name, symbol, totalSupply);
    }
}

contract tokenSale {
    address admin;
    Token public tokenContract;
    uint256 public tokenPrice;
    uint256 public tokensSold;
    string public phasename;

    event Sell(address _buyer, uint256 _amount);

    constructor (Token _tokenContract, uint256 _tokenPrice, string memory _phasename, address _admin) public {
        admin = _admin;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
        phasename = _phasename;
    }

    function multiply(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    // buying tokens from wallet other than metamask, which requires token recipient address
    function rbuyTokens(address recipient_addr, uint256 _numberOfTokens) public payable {
        require(msg.sender==admin);
        require(msg.value == multiply(_numberOfTokens, tokenPrice));
        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens);
        require(tokenContract.transfer(recipient_addr, _numberOfTokens));

        tokensSold += _numberOfTokens;

        emit Sell(msg.sender, _numberOfTokens);
    }

    function approveone(address spender, uint256 value) public {
        require(msg.sender==admin);
        tokenContract.approve(spender, value);
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        require(msg.value == multiply(_numberOfTokens, tokenPrice));
        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens); //----!!!!!!!
        require(tokenContract.transfer(msg.sender, _numberOfTokens));

        tokensSold += _numberOfTokens;

        emit Sell(msg.sender, _numberOfTokens);
    }

    function getmoney() public {
        require(msg.sender==admin);
        msg.sender.transfer(address(this).balance);
    }

    function endSale() public {
        require(msg.sender == admin);
        require(tokenContract.transfer(admin, tokenContract.balanceOf(address(this))));

        // UPDATE: Let's not destroy the contract here
        // Just transfer the balance to the admin
        msg.sender.transfer(address(this).balance);
    }
}