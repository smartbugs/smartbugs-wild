pragma solidity ^0.4.18;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    function Ownable() public {
        owner = msg.sender;
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

/*
 * ERC20Basic
 * Simpler version of ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Basic {
    function totalSupply() public constant returns (uint256);
    function balanceOf(address _owner) public constant returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
}


contract ERC223Basic is ERC20Basic {
    function transfer(address to, uint value, bytes data) public returns (bool);
}


/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC223Basic {
    // active supply of tokens
    function allowance(address _owner, address _spender) public constant returns (uint256);
    function transferFrom(address _from, address _to, uint _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 /*
 * Contract that is working with ERC223 tokens
 */

contract ERC223ReceivingContract {
    function tokenFallback(address _from, uint _value, bytes _data) public;
}

/**
 * @title ControlCentreInterface
 * @dev ControlCentreInterface is an interface for providing commonly used function
 * signatures to the ControlCentre
 */
contract ControllerInterface {

    function totalSupply() public constant returns (uint256);
    function balanceOf(address _owner) public constant returns (uint256);
    function allowance(address _owner, address _spender) public constant returns (uint256);
    function approve(address owner, address spender, uint256 value) public returns (bool);
    function transfer(address owner, address to, uint value, bytes data) public returns (bool);
    function transferFrom(address owner, address from, address to, uint256 amount, bytes data) public returns (bool);
    function mint(address _to, uint256 _amount) public returns (bool);
}

contract Token is Ownable, ERC20 {

    event Mint(address indexed to, uint256 amount);
    event MintToggle(bool status);

    // Constant Functions
    function balanceOf(address _owner) public constant returns (uint256) {
        return ControllerInterface(owner).balanceOf(_owner);
    }

    function totalSupply() public constant returns (uint256) {
        return ControllerInterface(owner).totalSupply();
    }

    function allowance(address _owner, address _spender) public constant returns (uint256) {
        return ControllerInterface(owner).allowance(_owner, _spender);
    }

    function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
        bytes memory empty;
        _checkDestination(address(this), _to, _amount, empty);
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }

    function mintToggle(bool status) onlyOwner public returns (bool) {
        MintToggle(status);
        return true;
    }

    // public functions
    function approve(address _spender, uint256 _value) public returns (bool) {
        ControllerInterface(owner).approve(msg.sender, _spender, _value);
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        bytes memory empty;
        return transfer(_to, _value, empty);
    }

    function transfer(address to, uint value, bytes data) public returns (bool) {
        ControllerInterface(owner).transfer(msg.sender, to, value, data);
        Transfer(msg.sender, to, value);
        _checkDestination(msg.sender, to, value, data);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        bytes memory empty;
        return transferFrom(_from, _to, _value, empty);
    }


    function transferFrom(address _from, address _to, uint256 _amount, bytes _data) public returns (bool) {
        ControllerInterface(owner).transferFrom(msg.sender, _from, _to, _amount, _data);
        Transfer(_from, _to, _amount);
        _checkDestination(_from, _to, _amount, _data);
        return true;
    }

    // Internal Functions
    function _checkDestination(address _from, address _to, uint256 _value, bytes _data) internal {
        uint256 codeLength;
        assembly {
            codeLength := extcodesize(_to)
        }
        if(codeLength>0) {
            ERC223ReceivingContract untrustedReceiver = ERC223ReceivingContract(_to);
            // untrusted contract call
            untrustedReceiver.tokenFallback(_from, _value, _data);
        }
    }
}


/**
 Simple Token based on OpenZeppelin token contract
 */
contract Force is  Token {

    string public constant name = "Force";
    string public constant symbol = "FORCE";
    uint8 public constant decimals = 18;

}