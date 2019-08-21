/**
 * SimpleRegistrar lets you claim a subdomain name for yourself and configure it
 * all in one step. This one is deployed at registrar.gimmethe.eth.
 * 
 * To use it, simply call register() with the name you want and the appropriate
 * fee (initially 0.01 ether, but adjustable over time; call fee() to get the
 * current price). For example, in a web3 console:
 * 
 *     var simpleRegistrarContract = web3.eth.contract([{"constant":true,"inputs":[],"name":"fee","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"name","type":"string"}],"name":"register","outputs":[],"payable":true,"type":"function"}]);
 *     var simpleRegistrar = simpleRegistrarContract.at("0x1bebbc372772817d5d11a06ee2a4eba33ab6ee65");
 *     simpleRegistrar.register('myname', {from: accounts[0], value: simpleRegistrar.fee(), gas: 150000});
 * 
 * SimpleRegistrar will take care of everything: registering your subdomain,
 * setting up a resolver, and pointing that resolver at the account that called
 * it.
 * 
 * Funds received from running this service are reinvested into building new
 * ENS tools and utilities.
 * 
 * Note that the Deed owning gimmethe.eth is not currently in a holding
 * contract, so I could theoretically change the registrar at any time. This is
 * a temporary measure, as it may be necessary to replace this contract with an
 * updated one as ENS best practices change. You have only my word that I will
 * never interfere with a properly registered subdomain of gimmethe.eth.
 * 
 * Author: Nick Johnson <nick@arachnidlabs.com>
 * Copyright 2017, Nick Johnson
 * Licensed under the Apache Public License, version 2.0.
 */
pragma solidity ^0.4.10;

contract AbstractENS {
    function owner(bytes32 node) constant returns(address);
    function resolver(bytes32 node) constant returns(address);
    function ttl(bytes32 node) constant returns(uint64);
    function setOwner(bytes32 node, address owner);
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner);
    function setResolver(bytes32 node, address resolver);
    function setTTL(bytes32 node, uint64 ttl);
}

contract owned {
    address owner;
    
    function owned() {
        owner = msg.sender;
    }
    
    modifier owner_only() {
        if(msg.sender != owner) throw;
        _;
    }
    
    function setOwner(address _owner) owner_only {
        owner = _owner;
    }
}

contract Resolver {
    function setAddr(bytes32 node, address addr);
}

contract ReverseRegistrar {
    function claim(address owner) returns (bytes32 node);
}

contract SimpleRegistrar is owned {
    // namehash('addr.reverse')
    bytes32 constant RR_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

    event HashRegistered(bytes32 indexed hash, address indexed owner);

    AbstractENS public ens;
    bytes32 public rootNode;
    uint public fee;
    // Temporary until we have a public address for it
    Resolver public resolver;
    
    function SimpleRegistrar(AbstractENS _ens, bytes32 _rootNode, uint _fee, Resolver _resolver) {
        ens = _ens;
        rootNode = _rootNode;
        fee = _fee;
        resolver = _resolver;
        
        // Assign reverse record to sender
        ReverseRegistrar(ens.owner(RR_NODE)).claim(msg.sender);
    }
    
    function withdraw() owner_only {
        if(!msg.sender.send(this.balance)) throw;
    }
    
    function setFee(uint _fee) owner_only {
        fee = _fee;
    }
    
    function setResolver(Resolver _resolver) owner_only {
        resolver = _resolver;
    }
    
    modifier can_register(bytes32 label) {
        if(ens.owner(sha3(rootNode, label)) != 0 || msg.value < fee) throw;
        _;
    }
    
    function register(string name) payable can_register(sha3(name)) {
        var label = sha3(name);
        
        // First register the name to ourselves
        ens.setSubnodeOwner(rootNode, label, this);
        
        // Now set a resolver up
        var node = sha3(rootNode, label);
        ens.setResolver(node, resolver);
        resolver.setAddr(node, msg.sender);
        
        // Now transfer ownership to the user
        ens.setOwner(node, msg.sender);
        
        HashRegistered(label, msg.sender);
        
        // Send any excess ether back
        if(msg.value > fee) {
            if(!msg.sender.send(msg.value - fee)) throw;
        }
    }
}