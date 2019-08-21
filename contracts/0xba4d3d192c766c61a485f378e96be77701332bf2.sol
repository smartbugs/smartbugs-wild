pragma solidity ^0.4.15;

contract P4PDonationSplitter {
    address public constant epicenter_works_addr = 0x883702a1b9B29119acBaaa0E7E0a2997FB8EBcd3;
    address public constant max_schrems_addr = 0x9abd6265Eaca022c1ccF931a7E9150dA0E7Db7Ec;

    /** Empty fallback function in order to allow receiving Ether
    Since internal send() (as used by P4PPool) has a budget of only 2300 gas -
    which is not enough to do anything useful - nothing is done here.
    */
    function () payable public {}

    /** Payout function
    Splits the funds currently hold by the contract between the two receivers.
    No access restriction to this function needed.
    The "payable" attribute is not needed, but doesn't harm -
    it allows to make additional donations in a single transaction.
    */
    function payout() payable public {
        var share = this.balance / 2;
        epicenter_works_addr.transfer(share);
        max_schrems_addr.transfer(share);
    }
}