pragma solidity ^0.4.18;

/* taking ideas from Zeppelin solidity module */
contract SafeMath {

    // it is recommended to define functions which can neither read the state of blockchain nor write in it as pure instead of constant

    function safeAdd(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x + y;
        assert((z >= x));
        return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal pure returns(uint256) {
        assert(x >= y);
        return x - y;
    }

    function safeMult(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x * y;
        assert((x == 0)||(z/x == y));
        return z;
    }

    function safeDiv(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x / y;
        return z;
    }

    // mitigate short address attack
    // thanks to https://github.com/numerai/contract/blob/c182465f82e50ced8dacb3977ec374a892f5fa8c/contracts/Safe.sol#L30-L34.
    // TODO: doublecheck implication of >= compared to ==
    modifier onlyPayloadSize(uint numWords) {
        assert(msg.data.length >= numWords * 32 + 4);
        _;
    }

}
// The abstract token contract

contract TrakToken {
    function TrakToken () public {}
    function transfer (address ,uint) public pure { }
    function burn (uint256) public pure { }
    function finalize() public pure { }
    function changeTokensWallet (address) public pure { }
}

contract CrowdSale is SafeMath {

    ///metadata
    enum State { Fundraising,Paused,Successful,Closed }
    State public state = State.Fundraising; // equal to 0
    string public version = "1.0";

    //External contracts
    TrakToken public trakToken;
    // who created smart contract
    address public creator;
    // Address which will receive raised funds
    address public contractOwner;
    // adreess vs state mapping (1 for exists , zero default);
    mapping (address => bool) public whitelistedContributors;

    uint256 public fundingStartBlock; // Dec 15 - Dec 25
    uint256 public firstChangeBlock;  // December 25 - January 5
    uint256 public secondChangeBlock; // January 5 -January 15
    uint256 public thirdChangeBlock;  // January 16
    uint256 public fundingEndBlock;   // Jan 31
    // funding maximum duration in hours
    uint256 public fundingDurationInHours;
    uint256 constant public fundingMaximumTargetInWei = 66685 ether;
    // We need to keep track of how much ether (in units of Wei) has been contributed
    uint256 public totalRaisedInWei;
    // maximum ether we will accept from one user
    uint256 constant public maxPriceInWeiFromUser = 1500 ether;
    uint256 public minPriceInWeiForPre = 1 ether;
    uint256 public minPriceInWeiForIco = 0.5 ether;
    uint8 constant public  decimals = 18;
    // Number of tokens distributed to investors
    uint public tokensDistributed = 0;
    // tokens per tranche
    uint constant public tokensPerTranche = 11000000 * (uint256(10) ** decimals);
    uint256 public privateExchangeRate = 1420; // 23.8%
    uint256 public firstExchangeRate   = 1289; // 15.25%
    uint256 public secondExchangeRate  = 1193;  //  8.42%
    uint256 public thirdExchangeRate   = 1142;  //  4.31%
    uint256 public fourthExchangeRate  = 1118;  //  2.25%
    uint256 public fifthExchangeRate   = 1105;  // 1.09%

    /// modifiers
    modifier onlyOwner() {
        require(msg.sender == contractOwner);
        _;
    }

    modifier isIcoOpen() {
        require(block.number >= fundingStartBlock);
        require(block.number <= fundingEndBlock);
        require(totalRaisedInWei <= fundingMaximumTargetInWei);
        _;
    }


    modifier isMinimumPrice() {
        if (tokensDistributed < safeMult(3,tokensPerTranche) || block.number < thirdChangeBlock ) {
           require(msg.value >= minPriceInWeiForPre);
        }
        else if (tokensDistributed <= safeMult(6,tokensPerTranche)) {
           require(msg.value >= minPriceInWeiForIco);
        }

        require(msg.value <= maxPriceInWeiFromUser);

         _;
    }

    modifier isIcoFinished() {
        require(totalRaisedInWei >= fundingMaximumTargetInWei || (block.number > fundingEndBlock) || state == State.Successful );
        _;
    }

    modifier inState(State _state) {
        require(state == _state);
        _;
    }

    modifier isCreator() {
        require(msg.sender == creator);
        _;
    }

    // wait 100 block after final contract state before allowing contract destruction
    modifier atEndOfLifecycle() {
        require(totalRaisedInWei >= fundingMaximumTargetInWei || (block.number > fundingEndBlock + 40000));
        _;
    }

    /// constructor
    function CrowdSale(
    address _fundsWallet,
    uint256 _fundingStartBlock,
    uint256 _firstInHours,
    uint256 _secondInHours,
    uint256 _thirdInHours,
    uint256 _fundingDurationInHours,
    TrakToken _tokenAddress
    ) public {

        require(safeAdd(_fundingStartBlock, safeMult(_fundingDurationInHours , 212)) > _fundingStartBlock);

        creator = msg.sender;

        if (_fundsWallet !=0) {
            contractOwner = _fundsWallet;
        }
        else {
            contractOwner = msg.sender;
        }

        fundingStartBlock = _fundingStartBlock;
        firstChangeBlock =  safeAdd(fundingStartBlock, safeMult(_firstInHours , 212));
        secondChangeBlock = safeAdd(fundingStartBlock, safeMult(_secondInHours , 212));
        thirdChangeBlock =  safeAdd(fundingStartBlock, safeMult(_thirdInHours , 212));
        fundingDurationInHours = _fundingDurationInHours;
        fundingEndBlock = safeAdd(fundingStartBlock, safeMult(_fundingDurationInHours , 212));
        trakToken = TrakToken(_tokenAddress);
    }


    // fallback function can be used to buy tokens
    function () external payable {
        buyTokens(msg.sender);
    }


    function buyTokens(address beneficiary) inState(State.Fundraising) isIcoOpen isMinimumPrice  public  payable  {
        require(beneficiary != 0x0);
        // state 1 is set for
        require(whitelistedContributors[beneficiary] == true );
        uint256 tokenAmount;
        uint256 checkedReceivedWei = safeAdd(totalRaisedInWei, msg.value);
        // Check that this transaction wouldn't exceed the ETH max cap

        if (checkedReceivedWei > fundingMaximumTargetInWei ) {

            // update totalRaised After Subtracting
            totalRaisedInWei = safeAdd(totalRaisedInWei,safeSubtract(fundingMaximumTargetInWei,totalRaisedInWei));
            // Calculate how many tokens (in units of Wei) should be awarded on this transaction
            var (rate,/*trancheMaxTokensLeft */) = getCurrentTokenPrice();
            // Calculate how many tokens (in units of Wei) should be awarded on this transaction
            tokenAmount = safeMult(safeSubtract(fundingMaximumTargetInWei,totalRaisedInWei), rate);
            // Send change extra ether to user.
            beneficiary.transfer(safeSubtract(checkedReceivedWei,fundingMaximumTargetInWei));
        }
        else {
            totalRaisedInWei = safeAdd(totalRaisedInWei,msg.value);
            var (currentRate,trancheMaxTokensLeft) = getCurrentTokenPrice();
            // Calculate how many tokens (in units of Wei) should be awarded on this transaction
            tokenAmount = safeMult(msg.value, currentRate);
            if (tokenAmount > trancheMaxTokensLeft) {
                // handle round off error by adding .1 token
                tokensDistributed =  safeAdd(tokensDistributed,safeAdd(trancheMaxTokensLeft,safeDiv(1,10)));
                //find remaining tokens by getCurrentTokenPrice() function and sell them from remaining ethers left
                var (nextCurrentRate,nextTrancheMaxTokensLeft) = getCurrentTokenPrice();

                if (nextTrancheMaxTokensLeft <= 0) {
                    tokenAmount = safeAdd(trancheMaxTokensLeft,safeDiv(1,10));
                    state =  State.Successful;
                    // Send change extra ether to user.
                    beneficiary.transfer(safeDiv(safeSubtract(tokenAmount,trancheMaxTokensLeft),currentRate));
                } else {
                    uint256 nextTokenAmount = safeMult(safeSubtract(msg.value,safeMult(trancheMaxTokensLeft,safeDiv(1,currentRate))),nextCurrentRate);
                    tokensDistributed =  safeAdd(tokensDistributed,nextTokenAmount);
                    tokenAmount = safeAdd(nextTokenAmount,safeAdd(trancheMaxTokensLeft,safeDiv(1,10)));
                }
            }
            else {
                tokensDistributed =  safeAdd(tokensDistributed,tokenAmount);
            }
        }

        trakToken.transfer(beneficiary,tokenAmount);
        // immediately transfer ether to fundsWallet
        forwardFunds();
    }

    function forwardFunds() internal {
        contractOwner.transfer(msg.value);
    }

    /// @dev Returns the current token rate , minimum ether needed and maximum tokens left in currenttranche
    function getCurrentTokenPrice() private constant returns (uint256 currentRate, uint256 maximumTokensLeft) {

        if (tokensDistributed < safeMult(1,tokensPerTranche) && (block.number < firstChangeBlock)) {
            //  return ( privateExchangeRate, minPriceInWeiForPre, safeSubtract(tokensPerTranche,tokensDistributed) );
            return ( privateExchangeRate, safeSubtract(tokensPerTranche,tokensDistributed) );
        }
        else if (tokensDistributed < safeMult(2,tokensPerTranche) && (block.number < secondChangeBlock)) {
            return ( firstExchangeRate, safeSubtract(safeMult(2,tokensPerTranche),tokensDistributed) );
        }
        else if (tokensDistributed < safeMult(3,tokensPerTranche) && (block.number < thirdChangeBlock)) {
            return ( secondExchangeRate, safeSubtract(safeMult(3,tokensPerTranche),tokensDistributed) );
        }
        else if (tokensDistributed < safeMult(4,tokensPerTranche) && (block.number < fundingEndBlock)) {
            return  (thirdExchangeRate,safeSubtract(safeMult(4,tokensPerTranche),tokensDistributed)  );
        }
        else if (tokensDistributed < safeMult(5,tokensPerTranche) && (block.number < fundingEndBlock)) {
            return  (fourthExchangeRate,safeSubtract(safeMult(5,tokensPerTranche),tokensDistributed)  );
        }
        else if (tokensDistributed <= safeMult(6,tokensPerTranche)) {
            return  (fifthExchangeRate,safeSubtract(safeMult(6,tokensPerTranche),tokensDistributed)  );
        }
    }


    function authorizeKyc(address[] addrs) external onlyOwner returns (bool success) {

        //@TODO  maximum batch size for uploading
        // @TODO amount of gas for a block of code - and will fail if that is exceeded
        uint arrayLength = addrs.length;

        for (uint x = 0; x < arrayLength; x++) {
            whitelistedContributors[addrs[x]] = true;
        }

        return true;
    }


    function withdrawWei () external onlyOwner {
        // send the eth to the project multisig wallet
        contractOwner.transfer(this.balance);
    }

    function updateFundingEndBlock(uint256 newFundingEndBlock)  external onlyOwner {
        require(newFundingEndBlock > fundingStartBlock);
        //require(newFundingEndBlock >= fundingEndBlock);
        fundingEndBlock = newFundingEndBlock;
    }


    // after ICO only owner can call this
    function burnRemainingToken(uint256 _value) external  onlyOwner isIcoFinished {
        //@TODO - check balance of address if no value passed
        require(_value > 0);
        trakToken.burn(_value);
    }

    // after ICO only owner can call this
    function withdrawRemainingToken(uint256 _value,address trakTokenAdmin)  external onlyOwner isIcoFinished {
        //@TODO - check balance of address if no value passed
        require(trakTokenAdmin != 0x0);
        require(_value > 0);
        trakToken.transfer(trakTokenAdmin,_value);
    }


    // after ICO only owner can call this
    function finalize() external  onlyOwner isIcoFinished  {
        state =  State.Closed;
        trakToken.finalize();
    }

    // after ICO only owner can call this
    function changeTokensWallet(address newAddress) external  onlyOwner  {
        require(newAddress != address(0));
        trakToken.changeTokensWallet(newAddress);
    }


    function removeContract ()  external onlyOwner atEndOfLifecycle {
        // msg.sender will receive all the ethers if this contract has ethers
        selfdestruct(msg.sender);
    }

    /// @param newAddress Address of new owner.
    function changeFundsWallet(address newAddress) external onlyOwner returns (bool)
    {
        require(newAddress != address(0));
        contractOwner = newAddress;
    }


    /// @dev Pauses the contract
    function pause() external onlyOwner inState(State.Fundraising) {
        // Move the contract to Paused state
        state =  State.Paused;
    }


    /// @dev Resume the contract
    function resume() external onlyOwner {
        // Move the contract out of the Paused state
        state =  State.Fundraising;
    }

    function updateFirstChangeBlock(uint256 newFirstChangeBlock)  external onlyOwner {
        firstChangeBlock = newFirstChangeBlock;
    }

    function updateSecondChangeBlock(uint256 newSecondChangeBlock)  external onlyOwner {
        secondChangeBlock = newSecondChangeBlock;
    }  

    function updateThirdChangeBlock(uint256 newThirdChangeBlock)  external onlyOwner {
        thirdChangeBlock = newThirdChangeBlock;
    }      

    function updatePrivateExhangeRate(uint256 newPrivateExchangeRate)  external onlyOwner {
        privateExchangeRate = newPrivateExchangeRate;
    } 

    function updateFirstExhangeRate(uint256 newFirstExchangeRate)  external onlyOwner {
        firstExchangeRate = newFirstExchangeRate;
    }    

    function updateSecondExhangeRate(uint256 newSecondExchangeRate)  external onlyOwner {
        secondExchangeRate = newSecondExchangeRate;
    }

    function updateThirdExhangeRate(uint256 newThirdExchangeRate)  external onlyOwner {
        thirdExchangeRate = newThirdExchangeRate;
    }      

    function updateFourthExhangeRate(uint256 newFourthExchangeRate)  external onlyOwner {
        fourthExchangeRate = newFourthExchangeRate;
    }    

    function updateFifthExhangeRate(uint256 newFifthExchangeRate)  external onlyOwner {
        fifthExchangeRate = newFifthExchangeRate;
    }    
    
    function updateMinInvestmentForPreIco(uint256 newMinPriceInWeiForPre)  external onlyOwner {
        minPriceInWeiForPre = newMinPriceInWeiForPre;
    }
    function updateMinInvestmentForIco(uint256 newMinPriceInWeiForIco)  external onlyOwner {
        minPriceInWeiForIco = newMinPriceInWeiForIco;
    }

}