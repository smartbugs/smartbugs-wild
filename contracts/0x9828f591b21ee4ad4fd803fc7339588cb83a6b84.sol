/// Simple contract that collects money, keeps them till the certain birthday
/// time and then allows certain recipient to take the collected money.
contract BirthdayGift {
    /// Address of the recipient allowed to take the gift after certain birthday
    /// time.
    address public recipient;

    /// Birthday time, the gift could be taken after.
    uint public birthday;

    /// Congratulate recipient and give the gift.
    ///
    /// @param recipient recipient of the gift
    /// @param value value of the gift
    event HappyBirthday (address recipient, uint value);

    /// Instantiate the contract with given recipient and birthday time.
    ///
    /// @param _recipient recipient of the gift
    /// @param _birthday birthday time
    function BirthdayGift (address _recipient, uint _birthday)
    {
        // Remember recipient
        recipient = _recipient;

        // Remember birthday time
        birthday = _birthday;
    }

    /// Collect money if birthday time didn't come yet.
    function ()
    {
        // Do not collect after birthday time
        if (block.timestamp >= birthday) throw;
    }

    /// Take a gift.
    function Take ()
    {
        // Only proper recipient is allowed to take the gift
        if (msg.sender != recipient) throw;

        // Gift couldn't be taken before birthday time
        if (block.timestamp < birthday) throw;

        // Let's congratulate our recipient
        HappyBirthday (recipient, this.balance);

        // And finally give the gift!
        if (!recipient.send (this.balance)) throw;
    }
}