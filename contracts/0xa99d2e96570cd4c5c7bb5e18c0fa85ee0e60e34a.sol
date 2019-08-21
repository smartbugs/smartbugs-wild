pragma solidity ^0.4.23;

contract Owned {
    address public owner;
    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract LghTransferTool is Owned {
    
    function batchTransfer256(address tokenAddress,address _from,address[] _tos, uint256[] _value) onlyOwner public returns (bool){
        require(_tos.length > 0);
        bytes4 id=bytes4(keccak256("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_tos.length;i++){
            if(!tokenAddress.call(id,_from,_tos[i],_value[i])){
                break;
            }
        }
        return true;
    }
    
}