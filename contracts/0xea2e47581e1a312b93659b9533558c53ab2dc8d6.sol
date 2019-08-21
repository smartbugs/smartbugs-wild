pragma solidity ^0.4.25 ;

interface IERC20Token {                                     
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function decimals() external returns (uint256);
}

contract LupeMining {
    
    using SafeMath for uint ; 
    using Limit for uint ; 
    
    IERC20Token public tokenContract ;
    address public owner;
    
    mapping(bytes32 => bytes32) public solutionForChallenge ; 
    
    uint public blockNumber  = 0 ; 
    
    uint public LUPX_BLOCKS_PER_EPOCH_TARGET = 5 ;
    uint public LUPX_BLOCK_TIME = 600 ; 
    uint public ETHER_BLOCK_TIME = 15 ; 
    uint public halvingBlockAmount = 25000 ; 
    
    uint public ETHER_BLOCKS_PER_EPOCH_TARGET = (LUPX_BLOCK_TIME.div(ETHER_BLOCK_TIME)).mul(LUPX_BLOCKS_PER_EPOCH_TARGET) ;
    
    uint public MIN_TARGET = 2 ** 16 ; 
    uint public MAX_TARGET = 2 ** 252 ; 
    
    uint public target  = MAX_TARGET.div(10**4) ; 
    bytes32 public challenge ; 
    
    address public lastRewardedMiner ; 
    uint public lastRewardAmount ; 
    uint public lastRewardETHBlock ; 
    
    uint public ETHBlockDiffAdjusted  = block.number ; 
    
    uint public minedTokensAmount  = 0 ; 
    
    uint public blockReward = 200 ; 
    
    bool public locked = false ; 
    
    event newBlock(address miner, uint reward) ; 
    
    constructor(IERC20Token _tokenContract) public {
        tokenContract = _tokenContract ;
        owner = msg.sender ; 
        
        newBlockChallenge() ; 
    }
    
    function lockContract() public onlyOwner returns (bool success) {
        locked = true ; 
        return true ; 
    }
    
    function mine(uint256 nonce, bytes32 challenge_digest) public returns (bool success) {
        require(!locked) ; 
        require(tokenContract.balanceOf(address(this)) > blockReward) ;
        
        bytes32 digest =  keccak256(challenge, msg.sender, nonce); 
        
        if (digest != challenge_digest) {
            revert() ; 
        }
        
        if (uint256(challenge_digest) > target) {
            revert() ; 
        }
        

        bytes32 solution = solutionForChallenge[challenge];
        solutionForChallenge[challenge] = digest;
        if(solution != 0x0) {
            revert();
        }
        
        minedTokensAmount = minedTokensAmount.add(blockReward) ; 
        
        lastRewardedMiner = msg.sender ; 
        lastRewardAmount = blockReward ; 
        lastRewardETHBlock = block.number ; 
        
        emit newBlock(msg.sender, blockReward) ; 
        
        tokenContract.transfer(msg.sender, blockReward * 10 ** tokenContract.decimals()) ; 
        
        newBlockChallenge() ; 
        
        return true ; 
    }

    function newBlockChallenge() internal {
        blockNumber = blockNumber.add(1) ; 
        
        if (blockNumber % LUPX_BLOCKS_PER_EPOCH_TARGET == 0) {
            adjustDifficulty() ; 
        }
        
        if (blockNumber % halvingBlockAmount == 0) {
            blockReward = blockReward.div(2) ; 
        }
        
        challenge = blockhash(block.number - 1) ; 
    }
    
    function adjustDifficulty() internal {
        uint blocksSinceLastBlock = block.number - ETHBlockDiffAdjusted ; 
          
        if (blocksSinceLastBlock < ETHER_BLOCKS_PER_EPOCH_TARGET) { 
            
            uint excs_percentage = (ETHER_BLOCKS_PER_EPOCH_TARGET.mul(100)).div(blocksSinceLastBlock) ;

            uint excs_percentage_extra = excs_percentage.sub(100).limitLessThan(1000) ;  
          
            target = target.sub(target.div(2000).mul(excs_percentage_extra)) ;      
        }
        
        else {      
            
            uint short_percentage = (blocksSinceLastBlock.mul(100)).div(ETHER_BLOCKS_PER_EPOCH_TARGET) ;

            uint short_percentage_extra = short_percentage.sub(100).limitLessThan(1000) ;

            target = target.add(target.div(2000).mul(short_percentage_extra)) ;
        }
        
        
        ETHBlockDiffAdjusted = block.number ; 
        
        
        if(target < MIN_TARGET) {target = MIN_TARGET ;}

        if(target > MAX_TARGET) {target = MAX_TARGET ;}
    }
    
    function getChallenge() public view returns (bytes32) {
        return challenge;
    }

     function getMiningDifficulty() public view returns (uint) {
        return MAX_TARGET.div(target);
    }

    function getMiningTarget() public view returns (uint) {
       return target;
   }
   
   function testHASH(uint256 nonce, bytes32 challenge_digest) public view returns (bool success) {
        bytes32 digest =  keccak256(challenge, msg.sender, nonce); 
        
        if (digest != challenge_digest) {
            revert() ; 
        }
        
        if (uint256(challenge_digest) > target) {
            revert() ; 
        }
        
        return true ; 
   }
   
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
    
    function destroyOwnership() public onlyOwner {
        owner = address(0) ; 
    }
    
    function stopMining() public onlyOwner {
        tokenContract.transfer(msg.sender, tokenContract.balanceOf(address(this))) ;
        msg.sender.transfer(address(this).balance) ;  
    }
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

library Limit {
    function limitLessThan(uint a, uint b) internal pure returns (uint c) {

        if(a > b) {
            return b;
        } else {
            return a;
        }
    }
}