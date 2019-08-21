pragma solidity ^0.4.24;
//ERC20
contract ERC20Ownable {
    address public owner;

    function ERC20Ownable() public{
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public{
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}
contract ERC20 {
    function transfer(address to, uint256 value) public returns (bool);
    function balanceOf(address who) public view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20Token is ERC20,ERC20Ownable {
    
    mapping (address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
	
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
		
	//Fix for short address attack against ERC20
	modifier onlyPayloadSize(uint size) {
		assert(msg.data.length == size + 4);
		_;
	}

	function balanceOf(address _owner) constant public returns (uint256) {
		return balances[_owner];
	}

	function transfer(address _to, uint256 _value) onlyPayloadSize(2*32) public returns (bool){
		require(balances[msg.sender] >= _value && _value > 0);
	    balances[msg.sender] -= _value;
	    balances[_to] += _value;
	    emit Transfer(msg.sender, _to, _value);
	    return true;
    }

	function transferFrom(address _from, address _to, uint256 _value) public {
		require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
    }

	function approve(address _spender, uint256 _value) public {
		allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
	}

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        //require(_spender.call(bytes4(keccak256("receiveApproval(address,uint256,address,bytes)")), abi.encode(msg.sender, _value, this, _extraData)));
        require(_spender.call(abi.encodeWithSelector(bytes4(keccak256("receiveApproval(address,uint256,address,bytes)")),msg.sender, _value, this, _extraData)));

        return true;
    }
    
	function allowance(address _owner, address _spender) constant public returns (uint256) {
		return allowed[_owner][_spender];
	}
}

contract ERC20StandardToken is ERC20Token {
	uint256 public totalSupply;
	string public name;
	uint256 public decimals;
	string public symbol;
	bool public mintable;


    function ERC20StandardToken(address _owner, string _name, string _symbol, uint256 _decimals, uint256 _totalSupply, bool _mintable) public {
        require(_owner != address(0));
        owner = _owner;
		decimals = _decimals;
		symbol = _symbol;
		name = _name;
		mintable = _mintable;
        totalSupply = _totalSupply;
        balances[_owner] = totalSupply;
    }
    
    function mint(uint256 amount) onlyOwner public {
		require(mintable);
		require(amount >= 0);
		balances[msg.sender] += amount;
		totalSupply += amount;
	}

    function burn(uint256 _value) onlyOwner public returns (bool) {
        require(balances[msg.sender] >= _value  && totalSupply >=_value && _value > 0);
        balances[msg.sender] -= _value;
        totalSupply -= _value;
        emit Transfer(msg.sender, 0x0, _value);
        return true;
    }
}
pragma solidity ^0.4.24;
//ERC223
contract ERC223Ownable {
    address public owner;

    function ERC223Ownable() public{
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public{
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

contract ContractReceiver {
     
    struct TKN {
        address sender;
        uint value;
        bytes data;
        bytes4 sig;
    }
    
    function tokenFallback(address _from, uint _value, bytes _data) public pure {
      TKN memory tkn;
      tkn.sender = _from;
      tkn.value = _value;
      tkn.data = _data;
      uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
      tkn.sig = bytes4(u);
      
      /* tkn variable is analogue of msg variable of Ether transaction
      *  tkn.sender is person who initiated this token transaction   (analogue of msg.sender)
      *  tkn.value the number of tokens that were sent   (analogue of msg.value)
      *  tkn.data is data of token transaction   (analogue of msg.data)
      *  tkn.sig is 4 bytes signature of function
      *  if data of token transaction is a function execution
      */
    }
}

contract ERC223 {
  uint public totalSupply;
  function balanceOf(address who) public view returns (uint);

  function transfer(address to, uint value) public returns (bool ok);
  function transfer(address to, uint value, bytes data) public returns (bool ok);
  function transfer(address to, uint value, bytes data, string custom_fallback) public returns (bool ok);

  event Transfer(address indexed from, address indexed to, uint value);
  event Transfer(address indexed from, address indexed to, uint value, bytes data);
}

contract SafeMath {
    uint256 constant public MAX_UINT256 =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function safeAdd(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (x > MAX_UINT256 - y) revert();
        return x + y;
    }

    function safeSub(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (x < y) revert();
        return x - y;
    }

    function safeMul(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (y == 0) return 0;
        if (x > MAX_UINT256 / y) revert();
        return x * y;
    }
}

contract ERC223Token is ERC223, SafeMath {

  mapping(address => uint) balances;

  string public name;
  string public symbol;
  uint256 public decimals;
  uint256 public totalSupply;
  bool public mintable;



  function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {

    if(isContract(_to)) {
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
        emit Transfer(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    else {
        return transferToAddress(_to, _value, _data);
    }
}


function transfer(address _to, uint _value, bytes _data) public returns (bool success) {

    if(isContract(_to)) {
        return transferToContract(_to, _value, _data);
    }
    else {
        return transferToAddress(_to, _value, _data);
    }
}

  function transfer(address _to, uint _value) public returns (bool success) {

    //standard function transfer similar to ERC20 transfer with no _data
    //added due to backwards compatibility reasons
    bytes memory empty;
    if(isContract(_to)) {
        return transferToContract(_to, _value, empty);
    }
    else {
        return transferToAddress(_to, _value, empty);
    }
}

  function isContract(address _addr) private view returns (bool is_contract) {
      uint length;
      assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
      }
      return (length>0);
    }

  function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
    balances[_to] = safeAdd(balanceOf(_to), _value);
    emit Transfer(msg.sender, _to, _value);
    emit Transfer(msg.sender, _to, _value, _data);
    return true;
  }

  function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
    balances[_to] = safeAdd(balanceOf(_to), _value);
    ContractReceiver receiver = ContractReceiver(_to);
    receiver.tokenFallback(msg.sender, _value, _data);
    emit Transfer(msg.sender, _to, _value);
    emit Transfer(msg.sender, _to, _value, _data);
    return true;
}


  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}

contract ERC223StandardToken is ERC223Token,ERC223Ownable {
    
    function ERC223StandardToken(address _owner, string _name, string _symbol, uint256 _decimals, uint256 _totalSupply, bool _mintable) public {
        
        require(_owner != address(0));
        owner = _owner;
		decimals = _decimals;
		symbol = _symbol;
		name = _name;
		mintable = _mintable;
        totalSupply = _totalSupply;
        balances[_owner] = totalSupply;
        emit Transfer(address(0), _owner, totalSupply);
        emit Transfer(address(0), _owner, totalSupply, "");
    }
  
    function mint(uint256 amount) onlyOwner public {
		require(mintable);
		require(amount >= 0);
		balances[msg.sender] += amount;
		totalSupply += amount;
	}

    function burn(uint256 _value) onlyOwner public returns (bool) {
        require(balances[msg.sender] >= _value  && totalSupply >=_value && _value > 0);
        balances[msg.sender] -= _value;
        totalSupply -= _value;
        emit Transfer(msg.sender, 0x0, _value);
        return true;
    }
}
pragma solidity ^0.4.24;
contract Ownable {
    address public owner;

    function Ownable() public{
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public{
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}
//TokenMaker
contract TokenMaker is Ownable{
    
	event LogERC20TokenCreated(ERC20StandardToken token);
	event LogERC223TokenCreated(ERC223StandardToken token);

    address public receiverAddress;
    uint public txFee = 0.1 ether;
    uint public VIPFee = 1 ether;

    /* VIP List */
    mapping(address => bool) public vipList;
	uint public numContracts;

    mapping(uint => address) public deployedContracts;
	mapping(address => address[]) public userDeployedContracts;

    function () payable public{}

    function getBalance(address _tokenAddress,uint _type) onlyOwner public {
      address _receiverAddress = getReceiverAddress();
      if(_tokenAddress == address(0)){
          require(_receiverAddress.send(address(this).balance));
          return;
      }
      if(_type == 0){
          ERC20 erc20 = ERC20(_tokenAddress);
          uint256 balance = erc20.balanceOf(this);
          erc20.transfer(_receiverAddress, balance);
      }else{
          ERC223 erc223 = ERC223(_tokenAddress);
          uint256 erc223_balance = erc223.balanceOf(this);
          erc223.transfer(_receiverAddress, erc223_balance);
      }
    }
    
    //Register VIP
    function registerVIP() payable public {
      require(msg.value >= VIPFee);
      address _receiverAddress = getReceiverAddress();
      require(_receiverAddress.send(msg.value));
      vipList[msg.sender] = true;
    }


    function addToVIPList(address[] _vipList) onlyOwner public {
        for (uint i =0;i<_vipList.length;i++){
            vipList[_vipList[i]] = true;
        }
    }


    function removeFromVIPList(address[] _vipList) onlyOwner public {
        for (uint i =0;i<_vipList.length;i++){
        vipList[_vipList[i]] = false;
        }
   }

    function isVIP(address _addr) public view returns (bool) {
        return _addr == owner || vipList[_addr];
    }


    function setReceiverAddress(address _addr) onlyOwner public {
        require(_addr != address(0));
        receiverAddress = _addr;
    }

    function getReceiverAddress() public view returns  (address){
        if(receiverAddress == address(0)){
            return owner;
        }

        return receiverAddress;
    }

    function setVIPFee(uint _fee) onlyOwner public {
        VIPFee = _fee;
    }


    function setTxFee(uint _fee) onlyOwner public {
        txFee = _fee;
    }

    function getUserCreatedTokens(address _owner) public view returns  (address[]){
        return userDeployedContracts[_owner];
    }
    
    function create(string _name, string _symbol, uint256 _decimals, uint256 _totalSupply,  bool _mintable,uint256 _type) payable public returns(address a){
         //check the tx fee
        uint sendValue = msg.value;
        address from = msg.sender;
	    bool vip = isVIP(from);
        if(!vip){
		    require(sendValue >= txFee);
        }
        
        address[] userAddresses = userDeployedContracts[from];

        if(_type == 0){
            ERC20StandardToken erc20Token = new ERC20StandardToken(from, _name, _symbol, _decimals, _totalSupply, _mintable);
            userAddresses.push(erc20Token);
            userDeployedContracts[from] = userAddresses;
            deployedContracts[numContracts] = erc20Token;
            numContracts++;
            emit LogERC20TokenCreated(erc20Token);
	        return erc20Token;
        }else{
            ERC223StandardToken erc223Token = new ERC223StandardToken(from, _name, _symbol, _decimals, _totalSupply, _mintable);
            userAddresses.push(erc223Token);
            userDeployedContracts[from] = userAddresses;
            deployedContracts[numContracts] = erc223Token;
            numContracts++;
            emit LogERC223TokenCreated(erc223Token);
	        return erc223Token;
        }
        
     }
    
}