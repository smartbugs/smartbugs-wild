pragma solidity ^0.5.0;

contract owned {
    address owner;

    modifier onlyowner() {
        require(msg.sender == owner);
        _;

    }

     constructor() public {
        owner = msg.sender;
    }
}

library SafeMath {
  function safeMul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }


}

contract ERC20Interface {
    // Get the total token supply
    function totalSupply() view public returns (uint256);

    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) view public returns (uint256);

    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success);

    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    // this function is required for some DEX functionality
    function approve(address _spender, uint256 _value) public returns (bool success);

    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) view public returns (uint256 remaining);

    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract BitSwap_5 is  owned{
    ////////////////
    ///// EVENTS /////
    //////////////////
    event DepositForEthReceived(address indexed _from, uint _amount, uint _timestamp);
    event withdrawalSwappedAsset(address indexed _to, uint indexed _symbolIndex, uint _amount, uint _timestamp);
    event DepositForTokenReceived(address indexed _from, uint indexed _symbolIndex, uint _amount, uint _timestamp);

    using SafeMath for uint256;
    
      //////////////
    // BALANCES //
    //////////////
    mapping (address => mapping (uint256 => uint)) tokenBalanceForAddress;
      struct Contracts {
         address contractAddr;
    }
    mapping (uint => Contracts) public ContractAddresses;
   

    mapping (address => uint) balanceEthForAddress;
       function depositEther() public payable {
        require(balanceEthForAddress[msg.sender] + msg.value >= balanceEthForAddress[msg.sender]);
        balanceEthForAddress[msg.sender] += msg.value;
        emit DepositForEthReceived(msg.sender, msg.value, now);
    }
    
    
     function addTokenContractAddress(string memory _symbol, address _contract) onlyowner() public{
         
         uint index = getSymbolContract(_symbol);
          require(index > 0);
         ContractAddresses[index] = Contracts(_contract);
        
    }
    
    
    
      function getSymbolContract(string memory _symbol) internal pure returns (uint) {
          uint index = 0;
         if(compareStringsbyBytes(_symbol,"BINS") || compareStringsbyBytes(_symbol,"BIB") || compareStringsbyBytes(_symbol,"DAIX")){
             if(compareStringsbyBytes(_symbol,"BINS")){
               index = 1;
             }else if(compareStringsbyBytes(_symbol,"BIB")){
                index = 2; 
             }else if(compareStringsbyBytes(_symbol,"DAIX")){
                index = 3; 
             }
             return index;
         }else{
            revert(); 
         }
         
        return 0;
    }


 function compareStringsbyBytes(string memory s1, string memory s2) public pure returns(bool){
    return keccak256(bytes(s1)) == keccak256(bytes(s2));
}

    
      function getTokenContractAddress(string memory _a) view public returns(address){
           uint index = getSymbolContract(_a);
           require(index > 0);
          return ContractAddresses[index].contractAddr;
     }
     
        function getTokenSymbolByContractAddress(string memory _a) view public returns(uint256){
          
           uint index = getSymbolContract(_a);
           require(index > 0);
            ERC20Interface token = ERC20Interface(ContractAddresses[index].contractAddr);

            return token.totalSupply();
     }
     
    
      
      
      function swapAsset(string memory _symbol) public {
           if(compareStringsbyBytes(_symbol,"DAIX")) revert(); 
       uint amountDue = 0;
       uint swapFromindex = getSymbolContract(_symbol);
     
      
       require(swapFromindex > 0);
       ERC20Interface swapFrom = ERC20Interface(ContractAddresses[swapFromindex].contractAddr);
  
      // require(swapFrom.approve(address(this), swapFrom.balanceOf(msg.sender)) == true);
        require(ContractAddresses[swapFromindex].contractAddr != address(0));
        

        require(tokenBalanceForAddress[msg.sender][swapFromindex] + swapFrom.balanceOf(msg.sender) >= tokenBalanceForAddress[msg.sender][swapFromindex]);
       if(compareStringsbyBytes(_symbol,"BINS")){
            amountDue = swapFrom.balanceOf(msg.sender);
        }else if(compareStringsbyBytes(_symbol,"BIB")){
             amountDue = swapFrom.balanceOf(msg.sender) / 200 * 3;
        }
        require(swapFrom.transferFrom(msg.sender, address(this), swapFrom.balanceOf(msg.sender)) == true);
       uint total = amountDue * 0.00000001 ether;
       
      
        tokenBalanceForAddress[msg.sender][swapFromindex] += total;
        emit DepositForTokenReceived(msg.sender, swapFromindex, total, now);
        
      }
      
    function withdrawSwappedAsset(string memory _symbol) public {
        string memory toAssetSymbol = "DAIX";
        uint symbolIndex = getSymbolContract(toAssetSymbol);
        uint withdrawSymbolIndex = getSymbolContract(_symbol);
        uint256 amount = tokenBalanceForAddress[msg.sender][withdrawSymbolIndex];
        require(ContractAddresses[symbolIndex].contractAddr != address(0));

        ERC20Interface token = ERC20Interface(ContractAddresses[symbolIndex].contractAddr);

        require(tokenBalanceForAddress[msg.sender][withdrawSymbolIndex] - amount >= 0);
        require(tokenBalanceForAddress[msg.sender][withdrawSymbolIndex] - amount <= tokenBalanceForAddress[msg.sender][withdrawSymbolIndex]);

        tokenBalanceForAddress[msg.sender][withdrawSymbolIndex] -= amount;
        
        require(token.transfer(msg.sender, amount) == true);
        emit withdrawalSwappedAsset(msg.sender, withdrawSymbolIndex, amount, now);
    }
    
      function getBalance(string memory symbolName) view public returns (uint) {
          uint withdrawSymbolIndex = getSymbolContract(symbolName);
        return tokenBalanceForAddress[msg.sender][withdrawSymbolIndex];
    }
    
    //   function calculate(uint symbolName) view public returns (uint) {
    //     uint total = symbolName * 0.00000001 ether;
    //     return total;
    // }
    
}