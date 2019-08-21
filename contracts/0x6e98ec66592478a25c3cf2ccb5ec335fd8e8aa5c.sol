pragma solidity ^0.4.19;

/*
*
* Domain on day 1: https://etherbonds.io/
*
* This contract implements bond contracts on the Ethereum blockchain
* - You can buy a bond for ETH (NominalPrice)
* - While buying you can set a desirable MaturityDate
* - After you reach the MaturityDate you can redeem the bond for the MaturityPrice
* - MaturityPrice is always greater than the NominalPrice
* - greater the MaturityDate = higher profit
* - You can't redeem a bond after MaxRedeemTime
* 
* For example, you bought a bond for 1 ETH which will mature in 1 month for 63% profit.
* After the month you can redeem the bond and receive your 1.63 ETH.
*
* If you don't want to wait for your bond maturity you can sell it to another investor. 
* For example you bought a 1 year bond, 6 months have passed and you urgently need money. 
* You can sell the bond on a secondary market to other investors before the maturity date.
* You can also redeem your bond prematurely but only for a part of the nominal price.
*
* !!! THIS IS A HIGH RISK INVESTMENT ASSET !!!
* !!! THIS IS GAMBLING !!!
* !!! THIS IS A PONZI SCHEME !!!
* All funds invested are going to prev investors for the exception of FounderFee and AgentFee
*
* Bonds are generating profit due to NEW and NEW investors BUYING them
* If the contract has no ETH in it you will FAIL to redeem your bond
* However as soon as new bonds will be issued the contract will receive ETH and
* you will be able to redeem the bond.
*
* You can also refer a friend for 10% of the bonds he buys. Your friend will also receive a referral bonus for trading with your code!
*
*/

/*
* ------------------------------
* Main functions are:
* Buy() - to buy a new issued bond
* Redeem() - to redeem your bond for profit 
*
* BuyOnSecondaryMarket() - to buy a bond from other investors
* PlaceSellOrder() - to place your bond on the secondary market for selling
* CancelSellOrder() - stop selling your bond
* Withdraw() - to withdraw agant commission or funds after selling a bond on the secondary market
* ------------------------------
*/

/**
/* Math operations with safety checks
*/
contract SafeMath 
{
    function mul(uint a, uint b) internal pure returns (uint) 
    {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) 
    {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) 
    {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) 
    {
        uint c = a + b;
        assert(c >= a);
        return c;
    }

    function assert(bool assertion) internal pure
    {
        if (!assertion) 
        {
            revert();
        }   
    }
}

contract EtherBonds is SafeMath
{
    /* A founder can write here useful information */
    /* For example current domain name or report a problem */
    string public README = "STATUS_OK";
    
    /* You can refer a friend and you will be receiving a bonus for EACH his deal */
    /* The friend will also have a bonus but only once */
    /* You should have at least one bond in your history to be an agent */
    /* Just ask your friend to specify your wallet address with his FIRST deal */
    uint32 AgentBonusInPercent = 10;
    /* A user gets a bonus for adding an agent for his first deal */
    uint32 UserRefBonusInPercent = 3;
    
    /* How long it takes for a bond to mature  */
    uint32 MinMaturityTimeInDays = 30; // don't set less than 15 days
    uint32 MaxMaturityTimeInDays = 240;
    
    /* Minimum price of a bond */
    uint MinNominalBondPrice = 0.006 ether;
    
    /* How much % of your bond you can redeem prematurely */
    uint32 PrematureRedeemPartInPercent = 25;
    /* How much this option costs */
    uint32 PrematureRedeemCostInPercent = 20;
    
    /* Be careful! */
    /* If you don't redeem your bond AFTER its maturity date */
    /* the bond will become irredeemable! */
    uint32 RedeemRangeInDays = 1;
    uint32 ExtraRedeemRangeInDays = 3;
    /* However you can prolong your redeem period for a price */
    uint32 ExtraRedeemRangeCostInPercent = 10;
    
    /* Founder takes a fee for each bond sold */
    /* There is no way for a founder to take all the contract's money, fonder takes only the fee */
    address public Founder;
    uint32 public FounderFeeInPercent = 5;
    
    /* Events */
    event Issued(uint32 bondId, address owner);
    event Sold(uint32 bondId, address seller, address buyer, uint price);
    event SellOrderPlaced(uint32 bondId, address seller);
    event SellOrderCanceled(uint32 bondId, address seller);
    event Redeemed(uint32 bondId, address owner);
    
    struct Bond 
    {
        /* Unique ID of a bond */
        uint32 id;
        
        address owner;
        
        uint32 issueTime;
        uint32 maturityTime;
        uint32 redeemTime;
        
        /* A bond can't be redeemed after this date */
        uint32 maxRedeemTime;
        bool canBeRedeemedPrematurely;
        
        uint nominalPrice;
        uint maturityPrice;
        
        /* You can resell your bond to another user */
        uint sellingPrice;
    }
    uint32 NextBondID = 1;
    mapping(uint32 => Bond) public Bonds;
    
    struct UserInfo
    {
        /* This address will receive commission for this user trading */
        address agent;
        
        uint32 totalBonds;
        mapping(uint32 => uint32) bonds;
    }
    mapping(address => UserInfo) public Users;

    mapping(address => uint) public Balances;

    /* MAIN */
    
    function EtherBonds() public 
    {
        Founder = msg.sender;
    }
    
    function ContractInfo() 
        public view returns(
            string readme,
            uint32 agentBonusInPercent,
            uint32 userRefBonusInPercent,
            uint32 minMaturityTimeInDays,
            uint32 maxMaturityTimeInDays,
            uint minNominalBondPrice,
            uint32 prematureRedeemPartInPercent,
            uint32 prematureRedeemCostInPercent,
            uint32 redeemRangeInDays,
            uint32 extraRedeemRangeInDays,
            uint32 extraRedeemRangeCostInPercent,
            uint32 nextBondID,
            uint balance
            )
    {
        readme = README;
        agentBonusInPercent = AgentBonusInPercent;
        userRefBonusInPercent = UserRefBonusInPercent;
        minMaturityTimeInDays = MinMaturityTimeInDays;
        maxMaturityTimeInDays = MaxMaturityTimeInDays;
        minNominalBondPrice = MinNominalBondPrice;
        prematureRedeemPartInPercent = PrematureRedeemPartInPercent;
        prematureRedeemCostInPercent = PrematureRedeemCostInPercent;
        redeemRangeInDays = RedeemRangeInDays;
        extraRedeemRangeInDays = ExtraRedeemRangeInDays;
        extraRedeemRangeCostInPercent = ExtraRedeemRangeCostInPercent;
        nextBondID = NextBondID;
        balance = this.balance;
    }
    
    /* This function calcs how much profit will a bond bring */
    function MaturityPrice(
        uint nominalPrice, 
        uint32 maturityTimeInDays,
        bool hasExtraRedeemRange,
        bool canBeRedeemedPrematurely,
        bool hasRefBonus
        ) 
        public view returns(uint)
    {
        uint nominalPriceModifierInPercent = 100;
        
        if (hasExtraRedeemRange)
        {
            nominalPriceModifierInPercent = sub(
                nominalPriceModifierInPercent, 
                ExtraRedeemRangeCostInPercent
                );
        }
        
        if (canBeRedeemedPrematurely)
        {
            nominalPriceModifierInPercent = sub(
                nominalPriceModifierInPercent, 
                PrematureRedeemCostInPercent
                );
        }
        
        if (hasRefBonus)
        {
            nominalPriceModifierInPercent = add(
                nominalPriceModifierInPercent, 
                UserRefBonusInPercent
                );
        }
        
        nominalPrice = div(
            mul(nominalPrice, nominalPriceModifierInPercent), 
            100
            );
        
        //y = 1.177683 - 0.02134921*x + 0.001112346*x^2 - 0.000010194*x^3 + 0.00000005298844*x^4
        /*
        15days        +7%
        30days       +30%
        60days      +138%
        120days     +700%
        240days    +9400% 
        */
        
        uint x = maturityTimeInDays;
        
        /* The formula will break if x < 15 */
        require(x >= 15);
        
        var a = mul(2134921000, x);
        var b = mul(mul(111234600, x), x);
        var c = mul(mul(mul(1019400, x), x), x);
        var d = mul(mul(mul(mul(5298, x), x), x), x);
        
        var k = sub(sub(add(add(117168300000, b), d), a), c);
        k = div(k, 10000000);
        
        return div(mul(nominalPrice, k), 10000);
    }
    
    /* This function checks if you can change your bond back to money */
    function CanBeRedeemed(Bond bond) 
        internal view returns(bool) 
    {
        return 
            bond.issueTime > 0 &&                       // a bond should be issued
            bond.owner != 0 &&                          // it should should have an owner
            bond.redeemTime == 0 &&                     // it should not be already redeemed
            bond.sellingPrice == 0 &&                   // it should not be reserved for selling
            (
                !IsPremature(bond.maturityTime) ||      // it should be mature / be redeemable prematurely 
                bond.canBeRedeemedPrematurely
            ) &&       
            block.timestamp <= bond.maxRedeemTime;      // be careful, you can't redeem too old bonds
    }
    
    /* For some external checkings we gonna to wrap this in a function */
    function IsPremature(uint maturityTime)
        public view returns(bool) 
    {
        return maturityTime > block.timestamp;
    }
    
    /* This is how you buy bonds on the primary market */
    function Buy(
        uint32 maturityTimeInDays,
        bool hasExtraRedeemRange,
        bool canBeRedeemedPrematurely,
        address agent // you can leave it 0
        ) 
        public payable
    {
        /* We don't issue bonds cheaper than MinNominalBondPrice*/
        require(msg.value >= MinNominalBondPrice);
        
        /* We don't issue bonds out of allowed maturity range */
        require(
            maturityTimeInDays >= MinMaturityTimeInDays && 
            maturityTimeInDays <= MaxMaturityTimeInDays
            );
            
        /* You can have a bonus on your first deal if specify an agent */
        bool hasRefBonus = false;
            
        /* On your first deal ...  */
        if (Users[msg.sender].agent == 0 && Users[msg.sender].totalBonds == 0)
        {
            /* ... you may specify an agent and get a bonus for this ... */
            if (agent != 0)
            {
                /* ... the agent should have some bonds behind him */
                if (Users[agent].totalBonds > 0)
                {
                    Users[msg.sender].agent = agent;
                    hasRefBonus = true;
                }
                else
                {
                    agent = 0;
                }
            }
        }
        /* On all your next deals you will have the same agent as on the first one */
        else
        {
            agent = Users[msg.sender].agent;
        }
            
        /* Issuing a new bond */
        Bond memory newBond;
        newBond.id = NextBondID;
        newBond.owner = msg.sender;
        newBond.issueTime = uint32(block.timestamp);
        newBond.canBeRedeemedPrematurely = canBeRedeemedPrematurely;
        
        /* You cant redeem your bond for profit untill this date */
        newBond.maturityTime = 
            newBond.issueTime + maturityTimeInDays*24*60*60;
        
        /* Your time to redeem is limited */    
        newBond.maxRedeemTime = 
            newBond.maturityTime + (hasExtraRedeemRange?ExtraRedeemRangeInDays:RedeemRangeInDays)*24*60*60;
        
        newBond.nominalPrice = msg.value;
        
        newBond.maturityPrice = MaturityPrice(
            newBond.nominalPrice,
            maturityTimeInDays,
            hasExtraRedeemRange,
            canBeRedeemedPrematurely,
            hasRefBonus
            );
        
        Bonds[newBond.id] = newBond;
        NextBondID += 1;
        
        /* Linking the bond to the owner so later he can easily find it */
        var user = Users[newBond.owner];
        user.bonds[user.totalBonds] = newBond.id;
        user.totalBonds += 1;
        
        /* Notify all users about the issuing event */
        Issued(newBond.id, newBond.owner);
        
        /* Founder's fee */
        uint moneyToFounder = div(
            mul(newBond.nominalPrice, FounderFeeInPercent), 
            100
            );
        /* Agent bonus */
        uint moneyToAgent = div(
            mul(newBond.nominalPrice, AgentBonusInPercent), 
            100
            );
        
        if (agent != 0 && moneyToAgent > 0)
        {
            /* Agent can potentially block user's trading attempts, so we dont use just .transfer*/
            Balances[agent] = add(Balances[agent], moneyToAgent);
        }
        
        /* Founder always gets his fee */
        require(moneyToFounder > 0);
        
        Founder.transfer(moneyToFounder);
    }
    
    /* You can also buy bonds on secondary market from other users */
    function BuyOnSecondaryMarket(uint32 bondId) 
        public payable
    {
        var bond = Bonds[bondId];
        
        /* A bond you are buying should be issued */
        require(bond.issueTime > 0);
        /* Checking, if the bond is a valuable asset */
        require(bond.redeemTime == 0 && block.timestamp < bond.maxRedeemTime);
        
        var price = bond.sellingPrice;
        /* You can only buy a bond if an owner is selling it */
        require(price > 0);
        /* You should have enough money to pay the owner */
        require(price <= msg.value);
        
        /* It's ok if you accidentally transfer more money, we will send them back */
        var residue = msg.value - price;
        
        /* Transfering the bond */
        var oldOwner = bond.owner;
        var newOwner = msg.sender;
        require(newOwner != 0 && newOwner != oldOwner);
        
        bond.sellingPrice = 0;
        bond.owner = newOwner;
        
        var user = Users[bond.owner];
        user.bonds[user.totalBonds] = bond.id;
        user.totalBonds += 1;
        
        /* Doublechecking the price */
        require(add(price, residue) == msg.value);
        
        /* Notify all users about the exchange event */
        Sold(bond.id, oldOwner, newOwner, price);
        
        /* Old owner can potentially block user's trading attempts, so we dont use just .transfer*/
        Balances[oldOwner] = add(Balances[oldOwner], price);
        
        if (residue > 0)
        {
            /* If there is residue we will send it back */
            newOwner.transfer(residue);
        }
    }
    
    /* You can sell your bond on the secondary market */
    function PlaceSellOrder(uint32 bondId, uint sellingPrice) 
        public
    {
        /* To protect from an accidental selling by 0 price */
        /* The selling price should be in Wei */
        require(sellingPrice >= MinNominalBondPrice);
        
        var bond = Bonds[bondId];
        
        /* A bond you are selling should be issued */
        require(bond.issueTime > 0);
        /* You can't update selling price, please, call CancelSellOrder beforehand */
        require(bond.sellingPrice == 0);
        /* You can't sell useless bonds */
        require(bond.redeemTime == 0 && block.timestamp < bond.maxRedeemTime);
        /* You should own a bond you're selling */
        require(bond.owner == msg.sender);
        
        bond.sellingPrice = sellingPrice;
        
        /* Notify all users about you wanting to sell the bond */
        SellOrderPlaced(bond.id, bond.owner);
    }
    
    /* You can cancel your sell order */
    function CancelSellOrder(uint32 bondId) 
        public
    {
        var bond = Bonds[bondId];
        
        /* Bond should be reserved for selling */
        require(bond.sellingPrice > 0);
        
        /* You should own a bond which sell order you're cancelling */
        require(bond.owner == msg.sender);
        
        bond.sellingPrice = 0;
        
        /* Notify all users about cancelling the selling order */
        SellOrderCanceled(bond.id, bond.owner);
    }
    
    /* Sometimes we can't just use .transfer for a security reason */
    function Withdraw()
        public
    {
        require(Balances[msg.sender] > 0);

        /* Don't forget about double entering in .transfer! */
        var money = Balances[msg.sender];
        Balances[msg.sender] = 0;

        msg.sender.transfer(money);
    }

    /* You can redeem bonds back to the contract for profit */
    /* But you need to wait till maturityTime */
    /* This is the key function where you get profit for a bond you own */
    function Redeem(uint32 bondId) 
        public
    {
        var bond = Bonds[bondId];
        
        require(CanBeRedeemed(bond));
        
        /* You should own a bond you redeem */
        require(bond.owner == msg.sender);
        
        /* If a bond has redeemTime it has been redeemed */
        bond.redeemTime = uint32(block.timestamp);
        
        /* If it's a premature redeem you will only get 
        PrematureRedeemPartInPercent of nominalPrice back */
        if (IsPremature(bond.maturityTime))
        {
            bond.maturityPrice = div(
                mul(bond.nominalPrice, PrematureRedeemPartInPercent), 
                100
                );
        }
        
        /* Notify all users about the redeem event */
        Redeemed(bond.id, bond.owner);
        
        /* Transfer funds to the owner */
        /* This is how you earn money */
        bond.owner.transfer(bond.maturityPrice);
    }
    
    /* Be carefull, this function can return a bound of a differet owner
    if the bond was sold. Always check the bond owner */
    function UserBondByOffset(uint32 offset) 
        public view 
        returns(
            uint32 bondId,
            bool canBeRedeemed,
            bool isPremature
            ) 
    {
        var bond = Bonds[Users[msg.sender].bonds[offset]];
        
        bondId = bond.id;
        canBeRedeemed = CanBeRedeemed(bond);
        isPremature = IsPremature(bond.maturityTime);
    }
    
    function BondInfoById(uint32 bondId) 
        public view 
        returns(
            bool canBeRedeemed,
            bool isPremature
            ) 
    {
        var bond = Bonds[bondId];
        
        canBeRedeemed = CanBeRedeemed(bond);
        isPremature = IsPremature(bond.maturityTime);
    }
    
    /* ADMIN */
     
    function AdmChange_README(string value) public
    {
        require(msg.sender == Founder);
        
        README = value;
    }
}