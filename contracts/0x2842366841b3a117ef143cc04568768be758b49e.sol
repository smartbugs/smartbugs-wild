pragma solidity ^0.4.18;
/*
 * A good friend of mine has been fired from his job just before christmas, in December 2017.
 * Since then, he has been looking for a new job, but wasn't successful due to difficult state of
 * labor market in Czech Republic. This is just another one of my futile attempts to help him.
 *
 * If you have some spare Ethereum, please consider donating to help him in this difficult life situation
*/
contract Charity_For_My_Friend{
    address owner;
    
    function Charity_For_My_Friend() {
        owner = msg.sender;
    }
    
    function kill() {
        require(msg.sender == owner);
        selfdestruct(owner);
    }
    
    function () payable {}
}