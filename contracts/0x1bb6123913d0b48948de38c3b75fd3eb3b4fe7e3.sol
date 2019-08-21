contract EtherAds {
    // define some events
    event BuyAd(address etherAddress, uint amount, string href, string anchor, string imgId, uint headerColor, uint8 countryId, address referral);
    event ResetContract();
    event PayoutEarnings(address etherAddress, uint amount, uint8 referralLevel);
    struct Ad {
        address etherAddress;
        uint amount;
        string href;
        string anchor;
        string imgId;
        uint8 countryId;
        int refId;
    }
    struct charityFundation {
        string href;
        string anchor;
        string imgId;
    }
    charityFundation[] public charityFundations;
    uint public charityFoundationIdx = 0;
    string public officialWebsite;
    Ad[] public ads;
    uint public payoutIdx = 0;
    uint public balance = 0;
    uint public fees = 0;
    uint public contractExpirationTime;
    uint public headerColor = 0x000000;
    uint public maximumDeposit = 42 ether;
    // keep prices levels
    uint[7] public txsThreshold = [10, 20, 50, 100, 200, 500, 1000];
    // prolongate hours for each txs level
    uint[8] public prolongH = [
        336 hours, 168 hours, 67 hours, 33 hours,
        16 hours, 6 hours, 3 hours, 1 hours
    ];
    // minimal deposits for each txs level
    uint[8] public minDeposits = [
        100 szabo, 400 szabo, 2500 szabo, 10 finney,
        40 finney, 250 finney, 1 ether, 5 ether
    ];
    // this array stores number of txs per each hour
    uint[24] public txsPerHour;
    uint public lastHour; // store last hour for txs number calculation
    uint public frozenMinDeposit = 0;
    // owners
    address[3] owners;
    // simple onlyowners function modifier
    modifier onlyowners {
        if (msg.sender == owners[0] || msg.sender == owners[1] || msg.sender == owners[2]) _
    }
    // create contract with 3 owners
    function EtherAds(address owner0, address owner1, address owner2) {
        owners[0] = owner0;
        owners[1] = owner1;
        owners[2] = owner2;
    }
    // // dont allow to waste money
    // function() {
    //     // the creators are like Satoshi
    //     // Bitcoin is important,
    //     // but Ethereum is better :-)
    //     throw;
    // }
    // buy add for charity fundation if just ethers was sent
    function() {
        buyAd(
            charityFundations[charityFoundationIdx].href,
            charityFundations[charityFoundationIdx].anchor,
            charityFundations[charityFoundationIdx].imgId,
            0xff8000,
            0, // charity flag
            msg.sender
        );
        charityFoundationIdx += 1;
        if (charityFoundationIdx >= charityFundations.length) {
            charityFoundationIdx = 0;
        }
    }
    // buy add
    function buyAd(string href, string anchor, string imgId, uint _headerColor, uint8 countryId, address referral) {
        uint value = msg.value;
        uint minimalDeposit = getMinimalDeposit();
        // dont allow to get in with too low deposit
        if (value < minimalDeposit) throw;
        // dont allow to invest more than 42
        if (value > maximumDeposit) {
            msg.sender.send(value - maximumDeposit);
            value = maximumDeposit;
        }
        // cancel buy if strings are too long
        if (bytes(href).length > 100 || bytes(anchor).length > 50) throw;
        // reset ads if last transaction reached outdateDuration
        resetContract();
        // store new ad id
        uint id = ads.length;
        // add new ad entry in storage
        ads.length += 1;
        ads[id].etherAddress = msg.sender;
        ads[id].amount = value;
        ads[id].href = href;
        ads[id].imgId = imgId;
        ads[id].anchor = anchor;
        ads[id].countryId = countryId;
        // add sent value to balance
        balance += value;
        // set header color
        headerColor = _headerColor;
        // call event
        BuyAd(msg.sender, value, href, anchor, imgId, _headerColor, countryId, referral);
        updateTxStats();
        // find referral id in ads and keep its id in storage
        setReferralId(id, referral);
        distributeEarnings();
    }
    function prolongateContract() private {
        uint level = getCurrentLevel();
        contractExpirationTime = now + prolongH[level];
    }
    function getMinimalDeposit() returns (uint) {
        uint txsThresholdIndex = getCurrentLevel();
        if (minDeposits[txsThresholdIndex] > frozenMinDeposit) {
            frozenMinDeposit = minDeposits[txsThresholdIndex];
        }
        return frozenMinDeposit;
    }
    function getCurrentLevel() returns (uint) {
        uint txsPerLast24hours = 0;
        uint i = 0;
        while (i < 24) {
            txsPerLast24hours += txsPerHour[i];
            i += 1;
        }
        i = 0;
        while (txsPerLast24hours > txsThreshold[i]) {
            i = i + 1;
        }
        return i;
    }
    function updateTxStats() private {
        uint currtHour = now / (60 * 60);
        uint txsCounter = txsPerHour[currtHour];
        if (lastHour < currtHour) {
            txsCounter = 0;
            lastHour = currtHour;
        }
        txsCounter += 1;
        txsPerHour[currtHour] = txsCounter;
    }
    // distribute earnings to participants
    function distributeEarnings() private {
        // start infinite payout while ;)
        while (true) {
            // calculate doubled payout
            uint amount = ads[payoutIdx].amount * 2;
            // if balance is enough to pay participant
            if (balance >= amount) {
                // send earnings - fee to participant
                ads[payoutIdx].etherAddress.send(amount / 100 * 80);
                PayoutEarnings(ads[payoutIdx].etherAddress, amount / 100 * 80, 0);
                // collect 15% fees
                fees += amount / 100 * 15;
                // calculate 5% 3-levels fees
                uint level0Fee = amount / 1000 * 25; // 2.5%
                uint level1Fee = amount / 1000 * 15; // 1.5%
                uint level2Fee = amount / 1000 * 10; // 1.0%
                // find 
                int refId = ads[payoutIdx].refId;
                if (refId == -1) {
                    // no refs, no fun :-)
                    balance += level0Fee + level1Fee + level2Fee;
                } else {
                    ads[uint(refId)].etherAddress.send(level0Fee);
                    PayoutEarnings(ads[uint(refId)].etherAddress, level0Fee, 1);
                    
                    refId = ads[uint(refId)].refId;
                    if (refId == -1) {
                        // no grand refs, no grand fun
                        balance += level1Fee + level2Fee;
                    } else {
                        // have grand children :-)
                        ads[uint(refId)].etherAddress.send(level1Fee);
                        PayoutEarnings(ads[uint(refId)].etherAddress, level1Fee, 2);
                     
                        refId = ads[uint(refId)].refId;
                        if (refId == -1) {
                            // no grand grand refs, no grand grand fun (great grandfather - satoshi is drunk)
                            balance += level2Fee;
                        } else {
                            // have grand grand children :-)
                            ads[uint(refId)].etherAddress.send(level2Fee);
                            PayoutEarnings(ads[uint(refId)].etherAddress, level2Fee, 3);
                        }
                    }
                }
                balance -= amount;
                payoutIdx += 1;
            } else {
                // if there was no any payouts (too low balance), cancel while loop
                // YOU CANNOT GET BLOOD OUT OF A STONE :-)
                break;
            }
        }
    }
    // check if contract is outdate which means there was no any transacions
    // since (now - outdateDuration) seconds and its going to reset
    function resetContract() private {
        // like in bible, the last are the first :-)
        if (now > contractExpirationTime) {
            // pay 50% of balance to last investor
            balance = balance / 2;
            ads[ads.length-1].etherAddress.send(balance);
            // clear ads storage
            ads.length = 0;
            // reset payout counter
            payoutIdx = 0;
            contractExpirationTime = now + 14 days;
            frozenMinDeposit = 0;
            // clear txs counter
            uint i = 0;
            while (i < 24) {
                txsPerHour[i] = 0;
                i += 1;
            }
            // call event
            ResetContract();
        }
    }
    // find and set referral Id
    function setReferralId(uint id, address referral) private {
        uint i = 0;
        // if referral address will be not found than keep -1 value
        // which means that ad purshared was not referred by anyone
        int refId = -1;
        // go through all ads and try to find referral address in this array
        while (i < ads.length) {
            // if ref was found end while
            if (ads[i].etherAddress == referral) {
                refId = int(i);
                break;
            }
            i += 1;
        }
        // if ref was not found than we have -1 value here
        ads[id].refId = refId;
    }

    // send fees to all contract owners
    function collectFees() onlyowners {
        if (fees == 0) return; // buy more ads
        uint sharedFee = fees / 3;
        uint i = 0;
        while (i < 3) {
            owners[i].send(sharedFee);
            i += 1;
        }
        // reset fees counter
        fees = 0;
    }
    // change single ownership
    function changeOwner(address newOwner) onlyowners {
        uint i = 0;
        while (i < 3) {
            // check if you are owner
            if (msg.sender == owners[i]) {
                // change ownership
                owners[i] = newOwner;
            }
            i += 1;
        }
    }
    // set official contract front-end website
    function setOfficialWebsite(string url) onlyowners {
        officialWebsite = url;
    }
    // add new charity foundation to the list
    function addCharityFundation(string href, string anchor, string imgId) onlyowners {
        uint id = charityFundations.length;
        // add new ad entry in storage
        charityFundations.length += 1;
        charityFundations[id].href = href;
        charityFundations[id].anchor = anchor;
        charityFundations[id].imgId = imgId;
    }
    // clear charity foundations list, to make new one
    function resetFoundationtList() onlyowners {
        charityFundations.length = 0;
    }
    function giveMeat() onlyowners {
        // add free financig to contract, lets FUN!
        balance += msg.value;
    }
}