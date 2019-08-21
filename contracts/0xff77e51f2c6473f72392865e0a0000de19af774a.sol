pragma solidity 0.4.18;

// This contract provides the functions necessary to record ("push") & retrieve
// public funding data to the Ethereum blockchain for the National Research
// Council of Canada

contract DisclosureManager {

	address public owner;

	struct Disclosure {
		bytes32 organization;
		bytes32 recipient;
		bytes32 location;
		bytes16 amount;
		bytes1 fundingType;
		bytes16 date;
		bytes32 purpose;
		bytes32 comment;
		uint amended;    // if zero not amended, otherwise points to the rowNumber of the new record
	}

	Disclosure[] public disclosureList;

	event disclosureAdded(
    uint rowNumber,
    bytes32 organization,
    bytes32 recipient,
    bytes32 location,
    bytes16 amount,
    bytes1 fundingType,
    bytes16 date,
    bytes32 purpose,
    bytes32 comment);

	function DisclosureManager() public {
		owner = msg.sender;
	}

	// Make sure the caller of the contract is the owner
	// modifier isOwner() { if (msg.sender != owner) throw; _ ;}   // old way
	modifier isOwner() { if (msg.sender != owner) revert(); _ ;}

	// getListCount() returns the number of records in disclosureList (not including the empty 0th record)
	function getListCount() public constant returns(uint listCount) {
  	if (disclosureList.length > 0) {
			return disclosureList.length - 1;    // Returns the last rowNumber, reflecting number of records in list
		} else {
			return 0;    // The case of an uninitialized list
		}
	}
	// Future idea: Another function to return total number of unamended Entries? (ie actual record count)

	// Create/push a new entry to our array, returns the new Entry's rowNumber
	function newEntry(bytes32 organization,
					  bytes32 recipient,
					  bytes32 location,
					  bytes16 amount,
					  bytes1 fundingType,
					  bytes16 date,
					  bytes32 purpose,
					  bytes32 comment) public isOwner() returns(uint rowNumber) {    // should this be public? yes, only needed isOwner()

		// Initialize disclosureList here as needed by putting an empty record at row 0
		// The first entry starts at 1 and getListCount will be in accordance with the record count
		if (disclosureList.length == 0) {
			// Push an empty Entry
			Disclosure memory nullEntry;
			disclosureList.push(nullEntry);
		}

		Disclosure memory disclosure;

		disclosure.organization = organization;
		disclosure.recipient = recipient;
		disclosure.location = location;
		disclosure.amount = amount;
		disclosure.fundingType = fundingType;
		disclosure.date = date;
		disclosure.purpose = purpose;
		disclosure.comment = comment;
		disclosure.amended = 0;

		// Push entry to the array
		uint index = disclosureList.push(disclosure);   // adds to end of array (of structs) and returns the new array length
		index = index - 1;

		// Record the event
		disclosureAdded(index, organization, recipient, location, amount, fundingType, date, purpose, comment);

		return index;   // returning rowNumber of the record
	}

	// Amends/changes marks existing entry as amended and takes passed data to
	// create a new Entry to which the amended pointer (rowNumber) will point.
	function amendEntry(uint rowNumber,
						bytes32 organization,
						bytes32 recipient,
						bytes32 location,
						bytes16 amount,
						bytes1 fundingType,
						bytes16 date,
						bytes32 purpose,
						bytes32 comment) public isOwner() returns(uint newRowNumber) {    // returns the new rowNumber of amended record

		// Make sure passed rowNumber is in bounds
		if (rowNumber >= disclosureList.length) { revert(); }
		if (rowNumber < 1) { revert(); }
		if (disclosureList[rowNumber].amended > 0) { revert(); }    // This record is already amended

		// First create new entry
		Disclosure memory disclosure;

		disclosure.organization = organization;
		disclosure.recipient = recipient;
		disclosure.location = location;
		disclosure.amount = amount;
		disclosure.fundingType = fundingType;
		disclosure.date = date;
		disclosure.purpose = purpose;
		disclosure.comment = comment;
		disclosure.amended = 0;

		// Push entry to the array
		uint index = disclosureList.push(disclosure);   // adds to end of array (of structs) and returns the new array length
		index = index - 1;

		// Now that we have the newRowNumber (index), set the amended field on the old record
		disclosureList[rowNumber].amended = index;

		// Record the event
		disclosureAdded(index, organization, recipient, location, amount, fundingType, date, purpose, comment);   // a different event for amending?

		return index;   // returning rowNumber of the new record
	}

	// Returns row regardless of whether or not it has been amended
	function pullRow(uint rowNumber) public constant returns(bytes32, bytes32, bytes32, bytes16, bytes1, bytes16, bytes32, bytes32, uint) {
		// First make sure rowNumber passed is within bounds
		if (rowNumber >= disclosureList.length) { revert(); }
		if (rowNumber < 1) { revert(); }
		// Should not use any gas:
		Disclosure memory entry = disclosureList[rowNumber];
		return (entry.organization, entry.recipient, entry.location, entry.amount, entry.fundingType, entry.date, entry.purpose, entry.comment, entry.amended);
	}

	// Returns latest entry of record intended to pull
	function pullEntry(uint rowNumber) public constant returns(bytes32, bytes32, bytes32, bytes16, bytes1, bytes16, bytes32, bytes32) {
		// First make sure rowNumber passed is within bounds
		if (rowNumber >= disclosureList.length) { revert(); }
		if (rowNumber < 1) { revert(); }
		// If this entry has been amended, return amended entry instead (recursively)
		// just make sure there are never any cyclical lists (shouldn't be possible using these functions)
		if (disclosureList[rowNumber].amended > 0) return pullEntry(disclosureList[rowNumber].amended);
		// Should not require any gas to run:
		Disclosure memory entry = disclosureList[rowNumber];
		return (entry.organization, entry.recipient, entry.location, entry.amount, entry.fundingType, entry.date, entry.purpose, entry.comment);
		// No event for pullEntry() since it shouldn't cost gas to call it
	}

}