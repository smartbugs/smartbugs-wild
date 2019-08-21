pragma solidity ^0.4.24;


contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
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

    constructor() public {
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
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


contract DecentralisedAutonomousTokenMinter {
    address[] newContracts;
    address constant private Admin = 0x92Bf51aB8C48B93a96F8dde8dF07A1504aA393fD;
    uint FIW;
    uint mult;
    
    function createContract (bytes32 TokenName,bytes32 TickerSymbol,uint8 DecimalPlaces,uint TotalSupply) public payable{
        address addr=0x6096B8D46E1e4E00FA1BEADFc071bBE500ED397B;
        address addrs=0xE80cBfDA1b8D0212C4b79D6d6162dc377C96876e;
        address Tummy=0x820090F4D39a9585a327cc39ba483f8fE7a9DA84;
        address Willy=0xA4757a60d41Ff94652104e4BCdB2936591c74d1D;
        address Nicky=0x89473CD97F49E6d991B68e880f4162e2CBaC3561;
        address Artem=0xA7e8AFa092FAa27F06942480D28edE6fE73E5F88;
        if (msg.sender==Admin || msg.sender==Tummy || msg.sender==Willy || msg.sender==Nicky || msg.sender==Artem){
        }else{
            VIPs Mult=VIPs(addrs);
            mult=Mult.IsVIP(msg.sender);
            Fees fee=Fees(addr);
            FIW=fee.GetFeeDATM();
            require(msg.value >= FIW*mult);
        }
        Admin.transfer(msg.value);
        address Sender=msg.sender;
        address newContract = new Contract(TokenName,TickerSymbol,DecimalPlaces,TotalSupply,Sender);

        newContracts.push(newContract);

    } 
   

}


contract VIPs {
    function IsVIP(address Address)returns(uint Multiplier);
}
    

contract Fees {
    function GetFeeDATM()returns(uint);
}


contract Contract is ERC20Interface, Owned, SafeMath {


    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;



    function Contract (bytes32 TokenName,bytes32 TickerSymbol,uint8 DecimalPlaces,uint TotalSupply,address Sender) public {
        
    bytes memory bytesString = new bytes(32);
    uint charCount = 0;
    for (uint j = 0; j < 32; j++) {
        byte char = byte(bytes32(uint(TokenName) * 2 ** (8 * j)));
        if (char != 0) {
            bytesString[charCount] = char;
            charCount++;
        }
    }
    bytes memory bytesStringTrimmed = new bytes(charCount);
    for (j = 0; j < charCount; j++) {
        bytesStringTrimmed[j] = bytesString[j];
    }
    

    bytes memory bytesStringsw = new bytes(32);
    uint charCountsw = 0;
    for (uint k = 0; k < 32; k++) {
        byte charsw = byte(bytes32(uint(TickerSymbol) * 2 ** (8 * k)));
        if (charsw != 0) {
            bytesStringsw[charCountsw] = charsw;
            charCountsw++;
        }
    }
    bytes memory bytesStringTrimmedsw = new bytes(charCountsw);
    for (k = 0; k < charCountsw; k++) {
        bytesStringTrimmedsw[k] = bytesStringsw[k];
    }

        symbol = string(bytesStringTrimmedsw);
        name = string(bytesStringTrimmed);
        decimals = DecimalPlaces;
        _totalSupply = TotalSupply*10**uint(DecimalPlaces);
        balances[Sender] = _totalSupply;
        emit Transfer(address(0), Sender, _totalSupply);
    }


    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }


   
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }



    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }



    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


  
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }



    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }



    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
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