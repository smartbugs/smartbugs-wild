pragma solidity ^0.4.24;

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract SEcoinAbstract {function unlock() public;}

contract SECrowdsale {
        
        using SafeMath for uint256;
        
        // The token being sold
        address constant public SEcoin = 0xe45b7cd82ac0f3f6cfc9ecd165b79d6f87ed2875;//"SEcoin address"
        
        // start and end timestamps where investments are allowed (both inclusive)
        uint256 public startTime;
        uint256 public endTime;
          
        // address where funds are collected
        address public SEcoinWallet = 0x5C737AdC09a0cFA1C9b83E199971a677163ddd07;//"SEcoin all token inside & ICO ether";
        address public SEcoinsetWallet = 0x52873e9191f21a26ddc8b65e5dddbac6b73b69e8;//"control SEcoin SmartContract address"
          
        // how many token units a buyer gets per wei
        uint256 public rate = 6000;//"ICO start rate"
        
        // amount of raised money in wei
        uint256 public weiRaised;
        uint256 public weiSold;
          
        //storage address and amount
        address public SEcoinbuyer;
        address[] public SEcoinbuyerevent;
        uint256[] public SEcoinAmountsevent;
        uint256[] public SEcoinmonth;
        uint public firstbuy;
        uint SEcoinAmounts ;
        uint SEcoinAmountssend;

          
        mapping(address => uint) public icobuyer;
        mapping(address => uint) public icobuyer2;
          
        event TokenPurchase(address indexed purchaser, address indexed SEcoinbuyer, uint256 value, uint256 amount,uint SEcoinAmountssend);
        
     // fallback function can be used to buy tokens
    function () external payable {buyTokens(msg.sender);}
      
    //check buyer
    function buyer(address SEcoinbuyer) internal{
          
        if(icobuyer[msg.sender]==0){
            icobuyer[msg.sender] = firstbuy;
            icobuyer2[msg.sender] = firstbuy;
            firstbuy++;
            //event buyer 
            SEcoinbuyerevent.push(SEcoinbuyer);
            SEcoinAmountsevent.push(SEcoinAmounts);
            SEcoinmonth.push(0);
    
        }else if(icobuyer[msg.sender]!=0){
            uint i = icobuyer2[msg.sender];
            SEcoinAmountsevent[i]=SEcoinAmountsevent[i]+SEcoinAmounts;
            icobuyer2[msg.sender]=icobuyer[msg.sender];}
        }
    
      // low level token purchase function
    function buyTokens(address SEcoinbuyer) public payable {
        require(SEcoinbuyer != address(0x0));
        require(selltime());
        require(msg.value>=1*1e16 && msg.value<=200*1e18);
        
        // calculate token amount to be created
        SEcoinAmounts = calculateObtainedSEcoin(msg.value);
        SEcoinAmountssend= calculateObtainedSEcoinsend(SEcoinAmounts);
        
        // update state
        weiRaised = weiRaised.add(msg.value);
        weiSold = weiSold.add(SEcoinAmounts);
            
        //sendtoken
        require(ERC20Basic(SEcoin).transfer(SEcoinbuyer, SEcoinAmountssend));
            
        //call function
        buyer(msg.sender);
        checkRate();
        forwardFunds();
            
        //write event 
        emit TokenPurchase(msg.sender, SEcoinbuyer, msg.value, SEcoinAmounts,SEcoinAmountssend);
    }
    
    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds() internal {
        SEcoinWallet.transfer(msg.value);
    }
    //calculate Amount
    function calculateObtainedSEcoin(uint256 amountEtherInWei) public view returns (uint256) {
        checkRate();
        return amountEtherInWei.mul(rate);
    }
    function calculateObtainedSEcoinsend (uint SEcoinAmounts)public view returns (uint){
        return SEcoinAmounts.div(10);
    }
    
    // return true if the transaction can buy tokens
    function selltime() internal view returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        return withinPeriod;
    }
    
    // return true if crowdsale event has ended
    function hasEnded() public view returns (bool) {
        bool isEnd = now > endTime || weiRaised >= 299600000*1e18;//ico max token
        return isEnd;
    }
    
    //releaseSEcoin only admin 
    function releaseSEcoin() public returns (bool) {
        require (msg.sender == SEcoinsetWallet);
        require (hasEnded() && startTime != 0);
        SEcoinAbstract(SEcoin).unlock();
    }
    
    //getunselltoken only admin
    function getunselltoken()public returns(bool){
        require (msg.sender == SEcoinsetWallet);
        require (hasEnded() && startTime != 0);
        uint256 remainedSEcoin = ERC20Basic(SEcoin).balanceOf(this)-weiSold;
        ERC20Basic(SEcoin).transfer(SEcoinWallet, remainedSEcoin);    
    }
    
    //backup
    function getunselltokenB()public returns(bool){
        require (msg.sender == SEcoinsetWallet);
        require (hasEnded() && startTime != 0);
        uint256 remainedSEcoin = ERC20Basic(SEcoin).balanceOf(this);
        ERC20Basic(SEcoin).transfer(SEcoinWallet, remainedSEcoin);    
    }
    
    // be sure to get the token ownerships
    function start() public returns (bool) {
        require (msg.sender == SEcoinsetWallet);
        require (firstbuy==0);
        startTime = 1541001600;//startTime
        endTime = 1543593599;//endTime
        SEcoinbuyerevent.push(SEcoinbuyer);
        SEcoinAmountsevent.push(SEcoinAmounts);
        SEcoinmonth.push(0);
        firstbuy=1;
    }
    
    //Change setting Wallet
    function changeSEcoinWallet(address _SEcoinsetWallet) public returns (bool) {
        require (msg.sender == SEcoinsetWallet);
        SEcoinsetWallet = _SEcoinsetWallet;
    }
      
    //ckeckRate
    function checkRate() public returns (bool) {
        if (now>=startTime && now< 1541433599){
            rate = 6000;//section one
        }else if (now >= 1541433599 && now < 1542297599) {
            rate = 5000;//section two
        }else if (now >= 1542297599 && now < 1543161599) {
            rate = 4000;//section three
        }else if (now >= 1543161599)  {
            rate = 3500;//section four
        }
    }
      
    //get ICOtoken in everyMonth
    function getICOtoken(uint number)public returns(string){
        require(SEcoinbuyerevent[number] == msg.sender);
        require(now>=1543593600&&now<=1567267199);
        uint  _month;
        
        //December 2018 two
        if(now>=1543593600 && now<=1546271999 && SEcoinmonth[number]==0){
            require(SEcoinmonth[number]==0);
            ERC20Basic(SEcoin).transfer(SEcoinbuyerevent[number], SEcoinAmountsevent[number].div(10));
            SEcoinmonth[number]=1;
        }
        
        //February January 2019 three
        else if(now>=1546272000 && now<=1548950399 && SEcoinmonth[number]<=1){
            if(SEcoinmonth[number]==1){
            ERC20Basic(SEcoin).transfer(SEcoinbuyerevent[number], SEcoinAmountsevent[number].div(10));
            SEcoinmonth[number]=2;
            }else if(SEcoinmonth[number]<1){
            _month = 2-SEcoinmonth[number];
            ERC20Basic(SEcoin).transfer(SEcoinbuyerevent[number], (SEcoinAmountsevent[number].div(10))*_month); 
            SEcoinmonth[number]=2;}
        }
        
        //February 2019 four
        else if(now>=1548950400 && now<=1551369599 && SEcoinmonth[number]<=2){
            if(SEcoinmonth[number]==2){
            ERC20Basic(SEcoin).transfer(SEcoinbuyerevent[number], SEcoinAmountsevent[number].div(10));
            SEcoinmonth[number]=3;
            }else if(SEcoinmonth[number]<2){
            _month = 3-SEcoinmonth[number];
            ERC20Basic(SEcoin).transfer(SEcoinbuyerevent[number], (SEcoinAmountsevent[number].div(10))*_month); 
            SEcoinmonth[number]=3;}
        }
        
        //March 2019 five
        else if(now>=1551369600 && now<=1554047999 && SEcoinmonth[number]<=3){
            if(SEcoinmonth[number]==3){
            ERC20Basic(SEcoin).transfer(SEcoinbuyerevent[number], SEcoinAmountsevent[number].div(10));
            SEcoinmonth[number]=4;
            }else if(SEcoinmonth[number]<3){
            _month = 4-SEcoinmonth[number];
            ERC20Basic(SEcoin).transfer(SEcoinbuyerevent[number], (SEcoinAmountsevent[number].div(10))*_month); 
            SEcoinmonth[number]=4;}
        }
        
        //April 2019 six
        else if(now>=1554048000 && now<=1556639999 && SEcoinmonth[number]<=4){
            if(SEcoinmonth[number]==4){
            ERC20Basic(SEcoin).transfer(SEcoinbuyerevent[number], SEcoinAmountsevent[number].div(10));
            SEcoinmonth[number]=5;
            }else if(SEcoinmonth[number]<4){
            _month = 5-SEcoinmonth[number];
            ERC20Basic(SEcoin).transfer(SEcoinbuyerevent[number], (SEcoinAmountsevent[number].div(10))*_month); 
           SEcoinmonth[number]=5;}
        }
        
        //May 2019 seven
        else if(now>=1556640000 && now<=1559318399 && SEcoinmonth[number]<=5){
            if(SEcoinmonth[number]==5){
            ERC20Basic(SEcoin).transfer(SEcoinbuyerevent[number], SEcoinAmountsevent[number].div(10));
            SEcoinmonth[number]=6;
            }else if(SEcoinmonth[number]<5){
            _month = 6-SEcoinmonth[number];
            ERC20Basic(SEcoin).transfer(SEcoinbuyerevent[number], (SEcoinAmountsevent[number].div(10))*_month); 
            SEcoinmonth[number]=6;}
        }
        
        //June 2019 eight
        else if(now>=1559318400 && now<=1561910399 && SEcoinmonth[number]<=6){
            if(SEcoinmonth[number]==6){
            ERC20Basic(SEcoin).transfer(SEcoinbuyerevent[number], SEcoinAmountsevent[number].div(10));
            SEcoinmonth[number]=7;
            }else if(SEcoinmonth[number]<6){
            _month = 7-SEcoinmonth[number];
            ERC20Basic(SEcoin).transfer(SEcoinbuyerevent[number], (SEcoinAmountsevent[number].div(10))*_month); 
            SEcoinmonth[number]=7;}
        }
        
        //July 2019 nine August
        else if(now>=1561910400 && now<=1564588799 && SEcoinmonth[number]<=7){
            if(SEcoinmonth[number]==7){
            ERC20Basic(SEcoin).transfer(SEcoinbuyerevent[number], SEcoinAmountsevent[number].div(10));
            SEcoinmonth[number]=8;
            }else if(SEcoinmonth[number]<7){
            _month = 8-SEcoinmonth[number];
            ERC20Basic(SEcoin).transfer(SEcoinbuyerevent[number], (SEcoinAmountsevent[number].div(10))*_month); 
            SEcoinmonth[number]=8;}
        }
            
        //August 2019 ten
        else if(now>=1564588800 && now<=1567267199 && SEcoinmonth[number]<=8){
            if(SEcoinmonth[number]==8){
            ERC20Basic(SEcoin).transfer(SEcoinbuyerevent[number], SEcoinAmountsevent[number].div(10));
            SEcoinmonth[number]=9;
            }else if(SEcoinmonth[number]<8){
            _month = 9-SEcoinmonth[number];
            ERC20Basic(SEcoin).transfer(SEcoinbuyerevent[number], (SEcoinAmountsevent[number].div(10))*_month); 
            SEcoinmonth[number]=9;}
        }    
        
        //get all token
        else if(now<1543593600 || now>1567267199 || SEcoinmonth[number]>=9){
            revert("Get all tokens or endtime");
        }
    }
}