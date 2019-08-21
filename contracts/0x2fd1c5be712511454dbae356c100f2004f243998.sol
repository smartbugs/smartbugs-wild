pragma solidity 0.4.25;

////////////////////////////////////////////////////////////////////////////////
//
// Eth17 - Master Contract that holds the Factory address and Eth funds
//
////////////////////////////////////////////////////////////////////////////////

contract Master {
    
    address public admin;
    address public thisContractAddress;
    address public factoryContractAddress;
    
    // MODIFIERS
    modifier onlyAdmin { 
        require(msg.sender == admin
        ); 
        _; 
    }
    
    // MODIFIERS
    modifier onlyAdminOrFactory { 
        require(
            msg.sender == admin ||
            msg.sender == factoryContractAddress
        ); 
        _; 
    }

    constructor() public payable {
        admin = msg.sender;
        thisContractAddress = address(this);
    }

    // FALLBACK
    function () private payable {}
    
    function setAdmin(address _address) onlyAdmin public {
        admin = address(_address);
    }

    function setFactoryContractAddress(address _address) onlyAdmin public {
        factoryContractAddress = address(_address);
    }

    function adminWithdraw(uint _amount) onlyAdmin public {
	    address(admin).transfer(_amount);
    }

    function adminWithdrawAll() onlyAdmin public {
	    address(admin).transfer(address(this).balance);
    }

    function transferEth() onlyAdminOrFactory public {
        address(factoryContractAddress).transfer(1 ether);
    }

    function thisContractBalance() public view returns(uint) {
        return address(this).balance;
    }

}