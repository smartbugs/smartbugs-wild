pragma solidity ^0.4.15;

contract Owned {

    // The address of the account that is the current owner 
    address internal owner;


    /**
     * The publisher is the inital owner
     */
    function Owned() {
        owner = msg.sender;
    }


    /**
     * Access is restricted to the current owner
     */
    modifier only_owner() {
        require(msg.sender == owner);

        _;
    }
}


contract IOwnership {

    /**
     * Returns true if `_account` is the current owner
     *
     * @param _account The address to test against
     */
    function isOwner(address _account) constant returns (bool);


    /**
     * Gets the current owner
     *
     * @return address The current owner
     */
    function getOwner() constant returns (address);
}


contract Ownership is IOwnership, Owned {


    /**
     * Returns true if `_account` is the current owner
     *
     * @param _account The address to test against
     */
    function isOwner(address _account) public constant returns (bool) {
        return _account == owner;
    }


    /**
     * Gets the current owner
     *
     * @return address The current owner
     */
    function getOwner() public constant returns (address) {
        return owner;
    }
}


contract ITransferableOwnership {

    /**
     * Transfer ownership to `_newOwner`
     *
     * @param _newOwner The address of the account that will become the new owner 
     */
    function transferOwnership(address _newOwner);
}


contract TransferableOwnership is ITransferableOwnership, Ownership {


    /**
     * Transfer ownership to `_newOwner`
     *
     * @param _newOwner The address of the account that will become the new owner 
     */
    function transferOwnership(address _newOwner) public only_owner {
        owner = _newOwner;
    }
}


/**
 * @title IWhitelist 
 *
 * Whitelist authentication interface
 *
 * #created 04/10/2017
 * #author Frank Bonnet
 */
contract IWhitelist {
    

    /**
     * Authenticate 
     *
     * Returns whether `_account` is on the whitelist
     *
     * @param _account The account to authenticate
     * @return whether `_account` is successfully authenticated
     */
    function authenticate(address _account) constant returns (bool);
}


/**
 * @title Whitelist 
 *
 * Whitelist authentication list
 *
 * #created 04/10/2017
 * #author Frank Bonnet
 */
contract Whitelist is IWhitelist, TransferableOwnership {

    struct Entry {
        uint datetime;
        bool accepted;
        uint index;
    }

    mapping (address => Entry) internal list;
    address[] internal listIndex;


    /**
     * Returns whether an entry exists for `_account`
     *
     * @param _account The account to check
     * @return whether `_account` is has an entry in the whitelist
     */
    function hasEntry(address _account) public constant returns (bool) {
        return listIndex.length > 0 && _account == listIndex[list[_account].index];
    }


    /**
     * Add `_account` to the whitelist
     *
     * If an account is currently disabled, the account is reenabled. Otherwise 
     * a new entry is created
     *
     * @param _account The account to add
     */
    function add(address _account) public only_owner {
        if (!hasEntry(_account)) {
            list[_account] = Entry(
                now, true, listIndex.push(_account) - 1);
        } else {
            Entry storage entry = list[_account];
            if (!entry.accepted) {
                entry.accepted = true;
                entry.datetime = now;
            }
        }
    }


    /**
     * Remove `_account` from the whitelist
     *
     * Will not actually remove the entry but disable it by updating
     * the accepted record
     *
     * @param _account The account to remove
     */
    function remove(address _account) public only_owner {
        if (hasEntry(_account)) {
            Entry storage entry = list[_account];
            entry.accepted = false;
            entry.datetime = now;
        }
    }


    /**
     * Authenticate 
     *
     * Returns whether `_account` is on the whitelist
     *
     * @param _account The account to authenticate
     * @return whether `_account` is successfully authenticated
     */
    function authenticate(address _account) public constant returns (bool) {
        return list[_account].accepted;
    }
}