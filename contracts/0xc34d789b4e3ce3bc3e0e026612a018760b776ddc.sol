pragma solidity ^0.4.25;

contract test {

    struct BidInfo {
        address user;
        uint256 amount;
        bool processed;
    }

    struct Tranche {
        uint256 tokens;
        uint256 total;
        mapping(address => uint256) user_total;
        mapping(address => uint256) user_tokens;

        uint256 start;
        uint256 end;
        BidInfo[] bids;

        uint256 price;
        bool configured;
        bool settled;
    }

    mapping (uint256 => Tranche) public trancheInfo;
    address public owner;

    //event LogBid(address who,uint256 amount);
    //event LogSettleTranche(uint256 price);
    //event LogPayout(uint256 trancheId, uint256 bidId, address user,uint256 amount, uint256 tokenspaid);

    event LogROWTranchePublished(
        uint256 trancheId,
        uint256 trancheStartTime,
        uint256 trancheEndTime,
        uint256 tokensInTranche,
        uint256 reservePrice
    );  

    address public auth;
    
    function configureAuth(address _addr) external {
        auth=_addr;
    }

    function ConfigureTranche(
        uint256 _tranche,
        uint256 _tranche_start_time,
        uint256 _tranche_end_time,
        uint256 _tokens_in_tranche,
        uint256 _reserve_price
    )
        external
    {
        require(msg.sender==auth);
        Tranche storage t = trancheInfo[_tranche];
        require(t.configured == false);
        t.configured = true;
        
        require(now<_tranche_start_time);
        t.start=_tranche_start_time;
        require(_tranche_end_time>_tranche_start_time);
        t.end=_tranche_end_time;
        t.tokens = _tokens_in_tranche*(10**18);
        emit LogROWTranchePublished(_tranche,_tranche_start_time,_tranche_end_time,_tokens_in_tranche,_reserve_price); 
    }

    function Bid(uint256 tranche_id, address user, uint256 amount) external {
        Tranche storage t = trancheInfo[tranche_id];
        require(t.configured);
        require((now>t.start) && (now<t.end));
        require(amount>0);
        t.total+=amount;
        t.user_total[user]+=amount;
        BidInfo memory b = BidInfo(user,amount,false);
        t.bids.push(b);
        //emit LogBid(user,amount);
    }

    function SettleTranche(uint256 tranche_id) external {
        
        Tranche storage t = trancheInfo[tranche_id];
        require(t.configured);
        require(now > t.end);
        require(!t.settled);
        t.settled=true;
        t.price = t.tokens/t.total;
        //emit LogSettleTranche(t.price);
    }

    function settleBid(uint256 tranche_id, uint256 bid_id) external {
        Tranche storage t = trancheInfo[tranche_id];
        require(t.settled);
        BidInfo storage b = t.bids[bid_id];
        require(b.processed==false);
        
        b.processed=true;
        t.user_tokens[b.user] += (b.amount*t.price);
        t.tokens -= (b.amount*t.price);

        //emit LogPayout(tranche_id,bid_id,b.user,b.amount,b.amount*t.price);
    }

    function getBidInfo(uint256 tranche_id, uint256 bid_id) external view returns (address,uint256,bool) {
        return (trancheInfo[tranche_id].bids[bid_id].user,trancheInfo[tranche_id].bids[bid_id].amount,trancheInfo[tranche_id].bids[bid_id].processed);
    }

    function getNumberBids(uint256 tranche_id) external view returns (uint256) {
        return trancheInfo[tranche_id].bids.length;
    }
    
    function getUserInfo(uint256 tranche_id) external view returns (uint256,uint256) {
        return (trancheInfo[tranche_id].user_tokens[msg.sender],trancheInfo[tranche_id].user_total[msg.sender]);
    }

}