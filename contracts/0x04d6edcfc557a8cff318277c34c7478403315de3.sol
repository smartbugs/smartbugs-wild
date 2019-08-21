pragma solidity 0.5.9;


/**
 * https://rekt.fyi
 *
 * Mock the performance of your friend's ETH stack by sending them a REKT token, and add a bounty to it.
 *
 * REKT tokens are non-transferrable. Holders can only burn the token and collect the bounty once their
 * ETH balance is m times higher or their ETH is worth m times more in USD than when they received the
 * token, where m is a multiplier value set by users.
 *
 * copyright 2019 rekt.fyi
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


/**
 * Libraries
 */

/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

library DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

/**
 * External Contracts
 */

contract Medianizer {
    function peek() public view returns (bytes32, bool) {}
}

contract Dai {
     function transferFrom(address src, address dst, uint wad) public returns (bool) {}
}


/**
 * Contracts
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
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
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}


/**
 * @title https://rekt.fyi
 * @notice Mock the performance of your friend's ETH stack by sending them a REKT token, and add a bounty to it.
 *
 * REKT tokens are non-transferrable. Holders can only burn the token and collect the bounty once their
 * ETH balance is m times higher or their ETH is worth m times more in USD than when they received the
 * token, where m is a multiplier value set by users.
 */
contract RektFyi is Ownable {

    using DSMath for uint;

    /**
     * Storage
     */

    struct Receiver {
        uint walletBalance;
        uint bountyETH;
        uint bountyDAI;
        uint timestamp;
        uint etherPrice;
        address payable sender;
    }

    struct Vault {
        uint fee;
        uint bountyETH;
        uint bountySAI; // DAI bounty sent here before the switch to MCD
        uint bountyDAI; // DAI bounty sent here after the switch to MCD
    }

    struct Pot {
        uint ETH;
        uint DAI;
    }


    mapping(address => Receiver) public receiver;
    mapping(address => uint) public balance;
    mapping(address => address[]) private recipients;
    mapping(address => Pot) public unredeemedBounty;
    mapping(address => Vault) public vault;
    Pot public bountyPot = Pot(0,0);
    uint public feePot = 0;

    bool public shutdown = false;
    uint public totalSupply = 0;
    uint public multiplier = 1300000000000000000; // 1.3x to start
    uint public bumpBasePrice = 10000000000000000; // 0.01 ETH
    uint public holdTimeCeiling = 3628800; // 6 weeks in seconds

    address public medianizerAddress;
    Medianizer oracle;

    bool public isMCD = false;
    uint public MCDswitchTimestamp = 0;
    address public saiAddress;
    address public daiAddress;

    Dai dai;
    Dai sai;


    constructor(address _medianizerAddress, address _saiAddress) public {
        medianizerAddress = _medianizerAddress;
        oracle = Medianizer(medianizerAddress);

        saiAddress = _saiAddress;
        dai = Dai(saiAddress);
        sai = dai;
    }


    /**
     * Constants
     */

    string public constant name = "REKT.fyi";
    string public constant symbol = "REKT";
    uint8 public constant decimals = 0;

    uint public constant WAD = 1000000000000000000;
    uint public constant PRECISION = 100000000000000; // 4 orders of magnitude / decimal places
    uint public constant MULTIPLIER_FLOOR = 1000000000000000000; // 1x
    uint public constant MULTIPLIER_CEILING = 10000000000000000000; // 10x
    uint public constant BONUS_FLOOR = 1250000000000000000; //1.25x 
    uint public constant BONUS_CEILING = 1800000000000000000; //1.8x
    uint public constant BOUNTY_BONUS_MINIMUM = 5000000000000000000; // $5
    uint public constant HOLD_SCORE_CEILING = 1000000000000000000000000000; // 1 RAY
    uint public constant BUMP_INCREMENT = 100000000000000000; // 0.1x
    uint public constant HOLD_TIME_MAX = 23670000; // 9 months is the maximum the owner can set with setHoldTimeCeiling(uint)
    uint public constant BUMP_PRICE_MAX = 100000000000000000; //0.1 ETH is the maximum the owner can set with setBumpPrice(uint)


    /**
     * Events
     */

    event LogVaultDeposit(address indexed addr, string indexed potType, uint value);
    event LogWithdraw(address indexed to, uint eth, uint sai, uint dai);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event LogBump(uint indexed from, uint indexed to, uint cost, address indexed by);
    event LogBurn(
        address indexed sender,
        address indexed receiver,
        uint receivedAt,
        uint multiplier,
        uint initialETH,
        uint etherPrice,
        uint bountyETH,
        uint bountyDAI,
        uint reward
        );
    event LogGive(address indexed sender, address indexed receiver);


    /**
     * Modifiers
     */

    modifier shutdownNotActive() {
        require(shutdown == false, "shutdown activated");
        _;
    }


    modifier giveRequirementsMet(address _to) {
        require(address(_to) != address(0), "Invalid address");
        require(_to != msg.sender, "Cannot give to yourself");
        require(balanceOf(_to) == 0, "Receiver already has a token");
        require(_to.balance > 0, "Receiver wallet must not be empty");
        _;
    }


    /**
     * External functions
     */

    /// @notice Give somebody a REKT token, along with an optional bounty in ether.
    /// @param _to The address to send the REKT token to.
    function give(address _to) external payable shutdownNotActive giveRequirementsMet(_to) {
        if (msg.value > 0) {
            unredeemedBounty[msg.sender].ETH = unredeemedBounty[msg.sender].ETH.add(msg.value);
            bountyPot.ETH = bountyPot.ETH.add(msg.value);
        }
        receiver[_to] = Receiver(_to.balance, msg.value, 0, now, getPrice(), msg.sender);
        giveCommon(_to);
    }


    /// @notice Give somebody a REKT token, along with an option bounty in DAI.
    /// @param _to The account to send the REKT token to.
    /// @param _amount The amount of DAI to use as a bounty.
    function giveWithDAI(address _to, uint _amount) external shutdownNotActive giveRequirementsMet(_to) {
        if (_amount > 0) {
            // If the switch has already been included in this block then MCD is active,
            // but we won't be able to tell later if that's the case so block this tx.
            // Its ok for the mcd switch to occur later than this function in the same block
            require(MCDswitchTimestamp != now, "Cannot send DAI during the switching block");
            require(dai.transferFrom(msg.sender, address(this), _amount), "DAI transfer failed");
            unredeemedBounty[msg.sender].DAI = unredeemedBounty[msg.sender].DAI.add(_amount);
            bountyPot.DAI = bountyPot.DAI.add(_amount);
        }
        receiver[_to] = Receiver(_to.balance, 0, _amount, now, getPrice(), msg.sender);
        giveCommon(_to);
    }


    /// @notice Bump the multiplier up or down.
    /// @dev Multiplier has PRECISION precision and is rounded down unless the unrounded
    /// value hits the MULTIPLIER_CEILING or MULTIPLIER_FLOOR.
    /// @param _up Boolean representing whether the direction of the bump is up or not.
    function bump(bool _up) external payable shutdownNotActive {
        require(msg.value > 0, "Ether required");
        uint initialMultiplier = multiplier;

        // amount = (value/price)*bonus*increment
        uint bumpAmount = msg.value
            .wdiv(bumpBasePrice)
            .wmul(getBonusMultiplier(msg.sender))
            .wmul(BUMP_INCREMENT);

        if (_up) {
            if (multiplier.add(bumpAmount) >= MULTIPLIER_CEILING) {
                multiplier = MULTIPLIER_CEILING;
            } else {
                multiplier = multiplier.add(roundBumpAmount(bumpAmount));
            }
        }
        else {
            if (multiplier > bumpAmount) {
                if (multiplier.sub(bumpAmount) <= MULTIPLIER_FLOOR) {
                    multiplier = MULTIPLIER_FLOOR;
                } else {
                    multiplier = multiplier.sub(roundBumpAmount(bumpAmount));
                }
            }
            else {
                multiplier = MULTIPLIER_FLOOR;
            }
        }

        emit LogBump(initialMultiplier, multiplier, msg.value, msg.sender);
        feePot = feePot.add(msg.value);
    }


    /// @notice Burn a REKT token. If applicable, fee reward and bounty are sent to user's pots.
    /// REKT tokens can only be burned if the receiver has made gains >= the multiplier
    /// (unless we are in shutdown mode).
    /// @param _receiver The account that currently holds the REKT token.
    function burn(address _receiver) external {
        require(balanceOf(_receiver) == 1, "Nothing to burn");
        address sender = receiver[_receiver].sender;
        require(
            msg.sender == _receiver ||
            msg.sender == sender ||
            (_receiver == address(this) && msg.sender == owner),
            "Must be token sender or receiver, or must be the owner burning REKT sent to the contract"
            );

        if (!shutdown) {
            if (receiver[_receiver].walletBalance.wmul(multiplier) > _receiver.balance) {
                uint balanceValueThen = receiver[_receiver].walletBalance.wmul(receiver[_receiver].etherPrice);
                uint balanceValueNow = _receiver.balance.wmul(getPrice());
                if (balanceValueThen.wmul(multiplier) > balanceValueNow) {
                    revert("Not enough gains");
                }
            }
        }

        balance[_receiver] = 0;
        totalSupply --;
        
        emit Transfer(_receiver, address(0), 1);

        uint feeReward = distributeBurnRewards(_receiver, sender);

        emit LogBurn(
            sender,
            _receiver,
            receiver[_receiver].timestamp,
            multiplier,
            receiver[_receiver].walletBalance,
            receiver[_receiver].etherPrice,
            receiver[_receiver].bountyETH,
            receiver[_receiver].bountyDAI,
            feeReward);
    }


    /// @notice Withdrawal of fee reward, DAI, SAI & ETH bounties for the user.
    /// @param _addr The account to receive the funds and whose vault the funds will be taken from.
    function withdraw(address payable _addr) external {
        require(_addr != address(this), "This contract cannot withdraw to itself");
        withdrawCommon(_addr, _addr);
    }


    /// @notice Withdraw from the contract's personal vault should anyone send
    /// REKT to REKT.fyi with a bounty.
    /// @param _destination The account to receive the funds.
    function withdrawSelf(address payable _destination) external onlyOwner {
        withdrawCommon(_destination, address(this));
    }


    /// @dev Sets a new Medianizer address in case of MakerDAO upgrades.
    /// @param _addr The new address.
    function setNewMedianizer(address _addr) external onlyOwner {
        require(address(_addr) != address(0), "Invalid address");
        medianizerAddress = _addr;
        oracle = Medianizer(medianizerAddress);
        bytes32 price;
        bool ok;
        (price, ok) = oracle.peek();
        require(ok, "Pricefeed error");
    }


    /// @notice Sets a new DAI token address when MakerDAO upgrades to multicollateral DAI.
    /// @dev DAI will now be deposited into vault[user].bountyDAI for new bounties instead
    /// of vault[user].bountySAI.
    /// If setMCD(address) has been included in the block already, then a user will
    /// not be able to give a SAI/DAI bounty later in this block.
    /// We can then determine with certainty whether they sent SAI or DAI when the time
    /// comes to distribute it to a user's vault.
    /// New DAI token can only be set once;
    /// further changes will require shutdown and redeployment.
    /// @param _addr The new address.
    function setMCD(address _addr) external onlyOwner {
        require(!isMCD, "MCD has already been set");
        require(address(_addr) != address(0), "Invalid address");
        daiAddress = _addr;
        dai = Dai(daiAddress);
        isMCD = true;
        MCDswitchTimestamp = now;
    }


    /// @dev Sets a new bump price up to BUMP_PRICE_MAX.
    /// @param _amount The base price of bumping by BUMP_INCREMENT.
    function setBumpPrice(uint _amount) external onlyOwner {
        require(_amount > 0 && _amount <= BUMP_PRICE_MAX, "Price must not be higher than BUMP_PRICE_MAX");
        bumpBasePrice = _amount;
    }


    /// @dev Sets a new hold time ceiling up to HOLD_TIME_MAX.
    /// @param _seconds The maximum hold time in seconds before the holdscore becomes 1 RAY.
    function setHoldTimeCeiling(uint _seconds) external onlyOwner {
        require(_seconds > 0 && _seconds <= HOLD_TIME_MAX, "Hold time must not be higher than HOLD_TIME_MAX");
        holdTimeCeiling = _seconds;
    }
    

    /// @dev Permanent shutdown of the contract.
    /// No one can give or bump, everyone can burn and withdraw.
    function setShutdown() external onlyOwner {
        shutdown = true;
    }


    /**
     * Public functions
     */

    /// @dev The proportion of the value of this bounty in relation to
    /// the value of all bounties in the system.
    /// @param _bounty This bounty.
    /// @return A uint representing the proportion of bounty as a RAY.
    function calculateBountyProportion(uint _bounty) public view returns (uint) {
        return _bounty.rdiv(potValue(bountyPot.DAI, bountyPot.ETH));
    }


    /// @dev A score <= 1 RAY that corresponds to a duration between 0 and HOLD_SCORE_CEILING.
    /// @params _receivedAtTime The timestamp of the block where the user received the REKT token.
    /// @return A uint representing the score as a RAY.
    function calculateHoldScore(uint _receivedAtTime) public view returns (uint) {
        if (now == _receivedAtTime)
        {
            return 0;
        }
        uint timeDiff = now.sub(_receivedAtTime);
        uint holdScore = timeDiff.rdiv(holdTimeCeiling);
        if (holdScore > HOLD_SCORE_CEILING) {
            holdScore = HOLD_SCORE_CEILING;
        }
        return holdScore;
    }


    /// @notice Returns the REKT balance of the specified address.
    /// @dev Effectively a bool because the balance can only be 0 or 1.
    /// @param _owner The address to query the balance of.
    /// @return A uint representing the amount owned by the passed address.
    function balanceOf(address _receiver) public view returns (uint) {
        return balance[_receiver];
    }


    /// @notice Returns the total value of _dai and _eth in USD. 1 DAI = $1 is assumed.
    /// @dev Price of ether taken from MakerDAO's Medianizer via getPrice().
    /// @param _dai DAI to use in calculation.
    /// @param _eth Ether to use in calculation.
    /// @return A uint representing the total value of the inputs.
    function potValue(uint _dai, uint _eth) public view returns (uint) {
        return _dai.add(_eth.wmul(getPrice()));
    }


    /// @dev Returns the bonus multiplier represented as a WAD.
    /// @param _sender The address of the sender.
    /// @return A uint representing the bonus multiplier as a WAD.
    function getBonusMultiplier(address _sender) public view returns (uint) {
        uint bounty = potValue(unredeemedBounty[_sender].DAI, unredeemedBounty[_sender].ETH);
        uint bonus = WAD;
        if (bounty >= BOUNTY_BONUS_MINIMUM) {
            bonus = bounty.wdiv(potValue(bountyPot.DAI, bountyPot.ETH)).add(BONUS_FLOOR);
            if (bonus > BONUS_CEILING) {
                bonus = BONUS_CEILING;
            }
        }
        return bonus;
    }


    /// @dev Returns the addresses the sender has sent to as an array.
    /// @param _sender The address of the sender.
    /// @return An array of recipient addresses.
    function getRecipients(address _sender) public view returns (address[] memory) {
        return recipients[_sender];
    }


    /// @dev Returns the price of ETH in USD as per the MakerDAO Medianizer interface.
    /// @return A uint representing the price of ETH in USD as a WAD.
    function getPrice() public view returns (uint) {
        bytes32 price;
        bool ok;
        (price, ok) = oracle.peek();
        require(ok, "Pricefeed error");
        return uint(price);
    }


    /**
     * Private functions
     */

    /// @dev Common functionality for give(address) and giveWithDAI(address, uint).
    /// @param _to The account to send the REKT token to.
    function giveCommon(address _to) private {
        balance[_to] = 1;
        recipients[msg.sender].push(_to);
        totalSupply ++;
        emit Transfer(address(0), msg.sender, 1);
        emit Transfer(msg.sender, _to, 1);
        emit LogGive(msg.sender, _to);
    }


    /// @dev Assigns rewards and bounties to pots within user vaults dependant on holdScore
    /// and bounty proportion compared to the total bounties within the system.
    /// @param _receiver The account that received the REKT token.
    /// @param _sender The account that sent the REKT token.
    /// @return A uint representing the fee reward.
    function distributeBurnRewards(address _receiver, address _sender) private returns (uint feeReward) {

        feeReward = 0;

        uint bountyETH = receiver[_receiver].bountyETH;
        uint bountyDAI = receiver[_receiver].bountyDAI;
        uint bountyTotal = potValue(bountyDAI, bountyETH);

        if (bountyTotal > 0 ) {
            uint bountyProportion = calculateBountyProportion(bountyTotal);
            uint userRewardPot = bountyProportion.rmul(feePot);

            if (shutdown) {
                // in the shutdown state the holdscore isn't used
                feeReward = userRewardPot;
            } else {
                uint holdScore = calculateHoldScore(receiver[_receiver].timestamp);
                feeReward = userRewardPot.rmul(holdScore);
            }

            if (bountyETH > 0) {
                // subtract bounty from the senders's bounty total and the bounty pot
                unredeemedBounty[_sender].ETH = unredeemedBounty[_sender].ETH.sub(bountyETH);
                bountyPot.ETH = bountyPot.ETH.sub(bountyETH);

                // add bounty to receivers vault
                vault[_receiver].bountyETH = vault[_receiver].bountyETH.add(bountyETH);
                emit LogVaultDeposit(_receiver, 'bountyETH', bountyETH);

            } else if (bountyDAI > 0) {
                unredeemedBounty[_sender].DAI = unredeemedBounty[_sender].DAI.sub(bountyDAI);
                bountyPot.DAI = bountyPot.DAI.sub(bountyDAI);
                if (isMCD && receiver[_receiver].timestamp > MCDswitchTimestamp) {
                    vault[_receiver].bountyDAI = vault[_receiver].bountyDAI.add(bountyDAI);
                } else { // they would have sent SAI
                    vault[_receiver].bountySAI = vault[_receiver].bountySAI.add(bountyDAI);
                }
                emit LogVaultDeposit(_receiver, 'bountyDAI', bountyDAI);
            }

            if (feeReward > 0) {
                feeReward = feeReward / 2;

                // subtract and add feeReward for receiver vault
                feePot = feePot.sub(feeReward);
                vault[_receiver].fee = vault[_receiver].fee.add(feeReward);
                emit LogVaultDeposit(_receiver, 'reward', feeReward);

                // subtract and add feeReward for sender vault
                feePot = feePot.sub(feeReward);
                vault[_sender].fee = vault[_sender].fee.add(feeReward);
                emit LogVaultDeposit(_sender, 'reward', feeReward);
            }
        }

        return feeReward;
    }


    /// @dev Returns a rounded bump amount represented as a WAD.
    /// @param _amount The amount to be rounded.
    /// @return A uint representing the amount rounded to PRECISION as a WAD.
    function roundBumpAmount(uint _amount) private pure returns (uint rounded) {
        require(_amount >= PRECISION, "bump size too small to round");
        return (_amount / PRECISION).mul(PRECISION);
    }


    /// @dev called by withdraw(address) and withdrawSelf(address) to withdraw
    /// fee reward, DAI, SAI & ETH bounties.
    /// Both params will be the same for a normal user withdrawal.
    /// @param _destination The account to receive the funds.
    /// @param _vaultOwner The vault that the funds will be taken from.
    function withdrawCommon(address payable _destination, address _vaultOwner) private {
        require(address(_destination) != address(0), "Invalid address");
        uint amountETH = vault[_vaultOwner].fee.add(vault[_vaultOwner].bountyETH);
        uint amountDAI = vault[_vaultOwner].bountyDAI;
        uint amountSAI = vault[_vaultOwner].bountySAI;
        vault[_vaultOwner] = Vault(0,0,0,0);
        emit LogWithdraw(_destination, amountETH, amountSAI, amountDAI);
        if (amountDAI > 0) {
            require(dai.transferFrom(address(this), _destination, amountDAI), "DAI transfer failed");
        }
        if (amountSAI > 0) {
            require(sai.transferFrom(address(this), _destination, amountSAI), "SAI transfer failed");
        }
        if (amountETH > 0) {
            _destination.transfer(amountETH);
        }
    }
}