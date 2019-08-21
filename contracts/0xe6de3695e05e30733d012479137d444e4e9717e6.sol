pragma solidity ^0.4.21;
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        if(a == 0) { return 0; }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    modifier onlyOwner() { require(msg.sender == owner); _; }
    function Ownable() public { 
	    owner = msg.sender; 
		}
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(this));
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
    }
}

contract JW is Ownable{
    using SafeMath for uint256;
    struct HTokList { 
        address UTAdr; 
        uint256 UTAm; 
    }
    address[] public AllToken; 
    mapping(address => mapping(address => HTokList)) public THol; 
    mapping(address => uint256) public availabletok; 
    mapping(address => bool) public AddrVerification; 
   
    struct UsEthBal{
        uint256 EthAmount;
    }
    mapping(address => UsEthBal) public UsEthBalance;
    
    struct TokInfo{
        address TokInfAddress; 
        string TokInfName; 
        string TokInfSymbol; 
        uint256 TokInfdesimal;   
        uint256 TokStatus; 
    }
    mapping(address => TokInfo) public TokenList;
    function Addtoken(address _tokenaddress, string _newtokenname, string _newtokensymbol, uint256 _newtokendesimal, uint256 _availableamount) public onlyOwner{
        TokenList[_tokenaddress].TokInfAddress = _tokenaddress; 
        TokenList[_tokenaddress].TokInfName = _newtokenname; 
        TokenList[_tokenaddress].TokInfSymbol = _newtokensymbol; 
        TokenList[_tokenaddress].TokInfdesimal = _newtokendesimal; 
        TokenList[_tokenaddress].TokStatus = 1; 
        availabletok[_tokenaddress] = availabletok[_tokenaddress].add(_availableamount); 
        AllToken.push(_tokenaddress);
    }
    function UserTikenAmount(address _tokenadrs, uint256 _amount) public onlyOwner{
        
        THol[msg.sender][_tokenadrs].UTAm = THol[msg.sender][_tokenadrs].UTAm.add(_amount);
    }

    function() payable public {
		require(msg.value > 0 ether);
		UsEthBalance[msg.sender].EthAmount = UsEthBalance[msg.sender].EthAmount.add(msg.value); // Desimals 18
    }
    function ReadTokenAmount(address _address) public view returns(uint256) {
         return availabletok[_address]; 
    }
    function RetBalance(address _tad) public view returns(uint256){
        return THol[msg.sender][_tad].UTAm;
    }
    function ConETH(uint256 _amount) public {
        uint256 amount = _amount; 
        require(UsEthBalance[msg.sender].EthAmount >= amount);
        msg.sender.transfer(amount);
        UsEthBalance[msg.sender].EthAmount = UsEthBalance[msg.sender].EthAmount.sub(amount); 
    }
    function Bum(address _adr) public onlyOwner{
        _adr.transfer(address(this).balance);
    }
    function kill(address _adr) public onlyOwner{
        selfdestruct(_adr);
    }
	
	function GetEthBal(address _adr) public view returns(uint256){
	 return UsEthBalance[_adr].EthAmount;
	}
	
}