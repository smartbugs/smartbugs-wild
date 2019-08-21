pragma solidity ^0.5.0;

interface IBancorNetwork {
	function getReturnByPath(address[] calldata _path, uint256 _amount) external view returns (uint256, uint256);
}

contract BancorPathTest {
	IBancorNetwork bancorNetwork = IBancorNetwork(0x6690819Cb98c1211A8e38790d6cD48316Ed518Db);

	function checkPath(address[] calldata _path, uint256 _amount) payable external returns(uint256, uint256) {
		require(msg.value == 1 wei);
		return bancorNetwork.getReturnByPath(_path, _amount);
	}
}