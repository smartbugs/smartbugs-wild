pragma solidity ^0.4.24;

/**
__          ___               _          __    ___       ____  _ _            _
\ \        / / |             | |        / _|  / _ \     |  _ \(_) |          (_)
 \ \  /\  / /| |__   ___  ___| |   ___ | |_  | | | |_  _| |_) |_| |_ ___ ___  _ _ __
  \ \/  \/ / | '_ \ / _ \/ _ \ |  / _ \|  _| | | | \ \/ /  _ <| | __/ __/ _ \| | '_ \
   \  /\  /  | | | |  __/  __/ | | (_) | |   | |_| |>  <| |_) | | || (_| (_) | | | | |
    \/  \/   |_| |_|\___|\___|_|  \___/|_|    \___//_/\_\____/|_|\__\___\___/|_|_| |_|

                                  `.-::::::::::::-.`
                           .:::+:-.`            `.-:+:::.
                      `::::.   `-                  -`   .:::-`
                   .:::`        :         J        :        `:::.
                `:/-            `-        A       -`            -/:`
              ./:`               :        C      `:               `:/.
            .+:                   :       K      :                  `:+.
          `/-`..`                 -`      P     `-                 `..`-/`
         :/`    ..`                :      O     :                `..    `/:
       `+.        ..`              -`     T    `-              `..        .+`
      .+`           ..`             :          :             `..           `+.
     -+               ..`           -.        ..           `..               +-
    .+                 `..`          :        :          `..                  +.
   `o                    `..`        ..      ..        `..`                    o`
   o`                      `..`     `./------/.`     `..`                      `o
  -+``                       `..``-::.````````.::-``..`                       ``+-
  s```....````                 `+:.  ..------..  .:+`                 ````....```o
 .+       ````...````         .+. `--``      ``--` .+.         ````...````       +.
 +.              ````....`````+` .:`            `:. `o`````....````              ./
 o                       ````s` `/                /` `s````                       o
 s                           s  /`                .:  s                           s
 s                           s  /`       0xB      `/  s                           s
 s                        ```s` `/                /` `s```                        o
 +.               ````....```.+  .:`            `:.  +.```....````               .+
 ./        ```....````        -/` `--`        `--` `/.        ````....```        +.
  s````....```                 .+:` `.--------.` `:+.                 ```....````s
  :/```                       ..`.::-.``    ``.-::.`..                       ```/:
   o`                       ..`     `-/-::::-/-`     `..                       `o
   `o                     ..`        ..      ..        `..                     o`
    -/                  ..`          :        :          `..                  /-
     -/               ..`           ..        ..           `..               /-
      -+`           ..`             :          :             `-.           `+-
       .+.        .-`              -`          ..              `-.        .+.
         /:     .-`                :            :                `-.    `:/
          ./- .-`                 -`            `-                 `-. -/.
            -+-                   :              :                   :+-
              -/-`               -`              `-               `-/-
                .:/.             :                :             ./:.
                   -:/-         :                  :         -/:-
                      .:::-`   `-                  -`   `-:::.
                          `-:::+-.`              `.:+:::-`
                                `.-::::::::::::::-.`

---Design---
Jörmungandr

---Contract and Frontend---
Mr Fahrenheit
Jörmungandr

---0xBitcoin Specialist---
Mr Fahrenheit

---Contract Auditor---
8 ฿ł₮ ₮Ɽł₱

---Contract Advisors---
Etherguy
Norsefire

**/

contract ERC20Interface
{
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract WheelOf0xBitcoin {
    using SafeMath for uint;

    //  Modifiers

    modifier nonContract() {                // contracts pls go
        require(tx.origin == msg.sender);
        _;
    }

    modifier gameActive() {
        require(gamePaused == false);
        _;
    }

    modifier onlyAdmin(){
        require(msg.sender == admin);
        _;
    }

    // Events

    event onDeposit(
        address indexed customerAddress,
        uint256 tokensIn,
        uint256 contractBal,
        uint256 devFee,
        uint timestamp
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 tokensOut,
        uint256 contractBal,
        uint timestamp
    );

    event spinResult(
        address indexed customerAddress,
        uint256 wheelNumber,
        uint256 outcome,
        uint256 tokensSpent,
        uint256 tokensReturned,
        uint256 userBalance,
        uint timestamp
    );

    uint256 _seed;
    address admin;
    bool public gamePaused = false;
    uint256 minBet = 100000000;
    uint256 maxBet = 500000000000;
    uint256 devFeeBalance = 0;

    uint8[10] brackets = [1,3,6,12,24,40,56,68,76,80];

    struct playerSpin {
        uint256 betAmount;
        uint48 blockNum;
    }

    mapping(address => playerSpin) public playerSpins;
    mapping(address => uint256) internal personalFactorLedger_;
    mapping(address => uint256) internal balanceLedger_;

    uint256 internal globalFactor = 10e21;
    uint256 constant internal constantFactor = 10e21 * 10e21;
    address public tokenAddress = 0xB6eD7644C69416d67B522e20bC294A9a9B405B31;

    constructor()
        public
    {
        admin = msg.sender;
    }


    function getBalance()
        public
        view
        returns (uint256)
    {
        return ERC20Interface(tokenAddress).balanceOf(this);
    }


    //deposit needs approval from token contract
    function deposit(address _customerAddress, uint256 amount)
        public
        gameActive
    {
        require(tx.origin == _customerAddress);
        require(amount >= (minBet * 2));
        require(ERC20Interface(tokenAddress).transferFrom(_customerAddress, this, amount), "token transfer failed");
        // Add 4% fee of the buy to devFeeBalance
        uint256 devFee = amount / 33;
        devFeeBalance = devFeeBalance.add(devFee);
        // Adjust ledgers while taking the dev fee into account
        balanceLedger_[_customerAddress] = tokenBalanceOf(_customerAddress).add(amount).sub(devFee);
        personalFactorLedger_[_customerAddress] = constantFactor / globalFactor;

        emit onDeposit(_customerAddress, amount, getBalance(), devFee, now);
    }


    function receiveApproval(address receiveFrom, uint256 amount, address tknaddr, bytes data)
      public
    {
        if (uint(data[0]) == 0) {
          deposit(receiveFrom, amount);
        } else {
          depositAndSpin(receiveFrom, amount);
        }
    }


    //withdraw from contract
    function withdraw(uint256 amount)
      public
    {
        address _customerAddress = msg.sender;
        require(amount <= tokenBalanceOf(_customerAddress));
        require(amount > 0);
        if(!ERC20Interface(tokenAddress).transfer(_customerAddress, amount))
            revert();
        balanceLedger_[_customerAddress] = tokenBalanceOf(_customerAddress).sub(amount);
        personalFactorLedger_[_customerAddress] = constantFactor / globalFactor;
        emit onWithdraw(_customerAddress, amount, getBalance(), now);
    }


    function withdrawAll()
        public
    {
        address _customerAddress = msg.sender;
        // Set the sell amount to the user's full balance, don't sell if empty
        uint256 amount = tokenBalanceOf(_customerAddress);
        require(amount > 0);
        // Transfer balance and update user ledgers
        if(!ERC20Interface(tokenAddress).transfer(_customerAddress, amount))
            revert();
        balanceLedger_[_customerAddress] = 0;
        personalFactorLedger_[_customerAddress] = constantFactor / globalFactor;
        emit onWithdraw(_customerAddress, amount, getBalance(), now);
    }


    function tokenBalanceOf(address _customerAddress)
        public
        view
        returns (uint256)
    {
        // Balance ledger * personal factor * globalFactor / constantFactor
        return balanceLedger_[_customerAddress].mul(personalFactorLedger_[_customerAddress]).mul(globalFactor) / constantFactor;
    }


    function spinTokens(uint256 betAmount)
        public
        nonContract
        gameActive
    {
        address _customerAddress = msg.sender;
        // User must have enough eth
        require(tokenBalanceOf(_customerAddress) >= betAmount);
        // User must bet at least the minimum
        require(betAmount >= minBet);
        // If the user bets more than maximum...they just bet the maximum
        if (betAmount > maxBet){
            betAmount = maxBet;
        }
        // User cannot bet more than 10% of available pool
        if (betAmount > betPool(_customerAddress)/10) {
            betAmount = betPool(_customerAddress)/10;
        }
        // Execute the bet and return the outcome
        startSpin(betAmount, _customerAddress);
    }


    function spinAll()
        public
        nonContract
        gameActive
    {
        address _customerAddress = msg.sender;
        // set the bet amount to the user's full balance
        uint256 betAmount = tokenBalanceOf(_customerAddress);
        // User cannot bet more than 10% of available pool
        if (betAmount > betPool(_customerAddress)/10) {
            betAmount = betPool(_customerAddress)/10;
        }
        // User must bet more than the minimum
        require(betAmount >= minBet);
        // If the user bets more than maximum...they just bet the maximum
        if (betAmount >= maxBet){
            betAmount = maxBet;
        }
        // Execute the bet and return the outcome
        startSpin(betAmount, _customerAddress);
    }


    //deposit needs approval from token contract
    function depositAndSpin(address _customerAddress, uint256 betAmount)
        public
        gameActive
    {
        require(tx.origin == _customerAddress);
        require(betAmount >= (minBet * 2));
        require(ERC20Interface(tokenAddress).transferFrom(_customerAddress, this, betAmount), "token transfer failed");
        // Add 4% fee of the buy to devFeeBalance
        uint256 devFee = betAmount / 33;
        devFeeBalance = devFeeBalance.add(devFee);
        // Adjust ledgers while taking the dev fee into account
        balanceLedger_[_customerAddress] = tokenBalanceOf(_customerAddress).add(betAmount).sub(devFee);
        personalFactorLedger_[_customerAddress] = constantFactor / globalFactor;

        emit onDeposit(_customerAddress, betAmount, getBalance(), devFee, now);

        betAmount = betAmount.sub(devFee);
        // If the user bets more than maximum...they just bet the maximum
        if (betAmount >= maxBet){
            betAmount = maxBet;
        }
        // User cannot bet more than 10% of available pool
        if (betAmount > betPool(_customerAddress)/10) {
            betAmount = betPool(_customerAddress)/10;
        }
        // Execute the bet while taking the dev fee into account, and return the outcome
        startSpin(betAmount, _customerAddress);
    }


    function betPool(address _customerAddress)
        public
        view
        returns (uint256)
    {
        // Balance of contract, minus eth balance of user and accrued dev fees
        return getBalance().sub(tokenBalanceOf(_customerAddress)).sub(devFeeBalance);
    }

    /*
        panicButton and refundUser are here incase of an emergency, or launch of a new contract
        The game will be frozen, and all token holders will be refunded
    */

    function panicButton(bool newStatus)
        public
        onlyAdmin
    {
        gamePaused = newStatus;
    }


    function refundUser(address _customerAddress)
        public
        onlyAdmin
    {
        uint256 withdrawAmount = tokenBalanceOf(_customerAddress);
        if(!ERC20Interface(tokenAddress).transfer(_customerAddress, withdrawAmount))
            revert();
        balanceLedger_[_customerAddress] = 0;
	      personalFactorLedger_[_customerAddress] = constantFactor / globalFactor;
        emit onWithdraw(_customerAddress, withdrawAmount, getBalance(), now);
    }


    function updateMinBet(uint256 newMin)
        public
        onlyAdmin
    {
        require(newMin > 0);
        minBet = newMin;
    }


    function updateMaxBet(uint256 newMax)
        public
        onlyAdmin
    {
        require(newMax > 0);
        maxBet = newMax;
    }


    function getDevBalance()
        public
        view
        returns (uint256)
    {
        return devFeeBalance;
    }


    function withdrawDevFees()
        public
    {
        address fahrenheit = 0x7e7e2bf7EdC52322ee1D251432c248693eCd9E0f;
        address jormun = 0xf14BE3662FE4c9215c27698166759Db6967De94f;
        uint256 initDevBal = devFeeBalance;
        if(!ERC20Interface(tokenAddress).transfer(fahrenheit, devFeeBalance/2))
          revert();
        if(!ERC20Interface(tokenAddress).transfer(jormun, devFeeBalance/2))
          revert();
        devFeeBalance = devFeeBalance.sub(initDevBal/2);
        devFeeBalance = devFeeBalance.sub(initDevBal/2);
    }


    function finishSpin(address _customerAddress)
        public
        returns (uint256)
    {
        return _finishSpin(_customerAddress);
    }


    // Internal Functions


    function startSpin(uint256 betAmount, address _customerAddress)
        internal
    {
        playerSpin memory spin = playerSpins[_customerAddress];
        require(block.number != spin.blockNum);

        if (spin.blockNum != 0) {
            _finishSpin(_customerAddress);
        }
        lose(_customerAddress, betAmount);
        playerSpins[_customerAddress] = playerSpin(uint256(betAmount), uint48(block.number));
    }


    function _finishSpin(address _customerAddress)
        internal
        returns (uint256 resultNum)
    {
        playerSpin memory spin = playerSpins[_customerAddress];
        require(block.number != spin.blockNum);

        uint result;
        if (block.number - spin.blockNum > 255) {
            resultNum = 80;
            result = 9; // timed out :(
            return resultNum;
        } else {
            resultNum = random(80, spin.blockNum, _customerAddress);
            result = determinePrize(resultNum);
        }

        uint256 betAmount = spin.betAmount;
        uint256 returnedAmount;

        if (result < 5)                                             // < 5 = WIN
        {
            uint256 wonAmount;
            if (result == 0){                                       // Grand Jackpot
                wonAmount = betAmount.mul(9) / 10;                  // +90% of original bet
            } else if (result == 1){                                // Jackpot
                wonAmount = betAmount.mul(8) / 10;                  // +80% of original bet
            } else if (result == 2){                                // Grand Prize
                wonAmount = betAmount.mul(7) / 10;                  // +70% of original bet
            } else if (result == 3){                                // Major Prize
                wonAmount = betAmount.mul(6) / 10;                  // +60% of original bet
            } else if (result == 4){                                // Minor Prize
                wonAmount = betAmount.mul(3) / 10;                  // +30% of original bet
            }
            returnedAmount = betAmount.add(wonAmount);
        } else if (result == 5){                                    // 5 = Refund
            returnedAmount = betAmount;
        } else {                                                    // > 5 = LOSE
            uint256 lostAmount;
            if (result == 6){                                	    // Minor Loss
                lostAmount = betAmount / 10;                        // -10% of original bet
            } else if (result == 7){                                // Major Loss
                lostAmount = betAmount / 4;                         // -25% of original bet
            } else if (result == 8){                                // Grand Loss
                lostAmount = betAmount / 2;                     	// -50% of original bet
            } else if (result == 9){                                // Total Loss
                lostAmount = betAmount;                             // -100% of original bet
            }
            returnedAmount = betAmount.sub(lostAmount);
        }
        if (returnedAmount > 0) {
            win(_customerAddress, returnedAmount);                  // Give user their tokens
        }
        uint256 newBal = tokenBalanceOf(_customerAddress);
        emit spinResult(_customerAddress, resultNum, result, betAmount, returnedAmount, newBal, now);

        playerSpins[_customerAddress] = playerSpin(uint256(0), uint48(0));

        return resultNum;
    }


    function maxRandom(uint blockn, address entropy)
        internal
        returns (uint256 randomNumber)
    {
        return uint256(keccak256(
            abi.encodePacked(
              blockhash(blockn),
              entropy)
        ));
    }


    function random(uint256 upper, uint256 blockn, address entropy)
        internal
        returns (uint256 randomNumber)
    {
        return maxRandom(blockn, entropy) % upper + 1;
    }


    function determinePrize(uint256 result)
        internal
        returns (uint256 resultNum)
    {
        // Loop until the result bracket is determined
        for (uint8 i=0;i<=9;i++){
            if (result <= brackets[i]){
                return i;
            }
        }
    }


    function lose(address _customerAddress, uint256 lostAmount)
        internal
    {
        uint256 customerBal = tokenBalanceOf(_customerAddress);
        // Increase amount of eth everyone else owns
        uint256 globalIncrease = globalFactor.mul(lostAmount) / betPool(_customerAddress);
        globalFactor = globalFactor.add(globalIncrease);
        // Update user ledgers
        personalFactorLedger_[_customerAddress] = constantFactor / globalFactor;
        // User can't lose more than they have
        if (lostAmount > customerBal){
            lostAmount = customerBal;
        }
        balanceLedger_[_customerAddress] = customerBal.sub(lostAmount);
    }


    function win(address _customerAddress, uint256 wonAmount)
        internal
    {
        uint256 customerBal = tokenBalanceOf(_customerAddress);
        // Decrease amount of eth everyone else owns
        uint256 globalDecrease = globalFactor.mul(wonAmount) / betPool(_customerAddress);
        globalFactor = globalFactor.sub(globalDecrease);
        // Update user ledgers
        personalFactorLedger_[_customerAddress] = constantFactor / globalFactor;
        balanceLedger_[_customerAddress] = customerBal.add(wonAmount);
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
          return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}