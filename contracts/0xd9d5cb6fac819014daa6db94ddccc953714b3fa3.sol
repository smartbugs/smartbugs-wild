pragma solidity ^ 0.4.11;

/**
	* @title SafeMath
	* @dev Math operations with safety checks that throw on error
*/
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns(uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function toUINT112(uint256 a) internal constant returns(uint112) {
        assert(uint112(a) == a);
        return uint112(a);
    }

    function toUINT120(uint256 a) internal constant returns(uint120) {
        assert(uint120(a) == a);
        return uint120(a);
    }

    function toUINT128(uint256 a) internal constant returns(uint128) {
        assert(uint128(a) == a);
        return uint128(a);
    }

    function percent(uint256 a, uint256 b) internal constant returns(uint256) {
        uint256 c = (b * a / 100);
        assert(c <= a);
        return c;
    }
}

contract Owned {

    address public owner;

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function setOwner(address _newOwner) onlyOwner {
        owner = _newOwner;
    }
}

/**
	* @title ERC20Basic
	* @dev Simpler version of ERC20 interface
	* @dev see https://github.com/ethereum/EIPs/issues/179
*/
contract ERC20Basic {
    function balanceOf(address who) public constant returns(uint256);
    function transfer(address to, uint256 value) public returns(bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
	* @title ERC20 interface
	* @dev see https://github.com/ethereum/EIPs/issues/20
*/
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns(uint256);
    function transferFrom(address from, address to, uint256 value) public returns(bool);
    function approve(address spender, uint256 value) public returns(bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
	* @title Basic token
	* @dev Basic version of StandardToken, with no allowances.
*/
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

        struct Account {
        uint256 balances;
        uint256 rawTokens;
        uint32 lastMintedTimestamp;
    }

    // Balances for each account
    mapping(address => Account) accounts;


	/**
		* @dev transfer token for a specified address
		* @param _to The address to transfer to.
		* @param _value The amount to be transferred.
	*/
    function transfer(address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));
        require(_value <= accounts[msg.sender].balances);

        // SafeMath.sub will throw if there is not enough balance.
        accounts[msg.sender].balances = accounts[msg.sender].balances.sub(_value);
        accounts[_to].balances = accounts[_to].balances.add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

	/**
		* @dev Gets the balance of the specified address.
		* @param _owner The address to query the the balance of.
		* @return An uint256 representing the amount owned by the passed address.
	*/
    function balanceOf(address _owner) public constant returns(uint256 balance) {
        return accounts[_owner].balances;
    }

}

/**
	* @title Standard ERC20 token
	*
	* @dev Implementation of the basic standard token.
	* @dev https://github.com/ethereum/EIPs/issues/20
	* @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
*/
contract StandardToken is ERC20, BasicToken {

    mapping(address => mapping(address => uint256)) internal allowed;


	/**
		* @dev Transfer tokens from one address to another
		* @param _from address The address which you want to send tokens from
		* @param _to address The address which you want to transfer to
		* @param _value uint256 the amount of tokens to be transferred
	*/
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));
        require(_value <= accounts[_from].balances);
        require(_value <= allowed[_from][msg.sender]);

        accounts[_from].balances = accounts[_from].balances.sub(_value);
        accounts[_to].balances = accounts[_to].balances.add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

	/**
		* @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
		*
		* Beware that changing an allowance with this method brings the risk that someone may use both the old
		* and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
		* race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
		* https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
		* @param _spender The address which will spend the funds.
		* @param _value The amount of tokens to be spent.
	*/
    function approve(address _spender, uint256 _value) public returns(bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

	/**
		* @dev Function to check the amount of tokens that an owner allowed to a spender.
		* @param _owner address The address which owns the funds.
		* @param _spender address The address which will spend the funds.
		* @return A uint256 specifying the amount of tokens still available for the spender.
	*/
    function allowance(address _owner, address _spender) public constant returns(uint256 remaining) {
        return allowed[_owner][_spender];
    }

	/**
		* approve should be called when allowed[_spender] == 0. To increment
		* allowed value is better to use this function to avoid 2 calls (and wait until
		* the first transaction is mined)
		* From MonolithDAO Token.sol
	*/
    function increaseApproval(address _spender, uint _addedValue) public returns(bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns(bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract BEC is StandardToken, Owned {
    string public constant name = "BITEXCHANGE";
    uint8 public constant decimals = 8;
    string public constant symbol = "BEC";
    bool public canClaimToken = false;
    uint256 public constant maxSupply = 30000000 * 10 ** uint256(decimals);
    uint256 public constant dateInit = 1522540800;

	/*          31 days     12months   12months
		|------------------|--x--x--x--|--x--x--x--|------------>
		04-01-18    ICO         LEND(*)       ECO    FINALIZED
		                        DEV
		                        MARK
		                        ADMIN
		(*): 100% tokens
	*/
    uint256 public constant dateICO = dateInit + 31 days;
    uint256 public constant dateRelease3 = dateICO + 90 days;
    uint256 public constant dateRelease6 = dateRelease3 + 90 days;
    uint256 public constant dateRelease9 = dateRelease6 + 90 days;
    uint256 public constant dateRelease12 = dateRelease9 + 90 days;

    uint256 public constant dateEcoRelease3 = dateRelease12 + 90 days;
    uint256 public constant dateEcoRelease6 = dateEcoRelease3 + 90 days;
    uint256 public constant dateEcoRelease9 = dateEcoRelease6 + 90 days;
    uint256 public constant dateEcoRelease12 = dateEcoRelease9 + 90 days;

    bool public isAllocatedICO = false;

    bool public isAllocatedLending = false;

    bool public isAllocated3 = false;
    bool public isAllocated6 = false;
    bool public isAllocated9 = false;
    bool public isAllocated12 = false;

    bool public isEcoAllocated3 = false;
    bool public isEcoAllocated6 = false;
    bool public isEcoAllocated9 = false;
    bool public isEcoAllocated12 = false;

    enum Stage {
        Finalized,
        ICO,
        Release3,
        Release6,
        Release9,
        Release12,
        Eco3,
        Eco6,
        Eco9,
        Eco12
    }

    struct Supplies {
        uint256 total;
        uint256 rawTokens;
    }

    //the stage for releasing Tokens
    struct StageRelease {
        uint256 rawTokens;
        uint256 totalRawTokens;
    }

    Supplies supplies;
    StageRelease public stageICO = StageRelease(maxSupply.percent(18), maxSupply.percent(18));
    StageRelease public stageLending = StageRelease(maxSupply.percent(27), maxSupply.percent(27));
    StageRelease public stageDevelop = StageRelease(maxSupply.percent(35), maxSupply.percent(35));
    StageRelease public stageMarketing = StageRelease(maxSupply.percent(9), maxSupply.percent(9));
    StageRelease public stageAdmin = StageRelease(maxSupply.percent(2), maxSupply.percent(2));
    StageRelease public stageEco = StageRelease(maxSupply.percent(9), maxSupply.percent(9));

    // Send back ether 
    function () {
        revert();
    }
    //getter totalSupply
    function totalSupply() public constant returns(uint256 total) {
        return supplies.total;
    }

    function mintToken(address _owner, uint256 _amount, bool _isRaw) onlyOwner internal {
        require(_amount.add(supplies.total) <= maxSupply);
        if (_isRaw) {
            accounts[_owner].rawTokens = _amount.add(accounts[_owner].rawTokens);
            supplies.rawTokens = _amount.add(supplies.rawTokens);
        } else {
            accounts[_owner].balances = _amount.add(accounts[_owner].balances);
        }
        supplies.total = _amount.add(supplies.total);
        Transfer(0, _owner, _amount);
    }

    function transferRaw(address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));
        require(_value <= accounts[msg.sender].rawTokens);


        // SafeMath.sub will throw if there is not enough balance.
        accounts[msg.sender].rawTokens = accounts[msg.sender].rawTokens.sub(_value);
        accounts[_to].rawTokens = accounts[_to].rawTokens.add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function setClaimToken(bool approve) onlyOwner public returns(bool) {
        canClaimToken = true;
        return canClaimToken;
    }

    function claimToken(address _owner) public returns(bool amount) {
        require(accounts[_owner].rawTokens != 0);
        require(canClaimToken);

        uint256 amountToken = accounts[_owner].rawTokens;
        accounts[_owner].rawTokens = 0;
        accounts[_owner].balances = amountToken + accounts[_owner].balances;
        return true;
    }

    function balanceOfRaws(address _owner) public constant returns(uint256 balance) {
        return accounts[_owner].rawTokens;
    }

    function blockTime() constant returns(uint32) {
        return uint32(block.timestamp);
    }

    function stage() constant returns(Stage) {

        if (blockTime() <= dateICO) {
            return Stage.ICO;
        }

        if (blockTime() <= dateRelease3) {
            return Stage.Release3;
        }

        if (blockTime() <= dateRelease6) {
            return Stage.Release6;
        }

        if (blockTime() <= dateRelease9) {
            return Stage.Release9;
        }

        if (blockTime() <= dateRelease12) {
            return Stage.Release12;
        }

        if (blockTime() <= dateEcoRelease3) {
            return Stage.Eco3;
        }

        if (blockTime() <= dateEcoRelease6) {
            return Stage.Eco6;
        }

        if (blockTime() <= dateEcoRelease9) {
            return Stage.Eco9;
        }

        if (blockTime() <= dateEcoRelease12) {
            return Stage.Eco12;
        }

        return Stage.Finalized;
    }

    function releaseStage(uint256 amount, StageRelease storage stageRelease, bool isRaw) internal returns(uint256) {
        if (stageRelease.rawTokens > 0) {
            int256 remain = int256(stageRelease.rawTokens - amount);
            if (remain < 0)
                amount = stageRelease.rawTokens;
            stageRelease.rawTokens = stageRelease.rawTokens.sub(amount);
            mintToken(owner, amount, isRaw);
            return amount;
        }
        return 0;
    }

    function releaseNotEco(uint256 percent, bool isRaw) internal returns(uint256) {

        uint256 amountDevelop = stageDevelop.totalRawTokens.percent(percent);
        uint256 amountMarketing = stageMarketing.totalRawTokens.percent(percent);
        uint256 amountAdmin = stageAdmin.totalRawTokens.percent(percent);
        uint256 amountSum = amountDevelop + amountMarketing + amountAdmin;

        releaseStage(amountDevelop, stageDevelop, isRaw);
        releaseStage(amountMarketing, stageMarketing, isRaw);
        releaseStage(amountAdmin, stageAdmin, isRaw);
        return amountSum;
    }

    function releaseEco(uint256 percent, bool isRaw) internal returns(uint256) {
        uint256 amountEco = stageEco.totalRawTokens.percent(percent);
        releaseStage(amountEco, stageEco, isRaw);
        return amountEco;
    }

    function release100Percent(bool isRaw, StageRelease storage stageRelease) internal returns(uint256) {
        uint256 amount = stageRelease.totalRawTokens.percent(100);
        releaseStage(amount, stageRelease, isRaw);
        return amount;
    }

    //main function, must run for releasing.
    //##################################################################33
    function release(bool isRaw) onlyOwner public returns(uint256) {
        uint256 amountSum = 0;

        if (stage() == Stage.ICO && isAllocatedICO == false) {
            uint256 amountICO = release100Percent(isRaw, stageICO);
            amountSum = amountSum.add(amountICO);
            isAllocatedICO = true;
            return amountSum;
        }

        if (stage() == Stage.Release3 && isAllocated3 == false) {
            uint256 amountRelease3 = releaseNotEco(40, isRaw);
            amountSum = amountSum.add(amountRelease3);
            //for lending
            amountRelease3 = release100Percent(isRaw, stageLending);
            amountSum = amountSum.add(amountRelease3);
            isAllocated3 = true;
            return amountSum;
        }

        if (stage() == Stage.Release6 && isAllocated6 == false) {
            uint256 amountRelease6 = releaseNotEco(10, isRaw);
            amountSum = amountSum.add(amountRelease6);
            isAllocated6 = true;
            return amountSum;
        }

        if (stage() == Stage.Release9 && isAllocated9 == false) {
            uint256 amountRelease9 = releaseNotEco(30, isRaw);
            amountSum = amountSum.add(amountRelease9);
            isAllocated9 = true;
            return amountSum;
        }

        if (stage() == Stage.Release12 && isAllocated12 == false) {
            uint256 amountRelease12 = releaseNotEco(20, isRaw);
            amountSum = amountSum.add(amountRelease12);
            isAllocated12 = true;
            return amountSum;
        }

        if (stage() == Stage.Eco3 && isEcoAllocated3 == false) {
            uint256 amountEcoRelease3 = releaseEco(40, isRaw);
            amountSum = amountSum.add(amountEcoRelease3);
            isEcoAllocated3 = true;
            return amountSum;
        }

        if (stage() == Stage.Eco6 && isEcoAllocated6 == false) {
            uint256 amountEcoRelease6 = releaseEco(10, isRaw);
            amountSum = amountSum.add(amountEcoRelease6);
            isEcoAllocated6 = true;
            return amountSum;
        }

        if (stage() == Stage.Eco9 && isEcoAllocated9 == false) {
            uint256 amountEcoRelease9 = releaseEco(20, isRaw);
            amountSum = amountSum.add(amountEcoRelease9);
            isEcoAllocated9 = true;
            return amountSum;
        }
        if (stage() == Stage.Eco12 && isEcoAllocated12 == false) {
            uint256 amountEcoRelease12 = releaseEco(30, isRaw);
            amountSum = amountSum.add(amountEcoRelease12);
            isEcoAllocated12 = true;
            return amountSum;
        }
        return amountSum;
    }
}