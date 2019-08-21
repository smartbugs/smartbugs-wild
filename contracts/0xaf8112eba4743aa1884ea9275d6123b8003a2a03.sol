pragma solidity ^0.4.18;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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
    assert(c >= a);
    return c;
  }
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}




/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Ownable {
    address public pendingOwner;

    /**
     * @dev Modifier throws if called by any account other than the pendingOwner.
     */
    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner);
        _;
    }

    /**
     * @dev Allows the current owner to set the pendingOwner address.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner public {
        pendingOwner = newOwner;
    }

    /**
     * @dev Allows the pendingOwner address to finalize the transfer.
     */
    function claimOwnership() onlyPendingOwner public {
        OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}



contract CrowdFunding is Claimable {
    using SafeMath for uint256;

    // =================================================================================================================
    //                                      Members
    // =================================================================================================================

    // the wallet of the beneficiary
    address public walletBeneficiary;

    // amount of raised money in wei
    uint256 public weiRaised;

    // indicate if the crowd funding is ended
    bool public isFinalized = false;

    // =================================================================================================================
    //                                      Modifiers
    // =================================================================================================================

    modifier isNotFinalized() {
        require(!isFinalized);
        _;
    }

    // =================================================================================================================
    //                                      Events
    // =================================================================================================================

    event DonateAdded(address indexed _from, address indexed _to,uint256 _amount);

    event Finalized();

    event ClaimBalance(address indexed _grantee, uint256 _amount);

    // =================================================================================================================
    //                                      Constructors
    // =================================================================================================================

    function CrowdFunding(address _walletBeneficiary) public {
        require(_walletBeneficiary != address(0));
        walletBeneficiary = _walletBeneficiary;
    }

    // =================================================================================================================
    //                                      Public Methods
    // =================================================================================================================

    function deposit() onlyOwner isNotFinalized external payable {
    }

    function() external payable {
        donate();
    }

    function donate() public payable {
        require(!isFinalized);

        uint256 weiAmount = msg.value;
        
        // transfering the donator funds to the beneficiary
        weiRaised = weiRaised.add(weiAmount);
        walletBeneficiary.transfer(weiAmount);
        DonateAdded(msg.sender, walletBeneficiary, weiAmount);

        // transfering the owner funds to the beneficiary with the same amount of the donator
        if(this.balance >= weiAmount) {
            weiRaised = weiRaised.add(weiAmount);
            walletBeneficiary.transfer(weiAmount);
            DonateAdded(address(this), walletBeneficiary, weiAmount);
        } else {

            weiRaised = weiRaised.add(this.balance);
            // if not enough funds in the owner contract - transfer the remaining balance
            walletBeneficiary.transfer(this.balance);
            DonateAdded(address(this), walletBeneficiary, this.balance);
        }
    }

    // allow the owner to claim his the contract balance at any time
    function claimBalanceByOwner(address beneficiary) onlyOwner isNotFinalized public {
        require(beneficiary != address(0));

        uint256 weiAmount = this.balance;
        beneficiary.transfer(weiAmount);

        ClaimBalance(beneficiary, weiAmount);
    }

    function finalizeDonation(address beneficiary) onlyOwner isNotFinalized public {
        require(beneficiary != address(0));

        claimBalanceByOwner(beneficiary);
        isFinalized = true;

        Finalized();
    }
}