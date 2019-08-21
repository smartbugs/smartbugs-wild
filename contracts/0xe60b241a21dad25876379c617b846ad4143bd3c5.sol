pragma solidity ^0.4.11;

contract token {
    function transfer(address receiver, uint amount);
    function balanceOf( address _address )returns(uint256);
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
        price =  .00000000002222222 ether;
        tokenReward = token(0xe31f159cdc3370aec8ef5fbf3b7fce23766155f5);
    }

    function () payable {
        require(!crowdSaleClosed);
        require(!crowdSalePause);
        if ( crowdSaleStart) require( now < deadline );
        if ( !crowdSaleStart && tokensSold > 250000000000000 ) throw;
        uint amount = msg.value;
        contributions[msg.sender] += amount;
        amountRaised += amount;
        tokensSold += amount / price;
        
        if (tokensSold >  250000000000000 && tokensSold  <=  850000000000000 ) { price = .00000000003333333 ether; }
        if (tokensSold >  850000000000000 && tokensSold  <= 1350000000000000 ) { price = .00000000003636363 ether; }
        if (tokensSold > 1350000000000000 && tokensSold <=  1850000000000000 ) { price = .00000000004444444 ether; }
        if (tokensSold > 1850000000000000 ) { price = .00000000005 ether; }
        
        tokenReward.transfer(msg.sender, amount / price);
        FundTransfer(msg.sender, amount );
        beneficiary.transfer( amount );
       
    }

    // Start this October 27
    function startCrowdsale() onlyOwner  {
        
        crowdSaleStart = true;
        deadline = now + 120 days;
        price =  .000000000033333333 ether;
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
        
        uint256 balance = tokenReward.balanceOf(address(this));
        
        tokenReward.transfer( beneficiary, balance );
        
        
    }
    
}