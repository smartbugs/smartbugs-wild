contract TestCert {

	mapping (uint32 => bytes32) private Cert;	
	
	function SetCert (uint32 _IndiceIndex, bytes32 _Cert) {
		if (msg.sender == 0x46b396728e61741D3AbD6Aa5bfC42610997c32C3) {
			Cert [_IndiceIndex] = _Cert;
		}
	}				
	
	function GetCert (uint32 _IndiceIndex) constant returns (bytes32)  {
		return Cert [_IndiceIndex];
	}		
}