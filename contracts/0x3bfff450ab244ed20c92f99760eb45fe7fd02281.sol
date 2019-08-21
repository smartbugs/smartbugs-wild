pragma solidity ^0.4.16;


/* 
This contract stores the memories of GuaGua and MiaoMiao.
Long last our love and the blockchain.
*/
contract GuaGuaMiaoMiaoMemories {

    struct Memory {
        string story;
        uint256 imageSliceCount;
        mapping(uint256 => bytes) imageSlices;
    }

    Memory[] internal memories;

    address public guagua;
    address public miaomiao;

    function GuaGuaMiaoMiaoMemories() public {
        guagua = msg.sender;
    }

    modifier onlyGuaGua() {
        require(msg.sender == guagua);
        _;
    }

    modifier onlyMiaoMiao() {
        require(msg.sender == miaomiao);
        _;
    }

    modifier onlyGuaGuaMiaoMiao() {
        require(msg.sender == guagua || msg.sender == miaomiao);
        _;
    }

    function initMiaoMiaoAddress(address _miaomiaoAddress) external onlyGuaGuaMiaoMiao {
        require(_miaomiaoAddress != address(0));
        miaomiao = _miaomiaoAddress;
    }

    function addMemory(string _story, bytes _imageFirstSlice) external onlyGuaGuaMiaoMiao {
        memories.push(Memory({story: _story, imageSliceCount: 0}));
        memories[memories.length-1].imageSlices[0] = _imageFirstSlice;
        memories[memories.length-1].imageSliceCount = 1;
    }

    function addMemoryImageSlice(uint256 _index, bytes _imageSlice) external onlyGuaGuaMiaoMiao {
        require(_index >= 0 && _index < memories.length);
        memories[_index].imageSlices[memories[_index].imageSliceCount] = _imageSlice;
        memories[_index].imageSliceCount += 1;
    }

    function viewMemory(uint256 _index) public view returns (string story, bytes image) {
        require(_index >= 0 && _index < memories.length);
        uint256 imageLen = 0;
        uint256 i = 0;
        for (i = 0; i < memories[_index].imageSliceCount; i++){
            imageLen += memories[_index].imageSlices[i].length;
        }
        image = new bytes(imageLen);
        uint256 j = 0;
        uint256 k = 0;
        for (i = 0; i < memories[_index].imageSliceCount; i++){
            for (j = 0; j < memories[_index].imageSlices[i].length; j++) {
                image[k] = memories[_index].imageSlices[i][j];
                k += 1;
            }
        }
        story = memories[_index].story;
        return (story, image);
    }

    function viewNumberOfMemories() public view returns(uint256) {
        return memories.length;
    }
    
}