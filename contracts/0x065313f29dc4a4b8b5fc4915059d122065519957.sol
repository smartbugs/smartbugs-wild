pragma solidity ^0.4.24;

contract Token {

    mapping (address => uint256) public balanceOf;
    function transfer(address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract Future1Exchange
 {
    /// Address of the owner (who can withdraw collected fees) 
    address public adminaddr; 
    
    ///************ Mapping ***********///
    
    mapping (address => mapping(address => uint256)) public dep_token;
    
    mapping (address => uint256) public dep_ETH;

    ///*********** Constructor *********///
    constructor() public
    {
         adminaddr = msg.sender;                                                            
    }
    
    
    function safeAdd(uint crtbal, uint depbal) public pure returns (uint) 
    {
        uint totalbal = crtbal + depbal;
        return totalbal;
    }
    
    function safeSub(uint crtbal, uint depbal) public pure returns (uint) 
    {
        uint totalbal = crtbal - depbal;
        return totalbal;
    }
    
    /// @notice This function allows to view the balance of token in given user
    /// @param token Token contract
    /// @param user  owner address
    function balanceOf(address token,address user) public view returns(uint256)            
    {
        return Token(token).balanceOf(user);
    }

    
    /// @notice This function allows to transfer ERC20 tokens.
    /// @param  token Token contract
    /// @param  tokens value
    function token_transfer(address token, uint256 tokens)public payable                          
    {
       // Token(token).approve.value(msg.sender)(address(this),tokens);
        if(Token(token).approve(address(this),tokens))
        {
            dep_token[msg.sender][token] = safeAdd(dep_token[msg.sender][token], tokens);
            Token(token).transferFrom(msg.sender,address(this), tokens);
        }
    }
    
    
    /// @notice  This function allows the owner to withdraw ERC20 tokens.
    /// @param  token Token contract
    /// @param  to Receiver address
    /// @param  tokens value
    function admin_token_withdraw(address token, address to, uint256 tokens)public payable      
    {
        if(adminaddr==msg.sender)
        {                                                                                                        
            if(dep_token[msg.sender][token]>=tokens) 
            {
                dep_token[msg.sender][token] = safeSub(dep_token[msg.sender][token] , tokens) ;   
                Token(token).transfer(to, tokens);
            }
        }
    }
    
    ///@notice This function allows to check the token balance in contract address
    ///@param token Token contract
    function contract_bal(address token) public view returns(uint256)                       
    {
        return Token(token).balanceOf(address(this));
    }
    
    ///@notice This function allows to deposit ether in contract address
    function depositETH() payable external                                                      
    { 
        
    }
    
    
    ///@notice This function allows admin to withdraw ether
    ///@param  to Receiver address
    ///@param  value ethervalue
    function admin_withdrawETH(address  to, uint256 value) public payable returns (bool)        
    {
        
        if(adminaddr==msg.sender)
        {                                                                                           
                 to.transfer(value);
                 return true;
    
         }
    }
}