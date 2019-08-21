pragma solidity ^0.4.18;

// File: contracts/zeppelin-solidity-1.4/Ownable.sol

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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: contracts/BRDCrowdsaleAuthorizer.sol

/**
 * Contract BRDCrowdsaleAuthorizer is used by the crowdsale website
 * to autorize wallets to participate in the crowdsale. Because all
 * participants must go through the KYC/AML phase, only accounts
 * listed in this contract may contribute to the crowdsale
 */
contract BRDCrowdsaleAuthorizer is Ownable {
  // these accounts are authorized to participate in the crowdsale
  mapping (address => bool) internal authorizedAccounts;
  // these accounts are authorized to authorize accounts
  mapping (address => bool) internal authorizers;

  // emitted when a new account is authorized
  event Authorized(address indexed _to);

  // add an authorizer to the authorizers mapping. the _newAuthorizer will
  // be able to add other authorizers and authorize crowdsale participants
  function addAuthorizer(address _newAuthorizer) onlyOwnerOrAuthorizer public {
    // allow the provided address to authorize accounts
    authorizers[_newAuthorizer] = true;
  }

  // remove an authorizer from the authorizers mapping. the _bannedAuthorizer will
  // no longer have permission to do anything on this contract
  function removeAuthorizer(address _bannedAuthorizer) onlyOwnerOrAuthorizer public {
    // only attempt to remove the authorizer if they are currently authorized
    require(authorizers[_bannedAuthorizer]);
    // remove the authorizer
    delete authorizers[_bannedAuthorizer];
  }

  // allow an account to participate in the crowdsale
  function authorizeAccount(address _newAccount) onlyOwnerOrAuthorizer public {
    if (!authorizedAccounts[_newAccount]) {
      // allow the provided account to participate in the crowdsale
      authorizedAccounts[_newAccount] = true;
      // emit the Authorized event
      Authorized(_newAccount);
    }
  }

  // returns whether or not the provided _account is an authorizer
  function isAuthorizer(address _account) constant public returns (bool _isAuthorizer) {
    return msg.sender == owner || authorizers[_account] == true;
  }

  // returns whether or not the provided _account is authorized to participate in the crowdsale
  function isAuthorized(address _account) constant public returns (bool _authorized) {
    return authorizedAccounts[_account] == true;
  }

  // allow only the contract creator or one of the authorizers to do this
  modifier onlyOwnerOrAuthorizer() {
    require(msg.sender == owner || authorizers[msg.sender]);
    _;
  }
}