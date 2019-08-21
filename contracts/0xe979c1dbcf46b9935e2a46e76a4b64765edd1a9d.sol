pragma solidity ^0.4.11;

contract Bills
{
    string public name          = "Bills";
    string public symbol        = "BLS";
    uint public totalSupply     = 3000000;
    uint public decimals        = 0;
    uint public tokenPrice;
    
    address private Owner;
    
    uint ICOTill   = 1523145601;
	uint ICOStart  = 1520467201;
    
    mapping (address => uint) public balanceOf;
    
    event Transfer(address indexed from, address indexed to, uint value);
    
    modifier onlyModerator()
    {
        require(msg.sender == moderators[msg.sender].Address || msg.sender == Owner);
        _;
    }
    
    modifier onlyOwner()
    {
        require(msg.sender == Owner);
        _;
    }
    
    modifier isICOend()
    {
        require(now >= ICOTill);
        _;
    }
    
    function Bills() public
    {
        name                    = name;
        symbol                  = symbol;
        totalSupply             = totalSupply;
        decimals                = decimals;
        
        balanceOf[this]         = 2800000;
		balanceOf[msg.sender]   = 200000;
        Owner                   = msg.sender;
    }
    
    struct Advert
    {
        uint BoardId;
        uint PricePerDay;
        uint MaxDays;
        address Advertiser;
        string AdvertSrc;
        uint Till;
        uint AddTime;
        uint SpentTokens;
        string Status;
        bool AllowLeasing;
    }
    
    struct Moderator
    {
        address Address;
    }
    
    mapping (uint => Advert) info;
    
    mapping (address => Moderator) moderators;
    
    uint[] Adverts;
    address[] Moderators;
    
    function() public payable
    {
        require(now >= ICOStart || now >= ICOTill);
        
        if(now >= ICOStart && now <= ICOTill)
        {
            require(
                msg.value == 100000000000000000 || msg.value == 300000000000000000 || msg.value == 500000000000000000 || msg.value == 800000000000000000 || 
                msg.value == 1000000000000000000 || msg.value == 3000000000000000000 || msg.value == 5000000000000000000
            );
            
            if(msg.value == 100000000000000000)
            {
                require(balanceOf[this] >= 31);
                balanceOf[msg.sender] += 31;
                balanceOf[this] -= 31;
                Transfer(this, msg.sender, 31);
            }
            if(msg.value == 300000000000000000)
            {
                require(balanceOf[this] >= 95);
                balanceOf[msg.sender] += 95;
                balanceOf[this] -= 95;
                Transfer(this, msg.sender, 95);
            }
            if(msg.value == 500000000000000000)
            {
                require(balanceOf[this] >= 160);
                balanceOf[msg.sender] += 160;
                balanceOf[this] -= 160;
                Transfer(this, msg.sender, 160);
            }
            if(msg.value == 800000000000000000)
            {
                require(balanceOf[this] >= 254);
                balanceOf[msg.sender] += 254;
                balanceOf[this] -= 254;
                Transfer(this, msg.sender, 254);
            }
            if(msg.value == 1000000000000000000)
            {
                require(balanceOf[this] >= 317);
                balanceOf[msg.sender] += 317;
                balanceOf[this] -= 317;
                Transfer(this, msg.sender, 317);
            }
            if(msg.value == 3000000000000000000)
            {
                require(balanceOf[this] >= 938);
                balanceOf[msg.sender] += 938;
                balanceOf[this] -= 938;
                Transfer(this, msg.sender, 938);
            }
            if(msg.value == 5000000000000000000)
            {
                require(balanceOf[this] >= 1560);
                balanceOf[msg.sender] += 1560;
                balanceOf[this] -= 1560;
                Transfer(this, msg.sender, 1560);
            }
        }
        
        if(now >= ICOTill)
        {
            require(msg.sender.balance >= msg.value);
            
            uint _Amount = msg.value / tokenPrice;
            
            require(balanceOf[this] >= _Amount);
            
            balanceOf[msg.sender] += _Amount;
            balanceOf[this] -= _Amount;
            
            Transfer(this, msg.sender, _Amount);
        }
    }
    
    function ContractBalance() public view returns (uint)
    {
        return balanceOf[this];
    }
    
    function LeaseBill(uint BoardId, uint Days, string AdvertSrc) isICOend public 
    {
        var Advr = info[BoardId];
        
        uint Price = Days * Advr.PricePerDay;
        
        require(Advr.BoardId == BoardId && BoardId > 0);
        require(bytes(AdvertSrc).length > 0);
        require(Days <= Advr.MaxDays && Days > 0);
        require(balanceOf[msg.sender] >= Price);
        require(Advr.Till <= now);
        require(Advr.AllowLeasing == true);
        require(keccak256(Advr.Status) == keccak256("Free") || keccak256(Advr.Status) == keccak256("Published"));
        
        require(balanceOf[this] + Price >= balanceOf[this]);
        balanceOf[msg.sender] -= Price;
        balanceOf[this] += Price;
        Transfer(msg.sender, this, Price);
        
        Advr.Advertiser         = msg.sender;
        Advr.AdvertSrc          = AdvertSrc;
        Advr.Till               = now + 86399 * Days;
        Advr.AddTime            = now;
        Advr.SpentTokens        = Price;
        Advr.Status             = "Moderate";
    }
    
    function ModerateBill(uint BoardIdToModerate, bool Published) onlyModerator isICOend public
    {
        var Advr = info[BoardIdToModerate];
        
        require(Advr.BoardId == BoardIdToModerate && BoardIdToModerate > 0);
        
        if(Published == true)
        {
            require(keccak256(Advr.Status) == keccak256("Moderate"));
        
            uint CompensateTime   = now - Advr.AddTime;
            
            Advr.Till             = Advr.Till + CompensateTime;
            Advr.Status           = "Published";
        }
        
        if(Published == false)
        {
            require(keccak256(Advr.Status) == keccak256("Moderate"));
            
			require(balanceOf[this] >= Advr.SpentTokens);
			
            balanceOf[Advr.Advertiser] += Advr.SpentTokens;
            balanceOf[this] -= Advr.SpentTokens;
            Transfer(this, Advr.Advertiser, Advr.SpentTokens);
            
            delete Advr.Advertiser;
            delete Advr.AdvertSrc;
            delete Advr.Till;
            delete Advr.AddTime;
            delete Advr.SpentTokens;
            
            Advr.Status = "Free";
        }
    }
    
    function ChangeBillLeasingInfo(uint _BillToEdit, uint _NewPricePerDay, uint _NewMaxDays, bool _AllowLeasing) onlyOwner isICOend public
    {
        var Advr = info[_BillToEdit];
        
        require(Advr.BoardId == _BillToEdit && _BillToEdit > 0 && _NewPricePerDay > 0 && _NewMaxDays > 0);
        
        Advr.BoardId          = _BillToEdit;
        Advr.PricePerDay      = _NewPricePerDay;
        Advr.MaxDays          = _NewMaxDays;
        Advr.AllowLeasing     = _AllowLeasing;
    }
    
    function AddBill(uint NewBoardId, uint PricePerDay, uint MaxDays, bool _AllowLeasing) onlyOwner isICOend public
    {
        var Advr              = info[NewBoardId];
        
        require(Advr.BoardId  != NewBoardId && NewBoardId > 0 && PricePerDay > 0 && MaxDays > 0);
        
        Advr.BoardId          = NewBoardId;
        Advr.PricePerDay      = PricePerDay;
        Advr.MaxDays          = MaxDays;
        Advr.Status           = "Free";
        Advr.AllowLeasing     = _AllowLeasing;
        
        Adverts.push(NewBoardId);
    }
    
    function AddBillModerator(address Address) onlyOwner isICOend public
    {
        var Modr = moderators[Address];
        
        require(Modr.Address != Address);
        
        Modr.Address = Address;
        
        Moderators.push(Address);
    }
    
    function DeleteBillModerator(address _Address) onlyOwner isICOend public
    {
        delete moderators[_Address];
    }
    
    function AboutBill(uint _BoardId) public view returns (uint BoardId, uint PricePerDay, uint MaxDays, string AdvertSource, uint AddTime, uint Till, string Status, bool AllowLeasing)
    {
        var Advr = info[_BoardId];
        
        return (Advr.BoardId, Advr.PricePerDay, Advr.MaxDays, Advr.AdvertSrc, Advr.AddTime, Advr.Till, Advr.Status, Advr.AllowLeasing);
    }
    
    function SetTokenPrice(uint _Price) onlyOwner isICOend public
    {
        tokenPrice = _Price;
    }
	
	function transfer(address _to, uint _value) public
	{
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
    }
    
    function WithdrawEther() onlyOwner public
    {
        Owner.transfer(this.balance);
    }
    
    function ChangeOwner(address _Address) onlyOwner public
    {
        Owner = _Address;
    }
}