pragma solidity ^0.4.0;


contract caller {

    function caller() public {
    }

    function delegate_2x(address callee, uint256[] uints,address[] addresses,bytes32[] b) public {
      
        if (callee.delegatecall(bytes4(keccak256("x(address,uint256,address,uint256,bytes32,bytes32)")),
          addresses[0],
          uints[0],
          addresses[2],
          uints[2],
          b[0],
          b[2]
          )) {
        (callee.delegatecall(bytes4(keccak256("x(address,uint256,address,uint256,bytes32,bytes32)")),
           addresses[1],
           uints[1],
           addresses[3],
           uints[3],
           b[1],
           b[3]
           ));
          }
    }
    
     function testcall(address callee)  public {
        bytes32[] memory b = new bytes32[](4);
        address[] memory addrs = new address[](6);
        uint256[] memory ints = new uint256[](12);
        bytes32 somebytes;
        ints[0]=1;
        ints[1]=2;
        ints[2]=3;
        ints[3]=4;
        b[0]=somebytes;
        b[1]=somebytes;
        b[2]=somebytes;
        b[3]=somebytes;
        addrs[0]=0xdc04977a2078c8ffdf086d618d1f961b6c54111;
        addrs[1]=0xdc04977a2078c8ffdf086d618d1f961b6c54222;
        addrs[2]=0xdc04977a2078c8ffdf086d618d1f961b6c54333;
        addrs[3]=0xdc04977a2078c8ffdf086d618d1f961b6c54444;

        delegate_2x(callee, ints, addrs,b);
    }
    
}