pragma solidity ^0.4.18;

contract Random {

    uint public ticketsNum = 0;
    
    mapping(uint => uint) internal tickets;  // tickets for the current draw
    mapping(uint => bool) internal payed_back; // ticket payment refunding identifier
    
    address[] public addr; // addresses of all the draw participants
    
    uint32 public random_num = 0; // draw serial number
 
    uint public liveBlocksNumber = 5760; // amount of blocks untill the lottery ending
    uint public startBlockNumber = 0; // initial block of the current lottery
    uint public endBlockNumber = 0; // final block of the current lottery

    uint public constant onePotWei = 10000000000000000; // 1 ticket cost is 0.01 ETH

    address public inv_contract = 0x5192c55B1064D920C15dB125eF2E69a17558E65a; // investing contract
    address public rtm_contract = 0x7E08c0468CBe9F48d8A4D246095dEb8bC1EB2e7e; // team contract
    address public mrk_contract = 0xc01c08B2b451328947bFb7Ba5ffA3af96Cfc3430; // marketing contract
    
    address manager; // lottery manager address
    
    uint public winners_count = 0; // amount of winners in the current draw
    uint last_winner = 0; // amount of winners already received rewards
    uint public others_prize = 0; // prize fund less jack pots
    
    uint public fee_balance = 0; // current balance available for commiting payment to investing, team and marketing contracts

    
    // Events
    // This generates a publics event on the blockchain that will notify clients
    
    event Buy(address indexed sender, uint eth); // tickets purchase
    event Withdraw(address indexed sender, address to, uint eth); // reward accruing
    event Transfer(address indexed from, address indexed to, uint value); // event: sending ticket to another address
    event TransferError(address indexed to, uint value); // event (error): sending ETH from the contract was failed
    

    // methods with following modifier can only be called by the manager
    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }
    

    // constructor
    function Random() public {
        manager = msg.sender;
        startBlockNumber = block.number - 1;
        endBlockNumber = startBlockNumber + liveBlocksNumber;
    }


    /// function for straight tickets purchase (sending ETH to the contract address)
    function() public payable {
        require(block.number < endBlockNumber || msg.value < 1000000000000000000);
        if (msg.value > 0 && last_winner == 0) {
            uint val =  msg.value / onePotWei;
            uint i = 0;
            uint ix = checkAddress(msg.sender);
            for(i; i < val; i++) { tickets[ticketsNum+i] = ix; }
            ticketsNum += i;
            Buy(msg.sender, msg.value);
        }
        if (block.number >= endBlockNumber) { 
            EndLottery(); 
        }
    }


    /// function for ticket sending from owner's address to designated address
    function transfer(address _to, uint _ticketNum) public {
        if (msg.sender == getAddress(tickets[_ticketNum]) && _to != address(0)) {
            uint ix = checkAddress(_to);
            tickets[_ticketNum] = ix;
            Transfer(msg.sender, _to, _ticketNum);
        }
    }


    /// manager's opportunity to write off ETH from the contract, in a case of unforseen contract blocking (possible in only case of more than 24 hours from the moment of lottery ending had passed and a new one has not started)
    function manager_withdraw() onlyManager public {
        require(block.number >= endBlockNumber + liveBlocksNumber);
        msg.sender.transfer(this.balance);
    }
    
    /// lottery ending
    function EndLottery() public payable returns (bool success) {
        require(block.number >= endBlockNumber); 
        uint tn = ticketsNum;
        if(tn < 3) { 
            tn = 0;
            if(msg.value > 0) { msg.sender.transfer(msg.value); }
            startNewDraw(msg.value);
            return false;
        }
        uint pf = prizeFund();
        uint jp1 = percent(pf, 10);
        uint jp2 = percent(pf, 4);
        uint jp3 = percent(pf, 1);
        uint lastbet_prize = onePotWei*10;
        
        if(last_winner == 0) {
            
            winners_count = percent(tn, 4) + 3; 
            
            uint prizes = jp1 + jp2 + jp3 + lastbet_prize*2;
            uint full_prizes = jp1 + jp2 + jp3 + (lastbet_prize * ( (winners_count+1)/10 ) );

            if(winners_count < 10) {
                if(prizes > pf) {
                    others_prize = 0;
                } else {
                    others_prize = pf - prizes;    
                }
            } else {
                if(full_prizes > pf) {
                    others_prize = 0;
                } else {
                    others_prize = pf - full_prizes;    
                }
            }

            sendEth(getAddress(tickets[getWinningNumber(1)]), jp1);
            sendEth(getAddress(tickets[getWinningNumber(2)]), jp2);
            sendEth(getAddress(tickets[getWinningNumber(3)]), jp3);
            last_winner += 1;
            
            sendEth(msg.sender, lastbet_prize + msg.value); 
            return true;
        } 
        
        if(last_winner < winners_count + 1 && others_prize > 0) {
            
            uint val = others_prize / winners_count;
            uint i;
            uint8 cnt = 0;
            for(i = last_winner; i < winners_count + 1; i++) {
                sendEth(getAddress(tickets[getWinningNumber(i+3)]), val);
                cnt++;
                if(cnt > 9) {
                    last_winner = i;
                    return true;
                }
            }
            last_winner = i;
            sendEth(msg.sender, lastbet_prize + msg.value);
            return true;
            
        } else {

            startNewDraw(lastbet_prize + msg.value);   
        }
        
        sendEth(msg.sender, lastbet_prize + msg.value);
        return true;
    }
    
    /// new draw start
    function startNewDraw(uint _msg_value) internal {
        ticketsNum = 0;
        startBlockNumber = block.number - 1;
        endBlockNumber = startBlockNumber + liveBlocksNumber;
        random_num += 1;
        winners_count = 0;
        last_winner = 0;
        fee_balance += (this.balance - _msg_value);
    }
    
    /// sending rewards to the investing, team and marketing contracts 
    function payfee() public {
        require(fee_balance > 0);
        uint val = fee_balance;
        inv_contract.transfer( percent(val, 20) );
        rtm_contract.transfer( percent(val, 49) );
        mrk_contract.transfer( percent(val, 30) );
        fee_balance = 0;
    }
    
    /// function for sending ETH with balance check (does not interrupt the program if balance is not sufficient)
    function sendEth(address _to, uint _val) internal returns(bool) {
        if(this.balance < _val) {
            TransferError(_to, _val);
            return false;
        }
        _to.transfer(_val);
        Withdraw(address(this), _to, _val);
        return true;
    }
    
    
    /// get winning ticket number basing on block hasg (block number is being calculated basing on specified displacement)
    function getWinningNumber(uint _blockshift) internal constant returns (uint) {
        return uint(block.blockhash(block.number - _blockshift)) % ticketsNum + 1;
    }
    

    /// current amount of jack pot 1
    function jackPotA() public view returns (uint) {
        return percent(prizeFund(), 10);
    }
    
    /// current amount of jack pot 2
    function jackPotB() public view returns (uint) {
        return percent(prizeFund(), 4);
    }
    
    /// current amount of jack pot 3
    function jackPotC() public view returns (uint) {
        return percent(prizeFund(), 1);
    }

    /// current amount of prize fund
    function prizeFund() public view returns (uint) {
        return ( (ticketsNum * onePotWei) / 100 ) * 90;
    }

    /// function for calculating definite percent of a number
    function percent(uint _val, uint8 _percent) public pure returns (uint) {
        return ( _val / 100 ) * _percent;
    }


    /// returns owner address using ticket number
    function getTicketOwner(uint _num) public view returns (address) {
        if(ticketsNum == 0) {
            return 0;
        }
        return getAddress(tickets[_num]);
    }

    /// returns amount of tickets for the current draw in the possession of specified address
    function getTicketsCount(address _addr) public view returns (uint) {
        if(ticketsNum == 0) {
            return 0;
        }
        uint num = 0;
        for(uint i = 0; i < ticketsNum; i++) {
            if(tickets[i] == readAddress(_addr)) {
                num++;
            }
        }
        return num;
    }
    
    /// returns tickets numbers for the current draw in the possession of specified address
    function getTicketsAtAdress(address _address) public view returns(uint[]) {
        uint[] memory result = new uint[](getTicketsCount(_address));
        uint num = 0;
        for(uint i = 0; i < ticketsNum; i++) {
            if(getAddress(tickets[i]) == _address) {
                result[num] = i;
                num++;
            }
        }
        return result;
    }


    /// returns amount of paid rewards for the current draw
    function getLastWinner() public view returns(uint) {
        return last_winner+1;
    }


    /// investing contract address change
    function setInvContract(address _addr) onlyManager public {
        inv_contract = _addr;
    }

    /// team contract address change
    function setRtmContract(address _addr) onlyManager public {
        rtm_contract = _addr;
    }

    /// marketing contract address change
    function setMrkContract(address _addr) onlyManager public {
        mrk_contract = _addr;
    }


    /// returns number of participant (in the list of participants) by belonging address and adding to the list, if not found
    function checkAddress(address _addr) public returns (uint addr_num)
    {
        for(uint i=0; i<addr.length; i++) {
            if(addr[i] == _addr) {
                return i;
            }
        }
        return addr.push(_addr) - 1;
    }
    
    /// returns participants number (in the list of participants) be belonging address (read only)
    function readAddress(address _addr) public view returns (uint addr_num)
    {
        for(uint i=0; i<addr.length; i++) {
            if(addr[i] == _addr) {
                return i;
            }
        }
        return 0;
    }

    /// returns address by the number in the list of participants
    function getAddress(uint _index) public view returns (address) {
        return addr[_index];
    }


    /// method for direct contract replenishment with ETH
    function deposit() public payable {
        require(msg.value > 0);
    }
    

}