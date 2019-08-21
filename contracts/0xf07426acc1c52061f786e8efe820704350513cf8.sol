pragma solidity ^0.5.0;

//SafeMath library for calculations.
contract SafeMath {
    function safeAdd(uint a, uint b) internal pure returns (uint c){
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) internal pure returns (uint c){
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) internal pure returns (uint c){
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) internal pure returns (uint c){
        require(b > 0);
        c = a / b;
    }
}

//ERC Function declaration
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

//Onwer function declaration.
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
}

//Main contract code.
contract ErgoPostToken is ERC20Interface, Owned, SafeMath{
    
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint  totalsupply;
    uint initialBalance;
    uint public reserved;
    uint public team;
    uint public ico;
    uint public bounty;
    uint public total_presale_token;
    uint public total_crowdsale_token;
    uint public total_sale_token;
    uint public total_purchase_token;
    uint public total_earning;
    uint decimal_price;
    
    struct presale{
        uint startDate;
        uint endDate;
        uint pretoken;
        uint price;
    }
    
    struct crowdsale{
        uint crowd_startdate;
        uint crowd_enddate;
        uint crowd_token;
        uint price;
       
    }
    
  
    presale[] public presale_detail;
    
    crowdsale public crowdsale_detail;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor() public{
        symbol = "EPT";
        name = "ErgoPostToken";
        decimals = 18;
        decimal_price = 1000000000000000000;
        initialBalance = 3000000000*decimal_price;
        balances[owner] = initialBalance;
        totalsupply += initialBalance;
        reserved =  totalsupply * 25/100;
        team =  totalsupply * 8/100;
        ico =  totalsupply * 65/100;
        bounty = totalsupply * 2/100;
        owner = msg.sender;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    //Code to Transfer the Ownership
    function transferOwnership(address newOwner) public onlyOwner{
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        uint _value = balances[msg.sender];
        balances[msg.sender] -= _value;
        balances[newOwner] += _value;
        emit Transfer(msg.sender, newOwner, _value);
    }
  
    //code to Start Pre-Sale.
    function start_presale(uint _startdate,uint _enddate,uint token_for_presale,uint price) public onlyOwner{
        
        if(_startdate <= _enddate && _startdate > now && token_for_presale < ico){
            for(uint start=0; start < presale_detail.length; start++)
            {
                if(presale_detail[start].endDate >= _startdate)
                {   
                    revert("Another Sale is running");
                }
            }
            presale memory p= presale(_startdate,_enddate,token_for_presale*decimal_price,price);
            presale_detail.push(p);
            total_presale_token += token_for_presale*decimal_price;
            balances[owner] -= token_for_presale*decimal_price;
            total_crowdsale_token = ico-total_presale_token;
            crowdsale_detail.crowd_token = total_crowdsale_token;
        }
        else{
            revert("Presale not set");
        }
    }
    
    //code to Start Pre-Sale.
    function start_crowdsale(uint _startdate,uint _enddate,uint _price) public onlyOwner{
        if(_startdate <= _enddate && _startdate > now){
            crowdsale_detail.crowd_startdate = _startdate;
            crowdsale_detail.crowd_enddate = _enddate;
            crowdsale_detail.price = _price;
            balances[owner] -= total_crowdsale_token;
        }
        else{
            revert("Crowdasale not set");
        }
    }
    
    //Function to get total supply.
    function totalSupply() public view returns (uint) {
        return totalsupply  - balances[address(0)];
    }

    //Function to check balance.
    function balanceOf(address tokenOwner) public view returns (uint balance){
        return balances[tokenOwner];
    }

    //Function to transfer token by owner.
    function transfer(address to, uint tokens) public onlyOwner returns (bool success){
        balances[msg.sender] = safeSub(balances[msg.sender], tokens*decimal_price);
        balances[to] = safeAdd(balances[to], tokens*decimal_price);
        total_sale_token += tokens*decimal_price;
        emit Transfer(msg.sender, to, tokens*decimal_price);
        return true;
    }
    
    //Approve function.
    function approve(address spender, uint tokens) public returns (bool success){
        allowed[msg.sender][spender] = tokens*decimal_price;
        emit Approval(msg.sender, spender, tokens*decimal_price);
        return true;
    }
    
    //Fucntion to transfer token from address.
    function transferFrom(address from, address to, uint tokens) public returns (bool success){
        balances[from] = safeSub(balances[from], tokens*decimal_price);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens*decimal_price);
        balances[to] = safeAdd(balances[to], tokens*decimal_price);
        emit Transfer(from, to, tokens*decimal_price);
        return true;
    }

    //Allowance function.
    function allowance(address tokenOwner, address spender) public view returns (uint remaining){
        return allowed[tokenOwner][spender];
    }
    //Code to purchase token.
    function purchase (address _account,uint256 _token,uint amount) public payable{
        for (uint i=0; i < presale_detail.length; i++){
            if (now >= presale_detail[i].startDate && now <=presale_detail[i].endDate){
                if(_token*decimal_price <= presale_detail[i].pretoken){
                    uint256 payment= _token * presale_detail[i].price;
                    if(payment == amount){
                        presale_detail[i].pretoken -= _token*decimal_price;
                        balances[_account] = safeAdd(balances[_account], _token*decimal_price);
                        total_earning += payment;
                        total_purchase_token += _token*decimal_price;
                        total_sale_token += _token*decimal_price;
                    }
                    else{
                        revert("Invalid amount");
                    }
                    return;
                }
                else{
                    revert();
                }
            }
        }
            
        if(now >= crowdsale_detail.crowd_startdate && now <= crowdsale_detail.crowd_enddate){
            require(_token < total_crowdsale_token);
            uint256 payment_for_crowdsale= _token * crowdsale_detail.price;
            if(payment_for_crowdsale == amount){
                balances[_account] = safeAdd(balances[_account], _token*decimal_price);
                if(crowdsale_detail.crowd_token > 0 ){
                    crowdsale_detail.crowd_token -= _token*decimal_price;
                    total_earning += payment_for_crowdsale;
                    total_purchase_token += _token*decimal_price;
                    total_sale_token += _token*decimal_price;
                }
                else{
                    revert("Check available token balances");
                }
            }
            else{
                revert("Invalid amount");
            }
        }
        else{
            revert("Sale is not started");
        }
        emit Transfer(address(0), _account, _token*decimal_price);
    }

    //Function to pay from bounty.
    function  pay_from_bounty(uint tokens, address to) public onlyOwner returns (bool success){
        bounty = safeSub(bounty, tokens*decimal_price);
        balances[owner] -= tokens*decimal_price;
        balances[to] = safeAdd(balances[to], tokens*decimal_price);
        total_sale_token += tokens*decimal_price;
        emit Transfer(msg.sender, to, tokens*decimal_price);
        return true;
    }

    //Function to pay from reserved.
    function pay_from_reserved(uint tokens, address to) public onlyOwner returns(bool success){
        reserved = safeSub(reserved,tokens*decimal_price);
        balances[owner] -= tokens*decimal_price;
         balances[to] = safeAdd(balances[to], tokens*decimal_price);
         total_sale_token += tokens*decimal_price;
         emit Transfer(msg.sender, to, tokens*decimal_price);
        return true;
    }

    //Function to pay from team.
    function pay_from_team(uint tokens , address to) public onlyOwner returns(bool success){
        team = safeSub(team,tokens*decimal_price); 
        balances[owner] -= tokens*decimal_price;
        balances[to] = safeAdd(balances[to], tokens*decimal_price);
         total_sale_token += tokens*decimal_price;
        emit Transfer(msg.sender,to,tokens*decimal_price);
        return true;
    }
    
    //Function to get contract balance.
    function get_contrct_balance() public view returns (uint256){
        return address(this).balance;
    }
    
    //ETH Transfer
    function ethTransfer(address payable to, uint value_in_eth) onlyOwner public returns(bool success){
        uint256 contractblc = address(this).balance;
        contractblc -= value_in_eth;
        uint wi = 1000000000000000000;
        uint finalamt = value_in_eth * wi;
        to.transfer(finalamt);
        return true;
    }   
    
    //User functionality to burn the token from his account.
    function burnFrom(address payable to, uint256 value) public returns (bool success){
        require(balances[msg.sender] >= value*decimal_price);
        balances[msg.sender] -= value*decimal_price;
        emit Transfer(msg.sender, address(0), value*decimal_price); //solhint-disable-line indent, no-unused-vars
        return true;
    }
    
}