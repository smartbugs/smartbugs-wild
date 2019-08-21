pragma solidity ^0.4.24;

// 'AELEUS TOKEN' CROWDSALE token contract
//
// Symbol      : AEL
// Name        : AELEUS TOKEN
// Total supply: 200,000,000
// Decimals    : 18

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract AEL {
    // Public variables of the token
    string public name = "AELEUS";
    string public symbol = "AEL";
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default
    uint256 public totalSupply;
    uint256 public tokenSupply = 200000000;
    uint public presale;
    uint public coresale;
    
    address public creator;
    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    event FundTransfer(address backer, uint amount, bool isContribution);
    
    
    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function AEL() public {
        totalSupply = tokenSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;    // Give DatBoiCoin Mint the total created tokens
        creator = msg.sender;
        presale = now + 21 days;
        coresale = now + 41 days;
    }
    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
      
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    
    
   function transfer(address[] _to, uint256[] _value) public {
    for (uint256 i = 0; i < _to.length; i++)  {
        _transfer(msg.sender, _to[i], _value[i]);
        }
    }


    /// @notice Buy tokens from contract by sending ether
    function () payable internal {
        uint amount;                   
        uint amountRaised;

        if (now <= presale) {
            amount = msg.value * 15000;
        } else if (now > presale && now <= coresale) {
            amount = msg.value * 13000;
        } else if (now > coresale) {
            amount = msg.value * 10000;
        }
        

                                             
        amountRaised += msg.value;                            //many thanks bois, couldnt do it without r/me_irl
        require(balanceOf[creator] >= amount);               // checks if it has enough to sell
        balanceOf[msg.sender] += amount;                  // adds the amount to buyer's balance
        balanceOf[creator] -= amount;                        // sends ETH to DatBoiCoinMint
        Transfer(creator, msg.sender, amount);               // execute an event reflecting the change
        creator.transfer(amountRaised);
    }

 }