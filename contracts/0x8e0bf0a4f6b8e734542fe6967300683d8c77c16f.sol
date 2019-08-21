pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXIII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXIII_III_883		"	;
		string	public		symbol =	"	RUSS_PFXIII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1074491109593450000000000000					;	
										
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
	//     < RUSS_PFXIII_III_metadata_line_1_____NORILSK_NICKEL_20251101 >									
	//        < XMS7E9aXBq3RJyoH4t6Am256D9Rxr5j43MtC115i8aNYxBJ24AK8D3ZP29SH8KU2 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000030842537.656945700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000002F0FDE >									
	//     < RUSS_PFXIII_III_metadata_line_2_____NORNICKEL_ORG_20251101 >									
	//        < bRdIG7y81W0n5PmT8KWi0vfufgnB7HqXI2z145ueUUvyLKmvoukw2y79MZ7dIXA0 >									
	//        <  u =="0.000000000000000001" : ] 000000030842537.656945700000000000 ; 000000055481107.695769700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002F0FDE54A84F >									
	//     < RUSS_PFXIII_III_metadata_line_3_____NORNICKEL_DAO_20251101 >									
	//        < G1eH4eRnaNHrFfHrk9Pw48T2KSUFwl517x211qyKWjXJeNe2BMW8iGM7HwwRtAIw >									
	//        <  u =="0.000000000000000001" : ] 000000055481107.695769700000000000 ; 000000084872949.052862900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000054A84F81817F >									
	//     < RUSS_PFXIII_III_metadata_line_4_____NORNICKEL_DAOPI_20251101 >									
	//        < ylyKtasxOp19Blp9abYg83Br6199B4r8IfszUeX2CD0Re3EwDKK5RQj215LoI9Do >									
	//        <  u =="0.000000000000000001" : ] 000000084872949.052862900000000000 ; 000000113709053.665753000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000081817FAD8199 >									
	//     < RUSS_PFXIII_III_metadata_line_5_____NORNICKEL_PENSII_20251101 >									
	//        < BjJO32Rli3PAPJa1Q6DNJcgsh54F5q047AOtfehNuag5nq2s2QLrQ7N7a5Vl7F0C >									
	//        <  u =="0.000000000000000001" : ] 000000113709053.665753000000000000 ; 000000141899875.701807000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AD8199D885A4 >									
	//     < RUSS_PFXIII_III_metadata_line_6_____NORNICKEL_DAC_20251101 >									
	//        < jXTmguI88SGxV5VQk4T6Sjznnvusi5Mb8JFLf2RN9HN2NZWP1IIPPm9D6LWiJOSB >									
	//        <  u =="0.000000000000000001" : ] 000000141899875.701807000000000000 ; 000000177357809.698882000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000D885A410EA065 >									
	//     < RUSS_PFXIII_III_metadata_line_7_____NORNICKEL_BIMI_20251101 >									
	//        < F9AXjDnSCqo5q8oP3Z68uEdm2b58O7702H4MWq05ABM088lhZ1n95n2GGxY1sR8R >									
	//        <  u =="0.000000000000000001" : ] 000000177357809.698882000000000000 ; 000000198008984.240360000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010EA06512E2342 >									
	//     < RUSS_PFXIII_III_metadata_line_8_____NORNICKEL_ALIANS_20251101 >									
	//        < 1zOWbJaS26e57p95x9U7Qd9iOlgth7i5W65sfFN59IkD23ckGofieB5rNhaCz62i >									
	//        <  u =="0.000000000000000001" : ] 000000198008984.240360000000000000 ; 000000219406278.915544000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012E234214EC994 >									
	//     < RUSS_PFXIII_III_metadata_line_9_____NORNICKEL_KOMPLEKS_20251101 >									
	//        < bMLu45eY54MaXCj68V9amgj6Sqe2087zyQL7d0ksXH3nL1x3lhWyom7RceK482IQ >									
	//        <  u =="0.000000000000000001" : ] 000000219406278.915544000000000000 ; 000000255034955.983762000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014EC9941852708 >									
	//     < RUSS_PFXIII_III_metadata_line_10_____NORNICKEL_PRODUKT_20251101 >									
	//        < 92Af50EYkDG86D6TL5yn91EafN2KRZ785yHU1Ex2PEF66YaEASGO7Ag6DL5o50fN >									
	//        <  u =="0.000000000000000001" : ] 000000255034955.983762000000000000 ; 000000287525976.110436000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018527081B6BAD6 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXIII_III_metadata_line_11_____YENESEI_RIVER_SHIPPING_CO_20251101 >									
	//        < ix1h912LgTn6Q3ywH5bjXu4rudcce188N82O5t9os81ni7q2Pt5BUPe9f35PSVN7 >									
	//        <  u =="0.000000000000000001" : ] 000000287525976.110436000000000000 ; 000000307867153.074581000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B6BAD61D5C49B >									
	//     < RUSS_PFXIII_III_metadata_line_12_____YENESEI_PI_PENSII_20251101 >									
	//        < LmWJd37wcMZ1Us4p86x2H30gb91Tw171s9Hr906MD3K90ENf298R7TJPy88f7GUc >									
	//        <  u =="0.000000000000000001" : ] 000000307867153.074581000000000000 ; 000000341307130.974575000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D5C49B208CB19 >									
	//     < RUSS_PFXIII_III_metadata_line_13_____YENESEI_PI_ALIANS_20251101 >									
	//        < 6M0WMwRV5r1IZot69EmUfGSy2KMe7W6hUvYRa5yHBsG41S7413Wb4Bp38RU3q54N >									
	//        <  u =="0.000000000000000001" : ] 000000341307130.974575000000000000 ; 000000360827014.327842000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000208CB19226940D >									
	//     < RUSS_PFXIII_III_metadata_line_14_____YENESEI_PI_KROM_20251101 >									
	//        < hCF61h8DMd5s4k87W3XAr4GnIlb9HlVWo7x575h64B7rnwyU0e84A9ZgG4p40Suq >									
	//        <  u =="0.000000000000000001" : ] 000000360827014.327842000000000000 ; 000000385221947.301837000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000226940D24BCD53 >									
	//     < RUSS_PFXIII_III_metadata_line_15_____YENESEI_PI_FINANS_20251101 >									
	//        < saH9fyDarMkh3HvFiBPQ9Aj1L4yl9FOLzL7Nl8lgHz1I12NGSVWQhmY8HpPh7Uf9 >									
	//        <  u =="0.000000000000000001" : ] 000000385221947.301837000000000000 ; 000000404670813.144591000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024BCD532697A89 >									
	//     < RUSS_PFXIII_III_metadata_line_16_____YENESEI_PI_KOMPLEKS_20251101 >									
	//        < z2ZU6cZmTBA480rJ21zAA98tO3K3D3TnhESkFthM8068TSrQY3671pTb56Qu74E6 >									
	//        <  u =="0.000000000000000001" : ] 000000404670813.144591000000000000 ; 000000438904424.962148000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002697A8929DB70A >									
	//     < RUSS_PFXIII_III_metadata_line_17_____YENESEI_PI_TECH_20251101 >									
	//        < Ga67eT8302uojwEPfQ9onQ7SGcVD3Vt5WalCKbh3X4sHrg086IG4Rl8S0CKrP1p6 >									
	//        <  u =="0.000000000000000001" : ] 000000438904424.962148000000000000 ; 000000468921820.329518000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029DB70A2CB8496 >									
	//     < RUSS_PFXIII_III_metadata_line_18_____YENESEI_PI_KOMPANIYA_20251101 >									
	//        < GBq9Nc99vMQU61Ij07Psw8MYH68x4g8C5M5Ko1C3m1N60f3tXDTaQnidxf0rRq93 >									
	//        <  u =="0.000000000000000001" : ] 000000468921820.329518000000000000 ; 000000501726599.676918000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CB84962FD92F4 >									
	//     < RUSS_PFXIII_III_metadata_line_19_____YENESEI_PI_MATHS_20251101 >									
	//        < 8V1QrHYOjgzXv94lFL44533My81PcLisLCRrhoi1L0T437JfA288qM1W5taa4A0O >									
	//        <  u =="0.000000000000000001" : ] 000000501726599.676918000000000000 ; 000000527098961.905134000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FD92F43244A08 >									
	//     < RUSS_PFXIII_III_metadata_line_20_____YENESEI_PI_PRODUKT_20251101 >									
	//        < kP6isycgds7r4D66seA33N20b65M5J2YEI16Sy30r9246Cu0jWC676P31qvsn4q6 >									
	//        <  u =="0.000000000000000001" : ] 000000527098961.905134000000000000 ; 000000555584729.023273000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003244A0834FC149 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXIII_III_metadata_line_21_____YENESEI_1_ORG_20251101 >									
	//        < g9961hwlKO6su1w37t2Txmy45E4BKZrIw0J3wB8SAIGq5h0AMW5dbPbtsZvH846E >									
	//        <  u =="0.000000000000000001" : ] 000000555584729.023273000000000000 ; 000000576134225.303400000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034FC14936F1C6F >									
	//     < RUSS_PFXIII_III_metadata_line_22_____YENESEI_1_DAO_20251101 >									
	//        < CV5bEDzFi0NJa5JB6x5E0nER22Ao523dBUlDjRE25uuRQ50Gt0r6pK371xbe5d23 >									
	//        <  u =="0.000000000000000001" : ] 000000576134225.303400000000000000 ; 000000607914036.349573000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036F1C6F39F9A6C >									
	//     < RUSS_PFXIII_III_metadata_line_23_____YENESEI_1_DAOPI_20251101 >									
	//        < m3Ktdi55WM034FrWLIU0oufs4l270akQ41Qkpc2nrLo8jwFvE3cU5E768IJqjw1w >									
	//        <  u =="0.000000000000000001" : ] 000000607914036.349573000000000000 ; 000000629152960.322887000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039F9A6C3C002E0 >									
	//     < RUSS_PFXIII_III_metadata_line_24_____YENESEI_1_DAC_20251101 >									
	//        < 42P1MYHt8w3263M7970YkDTzlHVXkYe5dZLZ93oUW3JaYi00Lav2JKV45aNrQXpF >									
	//        <  u =="0.000000000000000001" : ] 000000629152960.322887000000000000 ; 000000652102081.583705000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C002E03E30760 >									
	//     < RUSS_PFXIII_III_metadata_line_25_____YENESEI_1_BIMI_20251101 >									
	//        < 989OCSH08C21T2HgEx5zT2x4Vwu8WanJx4216Ei38QWWK9o7Zd944sX5Iyc9j4Fl >									
	//        <  u =="0.000000000000000001" : ] 000000652102081.583705000000000000 ; 000000683138300.918966000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E3076041262E6 >									
	//     < RUSS_PFXIII_III_metadata_line_26_____YENESEI_2_ORG_20251101 >									
	//        < v36w54sB8gJMNE76u277M3iQ4KCiI216GPHak58us3YP27dT79YUbs4lt1lzw5Xv >									
	//        <  u =="0.000000000000000001" : ] 000000683138300.918966000000000000 ; 000000710475053.526925000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041262E643C1951 >									
	//     < RUSS_PFXIII_III_metadata_line_27_____YENESEI_2_DAO_20251101 >									
	//        < fFuZHt365n5V5U37UR4F476j6521b9uTl7GuV1h85hZ8NK6S22BDCDlt5S18w0rf >									
	//        <  u =="0.000000000000000001" : ] 000000710475053.526925000000000000 ; 000000734123709.677309000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000043C19514602F13 >									
	//     < RUSS_PFXIII_III_metadata_line_28_____YENESEI_2_DAOPI_20251101 >									
	//        < 24Hl5mQ70tnV9b70yZZh5tr1GGE7953I4mVsLjJggbVoHEb9J02B8cFF1i6YFJPh >									
	//        <  u =="0.000000000000000001" : ] 000000734123709.677309000000000000 ; 000000762973852.600395000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004602F1348C34A9 >									
	//     < RUSS_PFXIII_III_metadata_line_29_____YENESEI_2_DAC_20251101 >									
	//        < Aj8FaFg1559pi7sZP3Hw345fvSLvyw4778Ht1A2J8f8R9h05SEdSN967qMIixT5T >									
	//        <  u =="0.000000000000000001" : ] 000000762973852.600395000000000000 ; 000000787309802.986215000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048C34A94B156E4 >									
	//     < RUSS_PFXIII_III_metadata_line_30_____YENESEI_2_BIMI_20251101 >									
	//        < 6sWpHo8bLK26d77p0tZNi0MZj3ZjQGJOSsDRE366RusD4uHp8iBQ82KU18DTZIy1 >									
	//        <  u =="0.000000000000000001" : ] 000000787309802.986215000000000000 ; 000000822602207.698884000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B156E44E730FD >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXIII_III_metadata_line_31_____NORDAVIA_20251101 >									
	//        < qfFydLdDkj7LB3v0CI30X5eM03R0eD5ZhkIMC6XI0yGoIBhsE93JMJ9PjY8ku5RO >									
	//        <  u =="0.000000000000000001" : ] 000000822602207.698884000000000000 ; 000000841156316.446957000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004E730FD50380B0 >									
	//     < RUSS_PFXIII_III_metadata_line_32_____NORDSTAR_20251101 >									
	//        < 5x8rmw91BX6sql73bY1E5sCIJo9Qe5ygY3MZKqYz7ep15fZ6DeF9tebuB5rQWnM9 >									
	//        <  u =="0.000000000000000001" : ] 000000841156316.446957000000000000 ; 000000867734481.690134000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000050380B052C0EC8 >									
	//     < RUSS_PFXIII_III_metadata_line_33_____OGK_3_20251101 >									
	//        < BG7iAKp8641oT8x0i7Cgvvs97A8wB6LLpLl5Uq9Zpub916iq2n8r9wLIkX086lgK >									
	//        <  u =="0.000000000000000001" : ] 000000867734481.690134000000000000 ; 000000892278303.646802000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000052C0EC85518236 >									
	//     < RUSS_PFXIII_III_metadata_line_34_____TAIMYR_ENERGY_CO_20251101 >									
	//        < e3aSR3P8617q5nOPapg7ft3b7IFf9c547OH9M8639iDvu574wfzKuq84M38wrWJX >									
	//        <  u =="0.000000000000000001" : ] 000000892278303.646802000000000000 ; 000000925508907.289169000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000551823658436EB >									
	//     < RUSS_PFXIII_III_metadata_line_35_____METAL_TRADE_OVERSEAS_AG_20251101 >									
	//        < 882OpuuxJx5f7b4fBgsY93522r1x2TUm683B37D9WfBckG736aSGS6PMfw7Hsxqj >									
	//        <  u =="0.000000000000000001" : ] 000000925508907.289169000000000000 ; 000000951711593.764789000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000058436EB5AC3257 >									
	//     < RUSS_PFXIII_III_metadata_line_36_____KOLSKAYA_GMK_20251101 >									
	//        < 4oUgnovT7wZrK68VoWYHhZn0B1eodp0EwziI7oRl2e6C0tlncO4Gl8bUWng21FE9 >									
	//        <  u =="0.000000000000000001" : ] 000000951711593.764789000000000000 ; 000000982754886.052762000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005AC32575DB90A1 >									
	//     < RUSS_PFXIII_III_metadata_line_37_____NORNICKEL_MMC_FINANCE_LIMITED_20251101 >									
	//        < 6Gq9EpHIo0d04dIdY848F69JpGfZd59492nZ121Vtqr3K9yWG71Q6Iyc9aJQZLp3 >									
	//        <  u =="0.000000000000000001" : ] 000000982754886.052762000000000000 ; 000001001544116.090280000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005DB90A15F83C2C >									
	//     < RUSS_PFXIII_III_metadata_line_38_____NORNICKEL_ASIA_LIMITED_20251101 >									
	//        < 1kbQOnd80CyN3dwA70X23hydCkQNK3FE1nzYkX0BKxl40Ry65Q7cHQdJWNi7y7Yv >									
	//        <  u =="0.000000000000000001" : ] 000001001544116.090280000000000000 ; 000001023916033.479120000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005F83C2C61A5F33 >									
	//     < RUSS_PFXIII_III_metadata_line_39_____TATI_NICKEL_MINING_CO_20251101 >									
	//        < 4jyrZe4o36ES1H3cLj60ehU0ItDL8ej3db8zqcA5L433v3ULWPh8yMnfrifSt613 >									
	//        <  u =="0.000000000000000001" : ] 000001023916033.479120000000000000 ; 000001050111350.710640000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000061A5F3364257BF >									
	//     < RUSS_PFXIII_III_metadata_line_40_____TATI_ORG_20251101 >									
	//        < 3CNiP325p4B74f1R80AI1d1H6Z1MXS78gf23c5tUr5v0BC7V85DuERzw7104t7a8 >									
	//        <  u =="0.000000000000000001" : ] 000001050111350.710640000000000000 ; 000001074491109.593450000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000064257BF6678B17 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}