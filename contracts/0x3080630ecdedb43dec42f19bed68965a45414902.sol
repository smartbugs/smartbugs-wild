// Welcome to the source code of the unofficial Etheremon Swap smart contract! This allows MonSeekers to trustlessly trade mons with each other.
// You can offer up any specific Etheremon you own in exchange for any other specific mon or any mon of a specific class.
// For example, you can offer up your Berrball in exchange for any Dracobra.
// Or you can offer it in exchange for some specific mon specified by object ID, like that level 50 Pangrass named "Donny".
// You can even keep both offers up at once if you want.
// If someone has an offer up that your mon qualifies for (for example if "Donny" belongs to you or you happen to own a Dracobra), you can match that offer to execute the trade, instantly transferring the mons to their new owners.

pragma solidity ^0.4.19;

contract Ownable
{
    address public owner;
    
    modifier onlyOwner
    {
        require(msg.sender == owner);
        _;
    }
    
    function Ownable() public
    {
        owner = msg.sender;
    }
}

// Interface for the official Etheremon Data contract.
contract EtheremonData
{
    function getMonsterObj(uint64 _objId) constant public returns(uint64 objId, uint32 classId, address trainer, uint32 exp, uint32 createIndex, uint32 lastClaimIndex, uint createTime);
}

// Interface for the official Etheremon Trade contract.
contract EtheremonTrade
{
    function freeTransferItem(uint64 _objId, address _receiver) external;
}

// Deposit contract. Each trader has a unique one which is generated ONCE and never changes.
// To trade a mon, it must be deposited in your deposit address. You can't trade mons that aren't deposited!
// Each trader has complete control over mons in their deposit address, so only send YOUR mons to YOUR unique deposit address!
// Sending a mon to someone else's deposit address is the same as giving them the mon for free.
// Finally, make sure you actually GENERATE a deposit address before depositing mons.
// If you haven't generated one before then your deposit address will appear to be 0x000... which is NOT A REAL DEPOSIT ADDRESS! Any mons sent to 0x000... will be lost forever!
contract EtheremonDepositContract is Ownable
{
    function sendMon(address tradeAddress, address receiver, uint64 mon) external onlyOwner // The "owner" is always the EtheremonSwap contract itself because it created this deposit contract on your behalf.
    {
        EtheremonTrade(tradeAddress).freeTransferItem(mon, receiver);
    }
}

// This is the main contract. This needs an owner (it's me, hi!) because it is possible for Etheremon's Trade contract to be upgraded. The owner of this contract is responsible for updating the Trade address if/when that happens.
// Eventually Etheremon will be fully decentralized and we can be sure the Trade contract will never be changed. After that happens the owner of THIS contract will be set to 0x0, effectively revoking ownership.
// The only power the contract owner has is changing the address pointing to the official Etheremon Trade contract.
// If the contract owner is compromised, the worst that could happen is you will no longer be able to trade mons through this contract.
// It is NOT possible for the contract owner to withdraw anyone else's mons.
// It is NOT possible for the contract owner to sever the link between a user and their deposit address.
// It is NOT possible for the contract owner to prevent a user from withdrawing their deposited mons.
// Even if the contract owner tried to set up his own malicious copy of the Trade contract, only the official Etheremon Trade contract has the authority to transfer mons, so nothing could be accomplished that way.
contract EtheremonSwap is Ownable
{
    address public dataAddress = 0xabc1c404424bdf24c19a5cc5ef8f47781d18eb3e;
    address public tradeAddress = 0x4ba72f0f8dad13709ee28a992869e79d0fe47030;
    
    mapping(address => address) public depositAddress;
    mapping(uint64 => address) public monToTrainer; // Only valid for POSTED mons.
    mapping(uint64 => uint64) public listedMonForMon;
    mapping(uint64 => uint32) public listedMonForClass;
    
    // Included here instead of Ownable because the Deposit contracts don't need it.
    function changeOwner(address newOwner) onlyOwner external
    {
        owner = newOwner;
    }
    
    function setTradeAddress(address _tradeAddress) onlyOwner external
    {
        tradeAddress = _tradeAddress;
    }
    
    // Generates a new deposit address for the sender.
    function generateDepositAddress() external
    {
        require(depositAddress[msg.sender] == 0); // Any given address may only have one deposit address at a time.
        depositAddress[msg.sender] = new EtheremonDepositContract();
    }
    
    // Withdraws the given mon from your deposit address. Only reason to do this is if someone changed their mind about trading a mon.
    function withdrawMon(uint64 mon) external
    {
        // Only possible to withdraw if you have a deposit address in the first place.
        require(depositAddress[msg.sender] != 0);
        // Delist the mon from any posted trades.
        delist(mon);
        // Execute the withdrawal. No need to check ownership or anything; Etheremon's official trade contract will revert this transaction for us if there's a problem.
        EtheremonDepositContract(depositAddress[msg.sender]).sendMon(tradeAddress, msg.sender, mon);
    }
    
    // If the contract owner is compromised or has failed to update the reference to the Trade contract after an Etheremon upgrade,
    // you can use this function to withdraw any deposited mons by providing the address of the official Etheremon Trade contract.
    function emergencyWithdraw(address _tradeAddress, uint64 mon) external
    {
        // Exactly the same as the regular withdrawal but with a user-provided trade address.
        require(depositAddress[msg.sender] != 0);
        delist(mon);
        EtheremonDepositContract(depositAddress[msg.sender]).sendMon(_tradeAddress, msg.sender, mon);
    }
    
    // Posts a trade offering up your mon for ONLY the given mon.
    // Will replace this mon's currently listed Mon-for-Mon trade if it exists.
    // Will NOT replace this mon's currently listed Mon-for-Class trade if it exists!
    function postMonForMon(uint64 yourMon, uint64 desiredMon) external
    {
        // Make sure you own and have deposited the mon you're posting.
        checkOwnership(yourMon);
        // Make sure you're requesting a valid mon.
        require(desiredMon != 0);
        
        listedMonForMon[yourMon] = desiredMon;
        
        monToTrainer[yourMon] = msg.sender;
    }
    
    // Posts a trade offering up your mon for ANY mon of the given class.
    // To figure out the class ID, just look at the URL of that mon's page.
    // For example, Tygloo is class 33: https://www.etheremon.com/#/mons/33
    // Will replace this mon's currently listed Mon-for-Class trade if it exists.
    // Will NOT replace this mon's currently listed Mon-for-Mon trade if it exists!
    function postMonForClass(uint64 yourMon, uint32 desiredClass) external
    {
        // Make sure you own and have deposited the mon you're posting.
        checkOwnership(yourMon);
        // Make sure you're requesting a valid class.
        require(desiredClass != 0);
        
        listedMonForClass[yourMon] = desiredClass;
        
        monToTrainer[yourMon] = msg.sender;
    }
    
    // Delists the given mon from all posted trades. This is only useful if you still want to trade it later.
    // If you just want to modify your listing, use appropriate the postMon functions instead.
    // If you just want your mon back, use withdrawMon. Withdrawn mons get delisted automatically.
    function delistMon(uint64 mon) external
    {
        // Make sure the mon is both listed and owned by the sender.
        require(monToTrainer[mon] == msg.sender);
        delist(mon);
    }
    
    // Matches a posted trade.
    function trade(uint64 yourMon, uint64 desiredMon) external
    {
        // No need to waste gas checking for weird uncommon situations (like yourMon and desiredMon being owned by
        // the same address or even being the same mon) because the trade will revert in those situations anyway.
        
        // Make sure you own and have deposited the mon you're offering.
        checkOwnership(yourMon);
        
        // If there's no exact match...
        if(listedMonForMon[desiredMon] != yourMon)
        {
            // ...check for a class match.
            uint32 class;
            (,class,,,,,) = EtheremonData(dataAddress).getMonsterObj(yourMon);
            require(listedMonForClass[desiredMon] == class);
        }
        
        // If we reached this point, we have a match. Now we execute the trade.
        executeTrade(msg.sender, yourMon, monToTrainer[desiredMon], desiredMon);
        
        // The trade was successful. Delist all mons involved.
        delist(yourMon);
        delist(desiredMon);
    }
    
    // Ensures the sender owns and has deposited the given mon.
    function checkOwnership(uint64 mon) private view
    {
        require(depositAddress[msg.sender] != 0); // Obviously you must have a deposit address in the first place.
        
        address trainer;
        (,,trainer,,,,) = EtheremonData(dataAddress).getMonsterObj(mon);
        require(trainer == depositAddress[msg.sender]);
    }
    
    // Executes a trade, swapping the mons between trainer A and trainer B.
    // No withdrawal is necessary: the mons end up in the trainers' actual addresses, NOT their deposit addresses!
    function executeTrade(address trainerA, uint64 monA, address trainerB, uint64 monB) private
    {
        EtheremonDepositContract(depositAddress[trainerA]).sendMon(tradeAddress, trainerB, monA); // Mon A from trainer A to trainer B.
        EtheremonDepositContract(depositAddress[trainerB]).sendMon(tradeAddress, trainerA, monB); // Mon B from trainer B to trainer A.
    }
    
    // Delists the given mon from any posted trades.
    function delist(uint64 mon) private
    {
        if(listedMonForMon  [mon] != 0){listedMonForMon  [mon] = 0;}
        if(listedMonForClass[mon] != 0){listedMonForClass[mon] = 0;}
        if(monToTrainer     [mon] != 0){monToTrainer     [mon] = 0;}
    }
}