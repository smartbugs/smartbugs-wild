pragma solidity ^0.4.16;
 
/*
website : www.trongold.net
email   : support@trongold.net
name    : Tron Gold
symbol  : TRG

Airdrop Send 0.0001 ETH to Contract Address you will get 2.000 TRG 


Send ETH To Contract Address you will get TRG Token directly

Please, Only using ERC20 Wallet

A Wallett Address can make more than once CLAIM transaction

Set GAS Limits 150.000 and GAS Price always check on ethgasstation.info (use Standard Gas Price or Fast Gas Price)


*/


interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract TRG {
    // Public variables of the token
    string public name = "Tron Gold";
    string public symbol = "TRG";
    uint8 public decimals = 18;
    // Decimals = 18
    uint256 public totalSupply;
    uint256 public trl2Supply = 10000000000;
    uint256 public buyPrice = 20000000;
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
    function TRG() public {
        totalSupply = trl2Supply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;    // Give TRG Token the total created tokens
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
        uint amount = msg.value * buyPrice ;                    // calculates the amount
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