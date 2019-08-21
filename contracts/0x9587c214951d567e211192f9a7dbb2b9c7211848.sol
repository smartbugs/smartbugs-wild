pragma solidity ^0.5.3;

contract TokenERC20 {
    mapping (address => uint256) public balanceOf;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public;
}
contract multiSend{
    address public baseAddr = 0x500Df47E1dF0ef06039218dCF0960253D89D6658;
	TokenERC20 bcontract = TokenERC20(baseAddr);
    event cannotAirdrop(address indexed addr, uint balance);
    
    function() external payable { 
        revert();
    }
    
    function sendOutToken(address[10] memory addrs) public {
        for(uint i=0;i<10;i++){
            if(addrs[i] == address(0)) continue;
            if(bcontract.balanceOf(addrs[i]) >0) emit cannotAirdrop(addrs[i],bcontract.balanceOf(addrs[i]));
            else bcontract.transferFrom(msg.sender,addrs[i],100);
        }
    }
}