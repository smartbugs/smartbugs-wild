pragma solidity ^0.4.11;

/*

--------------------
Distribute PP Tokens
Token: AION
Qty: 520000
--------------------
METHODS:
tokenTest() -- Sends 1 token to the multisig address
withdrawAll() -- Withdraws tokens to all payee addresses, withholding a quantity for gas cost
changeToken(address _token) -- Changes ERC20 token contract address
returnToSender() -- Returns all tokens and ETH to the multisig address
abort() -- Returns all tokens and ETH to the multisig address, then suicides
--------------------

*/

// ERC20 Interface: https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
	function transfer(address _to, uint _value) returns (bool success);
	function balanceOf(address _owner) constant returns (uint balance);
}

contract Distribute {

	// The ICO token address
	ERC20 public token = ERC20(0x4CEdA7906a5Ed2179785Cd3A40A69ee8bc99C466); // AION

	// ETH to token exchange rate (in tokens)
	uint public ethToTokenRate = 584; // AION tokens  THIS RATE WILL LEAVE APPROX 500 TOKENS BEHIND

	// ICO multisig address
	address public multisig = 0x0d6C24d85680a89152012F9dC81e406183489C1F; // AION multisig

	// Tokens to withhold per person (to cover gas costs)  // SEE ABOVE
	uint public withhold = 0;  // NOT USED WITH AION, SEE ABOVE

	// Payees
	struct Payee {
		address addr;
		uint contributionWei;
		bool paid;
	}

	Payee[] public payees;

	address[] public admins;

	// Token decimal multiplier - 8 decimals
	uint public tokenMultiplier = 100000000;

	// ETH to wei
	uint public ethToWei = 1000000000000000000;

	// Has withdrawal function been deployed to distribute tokens?
	bool public withdrawalDeployed = false;


	function Distribute() public {
		//--------------------------ADMINS--------------------------//
		admins.push(msg.sender);
		admins.push(0x008bEd0B3e3a7E7122D458312bBf47B198D58A48); // Matt
		admins.push(0x006501524133105eF4C679c40c7df9BeFf8B0FED); // Mick
		admins.push(0xed4aEddAaEDA94a7617B2C9D4CBF9a9eDC781573); // Marcelo
		admins.push(0xff4C40e273b4fAB581428455b1148352D13CCbf1); // CptTek

		// ------------------------- PAYEES ----------------------- //
		payees.push(Payee({addr:0x87d9342b59734fa3cc54ef9be44a6cb469d8f477, contributionWei:150000000000000000, paid:false})); // .15 ETH to contract deployer for gas cost
		payees.push(Payee({addr:0xA4f8506E30991434204BC43975079aD93C8C5651, contributionWei:87599000000000000000, paid:false}));
		payees.push(Payee({addr:0x5F0f119419b528C804C9BbBF15455d36450406B4, contributionWei:87599000000000000000, paid:false}));
		payees.push(Payee({addr:0xFf651EAD42b8EeA0B9cB88EDc92704ef6af372Ce, contributionWei:87599000000000000000, paid:false}));
		payees.push(Payee({addr:0x20A2F38c02a27292afEc7C90609e5Bd413Ab4DD9, contributionWei:87599000000000000000, paid:false}));
		payees.push(Payee({addr:0x00072ece87cb5f6582f557634f3a82adc5ce5db2, contributionWei:25000000000000000000, paid:false}));
		payees.push(Payee({addr:0x8dCd6294cE580bc6D17304a0a5023289dffED7d6, contributionWei:50000000000000000000, paid:false}));
		payees.push(Payee({addr:0xA534F5b9a5D115563A28FccC5C92ada771da236E, contributionWei:38000000000000000000, paid:false}));
		payees.push(Payee({addr:0x660E067602dC965F10928B933F21bA6dCb2ece9C, contributionWei:23000000000000000000, paid:false}));
		payees.push(Payee({addr:0xfBFcb29Ff159a686d2A0A3992E794A3660EAeFE4, contributionWei:23000000000000000000, paid:false}));
		payees.push(Payee({addr:0x9ebab12563968d8255f546831ec4833449234fFa, contributionWei:23000000000000000000, paid:false}));
		payees.push(Payee({addr:0x002ecfdA4147e48717cbE6810F261358bDAcC6b5, contributionWei:23000000000000000000, paid:false}));
		payees.push(Payee({addr:0x46cCc6b127D6d4d04080Da2D3bb5Fa9Fb294708a, contributionWei:23000000000000000000, paid:false}));
		payees.push(Payee({addr:0x0b6DF62a52e9c60f07fc8B4d4F90Cab716367fb7, contributionWei:23000000000000000000, paid:false}));
		payees.push(Payee({addr:0x0584e184Eb509FA6417371C8A171206658792Da0, contributionWei:20000000000000000000, paid:false}));
		payees.push(Payee({addr:0x82e4D78C6c62D461251fA5A1D4Deb9F0fE378E30, contributionWei:20000000000000000000, paid:false}));
		payees.push(Payee({addr:0xbC306679FC4c3f51D91b1e8a55aEa3461675da18, contributionWei:20000000000000000000, paid:false}));
		payees.push(Payee({addr:0xa6e78caa11ad160c6287a071949bb899a009dafa, contributionWei:15100000000000000000, paid:false}));
		payees.push(Payee({addr:0x5fbDE96c736be83bE859d3607FC96D963033E611, contributionWei:15000000000000000000, paid:false}));
		payees.push(Payee({addr:0x7993d82DCaaE05f60576AbA0F386994AebdEd764, contributionWei:15000000000000000000, paid:false}));
		payees.push(Payee({addr:0xd594b781901838649950A79d07429CA187Ec5888, contributionWei:15000000000000000000, paid:false}));
		payees.push(Payee({addr:0x85591bFABB18Be044fA98D72F7093469C588483C, contributionWei:15000000000000000000, paid:false}));
		payees.push(Payee({addr:0x8F212180bF6B8178559a67268502057Fb0043Dd9, contributionWei:10000000000000000000, paid:false}));
		payees.push(Payee({addr:0x907F6fB76D13Fa7244851Ee390DfE9c6B2135ec5, contributionWei:15000000000000000000, paid:false}));
		payees.push(Payee({addr:0x82e4ad6af565598e5af655c941d4d8995f9783db, contributionWei:15000000000000000000, paid:false}));
		payees.push(Payee({addr:0xE751721F1C79e3e24C6c134a7C77c099de9d412a, contributionWei:10000000000000000000, paid:false}));
		payees.push(Payee({addr:0x491b972AC0E1B26ca9F382493Ce26a8c458a6Ca5, contributionWei:15000000000000000000, paid:false}));
		payees.push(Payee({addr:0x47e48c958628670469c7E67aeb276212015B26fe, contributionWei:10000000000000000000, paid:false}));
		payees.push(Payee({addr:0xF1EA52AC3B0998B76e2DB8394f91224c06BEEf1c, contributionWei:10000000000000000000, paid:false}));
		payees.push(Payee({addr:0xd71932c505beeb85e488182bcc07471a8cfa93cb, contributionWei:10000000000000000000, paid:false}));
		payees.push(Payee({addr:0xAB40F1Bec1bFc341791a45fA037D908989EFBF3D, contributionWei:10000000000000000000, paid:false}));
		payees.push(Payee({addr:0xFDF13343F1E3626491066563aB6D787b9755cc17, contributionWei:10000000000000000000, paid:false}));
		payees.push(Payee({addr:0x808264eeb886d37b706C8e07172d5FdF40dF71A8, contributionWei:9000000000000000000, paid:false}));
		payees.push(Payee({addr:0x044a9c43e95AA9FD28EEa25131A62b602D304F1f, contributionWei:5000000000000000000, paid:false}));
		payees.push(Payee({addr:0xfBfE2A528067B1bb50B926D79e8575154C1dC961, contributionWei:5000000000000000000, paid:false}));
		payees.push(Payee({addr:0x2a7B8545c9f66e82Ac8237D47a609f0cb884C3cE, contributionWei:5000000000000000000, paid:false}));
		payees.push(Payee({addr:0xd9426Fb83321075116b9CF0fCc36F3EcBBe8178C, contributionWei:5000000000000000000, paid:false}));
		payees.push(Payee({addr:0x0743DB483E81668bA748fd6cD51bD6fAAc7665F7, contributionWei:3000000000000000000, paid:false}));
		payees.push(Payee({addr:0xB2cd0402Bc1C5e2d064C78538dF5837b93d7cC99, contributionWei:2000000000000000000, paid:false}));
		payees.push(Payee({addr:0x867D6B56809D4545A7F53E1d4faBE9086FDeb60B, contributionWei:2000000000000000000, paid:false}));
		payees.push(Payee({addr:0x9029056Fe2199Fe0727071611138C70AE2bf27ec, contributionWei:1000000000000000000, paid:false}));
		payees.push(Payee({addr:0x4709a3a7b4A0e646e9953459c66913322b8f4195, contributionWei:1000000000000000000, paid:false}));
	}

	// Check if user is whitelisted admin
	modifier onlyAdmins() {
		uint8 isAdmin = 0;
		for (uint8 i = 0; i < admins.length; i++) {
			if (admins[i] == msg.sender)
        isAdmin = isAdmin | 1;
		}
		require(isAdmin == 1);
		_;
	}

	// Calculate tokens due
	function tokensDue(uint _contributionWei) public view returns (uint) {
		return _contributionWei*ethToTokenRate/ethToWei;
	}

	// Allow admins to change token contract address, in case the wrong token ends up in this contract
	function changeToken(address _token) public onlyAdmins {
		token = ERC20(_token);
	}

    // Individual withdraw function -- Send 0 ETH from contribution address to withdraw tokens
	function () payable {
		for (uint i = 0; i < payees.length; i++) {
			uint _tokensDue = tokensDue(payees[i].contributionWei);
			if (payees[i].addr == msg.sender) {
				require(!payees[i].paid);
				require(_tokensDue >= withhold);
				require(token.balanceOf(address(this)) >= _tokensDue*tokenMultiplier);
				// Withhold tokens to cover gas cost
				uint tokensToSend = _tokensDue - withhold;
				// Send tokens to payee
				require(token.transfer(payees[i].addr, tokensToSend*tokenMultiplier));
				// Mark payee as paid
				payees[i].paid = true;
			}
		}
	}
	
	// Withdraw all tokens to contributing members
	function withdrawAll() public onlyAdmins {
		// Prevent withdrawal function from being called simultaneously by two parties
		require(withdrawalDeployed == false);
		// Confirm sufficient tokens available
		require(validate());
		withdrawalDeployed = true;
		// Send all tokens
		for (uint i = 0; i < payees.length; i++) {
			// Confirm that contributor has not yet been paid is owed more than gas withhold
			if (payees[i].paid == false && tokensDue(payees[i].contributionWei) >= withhold) {
				// Withhold tokens to cover gas cost
				uint tokensToSend = tokensDue(payees[i].contributionWei) - withhold;
				// Send tokens to payee
				require(token.transfer(payees[i].addr, tokensToSend*tokenMultiplier));
				// Mark payee as paid
				payees[i].paid = true;
			}
		}
	}

  // Confirms that enough tokens are available to distribute to all addresses
  function validate() public view returns (bool) {
		// Calculate total tokens due to all contributors
		uint totalTokensDue = 0;
		for (uint i = 0; i < payees.length; i++) {
			if (!payees[i].paid) {
				// Calculate tokens based on ETH contribution
				totalTokensDue += tokensDue(payees[i].contributionWei);
			}
		}
		return token.balanceOf(address(this)) >= totalTokensDue*tokenMultiplier;
  }

	// Test - Token transfer -- Try 1 token first
	function tokenTest() public onlyAdmins {
		require(token.transfer(multisig, 1*tokenMultiplier));
	}

	// Return all ETH and tokens to original multisig
	function returnToSender() public onlyAdmins returns (bool) {
		require(token.transfer(multisig, token.balanceOf(address(this))));
		require(multisig.send(this.balance));
		return true;
	}

	// Return all ETH and tokens to original multisig and then suicide
	function abort() public onlyAdmins {
		require(returnToSender());
		selfdestruct(multisig);
	}


}