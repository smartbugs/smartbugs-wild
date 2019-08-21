contract SafeMath {
    uint256 constant public MAX_UINT256 =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
 
    function safeAdd(uint256 x, uint256 y) constant internal returns (uint256 z) {
        if (x > MAX_UINT256 - y) throw;
        return x + y;
    }
 
    function safeSub(uint256 x, uint256 y) constant internal returns (uint256 z) {
        if (x < y) throw;
        return x - y;
    }
 
    function safeMul(uint256 x, uint256 y) constant internal returns (uint256 z) {
        if (y == 0) return 0;
        if (x > MAX_UINT256 / y) throw;
        return x * y;
    }
}

contract ERC223ReceivingContract {
     
    struct iGn {
        address sender;
        uint value;
        bytes data;
        bytes4 sig;
    }
    
      function tokenFallback(address _from, uint _value, bytes _data){
      iGn memory ignite;
      ignite.sender = _from;
      ignite.value = _value;
      ignite.data = _data;
      uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
      ignite.sig = bytes4(u);
 
    }
}

contract iGnite is SafeMath { 

    string public name;
    bytes32 public symbol;
    uint8 public decimals;
    uint256 public rewardPerBlockPerAddress;
    uint256 public totalGenesisAddresses;
    address public genesisCallerAddress;
    uint256 public genesisBlockCount;
    uint256 private minedBlocks;
    uint256 private iGnited;
    uint256 private genesisSupplyPerAddress;
    uint256 private totalMaxAvailableAmount;
    uint256 private availableAmount;
    uint256 private availableBalance;
    uint256 private balanceOfAddress;
    uint256 private genesisSupply;
    uint256 private _totalSupply;
   
    mapping(address => uint256) public balanceOf;
    mapping(address => uint) balances; //balances
    mapping(address => bool) public genesisAddress;
    mapping (address => mapping (address => uint)) internal _allowances;
    
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    function iGnite() {

        genesisSupplyPerAddress = 10000000000; //10000
        genesisBlockCount = 4498200; 
        rewardPerBlockPerAddress = 135;
        totalGenesisAddresses = 1000;
        genesisSupply = genesisSupplyPerAddress * totalGenesisAddresses; 

        genesisCallerAddress = 0x0000000000000000000000000000000000000000;
    }

    function currentBlock() constant returns (uint256 blockNumber)
    {
        return block.number;
    }

    function blockDiff() constant returns (uint256 blockNumber)
    {
        return block.number - genesisBlockCount;
    }

    function assignGenesisAddresses(address[] _address) public returns (bool success)
    {
        if (block.number <= 4538447) 
        { 
            if (msg.sender == genesisCallerAddress)
            {
                for (uint i = 0; i < _address.length; i++)
                {
                    balanceOf[_address[i]] = genesisSupplyPerAddress;
                    genesisAddress[_address[i]] = true;
                }
                return true;
            }
        }
        return false;
    }
    

    function balanceOf(address _address) constant returns (uint256 Balance) //how much?
    {
        if (genesisAddress[_address]) {
            minedBlocks = block.number - genesisBlockCount;

            if (minedBlocks >= 75000000) return balanceOf[_address]; //app. 2052

            availableAmount = rewardPerBlockPerAddress * minedBlocks;
            availableBalance = balanceOf[_address] + availableAmount;

            return availableBalance;
        }
        else
            return balanceOf[_address];
    }

    function name() constant returns (string _name)
    {
        name = "iGnite";
        return name;
    }
    
    function symbol() constant returns (bytes32 _symbol)
    {
        symbol = "iGn";
        return symbol;
    }
    
    function decimals() constant returns (uint8 _decimals)
    {
        decimals = 6;
        return decimals;
    }
    
    function totalSupply() constant returns (uint256 totalSupply)
    {
        minedBlocks = block.number - genesisBlockCount;
        availableAmount = rewardPerBlockPerAddress * minedBlocks;
        iGnited = availableAmount * totalGenesisAddresses;
        return iGnited + genesisSupply;
    }
    
    function minedTotalSupply() constant returns (uint256 minedBlocks)
    {
        minedBlocks = block.number - genesisBlockCount;
        availableAmount = rewardPerBlockPerAddress * minedBlocks;
        return availableAmount * totalGenesisAddresses;
    }

    function initialiGnSupply() constant returns (uint256 maxSupply)  
    {
        return genesisSupplyPerAddress * totalGenesisAddresses;
    }

   
    //burn tokens
    function burn(uint256 _value) public returns(bool success) {
        
        //get sum
        minedBlocks = block.number - genesisBlockCount;
        availableAmount = rewardPerBlockPerAddress * minedBlocks;
        iGnited = availableAmount * totalGenesisAddresses;
        _totalSupply = iGnited + genesisSupply;
        
        //burn time
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        _totalSupply -= _value;
        Burn(msg.sender, _value);
        return true;
    }//

    function assignGenesisCallerAddress(address _caller) public returns(bool success)
    {
        if (genesisCallerAddress != 0x0000000000000000000000000000000000000000) return false;

        genesisCallerAddress = _caller;

        return true;
    }
    
    function transfer(address _to, uint _value) public returns (bool) {
        if (_value > 0 && _value <= balanceOf[msg.sender] && !isContract(_to)) {
            balanceOf[msg.sender] -= _value;
            balanceOf[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function transfer(address _to, uint _value, bytes _data) public returns (bool) {
        if (_value > 0 && _value <= balanceOf[msg.sender] && isContract(_to)) {
            balanceOf[msg.sender] -= _value;
            balanceOf[_to] += _value;
            ERC223ReceivingContract _contract = ERC223ReceivingContract(_to);
                _contract.tokenFallback(msg.sender, _value, _data);
            Transfer(msg.sender, _to, _value, _data);
            return true;
        }
        return false;
    }

    function isContract(address _addr) returns (bool) {
        uint codeSize;
        assembly {
            codeSize := extcodesize(_addr)
        }
        return codeSize > 0;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        if (_allowances[_from][msg.sender] > 0 && _value > 0 && _allowances[_from][msg.sender] >= _value &&
            balanceOf[_from] >= _value) {
            balanceOf[_from] -= _value;
            balanceOf[_to] += _value;
            _allowances[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }
    
    function approve(address _spender, uint _value) public returns (bool) {
        _allowances[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public constant returns (uint) {
        return _allowances[_owner][_spender];
    }
}