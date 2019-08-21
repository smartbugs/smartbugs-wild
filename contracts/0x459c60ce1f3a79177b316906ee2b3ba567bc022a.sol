pragma solidity ^0.4.23;

/***
 * @title -MinerWinner beta_0.1
 * 
 * MinerWinner is a game created based on Ethereum. 
 * We try to create a completely fair game.
 * Try to streamline processes and operations.
 * This game has no commission.
 * Everyone have to participate through the equal way.
 * 
 * MinerWinner User Guide:
 * Players can play the game by transferring fund to protocol address at 
 *  a cost of 1 eth at a time (note: single transfer shall not be less
 *  than 1 eth, otherwise, the transfer will fail. If the transfer is
 *  greater than 1 eth, players cannot get extra benefits. If you want
 *  to make more benefits, you can transfer 1 eth at a time for several times.).
 * 
 * Besides eth reward, players can get MinerWinner unique token reward.
 * 
 * Token Reward:
 * Token reward is incrementally awarded to players according to the sort
 *  entered by the player, for instance, the tenth participant gets 10 tokens,
 *  and the 100th participant gets 100 token.
 * 
 * The eth reward is divided into two parts.
 * 1.After each new player enters, the reward will be given to the previous
 *    player in the form of an accelerated round tour.
 * 2.When the countdown is over but no player enters, the players that have
 *    extra eth can play repeatedly. If the token of this repeated player is
 *    more than the latter 8 players in current queue, this play can receive 3
 *    eth rewards and reactivate the countdown. In this way, the incentive will
 *    encourage more players to promote the game process.
 * 
 * Token transaction:
 * Token rewards can be traded to players who want to win the promotion reward.
 *  This is to become the token owner that has most of the token and to compete
 *  for the promotion reward.
 *
 * Then we will launch a series of versions.
 * This token is available for all versions of MinerWinner.
 *
 * WARNING:  THIS PRODUCT IS HIGHLY ADDICTIVE.  IF YOU HAVE AN ADDICTIVE NATURE.  DO NOT PLAY.
 */
//===========================================================================================>

contract miner_winner_basic {  

    address public owner;
    address public reward_winaddr;
    uint256 public deadline;
    uint256 public time;
    uint256 public price;
    uint256 public reward_value;
    token public token_reward;
    address[] public plyr;
    uint256 public next_count;
}

contract miner_winner is miner_winner_basic {

    constructor(address _token_reward_address) public {

        owner = msg.sender;
        reward_winaddr = address(0);
        time = 8 * 60 minutes;
        deadline = now + time;
        price = 1 ether;
        reward_value = 0;
        token_reward = token(_token_reward_address);
        plyr = new address[](0);
        plyr.push(msg.sender);
        next_count = 0;
    }

    function() public payable {

        require(msg.value >= price);

        plyr.push(msg.sender);

        if( next_count >= plyr.length) {
            next_count = 0;
        }
        plyr[next_count].transfer(price * 20/100);
        next_count++;
        
        if( next_count >= plyr.length) {
            next_count = 0;
        }
        plyr[next_count].transfer(price * 20/100);
        next_count++;    

        reward_value = token_reward.balanceOf(address(this));

        uint256 _pvalue = plyr.length * price;

        if(reward_value >= _pvalue){
            token_reward.transfer(msg.sender, _pvalue);
        }
        
        uint256 _now = now;

        if( _now > deadline) {

            if( reward_winaddr == address(0)) {
                reward_winaddr = plyr[plyr.length - 1];
            }

            for(uint256 i = plyr.length - 9; i < plyr.length; i++) {

                if(token_reward.balanceOf(plyr[i]) > token_reward.balanceOf(reward_winaddr)){
                    reward_winaddr = plyr[i];
                }
            }

            if(address(this).balance > 3 ether){
                reward_winaddr.transfer(3 ether);
            }
        }

        deadline = _now + time;
    }
}

contract token{

    function transfer(address receiver, uint amount) public;
    function balanceOf(address receiver) constant public returns (uint balance);
}