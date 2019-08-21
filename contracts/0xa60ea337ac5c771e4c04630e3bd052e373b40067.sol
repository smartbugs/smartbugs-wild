pragma solidity ^0.4.11;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

//! Fundraiser contract. Just records who sent what.
//! By Parity Technologies, 2017.
//! Released under the Apache Licence 2.
//! Modified by the Musereum.





/// Will accept Ether "contributions" and records each both as a log and in a
/// queryable records.
contract Fundraiser {
    using SafeMath for uint;

    // How much is enough?
    uint public constant dust = 100 finney;

    // Special addresses:
    //  administrator can halt/unhalt/kill/adjustRate;
    //  treasury receives all the funds
    address public admin;
    address public treasury;

    // Begin and end block for the fundraising period
    //uint public beginBlock;
    //uint public endBlock;

    // Number of wei per btc
    uint public weiPerBtc;

    // Default number of etm per btc
    uint public EtmPerBtc;

    // Are contributions abnormally halted?
    bool public isHalted = false;

    // The `records` mapping maps musereum addresses to the amount of ETM.
    mapping (address => uint) public records;

    // The total amount of ether raised
    uint public totalWei = 0;
    // The total amount of ETM suggested for allocation
    uint public totalETM = 0;
    // The number of donation
    uint public numDonations = 0;

    /// Constructor. `_admin` has the ability to pause the
    /// contribution period and, eventually, kill this contract. `_treasury`
    /// receives all funds. `_beginBlock` and `_endBlock` define the begin and
    /// end of the period. `_weiPerBtc` is the ratio of ETM to ether.
    function Fundraiser(
        address _admin,
        address _treasury,
        //uint _beginBlock,
        //uint _endBlock,
        uint _weiPerBtc,
        uint _EtmPerBtc
    ) {
        require(_weiPerBtc > 0);
        require(_EtmPerBtc > 0);

        admin = _admin;
        treasury = _treasury;
        //beginBlock = _beginBlock;
        //endBlock = _endBlock;

        weiPerBtc = _weiPerBtc;
        EtmPerBtc = _EtmPerBtc;
    }

    // Can only be called by admin.
    modifier only_admin { require(msg.sender == admin); _; }
    // Can only be called by prior to the period.
    //modifier only_before_period { require(block.number < beginBlock); _; }
    // Can only be called during the period when not halted.
    modifier only_during_period { require(/*block.number >= beginBlock || block.number < endBlock && */!isHalted); _; }
    // Can only be called during the period when halted.
    modifier only_during_halted_period { require(/*block.number >= beginBlock || block.number < endBlock && */isHalted); _; }
    // Can only be called after the period.
    //modifier only_after_period { require(block.number >= endBlock); _; }
    // The value of the message must be sufficiently large to not be considered dust.
    modifier is_not_dust { require(msg.value >= dust); _; }

    /// Some contribution `amount` received from `recipient` at rate of `currentRate` with emergency return of `returnAddr`.
    event Received(address indexed recipient, address returnAddr, uint weiAmount, uint currentRate);
    /// Period halted abnormally.
    event Halted();
    /// Period restarted after abnormal halt.
    event Unhalted();
    event RateChanged(uint newRate);

    // Is the fundraiser active?
    function isActive() public constant returns (bool active) {
        return (/*block.number >= beginBlock && block.number < endBlock && */ !isHalted);
    }

    /// Receive a contribution for a donor musereum address.
    function donate(address _donor, address _returnAddress, bytes4 checksum) public payable only_during_period is_not_dust {
        // checksum is the first 4 bytes of the sha3 of the xor of the bytes32 versions of the musereum address and the return address
        require( bytes4(sha3( bytes32(_donor)^bytes32(_returnAddress) )) == checksum );

        // forward the funds to the treasure
        require( treasury.send(msg.value) );

        // calculate the number of ETM at the current rate
        uint weiPerETM = weiPerBtc.div(EtmPerBtc);
        uint ETM = msg.value.div(weiPerETM);

        // update the donor details
        records[_donor] = records[_donor].add(ETM);

        // update the totals
        totalWei = totalWei.add(msg.value);
        totalETM = totalETM.add(ETM);
        numDonations = numDonations.add(1);

        Received(_donor, _returnAddress, msg.value, weiPerETM);
    }

    /// Adjust the weiPerBtc rate
    function adjustRate(uint newRate) public only_admin {
        weiPerBtc = newRate;
        RateChanged(newRate);
    }

    /// Halt the contribution period. Any attempt at contributing will fail.
    function halt() public only_admin only_during_period {
        isHalted = true;
        Halted();
    }

    /// Unhalt the contribution period.
    function unhalt() public only_admin only_during_halted_period {
        isHalted = false;
        Unhalted();
    }

    /// Kill this contract.
    function kill() public only_admin /*only_after_period*/ {
        suicide(treasury);
    }
}