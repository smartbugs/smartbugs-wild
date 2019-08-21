pragma solidity ^0.4.18;

contract ERC20 {
  function balanceOf(address _owner) public constant returns (uint balance);
  function transfer(address _to, uint _value) public returns (bool success);
}

contract TokenTrust {
	address public owner;
	uint256 start;
	mapping(address=>uint256) public trust;
	event AddTrust(address indexed _token, uint256 indexed _trust);
	modifier onlyOwner() {
      if (msg.sender!=owner) revert();
      _;
    }
    
    function TokenTrust() public {
    	owner = msg.sender;
    	start = block.number;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
    
    function getStart() public constant returns(uint256) {
        return start;
    }
    
    function getTokenTrust(address tadr) public constant returns(uint256) {
        return trust[tadr];
    }
    
    function withdrawTokens(address tadr, uint256 tokens) public onlyOwner  {
        if (tokens==0 || ERC20(tadr).balanceOf(address(this))<tokens) revert();
        trust[tadr]+=1;
        AddTrust(tadr,trust[tadr]);
        ERC20(tadr).transfer(owner, tokens);
    }
    
    function addTokenTrust(address tadr) public payable {
        if (msg.value==0 || tadr==address(0) || ERC20(tadr).balanceOf(msg.sender)==0) revert();
        trust[tadr]+=1;
        AddTrust(tadr,trust[tadr]);
        owner.transfer(msg.value);
    }
    
    function () payable public {
        if (msg.value>0) owner.transfer(msg.value);
    }
}