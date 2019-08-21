pragma solidity ^0.4.23;

/*
______ _   _ _   _  _   ___   __
| ___ \ | | | \ | || \ | \ \ / /
| |_/ / | | |  \| ||  \| |\ V / 
| ___ \ | | | . ` || . ` | \ /  
| |_/ / |_| | |\  || |\  | | |  
\____/ \___/\_| \_/\_| \_/ \_/   
 _____   ___  ___  ___ _____    
|  __ \ / _ \ |  \/  ||  ___|   
| |  \// /_\ \| .  . || |__     
| | __ |  _  || |\/| ||  __|    
| |_\ \| | | || |  | || |___    
 \____/\_| |_/\_|  |_/\____/ 
*
* Author:  Konstantin G...
* Telegram: @bunnygame (en)
* talk : https://bitcointalk.org/index.php?topic=5025885.0
* discord : https://discordapp.com/invite/G2jt4Fw
* email: info@bunnycoin.co
* site : http://bunnycoin.co 
*/
 
contract Ownable {
    
    address ownerCEO;
    address ownerMoney;  
    address privAddress = 0x23a9C3452F3f8FF71c7729624f4beCEd4A24fa55; 
    address public addressTokenBunny = 0x2Ed020b084F7a58Ce7AC5d86496dC4ef48413a24;
    
    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public { 
        ownerCEO = msg.sender; 
        ownerMoney = msg.sender;
    }
 
  /**
   * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner() {
        require(msg.sender == ownerCEO);
        _;
    }
   
    function transferOwnership(address add) public onlyOwner {
        if (add != address(0)) {
            ownerCEO = add;
        }
    }
 
    function transferOwnerMoney(address _ownerMoney) public  onlyOwner {
        if (_ownerMoney != address(0)) {
            ownerMoney = _ownerMoney;
        }
    }
 
    function getOwnerMoney() public view onlyOwner returns(address) {
        return ownerMoney;
    } 
    /**
    *  @dev private contract
     */
    function getPrivAddress() public view onlyOwner returns(address) {
        return privAddress;
    }

} 


contract Whitelist is Ownable {
    mapping(address => bool) public whitelist;

    mapping(uint  => address)   whitelistCheck;
    uint public countAddress = 0;

    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);
 
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender]);
        _;
    }

    constructor() public {
            whitelist[msg.sender] = true;  
    }

    function addAddressToWhitelist(address addr) onlyWhitelisted public returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;

            countAddress = countAddress + 1;
            whitelistCheck[countAddress] = addr;

            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

    function getWhitelistCheck(uint key) onlyWhitelisted view public returns(address) {
        return whitelistCheck[key];
    }


    function getInWhitelist(address addr) public view returns(bool) {
        return whitelist[addr];
    }
    function getOwnerCEO() public onlyWhitelisted view returns(address) {
        return ownerCEO;
    }
 
    function addAddressesToWhitelist(address[] addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }
    
    function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }

    function removeAddressesFromWhitelist(address[] addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
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
 contract ERC721 {
    // Required methods 

    function ownerOf(uint32 _tokenId) public view returns (address owner);
    function approve(address _to, uint32 _tokenId) public returns (bool success);
    function transfer(address _to, uint32 _tokenId) public;
    function transferFrom(address _from, address _to, uint32 _tokenId) public returns (bool);
    function totalSupply() public view returns (uint total);
    function balanceOf(address _owner) public view returns (uint balance);
 }
/// @title Interface new rabbits address
contract PrivateRabbitInterface {
    function getNewRabbit(address from)  public view returns (uint);
    function mixDNK(uint dnkmother, uint dnksire, uint genome)  public view returns (uint);
    function isUIntPrivate() public pure returns (bool);
}

contract TokenBunnyInterface { 
    
    function isPromoPause() public view returns(bool);
    function setTokenBunny(uint32 mother, uint32  sire, uint birthblock, uint birthCount, uint birthLastTime, uint genome, address _owner, uint DNK) external returns(uint32);
    function publicSetTokenBunnyTest(uint32 mother, uint32  sire, uint birthblock, uint birthCount, uint birthLastTime, uint genome, address _owner, uint DNK) public; 
    function setMotherCount( uint32 _bunny, uint count) external;
    function setRabbitSirePrice( uint32 _bunny, uint count) external;
    function setAllowedChangeSex( uint32 _bunny, bool canBunny) public;
    function setTotalSalaryBunny( uint32 _bunny, uint count) external;
    function setRabbitMother(uint32 children, uint32[5] _m) external; 
    function setDNK( uint32 _bunny, uint dnk) external;
    function setGiffBlock(uint32 _bunny, bool blocked) external;
    function transferFrom(address _from, address _to, uint32 _tokenId) public returns(bool);
    function setOwnerGennezise(address _to, bool canYou) external;
    function setBirthCount(uint32 _bunny, uint birthCount) external;
    function setBirthblock(uint32 _bunny, uint birthblock) external; 
    function setBirthLastTime(uint32 _bunny, uint birthLastTime) external;
    // getters
    function getOwnerGennezise(address _to) public view returns(bool);
    function getAllowedChangeSex(uint32 _bunny) public view returns(bool);
    function getRabbitSirePrice(uint32 _bunny) public view returns(uint);
    function getTokenOwner(address owner) public view returns(uint total, uint32[] list); 
    function getMotherCount(uint32 _mother) public view returns(uint);
    function getTotalSalaryBunny(uint32 _bunny) public view returns(uint);
    function getRabbitMother( uint32 mother) public view returns(uint32[5]);
    function getRabbitMotherSumm(uint32 mother) public view returns(uint count);
    function getDNK(uint32 bunnyid) public view returns(uint);
    function getSex(uint32 _bunny) public view returns(bool);
    function isUIntPublic() public view returns(bool);
    function balanceOf(address _owner) public view returns (uint);
    function totalSupply() public view returns (uint total); 
    function ownerOf(uint32 _tokenId) public view returns (address owner);
    function getBunnyInfo(uint32 _bunny) external view returns( uint32 mother, uint32 sire, uint birthblock, uint birthCount, uint birthLastTime, bool role, uint genome, bool interbreed, uint leftTime, uint lastTime, uint price, uint motherSumm);
    function getTokenBunny(uint32 _bunny) public view returns(uint32 mother, uint32 sire, uint birthblock, uint birthCount, uint birthLastTime, uint genome);
    function getGiffBlock(uint32 _bunny) public view returns(bool);
    function getGenome(uint32 _bunny) public view returns( uint);
    function getParent(uint32 _bunny) public view returns(uint32 mother, uint32 sire);
    function getBirthLastTime(uint32 _bunny) public view returns(uint);
    function getBirthCount(uint32 _bunny) public view returns(uint);
    function getBirthblock(uint32 _bunny) public view returns(uint);
        
}

contract BaseRabbit  is Whitelist, ERC721 {
    event EmotherCount(uint32 mother, uint summ); 
    event ChengeSex(uint32 bunnyId, bool sex, uint256 price);
    event SalaryBunny(uint32 bunnyId, uint cost); 
    event CoolduwnMother(uint32 bunnyId, uint num);
    event Referral(address from, uint32 matronID, uint32 childID, uint currentTime);
    event Approval(address owner, address approved, uint32 tokenId);
    event OwnerBunnies(address owner, uint32  tokenId);
    event Transfer(address from, address to, uint32 tokenId);
    event CreateChildren(uint32 matron, uint32 sire, uint32 child);
    TokenBunnyInterface TokenBunny;
    PrivateRabbitInterface privateContract; 

    /**
    * @dev setting up a new address for a private contract
    */
    function setToken(address _addressTokenBunny ) public returns(bool) {
        addressTokenBunny = _addressTokenBunny;
        TokenBunny = TokenBunnyInterface(_addressTokenBunny);
    } 
    /**
    * @dev setting up a new address for a private contract
    */
    function setPriv(address _privAddress) public returns(bool) {
        privAddress = _privAddress;
        privateContract = PrivateRabbitInterface(_privAddress);
    } 
    function isPriv() public view returns(bool) {
        return privateContract.isUIntPrivate();
    }
    modifier checkPrivate() {
        require(isPriv());
        _;
    }

    using SafeMath for uint256;
    bool pauseSave = false;
    uint256 bigPrice = 0.003 ether;
    uint public commission_system = 5;
    uint public totalGen0 = 0;
    uint public promoGen0 = 15000; 
    bool public promoPause = false;

    function setPromoGen0(uint _promoGen0) public onlyWhitelisted() {
        promoGen0 = _promoGen0;
    }
    function setPromoPause() public onlyWhitelisted() {
        promoPause = !promoPause;
    }
    function setBigPrice(uint _bigPrice) public onlyWhitelisted() {
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
    struct Rabbit { 
        uint32 mother;
        uint32 sire; 
        uint birthblock;
        uint birthCount;
        uint birthLastTime;
        uint genome; 
    }
}

contract BodyRabbit is BaseRabbit {
    uint public totalBunny = 0;
    string public constant name = "CryptoRabbits";
    string public constant symbol = "CRB";

    constructor() public { 
        setPriv(privAddress); 
        setToken(addressTokenBunny ); 
    }
    function ownerOf(uint32 _tokenId) public view returns (address owner) {
        return TokenBunny.ownerOf(_tokenId);
    }
    function balanceOf(address _owner) public view returns (uint balance) {
        return TokenBunny.balanceOf(_owner);
    }
    function transfer(address _to, uint32 _tokenId) public {
     _to;_tokenId;
    }
  function approve(address _to, uint32 _tokenId) public returns (bool success) {
     _to;_tokenId;
      return false;
  }
  
 
    function getSirePrice(uint32 _tokenId) public view returns(uint) {
        if(TokenBunny.getRabbitSirePrice(_tokenId) != 0){
            uint procent = (TokenBunny.getRabbitSirePrice(_tokenId) / 100);
            uint res = procent.mul(25);
            uint system  = procent.mul(commission_system);
            res = res.add( TokenBunny.getRabbitSirePrice(_tokenId));
            return res.add(system); 
        } else {
            return 0;
        }

    }

    function transferFrom(address _from, address _to, uint32 _tokenId) public onlyWhitelisted() returns(bool) {
        if(TokenBunny.transferFrom(_from, _to, _tokenId)){ 
            emit Transfer(_from, _to, _tokenId);
            return true;
        }
        return false;
    }  

    function isPauseSave() public view returns(bool) {
        return !pauseSave;
    }
    
    function isPromoPause() public view returns(bool) {
        if (getInWhitelist(msg.sender)) {
            return true;
        } else {
            return !promoPause;
        } 
    }

    function setPauseSave() public onlyWhitelisted()  returns(bool) {
        return pauseSave = !pauseSave;
    }
 

    function getTokenOwner(address owner) public view returns(uint total, uint32[] list) {
        (total, list) = TokenBunny.getTokenOwner(owner);
    } 


    function setRabbitMother(uint32 children, uint32 mother) internal { 
        require(children != mother);
        uint32[11] memory pullMother;
        uint32[5] memory rabbitMother = TokenBunny.getRabbitMother(mother);
        uint32[5] memory arrayChildren;
        uint start = 0;
        for (uint i = 0; i < 5; i++) {
            if (rabbitMother[i] != 0) {
              pullMother[start] = uint32(rabbitMother[i]);
              start++;
            } 
        }
        pullMother[start] = mother;
        start++;
        for (uint m = 0; m < 5; m++) {
             if(start >  5){
                    arrayChildren[m] = pullMother[(m+1)];
             }else{
                    arrayChildren[m] = pullMother[m];
             }
        }
        TokenBunny.setRabbitMother(children, arrayChildren);
        uint c = TokenBunny.getMotherCount(mother);
        TokenBunny.setMotherCount( mother, c.add(1));
    }

    // function uintToBytes(uint v) internal pure returns (bytes32 ret) {
    //     if (v == 0) {
    //         ret = '0';
    //     } else {
    //     while (v > 0) {
    //             ret = bytes32(uint(ret) / (2 ** 8));
    //             ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
    //             v /= 10;
    //         }
    //     }
    //     return ret;
    // }

    function sendMoney(address _to, uint256 _money) internal { 
        _to.transfer((_money/100)*95);
        ownerMoney.transfer((_money/100)*5); 
    }

    function getOwnerGennezise(address _to) public view returns(bool) { 
        return TokenBunny.getOwnerGennezise(_to);
    }

    function totalSupply() public view returns (uint total){ 
        return TokenBunny.totalSupply();
    }
    
    function getBreed(uint32 _bunny) public view returns(bool interbreed)
        {
            uint birtTime = 0;
            uint birthCount = 0;
            (, , , birthCount, birtTime, ) = TokenBunny.getTokenBunny(_bunny);

            uint  lastTime = uint(cooldowns[birthCount]);
            lastTime = lastTime.add(birtTime);
 
            if(lastTime <= now && TokenBunny.getSex(_bunny) == false) {
                interbreed = true;
            }
    }
    function getcoolduwn(uint32 _mother) public view returns(uint lastTime, uint cd, uint lefttime) {
        uint birthLastTime;
         (, , , cd, birthLastTime, ) = TokenBunny.getTokenBunny(_mother);

        if(cd > 11) {
            cd = 11;
        }
        lastTime = (cooldowns[cd] + birthLastTime);
        if(lastTime > now) {
            // I can not give birth, it remains until delivery
            lefttime = lastTime.sub(now);
        }
    }
     function getMotherCount(uint32 _mother) public view returns(uint) { //internal
        return TokenBunny.getMotherCount(_mother);
    }
     function getTotalSalaryBunny(uint32 _bunny) public view returns(uint) { //internal
        return TokenBunny.getTotalSalaryBunny(_bunny);
    }
    function getRabbitMother( uint32 mother) public view returns(uint32[5]) {
        return TokenBunny.getRabbitMother(mother);
    }
     function getRabbitMotherSumm(uint32 mother) public view returns(uint count) { //internal
        uint32[5] memory rabbitMother = TokenBunny.getRabbitMother(mother);
        for (uint m = 0; m < 5 ; m++) {
            if(rabbitMother[m] != 0 ) { 
                count++;
            }
        }
    }
    function getRabbitDNK(uint32 bunnyid) public view returns(uint) { 
        return TokenBunny.getDNK(bunnyid);
    }
    function isUIntPublic() public view returns(bool) {
        require(isPauseSave());
        return true;
    }
}
contract BunnyGame is BodyRabbit { 

    function createGennezise(uint32 _matron) public {
        bool promo = false;
        require(isPriv());
        require(isPauseSave());
        require(isPromoPause());
        if (totalGen0 > promoGen0) { 
            require(getInWhitelist(msg.sender));
        } else if (!(getInWhitelist(msg.sender))) {
            // promo action
                require(!TokenBunny.getOwnerGennezise(msg.sender));
                TokenBunny.setOwnerGennezise(msg.sender, true);
                promo = true;
        }
        uint  localdnk = privateContract.getNewRabbit(msg.sender);
        uint32 _bunnyid = TokenBunny.setTokenBunny(0, 0, block.number, 0, 0, 0, msg.sender, localdnk);
        
        totalGen0++; 
        setRabbitMother(_bunnyid, _matron);

        if(_matron != 0){  
            emit Referral(msg.sender, _matron, _bunnyid, block.timestamp);
        }
        
        if (promo) { 
            TokenBunny.setGiffBlock(_bunnyid, true);
        }
        emit Transfer(this, msg.sender, _bunnyid);
    }
    function getGenomeChildren(uint32 _matron, uint32 _sire) internal view returns(uint) {
        uint genome;
        if (TokenBunny.getGenome(_matron) >= TokenBunny.getGenome(_sire)) {
            genome = TokenBunny.getGenome(_matron);
        } else {
            genome = TokenBunny.getGenome(_sire);
        }
        return genome.add(1);
    }
    function createChildren(uint32 _matron, uint32 _sire) public  payable returns(uint32) {

        require(isPriv());
        require(isPauseSave());
        require(TokenBunny.ownerOf(_matron) == msg.sender);
        require(TokenBunny.getSex(_sire) == true);
        require(_matron != _sire);
        require(getBreed(_matron));
        require(msg.value >= getSirePrice(_sire));
        uint genome = getGenomeChildren(_matron, _sire);
        uint localdnk =  privateContract.mixDNK(TokenBunny.getDNK(_matron), TokenBunny.getDNK(_sire), genome);
 
        uint32 bunnyid = TokenBunny.setTokenBunny(_matron, _sire, block.number, 0, 0, genome, msg.sender, localdnk);
        uint _moneyMother = TokenBunny.getRabbitSirePrice(_sire).div(4);
        _transferMoneyMother(_matron, _moneyMother);

        TokenBunny.ownerOf(_sire).transfer( TokenBunny.getRabbitSirePrice(_sire) );
 
        uint system = TokenBunny.getRabbitSirePrice(_sire).div(100);

        system = system.mul(commission_system);
        ownerMoney.transfer(system);
        coolduwnUP(_matron); 
        setRabbitMother(bunnyid, _matron);
        emit Transfer(this, msg.sender, bunnyid);
        return bunnyid;
    } 
    function coolduwnUP(uint32 _mother) internal { 
        require(isPauseSave());
        uint coolduwn = TokenBunny.getBirthCount(_mother).add(1);
        TokenBunny.setBirthCount(_mother, coolduwn);
        TokenBunny.setBirthLastTime(_mother, now);
        emit CoolduwnMother(_mother, TokenBunny.getBirthCount(_mother));
    }
    function _transferMoneyMother(uint32 _mother, uint _valueMoney) internal {
        require(isPauseSave());
        require(_valueMoney > 0);
        if (getRabbitMotherSumm(_mother) > 0) {
            uint pastMoney = _valueMoney/getRabbitMotherSumm(_mother);
            
            for (uint i=0; i < getRabbitMotherSumm(_mother); i++) {

                if ( TokenBunny.getRabbitMother(_mother)[i] != 0) { 
                    uint32 _parrentMother = TokenBunny.getRabbitMother(_mother)[i];
                    address add = TokenBunny.ownerOf(_parrentMother);
                    TokenBunny.setMotherCount(_parrentMother, TokenBunny.getMotherCount(_parrentMother).add(1));
                    TokenBunny.setTotalSalaryBunny( _parrentMother, TokenBunny.getTotalSalaryBunny(_parrentMother).add(pastMoney));
                    emit SalaryBunny(_parrentMother, TokenBunny.getTotalSalaryBunny(_parrentMother));
                    add.transfer(pastMoney); // refund previous bidder
                }
            } 
        }
    }
    /*
    function setRabbitSirePrice(uint32 _rabbitid, uint price) public {
        require(isPauseSave());
        require(TokenBunny.ownerOf(_rabbitid) == msg.sender);
        require(price > bigPrice);
        require(TokenBunny.getAllowedChangeSex(_rabbitid));
        require(TokenBunny.getRabbitSirePrice(_rabbitid) != price);
        uint lastTime;
        (lastTime,,) = getcoolduwn(_rabbitid);
        require(now >= lastTime);
        TokenBunny.setRabbitSirePrice(_rabbitid, price);
        emit ChengeSex(_rabbitid, true, getSirePrice(_rabbitid));

    }
    function setSireStop(uint32 _rabbitid) public returns(bool) {
        require(isPauseSave());
        require(TokenBunny.getRabbitSirePrice(_rabbitid) !=0);

        require(TokenBunny.ownerOf(_rabbitid) == msg.sender);
     //   require(rabbits[(_rabbitid-1)].role == 0);
        TokenBunny.setRabbitSirePrice( _rabbitid, 0);
     //   deleteSire(_rabbitid);
        emit ChengeSex(_rabbitid, false, 0);
        return true;
    }*/
    function getMoney(uint _value) public onlyOwner {
        require(address(this).balance >= _value);
        ownerMoney.transfer(_value);
    }
}