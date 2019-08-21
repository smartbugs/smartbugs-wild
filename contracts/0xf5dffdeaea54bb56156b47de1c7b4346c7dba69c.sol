pragma solidity ^0.4.16;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {


    address owner;

    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);

    function Ownable() {
        owner = msg.sender;
        OwnershipTransferred (address(0), owner);
    }

    function transferOwnership(address _newOwner)
        public
        onlyOwner
        notZeroAddress(_newOwner)
    {
        owner = _newOwner;
        OwnershipTransferred(msg.sender, _newOwner);
    }

    //Only owner can call function
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier notZeroAddress(address _address) {
        require(_address != address(0));
        _;
    }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {


    /*
        @return sum of a and b
    */
    function ADD (uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    /*
        @return difference of a and b
    */
    function SUB (uint256 a, uint256 b) internal returns (uint256) {
        assert(a >= b);
        return a - b;
    }
    
}

/*	Interface of GeeToken contract */
contract Token {

    function transfer(address _to, uint256 _value) 
        external;

    function burn(uint256 _value) 
        external;

}


contract GEECrowdsale is Ownable {

    using SafeMath for uint256;

    //VARIABLE
    uint256 public soldTokens;                                  //Counts how many Gee coins are soldTokens
    
    uint256 public hardCapInTokens = 67 * (10**6) * (10**8);    //Hard cap in Gee coins (with 8 decimals)
    
    uint256 public constant MIN_ETHER = 0.03 ether;             //Min amount of Ether
    uint256 public constant MAX_ETHER = 1000 ether;             //Max amount of Ether

    
    address fund = 0x48a2909772b049D0eA3A0979eE05eDF37119738d;  //Address where funds are forwarded during the ICO

    
    uint256 public constant START_BLOCK_NUMBER = 4506850;       //Start block
    
    uint256 public constant TIER2 = 4525700;                      //Start + 3 days
    uint256 public constant TIER3 = 4569600;                     //Start + 10 days ( 3 days + 7 days)
    uint256 public constant TIER4 = 4632300;                     //Start + 20 days ( 3 days + 7 days + 10 days)
    uint256 public endBlockNumber = 4695000;                        //Start + 30 days
    uint256 public constant MAX_END_BLOCK_NUMBER = 4890000;         //End + 30 days

    uint256 public price;                                       //GEE price
   
    uint256 public constant TIER1_PRICE = 6000000;              //Price in 1st tier
    uint256 public constant TIER2_PRICE = 6700000;              //Price in 2nd tier
    uint256 public constant TIER3_PRICE = 7400000;              //Price in 3rd tier
    uint256 public constant TIER4_PRICE = 8200000;              //Price in 4th tier

    Token public gee;                                           //GeeToken contract

    uint256 public constant SOFT_CAP_IN_ETHER = 4000 ether;    //softcap in ETH

    uint256 public collected;                                   //saves how much ETH was collected

    uint256 public constant GEE100 = 100 * (10**8);


    //MAP
    mapping (address => uint256) public bought;                 //saves how much ETH user spent on GEE


    //EVENT
    event Buy    (address indexed _who, uint256 _amount, uint256 indexed _price);   //Keep track of buyings
    event Refund (address indexed _who, uint256 _amount);                           //Keep track of refunding
    event CrowdsaleEndChanged (uint256 _crowdsaleEnd, uint256 _newCrowdsaleEnd);    //Notifies users about end block change


    //FUNCTION
    //Payable - can store ETH
    function GEECrowdsale (Token _geeToken)
        public
        notZeroAddress(_geeToken)
        payable
    {
        gee = _geeToken;
    }


    /* Fallback function is called when Ether is sent to the contract */
    function() 
        external 
        payable 
    {
        if (isCrowdsaleActive()) {
            buy();
        } else { 
            require (msg.sender == fund || msg.sender == owner);    //after crowdsale owner can send back eth for refund
        }
    }


    /* Burn unsold GEE after crowdsale */
    function finalize() 
        external
        onlyOwner
    {
        require(soldTokens != hardCapInTokens);
        if (soldTokens < (hardCapInTokens - GEE100)) {
            require(block.number > endBlockNumber);
        }
        hardCapInTokens = soldTokens;
        gee.burn(hardCapInTokens.SUB(soldTokens));
    }


    /* Buy tokens */
    function buy()
        public
        payable
    {
        uint256 amountWei = msg.value;
        uint256 blocks = block.number;


        require (isCrowdsaleActive());
        require(amountWei >= MIN_ETHER);                            //Ether limitation
        require(amountWei <= MAX_ETHER);

        price = getPrice();
        
        uint256 amount = amountWei / price;                         //Count how many GEE sender can buy

        soldTokens = soldTokens.ADD(amount);                        //Add amount to soldTokens

        require(soldTokens <= hardCapInTokens);

        if (soldTokens >= (hardCapInTokens - GEE100)) {
            endBlockNumber = blocks;
        }
        
        collected = collected.ADD(amountWei);                       //counts ETH
        bought[msg.sender] = bought[msg.sender].ADD(amountWei);

        gee.transfer(msg.sender, amount);                           //Transfer amount of Gee coins to msg.sender
        fund.transfer(this.balance);                                //Transfer contract Ether to fund

        Buy(msg.sender, amount, price);
    }


    /* Return Crowdsale status, depending on block numbers and stopInEmergency() state */
    function isCrowdsaleActive() 
        public 
        constant 
        returns (bool) 
    {

        if (endBlockNumber < block.number || START_BLOCK_NUMBER > block.number) {
            return false;
        }
        return true;
    }


    /* Change tier taking block numbers as time */
    function getPrice()
        internal
        constant
        returns (uint256)
    {
        if (block.number < TIER2) {
            return TIER1_PRICE;
        } else if (block.number < TIER3) {
            return TIER2_PRICE;
        } else if (block.number < TIER4) {
            return TIER3_PRICE;
        }

        return TIER4_PRICE;
    }


    /* Refund, if the soft cap is not reached */
    function refund() 
        external 
    {
        uint256 refund = bought[msg.sender];
        require (!isCrowdsaleActive());
        require (collected < SOFT_CAP_IN_ETHER);
        bought[msg.sender] = 0;
        msg.sender.transfer(refund);
        Refund(msg.sender, refund);
    }


    function drainEther() 
        external 
        onlyOwner 
    {
        fund.transfer(this.balance);
    }

    /*
    Allows owner setting the new end block number to extend/close Crowdsale.
    */
    function setEndBlockNumber(uint256 _newEndBlockNumber) external onlyOwner {
        require(isCrowdsaleActive());
        require(_newEndBlockNumber >= block.number);
        require(_newEndBlockNumber <= MAX_END_BLOCK_NUMBER);

        uint256 currentEndBlockNumber = endBlockNumber;
        endBlockNumber = _newEndBlockNumber;
        CrowdsaleEndChanged (currentEndBlockNumber, _newEndBlockNumber);
    }

}