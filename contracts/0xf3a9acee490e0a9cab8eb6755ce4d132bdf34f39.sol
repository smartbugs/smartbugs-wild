pragma solidity ^0.4.23;
/*
* giff
* giff
* giff
* giff
* giff
* giff
* giff
* giff
* giff
*
* Author:  Konstantin G...
* Telegram: @bunnygame (en)
* talk : https://bitcointalk.org/index.php?topic=5025885.0
* discord : https://discordapp.com/invite/G2jt4Fw
* email: info@bunnycoin.co
* site : http://bunnycoin.co 
*/
contract Ownable {
    address owner;        
    constructor() public {
        owner = msg.sender; 
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function transferOwner(address _add) public onlyOwner {
        if (_add != address(0)) {
            owner = _add;
        }
    }  
}
 
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
  
}


contract PublicInterface { 
    function transferFrom(address _from, address _to, uint32 _tokenId) public returns (bool);
    function ownerOf(uint32 _tokenId) public view returns (address owner);
    function isUIntPublic() public view returns(bool);
    //function setAllowedChangeSex( uint32 _bunny, bool canBunny) public;
    //function ownerOf(uint32 _tokenId) public view returns (address owner);

    function getAllowedChangeSex(uint32 _bunny) public view returns(bool);
    function getBirthCount(uint32 _bunny) public view returns(uint);
    function getBirthLastTime(uint32 _bunny) public view returns(uint);
    function getRabbitSirePrice(uint32 _bunny) public view returns(uint);
    function setAllowedChangeSex( uint32 _bunny, bool canBunny) public;
    function setRabbitSirePrice( uint32 _bunny, uint count) external;
}

contract Gift  is Ownable { 
    event SendGift(address from, address to, uint32 bunnyId);
    event ChengeSex(uint32 bunnyId, bool sex, uint256 price);



    using SafeMath for uint256;

    uint256 bigPrice = 0.003 ether;
    function setBigPrice(uint _bigPrice) public onlyOwner() {
        bigPrice = _bigPrice;
    }
    uint32[12] public cooldowns = [
        uint32(1 minutes),
        uint32(2 minutes),
        uint32(4 minutes),
        uint32(8 minutes),
        uint32(16 minutes),
        uint32(32 minutes),
        uint32(1 hours),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(16 hours),
        uint32(1 days)
    ];


    bool public pause = false; 
    uint public totalGift = 0; 
    uint public lastGiftTime = 0; 
  
    uint public commission_system = 5;
    
    address public lastGift; 
    address public pubAddress; 

    PublicInterface publicContract; 
 
    constructor() public { 
        transferContract(0x2Ed020b084F7a58Ce7AC5d86496dC4ef48413a24);
    }
    function transferContract(address _pubAddress) public onlyOwner {
        require(_pubAddress != address(0)); 
        pubAddress = _pubAddress;
        publicContract = PublicInterface(_pubAddress);
    } 
    function setPause() public onlyOwner {
        pause = !pause;
    }
    function isPauseSave() public  view returns(bool){
        return !pause;
    } 
     
    function getSirePrice(uint32 _tokenId) public view returns(uint) {
        if(publicContract.getRabbitSirePrice(_tokenId) != 0){
            uint procent = (publicContract.getRabbitSirePrice(_tokenId) / 100);
            uint res = procent.mul(25);
            uint system  = procent.mul(commission_system);
            res = res.add( publicContract.getRabbitSirePrice(_tokenId));
            return res.add(system); 
        } else {
            return 0;
        }

    }




    
    function setRabbitSirePrice(uint32 _rabbitid, uint price) public {
        require(isPauseSave());
        require(publicContract.ownerOf(_rabbitid) == msg.sender);
        require(price > bigPrice);
        require(publicContract.getAllowedChangeSex(_rabbitid));
        require(publicContract.getRabbitSirePrice(_rabbitid) != price);
        uint lastTime;
        (lastTime,,) = getcoolduwn(_rabbitid);
        require(now >= lastTime);
        publicContract.setRabbitSirePrice(_rabbitid, price);
        emit ChengeSex(_rabbitid, true, getSirePrice(_rabbitid));

    }
    function setSireStop(uint32 _rabbitid) public returns(bool) {
        require(isPauseSave());
        require(publicContract.getRabbitSirePrice(_rabbitid) !=0);

        require(publicContract.ownerOf(_rabbitid) == msg.sender);
     //   require(rabbits[(_rabbitid-1)].role == 0);
        publicContract.setRabbitSirePrice( _rabbitid, 0);
     //   deleteSire(_rabbitid);
        emit ChengeSex(_rabbitid, false, 0);
        return true;
    }



    function sendGift(uint32 _bunnyId, address _to) public {
        require(isPauseSave());
        require(checkContract());
        require(ownerOf(_bunnyId) == msg.sender);
        require(_to != address(0)); 
        publicContract.transferFrom(msg.sender, _to, _bunnyId); 
        publicContract.setAllowedChangeSex( _bunnyId, true);
        lastGift = msg.sender; 
        totalGift = totalGift + 1;
        lastGiftTime = block.timestamp;
        emit SendGift(msg.sender, _to, _bunnyId);
    }  



    function ownerOf(uint32 _bunnyId) public  view returns(address) {
        return publicContract.ownerOf(_bunnyId);
    } 
    function checkContract() public view returns(bool) {
        return publicContract.isUIntPublic(); 
    }
    function isUIntPublic() public view returns(bool) {
        require(isPauseSave());
        return true;
    }
    /**
     *  we get cooldown
     */
    function getcoolduwn(uint32 _mother) public view returns(uint lastTime, uint cd, uint lefttime) {
        cd = publicContract.getBirthCount(_mother);
        if(cd > 11) {
            cd = 11;
        }
        // time when I can give birth
        lastTime = (cooldowns[cd] + publicContract.getBirthLastTime(_mother));
        if(lastTime > now) {
            // I can not give birth, it remains until delivery
            lefttime = lastTime.sub(now);
        }
    }
}