pragma solidity ^0.5.0;
//import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';


contract zeroXWrapper {
    
    event forwarderCall (bool success);

    function zeroXSwap (address to, address forwarder, bytes memory args) public payable{
    	(bool success, bytes memory returnData) = forwarder.call.value(msg.value)(args);
    	emit forwarderCall(success);
    }

    function () external payable {
        
    }

}