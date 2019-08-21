pragma solidity ^0.4.25;

/*
*   EBIC2019 smart contract
*   Created by DAPCAR ( https://dapcar.io/ )
*   Copyright © European Blockchain Investment Congress 2019. All rights reserved.
*   http://ebic2019.com/
*/

interface IERC20 {
    function totalSupply() public constant returns (uint256);
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract EBIC2019 {
    
    event PackageSent(address indexed sender, address indexed wallet, uint256 packageIndex, uint256 time);
    event Withdraw(address indexed sender, address indexed wallet, uint256 amount);
    event WithdrawTokens(address indexed sender, address indexed wallet, address indexed token, uint256 amount);
    event DappPurpose(address indexed dappAddress);
    event Suicide();
    
    address public owner;
    address public dapp;
    
    struct Package {
        Token[] tokens;
        bool enabled;
    }
    
    struct Token {
        address smartAddress;
        uint256 amount;
    }
    
    Package[] packages;
    uint256 public packageCount;
    
    mapping (address => uint256) public packageSent;
    uint256 public packageSentCount;
    
    constructor() 
    {
        owner = msg.sender;
        
        packages.length++;
    }
    
    function () 
    external 
    payable 
    {
	}
	
	function packageCreate()
	public
	returns (uint256 _index)
	{
	    require(msg.sender == owner);
	    
	    uint256 index = packages.length++;
	    _index = index--;
	    Package storage package = packages[_index];
	    package.enabled = true;
	    packageCount++;
	}
	
	function packageTokenCreate(uint256 _packageIndex, address _token, uint256 _amount)
	public
	returns (bool _success)
	{
	    _success = false;
	    
	    require(msg.sender == owner);
	    require(_packageIndex > 0 && _packageIndex <= packageCount);
	    require(_token != address(0));
	    require(_amount > 0);
	    
	    Token memory token = Token({
	        smartAddress: _token,
	        amount: _amount
	    });
	    
	    Package storage package = packages[_packageIndex];
	    package.tokens.push(token);
	    
	    _success = true;
	}
	
	function packageEnabled(uint256 _packageIndex, bool _enabled)
	public
	returns (bool _success)
	{
	    _success = false;
	    require(msg.sender == owner);
	    require(_packageIndex > 0 && _packageIndex <= packageCount);
	    
	    Package storage package = packages[_packageIndex];
	    package.enabled = _enabled;
	    
	    _success = true;
	}
	
	function packageView(uint256 _packageIndex)
	view
	public
	returns (uint256 _tokensCount, bool _enabled)
	{
	    require(_packageIndex > 0 && _packageIndex <= packageCount);
	    
	    Package memory package = packages[_packageIndex];
	    
	    _tokensCount = package.tokens.length;
	    _enabled = package.enabled;
	}
	
	function packageTokenView(uint256 _packageIndex, uint256 _tokenIndex)
	view
	public
	returns (address _token, uint256 _amount)
	{
	    require(_packageIndex > 0 && _packageIndex <= packageCount);
	    
	    Package memory package = packages[_packageIndex];
	    
	    require(_tokenIndex < package.tokens.length);
	    
	    Token memory token = package.tokens[_tokenIndex];
	    _token = token.smartAddress;
	    _amount = token.amount;
	}
	
	function packageSend(address _wallet, uint256 _packageIndex)
	public
	returns (bool _success)
	{
	    _success = false;
	    
	    require(msg.sender == owner || msg.sender == dapp);
	    require(_wallet != address(0));
	    require(_packageIndex > 0);
	    require(packageSent[_wallet] != _packageIndex);
	    
	    Package memory package = packages[_packageIndex];
	    require(package.enabled);
	    
	    for(uint256 index = 0; index < package.tokens.length; index++){
	        require(IERC20(package.tokens[index].smartAddress).transfer(_wallet, package.tokens[index].amount));
	    }
	    
	    packageSent[_wallet] = _packageIndex;
	    packageSentCount++;
	    
	    emit PackageSent(msg.sender, _wallet, _packageIndex, now);
	    
	    _success = true;
	}
	
	function dappPurpose(address _dappAddress)
	public
	returns (bool _success) 
	{
	    _success = false;
	    
	    require(msg.sender == owner);
	    
        dapp = _dappAddress;
        emit DappPurpose(dapp);
	    
	    _success = true;
	}
	
	function balanceOfTokens(address _token)
    public 
    constant
    returns (uint256 _amount) 
    {
        require(_token != address(0));
        
        return IERC20(_token).balanceOf(address(this));
    }
    
    function withdrawTokens(address _token, uint256 _amount)
    public 
    returns (bool _success) 
    {
        require(msg.sender == owner);
        require(_token != address(0));

        bool result = IERC20(_token).transfer(owner, _amount);
        if (result) {
            emit WithdrawTokens(msg.sender, owner, _token, _amount);
        }
        return result;
    }
    
    function withdraw()
    public 
    returns (bool success)
    {
        require(msg.sender == owner);

        emit Withdraw(msg.sender, owner, address(this).balance);
        owner.transfer(address(this).balance);
        return true;
    }
    
    function suicide()
    public
    {
        require(msg.sender == owner);
        
        emit Suicide();
        selfdestruct(owner);
    }
    
    
    
}