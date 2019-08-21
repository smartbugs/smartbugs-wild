//! Github Hinting contract.
//! By Gav Wood (Ethcore), 2016.
//! Released under the Apache Licence 2.

contract GithubHint {
    struct Entry {
        string accountSlashRepo;
        bytes20 commit;
        address owner;
    }
    
    modifier when_edit_allowed(bytes32 _content) { if (entries[_content].owner != 0 && entries[_content].owner != msg.sender) return; _ }
    
    function hint(bytes32 _content, string _accountSlashRepo, bytes20 _commit) when_edit_allowed(_content) {
        entries[_content] = Entry(_accountSlashRepo, _commit, msg.sender);
    }

    function hintURL(bytes32 _content, string _url) when_edit_allowed(_content) {
        entries[_content] = Entry(_url, 0, msg.sender);
    }

    function unhint(bytes32 _content) when_edit_allowed(_content) {
        delete entries[_content];
    }
    
    mapping (bytes32 => Entry) public entries;
}