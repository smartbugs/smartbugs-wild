pragma solidity ^0.4.2;
//This project is beta stage and might contain unknown bugs.
//I am not responsible for any consequences of any use of the code or protocol that is suggested here.
contract SimpleMixer {
    
    struct Deal{
        mapping(address=>uint) deposit;
        uint                   depositSum;
        mapping(address=>bool) claims;
	    uint 		           numClaims;
        uint                   claimSum;

        uint                   startTime;
        uint                   depositDurationInSec;
        uint                   claimDurationInSec;
        uint                   claimDepositInWei;
        uint                   claimValueInWei;
     	uint                   minNumClaims;
        
        bool                   active;
        bool                   fullyFunded;
    }
    
    Deal[]  _deals;
     
    event NewDeal( address indexed user, uint indexed _dealId, uint _startTime, uint _depositDurationInHours, uint _claimDurationInHours, uint _claimUnitValueInWei, uint _claimDepositInWei, uint _minNumClaims, bool _success, string _err );
    event Claim( address indexed _claimer, uint indexed _dealId, bool _success, string _err );
    event Deposit( address indexed _depositor, uint indexed _dealId, uint _value, bool _success, string _err );
    event Withdraw( address indexed _withdrawer, uint indexed _dealId, uint _value, bool _public, bool _success, string _err );

    event EnoughClaims( uint indexed _dealId );
    event DealFullyFunded( uint indexed _dealId );
    
    enum ReturnValue { Ok, Error }

    function SimpleMixer(){
    }
    
    function newDeal( uint _depositDurationInHours, uint _claimDurationInHours, uint _claimUnitValueInWei, uint _claimDepositInWei, uint _minNumClaims ) returns(ReturnValue){
        uint dealId = _deals.length;        
        if( _depositDurationInHours == 0 || _claimDurationInHours == 0 ){
        	NewDeal( msg.sender,
        	         dealId,
        	         now,
        	         _depositDurationInHours,
        	         _claimDurationInHours,
        	         _claimUnitValueInWei,
        	         _claimDepositInWei,
        	         _minNumClaims,
        	         false,
        	         "_depositDurationInHours and _claimDurationInHours must be positive" );
            return ReturnValue.Error;
        }
        _deals.length++;
        _deals[dealId].depositSum = 0;
	    _deals[dealId].numClaims = 0;
        _deals[dealId].claimSum = 0;
        _deals[dealId].startTime = now;
        _deals[dealId].depositDurationInSec = _depositDurationInHours * 1 hours;
        _deals[dealId].claimDurationInSec = _claimDurationInHours * 1 hours;
        _deals[dealId].claimDepositInWei = _claimDepositInWei;
        _deals[dealId].claimValueInWei = _claimUnitValueInWei;
	    _deals[dealId].minNumClaims = _minNumClaims;
        _deals[dealId].fullyFunded = false;
        _deals[dealId].active = true;
    	NewDeal( msg.sender,
    	         dealId,
    	         now,
    	         _depositDurationInHours,
    	         _claimDurationInHours,
    	         _claimUnitValueInWei,
    	         _claimDepositInWei,
    	         _minNumClaims,
    	         true,
    	         "all good" );
        return ReturnValue.Ok;
    }
    
    function makeClaim( uint dealId ) payable returns(ReturnValue){
        Deal deal = _deals[dealId];        
        bool errorDetected = false;
        string memory error;
    	// validations
    	if( !_deals[dealId].active ){
    	    error = "deal is not active";
    	    //ErrorLog( msg.sender, dealId, "makeClaim: deal is not active");
    	    errorDetected = true;
    	}
        if( deal.startTime + deal.claimDurationInSec < now ){
            error = "claim phase already ended";            
            //ErrorLog( msg.sender, dealId, "makeClaim: claim phase already ended" );
            errorDetected = true;
        }
        if( msg.value != deal.claimDepositInWei ){
            error = "msg.value must be equal to claim deposit unit";            
            //ErrorLog( msg.sender, dealId, "makeClaim: msg.value must be equal to claim deposit unit" );
            errorDetected = true;
        }
    	if( deal.claims[msg.sender] ){
    	    error = "cannot claim twice with the same address";
            //ErrorLog( msg.sender, dealId, "makeClaim: cannot claim twice with the same address" );
            errorDetected = true;
    	}
    	
    	if( errorDetected ){
    	    Claim( msg.sender, dealId, false, error );
    	    if( ! msg.sender.send(msg.value) ) throw; // send money back
    	    return ReturnValue.Error;
    	}

	    // actual claim
        deal.claimSum += deal.claimValueInWei;
        deal.claims[msg.sender] = true;
	    deal.numClaims++;

	    Claim( msg.sender, dealId, true, "all good" );
	    
	    if( deal.numClaims == deal.minNumClaims ) EnoughClaims( dealId );
	    
    	return ReturnValue.Ok;
    }

    function makeDeposit( uint dealId ) payable returns(ReturnValue){
        bool errorDetected = false;
        string memory error;
    	// validations
        if( msg.value == 0 ){
            error = "deposit value must be positive";
            //ErrorLog( msg.sender, dealId, "makeDeposit: deposit value must be positive");
            errorDetected = true;
        }
    	if( !_deals[dealId].active ){
    	    error = "deal is not active";
    	    //ErrorLog( msg.sender, dealId, "makeDeposit: deal is not active");
    	    errorDetected = true;
    	}
        Deal deal = _deals[dealId];
        if( deal.startTime + deal.claimDurationInSec > now ){
            error = "contract is still in claim phase";
    	    //ErrorLog( msg.sender, dealId, "makeDeposit: contract is still in claim phase");
    	    errorDetected = true;
        }
        if( deal.startTime + deal.claimDurationInSec + deal.depositDurationInSec < now ){
            error = "deposit phase is over";
    	    //ErrorLog( msg.sender, dealId, "makeDeposit: deposit phase is over");
    	    errorDetected = true;
        }
        if( ( msg.value % deal.claimValueInWei ) > 0 ){
            error = "deposit value must be a multiple of claim value";
    	    //ErrorLog( msg.sender, dealId, "makeDeposit: deposit value must be a multiple of claim value");
    	    errorDetected = true;
        }
    	if( deal.deposit[msg.sender] > 0 ){
    	    error = "cannot deposit twice with the same address";
    	    //ErrorLog( msg.sender, dealId, "makeDeposit: cannot deposit twice with the same address");
    	    errorDetected = true;
    	}
    	if( deal.numClaims < deal.minNumClaims ){
    	    error = "deal is off as there are not enough claims. Call withdraw with you claimer address";
    	    /*ErrorLog( msg.sender,
    	              dealId,
    	              "makeDeposit: deal is off as there are not enough claims. Call withdraw with you claimer address");*/
    	    errorDetected = true;
    	}
    	
    	if( errorDetected ){
    	    Deposit( msg.sender, dealId, msg.value, false, error );
    	    if( ! msg.sender.send(msg.value) ) throw; // send money back
    	    return ReturnValue.Error;
    	}
        
	    // actual deposit
        deal.depositSum += msg.value;
        deal.deposit[msg.sender] = msg.value;

    	if( deal.depositSum >= deal.claimSum ){
    	    deal.fullyFunded = true;
    	    DealFullyFunded( dealId );
    	}
    
    	Deposit( msg.sender, dealId, msg.value, true, "all good" );
	    return ReturnValue.Ok;    	
    }
        
    function withdraw( uint dealId ) returns(ReturnValue){
    	// validation
        bool errorDetected = false;
        string memory error;
        Deal deal = _deals[dealId];
    	bool enoughClaims = deal.numClaims >= deal.minNumClaims;
    	if( ! enoughClaims ){
    	    if( deal.startTime + deal.claimDurationInSec > now ){
    	        error = "claim phase not over yet";
    	        //ErrorLog( msg.sender, dealId, "withdraw: claim phase not over yet");
    	        errorDetected = true;
    	    }
    	}
    	else{
    	    if( deal.startTime + deal.depositDurationInSec + deal.claimDurationInSec > now ){
    	        error = "deposit phase not over yet";
    	        //ErrorLog( msg.sender, dealId, "withdraw: deposit phase not over yet");
    	        errorDetected = true;
    	    }
    	}
    	
    	if( errorDetected ){
    	    Withdraw( msg.sender, dealId, 0, false, false, error );
        	return ReturnValue.Error; // note that function is not payable    	    
    	}


	    // actual withdraw
	    bool publicWithdraw;
    	uint withdrawedValue = 0;
        if( (! deal.fullyFunded) && enoughClaims ){
	        publicWithdraw = true;
            uint depositValue = deal.deposit[msg.sender];
            if( depositValue == 0 ){
                Withdraw( msg.sender, dealId, 0, publicWithdraw, false, "address made no deposit. Note that this should be called with the public address" );
    	        //ErrorLog( msg.sender, dealId, "withdraw: address made no deposit. Note that this should be called with the public address");
    	        return ReturnValue.Error; // function non payable
            }
            
            uint effectiveNumDeposits = deal.depositSum / deal.claimValueInWei;
            uint userEffectiveNumDeposits = depositValue / deal.claimValueInWei;
            uint extraBalance = ( deal.numClaims - effectiveNumDeposits ) * deal.claimDepositInWei;
            uint userExtraBalance = userEffectiveNumDeposits * extraBalance / effectiveNumDeposits;

            deal.deposit[msg.sender] = 0; // invalidate user
            // give only half of extra balance. otherwise dishonest party could obtain 99% of the extra balance and lose almost nothing
	        withdrawedValue = depositValue + deal.claimDepositInWei * userEffectiveNumDeposits + ( userExtraBalance / 2 );
            if( ! msg.sender.send(withdrawedValue) ) throw;
        }
        else{
    	    publicWithdraw = false;
            if( ! deal.claims[msg.sender] ){
                Withdraw( msg.sender, dealId, 0, publicWithdraw, false, "address made no claims. Note that this should be called with the secret address" );
    	        //ErrorLog( msg.sender, dealId, "withdraw: address made no claims. Note that this should be called with the secret address");
    	        return ReturnValue.Error; // function non payable
            }
	        if( enoughClaims ) withdrawedValue = deal.claimDepositInWei + deal.claimValueInWei;
	        else withdrawedValue = deal.claimDepositInWei;
		
            deal.claims[msg.sender] = false; // invalidate claim
            if( ! msg.sender.send(withdrawedValue) ) throw;
        }
	    
        Withdraw( msg.sender, dealId, withdrawedValue, publicWithdraw, true, "all good" );
        return ReturnValue.Ok;
    }    

    ////////////////////////////////////////////////////////////////////////////////////////
    
    function dealStatus(uint _dealId) constant returns(uint[4]){
        // returns (active, num claims, claim sum, deposit sum) all as integers
        uint active = _deals[_dealId].active ? 1 : 0;
        uint numClaims = _deals[_dealId].numClaims;
        uint claimSum = _deals[_dealId].claimSum;
	    uint depositSum = _deals[_dealId].depositSum;
        
        return [active, numClaims, claimSum, depositSum];
    }

}