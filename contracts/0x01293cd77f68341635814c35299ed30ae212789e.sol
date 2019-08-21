pragma solidity ^0.4.18;

contract NBACrypto {

	address ceoAddress = 0xD2f0e35EB79789Ea24426233336DDa6b13E2fA1f;
    address cfoAddress = 0x831a278fF506bf4dAa955359F9c5DA9B9Be18f3A;

	struct Team {
		string name;
		address ownerAddress;
		uint256 curPrice;
	}

  struct Player {
    string name;
    address ownerAddress;
    uint256 curPrice;
    uint256 realTeamId;
  }
	Team[] teams;
  Player[] players;

	modifier onlyCeo() {
        require (msg.sender == ceoAddress);
        _;
    }

    bool teamsAreInitiated;
    bool playersAreInitiated;
    bool isPaused;

    /*
    We use the following functions to pause and unpause the game.
    */
    function pauseGame() public onlyCeo {
        isPaused = true;
    }
    function unPauseGame() public onlyCeo {
        isPaused = false;
    }
    function GetIsPauded() public view returns(bool) {
       return(isPaused);
    }


	function purchaseCountry(uint _countryId) public payable {
		require(msg.value == teams[_countryId].curPrice);
		require(isPaused == false);


		uint256 commission5percent = (msg.value / 10);


		uint256 commissionOwner = msg.value - commission5percent; // => 95%
		teams[_countryId].ownerAddress.transfer(commissionOwner);


		cfoAddress.transfer(commission5percent);

		// Update the team owner and set the new price
		teams[_countryId].ownerAddress = msg.sender;
		teams[_countryId].curPrice = mul(teams[_countryId].curPrice, 2);
	}

  function purchasePlayer(uint256 _playerId) public payable {
    require(msg.value == players[_playerId].curPrice);
	require(isPaused == false);

    // Calculate dev fee
		uint256 commissionDev = (msg.value / 10);

    //Calculate commision for team owner
    uint256 commisionTeam = (msg.value / 5);

    uint256 afterDevCut = msg.value - commissionDev;



		// Calculate the owner commission on this sale & transfer the commission to the owner.
		uint256 commissionOwner = afterDevCut - commisionTeam; //
		players[_playerId].ownerAddress.transfer(commissionOwner);
    teams[players[_playerId].realTeamId].ownerAddress.transfer(commisionTeam);

		// Transfer fee to Dev
		cfoAddress.transfer(commissionDev);

		// Update the team owner and set the new price


		players[_playerId].ownerAddress = msg.sender;
		players[_playerId].curPrice = mul(players[_playerId].curPrice, 2);
  }

	/*
	This function can be used by the owner of a team to modify the price of its team.
	He can make the price smaller than the current price but never bigger.
	*/
	function modifyPriceCountry(uint _teamId, uint256 _newPrice) public {
	    require(_newPrice > 0);
	    require(teams[_teamId].ownerAddress == msg.sender);
	    require(_newPrice < teams[_teamId].curPrice);
	    teams[_teamId].curPrice = _newPrice;
	}

	// This function will return all of the details of our teams
	function getTeam(uint _teamId) public view returns (
        string name,
        address ownerAddress,
        uint256 curPrice
    ) {
        Team storage _team = teams[_teamId];

        name = _team.name;
        ownerAddress = _team.ownerAddress;
        curPrice = _team.curPrice;
    }

    function getPlayer(uint _playerId) public view returns (
          string name,
          address ownerAddress,
          uint256 curPrice,
          uint256 realTeamId
      ) {
          Player storage _player = players[_playerId];

          name = _player.name;
          ownerAddress = _player.ownerAddress;
          curPrice = _player.curPrice;
          realTeamId = _player.realTeamId;
      }


    // This function will return only the price of a specific team
    function getTeamPrice(uint _teamId) public view returns(uint256) {
        return(teams[_teamId].curPrice);
    }

    function getPlayerPrice(uint _playerId) public view returns(uint256) {
        return(players[_playerId].curPrice);
    }

    // This function will return only the addess of a specific team
    function getTeamOwner(uint _teamId) public view returns(address) {
        return(teams[_teamId].ownerAddress);
    }

    function getPlayerOwner(uint _playerId) public view returns(address) {
        return(players[_playerId].ownerAddress);
    }

    /**
    @dev Multiplies two numbers, throws on overflow. => From the SafeMath library
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
          return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    @dev Integer division of two numbers, truncating the quotient. => From the SafeMath library
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

	// We run this function once to create all the teams and set the initial price.
	function InitiateTeams() public onlyCeo {
		 require(teamsAreInitiated == false);
		 teams.push(Team("Cavaliers", 0x54d6fca0ca37382b01304e6716420538604b447b, 6400000000000000000));
 		 teams.push(Team("Warriors", 0xc88ddaa37c1fec910670366ae16df2aa5e1124f7, 12800000000000000000));
 		 teams.push(Team("Celtics", 0x28d02f67316123dc0293849a0d254ad86b379b34, 6400000000000000000));
		 teams.push(Team("Rockets", 0xc88ddaa37c1fec910670366ae16df2aa5e1124f7, 6400000000000000000));
		 teams.push(Team("Raptors", 0x5c035bb4cb7dacbfee076a5e61aa39a10da2e956, 6400000000000000000));
		 teams.push(Team("Spurs", 0x183febd8828a9ac6c70c0e27fbf441b93004fc05, 3200000000000000000));
		 teams.push(Team("Wizards", 0xaec539a116fa75e8bdcf016d3c146a25bc1af93b, 3200000000000000000));
		 teams.push(Team("Timberwolves", 0xef764bac8a438e7e498c2e5fccf0f174c3e3f8db, 3200000000000000000));
		 teams.push(Team("Pacers", 0x8e668a4582d0465accf66b4e4ab6d817f6c5b2dc, 3200000000000000000));
		 teams.push(Team("Thunder", 0x7d757e571bd545008a95cd0c48d2bb164faa72e3, 3200000000000000000));
		 teams.push(Team("Bucks", 0x1edb4c7b145cef7e46d5b5c256cedcd5c45f2ece, 3200000000000000000));
		 teams.push(Team("Lakers", 0xa2381223639181689cd6c46d38a1a4884bb6d83c, 3200000000000000000));
		 teams.push(Team("76ers", 0xa2381223639181689cd6c46d38a1a4884bb6d83c, 3200000000000000000));
		 teams.push(Team("Blazers", 0x54d6fca0ca37382b01304e6716420538604b447b, 1600000000000000000));
		 teams.push(Team("Heat", 0xef764bac8a438e7e498c2e5fccf0f174c3e3f8db, 3200000000000000000));
		 teams.push(Team("Pelicans", 0x54d6fca0ca37382b01304e6716420538604b447b, 1600000000000000000));
		 teams.push(Team("Pistons", 0x54d6fca0ca37382b01304e6716420538604b447b, 1600000000000000000));
		 teams.push(Team("Clippers", 0x7ec915b8d3ffee3deaae5aa90def8ad826d2e110, 3200000000000000000));
		 teams.push(Team("Hornets", 0x7ec915b8d3ffee3deaae5aa90def8ad826d2e110, 3200000000000000000));
		 teams.push(Team("Jazz", 0x54d6fca0ca37382b01304e6716420538604b447b, 1600000000000000000));
		 teams.push(Team("Knicks", 0x7ec915b8d3ffee3deaae5aa90def8ad826d2e110, 3200000000000000000));
		 teams.push(Team("Nuggets", 0x7ec915b8d3ffee3deaae5aa90def8ad826d2e110, 3200000000000000000));
		 teams.push(Team("Bulls", 0x28d02f67316123dc0293849a0d254ad86b379b34, 3200000000000000000));
		 teams.push(Team("Grizzlies", 0x7ec915b8d3ffee3deaae5aa90def8ad826d2e110, 3200000000000000000));
		 teams.push(Team("Nets", 0x54d6fca0ca37382b01304e6716420538604b447b, 1600000000000000000));
		 teams.push(Team("Kings", 0x7ec915b8d3ffee3deaae5aa90def8ad826d2e110, 3200000000000000000));
		 teams.push(Team("Magic", 0xb87e73ad25086c43a16fe5f9589ff265f8a3a9eb, 3200000000000000000));
		 teams.push(Team("Mavericks", 0x7ec915b8d3ffee3deaae5aa90def8ad826d2e110, 3200000000000000000));
		 teams.push(Team("Hawks", 0x7ec915b8d3ffee3deaae5aa90def8ad826d2e110, 3200000000000000000));
		 teams.push(Team("Suns", 0x7ec915b8d3ffee3deaae5aa90def8ad826d2e110, 3200000000000000000));
	}

    function addPlayer(string name, address address1, uint256 price, uint256 realTeamId) public onlyCeo {
        players.push(Player(name,address1,price,realTeamId));
    }



}