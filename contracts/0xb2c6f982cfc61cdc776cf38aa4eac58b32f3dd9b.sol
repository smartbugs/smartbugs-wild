pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFV_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFV_III_883		"	;
		string	public		symbol =	"	RUSS_PFV_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1040488033833410000000000000					;	
										
		event Transfer(address indexed from, address indexed to, uint256 value);								
										
		function SimpleERC20Token() public {								
			balanceOf[msg.sender] = totalSupply;							
			emit Transfer(address(0), msg.sender, totalSupply);							
		}								
										
		function transfer(address to, uint256 value) public returns (bool success) {								
			require(balanceOf[msg.sender] >= value);							
										
			balanceOf[msg.sender] -= value;  // deduct from sender's balance							
			balanceOf[to] += value;          // add to recipient's balance							
			emit Transfer(msg.sender, to, value);							
			return true;							
		}								
										
		event Approval(address indexed owner, address indexed spender, uint256 value);								
										
		mapping(address => mapping(address => uint256)) public allowance;								
										
		function approve(address spender, uint256 value)								
			public							
			returns (bool success)							
		{								
			allowance[msg.sender][spender] = value;							
			emit Approval(msg.sender, spender, value);							
			return true;							
		}								
										
		function transferFrom(address from, address to, uint256 value)								
			public							
			returns (bool success)							
		{								
			require(value <= balanceOf[from]);							
			require(value <= allowance[from][msg.sender]);							
										
			balanceOf[from] -= value;							
			balanceOf[to] += value;							
			allowance[from][msg.sender] -= value;							
			emit Transfer(from, to, value);							
			return true;							
		}								
//	}									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	// Programme d'émission - Lignes 1 à 10									
	//									
	//									
	//									
	//									
	//     [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ]									
	//         [ Adresse exportée ]									
	//         [ Unité ; Limite basse ; Limite haute ]									
	//         [ Hex ]									
	//									
	//									
	//									
	//     < RUSS_PFV_III_metadata_line_1_____SIRIUS_ORG_20251101 >									
	//        < 102HY4LPuoYMrTr4VAibopMXIEuCq35lv87GY0691bMzb17WlKgYDzkmbtFVUEwX >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000031842467.509232100000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000309677 >									
	//     < RUSS_PFV_III_metadata_line_2_____SIRIUS_DAO_20251101 >									
	//        < RAzQbpYTLef9g7II8P9s7Zv3RK8rksR5rC7VofPgl78i2Mp63Q43QFEiyG3S91Px >									
	//        <  u =="0.000000000000000001" : ] 000000031842467.509232100000000000 ; 000000054035690.917497200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003096775273B1 >									
	//     < RUSS_PFV_III_metadata_line_3_____SIRIUS_DAOPI_20251101 >									
	//        < tKA4518dVCJOtHi9tC42OG3adGT22nSkLK678gdKKTLL50Xm8t315mw1qh005K8s >									
	//        <  u =="0.000000000000000001" : ] 000000054035690.917497200000000000 ; 000000079424043.044966900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005273B1793104 >									
	//     < RUSS_PFV_III_metadata_line_4_____SIRIUS_BIMI_20251101 >									
	//        < 7VAvxt9eEP0sja87Li0Hg2Znv064LCiP6x8LU5292lA19c8taaTEOs12ruZ626UD >									
	//        <  u =="0.000000000000000001" : ] 000000079424043.044966900000000000 ; 000000108829757.282133000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000793104A60FA0 >									
	//     < RUSS_PFV_III_metadata_line_5_____EDUCATIONAL_CENTER_SIRIUS_ORG_20251101 >									
	//        < iJY5f80I842a711C1DrZ906oWbYR8sVneg7GcSjlawS2I7DBmwS089RfWW3E0rvb >									
	//        <  u =="0.000000000000000001" : ] 000000108829757.282133000000000000 ; 000000131366670.068908000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A60FA0C8731B >									
	//     < RUSS_PFV_III_metadata_line_6_____EDUCATIONAL_CENTER_SIRIUS_DAO_20251101 >									
	//        < 4GwV8023THzjtmBhDkyECJfd5H2D1JCl51jXYEEqu8A47D0bL70gZ1ZsKZi9Hsj3 >									
	//        <  u =="0.000000000000000001" : ] 000000131366670.068908000000000000 ; 000000165128929.537305000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C8731BFBF77D >									
	//     < RUSS_PFV_III_metadata_line_7_____EDUCATIONAL_CENTER_SIRIUS_DAOPI_20251101 >									
	//        < hP7BxpQCQ7r2q7t7hWoL2yk1Z1pKioF6151LqhI2cjppxB97h5wKOt4D266dq0eL >									
	//        <  u =="0.000000000000000001" : ] 000000165128929.537305000000000000 ; 000000188090238.831709000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FBF77D11F00C0 >									
	//     < RUSS_PFV_III_metadata_line_8_____EDUCATIONAL_CENTER_SIRIUS_DAC_20251101 >									
	//        < Cg6Sn7MEtYdUz372Vxi19TVH11wWiLP636Ex9PcpqV6SIu5s7cD9AAz6CL134qpf >									
	//        <  u =="0.000000000000000001" : ] 000000188090238.831709000000000000 ; 000000221849217.110841000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011F00C015283DA >									
	//     < RUSS_PFV_III_metadata_line_9_____SOCHI_PARK_HOTEL_20251101 >									
	//        < 14sq5doY52RG1MZc8tC0HWn96lz5740e4KiU7S7g3X7olr9x5y07mHQz9nkEb9th >									
	//        <  u =="0.000000000000000001" : ] 000000221849217.110841000000000000 ; 000000241042366.600985000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015283DA16FCD2D >									
	//     < RUSS_PFV_III_metadata_line_10_____GOSTINICHNYY_KOMPLEKS_BOGATYR_20251101 >									
	//        < 30Nk3ziFtrdhfnAu433hw42Nsm0p15299u1X2p30GGOmh8Y83412Bsnzyhaf3mH0 >									
	//        <  u =="0.000000000000000001" : ] 000000241042366.600985000000000000 ; 000000275452983.825188000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016FCD2D1A44ED2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	// Programme d'émission - Lignes 11 à 20									
	//									
	//									
	//									
	//									
	//     [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ]									
	//         [ Adresse exportée ]									
	//         [ Unité ; Limite basse ; Limite haute ]									
	//         [ Hex ]									
	//									
	//									
	//									
	//     < RUSS_PFV_III_metadata_line_11_____SIRIUS_IKAISA_BIMI_I_20251101 >									
	//        < P7yiUI7Kly3dQo3743uvY647VrNz2cRxdKisTzBOzaV5jAJa0XS7nWMCs16q99kA >									
	//        <  u =="0.000000000000000001" : ] 000000275452983.825188000000000000 ; 000000305690817.885477000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A44ED21D2727A >									
	//     < RUSS_PFV_III_metadata_line_12_____SIRIUS_IKAISA_BIMI_II_20251101 >									
	//        < b0aeKHSkXbtwd0Mt4iKE53W8h76kawrQqR62DvAgLlD94sg6aFFh26CSn6rrR9Js >									
	//        <  u =="0.000000000000000001" : ] 000000305690817.885477000000000000 ; 000000325885657.397527000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D2727A1F14316 >									
	//     < RUSS_PFV_III_metadata_line_13_____SIRIUS_IKAISA_BIMI_III_20251101 >									
	//        < AviL0z9Q8K6Tv1YSeCnK0MjHCvj88z00NaT9AHm99Ia1DLrfJbnzSqw9VXo01L0J >									
	//        <  u =="0.000000000000000001" : ] 000000325885657.397527000000000000 ; 000000347163279.926510000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F14316211BAA8 >									
	//     < RUSS_PFV_III_metadata_line_14_____SIRIUS_IKAISA_BIMI_IV_20251101 >									
	//        < ep5A0r09MXT5QSxb0gpAKrGAqPkoe4txL3jC0sV3184IX86JXfOZxXJg03309oQ9 >									
	//        <  u =="0.000000000000000001" : ] 000000347163279.926510000000000000 ; 000000372055329.872605000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000211BAA8237B61D >									
	//     < RUSS_PFV_III_metadata_line_15_____SIRIUS_IKAISA_BIMI_V_20251101 >									
	//        < Oq14k81QVQ1gPL3S0oIEr2J90DmA19wlX7I3rW6IL6oyii3nC56aB7L1N59oHU0Y >									
	//        <  u =="0.000000000000000001" : ] 000000372055329.872605000000000000 ; 000000404125913.400101000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000237B61D268A5AF >									
	//     < RUSS_PFV_III_metadata_line_16_____SIRIUS_IKAISA_BIMI_VI_20251101 >									
	//        < T358tH5j2xl460xti03c5skeEIulumfPCsvPvnCb2UnEWXUdn93VeKpR9482947S >									
	//        <  u =="0.000000000000000001" : ] 000000404125913.400101000000000000 ; 000000422447286.134571000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000268A5AF2849A79 >									
	//     < RUSS_PFV_III_metadata_line_17_____SIRIUS_IKAISA_BIMI_VII_20251101 >									
	//        < 40ObNO6u51454hzrmP2jIC2JaWe8M2Javirdl8F9641h5e0l9HJOjuT3VatytdbE >									
	//        <  u =="0.000000000000000001" : ] 000000422447286.134571000000000000 ; 000000449132986.351541000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002849A792AD5293 >									
	//     < RUSS_PFV_III_metadata_line_18_____SIRIUS_IKAISA_BIMI_VIII_20251101 >									
	//        < 654PqqVpbvg2gcsd4NFLfc0XWUt27STeztAPqb3uh1oQxS09khnB1r4FR2Q8XVzX >									
	//        <  u =="0.000000000000000001" : ] 000000449132986.351541000000000000 ; 000000483948040.184955000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AD52932E27234 >									
	//     < RUSS_PFV_III_metadata_line_19_____SIRIUS_IKAISA_BIMI_IX_20251101 >									
	//        < Vm2FvQZ126xP8cVwSG3NK7X71jz8vmKXNts9gAxSsDRG381f56D31G033NL0A026 >									
	//        <  u =="0.000000000000000001" : ] 000000483948040.184955000000000000 ; 000000507128460.188606000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E27234305D10E >									
	//     < RUSS_PFV_III_metadata_line_20_____SIRIUS_IKAISA_BIMI_X_20251101 >									
	//        < zV69CY85uyw0n3885cO5qOo9V4EnVw9luUV7DiHaqVLNb6OGyCO3wnc9dmq05PHp >									
	//        <  u =="0.000000000000000001" : ] 000000507128460.188606000000000000 ; 000000529561238.367854000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000305D10E3280BDC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	// Programme d'émission - Lignes 21 à 30									
	//									
	//									
	//									
	//									
	//     [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ]									
	//         [ Adresse exportée ]									
	//         [ Unité ; Limite basse ; Limite haute ]									
	//         [ Hex ]									
	//									
	//									
	//									
	//     < RUSS_PFV_III_metadata_line_21_____SOCHI_INFRA_FUND_I_20251101 >									
	//        < 30EL9m8BaG700HqNd05gUNrVSJ1NP2Yu82i9zS4Pt98yv2Gx3wliOF9etzdAJQ8J >									
	//        <  u =="0.000000000000000001" : ] 000000529561238.367854000000000000 ; 000000558255887.215622000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003280BDC353D4B5 >									
	//     < RUSS_PFV_III_metadata_line_22_____SOCHI_INFRA_FUND_II_20251101 >									
	//        < eGpffe4tuc3s7u0P51N335g50ox894qVedo1MpzQ83TJ4Mm2hPLVQ3lxtt1whbmm >									
	//        <  u =="0.000000000000000001" : ] 000000558255887.215622000000000000 ; 000000593604318.781841000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000353D4B5389C4B0 >									
	//     < RUSS_PFV_III_metadata_line_23_____SOCHI_INFRA_FUND_III_20251101 >									
	//        < v68Gc1X9ysGl9G7y7TUfPrM7C1H7IPiOkQIcGSJ6jO9fj96SLT837P4DkSYtjP26 >									
	//        <  u =="0.000000000000000001" : ] 000000593604318.781841000000000000 ; 000000616875943.146094000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000389C4B03AD472A >									
	//     < RUSS_PFV_III_metadata_line_24_____SOCHI_INFRA_FUND_IV_20251101 >									
	//        < 9eDDZqDVIkjMpXP7hZc9Mkp9xmfE8c3fsD0FajN3xX1EqOcrB6TXSGwo2bahD0FV >									
	//        <  u =="0.000000000000000001" : ] 000000616875943.146094000000000000 ; 000000637814157.718163000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003AD472A3CD3A28 >									
	//     < RUSS_PFV_III_metadata_line_25_____SOCHI_INFRA_FUND_V_20251101 >									
	//        < NpgE6Jz4104V68aODjMJ07YDd9tBMhr9p0x0riko0CSWcLzBcEw6JkRpD3NkuYD3 >									
	//        <  u =="0.000000000000000001" : ] 000000637814157.718163000000000000 ; 000000670092598.231752000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003CD3A283FE7AEC >									
	//     < RUSS_PFV_III_metadata_line_26_____LIPNITSK_ORG_20251101 >									
	//        < 5nL5xJhX10NLUZhJV9fAT6UBFF57V2bK1OAh3BDodwo9K7MDiIROdTyH8AC02YMI >									
	//        <  u =="0.000000000000000001" : ] 000000670092598.231752000000000000 ; 000000690688251.605501000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003FE7AEC41DE819 >									
	//     < RUSS_PFV_III_metadata_line_27_____LIPNITSK_DAO_20251101 >									
	//        < iVH1JFUlklQmtjtx4RKRP8frm6889ZmQ332OTVbGscrq0san9bUWpYenybzIK0wV >									
	//        <  u =="0.000000000000000001" : ] 000000690688251.605501000000000000 ; 000000723885234.178188000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041DE8194508FAB >									
	//     < RUSS_PFV_III_metadata_line_28_____LIPNITSK_DAC_20251101 >									
	//        < 6Sd9h94p2Efjjo4bTMfMaAgdKapFbXV4iYA4vQ9po10FGZoc8BUx497Zct31G37R >									
	//        <  u =="0.000000000000000001" : ] 000000723885234.178188000000000000 ; 000000746155623.084131000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004508FAB4728B0A >									
	//     < RUSS_PFV_III_metadata_line_29_____LIPNITSK_ADIDAS_AB_20251101 >									
	//        < B00Q0HHSe3M5389IO82n8szys29Gq7T8Yo0fe9mC3lBzA29hNI2F33nf78lysK7b >									
	//        <  u =="0.000000000000000001" : ] 000000746155623.084131000000000000 ; 000000767346407.946645000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004728B0A492E0B1 >									
	//     < RUSS_PFV_III_metadata_line_30_____LIPNITSK_ALL_AB_M_ADIDAS_20251101 >									
	//        < 7xkfsXq8XeibJO5I2HMo8PfYp76J17A51CY0Mi19Zk26CJOWXl70rW0Kh82Y11AI >									
	//        <  u =="0.000000000000000001" : ] 000000767346407.946645000000000000 ; 000000794274372.893344000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000492E0B14BBF76D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	// Programme d'émission - Lignes 31 à 40									
	//									
	//									
	//									
	//									
	//     [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ]									
	//         [ Adresse exportée ]									
	//         [ Unité ; Limite basse ; Limite haute ]									
	//         [ Hex ]									
	//									
	//									
	//									
	//     < RUSS_PFV_III_metadata_line_31_____ANADYR_ORG_20251101 >									
	//        < SQEiXCf8KkoK7edk22j5aq6lzQ8bWatW603QgiZ6voip3QrZnF1354ftB6a2y04v >									
	//        <  u =="0.000000000000000001" : ] 000000794274372.893344000000000000 ; 000000822627990.929257000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004BBF76D4E73B0F >									
	//     < RUSS_PFV_III_metadata_line_32_____ANADYR_DAO_20251101 >									
	//        < 85siXa0AG83XG18XVmvT75Y01Smqf3hlbIsXMrkJ3u016VOupC2B1fQ68qi405c4 >									
	//        <  u =="0.000000000000000001" : ] 000000822627990.929257000000000000 ; 000000843557994.520662000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004E73B0F5072AD7 >									
	//     < RUSS_PFV_III_metadata_line_33_____ANADYR_DAOPI_20251101 >									
	//        < ZS7R4p6zy4b5rHc3QUSisK6A8qK354KlQVFClaRKAAFpMa90sU1loMi1dFbql9Vl >									
	//        <  u =="0.000000000000000001" : ] 000000843557994.520662000000000000 ; 000000868311564.343631000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005072AD752CF034 >									
	//     < RUSS_PFV_III_metadata_line_34_____CHUKOTKA_ORG_20251101 >									
	//        < 1qU5XF3fa76m1w4g8XE9uaUs1QxNc2BHehq6cliY42un4fO5741I06I7dQrUMiMN >									
	//        <  u =="0.000000000000000001" : ] 000000868311564.343631000000000000 ; 000000889884829.105852000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000052CF03454DDB43 >									
	//     < RUSS_PFV_III_metadata_line_35_____CHUKOTKA_DAO_20251101 >									
	//        < Oby0hAvujY9vbUhiipdF4Rvc1b5K4byZmMpn81y95Fr46u2EO7GpCqbDEhT4PFu2 >									
	//        <  u =="0.000000000000000001" : ] 000000889884829.105852000000000000 ; 000000919480669.516474000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000054DDB4357B0423 >									
	//     < RUSS_PFV_III_metadata_line_36_____CHUKOTKA_DAOPI_20251101 >									
	//        < XqA2lwg9j5qfChpb9Z8a9Mm6i7x2PAkSdmVfy8AxeyMd771829Dx941pBX7f8HV6 >									
	//        <  u =="0.000000000000000001" : ] 000000919480669.516474000000000000 ; 000000945748847.751205000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000057B04235A31925 >									
	//     < RUSS_PFV_III_metadata_line_37_____ANADYR_PORT_ORG_20251101 >									
	//        < D04SrXHKVIm5rW2Eb3Jy1gd1J83DyYOq28uWFW1ic7y103Q6WGtA8ZaV78ull77r >									
	//        <  u =="0.000000000000000001" : ] 000000945748847.751205000000000000 ; 000000975595748.451960000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005A319255D0A417 >									
	//     < RUSS_PFV_III_metadata_line_38_____INDUSTRIAL_PARK_ANADYR_ORG_20251101 >									
	//        < 57X7otb0j30fJm5W65jIi10FHrW9vrPZBDOCrx003GZQBT1rxtQ4x43NmT8d60si >									
	//        <  u =="0.000000000000000001" : ] 000000975595748.451960000000000000 ; 000000995896498.479891000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005D0A4175EF9E12 >									
	//     < RUSS_PFV_III_metadata_line_39_____POLE_COLD_SERVICE_20251101 >									
	//        < 2brAycmvfk98eX0Q9gWjXG8pe780DK73606XFbYHYb9h6Rc1Iox6579oLtJJy80g >									
	//        <  u =="0.000000000000000001" : ] 000000995896498.479891000000000000 ; 000001022150335.914460000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005EF9E12617AD7A >									
	//     < RUSS_PFV_III_metadata_line_40_____RED_OCTOBER_CO_20251101 >									
	//        < kVM9SXO38IfnvUE83sMatC9a58yT8lFzjDRXe6up06n2hnh093Xn88P1P5R3whjN >									
	//        <  u =="0.000000000000000001" : ] 000001022150335.914460000000000000 ; 000001040488033.833410000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000617AD7A633A8A3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}