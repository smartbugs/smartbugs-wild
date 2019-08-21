pragma solidity ^0.4.25;

contract IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);
    function ownerOf(uint256 tokenId) public view returns (address owner);

    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);

    function transferFrom(address from, address to, uint256 tokenId) public;
    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20BasicInterface {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);

    uint8 public decimals;
}
contract Bussiness {
  IERC721 public erc721Address;
  ERC20BasicInterface usdtToken = ERC20BasicInterface(0xdac17f958d2ee523a2206206994597c13d831ec7);
  constructor(IERC721 token) public {
     erc721Address = token;
  }
  struct Price {
    address tokenOwner;
    uint256 price;
  }

  mapping(uint256 => Price) public prices;
  mapping(uint256 => Price) public usdtPrices;
  function ownerOf(uint256 _tokenId) public view returns (address){
      return erc721Address.ownerOf(_tokenId);
  }
  function setPrice(uint256 _tokenId, uint256 _ethPrice, uint256 _usdtPrice) public {
      require(erc721Address.ownerOf(_tokenId) == msg.sender);
      prices[_tokenId] = Price(msg.sender, _ethPrice);
      usdtPrices[_tokenId] = Price(msg.sender, _usdtPrice);
  }
  function removePrice(uint256 tokenId) public returns (uint256){
      require(erc721Address.ownerOf(tokenId) == msg.sender);
      resetPrice(tokenId);
      return prices[tokenId].price;
  }

  function getPrice(uint256 tokenId) public returns (address, address, uint256, uint256){
      address currentOwner = erc721Address.ownerOf(tokenId);
      if(prices[tokenId].tokenOwner != currentOwner){
           resetPrice(tokenId);
       }
      return (currentOwner, prices[tokenId].tokenOwner, prices[tokenId].price, usdtPrices[tokenId].price);

  }
  function buy(uint256 tokenId) public payable {
    require(erc721Address.getApproved(tokenId) == address(this));
    require(prices[tokenId].price == msg.value);
    erc721Address.transferFrom(prices[tokenId].tokenOwner, msg.sender, tokenId);
    prices[tokenId].tokenOwner.transfer(msg.value);
    resetPrice(tokenId);
  }
  function buyByUsdt(uint256 tokenId) public {
    require(erc721Address.getApproved(tokenId) == address(this));
    require(usdtToken.transferFrom(msg.sender, usdtPrices[tokenId].tokenOwner, usdtPrices[tokenId].price));

    erc721Address.transferFrom(usdtPrices[tokenId].tokenOwner, msg.sender, tokenId);
    usdtPrices[tokenId].tokenOwner.transfer(msg.value);
    resetPrice(tokenId);

  }
  function resetPrice(uint256 tokenId) private {
    prices[tokenId] = Price(address(0), 0);
    usdtPrices[tokenId] = Price(address(0), 0);
  }
}