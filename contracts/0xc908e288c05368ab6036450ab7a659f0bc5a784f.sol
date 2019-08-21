pragma solidity ^0.4.25;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


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
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

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
contract Bussiness is Ownable {
    address public ceoAddress = address(0x6c3e879bdd20e9686cfd9bbd1bfd4b2dd6d47079);
  IERC721 public erc721Address = IERC721(0x273f7F8E6489682Df756151F5525576E322d51A3);
  ERC20BasicInterface public usdtToken = ERC20BasicInterface(0xdac17f958d2ee523a2206206994597c13d831ec7);
  uint256 public ETHFee = 2;
  uint256 public HBWALLETFee = 1;
  constructor() public {}
  struct Price {
    address tokenOwner;
    uint256 price;
    uint256 fee;
  }

  mapping(uint256 => Price) public prices;
  mapping(uint256 => Price) public usdtPrices;
  
  /**
   * @dev Throws if called by any account other than the ceo address.
   */
  modifier onlyCeoAddress() {
    require(msg.sender == ceoAddress);
    _;
  }
  function ownerOf(uint256 _tokenId) public view returns (address){
      return erc721Address.ownerOf(_tokenId);
  }
  function balanceOf() public view returns (uint256){
      return address(this).balance;
  }
  function getApproved(uint256 _tokenId) public view returns (address){
      return erc721Address.getApproved(_tokenId);
  }
  
  function setPrice(uint256 _tokenId, uint256 _ethPrice, uint256 _usdtPrice) public {
      require(erc721Address.ownerOf(_tokenId) == msg.sender);
      prices[_tokenId] = Price(msg.sender, _ethPrice, 0);
      usdtPrices[_tokenId] = Price(msg.sender, _usdtPrice, 0);
  }
  function setPriceFeeEth(uint256 _tokenId, uint256 _ethPrice) public payable {
      require(erc721Address.ownerOf(_tokenId) == msg.sender && prices[_tokenId].price != _ethPrice);
      uint256 ethfee;
      if(prices[_tokenId].price < _ethPrice) {
          ethfee = (_ethPrice - prices[_tokenId].price) * ETHFee / 100;
          require(msg.value == ethfee);
          ethfee += prices[_tokenId].fee;
      } else ethfee = _ethPrice * ETHFee / 100;
      prices[_tokenId] = Price(msg.sender, _ethPrice, ethfee);
  }
  function removePrice(uint256 tokenId) public returns (uint256){
      require(erc721Address.ownerOf(tokenId) == msg.sender);
      if (prices[tokenId].fee > 0) msg.sender.transfer(prices[tokenId].fee);
      resetPrice(tokenId);
      return prices[tokenId].price;
  }

  function getPrice(uint256 tokenId) public view returns (address, address, uint256, uint256){
      address currentOwner = erc721Address.ownerOf(tokenId);
      if(prices[tokenId].tokenOwner != currentOwner){
           resetPrice(tokenId);
       }
      return (currentOwner, prices[tokenId].tokenOwner, prices[tokenId].price, usdtPrices[tokenId].price);

  }

  function setFee(uint256 _ethFee, uint256 _hbWalletFee) public view onlyOwner returns (uint256 _ETHFee, uint256 _HBWALLETFee){
        require(_ethFee > 0 && _hbWalletFee > 0);
        _ETHFee = _ethFee;
        _HBWALLETFee = _hbWalletFee;
        return (_ETHFee, _HBWALLETFee);
    }
  /**
   * @dev Withdraw the amount of eth that is remaining in this contract.
   * @param _address The address of EOA that can receive token from this contract.
   */
    function withdraw(address _address, uint256 amount) public onlyCeoAddress {
        require(_address != address(0) && amount > 0 && address(this).balance > amount);
        _address.transfer(amount);
    }

  function buy(uint256 tokenId) public payable {
    require(erc721Address.getApproved(tokenId) == address(this));
    require(prices[tokenId].price > 0 && prices[tokenId].price == msg.value);
    erc721Address.transferFrom(prices[tokenId].tokenOwner, msg.sender, tokenId);
    prices[tokenId].tokenOwner.transfer(msg.value);
    resetPrice(tokenId);
  }
  function buyByUsdt(uint256 tokenId) public {
    require(usdtPrices[tokenId].price > 0 && erc721Address.getApproved(tokenId) == address(this));
    require(usdtToken.transferFrom(msg.sender, usdtPrices[tokenId].tokenOwner, usdtPrices[tokenId].price));

    erc721Address.transferFrom(usdtPrices[tokenId].tokenOwner, msg.sender, tokenId);
    resetPrice(tokenId);

  }
  function resetPrice(uint256 tokenId) private {
    prices[tokenId] = Price(address(0), 0, 0);
    usdtPrices[tokenId] = Price(address(0), 0, 0);
  }
}