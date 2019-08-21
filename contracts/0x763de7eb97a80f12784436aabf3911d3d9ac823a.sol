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

contract PrivateCityTokens {
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}


contract PCICO is SafeMath{

    uint256 public totalSupply;
    // Deposit address of account controlled by the creators
    address public ethFundDeposit = 0x48084911fdA6C97aa317516f2d21dD3e4698FC54;
    address public tokenExchangeAddress = 0x009f0e67dbaf4644603c0660e974cf5e34726481;
    address public tokenAccountAddress = 0x3c1F16a8D4B56889D4F6E49cc49b47B5c4287751;
    //Access to token contract for tokens exchange
    PrivateCityTokens public tokenExchange;

    // Fundraising parameters
    enum ContractState { Fundraising }
    ContractState public state;           // Current state of the contract

    uint256 public constant decimals = 18;
    //start date: 08/07/2017 @ 12:00am (UTC)
    uint public startDate = 1506521932;
    //start date: 09/21/2017 @ 11:59pm (UTC)
    uint public endDate = 1510761225;
    
    uint256 public constant TOKEN_MIN = 1 * 10**decimals; // 1 PCT

    // We need to keep track of how much ether have been contributed, since we have a cap for ETH too
    uint256 public totalReceivedEth = 0;
	

    // Constructor
    function PCICO()
    {
        // Contract state
        state = ContractState.Fundraising;
        tokenExchange = PrivateCityTokens(tokenExchangeAddress);
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
        return 800;//bonuses are not implied!
    }

}