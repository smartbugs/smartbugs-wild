pragma solidity >=0.4.22;

/*
* Hello world!
*/

contract SendMeBeer {
    address payable myAddress = 0xE52497FCA47cA80F6eAa161A80c0FAd247DDb457;
    function () external payable {
        myAddress.transfer(msg.value);
    }
    function getAddress() public view returns(address) {
        return myAddress;
    }
}