pragma solidity ^0.4.0;

//https://github.com/nexusdev/erc20/blob/master/contracts/erc20.sol

contract ERC20Constant {
    function balanceOf( address who ) constant returns (uint value);
}
contract ERC20Stateful {
    function transfer( address to, uint value) returns (bool ok);
}
contract ERC20Events {
    event Transfer(address indexed from, address indexed to, uint value);
}
contract ERC20 is ERC20Constant, ERC20Stateful, ERC20Events {}

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

// contract can sell tokens for ETH
// prices are in amount of wei per batch of token units

contract TokenTrader is owned {

    address public asset;       // address of token
    uint256 public sellPrice;   // contract sells lots of tokens at this price
    uint256 public units;       // lot size (token-wei)

    bool public sellsTokens;    // is contract selling

    event ActivatedEvent(bool sells);
    event UpdateEvent();

    function TokenTrader (
        address _asset, 
        uint256 _sellPrice, 
        uint256 _units,
        bool    _sellsTokens
        )
    {
          asset         = _asset; 
          sellPrice    = _sellPrice;
          units         = _units; 
          sellsTokens   = _sellsTokens;

          ActivatedEvent(sellsTokens);
    }

    // modify trading behavior
    function activate (
        bool    _sellsTokens
        ) onlyOwner
    {
          sellsTokens   = _sellsTokens;

          ActivatedEvent(sellsTokens);
    }

    // allow owner to remove trade token
    function withdrawAsset(uint256 _value) onlyOwner returns (bool ok)
    {
        return ERC20(asset).transfer(owner,_value);
        UpdateEvent();
    }

    // allow owner to remove arbitrary tokens
    // included just in case contract receives wrong token
    function withdrawToken(address _token, uint256 _value) onlyOwner returns (bool ok)
    {
        return ERC20(_token).transfer(owner,_value);
        UpdateEvent();
    }

    // allow owner to remove ETH
    function withdraw(uint256 _value) onlyOwner returns (bool ok)
    {
        if(this.balance >= _value) {
            return owner.send(_value);
        }
        UpdateEvent();
    }

    //user buys token with ETH
    function buy() payable {
        if(sellsTokens || msg.sender == owner) 
        {
            uint order   = msg.value / sellPrice; 
            uint can_sell = ERC20(asset).balanceOf(address(this)) / units;

            if(order > can_sell)
            {
                uint256 change = msg.value - (can_sell * sellPrice);
                order = can_sell;
                if(!msg.sender.send(change)) throw;
            }

            if(order > 0) {
                if(!ERC20(asset).transfer(msg.sender,order * units)) throw;
            }
            UpdateEvent();
        }
        else if(!msg.sender.send(msg.value)) throw;  // return user funds if the contract is not selling
    }

    // sending ETH to contract sells GNT to user
    function () payable {
        buy();
    }
}

// This contract deploys TokenTrader contracts and logs the event
// trade pairs are identified with sha3(asset,units)

contract TokenTraderFactory {

    event TradeListing(bytes32 bookid, address owner, address addr);
    event NewBook(bytes32 bookid, address asset, uint256 units);

    mapping( address => bool ) _verify;
    mapping( bytes32 => bool ) pairExits;
    
    function verify(address tradeContract)  constant returns (
        bool valid,
        address asset, 
        uint256 sellPrice, 
        uint256 units,
        bool    sellsTokens
        ) {
            
            valid = _verify[tradeContract];
            
            if(valid) {
                TokenTrader t = TokenTrader(tradeContract);
                
                asset = t.asset();
                sellPrice = t.sellPrice();
                units = t.units();
                sellsTokens = t.sellsTokens();
            }
        
    }

    function createTradeContract(       
        address _asset, 
        uint256 _sellPrice, 
        uint256 _units,
        bool    _sellsTokens
        ) returns (address) 
    {
        if(_units == 0) throw;              // can't sell zero units

        address trader = new TokenTrader (
                     _asset, 
                     _sellPrice, 
                     _units,
                     _sellsTokens);

        var bookid = sha3(_asset,_units);

        _verify[trader] = true; // record that this factory created the trader

        TokenTrader(trader).transferOwnership(msg.sender); // set the owner to whoever called the function

        if(pairExits[bookid] == false) {
            pairExits[bookid] = true;
            NewBook(bookid, _asset, _units);
        }

        TradeListing(bookid,msg.sender,trader);
    }

    function () {
        throw;     // Prevents accidental sending of ether to the factory
    }
}