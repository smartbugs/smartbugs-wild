pragma solidity ^0.4.25;

/**
 * Math operations with safety checks that throw on overflows.
 */
library SafeMath {

    function mul (uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b);
        return c;
    }
    
    function div (uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }
    
    function sub (uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add (uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
        return c;
    }

}

contract ERC20TokenInterface {

    function totalSupply () external constant returns (uint);
    function balanceOf (address tokenOwner) external constant returns (uint balance);
    function transfer (address to, uint tokens) external returns (bool success);
    function transferFrom (address from, address to, uint tokens) external returns (bool success);

}

/**
 * @title Team Vesting
 * You can check how many tokens you can withdraw from this smart contract by calling
 * `releasableAmount` function. If you want to withdraw these tokens, create a transaction
 * to a `release` function, specifying your account address as an argument.
 */
contract PermanentTeamVesting {

    using SafeMath for uint256;

    event Released(address beneficiary, uint256 amount);

    struct Beneficiary {
        uint256 start;
        uint256 duration;
        uint256 cliff;
        uint256 totalAmount;
        uint256 releasedAmount;
    }

    mapping (address => Beneficiary) public beneficiary;
    ERC20TokenInterface public token;

    modifier isVestedAccount (address account) { require(beneficiary[account].start != 0); _; }
    modifier isNotVestedAccount (address account) { require(beneficiary[account].start == 0); _; }

    /**
    * Token vesting.
    */
    constructor (ERC20TokenInterface tokenAddress) public {
        require(tokenAddress != address(0));
        token = tokenAddress;
    }

    /**
    * Calculates the releaseable amount of tokens at the current time.
    * @param account Vested account
    * @return Amount in decimals
    */
    function releasableAmount (address account) public view returns (uint256) {
        return vestedAmount(account).sub(beneficiary[account].releasedAmount);
    }

    /**
    * @notice Transfers available vested tokens to the beneficiary.
    * @param account Beneficiary account.
    */
    function release (address account) public isVestedAccount(account) {
        uint256 unreleased = releasableAmount(account);
        require(unreleased > 0);
        beneficiary[account].releasedAmount = beneficiary[account].releasedAmount.add(unreleased);
        token.transfer(account, unreleased);
        emit Released(account, unreleased);
        if (beneficiary[account].releasedAmount == beneficiary[account].totalAmount) { // When done, clean beneficiary info
            delete beneficiary[account];
        }
    }

    /**
     * Allows to vest tokens for beneficiary.
     */
    function addBeneficiary (
        address account,
        uint256 start,
        uint256 duration,
        uint256 cliff,
        uint256 amount
    ) public isNotVestedAccount(account) {
        require(amount != 0 && account != 0x0 && cliff < duration && beneficiary[account].start == 0);
        require(token.transferFrom(msg.sender, address(this), amount));
        beneficiary[account] = Beneficiary({
            start: start,
            duration: duration,
            cliff: start.add(cliff),
            totalAmount: amount,
            releasedAmount: 0
        });
    }

    /**
    * @dev Calculates the amount that has already vested.
    * @param account Vested account
    * @return Amount in decimals
    */
    function vestedAmount (address account) private view returns (uint256) {
        if (block.timestamp < beneficiary[account].cliff) {
            return 0;
        } else if (block.timestamp >= beneficiary[account].start.add(beneficiary[account].duration)) {
            return beneficiary[account].totalAmount;
        } else {
            return beneficiary[account].totalAmount.mul(
                block.timestamp.sub(beneficiary[account].start)
            ).div(beneficiary[account].duration);
        }
    }

}