pragma solidity ^0.4.16;

/*
MOSBIN is a Modern Marketplace Based on Blockchain - You can Sell and Buy goods with Fiat Money and Cryptocurrency

MOSBIN Token details :

Name            : MOSBIN 
Symbol          : MOS 
Total Supply    : 2.000.000.000 MOS
Decimals        : 18 
Telegram Group  : https://t.me/mosbin

Tokensale Details    :

Total for Tokensale         : 1.200.000.000 MOS 

Tokensale (+airdrop) Tier 1 : 200.000.000 MOS
*Price   : 600.000 MOS/ETH 
No minimum Contribution but if contribute 0.1 ETH or more will get 50% Bonus

Tokensale (+airdrop) Tier 2 : 400.000.000 MOS
*Price   : 600.000 MOS/ETH 
No minimum Contribution but if contribute 0.1 ETH or more will get 25% Bonus

Tokensale (+airdrop) Tier 3 : 600.000.000 MOS
*Price   : 600.000 MOS/ETH 
No minimum Contribution but if contribute 0.1 ETH or more will get 10% Bonus


Future Development   :   500.000.000 MOS 
Team and Foundation  :   300.000.000 MOS // Lock for 1 years

Softcap              :           400 ETH
Hardcap              :         1.400 ETH

*No Minimum contribution on MOS Tokensale
Send ETH To Contract Address you will get MOSBIN Token directly set gas limit 150.000

*Airdrop - If you don't have enough ETH , you can send 0 ETH to Contract Address and you will get "70 MOS" / Transaction 
A Wallett Address can make more than once transaction on tokensale and airdrop 

Set GAS Limits 150.000 and GAS Price always check on ethgasstation.info (use Standard Gas Price or Fast Gas Price)
Each contribution on Tokensale will get 70 MOS Extra  
Unsold token will Burned 

Add Custom Token on Myetherwallet and Metamask

Contract : 0x64599d1707d4ec6adcf7bd194af4b42a1ddc0c07
Symbol   : MOS 
Decimals : 18 

*/

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract MOS {
    // Public variables of the token
    string public name = "MOSBIN";
    string public symbol = "MOS";
    uint8 public decimals = 18;
    // Decimals = 18
    uint256 public totalSupply;
    uint256 public btnSupply = 2000000000;
    uint256 public buyPrice = 600000;
    address public creator;
    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain
    event Transfer(address indexed from, address indexed to, uint256 value);
    event FundTransfer(address backer, uint amount, bool isContribution);
    
    
    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function MOS() public {
        totalSupply = btnSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;    // Give MOS Token the total created tokens
        creator = msg.sender;
    }
    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0); //Burn
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
      
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    
    
    /// @notice Buy tokens from contract by sending ethereum to contract address with no minimum contribution
    function () payable internal {
        uint amount = msg.value * buyPrice +70e18 ;                    // calculates the amount
        uint amountRaised;                                     
        amountRaised += msg.value;                            
        require(balanceOf[creator] >= amount);               
        require(msg.value >=0);                        
        balanceOf[msg.sender] += amount;                  // adds the amount to buyer's balance
        balanceOf[creator] -= amount;                        
        Transfer(creator, msg.sender, amount);               
        creator.transfer(amountRaised);
    }    
    
 }