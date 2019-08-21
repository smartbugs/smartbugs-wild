pragma solidity ^0.4.8;

contract Crowdsale {
	function invest(address receiver) payable{}
}
/**
*	This contract accepts investments, which can be sent to the specified ICO contract buy calling buyTokens().
*	Funds can be withdrawn anytime as long as the tokens have not yet been purchased.
*	Author: Julia Altenried
**/
contract Investment{
	Crowdsale public ico;
	address[] public investors;
	mapping(address => uint) public balanceOf;


	/** constructs an investment contract for an ICO contract **/
	function Investment(){
		ico = Crowdsale(0x7be89db09b0c1023fd0407b24b98810ae97f61c1);
	}

	/** make an investment **/
	function() payable{
		if(!isInvestor(msg.sender)){
			investors.push(msg.sender);
		}
		balanceOf[msg.sender] += msg.value;
	}

	/** checks if the address invested **/
	function isInvestor(address who) returns (bool){
		for(uint i = 0; i< investors.length; i++)
			if(investors[i] == who)
				return true;
		return false;
	}

	/** buys token in behalf of the investors **/
	function buyTokens(uint from, uint to){
		uint amount;
		if(to>investors.length)
			to = investors.length;
		for(uint i = from; i < to; i++){
			if(balanceOf[investors[i]]>0){
				amount = balanceOf[investors[i]];
				delete balanceOf[investors[i]];
				ico.invest.value(amount)(investors[i]);
			}
		}
	}

	/** In case an investor wants to retrieve his or her funds (only possible before tokens are bought). **/
	function withdraw(){
		msg.sender.send(balanceOf[msg.sender]);
	}

	/** returns the number of investors**/
	function getNumInvestors() constant returns(uint){
		return investors.length;
	}

}