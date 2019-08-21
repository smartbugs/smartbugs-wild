pragma solidity ^0.4.18;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract EtherRacing is Ownable {
    using SafeMath for uint256;

    struct Customer {
        bytes32 name;
        uint256 earned;
        uint16 c_num;
        mapping (uint256 => uint16) garage;
        uint256[] garage_idx;
    }

    struct Car {
      uint256 id;
      bytes32 name;
      uint256 s_price;
      uint256 c_price;
      uint256 earning;
      uint256 o_earning;
      uint16 s_count;
      uint16 brand;
      uint8 ctype;
      uint8 spd;
      uint8 acc;
      uint8 dur;
      uint8 hndl;
      mapping (address => uint16) c_owners;
    }

    string public constant name = 'CarToken';
    string public constant symbol = 'CAR';
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(decimals));

    uint256 private store_balance;

    mapping (address => Customer) private customers;
    //mapping (address => uint256) pendingWithdrawals;
    mapping (uint256 => Car) public cars;
    mapping (uint256 => address[]) public yesBuyer;
    mapping (address => uint256) balances;
    uint256[] public carAccts;

    /* Store Events */

    event CarRegistered(uint256 carId);
    event CarUpdated(uint256 carId);
    event CarDeregistered(uint256 carId);
    event CarRegistrationFailed(uint256 carId);
    event CarDeregistrationFaled(uint256 carId);

    event BuyCarCompleted(address customer, uint256 paymentSum);
    event BuyCarFailed(address customer, uint256 customerBalance, uint256 paymentSum);
    event EventCashOut (address indexed player,uint256 amount);

    function EtherRacing() public payable {
        store_balance = 0;
        balances[tx.origin] = INITIAL_SUPPLY;
    }

    function() public payable {

    }

    function setInsertCar(bytes32 _name,
                          uint256 _s_price,
                          uint256 _earning,
                          uint256 _o_earning,
                          uint16 _brand,
                          uint8 _ctype,
                          uint8 _spd,
                          uint8 _acc,
                          uint8 _dur,
                          uint8 _hndl)
                          onlyOwner public {
        var _id = carAccts.length + 1;
        var car = Car(_id, _name, _s_price, _s_price, _earning, _o_earning,
                      0, _brand, _ctype, _spd, _acc, _dur, _hndl);
        cars[_id] = car;
        carAccts.push(_id);
        CarRegistered(_id);
    }

    function updateCar(uint256 _id,
                        bytes32 _name,
                        uint256 _s_price,
                        uint256 _earning,
                        uint256 _o_earning,
                        uint16 _brand,
                        uint8 _ctype,
                        uint8 _spd,
                        uint8 _acc,
                        uint8 _dur,
                        uint8 _hndl)
                        onlyOwner public {
        Car storage car = cars[_id];
        car.name = _name;
        car.s_price = _s_price;
        car.earning = _earning;
        car.o_earning = _o_earning;
        car.brand = _brand;
        car.ctype = _ctype;
        car.spd = _spd;
        car.acc = _acc;
        car.dur = _dur;
        car.hndl = _hndl;
        CarUpdated(_id);
    }

    function getCar(uint256 _id) view public returns (uint256,
                                                      bytes32,
                                                      uint256,
                                                      uint256,
                                                      uint256,
                                                      uint256,
                                                      uint16) {
        Car storage car = cars[_id];
        return (car.id, car.name, car.s_price, car.c_price, car.earning, car.o_earning, car.s_count);
    }

    function getCars() view public returns(uint256[]) {
        return carAccts;
    }

    function getCarName(uint256 _id) view public returns (bytes32){
      return cars[_id].name;
    }

    function countCars() view public returns (uint256) {
        return carAccts.length;
    }

    function deleteCar(uint256 _id) onlyOwner public returns (bool success) {
      Car storage car = cars[_id];
      if (car.id == _id) {
        delete cars[_id];
        CarDeregistered(_id);
        return true;
      }
      CarDeregistrationFaled(_id);
      return false;
    }

    function buyCar(uint256 _id) public payable returns (bool success) {
        require(_id > 0);
        require(cars[_id].c_price > 0 && (msg.value + balances[msg.sender]) > 0);
        require((msg.value + balances[msg.sender]) >= cars[_id].c_price);
        Customer storage customer = customers[msg.sender];
        customer.garage[_id] += 1;
        customer.garage_idx.push(_id);
        customer.c_num += 1;
        cars[_id].s_count += 1;

        if ((msg.value + balances[msg.sender]) > cars[_id].c_price)
            balances[msg.sender] += msg.value - cars[_id].c_price;

        uint256 f_price = cars[_id].earning * cars[_id].s_count + cars[_id].o_earning;
        if(f_price > cars[_id].s_price){
          cars[_id].c_price = f_price;
        }
        for (uint i = 0; i < yesBuyer[_id].length; ++i){
            address buyer = yesBuyer[_id][i];
            uint16 buy_count = cars[_id].c_owners[buyer];
            uint256 earned = cars[_id].earning * buy_count;
            balances[buyer] += earned;
            customers[buyer].earned += earned;

        }
        balances[owner] += cars[_id].c_price - cars[_id].earning * cars[_id].s_count;
        cars[_id].c_owners[msg.sender] +=1;
        if(cars[_id].c_owners[msg.sender] == 1){
          yesBuyer[_id].push(msg.sender);
        }
        BuyCarCompleted(msg.sender, cars[_id].c_price);
        return true;
    }

    function getMyCarsIdx() public view returns (uint256[]){
        Customer storage customer = customers[msg.sender];
        return customer.garage_idx;
    }

    function getMyCarsIdxCount(uint256 _id) public view returns (uint16){
        Customer storage customer = customers[msg.sender];
        return customer.garage[_id];
    }

    function getCustomer() public view returns (bytes32 _name,
                                                uint256 _balance,
                                                uint256 _earned,
                                                uint16 _c_num) {
        if (msg.sender != address(0)) {
            _name = customers[msg.sender].name;
            _balance = balances[msg.sender];
            _earned = customers[msg.sender].earned;
            _c_num = customers[msg.sender].c_num;
        }
        return (_name, _balance, _earned, _c_num);
    }

    function earnedOf(address _address) public view returns (uint256) {
        return customers[_address].earned;
    }

    function carnumOf(address _address) public view returns (uint16) {
        return customers[_address].c_num;
    }

    function getBalanceInEth(address addr) public view returns (uint256) {
  		return convert(getBalance(addr),2);
  	}

  	function getBalance(address addr) public view returns(uint256) {
  		return balances[addr];
  	}

    function getStoreBalance() onlyOwner public constant returns (uint256) {
        return this.balance;
    }

    function withdraw(uint256 _amount) public returns (bool) {

        require(_amount >= 0);
        require(_amount == uint256(uint128(_amount)));
        require(this.balance >= _amount);
        require(balances[msg.sender] >= _amount);

        if (_amount == 0)
            _amount = balances[msg.sender];

        balances[msg.sender] -= _amount;

        if (!msg.sender.send(_amount))
            balances[msg.sender] += _amount;
            return false;
        return true;

        EventCashOut(msg.sender, _amount);
    }

    function convert(uint256 amount,uint256 conversionRate) public pure returns (uint256 convertedAmount)
    {
      return amount * conversionRate;
    }


}