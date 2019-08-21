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
.:?_1517529600_ZZI=:,7?$$........~?I777$$$?III???=~~~=$77II????????7II7$???????+
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


library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {

        c = a + b;

        require(c >= a);

    }

    function sub(uint a, uint b) internal pure returns (uint c) {

        require(b <= a);

        c = a - b;

    }

    function mul(uint a, uint b) internal pure returns (uint c) {

        c = a * b;

        require(a == 0 || c / a == b);

    }

    function div(uint a, uint b) internal pure returns (uint c) {

        require(b > 0);

        c = a / b;

    }

}





contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}




contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;

}



contract Owned {

    address public owner;

    address public newOwner;


    event OwnershipTransferred(address indexed _from, address indexed _to);


    function Owned() public {

        owner = msg.sender;

    }


    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }


    function transferOwnership(address _newOwner) public onlyOwner {

        newOwner = _newOwner;

    }

    function acceptOwnership() public {

        require(msg.sender == newOwner);

        OwnershipTransferred(owner, newOwner);

        owner = newOwner;

        newOwner = address(0);

    }

}


contract FixedSupplyToken is ERC20Interface, Owned {

    using SafeMath for uint;


    string public symbol;

    string public  name;

    uint8 public decimals;

    uint public _totalSupply;


    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;



    function FixedSupplyToken() public {

        symbol = "PLE";

        name = "PolyETH";

        decimals = 18;

        _totalSupply = 100000000 * 10**uint(decimals);

        balances[owner] = _totalSupply;

        Transfer(address(0), owner, _totalSupply);

    }

    function totalSupply() public constant returns (uint) {

        return _totalSupply  - balances[address(0)];

    }


    function balanceOf(address tokenOwner) public constant returns (uint balance) {

        return balances[tokenOwner];

    }



    function transfer(address to, uint tokens) public returns (bool success) {

        balances[msg.sender] = balances[msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        Transfer(msg.sender, to, tokens);

        return true;

    }



    function approve(address spender, uint tokens) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        Approval(msg.sender, spender, tokens);

        return true;

    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

        balances[from] = balances[from].sub(tokens);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        Transfer(from, to, tokens);

        return true;

    }


    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {

        return allowed[tokenOwner][spender];

    }


    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        Approval(msg.sender, spender, tokens);

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);

        return true;

    }


    function () public payable {

        revert();

    }


    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

        return ERC20Interface(tokenAddress).transfer(owner, tokens);

    }

}