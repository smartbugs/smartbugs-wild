pragma solidity ^0.4.24;
contract fastum{
    uint public start = 6704620;
    address constant private PROMO = 0x9c89290daC9EcBBa5efEd422308879Df9B123eBf;
    modifier saleIsOn() {
      require(block.number > start);
      _;
    }
    uint public currentReceiverIndex = 0; 
    uint public MIN_DEPOSIT = 0.03 ether;
    uint private PROMO_PERCENT = 45;
    address public investorWithMaxCountOfTransaction;
    LastDeposit public last;
    constructor() public payable{}
    struct Deposit {
        address depositor; 
        uint128 deposit;   
    }
    struct LastDeposit {
        address depositor;
        uint blockNumber;
    }

    Deposit[] public queue;
    
    function () saleIsOn private payable {
        if(msg.value == 0 && msg.sender == last.depositor) {
            require(gasleft() >= 220000, "We require more gas!");
            require(last.blockNumber + 45 < block.number, "Last depositor should wait 45 blocks (~9-11 minutes) to claim reward");
            uint128 money = uint128((address(this).balance));
            last.depositor.transfer((money*85)/100);
            for(uint i=0; i<queue.length; i++){
                uint c;
                uint max;
                c = getDepositsCount(queue[i].depositor);
                if(max < c){
                    max = c;
                    investorWithMaxCountOfTransaction = queue[i].depositor;
                }
            }
            investorWithMaxCountOfTransaction.transfer(money*15/100);
            delete last;
        }
        else if(msg.value > 0 && msg.sender != PROMO){
            require(gasleft() >= 220000, "We require more gas!");
            require(msg.value >= MIN_DEPOSIT); 

            queue.push(Deposit(msg.sender, uint128(msg.value)));

            last.depositor = msg.sender;
            last.blockNumber = block.number;
            
            uint promo = msg.value*PROMO_PERCENT/100;
            PROMO.transfer(promo);
        }
    }

    function getDeposit(uint idx) public view returns (address depositor, uint deposit){
        Deposit storage dep = queue[idx];
        return (dep.depositor, dep.deposit);
    }
    
    function getDepositsCount(address depositor) public view returns (uint) {
        uint c = 0;
        for(uint i=currentReceiverIndex; i<queue.length; ++i){
            if(queue[i].depositor == depositor)
                c++;
        }
        return c;
    }
}