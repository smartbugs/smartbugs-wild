pragma solidity ^0.4.18;

contract KryptoArmy {

    address ceoAddress = 0x46d9112533ef677059c430E515775e358888e38b;
    address cfoAddress = 0x23a49A9930f5b562c6B1096C3e6b5BEc133E8B2E;

    modifier onlyCeo() {
        require (msg.sender == ceoAddress);
        _;
    }

    // Struct for Army
    struct Army {
        string name;            // The name of the army (invented by the user)
        string idArmy;          // The id of the army (USA for United States)
        uint experiencePoints;  // The experience points of the army, we will use this to handle
        uint256 price;          // The cost of the Army in Wei (1 ETH = 1000000000000000000 Wei) 
        uint attackBonus;       // The attack bonus for the soldiers (from 0 to 10)
        uint defenseBonus;      // The defense bonus for the soldiers (from 0 to 10)
        bool isForSale;         // User is selling this army, it can be purchase on the marketplace
        address ownerAddress;   // The address of the owner
        uint soldiersCount;     // The count of all the soldiers in this army
    } 
    Army[] armies;
    
    // Struct for Battles
    struct Battle {
        uint idArmyAttacking;   // The id of the army attacking
        uint idArmyDefensing;   // The id of the army defensing
        uint idArmyVictorious;  // The id of the winning army
    } 

    Battle[] battles;

    // Mapping army
    mapping (address => uint) public ownerToArmy;       // Which army does this address own
    mapping (address => uint) public ownerArmyCount;    // How many armies own this address?

    // Mapping weapons to army
    mapping (uint => uint) public armyDronesCount;
    mapping (uint => uint) public armyPlanesCount;
    mapping (uint => uint) public armyHelicoptersCount;
    mapping (uint => uint) public armyTanksCount;
    mapping (uint => uint) public armyAircraftCarriersCount;
    mapping (uint => uint) public armySubmarinesCount;
    mapping (uint => uint) public armySatelitesCount;

    // Mapping battles
    mapping (uint => uint) public armyCountBattlesWon;
    mapping (uint => uint) public armyCountBattlesLost;

    // This function creates a new army and saves it in the array with its parameters
    function _createArmy(string _name, string _idArmy, uint _price, uint _attackBonus, uint _defenseBonus) public onlyCeo {

        // We add the new army to the list and save the id in a variable 
        armies.push(Army(_name, _idArmy, 0, _price, _attackBonus, _defenseBonus, true, address(this), 0));
    }

    // We use this function to purchase an army with Metamask
    function purchaseArmy(uint _armyId) public payable {
        // We verify that the value paid is equal to the cost of the army
        require(msg.value == armies[_armyId].price);
        require(msg.value > 0);
        
        // We check if this army is owned by another user
        if(armies[_armyId].ownerAddress != address(this)) {
            uint CommissionOwnerValue = msg.value - (msg.value / 10);
            armies[_armyId].ownerAddress.transfer(CommissionOwnerValue);
        }

        // We modify the ownership of the army
        _ownershipArmy(_armyId);
    }

    // Function to purchase a soldier
    function purchaseSoldiers(uint _armyId, uint _countSoldiers) public payable {
        // Check that message value > 0
        require(msg.value > 0);
        uint256 msgValue = msg.value;

        if(msgValue == 1000000000000000 && _countSoldiers == 1) {
            // Increment soldiers count in army
            armies[_armyId].soldiersCount = armies[_armyId].soldiersCount + _countSoldiers;
        } else if(msgValue == 8000000000000000 && _countSoldiers == 10) {
            // Increment soldiers count in army
            armies[_armyId].soldiersCount = armies[_armyId].soldiersCount + _countSoldiers;
        } else if(msgValue == 65000000000000000 && _countSoldiers == 100) {
            // Increment soldiers count in army
            armies[_armyId].soldiersCount = armies[_armyId].soldiersCount + _countSoldiers;
        } else if(msgValue == 500000000000000000 && _countSoldiers == 1000) {
            // Increment soldiers count in army
            armies[_armyId].soldiersCount = armies[_armyId].soldiersCount + _countSoldiers;
        }
    }

    // Payable function to purchase weapons
    function purchaseWeapons(uint _armyId, uint _weaponId, uint _bonusAttack, uint _bonusDefense ) public payable {
        // Check that message value > 0
        uint isValid = 0;
        uint256 msgValue = msg.value;

        if(msgValue == 10000000000000000 && _weaponId == 0) {
            armyDronesCount[_armyId]++;
            isValid = 1;
        } else if(msgValue == 25000000000000000 && _weaponId == 1) {
             armyPlanesCount[_armyId]++;
            isValid = 1;
        } else if(msgValue == 25000000000000000 && _weaponId == 2) {
            armyHelicoptersCount[_armyId]++;
            isValid = 1;
        } else if(msgValue == 45000000000000000 && _weaponId == 3) {
            armyTanksCount[_armyId]++;
            isValid = 1;
        } else if(msgValue == 100000000000000000 && _weaponId == 4) {
            armyAircraftCarriersCount[_armyId]++;
            isValid = 1;
        } else if(msgValue == 100000000000000000 && _weaponId == 5) {
            armySubmarinesCount[_armyId]++;
            isValid = 1;
        } else if(msgValue == 120000000000000000 && _weaponId == 6) {
            armySatelitesCount[_armyId]++;
            isValid = 1;
        } 

        // We check if the data has been verified as valid
        if(isValid == 1) {
            armies[_armyId].attackBonus = armies[_armyId].attackBonus + _bonusAttack;
            armies[_armyId].defenseBonus = armies[_armyId].defenseBonus + _bonusDefense;
        }
    }

    // We use this function to affect an army to an address (when someone purchase an army)
    function _ownershipArmy(uint armyId) private {

        // We check if the sender already own an army
        require (ownerArmyCount[msg.sender] == 0);

        // If this army has alreay been purchased we verify that the owner put it on sale
        require(armies[armyId].isForSale == true);
        
        // We check one more time that the price paid is the price of the army
        require(armies[armyId].price == msg.value);

        // We decrement the army count for the previous owner (in case a user is selling army on marketplace)
        ownerArmyCount[armies[armyId].ownerAddress]--;
        
        // We set the new army owner
        armies[armyId].ownerAddress = msg.sender;
        ownerToArmy[msg.sender] = armyId;

        // We increment the army count for this address
        ownerArmyCount[msg.sender]++;

        // Send event for new ownership
        armies[armyId].isForSale = false;
    }

    // We use this function to start a new battle
    function startNewBattle(uint _idArmyAttacking, uint _idArmyDefensing, uint _randomIndicatorAttack, uint _randomIndicatorDefense) public returns(uint) {

        // We verify that the army attacking is the army of msg.sender
        require (armies[_idArmyAttacking].ownerAddress == msg.sender);

        // Get details for army attacking
        uint ScoreAttack = armies[_idArmyAttacking].attackBonus * (armies[_idArmyAttacking].soldiersCount/3) + armies[_idArmyAttacking].soldiersCount  + _randomIndicatorAttack; 

        // Get details for army defending
        uint ScoreDefense = armies[_idArmyAttacking].defenseBonus * (armies[_idArmyDefensing].soldiersCount/2) + armies[_idArmyDefensing].soldiersCount + _randomIndicatorDefense; 

        uint VictoriousArmy;
        uint ExperiencePointsGained;
        if(ScoreDefense >= ScoreAttack) {
            VictoriousArmy = _idArmyDefensing;
            ExperiencePointsGained = armies[_idArmyAttacking].attackBonus + 2;
            armies[_idArmyDefensing].experiencePoints = armies[_idArmyDefensing].experiencePoints + ExperiencePointsGained;

            // Increment mapping battles won
            armyCountBattlesWon[_idArmyDefensing]++;
            armyCountBattlesLost[_idArmyAttacking]++;
        } else {
            VictoriousArmy = _idArmyAttacking;
            ExperiencePointsGained = armies[_idArmyDefensing].defenseBonus + 2;
            armies[_idArmyAttacking].experiencePoints = armies[_idArmyAttacking].experiencePoints + ExperiencePointsGained;

            // Increment mapping battles won
            armyCountBattlesWon[_idArmyAttacking]++;
            armyCountBattlesLost[_idArmyDefensing]++;
        }
        
        // We add the new battle to the blockchain and save its id in a variable 
        battles.push(Battle(_idArmyAttacking, _idArmyDefensing, VictoriousArmy));  
        
        // Send event
        return (VictoriousArmy);
    }

    // Owner can sell army
    function ownerSellArmy(uint _armyId, uint256 _amount) public {
        // We close the function if the user calling this function doesn't own the army
        require (armies[_armyId].ownerAddress == msg.sender);
        require (_amount > 0);
        require (armies[_armyId].isForSale == false);

        armies[_armyId].isForSale = true;
        armies[_armyId].price = _amount;
    }
    
    // Owner remove army from marketplace
    function ownerCancelArmyMarketplace(uint _armyId) public {
        require (armies[_armyId].ownerAddress == msg.sender);
        require (armies[_armyId].isForSale == true);
        armies[_armyId].isForSale = false;
    }

    // Function to return all the value of an army
    function getArmyFullData(uint armyId) public view returns(string, string, uint, uint256, uint, uint, bool) {
        string storage ArmyName = armies[armyId].name;
        string storage ArmyId = armies[armyId].idArmy;
        uint ArmyExperiencePoints = armies[armyId].experiencePoints;
        uint256 ArmyPrice = armies[armyId].price;
        uint ArmyAttack = armies[armyId].attackBonus;
        uint ArmyDefense = armies[armyId].defenseBonus;
        bool ArmyIsForSale = armies[armyId].isForSale;
        return (ArmyName, ArmyId, ArmyExperiencePoints, ArmyPrice, ArmyAttack, ArmyDefense, ArmyIsForSale);
    }

    // Function to return the owner of the army
    function getArmyOwner(uint armyId) public view returns(address, bool) {
        return (armies[armyId].ownerAddress, armies[armyId].isForSale);
    }

    // Function to return the owner of the army
    function getSenderArmyDetails() public view returns(uint, string) {
        uint ArmyId = ownerToArmy[msg.sender];
        string storage ArmyName = armies[ArmyId].name;
        return (ArmyId, ArmyName);
    }
    
    // Function to return the owner army count
    function getSenderArmyCount() public view returns(uint) {
        uint ArmiesCount = ownerArmyCount[msg.sender];
        return (ArmiesCount);
    }

    // Function to return the soldiers count of an army
    function getArmySoldiersCount(uint armyId) public view returns(uint) {
        uint SoldiersCount = armies[armyId].soldiersCount;
        return (SoldiersCount);
    }

    // Return an array with the weapons of the army
    function getWeaponsArmy1(uint armyId) public view returns(uint, uint, uint, uint)  {
        uint CountDrones = armyDronesCount[armyId];
        uint CountPlanes = armyPlanesCount[armyId];
        uint CountHelicopters = armyHelicoptersCount[armyId];
        uint CountTanks = armyTanksCount[armyId];
        return (CountDrones, CountPlanes, CountHelicopters, CountTanks);
    }
    function getWeaponsArmy2(uint armyId) public view returns(uint, uint, uint)  {
        uint CountAircraftCarriers = armyAircraftCarriersCount[armyId];
        uint CountSubmarines = armySubmarinesCount[armyId];
        uint CountSatelites = armySatelitesCount[armyId];
        return (CountAircraftCarriers, CountSubmarines, CountSatelites);
    }

    // Retrieve count battles won
    function getArmyBattles(uint _armyId) public view returns(uint, uint) {
        return (armyCountBattlesWon[_armyId], armyCountBattlesLost[_armyId]);
    }
    
    // Retrieve the details of a battle
    function getDetailsBattles(uint battleId) public view returns(uint, uint, uint, string, string) {
        return (battles[battleId].idArmyAttacking, battles[battleId].idArmyDefensing, battles[battleId].idArmyVictorious, armies[battles[battleId].idArmyAttacking].idArmy, armies[battles[battleId].idArmyDefensing].idArmy);
    }
    
    // Get battles count
    function getBattlesCount() public view returns(uint) {
        return (battles.length);
    }

    // To withdraw fund from this contract
    function withdraw(uint amount, uint who) public onlyCeo returns(bool) {
        require(amount <= this.balance);
        if(who == 0) {
            ceoAddress.transfer(amount);
        } else {
            cfoAddress.transfer(amount);
        }
        
        return true;
    }
    
    // Initial function to create the 100 armies with their attributes
    function KryptoArmy() public onlyCeo {

      // 1. USA
        _createArmy("United States", "USA", 550000000000000000, 8, 9);

        // 2. North Korea
        _createArmy("North Korea", "NK", 500000000000000000, 10, 5);

        // 3. Russia
        _createArmy("Russia", "RUS", 450000000000000000, 8, 7);

        // 4. China
        _createArmy("China", "CHN", 450000000000000000, 7, 8);

        // 5. Japan
        _createArmy("Japan", "JPN", 420000000000000000, 7, 7);

        // 6. France
        _createArmy("France", "FRA", 400000000000000000, 6, 8);

        // 7. Germany
        _createArmy("Germany", "GER", 400000000000000000, 7, 6);

        // 8. India
        _createArmy("India", "IND", 400000000000000000, 7, 6);

        // 9. United Kingdom
        _createArmy("United Kingdom", "UK", 350000000000000000, 5, 7);

        // 10. South Korea
        _createArmy("South Korea", "SK", 350000000000000000, 6, 6);

        // 11. Turkey
        _createArmy("Turkey", "TUR", 300000000000000000, 7, 4);

        // 12. Italy
        //_createArmy("Italy", "ITA", 280000000000000000, 5, 5);
    }
}