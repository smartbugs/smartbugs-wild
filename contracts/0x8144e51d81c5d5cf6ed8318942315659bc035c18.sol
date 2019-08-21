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
* @title ERC20 interface
* @dev see https://github.com/ethereum/EIPs/issues/20
*/
contract ERC20 {
    function allowance(address owner, address spender) public view returns (uint256);
    function balanceOf(address who) public view returns  (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
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
contract RewardSharing is Ownable{
    using SafeMath for uint256;
    bool public IsWithdrawActive = true;

    //for Shareholder banlance record
    mapping(address => uint256) EtherBook;
    mapping(address=> mapping(address => uint256)) TokenBook;
    address[] supportToken;

    event withdrawLog(address userAddress, uint256 etherAmount, uint256 tokenAmount);

    function() public payable{}
    
    //Get counts of supported Token
    function GetTokenLen() public view returns(uint256)
    {
        return supportToken.length;
    }
    
    //Get supportToken by index
    function GetSupportToken(uint index) public view returns(address)
    {
        return supportToken[index];
    }

    //Add Ether for accounts
    function ProfitDividend (address[] addressArray, uint256[] profitArray) public onlyOwner
    {
        for( uint256 i = 0; i < addressArray.length;i++)
        {
            EtherBook[addressArray[i]] = EtherBook[addressArray[i]].add(profitArray[i]);
        }
    }
    
    // Adjust Ether balance of accounts in the vault
    function AdjustEtherBook(address[] addressArray, uint256[] profitArray) public onlyOwner
    {
        for( uint256 i = 0; i < addressArray.length;i++)
        {
            EtherBook[addressArray[i]] = profitArray[i];
        }
    }
    
    //Add token for accounts
    function ProfitTokenDividend (address ERC20Address, address[] addressArray, uint256[] profitArray) public onlyOwner
    {
        if(TokenBook[ERC20Address][0x0]== 0)
        {
            supportToken.push(ERC20Address);
            TokenBook[ERC20Address][0x0] = 1;
        }
        
        for( uint256 i = 0; i < addressArray.length;i++)
        {
            TokenBook[ERC20Address][addressArray[i]] = TokenBook[ERC20Address][addressArray[i]].add(profitArray[i]);
        }
    }
    
    // Adjust token balance of accounts in the vault
    function AdjustTokenBook(address ERC20Address,address[] addressArray, uint256[] profitArray) public onlyOwner
    {
        if(TokenBook[ERC20Address][0x0]== 0)
        {
            supportToken.push(ERC20Address);
            TokenBook[ERC20Address][0x0] = 1;
        }
        
        for( uint256 i = 0; i < addressArray.length;i++)
        {
            TokenBook[ERC20Address][addressArray[i]] = profitArray[i];
        }
    }
    
    //check ether balance in the vault
    function CheckBalance(address theAddress) public view returns(uint256 EtherProfit)
    {
        return (EtherBook[theAddress]);
    }
    
    //Check token balance in the vault
    function CheckTokenBalance(address ERC20Address, address theAddress) public view returns(uint256 TokenProfit)
    {
        return TokenBook[ERC20Address][theAddress];
    }
    
    //User withdraw ERC20 Token
    function withdrawToken(address ERC20Address) public
    {
        uint tokenAmount = TokenBook[ERC20Address][msg.sender];
        TokenBook[ERC20Address][msg.sender]= 0;
    
        ERC20(ERC20Address).transfer(msg.sender, tokenAmount);
    }
    
    //User Withdraw Ether
    function withdrawEther() public
    {
        uint etherAmount = EtherBook[msg.sender];
        EtherBook[msg.sender] = 0;
        msg.sender.transfer(etherAmount);
    }
    
    //Set withdraw status.
    function UpdateActive(bool _IsWithdrawActive) public onlyOwner
    {
        IsWithdrawActive = _IsWithdrawActive;
    }
}