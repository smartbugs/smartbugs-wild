pragma solidity ^0.4.18;

contract owned {
	address public owner;
	address public server;

	function owned() {
		owner = msg.sender;
		server = msg.sender;
	}

	function changeOwner(address newOwner) onlyOwner {
		owner = newOwner;
	}

	function changeServer(address newServer) onlyOwner {
		server = newServer;
	}

	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

	modifier onlyServer {
		require(msg.sender == server);
		_;
	}
}


contract Utils {

	function Utils() {
	}

	// Validates an address - currently only checks that it isn't null
	modifier validAddress(address _address) {
		require(_address != 0x0);
		_;
	}
}

contract Crowdsale is owned,Utils {
    
    //*** Pre-sale ***//
    uint preSaleStart=1513771200;
    uint preSaleEnd=1515585600;
    uint256 preSaleTotalTokens=30000000;
    uint256 preSaleTokenCost=6000;
    address preSaleAddress;
    
     //*** ICO ***//
    uint icoStart;
    uint256 icoSaleTotalTokens=400000000;
    address icoAddress;
    
    //*** Advisers,Consultants ***//
    uint256 advisersConsultantTokens=15000000;
    address advisersConsultantsAddress;
    
    //*** Bounty ***//
    uint256 bountyTokens=15000000;
    address bountyAddress=0xD53E82Aea770feED8e57433D3D61674caEC1D1Be;
    
    //*** Founders ***//
    uint256 founderTokens=40000000;
    address founderAddress;
    
    //***Balance***//
    mapping (address => uint256) public balanceOf;
    
    //*** Tranfer ***//
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    //*** GraphenePowerCrowdsale ***//
    function GraphenePowerCrowdsale(){
        balanceOf[this]=500000000;
        preSaleAddress=0xC07850969A0EC345A84289f9C5bb5F979f27110f;
        icoAddress=0x1C21Cf57BF4e2dd28883eE68C03a9725056D29F1;
        advisersConsultantsAddress=0xe8B6dA1B801b7F57e3061C1c53a011b31C9315C7;
        bountyAddress=0xD53E82Aea770feED8e57433D3D61674caEC1D1Be;
        founderAddress=0xDA0D3Dad39165EA2d7386f18F96664Ee2e9FD8db;
    }
    
    //*** Start ico ***//
    function startIco() onlyOwner internal{
        icoStart=now;
    }
    
    //*** Is ico closed ***//
    function isIcoClosed() constant returns (bool closed) {
		return ((icoStart+(35*24*60*60)) >= now);
	}
    
    //*** Is preSale closed ***//
    function isPreSaleClosed() constant returns (bool closed) {
		return (preSaleEnd >= now);
	}
	
	//*** Get Bounty Tokens ***//
	function getBountyTokens() onlyOwner{
	    require(bountyTokens>0);
	    payment(bountyAddress,bountyTokens);
	    bountyTokens=0;
	}
	
	//*** Get Founders Tokens ***//
	function getFoundersTokens() onlyOwner{
	    require(founderTokens>0);
	    payment(founderAddress,founderTokens);
	    founderTokens=0;
	}
	
	//*** Get Advisers,Consultants Tokens ***//
	function getAdvisersConsultantsTokens() onlyOwner{
	    require(advisersConsultantTokens>0);
	    payment(advisersConsultantsAddress,advisersConsultantTokens);
	    advisersConsultantTokens=0;
	}
	
	//*** Payment ***//
    function payment(address _from,uint256 _tokens) internal{
        if(balanceOf[this] > _tokens){
            balanceOf[msg.sender] += _tokens;
            balanceOf[this] -= _tokens;
            Transfer(this, _from, _tokens);
        }
    }
    
    //*** Payable ***//
    function() payable {
        require(msg.value>0);
        
        if(!isPreSaleClosed()){
            uint256 tokensPreSale = preSaleTotalTokens * msg.value / 1000000000000000000;
            require(preSaleTotalTokens >= tokensPreSale);
            payment(msg.sender,tokensPreSale);
        }
        else if(!isIcoClosed()){
             if((icoStart+(7*24*60*60)) >= now){
                 uint256 tokensWeek1 = 4000 * msg.value / 1000000000000000000;
                 require(icoSaleTotalTokens >= tokensWeek1);
                 payment(msg.sender,tokensWeek1);
                 icoSaleTotalTokens-=tokensWeek1;
            }
            else if((icoStart+(14*24*60*60)) >= now){
                 uint256 tokensWeek2 = 3750 * msg.value / 1000000000000000000;
                 require(icoSaleTotalTokens >= tokensWeek2);
                 payment(msg.sender,tokensWeek2);
                 icoSaleTotalTokens-=tokensWeek2;
            }
            else if((icoStart+(21*24*60*60)) >= now){
                 uint256 tokensWeek3 = 3500 * msg.value / 1000000000000000000;
                 require(icoSaleTotalTokens >= tokensWeek3);
                 payment(msg.sender,tokensWeek3);
                 icoSaleTotalTokens-=tokensWeek3;
            }
            else if((icoStart+(28*24*60*60)) >= now){
                 uint256 tokensWeek4 = 3250 * msg.value / 1000000000000000000;
                 require(icoSaleTotalTokens >= tokensWeek4);
                 payment(msg.sender,tokensWeek4);
                 icoSaleTotalTokens-=tokensWeek4;
            }
            else if((icoStart+(35*24*60*60)) >= now){
                 uint256 tokensWeek5 = 3000 * msg.value / 1000000000000000000;
                 require(icoSaleTotalTokens >= tokensWeek5);
                 payment(msg.sender, tokensWeek5);
                 icoSaleTotalTokens-=tokensWeek5;
            }
        }
	}
}

contract GraphenePowerToken is Crowdsale {
    
    /* Public variables of the token */
	string public standard = 'Token 0.1';

	string public name = 'Graphene Power';

	string public symbol = 'GRP';

	uint8 public decimals = 18;

	uint256 _totalSupply =500000000;

	/* This creates an array with all balances */
	mapping (address => uint256) balances;

	/* This generates a public event on the blockchain that will notify clients */
	event Transfer(address from, address to, uint256 value);

    bool transfersEnable=false;
    
	//*** Total Supply ***//
	function totalSupply() constant returns (uint256 totalSupply) {
		totalSupply = _totalSupply;
	}
	
	/*** Send coins ***/
	function transfer(address _to, uint256 _value) returns (bool success) {
		if (transfersEnable) {
	       require(balanceOf[msg.sender] >= _value);
           balanceOf[msg.sender] -= _value;
           balanceOf[_to] += _value;
           Transfer(msg.sender, _to, _value);
		   return true;
		}
      	else{
	           return false;
	        }
	}
	
	//*** Transfer Enabled ***//
	function transfersEnabled() onlyOwner{
	    require(!transfersEnable);
	    transfersEnable=true;
	}
}