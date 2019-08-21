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
  IERC721 public erc721Address = IERC721(0x5d00d312e171be5342067c09bae883f9bcb2003b);
  ERC20BasicInterface public usdtToken = ERC20BasicInterface(0x315f396592c3c8a2d96d62fb597e2bf4fa7734ab);
  ERC20BasicInterface public hbwalletToken = ERC20BasicInterface(0xEc7ba74789694d0d03D458965370Dc7cF2FE75Ba);
  uint256 public ETHFee = 25; // 2,5 %
  uint256 public Percen = 1000;
  uint256 public HBWALLETExchange = 21;
  // cong thuc hbFee = ETHFee / Percen * HBWALLETExchange / 2
  uint256 public limitETHFee = 2000000000000000;
  uint256 public limitHBWALLETFee = 2;
  constructor() public {}
  struct Price {
    address tokenOwner;
    uint256 price;
    uint256 fee;
    uint256 hbfee;
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
      prices[_tokenId] = Price(msg.sender, _ethPrice, 0, 0);
      usdtPrices[_tokenId] = Price(msg.sender, _usdtPrice, 0, 0);
  }
  function setPriceFeeEth(uint256 _tokenId, uint256 _ethPrice) public payable {
      require(erc721Address.ownerOf(_tokenId) == msg.sender && prices[_tokenId].price != _ethPrice);
      uint256 ethfee;
      if(prices[_tokenId].price < _ethPrice) {
          ethfee = (_ethPrice - prices[_tokenId].price) * ETHFee / Percen;
          if(ethfee >= limitETHFee) {
              require(msg.value == ethfee);
          } else {
              require(msg.value == limitETHFee);
          }
          ethfee += prices[_tokenId].fee;
      } else ethfee = _ethPrice * ETHFee / Percen;
      prices[_tokenId] = Price(msg.sender, _ethPrice, ethfee, 0);
  }
  function setPriceFeeHBWALLETTest(uint256 _tokenId, uint256 _ethPrice) public view returns (uint256, uint256){
      uint256 ethfee = _ethPrice * ETHFee / Percen;
      return (ethfee, ethfee * HBWALLETExchange / 2 / (10 ** 16)); // ethfee / (10 ** 18) * HBWALLETExchange / 2 * (10 ** 2)
  }
  function setPriceFeeHBWALLET(uint256 _tokenId, uint256 _ethPrice) public returns (bool){
      require(erc721Address.ownerOf(_tokenId) == msg.sender && prices[_tokenId].price != _ethPrice);
      uint256 fee;
      uint256 ethfee;
      if(prices[_tokenId].price < _ethPrice) {
          ethfee = (_ethPrice - prices[_tokenId].price) * ETHFee / Percen;
          fee = ethfee * HBWALLETExchange / 2 / (10 ** 16); // ethfee * HBWALLETExchange / 2 * (10 ** 2) / (10 ** 18)
          if(fee >= limitHBWALLETFee) {
              require(hbwalletToken.transferFrom(msg.sender, address(this), fee));
          } else {
              require(hbwalletToken.transferFrom(msg.sender, address(this), limitHBWALLETFee));
          }
          fee += prices[_tokenId].hbfee;
      } else {
          ethfee = _ethPrice * ETHFee / Percen;
          fee = ethfee * HBWALLETExchange / 2 / (10 ** 16);
      }
      prices[_tokenId] = Price(msg.sender, _ethPrice, 0, fee);
      return true;
  }
  function removePrice(uint256 tokenId) public returns (uint256){
      require(erc721Address.ownerOf(tokenId) == msg.sender);
      if (prices[tokenId].fee > 0) msg.sender.transfer(prices[tokenId].fee);
      else if (prices[tokenId].hbfee > 0) hbwalletToken.transfer(msg.sender, prices[tokenId].hbfee);
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

  function setFee(uint256 _ethFee, uint256 _HBWALLETExchange) public view onlyOwner returns (uint256, uint256){
        require(_ethFee > 0 && _HBWALLETExchange > 0);
        ETHFee = _ethFee;
        HBWALLETExchange = _HBWALLETExchange;
        return (ETHFee, HBWALLETExchange);
    }
    function setLimitFee(uint256 _ethlimitFee, uint256 _hbWalletlimitFee) public view onlyOwner returns (uint256, uint256){
        require(_ethlimitFee > 0 && _hbWalletlimitFee > 0);
        limitETHFee = _ethlimitFee;
        limitHBWALLETFee = _hbWalletlimitFee;
        return (limitETHFee, limitHBWALLETFee);
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
    require(getApproved(tokenId) == address(this));
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
    prices[tokenId] = Price(address(0), 0, 0, 0);
    usdtPrices[tokenId] = Price(address(0), 0, 0, 0);
  }
}