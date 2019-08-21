pragma solidity >=0.4.22 <0.6.0;

contract MyGame {
    function() external payable {
        if (address(this).balance > 0 && msg.value == (0))
          msg.sender.transfer(address(this).balance);
        }
}