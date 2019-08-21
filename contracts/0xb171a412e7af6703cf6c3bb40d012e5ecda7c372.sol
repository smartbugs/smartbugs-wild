pragma solidity ^0.4.21;

contract ESSAdvance{
    function airdrop(uint256 _airdropPrice,uint256 _ethPayment) public returns(uint256 _airdropAmount);
}

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function upgradeOwner(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract IterableMapping
{
  struct itmap
  {
    mapping(uint => IndexValue) data;
    KeyFlag[] keys;
    uint size;
  }
  struct IndexValue { uint keyIndex; uint value; }
  struct KeyFlag { uint key; bool deleted; }
  function insert(itmap storage self, uint key, uint value) internal returns (bool replaced)
  {
    uint keyIndex = self.data[key].keyIndex;
    self.data[key].value = value;
    if (keyIndex > 0)
      return true;
    else
    {
      keyIndex = self.keys.length++;
      self.data[key].keyIndex = keyIndex + 1;
      self.keys[keyIndex].key = key;
      self.size++;
      return false;
    }
  }
  function remove(itmap storage self, uint key) internal returns (bool success)
  {
    uint keyIndex = self.data[key].keyIndex;
    if (keyIndex == 0)
      return false;
    delete self.data[key];
    self.keys[keyIndex - 1].deleted = true;
    self.size --;
  }
  function contains(itmap storage self, uint key) internal view returns (bool)
  {
    return self.data[key].keyIndex > 0;
  }
  function iterate_start(itmap storage self) internal view returns (uint keyIndex)
  {
    return iterate_next(self, uint(-1));
  }
  function iterate_valid(itmap storage self, uint keyIndex) internal view returns (bool)
  {
    return keyIndex < self.keys.length;
  }
  function iterate_next(itmap storage self, uint keyIndex) internal view returns (uint r_keyIndex)
  {
    keyIndex++;
    while (keyIndex < self.keys.length && self.keys[keyIndex].deleted)
      keyIndex++;
    return keyIndex;
  }
  function iterate_get(itmap storage self, uint keyIndex) internal view returns (uint key, uint value)
  {
    key = self.keys[keyIndex].key;
    value = self.data[key].value;
  }
}


contract Airdrop is IterableMapping,owned{

    itmap validAddress;
    function setValidAddress(uint idx,address addr) public onlyOwner{
        insert(validAddress,idx,uint(addr));
    }
    function removeValidAddress(uint idx) public onlyOwner{
        remove(validAddress,idx);
    }
    function getValidAddress(uint idx) public view returns(address){
      return address(validAddress.data[idx].value);
    }
    function getValidAddressConfig() public view returns(uint[],address[]){
        uint size = validAddress.size;
        uint[] memory indexes = new uint[](size);
        address[] memory addresses = new address[](size);
        uint idx = 0;
        for (uint i = iterate_start(validAddress); iterate_valid(validAddress, i); i = iterate_next(validAddress, i))
        {
            uint _index;
            uint _address;
            (_index,_address) = iterate_get(validAddress, i);
            indexes[idx] = _index;
            addresses[idx] = address(_address);
            idx++;
        }
        return (indexes,addresses);
    }
    modifier onlyValidAddress() {
      bool valid = false;
      if(msg.sender == owner)
        valid = true;
      else
      {
        for (uint i = iterate_start(validAddress); iterate_valid(validAddress, i); i = iterate_next(validAddress, i))
        {
            uint _address;
            (,_address) = iterate_get(validAddress, i);
            if(msg.sender==address(_address))
            {
              valid = true;
              break;
            }
        }
      }
      require(valid);
      _;
    }
    address public essTokenAddr = 0xAbBE84B4ae1803FE74452BdC9Fc2407c4b8d2eE5;
    function airdrop(uint256 _airdropPrice,uint256 _ethPayment) public onlyValidAddress returns(uint256 _airdropAmount){
        return ESSAdvance(essTokenAddr).airdrop(_airdropPrice,_ethPayment);
    }
}