pragma solidity ^0.4.25;

contract EthMonsters {

	address public owner;


    event BuyMonsterEvent(
        uint price
    );

	uint public typesNumber = 0;
	uint public monstersNumber = 0;
	mapping (address => uint) public userMonstersCount;
	mapping (address => uint) goodContracts; 
    monster[] public monsters;
   	mapping (uint => address) public monsterToOwner;
   	mapping (address => uint) public userBalance;
   	mapping (address => uint[]) public userToMonsters;
   	uint public contractFees = 0;
	
	monsterType[] public types;

	constructor() public {
      	owner = msg.sender;
   	}
    
	modifier onlyOwner { 
    	require(msg.sender == owner);
    	_;
  	}
  	
  	modifier allowedContract { 
  	    address contractAddress = msg.sender;
  		require(goodContracts[contractAddress] == 1);
  		_;
  	}

  	struct monsterType {
  		string name;
  		uint currentPrice;
  		uint basePrice;
  		uint sales;
  		uint id;
  		uint maxPower;
   	}
   	
   	struct monster {
  		string name;
  		uint purchasePrice;
  		uint earnings;
  		uint monsterType;
  		uint id;
  		uint power;
  		uint exp;
  		uint eggs;
  		uint gen;
  		address creator;
  		address owner;
  		uint isEgg;
   	}

    function random(uint min, uint max) private view returns (uint) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%(max-min+1))+min;
    }
    
    function addGoodContract(address _con) public onlyOwner { //add address of a contract to be whitelisted
		goodContracts[_con] = 1;
	}

	function removeGoodContract(address _con) public onlyOwner { //remove address of a contract from whitelist
		goodContracts[_con] = 0;
	}
	
	function addExpToMonster(uint _id, uint amount) public allowedContract {
	    monsters[_id].exp += amount;
	}
	
	function transferMonster(uint _id, address newOwner) public allowedContract {
	    address oldOwner = monsterToOwner[_id];
	    uint[] memory oldUserMonsters = userToMonsters[oldOwner];
	    for(uint i=0; i<userMonstersCount[oldOwner]; i++) {
	        if(oldUserMonsters[i] == _id) {
	            oldUserMonsters[i] = oldUserMonsters[oldUserMonsters.length-1];
	            delete oldUserMonsters[oldUserMonsters.length-1];
	            userToMonsters[oldOwner] = oldUserMonsters;
	            userToMonsters[oldOwner].length--;
	            userToMonsters[newOwner].push(_id);
	            break;
	        }
	    }
	    userMonstersCount[oldOwner]--;
	    userMonstersCount[newOwner]++;
	    monsters[_id].owner = newOwner;
	    monsterToOwner[_id] = newOwner;
	}
	
	function hatchEgg(uint _id, uint _newPower) public allowedContract {
	    require(monsters[_id].isEgg == 1);
	    monsters[_id].isEgg = 0;
	    monsters[_id].power = _newPower;
	}
	
	function changeMonsterName(string _newName, uint _id) public allowedContract {
	    monsters[_id].name = _newName;
	}

	
    function buyMonster(string _name, uint _type) public payable { //starts with 0; public function to buy a monsters 
		require(_type < typesNumber);
		require(_type >= 0);
		if(msg.value < types[_type].currentPrice) { //if sent amount < the monster's price, the amount is added to the address's balance
			userBalance[msg.sender] += msg.value;
			emit BuyMonsterEvent(0);
		} else { //if the sent amount >= the kind's price, 
			userBalance[msg.sender] += (msg.value - types[_type].currentPrice);
			sendEarnings(_type);
			uint numberOfEggs = random(1, 3);
			for(uint _i=0; _i<numberOfEggs; _i++)
			    createMonster(_name, _type, 1, msg.sender, 100, 0, 1);
			createMonster(_name, _type, 0, msg.sender, types[_type].maxPower, types[_type].currentPrice, 0);
			emit BuyMonsterEvent(types[_type].currentPrice);
			types[_type].currentPrice += types[_type].basePrice;
		}
		types[_type].sales++;
	}
	
	function sendEarnings(uint _type) private { 
		require(_type < typesNumber);
		require(_type >= 0);
		contractFees += types[_type].basePrice;
		for(uint _id=0; _id<monsters.length; _id++)
 			if(monsters[_id].monsterType == _type && monsters[_id].gen == 0) {
 				userBalance[monsterToOwner[_id]] += types[_type].basePrice;
 				monsters[_id].earnings += types[_type].basePrice;
 			}
	}
	
	function withdrawFees() public onlyOwner payable {
	    require(contractFees > 0);
	    uint amount = contractFees;
	    contractFees = 0;
	    msg.sender.transfer(amount);
	}
	
	function withdraw() public payable{
	    require(userBalance[msg.sender] > 0);
	    uint amount = userBalance[msg.sender];
	    userBalance[msg.sender] = 0;
	    msg.sender.transfer(amount);
	}
	
    function createMonster(string _name, uint _type, uint _gen, address _owner, uint _power, uint _purchasePrice, uint _isEgg) private { 
		monsters.push(monster(_name, _purchasePrice, 0, _type, monstersNumber, _power, 0, 0 ,_gen ,_owner, _owner, _isEgg));
		monsterToOwner[monstersNumber] = _owner;
		userToMonsters[_owner].push(monstersNumber);
		monstersNumber++;
		userMonstersCount[_owner]++;
	}
	
	function getUserMonstersCount(address _address) public view returns(uint) {
	    return userMonstersCount[_address];
	}
	
	function getUserMonster(uint id, address _owner) public view returns (string, uint, uint, uint, uint, uint, uint, address, address) {
	    monster memory mon = monsters[userToMonsters[_owner][id]];
		return (mon.name, mon.purchasePrice, mon.earnings, mon.gen, mon.monsterType, mon.power, mon.isEgg, mon.creator, mon.owner);
	}
	
	function getMonster(uint id) public view returns (string, uint, uint, uint, uint, uint, uint, address, address) {
	    monster memory mon = monsters[id];
		return (mon.name, mon.purchasePrice, mon.earnings, mon.gen, mon.monsterType, mon.power, mon.isEgg, mon.creator, mon.owner);
	} 
	
   	function addNewType(string _name, uint _basePrice, uint _maxPower) public onlyOwner { //add new kind
		require(_maxPower > 0);
		types.push(monsterType(_name, _basePrice, _basePrice, 0, typesNumber, _maxPower));
		typesNumber++;
	}

	function getType(uint id) public view returns (string, uint, uint, uint, uint, uint) {
		return (types[id].name, types[id].currentPrice, types[id].basePrice, types[id].sales, types[id].id, types[id].maxPower);
	} 
}