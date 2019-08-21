/*  
    Subscrypto
    Copyright (C) 2019 Subscrypto Team

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.5.2;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


contract Medianizer {
    function read() public view returns (bytes32);
}


contract Weth {
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => uint) public balanceOf;

    function transferFrom(address src, address dst, uint wad) public returns (bool);
}


/// @author The Subscrypto Team
/// @title Subscrypto recurring payments
contract Subscrypto {
    using SafeMath for uint;
    Medianizer public daiPriceContract;
    Weth public wethContract;

    /**
     * Constructor
     * @param daiMedianizerContract address
     * @param wethContractAddress address
     */
    constructor(address daiMedianizerContract, address wethContractAddress) public {
        daiPriceContract = Medianizer(daiMedianizerContract);
        wethContract = Weth(wethContractAddress);
    }

    event NewSubscription(
        address indexed subscriber,
        address indexed receiver,
        uint daiCents,
        uint32 interval
    );

    event Unsubscribe(
        address indexed subscriber, 
        address indexed receiver
    );

    event ReceiverPaymentsCollected(
        address indexed receiver,
        uint weiAmount,
        uint startIndex,
        uint endIndex
    );

    event SubscriptionPaid(
        address indexed subscriber,
        address indexed receiver,
        uint weiAmount,
        uint daiCents,
        uint48 effectiveTimestamp
    );

    event UnfundedPayment(
        address indexed subscriber,
        address indexed receiver,
        uint weiAmount,
        uint daiCents
    );

    event StaleSubscription(
        address indexed subscriber,
        address indexed receiver
    );

    event SubscriptionDeactivated(
        address indexed subscriber,
        address indexed receiver
    );

    event SubscriptionReactivated(
        address indexed subscriber,
        address indexed receiver
    );

    // Conservative amount of gas used per loop in executeDebits()
    uint constant MIN_GAS_PER_EXECUTE_DEBIT = 45000;
    // Force subscribers to use multiple accounts when this limit is reached.
    uint constant MAX_SUBSCRIPTION_PER_SUBSCRIBER = 10000;
    // Minimum payment of 1 DAI
    uint constant MIN_SUBSCRIPTION_DAI_CENTS = 100;

    struct Subscription {
        bool    isActive;        //  1 byte
        uint48  nextPaymentTime; //  6 bytes
        uint32  interval;        //  4 bytes
        address subscriber;      // 20 bytes
        address receiver;        // 20 bytes
        uint    daiCents;        // 32 bytes
    }

    // global counter for suscriptions
    uint64 nextIndex = 1;

    // source of truth for subscriptions
    mapping(uint64 => Subscription) public subscriptions;

    // subscriber => receiver => subsciptionIndex
    mapping(address => mapping(address => uint64)) public subscriberReceiver;

    // receiver => subs array
    mapping(address => uint64[]) public receiverSubs;

    // subscriber => subs array
    mapping(address => uint64[]) public subscriberSubs;

    /**
     * Create a new subscription. Must be called by the subscriber's account.
     * First payment of `daiCents` is paid on creation.
     * Actual payment is made in Wrapped Ether (wETH) using currenct DAI-ETH conversion rate.
     * @param receiver address
     * @param daiCents subscription amount in hundredths of DAI
     * @param interval seconds between payments
     */
    function subscribe(address receiver, uint daiCents, uint32 interval) external {
        uint weiAmount = daiCentsToEthWei(daiCents, ethPriceInDaiWad());
        uint64 existingIndex = subscriberReceiver[msg.sender][receiver];
        require(subscriptions[existingIndex].daiCents == 0, "Subscription exists");
        require(daiCents >= MIN_SUBSCRIPTION_DAI_CENTS, "Subsciption amount too low");
        require(interval >= 86400, "Interval must be at least 1 day");
        require(interval <= 31557600, "Interval must be at most 1 year");
        require(subscriberSubs[msg.sender].length < MAX_SUBSCRIPTION_PER_SUBSCRIBER,"Subscription count limit reached");

        // first payment
        require(wethContract.transferFrom(msg.sender, receiver, weiAmount), "wETH transferFrom() failed");

        // add to subscription mappings
        subscriptions[nextIndex] = Subscription(
            true,
            uint48(now.add(interval)),
            interval,
            msg.sender,
            receiver,
            daiCents
        );
        subscriberReceiver[msg.sender][receiver] = nextIndex;
        receiverSubs[receiver].push(nextIndex);
        subscriberSubs[msg.sender].push(nextIndex);

        emit NewSubscription(msg.sender, receiver, daiCents, interval);
        emit SubscriptionPaid(msg.sender, receiver, weiAmount, daiCents, uint48(now));

        nextIndex++;
    }
    
    /**
     * Deactivate a subscription. Must be called by the subscriber's account.
     * Payments cannot be collected from deactivated subscriptons.
     * @param receiver address used to identify the unique subscriber-receiver pair.
     * @return success
     */
    function deactivateSubscription(address receiver) external returns (bool) {
        uint64 index = subscriberReceiver[msg.sender][receiver];
        require(index != 0, "Subscription does not exist");

        Subscription storage sub = subscriptions[index];
        require(sub.isActive, "Subscription is already disabled");
        require(sub.daiCents > 0, "Subscription does not exist");

        sub.isActive = false;
        emit SubscriptionDeactivated(msg.sender, receiver);

        return true;
    }

    /**
     * Reactivate a subscription. Must be called by the subscriber's account.
     * If less than one interval has passed since the last payment, no payment is collected now.
     * Otherwise it is treated as a new subscription starting now, and the first payment is collected.
     * No back-payments are collected.
     * @param receiver addres used to identify the unique subscriber-receiver pair.
     * @return success
     */
    function reactivateSubscription(address receiver) external returns (bool) {
        uint64 index = subscriberReceiver[msg.sender][receiver];
        require(index != 0, "Subscription does not exist");

        Subscription storage sub = subscriptions[index];
        require(!sub.isActive, "Subscription is already active");

        sub.isActive = true;
        emit SubscriptionReactivated(msg.sender, receiver);

        if (calculateUnpaidIntervalsUntil(sub, now) > 0) {
            // only make a payment if at least one interval has lapsed since the last payment
            uint weiAmount = daiCentsToEthWei(sub.daiCents, ethPriceInDaiWad());
            require(wethContract.transferFrom(msg.sender, receiver, weiAmount), "Insufficient funds to reactivate subscription");
            emit SubscriptionPaid(msg.sender, receiver, weiAmount, sub.daiCents, uint48(now));
        }

        sub.nextPaymentTime = uint48(now.add(sub.interval));

        return true;
    }

    /**
     * Delete a subscription. Must be called by the subscriber's account.
     * @param receiver address used to identify the unique subscriber-receiver pair.
     */
    function unsubscribe(address receiver) external {
        uint64 index = subscriberReceiver[msg.sender][receiver];
        require(index != 0, "Subscription does not exist");
        delete subscriptions[index];
        delete subscriberReceiver[msg.sender][receiver];
        deleteElement(subscriberSubs[msg.sender], index);
        emit Unsubscribe(msg.sender, receiver);
    }

    /**
     * Delete a subscription. Must be called by the receiver's account.
     * @param subscriber address used to identify the unique subscriber-receiver pair.
     */
    function unsubscribeByReceiver(address subscriber) external {
        uint64 index = subscriberReceiver[subscriber][msg.sender];
        require(index != 0, "Subscription does not exist");
        delete subscriptions[index];
        delete subscriberReceiver[subscriber][msg.sender];
        deleteElement(subscriberSubs[subscriber], index);
        emit Unsubscribe(subscriber, msg.sender);
    }

    /**
     * Collect all available *funded* payments for a receiver's account.
     * Helper function that calls executeDebitsRange() with the full range.
     * Will process as many payments as possible with the gas provided and exit gracefully.
     * 
     * @param receiver address
     */
    function executeDebits(address receiver) external {
        executeDebitsRange(receiver, 0, receiverSubs[receiver].length);
    }

    /**
     * A read-only version of executeDebits()
     * Calculates uncollected *funded* payments for a receiver.
     * @param receiver address
     * @return total unclaimed value in wei
     */
    function getTotalUnclaimedPayments(address receiver) external view returns (uint) {
        uint totalPayment = 0;
        uint ethPriceWad = ethPriceInDaiWad();

        for (uint i = 0; i < receiverSubs[receiver].length; i++) {
            Subscription storage sub = subscriptions[receiverSubs[receiver][i]];

            if (sub.isActive && sub.daiCents != 0) {
                uint wholeUnpaidIntervals = calculateUnpaidIntervalsUntil(sub, now);
                if (wholeUnpaidIntervals > 0) {
                    uint weiAmount = daiCentsToEthWei(sub.daiCents, ethPriceWad);
                    uint authorizedBalance = allowedBalance(sub.subscriber);

                    do {
                        if (authorizedBalance >= weiAmount) {
                            totalPayment = totalPayment.add(weiAmount);
                            authorizedBalance = authorizedBalance.sub(weiAmount);
                        }
                        wholeUnpaidIntervals = wholeUnpaidIntervals.sub(1);
                    } while (wholeUnpaidIntervals > 0);
                }
            }
        }

        return totalPayment;
    }

    /**
     * Calculates a subscriber's total outstanding payments in daiCents
     * @param subscriber address
     * @param time in seconds. If `time` < `now`, then we simply use `now`
     * @return total amount owed at `time` in daiCents
     */
    function outstandingBalanceUntil(address subscriber, uint time) external view returns (uint) {
        uint until = time <= now ? now : time;

        uint64[] memory subs = subscriberSubs[subscriber];

        uint totalDaiCents = 0;
        for (uint64 i = 0; i < subs.length; i++) {
            Subscription memory sub = subscriptions[subs[i]];
            if (sub.isActive) {
                totalDaiCents = totalDaiCents.add(sub.daiCents.mul(calculateUnpaidIntervalsUntil(sub, until)));
            }
        }

        return totalDaiCents;
    }

    /**
     * Collect available *funded* payments for a receiver's account within a certain range of receiverSubs[receiver].
     * Will process as many payments as possible with the gas provided and exit gracefully.
     * 
     * @param receiver address
     * @param start starting index of receiverSubs[receiver]
     * @param end ending index of receiverSubs[receiver]
     * @return last processed index
     */
    function executeDebitsRange(address receiver, uint start, uint end) public returns (uint) {
        uint64[] storage subs = receiverSubs[receiver];
        require(subs.length > 0, "receiver has no subscriptions");
        require(start < end && end <= subs.length, "wrong arguments for range");
        uint totalPayment = 0;
        uint ethPriceWad = ethPriceInDaiWad();

        uint last = end;
        uint i = start;
        while (i < last) {
            if (gasleft() < MIN_GAS_PER_EXECUTE_DEBIT) {
                break;
            }
            Subscription storage sub = subscriptions[subs[i]];

            // delete empty subs
            while (sub.daiCents == 0 && subs.length > 0) {
                uint lastIndex = subs.length.sub(1);
                subs[i] = subs[lastIndex];
                delete(subs[lastIndex]);
                subs.length = lastIndex;
                if (last > lastIndex) {
                    last = lastIndex;
                }
                if (lastIndex > 0) {
                    sub = subscriptions[subs[i]];
                }
            }

            if (sub.isActive && sub.daiCents != 0) {
                uint wholeUnpaidIntervals = calculateUnpaidIntervalsUntil(sub, now);
                if (wholeUnpaidIntervals > 0) {
                    uint weiAmount = daiCentsToEthWei(sub.daiCents, ethPriceWad);
                    uint authorizedBalance = allowedBalance(sub.subscriber);

                    do {
                        if (authorizedBalance >= weiAmount) {
                            assert(wethContract.transferFrom(sub.subscriber, receiver, weiAmount));
                            sub.nextPaymentTime = calculateNextPaymentTime(sub);
                            totalPayment = totalPayment.add(weiAmount);
                            emit SubscriptionPaid(sub.subscriber, receiver, weiAmount, sub.daiCents, sub.nextPaymentTime);
                        } else {
                            emit UnfundedPayment(sub.subscriber, receiver, weiAmount, sub.daiCents);

                            if (wholeUnpaidIntervals >= 2) {
                                sub.isActive = false;
                                emit SubscriptionDeactivated(sub.subscriber, receiver);
                                emit StaleSubscription(sub.subscriber, receiver);
                                break;
                            }
                        }
                        wholeUnpaidIntervals = wholeUnpaidIntervals.sub(1);
                    } while (wholeUnpaidIntervals > 0);
                }
            }

            i++;
        }

        emit ReceiverPaymentsCollected(receiver, totalPayment, start, i);
        return i;
    }

    /**
     * Calculates how much wETH balance Subscrypto is authorized to use on bealf of `payer`.
     * Returns the minimum(payer's wETH balance, amount authorized to Subscrypto).
     * @param payer address
     * @return wad amount of wETH available for Subscrypto payments
     */
    function allowedBalance(address payer) public view returns (uint) {
        uint balance = wethContract.balanceOf(payer);
        uint allowance = wethContract.allowance(payer, address(this));

        return balance > allowance ? allowance : balance;
    }

    /**
     * Calls the DAI medianizer contract to get the current exchange rate for ETH-DAI
     * @return current ETH price in DAI (wad format)
     */
    function ethPriceInDaiWad() public view returns (uint) {
        uint price = uint(daiPriceContract.read());
        require(price > 1, "Invalid price for DAI.");
        return price;
    }

    /**
     * Helper function to search for and delete an array element without leaving a gap.
     * Array size is also decremented.
     * DO NOT USE if ordering is important.
     * @param array array to be modified
     * @param element value to be removed
     */
    function deleteElement(uint64[] storage array, uint64 element) internal {
        uint lastIndex = array.length.sub(1);
        for (uint i = 0; i < array.length; i++) {
            if (array[i] == element) {
                array[i] = array[lastIndex];
                delete(array[lastIndex]);
                array.length = lastIndex;
                break;
            }
        }
    }

    /**
     * Calculates how many whole unpaid intervals (will) have elapsed since the last payment at a specific `time`.
     * DOES NOT check if subscriber account is funded.
     * @param sub Subscription object
     * @param time timestamp in seconds
     * @return number of unpaid intervals
     */
    function calculateUnpaidIntervalsUntil(Subscription memory sub, uint time) internal view returns (uint) {
        require(time >= now, "don't use a time before now");

        if (time > sub.nextPaymentTime) {
            return ((time.sub(sub.nextPaymentTime)).div(sub.interval)).add(1);
        }

        return 0;
    }

    /**
     * Safely calculate the next payment timestamp for a Subscription
     * @param sub Subscription object
     * @return uint48 timestamp in seconds of the next payment
     */
    function calculateNextPaymentTime(Subscription memory sub) internal pure returns (uint48) {
        uint48 nextPaymentTime = sub.nextPaymentTime + sub.interval;
        assert(nextPaymentTime > sub.nextPaymentTime);
        return nextPaymentTime;
    }

    /**
     * Converts DAI (cents) to ETH (wei) without losing precision
     * @param daiCents one hundreth of a DAI
     * @param ethPriceWad price from calling ethPriceInDaiWad()
     * @return ETH value denominated in wei
     */
    function daiCentsToEthWei(uint daiCents, uint ethPriceWad) internal pure returns (uint) {
        return centsToWad(daiCents).mul(10**18).div(ethPriceWad);
    }

    /**
     * Converts amount in cents (hundredths of DAI) to amount in wad
     * @param cents daiCents (hundredths of DAI)
     * @return amount of dai in wad
     */
    function centsToWad(uint cents) internal pure returns (uint) {
        return cents.mul(10**16);
    }
}