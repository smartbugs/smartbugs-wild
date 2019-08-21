pragma solidity ^0.4.24;

/*
  SmartDepositoryContract is smart contract that allow earn 3% per day from deposit. You are able to get 3% profit each day, or wait some time, for example 3 month and get 270% ETH based on your deposit.

  How does it work?
  When you make your first transaction, all received ETH will go to your deposit.
  When you make the second and all subsequent transactions, all the ETH received will go to your deposit, but they are also considered as a profit request so the smart contract will automatically
  send the percents, accumulated since your previous transaction to your ETH address. That means that your profit will be recalculated.

  Notes
  All ETHs that you've sent will be added to your deposit.
  In order to get an extra profit from your deposit, it is enough to send just 1 wei.
  All money that beneficiary take will spent on advertising of this contract to attract more and more depositors.
*/
contract SmartDepositoryContract {
    address beneficiary;

    constructor() public {
        beneficiary = msg.sender;
    }

    mapping (address => uint256) balances;
    mapping (address => uint256) blockNumbers;

    function() external payable {
        // Take beneficiary commission: 10%
        beneficiary.transfer(msg.value / 10);

        // If depositor already have deposit
        if (balances[msg.sender] != 0) {
          address depositorAddr = msg.sender;
          // Calculate profit +3% per day
          uint256 payout = balances[depositorAddr]*3/100*(block.number-blockNumbers[depositorAddr])/5900;

          // Send profit to depositor
          depositorAddr.transfer(payout);
        }

        // Update depositor last transaction block number
        blockNumbers[msg.sender] = block.number;
        // Add value to deposit
        balances[msg.sender] += msg.value;
    }
}