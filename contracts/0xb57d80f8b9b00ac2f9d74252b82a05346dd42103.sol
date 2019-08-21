// BitFrank.com : The unstoppable on-chain exchange of ERC20 tokens
// Copyright (c) 2018. All rights reserved.

pragma solidity ^0.4.20;

contract SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
}

contract ERC20 {
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(address src, address dst, uint wad) public returns (bool);
}

contract BitFrank is SafeMath {
    
    address public admin;
    
    string public constant name = "BitFrank v1";
    bool public suspendDeposit = false; // if we are upgrading to a new contract, deposit will be suspended, but you can still withdraw / trade
 
    // market details for each TOKEN
    struct TOKEN_DETAIL {
        uint8 level; // 1 = listed, 2 = registered, 3 = verified (by admin), MAX = 9
        uint fee; // fee for taker. 100 = 0.01%, 1000 = 0.1%, 10000 = 1%, 1000000 = 100%
    }
    uint public marketRegisterCost = 99 * (10 ** 16); // 0.99 ETH
    uint public marketDefaultFeeLow = 2000; // 0.2%
    uint public marketDefaultFeeHigh = 8000; // 0.8%
    
    mapping (address => TOKEN_DETAIL) public tokenMarket; // registered token details
    address[] public tokenList; // list of registered tokens
    
    mapping (address => mapping (address => uint)) public balance; // balance[tokenAddr][userAddr]
    mapping (address => mapping (address => uint)) public balanceLocked; // token locked in orders
    
    uint public globalOrderSerial = 100000; // always increasing
    uint public PRICE_FACTOR = 10 ** 18; // all prices are multiplied by PRICE_FACTOR
    
    struct ORDER {
        address token;
        bool isBuy; // buy or sell
        address user; // userMaker
        uint wad;
        uint wadFilled;
        uint price; // all prices are multiplied by PRICE_FACTOR
        uint listPosition; // position in orderList, useful when updating orderList
    }
    
    mapping (uint => ORDER) public order; // [orderID] => ORDER
    uint[] public orderList; // list of orderIDs

    //============== EVENTS ==============
    
    event MARKET_CHANGE(address indexed token);
    event DEPOSIT(address indexed user, address indexed token, uint wad, uint result);
    event WITHDRAW(address indexed user, address indexed token, uint wad, uint result);
    event ORDER_PLACE(address indexed user, address indexed token, bool isBuy, uint wad, uint price, uint indexed id);
    event ORDER_CANCEL(address indexed user, address indexed token, uint indexed id);
    event ORDER_MODIFY(address indexed user, address indexed token, uint indexed id, uint new_wad, uint new_price);
    event ORDER_FILL(address indexed userTaker, address userMaker, address indexed token, bool isOriginalOrderBuy, uint fillAmt, uint price, uint indexed id);
    event ORDER_DONE(address indexed userTaker, address userMaker, address indexed token, bool isOriginalOrderBuy, uint fillAmt, uint price, uint indexed id);
    
    //============== ORDER PLACEMENT & TRADE ==============
    
    // get order list count
    
    function getOrderCount() public constant returns (uint) {
        return orderList.length;
    }
    
    // limit order @ price (all prices are multiplied by PRICE_FACTOR)
    
    function orderPlace(address token, bool isBuy, uint wad, uint price) public {
        
        uint newLocked;
        if (isBuy) { // buy token, lock ETH
            newLocked = add(balanceLocked[0][msg.sender], mul(wad, price) / PRICE_FACTOR);
            require(balance[0][msg.sender] >= newLocked);
            balanceLocked[0][msg.sender] = newLocked;
        } else { // sell token, lock token
            newLocked = add(balanceLocked[token][msg.sender], wad);
            require(balance[token][msg.sender] >= newLocked);
            balanceLocked[token][msg.sender] = newLocked;
        }
        
        // place order
        ORDER memory o;
        o.token = token;
        o.isBuy = isBuy;
        o.wad = wad;
        o.price = price;
        o.user = msg.sender;
        o.listPosition = orderList.length; // position in orderList
        order[globalOrderSerial] = o;
        
        // update order list with orderID = globalOrderSerial
        orderList.push(globalOrderSerial);
        
        // event
        ORDER_PLACE(msg.sender, token, isBuy, wad, price, globalOrderSerial);

        globalOrderSerial++; // can never overflow
    }
    
    // market order to take order @ price (all prices are multiplied by PRICE_FACTOR)
    
    function orderTrade(uint orderID, uint wad, uint price) public {
        
        ORDER storage o = order[orderID];
        require(price == o.price); // price must match, because maker can modify price
        
        // fill amt
        uint fillAmt = sub(o.wad, o.wadFilled);
        if (fillAmt > wad) fillAmt = wad;
        
        // fill ETH and fee
        uint fillETH = mul(fillAmt, price) / PRICE_FACTOR;
        uint fee = mul(fillETH, tokenMarket[o.token].fee) / 1000000;
    
        uint newTakerBalance;
        
        if (o.isBuy) { // taker is selling token to maker
            
            // remove token from taker (check balance first)
            newTakerBalance = sub(balance[o.token][msg.sender], fillAmt);
            require(newTakerBalance >= balanceLocked[o.token][msg.sender]);
            balance[o.token][msg.sender] = newTakerBalance;
            
            // remove ETH from maker
            balance[0][o.user] = sub(balance[0][o.user], fillETH);
            balanceLocked[0][o.user] = sub(balanceLocked[0][o.user], fillETH);
            
            // give token to maker
            balance[o.token][o.user] = add(balance[o.token][o.user], fillAmt);
            
            // give ETH (after fee) to taker 
            balance[0][msg.sender] = add(balance[0][msg.sender], sub(fillETH, fee));
            
        } else { // taker is buying token from maker
        
            // remove ETH (with fee) from taker (check balance first)
            newTakerBalance = sub(balance[0][msg.sender], add(fillETH, fee));
            require(newTakerBalance >= balanceLocked[0][msg.sender]);
            balance[0][msg.sender] = newTakerBalance;

            // remove token from maker
            balance[o.token][o.user] = sub(balance[o.token][o.user], fillAmt);
            balanceLocked[o.token][o.user] = sub(balanceLocked[o.token][o.user], fillAmt);
            
            // give ETH to maker
            balance[0][o.user] = add(balance[0][o.user], fillETH);

            // give token to taker
            balance[o.token][msg.sender] = add(balance[o.token][msg.sender], fillAmt);
        }
        
        balance[0][admin] = add(balance[0][admin], fee);

        // fill order
        o.wadFilled = add(o.wadFilled, fillAmt);
        
        // remove filled order
        if (o.wadFilled >= o.wad) {

            // update order list
            orderList[o.listPosition] = orderList[orderList.length - 1];
            order[orderList[o.listPosition]].listPosition = o.listPosition; // update position in orderList
            orderList.length--;
            
            // delete order
            ORDER_DONE(msg.sender, o.user, o.token, o.isBuy, fillAmt, price, orderID);

            delete order[orderID];
            
        } else {
            ORDER_FILL(msg.sender, o.user, o.token, o.isBuy, fillAmt, price, orderID);
        }
    }
    
    function orderCancel(uint orderID) public {
        // make sure the order is correct
        ORDER memory o = order[orderID]; // o is not modified
        require(o.user == msg.sender);

        uint wadLeft = sub(o.wad, o.wadFilled);

        // release remained amt
        if (o.isBuy) { // release ETH
            balanceLocked[0][msg.sender] = sub(balanceLocked[0][msg.sender], mul(o.price, wadLeft) / PRICE_FACTOR);
        } else { // release token
            balanceLocked[o.token][msg.sender] = sub(balanceLocked[o.token][msg.sender], wadLeft);
        }

        ORDER_CANCEL(msg.sender, o.token, orderID);
        
        // update order list
        orderList[o.listPosition] = orderList[orderList.length - 1];
        order[orderList[o.listPosition]].listPosition = o.listPosition; // update position in orderList
        orderList.length--;
        
        // delete order
        delete order[orderID];
    }
    
    function orderModify(uint orderID, uint new_wad, uint new_price) public {
        // make sure the order is correct
        ORDER storage o = order[orderID]; // o is modified
        require(o.user == msg.sender);
        require(o.wadFilled == 0); // for simplicity, you can't change filled orders
        
        // change amount of locked assets
        
        uint newLocked;
        if (o.isBuy) { // lock ETH
            newLocked = sub(add(balanceLocked[0][msg.sender], mul(new_wad, new_price) / PRICE_FACTOR), mul(o.wad, o.price) / PRICE_FACTOR);
            require(balance[0][msg.sender] >= newLocked);
            balanceLocked[0][msg.sender] = newLocked;
        } else { // lock token
            newLocked = sub(add(balanceLocked[o.token][msg.sender], new_wad), o.wad);
            require(balance[o.token][msg.sender] >= newLocked);
            balanceLocked[o.token][msg.sender] = newLocked;
        }
    
        // modify order
        o.wad = new_wad;
        o.price = new_price;
        
        ORDER_MODIFY(msg.sender, o.token, orderID, new_wad, new_price);
    }
  
    //============== ADMINISTRATION ==============
  
    function BitFrank() public {
        admin = msg.sender;
        
        adminSetMarket(0, 9, 0); // ETH, level 9, fee = 0
    }
    
    // set admin
    function adminSetAdmin(address newAdmin) public {
        require(msg.sender == admin);
        require(balance[0][newAdmin] > 0); // newAdmin must have deposits
        admin = newAdmin;
    }
    
    // suspend deposit (prepare for upgrading to a new contract)
    function adminSuspendDeposit(bool status) public {
        require(msg.sender == admin);
        suspendDeposit = status;
    }
    
    // set market details
    function adminSetMarket(address token, uint8 level_, uint fee_) public {
        require(msg.sender == admin);
        require(level_ != 0);
        require(level_ <= 9);
        if (tokenMarket[token].level == 0) {
            tokenList.push(token);
        }
        tokenMarket[token].level = level_;
        tokenMarket[token].fee = fee_;
        MARKET_CHANGE(token);
    }
    
    // set register cost
    function adminSetRegisterCost(uint cost_) public {
        require(msg.sender == admin);
        marketRegisterCost = cost_;
    }
    
    // set default fee
    function adminSetDefaultFee(uint marketDefaultFeeLow_, uint marketDefaultFeeHigh_) public {
        require(msg.sender == admin);
        marketDefaultFeeLow = marketDefaultFeeLow_;
        marketDefaultFeeHigh = marketDefaultFeeHigh_;
    }
    
    //============== MARKET REGISTRATION & HELPER ==============

    // register token
    function marketRegisterToken(address token) public payable {
        require(tokenMarket[token].level == 1);
        require(msg.value >= marketRegisterCost); // register cost
        balance[0][admin] = add(balance[0][admin], msg.value);
        
        tokenMarket[token].level = 2;
        tokenMarket[token].fee = marketDefaultFeeLow;
        MARKET_CHANGE(token);
    }
    
    // get token list count
    function getTokenCount() public constant returns (uint) {
        return tokenList.length;
    }
  
    //============== DEPOSIT & WITHDRAW ==============
  
    function depositETH() public payable {
        require(!suspendDeposit);
        balance[0][msg.sender] = add(balance[0][msg.sender], msg.value);
        DEPOSIT(msg.sender, 0, msg.value, balance[0][msg.sender]);
    }

    function depositToken(address token, uint wad) public {
        require(!suspendDeposit);
        // remember to call TOKEN(address).approve(this, wad) first
        require(ERC20(token).transferFrom(msg.sender, this, wad)); // transfer token
        
        // add new token to list
        if (tokenMarket[token].level == 0) {
            tokenList.push(token);
            tokenMarket[token].level = 1;
            tokenMarket[token].fee = marketDefaultFeeHigh;
            MARKET_CHANGE(token);
        }
        
        balance[token][msg.sender] = add(balance[token][msg.sender], wad); // set balance
        DEPOSIT(msg.sender, token, wad, balance[token][msg.sender]);
    }

    function withdrawETH(uint wad) public {
        balance[0][msg.sender] = sub(balance[0][msg.sender], wad); // set amt first
        require(balance[0][msg.sender] >= balanceLocked[0][msg.sender]); // can't withdraw locked ETH
        msg.sender.transfer(wad); // send ETH
        WITHDRAW(msg.sender, 0, wad, balance[0][msg.sender]);
    }
    
    function withdrawToken(address token, uint wad) public {
        require(token != 0); // not for withdrawing ETH
        balance[token][msg.sender] = sub(balance[token][msg.sender], wad);
        require(balance[token][msg.sender] >= balanceLocked[token][msg.sender]); // can't withdraw locked token
        require(ERC20(token).transfer(msg.sender, wad)); // send token
        WITHDRAW(msg.sender, token, wad, balance[token][msg.sender]);
    }
}