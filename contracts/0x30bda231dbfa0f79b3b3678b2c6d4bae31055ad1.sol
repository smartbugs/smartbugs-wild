contract Assertive {
    function assert(bool assertion) internal {
        if (!assertion) throw;
    }
}

contract MutexUser {
    bool private lock;
    modifier exclusive {
        if (lock) throw;
        lock = true;
        _
        lock = false;
    }
}
contract ERC20 {
    function totalSupply() constant returns (uint);
    function balanceOf(address who) constant returns (uint);
    function allowance(address owner, address spender) constant returns (uint);

    function transfer(address to, uint value) returns (bool ok);
    function transferFrom(address from, address to, uint value) returns (bool ok);
    function approve(address spender, uint value) returns (bool ok);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
contract FallbackFailer {
  function () {
    throw;
  }
}

// A simple direct exchange order manager.

contract EventfulMarket {
    event ItemUpdate( uint id );
    event Trade( uint sell_how_much, address indexed sell_which_token,
                 uint buy_how_much, address indexed buy_which_token );
}
contract SimpleMarket is EventfulMarket
                       , Assertive
                       , FallbackFailer
                       , MutexUser
{
    struct OfferInfo {
        uint sell_how_much;
        ERC20 sell_which_token;
        uint buy_how_much;
        ERC20 buy_which_token;
        address owner;
        bool active;
    }
    mapping( uint => OfferInfo ) public offers;

    uint public last_offer_id;

    function next_id() internal returns (uint) {
        last_offer_id++; return last_offer_id;
    }

    modifier can_offer {
        _
    }
    modifier can_buy(uint id) {
        assert(isActive(id));
        _
    }
    modifier can_cancel(uint id) {
        assert(isActive(id));
        assert(getOwner(id) == msg.sender);
        _
    }
    function isActive(uint id) constant returns (bool active) {
        return offers[id].active;
    }
    function getOwner(uint id) constant returns (address owner) {
        return offers[id].owner;
    }
    function getOffer( uint id ) constant returns (uint, ERC20, uint, ERC20) {
      var offer = offers[id];
      return (offer.sell_how_much, offer.sell_which_token,
              offer.buy_how_much, offer.buy_which_token);
    }

    // non underflowing subtraction
    function safeSub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }
    // non overflowing multiplication
    function safeMul(uint a, uint b) internal returns (uint c) {
        c = a * b;
        assert(a == 0 || c / a == b);
    }

    function trade( address seller, uint sell_how_much, ERC20 sell_which_token,
                    address buyer,  uint buy_how_much,  ERC20 buy_which_token )
        internal
    {
        var seller_paid_out = buy_which_token.transferFrom( buyer, seller, buy_how_much );
        assert(seller_paid_out);
        var buyer_paid_out = sell_which_token.transfer( buyer, sell_how_much );
        assert(buyer_paid_out);
        Trade( sell_how_much, sell_which_token, buy_how_much, buy_which_token );
    }

    // ---- Public entrypoints ---- //

    // Make a new offer. Takes funds from the caller into market escrow.
    function offer( uint sell_how_much, ERC20 sell_which_token
                  , uint buy_how_much,  ERC20 buy_which_token )
        can_offer
        exclusive
        returns (uint id)
    {
        assert(sell_how_much > 0);
        assert(sell_which_token != ERC20(0x0));
        assert(buy_how_much > 0);
        assert(buy_which_token != ERC20(0x0));
        assert(sell_which_token != buy_which_token);

        OfferInfo memory info;
        info.sell_how_much = sell_how_much;
        info.sell_which_token = sell_which_token;
        info.buy_how_much = buy_how_much;
        info.buy_which_token = buy_which_token;
        info.owner = msg.sender;
        info.active = true;
        id = next_id();
        offers[id] = info;

        var seller_paid = sell_which_token.transferFrom( msg.sender, this, sell_how_much );
        assert(seller_paid);

        ItemUpdate(id);
    }
    // Accept given `quantity` of an offer. Transfers funds from caller to
    // offer maker, and from market to caller.
    function buy( uint id, uint quantity )
        can_buy(id)
        exclusive
        returns ( bool success )
    {
        // read-only offer. Modify an offer by directly accessing offers[id]
        OfferInfo memory offer = offers[id];

        // inferred quantity that the buyer wishes to spend
        uint spend = safeMul(quantity, offer.buy_how_much) / offer.sell_how_much;

        if ( spend > offer.buy_how_much || quantity > offer.sell_how_much ) {
            // buyer wants more than is available
            success = false;
        } else if ( spend == offer.buy_how_much && quantity == offer.sell_how_much ) {
            // buyer wants exactly what is available
            delete offers[id];

            trade( offer.owner, quantity, offer.sell_which_token,
                   msg.sender, spend, offer.buy_which_token );

            ItemUpdate(id);
            success = true;
        } else if ( spend > 0 && quantity > 0 ) {
            // buyer wants a fraction of what is available
            offers[id].sell_how_much = safeSub(offer.sell_how_much, quantity);
            offers[id].buy_how_much = safeSub(offer.buy_how_much, spend);

            trade( offer.owner, quantity, offer.sell_which_token,
                    msg.sender, spend, offer.buy_which_token );

            ItemUpdate(id);
            success = true;
        } else {
            // buyer wants an unsatisfiable amount (less than 1 integer)
            success = false;
        }
    }
    // Cancel an offer. Refunds offer maker.
    function cancel( uint id )
        can_cancel(id)
        exclusive
        returns ( bool success )
    {
        // read-only offer. Modify an offer by directly accessing offers[id]
        OfferInfo memory offer = offers[id];
        delete offers[id];

        var seller_refunded = offer.sell_which_token.transfer( offer.owner , offer.sell_how_much );
        assert(seller_refunded);

        ItemUpdate(id);
        success = true;
    }
}

// Simple Market with a market lifetime. When the lifetime has elapsed,
// offers can only be cancelled (offer and buy will throw).

contract ExpiringMarket is SimpleMarket {
    uint public close_time;
    function ExpiringMarket(uint lifetime) {
        close_time = getTime() + lifetime;
    }
    function getTime() constant returns (uint) {
        return block.timestamp;
    }
    function isClosed() constant returns (bool closed) {
        return (getTime() > close_time);
    }

    // after market lifetime has elapsed, no new offers are allowed
    modifier can_offer {
        assert(!isClosed());
        _
    }
    // after close, no new buys are allowed
    modifier can_buy(uint id) {
        assert(isActive(id));
        assert(!isClosed());
        _
    }
    // after close, anyone can cancel an offer
    modifier can_cancel(uint id) {
        assert(isActive(id));
        assert(isClosed() || (msg.sender == getOwner(id)));
        _
    }
}

// Flat file implementation of `dappsys/token/base.sol::DSTokenBase`

// Everything throws instead of returning false on failure.

contract ERC20Base is ERC20
{
    mapping( address => uint ) _balances;
    mapping( address => mapping( address => uint ) ) _approvals;
    uint _supply;
    function ERC20Base( uint initial_balance ) {
        _balances[msg.sender] = initial_balance;
        _supply = initial_balance;
    }
    function totalSupply() constant returns (uint supply) {
        return _supply;
    }
    function balanceOf( address who ) constant returns (uint value) {
        return _balances[who];
    }
    function transfer( address to, uint value) returns (bool ok) {
        if( _balances[msg.sender] < value ) {
            throw;
        }
        if( !safeToAdd(_balances[to], value) ) {
            throw;
        }
        _balances[msg.sender] -= value;
        _balances[to] += value;
        Transfer( msg.sender, to, value );
        return true;
    }
    function transferFrom( address from, address to, uint value) returns (bool ok) {
        // if you don't have enough balance, throw
        if( _balances[from] < value ) {
            throw;
        }
        // if you don't have approval, throw
        if( _approvals[from][msg.sender] < value ) {
            throw;
        }
        if( !safeToAdd(_balances[to], value) ) {
            throw;
        }
        // transfer and return true
        _approvals[from][msg.sender] -= value;
        _balances[from] -= value;
        _balances[to] += value;
        Transfer( from, to, value );
        return true;
    }
    function approve(address spender, uint value) returns (bool ok) {
        _approvals[msg.sender][spender] = value;
        Approval( msg.sender, spender, value );
        return true;
    }
    function allowance(address owner, address spender) constant returns (uint _allowance) {
        return _approvals[owner][spender];
    }
    function safeToAdd(uint a, uint b) internal returns (bool) {
        return (a + b >= a);
    }
}