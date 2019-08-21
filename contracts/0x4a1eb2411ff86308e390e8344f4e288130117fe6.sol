pragma solidity >0.4.99 <0.6.0;

interface SlidebitsToken {
    function frozenAccount(address tokenHolder) external returns (bool status);
    function balanceOf(address _owner) external view returns (uint balance);
}

interface token {
    function transfer(address _to, uint256 _value) external;
}

contract UpgradeToken {
   address public owner;

   modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

  address oldTokenAddress = 0xb7FE7B2B723020Cf668Db4F78992d10F81990fc4;
  address newTokenAddress = 0x46706C5e5B7dF0Afd54a7248F1E5788275B7FaC6;

  SlidebitsToken public oldToken = SlidebitsToken(oldTokenAddress);
  token public newToken = token(newTokenAddress);

  mapping (address => bool) public upgradedAccount;
  
  constructor() public {
    owner = msg.sender;
  }

  function upgradeFrozenAccounts(address[] memory tokenHolders) public onlyOwner {
    for(uint i = 0; i < tokenHolders.length; i++)
    {
      if (oldToken.frozenAccount(tokenHolders[i]) && !upgradedAccount[tokenHolders[i]]){
          upgradedAccount[tokenHolders[i]] = true;
          newToken.transfer(tokenHolders[i], oldToken.balanceOf(tokenHolders[i]));
      }
    }
  }

}