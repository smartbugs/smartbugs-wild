pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



library SafeERC20Detailed {

    function safeDecimals(address token) internal returns (uint256 decimals) {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSignature("decimals()"));

        if (!success) {
            (success, data) = address(token).call(abi.encodeWithSignature("Decimals()"));
        }

        if (!success) {
            (success, data) = address(token).call(abi.encodeWithSignature("DECIMALS()"));
        }

        if (!success) {
            return 18;
        }

        assembly {
            decimals := mload(add(data, 32))
        }
    }

    function safeSymbol(address token) internal returns(bytes32 symbol) {

        (bool success, bytes memory data) = token.call(abi.encodeWithSignature("symbol()"));

        if (!success) {
            (success, data) = token.call(abi.encodeWithSignature("Symbol()"));
        }

        if (!success) {
            (success, data) = token.call(abi.encodeWithSignature("SYMBOL()"));
        }

        if (!success) {
            return 0;
        }

        uint256 dataLength = data.length;
        assembly {
            symbol := mload(add(data, dataLength))
        }
    }
}



contract Approved {

    using SafeERC20Detailed for address;

    function allowances(
        address source,
        address[] calldata tokens,
        address[] calldata spenders
    )
        external
        returns(
            uint256[] memory results,
            uint256[] memory decimals,
            bytes32[] memory symbols
        )
    {
        require(tokens.length == spenders.length, "Invalid argument array lengths");

        results = new uint256[](tokens.length);
        decimals = new uint256[](tokens.length);
        symbols = new bytes32[](tokens.length);

        for (uint i = 0; i < tokens.length; i++) {

            results[i] = IERC20(tokens[i]).allowance(source, spenders[i]);
            decimals[i] = tokens[i].safeDecimals();
            symbols[i] = tokens[i].safeSymbol();
        }
    }
}
