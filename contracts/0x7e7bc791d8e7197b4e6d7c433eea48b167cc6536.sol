pragma solidity ^0.4.24;

contract BulletinBoard {
    event PostMade(
        address indexed poster,
        string note,
        bytes32 hash,
        uint256 listIndex,
        uint256 blocknum
    );
    
    struct Post {
        address poster;
        string note;
        bytes32 hash;
        uint256 listIndex;
        uint256 blocknum;
    }

    mapping(bytes32 => Post) public posts;
    bytes32[] public postList;
    
    address ZERO_ADDRESS = address(0);

    constructor() public {
        string memory testPost = "pizza is yummy 123";
        bytes32 testHash = keccak256(abi.encodePacked(testPost));
        string memory testNote = "secret note, shh";
        require(makePost(testHash, testNote) == 0, "Error making post!");
    }

    function makePost(
        bytes32 hash,
        string note
    ) public returns (uint256 listIndex) {
        require(
            posts[hash].poster == ZERO_ADDRESS,
            "A post with this hash was already made!"
        );
        posts[hash] = Post({
            poster: msg.sender,
            note: note,
            hash: hash,
            listIndex: postList.length,
            blocknum: block.number
        });
        postList.push(hash);
        listIndex = postList.length - 1;
        emit PostMade(msg.sender, note, hash, listIndex, block.number);
        return listIndex;
    }

    function getNumPosts() public view returns (uint256) {
        return postList.length;
    }
}