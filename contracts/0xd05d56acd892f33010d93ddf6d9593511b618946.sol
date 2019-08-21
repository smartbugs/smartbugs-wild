contract DgxToken {
  function approve(address _spender,uint256 _value) returns(bool success);
  function totalSupply() constant returns(uint256 );
  function transferFrom(address _from,address _to,uint256 _value) returns(bool success);
  function balanceOf(address _owner) constant returns(uint256 balance);
  function transfer(address _to,uint256 _value) returns(bool success);
  function allowance(address _owner,address _spender) constant returns(uint256 remaining);
}

contract SwapContract {
 
  address public seller;
  address public dgxContract;
  uint256 public weiPrice;

  modifier ifSeller() {
    if (seller != msg.sender) {
      throw;
    } else {
      _
    }
  }

  function SwapContract(address _seller, uint256 _weiPrice) {
    dgxContract = 0x55b9a11c2e8351b4ffc7b11561148bfac9977855;
    seller = _seller;
    weiPrice = _weiPrice;
  }

  function () {
    if (dgxBalance() == 0) throw;
    if (msg.value < totalWeiPrice()) throw;
    if (DgxToken(dgxContract).transfer(address(this), dgxBalance())) {
      seller.send(msg.value);       
    }
  }

  function setWeiPrice(uint256 _newweiprice) ifSeller returns (bool _success) {
    weiPrice = _newweiprice;
    _success = true;
    return _success;
  }

  function totalWeiPrice() public constant returns (uint256 _totalweiprice) {
    _totalweiprice = dgxBalance() * weiPrice;
    return _totalweiprice;
  }

  function dgxBalance() public constant returns (uint256 _dgxbalance) {
    _dgxbalance = DgxToken(dgxContract).balanceOf(address(this));
    return _dgxbalance;
  }

  function withdraw() ifSeller returns (bool _success) {
    _success = DgxToken(dgxContract).transfer(seller, dgxBalance());
    return _success;
  }
}

contract DgxSwap {

  uint256 public totalCount;
  mapping (address => address) public swapContracts;
  mapping (uint256 => address) public sellers;

  function DgxSwap() {
    totalCount = 0;
  }

  function createSwap(uint256 _weiprice) public returns (bool _success) {
    address _swapcontract = new SwapContract(msg.sender, _weiprice);
    swapContracts[msg.sender] = _swapcontract;
    sellers[totalCount] = msg.sender; 
    totalCount++;
    _success = true;
    return _success;
  }

  function getSwap(uint256 _id) public constant returns (address _seller, address _contract, uint256 _dgxbalance, uint256 _weiprice, uint256 _totalweiprice) {
    _seller = sellers[_id];
    if (_seller == 0x0000000000000000000000000000000000000000) {
      _contract = 0x0000000000000000000000000000000000000000;
      _dgxbalance = 0;
      _weiprice = 0;
      _totalweiprice = 0;
    } else {
      _contract = swapContracts[_seller];  
      _dgxbalance = SwapContract(_contract).dgxBalance();
      _weiprice = SwapContract(_contract).weiPrice();
      _totalweiprice = SwapContract(_contract).totalWeiPrice();
    }
    return (_seller, _contract, _dgxbalance, _weiprice, _totalweiprice);
  }

}