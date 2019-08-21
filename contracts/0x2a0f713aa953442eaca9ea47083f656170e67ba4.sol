pragma solidity ^0.4.18;

contract Pub {
    struct Publication {
        address source;
        uint256 timestamp;
        string title;
        // must be bytes in order to support files
        bytes body;
    }

    mapping (address => uint256[]) public allByAuthor;
    // anonymous by default
    mapping (address => string) public authors;
    Publication[] public all;

    function Pub() public { }

    function publishBytes(string _title, bytes _body)
    external
    returns (uint256) {
        uint256 index = all.length;
        all.push(Publication(
            msg.sender,
            now,
            _title,
            _body
        ));
        allByAuthor[msg.sender].push(index);
        return index;
    }

    function publish(string _title, string _body)
    external
    returns (uint256) {
        uint256 index = all.length;
        all.push(Publication(
            msg.sender,
            now,
            _title,
            bytes(_body)
        ));
        allByAuthor[msg.sender].push(index);
        return index;
    }

    function sign(string _name)
    external {
        authors[msg.sender] = _name;
    }

    function publicationCount(address _author)
    external view
    returns (uint256) {
        return allByAuthor[_author].length;
    }

    function size()
    external view
    returns (uint256) {
        return all.length;
    }
}