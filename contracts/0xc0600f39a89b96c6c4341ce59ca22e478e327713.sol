/*
* ETHEREUM ACCUMULATIVE SMARTCONTRACT
* Web              -            https://ethx.live
* EN  Telegram_chat: https://t.me/ethx_en
* RU  Telegram_chat: https://t.me/ethx_ru
* CN  Telegram_chat: https://t.me/ethx_cn
* 
*  - GAIN 4-5% OF YOUR DEPOSIT  PER 24 HOURS (every 5900 blocks)
*  - 4% IF YOUR TOTAL DEPOSIT 0.01-1 ETH
*  - 4.25% IF YOUR TOTAL DEPOSIT 1-10 ETH
*  - 4.5% IF YOUR TOTAL DEPOSIT 10-20 ETH
*  - 4.75% IF YOUR TOTAL DEPOSIT 20-40 ETH
*  - 5% IF YOUR TOTAL DEPOSIT 40+ ETH
*  - Life-long payments
*  - The revolutionary reliability
*  - Minimal contribution is 0.01 eth
*  - Currency and payment - ETH
*  - !!! It is not allowed to transfer from exchanges, only from your personal ETH wallet !!!
*
*  - Contribution allocation schemes:
*    -- 90% payments
*    -- 10% Marketing + Operating Expenses
*
* --- How to use:
*  1. Send from ETH wallet to the smart contract address "0xc0600F39a89b96c6c4341cE59ca22E478E327713"
*     any amount above 0.01 ETH.
*  2. Verify your transaction in the history of your application or etherscan.io, specifying the address 
*     of your wallet.
*  3a. Claim your profit by sending 0 ether transaction 
*  OR
*  3b. For reinvest, you need first to remove the accumulated percentage of charges (by sending 0 ether 
*      transaction), and only after that, deposit the amount that you want to reinvest.
*  
* RECOMMENDED GAS LIMIT: 200000
* RECOMMENDED GAS PRICE: https://ethgasstation.info/
* You can check the payments on the etherscan.io site, in the "Internal Txns" tab of your wallet.
*
* 
* Contracts reviewed and approved by pros!
*/
pragma solidity ^0.4.24;

contract ethx {
    mapping (address => uint256) invested;
    mapping (address => uint256) atBlock;
    uint256 minValue; 
    address owner1;    // 10%
    event Withdraw (address indexed _to, uint256 _amount);
    event Invested (address indexed _to, uint256 _amount);
    
    constructor () public {
        owner1 = 0x0D257779Bbe6321d8349eEbCb2f0f5a90409DB80;    // 10%
        minValue = 0.01 ether; //min amount for transaction
    }
    
    /**
     * This function calculated percent
     * less than 1 Ether    - 4.0  %
     * 1-10 Ether           - 4.25 %
     * 10-20 Ether          - 4.5  %
     * 20-40 Ether          - 4.75 %
     * more than 40 Ether   - 5.0  %
     */
        function getPercent(address _investor) internal view returns (uint256) {
        uint256 percent = 400;
        if(invested[_investor] >= 1 ether && invested[_investor] < 10 ether) {
            percent = 425;
        }

        if(invested[_investor] >= 10 ether && invested[_investor] < 20 ether) {
            percent = 450;
        }

        if(invested[_investor] >= 20 ether && invested[_investor] < 40 ether) {
            percent = 475;
        }

        if(invested[_investor] >= 40 ether) {
            percent = 500;
        }
        
        return percent;
    }
    
    /**
     * Main function
     */
    function () external payable {
        require (msg.value == 0 || msg.value >= minValue,"Min Amount for investing is 0.01 Ether.");
        
        uint256 invest = msg.value;
        address sender = msg.sender;
        //fee owners
        owner1.transfer(invest / 10);
            
        if (invested[sender] != 0) {
            uint256 amount = invested[sender] * getPercent(sender) / 10000 * (block.number - atBlock[sender]) / 5900;

            //fee sender
            sender.transfer(amount);
            emit Withdraw (sender, amount);
        }

        atBlock[sender] = block.number;
        invested[sender] += invest;
        if (invest > 0){
            emit Invested(sender, invest);
        }
    }
    
    /**
     * This function show deposit
     */
    function showDeposit (address _deposit) public view returns(uint256) {
        return invested[_deposit];
    }

    /**
     * This function show block of last change
     */
    function showLastChange (address _deposit) public view returns(uint256) {
        return atBlock[_deposit];
    }

    /**
     * This function show unpayed percent of deposit
     */
    function showUnpayedPercent (address _deposit) public view returns(uint256) {
        uint256 amount = invested[_deposit] * getPercent(_deposit) / 10000 * (block.number - atBlock[_deposit]) / 5900;
        return amount;
    }


}