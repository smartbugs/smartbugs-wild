pragma solidity ^0.4.18;
/**
 * Math operations with safety checks
 */
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
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

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

contract ERC20Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) public view  returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns  (bool );
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}

contract HHLCTOKEN is ERC20Token {
    using SafeMath for uint256;

    address public manager;
    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }
    
    mapping(address => uint256) public balances;
    mapping (address => mapping (address => uint256 )) allowed;

    uint256 exchangeTimestamp;

    uint256[] public privateTimes;
    uint256[] public airdropTimes;

    uint256[] public privateRates=[50,60,70,80,90,100];
    uint256[] public airdropRates=[5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100];

    struct LockRuler {
        uint256 utype;
        uint256 money;
    }

    mapping (address => LockRuler[]) public  mapLockRulers;

    function transfer( address _to, uint256 _value )
    public 
    returns (bool success)
    {

        if( mapLockRulers[msg.sender].length > 0 ){

            require (exchangeTimestamp > 0);

            uint256 _lockMoney = 0;
            uint256 _preMoney = 0;
            uint256 _idx = 0;
            uint256 _idx2 = 0;
            uint256 _rate = 0;
            uint256 _hundred = 100;
            uint256 _var1 = 0;
            uint256 _var2 = 0;
            uint256 _var3 = 0;

            for( _idx = 0; _idx < mapLockRulers[msg.sender].length; _idx++ ){


                if( mapLockRulers[msg.sender][_idx].utype == 0){

                    for( _idx2 = 0; _idx2 < privateTimes.length -1; _idx2++ ){

                        if(privateTimes[_idx2]<=block.timestamp && block.timestamp < privateTimes[_idx2+1]){
                            _rate = privateRates[_idx2];

                            _var1 = _hundred.sub(_rate);
                            _var2 = _var1.mul(mapLockRulers[msg.sender][_idx].money);
                            _var3 = _var2.div(_hundred);

                            _lockMoney = _lockMoney.add(_var3 );
                            break;

                        }else if( block.timestamp > privateTimes[privateTimes.length -1] ){

                            _lockMoney = _lockMoney.add(0);
                            break;

                        }else if(block.timestamp<privateTimes[0]){

                            _lockMoney = _lockMoney.add(mapLockRulers[msg.sender][_idx].money);
                            break;

                        }
                    }

                }

                if(mapLockRulers[msg.sender][_idx].utype == 1){

                    for( _idx2 = 0; _idx2 < airdropTimes.length -1; _idx2++ ){

                        if(airdropTimes[_idx2] <= block.timestamp && block.timestamp <= airdropTimes[_idx2+1]){
                            _rate = airdropRates[_idx2];

                            _var1 = _hundred.sub(_rate);
                            _var2 = _var1.mul(mapLockRulers[msg.sender][_idx].money);
                            _var3 = _var2.div(_hundred);

                            _lockMoney = _lockMoney.add(_var3 );
                            break;

                        }else if( block.timestamp > airdropTimes[airdropTimes.length -1] ){

                            _lockMoney = _lockMoney.add(0);
                            break;

                        }else if(block.timestamp < airdropTimes[0]){

                            _lockMoney = _lockMoney.add(mapLockRulers[msg.sender][_idx].money);
                            break;

                        }

                    }

                }
            }

            _preMoney = _value.add(_lockMoney);

            require ( _preMoney <= balances[msg.sender] );
            return _transfer(_to, _value);

        }else{

            return _transfer(_to, _value);

        }
    }

    function _transfer(address _to, uint256 _value)
    internal returns (bool success){

        require(_to != 0x0);
        require(_value > 0);
        require(balances[msg.sender] >= _value);

        uint256 previousBalances = balances[msg.sender] + balances[_to];
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        assert(balances[msg.sender] + balances[_to] == previousBalances);
        return true;
    }

    function balanceOf(address _owner)
    public
    view
    returns (uint balance) {
        return balances[_owner];
    }


    function allowance(address _owner, address _spender)
    public
    view
    returns (uint256){
        return allowed[_owner][_spender];
    }

    event NewToken(uint256 indexed _decimals, uint256  _totalSupply, string  _tokenName, string  _tokenSymbol);

    string public name;
    string public symbol;
    uint256 public decimals;


    constructor(
        uint256 _initialAmount,
        uint256 _decimals,
        string _tokenName,
        string _tokenSymbol
    )public{

        require (_decimals > 0);
        require (_initialAmount > 0);
        require (bytes(_tokenName).length>0);
        require (bytes(_tokenSymbol).length>0);

        manager = msg.sender;

        decimals = _decimals;
        totalSupply = _initialAmount * (10 ** uint256(decimals));
        balances[manager] = totalSupply;
        name = _tokenName;
        symbol = _tokenSymbol;


        exchangeTimestamp = 0;


        emit NewToken(_decimals, totalSupply, name, symbol);
    }


    function addAirdropUsers( address[] _accounts, uint256[] _moneys )
    onlyManager
    public{

        require (_accounts.length > 0);
        require (_accounts.length == _moneys.length);

        uint256 _totalMoney = 0;
        uint256 _idx = 0;

        for(_idx = 0; _idx < _moneys.length; _idx++){
            _totalMoney += _moneys[_idx];
        }

        require ( _totalMoney <= balances[manager] );


        for( _idx = 0; _idx < _accounts.length; _idx++ ){

            LockRuler memory _lockRuler = LockRuler({
                money:_moneys[_idx],
                utype:1
            });

            mapLockRulers[_accounts[_idx]].push(_lockRuler);
            _transfer(_accounts[_idx], _moneys[_idx]);
        }

    }


    function addPrivateUsers( address[] _accounts, uint256[] _moneys )
    onlyManager
    public{

        require (_accounts.length > 0);
        require (_accounts.length == _moneys.length);

        uint256 _totalMoney = 0;
        uint256 _idx = 0;

        for(_idx = 0; _idx < _moneys.length; _idx++){
            _totalMoney = _totalMoney.add(_moneys[_idx]) ;
        }

        require ( _totalMoney <= balances[manager] );


        for( _idx = 0; _idx < _accounts.length; _idx++ ){

            LockRuler memory _lockRuler = LockRuler({
                money:_moneys[_idx],
                utype:0
            });

            mapLockRulers[_accounts[_idx]].push(_lockRuler);
            _transfer(_accounts[_idx], _moneys[_idx]);

        }

    }


    function addExchangeTime( uint256 _time )
    onlyManager
    public{
        require (_time > 0);
        require (privateTimes.length == 0);
        require (airdropTimes.length == 0);


        exchangeTimestamp = _time;

        uint256 _idx = 0;
        for(_idx = 0; _idx < privateRates.length; _idx++){
            privateTimes.push( _getDate(_time, _idx) );
        }



        for(_idx = 0; _idx < airdropRates.length; _idx++){
            airdropTimes.push( _getDate(_time, _idx) );
        }

    }

    function _getDate(uint256 start, uint256 daysAfter)
    internal
    pure
    returns (uint256){
        daysAfter = daysAfter.mul(60);
        return start + daysAfter * 1 days;
    }  
}