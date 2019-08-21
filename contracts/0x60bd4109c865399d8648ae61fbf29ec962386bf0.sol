pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFVII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFVII_II_883		"	;
		string	public		symbol =	"	NDRV_PFVII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1198949438910400000000000000					;	
										
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
	//     < NDRV_PFVII_II_metadata_line_1_____Hannover Re_20231101 >									
	//        < 9Xh91q1p63l77loE4R8Rw9mI23eNeooS0E3xgL2691hk4AZZ8b2Zj6092J4MvWu5 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000021941814.608398500000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000217B05 >									
	//     < NDRV_PFVII_II_metadata_line_2_____Hannover Reinsurance Ireland Ltd_20231101 >									
	//        < 0Pg2Uz4j32Dr4Pt4ciZapg24592m26bEt71A5XyrDIOs07sILAPA9azlh20A88PP >									
	//        <  u =="0.000000000000000001" : ] 000000021941814.608398500000000000 ; 000000039244505.208834400000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000217B053BE1E3 >									
	//     < NDRV_PFVII_II_metadata_line_3_____975 Carroll Square Llc_20231101 >									
	//        < FZZacHJw5T4zx787pj89B67op8fZ29vo1ThQsA6gnnph6CDRobE8P7Z00B861pQP >									
	//        <  u =="0.000000000000000001" : ] 000000039244505.208834400000000000 ; 000000062351276.159486500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003BE1E35F23F8 >									
	//     < NDRV_PFVII_II_metadata_line_4_____Caroll_Holdings_20231101 >									
	//        < 8XMSSxaV5nWiQ7o2s2EUjsnCHII3aA3P4tb50YZ8IOUlrV6U0Wk9K12B1QM85tDE >									
	//        <  u =="0.000000000000000001" : ] 000000062351276.159486500000000000 ; 000000086301355.111389700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005F23F883AF78 >									
	//     < NDRV_PFVII_II_metadata_line_5_____Skandia Versicherung Management & Service Gmbh_20231101 >									
	//        < UUG3u5S2x49946Kox8M0oEamoLRrBlv4l082uBqgSYyFIR06B255f45QFWMT0l5Q >									
	//        <  u =="0.000000000000000001" : ] 000000086301355.111389700000000000 ; 000000107708401.375062000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000083AF78A45998 >									
	//     < NDRV_PFVII_II_metadata_line_6_____Skandia PortfolioManagement Gmbh, Asset Management Arm_20231101 >									
	//        < 3NX7g8E1hthRk1l90HfY6o8pQfIWKc5gisK96wK7n92zaDwYLEeoRO83x76rIsPx >									
	//        <  u =="0.000000000000000001" : ] 000000107708401.375062000000000000 ; 000000139913851.258111000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A45998D57DD9 >									
	//     < NDRV_PFVII_II_metadata_line_7_____Argenta Underwriting No8 Limited_20231101 >									
	//        < XRfs5i4FbHY7IzZ269K12SJOOO7XVI9Y5SZMP4zWNWR3w4bf37Ge2PYA05R7PhAo >									
	//        <  u =="0.000000000000000001" : ] 000000139913851.258111000000000000 ; 000000158125704.178147000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D57DD9F147DA >									
	//     < NDRV_PFVII_II_metadata_line_8_____Oval Office Grundstücks GmbH_20231101 >									
	//        < SdY6NCI2UFzTnRs60y5yQqkBp8U162Nx69FewJucszIl9z7b00kBN7qZE65zH4EQ >									
	//        <  u =="0.000000000000000001" : ] 000000158125704.178147000000000000 ; 000000189251520.210466000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F147DA120C660 >									
	//     < NDRV_PFVII_II_metadata_line_9_____Hannover Rückversicherung AG Asset Management Arm_20231101 >									
	//        < Yx74Vc68O01QLn11t9YibK3QT3fDYmxW4MO53NIl9A8K7o12Sb98Z55Vf3ToCPtO >									
	//        <  u =="0.000000000000000001" : ] 000000189251520.210466000000000000 ; 000000210117499.230351000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000120C6601409D26 >									
	//     < NDRV_PFVII_II_metadata_line_10_____Hannover Rueckversicherung Ag Korea Branch_20231101 >									
	//        < szOQ5aBIRo35I2Idq25EEMAyN0549qBm5nVf440788T26sGCdGek44zG4k04R537 >									
	//        <  u =="0.000000000000000001" : ] 000000210117499.230351000000000000 ; 000000242219011.642811000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001409D2617198CD >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFVII_II_metadata_line_11_____Nashville West LLC_20231101 >									
	//        < H1yv8mE7l7FueVqf60NFSDF8UQ0tg491U6vzUYMmm1YOM1dJk21v8BZiiU11No9m >									
	//        <  u =="0.000000000000000001" : ] 000000242219011.642811000000000000 ; 000000283061660.936021000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017198CD1AFEAF6 >									
	//     < NDRV_PFVII_II_metadata_line_12_____WRH Offshore High Yield Partners LP_20231101 >									
	//        < Q5elT7ujX01HcLCBkktw1GAPao9Pjmm7Invkx5z8b4Ok9l0h94ZI1E1179lCt2o1 >									
	//        <  u =="0.000000000000000001" : ] 000000283061660.936021000000000000 ; 000000310497770.112726000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AFEAF61D9C831 >									
	//     < NDRV_PFVII_II_metadata_line_13_____111Ord Llc_20231101 >									
	//        < GQbv3jAfDYYQVR9524HqLlr73QpsmbI590fMFvtW4TPOTT3C5aIi0h9ch3hB3Oe4 >									
	//        <  u =="0.000000000000000001" : ] 000000310497770.112726000000000000 ; 000000345900040.746659000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D9C83120FCD34 >									
	//     < NDRV_PFVII_II_metadata_line_14_____Hannover Insurance_Linked Securities GmbH & Co KG_20231101 >									
	//        < yPo1F804yNPd6J5trqbq3CUi92n14KAyg1S3pUWs0i79IrtzTmIsSFM8J2PZh1p7 >									
	//        <  u =="0.000000000000000001" : ] 000000345900040.746659000000000000 ; 000000369996854.878187000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020FCD342349205 >									
	//     < NDRV_PFVII_II_metadata_line_15_____Hannover Ruckversicherung AG Hong Kong_20231101 >									
	//        < FICySSxQg5aPT4p2X33245tNbq5A6wQ3R3jcLO7Co3UMDEb4t510B8FVv2Qa9SV7 >									
	//        <  u =="0.000000000000000001" : ] 000000369996854.878187000000000000 ; 000000399234795.527658000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023492052612F18 >									
	//     < NDRV_PFVII_II_metadata_line_16_____Hannover Reinsurance Mauritius Ltd_20231101 >									
	//        < IrF50MjffOpMmSA1m0FhJZ59oS4GXiUOiR8pJMq2CuUknCC4jdl3V93N3YDpx4S0 >									
	//        <  u =="0.000000000000000001" : ] 000000399234795.527658000000000000 ; 000000425340521.846731000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002612F1828904A4 >									
	//     < NDRV_PFVII_II_metadata_line_17_____HEPEP II Holding GmbH_20231101 >									
	//        < v4tVuq1g2NM48FCVBH8fz9v5S89n2M8umSW06wovwfP18bVd755Ki6S0Seb0192R >									
	//        <  u =="0.000000000000000001" : ] 000000425340521.846731000000000000 ; 000000464382177.984535000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028904A42C4974A >									
	//     < NDRV_PFVII_II_metadata_line_18_____International Insurance Company Of Hannover Limited Sweden_20231101 >									
	//        < GL59U14Ca86PPZq2aTtU5WxX7C379V1vx72E40Xb7UiIT04YetFj1Vmw1MS28Tep >									
	//        <  u =="0.000000000000000001" : ] 000000464382177.984535000000000000 ; 000000506165425.597722000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C4974A30458DF >									
	//     < NDRV_PFVII_II_metadata_line_19_____HEPEP III Holding GmbH_20231101 >									
	//        < UbSO8221i8D8TtQ9oG8W3Q862339zhg7s36o5VBot2280P41fVNzeiVOd9uWy8e6 >									
	//        <  u =="0.000000000000000001" : ] 000000506165425.597722000000000000 ; 000000531705551.344579000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030458DF32B517B >									
	//     < NDRV_PFVII_II_metadata_line_20_____Hannover Rueck Beteiligung Verwaltungs_GmbH_20231101 >									
	//        < risi3875K0Y9DV3j6IR7jjAXcb388gm1Q5A8Pdtl7xX3VG2y92z29cb7IeOI6O17 >									
	//        <  u =="0.000000000000000001" : ] 000000531705551.344579000000000000 ; 000000568039369.036535000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032B517B362C261 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFVII_II_metadata_line_21_____EplusS Rückversicherung AG_20231101 >									
	//        < i6XGrIiim6SmoFK12Istg5RPLz2M7723Gb5JNUIr58W4Ms1k4ebhJH83X993Da29 >									
	//        <  u =="0.000000000000000001" : ] 000000568039369.036535000000000000 ; 000000604124551.493776000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000362C261399D227 >									
	//     < NDRV_PFVII_II_metadata_line_22_____HILSP Komplementaer GmbH_20231101 >									
	//        < B8uj4d3toNy94Z5613xNlNl16K56yh1076Q3jh033CQh215k4Ow30uUvEwV48naY >									
	//        <  u =="0.000000000000000001" : ] 000000604124551.493776000000000000 ; 000000620931834.429592000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000399D2273B3777F >									
	//     < NDRV_PFVII_II_metadata_line_23_____Hannover Life Reassurance UK Limited_20231101 >									
	//        < AAkqwgRiEF7934CmOZnCEhCWVHAPHha28EUxle9xXj88q765iAATDKzH4Dm3nth3 >									
	//        <  u =="0.000000000000000001" : ] 000000620931834.429592000000000000 ; 000000660082408.342747000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B3777F3EF34B1 >									
	//     < NDRV_PFVII_II_metadata_line_24_____EplusS Reinsurance Ireland Ltd_20231101 >									
	//        < IYY8gy604lo25NSJUelEF71Dz8IrgLy1Y044J4k30GrL1fC7ec6H0193pyqLWX21 >									
	//        <  u =="0.000000000000000001" : ] 000000660082408.342747000000000000 ; 000000680102918.652329000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003EF34B140DC134 >									
	//     < NDRV_PFVII_II_metadata_line_25_____Svedea Skadeservice Ab_20231101 >									
	//        < o9mD8i8KCXx84ea9711264DZK71p0n5QWVP1S4S3tC7rFqLIshcT73l8ujPIaWc5 >									
	//        <  u =="0.000000000000000001" : ] 000000680102918.652329000000000000 ; 000000728461471.389698000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040DC1344578B43 >									
	//     < NDRV_PFVII_II_metadata_line_26_____Hannover Finance Luxembourg SA_20231101 >									
	//        < GGqGQA5CIqM21eV8y8cXP30Pv5HiafNWDjo719AKeXzVp8CALv5W99NG2Usi5Sru >									
	//        <  u =="0.000000000000000001" : ] 000000728461471.389698000000000000 ; 000000764939597.623054000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004578B4348F3488 >									
	//     < NDRV_PFVII_II_metadata_line_27_____Hannover Ruckversicherung AG Australia_20231101 >									
	//        < M0H1s0MD9U24WMnQp2Ti3HV5qNjr5Z4dejvWt88z0Pwr6015Xf286lm4DHFM6vnz >									
	//        <  u =="0.000000000000000001" : ] 000000764939597.623054000000000000 ; 000000792708680.564779000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048F34884B993D4 >									
	//     < NDRV_PFVII_II_metadata_line_28_____Cargo Transit Insurance Pty Limited_20231101 >									
	//        < 1JXZs6YR9H2gS6d13x3nbc3PXW9T25bJ5Bg45eIwjSW3b9344ugb8p3RZ6yw9amw >									
	//        <  u =="0.000000000000000001" : ] 000000792708680.564779000000000000 ; 000000819818750.680660000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B993D44E2F1B3 >									
	//     < NDRV_PFVII_II_metadata_line_29_____Hannover Life Re Africa_20231101 >									
	//        < mio8ZkLkrOT5WEQS0WZWm86AiC4Z2Eiz3FZo6W77D1H8p4hw17xP1J1wUpzWLG0Z >									
	//        <  u =="0.000000000000000001" : ] 000000819818750.680660000000000000 ; 000000867700053.363777000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004E2F1B352C0155 >									
	//     < NDRV_PFVII_II_metadata_line_30_____Hannover Re Services USA Inc_20231101 >									
	//        < 4jD98s5fLhD6rd490096Dbr58AA8vRCjS126L14KCvD5Wj7lPKjAke4yXV548CR9 >									
	//        <  u =="0.000000000000000001" : ] 000000867700053.363777000000000000 ; 000000893513319.634518000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000052C015555364A4 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFVII_II_metadata_line_31_____Talanx Deutschland AG_20231101 >									
	//        < 44lXT82x6Okbo44Se5VPj5j67cpc144MQb458n9zO6gr2vAF0Zfqm5H89nb9eZF2 >									
	//        <  u =="0.000000000000000001" : ] 000000893513319.634518000000000000 ; 000000931909737.331271000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000055364A458DFB3E >									
	//     < NDRV_PFVII_II_metadata_line_32_____HDI Lebensversicherung AG_20231101 >									
	//        < fs2HEzriG5JK3hjDvQMv0VCCRN30ft6w48wyep5C5AlS484W399yum5wBd1xR7a8 >									
	//        <  u =="0.000000000000000001" : ] 000000931909737.331271000000000000 ; 000000951018341.636865000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000058DFB3E5AB238A >									
	//     < NDRV_PFVII_II_metadata_line_33_____casa altra development GmbH_20231101 >									
	//        < GRFJ6Q8OB9q9XehK5YI881RtiQqJE8ECUnK1xJ0h8v2t00RO671281U4eOf5jNRF >									
	//        <  u =="0.000000000000000001" : ] 000000951018341.636865000000000000 ; 000000975094900.981676000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005AB238A5CFE072 >									
	//     < NDRV_PFVII_II_metadata_line_34_____Credit Life International Services GmbH_20231101 >									
	//        < sIML9scTSv2Aa2dCmP85thaSL111BjmPW8nBj4G219fnkL5K20vL4HS6p2gBPD8O >									
	//        <  u =="0.000000000000000001" : ] 000000975094900.981676000000000000 ; 000001016671437.963270000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005CFE07260F5148 >									
	//     < NDRV_PFVII_II_metadata_line_35_____FVB Gesellschaft für Finanz_und Versorgungsberatung mbH_20231101 >									
	//        < 9QvX7RTmu7u0k0sa6A91D1PQITV76VoIM6UTYa4e0J0ENx3w6ZV0SSnfB0lEoeX1 >									
	//        <  u =="0.000000000000000001" : ] 000001016671437.963270000000000000 ; 000001045189124.861270000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000060F514863AD500 >									
	//     < NDRV_PFVII_II_metadata_line_36_____ASPECTA Assurance International AG_20231101 >									
	//        < Hf2F6y15tCD2F5JH4xH99eJtP8r2b0CykwB5TH5Lc46Xiy7e3ElPnVCL7KU4FD84 >									
	//        <  u =="0.000000000000000001" : ] 000001045189124.861270000000000000 ; 000001087169358.893450000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000063AD50067AE388 >									
	//     < NDRV_PFVII_II_metadata_line_37_____Life Re_Holdings_20231101 >									
	//        < swabiQ85iFxUItcqW7WWdYp0080oJuM2RC6uv84SJ7n8J7h79x174CBtdkF7plCk >									
	//        <  u =="0.000000000000000001" : ] 000001087169358.893450000000000000 ; 000001113862251.105810000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000067AE3886A39E71 >									
	//     < NDRV_PFVII_II_metadata_line_38_____Credit Life_Pensions_20231101 >									
	//        < SBM9s2C4b1421ZSp6Btm0b8XO3D94XfA87n73e6UYL5Pi9wwtUIj4FKkxYvoOndU >									
	//        <  u =="0.000000000000000001" : ] 000001113862251.105810000000000000 ; 000001132716428.578140000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006A39E716C0635B >									
	//     < NDRV_PFVII_II_metadata_line_39_____ASPECTA_org_20231101 >									
	//        < 896r4dbh6ClaE297o685al7525qUHL9F3Y1PVcMz3Rf989474WS7WnR0r7M1Ri1D >									
	//        <  u =="0.000000000000000001" : ] 000001132716428.578140000000000000 ; 000001182398662.309500000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006C0635B70C327A >									
	//     < NDRV_PFVII_II_metadata_line_40_____Cargo Transit_Holdings_20231101 >									
	//        < 0nFurw5wRMSC9q9bMxAu387SsAaZR4FD6XWqRDi0F7Xk8aGwJaZ8ZPvosfycNEf0 >									
	//        <  u =="0.000000000000000001" : ] 000001182398662.309500000000000000 ; 000001198949438.910400000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000070C327A72573A0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}