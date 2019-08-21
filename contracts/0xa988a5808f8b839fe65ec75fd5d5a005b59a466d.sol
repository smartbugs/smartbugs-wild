pragma solidity ^0.4.13;

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract PausableToken is Ownable {
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function increaseFrozen(address _owner,uint256 _incrementalAmount) public returns (bool);
    function burn(uint256 _value) public;
}

contract AddressWhitelist is Ownable {
    // the addresses that are included in the whitelist
    mapping (address => bool) whitelisted;
    
    function isWhitelisted(address addr) view public returns (bool) {
        return whitelisted[addr];
    }

    event LogWhitelistAdd(address indexed addr);

    // add these addresses to the whitelist
    function addToWhitelist(address[] addresses) public onlyOwner returns (bool) {
        for (uint i = 0; i < addresses.length; i++) {
            if (!whitelisted[addresses[i]]) {
                whitelisted[addresses[i]] = true;
                LogWhitelistAdd(addresses[i]);
            }
        }

        return true;
    }

    event LogWhitelistRemove(address indexed addr);

    // remove these addresses from the whitelist
    function removeFromWhitelist(address[] addresses) public onlyOwner returns (bool) {
        for (uint i = 0; i < addresses.length; i++) {
            if (whitelisted[addresses[i]]) {
                whitelisted[addresses[i]] = false;
                LogWhitelistRemove(addresses[i]);
            }
        }

        return true;
    }
}

contract RtcTokenCrowdsale is Ownable, AddressWhitelist {
    using SafeMath for uint256;
    PausableToken  public tokenReward;                         // address of the token used as reward

    // deployment variables for static supply sale
    uint256 public initialSupply;
    uint256 public tokensRemaining;
    uint256 public decimals;

    // multi-sig addresses and price variable
    address public beneficiaryWallet;                           // beneficiaryMultiSig (founder group) or wallet account
    uint256 public tokensPerEthPrice;                           // set initial value floating priceVar 10,000 tokens per Eth

    // uint256 values for min,max,caps,tracking
    uint256 public amountRaisedInWei;
    uint256 public fundingMinCapInWei;

    // pricing veriable
    uint256 public p1_duration;
    uint256 public p1_start;
    uint256 public p2_start;
    uint256 public white_duration;

    // loop control, ICO startup and limiters
    uint256 public fundingStartTime;                           // crowdsale start time#
    uint256 public fundingEndTime;                             // crowdsale end time#
    bool    public isCrowdSaleClosed               = false;     // crowdsale completion boolean
    bool    public areFundsReleasedToBeneficiary   = false;     // boolean for founder to receive Eth or not
    bool    public isCrowdSaleSetup                = false;     // boolean for crowdsale setup

    // Gas price limit
    uint256 maxGasPrice = 50000000000;

    event Buy(address indexed _sender, uint256 _eth, uint256 _RTC);
    event Refund(address indexed _refunder, uint256 _value);
    mapping(address => uint256) fundValue;


    // convert tokens to decimals
    function toSmallrtc(uint256 amount) public constant returns (uint256) {
        return amount.mul(10**decimals);
    }

    // convert tokens to whole
    function toRtc(uint256 amount) public constant returns (uint256) {
        return amount.div(10**decimals);
    }

    function updateMaxGasPrice(uint256 _newGasPrice) public onlyOwner {
        require(_newGasPrice != 0);
        maxGasPrice = _newGasPrice;
    }

    // setup the CrowdSale parameters
    function setupCrowdsale(uint256 _fundingStartTime) external onlyOwner {
        if ((!(isCrowdSaleSetup))
            && (!(beneficiaryWallet > 0))){
            // init addresses
            tokenReward                             = PausableToken(0xdb75BFC1ad984c5CeefA8Ec6394596e20d789034);
            beneficiaryWallet                       = 0xf07bd63C5cf404c2f17ab4F9FA1e13fCCEbc5255;
            tokensPerEthPrice                       = 10000;                  // 1 ETH = 10,000 RTC

            // funding targets
            fundingMinCapInWei                      = 350 ether;                          //350 Eth (min cap) (test = 15) - crowdsale is considered success after this value

            // update values
            decimals                                = 18;
            amountRaisedInWei                       = 0;
            initialSupply                           = toSmallrtc(35000000);                  //   35 million * 18 decimal
            tokensRemaining                         = initialSupply;

            fundingStartTime                        = _fundingStartTime;

            white_duration                          = 2 weeks;                        // 2 week (test = 2 hour)
            p1_duration                             = 4 weeks;                       // 4 week (test = 2 hour)

            p1_start                                = fundingStartTime + white_duration;
            p2_start                                = p1_start + p1_duration + 4 weeks;   // + 4 week after p1 ends (test = 4 hour)

            fundingEndTime                          = p2_start + 4 weeks; // + 4 week (test = 4 hour)

            // configure crowdsale
            isCrowdSaleSetup                        = true;
            isCrowdSaleClosed                       = false;
        }
    }

    function setBonusPrice() public constant returns (uint256 bonus) {
        require(isCrowdSaleSetup);
        require(p1_start + p1_duration <= p2_start);
        if (now >= fundingStartTime && now <= p1_start) { // Private sale Bonus 40% = 4,000 RTC  = 1 ETH
            bonus = 4000;
        } else if (now > p1_start && now <= p1_start + p1_duration) { // Phase-1 Bonus 30% = 3,000 RTC  = 1 ETH
            bonus = 3000;
        } else if (now > p2_start && now <= p2_start + 1 days ) { // Phase-2 1st day Bonus 25% = 2,500 RTC = 1 ETH
            bonus = 2500;
        } else if (now > p2_start + 1 days && now <= p2_start + 1 weeks ) { // Phase-2 week-1 Bonus 20% = 2,000 RTC = 1 ETH
            bonus = 2000;
        } else if (now > p2_start + 1 weeks && now <= p2_start + 2 weeks ) { // Phase-2 week-2 Bonus +15% = 1,500 RTC = 1 ETH
            bonus = 1500;
        } else if (now > p2_start + 2 weeks && now <= p2_start + 3 weeks ) { // Phase-2 week-3 Bonus +10% = 1,000 RTC = 1 ETH
            bonus = 1000;
        } else if (now > p2_start + 3 weeks && now <= fundingEndTime ) { // Phase-2 final week Bonus 5% = 500 RTC = 1 ETH
            bonus = 500;
        } else {
            revert();
        }
    }

    // p1_duration constant. Only p2 start changes. p2 start cannot be greater than 1 month from p1 end
    function updateDuration(uint256 _newP2Start) external onlyOwner { // function to update the duration of phase-1 and adjust the start time of phase-2
        require(isCrowdSaleSetup
            && !(p2_start == _newP2Start)
            && !(_newP2Start > p1_start + p1_duration + 30 days)
            && (now < p2_start)
            && (fundingStartTime + p1_duration < _newP2Start));
        p2_start = _newP2Start;
        fundingEndTime = p2_start.add(4 weeks);   // 4 week
    }

    // default payable function when sending ether to this contract
    function () external payable {
        require(tx.gasprice <= maxGasPrice);
        require(msg.data.length == 0);
        
        BuyRTCtokens();
    }

    function BuyRTCtokens() public payable {
        // conditions (length, crowdsale setup, zero check, exceed funding contrib check, contract valid check, within funding block range check, balance overflow check etc)
        require(!(msg.value == 0)
        && (isCrowdSaleSetup)
        && (now >= fundingStartTime)
        && (now <= fundingEndTime)
        && (tokensRemaining > 0));

        // only whitelisted addresses are allowed during the first day of phase 1
        if (now <= p1_start) {
            assert(isWhitelisted(msg.sender));
        }
        uint256 rewardTransferAmount        = 0;
        uint256 rewardBaseTransferAmount    = 0;
        uint256 rewardBonusTransferAmount   = 0;
        uint256 contributionInWei           = msg.value;
        uint256 refundInWei                 = 0;

        rewardBonusTransferAmount       = setBonusPrice();
        rewardBaseTransferAmount        = (msg.value.mul(tokensPerEthPrice)); // Since both ether and RTC have 18 decimals, No need of conversion
        rewardBonusTransferAmount       = (msg.value.mul(rewardBonusTransferAmount)); // Since both ether and RTC have 18 decimals, No need of conversion
        rewardTransferAmount            = rewardBaseTransferAmount.add(rewardBonusTransferAmount);

        if (rewardTransferAmount > tokensRemaining) {
            uint256 partialPercentage;
            partialPercentage = tokensRemaining.mul(10**18).div(rewardTransferAmount);
            contributionInWei = contributionInWei.mul(partialPercentage).div(10**18);
            rewardBonusTransferAmount = rewardBonusTransferAmount.mul(partialPercentage).div(10**18);
            rewardTransferAmount = tokensRemaining;
            refundInWei = msg.value.sub(contributionInWei);
        }

        amountRaisedInWei               = amountRaisedInWei.add(contributionInWei);
        tokensRemaining                 = tokensRemaining.sub(rewardTransferAmount);  // will cause throw if attempt to purchase over the token limit in one tx or at all once limit reached
        fundValue[msg.sender]           = fundValue[msg.sender].add(contributionInWei);
        assert(tokenReward.increaseFrozen(msg.sender, rewardBonusTransferAmount));
        tokenReward.transfer(msg.sender, rewardTransferAmount);
        Buy(msg.sender, contributionInWei, rewardTransferAmount);
        if (refundInWei > 0) {
            msg.sender.transfer(refundInWei);
        }
    }

    function beneficiaryMultiSigWithdraw() external onlyOwner {
        checkGoalReached();
        require(areFundsReleasedToBeneficiary && (amountRaisedInWei >= fundingMinCapInWei));
        beneficiaryWallet.transfer(this.balance);
    }

    function checkGoalReached() public returns (bytes32 response) { // return crowdfund status to owner for each result case, update public constant
        // update state & status variables
        require (isCrowdSaleSetup);
        if ((amountRaisedInWei < fundingMinCapInWei) && (block.timestamp <= fundingEndTime && block.timestamp >= fundingStartTime)) { // ICO in progress, under softcap
            areFundsReleasedToBeneficiary = false;
            isCrowdSaleClosed = false;
            return "In progress (Eth < Softcap)";
        } else if ((amountRaisedInWei < fundingMinCapInWei) && (block.timestamp < fundingStartTime)) { // ICO has not started
            areFundsReleasedToBeneficiary = false;
            isCrowdSaleClosed = false;
            return "Crowdsale is setup";
        } else if ((amountRaisedInWei < fundingMinCapInWei) && (block.timestamp > fundingEndTime)) { // ICO ended, under softcap
            areFundsReleasedToBeneficiary = false;
            isCrowdSaleClosed = true;
            return "Unsuccessful (Eth < Softcap)";
        } else if ((amountRaisedInWei >= fundingMinCapInWei) && (tokensRemaining == 0)) { // ICO ended, all tokens gone
            areFundsReleasedToBeneficiary = true;
            isCrowdSaleClosed = true;
            return "Successful (RTC >= Hardcap)!";
        } else if ((amountRaisedInWei >= fundingMinCapInWei) && (block.timestamp > fundingEndTime) && (tokensRemaining > 0)) { // ICO ended, over softcap!
            areFundsReleasedToBeneficiary = true;
            isCrowdSaleClosed = true;
            return "Successful (Eth >= Softcap)!";
        } else if ((amountRaisedInWei >= fundingMinCapInWei) && (tokensRemaining > 0) && (block.timestamp <= fundingEndTime)) { // ICO in progress, over softcap!
            areFundsReleasedToBeneficiary = true;
            isCrowdSaleClosed = false;
            return "In progress (Eth >= Softcap)!";
        }
    }

    function refund() external { // any contributor can call this to have their Eth returned. user's purchased RTC tokens are burned prior refund of Eth.
        checkGoalReached();
        //require minCap not reached
        require ((amountRaisedInWei < fundingMinCapInWei)
        && (isCrowdSaleClosed)
        && (now > fundingEndTime)
        && (fundValue[msg.sender] > 0));

        //refund Eth sent
        uint256 ethRefund = fundValue[msg.sender];
        fundValue[msg.sender] = 0;

        //send Eth back, burn tokens
        msg.sender.transfer(ethRefund);
        Refund(msg.sender, ethRefund);
    }

    function burnRemainingTokens() onlyOwner external {
        require(now > fundingEndTime);
        uint256 tokensToBurn = tokenReward.balanceOf(this);
        tokenReward.burn(tokensToBurn);
    }
}

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