pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFVII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFVII_III_883		"	;
		string	public		symbol =	"	RUSS_PFVII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1042339756120710000000000000					;	
										
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
	//     < RUSS_PFVII_III_metadata_line_1_____NOVATEK_20251101 >									
	//        < fGF48l6848Z3WQE570rlTwt3Fc8OWQAG315f7642qFX290wfrpKfJKrlBwSk3Xeg >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000027797374.378013300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000002A6A59 >									
	//     < RUSS_PFVII_III_metadata_line_2_____NORTHGAS_20251101 >									
	//        < yza0F321txmDnAdZwjK2RsOMLAbdLhKMNqvc3GM9D8qmJXD5H0UFTzmGyp6hM2NU >									
	//        <  u =="0.000000000000000001" : ] 000000027797374.378013300000000000 ; 000000053286667.403940600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002A6A59514F1B >									
	//     < RUSS_PFVII_III_metadata_line_3_____SEVERENERGIA_20251101 >									
	//        < qAhfkM9312m3g3Eb2Rwmo4gL4J604dW0wPd2khZrl5LuI6SQK2STZNfnoSkctJk6 >									
	//        <  u =="0.000000000000000001" : ] 000000053286667.403940600000000000 ; 000000078145087.111599400000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000514F1B773D6D >									
	//     < RUSS_PFVII_III_metadata_line_4_____NOVATEK_ARCTIC_LNG_1_20251101 >									
	//        < 0D4ScAa9yh3359VALh4kjKFpp7sPm5KQCV1Ur19vf4mC5zMGbeOST4tNzcsrr138 >									
	//        <  u =="0.000000000000000001" : ] 000000078145087.111599400000000000 ; 000000097180118.369757600000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000773D6D9448FC >									
	//     < RUSS_PFVII_III_metadata_line_5_____NOVATEK_YURKHAROVNEFTEGAS_20251101 >									
	//        < I9aAZDlt379KKO0gk3q04A9mKu13vfde2jpKRfsH4wN20f1GBOOOqntR73Mn92F3 >									
	//        <  u =="0.000000000000000001" : ] 000000097180118.369757600000000000 ; 000000127745795.079815000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009448FCC2ECB4 >									
	//     < RUSS_PFVII_III_metadata_line_6_____NOVATEK_GAS_POWER_GMBH_20251101 >									
	//        < dq0RX4b20t0Bu2W0l95Q0IqvO3L7OjxcWaPZ3Et1Nfcjb2GFPt8nA5SU9rmKK94w >									
	//        <  u =="0.000000000000000001" : ] 000000127745795.079815000000000000 ; 000000147281722.920975000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C2ECB4E0BBEC >									
	//     < RUSS_PFVII_III_metadata_line_7_____OOO_CHERNICHNOYE_20251101 >									
	//        < cYQ4FNe556r9V8MAO02ly56AwgZHU7inhAkY1m579LOD717yNQIUs18Y4aW75lY1 >									
	//        <  u =="0.000000000000000001" : ] 000000147281722.920975000000000000 ; 000000168472617.045064000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E0BBEC101119E >									
	//     < RUSS_PFVII_III_metadata_line_8_____OAO_TAMBEYNEFTEGAS_20251101 >									
	//        < eq3P0V97Vf63XA4WVO20v7TRMurjG9f3JoH6xpj220FqQsYM0gEZUl01VT61Ax4y >									
	//        <  u =="0.000000000000000001" : ] 000000168472617.045064000000000000 ; 000000198608803.671477000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000101119E12F0D90 >									
	//     < RUSS_PFVII_III_metadata_line_9_____NOVATEK_TRANSERVICE_20251101 >									
	//        < z65WXDFG5IG9O8pyo6l7PL9rBrSn37zh80D8090UOEdmpUJI3ByE8p4nmAKJlyNe >									
	//        <  u =="0.000000000000000001" : ] 000000198608803.671477000000000000 ; 000000220163065.355302000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012F0D9014FF133 >									
	//     < RUSS_PFVII_III_metadata_line_10_____NOVATEK_ARCTIC_LNG_2_20251101 >									
	//        < 6QhJ8BPxF952qd52WV4mYbbtqWrVxXFP6RinhXf3JXP7V7z6K2xSP854JA4PMrWK >									
	//        <  u =="0.000000000000000001" : ] 000000220163065.355302000000000000 ; 000000248430515.988876000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014FF13317B132C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFVII_III_metadata_line_11_____YAMAL_LNG_20251101 >									
	//        < XUkN7zPR1437h1nolxdRjS6g27Gh150Vb44x09V2pDlR80Wr0Yn56AYoJY09pPB9 >									
	//        <  u =="0.000000000000000001" : ] 000000248430515.988876000000000000 ; 000000276681818.838527000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017B132C1A62ED6 >									
	//     < RUSS_PFVII_III_metadata_line_12_____OOO_YARGEO_20251101 >									
	//        < EVDl0fLMVNQcz361S9KIjJU1XRbqwp9gE9k2B2G2GKnE3vf3dG0ucuI8HOEA5Z28 >									
	//        <  u =="0.000000000000000001" : ] 000000276681818.838527000000000000 ; 000000305298930.075339000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A62ED61D1D965 >									
	//     < RUSS_PFVII_III_metadata_line_13_____NOVATEK_ARCTIC_LNG_3_20251101 >									
	//        < qQBy9wdo6bWvIa9MmMEOsVT39N8vqM1B7yKSSM1YBlNFH54isfsxkC423l6PhV06 >									
	//        <  u =="0.000000000000000001" : ] 000000305298930.075339000000000000 ; 000000330176825.470609000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D1D9651F7CF53 >									
	//     < RUSS_PFVII_III_metadata_line_14_____TERNEFTEGAZ_JSC_20251101 >									
	//        < m533D6tIJUn1YGyRz3ylRJN28Fj1rk2Bi4g5E2ELqr3wH3T0h534mL2X62QAY20P >									
	//        <  u =="0.000000000000000001" : ] 000000330176825.470609000000000000 ; 000000349150073.453018000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F7CF53214C2BF >									
	//     < RUSS_PFVII_III_metadata_line_15_____OOO_UNITEX_20251101 >									
	//        < gV1PTt06s0SO36gytbgsKD9jl5f3bPr4vHz0yPqmh87bg040Vy7J1ST6g2L0y98S >									
	//        <  u =="0.000000000000000001" : ] 000000349150073.453018000000000000 ; 000000378168725.347750000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000214C2BF2410A29 >									
	//     < RUSS_PFVII_III_metadata_line_16_____NOVATEK_FINANCE_DESIGNATED_ACTIVITY_CO_20251101 >									
	//        < dx8y7EQV37co9v44A3ioqs29paQpi13h7m50dW8DnwlJH61UWT1Eb8DLx6OqDjP5 >									
	//        <  u =="0.000000000000000001" : ] 000000378168725.347750000000000000 ; 000000404491193.504295000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002410A29269345F >									
	//     < RUSS_PFVII_III_metadata_line_17_____NOVATEK_EQUITY_CYPRUS_LIMITED_20251101 >									
	//        < 6CtjmJ4SJrNr6D1mSJBnEq1CfSZ2YcEMz15vXpDMu5FTql663e37325D1sWJ94m9 >									
	//        <  u =="0.000000000000000001" : ] 000000404491193.504295000000000000 ; 000000430186508.021036000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000269345F290699B >									
	//     < RUSS_PFVII_III_metadata_line_18_____BLUE_GAZ_SP_ZOO_20251101 >									
	//        < 1b2om95JzzirBw4o0nr0nX36XezKs07Hhy5CIGo7S9z31cOTX6db2FCqRP7KXiKY >									
	//        <  u =="0.000000000000000001" : ] 000000430186508.021036000000000000 ; 000000463225378.679579000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000290699B2C2D36A >									
	//     < RUSS_PFVII_III_metadata_line_19_____NOVATEK_OVERSEAS_AG_20251101 >									
	//        < xzRt9Uc7SsWLMj2W701XRX8wUUg3H9D9Srnc1tp2H8uwl02EN5Z4Qln9le60P023 >									
	//        <  u =="0.000000000000000001" : ] 000000463225378.679579000000000000 ; 000000482868768.702249000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C2D36A2E0CC9D >									
	//     < RUSS_PFVII_III_metadata_line_20_____NOVATEK_POLSKA_SP_ZOO_20251101 >									
	//        < jLevS5VcAc8q8Gjr42eaWkR0Ii555ofec7dSJ4F5Gz2J04CsGG9hw2GWH6kJsK03 >									
	//        <  u =="0.000000000000000001" : ] 000000482868768.702249000000000000 ; 000000509589859.196884000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E0CC9D309928A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFVII_III_metadata_line_21_____CRYOGAS_VYSOTSK_CJSC_20251101 >									
	//        < e79S089Zz5S8XFeLJVaWQ8sXbBC360Q36i108frIr4eYa5285hGd5g4Vcw22t7X7 >									
	//        <  u =="0.000000000000000001" : ] 000000509589859.196884000000000000 ; 000000536259291.921611000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000309928A3324449 >									
	//     < RUSS_PFVII_III_metadata_line_22_____OOO_PETRA_INVEST_M_20251101 >									
	//        < peRFYIR776Ha8I1tVP3bBSMZFpjg5MOODt3QG8Z7V0XCXJ5v0qqPhHT6xrMDlfZ1 >									
	//        <  u =="0.000000000000000001" : ] 000000536259291.921611000000000000 ; 000000570891905.703597000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033244493671CA7 >									
	//     < RUSS_PFVII_III_metadata_line_23_____ARCTICGAS_20251101 >									
	//        < gSQT3YFG0Xe0f26Oxehr9DZ6VQ8i9d2nN7y392rW0g0M3P0AlKJ7G6vo1Z33vPOO >									
	//        <  u =="0.000000000000000001" : ] 000000570891905.703597000000000000 ; 000000591276888.269572000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003671CA73863789 >									
	//     < RUSS_PFVII_III_metadata_line_24_____YARSALENEFTEGAZ_LLC_20251101 >									
	//        < 2nFB7nFKzC6237k2TUmTjVemuM19960FtHuE8P40k29QaxDZ1d2WkcQsRmY4ntY1 >									
	//        <  u =="0.000000000000000001" : ] 000000591276888.269572000000000000 ; 000000611115266.417870000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038637893A47CE7 >									
	//     < RUSS_PFVII_III_metadata_line_25_____NOVATEK_CHELYABINSK_20251101 >									
	//        < Z95qH8DBFU3oh2CWZd191NchPrI8R1HK40003Rc2vEX04w7eY9rumZ5pCvz9u2P8 >									
	//        <  u =="0.000000000000000001" : ] 000000611115266.417870000000000000 ; 000000642774109.533921000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A47CE73D4CBA3 >									
	//     < RUSS_PFVII_III_metadata_line_26_____EVROTEK_ZAO_20251101 >									
	//        < weM1LmFGKg9iu2WC2G4b6kNX2rcmC4kIh66Id6mD7384YuNy4027GSji8FQM1HM4 >									
	//        <  u =="0.000000000000000001" : ] 000000642774109.533921000000000000 ; 000000677033433.759728000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D4CBA3409122F >									
	//     < RUSS_PFVII_III_metadata_line_27_____OOO_NOVASIB_20251101 >									
	//        < B777vg56zszK7G9b6d8RhF11BHsw15GRG06ZEq0NA5vcKi1v7OQ8IOj87J7c2bI6 >									
	//        <  u =="0.000000000000000001" : ] 000000677033433.759728000000000000 ; 000000708254005.031884000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000409122F438B5B9 >									
	//     < RUSS_PFVII_III_metadata_line_28_____NOVATEK_PERM_OOO_20251101 >									
	//        < 9wghlcE58Iq311m6F2RksqpRx5Qg580r9loNl3kzKGgUqpO0ymEG66XGcnZLnCx8 >									
	//        <  u =="0.000000000000000001" : ] 000000708254005.031884000000000000 ; 000000734008944.258478000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000438B5B9460023E >									
	//     < RUSS_PFVII_III_metadata_line_29_____NOVATEK_AZK_20251101 >									
	//        < Iz6o01PUbvsqM69p6l9YY2d4Vl8NX7jRf22KmH1k4l10311XVjU3RmA0y5tl7466 >									
	//        <  u =="0.000000000000000001" : ] 000000734008944.258478000000000000 ; 000000756119279.082964000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000460023E481BF18 >									
	//     < RUSS_PFVII_III_metadata_line_30_____NOVATEK_NORTH_WEST_20251101 >									
	//        < mEb4Pi1j8pvKCBYI4itztfBosS2CJ152O4q33w0vS0j31gxxH4PiIYCrzqy1YB41 >									
	//        <  u =="0.000000000000000001" : ] 000000756119279.082964000000000000 ; 000000779894448.302477000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000481BF184A60645 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFVII_III_metadata_line_31_____OOO_EKOPROMSTROY_20251101 >									
	//        < wWRQ7YcV77J6KeQ13f395g1wad8hc1BipE37L7wxA1Z6E58p9x0im2am5d14ZFw0 >									
	//        <  u =="0.000000000000000001" : ] 000000779894448.302477000000000000 ; 000000799343200.249238000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A606454C3B370 >									
	//     < RUSS_PFVII_III_metadata_line_32_____OVERSEAS_EP_20251101 >									
	//        < F924oxje2GPRb7qGP4U0GmCd4dqZSJWwnGh41bgBH27sg63hTMqp1uchCp0yKDZ0 >									
	//        <  u =="0.000000000000000001" : ] 000000799343200.249238000000000000 ; 000000821253480.544889000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004C3B3704E52224 >									
	//     < RUSS_PFVII_III_metadata_line_33_____KOL_SKAYA_VERF_20251101 >									
	//        < Kn70pvXMhO4gb8utjN9OsTyhFzJ7qH01Y6jU0aT86ehE1g3pl4L4lahyRzU73X86 >									
	//        <  u =="0.000000000000000001" : ] 000000821253480.544889000000000000 ; 000000844569501.895695000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004E52224508B5F6 >									
	//     < RUSS_PFVII_III_metadata_line_34_____TARKOSELENEFTEGAS_20251101 >									
	//        < 7t88RK01kq81oD58gBkMXvVwhz68aY3UO1r3pZ66u0anHi8Jt940546RBDRA6G89 >									
	//        <  u =="0.000000000000000001" : ] 000000844569501.895695000000000000 ; 000000866543478.217807000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000508B5F652A3D8C >									
	//     < RUSS_PFVII_III_metadata_line_35_____TAMBEYNEFTEGAS_OAO_20251101 >									
	//        < Fv634UmB9U7xVe79msdpM094695N6UX3A580JwOIxY4besM69lDYoPu57LM3M09B >									
	//        <  u =="0.000000000000000001" : ] 000000866543478.217807000000000000 ; 000000901129070.159832000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000052A3D8C55F038B >									
	//     < RUSS_PFVII_III_metadata_line_36_____OOO_NOVATEK_MOSCOW_REGION_20251101 >									
	//        < 62R1hCV9Vtihyrc2017AuYL3ArNuKsqE430G7y9SSr4hzP7xvsNXmn5NgwWE72jr >									
	//        <  u =="0.000000000000000001" : ] 000000901129070.159832000000000000 ; 000000928660894.063814000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000055F038B5890629 >									
	//     < RUSS_PFVII_III_metadata_line_37_____OILTECHPRODUKT_INVEST_20251101 >									
	//        < kdvT5ncIQEs5s2bp6QrnO0o5el4692vHEIk8sCBn4mwTMTscDIfVt19511WMHy0Q >									
	//        <  u =="0.000000000000000001" : ] 000000928660894.063814000000000000 ; 000000962252820.535139000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000058906295BC4802 >									
	//     < RUSS_PFVII_III_metadata_line_38_____NOVATEK_UST_LUGA_20251101 >									
	//        < V20F9SR9qIZ0wog9rZez88db3GFN90fyo62m894B8O1w19RG3HmMXl4Q51DR5tVn >									
	//        <  u =="0.000000000000000001" : ] 000000962252820.535139000000000000 ; 000000984403731.140090000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005BC48025DE14B5 >									
	//     < RUSS_PFVII_III_metadata_line_39_____NOVATEK_SCIENTIFIC_TECHNICAL_CENTER_20251101 >									
	//        < Bw5eavyZ6yb7nG4ykng51JwwCuXCMd680v2hl22GYiz4W2Br57XyZv0p0KzJ1nu5 >									
	//        <  u =="0.000000000000000001" : ] 000000984403731.140090000000000000 ; 000001016204702.108330000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005DE14B560E9AF6 >									
	//     < RUSS_PFVII_III_metadata_line_40_____NOVATEK_GAS_POWER_ASIA_PTE_LTD_20251101 >									
	//        < 934SMx537ERP440AU33jZ03885Q4TZTf8aQvy7jih6Ffi53y67CD8v5C9Xr9brZj >									
	//        <  u =="0.000000000000000001" : ] 000001016204702.108330000000000000 ; 000001042339756.120710000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000060E9AF66367BF8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}