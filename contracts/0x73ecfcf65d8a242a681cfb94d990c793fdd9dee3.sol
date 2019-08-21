pragma solidity ^0.4.24;

pragma experimental ABIEncoderV2;

contract Subby {
    event Post(address indexed publisherAddress, uint indexed postId, uint indexed timestamp, string publisherUsername, string link, string comment);
    event Donation(address indexed recipientAddress, int indexed postId, address indexed senderAddress, string recipientUsername, string senderUsername, string text, uint amount, uint timestamp);

    mapping(address => string) public addressToThumbnail;
    mapping(address => string) public addressToBio;
    mapping(address => string) public addressToUsername;
    mapping(string => address) private usernameToAddress;
    mapping(address => string[]) private addressToComments;
    mapping(address => string[]) private addressToLinks;
    mapping(address => uint[]) public addressToTimestamps;
    mapping(address => uint) public addressToMinimumTextDonation;
    mapping(address => string[]) private addressToSubscriptions;
    mapping(address => bool) public addressToIsTerminated;
    mapping(address => uint) public addressToTotalDonationsAmount;
    mapping(address => mapping(uint => uint)) public addressToPostIdToDonationsAmount;
    mapping(address => bool) public addressToHideDonationsAmounts;
   
    constructor() public {}

    function terminateAccount() public {
        addressToIsTerminated[msg.sender] = true;
    }
  
    function donate(string text, address recipientAddress, string recipientUsername, int postId) public payable {
        require(addressToIsTerminated[recipientAddress] == false, "Can't donate to terminated account.");
       
        if (bytes(recipientUsername).length > 0) {
            recipientAddress = usernameToAddress[recipientUsername];
        }
        if (bytes(text).length > 0) {
            require(addressToMinimumTextDonation[recipientAddress] > 0, "Recipient has disabled donations.");
            require(msg.value >= addressToMinimumTextDonation[recipientAddress], "Donation amount lower than recipient minimum donation.");
        }
        recipientAddress.transfer(msg.value);
        addressToTotalDonationsAmount[recipientAddress] += msg.value;
        if (postId >= 0) {
            addressToPostIdToDonationsAmount[recipientAddress][uint(postId)] += msg.value;
        }
        if (msg.value > addressToMinimumTextDonation[recipientAddress] && addressToMinimumTextDonation[recipientAddress] > 0) {
            if (postId < 0) {
                postId = -1;
            }
            if (bytes(text).length > 0) {
                emit Donation(recipientAddress, postId, msg.sender, addressToUsername[recipientAddress], addressToUsername[msg.sender], text, msg.value, now);
            }
        }
    }

    function publish(string link, string comment) public {
        require(addressToIsTerminated[msg.sender] == false, "Terminated accounts may not publish.");
        uint id = addressToComments[msg.sender].push(comment);
        addressToLinks[msg.sender].push(link);
        addressToTimestamps[msg.sender].push(now);

        emit Post(msg.sender, id, now, addressToUsername[msg.sender], link, comment);
    }

    function setMinimumTextDonation (uint value) public {
        addressToMinimumTextDonation[msg.sender] = value;
    }

    function setThumbnail(string thumbnail) public {
        addressToThumbnail[msg.sender] = thumbnail;
    }

    function setBio(string bio) public {
        addressToBio[msg.sender] = bio;
    }

    function editProfile(string thumbnail, bool changeThumbnail, string bio, bool changeBio, uint minimumTextDonation, bool changeMinimumTextDonation, bool hideDonations, bool changeHideDonations, string username, bool changeUsername) public {
        require(addressToIsTerminated[msg.sender] == false, "Cant not edit terminated account.");
        if (changeHideDonations) {
            addressToHideDonationsAmounts[msg.sender] = hideDonations;
        }
        if (changeMinimumTextDonation) {
            require(minimumTextDonation > 0, "Can not set minimumTextDonation to less than 0.");
            addressToMinimumTextDonation[msg.sender] = minimumTextDonation;
        }
        if (changeThumbnail) {
            addressToThumbnail[msg.sender] = thumbnail;
        }
        if (changeBio) {
            addressToBio[msg.sender] = bio;
        }
        if (changeUsername) {
            require(bytes(username).length < 39, "Username can not have more than 39 characters.");
            require(bytes(username).length > 0, "Username must be longer than 0 characters.");
            // Require that the name has not already been taken.
            require(usernameToAddress[username] == 0x0000000000000000000000000000000000000000, "Usernames can not be changed.");
            // Require that the sender has not already set a name.
            require(bytes(addressToUsername[msg.sender]).length == 0, "This username is already taken.");
            addressToUsername[msg.sender] = username;
            usernameToAddress[username] = msg.sender;
        }
    }

    function getProfile(address _address, string username) public view returns (address, string, uint, string[], uint, bool[]) {
        string[] memory bio_thumbnail = new string[](2);
        bool[] memory hideDonations_isTerminated = new bool[](2);
        hideDonations_isTerminated[0] = addressToHideDonationsAmounts[_address];
        hideDonations_isTerminated[1] = addressToIsTerminated[_address];
        
        if (addressToIsTerminated[_address]) {
            return (0x0000000000000000000000000000000000000000, "", 0, bio_thumbnail, 0, hideDonations_isTerminated);
        }

        if (bytes(username).length > 0) {
            _address = usernameToAddress[username];
        }

        bio_thumbnail[0] = getBio(_address);
        bio_thumbnail[1] = getThumbnail(_address);
        
        return (_address, addressToUsername[_address], addressToMinimumTextDonation[_address], bio_thumbnail,
            getTotalDonationsAmount(_address), hideDonations_isTerminated);
    }

    function getProfiles(address[] memory addresses, string[] memory usernames) public view returns (address[] memory, string[] memory, uint[]) {
        address[] memory addressesFromUsernames = getAddressesFromUsernames(usernames);
        string[] memory thumbnails_bios_usernames = new string[]((addresses.length + addressesFromUsernames.length) * 3);
        address[] memory returnAddresses = new address[](addresses.length + addressesFromUsernames.length);
        uint[] memory minimumTextDonations_totalDonationsAmounts = new uint[]((addresses.length + addressesFromUsernames.length) * 2);

        for (uint i = 0; i < addresses.length; i++) {
            thumbnails_bios_usernames[i] = getThumbnail(addresses[i]);
            thumbnails_bios_usernames[i + addresses.length + addressesFromUsernames.length] = getBio(addresses[i]);
            thumbnails_bios_usernames[i + ((addresses.length + addressesFromUsernames.length) * 2)] = getUsername(addresses[i]);
            returnAddresses[i] = addresses[i];
            minimumTextDonations_totalDonationsAmounts[i] = getMinimumTextDonation(addresses[i]);
            minimumTextDonations_totalDonationsAmounts[i + addresses.length + addressesFromUsernames.length] = getTotalDonationsAmount(addresses[i]);
        }
        for (i = 0; i < addressesFromUsernames.length; i++) {
            thumbnails_bios_usernames[i + addresses.length] = getThumbnail(addressesFromUsernames[i]);
            thumbnails_bios_usernames[i + addresses.length + addresses.length + addressesFromUsernames.length] = getBio(addressesFromUsernames[i]);
            thumbnails_bios_usernames[i + addresses.length + ((addresses.length + addressesFromUsernames.length) * 2)] = getUsername(addressesFromUsernames[i]);
            returnAddresses[i + addresses.length] = addressesFromUsernames[i];
            minimumTextDonations_totalDonationsAmounts[i + addresses.length] = getMinimumTextDonation(addressesFromUsernames[i]);
            minimumTextDonations_totalDonationsAmounts[i + addresses.length + addresses.length + addressesFromUsernames.length] = getTotalDonationsAmount(addressesFromUsernames[i]);
        }
        return (returnAddresses, thumbnails_bios_usernames, minimumTextDonations_totalDonationsAmounts);
    }
        
    function getSubscriptions(address _address, string username) public view returns (string[]) {
        if (bytes(username).length > 0) {
            _address = usernameToAddress[username];
        }
        return addressToSubscriptions[_address];
    }

    function getSubscriptionsFromSender() public view returns (string[]) {
        return addressToSubscriptions[msg.sender];
    }
    
    function syncSubscriptions(string[] subsToPush, string[] subsToOverwrite, uint[] indexesToOverwrite ) public {
        for (uint i = 0; i < indexesToOverwrite.length; i++ ) {
            addressToSubscriptions[msg.sender][indexesToOverwrite[i]] = subsToOverwrite[i];
        }
        for ( i = 0; i < subsToPush.length; i++) {
            addressToSubscriptions[msg.sender].push(subsToPush[i]);
        }
    }

    function getUsernameFromAddress(address _address) public view returns (string) {
        return addressToUsername[_address];
    }

    function getAddressFromUsername(string username) public view returns (address) {
        return usernameToAddress[username];
    }

    function getAddressesFromUsernames(string[] usernames) public view returns (address[]) {
        address[] memory returnAddresses = new address[](usernames.length);
        for (uint i = 0; i < usernames.length; i++) {
            returnAddresses[i] = usernameToAddress[usernames[i]];
        }
        return returnAddresses;
    }
    
    function getComment(address _address, uint id) public view returns (string) {
        if (addressToIsTerminated[_address]) {
            return "";
        }
        string[] memory comments = addressToComments[_address];
        if (comments.length > id) {
            return comments[id];
        }
        else {
            return "";
        }
    }
    
    function getThumbnail(address _address) public view returns (string) {
        if (addressToIsTerminated[_address]) {
            return "";
        }
        return addressToThumbnail[_address];
    }
    
    function getLink(address _address, uint id) public view returns (string) {
        if (addressToIsTerminated[_address]) {
            return "";
        }
        string[] memory links = addressToLinks[_address];
        if (links.length > id) {
            return links[id];
        }
        else {
            return "";
        }
    }

    function getBio(address _address) public view returns (string) {
        if (addressToIsTerminated[_address]) {
            return "";
        }
        return addressToBio[_address];
    }

    function getTimestamp(address _address, uint id) public view returns (uint) {
        if (addressToIsTerminated[_address]) {
            return 0;
        }
        uint[] memory timestamps = addressToTimestamps[_address];
        if (timestamps.length > id) {
            return timestamps[id];
        }
        else {
            return 0;
        }
    }

    function getTotalDonationsAmount(address _address) public view returns (uint) {
        if (addressToHideDonationsAmounts[_address]) {
            return 0;
        }
        return addressToTotalDonationsAmount[_address];
    }
    
    function getMinimumTextDonation(address _address) public view returns (uint) {
        return addressToMinimumTextDonation[_address];
    }
    
    function getUsername(address _address) public view returns (string) {
        return addressToUsername[_address];
    }

    function getLinks(address _address) public view returns (string[]) {
        return addressToLinks[_address];
    }

    function getComments(address _address) public view returns (string[]) {
        return addressToComments[_address];
    }

    function getTimestamps(address _address) public view returns (uint[]) {
        return addressToTimestamps[_address];
    }

    function getPostFromId(address _address, string username,  uint id) public view returns ( string[], address, uint, uint, uint) {
        if (bytes(username).length > 0) {
            _address = usernameToAddress[username];
        }
        string[] memory comment_link_username_thumbnail = new string[](4);
        comment_link_username_thumbnail[0] = getComment(_address, id);
        comment_link_username_thumbnail[1] = getLink(_address, id);
        comment_link_username_thumbnail[2] = getUsername(_address);
        comment_link_username_thumbnail[3] = addressToThumbnail[_address];
        uint timestamp = getTimestamp(_address, id);
        uint postDonationsAmount = getPostDonationsAmount(_address, id);

        return (comment_link_username_thumbnail, _address,  timestamp,  addressToMinimumTextDonation[_address], postDonationsAmount);
    }
    
    function getPostDonationsAmount(address _address, uint id) public view returns (uint) {
        if (addressToHideDonationsAmounts[_address]) {
            return 0;
        }
        return addressToPostIdToDonationsAmount[_address][id];
    }

    function getPostsFromIds(address[] addresses, string[] usernames, uint[] ids) public view returns (string[], address[], uint[]) {
        address[] memory addressesFromUsernames = getAddressesFromUsernames(usernames);
        string[] memory comments_links_usernames_thumbnails = new string[]((addresses.length + addressesFromUsernames.length) * 4);
        address[] memory publisherAddresses = new address[](addresses.length + addressesFromUsernames.length);
        uint[] memory minimumTextDonations_postDonationsAmount_timestamps = new uint[]((addresses.length + addressesFromUsernames.length) * 3);

        for (uint i = 0; i < addresses.length; i++) {
            comments_links_usernames_thumbnails[i] = getComment(addresses[i], ids[i]);
            comments_links_usernames_thumbnails[i + addresses.length + addressesFromUsernames.length] = getLink(addresses[i], ids[i]);
            comments_links_usernames_thumbnails[i + ((addresses.length + addressesFromUsernames.length) * 2)] = getUsername(addresses[i]);
            comments_links_usernames_thumbnails[i + ((addresses.length + addressesFromUsernames.length) * 3)] = getThumbnail(addresses[i]);
            publisherAddresses[i] = addresses[i];
            minimumTextDonations_postDonationsAmount_timestamps[i] = getMinimumTextDonation(addresses[i]);
            minimumTextDonations_postDonationsAmount_timestamps[i + addresses.length + addressesFromUsernames.length] = getPostDonationsAmount(addresses[i], ids[i]);
            minimumTextDonations_postDonationsAmount_timestamps[i + ((addresses.length + addressesFromUsernames.length) * 2)] = getTimestamp(addresses[i], ids[i]);
        }
        
        for (i = 0; i < addressesFromUsernames.length; i++) {
            comments_links_usernames_thumbnails[i + addresses.length] = getComment(addressesFromUsernames[i], ids[i + addresses.length]);
            comments_links_usernames_thumbnails[i + addresses.length + (addresses.length + addressesFromUsernames.length)] = getLink(addressesFromUsernames[i], ids[i + addresses.length]);
            comments_links_usernames_thumbnails[i + addresses.length + ((addresses.length + addressesFromUsernames.length) * 2)] = getUsername(addressesFromUsernames[i]);
            comments_links_usernames_thumbnails[i + addresses.length + ((addresses.length + addressesFromUsernames.length) * 3)] = getThumbnail(addressesFromUsernames[i]);
            publisherAddresses[i + addresses.length] = addressesFromUsernames[i];
            minimumTextDonations_postDonationsAmount_timestamps[i + addresses.length] = getMinimumTextDonation(addressesFromUsernames[i]);
            minimumTextDonations_postDonationsAmount_timestamps[i + addresses.length + (addresses.length + addressesFromUsernames.length)] = getPostDonationsAmount(addressesFromUsernames[i], ids[i + addresses.length]);
            minimumTextDonations_postDonationsAmount_timestamps[i + addresses.length + ((addresses.length + addressesFromUsernames.length) * 2)] = getTimestamp(addressesFromUsernames[i], ids[i + addresses.length]);
        }
        
        return (comments_links_usernames_thumbnails, publisherAddresses, minimumTextDonations_postDonationsAmount_timestamps);
    }
    
    function getPostsFromPublisher(address _address, string username, uint startAt, bool startAtLatestPost, uint limit)
        public view returns (string[], string[], address, uint[]) {
        if (bytes(username).length > 0) {
            _address = usernameToAddress[username];
        }
        string[] memory comments_links = new string[](limit * 2);
        string[] memory thumbnail_username = new string[](2);
        thumbnail_username[0] = addressToThumbnail[_address];
        thumbnail_username[1] = addressToUsername[_address];
        if (startAtLatestPost == true) {
            startAt = addressToComments[_address].length;
        }
        uint[] memory timestamps_postDonationsAmounts_minimumTextDonation_postCount = new uint[]((limit * 2) + 2);

        parseCommentsLinks(comments_links, _address, startAt, limit, timestamps_postDonationsAmounts_minimumTextDonation_postCount);
        timestamps_postDonationsAmounts_minimumTextDonation_postCount[limit * 2] = addressToMinimumTextDonation[_address];
        timestamps_postDonationsAmounts_minimumTextDonation_postCount[(limit * 2) + 1] = addressToComments[_address].length;
        
        return (comments_links, thumbnail_username, _address, timestamps_postDonationsAmounts_minimumTextDonation_postCount );
    }
    
    function parseCommentsLinks(string[] comments_links, 
        address _address, uint startAt, uint limit, uint[] timestamps_postDonationsAmounts_minimumTextDonation_postCount) public view {
        uint count = 0;
        for (uint i = 1; i < limit + 1; i++) {
            comments_links[count] = getComment(_address, startAt - i);
            timestamps_postDonationsAmounts_minimumTextDonation_postCount[count] = getTimestamp(_address, startAt - i);
            timestamps_postDonationsAmounts_minimumTextDonation_postCount[count + limit] = getPostDonationsAmount(_address, startAt - i);
            count++;
        } 
        for (i = 1; i < limit + 1; i++) {
            comments_links[count] = getLink(_address, startAt - i);
            count++;
        } 
    }

    function getTimestampsFromPublishers(address[] addresses, string[] usernames, int[] startAts, int limit) public view returns (uint[], uint[]) {
        uint[] memory returnTimestamps = new uint[]((addresses.length + usernames.length) * uint(limit));
        uint[] memory publisherPostCounts = new uint[](addresses.length + usernames.length);
        uint timestampIndex = 0;
        uint addressesPlusUsernamesIndex = 0;
        for (uint i = 0; i < addresses.length; i++) {
            address _address = addresses[i];
            // startAt is the first index that will be returned.
            int startAt;
            if (startAts.length == 0) {
                startAt = int(addressToTimestamps[_address].length - 1);
            } else {
                startAt = startAts[addressesPlusUsernamesIndex];
            }
            // Collect timestamps, starting from startAt and counting down to 0 until limit is reached.
            for (int j = 0; j < limit; j++) {
                if (addressToIsTerminated[_address] == false && ((startAt - j) >= 0) && ((startAt - j) < int(addressToTimestamps[_address].length))) {
                    returnTimestamps[timestampIndex] = addressToTimestamps[_address][uint(startAt - j)];
                } else {
                    returnTimestamps[timestampIndex] = 0;
                }
                timestampIndex++;
            }
            publisherPostCounts[addressesPlusUsernamesIndex] = addressToTimestamps[_address].length;
            addressesPlusUsernamesIndex++;
        }
        // Do the same thing as above, but with usernames instead of addresses. Code duplication is essential to save gas.
        if (usernames.length > 0) {
            addresses = getAddressesFromUsernames(usernames);
            for (i = 0; i < addresses.length; i++) {
                _address = addresses[i];
                if (startAts.length == 0) {
                    startAt = int(addressToTimestamps[_address].length - 1);
                } else {
                    startAt = startAts[addressesPlusUsernamesIndex];
                }
                for (j = 0; j < limit; j++) {
                    if (addressToIsTerminated[_address] == false && ((startAt - j) >= 0) && ((startAt - j) < int(addressToTimestamps[_address].length))) {
                        returnTimestamps[timestampIndex] = addressToTimestamps[_address][uint(startAt - j)];
                    } else {
                        returnTimestamps[timestampIndex] = 0;
                    }
                    timestampIndex++;
                }
                publisherPostCounts[addressesPlusUsernamesIndex] = addressToTimestamps[_address].length;
                addressesPlusUsernamesIndex++;
            }
        }
        return (returnTimestamps, publisherPostCounts);
    }
}