pragma solidity ^0.4.23;

// * https://dice1.win - fair games that pay Ether. Version 1.
//
// * Ethereum smart contract, deployed at 0x5116A7B3FFF82C0FFaB4A49aBaE659aBF49A3f95.

contract Dice1Win{
    using SafeMath for uint256;
    
    uint256 constant MIN_BET = 0.01 ether;
    mapping(address => uint256) public balanceOf;
    address public owner;
    
    struct Bet {
        uint256 amount;
        uint256 target;
        address gambler;
    }
    
    uint256 public times = 1;
    uint256 public totalBig ;
    uint256 public totalSmall ;
    
    Bet[] public big ;
    Bet[] public small ;
    
    
    event placeBetEvent(uint256 totalCount);
    event settleBetEvent(uint256 random, uint256 times);
    event FailedPayment(address indexed beneficiary, uint256 amount);
    event Payment(address indexed beneficiary, uint256 amount);
    
    
    function placeBet(uint256 _target) external payable {
        require (msg.value >= MIN_BET);
        
        if(_target ==1){
            big.push(
                Bet({
                    amount : msg.value,
                    target : 1,
                    gambler: msg.sender
                })
            );
            totalBig = totalBig.add(msg.value);
        }
        
        if(_target ==0){
            small.push(
                Bet({
                    amount : msg.value,
                    target : 0,
                    gambler: msg.sender
                })
            );
            totalSmall = totalSmall.add(msg.value);
        }
        
        uint256 totalCount = big.length.add(small.length);
        
        if(totalCount >= 20){
            settleBet();
        }
        
        emit placeBetEvent(totalCount);
        
    }
    
    
    function getInfo(uint256 _uint) view public returns(uint256){
        if(_uint ==1){
            return big.length;
        }
        
        if(_uint ==0){
            return small.length;
        }
        
    }
    
    
    
    function settleBet() private {
        
        times += 1;
        
        if(totalSmall == 0 || totalBig==0){
            for(uint256 i=0;i<big.length;i++){
                balanceOf[big[i].gambler] = balanceOf[big[i].gambler].add(big[i].amount);
            }
            for( i=0;i<small.length;i++){
                balanceOf[small[i].gambler] = balanceOf[small[i].gambler].add(small[i].amount);
            }
            emit settleBetEvent(100, times);
        }else{
            
            uint _random = random();
            if(_random >=50){
                for( i=0;i<big.length;i++){
                    balanceOf[big[i].gambler] = balanceOf[big[i].gambler].add(big[i].amount * odds(1)/10000);
                }
            }else{
                for( i=0;i<small.length;i++){
                    balanceOf[small[i].gambler] = balanceOf[small[i].gambler].add(small[i].amount * odds(0) / 10000);
                }
            }
            balanceOf[owner] = balanceOf[owner].add((totalSmall + totalBig)  * 1/100);
            emit settleBetEvent(_random, times);
        }
        
        clean();
        
        
    }
    
    function odds(uint256 _target) view public returns(uint256){
        
        if(totalSmall == 0 || totalBig == 0){
            return 0;
        }
        
        if(_target == 1){
            return 10000*(totalSmall.add(totalBig)) / totalBig * 99/100;
        }
        
        if(_target == 0){
            return 10000*(totalSmall.add(totalBig)) / totalSmall * 99/100;
        }

    }
    
    function withdrawFunds(uint256 withdrawAmount) public  {
        require (balanceOf[msg.sender] >= withdrawAmount);
        require (withdrawAmount >= 0);
        
        if (msg.sender.send(withdrawAmount)) {
            emit Payment(msg.sender, withdrawAmount);
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(withdrawAmount);
        } else {
            emit FailedPayment(msg.sender, withdrawAmount);
        }
        
    }
    
    
    
    
    function random() private view returns(uint256){
        
        if(big.length >0){
            address addr = big[big.length-1].gambler;  
        }else{
             addr = msg.sender; 
        }

        uint256 random = uint(keccak256(now, addr, (totalSmall + totalSmall))) % 100;
        
        if(small.length >0){
             addr = small[big.length-1].gambler;  
        }else{
             addr = msg.sender; 
        }
        
        uint256 random2 = uint(keccak256(now, addr, random)) % 100;
        
        return random2;
    }
    
    
    function clean() private{
        delete totalBig;
        delete totalSmall;
        delete big;
        delete small;
    }
    
    
    constructor() public {
        owner = msg.sender;
    }

}



library SafeMath {
    int256 constant private INT256_MIN = -2**255;

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function mul(int256 a, int256 b) internal pure returns (int256) {
        if (a == 0) {
            return 0;
        }
        require(!(a == -1 && b == INT256_MIN));
        int256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0);
        require(!(b == -1 && a == INT256_MIN)); 
        int256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}