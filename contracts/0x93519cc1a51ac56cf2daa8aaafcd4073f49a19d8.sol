pragma solidity ^0.4.11;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}






/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        if (a != 0 && c / a != b) revert();
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        if (b > a) revert();
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        if (c < a) revert();
        return c;
    }
}



/*
 * !!!IMPORTANT!!!
 * Based on Open Zeppelin Refund Vault contract
 * https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/crowdsale/RefundVault.sol
 * the only thing that differs is a hardcoded wallet address
 */

/**
 * @title RefundVault.
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if crowdsale fails,
 * and forwarding it if crowdsale is successful.
 */
contract VLBRefundVault is Ownable {
    using SafeMath for uint256;

    enum State {Active, Refunding, Closed}
    State public state;

    mapping (address => uint256) public deposited;

    address public constant wallet = 0x02D408bc203921646ECA69b555524DF3c7f3a8d7;

    address crowdsaleContractAddress;

    event Closed();
    event RefundsEnabled();
    event Refunded(address indexed beneficiary, uint256 weiAmount);

    function VLBRefundVault() {
        state = State.Active;
    }

    modifier onlyCrowdsaleContract() {
        require(msg.sender == crowdsaleContractAddress);
        _;
    }

    function setCrowdsaleAddress(address _crowdsaleAddress) external onlyOwner {
        require(_crowdsaleAddress != address(0));
        crowdsaleContractAddress = _crowdsaleAddress;
    }

    function deposit(address investor) onlyCrowdsaleContract external payable {
        require(state == State.Active);
        deposited[investor] = deposited[investor].add(msg.value);
    }

    function close(address _wingsWallet) onlyCrowdsaleContract external {
        require(_wingsWallet != address(0));
        require(state == State.Active);
        state = State.Closed;
        Closed();
        uint256 wingsReward = this.balance.div(100);
        _wingsWallet.transfer(wingsReward);
        wallet.transfer(this.balance);
    }

    function enableRefunds() onlyCrowdsaleContract external {
        require(state == State.Active);
        state = State.Refunding;
        RefundsEnabled();
    }

    function refund(address investor) public {
        require(state == State.Refunding);
        uint256 depositedValue = deposited[investor];
        deposited[investor] = 0;
        investor.transfer(depositedValue);
        Refunded(investor, depositedValue);
    }

    /**
     * @dev killer method that can bu used by owner to
     *      kill the contract and send funds to owner
     */
    function kill() onlyOwner {
        require(state == State.Closed);
        selfdestruct(owner);
    }
}