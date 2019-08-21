/**
 * https://GreenRabbit.site
 *
 * Welcome to Green Rabbit's smart Kingdom.
 *
 * Here you can collect or earn GRC tokens (Green Rabbit's Coins) and sell it for Ethereum.
 * Send Ethereum to the contract address for buying GRC tokens.
 * Attention: purchase price more than sale price by 11.1%
 *
 * The price of GRC tokens will be increased by 1% per day.
 * 
 * For create the kingdom, you should to spend GRC tokens for increasing the number of citizens or warriors of your kingdom. 
 *
 * If you want to be just an investor, don't add citizens or warriors and your kingdom won't be created.
 * 
 * Each citizen of your Kingdom will pay tribute to you. One citizen pays tribute equal kingdom prosperity, per 7 days.
 * Your warriors can attack random kingdoms and can pick up their coins. One warrior can pick up number of GRC equal (100 - attacked kingdom defence).
 * After attack, number of your warriors will be reduced by percent of defence of attacked kingdom.
 * Send 0.01 ether to the contract 0x76d7aed5ab1c4a5e210d0ccac747d097f9d58966 for attack random kingdom.
 * Attention: You won't lose warriors, if attacked kingdom have GRC number less than 10000.
 *
 * Each kingdom have prosperity and defence levels. Sum of prosperity and defence levels always will be equal 100.
 * You can increase prosperity and reduce defence level by 10 sending 0.000333 ether to the contract address. Maximum prosperity is 100.
 * You can increase defence and reduce prosperity level by 10 sending 0.000444 ether to the contract address. Maximum defence is 90.
 *
 * Citizens will pay GRC tokens depending on their level of prosperity, the more it is, the more they will pay.
 * Attention! You can lost part of your coins, if your defence is not high and your kingdom would be under attack.
 *
 * Send from 0 to 0.00001 ether to this contract address for sell all your GRC tokens.
 * Send 0.000111 ether to spend your tokens to add citizens to your kingdom. 
 * Send 0.000222 ether to spend your tokens to add warriors to your kingdom. 
 * Send 0.000333 ether to set +10 prosperity and -10 defence level of your kingdom. 
 * Send 0.000444 ether to set +10 defence and -10 prosperity level of your kingdom. 
 *
 * Use 200000 of Gas limit for your transactions.
 *
 * Admin commissions: 5% from GRC tokens buying.
 *
 * Game will be paused for 3 days when balance is null and will be auto restarted, all kingdoms and tokens will be burnt.
 * 
 */

pragma solidity ^0.4.25;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0);
        uint256 c = _a / _b;

        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);

}

contract Ownable {
	address private owner;
	
    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }	
}

contract ERC20 is Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

	uint256 private _totalSupply;
	
	 
    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
    * @dev Transfer token for a specified address
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address from, address to, uint256 value) public onlyOwner returns (bool) {
        _transfer(from, to, value);
        return true;
    }

    /**
    * @dev Mint token for a specified address
    * @param account The address to mint to.
    * @param value The amount to be minted.
    */
    function mint(address account, uint256 value) public onlyOwner returns (bool) {
        _mint(account, value);
        return true;
    }
	
    /**
    * @dev Burn token for a specified address
    * @param account The address to burn from.
    * @param value The amount to be burnt.
    */
    function burn(address account, uint256 value) public onlyOwner returns (bool) {
        _burn(account, value);
        return true;
    }	
	
    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
    }


}

contract KingdomStorage is ERC20 {
    using SafeMath for uint256;

    uint private _kingdomsCount;

    struct Kingdom {
        uint numberOfCitizens;
		uint numberOfWarriors;
		uint prosperity;
		uint defence;
		uint lostCoins; //lost tokens in wars
        uint tributeCheckpoint;
    }

	mapping (uint => address) private kingdomAddress;
    mapping (address => Kingdom) private kingdoms;
	
	event War(address indexed _attacked, address indexed _invader, uint _lostCoins, uint _slayedWarriors);

    function addCitizens(address _address, uint _number, bool _are_warriors) external onlyOwner {
		if (kingdoms[_address].prosperity == 0) {
			// create the new kingdom
			kingdomAddress[_kingdomsCount] = _address;
			kingdoms[_address].prosperity = 50;
			kingdoms[_address].defence = 50;	
			_kingdomsCount++;
		}
		
        if (_are_warriors) {
			// add warriors	
			kingdoms[_address].numberOfWarriors = kingdoms[_address].numberOfWarriors.add(_number);
		} else {
			// add citizens
			kingdoms[_address].numberOfCitizens = kingdoms[_address].numberOfCitizens.add(_number);
			kingdoms[_address].tributeCheckpoint = block.timestamp;
		}

    }
	
    function getTribute(address _address) external onlyOwner {
		uint tributeValue = getTributeValue(_address);
		if (tributeValue > 0) {
			mint(_address, tributeValue);
			kingdoms[_address].tributeCheckpoint = block.timestamp;
			kingdoms[_address].lostCoins = 0;
		}
    }
	
	function startWar(address _invader, address _attacked) external onlyOwner {
		uint invaderWarriorsNumber = getWarriorsNumber(_invader);
		require (invaderWarriorsNumber >0);
		
		uint attackedKingdomBalance = balanceOf(_attacked);		
		uint attackedKingdomWealth = getTributeValue(_attacked).add(attackedKingdomBalance);
		uint attackedKingdomDefence = getDefence(_attacked); 
		
		// one warrior picks up number of GRC equal (100 - attacked kingdom defence)
		uint attackPower = invaderWarriorsNumber.mul(100 - attackedKingdomDefence); 
		if (attackPower > attackedKingdomWealth)
			attackPower = attackedKingdomWealth;
		
		// defence action: slay warriors
		uint slayedWarriors;
		// dont slay, if attackedKingdomWealth <= 10000 GRC
		if (attackedKingdomWealth > 10000) {
			slayedWarriors = invaderWarriorsNumber.mul(attackedKingdomDefence).div(100);	
			kingdoms[_invader].numberOfWarriors -= slayedWarriors;
		}
		
		// invader action: pick up tokens
		uint lostCoins;
		
		if (attackedKingdomBalance >= attackPower) {
			transfer(_attacked, _invader, attackPower);
			lostCoins += attackPower;
			attackPower = 0;
		} else if (attackedKingdomBalance > 0) {
			transfer(_attacked, _invader, attackedKingdomBalance);
			lostCoins += attackedKingdomBalance;
			attackPower -= attackedKingdomBalance;
		} 

		if (attackPower > 0) {
			kingdoms[_attacked].lostCoins += attackPower;
			mint(_invader, attackPower);
			lostCoins += attackPower;
		}
		
		emit War(_attacked, _invader, lostCoins, slayedWarriors);
	}
	
	function warFailed(address _invader) external onlyOwner {
		emit War(address(0), _invader, 0, 0);
	}
	
    function increaseProsperity(address _address) external onlyOwner {
		// minimum defence = 0%, maximum prosperity = 100%
		if (kingdoms[_address].prosperity <= 90) {
			kingdoms[_address].prosperity += 10;
			kingdoms[_address].defence -= 10;
		}
    }	
	
    function increaseDefence(address _address) external onlyOwner {
		// maximum defence = 90%, minimum prosperity = 10%
		if (kingdoms[_address].defence <= 80) {
			kingdoms[_address].defence += 10;
			kingdoms[_address].prosperity -= 10;
		}
    }	

    function getTributeValue(address _address) public view returns(uint) {
		uint numberOfCitizens = getCitizensNumber(_address);
		if (numberOfCitizens > 0) {
			// one citizen gives tribute equal kingdom prosperity, per 7 days;
			return numberOfCitizens.mul(getProsperity(_address)).mul(block.timestamp.sub(getTributeCheckpoint(_address))).div(7 days).sub(getLostCoins(_address)); 
		}
		return 0;
    }	

    function getProsperity(address _address) public view returns(uint) {
		return kingdoms[_address].prosperity;
    }
	
    function getDefence(address _address) public view returns(uint) {
		return kingdoms[_address].defence;
    }	
    function getLostCoins(address _address) public view returns(uint) {
		return kingdoms[_address].lostCoins;
    }	

    function getCitizensNumber(address _address) public view returns(uint) {
        return kingdoms[_address].numberOfCitizens;
    }

    function getWarriorsNumber(address _address) public view returns(uint) {
        return kingdoms[_address].numberOfWarriors;
    }
	
    function getTributeCheckpoint(address _address) public view returns(uint) {
        return kingdoms[_address].tributeCheckpoint;
    }

    function getKingdomAddress(uint _kingdomId) external view returns(address) {
        return kingdomAddress[_kingdomId];
    }
	
	function kingdomsCount() external view returns(uint) {
        return _kingdomsCount;
    }
}

contract GreenRabbitKingdom is IERC20 {
    using SafeMath for uint;

    address admin;

    uint invested;
    uint payed;
    uint startTime;
	uint tokenStartPrice;
	
	string public name = 'GreenRabbitCoin';
	string public symbol = 'GRC';
	uint public decimals = 0;
	
    event LogNewGame(uint _startTime);
	
    KingdomStorage private kingdom;

    modifier notOnPause() {
        require(startTime <= block.timestamp, "Game paused");
        _;
    }

    constructor() public {
        admin = msg.sender;
        kingdom = new KingdomStorage();
        startTime = now;
		tokenStartPrice = 1 szabo; //0.000001 ETH
    }
 
    function() external payable {
        if (msg.value == 0 && msg.value <= 0.00001 ether) {
            sellTokens();
        } else if (msg.value == 0.000111 ether) {
			//add citizens, not warriors
            addCitizens(false);
        } else if (msg.value == 0.000222 ether) {
			//add warriors
            addCitizens(true);
        } else if (msg.value == 0.000333 ether) {
            increaseProsperity();
        } else if (msg.value == 0.000444 ether) {
            increaseDefence();
		} else {            
			buyTokens();
        }
    }

    /**
     * @dev ERC20 function
     */
    function totalSupply() external view returns (uint256) {
        return kingdom.totalSupply();
    }

    /**
     * @dev ERC20 function
     */
    function transfer(address to, uint256 value) external returns (bool) {
		// get tribute from your citizens before
		kingdom.getTribute(msg.sender);
        return kingdom.transfer(msg.sender, to, value);
    }	

    /**
     * @dev ERC20 function
     */
	function balanceOf(address owner) public view returns (uint256) {
        return kingdom.balanceOf(owner);
    }
	
    function buyTokens() notOnPause public payable {
		require (msg.value >= 0.001 ether);
		uint tokensValue = msg.value.div(getTokenSellPrice()).mul(90).div(100);
		kingdom.mint(msg.sender, tokensValue);
		admin.send(msg.value / 20); //5%
		emit Transfer(address(0), msg.sender, tokensValue);
    }

    function sellTokens() notOnPause public {
		// get tribute from your citizens before
		kingdom.getTribute(msg.sender);
		
        uint tokensValue = balanceOf(msg.sender); 
		uint payout = tokensValue.mul(getTokenSellPrice());

        if (payout > 0) {

            if (payout > address(this).balance) {
				msg.sender.transfer(address(this).balance);
                nextGame();
                return;
            }

            msg.sender.transfer(payout);
			
			kingdom.burn(msg.sender, tokensValue);
			emit Transfer(msg.sender, address(0), tokensValue);
        }		
    }
	
	function addCitizens(bool _are_warriors) notOnPause public {
		// get tribute from your citizens before adding new citizens
		kingdom.getTribute(msg.sender);
		
		uint CitizensNumber = balanceOf(msg.sender).div(100);
		if (CitizensNumber > 0) {
			kingdom.addCitizens(msg.sender,CitizensNumber,_are_warriors);
			kingdom.burn(msg.sender, CitizensNumber * 100);
		}
	}
	
    function attackKingdom(address _invader, uint _random) notOnPause public returns(bool) {
		// Only for invader's smart contract:
		// https://etherscan.io/address/0x76d7aed5ab1c4a5e210d0ccac747d097f9d58966
		require (msg.sender == 0x76d7aed5ab1c4a5e210d0ccac747d097f9d58966); 
		
		uint attackedKingdomId = _random % (kingdom.kingdomsCount());
		address attackedKingdomAddress = kingdom.getKingdomAddress(attackedKingdomId);
		
		if (_invader != attackedKingdomAddress) {
			kingdom.startWar(_invader, attackedKingdomAddress);
		} else {
			// you can't attack youself
			kingdom.warFailed(_invader);
		}
			
        return true;
    }	
	
	function increaseProsperity() notOnPause public {
		// get tribute from your citizens before
		kingdom.getTribute(msg.sender);
		kingdom.increaseProsperity(msg.sender);
	}
	
	function increaseDefence() notOnPause public {
		// get tribute from your citizens before
		kingdom.getTribute(msg.sender);		
		kingdom.increaseDefence(msg.sender);
	}
	
	function synchronizeTokensBalance() notOnPause public {
		// get tribute from your citizens 
		// for release real tokens that you can see them in your ERC-20 wallet 
		kingdom.getTribute(msg.sender);		
	}	
	
	function getTokenSellPrice() public view returns(uint) {
		//each day +1% to token price
		return tokenStartPrice.add( tokenStartPrice.div(100).mul(block.timestamp.sub(startTime).div(1 days)) );
	}

    function getGameAge() external view returns(uint) {
		if (block.timestamp > startTime)
			return block.timestamp.sub(startTime).div(1 days).add(1);
		else 
			return 0;
    }
	
    function getKingdomsCount() external view returns(uint) {
        return kingdom.kingdomsCount();
    }
	
    function getKingdomData(address _address) external view returns(uint numberOfCitizens, uint numberOfWarriors, uint prosperity, uint defence, uint balance) {
		numberOfCitizens = kingdom.getCitizensNumber(_address);
		numberOfWarriors = kingdom.getWarriorsNumber(_address);
		prosperity = kingdom.getProsperity(_address);
		defence = kingdom.getDefence(_address);
		balance = kingdom.getTributeValue(_address) + balanceOf(_address);
    }	

    function getBalance() external view returns(uint) {
        return address(this).balance;
    }

    function nextGame() private {
        kingdom = new KingdomStorage();
        startTime = block.timestamp + 3 days;
        emit LogNewGame(startTime);
    }
	
}