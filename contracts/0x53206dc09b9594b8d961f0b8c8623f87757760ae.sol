pragma solidity ^0.4.17;

contract ExtendEvents {

    event LogQuery(bytes32 query, address userAddress);
    event LogBalance(uint balance);
    event LogNeededBalance(uint balance);
    event CreatedUser(bytes32 username);
    event UsernameDoesNotMatch(bytes32 username, bytes32 neededUsername);
    event VerifiedUser(bytes32 username);
    event UserTipped(address from, bytes32 indexed username, uint val);
    event WithdrawSuccessful(bytes32 username);
    event CheckAddressVerified(address userAddress);
    event RefundSuccessful(address from, bytes32 username);
    event GoldBought(uint price, address from, bytes32 to, string months, string priceUsd, string commentId, string nonce, string signature);

    mapping(address => bool) owners;

    modifier onlyOwners() {
        require(owners[msg.sender]);
        _;
    }

    function ExtendEvents() {
        owners[msg.sender] = true;
    }

    function addOwner(address _address) onlyOwners {
        owners[_address] = true;
    }

    function removeOwner(address _address) onlyOwners {
        owners[_address] = false;
    }

    function goldBought(uint _price, 
                        address _from, 
                        bytes32 _to, 
                        string _months,
                        string _priceUsd, 
                        string _commentId,
                        string _nonce, 
                        string _signature) onlyOwners {
                            
        GoldBought(_price, _from, _to, _months, _priceUsd, _commentId, _nonce, _signature);
    }

    function createdUser(bytes32 _username) onlyOwners {
        CreatedUser(_username);
    }

    function refundSuccessful(address _from, bytes32 _username) onlyOwners {
        RefundSuccessful(_from, _username);
    }

    function usernameDoesNotMatch(bytes32 _username, bytes32 _neededUsername) onlyOwners {
        UsernameDoesNotMatch(_username, _neededUsername);
    }

    function verifiedUser(bytes32 _username) onlyOwners {
        VerifiedUser(_username);
    }

    function userTipped(address _from, bytes32 _username, uint _val) onlyOwners {
        UserTipped(_from, _username, _val);
    }

    function withdrawSuccessful(bytes32 _username) onlyOwners {
        WithdrawSuccessful(_username);
    }

    function logQuery(bytes32 _query, address _userAddress) onlyOwners {
        LogQuery(_query, _userAddress);
    }

    function logBalance(uint _balance) onlyOwners {
        LogBalance(_balance);
    }

    function logNeededBalance(uint _balance) onlyOwners {
        LogNeededBalance(_balance);
    }

}