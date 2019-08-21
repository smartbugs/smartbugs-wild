pragma solidity ^0.4.19;

contract SafeMath {

    function safeAdd(uint256 x, uint256 y) internal pure returns ( uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }

    function safeSub(uint256 x, uint256 y) internal pure returns ( uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }

    function safeMult(uint256 x, uint256 y) internal pure returns ( uint256) {
        uint256 z = x * y;
        assert((x == 0)||(z/x == y));
        return z;
    }

}

contract ERC20 {
    function totalSupply() constant public returns ( uint supply);

    function balanceOf( address who ) constant public returns ( uint value);
    function allowance( address owner, address spender ) constant public returns (uint _allowance);
    function transfer( address to, uint value) public returns (bool ok);
    function transferFrom( address from, address to, uint value) public returns (bool ok);
    function approve( address spender, uint value ) public returns (bool ok);

    event Transfer( address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);
}

//implement 
contract StandardToken is SafeMath,ERC20 {
    uint256     _totalSupply;
    
    function totalSupply() constant public returns ( uint256) {
        return _totalSupply;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        assert(balances[msg.sender] >= wad);
        
        balances[msg.sender] = safeSub(balances[msg.sender], wad);
        balances[dst] = safeAdd(balances[dst], wad);
        
        Transfer(msg.sender, dst, wad);
        
        return true;
    }
    
    function transferFrom(address src, address dst, uint wad) public returns (bool) {
        assert(wad > 0 );
        assert(balances[src] >= wad);
        
        balances[src] = safeSub(balances[src], wad);
        balances[dst] = safeAdd(balances[dst], wad);
        
        Transfer(src, dst, wad);
        
        return true;
    }

    function balanceOf(address _owner) constant public returns ( uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns ( bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant public returns ( uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    function freezeOf(address _owner) constant public returns ( uint256 balance) {
        return freezes[_owner];
    }
    

    mapping (address => uint256) balances;
    mapping (address => uint256) freezes;
    mapping (address => mapping (address => uint256)) allowed;
}

contract DSAuth {
    address public authority;
    address public owner;

    function DSAuth() public {
        owner = msg.sender;
        authority = msg.sender;
    }

    function setOwner(address owner_) Owner public
    {
        owner = owner_;
    }

    modifier Auth {
        assert(isAuthorized(msg.sender));
        _;
    }
    
    modifier Owner {
        assert(msg.sender == owner);
        _;
    }

    function isAuthorized(address src) internal view returns ( bool) {
        if (src == address(this)) {
            return true;
        } else if (src == authority) {
            return true;
        }
        else if (src == owner) {
            return true;
        }
        return false;
    }

}

contract DRCToken is StandardToken,DSAuth {

    string public name = "Digit RedWine Coin";
    uint8 public decimals = 18;
    string public symbol = "DRC";
    
    /* This notifies clients about the amount frozen */
    event Freeze(address indexed from, uint256 value);
    
    /* This notifies clients about the amount unfrozen */
    event Unfreeze(address indexed from, uint256 value);
    
    /* This notifies clients about the amount burnt */
    event Burn(address indexed from, uint256 value);

    function DRCToken() public {
        
    }

    function mint(uint256 wad) Owner public {
        balances[msg.sender] = safeAdd(balances[msg.sender], wad);
        _totalSupply = safeAdd(_totalSupply, wad);
    }

    function burn(uint256 wad) Owner public {
        balances[msg.sender] = safeSub(balances[msg.sender], wad);
        _totalSupply = safeSub(_totalSupply, wad);
        Burn(msg.sender, wad);
    }

    function push(address dst, uint256 wad) public returns ( bool) {
        return transfer(dst, wad);
    }

    function pull(address src, uint256 wad) public returns ( bool) {
        return transferFrom(src, msg.sender, wad);
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return super.transfer(dst, wad);
    }
    
    function freeze(address dst,uint256 _value) Auth public returns (bool success) {
        assert(balances[dst] >= _value); // Check if the sender has enough
        assert(_value > 0) ; 
        balances[dst] = SafeMath.safeSub(balances[dst], _value);                      // Subtract from the sender
        freezes[dst] = SafeMath.safeAdd(freezes[dst], _value);                                // Updates totalSupply
        Freeze(dst, _value);
        return true;
    }
    
    function unfreeze(address dst,uint256 _value) Auth public returns (bool success) {
        assert(freezes[dst] >= _value);            // Check if the sender has enough
        assert(_value > 0) ; 
        freezes[dst] = SafeMath.safeSub(freezes[dst], _value);                      // Subtract from the sender
        balances[dst] = SafeMath.safeAdd(balances[dst], _value);
        Unfreeze(dst, _value);
        return true;
    }
}

contract DRCCrowSale is SafeMath,DSAuth {
    DRCToken public DRC;

    // Constants
    uint256 public constant tokensPerEth = 10000;// DRC per ETH 
    uint256 public presalePerEth;// DRC per ETH 
    
    uint256 public constant totalSupply = 1 * 1e9 * 1e18; // Total DRC amount created

    uint256 public tokensForTeam     = totalSupply * 15 / 100;
    uint256 public tokensForParnter  = totalSupply * 15 / 100;
    uint256 public tokensForPlatform = totalSupply * 45 / 100;

    uint256 public tokensForPresale1 = totalSupply * 5 / 100;
    uint256 public tokensForPresale2 = totalSupply * 10 / 100;
    uint256 public tokensForSale     = totalSupply * 10 / 100;
    
    address public team;
    address public parnter;
    address public platform;
    address public presale1;
    
    uint256 public Presale1Sold = 0;
    uint256 public Presale2Sold = 0;
    uint256 public PublicSold = 0;

    enum IcoState {Init,Presale1, Presale2, Running, Paused, Finished}
    IcoState public icoState = IcoState.Init;
    IcoState public preIcoState = IcoState.Init;
    
    function setPresalePerEth(uint256 discount) external Auth{
        presalePerEth = discount;
    }

    function startPreSale1() external Auth {
        require(icoState == IcoState.Init);
        icoState = IcoState.Presale1;
    }

    function startPreSale2() external Auth {
        require(icoState == IcoState.Presale1);
        icoState = IcoState.Presale2;
    }

    function startIco() external Auth {
        require(icoState == IcoState.Presale2);
        icoState = IcoState.Running;
    }

    function pauseIco() external Auth {
        require(icoState != IcoState.Paused);
        preIcoState = icoState ;
        icoState = IcoState.Paused;
    }

    function continueIco() external Auth {
        require(icoState == IcoState.Paused);
        icoState = preIcoState;
    }
    
    uint public finishTime = 0;
    function finishIco() external Auth {
        require(icoState == IcoState.Running);
        icoState = IcoState.Finished;
        finishTime = block.timestamp;
    }
    
    uint public unfreezeStartTime = 0;
    function setUnfreezeStartTime(uint timestamp) external Auth{
        unfreezeStartTime = timestamp;
    }
    
    mapping (uint => mapping (address => bool))  public  unfroze;
    mapping (address => uint256)                 public  userBuys;
    mapping (uint => bool)  public  burned;
    
    // anyone can burn
    function burn(IcoState state) external Auth{
        uint256 burnAmount = 0;
        //only burn once
        assert(burned[uint(state)] == false);
        if(state == IcoState.Presale1 && (icoState == IcoState.Presale2 || icoState == IcoState.Finished)){
            assert(Presale1Sold < tokensForPresale1);
            burnAmount = safeSub(tokensForPresale1,Presale1Sold);
        } 
        else if(state == IcoState.Presale2 && icoState == IcoState.Finished){ 
            assert(Presale2Sold < tokensForPresale2);
            burnAmount = safeSub(tokensForPresale2,Presale2Sold);
        } 
        else if(state == IcoState.Finished && icoState == IcoState.Finished){
            assert(PublicSold < tokensForSale);
            burnAmount = safeSub(tokensForSale,PublicSold);
        } 
        else {
            throw;
        }

        DRC.burn(burnAmount);
        burned[uint(state)] = true;
    }
        
    function presaleUnfreeze(uint step) external{
        
        assert(unfroze[step][msg.sender] == false);
        assert(DRC.freezeOf(msg.sender) > 0 );
        assert(unfreezeStartTime > 0);
        assert(msg.sender != platform);
        
        uint256 freeze  = DRC.freezeOf(msg.sender);
        uint256 unfreezeAmount = 0;

        if(step == 1){
            require( block.timestamp > (unfreezeStartTime + 30 days));
            unfreezeAmount = freeze / 3;
        }
        else if(step == 2){
            require( block.timestamp > (unfreezeStartTime + 60 days));
            unfreezeAmount = freeze / 2;
        }
        else if(step == 3){
            require( block.timestamp > (unfreezeStartTime + 90 days));
            unfreezeAmount = freeze;
        }
        else{
            throw ;
        }
        
        require(unfreezeAmount > 0 );
        
        DRC.unfreeze(msg.sender,unfreezeAmount);
        unfroze[step][msg.sender] = true;
    }
    
    //team unfreeze
    function teamUnfreeze() external{
        uint month = 6;
        
        assert(DRC.freezeOf(msg.sender) > 0 );
        assert(finishTime > 0);
        assert(msg.sender == team);
        uint step = safeSub(block.timestamp, finishTime) / (3600*24*30);
        
        uint256 freeze  = DRC.freezeOf(msg.sender);
        uint256 unfreezeAmount = 0;
        
        uint256 per = tokensForTeam / month;
        
        for(uint i = 0 ;i <= step && i < month;i++){
            if(unfroze[i][msg.sender] == false){
                unfreezeAmount += per;
            }
        }
        
        require(unfreezeAmount > 0 );
        require(unfreezeAmount <= freeze);

        DRC.unfreeze(msg.sender,unfreezeAmount);
        for(uint j = 0; j <= step && i < month; j++){
            unfroze[j][msg.sender] = true;
        }
    }
    
    //platform unfreeze
     function platformUnfreeze() external{
        uint month = 12;
        
        assert(DRC.freezeOf(msg.sender) > 0 );
        assert(finishTime > 0);
        assert(msg.sender == platform);
        uint step = safeSub(block.timestamp, finishTime) / (3600*24*30);
        
        uint256 freeze  = DRC.freezeOf(msg.sender);
        uint256 unfreezeAmount = 0;
        
        uint256 per = tokensForPlatform / month;
        
        for(uint i = 0 ;i <= step && i < month;i++){
            if(unfroze[i][msg.sender] == false){
                unfreezeAmount += per;
            }
        }
        
        require(unfreezeAmount > 0 );
        require(unfreezeAmount <= freeze);

        DRC.unfreeze(msg.sender,unfreezeAmount);
        for(uint j = 0; j <= step && i < month; j++){
            unfroze[j][msg.sender] = true;
        }
    }
    
    // Constructor
    function DRCCrowSale() public {

    }

    function initialize(DRCToken drc,address _team,address _parnter,address _platform,address _presale1) Auth public {
        assert(address(DRC) == address(0));
        assert(drc.owner() == address(this));
        assert(drc.totalSupply() == 0);
        assert(_team != _parnter && _parnter != _platform && _team != _platform);
        
        team =_team;
        parnter=_parnter;
        platform=_platform;
        presale1 = _presale1;

        DRC = drc;
        DRC.mint(totalSupply);
        
        // transfer to team partner platform 
        DRC.push(team, tokensForTeam);
        DRC.freeze(team,tokensForTeam);
        
        DRC.push(parnter, tokensForParnter);
        
        // freeze
        DRC.push(platform, tokensForPlatform);
        DRC.freeze(platform,tokensForPlatform);
        
        DRC.push(presale1, tokensForPresale1);
        
    }

    function() payable public {
        buy();
    }

    function buy()  payable public{
        require( (icoState == IcoState.Running)  ||
                 (icoState == IcoState.Presale1) || 
                 (icoState == IcoState.Presale2) );
        // require          
        if((icoState == IcoState.Presale1) || (icoState == IcoState.Presale2)){
            require(msg.value >= 10 ether);
        } 
        else {
            require(msg.value >= 0.01 ether);
            //limit peer user less than 10 eth
            require(userBuys[msg.sender] + msg.value <= 10 ether);
        }
 

        uint256 amount = getDRCTotal(msg.value);
        uint256 sold = 0;
        uint256 canbuy = 0;
        (sold,canbuy) = getSold();

        // refund eth for last buy
        if (sold + amount > canbuy){
            uint256 delta = sold + amount - canbuy;
            uint256 refundMoney = msg.value * delta / amount;
            amount = canbuy-sold;
            require(refundMoney > 0);
            msg.sender.transfer(refundMoney);
        }
        
        require(amount > 0);
    
        DRC.push(msg.sender, amount);
        
        //presale auto freeze
        if((icoState == IcoState.Presale1)  || (icoState == IcoState.Presale2)){
            DRC.freeze(msg.sender,amount);
        }
        else{
            //for limit amount peer user 
            userBuys[msg.sender] += amount;
        }
        
       addSold(amount);
    }
    
    function getSold() private view returns ( uint256,uint256){
        if(icoState == IcoState.Presale1){
            return(Presale1Sold,tokensForPresale1);
        } 
        else if(icoState == IcoState.Presale2){
            return(Presale2Sold,tokensForPresale2);
        } 
        else if(icoState == IcoState.Running){
            return(PublicSold,tokensForSale);
        }else{
            throw;
        }
    }

    function addSold(uint256 amount) private{
        if(icoState == IcoState.Presale1){
            Presale1Sold += amount;
        } 
        else if(icoState == IcoState.Presale2){
            Presale2Sold += amount;
        } 
        else if(icoState == IcoState.Running){
            PublicSold += amount;
        }
        else{
            throw;
        }
    }
    
    //discount
    function getDRCTotal(uint256 _eth) public view returns ( uint256)
    {
        if(icoState == IcoState.Presale1)
        {
            return safeMult(_eth , presalePerEth);
        }
        else if(icoState == IcoState.Presale2)
        {
           return safeMult(_eth , presalePerEth);
        }

        return safeMult(_eth , tokensPerEth);
    }

    function finalize() external Owner payable {
        require(this.balance > 0 );

        require(owner.send(this.balance));
    }

}