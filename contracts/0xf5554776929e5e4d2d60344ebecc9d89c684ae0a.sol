pragma solidity ^0.4.25;

contract WisNetwork {
	using SafeMath for uint256;

	mapping (address => uint256) userDeposit;
	mapping (address => uint256) userPartners;
	mapping (address => uint256) userWithdraw;
	mapping (address => uint256) userBlock;

	uint256 public allDeps = 0;
	uint256 public allPayment = 0;
    uint256 public allUsers = 0;
	address public constant ownerWallet = 0xb6434dEe1CBF061755C2046150cC0d987a768685;
	address public constant ownerWallet2 = 0x62FB5f1fc3B6902f2aD169eC7EE631714aD7bf3A;
	address public constant adsWallet = 0x48090A3425E94d124fcbF7604d49C22B3eaf391c;

	function() payable external {
		uint256 cashAdmin = msg.value.mul(3).div(100);
		uint256 cashAdmin2 = msg.value.mul(2).div(100);
		uint256 cashAdvert = msg.value.mul(10).div(100);

        if (msg.value > 0) {if (userDeposit[msg.sender] == 0) {allUsers += 1;}}

		adsWallet.transfer(cashAdvert);
		ownerWallet.transfer(cashAdmin);
		ownerWallet2.transfer(cashAdmin2);

		if (userDeposit[msg.sender] != 0) {
			address investor = msg.sender;
			uint256 depositsPercents = userDeposit[msg.sender].mul(5).div(100).mul(block.number-userBlock[msg.sender]).div(6500);
			investor.transfer(depositsPercents);
			userWithdraw[msg.sender] += depositsPercents;
			allPayment = allPayment.add(depositsPercents);
		}

		address referrer = bytesToAddress(msg.data); //Wallet partner
		if (referrer > 0x0 && referrer != msg.sender) {
			referrer.transfer(cashAdmin);
			userPartners[referrer] += cashAdmin;
		}
		
		userBlock[msg.sender] = block.number;
		userDeposit[msg.sender] += msg.value;
		allDeps = allDeps.add(msg.value);
	}
	function userDepositAdd(address _address) public view returns (uint256) {return userDeposit[_address];} //Depo add
	function userPayoutAdd(address _address) public view returns (uint256) {return userWithdraw[_address];} //Payout add
	function userDepositInfo(address _address) public view returns (uint256) {
		return userDeposit[_address].mul(5).div(100).mul(block.number-userBlock[_address]).div(6500);} //Depo info
	function userPartnersInfo(address _address) public view returns (uint256) {return userPartners[_address];} //Partners info
	function bytesToAddress(bytes bys) private pure returns (address addr) {assembly {addr := mload(add(bys, 20))}} //BalanceContract
}

library SafeMath {
	function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
		if (_a == 0) {return 0;} c = _a * _b;
		assert(c / _a == _b);return c;
	}
	function div(uint256 _a, uint256 _b) internal pure returns (uint256) {return _a / _b;}
	function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {assert(_b <= _a);return _a - _b;}
	function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {c = _a + _b;assert(c >= _a);return c;}
}