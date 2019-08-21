pragma solidity >=0.4.0 <0.6.0;

contract owned {
    address public owner;
    address public manager;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

contract Coin {
    function getOwner(uint index) public view returns (address, uint256);
    function getOwnerCount() public view returns (uint);
}

contract RTDAirdrop is owned{
    event console(address addr, uint256 amount);
    event AirDrop(address indexed from, address indexed to, uint256 value);
    string public detail;
    uint public eth_price_per_usd;
    uint public rtd_price_per_eth;
    uint public date_start;
    uint public date_end;
    uint public active_round;

    struct Member {
        uint256 have_rtd;
        uint256 dividend;
        uint take;
    }

    struct Round {
        string detail;
        uint eth_price_per_usd;
        uint rtd_price_per_eth;
        uint date_start;
        uint date_end;
        mapping(address => Member) members;
    }

    Round[] public round;


    function setting( string memory new_detail, uint new_eth_price_per_usd, uint new_rtd_price_per_eth, uint new_date_start, uint new_date_end ) onlyOwner public {

            detail = new_detail;
            eth_price_per_usd = new_eth_price_per_usd;
            rtd_price_per_eth = new_rtd_price_per_eth;
            date_start = new_date_start;
            date_end = new_date_end;
            active_round = round.length;

            round[active_round]=Round(detail,eth_price_per_usd,rtd_price_per_eth,date_start,date_end);
            Coin c = Coin(0x003FfEFeFBC4a6F34a62A3cA7b7937a880065BCB);
            for (uint256 i = 0; i < c.getOwnerCount(); i++) {
                address addr;
                uint256 amount;
                (addr, amount)  = c.getOwner(i);
                round[active_round].members[addr] = Member(amount,(amount * (eth_price_per_usd * rtd_price_per_eth)),0);
            } 

    }


    function getAirDrop() public {
        require (now >= date_start);  
        require (now <= date_end);  
        require (msg.sender != address(0x0));                
        if(round[active_round].members[msg.sender].take==0){
            round[active_round].members[msg.sender].take=1;
            //msg.sender.transfer(members[msg.sender].dividend);
            emit AirDrop(0x003FfEFeFBC4a6F34a62A3cA7b7937a880065BCB, msg.sender, round[active_round].members[msg.sender].dividend);
        }
    }
}