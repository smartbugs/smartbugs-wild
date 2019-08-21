pragma solidity ^0.4.23;

/*
* Author:  Konstantin G...
* Telegram: @bunnygame (en)
* talk : https://bitcointalk.org/index.php?topic=5025885.0
* discord : https://discordapp.com/invite/G2jt4Fw
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
            whitelist[this] = true;  
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
    event SalaryBunny(uint32 bunnyId, uint cost);
    event CreateChildren(uint32 matron, uint32 sire, uint32 child);
    event BunnyDescription(uint32 bunnyId, string name);
    event CoolduwnMother(uint32 bunnyId, uint num);
    event Referral(address from, uint32 matronID, uint32 childID, uint currentTime);
    event Approval(address owner, address approved, uint32 tokenId);
    event Transfer(address from, address to, uint32 tokenId);
    event NewBunny(uint32 bunnyId, uint dnk, uint256 blocknumber, uint breed);
 

    using SafeMath for uint256;
    bool pauseSave = false;
    
    // ID the last seal
    // ID the last seal
    bool public promoPause = false;




    function setPromoPause() public onlyWhitelisted() {
        promoPause = !promoPause;
    }


 // 
    // внешняя функция сколько заработала мамочка
    mapping(uint32 => uint) public totalSalaryBunny;
    // кто мамочка у ребёнка
    mapping(uint32 => uint32[5]) public rabbitMother;
    // сколько раз стала мамочка текущий кролик
    mapping(uint32 => uint) public motherCount;
    // сколько стоит скрещивание у кролика
    mapping(uint32 => uint)  public rabbitSirePrice;
    // разрешено ли менять кролику пол
    mapping(uint32 => bool)  public allowedChangeSex;
    // сколько мужиков с текущим геном
   // mapping(uint => uint32[]) public sireGenom;
    mapping (uint32 => uint) mapDNK;
   
    mapping (uint32 => bool) giffblock; 
    /**
    * Where we will store information about rabbits
    */
  //  Rabbit[]  public rabbits;
    mapping (uint32 => Rabbit)  tokenBunny; 
     
    uint public tokenBunnyTotal;
    /**
    * who owns the rabbit
    */
    mapping (uint32 => address) public rabbitToOwner; 
    mapping (address => uint32[]) public ownerBunnies;
    mapping (address => bool) ownerGennezise;

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
        //indexGenome   
        uint genome; 
    }
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


contract Rabbit is BaseRabbit, ERC721 {
    uint public totalBunny = 0;
    string public constant name = "CryptoRabbits";
    string public constant symbol = "CRB";

    function ownerOf(uint32 _tokenId) public view returns (address owner) {
        return rabbitToOwner[_tokenId];
    }

    function approve(address _to, uint32 _tokenId) public returns (bool) { 
        _to;
        _tokenId;
        return false;
    }


    function removeTokenList(address _owner, uint32 _tokenId) internal { 
        require(isPauseSave());
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
    * @dev add a new bunny in the storage
     */
    function addTokenList(address owner,  uint32 _tokenId) internal {
        ownerBunnies[owner].push( _tokenId);
        rabbitToOwner[_tokenId] = owner; 
    }
 

    function transfer(address _to, uint32 _tokenId) public {
        require(isPauseSave());
        address currentOwner = msg.sender;
        address oldOwner = rabbitToOwner[_tokenId];
        require(rabbitToOwner[_tokenId] == msg.sender);
        require(currentOwner != _to);
        require(_to != address(0));
        removeTokenList(oldOwner, _tokenId);
        addTokenList(_to, _tokenId);
        emit Transfer(oldOwner, _to, _tokenId);
    }
    
    function transferFrom(address _from, address _to, uint32 _tokenId) public onlyWhitelisted() returns(bool) {
        require(isPauseSave());
        address oldOwner = rabbitToOwner[_tokenId];
        require(oldOwner == _from); 
        require(oldOwner != _to);
        require(_to != address(0));
        removeTokenList(oldOwner, _tokenId);
        addTokenList(_to, _tokenId); 
        setAllowedChangeSex(_tokenId, false);
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

    function setPauseSave() public onlyWhitelisted() returns(bool) {
        return pauseSave = !pauseSave;
    }

    function setTotalBunny() internal onlyWhitelisted() returns(uint) {
        require(isPauseSave());
        return totalBunny = totalBunny.add(1);
    }
     

    function setTotalBunny_id(uint _totalBunny) external onlyWhitelisted() {
        require(isPauseSave());
        totalBunny = _totalBunny;
    }


    function setTokenBunny(uint32 mother, uint32  sire, uint birthblock, uint birthCount, uint birthLastTime, uint genome, address _owner, uint DNK) 
        external onlyWhitelisted() returns(uint32) {
            uint32 id = uint32(setTotalBunny());
            tokenBunny[id] = Rabbit(mother, sire, birthblock, birthCount, birthLastTime, genome);
            mapDNK[id] = DNK;
            addTokenList(_owner, id); 

            emit NewBunny(id, DNK, block.number, 0);
            emit CreateChildren(mother, sire, id);
            setMotherCount(id, 0);
        return id;
    }
    
    
    // correction of mistakes with parents
    function relocateToken(
        uint32 id, 
        uint32 mother, 
        uint32 sire, 
        uint birthblock, 
        uint birthCount, 
        uint birthLastTime, 
        uint genome, 
        address _owner, 
        uint DNK
         ) external onlyWhitelisted(){
        //    if(mapDNK[id] != 0){ 
                tokenBunny[id] = Rabbit(mother, sire, birthblock, birthCount, birthLastTime, genome);
                mapDNK[id] = DNK;
                addTokenList(_owner, id);
       //     }
    }

    
    
    function setDNK( uint32 _bunny, uint dnk) external onlyWhitelisted() {
        require(isPauseSave());
        mapDNK[_bunny] = dnk;
    }
    
    
    function setMotherCount( uint32 _bunny, uint count) public onlyWhitelisted() {
        require(isPauseSave()); 
        motherCount[_bunny] = count;
    }
    
    function setRabbitSirePrice( uint32 _bunny, uint count) external onlyWhitelisted() {
        require(isPauseSave()); 
        rabbitSirePrice[_bunny] = count;
    }
  
    function setAllowedChangeSex( uint32 _bunny, bool canBunny) public onlyWhitelisted() {
        require(isPauseSave()); 
        allowedChangeSex[_bunny] = canBunny;
    }
    
    function setTotalSalaryBunny( uint32 _bunny, uint count) external onlyWhitelisted() {
        require(isPauseSave()); 
        totalSalaryBunny[_bunny] = count;
    }  

    function setRabbitMother(uint32 children, uint32[5] _m) external onlyWhitelisted() { 
             rabbitMother[children] = _m;
    }

    function setGenome(uint32 _bunny, uint genome)  external onlyWhitelisted(){ 
        tokenBunny[_bunny].genome = genome;
    }

    function setParent(uint32 _bunny, uint32 mother, uint32 sire)  external onlyWhitelisted() { 
        tokenBunny[_bunny].mother = mother;
        tokenBunny[_bunny].sire = sire;
    }

    function setBirthLastTime(uint32 _bunny, uint birthLastTime) external onlyWhitelisted() { 
        tokenBunny[_bunny].birthLastTime = birthLastTime;
    }

    function setBirthCount(uint32 _bunny, uint birthCount) external onlyWhitelisted() { 
        tokenBunny[_bunny].birthCount = birthCount;
    }

    function setBirthblock(uint32 _bunny, uint birthblock) external onlyWhitelisted() { 
        tokenBunny[_bunny].birthblock = birthblock;
    }

    function setGiffBlock(uint32 _bunny, bool blocked) external onlyWhitelisted() { 
        giffblock[_bunny] = blocked;
    }


    function setOwnerGennezise(address _to, bool canYou) external onlyWhitelisted() { 
        ownerGennezise[_to] = canYou;
    }


 

    ////// getters
 
    function getOwnerGennezise(address _to) public view returns(bool) { 
        return ownerGennezise[_to];
    }
    function getGiffBlock(uint32 _bunny) public view returns(bool) { 
        return !giffblock[_bunny];
    }

    function getAllowedChangeSex(uint32 _bunny) public view returns(bool) {
        return !allowedChangeSex[_bunny];
    } 
 
    function getRabbitSirePrice(uint32 _bunny) public view returns(uint) {
        return rabbitSirePrice[_bunny];
    } 

    function getTokenOwner(address owner) public view returns(uint total, uint32[] list) {
        total = ownerBunnies[owner].length;
        list = ownerBunnies[owner];
    } 

    function totalSupply() public view returns (uint total) {
        return totalBunny;
    }

    function balanceOf(address _owner) public view returns (uint) {
        return ownerBunnies[_owner].length;
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
    function getDNK(uint32 bunnyid) public view returns(uint) { 
        return mapDNK[bunnyid];
    }


    function getTokenBunny(uint32 _bunny) public 
    view returns(uint32 mother, uint32 sire, uint birthblock, uint birthCount, uint birthLastTime, uint genome) { 
        mother = tokenBunny[_bunny].mother;
        sire = tokenBunny[_bunny].sire;
        birthblock = tokenBunny[_bunny].birthblock;
        birthCount = tokenBunny[_bunny].birthCount;
        birthLastTime = tokenBunny[_bunny].birthLastTime;
        genome = tokenBunny[_bunny].genome;
    }

    function isUIntPublic() public view returns(bool) {
        require(isPauseSave());
        return true;
    }

    function getSex(uint32 _bunny) public view returns(bool) {
        if(getRabbitSirePrice(_bunny) > 0) {
            return true;
        }
        return false;
    }

    function getGenome(uint32 _bunny) public view returns( uint) { 
        return tokenBunny[_bunny].genome;
    }

    function getParent(uint32 _bunny) public view returns(uint32 mother, uint32 sire) { 
        mother = tokenBunny[_bunny].mother;
        sire = tokenBunny[_bunny].sire;
    }

    function getBirthLastTime(uint32 _bunny) public view returns(uint) { 
        return tokenBunny[_bunny].birthLastTime;
    }

    function getBirthCount(uint32 _bunny) public view returns(uint) { 
        return tokenBunny[_bunny].birthCount;
    }

    function getBirthblock(uint32 _bunny) public view returns(uint) { 
        return tokenBunny[_bunny].birthblock;
    }
  

    function getBunnyInfo(uint32 _bunny) public view returns(
        uint32 mother,
        uint32 sire,
        uint birthblock,
        uint birthCount,
        uint birthLastTime,
        bool role, 
        uint genome,
        bool interbreed,
        uint leftTime,
        uint lastTime,
        uint price,
        uint motherSumm
        ) { 
            role = getSex(_bunny);
            mother = tokenBunny[_bunny].mother;
            sire = tokenBunny[_bunny].sire;
            birthblock = tokenBunny[_bunny].birthblock;
            birthCount = tokenBunny[_bunny].birthCount;
            birthLastTime = tokenBunny[_bunny].birthLastTime;
            genome = tokenBunny[_bunny].genome;
            motherSumm = getMotherCount(_bunny);
            price = getRabbitSirePrice(_bunny);
            lastTime = lastTime.add(birthLastTime);
            if(lastTime <= now) {
                interbreed = true;
            } else {
                leftTime = lastTime.sub(now);
            }
    }
}