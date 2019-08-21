pragma solidity ^0.4.24;

/**
 ZOMO 5D v2.6.8

 * This product is protected under license.  Any unauthorized copy, modification, or use is prohibited.

**/


contract Z5Devents {


    
    event onNewName
    (
        uint256 indexed playerID,
        address indexed playerAddress,
        bytes32 indexed playerName,
        bool isNewPlayer,
        uint256 affiliateID,
        address affiliateAddress,
        bytes32 affiliateName,
        uint256 amountPaid,
        uint256 timeStamp
    );
    

    event onEndTx
    (
       
        bytes32 playerName,
        address playerAddress,
        uint256 ethIn,
        uint256 keysBought,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 genAmount,
        uint256 potAmount,
        uint256 airDropPot,
		uint256 currentround
    );
    
	
    event onWithdraw
    (
        uint256 indexed playerID,
        address playerAddress,
        bytes32 playerName,
        uint256 ethOut,
        uint256 timeStamp
    );
    

    event onWithdrawAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 ethOut,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 genAmount
    );
    

	
    event onBuyAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 ethIn,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 genAmount
    );

    event onReLoadAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 genAmount
    );
    

    event onAffiliatePayout
    (
        uint256 indexed affiliateID,
        address affiliateAddress,
        bytes32 affiliateName,
        uint256 indexed roundID,
        uint256 indexed buyerID,
        uint256 amount,
        uint256 timeStamp
    );
    


}





contract ZoMo5D is Z5Devents 
{
    using SafeMath for *;
    using NameCheck for string;
    using Z5DKeyCount for uint256;
	

    string constant public name = "ZoMo5D";
    string constant public symbol = "Z5D";

   
    uint256 constant private rndInit_ = 24 hours;
    uint256 constant private rndInc_ = 30 seconds;              
    uint256 constant private rndMax_ = 24 hours;                
	uint256 constant private betPre_ = 5 days;     


	uint256 public BetTime;


	uint256 public airDropPot_;            
	uint256 public comm; 
	uint256 public lott;
	
    uint256 public rID_;    

	

	
    mapping (address => uint256) public pIDxAddr_;         
    mapping (bytes32 => uint256) public pIDxName_;         
    mapping (uint256 => Z5Ddatasets.Player) public plyr_;   
    mapping (uint256 => mapping (uint256 => Z5Ddatasets.PlayerRounds)) public plyrRnds_;    
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_; 
	
	uint256 public pID_;
	
	mapping (address => bool) internal team;


    mapping (uint256 => Z5Ddatasets.Round) public round_;  
    mapping (uint256 => uint256) public rndEth_;      
	mapping (uint256 => Z5Ddatasets.lotty) public Rndlotty;

	
	uint256 public lottrnd;
	
    uint256 public fees_;       
    uint256 public potSplit_;     

	
	ZoMo5DInterface private Z5DToken = ZoMo5DInterface(0x8b4f4872434DB00eB34B9420946534179249d676);
	
	
    constructor() public
    {
		
		
        fees_ = 59;  
     
        
        potSplit_ = 25;  
		
		plyr_[1].addr = 0xEAc1b04cBdd484244fC0dB0A8BEdA6212fFb32b1;
        plyr_[1].name = "zomo5d";
        pIDxAddr_[0xEAc1b04cBdd484244fC0dB0A8BEdA6212fFb32b1] = 1;
        pIDxName_["zomo5d"] = 1;
        plyrNames_[1]["zomo5d"] = true;
        pID_++;
        
  
		
		team[msg.sender] =true;
		team[0x13856bc546DbDE959F45cC863BbeBd40b5e8cCc2] = true;
		team[0xe418De1360a8e64de9468485F439B9174CE265a1] = true;
		team[0x654DC353AF41Cc83Ae99Bd7F4d4733f2948adCED] = true;
        team[0xEAc1b04cBdd484244fC0dB0A8BEdA6212fFb32b1] = true;
		team[0x78Ac79844328Ca4d652bCCC5f49ff7C43dC7c25d] = true;

		
    }    
	
	
	modifier onlyowner()
     {
         require(team[msg.sender]==true);
         _;
     }

    modifier isActivated() {
        require(activated_ == true, "not ready"); 
        _;
    }
    
    
    modifier NotContract() {
        address _addr = msg.sender;
        uint256 _codeLength;
        
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "contract is not accepted");
        _;
    }

    
    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 1000000000, "not a valid currency");
        _;    
    }
    
	
    function AirDistribute(uint256 _pID,uint256 amount_) onlyowner() public
	{
		require(amount_<=airDropPot_);
		airDropPot_ = airDropPot_.sub(amount_);
		plyr_[_pID].win = (plyr_[_pID].win).add(amount_);
		
	}
	
	
	
	
	function CommDistribute(uint256 _pID,uint256 amount_) onlyowner() public
	{
		require(amount_<=comm);
		comm = comm.sub(amount_);
		plyr_[_pID].win = (plyr_[_pID].win).add(amount_);
		
	}
	
	function lottDistribute(uint256 _pID,uint256 amount_,uint256 Lottround) onlyowner() public
	{
		
		require(amount_<=Rndlotty[Lottround].rndlott);
		Rndlotty[Lottround].rndlott = (Rndlotty[Lottround].rndlott).sub(amount_);
		plyr_[_pID].win = (plyr_[_pID].win).add(amount_);
		
	}
	
	
	function BetfromZ5D(uint256 amount_) isActivated() public
	{
		require(amount_>0,"amount_ should greater than 0");
		uint256 _pID = pIDxAddr_[msg.sender];
		require(_pID>0,"you should regist pid first");
		Z5DToken.AuthTransfer(msg.sender,amount_);
		plyr_[_pID].token = plyr_[_pID].token.add(amount_);
		BetCore(_pID,amount_);		
	}
	
	event BetTransfer(address indexed from, uint256 value, uint256 _round);
	
	function Betfromvault(uint256 amount_) isActivated() public
	{
	    
		require(amount_>0,"amount_ should greater than 0");
		uint256 _pID = pIDxAddr_[msg.sender];
		require(_pID>0,"you should regist pid first");
		updateGenVault(_pID, plyr_[_pID].lrnd);
		uint256 TokenAmount = plyr_[_pID].token ;
		
		require(TokenAmount>amount_,"you don't have enough token");		
		BetCore(_pID,amount_);	
	}

	function BetCore(uint256 _pID,uint256 amount_) private
	{
		//update last bet 
		updateBetVault(_pID);
		plyr_[_pID].bet = amount_.add(plyr_[_pID].bet);
		plyr_[_pID].token = plyr_[_pID].token.sub(amount_);
		plyr_[_pID].lrnd_lott = lottrnd;
		
		Rndlotty[lottrnd].rndToken = Rndlotty[lottrnd].rndToken.add(amount_);
		emit BetTransfer(plyr_[_pID].addr, amount_ , lottrnd);
	}
	
	
	function BetEnd() private
	{
		
		if 	(Rndlotty[lottrnd].rndToken > 0)
		{
			uint256 Betearn=lott.mul(3)/10;
		    Rndlotty[lottrnd].rndToken = Betearn/(Rndlotty[lottrnd].rndToken);
			Rndlotty[lottrnd].rndlott = lott.mul(5)/10;
		    lott = lott.sub(Rndlotty[lottrnd].rndlott).sub(Betearn);
			lottrnd++;
		}
		
		if (round_[rID_].pot > 1000000000000000000000)
		{
			uint256 fornext = (round_[rID_].pot).mul(5)/1000;
			round_[rID_].pot = (round_[rID_].pot).sub(fornext);
			lott = lott.add(fornext);
		}
		
		
	}
	
	function updateBetVault(uint256 _pID) private
	{
		uint256 _now = now;
		
		if (BetTime <_now)
		{	
			BetTime = _now + betPre_;
			BetEnd();	
		}
		
		uint256 lrnPlayed = plyr_[_pID].lrnd_lott;
		
		
		if (lrnPlayed>0 && lrnPlayed<lottrnd)
		{
		    uint256 lrnWin = (Rndlotty[lrnPlayed].rndToken).mul(plyr_[_pID].bet);
		    plyr_[_pID].bet = 0;
			plyr_[_pID].win = plyr_[_pID].win.add(lrnWin);
			plyr_[_pID].lrnd_lott = 0;
		}
		
	}
	
	
	
    function() isActivated() NotContract() isWithinLimits(msg.value) public payable
    {
       
        Z5Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
        uint256 _pID = pIDxAddr_[msg.sender];
        buyCore(_pID, plyr_[_pID].laff, _eventData_);
    }
    
    
	 function GrabName(string _nameString) isActivated() NotContract() public payable
	 {
		 bytes32 _name = _nameString.nameCheck();
		 
		 require(msg.value >= 10000000000000000, "not enouhgh for name registration");
		 uint256 _pID_name = pIDxName_[_name];
		 address  _addr = msg.sender;
		 uint256 _pID_add = pIDxAddr_[_addr];
		 
		 if (_pID_name!=0)
		 {
			require(plyrNames_[_pID_add][_name] ==true,"name had been registered");
		 }
		 
		 if (_pID_add == 0)
		 {
			 pID_++;
			 pIDxAddr_[_addr] = pID_;

			 plyr_[pID_].addr = _addr;
			 _pID_add = pID_;

		 }

		 pIDxName_[_name] = _pID_add;
		 plyr_[_pID_add].name = _name;
		 plyrNames_[_pID_add][_name] = true;
		 Z5DToken.deposit.value(msg.value)();

		 
		 
	 }

	 
    function buyXid(uint256 _affCode) isActivated() NotContract() isWithinLimits(msg.value) public payable
    {
        Z5Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
        
        uint256 _pID = pIDxAddr_[msg.sender];
        
        
        if (_affCode == 0 || _affCode == _pID)
        {

            _affCode = plyr_[_pID].laff;
       
        } else if (_affCode != plyr_[_pID].laff) {
            plyr_[_pID].laff = _affCode;
        }
 

        buyCore(_pID, _affCode, _eventData_);
    }
    
    function buyXaddr(address _affCode) isActivated() NotContract() isWithinLimits(msg.value) public payable
    {

        Z5Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
        

        uint256 _pID = pIDxAddr_[msg.sender];

        uint256 _affID;
        if (_affCode == address(0) || _affCode == msg.sender)
        {

            _affID = plyr_[_pID].laff;
        

        } else {
 
            _affID = pIDxAddr_[_affCode];
            if (_affID != plyr_[_pID].laff)
            {

                plyr_[_pID].laff = _affID;
            }
        }
        

        buyCore(_pID, _affID, _eventData_);
    }
    
    function buyXname(bytes32 _affCode) isActivated() NotContract() isWithinLimits(msg.value) public
        payable
    {
        
        Z5Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
        

        uint256 _pID = pIDxAddr_[msg.sender];
        
     
        uint256 _affID;

        if (_affCode == '' || _affCode == plyr_[_pID].name)
        {

            _affID = plyr_[_pID].laff;

        } else {

            _affID = pIDxName_[_affCode];
            
          
            if (_affID != plyr_[_pID].laff)
            {
        
                plyr_[_pID].laff = _affID;
            }
        }
        
   

        
    
        buyCore(_pID, _affID, _eventData_);
    }
    
   
   
   
    function reLoadXid(uint256 _affCode, uint256 _eth) isActivated() NotContract() isWithinLimits(_eth) public
    {
      
        Z5Ddatasets.EventReturns memory _eventData_;
        
       
        uint256 _pID = pIDxAddr_[msg.sender];
        
        
        if (_affCode == 0 || _affCode == _pID)
        {
            
            _affCode = plyr_[_pID].laff;
            
        
        } else if (_affCode != plyr_[_pID].laff) {
            
            plyr_[_pID].laff = _affCode;
        }



        reLoadCore(_pID, _affCode, _eth, _eventData_);
    }
    
    function reLoadXaddr(address _affCode, uint256 _eth)
        isActivated()
        NotContract()
        isWithinLimits(_eth)
        public
    {
   
        Z5Ddatasets.EventReturns memory _eventData_;
        
   
        uint256 _pID = pIDxAddr_[msg.sender];
        
      
        uint256 _affID;
       
        if (_affCode == address(0) || _affCode == msg.sender)
        {
            
            _affID = plyr_[_pID].laff;
        
         
        } else {
           
            _affID = pIDxAddr_[_affCode];
            
            
            if (_affID != plyr_[_pID].laff)
            {
               
                plyr_[_pID].laff = _affID;
            }
        }
        
        
        
        reLoadCore(_pID, _affID, _eth, _eventData_);
    }
    
    function reLoadXname(bytes32 _affCode, uint256 _eth) isActivated() NotContract() isWithinLimits(_eth) public
    {
       
        Z5Ddatasets.EventReturns memory _eventData_;
        
        
        uint256 _pID = pIDxAddr_[msg.sender];
        
        
        uint256 _affID;
        
        if (_affCode == '' || _affCode == plyr_[_pID].name)
        {
           
            _affID = plyr_[_pID].laff;
        
        
        } else {
           
            _affID = pIDxName_[_affCode];
            
            
            if (_affID != plyr_[_pID].laff)
            {
              
                plyr_[_pID].laff = _affID;
            }
        }
        

        

        reLoadCore(_pID, _affID, _eth, _eventData_);
    }

   
    function withdraw() isActivated() NotContract() public
    {
 
        uint256 _rID = rID_;

        uint256 _now = now;
        

		
        uint256 _pID = pIDxAddr_[msg.sender];
        

        uint256 _eth;
        uint256 token_temp;
		
 
        if (_now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
        {
          
            Z5Ddatasets.EventReturns memory _eventData_;
            
            
			round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);
            
			
            _eth = withdrawEarnings(_pID);


            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);
			
			token_temp = plyr_[_pID].token;
			if 	(token_temp > 0)
			{
				plyr_[_pID].token = 0;
				Z5DToken.transferTokensFromVault(plyr_[_pID].addr,token_temp);

			}
            
          
            emit Z5Devents.onWithdrawAndDistribute
            (
                msg.sender, 
                plyr_[_pID].name, 
                _eth, 
                _eventData_.winnerAddr, 
                _eventData_.winnerName, 
                _eventData_.amountWon, 
                _eventData_.newPot,  
                _eventData_.genAmount
            );
            
      
        } else {
          
            _eth = withdrawEarnings(_pID);


            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);
			
			token_temp = plyr_[_pID].token;
			if 	(token_temp > 0)
			{
				plyr_[_pID].token = 0;
				Z5DToken.transferTokensFromVault(plyr_[_pID].addr,token_temp);

			}
			
			
			
			
        
            emit Z5Devents.onWithdraw(_pID, msg.sender, plyr_[_pID].name, _eth, _now);
        }
    }
    

    function getBuyPrice() public view returns(uint256)
    {  
     
        uint256 _rID = rID_;
        
       
        uint256 _now = now;
        
        
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].keys.add(1000000000000000000)).ethRec(1000000000000000000) );
        else 
            return ( 75000000000000 );
    }
    
    
    function getTimeLeft() public view returns(uint256)
    {
       
        uint256 _rID = rID_;
        
       
        uint256 _now = now;
        
        if (_now < round_[_rID].end)
            if (_now > round_[_rID].strt)
                return( (round_[_rID].end).sub(_now) );
            else
                return( (round_[_rID].strt).sub(_now) );
        else
            return(0);
    }
    
    
    function getPlayerVaults(uint256 _pID) public view returns(uint256 ,uint256, uint256)
    {
     
        uint256 _rID = rID_;
        
        
        if (now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
        {
           
            if (round_[_rID].plyr == _pID)
            {
                return
                (
                    (plyr_[_pID].win).add( ((round_[_rID].pot).mul(50)) / 100 ),
                    (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)   ),
                    plyr_[_pID].aff
                );
           
            } 
			else if (round_[_rID].plyr_2nd == _pID)
			{
				return
                (
                    (plyr_[_pID].win).add( ((round_[_rID].pot).mul(10)) / 100 ),
                    (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)   ),
                    plyr_[_pID].aff
                );
				
			}
			else if (round_[_rID].plyr_3rd == _pID)
			{
				return
                (
                    (plyr_[_pID].win).add( ((round_[_rID].pot).mul(5)) / 100 ),
                    (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)   ),
                    plyr_[_pID].aff
                );
				
			}
			

			else {
                return
                (
                    plyr_[_pID].win,
                    (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)  ),
                    plyr_[_pID].aff
                );
            }
            
       
        } else {
            return
            (
                plyr_[_pID].win,
                (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),
                plyr_[_pID].aff
            );
        }
    }
    

    function getPlayerVaultsHelper(uint256 _pID, uint256 _rID) private view returns(uint256)
    {
        return(  ((((round_[_rID].mask).add(((((round_[_rID].pot).mul(potSplit_)) / 100).mul(1000000000000000000)) / (round_[_rID].keys))).mul(plyrRnds_[_pID][_rID].keys)) / 1000000000000000000)  );
    }
    

    function getCurrentRoundInfo() public view returns(uint256, uint256, uint256, uint256, uint256, uint256, address, bytes32, uint256)
    {
        
        uint256 _rID = rID_;
        return
        (
            _rID,                           //0
            round_[_rID].keys,              //1
            round_[_rID].end,               //2
            round_[_rID].strt,              //3
            round_[_rID].pot,               //4
            ((round_[_rID].plyr * 10)),     //5
            plyr_[round_[_rID].plyr].addr,  //6
            plyr_[round_[_rID].plyr].name,  //7
            rndEth_[_rID]                 //8
			
			
			
        );
    }


    function getPlayerInfoByAddress(address _addr) public view returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256)
    {


        
        if (_addr == address(0))
        {
            _addr == msg.sender;
        }
        uint256 _pID = pIDxAddr_[_addr];
        uint256 lrnWin =0;
		uint256 lrnPlayed = plyr_[_pID].lrnd_lott;
		if (lrnPlayed>0 && lrnPlayed<lottrnd)
		{
			lrnWin = (Rndlotty[lrnPlayed].rndToken).mul(plyr_[_pID].bet);
		}	
		
		
        return
        (
            _pID,                               //0
            plyr_[_pID].name,                   //1
            plyrRnds_[_pID][rID_].keys,         //2
            plyr_[_pID].win.add(lrnWin),        //3
            (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),       //4
            plyr_[_pID].aff,                    //5
            plyrRnds_[_pID][rID_].eth,           //6
			(plyr_[_pID].token).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)), 	 //7
			plyr_[_pID].bet,					//8
			plyr_[_pID].lrnd_lott				//9	
			
        );
    }


	 
    function buyCore(uint256 _pID, uint256 _affID, Z5Ddatasets.EventReturns memory _eventData_)
	private
    {
       
        uint256 _rID = rID_;
       
        uint256 _now = now;
        
        updateBetVault(_pID);
        
      
        if (_now > round_[_rID].strt&& (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0))) 
        {
            
            core(_rID, _pID, msg.value, _affID, _eventData_);
        
        
        } else {
            if (_now > round_[_rID].end && round_[_rID].ended == false) 
            {

			    round_[_rID].ended = true;
                _eventData_ = endRound(_eventData_);
                emit Z5Devents.onBuyAndDistribute
                (
                    msg.sender, 
                    plyr_[_pID].name, 
                    msg.value, 
                    _eventData_.winnerAddr, 
                    _eventData_.winnerName, 
                    _eventData_.amountWon, 
                    _eventData_.newPot,  
                    _eventData_.genAmount
                );
            }

            plyr_[_pID].gen = plyr_[_pID].gen.add(msg.value);
        }
    }
    

    function reLoadCore(uint256 _pID, uint256 _affID, uint256 _eth, Z5Ddatasets.EventReturns memory _eventData_) private
    {
     
        uint256 _rID = rID_;

        uint256 _now = now;
        
		updateBetVault(_pID);
		
		
        if (_now > round_[_rID].strt&& (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0))) 
        {
            
            plyr_[_pID].gen = withdrawEarnings(_pID).sub(_eth);
            
            core(_rID, _pID, _eth, _affID, _eventData_);
  
        } else if (_now > round_[_rID].end && round_[_rID].ended == false) {
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);
                

            emit Z5Devents.onReLoadAndDistribute
            (
                msg.sender, 
                plyr_[_pID].name, 
                _eventData_.winnerAddr, 
                _eventData_.winnerName, 
                _eventData_.amountWon, 
                _eventData_.newPot, 
                _eventData_.genAmount
            );
        }
    }
    
    
	
    function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, Z5Ddatasets.EventReturns memory _eventData_)
    private
    {
        if (plyrRnds_[_pID][_rID].keys == 0)
            _eventData_ = managePlayer(_pID, _eventData_);

        if (round_[_rID].eth < 100000000000000000000 && plyrRnds_[_pID][_rID].eth.add(_eth) > 1000000000000000000)
        {
            uint256 _availableLimit = (1000000000000000000).sub(plyrRnds_[_pID][_rID].eth);
            uint256 _refund = _eth.sub(_availableLimit);
            plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
            _eth = _availableLimit;
        }
		
        if (_eth > 1000000000) 
        {

            uint256 _keys = (round_[_rID].eth).keysRec(_eth);
			
            if (_keys >= 1000000000000000000)
            {
				updateTimer(_keys, _rID);
				if (round_[_rID].plyr != _pID)
				{	
					round_[_rID].plyr_3rd = round_[_rID].plyr_2nd;
					round_[_rID].plyr_2nd = round_[_rID].plyr;
					round_[_rID].plyr = _pID; 
				}	
          
        }

            plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);
            plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);
            
            round_[_rID].keys = _keys.add(round_[_rID].keys);
            round_[_rID].eth = _eth.add(round_[_rID].eth);
            rndEth_[_rID] = _eth.add(rndEth_[_rID]);

            _eventData_ = distributeExternal(_rID, _pID, _eth, _affID, _eventData_);
			
            _eventData_ = distributeInternal(_rID, _pID, _eth, _keys, _eventData_);

		    endTx(_pID, _eth, _keys, _eventData_);
        }
    }

	
    function calcUnMaskedEarnings(uint256 _pID, uint256 _rIDlast) private view returns(uint256)
    {
        return(  (((round_[_rIDlast].mask).mul(plyrRnds_[_pID][_rIDlast].keys)) / (1000000000000000000)).sub(plyrRnds_[_pID][_rIDlast].mask)  );
    }
    
	
    
    function calcKeysReceived(uint256 _rID, uint256 _eth)
        public
        view
        returns(uint256)
    {

        uint256 _now = now;

        if (_now > round_[_rID].strt&& (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].eth).keysRec(_eth) );
        else 
            return ( (_eth).keys() );
    }
    
   
    function iWantXKeys(uint256 _keys) public view returns(uint256)
    {

        uint256 _rID = rID_;

        uint256 _now = now;

        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].keys.add(_keys)).ethRec(_keys) );
        else 
            return ( (_keys).eth() );
    }


	 
	 
	 
	 
    function determinePID(Z5Ddatasets.EventReturns memory _eventData_)
        private
        returns (Z5Ddatasets.EventReturns)
    {
		
		address  _addr = msg.sender;

        if (pIDxAddr_[_addr] == 0)
        {

			pID_++;	
            pIDxAddr_[_addr] = pID_;
            plyr_[pID_].addr = _addr;
            

        } 
        return (_eventData_);
    }
    

   
    function managePlayer(uint256 _pID, Z5Ddatasets.EventReturns memory _eventData_) private returns (Z5Ddatasets.EventReturns)
    {
        
        if (plyr_[_pID].lrnd != 0)
            updateGenVault(_pID, plyr_[_pID].lrnd);

        plyr_[_pID].lrnd = rID_;
            
        
        return(_eventData_);
    }
    
   
    function endRound(Z5Ddatasets.EventReturns memory _eventData_) private returns (Z5Ddatasets.EventReturns)
    {

        uint256 _rID = rID_;
        
     
        uint256 _winPID = round_[_rID].plyr;
		uint256 _winPID_2nd = round_[_rID].plyr_2nd;
		uint256 _winPID_3rd = round_[_rID].plyr_3rd;
		
		if (_winPID_2nd == 0)
		{
			_winPID_2nd = 1;
		}
        
		if (_winPID_3rd == 0)
		{
			_winPID_3rd = 1;
		}

        uint256 _pot = round_[_rID].pot;
        


        uint256 _win = (_pot.mul(50)) / 100;
		
		
        uint256 _gen = (_pot.mul(potSplit_)) / 100;
        uint256 _res = (_pot.sub(_win.add(_win/5).add(_win/10))).sub(_gen);

        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        uint256 _dust = _gen.sub((_ppt.mul(round_[_rID].keys)) / 1000000000000000000);
        if (_dust > 0)
        {
            _gen = _gen.sub(_dust);
            _res = _res.add(_dust);
        }

        plyr_[_winPID].win = _win.add(plyr_[_winPID].win);
		plyr_[_winPID_2nd].win = (_win/5).add(plyr_[_winPID_2nd].win);
		plyr_[_winPID_3rd].win = (_win/10).add(plyr_[_winPID_3rd].win);

        round_[_rID].mask = _ppt.add(round_[_rID].mask);

        _eventData_.winnerAddr = plyr_[_winPID].addr;
        _eventData_.winnerName = plyr_[_winPID].name;
        _eventData_.amountWon = _win;
        _eventData_.genAmount = _gen;
        _eventData_.newPot = _res;

        rID_++;
        _rID++;
        round_[_rID].strt = now;
        round_[_rID].end = now.add(rndInit_);
        round_[_rID].pot = _res;
        
        return(_eventData_);
    }
    
    
    function updateGenVault(uint256 _pID, uint256 _rIDlast) private 
    {
        uint256 _earnings = calcUnMaskedEarnings(_pID, _rIDlast);
        if (_earnings > 0)
        {
            
            plyr_[_pID].gen = _earnings.add(plyr_[_pID].gen);
			plyr_[_pID].token = _earnings.add(plyr_[_pID].token);
            plyrRnds_[_pID][_rIDlast].mask = _earnings.add(plyrRnds_[_pID][_rIDlast].mask);
        }
    }
    
    
    function updateTimer(uint256 _keys, uint256 _rID)
        private
    {

        uint256 _now = now;

        uint256 _newTime;
        if (_now > round_[_rID].end && round_[_rID].plyr == 0)
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(_now);
        else
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(round_[_rID].end);
        
      
        if (_newTime < (rndMax_).add(_now))
            round_[_rID].end = _newTime;
        else
            round_[_rID].end = rndMax_.add(_now);
    }
    
    
    function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, Z5Ddatasets.EventReturns memory _eventData_) private returns(Z5Ddatasets.EventReturns)
    {

      
        uint256 z5dgame = (_eth / 100).mul(3);
        uint256 _aff = (_eth.mul(11))/100;
        if (_affID != _pID && plyr_[_affID].name != '') {
            plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
			plyr_[_affID].token = _aff.add(plyr_[_affID].token);
            emit Z5Devents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _aff, now);
        } 
		else
		{
			z5dgame = z5dgame.add(_aff);
		}
		
		plyr_[_pID].token = z5dgame.add(plyr_[_pID].token);
		Z5DToken.deposit.value(z5dgame)();
		
		

        return(_eventData_);
    }
    

    
   
    function distributeInternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _keys, Z5Ddatasets.EventReturns memory _eventData_)
      private returns(Z5Ddatasets.EventReturns)
    {
     
        uint256 _gen = (_eth.mul(fees_)) / 100;
    
        uint256 _air = _eth / 100;
		
		
		
        airDropPot_ = airDropPot_.add(_air);
		comm = comm.add(_air.mul(3));
		lott = lott.add(_air.mul(3));
        _eth = _eth.sub((_eth.mul(21)) / 100);     
        uint256 _pot = _eth.sub(_gen);

        uint256 _dust = updateMasks(_rID, _pID, _gen, _keys);
        if (_dust > 0)
            _gen = _gen.sub(_dust);
        
        
        round_[_rID].pot = _pot.add(_dust).add(round_[_rID].pot);
        

        _eventData_.genAmount = _gen.add(_eventData_.genAmount);
        _eventData_.potAmount = _pot;
        
        return(_eventData_);
    }

   
	
	
	
	
    function updateMasks(uint256 _rID, uint256 _pID, uint256 _gen, uint256 _keys) private returns(uint256)
    {

        
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        
		round_[_rID].mask = _ppt.add(round_[_rID].mask);
            
        
        uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);
        plyrRnds_[_pID][_rID].mask = (((round_[_rID].mask.mul(_keys)) / (1000000000000000000)).sub(_pearn)).add(plyrRnds_[_pID][_rID].mask);
        
        
        return(_gen.sub((_ppt.mul(round_[_rID].keys)) / (1000000000000000000)));
    }
    
    
	
	
	
    function withdrawEarnings(uint256 _pID) private returns(uint256)
    {

        updateGenVault(_pID, plyr_[_pID].lrnd);
		
		updateBetVault(_pID);
        

        uint256 _earnings = (plyr_[_pID].win).add(plyr_[_pID].gen).add(plyr_[_pID].aff);
		
		

        if (_earnings > 0)
        {
			
			plyr_[_pID].gen = 0;
            plyr_[_pID].win = 0;
            plyr_[_pID].aff = 0;
        }

        return(_earnings);
    }
    
    
    function endTx(uint256 _pID, uint256 _eth, uint256 _keys, Z5Ddatasets.EventReturns memory _eventData_) private
    {
  
        emit Z5Devents.onEndTx
        (

            plyr_[_pID].name,
            msg.sender,
            _eth,
            _keys,
            _eventData_.winnerAddr,
            _eventData_.winnerName,
            _eventData_.amountWon,
            _eventData_.newPot,
            _eventData_.genAmount,
            _eventData_.potAmount,
            airDropPot_,
			rID_
        );
    }

    bool public activated_ = false;
	
	function activate() onlyowner() public
    {

        require(activated_ == false, "already activated");
        
      
        activated_ = true;

		rID_ = 1;
        round_[1].strt = now ;
        round_[1].end = now + rndInit_;
		
		BetTime = round_[1].strt + betPre_;
		lottrnd = 1 ;
		
    }
	
	function claimsaleagent() public
    {
        Z5DToken.claimSalesAgent();
    }
    
}


interface ZoMo5DInterface 
{
	function transferTokensFromVault(address toAddress, uint256 tokensAmount) external;
	function claimSalesAgent() external;
	function deposit() external payable;
	function AuthTransfer(address from_, uint256 amount) external;
       
}



library Z5Ddatasets {

    struct EventReturns {
        address winnerAddr;         
        bytes32 winnerName;        
        uint256 amountWon;          
        uint256 newPot;            
        uint256 genAmount;         
        uint256 potAmount;          
    }
    struct Player {
        address addr;   
        bytes32 name;   
        uint256 win;    
        uint256 gen;   
        uint256 aff;    
        uint256 lrnd;  
        uint256 laff; 
		uint256 token;
		uint256 lrnd_lott;
		uint256 bet;
		
    }
    struct PlayerRounds {
        uint256 eth;    
        uint256 keys;   
        uint256 mask;  
    }
    struct Round {
        uint256 plyr;   	
		uint256 plyr_2nd;   
		uint256 plyr_3rd;	
        uint256 end;    	
        bool ended;     	
        uint256 strt;   	
        uint256 keys;   	
        uint256 eth;    	
        uint256 pot;    	
        uint256 mask;   	

    }
	
	struct lotty{
		uint256 rndToken;
		uint256 rndlott;
		
	}

}



library Z5DKeyCount {
    using SafeMath for *;

    function keysRec(uint256 _curEth, uint256 _newEth) internal pure returns (uint256)
    {	
	
        return(keys((_curEth).add(_newEth)).sub(keys(_curEth)));
    }
    

    function ethRec(uint256 _curKeys, uint256 _sellKeys) internal pure returns (uint256)
    {
        return((eth(_curKeys)).sub(eth(_curKeys.sub(_sellKeys))));
    }


    function keys(uint256 _eth) internal pure returns(uint256)
    {
		
		return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
	
    }
    
    
    function eth(uint256 _keys) 
        internal
        pure
        returns(uint256)  
    {
        return ((78125000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
    }
}




library NameCheck {
    
    function nameCheck(string _input) internal pure returns(bytes32)
    {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;

        require (_length <= 32 && _length > 0, "name is limited to 32 characters");
        
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "0x start is not allowed");
            require(_temp[1] != 0x58, "0X start is not allowed");
        }
        
        bool _hasNonNumber;
        
        for (uint256 i = 0; i < _length; i++)
        {
            
            if (_temp[i] > 0x40 && _temp[i] < 0x5b)
            {
                
                _temp[i] = byte(uint(_temp[i]) + 32);
				if (_hasNonNumber == false)
					_hasNonNumber = true;
            } 
			else 
			{
				
                require
                (
                    (_temp[i] > 0x60 && _temp[i] < 0x7b) ||(_temp[i] > 0x2f && _temp[i] < 0x3a)
                );
                
               
                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
                    _hasNonNumber = true;    
            }
        }
        
        require(_hasNonNumber == true, "only numbers is not allowed");
        
        bytes32 retrieve;
        assembly 
		{
            retrieve := mload(add(_temp, 32))
        }
        return (retrieve);
    }
}


library SafeMath {
    

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) 
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "Multiplication failed");
        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        require(b <= a, "Subtraction failed");
        return a - b;
    }


    function add(uint256 a, uint256 b) internal pure returns (uint256 c) 
    {
        c = a + b;
        require(c >= a, "add failed");
        return c;
    }
    

    function sqrt(uint256 x) internal pure returns (uint256 y) 
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y) 
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }

    function sq(uint256 x) internal pure returns (uint256)
    {
        return (mul(x,x));
    }
    

}