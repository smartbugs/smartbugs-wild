pragma solidity ^0.4.15;

/*
Copyright (c) 2016 Smart Contract Solutions, Inc.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract basicToken {
    function balanceOf(address) public view returns (uint256);
    function transfer(address, uint256) public returns (bool);
    function transferFrom(address, address, uint256) public returns (bool);
    function approve(address, uint256) public returns (bool);
    function allowance(address, address) public view returns (uint256);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract ERC20Standard is basicToken{

    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) public balances;

    /* Send coins */
    function transfer(address _to, uint256 _value) public returns (bool success){
        require (_to != 0x0);                               // Prevent transfer to 0x0 address
        require (balances[msg.sender] > _value);            // Check if the sender has enough
        require (balances[_to] + _value > balances[_to]);   // Check for overflows
        _transfer(msg.sender, _to, _value);                 // Perform actually transfer
        Transfer(msg.sender, _to, _value);                  // Trigger Transfer event
        return true;
    }

    /* Use admin powers to send from a users account */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require (_to != 0x0);                               // Prevent transfer to 0x0 address
        require (balances[msg.sender] > _value);            // Check if the sender has enough
        require (balances[_to] + _value > balances[_to]);   // Check for overflows
        require (allowed[_from][msg.sender] >= _value);     // Only allow if sender is allowed to do this
        _transfer(msg.sender, _to, _value);                 // Perform actually transfer
        Transfer(msg.sender, _to, _value);                  // Trigger Transfer event
        return true;
    }

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        balances[_from] -= _value;                          // Subtract from the sender
        balances[_to] += _value;                            // Add the same to the recipient
    }

    /* Get balance of an account */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    /* Approve an address to have admin power to use transferFrom */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}

contract HydroToken is ERC20Standard, owned{
    event Authenticate(uint partnerId, address indexed from, uint value);     // Event for when an address is authenticated
    event Whitelist(uint partnerId, address target, bool whitelist);          // Event for when an address is whitelisted to authenticate
    event Burn(address indexed burner, uint256 value);                        // Event for when tokens are burned

    struct partnerValues {
        uint value;
        uint challenge;
    }

    struct hydrogenValues {
        uint value;
        uint timestamp;
    }

    string public name = "Hydro";
    string public symbol = "HYDRO";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    /* This creates an array of all whitelisted addresses
     * Must be whitelisted to be able to utilize auth
     */
    mapping (uint => mapping (address => bool)) public whitelist;
    mapping (uint => mapping (address => partnerValues)) public partnerMap;
    mapping (uint => mapping (address => hydrogenValues)) public hydroPartnerMap;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function HydroToken() public {
        totalSupply = 11111111111 * 10**18;
        balances[msg.sender] = totalSupply;                 // Give the creator all initial tokens
    }

    /* Function to whitelist partner address. Can only be called by owner */
    function whitelistAddress(address _target, bool _whitelistBool, uint _partnerId) public onlyOwner {
        whitelist[_partnerId][_target] = _whitelistBool;
        Whitelist(_partnerId, _target, _whitelistBool);
    }

    /* Function to authenticate user
       Restricted to whitelisted partners */
    function authenticate(uint _value, uint _challenge, uint _partnerId) public {
        require(whitelist[_partnerId][msg.sender]);         // Make sure the sender is whitelisted
        require(balances[msg.sender] > _value);             // Check if the sender has enough
        require(hydroPartnerMap[_partnerId][msg.sender].value == _value);
        updatePartnerMap(msg.sender, _value, _challenge, _partnerId);
        transfer(owner, _value);
        Authenticate(_partnerId, msg.sender, _value);
    }

    function burn(uint256 _value) public onlyOwner {
        require(balances[msg.sender] > _value);
        balances[msg.sender] -= _value;
        totalSupply -= _value;
        Burn(msg.sender, _value);
    }

    function checkForValidChallenge(address _sender, uint _partnerId) public view returns (uint value){
        if (hydroPartnerMap[_partnerId][_sender].timestamp > block.timestamp){
            return hydroPartnerMap[_partnerId][_sender].value;
        }
        return 1;
    }

    /* Function to update the partnerValuesMap with their amount and challenge string */
    function updatePartnerMap(address _sender, uint _value, uint _challenge, uint _partnerId) internal {
        partnerMap[_partnerId][_sender].value = _value;
        partnerMap[_partnerId][_sender].challenge = _challenge;
    }

    /* Function to update the hydrogenValuesMap. Called exclusively from the Hydro API */
    function updateHydroMap(address _sender, uint _value, uint _partnerId) public onlyOwner {
        hydroPartnerMap[_partnerId][_sender].value = _value;
        hydroPartnerMap[_partnerId][_sender].timestamp = block.timestamp + 1 days;
    }

    /* Function called by Hydro API to check if the partner has validated
     * The partners value and data must match and it must be less than a day since the last authentication
     */
    function validateAuthentication(address _sender, uint _challenge, uint _partnerId) public constant returns (bool _isValid) {
        if (partnerMap[_partnerId][_sender].value == hydroPartnerMap[_partnerId][_sender].value
        && block.timestamp < hydroPartnerMap[_partnerId][_sender].timestamp
        && partnerMap[_partnerId][_sender].challenge == _challenge){
            return true;
        }
        return false;
    }
}