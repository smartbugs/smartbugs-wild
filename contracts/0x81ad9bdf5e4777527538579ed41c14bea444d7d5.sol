pragma solidity ^0.5.9;

contract StoredIPFSHashes {

    struct StateHashBatch {
        string contractHash;
        string event_id;
        uint new_privileges;
        uint new_firings;
        uint sold_resold_ratio;
    }
    
    event Update(
        string contractHash,
        uint sold_resold_ratio
    );
    
    address protocol;
    
    constructor() public {
        protocol = msg.sender;
    }
    
    modifier onlyProtocol() {
        if (msg.sender == protocol) {
            _;
        }
    } 
    
    StateHashBatch[] public all_hashes;
    
    function registerHash(
        string memory _contractHash, 
        string memory _event_id, 
        uint _new_privileges, 
        uint _new_firings,
        uint _sold_resold_ratio) public onlyProtocol {
            all_hashes.push(StateHashBatch(_contractHash, _event_id, _new_privileges, _new_firings, _sold_resold_ratio));
            emit Update(_contractHash, _sold_resold_ratio);
        }
}