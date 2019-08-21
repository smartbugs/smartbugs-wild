pragma solidity ^0.4.15;
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
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
contract Esla is Ownable{
	struct PersonalInfo{
		string full_name;
		string company;
		string job_title;
		string email;
		string mobile;
		string telephone;
		string fax;
	}
	mapping (address => PersonalInfo) personalInfos;
	address[] public users;
	mapping (address => bool) authorized;
	event Authorized(address indexed user_wallet_address);
  event DeAuthorized(address indexed user_wallet_address);
  event PersonalInfoAdded(address indexed user_wallet_address, string full_name, string company, 
		string job_title, string email, string mobile, string telephone, string fax);
	function Esla(){
		owner = msg.sender;
		authorized[owner] = true;
	}
	function authorize(address user_wallet_address) public onlyOwner{
		authorized[user_wallet_address] = true;
		Authorized(user_wallet_address);
	}
	function deAuthorize(address user_wallet_address) public onlyOwner{
		authorized[user_wallet_address] = false;
		DeAuthorized(user_wallet_address);
	}
	function isAuthorized(address user_wallet_address) public constant returns (bool){
		return authorized[user_wallet_address];
	}
  modifier allowedToAdd() {
    require(authorized[msg.sender]);
    _;
  }
	function addPersonalInfo(address user_wallet_address, string _full_name, string _company, 
		string _job_title, string _email, string _mobile, string _telephone, string _fax) public allowedToAdd returns (bool){
		personalInfos[user_wallet_address] = PersonalInfo(_full_name, _company, _job_title, _email, _mobile, _telephone, _fax);
		PersonalInfo storage personalInfo = personalInfos[user_wallet_address];
		users.push(user_wallet_address);
		PersonalInfoAdded(user_wallet_address, personalInfo.full_name, personalInfo.company, personalInfo.job_title, 
			personalInfo.email, personalInfo.mobile, personalInfo.telephone, personalInfo.fax);
		return true;
	}
	function getPersonalInfo(address user_wallet_address) public constant returns (string, string, string, string, 
		string, string, string){
		PersonalInfo storage personalInfo = personalInfos[user_wallet_address];
		return (personalInfo.full_name, personalInfo.company, personalInfo.job_title, 
			personalInfo.email, personalInfo.mobile, personalInfo.telephone, personalInfo.fax);
	}
	function getUserCount() public constant returns (uint){
		return users.length;
	}
}