pragma solidity ^0.4.23;


/**  
@title Gas Refund Token
Allow any user to sponsor gas refunds for transfer and mints. Utilitzes the gas refund mechanism in EVM
Each time an non-empty storage slot is set to 0, evm refund 15,000 (19,000 after Constantinople) to the sender
of the transaction. 
*/
contract GasRefundToken  {
    uint256[] public gasRefundPool;
    
    function sponsorGas() external {
        uint256 len = gasRefundPool.length;
        uint256 refundPrice = 1;
        require(refundPrice > 0);
        gasRefundPool.length = len + 9;
        gasRefundPool[len] = refundPrice;
        gasRefundPool[len + 1] = refundPrice;
        gasRefundPool[len + 2] = refundPrice;
        gasRefundPool[len + 3] = refundPrice;
        gasRefundPool[len + 4] = refundPrice;
        gasRefundPool[len + 5] = refundPrice;
        gasRefundPool[len + 6] = refundPrice;
        gasRefundPool[len + 7] = refundPrice;
        gasRefundPool[len + 8] = refundPrice;
    }
    

    function minimumGasPriceForRefund() public view returns (uint256) {
        uint256 len = gasRefundPool.length;
        if (len > 0) {
          return gasRefundPool[len - 1] + 1;
        }
        return uint256(-1);
    }

    /**  
    @dev refund 45,000 gas for functions with gasRefund modifier.
    */
    function gasRefund() public {
        uint256 len = gasRefundPool.length;
        if (len > 2 && tx.gasprice > gasRefundPool[len-1]) {
            gasRefundPool[--len] = 0;
            gasRefundPool[--len] = 0;
            gasRefundPool[--len] = 0;
            gasRefundPool.length = len;
        }   
    }
    

    /**  
    *@dev Return the remaining sponsored gas slots
    */
    function remainingGasRefundPool() public view returns (uint) {
        return gasRefundPool.length;
    }

    function remainingSponsoredTransactions() public view returns (uint) {
        return gasRefundPool.length / 3;
    }
}