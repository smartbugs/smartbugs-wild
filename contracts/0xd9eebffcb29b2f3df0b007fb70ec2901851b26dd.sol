pragma solidity ^0.4.24;

/*
    _______       __    __     ________      __  
   / ____(_)___ _/ /_  / /_   / ____/ /_  __/ /_ 
  / /_  / / __ `/ __ \/ __/  / /   / / / / / __ \
 / __/ / / /_/ / / / / /_   / /___/ / /_/ / /_/ /
/_/   /_/\__, /_/ /_/\__/   \____/_/\__,_/_.___/ 
        /____/                                   


Fight Club

https://ethfightclub.com

The Decentralized Ranking Site where YOU choose the winner

Promoters can add any two fighters for a fee

Enter the fighters names and image link

Image link should be in a format like this:   https://i.etsystatic.com/14392680/r/il/84f51c/1325571098/il_570xN.1325571098_p21w.jpg

Players can vote on either fighter

The winning fighter is the one who has the most votes when time runs out

The players who voted on the winning fighter receive 
a portion of 20% of all vote fees for the winning fighter

Promoters receive 50% of all vote fees

*/


contract fightclub {

    event newvote(
        uint rankid
    );

    mapping (uint => address[]) public voter1Add;
    mapping (uint => address[]) public voter2Add;


    //mapping (uint => string) categories;
    mapping (uint => string) public fighter1Name;  
    mapping (uint => string) public fighter2Name;  
    mapping (uint => string) public fighter1Image;  
    mapping (uint => string) public fighter2Image; 
    mapping (uint => uint) public fightEndTime; 
    mapping (uint => bool) public fightActive;

    mapping(uint => uint) public voteCount1;
    mapping(uint => uint) public voteCount2;

    mapping(uint => address) public promoter;      //map promoter address to fight
    mapping(uint => string) public promoterName;   //map promoter name to fight

    mapping(address => uint) public accounts;      //player and promoter accounts for withdrawal
    mapping(address => string) public playerName;      //players can enter an optional nickname
    mapping(uint => uint) public fightPool;        //Reward Pool for each fight
 

    uint public votePrice = 0.001 ether;
    uint public promotePrice = 0.05 ether;
    
    uint public ownerFeeRate = 15;
    uint public promoterFeeRate = 15;
    uint public playerFeeRate = 70;

    uint public fightLength = 17700; //3 days

    uint public fightCount = 0;
    
    uint public ownerAccount = 0;

    address owner;
    
    constructor() public {
        owner = msg.sender;
    }

    function vote(uint fightID, uint fighter) public payable
    {

        require(msg.value >= votePrice);
        require(fighter == 1 || fighter == 2);
        require(fightActive[fightID]);
        uint ownerFee;
        uint authorFee;
        uint fightPoolFee;

        ownerFee = SafeMath.div(SafeMath.mul(msg.value,ownerFeeRate),100);
        authorFee = SafeMath.div(SafeMath.mul(msg.value,promoterFeeRate),100);
        fightPoolFee = SafeMath.div(SafeMath.mul(msg.value,playerFeeRate),100);

        accounts[owner] = SafeMath.add(accounts[owner], ownerFee);
        accounts[promoter[fightID]] = SafeMath.add(accounts[promoter[fightID]], authorFee);
        fightPool[fightID] = SafeMath.add(fightPool[fightID], fightPoolFee);

        if (fighter == 1) {
            //vote1[fightID].push(1);
            //voter1[fightID][voteCount1] = 1;//msg.sender;
            voter1Add[fightID].push(msg.sender);
        } else {
            //vote2[fightID].push(1);
            //voter2[fightID][voter2[fightID].length] = msg.sender;
            voter2Add[fightID].push(msg.sender);
        }
    }

    function promoteFight(string _fighter1Name, string _fighter2Name, string _fighter1Image, string _fighter2Image) public payable
    {
        require(msg.value >= promotePrice || msg.sender == owner);
        fightActive[fightCount] = true;
        uint ownerFee;
        ownerFee = msg.value;
        accounts[owner] = SafeMath.add(accounts[owner], ownerFee);

        promoter[fightCount] = msg.sender;

        fightEndTime[fightCount] = block.number + fightLength;

        fighter1Name[fightCount] = _fighter1Name;
        fighter2Name[fightCount] = _fighter2Name;

        fighter1Image[fightCount] = _fighter1Image;
        fighter2Image[fightCount] = _fighter2Image;

        fightCount += 1;


    }

    function endFight(uint fightID) public 
    {
        require(block.number > fightEndTime[fightID] || msg.sender == owner);
        require(fightActive[fightID]);
        uint voterAmount;
        uint payoutRemaining;

        fightActive[fightID] = false;


        //determine winner and distribute funds
        if (voter1Add[fightID].length > voter2Add[fightID].length)
        {
            payoutRemaining = fightPool[fightID];
            voterAmount = SafeMath.div(fightPool[fightID],voter1Add[fightID].length);
            for (uint i1 = 0; i1 < voter1Add[fightID].length; i1++)
                {
                    if (payoutRemaining >= voterAmount)
                    {
                        accounts[voter1Add[fightID][i1]] = SafeMath.add(accounts[voter1Add[fightID][i1]], voterAmount);
                        payoutRemaining = SafeMath.sub(payoutRemaining,voterAmount);
                    } else {
                        accounts[voter1Add[fightID][i1]] = SafeMath.add(accounts[voter1Add[fightID][i1]], payoutRemaining);
                    }
                    
                }
            
        }

        if (voter1Add[fightID].length < voter2Add[fightID].length)
        {
            payoutRemaining = fightPool[fightID];
            voterAmount = SafeMath.div(fightPool[fightID],voter2Add[fightID].length);
            for (uint i2 = 0; i2 < voter2Add[fightID].length; i2++)
                {
                    if (payoutRemaining >= voterAmount)
                    {
                        accounts[voter2Add[fightID][i2]] = SafeMath.add(accounts[voter2Add[fightID][i2]], voterAmount);
                        payoutRemaining = SafeMath.sub(payoutRemaining,voterAmount);
                    } else {
                        accounts[voter2Add[fightID][i2]] = SafeMath.add(accounts[voter2Add[fightID][i2]], payoutRemaining);
                    }
                    
                }
        }

        if (voter1Add[fightID].length == voter2Add[fightID].length)
        {
            payoutRemaining = fightPool[fightID];
            voterAmount = SafeMath.div(fightPool[fightID],voter1Add[fightID].length + voter2Add[fightID].length);
            for (uint i3 = 0; i3 < voter1Add[fightID].length; i3++)
                {
                    if (payoutRemaining >= voterAmount)
                    {
                        accounts[voter1Add[fightID][i3]] = SafeMath.add(accounts[voter1Add[fightID][i3]], voterAmount);
                        accounts[voter2Add[fightID][i3]] = SafeMath.add(accounts[voter2Add[fightID][i3]], voterAmount);
                        payoutRemaining = SafeMath.sub(payoutRemaining,voterAmount + voterAmount);
                    }
                    
                }

        }

        

    }


    function ownerWithdraw() 
    {
        require(msg.sender == owner);
        uint tempAmount = ownerAccount;
        ownerAccount = 0;
        owner.transfer(tempAmount);
    }

    function withdraw() 
    {
        uint tempAmount = accounts[msg.sender];
        accounts[msg.sender] = 0;
        msg.sender.transfer(tempAmount);
    }

    function getFightData(uint fightID) public view returns(string, string, string, string, uint, uint, uint)
    {
        return(fighter1Name[fightID], fighter2Name[fightID], fighter1Image[fightID], fighter2Image[fightID], voter1Add[fightID].length, voter2Add[fightID].length, fightEndTime[fightID]);
    }

    function setPrices(uint _votePrice, uint _promotePrice) public 
    {
        require(msg.sender == owner);
        votePrice = _votePrice;
        promotePrice = _promotePrice;

    }

     function setFightLength(uint _fightLength) public 
    {
        require(msg.sender == owner);
        fightLength = _fightLength;

    }

    function setRates(uint _ownerRate, uint _promoterRate, uint _playerRate) public 
    {
        require(msg.sender == owner);
        require(_ownerRate + _promoterRate + _playerRate == 100);
        ownerFeeRate = _ownerRate;
        promoterFeeRate = _promoterRate;
        playerFeeRate = _playerRate;

    }

    function setImages(uint _fightID, string _fighter1Image, string _fighter2Image) public 
    {
        require(msg.sender == promoter[_fightID]);
        fighter1Image[fightCount] = _fighter1Image;
        fighter2Image[fightCount] = _fighter2Image;

    }


}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
 
  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
 
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }
 
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}