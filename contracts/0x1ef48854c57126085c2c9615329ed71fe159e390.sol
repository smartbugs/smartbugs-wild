pragma solidity ^0.4.25;

/**
  CRYPTOMAN
  
  EN:
  1. Fixed deposit - 0.05 Ether.
     The number of deposits from one address is not limited.
  2. The round consists of 10 deposits. At the end of the round, each participant
     gets either 150% of the deposit, or insurance compensation 30% of the
     deposit.
  3. Payments are made gradually - with each new deposit several payments are sent
     to the participants of the previous round. If the participant does
     not want to wait for a payout, he can send 0 Ether and get all his winnings.
  4. The prize fund is calculated as 7% of all deposits. To get the whole
     prize fund, it is necessary that after the participant no one invested during
     42 blocks (~ 10 minutes) and after that the participant needs to send
     0 Ether in 10 minutes.
  5. A participant may at any time withdraw their deposits made in the current round.
     Fees will not be refunded. To do this, the participant should to send
     0.0112 ETH to the contract address.

  GAS LIMIT 300000
  
  RU:
  1. Сумма депозита фиксированная - 0.05 Ether.
     Количество депозитов с одного адреса не ограничено.
  2. Раунд состоит из 10 депозитов. По окончании раунда каждому участнику
     производится начисление - либо 150% от депозита, либо страховое возмещение
     30% от депозита.
  3. Выплаты производятся постепенно - с каждым новым депозитом отправляется
     несколько выплат участникам предыдущего раунда. Если участник не
     хочет ждать выплату, он может отправить 0 Ether и получить все свои выигрыши.
  4. Призовой фонд рассчитывается как 7% от депозитов. Чтобы получить весь
     призовой фонд, нужно, чтобы после участника никто не вкладывался в течение
     42 блоков (~10 минут) и чтобы он отправил 0 Ether через 10 минут.
  5. Участник может в любое время вернуть свои депозиты, сделанные в текущем раунде.
     Комиссии возвращены не будут. Для этого участник должен отправить 0.0112
     ETH на адрес контракта.

  ЛИМИТ ГАЗА 300000
*/

contract Cryptoman {
    uint public depositValue = 0.05 ether;
    uint public returnDepositValue = 0.0112 ether;
    uint public places = 10;
    uint public winPlaces = 5;
    uint public winPercent = 150;
    uint public supportFee = 3;
    uint public prizeFee = 7;
    uint public winAmount = depositValue * winPercent / 100;
    uint public insuranceAmount = (depositValue * places * (100 - supportFee - prizeFee) / 100 - winAmount * winPlaces) / (places - winPlaces);
    uint public blocksBeforePrize = 42;
    uint public prize;
    address public lastInvestor;
    uint public lastInvestedAt;
    uint public currentRound;
    mapping (uint => address[]) public placesMap;
    mapping (uint => uint) public winners;
    uint public currentPayRound;
    uint public currentPayIndex;
    address public support1 = 0xD71C0B80E2fDF33dB73073b00A92980A7fa5b04B;
    address public support2 = 0x7a855307c008CA938B104bBEE7ffc94D3a041E53;
    
    uint private seed;
    
    // uint256 to bytes32
    function toBytes(uint256 x) internal pure returns (bytes b) {
        b = new bytes(32);
        assembly {
            mstore(add(b, 32), x)
        }
    }
    
    // returns a pseudo-random number
    function random(uint lessThan) internal returns (uint) {
        seed += block.timestamp + uint(msg.sender);
        return uint(sha256(toBytes(uint(blockhash(block.number - 1)) + seed))) % lessThan;
    }
    
    // removes item and shifts other items
    function removePlace(uint index) internal {
        if (index >= placesMap[currentRound].length) return;

        for (uint i = index; i < placesMap[currentRound].length - 1; i++) {
            placesMap[currentRound][i] = placesMap[currentRound][i + 1];
        }
        placesMap[currentRound].length--;
    }
    
    function placesLeft() external view returns (uint) {
        return places - placesMap[currentRound].length;
    }
    
    function processQueue() internal {
        while (gasleft() >= 50000 && currentPayRound < currentRound) {
            uint winner = winners[currentPayRound];
            uint index = (winner + currentPayIndex) % places;
            address investor = placesMap[currentPayRound][index];
            investor.transfer(currentPayIndex < winPlaces ? winAmount : insuranceAmount);
            delete placesMap[currentPayRound][index];
            
            if (currentPayIndex == places - 1) {
                currentPayIndex = 0;
                currentPayRound++;
            } else {
                currentPayIndex++;
            }
        }
    }
    
    function () public payable {
        require(gasleft() >= 250000);
        
        if (msg.value == depositValue) {
            placesMap[currentRound].push(msg.sender);
            if (placesMap[currentRound].length == places) {
                winners[currentRound] = random(places);
                currentRound++;
            }
            
            lastInvestor = msg.sender;
            lastInvestedAt = block.number;
            uint fee = msg.value * supportFee / 200;
            support1.transfer(fee);
            support2.transfer(fee);
            prize += msg.value * prizeFee / 100;
            
            processQueue();
        } else if (msg.value == returnDepositValue) {
            uint depositCount;
            
            uint i = 0;
            while (i < placesMap[currentRound].length) {
                if (placesMap[currentRound][i] == msg.sender) {
                    depositCount++;
                    removePlace(i);
                } else {
                    i++;
                }
            }
            
            require(depositCount > 0);
            
            if (msg.sender == lastInvestor) {
                delete lastInvestor;
            }
            
            prize += msg.value;
            msg.sender.transfer(depositValue * (100 - supportFee - prizeFee) / 100 * depositCount);
        } else if (msg.value == 0) {
            if (lastInvestor == msg.sender && block.number >= lastInvestedAt + blocksBeforePrize) {
                lastInvestor.transfer(prize);
                delete prize;
                delete lastInvestor;
            }
            
            processQueue();
        } else {
            revert();
        }
    }
}