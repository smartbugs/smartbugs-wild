pragma solidity ^0.4.25;

/**
 * token contract functions
*/
contract token {
    function transfer(address receiver, uint256 amount) public;
    function balanceOf(address _owner) public view returns (uint256 balance);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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

contract owned {
        address public owner;

        constructor() public {
            owner = msg.sender;
        }

        modifier onlyOwner {
            require(msg.sender == owner);
            _;
        }

        function transferOwnership(address newOwner) onlyOwner public {
            owner = newOwner;
        }
}

contract GenjiCrowdsale is owned{
    using SafeMath for uint256;
    
    address public beneficiary;
    uint256 public amountRaised;
    uint256 public preSaleStartdate;
    uint256 public preSaleDeadline;
    uint256 public mainSaleStartdate;
    uint256 public mainSaleDeadline;
    uint256 public preSalePrice;
    uint256 public price;
    uint256 public fundTransferred;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;

    /**
     * Constrctor function
     *
     */
    constructor() public{
        beneficiary = 0xBCEb3a1Ff8dF1eD574bdEeBf8c2feEf47351Ba42;
        preSaleStartdate = 1563580800;
        preSaleDeadline = 1564617599;
        mainSaleStartdate = 1564617600;
        mainSaleDeadline = 1567641599;
        preSalePrice = 0.00002345 ether;
        price = 0.0000335 ether;
        tokenReward = token(0xb49b4d400D66AAa53ec07184A8C7c6C9c23374c9);
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable external {
        require(!crowdsaleClosed);
        uint256 bonus;
        uint256 amount;
        uint256 ethamount = msg.value;
        balanceOf[msg.sender] = balanceOf[msg.sender].add(ethamount);
        amountRaised = amountRaised.add(ethamount);
        
        //add bounus for funders
        if(now >= preSaleStartdate && now <= preSaleDeadline){
            amount =  ethamount.div(preSalePrice);
            bonus = amount * 50 / 100;
            amount = amount.add(bonus);
        }
        else if(now >= mainSaleStartdate && now <= mainSaleStartdate + 1 weeks){
            amount =  ethamount.div(price);
            bonus = amount * 40/100;
            amount = amount.add(bonus);
        }
        else if(now >= mainSaleStartdate + 1 weeks && now <= mainSaleStartdate + 2 weeks){
            amount =  ethamount.div(price);
            bonus = amount * 33/100;
            amount = amount.add(bonus);
        }
        else if(now >= mainSaleStartdate + 2 weeks && now <= mainSaleStartdate + 3 weeks){
            amount =  ethamount.div(price);
            bonus = amount * 25/100;
            amount = amount.add(bonus);
        }
        else if(now >= mainSaleStartdate + 3 weeks && now <= mainSaleStartdate + 4 weeks){
            amount =  ethamount.div(price);
            bonus = amount * 15/100;
            amount = amount.add(bonus);
        }
        else {
            amount =  ethamount.div(price);
            bonus = amount * 8/100;
            amount = amount.add(bonus);
        }
        
        amount = amount.mul(1000000000000000000);
        tokenReward.transfer(msg.sender, amount);
        beneficiary.transfer(ethamount);
        fundTransferred = fundTransferred.add(ethamount);
    }

    modifier afterDeadline() { if (now >= mainSaleDeadline) _; }

    /**
     *ends the campaign after deadline
     */
     
    function endCrowdsale() public afterDeadline onlyOwner {
         crowdsaleClosed = true;
    }
    
    /**
     *change pre sale price
    */
	function ChangepreSalePrice(uint256 _preSalePrice) public onlyOwner {
		  preSalePrice = _preSalePrice;	
	}
	
    /**
     *change price
    */
	function ChangePrice(uint256 _price) public onlyOwner {
		  price = _price;	
	}
	
	/**
     *change beneficiary
    */
	function ChangeBeneficiary(address _beneficiary) public onlyOwner {
		  beneficiary = _beneficiary;	
	}
	
	/**
     *change dates
    */
    function ChangeDates(uint256 _preSaleStartdate, uint256 _preSaleDeadline, uint256 _mainSaleStartdate, uint256 _mainSaleDeadline) public onlyOwner {
        
          if(_preSaleStartdate != 0){
               preSaleStartdate = _preSaleStartdate;
          }
          if(_preSaleDeadline != 0){
               preSaleDeadline = _preSaleDeadline;
          }
          if(_mainSaleStartdate != 0){
               mainSaleStartdate = _mainSaleStartdate;
          }
          if(_mainSaleDeadline != 0){
               mainSaleDeadline = _mainSaleDeadline; 
          }
		  
		  if(crowdsaleClosed == true){
			 crowdsaleClosed = false;
		  }
    }
    
    function getTokensBack() public onlyOwner {
        uint256 remaining = tokenReward.balanceOf(this);
        tokenReward.transfer(beneficiary, remaining);
    }
}