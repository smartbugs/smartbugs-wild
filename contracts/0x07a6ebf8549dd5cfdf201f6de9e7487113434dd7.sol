pragma solidity ^0.4.25;

library SafeMath {

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0);
        uint256 c = _a / _b;

        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }


  function owner() public view returns(address) {
    return _owner;
  }


  modifier onlyOwner() {
    require(isOwner());
    _;
  }


  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }


  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract Multiplier is Ownable {
    using SafeMath for uint;

    //Address for promo expences
    address constant private support = 0x8Fa6E56c844be9B96C30B72cC2a8ccF6465a99F9;
    //Percent for promo expences
    uint constant public supportPercent = 3;

    uint public reserved;
    uint public delayed;

    uint minCycle  = 5 minutes;
    uint initCycle = 2 hours;
    uint maxCycle  = 1 days;

    uint public cycleStart;
    uint public actualCycle;
    uint public lastCycle;
    uint public cycles;

    uint minPercent = 1;
    uint maxPercent = 33;

    uint frontier = 50;

    mapping (address => address) referrer;
    mapping (address => bool) verified;

    uint refBonus = 5;

    uint verificationPrice = 0.0303 ether;

    event NewCycle(uint start, uint duration, uint indexed cycle);
    event NewDeposit(address indexed addr, uint idx, uint amount, uint profit, uint indexed cycle);
    event Payed(address indexed addr, uint amount, uint indexed cycle);
    event Refunded(address indexed addr, uint amount, uint indexed cycle);
    event RefundCompleted(uint indexed cycle);
    event RefVerified(address indexed addr);
    event RefBonusPayed(address indexed investor, address referrer, uint amount, uint level);
    event VerPriceChanged(uint oldPrice, uint newPrice);


    constructor() public {
        verified[owner()] = true;
        actualCycle = initCycle * 2;
        queue.length += 1;
    }

    //The deposit structure holds all the info about the deposit made
    struct Deposit {
        address depositor; //The depositor address
        uint128 deposit;   //The deposit amount
        uint128 expect;    //How much we should pay out
    }

    Deposit[] public queue;  //The queue
    uint public currentReceiverIndex = 0; //The index of the first depositor in the queue. The receiver of investments!
    uint public currentRefundIndex = 0;

    function bytesToAddress(bytes _source) internal pure returns(address parsedreferrer) {
        assembly {
            parsedreferrer := mload(add(_source,0x14))
        }
        return parsedreferrer;
    }

    function setRef() internal returns(bool) {
        address _referrer = bytesToAddress(bytes(msg.data));
        if (_referrer != msg.sender && msg.data.length == 20 && verified[_referrer]) {
            referrer[msg.sender] = _referrer;
            return true;
        }
    }

    function setVerificationPrice(uint newPrice) external onlyOwner {
        emit VerPriceChanged(verificationPrice, newPrice);
        verificationPrice = newPrice;
    }

    function verify(address addr) public payable {
        if (msg.sender != owner()) {
            require(msg.value == verificationPrice);
            support.send(verificationPrice);
        }
        verified[addr] = true;
        emit RefVerified(addr);
    }

    //This function receives all the deposits
    //stores them and make immediate payouts
    function () public payable {
        //check if sender is not a smart contract
        require(!isContract(msg.sender));

        if(msg.value == verificationPrice) {
            verify(msg.sender);
            return;
        }

        if (msg.value == 0 && msg.sender == owner()) {
            address a = bytesToAddress(bytes(msg.data));
            verify(a);
            return;
        }

        if (referrer[msg.sender] == address(0)) {
            require(setRef());
        }

        if(msg.value > 0){
            require(gasleft() >= 300000, "We require more gas!"); //We need gas to process queue
            require(msg.value <= 10 ether); //Do not allow too big investments to stabilize payouts

            if (block.timestamp >= cycleStart + actualCycle) {
                if (queue.length.sub(lastCycle) >= frontier) {
                    actualCycle = actualCycle * 2;
                    if (actualCycle > maxCycle) {
                        actualCycle = maxCycle;
                    }
                } else {
                    actualCycle = actualCycle / 2;

                    if (actualCycle < minCycle) {
                        actualCycle = minCycle;
                    }
                }

                uint amountOfPlayers = queue.length - lastCycle;
                lastCycle = queue.length;
                cycleStart = block.timestamp;
                currentReceiverIndex = lastCycle;
                cycles++;

                if (amountOfPlayers != 1) {
                    currentRefundIndex = lastCycle.sub(1);
                    refunding();
                } else {
                    singleRefunding();
                }

                emit NewCycle(cycleStart, actualCycle, cycles);
            }

            if (currentRefundIndex != 0) {
                refunding();
            }

            //Add the investor into the queue. Mark that he expects to receive 121% of deposit back
            uint percent = queue.length.sub(lastCycle).add(1);
            if (percent >= 33) {
                percent = 33;
            }

            queue.push(Deposit(msg.sender, uint128(msg.value), uint128(msg.value * (100 + percent) / 100)));

            //Send fee
            uint _support = msg.value * supportPercent / 100;
            support.send(_support);
            uint _refBonus = msg.value * refBonus / 1000;
            referrer[msg.sender].send(_refBonus);
            emit RefBonusPayed(msg.sender, referrer[msg.sender], _refBonus, 1);
            if (referrer[referrer[msg.sender]] != address(0)) {
                referrer[referrer[msg.sender]].send(_refBonus);
                emit RefBonusPayed(msg.sender, referrer[referrer[msg.sender]], _refBonus, 2);
            }

            emit NewDeposit(msg.sender, queue.length - 1, msg.value, msg.value * (100 + percent) / 100, cycles);

            if (currentRefundIndex == 0) {
                reserved += msg.value * 96 / 100 / 2;
                if (delayed != 0) {
                    reserved != delayed;
                    delayed = 0;
                }
                //Pay to first investors in line
                pay();
            } else {
                delayed += msg.value * 96 / 100 / 2;
            }

        }
    }

    //Used to pay to current investors
    //Each new transaction processes 1 - 4+ investors in the head of queue
    //depending on balance and gas left
    function pay() private {
        //Try to send all the money on contract to the first investors in line
        uint128 money = uint128(address(this).balance - reserved);

        //We will do cycle on the queue
        for(uint i=0; i<queue.length; i++){

            uint idx = currentReceiverIndex + i;  //get the index of the currently first investor

            Deposit storage dep = queue[idx]; //get the info of the first investor

            if(money >= dep.expect){  //If we have enough money on the contract to fully pay to investor
                dep.depositor.send(dep.expect); //Send money to him
                money -= dep.expect;            //update money left

                emit Payed(dep.depositor, dep.expect, cycles);

                //this investor is fully paid, so remove him
                delete queue[idx];
            }else{
                //Here we don't have enough money so partially pay to investor
                dep.depositor.send(money); //Send to him everything we have
                dep.expect -= money;       //Update the expected amount

                emit Payed(dep.depositor, money, cycles);

                break;                     //Exit cycle
            }

            if(gasleft() <= 50000)         //Check the gas left. If it is low, exit the cycle
                break;                     //The next investor will process the line further
        }

        currentReceiverIndex += i; //Update the index of the current first investor
    }

    function refunding() private {

        uint128 refund = uint128(reserved);
        if (refund >= 1 ether) {
            refund -= 1 ether;
        }

        for(uint i=0; i<=currentRefundIndex; i++){

            uint idx = currentRefundIndex.sub(i);

            Deposit storage dep = queue[idx];

            if (lastCycle.sub(idx) <= 33) {
                uint percent = lastCycle - idx;
            } else {
                percent = 33;
            }

            uint128 amount = uint128(dep.deposit + (dep.deposit * percent / 100));

            if(refund > amount){
                dep.depositor.send(amount);
                refund -= amount;
                reserved -= amount;

                emit Refunded(dep.depositor, amount, cycles - 1);
                delete queue[idx];
            }else{
                dep.depositor.send(refund);
                reserved -= refund;
                currentRefundIndex = 0;

                emit Refunded(dep.depositor, refund, cycles - 1);
                emit RefundCompleted(cycles - 1);
                break;
            }

            if(gasleft() <= 100000)
                break;
        }

        if (currentRefundIndex != 0) {
            currentRefundIndex -= i;
        }
    }

    function singleRefunding() private {
        Deposit storage dep = queue[queue.length - 1];
        uint amount = dep.deposit * 2 / 100 + dep.expect;
        if (reserved < amount) {
            amount = reserved;
        }
        dep.depositor.send(amount);
        reserved -= amount;
        emit Refunded(dep.depositor, amount, cycles - 1);
        delete queue[queue.length - 1];
        emit RefundCompleted(cycles - 1);
    }

    //Get the deposit info by its index
    //You can get deposit index from
    function getDeposit(uint idx) public view returns (address depositor, uint deposit, uint expect){
        Deposit storage dep = queue[idx];
        return (dep.depositor, dep.deposit, dep.expect);
    }

    //Get the count of deposits of specific investor
    function getDepositsCount(address depositor) public view returns (uint) {
        uint c = 0;
        for(uint i=currentReceiverIndex; i<queue.length; ++i){
            if(queue[i].depositor == depositor)
                c++;
        }
        return c;
    }

    //Get all deposits (index, deposit, expect) of a specific investor
    function getDeposits(address depositor) public view returns (uint[] idxs, uint128[] deposits, uint128[] expects) {
        uint c = getDepositsCount(depositor);

        idxs = new uint[](c);
        deposits = new uint128[](c);
        expects = new uint128[](c);

        if(c > 0) {
            uint j = 0;
            for(uint i=currentReceiverIndex; i<queue.length; ++i){
                Deposit storage dep = queue[i];
                if(dep.depositor == depositor){
                    idxs[j] = i;
                    deposits[j] = dep.deposit;
                    expects[j] = dep.expect;
                    j++;
                }
            }
        }
    }

    //Get current queue size
    function getQueueLength() public view returns (uint) {
        return queue.length - currentReceiverIndex;
    }

    function isContract(address addr) private view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function contractBalance() external view returns(uint) {
        return address(this).balance;
    }

}