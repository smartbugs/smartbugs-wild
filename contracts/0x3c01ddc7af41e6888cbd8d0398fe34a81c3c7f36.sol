pragma solidity ^0.4.6;

/**
* @title RLPReader
*
* RLPReader is used to read and parse RLP encoded data in memory.
*
* @author Andreas Olofsson (androlo1980@gmail.com)
*/
library RLP {

 uint constant DATA_SHORT_START = 0x80;
 uint constant DATA_LONG_START = 0xB8;
 uint constant LIST_SHORT_START = 0xC0;
 uint constant LIST_LONG_START = 0xF8;

 uint constant DATA_LONG_OFFSET = 0xB7;
 uint constant LIST_LONG_OFFSET = 0xF7;


 struct RLPItem {
     uint _unsafe_memPtr;    // Pointer to the RLP-encoded bytes.
     uint _unsafe_length;    // Number of bytes. This is the full length of the string.
 }

 struct Iterator {
     RLPItem _unsafe_item;   // Item that's being iterated over.
     uint _unsafe_nextPtr;   // Position of the next item in the list.
 }

 /* Iterator */

 function next(Iterator memory self) internal constant returns (RLPItem memory subItem) {
     if(hasNext(self)) {
         var ptr = self._unsafe_nextPtr;
         var itemLength = _itemLength(ptr);
         subItem._unsafe_memPtr = ptr;
         subItem._unsafe_length = itemLength;
         self._unsafe_nextPtr = ptr + itemLength;
     }
     else
         throw;
 }

 function next(Iterator memory self, bool strict) internal constant returns (RLPItem memory subItem) {
     subItem = next(self);
     if(strict && !_validate(subItem))
         throw;
     return;
 }

 function hasNext(Iterator memory self) internal constant returns (bool) {
     var item = self._unsafe_item;
     return self._unsafe_nextPtr < item._unsafe_memPtr + item._unsafe_length;
 }

 /* RLPItem */

 /// @dev Creates an RLPItem from an array of RLP encoded bytes.
 /// @param self The RLP encoded bytes.
 /// @return An RLPItem
 function toRLPItem(bytes memory self) internal constant returns (RLPItem memory) {
     uint len = self.length;
     if (len == 0) {
         return RLPItem(0, 0);
     }
     uint memPtr;
     assembly {
         memPtr := add(self, 0x20)
     }
     return RLPItem(memPtr, len);
 }

 /// @dev Creates an RLPItem from an array of RLP encoded bytes.
 /// @param self The RLP encoded bytes.
 /// @param strict Will throw if the data is not RLP encoded.
 /// @return An RLPItem
 function toRLPItem(bytes memory self, bool strict) internal constant returns (RLPItem memory) {
     var item = toRLPItem(self);
     if(strict) {
         uint len = self.length;
         if(_payloadOffset(item) > len)
             throw;
         if(_itemLength(item._unsafe_memPtr) != len)
             throw;
         if(!_validate(item))
             throw;
     }
     return item;
 }

 /// @dev Check if the RLP item is null.
 /// @param self The RLP item.
 /// @return 'true' if the item is null.
 function isNull(RLPItem memory self) internal constant returns (bool ret) {
     return self._unsafe_length == 0;
 }

 /// @dev Check if the RLP item is a list.
 /// @param self The RLP item.
 /// @return 'true' if the item is a list.
 function isList(RLPItem memory self) internal constant returns (bool ret) {
     if (self._unsafe_length == 0)
         return false;
     uint memPtr = self._unsafe_memPtr;
     assembly {
         ret := iszero(lt(byte(0, mload(memPtr)), 0xC0))
     }
 }

 /// @dev Check if the RLP item is data.
 /// @param self The RLP item.
 /// @return 'true' if the item is data.
 function isData(RLPItem memory self) internal constant returns (bool ret) {
     if (self._unsafe_length == 0)
         return false;
     uint memPtr = self._unsafe_memPtr;
     assembly {
         ret := lt(byte(0, mload(memPtr)), 0xC0)
     }
 }

 /// @dev Check if the RLP item is empty (string or list).
 /// @param self The RLP item.
 /// @return 'true' if the item is null.
 function isEmpty(RLPItem memory self) internal constant returns (bool ret) {
     if(isNull(self))
         return false;
     uint b0;
     uint memPtr = self._unsafe_memPtr;
     assembly {
         b0 := byte(0, mload(memPtr))
     }
     return (b0 == DATA_SHORT_START || b0 == LIST_SHORT_START);
 }

 /// @dev Get the number of items in an RLP encoded list.
 /// @param self The RLP item.
 /// @return The number of items.
 function items(RLPItem memory self) internal constant returns (uint) {
     if (!isList(self))
         return 0;
     uint b0;
     uint memPtr = self._unsafe_memPtr;
     assembly {
         b0 := byte(0, mload(memPtr))
     }
     uint pos = memPtr + _payloadOffset(self);
     uint last = memPtr + self._unsafe_length - 1;
     uint itms;
     while(pos <= last) {
         pos += _itemLength(pos);
         itms++;
     }
     return itms;
 }

 /// @dev Create an iterator.
 /// @param self The RLP item.
 /// @return An 'Iterator' over the item.
 function iterator(RLPItem memory self) internal constant returns (Iterator memory it) {
     if (!isList(self))
         throw;
     uint ptr = self._unsafe_memPtr + _payloadOffset(self);
     it._unsafe_item = self;
     it._unsafe_nextPtr = ptr;
 }

 /// @dev Return the RLP encoded bytes.
 /// @param self The RLPItem.
 /// @return The bytes.
 function toBytes(RLPItem memory self) internal constant returns (bytes memory bts) {
     var len = self._unsafe_length;
     if (len == 0)
         return;
     bts = new bytes(len);
     _copyToBytes(self._unsafe_memPtr, bts, len);
 }

 /// @dev Decode an RLPItem into bytes. This will not work if the
 /// RLPItem is a list.
 /// @param self The RLPItem.
 /// @return The decoded string.
 function toData(RLPItem memory self) internal constant returns (bytes memory bts) {
     if(!isData(self))
         throw;
     var (rStartPos, len) = _decode(self);
     bts = new bytes(len);
     _copyToBytes(rStartPos, bts, len);
 }

 /// @dev Get the list of sub-items from an RLP encoded list.
 /// Warning: This is inefficient, as it requires that the list is read twice.
 /// @param self The RLP item.
 /// @return Array of RLPItems.
 function toList(RLPItem memory self) internal constant returns (RLPItem[] memory list) {
     if(!isList(self))
         throw;
     var numItems = items(self);
     list = new RLPItem[](numItems);
     var it = iterator(self);
     uint idx;
     while(hasNext(it)) {
         list[idx] = next(it);
         idx++;
     }
 }

 /// @dev Decode an RLPItem into an ascii string. This will not work if the
 /// RLPItem is a list.
 /// @param self The RLPItem.
 /// @return The decoded string.
 function toAscii(RLPItem memory self) internal constant returns (string memory str) {
     if(!isData(self))
         throw;
     var (rStartPos, len) = _decode(self);
     bytes memory bts = new bytes(len);
     _copyToBytes(rStartPos, bts, len);
     str = string(bts);
 }

 /// @dev Decode an RLPItem into a uint. This will not work if the
 /// RLPItem is a list.
 /// @param self The RLPItem.
 /// @return The decoded string.
 function toUint(RLPItem memory self) internal constant returns (uint data) {
     if(!isData(self))
         throw;
     var (rStartPos, len) = _decode(self);
     if (len > 32 || len == 0)
         throw;
     assembly {
         data := div(mload(rStartPos), exp(256, sub(32, len)))
     }
 }

 /// @dev Decode an RLPItem into a boolean. This will not work if the
 /// RLPItem is a list.
 /// @param self The RLPItem.
 /// @return The decoded string.
 function toBool(RLPItem memory self) internal constant returns (bool data) {
     if(!isData(self))
         throw;
     var (rStartPos, len) = _decode(self);
     if (len != 1)
         throw;
     uint temp;
     assembly {
         temp := byte(0, mload(rStartPos))
     }
     if (temp > 1)
         throw;
     return temp == 1 ? true : false;
 }

 /// @dev Decode an RLPItem into a byte. This will not work if the
 /// RLPItem is a list.
 /// @param self The RLPItem.
 /// @return The decoded string.
 function toByte(RLPItem memory self) internal constant returns (byte data) {
     if(!isData(self))
         throw;
     var (rStartPos, len) = _decode(self);
     if (len != 1)
         throw;
     uint temp;
     assembly {
         temp := byte(0, mload(rStartPos))
     }
     return byte(temp);
 }

 /// @dev Decode an RLPItem into an int. This will not work if the
 /// RLPItem is a list.
 /// @param self The RLPItem.
 /// @return The decoded string.
 function toInt(RLPItem memory self) internal constant returns (int data) {
     return int(toUint(self));
 }

 /// @dev Decode an RLPItem into a bytes32. This will not work if the
 /// RLPItem is a list.
 /// @param self The RLPItem.
 /// @return The decoded string.
 function toBytes32(RLPItem memory self) internal constant returns (bytes32 data) {
     return bytes32(toUint(self));
 }

 /// @dev Decode an RLPItem into an address. This will not work if the
 /// RLPItem is a list.
 /// @param self The RLPItem.
 /// @return The decoded string.
 function toAddress(RLPItem memory self) internal constant returns (address data) {
     if(!isData(self))
         throw;
     var (rStartPos, len) = _decode(self);
     if (len != 20)
         throw;
     assembly {
         data := div(mload(rStartPos), exp(256, 12))
     }
 }

 // Get the payload offset.
 function _payloadOffset(RLPItem memory self) private constant returns (uint) {
     if(self._unsafe_length == 0)
         return 0;
     uint b0;
     uint memPtr = self._unsafe_memPtr;
     assembly {
         b0 := byte(0, mload(memPtr))
     }
     if(b0 < DATA_SHORT_START)
         return 0;
     if(b0 < DATA_LONG_START || (b0 >= LIST_SHORT_START && b0 < LIST_LONG_START))
         return 1;
     if(b0 < LIST_SHORT_START)
         return b0 - DATA_LONG_OFFSET + 1;
     return b0 - LIST_LONG_OFFSET + 1;
 }

 // Get the full length of an RLP item.
 function _itemLength(uint memPtr) private constant returns (uint len) {
     uint b0;
     assembly {
         b0 := byte(0, mload(memPtr))
     }
     if (b0 < DATA_SHORT_START)
         len = 1;
     else if (b0 < DATA_LONG_START)
         len = b0 - DATA_SHORT_START + 1;
     else if (b0 < LIST_SHORT_START) {
         assembly {
             let bLen := sub(b0, 0xB7) // bytes length (DATA_LONG_OFFSET)
             let dLen := div(mload(add(memPtr, 1)), exp(256, sub(32, bLen))) // data length
             len := add(1, add(bLen, dLen)) // total length
         }
     }
     else if (b0 < LIST_LONG_START)
         len = b0 - LIST_SHORT_START + 1;
     else {
         assembly {
             let bLen := sub(b0, 0xF7) // bytes length (LIST_LONG_OFFSET)
             let dLen := div(mload(add(memPtr, 1)), exp(256, sub(32, bLen))) // data length
             len := add(1, add(bLen, dLen)) // total length
         }
     }
 }

 // Get start position and length of the data.
 function _decode(RLPItem memory self) private constant returns (uint memPtr, uint len) {
     if(!isData(self))
         throw;
     uint b0;
     uint start = self._unsafe_memPtr;
     assembly {
         b0 := byte(0, mload(start))
     }
     if (b0 < DATA_SHORT_START) {
         memPtr = start;
         len = 1;
         return;
     }
     if (b0 < DATA_LONG_START) {
         len = self._unsafe_length - 1;
         memPtr = start + 1;
     } else {
         uint bLen;
         assembly {
             bLen := sub(b0, 0xB7) // DATA_LONG_OFFSET
         }
         len = self._unsafe_length - 1 - bLen;
         memPtr = start + bLen + 1;
     }
     return;
 }

 // Assumes that enough memory has been allocated to store in target.
 function _copyToBytes(uint btsPtr, bytes memory tgt, uint btsLen) private constant {
     // Exploiting the fact that 'tgt' was the last thing to be allocated,
     // we can write entire words, and just overwrite any excess.
     assembly {
         {
                 let i := 0 // Start at arr + 0x20
                 let words := div(add(btsLen, 31), 32)
                 let rOffset := btsPtr
                 let wOffset := add(tgt, 0x20)
             tag_loop:
                 jumpi(end, eq(i, words))
                 {
                     let offset := mul(i, 0x20)
                     mstore(add(wOffset, offset), mload(add(rOffset, offset)))
                     i := add(i, 1)
                 }
                 jump(tag_loop)
             end:
                 mstore(add(tgt, add(0x20, mload(tgt))), 0)
         }
     }
 }

 // Check that an RLP item is valid.
     function _validate(RLPItem memory self) private constant returns (bool ret) {
         // Check that RLP is well-formed.
         uint b0;
         uint b1;
         uint memPtr = self._unsafe_memPtr;
         assembly {
             b0 := byte(0, mload(memPtr))
             b1 := byte(1, mload(memPtr))
         }
         if(b0 == DATA_SHORT_START + 1 && b1 < DATA_SHORT_START)
             return false;
         return true;
     }
}

/*
    Copyright 2016, Jordi Baylina

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/// @title MilestoneTracker Contract
/// @author Jordi Baylina
/// @dev This contract tracks the


/// is rules the relation betwen a donor and a recipient
///  in order to guaranty to the donor that the job will be done and to guaranty
///  to the recipient that he will be paid


/// @dev We use the RLP library to decode RLP so that the donor can approve one
///  set of milestone changes at a time.
///  https://github.com/androlo/standard-contracts/blob/master/contracts/src/codec/RLP.sol
// import "RLP.sol";



/// @dev This contract allows for `recipient` to set and modify milestones
contract MilestoneTracker {
    using RLP for RLP.RLPItem;
    using RLP for RLP.Iterator;
    using RLP for bytes;

    struct Milestone {
        string description;     // Description of the milestone
        string url;             // A link to more information (swarm gateway)
        uint minCompletionDate;       // Earliest UNIX time the milestone can be paid
        uint maxCompletionDate;       // Latest UNIX time the milestone can be paid
        address reviewer;       // Who will check the milestone has completed
        uint reviewTime;        // How many seconds the reviewer has to review
        address paymentSource;  // Where the milestone payment is sent from
        bytes payData;          // Data defining how much ether is sent where

        MilestoneStatus status; // Current status of the milestone (Completed, Paid...)
        uint doneTime;          // UNIX time when the milestone was marked DONE
    }

    // The list of all the milestones.
    Milestone[] public milestones;

    address public recipient;   // Calls functions in the name of the recipient
    address public donor;       // Calls functions in the name of the donor
    address public arbitrator;  // Calls functions in the name of the arbitrator

    enum MilestoneStatus { AcceptedAndInProgress, Completed, Paid, Canceled }

    // True if the campaign has been canceled
    bool public campaignCanceled;

    // True if an approval on a change to `milestones` is a pending
    bool public changingMilestones;

    // The pending change to `milestones` encoded in RLP
    bytes public proposedMilestones;


    /// @dev The following modifiers only allow specific roles to call functions
    /// with these modifiers
    modifier onlyRecipient { if (msg.sender !=  recipient) throw; _; }
    modifier onlyArbitrator { if (msg.sender != arbitrator) throw; _; }
    modifier onlyDonor { if (msg.sender != donor) throw; _; }

    /// @dev The following modifiers prevent functions from being called if the
    /// campaign has been canceled or if new milestones are being proposed
    modifier campaignNotCanceled { if (campaignCanceled) throw; _; }
    modifier notChanging { if (changingMilestones) throw; _; }

 // @dev Events to make the payment movements easy to find on the blockchain
    event NewMilestoneListProposed();
    event NewMilestoneListUnproposed();
    event NewMilestoneListAccepted();
    event ProposalStatusChanged(uint idProposal, MilestoneStatus newProposal);
    event CampaignCalncelled();


///////////
// Constructor
///////////

    /// @notice The Constructor creates the Milestone contract on the blockchain
    /// @param _arbitrator Address assigned to be the arbitrator
    /// @param _donor Address assigned to be the donor
    /// @param _recipient Address assigned to be the recipient
    function MilestoneTracker (
        address _arbitrator,
        address _donor,
        address _recipient
    ) {
        arbitrator = _arbitrator;
        donor = _donor;
        recipient = _recipient;
    }


/////////
// Helper functions
/////////

    /// @return The number of milestones ever created even if they were canceled
    function numberOfMilestones() constant returns (uint) {
        return milestones.length;
    }


////////
// Change players
////////

    /// @notice `onlyArbitrator` Reassigns the arbitrator to a new address
    /// @param _newArbitrator The new arbitrator
    function changeArbitrator(address _newArbitrator) onlyArbitrator {
        arbitrator = _newArbitrator;
    }

    /// @notice `onlyDonor` Reassigns the `donor` to a new address
    /// @param _newDonor The new donor
    function changeDonor(address _newDonor) onlyDonor {
        donor = _newDonor;
    }

    /// @notice `onlyRecipient` Reassigns the `recipient` to a new address
    /// @param _newRecipient The new recipient
    function changeRecipient(address _newRecipient) onlyRecipient {
        recipient = _newRecipient;
    }


////////////
// Creation and modification of Milestones
////////////

    /// @notice `onlyRecipient` Proposes new milestones or changes old
    ///  milestones, this will require a user interface to be built up to
    ///  support this functionality as asks for RLP encoded bytecode to be
    ///  generated, until this interface is built you can use this script:
    ///  https://github.com/Giveth/milestonetracker/blob/master/js/milestonetracker_helper.js
    ///  the functions milestones2bytes and bytes2milestones will enable the
    ///  recipient to encode and decode a list of milestones, also see
    ///  https://github.com/Giveth/milestonetracker/blob/master/README.md
    /// @param _newMilestones The RLP encoded list of milestones; each milestone
    ///  has these fields:
    ///       string description,
    ///       string url,
    ///       address paymentSource,
    ///       bytes payData,
    ///       uint minCompletionDate,
    ///       uint maxCompletionDate,
    ///       address reviewer,
    ///       uint reviewTime
    function proposeMilestones(bytes _newMilestones
    ) onlyRecipient campaignNotCanceled {
        proposedMilestones = _newMilestones;
        changingMilestones = true;
        NewMilestoneListProposed();
    }


////////////
// Normal actions that will change the state of the milestones
////////////

    /// @notice `onlyRecipient` Cancels the proposed milestones and reactivates
    ///  the previous set of milestones
    function unproposeMilestones() onlyRecipient campaignNotCanceled {
        delete proposedMilestones;
        changingMilestones = false;
        NewMilestoneListUnproposed();
    }

    /// @notice `onlyDonor` Approves the proposed milestone list
    /// @param _hashProposals The sha3() of the proposed milestone list's
    ///  bytecode; this confirms that the `donor` knows the set of milestones
    ///  they are approving
    function acceptProposedMilestones(bytes32 _hashProposals
    ) onlyDonor campaignNotCanceled {

        uint i;

        if (!changingMilestones) throw;
        if (sha3(proposedMilestones) != _hashProposals) throw;

        // Cancel all the unfinished milestones
        for (i=0; i<milestones.length; i++) {
            if (milestones[i].status != MilestoneStatus.Paid) {
                milestones[i].status = MilestoneStatus.Canceled;
            }
        }
        // Decode the RLP encoded milestones and add them to the milestones list
        bytes memory mProposedMilestones = proposedMilestones;

        var itmProposals = mProposedMilestones.toRLPItem(true);

        if (!itmProposals.isList()) throw;

        var itrProposals = itmProposals.iterator();

        while(itrProposals.hasNext()) {


            var itmProposal = itrProposals.next();

            Milestone milestone = milestones[milestones.length ++];

            if (!itmProposal.isList()) throw;

            var itrProposal = itmProposal.iterator();

            milestone.description = itrProposal.next().toAscii();
            milestone.url = itrProposal.next().toAscii();
            milestone.minCompletionDate = itrProposal.next().toUint();
            milestone.maxCompletionDate = itrProposal.next().toUint();
            milestone.reviewer = itrProposal.next().toAddress();
            milestone.reviewTime = itrProposal.next().toUint();
            milestone.paymentSource = itrProposal.next().toAddress();
            milestone.payData = itrProposal.next().toData();

            milestone.status = MilestoneStatus.AcceptedAndInProgress;

        }

        delete proposedMilestones;
        changingMilestones = false;
        NewMilestoneListAccepted();
    }

    /// @notice `onlyReviewer` Approves a specific milestone
    /// @param _idMilestone ID of the milestone that is approved
    function approveCompletedMilestone(uint _idMilestone) campaignNotCanceled notChanging {
        if (_idMilestone >= milestones.length) throw;
        Milestone milestone = milestones[_idMilestone];
        if ((msg.sender != milestone.reviewer) ||
            (milestone.status != MilestoneStatus.Completed)) throw;

        doPayment(_idMilestone);
    }

    /// @notice `onlyReviewer` Rejects a specific milestone's completion and
    ///  reverts the `milestone.status` back to the `AcceptedAndInProgress` state
    /// @param _idMilestone ID of the milestone that is being rejected
    function rejectMilestone(uint _idMilestone) campaignNotCanceled notChanging {
        if (_idMilestone >= milestones.length) throw;
        Milestone milestone = milestones[_idMilestone];
        if ((msg.sender != milestone.reviewer) ||
            (milestone.status != MilestoneStatus.Completed)) throw;

        milestone.status = MilestoneStatus.AcceptedAndInProgress;
        ProposalStatusChanged(_idMilestone, milestone.status);
    }

    /// @notice `onlyRecipient` Marks a milestone as DONE and ready for review
    /// @param _idMilestone ID of the milestone that has been completed
    function milestoneCompleted(uint _idMilestone) onlyRecipient campaignNotCanceled notChanging {
        if (_idMilestone >= milestones.length) throw;
        Milestone milestone = milestones[_idMilestone];
        if (milestone.status != MilestoneStatus.AcceptedAndInProgress) throw;
        if (now < milestone.minCompletionDate) throw;
        if (now > milestone.maxCompletionDate) throw;
        milestone.status = MilestoneStatus.Completed;
        milestone.doneTime = now;
        ProposalStatusChanged(_idMilestone, milestone.status);
    }

    /// @notice `onlyRecipient` Sends the milestone payment as specified in
    ///  `payData`; the recipient can only call this after the `reviewTime` has
    ///  elapsed
    /// @param _idMilestone ID of the milestone to be paid out
    function collectMilestonePayment(uint _idMilestone
        ) onlyRecipient campaignNotCanceled notChanging {
        if (_idMilestone >= milestones.length) throw;
        Milestone milestone = milestones[_idMilestone];
        if  ((milestone.status != MilestoneStatus.Completed) ||
             (now < milestone.doneTime + milestone.reviewTime))
            throw;

        doPayment(_idMilestone);
    }

    /// @notice `onlyRecipient` Cancels a previously accepted milestone
    /// @param _idMilestone ID of the milestone to be canceled
    function cancelMilestone(uint _idMilestone) onlyRecipient campaignNotCanceled notChanging {
        if (_idMilestone >= milestones.length) throw;
        Milestone milestone = milestones[_idMilestone];
        if  ((milestone.status != MilestoneStatus.AcceptedAndInProgress) &&
             (milestone.status != MilestoneStatus.Completed))
            throw;

        milestone.status = MilestoneStatus.Canceled;
        ProposalStatusChanged(_idMilestone, milestone.status);
    }

    /// @notice `onlyArbitrator` Forces a milestone to be paid out as long as it
    /// has not been paid or canceled
    /// @param _idMilestone ID of the milestone to be paid out
    function arbitrateApproveMilestone(uint _idMilestone
    ) onlyArbitrator campaignNotCanceled notChanging {
        if (_idMilestone >= milestones.length) throw;
        Milestone milestone = milestones[_idMilestone];
        if  ((milestone.status != MilestoneStatus.AcceptedAndInProgress) &&
             (milestone.status != MilestoneStatus.Completed))
           throw;
        doPayment(_idMilestone);
    }

    /// @notice `onlyArbitrator` Cancels the entire campaign voiding all
    ///  milestones vo
    function arbitrateCancelCampaign() onlyArbitrator campaignNotCanceled {
        campaignCanceled = true;
        CampaignCalncelled();
    }

    // @dev This internal function is executed when the milestone is paid out
    function doPayment(uint _idMilestone) internal {
        if (_idMilestone >= milestones.length) throw;
        Milestone milestone = milestones[_idMilestone];
        // Recheck again to not pay twice
        if (milestone.status == MilestoneStatus.Paid) throw;
        milestone.status = MilestoneStatus.Paid;
        if (!milestone.paymentSource.call.value(0)(milestone.payData))
            throw;
        ProposalStatusChanged(_idMilestone, milestone.status);
    }
}