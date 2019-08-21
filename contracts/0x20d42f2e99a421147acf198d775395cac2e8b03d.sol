//pragma solidity ^0.3.6;
contract Token {
	function balanceOf(address user) constant returns (uint256 balance);
	function transfer(address receiver, uint amount) returns(bool);
}

// A Sub crowdfunding contract. Its only purpose is to redirect ether it receives to the 
// main crowdfunding contract. This mecanism is usefull to know the sponsor to
// reward for an indirect donation. You can't give for someone else when you give through
// these contracts
contract AltCrowdfunding {
	
	Crowdfunding mainCf ;                                       // Referenre to the main crowdfunding contract
	
	function AltCrowdfunding(address cf){						// Construct the altContract with a reference to the main one
		mainCf = Crowdfunding(cf);
	}
	
	function(){
		mainCf.giveFor.value(msg.value)(msg.sender);			// Relay Ether sent to the main crowndfunding contract
	}
	
}

contract Crowdfunding {

	struct Backer {
		uint weiGiven;										// Amount of Ether given
		uint ungivenNxc ;                                 	// (pending) If the first goal of the crowdfunding is not reached yet the NxC are stored here
	}
	
	struct Sponsor {
	    uint nxcDirected;                                   // How much milli Nxc this sponsor sold for us
	    uint earnedNexium;                                  // How much milli Nxc this sponsor earned by solding Nexiums for us
	    address sponsorAddress;                             // Where Nexiums earned by a sponsor are sent
	    uint sponsorBonus;
	    uint backerBonus;
	}
	
    //Every public variable can be read by everyone from the blockchain
	
	Token 	public nexium;                                  // Nexium contract reference
	address public owner;					               	// Contract admin (beyond the void)
	address public beyond;					            	// Address that will receive ether when the first step is be reached
	address public bitCrystalEscrow;   						// Our escrow for Bitcrystals (ie EverdreamSoft)
	uint 	public startingEtherValue;						// How much milli Nxc are sent by ether
	uint 	public stepEtherValue;					        // For every stage of the crowdfunding, the number of Nexium sent by ether is decreased by this number
	uint    public collectedEth;                            // Collected ether in wei
	uint 	public nxcSold;                                 // How much milli Nxc were sold 
	uint 	public perStageNxc;                             // How much milli Nxc we much sell for each stage
	uint 	public nxcPerBcy;                         		// How much milli Nxc we give for each Bitcrystal
    uint 	public collectedBcy;                            // Collected Bitcrystals
	uint 	public minInvest;				            	// Minimum to invest (in wei)
	uint 	public startDate;    							// crowndfunding startdate                               
	uint 	public endDate;									// crowndfunding enddate 
	bool 	public isLimitReached;                          // Tell if the first stage of the CrowdFunding is reached, false when not set
	
	address[] public backerList;							// Addresses of all backers
	address[] public altList;					     		// List of alternative contracts for sponsoring (useless for this contract)
	mapping(address => Sponsor) public sponsorList;	        // The sponsor linked to an alternative contract
	mapping(address => Backer) public backers;            	// The Backer for a given address

	modifier onlyBy(address a){
		if (msg.sender != a) throw;                         // Auth modifier, if the msg.sender isn't the expected address, throw.
		_
	}
	
	event Gave(address);									// 
	
//--------------------------------------\\
	
	function Crowdfunding() {
		
		// Constructor of the contract. set the different variables
		
		nexium = Token(0x45e42d659d9f9466cd5df622506033145a9b89bc); 	// Nexium contract address
		beyond = 0x89E7a245d5267ECd5Bf4cA4C1d9D4D5A14bbd130 ;
		owner = msg.sender;
		minInvest = 10 finney;
		startingEtherValue = 700*1000;
		stepEtherValue = 25*1000;
		nxcPerBcy = 14;
		perStageNxc = 5000000 * 1000;
		startDate = 1478012400 ;
		endDate = 1480604400 ;
		bitCrystalEscrow = 0x72037bf2a3fc312cde40c7f7cd7d2cef3ad8c193;
	} 

//--------------------------------------\\
	
	// Use this function to buy Nexiums for someone (can be you of course)
	function giveFor(address beneficiary){
		if (msg.value < minInvest) throw;                                      // Throw when the minimum to invest isn't reached
		if (endDate < now || (now < startDate && now > startDate - 3 hours )) throw;        // Check if the crowdfunding is started and not already over
		
		// Computing the current amount of Nxc we send per ether. 
		uint currentEtherValue = getCurrEthValue();
		
		//it's possible to invest before the begining of the crowdfunding but the price is x10.
		//Allow backers to test the contract before the begining.
		if(now < startDate) currentEtherValue /= 10;
		
		// Computing the number of milli Nxc we will send to the beneficiary
		uint givenNxc = (msg.value * currentEtherValue)/(1 ether);
		nxcSold += givenNxc;                                                   //Updating the sold Nxc amount
		if (nxcSold >= perStageNxc) isLimitReached = true ; 
		
		Sponsor sp = sponsorList[msg.sender];
		
		//Check if the user gives through a sponsor contract
		if (sp.sponsorAddress != 0x0000000000000000000000000000000000000000) {
		    sp.nxcDirected += givenNxc;                                        // Update the number of milli Nxc this sponsor sold for us
		    
		    // This part compute the bonus rate NxC the sponsor will have depending on the total of Nxc he sold.
		    uint bonusRate = sp.nxcDirected / 80000000;
		    if (bonusRate > sp.sponsorBonus) bonusRate = sp.sponsorBonus;
		    
		    // Giving to the sponsor the amount of Nxc he earned by this last donation
		    uint sponsorNxc = (sp.nxcDirected * bonusRate)/100 - sp.earnedNexium;
			if (!giveNxc(sp.sponsorAddress, sponsorNxc))throw;
			
			
			sp.earnedNexium += sponsorNxc;                                     // Update the number of milli Nxc this sponsor earned
			givenNxc = (givenNxc*(100 + sp.backerBonus))/100;                  // Increase by x% the number of Nxc we will give to the backer
		}
		
		if (!giveNxc(beneficiary, givenNxc))throw;                             // Give to the Backer the Nxc he just earned
		
		// Add the new Backer to the list, if he gave for the first time
		Backer backer = backers[beneficiary];
		if (backer.weiGiven == 0){
			backerList[backerList.length++] = beneficiary;
		}
		backer.weiGiven += msg.value;                                          // Update the gave wei of this Backer
		collectedEth += msg.value;                                             // Update the total wei collcted during the crowdfunding     
		Gave(beneficiary);                                                     // Trigger an event 
	}
	
	
	// If you gave ether before the first stage is reached you might have some ungiven
	// Nxc for your address. This function, if called, will give you the nexiums you didn't
	// received. /!\ Nexium bonuses for your partner rank will not be given during the crowdfunding
	function claimNxc(){
	    if (!isLimitReached) throw;
	    address to = msg.sender;
	    nexium.transfer(to, backers[to].ungivenNxc);
	    backers[to].ungivenNxc = 0;
	}
	
	// This function can be called after the crowdfunding if the first goal is not reached
	// It gives back the ethers of the specified address
	function getBackEther(){
	    getBackEtherFor(msg.sender);
	}
	
	function getBackEtherFor(address account){
	    if (now > endDate && !isLimitReached){
	        uint sentBack = backers[account].weiGiven;
	        backers[account].weiGiven = 0;                                     // No DAO style re entrance ;)
	        if(!account.send(sentBack))throw;
	    } else throw ;
	}
	
	// The anonymous function automatically make a donation for the person who gave ethers
	function(){
		giveFor(msg.sender);
	}
	
//--------------------------------------\\

    //Create a new sponsoring contract 
	function addAlt(address sponsor, uint _sponsorBonus, uint _backerBonus)
	onlyBy(owner){
	    if (_sponsorBonus > 10 || _backerBonus > 10 || _sponsorBonus + _backerBonus > 15) throw;
		altList[altList.length++] = address(new AltCrowdfunding(this));
		sponsorList[altList[altList.length -1]] = Sponsor(0, 0, sponsor, _sponsorBonus, _backerBonus);
	}
	
	// Set the value of BCY gave by the SOG network. Only our BCY escrow can modify it.
    function setBCY(uint newValue)
    onlyBy(bitCrystalEscrow){
        if (now < startDate || now > endDate) throw;
        if (newValue != 0 && newValue < 714285714) collectedBcy = newValue; // 714285714 * 14 ~= 10 000 000 000 mili Nxc maximum to avoid wrong value
        else throw;
    }
    
    // If the minimum goal is reached, beyond the void can have the ethers stored on the contract
    function withdrawEther(address to, uint amount)
    onlyBy(owner){
        if (!isLimitReached) throw;
        var r = to.send(amount);
    }
    
    function withdrawNxc(address to, uint amount)
    onlyBy(owner){
        nexium.transfer(to, amount);
    }
    
    //If there are still Nexiums or Ethers on the contract after 100 days after the end of the crowdfunding
    //This function send all of it to the multi sig of the beyond the void team (emergency case)
    function blackBox(){
        if (now < endDate + 100 days)throw;
        nexium.transfer(beyond, nexium.balanceOf(this));
        var r = beyond.send(this.balance);
    }
	
	// Each time this contract send Nxc this function is called. It check if
	// the minimum goal is reached before sending any nexiums out.
	function giveNxc(address to, uint amount) internal returns (bool){
	    bool res;
	    if (isLimitReached){
	        if (nexium.transfer(to, amount)){
	            // If there is some ungiven Nxc remaining for this address, send it.
	            if (backers[to].ungivenNxc != 0){
	                 res = nexium.transfer(to, backers[to].ungivenNxc); 
	                 backers[to].ungivenNxc = 0;
	            } else {
	                res = true;
	            }
	        } else {
	            res = false;
	        }
		// If the limit is not reached yet, the nexiums are not sent but stored in the contract waiting this goal being reached.
		// They are released when the same backer gives ether while the limit is reached, or by claiming them after the minimal goal is reached .
	    } else {
	        backers[to].ungivenNxc += amount;
	        res = true;
	    }
	    return res;
	}
	
	//--------------------------------------\\
	
	function getCurrEthValue() returns(uint){
	    return  startingEtherValue - stepEtherValue * ((nxcSold + collectedBcy * nxcPerBcy)/perStageNxc);
	}
	
}