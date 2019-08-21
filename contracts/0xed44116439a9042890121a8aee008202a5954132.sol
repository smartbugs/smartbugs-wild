pragma solidity ^0.4.24;
interface Interfacemc {
  
  function balanceOf(address who) external view returns (uint256);
  
  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);
  
  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);
  
  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );
  
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
  
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


contract Mundicoin is Interfacemc{
    using SafeMath for uint256;
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;
    uint256 public totalSupply;
    string public name = "Mundicoin"; 
    uint8 public decimals = 8; 
    string public symbol = "MC";
    address private _owner;
    
    mapping (address => bool) public _notransferible;
    mapping (address => bool) private _administradores; 
    
    constructor() public{
        _owner = msg.sender;
        _balances[_owner] = totalSupply;
        totalSupply = 10000000000000000;
        _administradores[_owner] = true;
    }

    function isAdmin(address dir) public view returns(bool){
        return _administradores[dir];
    }
    
    modifier OnlyOwner(){
        require(msg.sender == _owner, "Not an admin");
        _;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }
    
    function allowance(
        address owner,
        address spender
    )
      public
      view
      returns (uint256)
    {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(!_notransferible[from], "No authorized ejecutor");
        require(value <= _balances[from], "Not enough balance");
        require(to != address(0), "Invalid account");

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }
    
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "Invalid account");

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
      public
      returns (bool)
    {   
        require(value <= _allowed[from][msg.sender], "Not enough approved ammount");
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }
    
    function increaseAllowance(
        address spender,
        uint256 addedValue
    )
      public
      returns (bool)
    {
        require(spender != address(0), "Invalid account");

        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    )
      public
      returns (bool)
    {
        require(spender != address(0), "Invalid account");

        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _burn(address account, uint256 value) internal {
        require(account != 0, "Invalid account");
        require(value <= _balances[account], "Not enough balance");

        totalSupply = totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _burnFrom(address account, uint256 value) internal {
        require(value <= _allowed[account][msg.sender], "No enough approved ammount");
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
    }

    function setTransferible(address admin, address sujeto, bool state) public returns (bool) {
        require(_administradores[admin], "Not an admin");
        _notransferible[sujeto] = state;
        return true;
    }

    function setNewAdmin(address admin)public OnlyOwner returns(bool){
        _administradores[admin] = true;
        return true;
    }  

}

library SafeMundicoin {

    using SafeMath for uint256;

    function safeSetTransferible(
        Mundicoin token,
        address authorizer,
        address to,
        bool state
    )
        internal
    {
        require(token.setTransferible(authorizer, to, state));
    }

    function safeTransfer(
        Mundicoin token,
        address to,
        uint256 value
    )
        internal
    {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        Mundicoin token,
        address from,
        address to,
        uint256 value
    )
        internal
    {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        Mundicoin token,
        address spender,
        uint256 value
    )
        internal
    {
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(
        Mundicoin token,
        address spender,
        uint256 value
    )
        internal
    {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(
        Mundicoin token,
        address spender,
        uint256 value
    )
        internal
    {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}

pragma solidity ^0.4.24;
contract ReentradaProteccion {

    uint256 private _guardCounter;
    constructor() public {
        // Inicia en 1 para ahorrar gas
        _guardCounter = 1;
    }

    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "No double");
    }

}

contract Venta is ReentradaProteccion{
    using SafeMath for uint256;
    mapping(address => uint256) private _contributions;
    mapping(uint => address[]) private _contributors;
    uint128 public _campaign;
    bool private _state;
    address private _custodian;
    address private _owner;
    uint256 private _rate;
    uint256 private _weiRaised;
    using SafeMundicoin for Mundicoin;
    Mundicoin private _token;
    
    event TokensPurchased(
      address indexed purchaser,
      address indexed beneficiary,
      uint256 value,
      uint256 amount
    );
    
    constructor(Mundicoin token) public {
        require(token != address(0),"Invalid address");
        _token = token;
        _owner = msg.sender;
    }

    modifier OnlyOwner(){
        require(msg.sender == _owner, "Not an admin");
        _;
    }
    
    function setCampaign(uint256 rate, uint128 campaign, bool state) public OnlyOwner returns(bool){
        require(rate > 0, "Invalid rate");
        _rate = rate;
        _campaign = campaign;
        _state = state;
        return true;
    }

    function getRate() public view returns(uint256){
        return _rate;
    }
    
    function updateCustodian(address custodian) public OnlyOwner returns(bool) {
        require(custodian != address(0), "invalid address");
        _custodian = custodian;
        return true;
    }
    
    function getCustodian()public view OnlyOwner returns(address){
        return _custodian;
    }
    
    function getOwner()public view returns(address){
        return _owner;
    }

    
    function () external payable {
        buyTokens(msg.sender);
    }
    
    function buyTokens(address beneficiary) public nonReentrant payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);
        _weiRaised = _weiRaised.add(weiAmount);
        uint256 tokens = _getTokenAmount(weiAmount);
        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(
            msg.sender,
            beneficiary,
            weiAmount,
            tokens
        );
        _updatePurchasingState(this, beneficiary, weiAmount);
        _forwardFunds();

    }
   
    function _preValidatePurchase(
        address beneficiary,
        uint256 weiAmount
    )
      internal
      pure
    {
        require(beneficiary != address(0), "Invalid address");
        require(weiAmount != 0, "Invalid ammount");
    }

    function _deliverTokens(
        address beneficiary,
        uint256 tokenAmount
    )
      internal
    {  
        _token.safeTransfer(beneficiary, tokenAmount);
    }

    function _processPurchase(
        address beneficiary,
        uint256 tokenAmount
    )
      internal
    {
        _deliverTokens(beneficiary, tokenAmount);
    }

    function _updatePurchasingState(
        address ejecutor,
        address beneficiary,
        uint256 weiAmount
    )
      internal
    {
        _contributions[beneficiary] = _contributions[beneficiary].add(
        weiAmount);
        _contributors[_campaign].push(beneficiary);
        _token.safeSetTransferible(ejecutor, beneficiary, _state);
    }

    function _getTokenAmount(uint256 weiAmount)
      internal view returns (uint256)
    {
        return weiAmount.div(_rate);
    }

    function _forwardFunds() internal {
        _custodian.transfer(msg.value);
    }

    function getContribution(address beneficiary)
        public view returns (uint256)
    {
        return _contributions[beneficiary];
    }

    function freedom(bool state, uint campaign) 
        public OnlyOwner returns(bool)
    {
        address[] memory array = _contributors[campaign];
        uint256 n = array.length;

        for(uint256 i = 0; i < n; i++ ){
            _token.safeSetTransferible(this, array[i], state);
        }
        return true;
    }
}