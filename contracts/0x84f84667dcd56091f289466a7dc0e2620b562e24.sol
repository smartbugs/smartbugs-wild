pragma solidity ^0.4.24;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}

contract Factory{
	function getExchange(address token_addr) public view returns(address);
}

contract Exchange{
	function tokenToEthSwapInput(uint256 token_sold, uint256 min_eth,uint256 deadline) public returns(uint256);
}

contract ERC20 {
    function balanceOf(address _owner) view public returns(uint256);
    function allowance(address _owner, address _spender) view public returns(uint256);
    function transfer(address _to, uint256 _value) public returns(bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool);
    function approve(address _spender, uint256 _value) public returns(bool);
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns(bool);
}

contract CryptoCow is ERC20{
	function selltoken(uint256 _amount) public;
	function buyToken() public payable;
}

contract CowSwap{
	Factory factory = Factory(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95);
	CryptoCow cow = CryptoCow(0xFDb0065240753FEF4880a9CC7876be59E09D78BB);

	function () public payable{}

	function tokenToCow(address token, uint256 amount) public {

		ERC20 erc20 = ERC20(token);
		address t = factory.getExchange(token);
		require(t != address(0));
		Exchange te = Exchange(t);

		require(erc20.transferFrom(msg.sender, address(this), amount));
		erc20.approve(t, amount);
		te.tokenToEthSwapInput(amount, 1, now);

		uint256 ethIn = address(this).balance;
		cow.buyToken.value(ethIn)();

		uint256 cowBought = cow.balanceOf(address(this));
		cow.transfer(msg.sender, cowBought);
	}
}