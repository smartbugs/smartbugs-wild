pragma solidity ^0.4.25;

/**
* @title SafeMath
* @dev Math operations with safety checks that revert on error
*/
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// Setup Movecoin contract interface
contract ERC20MOVEInterface {
    function balanceOf(address owner) public view returns (uint256);
    function allowance(address owner, address spender) public view returns (uint256);
    function burnFrom(address from, uint256 value) public;
}

// CO2 Certificate "struct"
contract CO2Certificate {
    using SafeMath for uint256;

    uint256 private _burnedTokens;
    uint256 private _certifiedKilometers;
    string  private _ownerName;

    constructor (uint256 burnedTokens, uint256 certifiedKilometers, string ownerName) public {
        require (burnedTokens > 0, "You must burn at least one token");
        require (certifiedKilometers >= 0, "Certified Kilometers must be positive");
        
        _burnedTokens = burnedTokens;
        _certifiedKilometers = certifiedKilometers;
        _ownerName = ownerName;
    }

    // Getters
    function getBurnedTokens() public view returns(uint256) {
        return _burnedTokens;
    }

    function getCertifiedKilometers() public view returns(uint256) {
        return _certifiedKilometers;
    }

    function getOwnerName() public view returns(string) {
        return _ownerName;
    }

}

// Smart contract for certificate authority
contract MovecoinCertificationAuthority {
    using SafeMath for uint256;

    // Mapping address to CO2Certificate
    mapping (address => address) private _certificates;
    
    // Internal addresses
    address private _owner;
    address private _moveAddress;

    // Events
    event certificateIssued(uint256 tokens, uint256 kilometers, string ownerName, address certificateAddress);

    modifier onlymanager()
    {
        require(msg.sender == _owner, "Only Manager can access this function");
        _;
    }

    // When deploying the contract you must specify the address of the ERC20 MOVE Token and the address of the owner
    constructor (address moveAddress) public {
        require(moveAddress != address(0), "MOVE ERC20 Address cannot be null");
        _owner = msg.sender;
        _moveAddress = moveAddress;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a new manager.
    * @param newManager The address to transfer ownership to.
    */
    function transferManager(address newManager) public onlymanager {
        require(newManager != address(0), "Manager cannot be null");
        _owner = newManager;
    }

    /**
    * @dev Get issued certificate for that address
    * @param certOwner the certificate owner address
    */
    function getCertificateAddress(address certOwner) public view returns (address) {
        require(certOwner != address(0), "Certificate owner cannot be null");
        return _certificates[certOwner];
    } 

    /**
    * @dev Get issued certificate data for that address
    * @param certOwner the certificate owner address
    */
    function getCertificateData(address certOwner) public view returns (uint256, uint256, string) {
        require(certOwner != address(0), "Certificate owner cannot be null");

        CO2Certificate cert = CO2Certificate(_certificates[certOwner]);

        return (
            cert.getBurnedTokens(),
            cert.getCertifiedKilometers(),
            cert.getOwnerName()
        );
    }

    // Notice: certificateReceiver must allow MovecoinCertificationAuthority to burn his tokens using approve ERC20 function
    function issueNewCertificate(
        address certificateReceiver,
        uint256 tokensToBurn, 
        uint256 kilomitersToCertify, 
        string certificateReceiverName
    ) public onlymanager {

        // Initialize movecoin contract
        ERC20MOVEInterface movecoin = ERC20MOVEInterface(_moveAddress);

        // Check if the receiver really haves tokens
        require(tokensToBurn <= movecoin.balanceOf(certificateReceiver), "Certificate receiver must have tokens");

        // Check if we are allowed to move this tokens
        require(
            tokensToBurn <= movecoin.allowance(certificateReceiver, this),
            "CO2 Contract is not allowed to burn tokens in behalf of certificate receiver"
        );

        // Finally Burn tokens
        movecoin.burnFrom(certificateReceiver, tokensToBurn);

        // Issue new certificate if burned tokens succeed
        address Certificate = new CO2Certificate(tokensToBurn, kilomitersToCertify, certificateReceiverName);
        _certificates[certificateReceiver] = Certificate;

        emit certificateIssued(tokensToBurn, kilomitersToCertify, certificateReceiverName, Certificate);
    }

}