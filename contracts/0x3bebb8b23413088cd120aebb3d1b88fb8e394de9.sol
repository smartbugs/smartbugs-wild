pragma solidity ^0.4.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract EtherOlympics is Ownable {
    mapping(bytes3 => uint16) iocCountryCodesToPriceMap;
    event newTeamCreated(bytes32 teamName, bytes3 country1, bytes3 country2, bytes3 country3,
        bytes3 country4, bytes3 country5, bytes3 country6);
    
    function() public payable { }

    function EtherOlympics() public {
        iocCountryCodesToPriceMap['GER'] = 9087;
        iocCountryCodesToPriceMap['NOR'] = 8748;
        iocCountryCodesToPriceMap['USA'] = 7051;
        iocCountryCodesToPriceMap['FRA'] = 6486;
        iocCountryCodesToPriceMap['CAN'] = 6486;
        iocCountryCodesToPriceMap['NED'] = 4412;
        iocCountryCodesToPriceMap['JPN'] = 3544;
        iocCountryCodesToPriceMap['AUT'] = 3507;
        iocCountryCodesToPriceMap['SWE'] = 3507;
        iocCountryCodesToPriceMap['SUI'] = 3431;
        iocCountryCodesToPriceMap['KOR'] = 3318;
        iocCountryCodesToPriceMap['CHN'] = 2941;
        iocCountryCodesToPriceMap['CZE'] = 1961;
        iocCountryCodesToPriceMap['ITA'] = 1395;
        iocCountryCodesToPriceMap['AUS'] = 1207;
        iocCountryCodesToPriceMap['POL'] = 867;
        iocCountryCodesToPriceMap['GBR'] = 792;
        iocCountryCodesToPriceMap['FIN'] = 792;
        iocCountryCodesToPriceMap['BEL'] = 490;
        iocCountryCodesToPriceMap['SLO'] = 490;
        iocCountryCodesToPriceMap['SVK'] = 452;
        iocCountryCodesToPriceMap['LAT'] = 377;
        iocCountryCodesToPriceMap['LIE'] = 377;
        iocCountryCodesToPriceMap['BLR'] = 339;
        iocCountryCodesToPriceMap['HUN'] = 339;
        iocCountryCodesToPriceMap['ESP'] = 339;
        iocCountryCodesToPriceMap['NZL'] = 113;
        iocCountryCodesToPriceMap['UKR'] = 113;
        iocCountryCodesToPriceMap['KAZ'] = 113;
        iocCountryCodesToPriceMap['IRL'] = 50;
        iocCountryCodesToPriceMap['JAM'] = 50;
        iocCountryCodesToPriceMap['SRB'] = 50;
        iocCountryCodesToPriceMap['PHI'] = 50;
        iocCountryCodesToPriceMap['IND'] = 50;
        iocCountryCodesToPriceMap['THA'] = 50;
        iocCountryCodesToPriceMap['MEX'] = 50;
        iocCountryCodesToPriceMap['PRK'] = 50;
        iocCountryCodesToPriceMap['BRA'] = 50;
        iocCountryCodesToPriceMap['EST'] = 50;
        iocCountryCodesToPriceMap['GHA'] = 50;
        iocCountryCodesToPriceMap['GRE'] = 50;
        iocCountryCodesToPriceMap['ISL'] = 50;

    }

    function createTeam(bytes32 _teamName, bytes3 _country1, bytes3 _country2, bytes3 _country3,   bytes3 _country4, bytes3 _country5, bytes3 _country6) public payable {
        require (msg.value > 99999999999999999);
        
        require (block.number < 5100000);

        require (_country1 != _country2);
        require (_country1 != _country3);
        require (_country1 != _country4);
        require (_country1 != _country5);
        require (_country1 != _country6);
        require (_country2 != _country3);
        require (_country2 != _country4);
        require (_country2 != _country5);
        require (_country2 != _country6);
        require (_country3 != _country4);
        require (_country3 != _country5);
        require (_country3 != _country6);
        require (_country4 != _country5);
        require (_country4 != _country6);
        require (_country5 != _country6);

        require (iocCountryCodesToPriceMap[_country1] > 0);
        require (iocCountryCodesToPriceMap[_country2] > 0);
        require (iocCountryCodesToPriceMap[_country3] > 0);
        require (iocCountryCodesToPriceMap[_country4] > 0);
        require (iocCountryCodesToPriceMap[_country5] > 0);
        require (iocCountryCodesToPriceMap[_country6] > 0);

        require (iocCountryCodesToPriceMap[_country1] +
        iocCountryCodesToPriceMap[_country2] +
        iocCountryCodesToPriceMap[_country3] +
        iocCountryCodesToPriceMap[_country4] +
        iocCountryCodesToPriceMap[_country5] +
        iocCountryCodesToPriceMap[_country6] < 12000);
        
        newTeamCreated( _teamName, _country1, _country2, _country3, _country4, _country5, _country6);

    }

    function withdraw(address payTo, uint256 amount) onlyOwner {
        require(amount <= this.balance);
        assert(payTo.send(amount));
    }

}