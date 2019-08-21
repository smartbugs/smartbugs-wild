pragma solidity ^0.4.20;


contract Voucher {

    bytes32 private token;
    address private owner;
    uint private created_at;
    uint private updated_at;
    uint private expires_at;
    /** in days **/
    bool private burnt;

    /**
     * Constructor
     */
    constructor(bytes32 voucher_token, uint _lifetime) public {
        token = voucher_token;
        burnt = false;
        created_at = now;
        updated_at = now;
        expires_at = created_at + (_lifetime * 60*60*24);
        owner = msg.sender;
    }

    /**
     * Burn a Voucher
     */
    function burn(bytes32 voucher_token) public returns (bool success){
        require(token == voucher_token, "Forbidden.");
        require(msg.sender == owner);
        require(!burnt, "Already burnt.");
        burnt = true;
        updated_at = now;
        return true;
    }

    function is_burnt(bytes32 voucher_token) public returns (bool) {
        require(token == voucher_token, "Forbidden.");
        require(msg.sender == owner);
        if (is_expired(voucher_token)){
            burn(voucher_token);
        }
        return burnt;
    }

    function is_expired(bytes32 voucher_token) view public returns(bool){
        require(token == voucher_token, "Forbidden.");
        return expires_at != created_at && expires_at < now;
    }
}