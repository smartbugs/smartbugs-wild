pragma solidity ^0.4.24;

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract  CheckErc20 { 

    mapping(address=>string) public erc20Map;
    address[] public erc20Array;
    address owner;
    constructor () public{
        owner = msg.sender;
    }

    function getBalance() public view returns (uint[]){
        return this.getBalance(msg.sender);
    }  

    function getBalance(address addr) public view returns (uint[]){
        uint erc20Length = erc20Array.length;
        uint[] memory balances;
        for(uint i = 0;i<erc20Length;i++){
            IERC20 erc20Contract = IERC20(erc20Array[i]);
            uint erc20Balance = erc20Contract.balanceOf(addr);
            balances[i] = erc20Balance;
        }
        return balances;
    }

    function addErc20 (address erc20address, string erc20Name) public {
        require(msg.sender==owner, "need owner");
        erc20Array.push(erc20address);
        erc20Map[erc20address] = erc20Name;
    }
}