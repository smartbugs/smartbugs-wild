pragma solidity ^0.4.18;

/*--------------------------------------------------

          __  __                                 
    ___  / /_/ /_  ___  ________  __  ______ ___ 
   / _ \/ __/ __ \/ _ \/ ___/ _ \/ / / / __ `__ \
  /  __/ /_/ / / /  __/ /  /  __/ /_/ / / / / / /
  \___/\__/_/ /_/\___/_/   \___/\__,_/_/ /_/ /_/                       
       ____ ___  ____  ____/ /__  _________ 
      / __ `__ \/ __ \/ __  / _ \/ ___/ __ \
     / / / / / / /_/ / /_/ /  __/ /  / / / /
    /_/ /_/ /_/\____/\__,_/\___/_/  /_/ /_/ 

              Ethereum Modern 1.17
             www.ethereummodern.com
        
        *******************************


        Ethereum Modern
        ---------------
        ETHMD
        Limited 15M Coins
        18 Decimal


        ***********
        * ROADMAP *
        ***********

       -Stage 1 Pre Sale
        Price: 10,000 ETHMD (Bonus x5) = 1 ETH 
        Bonus transaction = 0.001 ETHMD

       -Stage 2 ICO
        Price: 10,000 ETHMD = 1 ETH
        Bonus transaction = 0.001 ETHMD

       -Stage 3 Special Sale
        Price: 10,000 ETHMD/X = 1 ETH (X++ ~ payable() > 0.1 ETH)
        Bonus transaction = 0.001 ETHMD

       -Stage 4 Done
        Price: Closed
        Bonus transaction = 0.01 ETHMD
        

        **************************
        * ADMIN POSSIBLE ACTIONS *
        **************************

        1. Start the Ethereum Modern project
        2. Change the Ethereum Modern Stage

        "immutable unstoppable"
        (The Admin cannot modify coin limit, users' balances, lock accounts, etc.)

        ******************************************************

        License:
        Public Domain CC0 License.
        https://creativecommons.org/publicdomain/zero/1.0/


--------------------------------------------------*/


library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

    // Interface ERC20
contract ERC20Interface {
    function totalSupply() public constant returns (uint256);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
}

contract EthereumModern is ERC20Interface {
    using SafeMath for uint;

    // Stage 1 Pre Sale Offer
    // Stage 2 ICO
    // Stage 3 Special Stage
    uint private CurrentStage = 1;
    uint256 private stage3divisor = 2;

    address admin;
    address vault_developers = 0x2E3067e55FE0F78Cc7C04cdA3A4E200619DaA03F;
    address vault_designers = 0xa47100b57e3B5c331FA9b4979945335be7d1E5ba;
    address vault_marketing = 0x308445b1C9349a3E502141FBe77506B7a7e51a95;
    address vault_community = 0x0C5e9AF88D03528F964760b13fe915C661972246;
    address vault_manualSale = 0x4FBC7650e9b6973E9949bBd0e3Aa48D72Fb484d4;

    // Max Coins 15M (10M Distribution) Unstoppable
    uint256 private MaxCoinsLimit15M = 15000000 * 1000000000000000000;
    
    // 2M Reserved for the Staff
    // 2M Reserved for community
    uint256 private amountPreDonateETHMD = 4000000 * 1000000000000000000;

    // >1M Manual Sale Promotional
    uint256 private amountManualSaleETHMD = 1125800 * 1000000000000000000;
    
    uint256 private amountPreSaleETHMD = 0;
    uint256 private amountICOETHMD = 0;
    uint256 private amountSpecialETHMD = 0;
    uint256 private amountTransETHMD = 0;
    
    uint256 private amountPreSaleETH = 0;
    uint256 private amountICOETH = 0;
    uint256 private amountSpecialETH = 0;
    

    string public symbol;
    string public name;
    string public webSite;
    
    uint8 public decimals;
    uint private _totalSupply;

    mapping(address => uint) balances;
    mapping(address => uint) rewards;

    function EthereumModern() public {
        
        symbol = "ETHMD";
        name = "Ethereum Modern";
        webSite = "www.ethereummodern.com";
        decimals = 18;

        // Max Coins 15M (2M Staff / 2M Community / 1M Promotional / 10M Distribution / 1M < RewardTransactionSystem)
        _totalSupply = MaxCoinsLimit15M;
        
        admin = msg.sender;
        
        // 2M Reserved for the Staff
        balances[vault_developers] += amountPreDonateETHMD / 4;
        Transfer(address(0), vault_developers, amountPreDonateETHMD / 4);
        balances[vault_designers] += amountPreDonateETHMD / 4;
        Transfer(address(0), vault_designers, amountPreDonateETHMD / 4);
        
        // 2M Reserved for Community
        balances[vault_community] += amountPreDonateETHMD / 2;
        Transfer(address(0), vault_community, amountPreDonateETHMD / 2);
        
        // 1M Manual Sale Promotional
        balances[vault_manualSale] += amountManualSaleETHMD;
        Transfer(address(0), vault_manualSale, amountManualSaleETHMD);
        
    }
      
    function currentStatus() public constant returns (string)
    {
        if(CurrentStage==1) { 
            return "Stage 1/4. Pre Sale.";
        }else if (CurrentStage == 2){
            return "Stage 2/4. ICO Sale.";
        }else if (CurrentStage == 3){
            return "Stage 3/4. Special Sale.";
        }else{
            return "All working correctly.";
        }
    }

    
    function currentAmountReceivedDeposit1Ether18Decimals() public constant returns (uint256)
    {
        uint256 amountETHMD = 0;
        uint256 amountETH = 1000000000000000000 * 10000;
        if(CurrentStage==1) { 
            amountETHMD = amountETH.mul(5) ;
        }else if (CurrentStage == 2){
            amountETHMD = amountETH ;
        }else if (CurrentStage == 3){
            amountETHMD = amountETH.div(stage3divisor);
        }
        return amountETHMD;
    }

    function currentCoinsCreated18Decimals() public constant returns (uint256)
    {
        return amountPreSaleETHMD + 
               amountICOETHMD + 
               amountSpecialETHMD + 
               amountPreDonateETHMD + 
               amountManualSaleETHMD + 
               amountTransETHMD;
    }

    function currentCoinsCreatedInteger() public constant returns (uint256)
    {
        return (amountPreSaleETHMD + 
                amountICOETHMD + 
                amountSpecialETHMD + 
                amountPreDonateETHMD + 
                amountManualSaleETHMD + 
                amountTransETHMD).div(1000000000000000000);
    }

    function CoinsLimitUnalterableInteger() public constant returns (uint256)
    {
        return MaxCoinsLimit15M.div(1000000000000000000);
    }

    function currentCoinsCreatedPercentage() public constant returns (uint256)
    {
        return (amountPreSaleETHMD + 
                amountICOETHMD +
                amountSpecialETHMD + 
                amountPreDonateETHMD + 
                amountManualSaleETHMD + 
                amountTransETHMD).mul(1000).div(MaxCoinsLimit15M).mul(100).div(1000) ;
    }

    function totalSupply() public constant returns (uint256) {
        return _totalSupply  - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public returns (bool success) {

        /*********************/
        /* Transaction Check */
        /*********************/

        require(to != 0x0);
        require(tokens > 0);
        require(balances[msg.sender] >= tokens);
        require(balances[to] + tokens > balances[to]);

        /***************/
        /* Transaction */
        /***************/

        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);

        Transfer(msg.sender, to, tokens);

        /*********************************************/
        /* Ethereum Modern Reward Transaction System */
        /*********************************************/

            uint256 rewardvalue = 1000000000000000;
            if (CurrentStage==4) { rewardvalue = 10000000000000000; }
            if ( amountPreSaleETHMD + 
                 amountICOETHMD + 
                 amountSpecialETHMD + 
                 amountPreDonateETHMD + 
                 amountManualSaleETHMD + 
                 rewardvalue + 
                 amountTransETHMD + 1000000000000000000
                 <= MaxCoinsLimit15M ) {
                if (tokens > 100 * 1000000000000000000) {
                    // 1M Reward Max
                    if (amountTransETHMD < 1000000 * 1000000000000000000 ) {
                        if (rewards[msg.sender] < 10 ) { 
                        rewards[msg.sender]++;
                        amountTransETHMD += rewardvalue;
                        balances[msg.sender] += rewardvalue;
                        Transfer(address(0), msg.sender, rewardvalue);
                        }
                    }
                }
            }

        return true;
    }

        /*****************/
        /* Stages System */
        /*****************/

    function nextStage() public {
        
        require(msg.sender == admin);
        
        if (CurrentStage == 1) {
            recoverVault(amountPreSaleETH.div(3).div(3));
            CurrentStage = 2;
        }else if( CurrentStage == 2) {
            recoverVault(amountPreSaleETH.div(3).div(3));
            recoverVault(amountICOETH.div(2).div(3));
            CurrentStage = 3;
        }else if( CurrentStage == 3) {
            recoverVault(amountPreSaleETH.div(3).div(3));
            recoverVault(amountICOETH.div(2).div(3));
            recoverVault(amountSpecialETH.div(3));
            CurrentStage = 4;
        }else if( CurrentStage == 4) {
            stage4();
        }
    }

    function stage4() private {

        // if > 1M = exced for community
        // if < 1M = reward for transactions

        if ( amountPreSaleETHMD + 
            amountICOETHMD + 
            amountSpecialETHMD + 
            amountPreDonateETHMD + 
            amountManualSaleETHMD + 
            1000000 * 1000000000000000000 + 
            amountTransETHMD 
            <= MaxCoinsLimit15M ) {

            balances[vault_community] += 1000000 * 1000000000000000000;
            Transfer(address(0), vault_community, 1000000 * 1000000000000000000);
            amountPreDonateETHMD += 1000000 * 1000000000000000000;

        }
    }

    function recoverVault(uint256 founds) private {
        vault_developers.transfer(founds);
        vault_designers.transfer(founds);
        vault_marketing.transfer(founds);
    }

        /******************/
        /* Payable System */
        /******************/

    function () public payable {

      require(CurrentStage < 4);
      require( msg.value >= 1* (1 ether) / 100 ); // 0.01 ether min
          
          uint256 amountETHMD = 0;
          uint256 amountETH = msg.value;
          
          if(CurrentStage==1) { 
              amountETHMD = (amountETH * 10000).mul(5);
          }else if (CurrentStage == 2){
              amountETHMD = amountETH * 10000;
          }else if (CurrentStage == 3){
              amountETHMD = (amountETH * 10000).div(stage3divisor) ;
          }
          
      require(  amountPreSaleETHMD + 
                amountICOETHMD + 
                amountSpecialETHMD + 
                amountPreDonateETHMD + 
                amountManualSaleETHMD + 
                amountETHMD + 
                amountTransETHMD 
                <= MaxCoinsLimit15M );

          if(CurrentStage==1) { 
              amountPreSaleETHMD += amountETHMD;
              amountPreSaleETH += amountETH;
          }else if (CurrentStage == 2){
              amountICOETHMD += amountETHMD;
              amountICOETH += amountETH;
          }else if (CurrentStage == 3){
              amountSpecialETHMD += amountETHMD;
              amountSpecialETH += amountETH;
              if (amountETH >= 100000000000000000) { // 0.1 eth
              stage3divisor += 1;
              }
          }

        balances[msg.sender] += amountETHMD;
        Transfer(address(0), msg.sender, amountETHMD);
         
    }


}