//! Fundraiser contract. Just records who sent what.
//! By Parity Technologies, 2017.
//! Released under the Apache Licence 2.
//! Modified by the Interchain Foundation.

pragma solidity ^0.4.8;

/// Will accept Ether "contributions" and record each both as a log and in a
/// queryable record.
contract Fundraiser {


    // How much is enough?
    uint public constant dust = 180 finney;


    // Special addresses: 
    //  administrator can halt/unhalt/kill/adjustRate;
    //  treasury receives all the funds
    address public admin;
    address public treasury;

    // Begin and end block for the fundraising period
    uint public beginBlock;
    uint public endBlock;

    // Number of wei per atom
    uint public weiPerAtom; 

    // Are contributions abnormally halted?
    bool public isHalted = false;

    // The `record` mapping maps cosmos addresses to the amount of atoms.
    mapping (address => uint) public record;

    // The total amount of ether raised
    uint public totalWei = 0;
    // The total amount of atoms suggested for allocation
    uint public totalAtom = 0;
    // The number of donation
    uint public numDonations = 0;

    /// Constructor. `_admin` has the ability to pause the
    /// contribution period and, eventually, kill this contract. `_treasury`
    /// receives all funds. `_beginBlock` and `_endBlock` define the begin and
    /// end of the period. `_weiPerAtom` is the ratio of atoms to ether.
    function Fundraiser(address _admin, address _treasury, uint _beginBlock, uint _endBlock, uint _weiPerAtom) {
        admin = _admin;
        treasury = _treasury;
        beginBlock = _beginBlock;
        endBlock = _endBlock;
	weiPerAtom = _weiPerAtom;
    }

    // Can only be called by _admin.
    modifier only_admin { if (msg.sender != admin) throw; _; }
    // Can only be called by prior to the period.
    modifier only_before_period { if (block.number >= beginBlock) throw; _; }
    // Can only be called during the period when not halted.
    modifier only_during_period { if (block.number < beginBlock || block.number >= endBlock || isHalted) throw; _; }
    // Can only be called during the period when halted.
    modifier only_during_halted_period { if (block.number < beginBlock || block.number >= endBlock || !isHalted) throw; _; }
    // Can only be called after the period.
    modifier only_after_period { if (block.number < endBlock) throw; _; }
    // The value of the message must be sufficiently large to not be considered dust.
    modifier is_not_dust { if (msg.value < dust) throw; _; }

    /// Some contribution `amount` received from `recipient` at rate of `currentRate` with emergency return of `returnAddr`.
    event Received(address indexed recipient, address returnAddr, uint amount, uint currentRate);
    /// Period halted abnormally.
    event Halted();
    /// Period restarted after abnormal halt.
    event Unhalted();

    // Is the fundraiser active?
    function isActive() constant returns (bool active) {
	return (block.number >= beginBlock && block.number < endBlock && !isHalted);
    }

    /// Receive a contribution for a donor cosmos address.
    function donate(address _donor, address _returnAddress, bytes4 checksum) payable only_during_period is_not_dust {
	// checksum is the first 4 bytes of the sha3 of the xor of the bytes32 versions of the cosmos address and the return address
	if ( !( bytes4(sha3( bytes32(_donor)^bytes32(_returnAddress) )) == checksum )) throw;

	// forward the funds to the treasurer
        if (!treasury.send(msg.value)) throw;

	// calculate the number of atoms at the current rate
	var atoms = msg.value / weiPerAtom;

	// update the donor details
        record[_donor] += atoms;

	// update the totals
        totalWei += msg.value;
	totalAtom += atoms;
	numDonations += 1;

        Received(_donor, _returnAddress, msg.value, weiPerAtom);
    }

    /// Adjust the weiPerAtom
    function adjustRate(uint newRate) only_admin {
	weiPerAtom = newRate;
    }

    /// Halt the contribution period. Any attempt at contributing will fail.
    function halt() only_admin only_during_period {
        isHalted = true;
        Halted();
    }

    /// Unhalt the contribution period.
    function unhalt() only_admin only_during_halted_period {
        isHalted = false;
        Unhalted();
    }

    /// Kill this contract.
    function kill() only_admin only_after_period {
        suicide(treasury);
    }
}