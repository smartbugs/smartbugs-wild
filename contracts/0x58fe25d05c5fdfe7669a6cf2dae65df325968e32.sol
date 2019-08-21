pragma solidity ^0.4.2;
contract storer {
	address public owner;
	string public log;

	function storer() {
		owner = msg.sender ;
		}

	modifier onlyOwner {
		if (msg.sender != owner)
            		throw;
        		_;
		}

	function store(string _log) onlyOwner() {
	log = _log;
		}

	function kill() onlyOwner() {
	selfdestruct(owner); }
	
/*

{
	"maker": {
		"address": "0x0a6d88d0ac14bb76b58bf6341b65a10353b8aee8",
		"token": {
			"name": "Augur Reputation Token",
			"symbol": "REP",
			"decimals": 18,
			"address": "0xe94327d07fc17907b4db788e5adf2ed424addff6"
		},
		"amount": "860000000000000000",
		"feeAmount": "0"
	},
	"taker": {
		"address": "0x6CF821A13455cABed0adc2789C6803FA2e938cA9",
		"token": {
			"name": "pcp cab dac sec 5",
			"symbol": "CCA",
			"decimals": 8,
			"address": "0xaf34de25a4962c05287025a386869fa0e12ce95d"
		},
		"amount": "1700000000",
		"feeAmount": "0"
	},
	"expiration": "1509303780",
	"feeRecipient": "0x0000000000000000000000000000000000000000",
	"salt": "99080185595902305128011107182726626379042477463436851204612997193034843428216",
	"signature": {
		"v": 28,
		"r": "0xa5a3b9dee57e814e2cc733c2b362cee5c037baade9dbdd47bcfa47de10c38a10",
		"s": "0x75225fddc9b382a218b4d64e8992ab17e6d030fde885c4c618a97da0311e1e5f",
		"hash": "0x4e427f1a75e0f55745689b0f6e36d4f44a8fcb1b525620c69e491a36daf9a3ee"
	},
	"exchangeContract": "0x12459c951127e0c374ff9105dda097662a027093",
	"networkId": 1
}

	'0x protocol implementation
	'carnet d'ordres
	'offre d'achat
	'acheteur, compte numéro :	0x0a6d88d0ac14bb76b58bf6341b65a10353b8aee8
	'compte d'actif, actif :	CCA (clevestAB equity)
	'volume :			17.00000000
	'au prix de
	'compte en devises, devise :	REP
	'montant :			0.860
	'consolidation
	'compte en devises, devise :	ETH
	'montant :			0.01
	'compte en devise, devise :	CHF
	'montant :			17.00
	'contrôle source :		

*/	
}