pragma solidity ^0.4.18;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract BlockdeblockContract is Ownable {

	struct Product {
		uint index;
		uint date;
		uint uniqueId;
		uint design;
		uint8 gender;
		uint8 productType;
		uint8 size;
		uint8 color;
		string brandGuardPhrase;
	}

	mapping(uint8 => string) public sizes;
	mapping(uint8 => string) public colors;
	mapping(uint8 => string) public genders;
	mapping(uint8 => string) public productTypes;
	mapping(uint => string) public designs;
	mapping(uint => Product) public products;

	uint public lastIndex;

	mapping(uint => uint) public uniqueIds;

	event Registration(uint index, uint date, 
		uint indexed uniqueId, uint design, uint8 gender, uint8 productType,
		uint8 size, uint8 color, string brandGuardPhrase);

	function setDesign(uint index, string description) public onlyOwner {
		designs[index] = description;
	}

	function setSize(uint8 index, string size) public onlyOwner {
		sizes[index] = size;
	}

	function setColor(uint8 index, string color) public onlyOwner {
		colors[index] = color;
	}

	function setGender(uint8 index, string gender) public onlyOwner {
		genders[index] = gender;
	}

	function setProductType(uint8 index, string productType) public onlyOwner {
		productTypes[index] = productType;
	}

	function register(uint uniqueId, uint design, uint8 gender, uint8 productType,
		uint8 size, uint8 color, string brandGuardPhrase) external onlyOwner {
		lastIndex += 1;
		require(!uniqueIdExists(uniqueId));
		uniqueIds[uniqueId] = lastIndex;
		products[lastIndex] = 
			Product(lastIndex, now, uniqueId, design, gender, productType, size,
				color, brandGuardPhrase);
		Registration(lastIndex, now, uniqueId, design, gender, productType, size,
			color, brandGuardPhrase);
	}

	function edit(uint uniqueId, uint design, uint8 gender, uint8 productType,
		uint8 size, uint8 color, string brandGuardPhrase) external onlyOwner {
		uint index = uniqueIds[uniqueId];
		Product storage product = products[index];
		if(design != 0) {
			product.design = design;
		}
		if(gender != 0) {
			product.gender = gender;
		}
		if(size != 0) {
			product.size = size;
		}
		if(color != 0) {
			product.color = color;
		}
		if(productType != 0) {
			product.productType = productType;
		}
		if(bytes(brandGuardPhrase).length > 0) {
			product.brandGuardPhrase = brandGuardPhrase;
		}
	}

	function uniqueIdExists(uint uniqueId) internal view returns (bool exists) {
		uint index = uniqueIds[uniqueId];
		return index > 0;
	}

}