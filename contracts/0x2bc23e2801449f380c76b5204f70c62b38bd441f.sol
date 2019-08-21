pragma solidity ^0.4.24;

interface ERC725 {
    function keyHasPurpose(bytes32 _key, uint256 _purpose) public view returns (bool result);
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
interface ERC20Basic {
	function balanceOf(address who) public constant returns (uint256);
}


interface ProfileStorage {
	function getStake(address identity) public view returns(uint256);
}

/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor () public {
        owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract Voting is Ownable {
	mapping(address => bool) public walletApproved;
	mapping(address => bool) public walletVoted;

	ERC20Basic public tokenContract;
	ProfileStorage public profileStorageContract;

	uint256 public votingClosingTime;

	struct Candidate{
		string name;
		uint256 votes;
	}

	Candidate[34] public candidates;

	constructor (address tokenContractAddress, address profileStorageContractAddress) public {
		tokenContract = ERC20Basic(tokenContractAddress);
		profileStorageContract = ProfileStorage(profileStorageContractAddress);

		votingClosingTime = 0;

		 candidates[0].name = "Air Sourcing";
		 candidates[1].name = "Ametlab";
		 candidates[2].name = "B2B Section of Slovenian Blockchain Association (SBCA)";
		 candidates[3].name = "Beleaf & Co";
		 candidates[4].name = "BioGenom 2.0";
		 candidates[5].name = "CAM Engineering";
		 candidates[6].name = "Dispensa Dei Tipici";
		 candidates[7].name = "Fuzzy Factory";
		 candidates[8].name = "GSC Platform";
		 candidates[9].name = "HydraWarehouse";
		candidates[10].name = "Ibis Eteh";
		candidates[11].name = "Infotrans";
		candidates[12].name = "Intelisale";
		candidates[13].name = "Istmos";
		candidates[14].name = "Ivy Food Tech";
		candidates[15].name = "Journey Foods";
		candidates[16].name = "Kakaxi";
		candidates[17].name = "L.Co";
		candidates[18].name = "LynqWallet";
		candidates[19].name = "MedicoHealth AG";
		candidates[20].name = "Moku Menehune";
		candidates[21].name = "NetSDL";
		candidates[22].name = "Orchit";
		candidates[23].name = "Phy2Trace";
		candidates[24].name = "Procurean";
		candidates[25].name = "PsyChain";
		candidates[26].name = "RealMeal";
		candidates[27].name = "Reterms";
		candidates[28].name = "Sensefinity";
		candidates[29].name = "Solomon Ears";
		candidates[30].name = "Space Invoices";
		candidates[31].name = "Step Online";
		candidates[32].name = "TMA";
		candidates[33].name = "Zemlja&Morje";
	}

	// Enabling and disabling the voting process
	function startVoting() public onlyOwner {
		require(votingClosingTime == 0, "Voting already started once!");
		votingClosingTime = block.timestamp + 7 days;
	}

	event WalletApproved(address wallet, address ERC725Address);
	event WalletRejected(address wallet, address ERC725Address, string reason);
	event WalletVoted(address wallet, string firstChoice, string secondChoice, string thirdChoice);

	// Setting and getting voting approval for wallets
	function approveMultipleWallets(address[] wallets, address[] ERC725Addresses) public onlyOwner {
		require(votingClosingTime == 0, "Voting already started!");
		require(wallets.length <= 50, "Cannot approve more than 50 wallets at a time!");
		require(wallets.length == ERC725Addresses.length, "Arrays are not the same length!");
		uint256 i = 0;
		for(i = 0; i < wallets.length && i < 50; i = i + 1) {
			walletApproved[wallets[i]] = false;

			if (wallets[i] == address(0) && ERC725Addresses[i] == address(0)) {
				emit WalletRejected(wallets[i], ERC725Addresses[i], 
						"Cannot verify an empty application!");
			}
			else {
				if(ERC725Addresses[i] != address(0)) {
					if(profileStorageContract.getStake(ERC725Addresses[i]) >= 10^21) {
						walletApproved[ERC725Addresses[i]] = true;
						emit WalletApproved(address(0), ERC725Addresses[i]);
					}
					else {
						emit WalletRejected(wallets[i], ERC725Addresses[i], 
							"Profile does not have at least 1000 trac at the time of approval!");
					}	
				}
				else {
					// Only wallet was submitted 
						// -> Verify wallet balance and approve wallet
					if(tokenContract.balanceOf(wallets[i]) >= 10^21) {
						walletApproved[wallets[i]] = true;
						emit WalletApproved(wallets[i], address(0));
					}
					else {
						emit WalletRejected(wallets[i], address(0), 
							"Wallet does not have at least 1000 trac at the time of approval!");
					}
				}
			}
		}
	}
	function disapproveMultipleWallets(address[] wallets) public onlyOwner {
		require(wallets.length <= 50, "Cannot approve more than 50 wallets at a time!");
		uint256 i = 0;
		for(i = 0; i < wallets.length && i < 50; i = i + 1) {
			walletApproved[wallets[i]] = false;
			emit WalletRejected(wallets[i], address(0), "Wallet approval removed!");
		}
	}
	function isWalletApproved(address wallet) public view returns (bool) {
		return walletApproved[wallet];
	}


	function vote(uint256[] candidateIndexes) public {
		require(votingClosingTime != 0, "Voting has not yet started!");
		require(votingClosingTime >= block.timestamp, "Voting period has expired!");

		require(walletApproved[msg.sender] == true, "Sender is not approved and thus cannot vote!");
		
		require(walletVoted[msg.sender] == false, "Sender already voted!");

		require(candidateIndexes.length == 3, "Must vote for 3 candidates!");

		require(candidateIndexes[0] != candidateIndexes[1], "Cannot cast multiple votes for the same person!");
		require(candidateIndexes[1] != candidateIndexes[2], "Cannot cast multiple votes for the same person!");
		require(candidateIndexes[2] != candidateIndexes[0], "Cannot cast multiple votes for the same person!");

		require(candidateIndexes[0] >= 0 && candidateIndexes[0] < candidates.length, "The selected candidate does not exist!");
		require(candidateIndexes[1] >= 0 && candidateIndexes[1] < candidates.length, "The selected candidate does not exist!");
		require(candidateIndexes[2] >= 0 && candidateIndexes[2] < candidates.length, "The selected candidate does not exist!");

		walletVoted[msg.sender] = true;
		emit WalletVoted(msg.sender, candidates[candidateIndexes[0]].name, candidates[candidateIndexes[1]].name, candidates[candidateIndexes[2]].name);

		assert(candidates[candidateIndexes[0]].votes + 3 > candidates[candidateIndexes[0]].votes);
		candidates[candidateIndexes[0]].votes = candidates[candidateIndexes[0]].votes + 3;		

		assert(candidates[candidateIndexes[1]].votes + 2 > candidates[candidateIndexes[1]].votes);
		candidates[candidateIndexes[1]].votes = candidates[candidateIndexes[1]].votes + 2;		
	
		assert(candidates[candidateIndexes[2]].votes + 1 > candidates[candidateIndexes[2]].votes);
		candidates[candidateIndexes[2]].votes = candidates[candidateIndexes[2]].votes + 1;		
	
		require(tokenContract.balanceOf(msg.sender) >= 10^21, "Sender does not have at least 1000 TRAC and thus cannot vote!");
	}

	function voteWithProfile(uint256[] candidateIndexes, address ERC725Address) public {
		require(votingClosingTime != 0, "Voting has not yet started!");
		require(votingClosingTime >= block.timestamp, "Voting period has expired!");
		
		require(walletApproved[msg.sender] == true || walletApproved[ERC725Address] == true, "Sender is not approved and thus cannot vote!");

		require(walletVoted[msg.sender] == false, "Sender already voted!");
		require(walletVoted[ERC725Address] == false, "Profile was already used for voting!");

		require(candidateIndexes.length == 3, "Must vote for 3 candidates!");

		require(candidateIndexes[0] != candidateIndexes[1], "Cannot cast multiple votes for the same person!");
		require(candidateIndexes[1] != candidateIndexes[2], "Cannot cast multiple votes for the same person!");
		require(candidateIndexes[2] != candidateIndexes[0], "Cannot cast multiple votes for the same person!");

		require(candidateIndexes[0] >= 0 && candidateIndexes[0] < candidates.length, "The selected candidate does not exist!");
		require(candidateIndexes[1] >= 0 && candidateIndexes[1] < candidates.length, "The selected candidate does not exist!");
		require(candidateIndexes[2] >= 0 && candidateIndexes[2] < candidates.length, "The selected candidate does not exist!");

		walletVoted[msg.sender] = true;
		walletVoted[ERC725Address] = true;
		emit WalletVoted(msg.sender, candidates[candidateIndexes[0]].name, candidates[candidateIndexes[1]].name, candidates[candidateIndexes[2]].name);
		
		assert(candidates[candidateIndexes[0]].votes + 3 > candidates[candidateIndexes[0]].votes);
		candidates[candidateIndexes[0]].votes = candidates[candidateIndexes[0]].votes + 3;		

		assert(candidates[candidateIndexes[1]].votes + 2 > candidates[candidateIndexes[1]].votes);
		candidates[candidateIndexes[1]].votes = candidates[candidateIndexes[1]].votes + 2;		
	
		assert(candidates[candidateIndexes[2]].votes + 1 > candidates[candidateIndexes[2]].votes);
		candidates[candidateIndexes[2]].votes = candidates[candidateIndexes[2]].votes + 1;		

		require(ERC725(ERC725Address).keyHasPurpose(keccak256(abi.encodePacked(msg.sender)), 2), 
			"Sender is not the management wallet for this ERC725 identity!");
			
		require(tokenContract.balanceOf(msg.sender) >= 10^21 || profileStorageContract.getStake(ERC725Address) >= 10^21,
		    "Neither the sender nor the submitted profile have at least 1000 TRAC and thus cannot vote!");
	}
}