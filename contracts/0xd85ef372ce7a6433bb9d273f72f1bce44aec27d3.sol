pragma solidity ^0.4.8;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

contract CryptoFishing {
    
    using SafeMath for uint256;
    
    address lastBonusPlayer;
    uint256 lastBonusAmount;
    
    address owner;
    
    event finishFishing(address player, uint256 awardAmount, uint awardType);
    
    constructor() public {
        owner = msg.sender;
    }
    
    function getLastBonus() public view returns (address, uint256) {
        return (lastBonusPlayer, lastBonusAmount);
    }
    
    function randomBonus(uint256 a, uint256 b, uint256 fee) private view returns (uint256) {
        uint256 bonus = randomRange(a, b) * fee / 10;
        return bonus;
    }
    
    function calcBonus(uint poolType, uint256 fee) private view returns (uint256, uint) {
        uint256 rn = random() % 1000000;
        
        uint256 bonus = 0;
        uint fishId = 0;
        
        if(rn <= 100) {
            uint256 total = address(this).balance;
            bonus = total.div(2);
            fishId = 90001;
        } else if(poolType == 1) {
            if(rn < 200000) {
                bonus = 0;
                fishId = 0;
            } else if(rn < 400000) {
                bonus = randomBonus(1, 5, fee);
                fishId = 10001;
            } else if(rn < 550000) {
                bonus = randomBonus(6, 10, fee);
                fishId = 10002;
            } else if(rn < 750000) {
                bonus = randomBonus(11, 11, fee);
                fishId = 10003;
            } else if(rn < 878000) {
                bonus = randomBonus(12, 12, fee);
                fishId = 10004;
            } else if(rn < 928000) {
                bonus = randomBonus(13, 13, fee);
                fishId = 10005;
            } else if(rn < 948000) {
                bonus = randomBonus(14, 14, fee);
                fishId = 10006;
            } else if(rn < 958000) {
                bonus = randomBonus(15, 15, fee);
                fishId = 10007;
            } else if(rn < 961000) {
                bonus = randomBonus(16, 20, fee);
                fishId = 10008;
            } else if(rn < 971000) {
                bonus = randomBonus(21, 30, fee);
                fishId = 10009;
            } else if(rn < 981000) {
                bonus = randomBonus(31, 40, fee);
                fishId = 10010;
            } else if(rn < 986000) {
                bonus = randomBonus(41, 50, fee);
                fishId = 10011;
            } else if(rn < 990000) {
                bonus = randomBonus(51, 60, fee);
                fishId = 10012; 
            } else if(rn < 994000) {
                bonus = randomBonus(61, 70, fee);
                fishId = 10013; 
            } else if(rn < 997000) {
                bonus = randomBonus(71, 80, fee);
                fishId = 10014; 
            } else if(rn < 999000) {
                bonus = randomBonus(81, 90, fee);
                fishId = 10015; 
            } else if(rn < 1000000) {
                bonus = randomBonus(91, 100, fee);
                fishId = 10016; 
            }
        } else if(poolType == 2) {   
            if(rn < 100000) {
                bonus = 0;
                fishId = 0;
            } else if(rn < 300000) {
                bonus = randomBonus(1, 5, fee);
                fishId = 20001;
            } else if(rn < 543000) {
                bonus = randomBonus(6, 10, fee);
                fishId = 20002;
            } else if(rn < 743000) {
                bonus = randomBonus(11, 11, fee);
                fishId = 20003;
            } else if(rn < 893000) {
                bonus = randomBonus(12, 12, fee);
                fishId = 20004;
            } else if(rn < 963000) {
                bonus = randomBonus(13, 13, fee);
                fishId = 20005;
            } else if(rn < 983000) {
                bonus = randomBonus(14, 14, fee);
                fishId = 20006;
            } else if(rn < 993000) {
                bonus = randomBonus(15, 15, fee);
                fishId = 20007;
            } else if(rn < 996000) {
                bonus = randomBonus(16, 20, fee);
                fishId = 20008;
            } else if(rn < 997000) {
                bonus = randomBonus(21, 50, fee);
                fishId = 20009;
            } else if(rn < 998000) {
                bonus = randomBonus(51, 100, fee);
                fishId = 20010;
            } else if(rn < 998800) {
                bonus = randomBonus(101, 150, fee);
                fishId = 20011;
            } else if(rn < 999100) {
                bonus = randomBonus(151, 200, fee);
                fishId = 20012;
            } else if(rn < 999300) {
                bonus = randomBonus(201, 250, fee);
                fishId = 20013;
            } else if(rn < 999500) {
                bonus = randomBonus(251, 300, fee);
                fishId = 20014;
            } else if(rn < 999700) {
                bonus = randomBonus(301, 350, fee);
                fishId = 20015;
            } else if(rn < 999800) {
                bonus = randomBonus(351, 400, fee);
                fishId = 20016;
            } else if(rn < 999900) {
                bonus = randomBonus(401, 450, fee);
                fishId = 20017;
            } else if(rn < 1000000) {
                bonus = randomBonus(451, 500, fee);
                fishId = 20018;
            } 
        } else if(poolType == 3) {     
            if(rn < 300000) {
                bonus = randomBonus(1, 5, fee);
                fishId = 30001;
            } else if(rn < 600000) {
                bonus = randomBonus(6, 10, fee);
                fishId = 30002;
            } else if(rn < 800000) {
                bonus = randomBonus(11, 11, fee);
                fishId = 30003;
            } else if(rn < 917900) {
                bonus = randomBonus(12, 12, fee);
                fishId = 30004;
            } else if(rn < 967900) {
                bonus = randomBonus(13, 13, fee);
                fishId = 30005;
            } else if(rn < 982900) {
                bonus = randomBonus(14, 14, fee);
                fishId = 30006;
            } else if(rn < 989900) {
                bonus = randomBonus(15, 15, fee);
                fishId = 30007;
            } else if(rn < 993900) {
                bonus = randomBonus(16, 20, fee);
                fishId = 30008;
            } else if(rn < 995900) {
                bonus = randomBonus(21, 50, fee);
                fishId = 30009;
            } else if(rn < 997900) {
                bonus = randomBonus(51, 100, fee);
                fishId = 30010;
            } else if(rn < 998200) {
                bonus = randomBonus(101, 150, fee);
                fishId = 30011;
            } else if(rn < 998500) {
                bonus = randomBonus(151, 200, fee);
                fishId = 30012;
            } else if(rn < 998700) {
                bonus = randomBonus(201, 250, fee);
                fishId = 30013;
            } else if(rn < 998900) {
                bonus = randomBonus(251, 300, fee);
                fishId = 30014;
            } else if(rn < 999100) {
                bonus = randomBonus(301, 350, fee);
                fishId = 30015;
            } else if(rn < 999200) {
                bonus = randomBonus(351, 400, fee);
                fishId = 30016;
            } else if(rn < 999300) {
                bonus = randomBonus(401, 450, fee);
                fishId = 30017;
            } else if(rn < 999400) {
                bonus = randomBonus(451, 500, fee);
                fishId = 30018;
            } else if(rn < 999500) {
                bonus = randomBonus(501, 550, fee);
                fishId = 30019;
            } else if(rn < 999600) {
                bonus = randomBonus(551, 600, fee);
                fishId = 30020;
            } else if(rn < 999650) {
                bonus = randomBonus(601, 650, fee);
                fishId = 30021;
            } else if(rn < 999700) {
                bonus = randomBonus(651, 700, fee);
                fishId = 30022;
            } else if(rn < 999750) {
                bonus = randomBonus(701, 750, fee);
                fishId = 30023;
            } else if(rn < 999800) {
                bonus = randomBonus(751, 800, fee);
                fishId = 30024;
            } else if(rn < 999850) {
                bonus = randomBonus(801, 850, fee);
                fishId = 30025;
            } else if(rn < 999900) {
                bonus = randomBonus(851, 900, fee);
                fishId = 30026;
            } else if(rn < 999950) {
                bonus = randomBonus(901, 950, fee);
                fishId = 30027;
            } else if(rn < 1000000) {
                bonus = randomBonus(951, 1000, fee);
                fishId = 30028;
            }
        }
        
        return (bonus, fishId);
    }
        
    function doFishing(uint poolType) public payable {
        uint256 fee = msg.value;
        
        require( (poolType == 1 && fee == 0.05 ether)
                  || (poolType == 2 && fee == 0.25 ether)
                  || (poolType == 3 && fee == 0.5 ether)
                  , 'error eth amount');
        
        uint256 reserveFee = fee.div(20);
        owner.transfer(reserveFee);
        
        uint256 bonus;
        uint fishId;
        
        (bonus,fishId) = calcBonus(poolType, fee);
        
        uint256 nowBalance = address(this).balance;
        
        uint256 minRemain = uint256(0.1 ether);

        if(bonus + minRemain > nowBalance) {
            if(nowBalance > minRemain) {
                bonus = nowBalance - minRemain;
            } else {
                bonus = 0;
            }
        }
        
        if(bonus > 0) {
            lastBonusPlayer = msg.sender;
            lastBonusAmount = bonus;
            msg.sender.transfer(bonus);
        }
        
        emit finishFishing(msg.sender, bonus, fishId);
    }
    
    function charge() public payable {
    }
    
    function randomRange(uint256 a, uint256 b) private view returns (uint256) {
        assert(a <= b);
        uint256 rn = random();
        return a + rn % (b - a + 1);
    } 
    
    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, lastBonusPlayer, lastBonusAmount)));
    }
}