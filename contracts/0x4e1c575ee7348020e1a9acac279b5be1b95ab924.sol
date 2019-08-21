pragma solidity 0.4.24;

// File: contracts/interfaces/VaultI.sol

interface VaultI {
    function deposit(address contributor) external payable;
    function saleSuccessful() external;
    function enableRefunds() external;
    function refund(address contributor) external;
    function close() external;
    function sendFundsToWallet() external;
}

// File: contracts/Refunder.sol

/**
 * @title Refunder
 * @dev This contract is used when sale has had its refunds enabled,
 *      and ETH needs to be refunded to each sale contributor.
 */
contract Refunder {

    /// @dev Called to refund ETH
    /// @dev The array of contributors should not have an address that has already
    ///      been refunded otherwise it will revert. So the contributors array
    ///      should be checked offchain before being sent to this function
    /// @param _vault Address of the interface for the sale to use
    /// @param _contributors Array of contributors for which eth will be refunded
    function refundContribution(VaultI _vault, address[] _contributors)
        external
    {
        for (uint256 i = 0; i < _contributors.length; i++) {
            address contributor = _contributors[i];
            _vault.refund(contributor);
        }
    }
}