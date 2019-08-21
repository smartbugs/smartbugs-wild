pragma solidity ^0.4.24;
 

//
//                       .#########'
//                    .###############+
//                  ,####################
//                `#######################+
//               ;##########################
//              #############################.
//             ###############################,
//           +##################,    ###########`
//          .###################     .###########
//         ##############,          .###########+
//         #############`            .############`
//         ###########+                ############
//        ###########;                  ###########
//        ##########'                    ###########
//       '##########    '#.        `,     ##########
//       ##########    ####'      ####.   :#########;
//      `#########'   :#####;    ######    ##########
//      :#########    #######:  #######    :#########
//      +#########    :#######.########     #########`
//      #########;     ###############'     #########:
//      #########       #############+      '########'
//      #########        ############       :#########
//      #########         ##########        ,#########
//      #########         :########         ,#########
//      #########        ,##########        ,#########
//      #########       ,############       :########+
//      #########      .#############+      '########'
//      #########:    `###############'     #########,
//      +########+    ;#######`;#######     #########
//      ,#########    '######`  '######    :#########
//       #########;   .#####`    '#####    ##########
//       ##########    '###`      +###    :#########:
//       ;#########+     `                ##########
//        ##########,                    ###########
//         ###########;                ############
//         +############             .############`
//          ###########+           ,#############;
//          `###########     ;++#################
//           :##########,    ###################
//            '###########.'###################
//             +##############################
//              '############################`
//               .##########################
//                 #######################:
//                   ###################+
//                     +##############:
//                        :#######+`
//
//
//
// Play0x.com (The ONLY gaming platform for all ERC20 Tokens)
// -------------------------------------------------------------------------------------------------------
// * Multiple types of game platforms
// * Build your own game zone - Not only playing games, but also allowing other players to join your game.
// * Support all ERC20 tokens.
//
//
//
// 0xC Token (Contract address : 0x60d8234a662651e586173c17eb45ca9833a7aa6c)
// -------------------------------------------------------------------------------------------------------
// * 0xC Token is an ERC20 Token specifically for digital entertainment.
// * No ICO and private sales,fair access.
// * There will be hundreds of games using 0xC as a game token.
// * Token holders can permanently get ETH's profit sharing.
//

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

/**
* @title ERC20 interface
* @dev see https://github.com/ethereum/EIPs/issues/20
*/
contract ERC20 {
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address owner, address spender) public constant returns (uint256);
    function balanceOf(address who) public constant returns  (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function transfer(address _to, uint256 _value) public;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Play0x_LottoBall {

    using SafeMath for uint256;
    using SafeMath for uint128;
    using SafeMath for uint40;
    using SafeMath for uint8;

    uint public jackpotSize;

    uint public MIN_BET;
    uint public MAX_BET;
    uint public MAX_AMOUNT;
    uint constant MAX_MODULO = 15;

    //Adjustable max bet profit.
    uint public maxProfit; 

    //Fee percentage
    uint8 public platformFeePercentage = 15;
    uint8 public jackpotFeePercentage = 5;
    uint8 public ERC20rewardMultiple = 5;
    
    //0:ether 1:token
    uint8 public currencyType = 0;

    //Bets can be refunded via invoking refundBet.
    uint constant BetExpirationBlocks = 250;

    //Funds that are locked in potentially winning bets.
    uint public lockedInBets; 

    //Standard contract ownership transfer.
    address public owner;
    address private nextOwner; 
    address public secretSigner;
    address public refunder; 

    //The address corresponding to a private key used to sign placeBet commits. 
    address public ERC20ContractAddres;
    
    address constant DUMMY_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    //Single bet.
    struct Bet {
        //Amount in wei.
        uint amount;
        //place tx Block number.
        uint40 placeBlockNumber;
        // Address of a gambler.
        address gambler;  
        // Game mode.
        uint8 machineMode; 
        // Number of draws
        uint8 rotateTime;
    }

    //Mapping from commits
    mapping (uint => Bet) public bets;

    //Mapping from signer
    mapping(address => bool) public signerList;
    
    //Mapping from withdrawal
    mapping(uint8 => uint32) public withdrawalMode;
     
    //Admin Payment
    event ToManagerPayment(address indexed beneficiary, uint amount);
    event ToManagerFailedPayment(address indexed beneficiary, uint amount);
    event ToOwnerPayment(address indexed beneficiary, uint amount);
    event ToOwnerFailedPayment(address indexed beneficiary, uint amount);

    //Bet Payment
    event Payment(address indexed beneficiary, uint amount);
    event AllFundsPayment(address indexed beneficiary, uint amount);
    event AllTokenPayment(address indexed beneficiary, uint amount);
    event FailedPayment(address indexed beneficiary, uint amount);
    event TokenPayment(address indexed beneficiary, uint amount);

    //JACKPOT
    event JackpotBouns(address indexed beneficiary, uint amount);

    // Events that are issued to make statistic recovery easier.
    event PlaceBetLog(address indexed player, uint amount,uint8 rotateTime,uint commit);

    //Play0x_LottoBall_Event
    event BetRelatedData(
        address indexed player,
        uint playerBetAmount,
        uint playerGetAmount,
        bytes32 entropy, 
        uint8 rotateTime
    );
    
    //Refund_Event
    event RefundLog(address indexed player, uint commit, uint amount);
 
    // Constructor. Deliberately does not take any parameters.
    constructor () public {
        owner = msg.sender;
        secretSigner = DUMMY_ADDRESS; 
        ERC20ContractAddres = DUMMY_ADDRESS; 
        refunder = DUMMY_ADDRESS; 
    }

    // Standard modifier on methods invokable only by contract owner.
    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }
    
    modifier onlyRefunder {
        require (msg.sender == refunder);
        _;
    } 
    
    modifier onlySigner {
        require (signerList[msg.sender] == true); 
        _;
    }
    
    //Init Parameter.
    function initialParameter(
        // address _manager,
        address _secretSigner,
        address _erc20tokenAddress ,
        address _refunder,
        
        uint _MIN_BET,
        uint _MAX_BET,
        uint _maxProfit, 
        uint _MAX_AMOUNT, 
        
        uint8 _platformFeePercentage,
        uint8 _jackpotFeePercentage,
        uint8 _ERC20rewardMultiple,
        uint8 _currencyType,
        
        address[] _signerList,
        uint32[] _withdrawalMode)public onlyOwner{
            
        secretSigner = _secretSigner;
        ERC20ContractAddres = _erc20tokenAddress;
        refunder = _refunder; 
        
        MIN_BET = _MIN_BET;
        MAX_BET = _MAX_BET;
        maxProfit = _maxProfit; 
        MAX_AMOUNT = _MAX_AMOUNT;
        
        platformFeePercentage = _platformFeePercentage;
        jackpotFeePercentage = _jackpotFeePercentage;
        ERC20rewardMultiple = _ERC20rewardMultiple;
        currencyType = _currencyType;
        
        createSignerList(_signerList);
        createWithdrawalMode(_withdrawalMode); 
    }
 
    // Standard contract ownership transfer implementation,
    function approveNextOwner(address _nextOwner) public onlyOwner {
        require (_nextOwner != owner);
        nextOwner = _nextOwner;
    }

    function acceptNextOwner() public {
        require (msg.sender == nextOwner);
        owner = nextOwner;
    }

    // Fallback function deliberately left empty.
    function () public payable {
    }
   
    //Creat SignerList.
    function createSignerList(address[] _signerList)private onlyOwner  {
        for (uint i=0; i<_signerList.length; i++) {
            address newSigner = _signerList[i];
            signerList[newSigner] = true; 
        } 
    }
     
    //Creat WithdrawalMode.
    function createWithdrawalMode(uint32[] _withdrawalMode)private onlyOwner {
        for (uint8 i=0; i<_withdrawalMode.length; i++) {
            uint32 newWithdrawalMode = _withdrawalMode[i];
            uint8 mode = i + 1;
            withdrawalMode[mode] = newWithdrawalMode;
        } 
    }
     
    //Set SecretSigner.
    function setSecretSigner(address _secretSigner) external onlyOwner {
        secretSigner = _secretSigner;
    } 
    
    //Set settle signer.
    function setSigner(address signer,bool isActive )external onlyOwner{
        signerList[signer] = isActive; 
    } 
    
    //Set Refunder.
    function setRefunder(address _refunder) external onlyOwner {
        refunder = _refunder;
    } 
     
    //Set tokenAddress.
    function setTokenAddress(address _tokenAddress) external onlyOwner {
        ERC20ContractAddres = _tokenAddress;
    }
 
    // Change max bet reward. Setting this to zero effectively disables betting.
    function setMaxProfit(uint _maxProfit) external onlyOwner {
        require (_maxProfit < MAX_AMOUNT && _maxProfit > 0);
        maxProfit = _maxProfit;
    }

    // Funds withdrawal.
    function withdrawFunds(address beneficiary, uint withdrawAmount) external onlyOwner {
        require (withdrawAmount <= address(this).balance && withdrawAmount > 0);

        uint safetyAmount = jackpotSize.add(lockedInBets).add(withdrawAmount);
        safetyAmount = safetyAmount.add(withdrawAmount);

        require (safetyAmount <= address(this).balance);
        sendFunds(beneficiary, withdrawAmount );
    }

    // Token withdrawal.
    function withdrawToken(address beneficiary, uint withdrawAmount) external onlyOwner {
        require (withdrawAmount <= ERC20(ERC20ContractAddres).balanceOf(address(this)));

        uint safetyAmount = jackpotSize.add(lockedInBets);
        safetyAmount = safetyAmount.add(withdrawAmount);
        require (safetyAmount <= ERC20(ERC20ContractAddres).balanceOf(address(this)));

         ERC20(ERC20ContractAddres).transfer(beneficiary, withdrawAmount);
         emit TokenPayment(beneficiary, withdrawAmount);
    }

    //Recovery of funds
    function withdrawAllFunds(address beneficiary) external onlyOwner {
        if (beneficiary.send(address(this).balance)) {
            lockedInBets = 0;
            jackpotSize = 0;
            emit AllFundsPayment(beneficiary, address(this).balance);
        } else {
            emit FailedPayment(beneficiary, address(this).balance);
        }
    }

    //Recovery of Token funds
    function withdrawAlltokenFunds(address beneficiary) external onlyOwner {
        ERC20(ERC20ContractAddres).transfer(beneficiary, ERC20(ERC20ContractAddres).balanceOf(address(this)));
        lockedInBets = 0;
        jackpotSize = 0;
        emit AllTokenPayment(beneficiary, ERC20(ERC20ContractAddres).balanceOf(address(this)));
    }

    // Contract may be destroyed only when there are no ongoing bets,
    // either settled or refunded. All funds are transferred to contract owner.
    function kill() external onlyOwner {
        require (lockedInBets == 0); 
        selfdestruct(owner);
    }

    function getContractInformation()public view returns(
        uint _jackpotSize, 
        uint _MIN_BET,
        uint _MAX_BET,
        uint _MAX_AMOUNT,
        uint8 _platformFeePercentage,
        uint8 _jackpotFeePercentage,
        uint _maxProfit, 
        uint _lockedInBets){

        _jackpotSize = jackpotSize; 
        _MIN_BET = MIN_BET;
        _MAX_BET = MAX_BET;
        _MAX_AMOUNT = MAX_AMOUNT;
        _platformFeePercentage = platformFeePercentage;
        _jackpotFeePercentage = jackpotFeePercentage;
        _maxProfit = maxProfit; 
        _lockedInBets = lockedInBets;  
    }

    function getContractAddress()public view returns(
        address _owner, 
        address _ERC20ContractAddres,
        address _secretSigner,
        address _refunder ){

        _owner = owner; 
        _ERC20ContractAddres = ERC20ContractAddres;
        _secretSigner = secretSigner;  
        _refunder = refunder; 
    } 
 
    //Bet by ether: Commits are signed with a block limit to ensure that they are used at most once.
    function placeBet(uint8 _rotateTime , uint8 _machineMode , uint _commitLastBlock, uint _commit, bytes32 r, bytes32 s ) external payable {
         
        // Check that the bet is in 'clean' state.
        Bet storage bet = bets[_commit];
        require (bet.gambler == address(0));
        
        //Check SecretSigner.
        bytes32 signatureHash = keccak256(abi.encodePacked(_commitLastBlock, _commit));
        require (secretSigner == ecrecover(signatureHash, 27, r, s));
        
        //Check rotateTime ,machineMode and commitLastBlock.
        require (_rotateTime > 0 && _rotateTime <= 20); 
        
        //_machineMode: 1~15
        require (_machineMode > 0 && _machineMode <= MAX_MODULO);
        
        require (block.number < _commitLastBlock );
         
        lockedInBets = lockedInBets.add( getPossibleWinPrize(withdrawalMode[_machineMode],msg.value) );
        
        //Check the highest profit
        require (getPossibleWinPrize(withdrawalMode[_machineMode],msg.value) <= maxProfit && getPossibleWinPrize(withdrawalMode[_machineMode],msg.value) > 0);
        require (lockedInBets.add(jackpotSize) <= address(this).balance);
 
        //Amount should be within range
        require (msg.value >= MIN_BET && msg.value <= MAX_BET);
        
        emit PlaceBetLog(msg.sender, msg.value,_rotateTime,_commit);
          
        // Store bet parameters on blockchain.
        bet.amount = msg.value;
        bet.placeBlockNumber = uint40(block.number);
        bet.gambler = msg.sender;  
        bet.machineMode = uint8(_machineMode);  
        bet.rotateTime = uint8(_rotateTime);  
    }

    function placeTokenBet(uint8 _rotateTime , uint8 _machineMode , uint _commitLastBlock, uint _commit, bytes32 r, bytes32 s, uint _amount, address _playerAddress) external onlySigner {
        
        // Check that the bet is in 'clean' state.
        Bet storage bet = bets[_commit];
        require (bet.gambler == address(0));
        
        //Check SecretSigner.
        bytes32 signatureHash = keccak256(abi.encodePacked(_commitLastBlock, _commit));
        require (secretSigner == ecrecover(signatureHash, 27, r, s));
        
        //Check rotateTime ,machineMode and commitLastBlock.
        require (_rotateTime > 0 && _rotateTime <= 20); 
         
        //_machineMode: 1~15
        require (_machineMode > 0 && _machineMode <= MAX_MODULO); 
        
        require (block.number < _commitLastBlock ); 
        
        //Token lockedInBets 
        lockedInBets = lockedInBets.add(getPossibleWinPrize(withdrawalMode[_machineMode],_amount));
        
        //Check the highest profit
        require (getPossibleWinPrize(withdrawalMode[_machineMode],_amount) <= maxProfit && getPossibleWinPrize(withdrawalMode[_machineMode],_amount) > 0);
        require (lockedInBets.add(jackpotSize) <= ERC20(ERC20ContractAddres).balanceOf(address(this)));
  
        //Amount should be within range
        require (_amount >= MIN_BET && _amount <= MAX_BET);
        
        emit PlaceBetLog(_playerAddress, _amount, _rotateTime,_commit);
        
        // Store bet parameters on blockchain.
        bet.amount = _amount;
        bet.placeBlockNumber = uint40(block.number);
        bet.gambler = _playerAddress;  
        bet.machineMode = _machineMode;
        bet.rotateTime = _rotateTime;
    }
 
    function settleBet(bytes32 luckySeed,uint reveal, bytes32 blockHash ) external onlySigner{ 
          
        // "commit" for bet settlement can only be obtained by hashing a "reveal".
        uint commit = uint(keccak256(abi.encodePacked(reveal)));

        // Fetch bet parameters into local variables (to save gas).
        Bet storage bet = bets[commit];
        
        // Check that bet is in 'active' state and check that bet has not expired yet.
        require (bet.amount != 0); 
        require (bet.rotateTime > 0 && bet.rotateTime <= 20); 
        require (bet.machineMode > 0 && bet.machineMode <= MAX_MODULO); 
        require (block.number > bet.placeBlockNumber);
        require (block.number <= bet.placeBlockNumber.add(BetExpirationBlocks));
        require (blockhash(bet.placeBlockNumber) == blockHash);
 
        //check possibleWinAmount   
        require (getPossibleWinPrize(withdrawalMode[bet.machineMode],bet.amount) < maxProfit); 
         
        require (luckySeed > 0); 

        //The RNG - combine "reveal" and blockhash of LuckySeed using Keccak256.
        bytes32 _entropy = keccak256(
            abi.encodePacked(
                uint(
                    keccak256(
                        abi.encodePacked(
                            reveal,
                            luckySeed
                        )
                    )
                ),
                blockHash
            )
        );
        
        //Player profit
        uint totalAmount = 0;
        
        //Player Token profit
        uint totalTokenAmount = 0;
        
        //Jackpot check default value
        bool isGetJackpot = false; 
        
        //Settlement record
        bytes32 tmp_entropy = _entropy; 
        
        //Billing mode
        uint8 machineMode = bet.machineMode; 
        
        for (uint8 i = 0; i < bet.rotateTime; i++) {
            
            //every round result
            bool isWinThisRound = false;
            
            //Random number of must be less than the machineMode
            assembly {   
                switch gt(machineMode,and(tmp_entropy, 0xf))
                case 1 {
                    isWinThisRound := 1
                }
            }

            if (isWinThisRound == true ){
                //bet win, get single round bonus
                totalAmount = totalAmount.add(getPossibleWinPrize(withdrawalMode[bet.machineMode],bet.amount).div(bet.rotateTime));

                //Platform fee determination:Ether Game Winning players must pay platform fees 
                totalAmount = totalAmount.sub( 
                        (
                            (
                                bet.amount.div(bet.rotateTime)
                            ).mul(platformFeePercentage)
                        ).div(1000) 
                    );
            }else if ( isWinThisRound == false && currencyType == 0 && ERC20(ERC20ContractAddres).balanceOf(address(this)) > 0){
                //Ether game lose, get token reward 
                 totalTokenAmount = totalTokenAmount.add(bet.amount.div(bet.rotateTime).mul(ERC20rewardMultiple));
            }

            //Get jackpotWin Result, only one chance to win Jackpot in each game.
            if (isGetJackpot == false){ 
                //getJackpotWinBonus
                assembly { 
                    let buf := and(tmp_entropy, 0xffff)  
                    switch buf
                    case 0xffff {
                        isGetJackpot := 1
                    }
                }
            }
            
            //This round is settled, shift settlement record.
            tmp_entropy = tmp_entropy >> 4;
        } 
         
        //Player get Jackpot 
        if (isGetJackpot == true ) { 
            emit JackpotBouns(bet.gambler,jackpotSize);
            
            totalAmount = totalAmount.add(jackpotSize);
            jackpotSize = 0; 
        } 
 
        if (currencyType == 0) {
            //Ether game
            if (totalAmount != 0 && totalAmount < maxProfit){
                sendFunds(bet.gambler, totalAmount );
            }

            //Send ERC20 Token
            if (totalTokenAmount != 0){ 
                
                if(ERC20(ERC20ContractAddres).balanceOf(address(this)) > 0){
                    ERC20(ERC20ContractAddres).transfer(bet.gambler, totalTokenAmount);
                    emit TokenPayment(bet.gambler, totalTokenAmount);
                }
            }
        }else if(currencyType == 1){
            //ERC20 game

            //Send ERC20 Token
            if (totalAmount != 0 && totalAmount < maxProfit){
                if(ERC20(ERC20ContractAddres).balanceOf(address(this)) > 0){
                    ERC20(ERC20ContractAddres).transfer(bet.gambler, totalAmount);
                    emit TokenPayment(bet.gambler, totalAmount);
                }
            }
        }

        //Unlock the bet amount, regardless of the outcome.
        lockedInBets = lockedInBets.sub(getPossibleWinPrize(withdrawalMode[bet.machineMode],bet.amount));

  
        //Save jackpotSize
        jackpotSize = jackpotSize.add(bet.amount.mul(jackpotFeePercentage).div(1000));
         
        emit BetRelatedData(
            bet.gambler,
            bet.amount,
            totalAmount,
            _entropy, 
            bet.rotateTime
        );
        
        //Move bet into 'processed' state already.
        bet.amount = 0;
    }

    function runRotateTime (Bet storage bet, bytes32 _entropy )private view returns(uint totalAmount, uint totalTokenAmount, bool isGetJackpot ) {
           
        bytes32 tmp_entropy = _entropy; 
 
        isGetJackpot = false;
        
        uint8 machineMode = bet.machineMode;
        
        for (uint8 i = 0; i < bet.rotateTime; i++) {
            
            //every round result
            bool isWinThisRound = false;
            
            //Random number of must be less than the machineMode
            assembly {   
                switch gt(machineMode,and(tmp_entropy, 0xf))
                case 1 {
                    isWinThisRound := 1
                }
            }

            if (isWinThisRound == true ){
                //bet win, get single round bonus
                totalAmount = totalAmount.add(getPossibleWinPrize(withdrawalMode[bet.machineMode],bet.amount).div(bet.rotateTime));

                //Platform fee determination:Ether Game Winning players must pay platform fees 
                totalAmount = totalAmount.sub( 
                        (
                            (
                                bet.amount.div(bet.rotateTime)
                            ).mul(platformFeePercentage)
                        ).div(1000) 
                    );
            }else if ( isWinThisRound == false && currencyType == 0 && ERC20(ERC20ContractAddres).balanceOf(address(this)) > 0){
                //Ether game lose, get token reward 
                 totalTokenAmount = totalTokenAmount.add(bet.amount.div(bet.rotateTime).mul(ERC20rewardMultiple));
            }

            //Get jackpotWin Result, only one chance to win Jackpot in each game.
            if (isGetJackpot == false){ 
                //getJackpotWinBonus
                assembly { 
                    let buf := and(tmp_entropy, 0xffff)  
                    switch buf
                    case 0xffff {
                        isGetJackpot := 1
                    }
                }
            } 
            //This round is settled, shift settlement record.
            tmp_entropy = tmp_entropy >> 4;
        } 

        if (isGetJackpot == true ) { 
            //gambler get jackpot. 
            totalAmount = totalAmount.add(jackpotSize); 
        }
    }
 
    //Get deductedBalance
    function getPossibleWinPrize(uint bonusPercentage,uint senderValue)public pure returns (uint possibleWinAmount) { 
        //Win Amount  
        possibleWinAmount = ((senderValue.mul(bonusPercentage))).div(10000);
    }
    
    //Get deductedBalance
    function getPossibleWinAmount(uint bonusPercentage,uint senderValue)public view returns (uint platformFee,uint jackpotFee,uint possibleWinAmount) {

        //Platform Fee
        uint prePlatformFee = (senderValue).mul(platformFeePercentage);
        platformFee = (prePlatformFee).div(1000);

        //Get jackpotFee
        uint preJackpotFee = (senderValue).mul(jackpotFeePercentage);
        jackpotFee = (preJackpotFee).div(1000);

        //Win Amount
        uint preUserGetAmount = senderValue.mul(bonusPercentage);
        possibleWinAmount = preUserGetAmount.div(10000);
    }

    function settleBetVerifi(bytes32 luckySeed,uint reveal,bytes32 blockHash  )external view onlySigner returns(uint totalAmount,uint totalTokenAmount,bytes32 _entropy,bool isGetJackpot ) {
        
        // "commit" for bet settlement can only be obtained by hashing a "reveal".
        uint commit = uint(keccak256(abi.encodePacked(reveal)));

        // Fetch bet parameters into local variables (to save gas).
        Bet storage bet = bets[commit];
         
        //The RNG - combine "reveal" and blockhash of LuckySeed using Keccak256.
        _entropy = keccak256(
            abi.encodePacked(
                uint(
                    keccak256(
                        abi.encodePacked(
                                reveal,
                                luckySeed
                            )
                        )
                    ),
                blockHash
            )
        );
        
        isGetJackpot = false;
        (totalAmount,totalTokenAmount,isGetJackpot) = runRotateTime( 
            bet,
            _entropy 
        ); 
    }

    // Refund transaction
    function refundBet(uint commit) external onlyRefunder{
        // Check that bet is in 'active' state.
        Bet storage bet = bets[commit];
        uint amount = bet.amount; 
        uint8 machineMode = bet.machineMode; 
        
        require (amount != 0, "Bet should be in an 'active' state");

        // Check that bet has already expired.
        require (block.number > bet.placeBlockNumber.add(BetExpirationBlocks));
  
        //Amount unlock
        lockedInBets = lockedInBets.sub(getPossibleWinPrize(withdrawalMode[machineMode],bet.amount));
 
        //Refund
        emit RefundLog(bet.gambler,commit, amount); 
        sendFunds(bet.gambler, amount );
        
        // Move bet into 'processed' state, release funds.
        bet.amount = 0;
    }

    function refundTokenBet(uint commit) external onlyRefunder{
        // Check that bet is in 'active' state.
        Bet storage bet = bets[commit];
        uint amount = bet.amount;
        uint8 machineMode = bet.machineMode; 

        require (amount != 0, "Bet should be in an 'active' state");

        // Check that bet has already expired.
        require (block.number > bet.placeBlockNumber.add(BetExpirationBlocks));
 
        //Amount unlock
        lockedInBets = lockedInBets.sub(getPossibleWinPrize(withdrawalMode[machineMode],bet.amount));

        emit RefundLog(bet.gambler,commit, amount); 
         
        //Refund
        emit TokenPayment(bet.gambler, amount);
        ERC20(ERC20ContractAddres).transfer(bet.gambler, amount);
         
        // Move bet into 'processed' state, release funds.
        bet.amount = 0;
    }

    // A helper routine to bulk clean the storage.
    function clearStorage(uint[] cleanCommits) external onlyRefunder {
        uint length = cleanCommits.length;

        for (uint i = 0; i < length; i++) {
            clearProcessedBet(cleanCommits[i]);
        }
    }

    // Helper routine to move 'processed' bets into 'clean' state.
    function clearProcessedBet(uint commit) private {
        Bet storage bet = bets[commit];

        // Do not overwrite active bets with zeros
        if (bet.amount != 0 || block.number <= bet.placeBlockNumber + BetExpirationBlocks) {
            return;
        }

        // Zero out the remaining storage
        bet.placeBlockNumber = 0;
        bet.gambler = address(0);
        bet.machineMode = 0;
        bet.rotateTime = 0; 
    }

    // Helper routine to process the payment.
    function sendFunds(address receiver, uint amount ) private {
        if (receiver.send(amount)) {
            emit Payment(receiver, amount);
        } else {
            emit FailedPayment(receiver, amount);
        }
    } 
    
    function sendFundsToOwner(address beneficiary, uint amount) external onlyOwner {
        if (beneficiary.send(amount)) {
            emit ToOwnerPayment(beneficiary, amount);
        } else {
            emit ToOwnerFailedPayment(beneficiary, amount);
        }
    }

    //Update
    function updateMIN_BET(uint _uintNumber)external onlyOwner {
         MIN_BET = _uintNumber;
    }

    function updateMAX_BET(uint _uintNumber)external onlyOwner {
         MAX_BET = _uintNumber;
    }

    function updateMAX_AMOUNT(uint _uintNumber)external onlyOwner {
         MAX_AMOUNT = _uintNumber;
    } 
    
    function updateWithdrawalMode(uint8 _mode, uint32 _modeValue) external onlyOwner{
       withdrawalMode[_mode]  = _modeValue;
    } 

    function updatePlatformFeePercentage(uint8 _platformFeePercentage ) external onlyOwner{
       platformFeePercentage = _platformFeePercentage;
    }

    function updateJackpotFeePercentage(uint8 _jackpotFeePercentage ) external onlyOwner{
       jackpotFeePercentage = _jackpotFeePercentage;
    }

    function updateERC20rewardMultiple(uint8 _ERC20rewardMultiple ) external onlyOwner{
       ERC20rewardMultiple = _ERC20rewardMultiple;
    }
    
    function updateCurrencyType(uint8 _currencyType ) external onlyOwner{
       currencyType = _currencyType;
    }
    
    function updateJackpot(uint newSize) external onlyOwner {
        require (newSize < address(this).balance && newSize > 0); 
        jackpotSize = newSize;
    }
}