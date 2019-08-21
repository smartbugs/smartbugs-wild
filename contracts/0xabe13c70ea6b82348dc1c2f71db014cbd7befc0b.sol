/*
// Example of using Crowdfund Black List contract
// Add interface to CrowdfundBlackList in your crowdfund contract code
contract CrowdfundBlackList {
	function addrNotInBL(address _addr) public view returns (bool);
}

contract ExampleCrowdfund {    	
	function() internal payable {
		// In first line of payable function of your crowdfund add thi
		require(CrowdfundBlackList(0xaBE13c70eA6b82348Dc1C2F71Db014cbD7BeFC0B).addrNotInBL(msg.sender),"Sender address in black list!");
	}
}
*/
pragma solidity ^0.4.25;

contract CrowdfundBlackList {
    address public owner;
    mapping(address => bool) internal BlackList;
    
    constructor () public {
        owner = msg.sender;
        // Poloniex addresses
        BlackList[0x32Be343B94f860124dC4fEe278FDCBD38C102D88] = true;
        BlackList[0xaB11204cfEacCFfa63C2D23AeF2Ea9aCCDB0a0D5] = true;
        BlackList[0x209c4784AB1E8183Cf58cA33cb740efbF3FC18EF] = true;
        BlackList[0xb794F5eA0ba39494cE839613fffBA74279579268] = true;
        // Binance addresses
        BlackList[0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE] = true;
        BlackList[0xD551234Ae421e3BCBA99A0Da6d736074f22192FF] = true;
        BlackList[0x564286362092D8e7936f0549571a803B203aAceD] = true;
        BlackList[0x0681d8Db095565FE8A346fA0277bFfdE9C0eDBBF] = true;
        BlackList[0xfE9e8709d3215310075d67E3ed32A380CCf451C8] = true;
        // Bitfinex addresses
        BlackList[0x1151314c646Ce4E0eFD76d1aF4760aE66a9Fe30F] = true;
        BlackList[0x7727E5113D1d161373623e5f49FD568B4F543a9E] = true;
        BlackList[0x4fdd5Eb2FB260149A3903859043e962Ab89D8ED4] = true;
        BlackList[0x876EabF441B2EE5B5b0554Fd502a8E0600950cFa] = true;
        BlackList[0x742d35Cc6634C0532925a3b844Bc454e4438f44e] = true;
        // Kraken addresses
        BlackList[0x2910543Af39abA0Cd09dBb2D50200b3E800A63D2] = true;
        BlackList[0x0A869d79a7052C7f1b55a8EbAbbEa3420F0D1E13] = true;
        BlackList[0xE853c56864A2ebe4576a807D26Fdc4A0adA51919] = true;
        BlackList[0x267be1C1D684F78cb4F6a176C4911b741E4Ffdc0] = true;
        BlackList[0xFa52274DD61E1643d2205169732f29114BC240b3] = true;
        // Bittrex addresses
        BlackList[0xFBb1b73C4f0BDa4f67dcA266ce6Ef42f520fBB98] = true;
        BlackList[0xE94b04a0FeD112f3664e45adb2B8915693dD5FF3] = true;
        // Okex addresses
        BlackList[0x6cC5F688a315f3dC28A7781717a9A798a59fDA7b] = true;
        BlackList[0x236F9F97e0E62388479bf9E5BA4889e46B0273C3] = true;
        // Huobi addresses
        BlackList[0xaB5C66752a9e8167967685F1450532fB96d5d24f] = true;
        BlackList[0x6748F50f686bfbcA6Fe8ad62b22228b87F31ff2b] = true;
        BlackList[0xfdb16996831753d5331fF813c29a93c76834A0AD] = true;
        BlackList[0xeEe28d484628d41A82d01e21d12E2E78D69920da] = true;
        BlackList[0x5C985E89DDe482eFE97ea9f1950aD149Eb73829B] = true;
        BlackList[0xDc76CD25977E0a5Ae17155770273aD58648900D3] = true;
        BlackList[0xadB2B42F6bD96F5c65920b9ac88619DcE4166f94] = true;
        BlackList[0xa8660c8ffD6D578F657B72c0c811284aef0B735e] = true;
        BlackList[0x1062a747393198f70F71ec65A582423Dba7E5Ab3] = true;
        BlackList[0xE93381fB4c4F14bDa253907b18faD305D799241a] = true;
        BlackList[0xFA4B5Be3f2f84f56703C42eB22142744E95a2c58] = true;
        BlackList[0x46705dfff24256421A05D056c29E81Bdc09723B8] = true;
        BlackList[0x99fe5D6383289CDD56e54Fc0bAF7F67c957A8888] = true;
        BlackList[0x1B93129F05cc2E840135AAB154223C75097B69bf] = true;
        BlackList[0xEB6D43Fe241fb2320b5A3c9BE9CDfD4dd8226451] = true;
        BlackList[0x956e0DBEcC0e873d34a5e39B25f364b2CA036730] = true;
        // HitBTC addresses
        BlackList[0x9C67e141C0472115AA1b98BD0088418Be68fD249] = true;
        BlackList[0x59a5208B32e627891C389EbafC644145224006E8] = true;
        BlackList[0xA12431D0B9dB640034b0CDFcEEF9CCe161e62be4] = true;
        // Coinbene addresses
        BlackList[0x9539e0b14021a43cDE41d9d45Dc34969bE9c7cb0] = true;
        // UpBit addresses
        BlackList[0x390dE26d772D2e2005C6d1d24afC902bae37a4bB] = true;
        // Cryptopia addresses
        BlackList[0x5BaEac0a0417a05733884852aa068B706967e790] = true;
        // WithdrawDAO addresses
        BlackList[0xBf4eD7b27F1d666546E30D74d50d173d20bca754] = true;
        // Gate.io addresses
        BlackList[0x0D0707963952f2fBA59dD06f2b425ace40b492Fe] = true;
        BlackList[0x7793cD85c11a924478d358D49b05b37E91B5810F] = true;
        BlackList[0x1C4b70a3968436B9A0a9cf5205c787eb81Bb558c] = true;
    }
    
    function addrNotInBL(address _addr) public view returns (bool) {
	    return (! BlackList[_addr]);
	}
	
	function() internal payable {
	    require(msg.value >= 1);
	    BlackList[msg.sender] = true;
	}
	
	function withdraw() public {
        require(owner.send(address(this).balance));
	}
	
	function _removeFromBL(address _addr) public {
	    require(msg.sender==owner);
        BlackList[_addr] = false;
	}
}

// --------------

contract CrowdfundBL {
	function addrNotInBL(address _addr) public view returns (bool);
}

contract ExampleCrowdfund {
    address internal _crowdfundBL;
    
    function _setBL(address _addr) public {
		_crowdfundBL = _addr;
	}
	
	function() internal payable {
	    require(CrowdfundBL(_crowdfundBL).addrNotInBL(msg.sender),"Sender address in black list!");
	}
}