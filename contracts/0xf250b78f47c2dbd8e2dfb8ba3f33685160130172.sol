pragma solidity ^0.5.0;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract Whitelisting is Ownable {
    mapping(address => bool) public isInvestorApproved;
    mapping(address => bool) public isInvestorPaymentApproved;

    event Approved(address indexed investor);
    event Disapproved(address indexed investor);

    event PaymentApproved(address indexed investor);
    event PaymentDisapproved(address indexed investor);


    //Token distribution approval (KYC results)
    function approveInvestor(address toApprove) public onlyOwner {
        isInvestorApproved[toApprove] = true;
        emit Approved(toApprove);
    }

    function approveInvestorsInBulk(address[] calldata toApprove) external onlyOwner {
        for (uint i=0; i<toApprove.length; i++) {
            isInvestorApproved[toApprove[i]] = true;
            emit Approved(toApprove[i]);
        }
    }

    function disapproveInvestor(address toDisapprove) public onlyOwner {
        delete isInvestorApproved[toDisapprove];
        emit Disapproved(toDisapprove);
    }

    function disapproveInvestorsInBulk(address[] calldata toDisapprove) external onlyOwner {
        for (uint i=0; i<toDisapprove.length; i++) {
            delete isInvestorApproved[toDisapprove[i]];
            emit Disapproved(toDisapprove[i]);
        }
    }

    //Investor payment approval (For private sale)
    function approveInvestorPayment(address toApprove) public onlyOwner {
        isInvestorPaymentApproved[toApprove] = true;
        emit PaymentApproved(toApprove);
    }

    function approveInvestorsPaymentInBulk(address[] calldata toApprove) external onlyOwner {
        for (uint i=0; i<toApprove.length; i++) {
            isInvestorPaymentApproved[toApprove[i]] = true;
            emit PaymentApproved(toApprove[i]);
        }
    }

    function disapproveInvestorapproveInvestorPayment(address toDisapprove) public onlyOwner {
        delete isInvestorPaymentApproved[toDisapprove];
        emit PaymentDisapproved(toDisapprove);
    }

    function disapproveInvestorsPaymentInBulk(address[] calldata toDisapprove) external onlyOwner {
        for (uint i=0; i<toDisapprove.length; i++) {
            delete isInvestorPaymentApproved[toDisapprove[i]];
            emit PaymentDisapproved(toDisapprove[i]);
        }
    }

}