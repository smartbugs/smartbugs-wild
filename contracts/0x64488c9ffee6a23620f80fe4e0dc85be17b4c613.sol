pragma solidity ^0.4.25;

/**
  MTWE - Mineable Token With Exchange
*/

contract MTWE {
    struct Order {
        address creator;
        bool buy;
        uint price;
        uint amount;
    }
    
    string public name = 'MTWE';
    string public symbol = 'MTWE';
    uint8 public decimals = 18;
    uint256 public totalSupply = 10000000000000000000000000;
    
    uint private seed;
    
    mapping (address => uint256) public balanceOf;
    mapping (address => uint256) public successesOf;
    mapping (address => uint256) public failsOf;
    mapping (address => mapping (address => uint256)) public allowance;
    
    Order[] public orders;
    uint public orderCount;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event PlaceBuy(address indexed user, uint price, uint amount, uint id);
    event PlaceSell(address indexed user, uint price, uint amount, uint id);
    event FillOrder(uint indexed id, address indexed user, uint amount);
    event CancelOrder(uint indexed id);
    
    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor () public {
        balanceOf[msg.sender] = totalSupply;
    }
    
    /*** Helpers */
    
    /* Converts uint256 to bytes32 */
    function toBytes(uint256 x) internal pure returns (bytes b) {
        b = new bytes(32);
        assembly {
            mstore(add(b, 32), x)
        }
    }
    
    function safeAdd(uint a, uint b) private pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }
    
    function safeSub(uint a, uint b) private pure returns (uint) {
        assert(b <= a);
        return a - b;
    }
    
    function safeMul(uint a, uint b) private pure returns (uint) {
        if (a == 0) {
          return 0;
        }
        
        uint c = a * b;
        assert(c / a == b);
        return c;
    }
    
    function safeIDiv(uint a, uint b) private pure returns (uint) {
        uint c = a / b;
        assert(b * c == a);
        return c;
    }
    
    /* Returns a pseudo-random number */
    function random(uint lessThan) internal returns (uint) {
        seed += block.timestamp + uint(msg.sender);
        return uint(sha256(toBytes(uint(blockhash(block.number - 1)) + seed))) % lessThan;
    }
    
    function calcAmountEther(uint price, uint amount) internal pure returns (uint) {
        return safeIDiv(safeMul(price, amount), 1000000000000000000);
    }
    
    /*** Token */
    
    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    
    /* Send coins */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }
    
    /* Transfer tokens from other address */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    
    /* Set allowance for other address */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }
    
    /*** Exchange */
    
    function placeBuy(uint price, uint amount) external payable {
        require(price > 0 && amount > 0 && msg.value == calcAmountEther(price, amount));
        orders.push(Order({
            creator: msg.sender,
            buy: true,
            price: price,
            amount: amount
        }));
        emit PlaceBuy(msg.sender, price, amount, orderCount);
        orderCount++;
    }
    
    function placeSell(uint price, uint amount) external {
        require(price > 0 && amount > 0);
        _transfer(msg.sender, this, amount);
        orders.push(Order({
            creator: msg.sender,
            buy: false,
            price: price,
            amount: amount
        }));
        emit PlaceSell(msg.sender, price, amount, orderCount);
        orderCount++;
    }
    
    function fillOrder(uint id, uint amount) external payable {
        require(id < orders.length);
        require(amount > 0);
        require(orders[id].creator != msg.sender);
        require(orders[id].amount >= amount);
        if (orders[id].buy) {
            require(msg.value == 0);
            
            /* send tokens from sender to creator */
            _transfer(msg.sender, orders[id].creator, amount);
            
            /* send Ether to sender */
            msg.sender.transfer(calcAmountEther(orders[id].price, amount));
        } else {
            uint etherAmount = calcAmountEther(orders[id].price, amount);
            require(msg.value == etherAmount);
            
            /* send tokens to sender */
            _transfer(this, msg.sender, amount);
            
            /* send Ether from sender to creator */
            orders[id].creator.transfer(etherAmount);
        }
        if (orders[id].amount == amount) {
            delete orders[id];
        } else {
            orders[id].amount -= amount;
        }
        emit FillOrder(id, msg.sender, amount);
    }
    
    function cancelOrder(uint id) external {
        require(id < orders.length);
        require(orders[id].creator == msg.sender);
        require(orders[id].amount > 0);
        if (orders[id].buy) {
            /* return Ether */
            msg.sender.transfer(calcAmountEther(orders[id].price, orders[id].amount));
        } else {
            /* return tokens */
            _transfer(this, msg.sender, orders[id].amount);
        }
        delete orders[id];
        emit CancelOrder(id);
    }
    
    function () public payable {
        if (msg.value == 0) {
            uint minedHashRel = random(10000);
            uint k = balanceOf[msg.sender] * 10000 / totalSupply;
            if (k > 0) {
                if (k > 19) {
                    k = 19;
                }
                k = 2 ** k;
                k = 5000 / k;
                k = 5000 - k;
                if (minedHashRel < k) {
                    uint reward = minedHashRel * 10000000000000000;
                    balanceOf[msg.sender] += reward;
                    totalSupply += reward;
                    emit Transfer(0, this, reward);
                    emit Transfer(this, msg.sender, reward);
                    successesOf[msg.sender]++;
                } else {
                    emit Transfer(this, msg.sender, 0);
                    failsOf[msg.sender]++;
                }
            } else {
                revert();
            }
        } else {
            revert();
        }
    }
}