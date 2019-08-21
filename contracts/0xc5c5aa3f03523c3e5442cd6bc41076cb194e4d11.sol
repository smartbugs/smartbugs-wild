pragma solidity ^0.4.19;

/*
    Our Roulette - A decentralized, crowdfunded game of Roulette
    
    Developer:
        Dadas1337
        
    Thanks to:
    
        FrontEnd help & tips:
            CiernaOvca
            Matt007
            Kebabist
            
        Chief-Shiller:
            M.Tejas
            
        Auditor:
            Inventor
            
    If the website ever goes down for any reason, just send a 0 ETH transaction
    with no data and at least 150 000 GAS to the contract address.
    Your shares will be sold and dividends withdrawn.
*/

contract OurRoulette{
    struct Bet{
        uint value;
        uint height; //result of a bet placed at height is determined by blocks at height+1 and height+2, bet can be resolved from height+3 upwards..
        uint tier; //min bet amount
        bytes betdata;
    }
    mapping (address => Bet) bets;
    
    // These functions will be removed in the real thing, they are only here for testing purposes
    address owner = msg.sender;
    function Kill() public { if(owner==msg.sender)selfdestruct(owner); }
    
    function AddDiv() public payable {
        require(msg.sender==owner);
        contractBalance+=msg.value;
        AddToDividends(msg.value);
    }
    
    function SubDiv(uint256 value) public {
        require(msg.sender==owner);
        contractBalance-=value;
        SubFromDividends(value);
        msg.sender.transfer(value);
    }
    
    // ---- end of testing functions
    
    //helper function used when calculating win amounts
    function GroupMultiplier(uint number,uint groupID) public pure returns(uint){
        uint80[12] memory groups=[ //matrix of bet multipliers for each group - 2bits per number
            0x30c30c30c30c30c30c0, //0: 3rd column
            0x0c30c30c30c30c30c30, //1: 2nd column
            0x030c30c30c30c30c30c, //2: 1st column
            0x0000000000003fffffc, //3: 1st 12
            0x0000003fffffc000000, //4: 2nd 12
            0x3fffffc000000000000, //5: 3rd 12
            0x0000000002aaaaaaaa8, //6: 1 to 18
            0x2222222222222222220, //7: even
            0x222208888a222088888, //8: red
            0x0888a22220888a22220, //9: black
            0x0888888888888888888, //10: odd
            0x2aaaaaaaa8000000000  //11: 19 to 36
        ];
        return (groups[groupID]>>(number*2))&3; //this function is only public so you can verify that group multipliers are working correctly
    }
    
    //returns a "random" number based on blockhashes and addresses
    function GetNumber(address adr,uint height) public view returns(uint){
        bytes32 hash1=block.blockhash(height+1);
        bytes32 hash2=block.blockhash(height+2);
        if(hash1==0 || hash2==0)return 69;//if the hash equals zero, it means that its too late now (blockhash can only get most recent 256 blocks)
        return ((uint)(keccak256(adr,hash1,hash2)))%37;
    }
    
    //returns user's payout from his last bet
    function BetPayout() public view returns (uint payout) {
        Bet memory tmp = bets[msg.sender];
        
        uint n=GetNumber(msg.sender,tmp.height);
        if(n==69)return 0; //unable to get blockhash - too late
        
        payout=((uint)(tmp.betdata[n]))*36; //if there is a bet on the winning number, set payout to the bet*36
        for(uint i=37;i<49;i++)payout+=((uint)(tmp.betdata[i]))*GroupMultiplier(n,i-37); //check all groups
        
        return payout*tmp.tier;
    }
    
    //claims last bet (if it exists), creates a new one and sends back any leftover balance
    function PlaceBet(uint tier,bytes betdata) public payable {
        Bet memory tmp = bets[msg.sender];
        uint balance=msg.value; //user's balance
        require(tier<(realReserve()/12500)); //tier has to be 12500 times lower than current balance
        
        require((tmp.height+2)<=(block.number-1)); //if there is a bet that can't be claimed yet, revert (this bet must be resolved before placing another one)
        if(tmp.height!=0&&((block.number-1)>=(tmp.height+2))){ //if there is an unclaimed bet that can be resolved...
            uint win=BetPayout();
            
            if(win>0&&tmp.tier>(realReserve()/12500)){
                // tier has to be 12500 times lower than current balance
                // if it isnt, refund the bet and cancel the new bet
                
                //   - this shouldnt ever happen, only in a very specific scenario where
                //     most of the people pull out at the same time.
                
                if(contractBalance>=tmp.value){
                    bets[msg.sender].height=0; //set bet height to 0 so it can't be claimed again
                    contractBalance-=tmp.value;
                    SubFromDividends(tmp.value);
                    msg.sender.transfer(tmp.value+balance); //refund both last bet and current bet
                }else msg.sender.transfer(balance); //if there isnt enough money to refund last bet, then refund at least the new bet
                                                    //again, this should never happen, its an extreme edge-case
                                                    //old bet can be claimed later, after the balance increases again

                return; //cancel the new bet
            }
            
            balance+=win; //if all is right, add last bet's payout to user's balance
        }
        
        uint betsz=0;
        for(uint i=0;i<49;i++)betsz+=(uint)(betdata[i]);
        require(betsz<=50); //bet size can't be greater than 50 "chips"
        
        betsz*=tier; //convert chips to wei
        require(betsz<=balance); //betsz must be smaller or equal to user's current balance
        
        tmp.height=block.number; //fill the new bet's structure
        tmp.value=betsz;
        tmp.tier=tier;
        tmp.betdata=betdata;
        
        bets[msg.sender]=tmp; //save it to storage
        
        balance-=betsz; //balance now contains (msg.value)+(winnings from last bet) - (current bet size)
        
        if(balance>0){
            contractBalance-=balance;
            if(balance>=msg.value){
                contractBalance-=(balance-msg.value);
                SubFromDividends(balance-msg.value);
            }else{
                contractBalance+=(msg.value-balance);
                AddToDividends(msg.value-balance);
            }

            msg.sender.transfer(balance); //send any leftover balance back to the user
        }else{
            contractBalance+=msg.value;
            AddToDividends(msg.value);
        }
    }
    
    //adds "value" to dividends
    function AddToDividends(uint256 value) internal {
        earningsPerToken+=(int256)((value*scaleFactor)/totalSupply);
    }
    
    //subtract "value" from dividends
    function SubFromDividends(uint256 value)internal {
        earningsPerToken-=(int256)((value*scaleFactor)/totalSupply);
    }
    
    //claims last bet
    function ClaimMyBet() public{
        Bet memory tmp = bets[msg.sender];
        require((tmp.height+2)<=(block.number-1)); //if it is a bet that can't be claimed yet
        
        uint win=BetPayout();
        
        if(win>0){
            if(bets[msg.sender].tier>(realReserve()/12500)){
                // tier has to be 12500 times lower than current balance
                // if it isnt, refund the bet
                
                //   - this shouldnt ever happen, only in a very specific scenario where
                //     most of the people pull out at the same time.
                
                if(contractBalance>=tmp.value){
                    bets[msg.sender].height=0; //set bet height to 0 so it can't be claimed again
                    contractBalance-=tmp.value;
                    SubFromDividends(tmp.value);
                    msg.sender.transfer(tmp.value);
                }
                
                //if the code gets here, it means that there isnt enough balance to refund the bet
                //bet can be claimed later, after the balance increases again
                return;
            }
            
            bets[msg.sender].height=0; //set bet height to 0 so it can't be claimed again
            contractBalance-=win;
            SubFromDividends(win);
            msg.sender.transfer(win);
        }
    }
    
    //public function used to fill user interface with data
    function GetMyBet() public view returns(uint, uint, uint, uint, bytes){
        return (bets[msg.sender].value,bets[msg.sender].height,bets[msg.sender].tier,BetPayout(),bets[msg.sender].betdata);
    }
    
//          --- EthPyramid code with fixed compiler warnings and support for negative dividends ---

/*
          ,/`.
        ,'/ __`.
      ,'_/_  _ _`.
    ,'__/_ ___ _  `.
  ,'_  /___ __ _ __ `.
 '-.._/___...-"-.-..__`.
  B

 EthPyramid. A no-bullshit, transparent, self-sustaining pyramid scheme.
 
 Inspired by https://test.jochen-hoenicke.de/eth/ponzitoken/

 Developers:
	Arc
	Divine
	Norsefire
	ToCsIcK
	
 Front-End:
	Cardioth
	tenmei
	Trendium
	
 Moral Support:
	DeadCow.Rat
	Dots
	FatKreamy
	Kaseylol
	QuantumDeath666
	Quentin
 
 Shit-Tier:
	HentaiChrist
 
*/
    
    // scaleFactor is used to convert Ether into tokens and vice-versa: they're of different
	// orders of magnitude, hence the need to bridge between the two.
	uint256 constant scaleFactor = 0x10000000000000000;  // 2^64

	// CRR = 50%
	// CRR is Cash Reserve Ratio (in this case Crypto Reserve Ratio).
	// For more on this: check out https://en.wikipedia.org/wiki/Reserve_requirement
	int constant crr_n = 1; // CRR numerator
	int constant crr_d = 2; // CRR denominator

	// The price coefficient. Chosen such that at 1 token total supply
	// the amount in reserve is 0.5 ether and token price is 1 Ether.
	int constant price_coeff = -0x296ABF784A358468C;

	// Array between each address and their number of tokens.
	mapping(address => uint256) public tokenBalance;
		
	// Array between each address and how much Ether has been paid out to it.
	// Note that this is scaled by the scaleFactor variable.
	mapping(address => int256) public payouts;

	// Variable tracking how many tokens are in existence overall.
	uint256 public totalSupply;

	// Aggregate sum of all payouts.
	// Note that this is scaled by the scaleFactor variable.
	int256 totalPayouts;

	// Variable tracking how much Ether each token is currently worth.
	// Note that this is scaled by the scaleFactor variable.
	int256 earningsPerToken;
	
	// Current contract balance in Ether
	uint256 public contractBalance;

	// The following functions are used by the front-end for display purposes.

	// Returns the number of tokens currently held by _owner.
	function balanceOf(address _owner) public constant returns (uint256 balance) {
		return tokenBalance[_owner];
	}

	// Withdraws all dividends held by the caller sending the transaction, updates
	// the requisite global variables, and transfers Ether back to the caller.
	function withdraw() public {
		// Retrieve the dividends associated with the address the request came from.
		uint256 balance = dividends(msg.sender);
		
		// Update the payouts array, incrementing the request address by `balance`.
		payouts[msg.sender] += (int256) (balance * scaleFactor);
		
		// Increase the total amount that's been paid out to maintain invariance.
		totalPayouts += (int256) (balance * scaleFactor);
		
		// Send the dividends to the address that requested the withdraw.
		contractBalance = sub(contractBalance, balance);
		msg.sender.transfer(balance);
	}

	// Converts the Ether accrued as dividends back into EPY tokens without having to
	// withdraw it first. Saves on gas and potential price spike loss.
	function reinvestDividends() public {
		// Retrieve the dividends associated with the address the request came from.
		uint256 balance = dividends(msg.sender);
		
		// Update the payouts array, incrementing the request address by `balance`.
		// Since this is essentially a shortcut to withdrawing and reinvesting, this step still holds.
		payouts[msg.sender] += (int256) (balance * scaleFactor);
		
		// Increase the total amount that's been paid out to maintain invariance.
		totalPayouts += (int256) (balance * scaleFactor);
		
		// Assign balance to a new variable.
		uint value_ = (uint) (balance);
		
		// If your dividends are worth less than 1 szabo, or more than a million Ether
		// (in which case, why are you even here), abort.
		if (value_ < 0.000001 ether || value_ > 1000000 ether)
			revert();
			
		// msg.sender is the address of the caller.
		address sender = msg.sender;
		
		// A temporary reserve variable used for calculating the reward the holder gets for buying tokens.
		// (Yes, the buyer receives a part of the distribution as well!)
		uint256 res = reserve() - balance;

		// 10% of the total Ether sent is used to pay existing holders.
		uint256 fee = div(value_, 10);
		
		// The amount of Ether used to purchase new tokens for the caller.
		uint256 numEther = value_ - fee;
		
		// The number of tokens which can be purchased for numEther.
		uint256 numTokens = calculateDividendTokens(numEther, balance);
		
		// The buyer fee, scaled by the scaleFactor variable.
		uint256 buyerFee = fee * scaleFactor;
		
		// Check that we have tokens in existence (this should always be true), or
		// else you're gonna have a bad time.
		if (totalSupply > 0) {
			// Compute the bonus co-efficient for all existing holders and the buyer.
			// The buyer receives part of the distribution for each token bought in the
			// same way they would have if they bought each token individually.
			uint256 bonusCoEff =
			    (scaleFactor - (res + numEther) * numTokens * scaleFactor / (totalSupply + numTokens) / numEther)
			    * (uint)(crr_d) / (uint)(crr_d-crr_n);
				
			// The total reward to be distributed amongst the masses is the fee (in Ether)
			// multiplied by the bonus co-efficient.
			uint256 holderReward = fee * bonusCoEff;
			
			buyerFee -= holderReward;

			// Fee is distributed to all existing token holders before the new tokens are purchased.
			// rewardPerShare is the amount gained per token thanks to this buy-in.
			uint256 rewardPerShare = holderReward / totalSupply;
			
			// The Ether value per token is increased proportionally.
			earningsPerToken += (int256)(rewardPerShare);
		}
		
		// Add the numTokens which were just created to the total supply. We're a crypto central bank!
		totalSupply = add(totalSupply, numTokens);
		
		// Assign the tokens to the balance of the buyer.
		tokenBalance[sender] = add(tokenBalance[sender], numTokens);
		
		// Update the payout array so that the buyer cannot claim dividends on previous purchases.
		// Also include the fee paid for entering the scheme.
		// First we compute how much was just paid out to the buyer...
		int256 payoutDiff  = ((earningsPerToken * (int256)(numTokens)) - (int256)(buyerFee));
		
		// Then we update the payouts array for the buyer with this amount...
		payouts[sender] += payoutDiff;
		
		// And then we finally add it to the variable tracking the total amount spent to maintain invariance.
		totalPayouts    += payoutDiff;
		
	}

	// Sells your tokens for Ether. This Ether is assigned to the callers entry
	// in the tokenBalance array, and therefore is shown as a dividend. A second
	// call to withdraw() must be made to invoke the transfer of Ether back to your address.
	function sellMyTokens() public {
		uint256 balance = balanceOf(msg.sender);
		sell(balance);
	}

	// The slam-the-button escape hatch. Sells the callers tokens for Ether, then immediately
	// invokes the withdraw() function, sending the resulting Ether to the callers address.
    function getMeOutOfHere() public {
		sellMyTokens();
        withdraw();
	}

	// Gatekeeper function to check if the amount of Ether being sent isn't either
	// too small or too large. If it passes, goes direct to buy().
	function fund() payable public {
		// Don't allow for funding if the amount of Ether sent is less than 1 szabo.
		if (msg.value > 0.000001 ether) {
		    contractBalance = add(contractBalance, msg.value);
			buy();
		} else {
			revert();
		}
    }

	// Function that returns the (dynamic) price of buying a finney worth of tokens.
	function buyPrice() public constant returns (uint) {
		return getTokensForEther(1 finney);
	}

	// Function that returns the (dynamic) price of selling a single token.
	function sellPrice() public constant returns (uint) {
        uint256 eth;
        uint256 penalty;
        (eth,penalty) = getEtherForTokens(1 finney);
        
        uint256 fee = div(eth, 10);
        return eth - fee;
    }

	// Calculate the current dividends associated with the caller address. This is the net result
	// of multiplying the number of tokens held by their current value in Ether and subtracting the
	// Ether that has already been paid out. Returns 0 in case of negative dividends
	function dividends(address _owner) public constant returns (uint256 amount) {
	    int256 r=((earningsPerToken * (int256)(tokenBalance[_owner])) - payouts[_owner]) / (int256)(scaleFactor);
	    if(r<0)return 0;
		return (uint256)(r);
	}
	
	// Returns real dividends, including negative values
	function realDividends(address _owner) public constant returns (int256 amount) {
	    return (((earningsPerToken * (int256)(tokenBalance[_owner])) - payouts[_owner]) / (int256)(scaleFactor));
	}

	// Internal balance function, used to calculate the dynamic reserve value.
	function balance() internal constant returns (uint256 amount) {
		// msg.value is the amount of Ether sent by the transaction.
		return contractBalance - msg.value;
	}

	function buy() internal {
		// Any transaction of less than 1 szabo is likely to be worth less than the gas used to send it.
		if (msg.value < 0.000001 ether || msg.value > 1000000 ether)
			revert();
						
		// msg.sender is the address of the caller.
		address sender = msg.sender;
		
		// 10% of the total Ether sent is used to pay existing holders.
		uint256 fee = div(msg.value, 10);
		
		// The amount of Ether used to purchase new tokens for the caller.
		uint256 numEther = msg.value - fee;
		
		// The number of tokens which can be purchased for numEther.
		uint256 numTokens = getTokensForEther(numEther);
		
		// The buyer fee, scaled by the scaleFactor variable.
		uint256 buyerFee = fee * scaleFactor;
		
		// Check that we have tokens in existence (this should always be true), or
		// else you're gonna have a bad time.
		if (totalSupply > 0) {
			// Compute the bonus co-efficient for all existing holders and the buyer.
			// The buyer receives part of the distribution for each token bought in the
			// same way they would have if they bought each token individually.
			uint256 bonusCoEff =
			    (scaleFactor - (reserve() + numEther) * numTokens * scaleFactor / (totalSupply + numTokens) / numEther)
			    * (uint)(crr_d) / (uint)(crr_d-crr_n);
				
			// The total reward to be distributed amongst the masses is the fee (in Ether)
			// multiplied by the bonus co-efficient.
			uint256 holderReward = fee * bonusCoEff;
			
			buyerFee -= holderReward;

			// Fee is distributed to all existing token holders before the new tokens are purchased.
			// rewardPerShare is the amount gained per token thanks to this buy-in.
			uint256 rewardPerShare = holderReward / totalSupply;
			
			// The Ether value per token is increased proportionally.
			earningsPerToken += (int256)(rewardPerShare);
			
		}

		// Add the numTokens which were just created to the total supply. We're a crypto central bank!
		totalSupply = add(totalSupply, numTokens);

		// Assign the tokens to the balance of the buyer.
		tokenBalance[sender] = add(tokenBalance[sender], numTokens);

		// Update the payout array so that the buyer cannot claim dividends on previous purchases.
		// Also include the fee paid for entering the scheme.
		// First we compute how much was just paid out to the buyer...
		int256 payoutDiff = ((earningsPerToken * (int256)(numTokens)) - (int256)(buyerFee));
		
		// Then we update the payouts array for the buyer with this amount...
		payouts[sender] += payoutDiff;
		
		// And then we finally add it to the variable tracking the total amount spent to maintain invariance.
		totalPayouts    += payoutDiff;
		
	}

	// Sell function that takes tokens and converts them into Ether. Also comes with a 10% fee
	// to discouraging dumping, and means that if someone near the top sells, the fee distributed
	// will be *significant*.
	function sell(uint256 amount) internal {
	    // Calculate the amount of Ether that the holders tokens sell for at the current sell price.
		uint256 numEthersBeforeFee;
		uint256 penalty;
		(numEthersBeforeFee,penalty) = getEtherForTokens(amount);
		
		// 10% of the resulting Ether is used to pay remaining holders, but only if there are any remaining holders.
		uint256 fee = 0;
		if(amount!=totalSupply) fee = div(numEthersBeforeFee, 10);
		
		// Net Ether for the seller after the fee has been subtracted.
        uint256 numEthers = numEthersBeforeFee - fee;
		
		// *Remove* the numTokens which were just sold from the total supply. We're /definitely/ a crypto central bank.
		totalSupply = sub(totalSupply, amount);
		
        // Remove the tokens from the balance of the buyer.
		tokenBalance[msg.sender] = sub(tokenBalance[msg.sender], amount);

        // Update the payout array so that the seller cannot claim future dividends unless they buy back in.
		// First we compute how much was just paid out to the seller...
		int256 payoutDiff = (earningsPerToken * (int256)(amount) + (int256)(numEthers * scaleFactor));
		
        // We reduce the amount paid out to the seller (this effectively resets their payouts value to zero,
		// since they're selling all of their tokens). This makes sure the seller isn't disadvantaged if
		// they decide to buy back in.
		payouts[msg.sender] -= payoutDiff;
		
		// Decrease the total amount that's been paid out to maintain invariance.
        totalPayouts -= payoutDiff;
		
		// Check that we have tokens in existence (this is a bit of an irrelevant check since we're
		// selling tokens, but it guards against division by zero).
		if (totalSupply > 0) {
			// Scale the Ether taken as the selling fee by the scaleFactor variable.
			uint256 etherFee = fee * scaleFactor;
			
			if(penalty>0)etherFee += (penalty * scaleFactor); //if there is any penalty, use it to settle the debt
			
			// Fee is distributed to all remaining token holders.
			// rewardPerShare is the amount gained per token thanks to this sell.
			uint256 rewardPerShare = etherFee / totalSupply;
			
			// The Ether value per token is increased proportionally.
			earningsPerToken += (int256)(rewardPerShare);
		}else payouts[msg.sender]+=(int256)(penalty); //if he is the last holder, give him his penalty too, so there is no leftover ETH in the contract
	}
	
	//returns value of all dividends currently held by all shareholders
	function totalDiv() public view returns (int256){
	    return ((earningsPerToken * (int256)(totalSupply))-totalPayouts)/(int256)(scaleFactor);
	}
	
	// Dynamic value of Ether in reserve, according to the CRR requirement. Designed to not decrease token value in case of negative dividends
	function reserve() internal constant returns (uint256 amount) {
	    int256 divs=totalDiv();
	    
	    if(divs<0)return balance()+(uint256)(divs*-1);
	    return balance()-(uint256)(divs);
	}
	
	// Dynamic value of Ether in reserve, according to the CRR requirement. Returns reserve without negative dividends
	function realReserve() public view returns (uint256 amount) {
	    int256 divs=totalDiv();
	    
	    if(divs<0)return balance();
	    return balance()-(uint256)(divs);
	}

	// Calculates the number of tokens that can be bought for a given amount of Ether, according to the
	// dynamic reserve and totalSupply values (derived from the buy and sell prices).
	function getTokensForEther(uint256 ethervalue) public constant returns (uint256 tokens) {
		return sub(fixedExp(fixedLog(reserve() + ethervalue)*crr_n/crr_d + price_coeff), totalSupply);
	}

	// Semantically similar to getTokensForEther, but subtracts the callers balance from the amount of Ether returned for conversion.
	function calculateDividendTokens(uint256 ethervalue, uint256 subvalue) public constant returns (uint256 tokens) {
		return sub(fixedExp(fixedLog(reserve() - subvalue + ethervalue)*crr_n/crr_d + price_coeff), totalSupply);
	}
	
	// Converts a number tokens into an Ether value. Doesn't account for negative dividends
	function getEtherForTokensOld(uint256 tokens) public constant returns (uint256 ethervalue) {
		// How much reserve Ether do we have left in the contract?
		uint256 reserveAmount = reserve();

		// If you're the Highlander (or bagholder), you get The Prize. Everything left in the vault.
		if (tokens == totalSupply)
			return reserveAmount;

		// If there would be excess Ether left after the transaction this is called within, return the Ether
		// corresponding to the equation in Dr Jochen Hoenicke's original Ponzi paper, which can be found
		// at https://test.jochen-hoenicke.de/eth/ponzitoken/ in the third equation, with the CRR numerator 
		// and denominator altered to 1 and 2 respectively.
		return sub(reserveAmount, fixedExp((fixedLog(totalSupply - tokens) - price_coeff) * crr_d/crr_n));
	}

	// Converts a number tokens into an Ether value. Accounts for negative dividends
	function getEtherForTokens(uint256 tokens) public constant returns (uint256 ethervalue,uint256 penalty) {
		uint256 eth=getEtherForTokensOld(tokens);
		int256 divs=totalDiv();
		if(divs>=0)return (eth,0);
		
		uint256 debt=(uint256)(divs*-1);
		penalty=(((debt*scaleFactor)/totalSupply)*tokens)/scaleFactor;
		
		if(penalty>eth)return (0,penalty);
		return (eth-penalty,penalty);
	}

	// You don't care about these, but if you really do they're hex values for 
	// co-efficients used to simulate approximations of the log and exp functions.
	int256  constant one        = 0x10000000000000000;
	uint256 constant sqrt2      = 0x16a09e667f3bcc908;
	uint256 constant sqrtdot5   = 0x0b504f333f9de6484;
	int256  constant ln2        = 0x0b17217f7d1cf79ac;
	int256  constant ln2_64dot5 = 0x2cb53f09f05cc627c8;
	int256  constant c1         = 0x1ffffffffff9dac9b;
	int256  constant c3         = 0x0aaaaaaac16877908;
	int256  constant c5         = 0x0666664e5e9fa0c99;
	int256  constant c7         = 0x049254026a7630acf;
	int256  constant c9         = 0x038bd75ed37753d68;
	int256  constant c11        = 0x03284a0c14610924f;

	// The polynomial R = c1*x + c3*x^3 + ... + c11 * x^11
	// approximates the function log(1+x)-log(1-x)
	// Hence R(s) = log((1+s)/(1-s)) = log(a)
	function fixedLog(uint256 a) internal pure returns (int256 log) {
		int32 scale = 0;
		while (a > sqrt2) {
			a /= 2;
			scale++;
		}
		while (a <= sqrtdot5) {
			a *= 2;
			scale--;
		}
		int256 s = (((int256)(a) - one) * one) / ((int256)(a) + one);
		int256 z = (s*s) / one;
		return scale * ln2 +
			(s*(c1 + (z*(c3 + (z*(c5 + (z*(c7 + (z*(c9 + (z*c11/one))
				/one))/one))/one))/one))/one);
	}

	int256 constant c2 =  0x02aaaaaaaaa015db0;
	int256 constant c4 = -0x000b60b60808399d1;
	int256 constant c6 =  0x0000455956bccdd06;
	int256 constant c8 = -0x000001b893ad04b3a;
	
	// The polynomial R = 2 + c2*x^2 + c4*x^4 + ...
	// approximates the function x*(exp(x)+1)/(exp(x)-1)
	// Hence exp(x) = (R(x)+x)/(R(x)-x)
	function fixedExp(int256 a) internal pure returns (uint256 exp) {
		int256 scale = (a + (ln2_64dot5)) / ln2 - 64;
		a -= scale*ln2;
		int256 z = (a*a) / one;
		int256 R = ((int256)(2) * one) +
			(z*(c2 + (z*(c4 + (z*(c6 + (z*c8/one))/one))/one))/one);
		exp = (uint256) (((R + a) * one) / (R - a));
		if (scale >= 0)
			exp <<= scale;
		else
			exp >>= -scale;
		return exp;
	}
	
	// The below are safemath implementations of the four arithmetic operators
	// designed to explicitly prevent over- and under-flows of integer values.

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

	// This allows you to buy tokens by sending Ether directly to the smart contract
	// without including any transaction data (useful for, say, mobile wallet apps).
	function () payable public {
		// msg.value is the amount of Ether sent by the transaction.
		if (msg.value > 0) {
			fund();
		} else {
			getMeOutOfHere();
		}
	}
}