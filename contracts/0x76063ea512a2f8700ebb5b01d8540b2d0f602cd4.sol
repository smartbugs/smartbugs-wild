pragma solidity ^0.4.25;
/* 
  this version of tradiing contracts uses mappings insead of array to keep track of
  weapons on sale
 */

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a && c>=b);
    return c;
  }
}

contract WeaponTokenize {
  event GameProprietaryDataUpdated(uint weaponId, string gameData);
  event PublicDataUpdated(uint weaponId, string publicData);
  event OwnerProprietaryDataUpdated(uint weaponId, string ownerProprietaryData);
  event WeaponAdded(uint weaponId, string gameData, string publicData, string ownerData);
  function updateOwnerOfWeapon (uint, address) public  returns(bool res);
  function getOwnerOf (uint _weaponId) public view returns(address _owner) ;
}

contract ERC20Interface {
  function transfer(address to, uint tokens) public returns (bool success);
  function balanceOf(address _sender) public returns (uint _bal);
  function allowance(address tokenOwner, address spender) public view returns (uint remaining);
  event Transfer(address indexed from, address indexed to, uint tokens);
      function transferFrom(address from, address to, uint tokens) public returns (bool success);
}


contract TradeWeapon {
  using SafeMath for uint;
  // state variables
  address public owner;
  WeaponTokenize public weaponTokenize;
  ERC20Interface public RCCToken;
  uint public rate = 100; // 1 ETH = 100 RCC
  uint public commssion_n = 50; // 1% commssion of each trade from both buyers and sellers
  uint public commssion_d = 100;
  bool public saleDisabled = false;
  bool public ethSaleDisabled = false;

  // statics
  uint public totalOrdersPlaced = 0;
  uint public totalOrdersCancelled = 0;
  uint public totalOrdersMatched = 0;

  struct item{
    uint sellPrice;
    uint commssion;
    address seller;
  }

  // this mapping contains weaponId to details of sale
  mapping (uint => item) public weaponDetail;
  // total weapon on Sale
  uint totalWeaponOnSale;
  // index => weaponId
  mapping(uint => uint) public indexToWeaponId;
  // weaponId => index
  mapping(uint => uint) public weaponIdToIndex;
  // mapping of weaponId to saleStatus
  mapping (uint => bool) public isOnSale;
  // address to operator
  mapping (address => mapping(address => bool)) private operators;
  
  // events
  event OrderPlaced(address _seller, address _placedBy, uint _weaponId, uint _sp);
  event OderUpdated(address _seller, address _placedBy, uint _weaponId, uint _sp);
  event OrderCacelled(address _placedBy, uint _weaponId);
  event OrderMatched(address _buyer, address _seller, uint _sellPrice, address _placedBy, uint _commssion, string _payType);
  
  constructor (address _tokenizeAddress, address _rccAddress) public{
    owner = msg.sender;
    weaponTokenize =  WeaponTokenize(_tokenizeAddress);
    RCCToken = ERC20Interface(_rccAddress);
  }

  modifier onlyOwnerOrOperator(uint _weaponId) {
    address weaponOwner = weaponTokenize.getOwnerOf(_weaponId);
    require (
      (msg.sender == weaponOwner ||
      checkOperator(weaponOwner, msg.sender)
      ), '2');
    _;
  }

  modifier onlyIfOnSale(uint _weaponId) {
    require(isOnSale[_weaponId], '3');
    _;
  }

  modifier ifSaleLive(){
    require(!saleDisabled, '6');
    _;
  }

  modifier ifEthSaleLive() {
    require(!ethSaleDisabled, '7');
    _;
  }

  modifier onlyOwner() {
    require (msg.sender == owner, '1');
    _;
  }

  ///////////////////////////////////////////////////////////////////////////////////
                    // Only Owner //
  ///////////////////////////////////////////////////////////////////////////////////

  function updateRate(uint _newRate) onlyOwner public {
    rate = _newRate;
  }

  function updateCommission(uint _commssion_n, uint _commssion_d) onlyOwner public {
    commssion_n = _commssion_n;
    commssion_d = _commssion_d;
  }

  function disableSale() public onlyOwner {
    saleDisabled = true;
  }

  function enableSale() public onlyOwner {
    saleDisabled = false;
  }

  function disableEthSale() public onlyOwner {
    ethSaleDisabled = false;
  }

  function enableEthSale() public onlyOwner {
    ethSaleDisabled = true;
  }

  ///////////////////////////////////////////////////////////////////////////////////
                    // Public Functions //
  ///////////////////////////////////////////////////////////////////////////////////

  function addOperator(address newOperator) public{
    operators[msg.sender][newOperator] =  true;
  }

  function removeOperator(address _operator) public {
    operators[msg.sender][_operator] =  false;
  }



  function sellWeapon(uint _weaponId, uint _sellPrice) ifSaleLive onlyOwnerOrOperator(_weaponId) public {
    // weapon should not be already on sale
    require( ! isOnSale[_weaponId], '4');
    // get owner of weapon from Tokenization contract
    address weaponOwner = weaponTokenize.getOwnerOf(_weaponId);
    // calculate commssion
    uint _commssion = calculateCommission(_sellPrice);
    
    item memory testItem = item(_sellPrice, _commssion, weaponOwner);
    // put weapon on sale
    putWeaponOnSale(_weaponId, testItem);
    // emit sell event
    emit OrderPlaced(weaponOwner, msg.sender, _weaponId, _sellPrice);
  }

  function updateSale(uint _weaponId, uint _sellPrice) ifSaleLive onlyIfOnSale(_weaponId) onlyOwnerOrOperator(_weaponId) public {
    // calculate commssion
    uint _commssion = calculateCommission(_sellPrice);
    // get owner of weapon
    address weaponOwner = weaponTokenize.getOwnerOf(_weaponId);
    item memory testItem = item(_sellPrice ,_commssion, weaponOwner);
    weaponDetail[_weaponId] = testItem;
    emit OderUpdated(weaponOwner, msg.sender, _weaponId, _sellPrice);
  }


  function cancelSale(uint _weaponId) ifSaleLive onlyIfOnSale(_weaponId) onlyOwnerOrOperator(_weaponId) public {
    (address weaponOwner,,) = getWeaponDetails(_weaponId);
    removeWeaponFromSale(_weaponId);
    totalOrdersCancelled = totalOrdersCancelled.add(1);
    weaponTokenize.updateOwnerOfWeapon(_weaponId, weaponOwner);
    emit OrderCacelled(msg.sender, _weaponId);
  }

  function buyWeaponWithRCC(uint _weaponId, address _buyer) ifSaleLive onlyIfOnSale(_weaponId) public{
    if (_buyer != address(0)){
      buywithRCC(_weaponId, _buyer);
    }else{
      buywithRCC(_weaponId, msg.sender);
    }
  }

  function buyWeaponWithEth(uint _weaponId, address _buyer) ifSaleLive ifEthSaleLive onlyIfOnSale(_weaponId) public payable {
    if (_buyer != address(0)){
      buywithEth(_weaponId, _buyer, msg.value);
    }else{
      buywithEth(_weaponId, msg.sender, msg.value);
    }
  }


  ///////////////////////////////////////////////////////////////////////////////////
                    // Internal Fns //
  ///////////////////////////////////////////////////////////////////////////////////

  function buywithRCC(uint _weaponId, address _buyer) internal {
    // get details of weapon on sale
    (address seller, uint spOfWeapon, uint commssion) = getWeaponDetails(_weaponId);
    // get allowance to trading contract from buyer
    uint allowance = RCCToken.allowance(_buyer, address(this));
    // calculate selling price (= sp + commission)
    uint sellersPrice = spOfWeapon.sub(commssion);
    require(allowance >= spOfWeapon, '5');
    // delete weapon for sale
    removeWeaponFromSale(_weaponId);
    // transfer coins
    if(spOfWeapon > 0){
      RCCToken.transferFrom(_buyer, seller, sellersPrice);
    }
    if(commssion > 0){
      RCCToken.transferFrom(_buyer, owner, commssion);
    }
    // add to total orders matched
	  totalOrdersMatched = totalOrdersMatched.add(1);
    // update ownership to buyer
    weaponTokenize.updateOwnerOfWeapon(_weaponId, _buyer);
    emit OrderMatched(_buyer, seller, spOfWeapon, msg.sender, commssion, 'RCC');
  }

  function buywithEth(uint _weaponId, address _buyer, uint weiPaid) internal {
    // basic validations
    require ( rate > 0, '8');

    // get weapon details
    (address seller, uint spOfWeapon, uint commssion) = getWeaponDetails(_weaponId);

    // calculate prices in wei
    uint spInWei = spOfWeapon.div(rate);
    require(spInWei > 0, '9');
    require(weiPaid == spInWei, '10');
    uint sellerPrice = spOfWeapon.sub(commssion);

    // send RCC to seller
    require (RCCToken.balanceOf(address(this)) >= sellerPrice, '11');
    RCCToken.transfer(seller, sellerPrice);

    // send ETH to admin
    //address(owner).transfer(weiPaid);

    // remove weapon from sale
    removeWeaponFromSale(_weaponId);

    // add to total orders matched
	  totalOrdersMatched = totalOrdersMatched.add(1);

    // transfer weapon to buyer
    weaponTokenize.updateOwnerOfWeapon(_weaponId, _buyer);
    emit OrderMatched(_buyer, seller, spOfWeapon,  msg.sender, commssion, 'ETH');
  } 

  function putWeaponOnSale(uint _weaponId, item memory _testItem) internal {
    // chnage ownership of weapon to this contract
    weaponTokenize.updateOwnerOfWeapon(_weaponId, address(this));
    // allocate last index to this weapon id
    indexToWeaponId[totalWeaponOnSale.add(1)] = _weaponId;
    //
    weaponIdToIndex[_weaponId] = totalWeaponOnSale.add(1);
    // increase totalWeapons
    totalWeaponOnSale = totalWeaponOnSale.add(1);
    // map weaponId to weaponDetail
    weaponDetail[_weaponId] = _testItem;
    // set on sale flag to true
    isOnSale[_weaponId] = true;
    // add to total orders placed
    totalOrdersPlaced = totalOrdersPlaced.add(1);
  }

  function removeWeaponFromSale(uint _weaponId) internal {
    // set on sale property to false
    isOnSale[_weaponId] = false;
    // reset values of struct
    weaponDetail[_weaponId] = item(0, 0,address(0));
    uint indexOfDeletedWeapon = weaponIdToIndex[_weaponId];
    if(indexOfDeletedWeapon != totalWeaponOnSale){
      uint weaponAtLastIndex = indexToWeaponId[totalWeaponOnSale];
      // map last elment to current one
      weaponIdToIndex[weaponAtLastIndex] = indexOfDeletedWeapon;
      indexToWeaponId[indexOfDeletedWeapon] = weaponAtLastIndex;
      // last element to 0
      weaponIdToIndex[_weaponId] = 0;
      indexToWeaponId[totalWeaponOnSale] = 0;
    } else{
      weaponIdToIndex[_weaponId] = 0;
      indexToWeaponId[indexOfDeletedWeapon] = 0;
    }
    totalWeaponOnSale = totalWeaponOnSale.sub(1);
  }

  ///////////////////////////////////////////////////////////////////////////////////
                    // Constant functions //
  ///////////////////////////////////////////////////////////////////////////////////

  function getWeaponDetails (uint _weaponId) public view returns (address, uint, uint) {
    item memory currentItem = weaponDetail[_weaponId];
    return (currentItem.seller, currentItem.sellPrice, currentItem.commssion);
  }

  function calculateCommission (uint _amount) public view returns (uint) {
    return _amount.mul(commssion_n).div(commssion_d).div(100);
  }

  function getTotalWeaponOnSale() public view returns (uint) {
    return totalWeaponOnSale;
  }

  function getWeaponAt(uint index) public view returns(address, uint, uint, uint) {
    uint weaponId =  indexToWeaponId[index];
    item memory currentItem = weaponDetail[weaponId];
    return (currentItem.seller, currentItem.sellPrice, currentItem.commssion, weaponId);
  }

  function checkOperator(address _user, address _operator) public view returns (bool){
    return operators[_user][_operator];
  }

}