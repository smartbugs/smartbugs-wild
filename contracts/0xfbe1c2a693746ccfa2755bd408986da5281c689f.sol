// DAC Contract Address: 0x800deede5d02713616498cdfd8bc5780964deb9a
// ABI: [{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"totalSupply","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_value","type":"uint256"},{"name":"tokenAddress","type":"address"},{"name":"tokenName","type":"string"},{"name":"tokenSymbol","type":"string"}],"name":"transmuteTransfer","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"_totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"standard","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"toCheck","type":"address"}],"name":"vaildBalanceForTokenCreation","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"coinsAmount","type":"uint256"},{"name":"initialSupply","type":"uint256"},{"name":"assetTokenName","type":"string"},{"name":"tokenSymbol","type":"string"},{"name":"_assetID","type":"string"},{"name":"_assetMeta","type":"string"},{"name":"_isVerified","type":"string"}],"name":"CreateDigitalAssetToken","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"totalAssetTokens","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_newOwner","type":"address"}],"name":"changeOwner","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"assetToken","type":"address"}],"name":"doesAssetTokenExist","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"idx","type":"uint256"}],"name":"getAssetTokenByIndex","outputs":[{"name":"assetToken","type":"address"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_creator","type":"address"},{"indexed":true,"name":"_assetContract","type":"address"}],"name":"NewDigitalAsset","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"},{"indexed":false,"name":"_tokenAddress","type":"address"},{"indexed":false,"name":"_tokenName","type":"string"},{"indexed":false,"name":"_tokenSymbol","type":"string"}],"name":"TransmutedTransfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_owner","type":"address"},{"indexed":true,"name":"_spender","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Approval","type":"event"}]
//
// Test Asset Created with owner & _isVerified : 0x7962e319eDCB6afEabb0d72bb245A23d2266e3AD

pragma solidity ^0.4.10;

contract SafeMath {

    /* function assert(bool assertion) internal { */
    /*   if (!assertion) { */
    /*     throw; */
    /*   } */
    /* }      // assert no longer needed once solidity is on 0.4.10 */

    function safeToAdd(uint a, uint b) internal returns (bool) {
        return (a + b >= a);
    }

    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }

}

contract Token {
    uint256 public _totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/*  ERC 20 token */
contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
      if (balances[msg.sender] >= _value && _value > 0) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    function totalSupply() constant returns (uint256 totalSupply) {
          totalSupply = _totalSupply;
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}
  
contract DigitalAssetToken is StandardToken() 
{
    string public constant standard = 'DigitalAssetToken 1.0';
    string public symbol;
    string public  name;
    string public  assetID;
    string public  assetMeta;
    string public isVerfied;
    uint8 public constant decimals = 0;
   
    // Constructor
    function DigitalAssetToken(
    address tokenMaster,
    address requester,
    uint256 initialSupply,
    string assetTokenName,
    string tokenSymbol,
    string _assetID,
    string _assetMeta
    ) {
        //Only Token Master can initiate Digital Asset Token Creations
        require(msg.sender == tokenMaster);

        DigitalAssetCoin coinMaster = DigitalAssetCoin(tokenMaster);

        require(coinMaster.vaildBalanceForTokenCreation(requester));
        
        balances[requester] = initialSupply;              // Give the creator all initial tokens
        _totalSupply = initialSupply;                        // Update total supply
        name = assetTokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        assetID = _assetID;
        assetMeta = _assetMeta;
    } 
}
  
contract DigitalAssetCoin is StandardToken {
    string public constant standard = 'DigitalAssetCoin 1.0';
    string public constant symbol = "DAC";
    string public constant name = "Digital Asset Coin";
    uint8 public constant decimals = 0;

    // Balances for each account
    mapping(address => uint256) transmutedBalances;

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event NewDigitalAsset(address indexed _creator, address indexed _assetContract);
    event TransmutedTransfer(address indexed _from, address indexed _to, uint256 _value, address _tokenAddress, string _tokenName, string _tokenSymbol);

    //List of Asset Tokens
    uint256 public totalAssetTokens;
    address[] addressList;
    mapping(address => uint256) addressDict;
    
    // Owner of this contract
    address public owner;

    // Functions with this modifier can only be executed by the owner
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    // Allow Owner to be changed by exisiting owner (Dev management)
    function changeOwner(address _newOwner) onlyOwner() {
        owner = _newOwner;
    }

    // Constructor
    function DigitalAssetCoin() {
        owner = msg.sender;
        _totalSupply = 100000000000;
        balances[owner] = _totalSupply;
        totalAssetTokens = 0;
        addressDict[this] = totalAssetTokens;
        addressList.length = 1;
        addressList[totalAssetTokens] = this;
    }

    function CreateDigitalAssetToken(
    uint256 coinsAmount,
    uint256 initialSupply,
    string assetTokenName,
    string tokenSymbol,
    string _assetID,
    string _assetMeta
    ) {
        //Not Enought Coins to Create new Asset Token
        require(balanceOf(msg.sender) > coinsAmount);
        
        //Cant be smaller than 1 or larger than 1
        require(coinsAmount == 1);

        //Send coins back to master escrow
        DigitalAssetToken newToken = new DigitalAssetToken(this, msg.sender,initialSupply,assetTokenName,tokenSymbol,_assetID,_assetMeta);
        //Use coins for Token Creation
        transmuteTransfer(msg.sender, 1, newToken, assetTokenName, tokenSymbol);
        insetAssetToken(newToken);
    }

    function vaildBalanceForTokenCreation (address toCheck) external returns (bool success) {
        address sender = msg.sender;
        address org = tx.origin; 
        address tokenMaster = this;

        //Can not be run from human or master contract
        require(sender != org || sender != tokenMaster);

        //Check if message send can make token
        if (balances[toCheck] >= 1) {
            return true;
        } else {
            return false;
        }

    }
    
    function insetAssetToken(address assetToken) internal {
        totalAssetTokens = totalAssetTokens + 1;
        addressDict[assetToken] = totalAssetTokens;
        addressList.length += 1;
        addressList[totalAssetTokens] = assetToken;
        NewDigitalAsset(msg.sender, assetToken);
        //Transfer(msg.sender, assetToken, 777);
    }
    
    function getAssetTokenByIndex (uint256 idx) external returns (address assetToken) {
        require(totalAssetTokens <= idx);
        return addressList[idx];
    }
    
    function doesAssetTokenExist (address assetToken) external returns (bool success) {
        uint256 value = addressDict[assetToken];
        if(value == 0)
            return false;
        else
            return true;
    }
    
    // Transmute DAC to DAT
    function transmuteTransfer(address _from, uint256 _value, address tokenAddress, string tokenName, string tokenSymbol) returns (bool success) {
        if (balances[_from] >= _value && _value > 0) {
            balances[_from] -= _value;
            transmutedBalances[this] += _value;
            TransmutedTransfer(_from, this, _value, tokenAddress, tokenName, tokenSymbol);
            return true;
        } else {
            return false;
        }
    }

}