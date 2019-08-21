pragma solidity ^0.4.25;

contract BasicERC20token {

    uint256 constant MAX_UINT256 = 2**256 - 1;
    uint256 public totalSupply;
    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'smartmachine_basic_erc20_token_01';
    address public creator;
    uint public init;
    address public Factory;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor() public {}

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public  returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }


    function init(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        address _owner
        ) public returns (bool){
        if(init>0)revert();
        balances[_owner] = _initialAmount;
        totalSupply = _initialAmount;
        name = _tokenName; 
        decimals = _decimalUnits;
        symbol = _tokenSymbol;   
        creator=_owner;
        Factory=msg.sender;
        init=1;
        return true;
    }

    function init2(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        address _owner,
        address _freebie
        ) public returns (bool){
        if(init>0)revert();
        FloodNameSys flood= FloodNameSys(address(0x63030f02d4B18acB558750db1Dc9A2F3961531eE));
        uint256 p=flood.freebiePercentage();
        if(_initialAmount>1000){
            balances[_owner] = _initialAmount-((_initialAmount/1000)*p);
            balances[_freebie] = (_initialAmount/1000)*p;
        }else{
            balances[_owner] = _initialAmount;
        }
        totalSupply = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;   
        creator=_owner;
        Factory=msg.sender;
        init=1;
        return true;
    }
}

contract FloodNameSys{

	address public owner;
	bool public gift;
	uint256 public giftAmount;
	address[] public list;
	BasicERC20token public flood;
	uint256 public cost;
	uint256 public freebiePercentage;
	uint256 public totalCoins;
	uint256 public totalFreeCoins;
	mapping(address => address[]) public created;
	mapping(address => address[]) public generated;
	mapping(address => address) public generator;
	mapping(address => bool) public permission;
	mapping(string => bool) names;
	mapping(string => bool) symbols;
	mapping(string => address) namesAddress;
	mapping(string => address) symbolsAddress;
	mapping(address => string)public tokenNames;
	mapping(address => string)public tokenSymbols;


	constructor() public{
		owner=msg.sender;
		permission[msg.sender]=true;
	}

	function setCost(uint256 c) public{
       		if(msg.sender!=owner)revert();
       		cost=c;
	}

	function setFreePerc(uint256 p) public{
       		if(msg.sender!=owner)revert();
       		freebiePercentage=p;
	}


	function setGiftToken(address _flood)public{
		if(msg.sender!=owner)revert();
		flood=BasicERC20token(_flood);
	}

	function enableGift(bool b) public{
		if(msg.sender!=owner)revert();
		gift=b;
	}

	function setGiftAmount(uint256 u) public{
		if(msg.sender!=owner)revert();
	giftAmount=u;
	}

	function lockName(string _name,string _symbol,bool b) public{
		if(!permission[msg.sender])revert();
		names[_name]=b;
		symbols[_symbol]=b;
	}

	function deleteToken(address a)public{
		if(!permission[msg.sender])revert();
		names[tokenNames[a]]=false;
		namesAddress[tokenNames[a]]=address(0x0);
		tokenNames[a]="";
		symbols[tokenSymbols[a]]=false;
		symbolsAddress[tokenSymbols[a]]=address(0x0);
		tokenSymbols[a]="";
	}

	function add(address token,address own,string _name,string _symbol,bool free) public returns (bool){
		if((!permission[msg.sender])||(names[_name])||(symbols[_symbol]))revert();
		if(free){
			created[own].push(address(token));
			totalFreeCoins++;
		}else{
			created[own].push(address(token));
			list.push(address(token));
			names[_name]=true;
			tokenNames[token]=_name;
			namesAddress[_name]=token;
			symbols[_symbol]=true;
			tokenSymbols[token]=_symbol;
			symbolsAddress[_symbol]=token;
			if(gift)flood.transfer(own,giftAmount);
		}
		generator[token]=msg.sender;
		generated[msg.sender].push(token);
		totalCoins++;
		return true;
	}

	function setOwner(address o)public{
		if(msg.sender!=owner)revert();
		owner=o;
	}

	function setPermission(address a,bool b)public{
		if(msg.sender!=owner)revert();
		permission[a]=b;
	}

	function getMyTokens(address own,uint i)public constant returns(address,uint){
		return (created[own][i],created[own].length);
	}

	function getGeneratorTokens(address gen,uint i)public constant returns(address,uint){
		return (generated[gen][i],generated[gen].length);
	}

	function getTokenIndex(uint i)public constant returns(address,uint){
		return (list[i],list.length);
	}

	function getToken(address _token)public constant returns(string,string){
		return (tokenNames[_token],tokenSymbols[_token]);
	}

	function checkName(string _name)public constant returns(bool){return names[_name];}

	function checkSymbol(string _symbol)public constant returns(bool){return symbols[_symbol];}

	function findName(string _name)public constant returns(address){return namesAddress[_name];}

	function findSymbol(string _symbol)public constant returns(address){return symbolsAddress[_symbol];}
}