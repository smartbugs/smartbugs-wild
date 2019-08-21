pragma solidity ^0.4.24;
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
               
* Author:  Konstantin G...
* Telegram: @bunnygame (en)
* email: info@bunnycoin.co
* site : http://bunnycoin.co 
*/

/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/
contract Ownable {
    
    address ownerCEO;
    address ownerMoney;  
     
    address privAddress; 
    address addressAdmixture;
    
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
    function getAddressAdmixture() public view onlyOwner returns(address) {
        return addressAdmixture;
    }
} 



/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * @dev This simplifies the implementation of "user permissions".
 */
contract Whitelist is Ownable {
    mapping(address => bool) public whitelist;

    mapping(uint  => address)   whitelistCheck;
    uint public countAddress = 0;

    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);
 
  /**
   * @dev Throws if called by any account that's not whitelisted.
   */
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender]);
        _;
    }

    constructor() public {
            whitelist[msg.sender] = true;  
    }

  /**
   * @dev add an address to the whitelist
   * @param addr address
   * @return true if the address was added to the whitelist, false if the address was already in the whitelist
   */
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
 
    /**
    * @dev add addresses to the whitelist
    * @param addrs addresses
    * @return true if at least one address was added to the whitelist,
    * false if all addresses were already in the whitelist
    */
    function addAddressesToWhitelist(address[] addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    /**
    * @dev remove an address from the whitelist
    * @param addr address
    * @return true if the address was removed from the whitelist,
    * false if the address wasn't in the whitelist in the first place
    */
    function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }

    /**
    * @dev remove addresses from the whitelist
    * @param addrs addresses
    * @return true if at least one address was removed from the whitelist,
    * false if all addresses weren't in the whitelist in the first place
    */
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
 

contract BaseRabbit  is Whitelist {
       

 
    event EmotherCount(uint32 mother, uint summ);
    event NewBunny(uint32 bunnyId, uint dnk, uint256 blocknumber, uint breed, uint procentAdmixture, uint admixture);
    event ChengeSex(uint32 bunnyId, bool sex, uint256 price);
    event SalaryBunny(uint32 bunnyId, uint cost);
    event CreateChildren(uint32 matron, uint32 sire, uint32 child);
    event BunnyDescription(uint32 bunnyId, string name);
    event CoolduwnMother(uint32 bunnyId, uint num);


    event Referral(address from, uint32 matronID, uint32 childID, uint currentTime);
    event Approval(address owner, address approved, uint32 tokenId);
    event OwnerBunnies(address owner, uint32  tokenId);
    event Transfer(address from, address to, uint32 tokenId);

 

    using SafeMath for uint256;
    bool pauseSave = false;
    uint256 bigPrice = 0.005 ether;
    
    uint public commission_system = 5;
     
    // ID the last seal
    uint32 public lastIdGen0;
    uint public totalGen0 = 0;
    // ID the last seal
    uint public lastTimeGen0;
    
    // ID the last seal
  //  uint public timeRangeCreateGen0 = 1800; 

    uint public promoGen0 = 15000;
    uint public promoMoney = 1*bigPrice;
    bool public promoPause = false;


    function setPromoGen0(uint _promoGen0) public onlyWhitelisted() {
        promoGen0 = _promoGen0;
    }

    function setPromoPause() public onlyWhitelisted() {
        promoPause = !promoPause;
    }



    function setPromoMoney(uint _promoMoney) public onlyWhitelisted() {
        promoMoney = _promoMoney;
    }
 

    mapping(uint32 => uint) public totalSalaryBunny;
    mapping(uint32 => uint32[5]) public rabbitMother;
    
    mapping(uint32 => uint) public motherCount;
    
    // how many times did the rabbit cross
    mapping(uint32 => uint) public rabbitBreedCount;

    mapping(uint32 => uint)  public rabbitSirePrice;
    mapping(uint => uint32[]) public sireGenom;
    mapping (uint32 => uint) mapDNK;
   
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
         // parents
        uint32 mother;
        uint32 sire; 
        // block in which a rabbit was born
        uint birthblock;
         // number of births or how many times were offspring
        uint birthCount;
         // The time when Rabbit last gave birth
        uint birthLastTime;
        // the current role of the rabbit
        uint role;
        //indexGenome   
        uint genome;

        uint procentAdmixture;
        uint admixture;
    }

 
    /**
    * Where we will store information about rabbits
    */
    Rabbit[]  public rabbits;
     
    /**
    * who owns the rabbit
    */
    mapping (uint32 => address) public rabbitToOwner; 
    mapping (address => uint32[]) public ownerBunnies;
    //mapping (address => uint) ownerRabbitCount;
    mapping (uint32 => string) rabbitDescription;
    mapping (uint32 => string) rabbitName; 

    //giff 
    mapping (uint32 => bool) giffblock; 
    mapping (address => bool) ownerGennezise;

}


/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <dete@axiomzen.co> (https://github.com/dete)
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

contract AdmixtureInterface {
    function getAdmixture(uint m, uint w)  public view returns (uint procentAdmixture, uint admixture);
}

 


contract BodyRabbit is BaseRabbit, ERC721 {
    uint public totalBunny = 0;
    string public constant name = "CryptoRabbits";
    string public constant symbol = "CRB";


    PrivateRabbitInterface privateContract;
    AdmixtureInterface AdmixtureContract;

    /**
    * @dev setting up a new address for a private contract
    */
    function setPriv(address _privAddress) public returns(bool) {
        privAddress = _privAddress;
        privateContract = PrivateRabbitInterface(_privAddress);
    } 
    function setAdmixture(address _addressAdmixture) public returns(bool) {
        addressAdmixture = _addressAdmixture;
        AdmixtureContract = AdmixtureInterface(_addressAdmixture);
    } 

    bool public fcontr = false;
 
    
    constructor() public { 
        fcontr = true;
    }

    function isPriv() public view returns(bool) {
        return privateContract.isUIntPrivate();
    }

    modifier checkPrivate() {
        require(isPriv());
        _;
    }

    function ownerOf(uint32 _tokenId) public view returns (address owner) {
        return rabbitToOwner[_tokenId];
    }

    function approve(address _to, uint32 _tokenId) public returns (bool) { 
        _to;
        _tokenId;
        return false;
    }


    function removeTokenList(address _owner, uint32 _tokenId) internal { 
        uint count = ownerBunnies[_owner].length;
        for (uint256 i = 0; i < count; i++) {
            if(ownerBunnies[_owner][i] == _tokenId)
            { 
                delete ownerBunnies[_owner][i];
                if(count > 0 && count != (i-1)){
                    ownerBunnies[_owner][i] = ownerBunnies[_owner][(count-1)];
                    delete ownerBunnies[_owner][(count-1)];
                } 
                ownerBunnies[_owner].length--;
                return;
            } 
        }
    }
    /**
    * Get the cost of the reward for pairing
    * @param _tokenId - rabbit that mates
     */
    function getSirePrice(uint32 _tokenId) public view returns(uint) {
        if(rabbits[(_tokenId-1)].role == 1){
            uint procent = (rabbitSirePrice[_tokenId] / 100);
            uint res = procent.mul(25);
            uint system  = procent.mul(commission_system);

            res = res.add(rabbitSirePrice[_tokenId]);
            return res.add(system); 
        } else {
            return 0;
        }
    }

    /**
    * @dev add a new bunny in the storage
     */
    function addTokenList(address owner,  uint32 _tokenId) internal {
        ownerBunnies[owner].push( _tokenId);
        emit OwnerBunnies(owner, _tokenId);
        rabbitToOwner[_tokenId] = owner; 
    }
 

    function transfer(address _to, uint32 _tokenId) public {
        address currentOwner = msg.sender;
        address oldOwner = rabbitToOwner[_tokenId];
        require(rabbitToOwner[_tokenId] == msg.sender);
        require(currentOwner != _to);
        require(_to != address(0));
        removeTokenList(oldOwner, _tokenId);
        addTokenList(_to, _tokenId);
        emit Transfer(oldOwner, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint32 _tokenId) public returns(bool) {
        address oldOwner = rabbitToOwner[_tokenId];
        require(oldOwner == _from);
        require(getInWhitelist(msg.sender));
        require(oldOwner != _to);
        require(_to != address(0));

        removeTokenList(oldOwner, _tokenId);
        addTokenList(_to, _tokenId); 
        emit Transfer (oldOwner, _to, _tokenId);
        return true;
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
        total = ownerBunnies[owner].length;
        list = ownerBunnies[owner];
    } 



    function setRabbitMother(uint32 children, uint32 mother) internal { 
        require(children != mother);
        uint32[11] memory pullMother;
        uint start = 0;
        for (uint i = 0; i < 5; i++) {
            if (rabbitMother[mother][i] != 0) {
              pullMother[start] = uint32(rabbitMother[mother][i]);
              rabbitMother[mother][i] = 0;
              start++;
            } 
        }
        pullMother[start] = mother;
        start++;
        for (uint m = 0; m < 5; m++) {
             if(start >  5){
                    rabbitMother[children][m] = pullMother[(m+1)];
             }else{
                    rabbitMother[children][m] = pullMother[m];
             }
        } 
        setMotherCount(mother);
    }

      

    function setMotherCount(uint32 _mother) internal returns(uint)  { //internal
        motherCount[_mother] = motherCount[_mother].add(1);
        emit EmotherCount(_mother, motherCount[_mother]);
        return motherCount[_mother];
    } 
     
    function bytes32ToString(bytes32 x) internal pure returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
    
    function uintToBytes(uint v) internal pure returns (bytes32 ret) {
        if (v == 0) {
            ret = '0';
        } else {
        while (v > 0) {
                ret = bytes32(uint(ret) / (2 ** 8));
                ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
                v /= 10;
            }
        }
        return ret;
    }

    function totalSupply() public view returns (uint total) {
        return totalBunny;
    }

    function balanceOf(address _owner) public view returns (uint) {
      //  _owner;
        return ownerBunnies[_owner].length;
    }

    function sendMoney(address _to, uint256 _money) internal { 
        _to.transfer((_money/100)*95);
        ownerMoney.transfer((_money/100)*5); 
    }

    function getGiffBlock(uint32 _bunnyid) public view returns(bool) { 
        return !giffblock[_bunnyid];
    }

    function getOwnerGennezise(address _to) public view returns(bool) { 
        return ownerGennezise[_to];
    }
    

    function getBunny(uint32 _bunny) public view returns(
        uint32 mother,
        uint32 sire,
        uint birthblock,
        uint birthCount,
        uint birthLastTime,
        uint role, 
        uint genome,
        bool interbreed,
        uint leftTime,
        uint lastTime,
        uint price,
        uint motherSumm
        )
        {
            price = getSirePrice(_bunny);
            _bunny = _bunny - 1;
            mother = rabbits[_bunny].mother;
            sire = rabbits[_bunny].sire;
            birthblock = rabbits[_bunny].birthblock;
            birthCount = rabbits[_bunny].birthCount;
            birthLastTime = rabbits[_bunny].birthLastTime;
            role = rabbits[_bunny].role;
            genome = rabbits[_bunny].genome;
                     
            if(birthCount > 11) {
                birthCount = 11;
            }

            motherSumm = motherCount[_bunny];

            lastTime = uint(cooldowns[birthCount]);
            lastTime = lastTime.add(birthLastTime);
            if(lastTime <= now) {
                interbreed = true;
            } else {
                leftTime = lastTime.sub(now);
            }
    }



    /**
    * We update the information on rabbits
     */
    function updateBunny(uint32 _bunny, uint types, uint data ) public onlyWhitelisted()
    { 
        if (types == 1) {
            rabbits[(_bunny - 1)].birthCount = data;
        } else if (types == 2) {
            rabbits[(_bunny - 1)].genome = data;
        } else if (types == 3) {
            rabbitSirePrice[_bunny] = data;
        } else if (types == 4) {
            motherCount[_bunny] = data;
            emit EmotherCount(_bunny, data);
        } 

            
    }

    /**
    * @param _bunny A rabbit on which we receive information
     */
    function getBreed(uint32 _bunny) public view returns(bool interbreed)
        {
      
        uint birtTime = rabbits[(_bunny - 1)].birthLastTime;
        uint birthCount = rabbits[(_bunny - 1)].birthCount;

        uint  lastTime = uint(cooldowns[birthCount]);
        lastTime = lastTime.add(birtTime);

        if(lastTime <= now && rabbits[(_bunny - 1)].role == 0 ) {
            interbreed = true;
        } 
    }

    /**
     *  we get cooldown
     */
    function getcoolduwn(uint32 _mother) public view returns(uint lastTime, uint cd, uint lefttime) {
        cd = rabbits[(_mother-1)].birthCount;
        if(cd > 11) {
            cd = 11;
        }
        // time when I can give birth
        lastTime = (cooldowns[cd] + rabbits[(_mother-1)].birthLastTime);
        if(lastTime > now) {
            // I can not give birth, it remains until delivery
            lefttime = lastTime.sub(now);
        }
    }



     function getMotherCount(uint32 _mother) public view returns(uint) { //internal
        return  motherCount[_mother];
    }


     function getTotalSalaryBunny(uint32 _bunny) public view returns(uint) { //internal
        return  totalSalaryBunny[_bunny];
    }
 
 
    function getRabbitMother( uint32 mother) public view returns(uint32[5]) {
        return rabbitMother[mother];
    }

     function getRabbitMotherSumm(uint32 mother) public view returns(uint count) { //internal
        for (uint m = 0; m < 5 ; m++) {
            if(rabbitMother[mother][m] != 0 ) { 
                count++;
            }
        }
    }

    function getRabbitDNK(uint32 bunnyid) public view returns(uint) { 
        return mapDNK[bunnyid];
    }

    function isUIntPublic() public view returns(bool) {
        require(isPauseSave());
        return true;
    }

}
/**
* Basic actions for the transfer of rights of rabbits
*/ 
 
contract BunnyGame is BodyRabbit{    
  
    function transferNewBunny(address _to, uint32 _bunnyid, uint localdnk, uint breed, uint32 matron, uint32 sire, uint procentAdmixture, uint admixture) internal {
        emit NewBunny(_bunnyid, localdnk, block.number, breed, procentAdmixture, admixture);
        emit CreateChildren(matron, sire, _bunnyid);
        addTokenList(_to, _bunnyid);
        totalSalaryBunny[_bunnyid] = 0;
        motherCount[_bunnyid] = 0;
        totalBunny++;
    }

         
    /***
    * @dev create a new gene and put it up for sale, this operation takes place on the server
    */
    function createGennezise(uint32 _matron) public {
         
        bool promo = false;
        require(isPriv());
        require(isPauseSave());
        require(isPromoPause());
 
        if (totalGen0 > promoGen0) { 
            require(getInWhitelist(msg.sender));
        } else if (!(getInWhitelist(msg.sender))) {
            // promo action
                require(!ownerGennezise[msg.sender]);
                ownerGennezise[msg.sender] = true;
                promo = true;
        }
        
        uint  localdnk = privateContract.getNewRabbit(msg.sender);
        Rabbit memory _Rabbit =  Rabbit( 0, 0, block.number, 0, 0, 0, 0, 0, 0);
        uint32 _bunnyid =  uint32(rabbits.push(_Rabbit));
        mapDNK[_bunnyid] = localdnk;
       
        transferNewBunny(msg.sender, _bunnyid, localdnk, 0, 0, 0, 4, 0);  
        
        lastTimeGen0 = now;
        lastIdGen0 = _bunnyid; 
        totalGen0++; 

        setRabbitMother(_bunnyid, _matron);

        emit Referral(msg.sender, _matron, _bunnyid, block.timestamp);

        if (promo) {
            giffblock[_bunnyid] = true;
        }
    }

    function getGenomeChildren(uint32 _matron, uint32 _sire) internal view returns(uint) {
        uint genome;
        if (rabbits[(_matron-1)].genome >= rabbits[(_sire-1)].genome) {
            genome = rabbits[(_matron-1)].genome;
        } else {
            genome = rabbits[(_sire-1)].genome;
        }
        return genome.add(1);
    }
    
    /**
    * create a new rabbit, according to the cooldown
    * @param _matron - mother who takes into account the cooldown
    * @param _sire - the father who is rewarded for mating for the fusion of genes
     */
    function createChildren(uint32 _matron, uint32 _sire) public  payable returns(uint32) {

        require(isPriv());
        require(isPauseSave());
        require(rabbitToOwner[_matron] == msg.sender);
        // Checking for the role
        require(rabbits[(_sire-1)].role == 1);
        require(_matron != _sire);

        require(getBreed(_matron));
        // Checking the money 
        
        require(msg.value >= getSirePrice(_sire));
        
        uint genome = getGenomeChildren(_matron, _sire);

        uint localdnk =  privateContract.mixDNK(mapDNK[_matron], mapDNK[_sire], genome);


        uint procentAdm; 
        uint admixture;
        (procentAdm, admixture) = AdmixtureContract.getAdmixture(rabbits[(_sire-1)].procentAdmixture, rabbits[(_matron-1)].procentAdmixture);
        Rabbit memory rabbit =  Rabbit(_matron, _sire, block.number, 0, 0, 0, genome, procentAdm, admixture);

        uint32 bunnyid =  uint32(rabbits.push(rabbit));
        mapDNK[bunnyid] = localdnk;

        uint _moneyMother = rabbitSirePrice[_sire].div(4);

        _transferMoneyMother(_matron, _moneyMother);

        rabbitToOwner[_sire].transfer(rabbitSirePrice[_sire]);

        uint system = rabbitSirePrice[_sire].div(100);
        system = system.mul(commission_system);
        ownerMoney.transfer(system); // refund previous bidder
  
        coolduwnUP(_matron);
        // we transfer the rabbit to the new owner
        transferNewBunny(rabbitToOwner[_matron], bunnyid, localdnk, genome, _matron, _sire, procentAdm, admixture );   
        // we establish parents for the child
        setRabbitMother(bunnyid, _matron);
        return bunnyid;
    } 
  
    /**
     *  Set the cooldown for childbirth
     * @param _mother - mother for which cooldown
     */
    function coolduwnUP(uint32 _mother) internal { 
        require(isPauseSave());
        rabbits[(_mother-1)].birthCount = rabbits[(_mother-1)].birthCount.add(1);
        rabbits[(_mother-1)].birthLastTime = now;
        emit CoolduwnMother(_mother, rabbits[(_mother-1)].birthCount);
    }


    /**
     * @param _mother - matron send money for parrent
     * @param _valueMoney - current sale
     */
    function _transferMoneyMother(uint32 _mother, uint _valueMoney) internal {
        require(isPauseSave());
        require(_valueMoney > 0);
        if (getRabbitMotherSumm(_mother) > 0) {
            uint pastMoney = _valueMoney/getRabbitMotherSumm(_mother);
            for (uint i=0; i < getRabbitMotherSumm(_mother); i++) {
                if (rabbitMother[_mother][i] != 0) { 
                    uint32 _parrentMother = rabbitMother[_mother][i];
                    address add = rabbitToOwner[_parrentMother];
                    // pay salaries
                    setMotherCount(_parrentMother);
                    totalSalaryBunny[_parrentMother] += pastMoney;
                    emit SalaryBunny(_parrentMother, totalSalaryBunny[_parrentMother]);
                    add.transfer(pastMoney); // refund previous bidder
                }
            } 
        }
    }
    
    /**
    * @dev We set the cost of renting our genes
    * @param price rent price
     */
    function setRabbitSirePrice(uint32 _rabbitid, uint price) public returns(bool) {
        require(isPauseSave());
        require(rabbitToOwner[_rabbitid] == msg.sender);
        require(price > bigPrice);

        uint lastTime;
        (lastTime,,) = getcoolduwn(_rabbitid);
        require(now >= lastTime);

        if (rabbits[(_rabbitid-1)].role == 1 && rabbitSirePrice[_rabbitid] == price) {
            return false;
        }

        rabbits[(_rabbitid-1)].role = 1;
        rabbitSirePrice[_rabbitid] = price;
        uint gen = rabbits[(_rabbitid-1)].genome;
        sireGenom[gen].push(_rabbitid);
        emit ChengeSex(_rabbitid, true, getSirePrice(_rabbitid));
        return true;
    }
 
    /**
    * @dev We set the cost of renting our genes
     */
    function setSireStop(uint32 _rabbitid) public returns(bool) {
        require(isPauseSave());
        require(rabbitToOwner[_rabbitid] == msg.sender);
     //   require(rabbits[(_rabbitid-1)].role == 0);
        rabbits[(_rabbitid-1)].role = 0;
        rabbitSirePrice[_rabbitid] = 0;
        deleteSire(_rabbitid);
        return true;
    }
    
      function deleteSire(uint32 _tokenId) internal { 
        uint gen = rabbits[(_tokenId-1)].genome;

        uint count = sireGenom[gen].length;
        for (uint i = 0; i < count; i++) {
            if(sireGenom[gen][i] == _tokenId)
            { 
                delete sireGenom[gen][i];
                if(count > 0 && count != (i-1)){
                    sireGenom[gen][i] = sireGenom[gen][(count-1)];
                    delete sireGenom[gen][(count-1)];
                } 
                sireGenom[gen].length--;
                emit ChengeSex(_tokenId, false, 0);
                return;
            } 
        }
    } 

    function getMoney(uint _value) public onlyOwner {
        require(address(this).balance >= _value);
        ownerMoney.transfer(_value);
    }

    /**
    * @dev give a rabbit to a specific user
    * @param add new address owner rabbits
    */
    function gift(uint32 bunnyid, address add) public {
        require(rabbitToOwner[bunnyid] == msg.sender);
        // a rabbit taken for free can not be given
        require(!(giffblock[bunnyid]));
        transferFrom(msg.sender, add, bunnyid);
    }
}