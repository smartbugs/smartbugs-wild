pragma solidity ^0.4.13;
contract SafeMath {

    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
        uint256 z = x * y;
        assert((x == 0)||(z/x == y));
        return z;
    }
}

contract PrivateCityToken {
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}


contract PrivateCityCrowdsale is SafeMath{

    uint256 public totalSupply;
    // Deposit address of account controlled by the creators
    address public ethFundDeposit = 0x4574C2A0a1C39114Fe794dD1A3D1A5F90C92AD90;
    address public tokenExchangeAddress = 0xD9fc693CA2C5CF060D10E182a078a0A4CFF1F4d6;
    address public tokenAccountAddress = 0xdca42D3220681C3beaF3dD0631D06536c39beB67;
    //Access to token contract for tokens exchange
    PrivateCityToken public tokenExchange;

    // Fundraising parameters
    enum ContractState { Fundraising }
    ContractState public state;

    uint256 public constant decimals = 18;
    //start date: 11/24/2017 @ 00:00 (GMT-8)
    uint public startDate = 1511510400;
    //start date: 1/01/2018 @ 00:00 (GMT-8)
    uint public endDate = 1514793600;
    
    uint256 public constant TOKEN_MIN = 1 * 10**decimals; // 1 PCT

    // We need to keep track of how much ether have been contributed, since we have a cap for ETH too
    uint256 public totalReceivedEth = 0;
	

    // Constructor
    function PrivateCityCrowdsale()
    {
        // Contract state
        state = ContractState.Fundraising;
        tokenExchange = PrivateCityToken(tokenExchangeAddress);
        totalSupply = 0;
    }

    
    function ()
    payable
    external
    {
        require(now >= startDate);
        require(now <= endDate);
        require(msg.value > 0);
        

        // First we check the ETH cap, as it's easier to calculate, return
        // the contribution if the cap has been reached already
        uint256 checkedReceivedEth = safeAdd(totalReceivedEth, msg.value);

        // If all is fine with the ETH cap, we continue to check the
        // minimum amount of tokens
        uint256 tokens = safeMult(msg.value, getCurrentTokenPrice());
        require(tokens >= TOKEN_MIN);

        totalReceivedEth = checkedReceivedEth;
        totalSupply = safeAdd(totalSupply, tokens);
        ethFundDeposit.transfer(msg.value);
        if(!tokenExchange.transferFrom(tokenAccountAddress, msg.sender, tokens)) revert();
            

    }


    /// @dev Returns the current token price
    function getCurrentTokenPrice()
    private
    constant
    returns (uint256 currentPrice)
    {
        return 6000;//bonuses are not implied!
    }

}