/**+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                            abcLotto: a Block Chain Lottery

                            Don't trust anyone but the CODE!
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
 /*
 * This product is protected under license.  Any unauthorized copy, modification, or use without 
 * express written consent from the creators is prohibited.
 */
/*
    address resolver for resolve contracts interract.
    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    depoly on:
    1) mainnet 
        owner:      0x15ebb02F39563675Fd255d34b8c03650373A8F0F
        address:    0xde4413799c73a356d83ace2dc9055957c0a5c335
    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/
pragma solidity ^0.4.20;

contract abcResolver {
    address owner;
    address lotto;
    address controller;
    address wallet;
    address inviterBook;
    address[10] alternate;

    //modifier
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() public{
        owner = msg.sender;
    }

    function setNewOwner(address newOwner) public onlyOwner{
        require(newOwner != address(0x0));
        owner = newOwner;
    }

    function getOwner() public view returns (address){
        return owner;
    }

    function getAddress() public view returns (address) {
        return lotto;
    }

    function setAddress(address newAddr) public onlyOwner{
        require(newAddr != address(0x0));
        lotto = newAddr;
    }

    function getControllerAddress() public view returns (address) {
        return controller;
    }

    function setControllerAddress(address newAddr) public onlyOwner{
        require(newAddr != address(0x0));
        controller = newAddr;
    }

    function getWalletAddress() public view returns (address) {
        return wallet;
    }

    function setWalletAddress(address newAddr) public onlyOwner{
        require(newAddr != address(0x0));
        wallet = newAddr;
    }

    function getBookAddress() public view returns (address) {
        return inviterBook;
    }

    function setBookAddress(address newAddr) public onlyOwner{
        require(newAddr != address(0x0));
        inviterBook = newAddr;
    }    

    function getAlternate(uint index) public view returns (address){
        return alternate[index];
    }

    function setAlternate(uint index, address newAddr) public onlyOwner{
        require(index>=0 && index<10);
        require(newAddr != address(0x0));
        alternate[index] = newAddr;
    }
}