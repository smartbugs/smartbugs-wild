pragma solidity ^0.4.11;

contract token {
    function transfer(address receiver, uint amount);
    function balanceOf( address _address )returns(uint256);
    function burn ( uint256 amount ); 
}

contract StudioCrowdsale {
    address public beneficiary;
    address public owner;
  
    uint public amountRaised;
    uint public tokensSold;
    uint public deadline;
    uint public price;
    token public tokenReward;
    
    mapping(address => uint256) public contributions;
    bool crowdSaleStart;
    bool crowdSalePause;
    bool crowdSaleClosed;

   
    event FundTransfer(address participant, uint amount);

    modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }

    function StudioCrowdsale() {
        beneficiary = msg.sender;
        owner = msg.sender;
        price =  .00222222222 ether;
        tokenReward = token(0xf064c38e3f5fa73981ee98372d32a16d032769cc);
    }

    function () payable {
        require(!crowdSaleClosed);
        require(!crowdSalePause);
        if ( crowdSaleStart) require( now < deadline );
        if ( !crowdSaleStart && tokensSold > 2500000 ) throw;
        uint amount = msg.value;
        contributions[msg.sender] += amount;
        amountRaised += amount;
        tokensSold += amount / price;
        
        if (tokensSold >  2500000 && tokensSold  <=  8500000 ) { price = .00333333333 ether; }
        if (tokensSold >  8500000 && tokensSold  <= 13500000 ) { price = .00363636363 ether; }
        if (tokensSold > 13500000 && tokensSold <=  18500000 ) { price = .00444444444 ether; }
        if (tokensSold > 18500000 ) { price = .005 ether; }
        
        tokenReward.transfer(msg.sender, amount / price);
        FundTransfer(msg.sender, amount );
        beneficiary.transfer( amount );
       
    }

    // Start this November 1
    function startCrowdsale() onlyOwner  {
        
        crowdSaleStart = true;
        deadline = now + 120 days;
        price =  .0033333333333 ether;
    }

    function endCrowdsale() onlyOwner  {
        
        
        crowdSaleClosed = true;
    }


    function pauseCrowdsale() onlyOwner {
        
        crowdSalePause = true;
        
        
    }

    function unpauseCrowdsale() onlyOwner {
        
        crowdSalePause = false;
        
        
    }
    
    function transferOwnership ( address _newowner ) onlyOwner {
        
        owner = _newowner;
        
    }
    
    function transferBeneficiary ( address _newbeneficiary ) onlyOwner {
        
        beneficiary = _newbeneficiary;
        
    }
    
    function withdrawStudios() onlyOwner{
        if ( now < deadline ){
        uint256 balance = tokenReward.balanceOf(address(this));
        tokenReward.transfer( beneficiary, balance );}
        else tokenReward.burn(tokenReward.balanceOf(address(this)));
        
        
    }
    
}