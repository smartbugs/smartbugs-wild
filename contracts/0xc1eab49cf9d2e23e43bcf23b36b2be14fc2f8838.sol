pragma solidity 0.4.24;
pragma experimental "v0.5.0";
/******************************************************************************\
*..................................Mokens......................................*
*.....................General purpose cryptocollectibles.......................*
*..............................................................................*
/******************************************************************************/

/******************************************************************************\
* Author: Nick Mudge, nick@mokens.io
* Copyright (c) 2018
* Mokens
*
* The Mokens contract is a proxy contract that delegates all functionality
* to delegate contracts. This design enables new functionality and improvements
* to be added to the Mokens contract over time.
*
* Changes to the Mokens contract are transparent and visible. To make changes
* easier to monitor the ContractUpdated event is emitted any time a function is
* added, removed or updated. The ContractUpdated event exists in the
* MokenUpdates delegate contract
*
* The source code for all delegate contracts used by the Mokens contract can be
* found online and inspected.
*
* The Mokens contract is reflective or self inspecting. It contains functions
* for inspecting what delegate contracts it has and what functions they have.
* Specifically, the QueryMokenDelegates delegate contract contains functions for
* querying delegate contracts and functions.
*
*    Here are some of the other delegate contracts:
*
*  - MokenERC721: Implements the ERC721 standard for mokens.
*  - MokenERC721Batch: Implements batch transfers and approvals.
*  - MokenERC998ERC721TopDown: Implements ERC998 composable functionality.
*  - MokenERC998ERC20TopDown: Implements ERC998 composable functionality.
*  - MokenERC998ERC721BottomUp: Implements ERC998 composable functionality.
*  - MokenMinting: Implements moken minting functionality.
*  - MokenEras: Implements moken era functionality.
*  - QueryMokenData: Implements functions to query info about mokens.
/******************************************************************************/
//////////////////////////////////////
//////////////////////////////////////
contract Storage0 {
    // funcId => delegate contract
    mapping(bytes4 => address) internal delegates;
}

contract Mokens is Storage0 {
    constructor(address mokenUpdates) public {
        //0x584fc325 == "initializeMokensContract()"
        bytes memory calldata = abi.encodeWithSelector(0x584fc325,mokenUpdates);
        assembly {
            let callSuccess := delegatecall(gas, mokenUpdates, add(calldata, 0x20), mload(calldata), 0, 0)
            let size := returndatasize
            returndatacopy(calldata, 0, size)
            if eq(callSuccess,0) {revert(calldata, size)}
        }
    }
    function() external payable {
        address delegate = delegates[msg.sig];
        require(delegate != address(0), "Mokens function does not exist.");
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, delegate, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)
            switch result
            case 0 {revert(ptr, size)}
            default {return (ptr, size)}
        }
    }
}