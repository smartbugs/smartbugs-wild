pragma solidity ^0.4.18;


contract SMEBankingPlatformToken {
  function transfer(address to, uint256 value) public returns (bool);
  function balanceOf(address who) public constant returns (uint256);
}


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
  function Ownable() public {
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


contract Airdrop is Ownable {
  uint256 airdropAmount = 10000 * 10 ** 18;

  SMEBankingPlatformToken public token;

  mapping(address=>bool) public participated;

  mapping(address=>bool) public whitelisted;

  event TokenAirdrop(address indexed beneficiary, uint256 amount);

  event AddressWhitelist(address indexed beneficiary);

  function Airdrop(address _tokenAddress) public {
    token = SMEBankingPlatformToken(_tokenAddress);
  }

  function () public payable {
    getTokens(msg.sender);
  }

  function setAirdropAmount(uint256 _airdropAmount) public onlyOwner {
    require(_airdropAmount > 0);

    airdropAmount = _airdropAmount;
  }

  function getTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase(beneficiary));

    token.transfer(beneficiary, airdropAmount);

    TokenAirdrop(beneficiary, airdropAmount);

    participated[beneficiary] = true;
  }

  function whitelistAddresses(address[] beneficiaries) public onlyOwner {
    for (uint i = 0 ; i < beneficiaries.length ; i++) {
      address beneficiary = beneficiaries[i];
      require(beneficiary != 0x0);
      whitelisted[beneficiary] = true;
      AddressWhitelist(beneficiary);
    }
  }

  function validPurchase(address beneficiary) internal view returns (bool) {
    bool isWhitelisted = whitelisted[beneficiary];
    bool hasParticipated = participated[beneficiary];

    return isWhitelisted && !hasParticipated;
  }
}


contract SMEBankingPlatformAirdrop is Airdrop {
  function SMEBankingPlatformAirdrop(address _tokenAddress) public
    Airdrop(_tokenAddress)
  {

  }

  function drainRemainingTokens () public onlyOwner {
    token.transfer(owner, token.balanceOf(this));
  }
}