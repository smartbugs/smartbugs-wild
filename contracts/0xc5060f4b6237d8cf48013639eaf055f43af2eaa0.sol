pragma solidity ^0.4.25;
// Interface to ERC20 functions used in this contract
interface ERC20token {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
contract ExoTokensMarketSimple {
    ERC20token ExoToken;
    address owner;
    uint256 pricePerToken;
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    constructor() public {
        owner = msg.sender;
    }

    function setPricePerToken(uint256 ethPrice) public onlyOwner {
        pricePerToken = ethPrice;
    }
    function getPricePerToken() public view returns(uint256) {
        return pricePerToken;
    }
    function setERC20Token(address tokenAddr) public onlyOwner  {
        ExoToken = ERC20token(tokenAddr);
    }
    function getERC20Token() public view returns(address) {
        return ExoToken;
    }
    function getERC20Balance() public view returns(uint256) {
        return ExoToken.balanceOf(this);
    }
    function depositERC20Token(uint256 _exo_amount) public  {
        require(ExoToken.allowance(msg.sender, this) >= _exo_amount);
        require(ExoToken.transferFrom(msg.sender, this, _exo_amount));
    }

    // EXO buying function
    // All of the ETH included in the TX is converted to EXO and the remainder is sent back
    function BuyTokens() public payable{
        uint256 exo_balance = ExoToken.balanceOf(this);
        uint256 tokensToXfer = msg.value / pricePerToken;
        require(exo_balance >= tokensToXfer, "Not enough tokens in contract");
        uint256 return_ETH_amount = msg.value - (tokensToXfer *pricePerToken);
        require(return_ETH_amount < msg.value); // just in case

        if(return_ETH_amount > 0){
            msg.sender.transfer(return_ETH_amount); // return extra ETH
        }

        require(ExoToken.transfer(msg.sender, tokensToXfer), "Couldn't send funds"); // send EXO tokens
    }

    // Withdraw erc20 tokens
    function withdrawERC20Tokens(uint _val) public onlyOwner {
        require(ExoToken.transfer(msg.sender, _val), "Couldn't send funds"); // send EXO tokens
    }

    // Withdraw Ether
    function withdrawEther() public onlyOwner {
        msg.sender.transfer(address(this).balance);

    }
 
    // change the owner
    function setOwner(address _owner) public onlyOwner {
        owner = _owner;    
    }
    // fallback
    function() external payable { }   
}