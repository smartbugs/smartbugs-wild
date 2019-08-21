pragma solidity ^0.5.3;

contract RNG {
    //uint public nonce;
    struct History{
        uint time;
        uint result;
        address sender;
        string description;
    }
    History[] public history;
    event Result(uint time, uint result, address sender);
    
    function ByteToInt(bytes32 _number) public pure returns(uint num) {
      return uint(_number);
  }
    
    function GetResult(uint nonce, string memory desc, uint min, uint max) public returns(uint num){
        require(msg.sender == 0x4769D2D7DDF8e75Ba0Fb09544fd0528498558fba);
        bytes32 lottery = keccak256(abi.encodePacked(msg.sender, nonce, blockhash(block.number - 1)));
        uint res = min + (ByteToInt(lottery) % max + 1);
        history.push(History(now, res, msg.sender, desc));
        emit Result(now, res, msg.sender);
        return res;
    }


}