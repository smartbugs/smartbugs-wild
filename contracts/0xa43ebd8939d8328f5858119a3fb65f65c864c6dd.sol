pragma solidity ^0.4.4;
/*
* This is a contract for debloating the state
* @author mhswende
**/
contract Sweeper
{
    //Solidity implentation
    function sol_clean(uint256 s, uint i){
        uint x = s;
        address b = 0;
        for(uint c=0 ; c < i ; c++){
            x = x+s;
            b = address(x/0x1000000000000000000000000);
            b.send(0);

        }
    }
    //Asm implementation
    function asm_clean(uint s, uint i)
    {

        assembly{
            let seed := calldataload(4)//4 if we're using a named function
            let iterations := calldataload(36)
            let target :=seed
        
        loop:
            target := add(target,seed)
            pop(call(0,div(target,0x1000000000000000000000000),0,0,0,0,0))
            iterations := sub(iterations,1) 
            jumpi(loop, iterations)
        }
    }
}