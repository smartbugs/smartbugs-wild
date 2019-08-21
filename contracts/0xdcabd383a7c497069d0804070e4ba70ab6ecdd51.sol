contract BlockChainEnterprise {
    
        uint private BlockBalance = 0; //block balance (0 to BlockSize eth)
        uint private NumberOfBlockMined = 0; 
        uint private BlockReward = 0;
        uint private BlockSize =  10 ether; //a block is size 10 ETH, and with 1.2 multiplier it is paid 12 ETH
        uint private MaxDeposit = 5 ether;
        uint private multiplier = 1200; // Multiplier
        
        
        uint private fees = 0;      //Fees are just verly low : 1% !
        uint private feeFrac = 5;  //Fraction for fees in "thousandth" --> only 0.5% !!
        uint private RewardFrac = 30;  //Fraction for Reward in "thousandth"
        
        
        uint private Payout_id = 0;
        
        address private admin;
        
        function BlockChainEnterprise() {
            admin = msg.sender;
        }

        modifier onlyowner {if (msg.sender == admin) _  }

        struct Miner {
            address addr;
            uint payout;
            bool paid;
        }

        Miner[] private miners;

        //--Fallback function
        function() {
            init();
        }

        //--initiated function
        function init() private {
            uint256 new_deposit=msg.value;
            //------ Verifications on this new deposit ------
            if (new_deposit < 100 finney) { //only >0.1 eth participation accepted
                    msg.sender.send(new_deposit);
                    return;
            }
            
            if( new_deposit > MaxDeposit ){
                msg.sender.send( msg.value - MaxDeposit );
                new_deposit= MaxDeposit;
            }
            //-- enter the block ! --
            Participate(new_deposit);
        }

        function Participate(uint deposit) private {
            
            if( BlockSize  < (deposit + BlockBalance) ){ //if this new deposit is part of 2 blocks
                uint256 fragment = BlockSize - BlockBalance;
                miners.push(Miner(msg.sender, fragment*multiplier/1000 , false)); //fill the block
                miners.push(Miner(msg.sender, (deposit - fragment)*multiplier/1000  , false)); //contruct the next one
            }
            else{
                miners.push(Miner(msg.sender, deposit*multiplier/1000 , false)); // add this new miner in the block !
            }
                
            //--- UPDATING CONTRACT STATS ----
            BlockReward += (deposit * RewardFrac) / 1000; // take some to reward the winner that make the whole block mined !
            fees += (deposit * feeFrac) / 1000;          // collect small fee
            BlockBalance += (deposit * (1000 - ( feeFrac + RewardFrac ))) / 1000; //update balance

            
            //Mine the block first if possible !
            if( BlockBalance >= (BlockSize/1000*multiplier) ){// it can be mined now !
                PayMiners();
                PayWinnerMiner(msg.sender,deposit);
            }
        }


        function PayMiners() private{
            NumberOfBlockMined +=1;
            //Classic payout of all participants of the block
            while ( miners[Payout_id].payout!=0 && BlockBalance >= ( miners[Payout_id].payout )  ) {
                miners[Payout_id].addr.send(miners[Payout_id].payout); //pay the man !
                
                BlockBalance -= miners[Payout_id].payout; //update the balance
                miners[Payout_id].paid=true;
                
                Payout_id += 1;
            }
        }
        
        function  PayWinnerMiner(address winner, uint256 deposit) private{ //pay the winner accordingly to his deposit !
            //Globally, EVERYONE CAN WIN by being smart and quick.
            if(deposit >= 1 ether){ //only 1 ether, and you get it all !
                winner.send(BlockReward);
                BlockReward =0;
            }
            else{ // deposit is between 0.1 and 0.99 ether
                uint256 pcent = deposit / 10 finney;
                winner.send(BlockReward*pcent/100);
                BlockReward -= BlockReward*pcent/100;
            }
        }
    

    //---Contract management functions
    function ChangeOwnership(address _owner) onlyowner {
        admin = _owner;
    }
    
    
    function CollectAllFees() onlyowner {
        if (fees == 0) throw;
        admin.send(fees);
        fees = 0;
    }
    
    function GetAndReduceFeesByFraction(uint p) onlyowner {
        if (fees == 0) feeFrac=feeFrac*80/100; //Reduce fees.
        admin.send(fees / 1000 * p);//send a percent of fees
        fees -= fees / 1000 * p;
    }
        

//---Contract informations


function WatchBalance() constant returns(uint TotalBalance, string info) {
    TotalBalance = BlockBalance /  1 finney;
    info ='Balance in finney';
}

function WatchBlockSizeInEther() constant returns(uint BlockSizeInEther, string info) {
    BlockSizeInEther = BlockSize / 1 ether;
    info ='Balance in ether';
}
function WatchNextBlockReward() constant returns(uint Reward, string info) {
    Reward = BlockReward / 1 finney;
    info ='Current reward collected. The reward when a block is mined is always BlockSize*RewardPercentage/100';
}

function NumberOfMiners() constant returns(uint NumberOfMiners, string info) {
    NumberOfMiners = miners.length;
    info ='Number of participations since the beginning of this wonderful blockchain';
}

function WatchCurrentMultiplier() constant returns(uint Mult, string info) {
    Mult = multiplier;
    info ='Current multiplier';
}
function NumberOfBlockAlreadyMined() constant returns(uint NumberOfBlockMinedAlready, string info) {
    NumberOfBlockMinedAlready = NumberOfBlockMined;
    info ='A block mined is a payout of size BlockSize, multiply this number and you get the sum of all payouts.';
}
function AmountToForgeTheNextBlock() constant returns(uint ToDeposit, string info) {
    ToDeposit = ( ( (BlockSize/1000*multiplier) - BlockBalance)*(1000 - ( feeFrac + RewardFrac ))/1000) / 1 finney;
    info ='This amount in finney in finney required to complete the current block, and to MINE it (trigger the payout).';
}
function PlayerInfo(uint id) constant returns(address Address, uint Payout, bool UserPaid) {
    if (id <= miners.length) {
        Address = miners[id].addr;
        Payout = (miners[id].payout) / 1 finney;
        UserPaid=miners[id].paid;
    }
}

function WatchCollectedFeesInSzabo() constant returns(uint CollectedFees) {
    CollectedFees = fees / 1 szabo;
}

function NumberOfCurrentBlockMiners() constant returns(uint QueueSize, string info) {
    QueueSize = miners.length - Payout_id;
    info ='Number of participations in the current block.';
}


}