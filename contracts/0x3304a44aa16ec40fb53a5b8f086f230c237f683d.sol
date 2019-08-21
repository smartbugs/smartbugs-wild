/**
 * Copyright (C) 2017-2018 Hashfuture Inc. All rights reserved.
 */


pragma solidity ^0.4.19;

contract owned {
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

contract mall is owned {

    /* Struct for one commodity */
    struct Commodity {
        uint commodityId;            // Unique id for a commodity
        uint seedBlock;         // Block number whose hash as random seed
        string MD5;         // MD5 of full content
    }

    uint commodityNum;
    /* This notes all commodities and a map from commodityId to commodityIdx */
    mapping(uint => Commodity) commodities;
    mapping(uint => uint) indexMap;

    /** constructor */
    constructor() public {
        commodityNum = 1;
    }

    /**
     * Initialize a new Commodity
     */
    function newCommodity(uint commodityId, uint seedBlock, string MD5) onlyOwner public returns (uint commodityIndex) {
        require(indexMap[commodityId] == 0);             // commodityId should be unique
        commodityIndex = commodityNum++;
        indexMap[commodityId] = commodityIndex;
        commodities[commodityIndex] = Commodity(commodityId, seedBlock, MD5);
    }

    /**
     * Get commodity info by index
     * Only can be called by newOwner
     */
    function getCommodityInfoByIndex(uint commodityIndex) onlyOwner public view returns (uint commodityId, uint seedBlock, string MD5) {
        require(commodityIndex < commodityNum);               // should exist
        require(commodityIndex >= 1);                    // should exist
        commodityId = commodities[commodityIndex].commodityId;
        seedBlock = commodities[commodityIndex].seedBlock;
        MD5 = commodities[commodityIndex].MD5;
    }

    /**
     * Get commodity info by commodity id
     * Only can be called by newOwner
     */
    function getCommodityInfoById(uint commodityId) public view returns (uint commodityIndex, uint seedBlock, string MD5) {
        commodityIndex = indexMap[commodityId];
        require(commodityIndex < commodityNum);              // should exist
        require(commodityIndex >= 1);                   // should exist
        seedBlock = commodities[commodityIndex].seedBlock;
        MD5 = commodities[commodityIndex].MD5;
    }

    /**
     * Get the number of commodities
     */
    function getCommodityNum() onlyOwner public view returns (uint num) {
        num = commodityNum - 1;
    }
}