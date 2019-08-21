pragma solidity ^0.4.19;

/*
                        ...........:??I7ZZ:......                               
                        ......=??????7IIOOZZ=~...                               
                   .  ..,I+?????????I7II==?ZZZO:,.. .......   .. .              
                   ..??I:=~:~?????I7++++~:++++=?Z7~,.....,...........           
                   .???.,,~:::::~+++++++~~=++++++++??+++?++???+.....            
                   .?=,,,,,::::~~~+++++~~~~=+++++++I+?++?+?????????,.           
              .....?,,,,,,,,:~:~~~?++??~~~~~++++++=??+++++?++++??+????~.......  
              .....,,,,,,,,:?::~~~~+++~~~~~~~++++=I~:$++?+?++??+???????7?+....  
              ...,=~~~~~~~~+I+++:~~:++=~~~~~:~+++++::::??+++++++?+????7II++.... 
              ...?~~~~~~?+?II++++?+=?~~~~~~~~~~?+I=::::7+===+?+=+++??7III7?I... 
              ..+?~~~~~???I??+++++++++++++~~~~~~+?:::::7===========+7IIIII7I?.. 
              .~+~~~++???+???++++???I7?+++++++=+O,,::::I===========+I7II7777II. 
         .....:++:~??????+?+I++??????77++++++$7~:::::::7=========?+?I777777+I?,.
         .....?+?I++++++:7$??????????777?++Z$=:~:::::::7I++=====++?+I777777+??+.
         ... ~???++++?,::777?I?IIII?ZZ+?$$?ZZ+~~~~::::?I7=====+?+++?7I7777?++I?.
. ...........+??=?++~,::::IZ?II7IIOZI????+7ZZI~~~~~:::7I7+==?+++++?+III77I+++??.
...      .,=+~??+=?,::::,:Z???7~.7I77Z???+ZZZZ~~~~~~::II7=++++++++?+III77++????.
,=??++++,,:=,,,:,,:,:,,.O7.......,III$$Z+?ZZZO~~~~~~+:I777II++++??+IIII7I??????~
.:?_1517702400_ZZI=:,7?$$........~?I777$$$?III???=~~~=$77II????????7II7$???????+
 .. ..........?=+=+~I+7Z....... ..I?I?7ZZZIIII+++++++?I77IIII?????III$ZZ???????.
..............=====?IIZ.. ..... ..II??I7IZIIII++++++??+I7IIIII?I?7I$Z$ZZ??????+.
. ..   ...  ..+++++=I?, .....    .7I???IIZI7II+++++????77IIIIIIII$ZZZ$ZZ?????+I.
            ..=+++++II=.          7?I??I7ZIIII+++=+????+ZZZZ$ZZZOZZZZZZZ??????+.
              =+=++=?I+.          $II??II$IIII+++++++++?$ZZ$ZOZ77777IZOZ?????+..
              ,=+++=+II           +??I?7IIIIII?++??+++??....7III7777IIII?III?7..
              .+++++??7.          ,II?I7I7ZIIII+++?+?+??....7III7777III7I+?++I. 
              .+=++?+??.          .?III7IIZIIII+??????+?.....7III777IIIII++?+?. 
              .+++I7???:          .IIII7IIIIIII???????+:.....I7II777III$II++I?. 
              ..???????+.....     .=III7IIIIII?I???????.......7II77IIII7II+???. 
              ...?I?????,.....    ..??I777III?II???????.... ..7II7II?I$$III???. 
              ....:?I???II?77  .  ..??I7777IIIII?I????+.......:7I7II?I7$III+??. 
                 ...???I++?++$......7II7I777III??????+,.......II7I+??$$$???$?I..
                   ..?IIII?+?=......+III?I???????????+.......?I$$???I$?I=+~~II:.
                   ........=?......~+=II??I7?$~~~~~:+I.......=I$Z$??IOI~====II7.
                                  .==+?I?7I77:~:~~~~~I.....       ...Z======II. 
                                  .:+=+I$7~?$~~~+~~~I?.....         .... ...... 
                                  .........O:~~~~==:II.....         ..........  
                                          ....,::~=:..                PolyETH         
*/

contract ERC20Interface {
    function totalSupply() public constant returns (uint256 supply);
    function balance() public constant returns (uint256);
    function balanceOf(address _owner) public constant returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Polyion is ERC20Interface {
    string public constant symbol = "PLYN";
    string public constant name = "Polyion";
    uint8 public constant decimals = 2;

    uint256 _totalSupply = 0;
    uint256 _airdropAmount = 1000000;
    uint256 _cutoff = _airdropAmount * 10000;

    mapping(address => uint256) balances;
    mapping(address => bool) initialized;

    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) allowed;

    function  Polyion() public {
        initialized[msg.sender] = true;
        balances[msg.sender] = _airdropAmount * 1000;
        _totalSupply = balances[msg.sender];
    }

    function totalSupply() public constant returns (uint256 supply) {
        return _totalSupply;
    }

    // What's my balance?
    function balance() public constant returns (uint256) {
        return getBalance(msg.sender);
    }

    // What is the balance of a particular account?
    function balanceOf(address _address) public constant returns (uint256) {
        return getBalance(_address);
    }

    // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        initialize(msg.sender);

        if (balances[msg.sender] >= _amount
            && _amount > 0) {
            initialize(_to);
            if (balances[_to] + _amount > balances[_to]) {

                balances[msg.sender] -= _amount;
                balances[_to] += _amount;

                Transfer(msg.sender, _to, _amount);

                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        initialize(_from);

        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0) {
            initialize(_to);
            if (balances[_to] + _amount > balances[_to]) {

                balances[_from] -= _amount;
                allowed[_from][msg.sender] -= _amount;
                balances[_to] += _amount;

                Transfer(_from, _to, _amount);

                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // internal private functions
    function initialize(address _address) internal returns (bool success) {
        if (_totalSupply < _cutoff && !initialized[_address]) {
            initialized[_address] = true;
            balances[_address] = _airdropAmount;
            _totalSupply += _airdropAmount;
        }
        return true;
    }

    function getBalance(address _address) internal returns (uint256) {
        if (_totalSupply < _cutoff && !initialized[_address]) {
            return balances[_address] + _airdropAmount;
        }
        else {
            return balances[_address];
        }
    }
}