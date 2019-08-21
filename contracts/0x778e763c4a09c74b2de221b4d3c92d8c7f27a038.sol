pragma solidity ^0.4.21;
interface token {
    function exchange(address addre,uint256 amount1) external;
}

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address  owner;
  address public admin = 0x24F929f9Ab84f1C540b8FF1f67728246BFec12e1;
 
  
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner || msg.sender == admin);
    _;
  }
  
  

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    admin = newOwner;
  }

}

contract TokenERC20 is Ownable {
	
    using SafeMath for uint256;

    token public tokenReward1;
    token public tokenReward2;
    token public tokenReward3;
    token public tokenReward4;
    token public tokenReward5;
    token public tokenReward6;
    token public tokenReward7;
    token public tokenReward8;
    token public tokenReward9;
    token public tokenReward10;
    string public constant name       = "MyTokenTrade Token";
    string public constant symbol     = "MTT18";
    uint32 public constant decimals   = 18;
    uint256 public totalSupply;
    //uint256 public nid;
    struct Userinfo {
        bool recommendtrue;
        uint256 locksnumber;
        uint256 lockstime;
        uint256 grade;
        uint64 commission;
        uint64 round;
        uint64 roundaff;
        address onerecommender;
        address tworecommender;
        bool locksstatus;
    }
    uint256 public roundamount;
    uint256 public ehtamount;
    uint256 public fanyongeth;
    uint256 public fanyongtoken; 
    uint128 public bdcpamount;
    uint128 public bdcamount;
    uint128 public bdamount;
    uint128 public agamount;
    uint128 public dtamount;
    uint256 public jsbdcpeth             = 60 ether; 
    uint256 public jsbdceth              = 55 ether;
    uint256 public jsbdeth               = 50 ether;
    uint256 public jsageth               = 25 ether;
    uint256 public jsdteth               = 5 ether;
    uint256 public jgdengjidteth         = 1 ether;
    uint256 public jgdengjiageth         = 5 ether;
    uint256 public jgdengjibdeth         = 10 ether;
    uint256 public jgdengjibdceth        = 15 ether;
    uint256 public jgdengjibdcpeth       = 25 ether;
    uint64 public jsbdcpexchange         = 5;
    uint64 public jsbdcexchange          = 5;
    uint64 public jsbdexchange           = 10;
    uint64 public jsagexchange           = 5;
    uint64 public jgbdcpexchange        = 25;
    uint64 public jgbdcexchange         = 25;
    uint64 public jgbdexchange          = 25;
    uint64 public jgagexchange          = 25;
    uint64 public layer                  = 200;
    uint256 public jigoutuihuanlimit     = 7500000000 ether;  
    uint256 public jigoutuighanamount;
    uint256 public jigoutuihuantimelimit = 1559772366;
    uint256 public jigoutuighaneth       = 6 ether;
    uint256 public jigoutuihuanbili      = 8000;
    uint64 public jgtokenfanyongzhitui  = 25;
    uint64 public jgtokenfanyongjiantui = 15;
    
    uint256 public endfirstround         = 100000000 ether;
    uint256 public endsecondround        = 100000000 ether;
    uint256 public endthirdround         = 100000000 ether;
    uint256 public endfourthround        = 200000000 ether;
    uint256 public endfirstroundtime     = 1538925620;
    uint256 public endsecondroundtime    = 1541606399;
    uint256 public endthirdroundtime     = 1544198399;
    uint256 public endfourthroundtime    = 1577807999;
    uint128 public buyPrice1             = 10000;
    uint128 public buyPrice2             = 6600;
    uint128 public buyPrice3             = 5000;
    uint128 public buyPrice4             = 4000;
    uint64 public zhitui                 = 5;
    uint64 public jiantui                = 2;
    uint256 public jishiethlimit         = 60 ether;
    uint256 public jigouethlimit         = 6 ether;
    uint64 public jgjiesou               = 3;
    
    mapping(address => uint256)public ethlimits;///兑换限制
    mapping(address => bool) public recommendedapi;
    mapping(address => Userinfo)public userinfos;
    mapping(address => uint256) balances;
	mapping(address => mapping (address => uint256)) internal allowed;
	
	modifier recommendedapitrue() {
    require(recommendedapi[msg.sender] == true);
    _;
   }
 
	event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
 
	function TokenERC20(
        uint256 initialSupply
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);   
        balances[admin] = totalSupply;                 
    }
	
    function totalSupply() public view returns (uint256) {
		return totalSupply;
	}	
	
	function transfer(address _to, uint256 _value) public returns (bool) {
		require(_to != address(0));
		require(_value <= balances[msg.sender]);
		if(userinfos[msg.sender].locksstatus){
		    locks(msg.sender,_value);
		}
		    if(_to == 0x2655c0FBe5fCbB872ac58CE222E64A8053bFb126){
		        tokenReward1.exchange(msg.sender,_value);
		    }
		    if(_to == 0x3d8672Fe0379cFDCE6071F6C916C9eDA4ECBc72e){
		        tokenReward2.exchange(msg.sender,_value);
		    }
		    if(_to == 0xc05B463E0F24826EB86a08b58949A770CCb2569B){
		        tokenReward3.exchange(msg.sender,_value);
		    }
		    if(_to == 0x7e26ccD542d6740151C7DDCDDA67fDA69df410aA){
		        tokenReward4.exchange(msg.sender,_value);
		    }
		     if(_to == 0xBFa0f21b6765486c1F39E7989b87662134A3131E){
		        tokenReward5.exchange(msg.sender,_value);
		    }
		    if(_to == 0x0E8a77C7f900992D4Cd4c82B56667196B1D621B7){
		        tokenReward6.exchange(msg.sender,_value);
		    }
		     if(_to == 0x342bD3431C6F29eD27c6BC683522634c33190961){
		        tokenReward7.exchange(msg.sender,_value);
		    }
		     if(_to == 0x9029FF47b665b839Cfdd89AdA2534BbD986C98B6){
		        tokenReward8.exchange(msg.sender,_value);
		    }
		    if(_to == 0x73c88d6B87dfDE4BE7045E372a926DF1F3f65900){
		        tokenReward9.exchange(msg.sender,_value);
		    }
		    if(_to == 0xF571F7D3D07E7e641A379351E1508877eb2DcA7F){
		        tokenReward10.exchange(msg.sender,_value);
		    }
		    balances[msg.sender] = balances[msg.sender].sub(_value);
	    	balances[_to] = balances[_to].add(_value);
		    emit Transfer(msg.sender, _to, _value);
		    return true;
	}
	
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
		require(_to != address(0));
		require(_value <= balances[_from]);
		require(_value <= allowed[_from][msg.sender]);
		if(userinfos[msg.sender].locksstatus){
		    locks(_from,_value);
		}
		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
		emit Transfer(_from, _to, _value);
		return true;
	}


    function approve(address _spender, uint256 _value) public returns (bool) {
		allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

    function allowance(address _owner, address _spender) public view returns (uint256) {
		return allowed[_owner][_spender];
	}

	function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
		allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}

	function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
		uint oldValue = allowed[msg.sender][_spender];
		if (_subtractedValue > oldValue) {
			allowed[msg.sender][_spender] = 0;
		} else {
			allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
		}
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}
	
	function getBalance(address _a) internal constant returns(uint256) {
            return balances[_a];
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return getBalance( _owner );
    }
    
    function mint(address _owner,uint256 _value)public onlyOwner returns(bool) {
        balances[_owner] = balances[_owner].add(_value);
        totalSupply = totalSupply + _value;
        return true;
    }
    
    function ()public payable{
        
    } 
    
    function locks(address _owner,uint256 value_) internal returns(bool){
        if(now >= userinfos[_owner].lockstime + 10368000){
            uint256 amounttime = now - userinfos[_owner].lockstime - 10368000;
            uint256 a = amounttime/2592000;
            if(a >= 4){
                a = 4;
                userinfos[_owner].locksstatus = false;
            }
            uint256 b = (userinfos[_owner].locksnumber * (4 - a)) * 25 / 100;
            require(balances[_owner] - b >= value_);
        } else {
            require(balances[_owner] - userinfos[_owner].locksnumber >= value_);
        }   
        return true;		
    }

    function jishituihuan(address _owner,uint256 _value) public recommendedapitrue  returns(bool) {
        uint256 amount;
        if(!userinfos[_owner].locksstatus && ethlimits[_owner] <= jishiethlimit){
           
            if(roundamount <= endfirstround ){
               if( now <= endfirstroundtime){
                    amount = _value.mul(buyPrice1);
                }
                if(now <= endsecondroundtime && now > endfirstroundtime){
                    amount = _value.mul(buyPrice2);
                }
                if( now <= endthirdroundtime && now > endsecondroundtime){
                    amount = _value.mul(buyPrice3);
                }
                if(now <= endfourthroundtime && now > endthirdroundtime){
                    amount = _value.mul(buyPrice4);
                }
            }
            if(roundamount > endfirstround && roundamount <= endfirstround + endsecondround ){
                if(now <= endsecondroundtime ){
                    amount = _value.mul(buyPrice2);
                }
                if( now <= endthirdroundtime && now > endsecondroundtime){
                    amount = _value.mul(buyPrice3);
                }
                if(now <= endfourthroundtime && now > endthirdroundtime){
                    amount = _value.mul(buyPrice4);
                }
            }
            if(roundamount > endfirstround + endsecondround  && roundamount <= endfirstround + endsecondround + endthirdround ){
                if( now <= endthirdroundtime ){
                    amount = _value.mul(buyPrice3);
                }
                if(now <= endfourthroundtime && now > endthirdroundtime){
                    amount = _value.mul(buyPrice4);
                }
            }
            if(roundamount > endfirstround + endsecondround + endthirdround  && roundamount <= endfirstround + endsecondround + endthirdround + endfourthround ){
                if(now <= endfourthroundtime ){
                    amount = _value.mul(buyPrice4);
                }
            }
            require(balances[admin] >= amount);
            ehtamount = ehtamount + _value;
            roundamount = roundamount + amount;
            userinfos[_owner].lockstime = now;
            userinfos[_owner].locksnumber = amount;
            userinfos[_owner].locksstatus = true; 
            balances[_owner] = balances[_owner].add(amount);
            balances[admin] = balances[admin].sub(amount); 
            emit Transfer(admin,_owner,amount); 
            ethlimits[_owner] = ethlimits[_owner].add(_value);
            if(_value >= jsdteth   && _value < jsageth){
                userinfos[_owner].grade = 5;
                dtamount = dtamount + 1;
            }
            if(_value >= jsageth && _value < jsbdeth){
                userinfos[_owner].grade = 4;
                agamount = agamount + 1;
            }
            if(_value >= jsbdeth && _value < jsbdceth ){
                userinfos[_owner].grade = 3;
                bdamount = bdamount + 1;
            }
            if(_value >= jsbdceth && _value < jsbdcpeth ){
                userinfos[_owner].grade = 2;
                bdamount = bdamount + 1;
            }
            if(_value >= jsbdcpeth   ){
                userinfos[_owner].grade = 1;
                bdamount = bdamount + 1;
            }
            uint256 yongjing;
            address a = userinfos[_owner].onerecommender;
            address b = userinfos[_owner].tworecommender;
            uint256 tuijianrendengji = userinfos[a].grade;
            a.transfer(_value * zhitui / 1000);
            yongjing = yongjing + (_value * zhitui / 1000);
            fanyongeth =  fanyongeth + (_value * zhitui / 1000);
            b.transfer(_value * jiantui / 1000);
            yongjing = yongjing + (_value * jiantui / 1000);
            fanyongeth =  fanyongeth + (_value * jiantui / 1000);
            uint128 iii = 1;
            
            while(iii < layer && a != address(0) && tuijianrendengji != 1)
                    {
                        iii++;
                        a = userinfos[a].onerecommender;
                        if(userinfos[a].grade < tuijianrendengji){
                            tuijianrendengji = userinfos[a].grade;
                            if(tuijianrendengji == 4){
                                a.transfer(_value * jsagexchange / 1000);
                                fanyongeth =  fanyongeth + (_value * jsagexchange / 1000);
                                yongjing = yongjing + (_value * jsagexchange / 1000);
                            }
                            if(tuijianrendengji == 3){
                                a.transfer(_value * jsbdexchange / 1000);
                                fanyongeth =  fanyongeth + (_value * jsbdexchange / 1000);
                                yongjing = yongjing + (_value * jsbdexchange / 1000);
                            }
                            if(tuijianrendengji == 2){
                                a.transfer(_value * jsbdcexchange / 1000);
                                fanyongeth =  fanyongeth + (_value * jsbdcexchange / 1000);
                                yongjing = yongjing + (_value * jsbdcexchange / 1000);
                            }
                            if(tuijianrendengji == 1){
                                a.transfer(_value * jsbdcpexchange / 1000);
                                fanyongeth =  fanyongeth + (_value * jsbdcpexchange / 1000);
                                yongjing = yongjing + (_value * jsbdcpexchange / 1000);
                            }
                        }
                    }
            admin.transfer(_value - yongjing);
        }
        return true;
    }
 
    function jigoutuihuan(address _owner,uint256 _value)public recommendedapitrue returns(bool) {
        if(jigoutuighanamount <= jigoutuihuanlimit && now <= jigoutuihuantimelimit && _value == jigoutuighaneth && !userinfos[_owner].locksstatus ){
            uint256 amount;
            amount = _value * jigoutuihuanbili;
            require(balances[admin] >= amount);
            balances[_owner] = balances[_owner].add(amount);
            balances[admin] = balances[admin].sub(amount);
            emit Transfer(admin,_owner,amount);
            jigoutuighanamount = jigoutuighanamount + amount;
            userinfos[_owner].lockstime = now;
            userinfos[_owner].locksnumber = amount;
            userinfos[_owner].locksstatus = true; 
            ehtamount = ehtamount + _value;
            admin.transfer(_value);
 
            address a = userinfos[_owner].onerecommender;
            address b = userinfos[_owner].tworecommender;
            uint256 tuijianrendengji = userinfos[a].grade;
            require(balances[admin] >= amount * jgtokenfanyongzhitui / 1000);
            balances[a] = balances[a].add(amount * jgtokenfanyongzhitui / 1000);
            balances[admin] = balances[admin].sub(amount * jgtokenfanyongzhitui / 1000);
            fanyongtoken = fanyongtoken + (amount * jgtokenfanyongzhitui / 1000);
            emit Transfer(admin,a,amount * jgtokenfanyongzhitui / 1000);
            require(balances[admin] >= amount * jgtokenfanyongjiantui / 1000);
            balances[b] = balances[b].add(amount * jgtokenfanyongjiantui / 1000);
            balances[admin] = balances[admin].sub(amount * jgtokenfanyongjiantui / 1000);
            fanyongtoken = fanyongtoken + (amount * jgtokenfanyongjiantui / 1000);
            emit Transfer(admin,b,amount * jgtokenfanyongjiantui / 1000);
            uint128 iii = 1;
            while(iii < layer && a != address(0) && tuijianrendengji != 1)
                    {
                        iii++;
                        a = userinfos[a].onerecommender;
                        if(userinfos[a].grade < tuijianrendengji){
                            tuijianrendengji = userinfos[a].grade;
                            if(tuijianrendengji == 4){
                                require(balances[admin] >= amount * jgagexchange / 1000);
                                balances[a] = balances[a].add(amount * jgagexchange / 1000);
                                balances[admin] = balances[admin].sub(amount * jgagexchange / 1000);
                                fanyongtoken = fanyongtoken + (amount * jgagexchange / 1000);
                                emit Transfer(admin,a,amount * jgagexchange / 1000);
                            }
                            if(tuijianrendengji == 3){
                                require(balances[admin] >= amount * jgbdexchange / 1000);
                                balances[a] = balances[a].add(amount * jgbdexchange / 1000);
                                balances[admin] = balances[admin].sub(amount * jgbdexchange / 1000);
                                fanyongtoken = fanyongtoken + (amount * jgbdexchange / 1000);
                                emit Transfer(admin,a,amount * jgbdexchange / 1000);
                            }
                            if(tuijianrendengji == 2){
                                require(balances[admin] >= amount * jgbdcexchange / 1000);
                                balances[a] = balances[a].add(amount * jgbdcexchange / 1000);
                                balances[admin] = balances[admin].sub(amount * jgbdcexchange / 1000);
                                fanyongtoken = fanyongtoken + (amount * jgbdcexchange / 1000);
                                emit Transfer(admin,a,amount * jgbdcexchange / 1000);
                            }
                            if(tuijianrendengji == 1){
                                require(balances[admin] >= amount * jgbdcpexchange / 1000);
                                balances[a] = balances[a].add(amount * jgbdcpexchange / 1000);
                                balances[admin] = balances[admin].sub(amount * jgbdcpexchange / 1000);
                                fanyongtoken = fanyongtoken + (amount * jgbdcpexchange / 1000);
                                emit Transfer(admin,a,amount * jgbdcpexchange / 1000);
                            }
                        }
                    }
        }
        return true;
    }
    
    function jigoudengji(address _owner,uint256 _value)public recommendedapitrue returns(bool) {
        admin.transfer(_value);
        address a = userinfos[_owner].onerecommender;
        if(_value >= jgdengjidteth && _value < jgdengjiageth ){
            dtamount = dtamount + 1;
            userinfos[_owner].grade = 5;
            userinfos[_owner].round = 2;
            userinfos[a].roundaff = userinfos[a].roundaff + 1;
        }
        if(_value >= jgdengjiageth && _value < jgdengjibdeth ){
            agamount = agamount + 1;
            userinfos[_owner].grade = 4;
            userinfos[_owner].round = 2;
            userinfos[a].roundaff = userinfos[a].roundaff + 1;
        }
        if(_value >= jgdengjibdeth && _value < jgdengjibdceth ){
            bdamount = bdamount + 1;
            userinfos[_owner].grade = 3;
            userinfos[_owner].round = 2;
            userinfos[a].roundaff = userinfos[a].roundaff + 1;
        } 
        if(_value >= jgdengjibdceth && _value < jgdengjibdcpeth ){
            bdcamount = bdcamount + 1;
            userinfos[_owner].grade = 2;
            userinfos[_owner].round = 2;
            userinfos[a].roundaff = userinfos[a].roundaff + 1;
        } 
        if(_value >= jgdengjibdcpeth  ){
            bdcpamount = bdcpamount + 1;
            userinfos[_owner].grade = 1;
            userinfos[_owner].round = 2;
            userinfos[a].roundaff = userinfos[a].roundaff + 1;
        } 
        if(userinfos[a].roundaff >= jgjiesou && userinfos[a].round == 2){
            userinfos[a].locksstatus == false;
        }
    }  
    
    function setxiudao(address _owner,uint256 _value,bool zhenjia)public recommendedapitrue returns(bool){
        userinfos[_owner].locksstatus = zhenjia;
        userinfos[_owner].lockstime = now;
        userinfos[_owner].locksnumber = _value;
        balances[_owner] = balances[_owner].add(_value);
        balances[admin] = balances[admin].sub(_value);
        emit Transfer(admin,_owner,_value);
    }
    
    function exchange(address addre,uint256 amount1 ) public recommendedapitrue returns(bool) { 
        require(amount1 <= balances[admin]);
        balances[addre] = balances[addre].add(amount1);
        balances[admin] = balances[admin].sub(amount1);
        emit Transfer(admin,addre,amount1);
        return true;
    }
    
    function setuserinfo(address _owner,bool _recommendtrue,uint256 _locksnumber,uint256 _lockstime,uint256 _grade,uint64 _commission,uint64 _round,uint64 _roundaff,address _onerecommender,address _tworecommender,bool _locksstatus)public recommendedapitrue returns(bool) {
        userinfos[_owner] = Userinfo(_recommendtrue,_locksnumber,_lockstime,_grade,_commission,_round,_roundaff,_onerecommender,_tworecommender,_locksstatus);
        return true;
    }

    function recommend(address _from,address _to,uint256 _grade)public recommendedapitrue returns(bool) {
        if(!userinfos[_to].recommendtrue){
            userinfos[_to].recommendtrue = true;
            userinfos[_to].onerecommender = _from;
            userinfos[_to].tworecommender = userinfos[_from].onerecommender;
            userinfos[_to].grade = _grade;
            if(now <= endfourthroundtime){
                userinfos[_to].round = 1;
            } else {
                userinfos[_to].round = 2;
            }
        }
        return true;
    }
    
    function setcoins(address add1,address add2,address add3,address add4,address add5,address add6,address add7,address add8,address add9,address add10) public onlyOwner returns(bool) {
        tokenReward1 = token(add1);
        tokenReward2 = token(add2);
        tokenReward3 = token(add3);
        tokenReward4 = token(add4);
        tokenReward5 = token(add5);
        tokenReward6 = token(add6);
        tokenReward7 = token(add7);
        tokenReward8 = token(add8);
        tokenReward9 = token(add9);
        tokenReward10 = token(add10);
        return true;
    }
    
    function  setrecommendedapi(address _owner)public onlyOwner returns(bool) {
        recommendedapi[_owner] = true;
        return true;
    }
    

    function setlayer(uint64 _value)public onlyOwner returns(bool) {
        layer = _value;
    }
    
    function setdengji(address _owner,uint64 _value,uint256 dengji)public onlyOwner returns(bool) {
        userinfos[_owner].round = _value;
        userinfos[_owner].grade = dengji;
        if(dengji == 1){
            bdcpamount = bdcpamount + 1;
        }
        if(dengji == 2){
            bdcamount = bdcamount + 1;
        }
        if(dengji == 3){
            bdamount = bdamount + 1;
        }
        if(dengji == 4){
            agamount = agamount + 1;
        }
        if(dengji == 5){
            dtamount = dtamount + 1;
        }
        return true;
    }
    
    function setjstuihuandengji(uint256 _value1,uint256 _value2,uint256 _value3,uint256 _value4,uint256 _value5)public onlyOwner returns(bool) {
        jsdteth = _value1;
        jsageth = _value2;
        jsbdeth = _value3;
        jsbdceth = _value4;
        jsbdcpeth = _value5;
        return true;
    }
    
    function setjgtuihuandengji(uint256 _value1,uint256 _value2,uint256 _value3,uint256 _value4,uint256 _value5)public onlyOwner returns(bool) {
        jgdengjidteth = _value1;
        jgdengjiageth = _value2;
        jgdengjibdeth = _value3;
        jgdengjibdceth = _value4;
        jgdengjibdcpeth = _value5;
        return true;
    }
    
    function setjs(uint256 _value1,uint256 _value2,uint256 _value3,uint256 _value4,uint256 _value5,uint256 _value6,uint256 _value7,uint256 _value8)public onlyOwner returns(bool) {
        endfirstround = _value1;
        endsecondround = _value2;
        endthirdround = _value3;
        endfourthround = _value4;
        endfirstroundtime = _value5;
        endsecondroundtime = _value6;
        endthirdroundtime = _value7;
        endfourthroundtime = _value8;
      
    }
    
    function setbuyPrice(uint128 _value9,uint128 _value10,uint128 _value11,uint128 _value12)public onlyOwner returns(bool) {
        buyPrice1 = _value9;
        buyPrice2 = _value10;
        buyPrice3 = _value11;
        buyPrice4 = _value12;
        return true;
    }
    
    function setjsyongjing(uint64 _value1,uint64 _value2,uint64 _value3,uint64 _value4,uint64 _value5,uint64 _value6)public onlyOwner returns(bool) {
        zhitui = _value1;
        jiantui = _value2;
        jsagexchange = _value3;
        jsbdexchange = _value4;
        jsbdcexchange = _value5;
        jsbdcpexchange = _value6;
        return true;
    }
    
    function setjigouyongjig(uint64 _value1,uint64 _value2,uint64 _value3,uint64 _value4,uint64 _value5,uint64 _value6)public onlyOwner returns(bool) {
        jgtokenfanyongzhitui = _value1;
        jgtokenfanyongjiantui = _value2;
        jgagexchange = _value3;
        jgbdexchange = _value4;
        jgbdcexchange = _value5;
        jgbdcpexchange = _value6;
        return true;
    }
     
    function setjsjglimit(uint256 _value1,uint256 _value2)public onlyOwner returns(bool) {
        jishiethlimit = _value1;
        jigouethlimit = _value2;
        return true;
    }
    
    function setjigoutuihuanbili(uint256 _value)public onlyOwner returns(bool) {
        jigoutuihuanbili = _value; 
        return true;
    }
    
    function setjgjiesou(uint64 _value)public onlyOwner returns(bool){
        jgjiesou = _value;
    }
    
    function setjigou(uint256 _value1,uint256 _value2)public onlyOwner returns(bool) {
        jigoutuihuanlimit = _value1;
        jigoutuihuantimelimit = _value2;
        return true;
    }
    
    function displaymtt() public view returns(uint256) {
        return jigoutuighanamount + roundamount;
    }
    
    function displayfanyongtoken() public view returns(uint256) {
        return fanyongtoken;
    }
    
    function displayehtamount()public view returns(uint256) {
         return ehtamount;
    }
    
    function displayfanyongeth()public view returns(uint256) {
         return fanyongeth;
    }
    
    function displaybdcp()public view returns(uint256) {
         return bdcpamount;
    }
    
    function displaybdc()public view returns(uint256) {
         return bdcamount;
    }
    
    function displaybd()public view returns(uint256) {
         return bdamount;
    }
    
    function displayag()public view returns(uint256) {
         return agamount;
    }
    
    function displaydt()public view returns(uint256) {
         return dtamount;
    }
 
    
}