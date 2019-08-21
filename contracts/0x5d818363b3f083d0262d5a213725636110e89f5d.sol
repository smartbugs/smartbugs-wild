pragma solidity ^0.4.17;

// ----------------------------------------------------------------------------------------------
// Kryptor Token by EdooPAD Inc.
// An ERC20 standard
//
// author: EdooPAD Inc.
// Contact: william@edoopad.com 

contract ERC20Interface {
    // Get the total token supply
    function totalSupply() public constant returns (uint256 _totalSupply);
 
    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) public constant returns (uint256 balance);
 
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success);
  
    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
 
    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
 
contract Kryptor is ERC20Interface {
    uint public constant decimals = 10;

    string public constant symbol = "Kryptor";
    string public constant name = "Kryptor";

    uint private constant icoSupplyRatio = 30;  // percentage of _icoSupply in _totalSupply. Preset: 30%
    uint private constant bonusRatio = 20;   // sale bonus percentage
    uint private constant bonusBound = 10;  // First 10% of totalSupply get bonus
    uint private constant initialPrice = 5000; // Initially, 5000 Kryptor = 1 ETH

    bool public _selling = true;
    uint public _totalSupply = 10 ** 19; // total supply is 10^19 unit, equivalent to 10^9 Kryptor
    uint public _originalBuyPrice = (10 ** 18) / (initialPrice * 10**decimals); // original buy in wei of one unit. Ajustable.

    // Owner of this contract
    address public owner;
 
    // Balances Kryptor for each account
    mapping(address => uint256) balances;
    
    // _icoSupply is the avalable unit. Initially, it is _totalSupply
    // uint public _icoSupply = _totalSupply - (_totalSupply * bonusBound)/100 * bonusRatio;
    uint public _icoSupply = (_totalSupply * icoSupplyRatio) / 100;
    
    // amount of units with bonus
    uint public bonusRemain = (_totalSupply * bonusBound) / 100;//10% _totalSupply
    
    /* Functions with this modifier can only be executed by the owner
     */
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }

    /* Functions with this modifier can only be executed by users except owners
     */
    modifier onlyNotOwner() {
        if (msg.sender == owner) {
            revert();
        }
        _;
    }

    /* Functions with this modifier check on sale status
     * Only allow sale if _selling is on
     */
    modifier onSale() {
        if (!_selling || (_icoSupply <= 0) ) { 
            revert();
        }
        _;
    }

    /* Functions with this modifier check the validity of original buy price
     */
    modifier validOriginalBuyPrice() {
        if(_originalBuyPrice <= 0) {
            revert();
        }
        _;
    }

    ///  Fallback function allows to buy ether.
    function()
        public
        payable
    {
        buy();
    }

    /// @dev Constructor
    function Kryptor() 
        public {
        owner = msg.sender;
        balances[owner] = _totalSupply;
    }
    
    /// @dev Gets totalSupply
    /// @return Total supply
    function totalSupply()
        public 
        constant 
        returns (uint256) {
        return _totalSupply;
    }
 
    /// @dev Gets account's balance
    /// @param _addr Address of the account
    /// @return Account balance
    function balanceOf(address _addr) 
        public
        constant 
        returns (uint256) {
        return balances[_addr];
    }
 
    /// @dev Transfers the balance from Multisig wallet to an account
    /// @param _to Recipient address
    /// @param _amount Transfered amount in unit
    /// @return Transfer status
    function transfer(address _to, uint256 _amount)
        public 
        returns (bool) {
        // if sender's balance has enough unit and amount > 0, 
        //      and the sum is not overflow,
        // then do transfer 
        if ( (balances[msg.sender] >= _amount) &&
             (_amount > 0) && 
             (balances[_to] + _amount > balances[_to]) ) {  

            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            
            return true;

        } else {
            return false;
        }
    }

    /// @dev Enables sale 
    function turnOnSale() onlyOwner 
        public {
        _selling = true;
    }

    /// @dev Disables sale
    function turnOffSale() onlyOwner 
        public {
        _selling = false;
    }

    /// @dev Gets selling status
    function isSellingNow() 
        public 
        constant
        returns (bool) {
        return _selling;
    }

    /// @dev Updates buy price (owner ONLY)
    /// @param newBuyPrice New buy price (in unit)
    function setBuyPrice(uint newBuyPrice) onlyOwner 
        public {
        _originalBuyPrice = newBuyPrice;
    }
    
    /*
     *  Exchange wei for Kryptor.
     *  modifier _icoSupply > 0
     *  if requestedCoin > _icoSupply 
     *      revert
     *  
     *  Buy transaction must follow this policy:
     *      if requestedCoin < bonusRemain
     *          actualCoin = requestedCoin + 20%requestedCoin
     *          bonusRemain -= requestedCoin
     *          _icoSupply -= requestedCoin
     *      else
     *          actualCoin = requestedCoin + 20%bonusRemain
     *          _icoSupply -= requested
     *          bonusRemain = 0
     *
     *   Return: 
     *       amount: actual amount of units sold.
     *
     *   NOTE: msg.value is in wei
     */ 
    /// @dev Buys Kryptor
    /// @return Amount of actual sold units 
    function buy() payable onlyNotOwner validOriginalBuyPrice onSale 
        public
        returns (uint256 amount) {
        // convert buy amount in wei to number of unit want to buy
        uint requestedUnits = msg.value / _originalBuyPrice ;
        
        //check requestedUnits > _icoSupply
        if(requestedUnits > _icoSupply){
            revert();
        }
        
        // amount of Kryptor bought
        uint actualSoldUnits = 0;

        // If bonus is available and requested amount of units is less than bonus amount
        if (requestedUnits < bonusRemain) {
            // calculate actual sold units with bonus to the requested amount of units
            actualSoldUnits = requestedUnits + ((requestedUnits*bonusRatio) / 100); 
            // decrease _icoSupply
            _icoSupply -= requestedUnits;
            
            // decrease available bonus amount
            bonusRemain -= requestedUnits;
        }
        else {
            // calculate actual sold units with bonus - if available - to the requested amount of units
            actualSoldUnits = requestedUnits + (bonusRemain * bonusRatio) / 100;
            
            // otherwise, decrease _icoSupply by the requested amount
            _icoSupply -= requestedUnits;

            // no more bonus
            bonusRemain = 0;
        }

        // prepare transfer data
        balances[owner] -= actualSoldUnits;
        balances[msg.sender] += actualSoldUnits;

        //transfer ETH to owner
        owner.transfer(msg.value);
        
        // submit transfer
        Transfer(owner, msg.sender, actualSoldUnits);

        return actualSoldUnits;
    }
    
    /// @dev Withdraws Ether in contract (Owner only)
    function withdraw() onlyOwner 
        public 
        returns (bool) {
        return owner.send(this.balance);
    }
}