pragma solidity ^0.4.11;

contract token { function preallocate(address receiver, uint fullTokens, uint weiPrice) public;
                function transferOwnership(address _newOwner) public;
                function acceptOwnership() public;
                }
contract Airdrop {
    token public tokenReward;
    
    function Airdrop(token _addressOfTokenUsedAsTransfer) public{
         tokenReward = token(_addressOfTokenUsedAsTransfer);
    }

   /* TransferToken function for send token to many accound
        @param _to address array hold the receiver address
        @param _value send token value 
        @param weiPrice Price of a single full token in wei
   */

    function TransferToken (address[] _to, uint _value, uint _weiPrice) public
    {   for (uint i=0; i< _to.length; i++)
        {
        tokenReward.preallocate(_to[i], _value, _weiPrice);
        }
    }

    /* TransferOwner function for Transfer the owner ship to address
        @param _owner address of owner
    */


    function TransferOwner (address _owner) public {
        tokenReward.transferOwnership(_owner);
    }

    /* 
        acceptOwner function for accept owner ship of account
    */

    function acceptOwner () public {
        tokenReward.acceptOwnership();
    }

    /* 
        removeContract function for destroy the contract on network
    */

    function removeContract() public
        {
            selfdestruct(msg.sender);
            
        }   
}