pragma solidity ^0.4.2;
contract Sign {

	address public AddAuthority;	
	mapping (uint32 => bytes32) Cert;	
	
	// =============================================
	
	function Sign() {
		AddAuthority = msg.sender;
		Cert [0] = 0x7a1d671e46f713a33286d4b4215796c8d396fd0e7cedf0b4e01d071df0f1412a;
		Cert [1] = 0x5705f82396973f8f3861f1c29d7962e3234ff732723e39689ca7e7c030580000;
	}

	function () {throw;} // reverse
	
	function destroy() {if (msg.sender == AddAuthority) {selfdestruct(AddAuthority);}}
	
	function SetCert (uint32 _IndiceIndex, bytes32 _Cert) {
		if (msg.sender == AddAuthority) {
			Cert [_IndiceIndex] = _Cert;
		}
	}				
	
	function GetCert (uint32 _IndiceIndex) returns (bytes32 _Valeur)  {
		_Valeur = Cert [_IndiceIndex];
		return _Valeur;
	}		
}