pragma solidity ^0.4.11;
/**
* Token Batch assignments 
*/

 contract token {

    function balanceOf(address _owner) public returns (uint256 bal);
    function transfer(address _to, uint256 _value) public returns (bool); 
 
 }


/**
 * This contract is administered
 */

contract admined {
    address public admin; //Admin address is public
    /**
    * @dev This constructor set the initial admin of the contract
    */
    function admined() internal {
        admin = msg.sender; //Set initial admin to contract creator
        Admined(admin);
    }

    modifier onlyAdmin() { //A modifier to define admin-only functions
        require(msg.sender == admin);
        _;
    }

    /**
    * @dev Transfer the adminship of the contract
    * @param _newAdmin The address of the new admin.
    */
    function transferAdminship(address _newAdmin) onlyAdmin public { //Admin can be transfered
        require(_newAdmin != address(0));
        admin = _newAdmin;
        TransferAdminship(admin);
    }

    //All admin actions have a log for public review
    event TransferAdminship(address newAdmin);
    event Admined(address administrador);
}

contract Sender is admined {
    
    token public ERC20Token;
    mapping (address => bool) public flag; //Balances mapping
    uint256 public price; //with all decimals
    
    function Sender (token _addressOfToken, uint256 _initialPrice) public {
        price = _initialPrice;
        ERC20Token = _addressOfToken; 
    }

    function updatePrice(uint256 _newPrice) onlyAdmin public {
        price = _newPrice;
    }

    function contribute() public payable { //It takes an array of addresses and an amount
        require(flag[msg.sender] == false);
        flag[msg.sender] = true;
        ERC20Token.transfer(msg.sender,price);
    }

    function withdraw() onlyAdmin public{
        require(admin.send(this.balance));
        ERC20Token.transfer(admin, ERC20Token.balanceOf(this));
    }

    function() public payable {
        contribute();
    }
}