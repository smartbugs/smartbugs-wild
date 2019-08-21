pragma solidity ^0.4.16;


/// This is the smart contract for the LOTUS TOKEN NETWORK (LTO)
/// It covers the deployment of the three (3) Crowdsale periods
/// As well as the distribution of:
/// (1) Collected Crowdsale fund
/// (2) Reserved tokens for Airdrop
/// (3) Reserved Token Supply (55% of total supply)
/// (4) Unsold tokens during the Crowdsale Period

/// Total Supply is 90,000,000 tokens, for test purposes we will use 90,000 tokens
/// We've set a standard rate of:
/// 1 ETH = 3,000 tokens or 1 x 10^18 wei for ICO price

/// Deployments:
/// First successful deployment of ETH-Token exchange on 11/01/2017 4AM GMT+8 done by Dondi
/// Second successful run based on approved parameters: 11/01/2017 11PM GMT+8
/// Done by Michael, Sam, and Mahlory
///
/// Final Ticker Symbol will be -- LTO (Lotus Token, Inc.) -- unless already taken.

/// Core Members are:
/// Joss Morera (Concept Designer) and Jonathan Bate (Lead Coordinator)

/// Initial Shareholders are:
/// Luke McWright, Claire Zhang, and Wanjiao Nan

/// this is a freelance collaborative work of four (4) developers:
/// @author DONDI IMPERIAL, MICHAEL DE GUZMAN, SAMUEL SENDON II

/// Initital code researched by Michael on 10/26/2017 3PM GMT + 8
/// Major coding works by Dondi
/// Minor code mods, test deployments and debugging by Samuel
/// Additional Deployment Test by Mahlory
/// smart contract development compensation is agreed at
/// 2% per developer out of the crowdsale token supply and/or funds raised
/// All other values are based on Core Team discussions



/// SafeMath helps protect against integer overflow or underflow
contract SafeMath {
     function safeMul(uint a, uint b) internal pure returns (uint) {
          uint c = a * b;
          assert(a == 0 || c / a == b);
          return c;
     }

     function safeSub(uint a, uint b) internal pure returns (uint) {
          assert(b <= a);
          return a - b;
     }

     function safeAdd(uint a, uint b) internal pure returns (uint) {
          uint c = a + b;
          assert(c>=a && c>=b);
          return c;
     }
}

// Standard token interface (ERC 20)
// https://github.com/ethereum/EIPs/issues/20
contract Token is SafeMath {
     // Functions:
     /// @return total amount of tokens

     function totalSupply() public constant returns (uint256 supply);

     /// @param _owner - The address from which the balance will be retrieved
     /// @return The balance

     function balanceOf(address _owner) public constant returns (uint256 balance);

     /// @notice send _value token to _to from msg.sender
     /// @param _to - The address of the recipient
     /// @param _value - The amount of token to be transferred

     function transfer(address _to, uint256 _value) public returns(bool);

     /// @notice send _value token to _to from _from on the condition it is approved by _from
     /// @param _from - The address of the sender
     /// @param _to - The address of the recipient
     /// @param _value - The amount of token to be transferred
     /// @return Whether the transfer was successful or not

     function transferFrom(address _from, address _to, uint256 _value) public returns(bool);

     /// @notice msg.sender approves _addr to spend _value tokens
     /// @param _spender - The address of the account able to transfer the tokens
     /// @param _value - The amount of wei to be approved for transfer
     /// @return Whether the approval was successful or not

     function approve(address _spender, uint256 _value) public returns (bool success);

     /// @param _owner - The address of the account owning tokens
     /// @param _spender - The address of the account able to transfer the tokens
     /// @return Amount of remaining tokens allowed to spent

     function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

     // Events:
     event Transfer(address indexed _from, address indexed _to, uint256 _value);
     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StdToken is Token {
     // Fields:
     mapping(address => uint256) balances;
     mapping (address => mapping (address => uint256)) allowed;
     uint public supply = 0;  /// initialized supply is zero

     // Functions:
     function transfer(address _to, uint256 _value) public returns(bool) {
          require(balances[msg.sender] >= _value);
          require(balances[_to] + _value > balances[_to]);

          balances[msg.sender] = safeSub(balances[msg.sender],_value);
          balances[_to] = safeAdd(balances[_to],_value);

          Transfer(msg.sender, _to, _value);
          return true;
     }

     function transferFrom(address _from, address _to, uint256 _value) public returns(bool){
          require(balances[_from] >= _value);
          require(allowed[_from][msg.sender] >= _value);
          require(balances[_to] + _value > balances[_to]);

          balances[_to] = safeAdd(balances[_to],_value);
          balances[_from] = safeSub(balances[_from],_value);
          allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender],_value);

          Transfer(_from, _to, _value);
          return true;
     }

     function totalSupply() public constant returns (uint256) {
          return supply;
     }

     function balanceOf(address _owner) public constant returns (uint256) {
          return balances[_owner];
     }

     function approve(address _spender, uint256 _value) public returns (bool) {
          // To change the approve amount you first have to reduce the addresses`
          //  allowance to zero by calling approve(_spender, 0) if it is not
          //  already 0 to mitigate the race condition described here:
          //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
          require((_value == 0) || (allowed[msg.sender][_spender] == 0));

          allowed[msg.sender][_spender] = _value;
          Approval(msg.sender, _spender, _value);

          return true;
     }

     function allowance(address _owner, address _spender) public constant returns (uint256) {
          return allowed[_owner][_spender];
     }
}



contract LotusToken is StdToken {
    struct Sale {
        uint tokenLimit;
        uint tokenPriceInWei;
        uint tokensSold;
        uint minPurchaseInWei;
        uint maxPurchaseInWei;
        uint saleLimitPerAddress;
    }

    struct Signatory {
        address account;
        bool signed;
    }

    struct SaleTotals {
        uint earlyAdoptersSold;
        uint icoOneSold;
        uint icoTwoSold;
    }

    string public name = "Lotus Token Inc";
    string public symbol = "LTO";
    uint public decimals = 18;

    /// The address that owns this contract.
    /// Only this address is allowed to execute the functions that move the sale through stages.
    address private owner;

    /// Vesting parameters
    /// Vesting cliff. This must be set to some time in the future to allow for proper vesting.
    uint public cliff = 0;
    /// Timespan to schedule allocation of vested shares.
    uint private vestingSchedule = 30 days; // Testing code has this set to 1 minute for the production
    /// deploy set this to "30 days". <-----<<<<<<<<<

    /// wallet declarations (added 11/9/2017 1:30PM GMT + 8) by Sam
    /// venture capitalists (shareholders)
    address public vc1Wallet4Pct;
    address public vc2Wallet4Pct;
    address public vc3Wallet4Pct;

    /// co-founders
    address public cf1Wallet2Pct;
    address public cf2Wallet2Pct;

    /// dev-team
    address public dev1Wallet2Pct;
    address public dev2Wallet2Pct;
    address public dev3Wallet2Pct;
    address public dev4Wallet2Pct;

    /// branding
    address public preicobrandingWallet1Pct;

    /// management multi-sig address
    address public lotusWallet75Pct;

    /// airdrop contract address
    address public airdropWallet5Pct;

    /// tokensSold amount of tokens sold or transferred
    uint public tokensSold = 0;

    /// Allocation of collected eth from sale to respective wallets.
    mapping(address => uint256) internal ethDistribution;

    /// Allocation of tokens left over from crowdsale. Note that these are reserved under a vesting scheme described in the whitepaper.
    mapping(address => uint256) private vestingTokens;
    mapping(address => uint256) private withdrawnVestedTokens;

    Sale public EARLYADOPTERS;
    Sale public ICO_ONE;
    Sale public ICO_TWO;

    /// Per sale stage ledger. Used to track and set limits on tokens purchased by an address per sale stage.
    mapping(address => uint256) private earlyAdoptersAddressPurchased;
    mapping(address => uint256) private icoOneAddressPurchased;
    mapping(address => uint256) private icoTwoAddressPurchased;

    enum SaleStage { Waiting, EarlyAdopters, EarlyAdoptersClosed,  IcoOne, IcoOneClosed, IcoTwo, Closed }
    SaleStage currentStage = SaleStage.Waiting;

    /// var declarations to get wallet addresses (11/7/2017 1:30PM GMT + 8) by Sam
    function LotusToken(address _shareholder1Account,
                        address _shareholder2Account,
                        address _shareholder3Account,

                        /// co-founders
                        address _core1Account,
                        address _core2Account,

                        /// dev-team
                        address _dev1Account,
                        address _dev2Account,
                        address _dev3Account,
                        address _dev4Account,

                        /// branding
                        address _brandingAccount,

                        /// company wallet
                        address _lotusTokenAccount,

                        /// airdrop contract address
                        address _airdropContractAccount

    ) public {
        /// The owner is whoever initialized the contract.
        owner = msg.sender;

        // Total supply of tokens is fixed at this value (90000000).
        // Convert to the appropriate decimal place.
        supply = 90000000 * 10 ** decimals;

        /// Crowdsale parameters set by Sam (11/7/2017)

        /// EARLYADOPTERS tokens are 10% of total supply.
        /// EARLYADOPTERS value: 1 ETH at 5999 tokens
        /// 1 token = 1 ETH / 6000 = (10^18)/6000
        /// EARLYADOPTERS value in wei: 166666666666667 weis
        /// EARLYADOPTERS set tokens sold to zero at contract creation.
        /// EARLYADOPTERS min purchase in wei: 2 * 10 ** 17 or 0.2 ETH by Dondi
        /// EARLYADOPTERS max purchase in wei: 1 * 10 ** 18 or 1 ETH by Dondi (test)
        /// max purchase per transaction in wei: 5 * 10 ** 18 (5 eth on LIVE)
        /// EARLYADOPTERS max purchase per address for testing purposes: 5999 (1 ether)
        /// max purchase per address on live deployment: equivalent to 10 ethers
        /// Max Ethers to raise: 1500 (live); 1.5 ethers (test)
        uint earlyAdoptersSupply = (supply * 10 / 100); /// - 2000000000000000000;
        // EARLYADOPTERS = Sale(supply * 10 / 100, 166666666666667, 0);
        EARLYADOPTERS = Sale(earlyAdoptersSupply, 166666666666667, 0, 2 * 10 ** 17, 5 * 10 ** 18, 59990000000000000000000);

        /// PRESALE tokens are 15% of total supply.
        /// ICO1 (PRESALE) value: 1 ETH = 3750 tokens
        /// 1 token = 1/3750 = (10^18)/3750
        /// ICO1 value in wei: 266666666666666 changed from 333333333333334
        /// ICO_ONE set tokens sold to zero at contract creation.
        /// ICO_ONE min purchase in wei: 2 * 10 ** 17 or 0.2 ETH by Dondi
        /// ICO_ONE max purchase in wei: 2 * 10 ** 18 or 2 ETH by Dondi (TEST)
        /// max purchase per transaction in wei: 10 * 10 ** 18 (10 eth on LIVE)
        /// ICO_ONE max purchase per address for testing purposes: 7500 (2 ethers)
        /// max purchase per address on live deployment: equivalent to 18 ethers or
        /// max ethers to raise: 3600 (live); 3.6 (test)
        ICO_ONE = Sale(supply * 15 / 100, 266666666666666, 0, 2 * 10 ** 17, 10 * 10 ** 18, 67500000000000000000000);

        /// ICO2 (MAIN ICO) tokens are 15% of total supply.
        /// ICO2 value: 1 ETH = 3000 tokens instead of 2000
        ///  1 token = 1/3000 = (10^18)/3000
        /// ICO2 value in wei: 333333333333334 changed from 500000000000000
        /// ICO_TWO set tokens sold to zero at contract creation.
        /// ICO_TWO min purchase in wei: 2 * 10 ** 17 or 0.2 ETH by Dondi
        /// ICO_TWO max purchase in wei: 3 * 10 ** 18 or 3 ETH by Dondi (test)
        /// max purchase per transaction in wei: 20 * 10 ** 18 (20 eth on LIVE)
        /// ICO_TWO max purchase per address for testing purposes: 10000
        /// max purchase per address on live deployment: equivalent to 25 ethers (75000)
        /// max ethers to raise: 4,500 (live); 4.5 (test)
        ICO_TWO = Sale(supply * 15 / 100, 333333333333334, 0, 2 * 10 ** 17, 20 * 10 ** 18, 75000000000000000000000);

        // Technically this check should  not be required as the limits are computed above as fractions of the total supply.
        require(safeAdd(safeAdd(EARLYADOPTERS.tokenLimit, ICO_ONE.tokenLimit), ICO_ONE.tokenLimit)  <= supply);

        /// For safety zero out the allocation for the 0 address.
        ethDistribution[0X0] = 0;

        /// venture capitalist
        vc1Wallet4Pct = _shareholder1Account;
        vc2Wallet4Pct = _shareholder2Account;
        vc3Wallet4Pct = _shareholder3Account;

        /// co-founders
        cf1Wallet2Pct = _core1Account;
        cf2Wallet2Pct = _core2Account;

        /// dev-team
        dev1Wallet2Pct = _dev1Account;
        dev2Wallet2Pct = _dev2Account;
        dev3Wallet2Pct = _dev3Account;
        dev4Wallet2Pct = _dev4Account;

        /// branding
        preicobrandingWallet1Pct = _brandingAccount;

        lotusWallet75Pct = _lotusTokenAccount; /// this will go to the company controlled multi-sig wallet
        /// this replaced adminWallet, posticosdWallet, mktgWallet, legalWallet, cntgncyWallet
        /// it will contain both the 75% of ETHs collected via crowdsale
        /// it will also contain the unsold tokens via the crowdsale periods
        /// it will also contain the 55% tokens from total supply

        airdropWallet5Pct = _airdropContractAccount; /// airdrop wallet contract
    }

    /// modifier coded by Dondi
    modifier mustBeSelling {
        require(currentStage == SaleStage.EarlyAdopters || currentStage == SaleStage.IcoOne || currentStage == SaleStage.IcoTwo);
        _;
    }

    modifier ownerOnly {
        require(msg.sender == owner);
        _;
    }

    // function coded by Dondi
    function () public payable mustBeSelling {
        // Must have sent some ether.
        require(msg.value > 0);

        // Must be purchasing at least the min allowed and not more than the max allowed ETH.
        require(msg.value >= currentMinPurchase() && msg.value <= currentMaxPurchase());


        // The price at the current sale stage.
        uint priceNow = currentSalePriceInWei();
        // The total amount of tokens for sale at this stage
        uint currentLimit = currentSaleLimit();
        // The amount of tokens that have been sold at this sale stage.
        uint currentSold = currentSaleSold();
        // The total amount of tokens that a single address can purchase at this sale stage.
        uint currentLimitPerAddress = currentSaleLimitPerAddress();
        // The total amount of tokens already purchased by the current buyer.
        uint currentStageTokensBought = currentStageTokensBoughtByAddress();

        // Convert msg.value into wei (line added 11/1/2017 11PM)
        uint priceInWei = msg.value;

        // change numerator from msg.value into priceInWei 11/01/2017 11PM
        uint tokensAtPrice = (priceInWei / priceNow) * 10 ** decimals;     // total token equivalent of contributed ETH

        // make sure the payment does not exceed the supply (11/5/2017 10AM)
        //  backer with exact ETH sent equivalent to supply left will get accepted
        require(tokensAtPrice + currentSold <= currentLimit);

        // Buyer can't exceed the per address limit
        require(tokensAtPrice + currentStageTokensBought <= currentLimitPerAddress);

        // remove conditional statements and proceed with credit of tokens to backer (11/5/2017 10AM)
        balances[msg.sender] = safeAdd(balances[msg.sender], tokensAtPrice);  /// send tokens
        tokensSold = safeAdd(tokensSold, tokensAtPrice); /// Update total token sold

        // Update tokens sold for current sale.
        _addTokensSoldToCurrentSale(tokensAtPrice);

        // Distribute ether as it arrives.
        distributeCollectedEther();

        // Show transaction details on blockchain explorer
        Transfer(this, msg.sender, tokensAtPrice);
    }

    // send ether to the fund collection wallets
    // override to create custom fund forwarding mechanisms
    // taken from OpenZeppelin, added 11/7/2017 10AM
    function distributeCollectedEther() internal {

    /**
    /// November 9, 2017
    /// Distribution details: TotalSupply = 9M tokens
    /// each core member receives .9% from TotalSupply (9M * 9 / 1000)
    /// except for branding, which gets .45% (9M * 45 / 10000)
    /// seed fund venture capitalist receives 1.8% each multiplied by 3 persons (9M * 18 / 1000)
    /// In Crowdsale values (which is 45% of the TotalSupply), this divides the funds into:
    /// 25% for all core members and shareholders (10 individuals)
    /// and 75% to Lotus Post ICO Management
    **/

    /// Allocate eth to the appropriate accounts.
    /// To transfer the share of the collected ETH, accounts need to call the 'withdraw allocation' function from the addresses passed to this contract during deployment.
    /// Note that due to the implementation below it is not possible to use the same address for multiple recipients. If the same address is used twice or more, only the last allocation will apply.

    /// TODO: Update the Crowdsale Fund division (11/9/2017)
    /// Lines 361 to 392 updated on 11/9/2017 by Sam
    /// shareholders each get 4% of the Crowdsale Fund
        ethDistribution[vc1Wallet4Pct] = safeAdd(ethDistribution[vc1Wallet4Pct], msg.value * 4 / 100);
        ethDistribution[vc2Wallet4Pct] = safeAdd(ethDistribution[vc2Wallet4Pct], msg.value * 4 / 100);
        ethDistribution[vc3Wallet4Pct] = safeAdd(ethDistribution[vc3Wallet4Pct], msg.value * 4 / 100);

    /// co-founders each get 2% of the Crowdsale Fund
        ethDistribution[cf1Wallet2Pct] = safeAdd(ethDistribution[cf1Wallet2Pct], msg.value * 2 / 100);
        ethDistribution[cf2Wallet2Pct] = safeAdd(ethDistribution[cf2Wallet2Pct], msg.value * 2 / 100);

    /// dev-team members each get 2% of the Crowdsale Fund
        ethDistribution[dev1Wallet2Pct] = safeAdd(ethDistribution[dev1Wallet2Pct], msg.value * 2 / 100);
        ethDistribution[dev3Wallet2Pct] = safeAdd(ethDistribution[dev3Wallet2Pct], msg.value * 2 / 100);
        ethDistribution[dev2Wallet2Pct] = safeAdd(ethDistribution[dev2Wallet2Pct], msg.value * 2 / 100);
        ethDistribution[dev4Wallet2Pct] = safeAdd(ethDistribution[dev4Wallet2Pct], msg.value * 2 / 100);

    /// branding developer gets 1% of the Crowdsale Fund
        ethDistribution[preicobrandingWallet1Pct] = safeAdd(ethDistribution[preicobrandingWallet1Pct], msg.value * 1 / 100);

    /// management multi-sig address gets 75% of Crowdsale Fund
        ethDistribution[lotusWallet75Pct] = safeAdd(ethDistribution[lotusWallet75Pct], msg.value * 75 / 100);
    }

    /// Distribute the tokens left after the crowdsale to the pre-agreed accounts
    function distributeRemainingTokens() internal ownerOnly {
        /// @dev to sam: Remaining tokens are distributed here. (11/8/2017)
        uint crowdsaleSupply = supply * 40 / 100;
        uint unsoldTokens = crowdsaleSupply - tokensSold;

        // lines 400 to 450 updated on 11/9/2017 by Sam
        // Lotus Wallet gets 75% of the unsoldTokens
        balances[lotusWallet75Pct] = safeAdd(balances[lotusWallet75Pct], unsoldTokens * 75 / 100);
        Transfer(this, lotusWallet75Pct, unsoldTokens * 75 / 100);

        // Shareholders get 4% each (x3) of the unsoldTokens, Core Team (CT) gets 2% each (x6) and Branding gets 1%
        // Total: 25% of unsoldTokens
        // Only 25% of the actual allocations are immediately transferred to the recipients, the rest are left over for vesting.
        // The remaining tokens (75%) are reserved for vesting and are transferred to the Lotus Token Inc wallet contract address.
        // Shareholder 1: Luke McWright
        balances[vc1Wallet4Pct] = safeAdd(balances[vc1Wallet4Pct],  unsoldTokens * 4 / 100 * 25 / 100);
        Transfer(this, vc1Wallet4Pct, unsoldTokens * 4 / 100 * 25 / 100);
        // Vesting
        vestingTokens[vc1Wallet4Pct] = safeAdd(vestingTokens[vc1Wallet4Pct], unsoldTokens * 4 / 100 * 75 / 100);

        // Shareholder 2: Claire Zhang
        balances[vc2Wallet4Pct] = safeAdd(balances[vc2Wallet4Pct], unsoldTokens * 4 / 100 * 25 / 100);
        Transfer(this, vc2Wallet4Pct, unsoldTokens * 4 / 100 * 25 / 100);
        // Vesting
        vestingTokens[vc2Wallet4Pct] = safeAdd(vestingTokens[vc2Wallet4Pct], unsoldTokens * 4 / 100 * 75 / 100);

        // Shareholder 3: Wan Jiao Nan
        balances[vc3Wallet4Pct] = safeAdd(balances[vc3Wallet4Pct], unsoldTokens * 4 / 100 * 25 / 100);
        Transfer(this, vc3Wallet4Pct, unsoldTokens * 4 / 100 * 25 / 100);
        // Vesting
        vestingTokens[vc3Wallet4Pct] = safeAdd(vestingTokens[vc3Wallet4Pct], unsoldTokens * 4 / 100 * 75 / 100);

        // CT Co-Founder 1: Joss Morera
        balances[cf1Wallet2Pct] = safeAdd(balances[cf1Wallet2Pct], unsoldTokens * 2 / 100 * 25 / 100);
        Transfer(this, cf1Wallet2Pct, unsoldTokens * 2 / 100 * 25 / 100);
        // Vesting
        vestingTokens[cf1Wallet2Pct] = safeAdd(vestingTokens[cf1Wallet2Pct], unsoldTokens * 2 / 100 * 75 / 100);

        // CT Co-Founder 2: Jonathan Bate
        balances[cf2Wallet2Pct] = safeAdd(balances[cf2Wallet2Pct], unsoldTokens * 2 / 100 * 25 / 100);
        Transfer(this, cf2Wallet2Pct, unsoldTokens * 2 / 100 * 25 / 100);
        // Vesting
        vestingTokens[cf2Wallet2Pct] = safeAdd(vestingTokens[cf2Wallet2Pct], unsoldTokens * 2 / 100 * 75 / 100);

        // CT Dev-Team Leader and Social Media Manager: Michael De Guzman
        balances[dev1Wallet2Pct] = safeAdd(balances[dev1Wallet2Pct], unsoldTokens * 2 / 100 * 25 / 100);
        Transfer(this, dev1Wallet2Pct, unsoldTokens * 2 / 100 * 25 / 100);
        // Vesting
        vestingTokens[dev1Wallet2Pct] = safeAdd(vestingTokens[dev1Wallet2Pct], unsoldTokens * 2 / 100 * 75 / 100);

        // CT Senior Solidity Developer:
        balances[dev2Wallet2Pct] = safeAdd(balances[dev2Wallet2Pct], unsoldTokens * 2 / 100 * 25 / 100);
        Transfer(this, dev2Wallet2Pct, unsoldTokens * 2 / 100 * 25 / 100);
        // Vesting
        vestingTokens[dev2Wallet2Pct] = safeAdd(vestingTokens[dev2Wallet2Pct], unsoldTokens * 2 / 100 * 75 / 100);

        // CT Server Manager and Junior Developer: Mahlory Ambrosio
        balances[dev3Wallet2Pct] = safeAdd(balances[dev3Wallet2Pct], unsoldTokens * 2 / 100 * 25 / 100);
        Transfer(this, dev3Wallet2Pct, unsoldTokens * 2 / 100 * 25 / 100);
        // Vesting
        vestingTokens[dev3Wallet2Pct] = safeAdd(vestingTokens[dev3Wallet2Pct], unsoldTokens * 2 / 100 * 75 / 100);

        // CT Branding - Logo, Whitepaper Design, Website Design: Tamlyn
        balances[preicobrandingWallet1Pct] = safeAdd(balances[preicobrandingWallet1Pct], unsoldTokens * 1 / 100 * 25 / 100);
        Transfer(this, preicobrandingWallet1Pct, unsoldTokens * 1 / 100  * 25 / 100);
        // Vesting
        vestingTokens[preicobrandingWallet1Pct] = safeAdd(vestingTokens[preicobrandingWallet1Pct], unsoldTokens * 1 / 100 * 75 / 100);

        // CT Jr Solidity Developer: Samuel T Sendon II
        balances[dev4Wallet2Pct] = safeAdd(balances[dev4Wallet2Pct], unsoldTokens * 2 / 100 * 25 / 100);
        Transfer(this, dev4Wallet2Pct, unsoldTokens * 2 / 100 * 25 / 100);
        // Vesting
        vestingTokens[dev4Wallet2Pct] = safeAdd(vestingTokens[dev4Wallet2Pct], unsoldTokens * 2 / 100 * 75 / 100);

        // TODO: At this point all tokens have been allocated.
        //   1) Should the tokensSold value be updated as well?
        //   2) Verify that there are no edge cases that will result in inadverdently mining additional tokens.
        //      One possiblity is to keep a 'tokensIssued' counter and validate against that when issuing (not transfering) tokens.

        /// transfer the rest of the token supply minus the crowdsale supply to the Lotus Wallet
        uint reservedSupply = supply * 55 / 100;

        /// This should be a multi-sig wallet so that each time fund is withdrawn from the smart contract,
        /// it needs to be executed from within the multi-sig wallet, and each time funds are withdrawn,
        /// it will need signatures from all signatories
        balances[lotusWallet75Pct] = safeAdd(balances[lotusWallet75Pct], reservedSupply);
        Transfer(this, lotusWallet75Pct, reservedSupply);

        /// transfer the tokens for Airdrop on a wallet contract
        uint airdropSupply = supply * 5 / 100;
        /// UNCERTAIN whether this should be multi-sig or not
        balances[airdropWallet5Pct] = safeAdd(balances[airdropWallet5Pct], airdropSupply);
        Transfer(this, airdropWallet5Pct, airdropSupply);
    }

    function startEarlyAdopters() public ownerOnly {
        require(currentStage == SaleStage.Waiting);
        currentStage = SaleStage.EarlyAdopters;
    }

    function closeEarlyAdopters() public ownerOnly {
        require(currentStage == SaleStage.EarlyAdopters);
        currentStage = SaleStage.EarlyAdoptersClosed;
    }

    function startIcoOne() public ownerOnly {
        require(currentStage == SaleStage.EarlyAdopters || currentStage == SaleStage.EarlyAdoptersClosed);
        currentStage = SaleStage.IcoOne;
    }

    function closeIcoOne() public ownerOnly {
        require(currentStage == SaleStage.IcoOne);
        currentStage = SaleStage.IcoOneClosed;
    }

    function startIcoTwo() public ownerOnly {
        require(currentStage == SaleStage.IcoOne || currentStage == SaleStage.IcoOneClosed);
        currentStage = SaleStage.IcoTwo;

        /// optional auto exec process condition to endSale
        /// only if total tokens sold is reached (11/07/2017 3PM GMT + 8)
        /// if total tokens sold is = to sum of earlyadopters, icoone, icotwo supplies

    }

    function closeSale() public ownerOnly {
        require(currentStage == SaleStage.IcoTwo);
        currentStage = SaleStage.Closed;
        distributeRemainingTokens(); // 11/22/2017 by Dondi
        /// Start countdown to cliff
        cliff = now + 180 days; // Testing code has this set to "now + 5 minutes"
        /// in the live deploy set this to "now + 180 days".
    }

    modifier doneSelling {
        require(currentStage == SaleStage.Closed);
        _;
    }

    /// @dev Let the caller withdraw all ether allocated to it during the sale period.
    function withdrawAllocation() public {
        // Lifted from: http://solidity.readthedocs.io/en/develop/solidity-by-example.html
        // It is a good guideline to structure functions that interact
        // with other contracts (i.e. they call functions or send Ether)
        // into three phases:
        // 1. checking conditions
        // 2. performing actions (potentially changing conditions)
        // 3. interacting with other contracts

        // Checking Conditions
        require(ethDistribution[msg.sender] > 0);
        // Must be at least after a sale stage but not during a sale.
        require(currentStage == SaleStage.EarlyAdoptersClosed || currentStage == SaleStage.IcoOneClosed || currentStage == SaleStage.Closed);
        // 75% allocation can only be withdrawn when the crowd sale has completed
        require(msg.sender != lotusWallet75Pct || currentStage == SaleStage.Closed);


        // Performing actions
        // copy the current value allocated as we will change the saved value later.
        uint toTransfer = ethDistribution[msg.sender];
        // Note that in order to avoid re-entrancy the allocation is zeroed BEFORE the actual transfer.
        ethDistribution[msg.sender] = 0;

        // (Potentially) interacting with other contracts.
        msg.sender.transfer(toTransfer);
    }

    function currentSalePriceInWei() constant public mustBeSelling returns(uint) {
        if(currentStage == SaleStage.EarlyAdopters) {
            return EARLYADOPTERS.tokenPriceInWei;
        } else if (currentStage == SaleStage.IcoOne) {
            return ICO_ONE.tokenPriceInWei;
        } else if (currentStage == SaleStage.IcoTwo) {
            return ICO_TWO.tokenPriceInWei;
        }
    }


    function currentSaleLimit() constant public mustBeSelling returns(uint) {
        if(currentStage == SaleStage.EarlyAdopters) {
            return EARLYADOPTERS.tokenLimit;
        } else if (currentStage == SaleStage.IcoOne) {
            return ICO_ONE.tokenLimit;
        } else if (currentStage == SaleStage.IcoTwo) {
            return ICO_TWO.tokenLimit;
        }
    }

    function currentSaleSold() constant public mustBeSelling returns(uint) {
        if(currentStage == SaleStage.EarlyAdopters) {
            return EARLYADOPTERS.tokensSold;
        } else if (currentStage == SaleStage.IcoOne) {
            return ICO_ONE.tokensSold;
        } else if (currentStage == SaleStage.IcoTwo) {
            return ICO_TWO.tokensSold;
        }
    }

    function currentMinPurchase() constant public mustBeSelling returns(uint) {
        if(currentStage == SaleStage.EarlyAdopters) {
            return EARLYADOPTERS.minPurchaseInWei;
        } else if (currentStage == SaleStage.IcoOne) {
            return ICO_ONE.minPurchaseInWei;
        } else if (currentStage == SaleStage.IcoTwo) {
            return ICO_TWO.minPurchaseInWei;
        }
    }

    function currentMaxPurchase() constant public mustBeSelling returns(uint) {
        if(currentStage == SaleStage.EarlyAdopters) {
            return EARLYADOPTERS.maxPurchaseInWei;
        } else if (currentStage == SaleStage.IcoOne) {
            return ICO_ONE.maxPurchaseInWei;
        } else if (currentStage == SaleStage.IcoTwo) {
            return ICO_TWO.maxPurchaseInWei;
        }
    }

    function currentSaleLimitPerAddress() constant public mustBeSelling returns(uint) {
        if(currentStage == SaleStage.EarlyAdopters) {
            return EARLYADOPTERS.saleLimitPerAddress;
        } else if (currentStage == SaleStage.IcoOne) {
            return ICO_ONE.saleLimitPerAddress;
        } else if (currentStage == SaleStage.IcoTwo) {
            return ICO_TWO.saleLimitPerAddress;
        }
    }

    function currentStageTokensBoughtByAddress() constant public mustBeSelling returns(uint) {
        if(currentStage == SaleStage.EarlyAdopters) {
            return earlyAdoptersAddressPurchased[msg.sender];
        } else if (currentStage == SaleStage.IcoOne) {
            return icoOneAddressPurchased[msg.sender];
        } else if (currentStage == SaleStage.IcoTwo) {
            return icoTwoAddressPurchased[msg.sender];
        }
    }

    function _addTokensSoldToCurrentSale(uint _additionalTokensSold) internal mustBeSelling {
        if(currentStage == SaleStage.EarlyAdopters) {
            EARLYADOPTERS.tokensSold = safeAdd(EARLYADOPTERS.tokensSold, _additionalTokensSold);
            earlyAdoptersAddressPurchased[msg.sender] = safeAdd(earlyAdoptersAddressPurchased[msg.sender], _additionalTokensSold);
        } else if (currentStage == SaleStage.IcoOne) {
            ICO_ONE.tokensSold = safeAdd(ICO_ONE.tokensSold, _additionalTokensSold);
            icoOneAddressPurchased[msg.sender] = safeAdd(icoOneAddressPurchased[msg.sender], _additionalTokensSold);
        } else if (currentStage == SaleStage.IcoTwo) {
            ICO_TWO.tokensSold = safeAdd(ICO_TWO.tokensSold, _additionalTokensSold);
            icoTwoAddressPurchased[msg.sender] = safeAdd(icoTwoAddressPurchased[msg.sender], _additionalTokensSold);
        }
    }

    function withdrawVestedTokens() public doneSelling {
        // 1. checking conditions
        // Cliff must have been previously set (This is set in closeSale).
        require(cliff > 0);
        // Must be past the cliff. (and equal or greater than the initial value of cliff upon CloseSale)
        require(now >= cliff);
        // Must have some (remaining) vested tokens for withdrawal.
        require(withdrawnVestedTokens[msg.sender] < vestingTokens[msg.sender]);

        // 2. performing actions (potentially changing conditions)
        // How many scheduled allocations have passed.
        uint schedulesPassed = ((now - cliff) / vestingSchedule) + 1;
        // Number of tokens available to the user at this point (may include previously already withdrawn tokens).
        uint vestedTokens = (vestingTokens[msg.sender] / 15) * schedulesPassed;
        // Actual tokens available for withdrawal at this point.
        uint availableToWithdraw = vestedTokens - withdrawnVestedTokens[msg.sender];
        // For contract safety mark tokens as allocated before allocating.
        withdrawnVestedTokens[msg.sender] = safeAdd(withdrawnVestedTokens[msg.sender], availableToWithdraw);
        // Allocate tokens
        balances[msg.sender] = safeAdd(balances[msg.sender], availableToWithdraw);
        Transfer(this, msg.sender, availableToWithdraw);
    }
}