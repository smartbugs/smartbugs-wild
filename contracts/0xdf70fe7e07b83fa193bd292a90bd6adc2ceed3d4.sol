pragma solidity ^0.4.24;

// ----------------------------------------------------------------------------
// ExchangeArbitrage token contract
//
// Symbol      : EXARB
// Name        : Exchange Arbitrage Token
// Decimals    : 18
//
// ----------------------------------------------------------------------------


library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract Owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

contract ExchangeArbitrageToken is Owned {
    using SafeMath for uint;

    string public symbol = "EXARB";
    string public name = "Exchange Arbitrage Token";
    uint8 public decimals = 18;

    uint minted_tokens;
    uint exchange_rate;
    uint max_minted_supply;
    uint cash_out_rate;

    mapping(address => mapping (address => uint)) allowed;

    event Transfer(address indexed from, address indexed to, uint tokens);
    event MintTokens(address from, uint amount);

    event ExchangeRateSet(uint exchange_rate);
    event CashOutRateSet(uint exchange_rate);
    event MaxMintedSupplySet(uint max_minted_supply);
    event Approval(address tokenOwner, address spender, uint tokens);

    // historical tracking of balances at a particular block
    mapping(address => BlockBalance[]) block_balances;
    struct BlockBalance {
        uint block_id;
        uint balance;
    }

    // keep track of which token owners picked up their payout amounts
    // ( token_owner => ( payout_id => paid_out_amount ) )
    mapping(address => mapping(uint16 => uint)) collected_payouts;

    // basic array that has all of the payout ids
    uint16[] payout_ids;

    // mapping that has the payout details.
    mapping(uint16 => PayoutBlock) payouts;
    struct PayoutBlock {
        uint block_id;
        uint amount;
        uint minted_tokens;
    }

    constructor() public payable {
        minted_tokens = 0;
        exchange_rate = 210;
        cash_out_rate = 50000000000000;
        max_minted_supply = 450000000000000000000000;
        emit MaxMintedSupplySet(max_minted_supply);
        emit CashOutRateSet(cash_out_rate);
        emit ExchangeRateSet(exchange_rate);
    }

    function totalSupply() public view returns (uint) {
        return minted_tokens;
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return getTokenBalanceOf(tokenOwner);
    }

    function allowance(address tokenOwner, address spender) public constant returns(uint remaining){
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(tokens > 0, "Transfer must be positive.");
        require(allowed[from][msg.sender] >= tokens, "Not enough allowed tokens.");
        subtractTokenBalanceFrom(from, tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        addTokenBalanceTo(to, tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function ownershipPercentageOf(address tokenOwner) public view returns (uint percentage_8_decimals) {
        return balanceOf(tokenOwner).mul(10000000000).div(minted_tokens);
    }

    function allPayoutIds() public view returns (uint16[]) {
        return payout_ids;
    }

    function getPayoutAmountForId(uint16 payout_id) public view returns (uint) {
        return payouts[payout_id].amount;
    }

    function getPayoutBlockForId(uint16 payout_id) public view returns (uint) {
        return payouts[payout_id].block_id;
    }

    function ethToTokenExchangeRate() public view returns (uint) {
        return exchange_rate;
    }

    function limitMintedSupply() public view returns (uint) {
        return max_minted_supply;
    }

    function limitCashOutRate() public view returns (uint) {
        return cash_out_rate;
    }

    function payoutAmountFor(uint16 payout_id) public view returns (uint) {
        require(payouts[payout_id].block_id > 0, "Invalid payout_id");
        require(block_balances[msg.sender].length > 0, "This address has no history on this contract.");

        PayoutBlock storage payout_block = payouts[payout_id];
        BlockBalance memory relevant_block;
        for(uint i = 0; i < block_balances[msg.sender].length; i++) {
            if (block_balances[msg.sender][i].block_id < payout_block.block_id  ) {
                relevant_block = block_balances[msg.sender][i];
            }
        }
        return relevant_block.balance.mul(payout_block.amount).div(payout_block.minted_tokens);
    }

    function payoutCollected(uint16 payout_id) public view returns (bool) {
        return collected_payouts[msg.sender][payout_id] > 0;
    }

    function payoutCollect(uint16 payout_id) public returns (bool success) {
        require(collected_payouts[msg.sender][payout_id] == 0, "Payment already collected");
        uint payout = payoutAmountFor(payout_id);
        require(address(this).balance >= payout, "Balance is too low.");
        collected_payouts[msg.sender][payout_id] = payout;
        msg.sender.transfer(payout);
        return true;
    }

    function calculateCashOut() public view returns (uint amount) {
        uint current_token_balance = getTokenBalanceOf(msg.sender);
        uint payout = current_token_balance.mul(cash_out_rate).div(1000000000000000000);
        return payout;
    }

    function cashOut() public returns (bool success) {
        uint current_token_balance = getTokenBalanceOf(msg.sender);
        require(current_token_balance > 0, 'Address has no balance');
        uint payout = current_token_balance.mul(cash_out_rate).div(1000000000000000000);
        subtractTokenBalanceFrom(msg.sender, current_token_balance);
        minted_tokens = minted_tokens.sub(current_token_balance);
        msg.sender.transfer(payout);
        return true;
    }

    // Allow anyone to transfer to anyone else as long as they have enough balance.
    function transfer(address to, uint tokens) public returns (bool success) {
        require(tokens > 0, "Transfer must be positive.");

        subtractTokenBalanceFrom(msg.sender, tokens);
        addTokenBalanceTo(to, tokens);

        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function () public payable {
        if (msg.sender != owner){
            require(msg.value.mul(exchange_rate) + minted_tokens < max_minted_supply, "Contract Fully Funded.  Try again later.");
            mint(msg.sender, msg.value);
            if (!owner.send(msg.value)) { revert(); }
        } else {
            require(msg.value > 0);  // owner sent funds.  keep on contract for payouts.
        }
    }

    // ----------------------------------------------------------------------------
    //   private functions
    // ----------------------------------------------------------------------------

    function mint(address sender, uint value) private {
        uint tokens = value.mul(exchange_rate);
        addTokenBalanceTo(sender, tokens);
        minted_tokens = minted_tokens.add(tokens);
        emit MintTokens(sender, tokens);
    }

    function getTokenBalanceOf(address tokenOwner) private view returns (uint tokens) {
        uint owner_block_balance_length = block_balances[tokenOwner].length;
        if (owner_block_balance_length == 0) {
            return 0;
        } else {
            return block_balances[tokenOwner][owner_block_balance_length-1].balance;
        }
    }

    function addTokenBalanceTo(address tokenOwner, uint value) private {
        uint owner_block_balance_length = block_balances[tokenOwner].length;
        if (owner_block_balance_length == 0) {
            block_balances[tokenOwner].push(BlockBalance({ block_id: block.number, balance: value }));
        } else {
            BlockBalance storage owner_last_block_balance = block_balances[tokenOwner][owner_block_balance_length-1];

            uint owner_current_balance = getTokenBalanceOf(tokenOwner);

            // if we have never had any payouts or there has been no payout since the last time the user sent eth.
            //   --> reuse the last location
            // else --> create a new location
            if (payout_ids.length == 0 || owner_last_block_balance.block_id > payouts[payout_ids[payout_ids.length-1]].block_id ) {
                // overwrite last item in the array.
                block_balances[tokenOwner][owner_block_balance_length-1] = BlockBalance({ block_id: block.number, balance: owner_current_balance.add(value) });
            } else {
                block_balances[tokenOwner].push(BlockBalance({ block_id: block.number, balance: owner_current_balance.add(value) }));
            }
        }
    }

    function subtractTokenBalanceFrom(address tokenOwner, uint value) private {
        uint owner_block_balance_length = block_balances[tokenOwner].length;
        if (owner_block_balance_length == 0) {
            revert('Can not remove balance from an address with no history.');
        } else {
            BlockBalance storage owner_last_block_balance = block_balances[tokenOwner][owner_block_balance_length-1];

            uint owner_current_balance = getTokenBalanceOf(tokenOwner);

            // if we have never had any payouts or there has been no payout since the last time the user sent eth.
            //   --> reuse the last location
            // else --> create a new location
            if (payout_ids.length == 0 || owner_last_block_balance.block_id > payouts[payout_ids[payout_ids.length-1]].block_id ) {
                // overwrite last item in the array.
                block_balances[tokenOwner][owner_block_balance_length-1] = BlockBalance({ block_id: block.number, balance: owner_current_balance.sub(value) });
            } else {
                block_balances[tokenOwner].push(BlockBalance({ block_id: block.number, balance: owner_current_balance.sub(value) }));
            }
        }

    }

    // ----------------------------------------------------------------------------
    //   onlyOwner functions.
    // ----------------------------------------------------------------------------

    function payout(uint16 payout_id, uint amount) public onlyOwner returns (bool success) {
        require(payouts[payout_id].block_id == 0);
        payouts[payout_id] = PayoutBlock({ block_id: block.number, amount: amount, minted_tokens: minted_tokens });
        payout_ids.push(payout_id);
        return true;
    }

    function setExchangeRate(uint newRate) public onlyOwner returns (bool success) {
        exchange_rate = newRate;
        emit ExchangeRateSet(newRate);
        return true;
    }

    function setCashOutRate(uint newRate) public onlyOwner returns (bool success) {
        cash_out_rate = newRate;
        emit CashOutRateSet(newRate);
        return true;
    }

    function setMaxMintedSupply(uint newMaxMintedSupply) public onlyOwner returns (bool success) {
        max_minted_supply = newMaxMintedSupply;
        emit MaxMintedSupplySet(max_minted_supply);
        return true;
    }

    function ownerTransfer(address from, address to, uint tokens) public onlyOwner returns (bool success) {
        require(tokens > 0, "Transfer must be positive.");

        subtractTokenBalanceFrom(from, tokens);
        addTokenBalanceTo(to, tokens);

        emit Transfer(from, to, tokens);
        return true;
    }

    function ownerMint(address to, uint tokens) public onlyOwner returns (bool success) {
        addTokenBalanceTo(to, tokens);
        minted_tokens = minted_tokens.add(tokens);
        emit MintTokens(to, tokens);
        return true;
    }

    function destroy() public onlyOwner {
        selfdestruct(owner);
    }

}