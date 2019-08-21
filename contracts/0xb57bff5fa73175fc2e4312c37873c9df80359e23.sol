pragma solidity ^0.4.24;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

interface Token {
    function transfer(address to, uint256 value) external returns (bool success);
    function transferFrom(address from, address to, uint256 value) external returns (bool success);
    function approve(address spender, uint256 value) external returns (bool success);

    // This is not an abstract function, because solc won't recognize generated getter functions for public variables as functions.
    function totalSupply() external constant returns (uint256 supply);
    function balanceOf(address owner) external constant returns (uint256 balance);
    function allowance(address owner, address spender) external constant returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface PromissoryToken {

	function claim() payable external;
	function lastPrice() external returns(uint256);
}

contract DutchAuction {

    /*
     *  Events
     */
    event BidSubmission(address indexed sender, uint256 amount);
    event logPayload(bytes _data, uint _lengt);

    /*
     *  Constants
     */
    uint constant public MAX_TOKENS_SOLD = 10000000 * 10**18; // 10M
    uint constant public WAITING_PERIOD = 45 days;

    /*
     *  Storage
     */


    address public pWallet;
    Token public KittieFightToken;
    address public owner;
    PromissoryToken public PromissoryTokenIns; 
    address constant public promissoryAddr = 0x0348B55AbD6E1A99C6EBC972A6A4582Ec0bcEb5c;
    uint public ceiling;
    uint public priceFactor;
    uint public startBlock;
    uint public endTime;
    uint public totalReceived;
    uint public finalPrice;
    mapping (address => uint) public bids;
    Stages public stage;

    /*
     *  Enums
     */
    enum Stages {
        AuctionDeployed,
        AuctionSetUp,
        AuctionStarted,
        AuctionEnded,
        TradingStarted
    }

    /*
     *  Modifiers
     */
    modifier atStage(Stages _stage) {
        require(stage == _stage);
            // Contract not in expected state
        _;
    }

    modifier isOwner() {
        require(msg.sender == owner);
            // Only owner is allowed to proceed
        _;
    }

    modifier isWallet() {
         require(msg.sender == address(pWallet));
            // Only wallet is allowed to proceed
        _;
    }

    modifier isValidPayload() {
        emit logPayload(msg.data, msg.data.length);
        require(msg.data.length == 4 || msg.data.length == 36, "No valid payload");
        _;
    }

    modifier timedTransitions() {
        if (stage == Stages.AuctionStarted && calcTokenPrice() <= calcStopPrice())
            finalizeAuction();
        if (stage == Stages.AuctionEnded && now > endTime + WAITING_PERIOD)
            stage = Stages.TradingStarted;
        _;
    }

    /*
     *  Public functions
     */
    /// @dev Contract constructor function sets owner.
    /// @param _pWallet KittieFight promissory wallet.
    /// @param _ceiling Auction ceiling.
    /// @param _priceFactor Auction price factor.
    constructor(address _pWallet, uint _ceiling, uint _priceFactor)
        public
    {
        if (_pWallet == 0 || _ceiling == 0 || _priceFactor == 0)
            // Arguments are null.
            revert();
        owner = msg.sender;
        PromissoryTokenIns = PromissoryToken(promissoryAddr);
        pWallet = _pWallet;
        ceiling = _ceiling;
        priceFactor = _priceFactor;
        stage = Stages.AuctionDeployed;
    }

    /// @dev Setup function sets external contracts' addresses.
    /// @param _kittieToken  token address.
    function setup(address _kittieToken)
        public
        isOwner
        atStage(Stages.AuctionDeployed)
    {
        if (_kittieToken == 0)
            // Argument is null.
            revert();
        KittieFightToken = Token(_kittieToken);
        // Validate token balance
        if (KittieFightToken.balanceOf(this) != MAX_TOKENS_SOLD)
            revert();
        stage = Stages.AuctionSetUp;
    }

    /// @dev Starts auction and sets startBlock.
    function startAuction()
        public
        isOwner
        atStage(Stages.AuctionSetUp)
    {
        stage = Stages.AuctionStarted;
        startBlock = block.number;
    }

    /// @dev Changes auction ceiling and start price factor before auction is started.
    /// @param _ceiling Updated auction ceiling.
    /// @param _priceFactor Updated start price factor.
    function changeSettings(uint _ceiling, uint _priceFactor)
        public
        isWallet
        atStage(Stages.AuctionSetUp)
    {
        ceiling = _ceiling;
        priceFactor = _priceFactor;
    }

    /// @dev Calculates current token price.
    /// @return Returns token price.
    function calcCurrentTokenPrice()
        public
        timedTransitions
        returns (uint)
    {
        if (stage == Stages.AuctionEnded || stage == Stages.TradingStarted)
            return finalPrice;
        return calcTokenPrice();
    }

    /// @dev Returns correct stage, even if a function with timedTransitions modifier has not yet been called yet.
    /// @return Returns current auction stage.
    function updateStage()
        public
        timedTransitions
        returns (Stages)
    {
        return stage;
    }

    /// @dev Allows to send a bid to the auction.
    /// @param receiver Bid will be assigned to this address if set.
    function bid(address receiver)
        public
        payable
        //isValidPayload
        timedTransitions
        atStage(Stages.AuctionStarted)
        returns (uint amount)
    {
        // If a bid is done on behalf of a user via ShapeShift, the receiver address is set.
        if (receiver == 0)
            receiver = msg.sender;
        amount = msg.value;
        // Prevent that more than 90% of tokens are sold. Only relevant if cap not reached.
        uint maxWei = (MAX_TOKENS_SOLD / 10**18) * calcTokenPrice() - totalReceived;
        uint maxWeiBasedOnTotalReceived = ceiling - totalReceived;
        if (maxWeiBasedOnTotalReceived < maxWei)
            maxWei = maxWeiBasedOnTotalReceived;
        // Only invest maximum possible amount.
        if (amount > maxWei) {
            amount = maxWei;
            // Send change back to receiver address. In case of a ShapeShift bid the user receives the change back directly.
            if (!receiver.send(msg.value - amount))
                // Sending failed
                revert();
        }
        // Forward funding to ether pWallet
        if (amount == 0 || !address(pWallet).send(amount))
            // No amount sent or sending failed
            revert();
        bids[receiver] += amount;
        totalReceived += amount;
        if (maxWei == amount)
            // When maxWei is equal to the big amount the auction is ended and finalizeAuction is triggered.
            finalizeAuction();
        emit BidSubmission(receiver, amount);
    }

    /// @dev Claims tokens for bidder after auction.
    /// @param receiver Tokens will be assigned to this address if set.
    function claimTokens(address receiver)
        public
        isValidPayload
        timedTransitions
        atStage(Stages.TradingStarted)
    {
        if (receiver == 0)
            receiver = msg.sender;
        uint tokenCount = bids[receiver] * 10**18 / finalPrice;
        bids[receiver] = 0;
        KittieFightToken.transfer(receiver, tokenCount);
    }

    /// @dev Calculates stop price.
    /// @return Returns stop price.
    function calcStopPrice()
        view
        public
        returns (uint)
    {
        return totalReceived * 10**18 / MAX_TOKENS_SOLD + 1;
    }

    /// @dev Calculates token price.
    /// @return Returns token price.
    function calcTokenPrice()
        view
        public
        returns (uint)
    {
        return priceFactor * 10**18 / (block.number - startBlock + 7500) + 1;
    }

    /*
     *  Private functions
     */
    function finalizeAuction()
        private
    {
        stage = Stages.AuctionEnded;

        if (totalReceived == ceiling)
            finalPrice = calcTokenPrice();
        else
            finalPrice = calcStopPrice();

        endTime = now;
    }


}

contract Dutchwrapper is DutchAuction {


    uint constant public MAX_TOKEN_REFERRAL = 2000000 * 10**18; // One Million and eight hundred  thousand

    uint public claimedTokenReferral = 0; // 800,000 : eigth hundred thousand limit
    uint public totalEthEarnedByPartners = 0; // Partners earning


    // 2,000,000 :  2 million: total MAX_TOKEN_REFERRAL
    uint constant public TOTAL_BONUS_TOKEN = 2000000 * 10**18;

    uint public softCap;
    bool public softcapReached = false;


    uint constant public Partners = 1; // Distinction between promotion groups, partnership for eth
    uint constant public Referrals = 2; // Distinction between promotion groups, referral campaign for tokens
    

    uint constant public ONE = 1; // NUMBER 1

    // various reward levels
    uint constant public thirty = 30 * 10**18; // thirty tokens awarded to bidder when earned
    uint constant public twoHundred = 200 * 10**18; // two hundred tokens awarded to bidder when earned
    uint constant public sixHundred = 600 * 10**18; // six hundred tokens awarded to bidder when earned

    uint constant public oneHundred = 100 * 10**18; // one hundred tokens awarded to refferer when earned
    uint constant public fiveHundred = 500 * 10**18; // five hundred tokens awarded to refferer when earned
    uint constant public oneThousand = 1000 * 10**18; // one thousand tokens awarded to refferer when earned
    uint public residualToken; // variable tracking number of tokens left at near complete token exhaustion

    mapping (address => uint) public SuperDAOTokens; // amount of bonus Superdao Tokens earned per bidder
    //for participation on auction based on eth bid

    struct PartnerForEth {
        bytes4 hash; // unique hash for partner
        address addr; //address for partner
        uint totalReferrals; // Number of reffered parties
        uint totalContribution; // total contribution in ETH by reffered parties
        uint[] individualContribution; // individual contribution list, number of eth per contributor
        uint percentage; // percentage share for partner of each referral
        uint EthEarned; // up to date total amount earned
    }

	address [] public PartnersList; // list of partners

    //for token referal campaign
    struct tokenForReferral {
        bytes4 hash; // hash of this campaign
        address addr; // address of this user
        uint totalReferrals; // total amount of participators refered
        uint totalTokensEarned; // total tokens earned based on referals
        mapping(uint => uint) tokenAmountPerReferred;// Amount of tokens earned for each participator referred
    }

     address [] public TokenReferalList; // list of partners

     bytes4 [20] public topAddrHashes; // display top 20 refferers address hashes
     uint [20] public topReferredNum; // display number of bidders reffered by top 20 refferers

    event topAddrHashesUpdate(bytes4 [20] topAddrHashes); // log display top 20 refferers address hashes ( see function orderTop20 )
    event topNumbersUpdate(uint[20] topNumArray);  // log number of bidders reffered by top 20 refferers (( see function orderTop20 )
    bool public bidderBonus = true; // bolean bonus indicator for both refferers and bidders

    mapping(bytes4 => PartnerForEth )  public MarketingPartners;
    mapping(bytes4 => tokenForReferral)  public TokenReferrals;
    mapping(address => bool ) public Admins;

    // statistics on the number of bidders
    struct bidder {
        address addr;
        uint amount;
    }

    bidder [] public CurrentBidders; // document current bidders


    event PartnerReferral(bytes4 _partnerHash,address _addr, uint _amount);//fired after marketing partner referral happens
    event TokenReferral(bytes4 _campaignHash,address _addr, uint _amount);// fired when token referral happens
    event BidEvent(bytes4 _hash, address _addr, uint _amount); //fired when a bid happens
    event SetupReferal(uint _type); //fired when a referal campaign is setup
    event ReferalSignup(bytes4 _Hash, address _addr); // fired when a token promoter signs up
    event ClaimtokenBonus(bytes4 _Hash, address _addr, bool success); //fired when a person claims earned tokens



    // check when dutch auction is ended and trading has started
    modifier tradingstarted(){
        require(stage == Stages.TradingStarted);
        _;
    }

    // uint constant public MAX_TOKEN_REFERRAL = 1800000 * 10**18; // 1 800,000 : one million and eight hundred  thousand    
    // uint public claimedTokenReferral = 0; // 800,000 : eigth hundred thousand limit

    // safety check for requiring limits at maximum amount allocated for referrals
    modifier ReferalCampaignLimit() {
        require (claimedTokenReferral < MAX_TOKEN_REFERRAL);
        _;
    }


    constructor  (address _pWallet, uint _ceiling, uint _priceFactor, uint _softCap)
        DutchAuction(_pWallet, _ceiling, _priceFactor)  public {

            softCap = _softCap;
    }

    function checksoftCAP() internal {
        //require (softcapReached == false);
        if( totalReceived >= softCap ) {
            softcapReached = true;
        }
    }

    // creates either a marketing partnering for eth or a twitter retweet campaign. referal marketing in
    // exchange for tokens are self generated in referal signup function

    function setupReferal(address _addr, uint _percentage)
        public
        isOwner
        returns (string successmessage) 
    {

            bytes4 tempHash = bytes4(keccak256(abi.encodePacked(_addr, msg.sender)));

            MarketingPartners[tempHash].hash = tempHash;
            MarketingPartners[tempHash].addr = _addr;
            MarketingPartners[tempHash].percentage = _percentage;

            InternalReferalSignupByhash(tempHash, _addr);

    		emit SetupReferal(1); // Marketin partners
            return "partner signed up";
    }

    // generated hash on behalf of partners earning cash and tokensby tokens. referalcampaignlimmit modifier
    //removed because partner signup it will fail if referal tokens are used up
    function InternalReferalSignup(address _addr) internal returns (bytes4 referalhash) {
        
        bytes4 tempHash = bytes4(keccak256(abi.encodePacked(_addr)));
        TokenReferrals[tempHash].addr = msg.sender;
        TokenReferrals[tempHash].hash = tempHash;
        referalhash = tempHash;
        emit ReferalSignup(tempHash, _addr);
    }

    //
    function InternalReferalSignupByhash(bytes4 _hash, address _addr) internal returns (bytes4 referalhash) {
        TokenReferrals[_hash].addr = _addr;
        TokenReferrals[_hash].hash = _hash;
        referalhash = _hash;
        emit ReferalSignup(_hash, _addr);
    }


    // public self generated hash by token earning promoters
    function referralSignup() public ReferalCampaignLimit returns (bytes4 referalhash) {
        bytes4 tempHash = bytes4(keccak256(abi.encodePacked(msg.sender)));
        require (tempHash != TokenReferrals[tempHash].hash); //check prevent overwriting
        TokenReferrals[tempHash].addr = msg.sender;
        TokenReferrals[tempHash].hash = tempHash;
        referalhash = tempHash;
        emit ReferalSignup(tempHash, msg.sender);
    }


    // Biding using a referral hash
    function bidReferral(address _receiver, bytes4 _hash) public payable returns (uint) {

        uint bidAmount = msg.value;
        uint256 promissorytokenLastPrice = PromissoryTokenIns.lastPrice();


        if(bidAmount > ceiling - totalReceived) {
            bidAmount = ceiling - totalReceived;
        }

        require( bid(_receiver) == bidAmount );

		uint amount = msg.value;
		bidder memory _bidder;
		_bidder.addr = _receiver;
		_bidder.amount = amount;
        SuperDAOTokens[msg.sender] += amount/promissorytokenLastPrice;
		CurrentBidders.push(_bidder);
        checksoftCAP();

        emit BidEvent(_hash, msg.sender, amount);

        if (_hash == MarketingPartners[_hash].hash) {

            MarketingPartners[_hash].totalReferrals += ONE;
            MarketingPartners[_hash].totalContribution += amount;
            MarketingPartners[_hash].individualContribution.push(amount);
            MarketingPartners[_hash].EthEarned += referalPercentage(amount, MarketingPartners[_hash].percentage);

            totalEthEarnedByPartners += referalPercentage(amount, MarketingPartners[_hash].percentage);

            if( (msg.value >= 1 ether) && (msg.value <= 3 ether) && (bidderBonus == true)) {
             if(bonusChecker(oneHundred, thirty) == false){
                    discontinueBonus(oneHundred, thirty);
                    return;
                    }
              TokenReferrals[_hash].totalReferrals += ONE;
              orderTop20(TokenReferrals[_hash].totalReferrals, _hash);
              TokenReferrals[_hash].tokenAmountPerReferred[amount] = oneHundred;
              TokenReferrals[_hash].totalTokensEarned += oneHundred;
              bidderEarnings (thirty) == true ? claimedTokenReferral = oneHundred + thirty : claimedTokenReferral += oneHundred;
              emit TokenReferral(_hash ,msg.sender, amount);


              } else if ((msg.value > 3 ether)&&(msg.value <= 6 ether) && (bidderBonus == true)) {
                   if(bonusChecker(fiveHundred, twoHundred) == false){
                    discontinueBonus(fiveHundred, twoHundred);
                    return;
                    }
                  TokenReferrals[_hash].totalReferrals += ONE;
                  orderTop20(TokenReferrals[_hash].totalReferrals, _hash);
                  TokenReferrals[_hash].tokenAmountPerReferred[amount] = fiveHundred;
                  TokenReferrals[_hash].totalTokensEarned += fiveHundred;
                  bidderEarnings (twoHundred) == true ? claimedTokenReferral = fiveHundred + twoHundred : claimedTokenReferral += fiveHundred;
                  emit TokenReferral(_hash ,msg.sender, amount);


                  } else if ((msg.value > 6 ether) && (bidderBonus == true)) {
                    if(bonusChecker(oneThousand, sixHundred) == false){
                    discontinueBonus(oneThousand, sixHundred);
                    return;
                    }
                    TokenReferrals[_hash].totalReferrals += ONE;
                    orderTop20(TokenReferrals[_hash].totalReferrals, _hash);
                    TokenReferrals[_hash].tokenAmountPerReferred[amount] = oneThousand;
                    TokenReferrals[_hash].totalTokensEarned += oneThousand;
                    bidderEarnings (sixHundred) == true ? claimedTokenReferral = oneThousand + sixHundred : claimedTokenReferral += oneThousand;
                    emit TokenReferral(_hash, msg.sender, amount);

                  }

            emit PartnerReferral(_hash, MarketingPartners[_hash].addr, amount);

            return Partners;

          } else if (_hash == TokenReferrals[_hash].hash){

        			if( (msg.value >= 1 ether) && (msg.value <= 3 ether) && (bidderBonus == true) ) {
        			    if(bonusChecker(oneHundred, thirty) == false){
                            discontinueBonus(oneHundred, thirty);
                                return;
                            }
                            TokenReferrals[_hash].totalReferrals += ONE;
                            orderTop20(TokenReferrals[_hash].totalReferrals, _hash);
            				TokenReferrals[_hash].tokenAmountPerReferred[amount] = oneHundred;
            				TokenReferrals[_hash].totalTokensEarned += oneHundred;
                            bidderEarnings (thirty) == true ? claimedTokenReferral = oneHundred + thirty : claimedTokenReferral += oneHundred;
            				emit TokenReferral(_hash ,msg.sender, amount);
            				return Referrals;

        				} else if ((msg.value > 3 ether)&&(msg.value <= 6 ether) && (bidderBonus == true)) {
        				    if(bonusChecker(fiveHundred, twoHundred) == false){
                                discontinueBonus(fiveHundred, twoHundred);
                                return;
                                }
                                TokenReferrals[_hash].totalReferrals += ONE;
                                orderTop20(TokenReferrals[_hash].totalReferrals, _hash);
        						TokenReferrals[_hash].tokenAmountPerReferred[amount] = fiveHundred;
        						TokenReferrals[_hash].totalTokensEarned += fiveHundred;
                                bidderEarnings (twoHundred) == true ? claimedTokenReferral = fiveHundred + twoHundred : claimedTokenReferral += fiveHundred;
        						emit TokenReferral(_hash ,msg.sender, amount);
        						return Referrals;

        						} else if ((msg.value > 6 ether) && (bidderBonus == true)) {
        						    if(bonusChecker(oneThousand, sixHundred) == false){
                                     discontinueBonus(oneThousand, sixHundred);
                                     return;
                                    }
                                    TokenReferrals[_hash].totalReferrals += ONE;
                                    orderTop20(TokenReferrals[_hash].totalReferrals, _hash);
        							TokenReferrals[_hash].tokenAmountPerReferred[amount] = oneThousand;
        							TokenReferrals[_hash].totalTokensEarned += oneThousand;
        							bidderEarnings (sixHundred) == true ? claimedTokenReferral = oneThousand + sixHundred : claimedTokenReferral += oneThousand;
        							emit TokenReferral(_hash, msg.sender, amount);
        							return Referrals;
        						}
                        }
    
    }


	function referalPercentage(uint _amount, uint _percent)
	    internal
	    pure
	    returns (uint) {
            return SafeMath.mul( SafeMath.div( SafeMath.sub(_amount, _amount%100), 100 ), _percent );
	}


    function claimtokenBonus () public returns(bool success)  {

        bytes4 _personalHash = bytes4(keccak256(abi.encodePacked(msg.sender)));
        
        if ((_personalHash == TokenReferrals[_personalHash].hash) 
                && (TokenReferrals[_personalHash].totalTokensEarned > 0)) {

            uint TokensToTransfer1 = TokenReferrals[_personalHash].totalTokensEarned;
            TokenReferrals[_personalHash].totalTokensEarned = 0;
            KittieFightToken.transfer(TokenReferrals[_personalHash].addr , TokensToTransfer1);
            emit ClaimtokenBonus(_personalHash, msg.sender, true);
         
            return true;

        } else {

            return false;
       }
    }


    function claimCampaignTokenBonus(bytes4 _campaignHash) public returns(bool success)  {
        
        bytes4 _marketingCampaignHash = bytes4(keccak256(abi.encodePacked(msg.sender, owner)));

        if ((_marketingCampaignHash == TokenReferrals[_campaignHash].hash) 
                && (TokenReferrals[_campaignHash].totalTokensEarned > 0)) {

            uint TokensToTransfer1 = TokenReferrals[_campaignHash].totalTokensEarned;
            TokenReferrals[_campaignHash].totalTokensEarned = 0;
            KittieFightToken.transfer(TokenReferrals[_campaignHash].addr , TokensToTransfer1);
            emit ClaimtokenBonus(_campaignHash, msg.sender, true);
         
            return true;

        } else {

            return false;
       }
    }
    

    /*
     *  Admin transfers all unsold tokens back to token contract
     */
    function transferUnsoldTokens(uint _unsoldTokens, address _addr)
        public
        isOwner

     {

        uint soldTokens = totalReceived * 10**18 / finalPrice;
        uint totalSold = (MAX_TOKENS_SOLD + claimedTokenReferral)  - soldTokens;

        require (_unsoldTokens < totalSold );
        KittieFightToken.transfer(_addr, _unsoldTokens);
    }


    function tokenAmountPerReferred(bytes4 _hash, uint _amount ) public view returns(uint tokenAmount) {
        tokenAmount = TokenReferrals[_hash].tokenAmountPerReferred[_amount];
    }

    function getCurrentBiddersCount () public view returns(uint biddersCount)  {
        biddersCount = CurrentBidders.length;
    }

    // helper functions  return msg.senders hash
    function calculatPersonalHash() public view returns (bytes4 _hash) {
        _hash = bytes4(keccak256(abi.encodePacked(msg.sender)));
    }

    function calculatPersonalHashByAddress(address _addr) public view returns (bytes4 _hash) {
        _hash = bytes4(keccak256(abi.encodePacked(_addr)));
    }

    function calculateCampaignHash(address _addr) public view returns (bytes4 _hash) {
        _hash = bytes4(keccak256(abi.encodePacked(_addr, msg.sender)));
    }

    // helper functions ordering top 20 address by number of reffered bidders
    // array of addresses and bidder numbers are logged
    function orderTop20(uint _value, bytes4 _hash) private {
        uint i = 0;
        /** get the index of the current max element **/
        for(i; i < topReferredNum.length; i++) {
            if(topReferredNum[i] < _value) {
                break;
            }
        }

        if(i < topReferredNum.length)
        {
            if(topAddrHashes[i]!=_hash)
            {
                /** shift the array of one position (getting rid of the last element) **/
                for(uint j = topReferredNum.length - 1; j > i; j--) {
                    (topReferredNum[j], topAddrHashes[j] ) = (topReferredNum[j - 1],topAddrHashes[j - 1]);
                }

            
            }
            /** update the new max element **/
            (topReferredNum[i], topAddrHashes[i]) = (_value, _hash);
            emit topAddrHashesUpdate (topAddrHashes);
            emit topNumbersUpdate(topReferredNum);
        }



    }

    // helper functions returning top 20 leading number of reffered bidders by refferers
    function getTop20Reffered() public view returns (uint [20]){
      return topReferredNum;
    }

    // helper functions  top 20 refferer addresses
    function getTop20Addr() public view returns (bytes4 [20]){
        return topAddrHashes;
     }

    // helper functions  return msg.senders address from given hash
    function getAddress (bytes4 _hash) public view returns (address){
        return TokenReferrals[_hash].addr;
    }

    // helper checking existence of bidder as a token refferer
    // creates a token refferer hash for bidder, if bidder is not already a refferer
    // also allocates  20%, 25% or 40% (30, 200, 600 KTY tokens) discounts to bidder, based on amount bid
    function bidderEarnings (uint _amountEarned) private returns (bool){

        bytes4 bidderTemphash = calculatPersonalHash();

        if ( bidderTemphash == TokenReferrals[bidderTemphash].hash){
            TokenReferrals[bidderTemphash].totalTokensEarned += _amountEarned;
            return true;
        }else{
            bytes4 newBidderHash = InternalReferalSignup(msg.sender);
            TokenReferrals[newBidderHash].totalTokensEarned = _amountEarned;
            return true;
        }
        return false;
    }

     // check if both bidder bonus and refferer bonus is avalable
     // return true if bonus is available
     function bonusChecker(uint _tokenRefferralBonus, uint _bidderBonusAmount) public view returns (bool){
      return _tokenRefferralBonus + _bidderBonusAmount + claimedTokenReferral <= MAX_TOKEN_REFERRAL ? true : false;
    }

    //document actual remaining residual tokens
    //call function to terminate bonus
    function discontinueBonus(uint _tokenRefferralBonus, uint _bidderBonusAmount) private returns (string) {
        residualToken = MAX_TOKEN_REFERRAL - (_tokenRefferralBonus + _bidderBonusAmount + claimedTokenReferral);
        return setBonustoFalse();
    }


    // bolean bonus switcher, only called when
    // tokens bonus availability is exhuated
    // terminate bonus
    function setBonustoFalse() private returns (string) {
        require (bidderBonus == true,"no more bonuses");
        bidderBonus = false;
        return "tokens exhausted";
    }

}