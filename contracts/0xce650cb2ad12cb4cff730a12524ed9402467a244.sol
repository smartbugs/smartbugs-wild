pragma solidity ^0.4.25;

contract IUserData {
    //set
    function setUserRef(address _address, address _refAddress, string _gameName) public;
    //get
    function getUserRef(address _address, string _gameName) public view returns (address);
}

contract Dice_BrickGame {
    IUserData userData = IUserData(address(0x21d364b66d9065B5207124e2b1e49e4193e0a2ff));

    //Setup Contract
    uint8 public FEE_PERCENT = 2;
    uint8 public JACKPOT_PERCENT = 1;
    uint constant MIN_JACKPOT = 0.1 ether;
    uint public JACKPOT_WIN = 1000;
    uint public MIN_BET = 0.01 ether;
    uint public MAX_BET = 1 ether;
    uint public MAX_PROFIT = 5 ether;
    uint public REF_PERCENT = 5;
    address public owner;
    address private bot;
    uint public jackpotFund;
    uint public resolve = 0;
    uint public payLoan = 0;

    struct Bet {
        uint blockNumber;
        address player;
        uint amount;
        bytes hexData;
    }

    struct Loan {
        address player;
        uint amount;
    }

    Bet[] public bets;
    Loan[] private loans;


    // Events
    event DiceBet(address indexed player, uint amount, uint blockNumber, bytes data, uint8 result, uint reward, uint16 jackpotNumber, uint indexed modulo);
    event Jackpot(address indexed player, uint amount);
    event JackpotIncrease(uint amount);
    event FailedPayment(address indexed beneficiary, uint amount);
    event Payment(address indexed beneficiary, uint amount);
    event Repayment(address indexed beneficiary, uint amount);

    constructor () public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "OnlyOwner can call.");
        _;
    }

    modifier onlyBot {
        require(msg.sender == bot || msg.sender == owner, "OnlyOwner can call.");
        _;
    }

    function() public payable {
        uint8 length = uint8(msg.data.length);
        require(length >= 2, "Wrong bet number!");
        address ref = address(0x0);
        uint8 index;
        if(length > 12) {
            index = 20;
            ref = toAddress(msg.data, 0);
            require(ref != msg.sender, "Reference must be different than sender");
        } else {
            index = 0;
        }
        uint8 modulo = uint8((msg.data[index] >> 4) & 0xF) * 10 + uint8(msg.data[index] & 0xF);
        require(modulo == 2 || modulo == 6 || modulo == 12 || modulo == 0, "Wrong modulo!");
        if (modulo == 0) {
            modulo = 100;
        }
        uint8[] memory number = new uint8[](length - index - 1);
        for (uint8 j = 0; j < length - index - 1; j++) {
            number[j] = uint8((msg.data[j + index + 1] >> 4) & 0xF) * 10 + uint8(msg.data[j + index + 1] & 0xF);
            if (modulo == 12) {
                require(number[j] > 1 && number[j] <= 12, "Two Dice Confirm!");
            } else {
                require(number[j] <= modulo, "Wrong number bet!");
                if (modulo != 100) {
                    require(number[j] > 0, "Wrong number bet!");
                }
            }
        }
        if (modulo == 100) {
            require(number[0] == 0 || number[0] == 1, "Etheroll Confirm!");
            require(number[1] > 1 && number[1] < 100, "Etheroll Confirm!");
        } else if (modulo == 12) {
            require(number.length < 11, "Much number bet!");
        } else {
            require(number.length < modulo, "Much number bet!");
        }
        require(msg.value >= MIN_BET && msg.value <= MAX_BET, "Value confirm!");
        uint winPossible;
        if (modulo == 100) {
            if (number[0] == 1) {
                winPossible = (100 - number[1]) / number[1] * msg.value * (100 - FEE_PERCENT - (msg.value >= MIN_JACKPOT ? 1 : 0)) / 100;
            } else {
                winPossible = (number[1] - 1) / (101 - number[1]) * msg.value * (100 - FEE_PERCENT - (msg.value >= MIN_JACKPOT ? 1 : 0)) / 100;
            }
        } else {
            if (modulo == 12) {
                winPossible = ((modulo - 1 - number.length) / number.length + 1) * msg.value * (100 - FEE_PERCENT - (msg.value >= MIN_JACKPOT ? 1 : 0)) / 100;
            } else {
                winPossible = ((modulo - number.length) / number.length + 1) * msg.value * (100 - FEE_PERCENT - (msg.value >= MIN_JACKPOT ? 1 : 0)) / 100;
            }

        }
        require(winPossible <= MAX_PROFIT);
        if(userData.getUserRef(msg.sender, "Dice") != address(0x0)) {
            userData.getUserRef(msg.sender, "Dice").transfer(msg.value * REF_PERCENT / 1000);
        } else if(ref != address(0x0)) {
            ref.transfer(msg.value * REF_PERCENT / 1000);
            userData.setUserRef(msg.sender, ref, "Dice");
        }
        bets.length++;
        bets[bets.length - 1].blockNumber = block.number;
        bets[bets.length - 1].player = msg.sender;
        bets[bets.length - 1].amount = msg.value;
        bets[bets.length - 1].hexData.length = length - index;
        for(j = 0; j < bets[bets.length - 1].hexData.length; j++){
            bets[bets.length - 1].hexData[j] = msg.data[j + index];
        }
    }

    function setBot(address _bot) public onlyOwner {
        require(_bot != address(0x0));
        bot = _bot;
    }

    function setConfig(uint8 _FEE_PERCENT, uint8 _JACKPOT_PERCENT, uint _MAX_PROFIT, uint _MIN_BET, uint _MAX_BET, uint _JACKPOT_WIN, uint8 _REF_PERCENT) public onlyOwner {
        FEE_PERCENT = _FEE_PERCENT;
        JACKPOT_PERCENT = _JACKPOT_PERCENT;
        MAX_PROFIT = _MAX_PROFIT;
        MIN_BET = _MIN_BET;
        MAX_BET = _MAX_BET;
        MAX_PROFIT = _MAX_PROFIT;
        JACKPOT_WIN = _JACKPOT_WIN;
        REF_PERCENT = _REF_PERCENT;
    }

    function increaseJackpot(uint increaseAmount) external onlyOwner {
        require(increaseAmount <= address(this).balance, "Not enough funds");
        jackpotFund += uint(increaseAmount);
        emit JackpotIncrease(jackpotFund);
    }

    function withdrawFunds(address beneficiary, uint withdrawAmount) external onlyOwner {
        require(withdrawAmount <= address(this).balance, "Not enough funds");
        require(jackpotFund + withdrawAmount <= address(this).balance, "Not enough funds.");
        sendFunds(beneficiary, withdrawAmount);
    }

    function kill() external onlyOwner {
        sendFunds(owner, address(this).balance);
        selfdestruct(owner);
    }


    function doBet(uint gameNumber) private {
        uint8 modulo = uint8((bets[gameNumber].hexData[0] >> 4) & 0xF) * 10 + uint8(bets[gameNumber].hexData[0] & 0xF);
        uint8 result;
        if (modulo == 12) {
            uint8 dice1 = uint8(keccak256(abi.encodePacked(bets[gameNumber].hexData, blockhash(bets[gameNumber].blockNumber)))) % 6;
            uint8 dice2 = uint8(keccak256(abi.encodePacked(address(this).balance, blockhash(bets[gameNumber].blockNumber), bets[gameNumber].player))) % 6;
            result = (dice1 == 0 ? 6 : dice1) + (dice2 == 0 ? 6 : dice2);
        } else {
            result = uint8(keccak256(abi.encodePacked(bets[gameNumber].hexData, address(this).balance, blockhash(bets[gameNumber].blockNumber), bets[gameNumber].player))) % modulo;
        }
        if (result == 0) {
            result = modulo;
        }
        uint winValue = 0;
        uint8[] memory number = new uint8[](bets[gameNumber].hexData.length - 1);
        for (uint8 j = 0; j < bets[gameNumber].hexData.length - 1; j++) {
            number[j] = uint8((bets[gameNumber].hexData[j + 1] >> 4) & 0xF) * 10 + uint8(bets[gameNumber].hexData[j + 1] & 0xF);
        }

        for (uint8 i = 0; i < number.length; i++) {
            if (number[i] == result) {
                if (modulo == 12) {
                    winValue = bets[gameNumber].amount * (100 - FEE_PERCENT) / 100 + (modulo - 1 - number.length) * bets[gameNumber].amount * (100 - FEE_PERCENT) / (100 * number.length);
                } else {
                    winValue = bets[gameNumber].amount * (100 - FEE_PERCENT) / 100 + (modulo - number.length) * bets[gameNumber].amount * (100 - FEE_PERCENT) / (100 * number.length);
                }
                break;
            }
        }
        if (bets[gameNumber].amount >= MIN_JACKPOT) {
            jackpotFund += bets[gameNumber].amount * JACKPOT_PERCENT / 100;
            emit JackpotIncrease(jackpotFund);
            if (winValue != 0) {
                winValue = bets[gameNumber].amount * (100 - FEE_PERCENT - JACKPOT_PERCENT) / 100 + (modulo - number.length) * bets[gameNumber].amount * (100 - FEE_PERCENT - JACKPOT_PERCENT) / (100 * number.length);
            }
            uint16 jackpotNumber = uint16(uint(keccak256(abi.encodePacked(bets[gameNumber].player, winValue, blockhash(bets[gameNumber].blockNumber), bets[gameNumber].hexData))) % JACKPOT_WIN);
            if (jackpotNumber == 999) {
                emit Jackpot(bets[gameNumber].player, jackpotFund);
                sendFunds(bets[gameNumber].player, jackpotFund + winValue);
                jackpotFund = 0;
            } else {
                if (winValue > 0) {
                    sendFunds(bets[gameNumber].player, winValue);
                }
            }
        } else {
            if (winValue > 0) {
                sendFunds(bets[gameNumber].player, winValue);
            }
        }
        emit DiceBet(bets[gameNumber].player, bets[gameNumber].amount, bets[gameNumber].blockNumber, bets[gameNumber].hexData, result, winValue, jackpotNumber, modulo);
    }

    function etheRoll(uint gameNumber) private {
        uint8 result = uint8(keccak256(abi.encodePacked(bets[gameNumber].hexData, blockhash(bets[gameNumber].blockNumber), bets[gameNumber].player))) % 100;
        if (result == 0) {
            result = 100;
        }
        uint winValue = 0;

        uint8[] memory number = new uint8[](bets[gameNumber].hexData.length - 1);
        for (uint8 j = 0; j < bets[gameNumber].hexData.length - 1; j++) {
            number[j] = uint8((bets[gameNumber].hexData[j + 1] >> 4) & 0xF) * 10 + uint8(bets[gameNumber].hexData[j + 1] & 0xF);
        }

        if (number[0] == 0 && number[1] >= result) {
            winValue = bets[gameNumber].amount * (100 - FEE_PERCENT) / 100 + (100 - uint(number[1])) * bets[gameNumber].amount * (100 - FEE_PERCENT) / (100 * uint(number[1]));
        }
        if (number[0] == 1 && number[1] <= result) {
            winValue = bets[gameNumber].amount * (100 - FEE_PERCENT) / 100 + (uint(number[1]) - 1) * bets[gameNumber].amount * (100 - FEE_PERCENT) / (100 * (101 - uint(number[1])));
        }
        if (bets[gameNumber].amount >= MIN_JACKPOT) {
            jackpotFund += bets[gameNumber].amount * JACKPOT_PERCENT / 100;
            emit JackpotIncrease(jackpotFund);
            if (number[0] == 0 && number[1] >= result) {
                winValue = bets[gameNumber].amount * (100 - FEE_PERCENT - JACKPOT_PERCENT) / 100 + (100 - uint(number[1])) * bets[gameNumber].amount * (100 - FEE_PERCENT - JACKPOT_PERCENT) / (100 * uint(number[1]));
            }
            if (number[0] == 1 && number[1] <= result) {
                winValue = bets[gameNumber].amount * (100 - FEE_PERCENT - JACKPOT_PERCENT) / 100 + (uint(number[1]) - 1) * bets[gameNumber].amount * (100 - FEE_PERCENT - JACKPOT_PERCENT) / (100 * (101 - uint(number[1])));
            }
            uint16 jackpotNumber = uint16(uint(keccak256(abi.encodePacked(bets[gameNumber].hexData, winValue, blockhash(bets[gameNumber].blockNumber), bets[gameNumber].player))) % JACKPOT_WIN);
            if (jackpotNumber == 999) {
                emit Jackpot(bets[gameNumber].player, jackpotFund);
                sendFunds(bets[gameNumber].player, jackpotFund + winValue);
                jackpotFund = 0;
            } else {
                if (winValue > 0) {
                    sendFunds(bets[gameNumber].player, winValue);
                }
            }
        } else {
            if (winValue > 0) {
                sendFunds(bets[gameNumber].player, winValue);
            }
        }

        emit DiceBet(bets[gameNumber].player, bets[gameNumber].amount, bets[gameNumber].blockNumber, bets[gameNumber].hexData, result, winValue, jackpotNumber, 100);
    }

    function resolveBet() public onlyBot {
        uint i = 0;
        for (uint k = resolve; k < bets.length; k++) {
            uint8 modulo = uint8((bets[k].hexData[0] >> 4) & 0xF) * 10 + uint8(bets[k].hexData[0] & 0xF);
            if (modulo == 0) {
                modulo = 100;
            }

            if (bets[k].blockNumber <= (block.number - 1)) {
                if (modulo == 100) {
                    etheRoll(k);
                    i++;
                } else {
                    doBet(k);
                    i++;
                }
            } else {
                break;
            }
        }
        resolve += i;
    }

    function addBalance() public payable {}


    function sendFunds(address beneficiary, uint amount) private {
        if (beneficiary.send(amount)) {
            emit Payment(beneficiary, amount);
        } else {
            emit FailedPayment(beneficiary, amount);
            loans.push(Loan(beneficiary, amount));
        }
    }

    function payLoan() public onlyBot {
        uint pay = 0;
        for (uint i = payLoan; i < loans.length; i++) {
            if (loans[i].player.send(loans[i].amount)) {
                emit Repayment(loans[i].player, loans[i].amount);
                pay++;
            } else {
                break;
            }
        }
        payLoan += pay;
    }

    function getLengthBets() public view returns (uint) {
        return bets.length;
    }
    function toAddress(bytes _bytes, uint _start) internal  pure returns (address) {
        require(_bytes.length >= (_start + 20),"Wrong size!");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }
}