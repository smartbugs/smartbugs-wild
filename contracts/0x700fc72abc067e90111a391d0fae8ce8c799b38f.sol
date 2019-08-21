pragma solidity ^0.4.18;

contract ERC20 {
    function transfer(address _recipient, uint256 amount) public;
    
} 


contract MultiTransfer {
    
    address[] public Airdrop2;
        
        
    function multiTransfer(ERC20 token, address[] Airdrop2, uint256 amount) public {
        for (uint256 i = 0; i < Airdrop2.length; i++) {
            token.transfer( Airdrop2[i], amount * 10 ** 18);
        }
    }
}