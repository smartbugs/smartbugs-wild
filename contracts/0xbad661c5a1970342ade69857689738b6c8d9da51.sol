contract AddressReg{

    address public owner;

    function setOwner(address _owner){
        if(msg.sender==owner)
            owner = _owner;
    }

    function AddressReg(){
        owner = msg.sender;
    }

    mapping (address=>bool) isVerifiedMap;

    function verify(address addr){
        if(msg.sender==owner)
            isVerifiedMap[addr] = true;
    }

    function deverify(address addr){
        if(msg.sender==owner)
            isVerifiedMap[addr] = false;
    }

    function hasPhysicalAddress(address addr) constant returns(bool){
        return isVerifiedMap[addr];
    }

}