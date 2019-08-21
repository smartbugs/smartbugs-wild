pragma solidity ^0.5.0;

interface Token {
  /// @return total amount of tokens
  function totalSupply() external view returns (uint256 supply);

  /// @param _owner The address from which the balance will be retrieved
  /// @return The balance
  function balanceOf(address _owner) external view returns (uint256 balance);

  /// @notice send `_value` token to `_to` from `msg.sender`
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transfer(address _to, uint256 _value) external returns (bool success);

  /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
  /// @param _from The address of the sender
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

  /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @param _value The amount of wei to be approved for transfer
  /// @return Whether the approval was successful or not
  function approve(address _spender, uint256 _value) external returns (bool success);

  /// @param _owner The address of the account owning tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @return Amount of remaining tokens allowed to spent
  function allowance(address _owner, address _spender) external view returns (uint256 remaining);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

library SafeMath {
    function safeMul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }

    function safeDiv(uint a, uint b) internal pure returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }
}

contract ERC20 is Token {
    using SafeMath for uint256;
    
    mapping (address => uint256) public balance;

    mapping (address => mapping (address => uint256)) public allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event TransferFrom(address indexed spender, address indexed from, address indexed to, uint256 _value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 constant private MAX_UINT256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Can't send to null");

        balance[msg.sender] = balance[msg.sender].safeSub(_value);
        balance[_to] = balance[_to].safeAdd(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Can't send to null");
        require(_to != address(this), "Can't send to contract");
        
        uint256 allowance = allowed[_from][msg.sender];
        require(_value <= allowance || _from == msg.sender, "Not allowed to send that much");

        balance[_to] = balance[_to].safeAdd(_value);
        balance[_from] = balance[_from].safeSub(_value);

        if (allowed[_from][msg.sender] != MAX_UINT256 && _from != msg.sender) {
            allowed[_from][msg.sender] = allowed[_from][msg.sender].safeSub(_value);
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @notice `msg.sender` approves `_spender` to spend `_value` tokens
    *
    * @param _spender The address of the account able to transfer the tokens
    * @param _value The amount of tokens to be approved for transfer
    * @return Whether the approval was successful or not
    */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "spender can't be null");

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        remaining = allowed[_owner][_spender];
    } 

    function totalSupply() public view returns (uint256 supply) {
        return 0;
    }

    function balanceOf(address _owner) public view returns (uint256 ownerBalance) {
        return balance[_owner];
    }
}

contract Ownable {
    address payable public admin;

  /**
   * @dev The Ownable constructor sets the original `admin` of the contract to the sender
   * account.
   */
    constructor() public {
        admin = msg.sender;
    }

  /**
   * @dev Throws if called by any account other than the admin.
   */
    modifier onlyAdmin() {
        require(msg.sender == admin, "Function reserved to admin");
        _;
    }

  /**
   * @dev Allows the current admin to transfer control of the contract to a new admin.
   * @param _newAdmin The address to transfer ownership to.
   */

    function transferOwnership(address payable _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "New admin can't be null");      
        admin = _newAdmin;
    }

    function destroy() onlyAdmin public {
        selfdestruct(admin);
    }

    function destroyAndSend(address payable _recipient) public onlyAdmin {
        selfdestruct(_recipient);
    }
}

contract NotTransferable is ERC20, Ownable {
    /// @notice Enables token holders to transfer their tokens freely if true
   /// @param _enabledTransfer True if transfers are allowed in the clone
    bool public enabledTransfer = false;

    function enableTransfers(bool _enabledTransfer) public onlyAdmin {
        enabledTransfer = _enabledTransfer;
    }

    function transferFromContract(address _to, uint256 _value) public onlyAdmin returns (bool success) {
        return super.transfer(_to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(enabledTransfer, "Transfers are not allowed yet");
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(enabledTransfer, "Transfers are not allowed yet");
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require(enabledTransfer, "Transfers are not allowed yet");
        return super.approve(_spender, _value);
    }
}

contract MOCoinstantine is NotTransferable {

    string constant public NAME = "MOCoinstantine";

    string constant public SYMBOL = "MOC";

    uint8 constant public DECIMALS = 0;

    uint256 public TOTALSUPPLY = 0;

    constructor(uint256 totalSupply) public {
        TOTALSUPPLY = totalSupply;
        balance[msg.sender] = totalSupply;
    }

    function totalSupply() public view returns (uint256 supply) {
        return TOTALSUPPLY;
    }
}

library Maps {
    using SafeMath for uint256;

    struct Participant {
        address Address;
        uint256 Participation;
        uint256 Tokens;
        uint256 Timestamp;
    }

    struct Map {
        mapping(uint => Participant) data;
        uint count;
        uint lastIndex;
        mapping(address => bool) addresses;
        mapping(address => uint) indexes;
    }

    function insertOrUpdate(Map storage self, Participant memory value) internal {
        if(!self.addresses[value.Address]) {
            uint newIndex = ++self.lastIndex;
            self.count++;
            self.indexes[value.Address] = newIndex;
            self.addresses[value.Address] = true;
            self.data[newIndex] = value;
        }
        else {
            uint existingIndex = self.indexes[value.Address];
            self.data[existingIndex] = value;
        }
    }

    function remove(Map storage self, Participant storage value) internal returns (bool success) {
        if(!self.addresses[value.Address]) {
            return false;
        }
        uint index = self.indexes[value.Address];
        self.addresses[value.Address] = false;
        self.indexes[value.Address] = 0;
        delete self.data[index];
        self.count--;
        return true;
    }

    function destroy(Map storage self) internal {
        for (uint i; i <= self.lastIndex; i++) {
            if(self.data[i].Address != address(0x0)) {
                delete self.addresses[self.data[i].Address];
                delete self.indexes[self.data[i].Address];
                delete self.data[i];
            }
        }
        self.count = 0;
        self.lastIndex = 0;
        return ;
    }
    
    function contains(Map storage self, Participant memory participant) internal view returns (bool exists) {
        return self.indexes[participant.Address] > 0;
    }

    function length(Map memory self) internal pure returns (uint) {
        return self.count;
    }

    function get(Map storage self, uint index) internal view returns (Participant storage) {
        return self.data[index];
    }

    function getIndexOf(Map storage self, address _address) internal view returns (uint256) {
        return self.indexes[_address];
    }

    function getByAddress(Map storage self, address _address) internal view returns (Participant storage) {
        uint index = self.indexes[_address];
        return self.data[index];
    }

    function containsAddress(Map storage self, address _address) internal view returns (bool exists) {
        return self.indexes[_address] > 0;
    }
}

contract CsnCrowdConfigurableSale is Ownable {
    using SafeMath for uint256;

    // start and end date where investments are allowed (both inclusive)
    uint256 public startDate; 
    uint256 public endDate;

    // Minimum amount to participate
    uint256 public minimumParticipationAmount;

    uint256 public minimumToRaise;

    // address where funds are collected
    address payable public wallet ;

    // how many token units a buyer gets per ether
    uint256 public baseRate;
    //cap for the sale
    uint256 public cap; 

    uint256 capBonus1; 
    uint256 capBonus2;
    uint256 capBonus3;

    uint256 bonus1;
    uint256 bonus2;
    uint256 bonus3;
    // amount of raised money in wei
    uint256 public weiRaised;

    //flag for final of crowdsale
    bool public isFinalized = false;
    bool public isCanceled = false;

    
    function getRate() public view returns (uint256) {
        uint256 bonus = 0;
        if(weiRaised >= capBonus3)
        {
            // 5% bonus
            bonus = bonus3;
        }
        else if (weiRaised >= capBonus2)
        {
            // 15% bonus
            bonus = bonus2;
        }
        else if (weiRaised >= capBonus1)
        {
            // 30 % bonus
            bonus = bonus1;
        }
        return baseRate.safeAdd(bonus);
    }
    
    function isStarted() public view returns (bool) {
        return startDate <= block.timestamp;
    }

    function changeStartDate(uint256 _startDate) public onlyAdmin {
        startDate = _startDate;
    }

    function changeEndDate(uint256 _endDate) public onlyAdmin {
        endDate = _endDate;
    }
}

contract CsnCrowdSaleBase is CsnCrowdConfigurableSale {
    using SafeMath for uint256;
    using Maps for Maps.Map;
    // The token being sold
    MOCoinstantine public token;
    mapping(address => uint256) public participations;
    Maps.Map public participants;

    event Finalized();

    /**
    * event for token purchase logging
    * @param purchaser who paid for the tokens
    * @param value weis paid for purchase
    * @param amount amount of tokens purchased
    */ 
    event BuyTokens(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    event ClaimBack(address indexed purchaser, uint256 amount);

    constructor() public {
        wallet = 0xd21662630913Eb962c186c4A4B5834409226B65a;
    }

    function setWallet(address payable _wallet) public onlyAdmin  {
        wallet = _wallet;
    }

    function () external payable {
        if(msg.sender != wallet && msg.sender != address(0x0) && !isCanceled) {
            buyTokens(msg.value);
        }
    }

    function buyTokens(uint256 _weiAmount) private {
        require(validPurchase(), "Requirements to buy are not met");
        uint256 rate = getRate();
        // calculate token amount to be created
        uint256 gas = 0;
        uint256 amountIncl = 0;
        uint256 amount = 0;
        uint256 tokens = 0;
        uint256 newBalance = 0;
       
        participations[msg.sender] = participations[msg.sender].safeAdd(_weiAmount);
        if(participants.containsAddress(msg.sender))
        {
            gas = tx.gasprice * 83000;
            amountIncl = _weiAmount.safeAdd(gas);
            amount = amountIncl.safeMul(rate);
            tokens = amount.safeDiv(1000000000000000000);
            Maps.Participant memory existingParticipant = participants.getByAddress(msg.sender);
            newBalance = tokens.safeAdd(existingParticipant.Tokens);
        }
        else {
            gas = tx.gasprice * 280000;
            amountIncl = _weiAmount.safeAdd(gas);
            amount = amountIncl.safeMul(rate);
            tokens = amount.safeDiv(1000000000000000000);
            newBalance = tokens;
        } 
        participants.insertOrUpdate(Maps.Participant(msg.sender, participations[msg.sender], newBalance, block.timestamp));

        //forward funds to wallet
        forwardFunds();

         // update state
        weiRaised = weiRaised.safeAdd(_weiAmount);
         //purchase tokens and transfer to buyer
        token.transferFromContract(msg.sender, tokens);
         //Token purchase event
        emit BuyTokens(msg.sender, msg.sender, _weiAmount, tokens);
    }

    function GetNumberOfParticipants() public view  returns (uint) {
        return participants.count;
    }

    function GetMaxIndex() public view  returns (uint) {
        return participants.lastIndex;
    }

    function GetParticipant(uint index) public view  returns (address Address, uint256 Participation, uint256 Tokens, uint256 Timestamp ) {
        Maps.Participant memory participant = participants.get(index);
        Address = participant.Address;
        Participation = participant.Participation;
        Tokens = participant.Tokens;
        Timestamp = participant.Timestamp;
    }
    
    function Contains(address _address) public view returns (bool) {
        return participants.contains(Maps.Participant(_address, 0, 0, block.timestamp));
    }
    
    function Destroy() private returns (bool) {
        participants.destroy();
    }

    function buyTokens() public payable {
        require(msg.sender != address(0x0), "Can't by from null");
        buyTokens(msg.value);
    }

    //send tokens to the given address used for investors with other conditions, only contract admin can call this
    function transferTokensManual(address beneficiary, uint256 amount) public onlyAdmin {
        require(beneficiary != address(0x0), "address can't be null");
        require(amount > 0, "amount should greater than 0");

        //transfer tokens
        token.transferFromContract(beneficiary, amount);

        //Token purchase event
        emit BuyTokens(wallet, beneficiary, 0, amount);

    }

    /// @notice Enables token holders to transfer their tokens freely if true
    /// @param _transfersEnabled True if transfers are allowed in the clone
    function enableTransfers(bool _transfersEnabled) public onlyAdmin {
        token.enableTransfers(_transfersEnabled);
    }

    // send ether to the fund collection wallet
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    // should be called after crowdsale ends or to emergency stop the sale
    function finalize() public onlyAdmin {
        require(!isFinalized, "Is already finalised");
        emit Finalized();
        isFinalized = true;
    }

    // @return true if the transaction can buy tokens
    // check for valid time period, min amount and within cap
    function validPurchase() internal view returns (bool) {
        bool withinPeriod = startDate <= block.timestamp && endDate >= block.timestamp;
        bool nonZeroPurchase = msg.value != 0;
        bool minAmount = msg.value >= minimumParticipationAmount;
        bool withinCap = weiRaised.safeAdd(msg.value) <= cap;

        return withinPeriod && nonZeroPurchase && minAmount && !isFinalized && withinCap;
    }

    // @return true if the goal is reached
    function capReached() public view returns (bool) {
        return weiRaised >= cap;
    }

    function minimumCapReached() public view returns (bool) {
        return weiRaised >= minimumToRaise;
    }

    function claimBack() public {
        require(isCanceled, "The presale is not canceled, claiming back is not possible");
        require(participations[msg.sender] > 0, "The sender didn't participate to the presale");
        uint256 participation = participations[msg.sender];
        participations[msg.sender] = 0;
        msg.sender.transfer(participation);
        emit ClaimBack(msg.sender, participation);
    }

    function cancelSaleIfCapNotReached() public onlyAdmin {
        require(weiRaised < minimumToRaise, "The amount raised must not exceed the minimum cap");
        require(!isCanceled, "The presale must not be canceled");
        require(endDate > block.timestamp, "The presale must not have ended");
        isCanceled = true;
    }
}

contract CsnCrowdPreSale is CsnCrowdSaleBase {
    using SafeMath for uint256;

    constructor() public {
        token = new MOCoinstantine(6000000);
        startDate = 1561968000; //Mon, 1 Jul 2019 08:00:00 +00:00
        endDate = 1565827199; //Wed, 14 Aug 2019 23:59:59 +00:00
        minimumParticipationAmount = 100000000000000000 wei; //0.1 Ether
        minimumToRaise = 400000000000000000000; // 400 Ether
        baseRate = 1000;
        cap = 4000000000000000000000 wei; //4000 ether
        capBonus1 = 0; // 0 ether
        capBonus2 = 1000000000000000000000; // 1000 ether
        capBonus3 = 3000000000000000000000; // 3000 ether
        bonus1 = 300;
        bonus2 = 150;
        bonus3 = 50;
    }
}

contract CsnCrowdSale is CsnCrowdSaleBase {
    using SafeMath for uint256;

    constructor() public {
        token = new MOCoinstantine(50000000);
        startDate = 1569916800; //Tue, 1 Oct 2019 08:00:00 +00:00
        endDate = 1575158399; //Sun, 30 Nov 2019 23:59:59 +00:00
        minimumParticipationAmount = 100000000000000000 wei; // 0.1 Ether
        minimumToRaise = 4000000000000000000000; // 4.000 Ether
        baseRate = 500;
        cap = 100000000000000000000000 wei; //100.000 ether
        // No bonus
        capBonus1 = 0; // 0 ether
        capBonus2 = 0; // 0 ether
        capBonus3 = 0; // 0 ether
        bonus1 = 0;
        bonus2 = 0;
        bonus3 = 0;
    }
}

contract TestCrowdSaleEnded is CsnCrowdSaleBase {
    using SafeMath for uint256;

    constructor() public {
        token = new MOCoinstantine(100000);
        startDate = 1525940887; // 10 May 2018
        endDate = 1539160087; // 10 Oct 2018
        minimumParticipationAmount = 100000000000000000 wei; //0.1 Ether
        minimumToRaise = 400000000000000000000; // 400 Ether
        baseRate = 1000;
        cap = 4000000000000000000000 wei; //4000 ether
        capBonus1 = 0; // 0 ether
        capBonus2 = 1000000000000000000000; // 1000 ether
        capBonus3 = 3000000000000000000000; // 3000 ether
        bonus1 = 300;
        bonus2 = 150;
        bonus3 = 50;
    }
}

contract TestCrowdSaleStarted is CsnCrowdSaleBase {
    using SafeMath for uint256;

    constructor() public {
        token = new MOCoinstantine(100000);
        startDate = 1557377510; // 9 May 2019
        endDate = 1575158399; // 10 Oct 2019
        minimumParticipationAmount = 100000000000000000 wei; //0.1 Ether
        minimumToRaise = 400000000000000000000; // 400 Ether
        baseRate = 1000;
        cap = 4000000000000000000000 wei; //4000 ether
        capBonus1 = 0; // 0 ether
        capBonus2 = 1000000000000000000000; // 1000 ether
        capBonus3 = 3000000000000000000000; // 3000 ether
        bonus1 = 300;
        bonus2 = 150;
        bonus3 = 50;
    }
}

contract TestCrowdSale is CsnCrowdSaleBase {
    using SafeMath for uint256;

    constructor() public {
        token = new MOCoinstantine(2600);
        startDate = 1557377510; // 9 May 2019
        endDate = 1575158399; // 10 Oct 2019
        minimumParticipationAmount = 100000000000000000 wei; //0.1 Ether
        minimumToRaise = 1000000000000000000; // 1 Ether
        baseRate = 1000;
        cap = 2000000000000000000 wei; //2 ether
        capBonus1 = 0; // 0 ether
        capBonus2 = 1000000000000000000; // 1 ether
        capBonus3 = 1500000000000000000; // 1.5 ether
        bonus1 = 300;
        bonus2 = 150;
        bonus3 = 50;
    }
}

contract TestCrowdSaleAboveSupply is CsnCrowdSaleBase {
    using SafeMath for uint256;

    constructor() public {
        token = new MOCoinstantine(500);
        startDate = 1557377510; // 9 May 2019
        endDate = 1575158399; // 10 Oct 2019
        minimumParticipationAmount = 100000000000000000 wei; //0.1 Ether
        minimumToRaise = 1000000000000000000; // 1 Ether
        baseRate = 1000;
        cap = 2000000000000000000 wei; //2 ether
        capBonus1 = 0; // 0 ether
        capBonus2 = 1000000000000000000; // 1 ether
        capBonus3 = 1500000000000000000; // 1.5 ether
        bonus1 = 300;
        bonus2 = 150;
        bonus3 = 50;
    }
}