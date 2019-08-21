pragma solidity ^0.4.25;

//LIBRARIES

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
          return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "the SafeMath multiplication check failed");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    	require(b > 0, "the SafeMath division check failed");
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "the SafeMath subtraction check failed");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "the SafeMath addition check failed");
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
	    require(b != 0, "the SafeMath modulo check failed");
	    return a % b;
	 }
}

//CONTRACT INTERFACE

contract OneHundredthMonkey {
	function adminWithdraw() public {}
}

//MAIN CONTRACT

contract FoundationFund {

	using SafeMath for uint256;

	//CONSTANTS

	uint256 public fundsReceived;
	address public masterAdmin;
	address public mainContract;
	bool public mainContractSet = false;

	address public teamMemberA = 0x2597afE84661669E590016E51f8FB0059D1Ad63e;   
	address public teamMemberB = 0x2E6C1b2B4F7307dc588c289C9150deEB1A66b73d;
	address public teamMemberC = 0xB3CaC7157d772A7685824309Dc1eB79497839795;
	address public teamMemberD = 0x87395d203B35834F79B46cd16313E6027AE4c9D4;

	uint256 public teamMemberArate = 30; //30%
	uint256 public teamMemberBrate = 30; //30%
	uint256 public teamMemberCrate = 20; //20% 
	uint256 public teamMemberDrate = 20; //20% 

	mapping (address => uint256) public teamMemberTotal;
	mapping (address => uint256) public teamMemberUnclaimed;
	mapping (address => uint256) public teamMemberClaimed;
	mapping (address => bool) public validTeamMember;
	mapping (address => bool) public isProposedAddress;
	mapping (address => bool) public isProposing;
	mapping (address => uint256) public proposingAddressIndex;

	//CONSTRUCTOR

	constructor() public {
		masterAdmin = msg.sender;
		validTeamMember[teamMemberA] = true;
		validTeamMember[teamMemberB] = true;
		validTeamMember[teamMemberC] = true;
		validTeamMember[teamMemberD] = true;
	}

	//MODIFIERS
	
	modifier isTeamMember() { 
		require (validTeamMember[msg.sender] == true, "you are not a team member"); 
		_; 
	}

	modifier isMainContractSet() { 
		require (mainContractSet == true, "the main contract is not yet set"); 
		_; 
	}

	modifier onlyHumans() { 
        require (msg.sender == tx.origin, "no contracts allowed"); 
        _; 
    }

	//EVENTS
	event fundsIn(
		uint256 _amount,
		address _sender,
		uint256 _totalFundsReceived
	);

	event fundsOut(
		uint256 _amount,
		address _receiver
	);

	event addressChangeProposed(
		address _old,
		address _new
	);

	event addressChangeRemoved(
		address _old,
		address _new
	);

	event addressChanged(
		address _old,
		address _new
	);

	//FUNCTIONS

	//add main contract address 
	function setContractAddress(address _address) external onlyHumans() {
		require (msg.sender == masterAdmin);
		require (mainContractSet == false);
		mainContract = _address;
		mainContractSet = true;
	}

	//withdrawProxy
	function withdrawProxy() external isTeamMember() isMainContractSet() onlyHumans() {
		OneHundredthMonkey o = OneHundredthMonkey(mainContract);
		o.adminWithdraw();
	}

	//team member withdraw
	function teamWithdraw() external isTeamMember() isMainContractSet() onlyHumans() {
	
		//set up for msg.sender
		address user;
		uint256 rate;
		if (msg.sender == teamMemberA) {
			user = teamMemberA;
			rate = teamMemberArate;
		} else if (msg.sender == teamMemberB) {
			user = teamMemberB;
			rate = teamMemberBrate;
		} else if (msg.sender == teamMemberC) {
			user = teamMemberC;
			rate = teamMemberCrate;
		} else if (msg.sender == teamMemberD) {
			user = teamMemberD;
			rate = teamMemberDrate;
		}
		
		//update accounting 
		uint256 teamMemberShare = fundsReceived.mul(rate).div(100);
		teamMemberTotal[user] = teamMemberShare;
		teamMemberUnclaimed[user] = teamMemberTotal[user].sub(teamMemberClaimed[user]);
		
		//safe transfer 
		uint256 toTransfer = teamMemberUnclaimed[user];
		teamMemberUnclaimed[user] = 0;
		teamMemberClaimed[user] = teamMemberTotal[user];
		user.transfer(toTransfer);

		emit fundsOut(toTransfer, user);
	}

	function proposeNewAddress(address _new) external isTeamMember() onlyHumans() {
		require (isProposedAddress[_new] == false, "this address cannot be proposed more than once");
		require (isProposing[msg.sender] == false, "you can only propose one address at a time");

		isProposing[msg.sender] = true;
		isProposedAddress[_new] = true;

		if (msg.sender == teamMemberA) {
			proposingAddressIndex[_new] = 0;
		} else if (msg.sender == teamMemberB) {
			proposingAddressIndex[_new] = 1;
		} else if (msg.sender == teamMemberC) {
			proposingAddressIndex[_new] = 2;
		} else if (msg.sender == teamMemberD) {
			proposingAddressIndex[_new] = 3;
		}

		emit addressChangeProposed(msg.sender, _new);
	}

	function removeProposal(address _new) external isTeamMember() onlyHumans() {
		require (isProposedAddress[_new] == true, "this address must be proposed but not yet accepted");
		require (isProposing[msg.sender] == true, "your address must be actively proposing");

		if (proposingAddressIndex[_new] == 0 && msg.sender == teamMemberA) {
			isProposedAddress[_new] = false;
			isProposing[msg.sender] = false;
		} else if (proposingAddressIndex[_new] == 1 && msg.sender == teamMemberB) {
			isProposedAddress[_new] = false;
			isProposing[msg.sender] = false;
		} else if (proposingAddressIndex[_new] == 2 && msg.sender == teamMemberC) {
			isProposedAddress[_new] = false;
			isProposing[msg.sender] = false;
		} else if (proposingAddressIndex[_new] == 3 && msg.sender == teamMemberD) {
			isProposedAddress[_new] = false;
			isProposing[msg.sender] = false;
		} 

		emit addressChangeRemoved(msg.sender, _new);
	}

	function acceptProposal() external onlyHumans() {
		require (isProposedAddress[msg.sender] == true, "your address must be proposed");
		
		if (proposingAddressIndex[msg.sender] == 0) {
			address old = teamMemberA;
			validTeamMember[old] = false;
			isProposing[old] = false;
			teamMemberA = msg.sender;
			validTeamMember[teamMemberA] = true;
		} else if (proposingAddressIndex[msg.sender] == 1) {
			old = teamMemberB;
			validTeamMember[old] = false;
			isProposing[old] = false;
			teamMemberB = msg.sender;
			validTeamMember[teamMemberB] = true;
		} else if (proposingAddressIndex[msg.sender] == 2) {
			old = teamMemberC;
			validTeamMember[old] = false;
			isProposing[old] = false;
			teamMemberC = msg.sender;
			validTeamMember[teamMemberC] = true;
		} else if (proposingAddressIndex[msg.sender] == 3) {
			old = teamMemberD;
			validTeamMember[old] = false;
			isProposing[old] = false;
			teamMemberD = msg.sender;
			validTeamMember[teamMemberD] = true;
		} 

		isProposedAddress[msg.sender] = false;

		emit addressChanged(old, msg.sender);
	}

	//VIEW FUNCTIONS

	function balanceOf(address _user) public view returns(uint256 _balance) {
		address user;
		uint256 rate;
		if (_user == teamMemberA) {
			user = teamMemberA;
			rate = teamMemberArate;
		} else if (_user == teamMemberB) {
			user = teamMemberB;
			rate = teamMemberBrate;
		} else if (_user == teamMemberC) {
			user = teamMemberC;
			rate = teamMemberCrate;
		} else if (_user == teamMemberD) {
			user = teamMemberD;
			rate = teamMemberDrate;
		} else {
			return 0;
		}

		uint256 teamMemberShare = fundsReceived.mul(rate).div(100);
		uint256 unclaimed = teamMemberShare.sub(teamMemberClaimed[_user]); 

		return unclaimed;
	}

	function contractBalance() public view returns(uint256 _contractBalance) {
	    return address(this).balance;
	}

	//FALLBACK

	function () public payable {
		fundsReceived += msg.value;
		emit fundsIn(msg.value, msg.sender, fundsReceived); 
	}
}