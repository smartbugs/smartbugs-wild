pragma solidity ^0.4.25;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Token {
    function transfer(address _to, uint256 _value) returns(bool ok);
}

contract WhiteList {
    function checkAddress ( address _address ) constant public returns(bool);
}

contract MultiOwnable {
    
    mapping(address => bool) public owners;
    uint256 ownersCount;
    
    address[] public ownerslist;
    
    event OwnerAdded(address admin);
    event OwnerRemoved(address admin);
    
    modifier onlyOwner() {
        require(owners[msg.sender] == true);
        _;
    }
    
    constructor() public {
        owners[msg.sender] = true;
        ownersCount++;
        ownerslist.push(msg.sender);
    }
    
    function addOwner(address owner) public onlyOwner {
        require(owner != 0x0);
        owners[owner] = true;
        ownerslist.push(owner);
        emit OwnerAdded(owner);
    }
    
    function removeOwner(address owner) public onlyOwner {
        require(ownersCount > 1);
        owners[owner] = false;
        ownersCount--;
        emit OwnerRemoved(owner);
    }
    
    function isOwner(address _address) public returns(bool){
        return owners[_address];
    }
    
    
}

contract FiatContract {
    function ETH(uint _id) constant returns (uint256);
    function USD(uint _id) constant returns (uint256);
}

contract BSAFECrowdsale is MultiOwnable {
    
    FiatContract public fiat;

    using SafeMath for uint256;

    enum Status {CREATED, PRESTO, STO, FINISHED}

    event PreSTOStarted();
    event STOStarted();
    event SaleFinished();
    event SalePaused();
    event SaleUnpaused();
    event Purchase(address to, uint256 amount);
    event Withdrawal(address to, uint256 amount);
    
    event NewWallet(address _wallet);
    event NewToken(address _token);
	
    Status public status;

    uint256 public rate;
    uint256 public saleSupply;
    Token public token;
    WhiteList public whitelist;
    address public wallet;
    uint256 price;

    bool public isPaused = true;
    
    uint public presto_min;
    uint public sto_min;

    modifier whenPaused() {
        require(isPaused);
        _;
    }
    
    modifier whenNotPaused() {
        require(!isPaused);
        _;
    }
    
    function tokenFallback(address _from, uint _value, bytes _data) public {
    }
   

    /**
     * @param _token Address of token to sale
     * @param _wallet Address to withdraw funds
     */
     // use 0x2CDe56E5c8235D6360CCbb0c57Ce248Ca9C80909 for _fiatcontract
     // deploy whitelist contract first in order to properly add whitelist contract
    constructor(address _token, address _wallet, address _whitelist, address _fiatcontract) public {
        token = Token(_token);
        whitelist = WhiteList(_whitelist);
        wallet = _wallet;
        fiat = FiatContract( _fiatcontract ); 
        status = Status.CREATED;
        
        presto_min = 2500000;
        sto_min    =  100000;
        
    }
    
    function getPrice(uint256 _usd) constant returns(uint256) {
        return _usd * fiat.USD(0);
    }
    
    function startPreSTOSale() public onlyOwner {
        require(status == Status.CREATED);
        isPaused = false;
        status = Status.PRESTO;
        rate = 25;
        emit PreSTOStarted();
    }
    
    function startSTO() public onlyOwner {
        require(status == Status.PRESTO);
        status = Status.STO;
        rate = 50;
        emit STOStarted();
    }
    
    /** 
     * Ends crowdsale 
     * Should be used carefully. You cannot start crowdsale twice
     */
    function finishSale() public onlyOwner {
        status = Status.FINISHED;
        isPaused = false;
    }
    
    function pause() public onlyOwner {
        isPaused = true;
        emit SalePaused();
    }
    
    function unpause() public onlyOwner {
        isPaused = false;
        emit SaleUnpaused();
    }
    
    function buy(uint256 _wei) internal whenNotPaused{
        require( whitelist.checkAddress(msg.sender) == true );
	require (  status != Status.FINISHED ) ;
        if(status==Status.PRESTO) require ( msg.value >=  getPrice(presto_min) );
        if(status==Status.STO)    require ( msg.value >=  getPrice(sto_min)    );
        uint256 tokensAmount = calcTokens(_wei);
        token.transfer(msg.sender, tokensAmount.mul(10**8));
        emit Purchase(msg.sender, tokensAmount);
    }
    
    function() external payable whenNotPaused{
        buy(msg.value);
    }
    
    function calcTokens(uint256 _amount) public constant returns (uint256) {
        return _amount.div( getPrice(rate) );    
    }
    
    function setTokenContract(address _address) public onlyOwner whenPaused {
        require(_address != 0x0);
        token = Token(_address);
        emit NewToken(_address);
    }
    
    function setWallet(address _address) public onlyOwner whenPaused {
        require(_address != 0x0);
        wallet = _address;
        emit NewWallet(_address);
    }
    
    function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(_to != 0x0);
        _to.transfer(_amount);
        emit Withdrawal(_to, _amount);
    }
    
    function withdrawBSAFE(address _to, uint256 _amount) public onlyOwner {
        require(_to != 0x0);
        token.transfer(_to, _amount);
        emit Withdrawal(_to, _amount);
    }
    
    function updateSTOPrice ( uint _newprice ) public onlyOwner {
        sto_min = _newprice;
    }
    
     
}