pragma solidity ^0.5.3;

/*
Ethereum Tree

Website: https://www.ethereumtree.com
Telegram: https://t.me/ethereumtree
Twitter: https://www.twitter.com/ethereumtree
Medium: https://medium.com/@ethereumtree

What is Ethereum Tree?
Ethereum Tree is intelligent platform which works on simple principle of “money tree” – now everyone will earn Ethereum. It is a never ending source of income for those who will invest in the Ethereum Tree. Ethereum Tree grows continuously whenever new investors are added into the Ethereum Tree system.

How Ethereum Tree works?
Anybody willing to invest in Ethereum Tree can start investing with any amount as small as 0.0001 ETH. As name suggests, this platform is completely Ethereum blockchain based system.  After investing into the system person will start earning profit based on the amount of ETH he/she is holding into Ethereum Tree smart contract.

Investors will get income in 2 different ways as explained below:
1.	Income from dividend obtained from successive investments:
Whenever new investor invests Ethereum into Ethereum Tree smart contract (DAPP), system will deduct 10% amount as a network fee which will be distributed to all the investors who are already part of Ethereum Tree.  Distribution amount assigned to each investor is directly proportional to the current holdings of that investor in Ethereum Tree. That means, investors with higher holdings will get larger portion of the dividend (Larger is the holding bigger is the profit). Same thing is illustrated in below image.

2.	Earning from referral bonus:
Ethereum Tree assigns unique referral link to each investor wallet. The format of link is as below:
https://ethereumtree.com/?ref=Your_ETH_Address
Whenever users share this link with his/her friends or relatives to refer them to Ethereum Tree DAPP he/she will get flat 1/3 of 10% network fee from the referral’s investment as a referral bonus. This means, whenever referred person invests 10% amount is deducted as a network fee for distribution amongst the present members of the Ethereum Tree but 1/3 part of that deducted amount will be directly given to referring person as a referral bonus and remaining 2/3 portion will be distributed amongst all the members of the Ethereum Tree based on current holdings. So, person who refers other members to the system will get double benefits (referral bonus as well as future dividend on referential bonus).

Benefits of using Ethereum Tree as an investment option:
•	Investors get dividend amount from successive investors based on their current holdings in the system. So investor can increase their holdings to get more and more profit out of it.
•	Ethereum Tree is highly secure distributed system so no one controls it but the investors. So all the investments of investors are safe into the system (Ethereum blockchain).
•	Investors can withdraw their holdings including profits earned via dividend and referral bonus anytime as per their need.
•	Investor can earn unlimited profits by referring more and more members to the Ethereum Tree. User who refers other members will get benefits from both referral bonus as well as future dividend on referential bonus.
•	The best thing about Ethereum Tree is that the investors get profit based on percentage of total holdings which they have in Ethereum Tree. Holdings go on increasing with newly added members in the system and investor’s income from dividend also starts increasing.

Admin can't do below things:
1. Withdraw funds from Ethereum Tree Contract
2. Modify EthereumTree contract

Admin can do:
1. Invest in EthereumTree
2. Pay promoter from admin account. This will be deducted from admin investment in Ethereum Tree.

*/
contract owned {
    
    // set owner while creating Ethereum Tree contract. It will be ETH Address setting up Contract
    constructor() public { owner = msg.sender; }
    address payable owner;

    // This contract only defines a modifier but does not use
    // it: it will be used in derived contracts.
    // The function body is inserted where the special symbol
    // `_;` in the definition of a modifier appears.
    // This means that if the owner calls this function, the
    // function is executed and otherwise, an exception is
    // thrown.
    
    // Modifier onlyOwner to check transaction send is from owner or not for paying promotor fees. This fee will be deducted from admins investment in Ethereum Tree
    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }
}


// Contract Ethereum Tree
contract EthereumTree is owned{
    
    // solidity structure which hold record of investors transaction
    struct Account 
    {
        uint accountBalance;
        uint accountInvestment;
        uint accountWithdrawedAmount;
        uint accountReferralInvestment;
        uint accountReferralBenefits;
        uint accountEarnedHolderBenefits;
        uint accountReferralCount;
        uint index;
    }

    mapping(address => Account) private Accounts;
    address[] private accountIndex;
    
    // Solidity events which execute when users Invest or Withdraw funds in Ethereum Tree
    event RegisterInvestment(address userAddress, uint totalInvestmentAmount, uint depositInUserAccount, uint balanceInUserAccount);
    event RegisterWithdraw(address userAddress, uint totalWithdrawalAmount, uint withdrawToUserAccount, uint balanceInUserAccount);
    
    
    //Function default payable which will store investment record in case anyone send Ethereum directly to contract address
    function() external payable
    {
        investInEthereumTree();
    }
    
    // Function to check user already part of Ethereum Tree
    function isUser(address Address) public view returns(bool isIndeed) 
    {
        if(accountIndex.length == 0) return false;
        return (accountIndex[Accounts[Address].index] == Address);
    }
    
    // Function to get index of account record stored in Solidity structure
    function getAccountAtIndex(uint index) public view returns(address Address)
    {
        return accountIndex[index];
    }
    
    // Function to insert new user when invest or refer in Ethereum Tree. Set default balance to 0 before processing
    function insertUser(address accountAddress) public returns(uint index)
    {
        require(!isUser(accountAddress));
        
        Accounts[accountAddress].accountBalance = 0;
        Accounts[accountAddress].accountInvestment = 0;
        Accounts[accountAddress].accountWithdrawedAmount = 0;
        Accounts[accountAddress].accountReferralInvestment = 0;
        Accounts[accountAddress].accountReferralBenefits = 0;
        Accounts[accountAddress].accountEarnedHolderBenefits = 0;
        Accounts[accountAddress].accountReferralCount = 0;
        Accounts[accountAddress].index = accountIndex.push(accountAddress)-1;
        return accountIndex.length-1;
    }
    
    // Function  to get total account count present in Ethereum Tree
    function getAccountCount() public view returns(uint count)
    {
        return accountIndex.length;
    }
    
    // Function to get account balance of callling Ethereum address
    function getAccountBalance() public view returns(uint accountBalance, uint accountInvestment, uint accountWithdrawedAmount, uint accountReferralInvestment, uint accountReferralBenefits, uint accountEarnedHolderBenefits, uint accountReferralCount, uint index)
    {
        address accountAddress = msg.sender;
        if (isUser(accountAddress))
        {
            return (Accounts[accountAddress].accountBalance, Accounts[accountAddress].accountInvestment, Accounts[accountAddress].accountWithdrawedAmount, Accounts[accountAddress].accountReferralInvestment, Accounts[accountAddress].accountReferralBenefits, Accounts[accountAddress].accountEarnedHolderBenefits, Accounts[accountAddress].accountReferralCount, Accounts[accountAddress].index);
        }
        else
        {
            return (0, 0, 0, 0, 0, 0, 0, 0);
        }
        
    }
    
    // Function to get account balance of any address in Ethereum Tree
    function getAccountBalance(address Address) public view returns(uint accountBalance, uint accountInvestment, uint accountWithdrawedAmount, uint accountReferralInvestment, uint accountReferralBenefits, uint accountEarnedHolderBenefits, uint accountReferralCount, uint index)
    {
        address accountAddress = Address;
        if (isUser(accountAddress))
        {
            return (Accounts[accountAddress].accountBalance, Accounts[accountAddress].accountInvestment, Accounts[accountAddress].accountWithdrawedAmount, Accounts[accountAddress].accountReferralInvestment, Accounts[accountAddress].accountReferralBenefits, Accounts[accountAddress].accountEarnedHolderBenefits, Accounts[accountAddress].accountReferralCount, Accounts[accountAddress].index);
        }
        else
        {
            return (0, 0, 0, 0, 0, 0, 0, 0);
        }
        
    }
    
    // Function to get account summary of wallet calling function along with contract balance
    function getAccountSummary() public view returns(uint contractBalance, uint accountBalance, uint accountInvestment, uint accountWithdrawedAmount, uint accountReferralInvestment, uint accountReferralBenefits, uint accountEarnedHolderBenefits, uint accountReferralCount, uint index)
    {
        address accountAddress = msg.sender;
        if (isUser(accountAddress))
        {
            return (address(this).balance, Accounts[accountAddress].accountBalance, Accounts[accountAddress].accountInvestment, Accounts[accountAddress].accountWithdrawedAmount, Accounts[accountAddress].accountReferralInvestment, Accounts[accountAddress].accountReferralBenefits, Accounts[accountAddress].accountEarnedHolderBenefits, Accounts[accountAddress].accountReferralCount, Accounts[accountAddress].index);
        }
        else
        {
            return (address(this).balance, 0, 0, 0, 0, 0, 0, 0, 0);
        }
        
    }
    
    // Function to get account summary of other wallet along with contract balance
    function getAccountSummary(address Address) public view returns(uint contractBalance, uint accountBalance, uint accountInvestment, uint accountWithdrawedAmount, uint accountReferralInvestment, uint accountReferralBenefits, uint accountEarnedHolderBenefits, uint accountReferralCount, uint index)
    {
        address accountAddress = Address;
        
        if (isUser(accountAddress))
        {
            return (address(this).balance, Accounts[accountAddress].accountBalance, Accounts[accountAddress].accountInvestment, Accounts[accountAddress].accountWithdrawedAmount, Accounts[accountAddress].accountReferralInvestment, Accounts[accountAddress].accountReferralBenefits, Accounts[accountAddress].accountEarnedHolderBenefits, Accounts[accountAddress].accountReferralCount, Accounts[accountAddress].index);    
        }
        else
        {
            return (address(this).balance, 0, 0, 0, 0, 0, 0, 0, 0);    
        }
        
    }
    
    // Function to get total Ethereum tree contract balance
    function getBalanceSummary() public view returns(uint accountBalance, uint accountInvestment, uint accountWithdrawedAmount, uint accountReferralInvestment, uint accountReferralBenefits, uint accountEarnedHolderBenefits, uint accountReferralCount)
    {
        accountBalance = 0;
        accountInvestment = 0;
        accountWithdrawedAmount = 0;
        accountReferralInvestment = 0;
        accountReferralBenefits = 0;
        accountEarnedHolderBenefits = 0;
        accountReferralCount = 0;
        
        // Read balance of alll account and return
        for(uint i=0; i< accountIndex.length;i++)
        {
            accountBalance = accountBalance + Accounts[getAccountAtIndex(i)].accountBalance; 
            accountInvestment =accountInvestment + Accounts[getAccountAtIndex(i)].accountInvestment;
            accountWithdrawedAmount = accountWithdrawedAmount + Accounts[getAccountAtIndex(i)].accountWithdrawedAmount;
            accountReferralInvestment = accountReferralInvestment + Accounts[getAccountAtIndex(i)].accountReferralInvestment;
            accountReferralBenefits = accountReferralBenefits + Accounts[getAccountAtIndex(i)].accountReferralBenefits;
            accountEarnedHolderBenefits = accountEarnedHolderBenefits + Accounts[getAccountAtIndex(i)].accountEarnedHolderBenefits;
            accountReferralCount = accountReferralCount + Accounts[getAccountAtIndex(i)].accountReferralCount;
        }
        
        return (accountBalance,accountInvestment, accountWithdrawedAmount, accountReferralInvestment, accountReferralBenefits,accountEarnedHolderBenefits,accountReferralCount);
    }
    
    // Function which  will execute when user invest in Ethereum Tree to feed balance and assign divident to rest account
    function investInEthereumTree() public payable returns(bool success)
    {
        require(msg.value > 0);
        
        uint iTotalInvestmentAmount = 0;
        uint iInvestmentAmountToUserAccount = 0;
        uint iInvestmentAmountToDistribute = 0;
        
        uint totalAccountBalance = 0;
        uint totalaccountInvestment = 0;
        uint totalAccountWithdrawedAmount = 0;
        uint totalAccountReferralInvestment = 0;
        uint totalAccountReferralBenefits = 0;
        uint TotalAccountEarnedHolderBenefits = 0;
        uint TotalAccountReferralCount = 0;
        
        // store value of Ethereum receiving
        iTotalInvestmentAmount = msg.value;
        
        // Set investment amount to distribute in holders. As investor invested without referral link it will 10%
        iInvestmentAmountToDistribute = (iTotalInvestmentAmount * 10) /100;
        
        // Set investment amount to distribute in investor account. As investor invested without referral link it will 10%
        iInvestmentAmountToUserAccount = iTotalInvestmentAmount - iInvestmentAmountToDistribute;
        
        (totalAccountBalance,totalaccountInvestment,totalAccountWithdrawedAmount,totalAccountReferralInvestment,totalAccountReferralBenefits,TotalAccountEarnedHolderBenefits,TotalAccountReferralCount) = getBalanceSummary();
        
        if(!isUser(msg.sender))
        {
            insertUser(msg.sender);
        }
        
        // If no one holding fund in Ethereum Tree then assign complete investment to user Accounts
        if (totalAccountBalance == 0)
        {
            Accounts[msg.sender].accountBalance = Accounts[msg.sender].accountBalance + iTotalInvestmentAmount;
            Accounts[msg.sender].accountInvestment = Accounts[msg.sender].accountInvestment + iTotalInvestmentAmount;

            emit RegisterInvestment(msg.sender, iTotalInvestmentAmount, iTotalInvestmentAmount, Accounts[msg.sender].accountBalance);

            return true;
        }
        else
        {
            // If previous holders holding ETH in Ethereum Tree then distribute them divident based on their holding in Ethereum Tree
            for(uint i=0; i< accountIndex.length;i++)
            {
                if (Accounts[getAccountAtIndex(i)].accountBalance != 0)
                {
                    Accounts[getAccountAtIndex(i)].accountBalance = Accounts[getAccountAtIndex(i)].accountBalance + ((iInvestmentAmountToDistribute * Accounts[getAccountAtIndex(i)].accountBalance)/totalAccountBalance);
                    Accounts[getAccountAtIndex(i)].accountEarnedHolderBenefits = Accounts[getAccountAtIndex(i)].accountEarnedHolderBenefits + ((iInvestmentAmountToDistribute * Accounts[getAccountAtIndex(i)].accountBalance)/totalAccountBalance);
                }                    
            }
            
            // Set balance of investor in Ethereum Tree
            Accounts[msg.sender].accountBalance = Accounts[msg.sender].accountBalance + iInvestmentAmountToUserAccount;
            Accounts[msg.sender].accountInvestment = Accounts[msg.sender].accountInvestment + iTotalInvestmentAmount;
            
            // Register event abount Investment
            emit RegisterInvestment(msg.sender, iTotalInvestmentAmount, iInvestmentAmountToUserAccount, Accounts[msg.sender].accountBalance);
            
            return true;
        }
    }
    
    // Function will be called when investment invest using referrial link
    function investInEthereumTree(address ReferralAccount) public payable returns(bool success) {
        require(msg.value > 0);
        
        // Store ReferralAccount address
        address accReferralAccount = ReferralAccount;
        
        uint iTotalInvestmentAmount = 0;
        uint iInvestmentAmountToUserAccount = 0;
        uint iInvestmentAmountToReferralAccount = 0;
        uint iInvestmentAmountToDistribute = 0;
        
        uint totalAccountBalance = 0;
        uint totalaccountInvestment = 0;
        uint totalAccountWithdrawedAmount = 0;
        uint totalAccountReferralInvestment = 0;
        uint totalAccountReferralBenefits = 0;
        uint TotalAccountEarnedHolderBenefits = 0;
        uint TotalAccountReferralCount = 0;
        
        // store value of Ethereum receiving
        iTotalInvestmentAmount = msg.value;
        
        // Set investment amount to distribute to referral. As investor invested with referral link it will 3.33% of total investment or 33.33% of network fees
        iInvestmentAmountToReferralAccount = ((iTotalInvestmentAmount * 10) /100)/3;
        
        // Set investment amount to distribute among holders as divident
        iInvestmentAmountToDistribute = ((iTotalInvestmentAmount * 10) /100)-iInvestmentAmountToReferralAccount;
        
        // Set investment amount to update in investor account
        iInvestmentAmountToUserAccount = iTotalInvestmentAmount - (iInvestmentAmountToReferralAccount + iInvestmentAmountToDistribute);

        // If investor using own referral link then distriibute all network fees in holders as divident
        if(msg.sender == accReferralAccount)
        {
            iInvestmentAmountToDistribute = iInvestmentAmountToDistribute + iInvestmentAmountToReferralAccount;
            iInvestmentAmountToReferralAccount = 0;
        }
        
        (totalAccountBalance,totalaccountInvestment,totalAccountWithdrawedAmount,totalAccountReferralInvestment,totalAccountReferralBenefits,TotalAccountEarnedHolderBenefits,TotalAccountReferralCount) = getBalanceSummary();
        
        if(!isUser(msg.sender))
        {
            insertUser(msg.sender);
        }
        
        if(!isUser(ReferralAccount))
        {
            insertUser(ReferralAccount);
        }
        
        // If Ethereum Tree holders are not holding any fund assign fund to referral account and investor account
        if (totalAccountBalance == 0)
        {
            Accounts[msg.sender].accountBalance = Accounts[msg.sender].accountBalance + iInvestmentAmountToUserAccount + iInvestmentAmountToDistribute;
            Accounts[msg.sender].accountInvestment = Accounts[msg.sender].accountInvestment +  iTotalInvestmentAmount;
            
            if (msg.sender != ReferralAccount)
            {
                Accounts[accReferralAccount].accountBalance = Accounts[accReferralAccount].accountBalance + iInvestmentAmountToReferralAccount;
                Accounts[accReferralAccount].accountReferralInvestment = Accounts[accReferralAccount].accountReferralInvestment + iTotalInvestmentAmount;    
                Accounts[accReferralAccount].accountReferralBenefits = Accounts[accReferralAccount].accountReferralBenefits + iInvestmentAmountToReferralAccount;
                Accounts[accReferralAccount].accountReferralCount = Accounts[accReferralAccount].accountReferralCount + 1;
            }

            
            emit RegisterInvestment(msg.sender, iTotalInvestmentAmount, iTotalInvestmentAmount, Accounts[msg.sender].accountBalance);
            
            return true;
        }
        else
        {
            // If previous holders holding ETH in Ethereum Tree then distribute them divident based on their holding in Ethereum Tree
            for(uint i=0; i< accountIndex.length;i++)
            {
                if (Accounts[getAccountAtIndex(i)].accountBalance != 0)
                {
                    Accounts[getAccountAtIndex(i)].accountBalance = Accounts[getAccountAtIndex(i)].accountBalance + ((iInvestmentAmountToDistribute * Accounts[getAccountAtIndex(i)].accountBalance)/totalAccountBalance);
                    Accounts[getAccountAtIndex(i)].accountEarnedHolderBenefits = Accounts[getAccountAtIndex(i)].accountEarnedHolderBenefits + ((iInvestmentAmountToDistribute * Accounts[getAccountAtIndex(i)].accountBalance)/totalAccountBalance);
                }                    
            }
            
            // update investor account for new investment
            Accounts[msg.sender].accountBalance = Accounts[msg.sender].accountBalance + iInvestmentAmountToUserAccount;
            Accounts[msg.sender].accountInvestment = Accounts[msg.sender].accountInvestment +  iTotalInvestmentAmount;
            
            // update referral account with referral benefits
            if (msg.sender != ReferralAccount){
                Accounts[accReferralAccount].accountBalance = Accounts[accReferralAccount].accountBalance + iInvestmentAmountToReferralAccount;
                Accounts[accReferralAccount].accountReferralInvestment = Accounts[accReferralAccount].accountReferralInvestment + iTotalInvestmentAmount;
                Accounts[accReferralAccount].accountReferralBenefits = Accounts[accReferralAccount].accountReferralBenefits + iInvestmentAmountToReferralAccount;
                Accounts[accReferralAccount].accountReferralCount = Accounts[accReferralAccount].accountReferralCount + 1;    
            }
            
            emit RegisterInvestment(msg.sender, iTotalInvestmentAmount, iInvestmentAmountToUserAccount, Accounts[msg.sender].accountBalance);
            
            return true;
        }
    }
    
    // Function to withdraw fund from account of Ethereum Tree. User will be able to withdraw fund only he is holding and same will be deducted from account. On withdrawal 10% network fees will be distributed among holders
    function withdraw(uint withdrawalAmount) public returns(bool success)
    {
        require(isUser(msg.sender) && Accounts[msg.sender].accountBalance >= withdrawalAmount);
    
        uint iTotalWithdrawalAmount = 0;
        uint iWithdrawalAmountToUserAccount = 0;
        uint iWithdrawalAmountToDistribute = 0;
        
        uint totalAccountBalance = 0;
        uint totalaccountInvestment = 0;
        uint totalAccountWithdrawedAmount = 0;
        uint totalAccountReferralInvestment = 0;
        uint totalAccountReferralBenefits = 0;
        uint TotalAccountEarnedHolderBenefits = 0;
        uint TotalAccountReferralCount = 0;
        
        iTotalWithdrawalAmount = withdrawalAmount;
        iWithdrawalAmountToDistribute = (iTotalWithdrawalAmount * 10) /100;
        iWithdrawalAmountToUserAccount = iTotalWithdrawalAmount - iWithdrawalAmountToDistribute;

        // deduct fund from user account initiate to withdraw        
        Accounts[msg.sender].accountBalance = Accounts[msg.sender].accountBalance - iTotalWithdrawalAmount;
        Accounts[msg.sender].accountWithdrawedAmount = Accounts[msg.sender].accountWithdrawedAmount + iTotalWithdrawalAmount;
        
        (totalAccountBalance,totalaccountInvestment,totalAccountWithdrawedAmount,totalAccountReferralInvestment,totalAccountReferralBenefits,TotalAccountEarnedHolderBenefits,TotalAccountReferralCount) = getBalanceSummary();
    
        // If only current user holding fund then withdraw complete initiated account without deducting network fees
        if (totalAccountBalance == iTotalWithdrawalAmount)
        {
            msg.sender.transfer(iTotalWithdrawalAmount);
            
            emit RegisterWithdraw(msg.sender, iTotalWithdrawalAmount, iTotalWithdrawalAmount, Accounts[msg.sender].accountBalance);
            
            return true;
        }
        else
        {
            // If other users holding fund then deduct 10% network fees from withdrawal amount and ditribute it as divident between holders.
            for(uint i=0; i< accountIndex.length;i++)
            {
                if (Accounts[getAccountAtIndex(i)].accountBalance != 0)
                {
                    Accounts[getAccountAtIndex(i)].accountBalance = Accounts[getAccountAtIndex(i)].accountBalance + ((iWithdrawalAmountToDistribute * Accounts[getAccountAtIndex(i)].accountBalance)/totalAccountBalance);
                    Accounts[getAccountAtIndex(i)].accountEarnedHolderBenefits = Accounts[getAccountAtIndex(i)].accountEarnedHolderBenefits + ((iWithdrawalAmountToDistribute * Accounts[getAccountAtIndex(i)].accountBalance)/totalAccountBalance);
                }                    
            }
            
            // initiate withdrawal to user account
            msg.sender.transfer(iWithdrawalAmountToUserAccount);
            
            emit RegisterWithdraw(msg.sender, iTotalWithdrawalAmount, iWithdrawalAmountToUserAccount, Accounts[msg.sender].accountBalance);
            
            return true;
        }
    }
    
    //  Pay promotor fees from owner account. Note this amount will be deducted from owner holding in Ethereum Tree
    function payPromoterRewardFromOwnerAccount(address addPromoter, uint iAmount) public onlyOwner returns(bool success)
    {
        require(isUser(msg.sender) && !(msg.sender == addPromoter) && (iAmount > 0) && (Accounts[msg.sender].accountBalance > Accounts[addPromoter].accountBalance));
        
        if (isUser(addPromoter)==false)
        {
            insertUser(addPromoter);
        }
        
        Accounts[msg.sender].accountBalance = Accounts[msg.sender].accountBalance - iAmount;
        Accounts[addPromoter].accountBalance = Accounts[addPromoter].accountBalance + iAmount;
        
        return true;
    }
    
}