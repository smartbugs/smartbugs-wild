pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXIV_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXIV_III_883		"	;
		string	public		symbol =	"	RUSS_PFXXIV_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1026841485325970000000000000					;	
										
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
	//     < RUSS_PFXXIV_III_metadata_line_1_____ALFASTRAKHOVANIE_20251101 >									
	//        < v4yt5CLBMZe24NAoOWa411wbeeUSNe8zkAVxh57Wa3I57AwgAG04L0iEIWN8t66e >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000030832133.667126800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000002F0BCD >									
	//     < RUSS_PFXXIV_III_metadata_line_2_____ALFA_DAO_20251101 >									
	//        < 3U8mzo8s4f1YIf0ni028N3XXJ5Q4JDMr0EMjt22gluT1ry7OQTrRf08d9my9li5I >									
	//        <  u =="0.000000000000000001" : ] 000000030832133.667126800000000000 ; 000000061026292.034962800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002F0BCD5D1E65 >									
	//     < RUSS_PFXXIV_III_metadata_line_3_____ALFA_DAOPI_20251101 >									
	//        < zTL550hJ6XeO2zghtN18gFU77jh3ATY36a6I6w8b8vDyVTjR8n1rw09znfa9urh4 >									
	//        <  u =="0.000000000000000001" : ] 000000061026292.034962800000000000 ; 000000089795196.745507700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005D1E65890440 >									
	//     < RUSS_PFXXIV_III_metadata_line_4_____ALFA_DAC_20251101 >									
	//        < 2xO610BmYfh2Y6s7xCOEGoh7zj9h7ITZup9829XZtx9r6Fg83B09YAdtV922n872 >									
	//        <  u =="0.000000000000000001" : ] 000000089795196.745507700000000000 ; 000000110741730.601322000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000890440A8FA7D >									
	//     < RUSS_PFXXIV_III_metadata_line_5_____ALFA_BIMI_20251101 >									
	//        < gHB50BQu0SRJ2MTFc7zGWzMWFg0VvS7T35ZlswVIcZEpxuNIYZ3dJhWYnpd64zKI >									
	//        <  u =="0.000000000000000001" : ] 000000110741730.601322000000000000 ; 000000140992992.670519000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A8FA7DD72363 >									
	//     < RUSS_PFXXIV_III_metadata_line_6_____SMO_SIBERIA_20251101 >									
	//        < yF65w4vLs0FKKkYh6WR8N2JQEF63SV9HSlW5h4RO7pMJ5vH6rPSL36f7542X8jEh >									
	//        <  u =="0.000000000000000001" : ] 000000140992992.670519000000000000 ; 000000167916918.029043000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000D72363100388C >									
	//     < RUSS_PFXXIV_III_metadata_line_7_____SIBERIA_DAO_20251101 >									
	//        < Hr7GQv8gURZ00PTb07p418i9Kn8nv1Mf4BMeln3NfvzO9ACFhMKG92PTFndn4azZ >									
	//        <  u =="0.000000000000000001" : ] 000000167916918.029043000000000000 ; 000000203573393.563953000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000100388C136A0DB >									
	//     < RUSS_PFXXIV_III_metadata_line_8_____SIBERIA_DAOPI_20251101 >									
	//        < Ew1h831308F7KgVpH9jCnBkqM2H2H9Jnm946x7kmnoC4U2r9cs29c9nBATBP6732 >									
	//        <  u =="0.000000000000000001" : ] 000000203573393.563953000000000000 ; 000000223853478.600614000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000136A0DB15592C4 >									
	//     < RUSS_PFXXIV_III_metadata_line_9_____SIBERIA_DAC_20251101 >									
	//        < Hzt854ciC7gmgHiyOFs5I7ugT7AS7rN0t037h2xJ8rm1pq4B05RXF30E36s118ib >									
	//        <  u =="0.000000000000000001" : ] 000000223853478.600614000000000000 ; 000000242947711.229605000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015592C4172B573 >									
	//     < RUSS_PFXXIV_III_metadata_line_10_____SIBERIA_BIMI_20251101 >									
	//        < DcM806YreC6WlkPM159J0Qah08GM8rz7DgJIfzBnoXix2Y5mvT3Xjq71G33yM687 >									
	//        <  u =="0.000000000000000001" : ] 000000242947711.229605000000000000 ; 000000264600301.093972000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000172B573193BF7E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXIV_III_metadata_line_11_____ALFASTRAKHOVANIE_LIFE_20251101 >									
	//        < 6JUp0F83x1AmzJV20Sp9w6UWx1RwNXi046k5if6B2PfH2zqHAm0QKItUUq0USDBG >									
	//        <  u =="0.000000000000000001" : ] 000000264600301.093972000000000000 ; 000000294017207.339377000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000193BF7E1C0A279 >									
	//     < RUSS_PFXXIV_III_metadata_line_12_____ALFA_LIFE_DAO_20251101 >									
	//        < WD0hfI57Mk405i109H57RmW2hyeJ1BzAlovyZqZ40W3sZx8o1Anr5CNa9r00bh56 >									
	//        <  u =="0.000000000000000001" : ] 000000294017207.339377000000000000 ; 000000322018464.757004000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C0A2791EB5C76 >									
	//     < RUSS_PFXXIV_III_metadata_line_13_____ALFA_LIFE_DAOPI_20251101 >									
	//        < N0H2I6E1qhaCTi3N2D7I1amtp6uyGYMHTv8J23A73ItF378I07pvrr7zkP16XhOS >									
	//        <  u =="0.000000000000000001" : ] 000000322018464.757004000000000000 ; 000000346529935.697047000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EB5C76210C342 >									
	//     < RUSS_PFXXIV_III_metadata_line_14_____ALFA_LIFE_DAC_20251101 >									
	//        < usfWK9KvUQbO51mQYIg4MvPEgi8Fl4xT13J272kP2PbyxK2a8RNc4jQU6cO3v4eJ >									
	//        <  u =="0.000000000000000001" : ] 000000346529935.697047000000000000 ; 000000367309437.906052000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000210C3422307840 >									
	//     < RUSS_PFXXIV_III_metadata_line_15_____ALFA_LIFE_BIMI_20251101 >									
	//        < 0ZWnlS99ROz9E65GfESbBuOklM81q8O2lLn3l2zy63iytf0Zf0k3UWCxLh0z0NBv >									
	//        <  u =="0.000000000000000001" : ] 000000367309437.906052000000000000 ; 000000396333981.592329000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000230784025CC1F6 >									
	//     < RUSS_PFXXIV_III_metadata_line_16_____ALFASTRAKHOVANIE_AVERS_20251101 >									
	//        < 0EZa7Ob4Je5Ju199RwgOE06l0A1Mc1ROIcF8k444zV30ci2S75snb0u1YL0P5NVC >									
	//        <  u =="0.000000000000000001" : ] 000000396333981.592329000000000000 ; 000000422142029.020260000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025CC1F6284233B >									
	//     < RUSS_PFXXIV_III_metadata_line_17_____AVERS_DAO_20251101 >									
	//        < 0f9Rv0iGEn7JW371W87r1zGat78G174fdg2KOomVVPErLM9VYY6413oE78Ga6y5P >									
	//        <  u =="0.000000000000000001" : ] 000000422142029.020260000000000000 ; 000000443008947.660713000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000284233B2A3FA5F >									
	//     < RUSS_PFXXIV_III_metadata_line_18_____AVERS_DAOPI_20251101 >									
	//        < 8E9RPc335ONCqOZ6dHWIDmHh02Ivoj7leq79hT1pBIkqPx15WH0G1LmPUqA2qbK8 >									
	//        <  u =="0.000000000000000001" : ] 000000443008947.660713000000000000 ; 000000465305968.678041000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A3FA5F2C60025 >									
	//     < RUSS_PFXXIV_III_metadata_line_19_____AVERS_DAC_20251101 >									
	//        < pRHCGQy8jW6555Z4UEg9qzNHXUsspkIICf69mp9Xs11u9ebu36su8Sq7bN0Y28i2 >									
	//        <  u =="0.000000000000000001" : ] 000000465305968.678041000000000000 ; 000000488714379.832339000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C600252E9B80E >									
	//     < RUSS_PFXXIV_III_metadata_line_20_____AVERS_BIMI_20251101 >									
	//        < tmgximc5DEwKr5ZCy9d5gJoggT6V8Dj0v91H1BL4gfUjL804Yi9tzC81Bi1621A1 >									
	//        <  u =="0.000000000000000001" : ] 000000488714379.832339000000000000 ; 000000509222339.179630000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E9B80E30902FA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXIV_III_metadata_line_21_____ALFASTRAKHOVANIE_PLC_20251101 >									
	//        < D08EBD7OSiH1y8vt8S22jp11MkX8IQps5V3r4fG551K11GzrKrC3slrq2aQ85Hbz >									
	//        <  u =="0.000000000000000001" : ] 000000509222339.179630000000000000 ; 000000531788124.252059000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030902FA32B71BC >									
	//     < RUSS_PFXXIV_III_metadata_line_22_____ALFASTRA_DAO_20251101 >									
	//        < Z9p3ZPbaExyKXn9G4Bh4P0GtCl8Gtte42W368c84WVb9aUa4u38CXjZWptH0p9YS >									
	//        <  u =="0.000000000000000001" : ] 000000531788124.252059000000000000 ; 000000556666829.952861000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032B71BC35167FB >									
	//     < RUSS_PFXXIV_III_metadata_line_23_____ALFASTRA_DAOPI_20251101 >									
	//        < x3pB2877jY3VKioEuda5P4g1T0qgcN34eaSIL5B1lhsAE6m8aWOKsF7644f49Xq7 >									
	//        <  u =="0.000000000000000001" : ] 000000556666829.952861000000000000 ; 000000586863775.244052000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035167FB37F7BAA >									
	//     < RUSS_PFXXIV_III_metadata_line_24_____ALFASTRA_DAC_20251101 >									
	//        < L0F30MI0UzkOzkc92JH4RGCU3Yw1a9XeQm9767vv94g9l6M7v30M4ZBIRmb5R4Pm >									
	//        <  u =="0.000000000000000001" : ] 000000586863775.244052000000000000 ; 000000611978332.215461000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037F7BAA3A5CE09 >									
	//     < RUSS_PFXXIV_III_metadata_line_25_____ALFASTRA_BIMI_20251101 >									
	//        < QkIsSF1t60q8H2294yjPkFoz71914PMK1PDIFpo0z0L0L204F4GW2v6zj1RO4bZ0 >									
	//        <  u =="0.000000000000000001" : ] 000000611978332.215461000000000000 ; 000000644150011.193248000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A5CE093D6E519 >									
	//     < RUSS_PFXXIV_III_metadata_line_26_____MEDITSINSKAYA_STRAKHOVAYA_KOMP_VIRMED_20251101 >									
	//        < 8yY2hSlunj1s956DaNob3NF7ukxLJIASc5xJIm8Xo0pa838FBsi34aSk5serI36S >									
	//        <  u =="0.000000000000000001" : ] 000000644150011.193248000000000000 ; 000000675365478.699120000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D6E51940686A4 >									
	//     < RUSS_PFXXIV_III_metadata_line_27_____VIRMED_DAO_20251101 >									
	//        < N7tt39UWQjTkc4Kbu0sd6JMAuVrq2778TLY14123N42d74O8X2RXf9IJfl6ylyWI >									
	//        <  u =="0.000000000000000001" : ] 000000675365478.699120000000000000 ; 000000703767991.679111000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040686A4431DD5F >									
	//     < RUSS_PFXXIV_III_metadata_line_28_____VIRMED_DAOPI_20251101 >									
	//        < 12VQQo0LIKjxyIxzayWZqlYG7Dk18BZ8LI69Y8O1whyJadz5b6rd3Wvxi2nTn401 >									
	//        <  u =="0.000000000000000001" : ] 000000703767991.679111000000000000 ; 000000727091874.299966000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000431DD5F4557443 >									
	//     < RUSS_PFXXIV_III_metadata_line_29_____VIRMED_DAC_20251101 >									
	//        < WBDJ44DItg2RAnV2amwd8PyBQ12GbL3w9vB0Ki46kHRFSyfy8kruT2bX0klTrUZm >									
	//        <  u =="0.000000000000000001" : ] 000000727091874.299966000000000000 ; 000000750348218.410340000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004557443478F0C6 >									
	//     < RUSS_PFXXIV_III_metadata_line_30_____VIRMED_BIMI_20251101 >									
	//        < XC7g542fkp464k2RNN28959g4UrH1DIhx87D0c4876895335NL1crhRKC1HihXYQ >									
	//        <  u =="0.000000000000000001" : ] 000000750348218.410340000000000000 ; 000000771649022.954201000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000478F0C64997166 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXIV_III_metadata_line_31_____MSK_ASSTRA_20251101 >									
	//        < kljw08jdhJhrRl484Db0Ve0s12OW8fcn0MnlRV575Nvhh4ntxRMk49jmXA75WhY9 >									
	//        <  u =="0.000000000000000001" : ] 000000771649022.954201000000000000 ; 000000791320463.895392000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049971664B7758E >									
	//     < RUSS_PFXXIV_III_metadata_line_32_____ASSTRA_DAO_20251101 >									
	//        < wn9zhoOh1R1Uvp8Pjl2BjuVSB606gGdjW067RBHvoBSz9i9T4x577T4irqxSN2Vc >									
	//        <  u =="0.000000000000000001" : ] 000000791320463.895392000000000000 ; 000000811582440.666179000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B7758E4D66064 >									
	//     < RUSS_PFXXIV_III_metadata_line_33_____ASSTRA_DAOPI_20251101 >									
	//        < 7pYwd7xs7Lto8027IP7699YCrFy8510f4gtIqXrWFyAPjX535bIRG1K0jm1FX11N >									
	//        <  u =="0.000000000000000001" : ] 000000811582440.666179000000000000 ; 000000844578892.736064000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004D66064508B9A1 >									
	//     < RUSS_PFXXIV_III_metadata_line_34_____ASSTRA_DAC_20251101 >									
	//        < 6Zhge7O9GTV9yMHh7OG7j7v914jrQPM8bHAnH81x4o40ahuWE9mkPAAtzjglEay9 >									
	//        <  u =="0.000000000000000001" : ] 000000844578892.736064000000000000 ; 000000868709037.956733000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000508B9A152D8B78 >									
	//     < RUSS_PFXXIV_III_metadata_line_35_____ASSTRA_BIMI_20251101 >									
	//        < 3z227Wij176d2irv048cOR78BOZt9zIn1GDuMnu8N56n2E3u677ZNhsLI1d5rLp8 >									
	//        <  u =="0.000000000000000001" : ] 000000868709037.956733000000000000 ; 000000892940474.712827000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000052D8B7855284DF >									
	//     < RUSS_PFXXIV_III_metadata_line_36_____AVICOS_AFES_INSURANCE_GROUP_20251101 >									
	//        < m0bmL1Cm6oR86DZh1p6FdE5J1uJmi7Fjm5644VmukXknrFd6P6p04L6Ky3E0LJ37 >									
	//        <  u =="0.000000000000000001" : ] 000000892940474.712827000000000000 ; 000000914895441.097562000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000055284DF5740508 >									
	//     < RUSS_PFXXIV_III_metadata_line_37_____AVICOS_DAO_20251101 >									
	//        < 7KNPs9p76F95z1kQh9zcK8u2mv6zwhB5hgeUG4lG8L75DQGX8aIy0EZ4T7zD7ij2 >									
	//        <  u =="0.000000000000000001" : ] 000000914895441.097562000000000000 ; 000000938155413.236760000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000574050859782F5 >									
	//     < RUSS_PFXXIV_III_metadata_line_38_____AVICOS_DAOPI_20251101 >									
	//        < 5xeGA3277nj05eo2xGK9mPNvf4FEq09W0MOK9a6TuFA70oITs7474uTV6886wN7p >									
	//        <  u =="0.000000000000000001" : ] 000000938155413.236760000000000000 ; 000000969091713.081654000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000059782F55C6B773 >									
	//     < RUSS_PFXXIV_III_metadata_line_39_____AVICOS_DAC_20251101 >									
	//        < 57E5B8a4dJi6i8RIBL1vt9y5uMKM9W6XqmqVAmI612AIz5a0lnKINOSrQDNi185T >									
	//        <  u =="0.000000000000000001" : ] 000000969091713.081654000000000000 ; 000000998746865.445303000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005C6B7735F3F77F >									
	//     < RUSS_PFXXIV_III_metadata_line_40_____AVICOS_BIMI_20251101 >									
	//        < ll415R0k205rpqN5NnkY84meEtYKq03VUDsX4RM8rNgFzg1mc1VQV14jeJYiTTj2 >									
	//        <  u =="0.000000000000000001" : ] 000000998746865.445303000000000000 ; 000001026841485.325970000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005F3F77F61ED5F5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}