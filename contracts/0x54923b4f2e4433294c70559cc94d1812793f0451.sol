pragma solidity ^0.4.24;

contract Token {

    mapping (address => uint256) public balanceOf;
    function transfer(address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract Future1Exchange
 {
    address public archon; 
    
    mapping (address => mapping(address => uint256)) public _token;
    
    constructor() public
    {
         archon = msg.sender;                                                            
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
    
    /// @notice View balance
    /// @param token Token contract
    /// @param user  owner address
    function balanceOf(address token,address user) public view returns(uint256)            
    {
        return Token(token).balanceOf(user);
    }

    
    /// @notice Token transfer
    /// @param  token Token contract
    /// @param  tokens value
    function tokenTransfer(address token, uint256 tokens)public payable                          
    {

        _token[msg.sender][token] = safeAdd(_token[msg.sender][token], tokens);
        Token(token).transferFrom(msg.sender,address(this), tokens);

    }
    
    /// @notice Token withdraw
    /// @param  token Token contract
    /// @param  to Receiver address
    /// @param  tokens value
    function tokenWithdraw(address token, address to, uint256 tokens)public payable      
    {
        if(archon==msg.sender)
        {                                                                                                        
            if(Token(token).balanceOf(address(this))>=tokens) 
            {
                _token[msg.sender][token] = safeSub(_token[msg.sender][token] , tokens) ;   
                Token(token).transfer(to, tokens);
            }
        }
    }
    
    ///@notice Token balance
    ///@param token Token contract
    function contract_bal(address token) public view returns(uint256)                       
    {
        return Token(token).balanceOf(address(this));
    }
    
    ///@notice Deposit ETH
    function depositETH() payable external                                                      
    { 
        
    }
    
    ///@notice Withdraw ETH
    ///@param  to Receiver address
    ///@param  value ethervalue
    function withdrawETH(address  to, uint256 value) public payable returns (bool)        
    {
        
        if(archon==msg.sender)
        {                                                                                           
                 to.transfer(value);
                 return true;
    
         }
    }
}