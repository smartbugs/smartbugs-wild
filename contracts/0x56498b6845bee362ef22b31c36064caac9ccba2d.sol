pragma solidity ^0.5.5;

/*

file    : colossus.sol
ver     : 0.4.2

Deployment of Hut34's DIT contract - an ERC20 contract with all addresses having the entire supply, and being approved for transfers.
Additional functions allow on chain broadcast / storage of metadata related to encryption services provided by Colossus, Hut34's data encryption and storage beastie.

Come see us at https://hut34.io/ for further info (and see https://en.wikipedia.org/wiki/Colossus_computer for background.....)

Special thanks to OpenRelay's stateless contract "Notcoin" - https://blog.openrelay.xyz/notcoin/ :)

*/


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract DITToken is ERC20 {
  uint constant MAX_UINT = 2**256 - 1;

  string  public constant name            = "Discrete Information Theory";
  string  public constant symbol          = "DIT";
  uint8   public constant decimals        = 18;

  function totalSupply() public view returns (uint) {
    return MAX_UINT;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return MAX_UINT;
  }

  function transfer(address _to, uint _value) public returns (bool)  {
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    return MAX_UINT;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    emit Transfer(_from, _to, _value);
    return true;
  }

//functions required by Colossus to bind ETH addresses and other encrpytion keypairs

    mapping(address => string) private dataOne;

    function addDataOne(string memory _data) public {
        dataOne[msg.sender] = _data;
    }

    function getDataOne(address who) public view returns (string memory) {
        return dataOne[who];
    }

mapping(address => string) private dataTwo;

    function addDataTwo(string memory _data) public {
        dataTwo[msg.sender] = _data;
    }

    function getDataTwo(address who) public view returns (string memory) {
        return dataTwo[who];
    }

mapping(address => string) private dataThree;

    function addDataThree(string memory _data) public {
        dataThree[msg.sender] = _data;
    }

    function getDataThree(address who) public view returns (string memory) {
        return dataThree[who];
    }

mapping(address => string) private dataFour;

    function addDataFour(string memory _data) public {
        dataFour[msg.sender] = _data;
    }

    function getDataFour(address who) public view returns (string memory) {
        return dataFour[who];
}


    event hutXTransfer(string IPFSHash, string txHash);

    function hutXTxComplete(string memory IPFSHash, string memory txHash) public returns (bool){
        emit hutXTransfer(IPFSHash, txHash);
        return true;
    }

}