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
* @dev Math operations with safety checks that throw on error
*/
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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

/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control 
* functions, this simplifies the implementation of "user permissions". 
*/ 
contract Ownable {
    address public owner;

/** 
* @dev The Ownable constructor sets the original `owner` of the contract to the sender
* account.
*/
    constructor() public {
        owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner, "only for owner");
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

//Main contract
contract ShareholderDividend is Ownable{
    using SafeMath for uint256;
    bool public IsWithdrawActive = true;
    
    //for Shareholder banlance record
    mapping(address => uint256) EtherBook;

    event withdrawLog(address userAddress, uint256 amount);

    function() public payable{}

    //Add profits for accounts
    function ProfitDividend (address[] addressArray, uint256[] profitArray) public onlyOwner
    {
        for( uint256 i = 0; i < addressArray.length;i++)
        {
            EtherBook[addressArray[i]] = EtherBook[addressArray[i]].add(profitArray[i]);
        }
    }
    
    // Adjust balance of accounts in the vault
    function AdjustEtherBook(address[] addressArray, uint256[] profitArray) public onlyOwner
    {
        for( uint256 i = 0; i < addressArray.length;i++)
        {
            EtherBook[addressArray[i]] = profitArray[i];
        }
    }
    
    //Check balance in the vault
    function CheckBalance(address theAddress) public view returns(uint256 profit)
    {
        return EtherBook[theAddress];
    }
    
    //User withdraw balance from the vault
    function withdraw() public payable
    {
        //if withdraw actived;
        require(IsWithdrawActive == true, "Vault is not ready.");
        require(EtherBook[msg.sender]>0, "Your vault is empty.");

        uint share = EtherBook[msg.sender];
        EtherBook[msg.sender] = 0;
        msg.sender.transfer(share);
        
        emit withdrawLog(msg.sender, share);
    }
    
    //Set withdraw status.
    function UpdateActive(bool _IsWithdrawActive) public onlyOwner
    {
        IsWithdrawActive = _IsWithdrawActive;
    }
}