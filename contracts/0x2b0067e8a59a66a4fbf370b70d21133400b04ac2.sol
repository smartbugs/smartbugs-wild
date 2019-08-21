contract Tickets {

    string public name = "Kraftwerk";
    string public symbol = "KKT";
    uint8 public decimals = 0;

    address[1000] public holders;
    mapping(uint256 => bool) public usedTickets;
    mapping(uint256 => string) public additionalInfo;
    mapping(address => uint[16]) public seatsList;
    mapping(address => uint256) public balanceOf;
    address[30000] public booking;
    mapping(address => uint[16]) public bookingList;
    mapping(address => uint256) public amountOfBooked;

    address Manager;
    address ManagerForRate;
    address Company;
    address nullAddress = 0x0;

    uint public limitPerHolder = 16;
    uint public seatsCount = 1000;
    uint scaleMultiplier = 1000000000000000000; 

    uint public Rate_Eth = 298;
    uint public Ticket_Price = 15*scaleMultiplier/Rate_Eth;

    modifier managerOnly { require(msg.sender == Manager); _; }
    modifier rateManagerOnly { require(msg.sender == ManagerForRate); _; }

    event LogAllocateTicket(uint256 _seatID, address _buyer, string _infoString);
    event LogTransfer(address _holder, address _receiver, uint256 _seatID, string _infoStringt);
    event LogRedeemTicket(uint _seatID, address _holder, string _infoString);
    event LogBookTicket(uint _seatID, address _buyer,string _infoString);
    event LogCancelReservation(address _buyer, uint _seatID);



    function Tickets(address _ManagerForRate,  address _Manager, address _Company) {
        ManagerForRate = _ManagerForRate;
        Manager = _Manager;
        Company = _Company;
    }

    function setRate(uint _RateEth) external rateManagerOnly {
       Rate_Eth = _RateEth;
       Ticket_Price = 15*scaleMultiplier/Rate_Eth;
    }


    function allocateTicket(uint256 seatID, address buyer, string infoString) external managerOnly {
        require(seatID > 0 && seatID < seatsCount);
        require(holders[seatID] == nullAddress);
        require(balanceOf[buyer] < limitPerHolder);
        require(booking[seatID] == nullAddress);
        createTicket(seatID, buyer);
        additionalInfo[seatID] = infoString;
        LogAllocateTicket(seatID, buyer, infoString);
    }

    function createTicket(uint256 seatID, address buyer) internal {
        uint i = 0;
        for(i = 0; i < limitPerHolder; i++)
        {
            if(seatsList[buyer][i] == 0)
            {
                break;
            }
        }
        holders[seatID] = buyer;
        balanceOf[buyer] += 1;
        seatsList[buyer][i] = seatID;
    }

    function redeemTicket(uint seatID, address holder) external managerOnly{
        require(seatID > 0 && seatID < seatsCount);
        require(usedTickets[seatID] == false);
        require(holders[seatID] == holder);
        usedTickets[seatID] = true;
        string infoString = additionalInfo[seatID];
        LogRedeemTicket(seatID, holder, infoString);
    }

    function transfer(address holder, address receiver, uint256 seatID) external managerOnly{
        require(seatID > 0 && seatID < seatsCount);
        require(holders[seatID] == holder);
        require(balanceOf[receiver] < limitPerHolder);
        require(holder != receiver);
        uint i = 0;
        holders[seatID] = receiver;
        balanceOf[holder] -= 1;
        if(receiver != nullAddress)
        {
            for(i = 0; i < limitPerHolder; i++)
              {
                  if(seatsList[receiver][i] == 0)
                  {
                     break;
                  }
            }
            balanceOf[receiver] += 1;
            seatsList[receiver][i] = seatID;
        }
        for(i = 0; i < limitPerHolder; i++)
        {
            if(seatsList[holder][i] == seatID)
            {
                seatsList[holder][i] = 0;
            }
        }
        string infoString = additionalInfo[seatID];
        LogTransfer(holder, receiver, seatID, infoString);
    }

    function bookTicket(uint256 seatID, address buyer, string infoString) external managerOnly{
        require(seatID > 0 && seatID < seatsCount);
        require(holders[seatID] == nullAddress);
        require(booking[seatID] == nullAddress);
        require(balanceOf[buyer] + amountOfBooked[buyer] < limitPerHolder);
        uint i = 0;
        booking[seatID] = buyer;
        amountOfBooked[buyer] += 1;
        while(bookingList[buyer][i] != 0) {
            i++;
        }
        bookingList[buyer][i] = seatID;
        additionalInfo[seatID] = infoString;
        LogBookTicket(seatID, buyer, infoString);
    }

    function cancelReservation(address buyer, uint256 seatID) external managerOnly{
        require(booking[seatID] == buyer);
        uint i = 0;
        while(i < limitPerHolder) {
            if (seatID == bookingList[buyer][i]){
              booking[seatID] = nullAddress;
              bookingList[buyer][i] = 0;
              break;
            }
            i++;
        }
        amountOfBooked[buyer] -= 1;
        LogCancelReservation(buyer, seatID);
    }


    function() payable {
        require(amountOfBooked[msg.sender] != 0);
        require(balanceOf[msg.sender] + amountOfBooked[msg.sender] <= limitPerHolder);
        require(msg.value >= Ticket_Price * amountOfBooked[msg.sender]);
        makePayment(msg.sender);
    }

    function makePayment(address buyer) internal {
        uint i = 0;
        uint seatID;
        string infoString;
        while(i < limitPerHolder) {
            if(bookingList[buyer][i] != 0) {
              seatID = bookingList[buyer][i];
              bookingList[buyer][i] = 0;
              booking[seatID] = nullAddress;
              createTicket(seatID, buyer);
              infoString = additionalInfo[seatID];
              LogAllocateTicket(seatID, msg.sender, infoString);
            }
            i++;
        }
        amountOfBooked[buyer] = 0;
    }

    function withdrawEther(uint256 _value) external managerOnly{
       Company.transfer(_value);
    }


}