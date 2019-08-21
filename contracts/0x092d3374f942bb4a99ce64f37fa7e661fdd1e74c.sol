pragma solidity ^0.4.17;

//Developed by Zenos Pavlakou

library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure  returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
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


contract Ownable {
    
    address public owner;

    /**
     * The address whcih deploys this contrcat is automatically assgined ownership.
     * */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
     * Functions with this modifier can only be executed by the owner of the contract. 
     * */
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}


contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) constant public returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) constant public returns (uint256);
    function transferFrom(address from, address to, uint256 value) public  returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract BasicToken is ERC20Basic, Ownable {

    using SafeMath for uint256;

    mapping (address => uint256) balances;

    modifier onlyPayloadSize(uint size) {
        if (msg.data.length < size + 4) {
        revert();
        }
        _;
    }

    /**
     * Transfers ACO tokens from the sender's account to another given account.
     * 
     * @param _to The address of the recipient.
     * @param _amount The amount of tokens to send.
     * */
    function transfer(address _to, uint256 _amount) public onlyPayloadSize(2 * 32) returns (bool) {
        require(balances[msg.sender] >= _amount);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    /**
     * Returns the balance of a given address.
     * 
     * @param _addr The address of the balance to query.
     **/
    function balanceOf(address _addr) public constant returns (uint256) {
        return balances[_addr];
    }
}


contract AdvancedToken is BasicToken, ERC20 {

    mapping (address => mapping (address => uint256)) allowances;

    /**
     * Transfers tokens from the account of the owner by an approved spender. 
     * The spender cannot spend more than the approved amount. 
     * 
     * @param _from The address of the owners account.
     * @param _amount The amount of tokens to transfer.
     * */
    function transferFrom(address _from, address _to, uint256 _amount) public onlyPayloadSize(3 * 32) returns (bool) {
        require(allowances[_from][msg.sender] >= _amount && balances[_from] >= _amount);
        allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_amount);
        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(_from, _to, _amount);
        return true;
    }

    /**
     * Allows another account to spend a given amount of tokens on behalf of the 
     * owner's account. If the owner has previously allowed a spender to spend
     * tokens on his or her behalf and would like to change the approval amount,
     * he or she will first have to set the allowance back to 0 and then update
     * the allowance.
     * 
     * @param _spender The address of the spenders account.
     * @param _amount The amount of tokens the spender is allowed to spend.
     * */
    function approve(address _spender, uint256 _amount) public returns (bool) {
        require((_amount == 0) || (allowances[msg.sender][_spender] == 0));
        allowances[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }


    /**
     * Returns the approved allowance from an owners account to a spenders account.
     * 
     * @param _owner The address of the owners account.
     * @param _spender The address of the spenders account.
     **/
    function allowance(address _owner, address _spender) public constant returns (uint256) {
        return allowances[_owner][_spender];
    }
}


contract MintableToken is AdvancedToken {

    bool public mintingFinished;

    event TokensMinted(address indexed to, uint256 amount);
    event MintingFinished();

    /**
     * Generates new ACO tokens during the ICO, after which the minting period 
     * will terminate permenantly. This function can only be called by the ICO 
     * contract.
     * 
     * @param _to The address of the account to mint new tokens to.
     * @param _amount The amount of tokens to mint. 
     * */
    function mint(address _to, uint256 _amount) external onlyOwner onlyPayloadSize(2 * 32) returns (bool) {
        require(_to != 0x0 && _amount > 0 && !mintingFinished);
        balances[_to] = balances[_to].add(_amount);
        totalSupply = totalSupply.add(_amount);
        Transfer(0x0, _to, _amount);
        TokensMinted(_to, _amount);
        return true;
    }

    /**
     * Terminates the minting period permenantly. This function can only be called
     * by the ICO contract only when the duration of the ICO has ended. 
     * */
    function finishMinting() external onlyOwner {
        require(!mintingFinished);
        mintingFinished = true;
        MintingFinished();
    }
    
    /**
     * Returns true if the minting period has ended, false otherwhise.
     * */
    function mintingFinished() public constant returns (bool) {
        return mintingFinished;
    }
}


contract ACO is MintableToken {

    uint8 public decimals;
    string public name;
    string public symbol;

    function ACO() public {
        totalSupply = 0;
        decimals = 18;
        name = "ACO";
        symbol = "ACO";
    }
}


contract MultiOwnable {
    
    address[2] public owners;

    event OwnershipTransferred(address from, address to);
    event OwnershipGranted(address to);

    function MultiOwnable() public {
        owners[0] = 0x1d554c421182a94E2f4cBD833f24682BBe1eeFe8; //R1
        owners[1] = 0x0D7a2716466332Fc5a256FF0d20555A44c099453; //R2
    }

    /**
     * Functions with this modifier will only execute if the the function is called by the 
     * owners of the contract.
     * */ 
    modifier onlyOwners {
        require(msg.sender == owners[0] || msg.sender == owners[1]);
        _;
    }

    /**
     * Trasfers ownership from the owner who executes the function to another given address.
     * 
     * @param _newOwner The address which will be granted ownership.
     * */
    function transferOwnership(address _newOwner) public onlyOwners {
        require(_newOwner != 0x0 && _newOwner != owners[0] && _newOwner != owners[1]);
        if (msg.sender == owners[0]) {
            OwnershipTransferred(owners[0], _newOwner);
            owners[0] = _newOwner;
        } else {
            OwnershipTransferred(owners[1], _newOwner);
            owners[1] = _newOwner;
        }
    }
}


contract Crowdsale is MultiOwnable {

    using SafeMath for uint256;

    ACO public ACO_Token;

    address public constant MULTI_SIG = 0x3Ee28dA5eFe653402C5192054064F12a42EA709e;

    bool public success;
    uint256 public rate;
    uint256 public rateWithBonus;
    uint256 public tokensSold;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public minimumGoal;
    uint256 public cap;
    uint256[4] private bonusStages;

    mapping (address => uint256) investments;
    mapping (address => bool) hasAuthorizedWithdrawal;

    event TokensPurchased(address indexed by, uint256 amount);
    event RefundIssued(address indexed by, uint256 amount);
    event FundsWithdrawn(address indexed by, uint256 amount);
    event IcoSuccess();
    event CapReached();

    function Crowdsale() public {
        ACO_Token = new ACO();
        minimumGoal = 3000 ether;
        cap = 87500 ether;
        rate = 4000;
        startTime = now.add(3 days);
        endTime = startTime.add(90 days);
        bonusStages[0] = startTime.add(14 days);

        for (uint i = 1; i < bonusStages.length; i++) {
            bonusStages[i] = bonusStages[i - 1].add(14 days);
        }
    }

    /**
     * Fallback function calls the buyTokens function when ETH is sent to this 
     * contact.
     * */
    function() public payable {
        buyTokens(msg.sender);
    }

    /**
     * Allows investors to buy ACO tokens. Once ETH is sent to this contract, 
     * the investor will automatically receive tokens. 
     * 
     * @param _beneficiary The address the newly minted tokens will be sent to.
     * */
    function buyTokens(address _beneficiary) public payable {
        require(_beneficiary != 0x0 && validPurchase() && weiRaised().sub(msg.value) < cap);
        if (this.balance >= minimumGoal && !success) {
            success = true;
            IcoSuccess();
        }
        uint256 weiAmount = msg.value;
        if (this.balance > cap) {
            CapReached();
            uint256 toRefund = this.balance.sub(cap);
            msg.sender.transfer(toRefund);
            weiAmount = weiAmount.sub(toRefund);
        }
        uint256 tokens = weiAmount.mul(getCurrentRateWithBonus());
        ACO_Token.mint(_beneficiary, tokens);
        tokensSold = tokensSold.add(tokens);
        investments[_beneficiary] = investments[_beneficiary].add(weiAmount);
        TokensPurchased(_beneficiary, tokens);
    }

    /**
     * Returns the amount of tokens 1 ETH equates to with the bonus percentage.
     * */
    function getCurrentRateWithBonus() public returns (uint256) {
        rateWithBonus = (rate.mul(getBonusPercentage()).div(100)).add(rate);
        return rateWithBonus;
    }

    /**
     * Calculates and returns the bonus percentage based on how early an investment
     * is made. If ETH is sent to the contract after the bonus period, the bonus 
     * percentage will default to 0
     * */
    function getBonusPercentage() internal view returns (uint256 bonusPercentage) {
        uint256 timeStamp = now;
        if (timeStamp > bonusStages[3]) {
            bonusPercentage = 0;
        } else { 
            bonusPercentage = 25;
            for (uint i = 0; i < bonusStages.length; i++) {
                if (timeStamp <= bonusStages[i]) {
                    break;
                } else {
                    bonusPercentage = bonusPercentage.sub(5);
                }
            }
        }
        return bonusPercentage;
    }

    /**
     * Returns the current rate 1 ETH equates to including the bonus amount. 
     * */
    function currentRate() public constant returns (uint256) {
        return rateWithBonus;
    }

    /**
     * Checks whether an incoming transaction from the buyTokens function is 
     * valid or not. For a purchase to be valid, investors have to buy tokens
     * only during the ICO period and the value being transferred must be greater
     * than 0.
     * */
    function validPurchase() internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }
    
    /**
     * Issues a refund to a given address. This function can only be called if
     * the duration of the ICO has ended and the minimum goal has not been reached.
     * 
     * @param _addr The address that will receive a refund. 
     * */
    function getRefund(address _addr) public {
        if (_addr == 0x0) {
            _addr = msg.sender;
        }
        require(!isSuccess() && hasEnded() && investments[_addr] > 0);
        uint256 toRefund = investments[_addr];
        investments[_addr] = 0;
        _addr.transfer(toRefund);
        RefundIssued(_addr, toRefund);
    }

    /**
     * This function can only be called by the onwers of the ICO contract. There 
     * needs to be 2 approvals, one from each owner. Once two approvals have been 
     * made, the funds raised will be sent to a multi signature wallet. This 
     * function cannot be called if the ICO is not a success.
     * */
    function authorizeWithdrawal() public onlyOwners {
        require(hasEnded() && isSuccess() && !hasAuthorizedWithdrawal[msg.sender]);
        hasAuthorizedWithdrawal[msg.sender] = true;
        if (hasAuthorizedWithdrawal[owners[0]] && hasAuthorizedWithdrawal[owners[1]]) {
            FundsWithdrawn(owners[0], this.balance);
            MULTI_SIG.transfer(this.balance);
        }
    }
    
    /**
     * Generates newly minted ACO tokens and sends them to a given address. This 
     * function can only be called by the owners of the ICO contract during the 
     * minting period.
     * 
     * @param _to The address to mint new tokens to.
     * @param _amount The amount of tokens to mint.
     * */
    function issueBounty(address _to, uint256 _amount) public onlyOwners {
        require(_to != 0x0 && _amount > 0);
        ACO_Token.mint(_to, _amount);
    }
    
    /**
     * Terminates the minting period permanently. This function can only be 
     * executed by the owners of the ICO contract. 
     * */
    function finishMinting() public onlyOwners {
        require(hasEnded());
        ACO_Token.finishMinting();
    }

    /**
     * Returns the minimum goal of the ICO.
     * */
    function minimumGoal() public constant returns (uint256) {
        return minimumGoal;
    }

    /**
     * Returns the maximum amount of funds the ICO can receive.
     * */
    function cap() public constant returns (uint256) {
        return cap;
    }

    /**
     * Returns the time that the ICO duration will end.
     * */
    function endTime() public constant returns (uint256) {
        return endTime;
    }

    /**
     * Returns the amount of ETH a given address has invested.
     * 
     * @param _addr The address to query the investment of. 
     * */
    function investmentOf(address _addr) public constant returns (uint256) {
        return investments[_addr];
    }

    /**
     * Returns true if the duration of the ICO is over.
     * */
    function hasEnded() public constant returns (bool) {
        return now > endTime;
    }

    /**
     * Returns true if the ICO is a success.
     * */
    function isSuccess() public constant returns (bool) {
        return success;
    }

    /**
     * Returns the amount of ETH raised in wei.
     * */
    function weiRaised() public constant returns (uint256) {
        return this.balance;
    }
}