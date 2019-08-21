pragma solidity 		^0.4.25	;						
										
	contract	CHEMCHINA_PFI_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	CHEMCHINA_PFI_I_883		"	;
		string	public		symbol =	"	CHEMCHINA_PFI_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		561734866207499000000000000					;	
										
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
	//     < CHEMCHINA_PFI_I_metadata_line_1_____001Chemical_20220321 >									
	//        < SHntZKht18nMcdKJknO5O2Gy6kqD5xzpeg0crOfCwDKXdRM6YmMk87p4zFR2WeEV >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000013490436.191562500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001495B4 >									
	//     < CHEMCHINA_PFI_I_metadata_line_2_____3B_Scientific__Wuhan__Corporation_Limited_20220321 >									
	//        < lXFy68Wcv5Jcj1FU8hRUA2KMlsJf51QSZMltMR0kxhk319Jwm99m7wNnxoG3bhPG >									
	//        <  u =="0.000000000000000001" : ] 000000013490436.191562500000000000 ; 000000027021597.099934200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001495B4293B50 >									
	//     < CHEMCHINA_PFI_I_metadata_line_3_____3Way_Pharm_inc__20220321 >									
	//        < mH56w79C98tIADFfq9EOto28525JK34iC9Dv2Q3jsq5Q0D3vI1ph6CmO1IRZW1PG >									
	//        <  u =="0.000000000000000001" : ] 000000027021597.099934200000000000 ; 000000043064326.123049400000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000293B5041B601 >									
	//     < CHEMCHINA_PFI_I_metadata_line_4_____Acemay_Biochemicals_20220321 >									
	//        < L3Hp3UqDJVVGRqx6Yw8hxhDqVET8F0IPd0Ns3l7Wot27A29cjZrFqClZ99Heft78 >									
	//        <  u =="0.000000000000000001" : ] 000000043064326.123049400000000000 ; 000000056063549.168661400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000041B601558BD3 >									
	//     < CHEMCHINA_PFI_I_metadata_line_5_____Aemon_Chemical_Technology_Co_Limited_20220321 >									
	//        < 70Jfl06Nwg8Y8RQpiI75x80ft10oc7oqpPK67TqP53PGgt6ngv2q9aIoPMlv4VxW >									
	//        <  u =="0.000000000000000001" : ] 000000056063549.168661400000000000 ; 000000069154886.730664900000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000558BD36985A1 >									
	//     < CHEMCHINA_PFI_I_metadata_line_6_____AgileBioChem_Co_Limited_20220321 >									
	//        < cAeg7qdHy93iJTMM3dJw0CZd0WNw2314BEY4FCR6AU49ExGw0W05s9G60n6jzK5Q >									
	//        <  u =="0.000000000000000001" : ] 000000069154886.730664900000000000 ; 000000084993288.918498200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006985A181B081 >									
	//     < CHEMCHINA_PFI_I_metadata_line_7_____Aktin_Chemicals,_inc__20220321 >									
	//        < PJqZHB31o4AUxRRl8be5k2g0OXlCt8MXe3G6Y0Uw1805p9m37l210J3GxvwfIf3V >									
	//        <  u =="0.000000000000000001" : ] 000000084993288.918498200000000000 ; 000000098297181.651838700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000081B08195FD56 >									
	//     < CHEMCHINA_PFI_I_metadata_line_8_____Aktin_Chemicals,_org_20220321 >									
	//        < 02T2FxO8QiB9W1811nGj4pqMztgZ38UIpjN12tT5GSU9I2aVbxn0y997n5tSN6Bs >									
	//        <  u =="0.000000000000000001" : ] 000000098297181.651838700000000000 ; 000000110946475.204030000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000095FD56A94A78 >									
	//     < CHEMCHINA_PFI_I_metadata_line_9_____Angene_International_Limited_20220321 >									
	//        < aGJ9Y1pdS5WQa95V6olw8L9NV2DuwF8pD7EoA4rr6P71C2bRjNig9AQ8s6IxwsBC >									
	//        <  u =="0.000000000000000001" : ] 000000110946475.204030000000000000 ; 000000125836198.865079000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A94A78C002C4 >									
	//     < CHEMCHINA_PFI_I_metadata_line_10_____ANSHAN_HIFI_CHEMICALS_Co__Limited_20220321 >									
	//        < 1SM2U611wahs935198qZv0iFd35M5F34xw5o15TfUxOvQ0PyF54LmD6BH104aY1f >									
	//        <  u =="0.000000000000000001" : ] 000000125836198.865079000000000000 ; 000000140457797.636842000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C002C4D65254 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFI_I_metadata_line_11_____Aromalake_Chemical_Corporation_Limited_20220321 >									
	//        < q60LoioKnC7bfY8D5ODD6iTrxovSykJA5jHjl0fOI8gn223B0d3Iuf122Q041196 >									
	//        <  u =="0.000000000000000001" : ] 000000140457797.636842000000000000 ; 000000152787236.992027000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D65254E92284 >									
	//     < CHEMCHINA_PFI_I_metadata_line_12_____Aromsyn_Co_Limited_20220321 >									
	//        < ky8P0U498n6tBYU43R55gUQ9Xk98u1e33aeHPLpW840x4La3v7y1QRd42fqNsU8l >									
	//        <  u =="0.000000000000000001" : ] 000000152787236.992027000000000000 ; 000000168038344.800047000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E9228410067FA >									
	//     < CHEMCHINA_PFI_I_metadata_line_13_____Arromax_Pharmatech_Co__Limited_20220321 >									
	//        < 7c0Rh1luiM4059rdh26CfyP4Opa52A46977r750ixDCs73E394RY4kPAj94zSDG1 >									
	//        <  u =="0.000000000000000001" : ] 000000168038344.800047000000000000 ; 000000180437052.914451000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010067FA1135339 >									
	//     < CHEMCHINA_PFI_I_metadata_line_14_____Asambly_Chemicals_Co_Limited_20220321 >									
	//        < q21c4tGnER0W4We1kQWH8Xuhv5OjRarUnX1P0xbR8Cl78dsoVd48GeXpDiuEVVSL >									
	//        <  u =="0.000000000000000001" : ] 000000180437052.914451000000000000 ; 000000195318648.116764000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000113533912A0859 >									
	//     < CHEMCHINA_PFI_I_metadata_line_15_____Atomax_Chemicals_Co__Limited_20220321 >									
	//        < 7Tec3HW842n8o3185K6zZXlsXL51X0Dsh4lchne4Rg26XB31CQDxncG6rN12HxOB >									
	//        <  u =="0.000000000000000001" : ] 000000195318648.116764000000000000 ; 000000210726532.012637000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012A08591418B0D >									
	//     < CHEMCHINA_PFI_I_metadata_line_16_____Atomax_Chemicals_org_20220321 >									
	//        < 9XJ6y4P3J6NU8ahfdduEO3LKe0qDvlunxu3ljGK73BPXkG528vGJOR63jy5463x7 >									
	//        <  u =="0.000000000000000001" : ] 000000210726532.012637000000000000 ; 000000226143644.892808000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001418B0D159115C >									
	//     < CHEMCHINA_PFI_I_metadata_line_17_____Beijing_Pure_Chem__Co_Limited_20220321 >									
	//        < ZTugt9jeg61he0ZSiEJWH847iM8FqKdCTZV29b6A853ziyFhG29eZf8B9E1JUgzU >									
	//        <  u =="0.000000000000000001" : ] 000000226143644.892808000000000000 ; 000000239485193.432416000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000159115C16D6CE7 >									
	//     < CHEMCHINA_PFI_I_metadata_line_18_____BEIJING_SHLHT_CHEMICAL_TECHNOLOGY_20220321 >									
	//        < Td6gMrD4p5Q0Fw943J2X8M4x782cUHE788d4NFcnRbK4pw4I2O59qmB65T1TBtZ0 >									
	//        <  u =="0.000000000000000001" : ] 000000239485193.432416000000000000 ; 000000254948314.360139000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016D6CE7185052F >									
	//     < CHEMCHINA_PFI_I_metadata_line_19_____Beijing_Smart_Chemicals_Co_Limited_20220321 >									
	//        < w9IIzqdCKr9t5Mbb4wOXe8MaPpUaS81bjg87WDCxK25h77k6RrzYfnWD25EH1sYW >									
	//        <  u =="0.000000000000000001" : ] 000000254948314.360139000000000000 ; 000000269505117.372652000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000185052F19B3B70 >									
	//     < CHEMCHINA_PFI_I_metadata_line_20_____Beijing_Stable_Chemical_Co_Limited_20220321 >									
	//        < 22pBPS5P5cY5gljlPOR90OY8RO6371W72EZdo5a0gH7Sh4S8TzHeRe3yerfg30p6 >									
	//        <  u =="0.000000000000000001" : ] 000000269505117.372652000000000000 ; 000000283907334.226544000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019B3B701B1354D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFI_I_metadata_line_21_____Beijing_Sunpu_Biochem___Tech__Co__Limited_20220321 >									
	//        < Ao6Ri704jn11352LiH5Y7E91PqnbOwsdUlMecMhYV3Eai748lW8Oeez2Av9j0CD9 >									
	//        <  u =="0.000000000000000001" : ] 000000283907334.226544000000000000 ; 000000296267685.430153000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B1354D1C41191 >									
	//     < CHEMCHINA_PFI_I_metadata_line_22_____Bellen_Chemistry_Co__Limited_20220321 >									
	//        < vvEaOHpyXO7up2U3Rk30Z9h0I9Es3ryHE5gXyZOfoQF8432bjp3l7L9F4s6zDS5f >									
	//        <  u =="0.000000000000000001" : ] 000000296267685.430153000000000000 ; 000000312064094.847747000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C411911DC2C09 >									
	//     < CHEMCHINA_PFI_I_metadata_line_23_____BEYO_CHEMICAL_Co__Limited_20220321 >									
	//        < 8cK309p3Y075v0SwfdNrX4lqNkIXv0FBN8j70Juymig5231sDiZbiOxL079T4E7P >									
	//        <  u =="0.000000000000000001" : ] 000000312064094.847747000000000000 ; 000000326514528.934342000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DC2C091F238BD >									
	//     < CHEMCHINA_PFI_I_metadata_line_24_____Beyond_Pharmaceutical_Co_Limited_20220321 >									
	//        < 4sj48926BQBVz683N3ySG4lPC3A8wA36V16u49014Wo3g6RHIFb45gIbL37tF727 >									
	//        <  u =="0.000000000000000001" : ] 000000326514528.934342000000000000 ; 000000340251544.896348000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F238BD2072EC2 >									
	//     < CHEMCHINA_PFI_I_metadata_line_25_____Binhai_Gaolou_Chemical_Co_Limited_20220321 >									
	//        < 4YTq70MJU3z4amt47U7e5jNLG59P9U39zE2932wi1Y9J2447j2f48X8uiK2DG517 >									
	//        <  u =="0.000000000000000001" : ] 000000340251544.896348000000000000 ; 000000354364202.683361000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002072EC221CB784 >									
	//     < CHEMCHINA_PFI_I_metadata_line_26_____Binhong_Industry_Co__Limited_20220321 >									
	//        < CyFmrpOME6oKuhli58IrvAp3H920g5087KusZRu1I1oD3FLCJP739iSNtIDtjo3y >									
	//        <  u =="0.000000000000000001" : ] 000000354364202.683361000000000000 ; 000000367569759.192729000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021CB784230DDF0 >									
	//     < CHEMCHINA_PFI_I_metadata_line_27_____BLD_Pharmatech_org_20220321 >									
	//        < tUsOUsq8Ox1yQYLt5s50m0r83A0B8IN44T9Cwz7cR4N1ehb15vb865fB987rRL87 >									
	//        <  u =="0.000000000000000001" : ] 000000367569759.192729000000000000 ; 000000380259821.993897000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000230DDF02443AFE >									
	//     < CHEMCHINA_PFI_I_metadata_line_28_____BLD_Pharmatech_Limited_20220321 >									
	//        < 0MRXAJ0171AJfDN2DjDiOUz9yHLGUXxnYhjoUteVL6WaC0Ky87VJ4HxgDpFc2EZ0 >									
	//        <  u =="0.000000000000000001" : ] 000000380259821.993897000000000000 ; 000000393694317.118556000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002443AFE258BAD8 >									
	//     < CHEMCHINA_PFI_I_metadata_line_29_____Bocchem_20220321 >									
	//        < ju3X7k675F9GaDX5jj7x7Gf5u33ewff31H0du5U64lBpzI23iWm4lns8fB23zsX3 >									
	//        <  u =="0.000000000000000001" : ] 000000393694317.118556000000000000 ; 000000409726344.894086000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000258BAD8271315A >									
	//     < CHEMCHINA_PFI_I_metadata_line_30_____Boroncore_LLC_20220321 >									
	//        < 83dwh40Q6kjQPr5Azo3TrS5Z808V3498d2DtmLSwRhFhe944Eh3RIWg0BoO62VEH >									
	//        <  u =="0.000000000000000001" : ] 000000409726344.894086000000000000 ; 000000423522410.238724000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000271315A2863E71 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFI_I_metadata_line_31_____BTC_Pharmaceuticals_Co_Limited_20220321 >									
	//        < lQ2OTV5uNA5Xqd6LSinOADeQ2Ng7Zxocn7GJRttOmt6t373dOUMMz7d2cujssJ43 >									
	//        <  u =="0.000000000000000001" : ] 000000423522410.238724000000000000 ; 000000436169094.785650000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002863E712998A8D >									
	//     < CHEMCHINA_PFI_I_metadata_line_32_____Cangzhou_Goldlion_Chemicals_Co_Limited_20220321 >									
	//        < 9L6QEMZ5PU9249Cba71l7p74f4wTx5L0uWfcAU7Moh8tP5t4SLAbF7SXG9oSaKEa >									
	//        <  u =="0.000000000000000001" : ] 000000436169094.785650000000000000 ; 000000451052334.370698000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002998A8D2B04051 >									
	//     < CHEMCHINA_PFI_I_metadata_line_33_____Capot_Chemical_Co_Limited_20220321 >									
	//        < A3Uf3oWWxU39QyC8721TI9YJen67dDjq9IkLhtt6eq0013612628DCZ5RuV994P7 >									
	//        <  u =="0.000000000000000001" : ] 000000451052334.370698000000000000 ; 000000467103514.309214000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B040512C8BE4F >									
	//     < CHEMCHINA_PFI_I_metadata_line_34_____CBS_TECHNOLOGY_LTD_20220321 >									
	//        < z711LUhD4Th6aRIwSth39Da1DNs2B1J3091a3XVPS1VoK4699N01m32G16ogYe9A >									
	//        <  u =="0.000000000000000001" : ] 000000467103514.309214000000000000 ; 000000480058543.980600000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C8BE4F2DC82DE >									
	//     < CHEMCHINA_PFI_I_metadata_line_35_____Changzhou_Carbochem_Co_Limited_20220321 >									
	//        < xfNWi5G685rb4Gf2U0rS07h534351dIvLg3n5WGZ3Y1Es4t5Sa1x3MOxq6k0A637 >									
	//        <  u =="0.000000000000000001" : ] 000000480058543.980600000000000000 ; 000000494015798.267553000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DC82DE2F1CEEC >									
	//     < CHEMCHINA_PFI_I_metadata_line_36_____Changzhou_Hengda_Biotechnology_Co__org_20220321 >									
	//        < 6YTK2kY0n8H28UmZ35RDUDcQ1GStFc2RlPqmV0EewVYLJAbIfQKLYwGjPXDPagxY >									
	//        <  u =="0.000000000000000001" : ] 000000494015798.267553000000000000 ; 000000510024630.538324000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F1CEEC30A3C5F >									
	//     < CHEMCHINA_PFI_I_metadata_line_37_____Changzhou_Hengda_Biotechnology_Co__Limited_20220321 >									
	//        < JUebsgW7eCjg20j52j5BX2atA57napGmgE034O30GBmzI1Cz4i8y7DE6uR3AfItN >									
	//        <  u =="0.000000000000000001" : ] 000000510024630.538324000000000000 ; 000000522586035.816742000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030A3C5F31D672C >									
	//     < CHEMCHINA_PFI_I_metadata_line_38_____Changzhou_LanXu_Chemical_Co_Limited_20220321 >									
	//        < Mc690734vQtq7e0G1W4g80gdo8wt069XFrV4dl6TU79zZ6Up7w1X98196TneMAvk >									
	//        <  u =="0.000000000000000001" : ] 000000522586035.816742000000000000 ; 000000534886141.557242000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031D672C3302BE6 >									
	//     < CHEMCHINA_PFI_I_metadata_line_39_____Changzhou_Standard_Chemicals_Co_Limited_20220321 >									
	//        < M4o2PE0C9kq1Sp0Ef47Szh8W2kt3WjPGzZ5n33cUFZe3gwIr41rJjvS28A31Q35k >									
	//        <  u =="0.000000000000000001" : ] 000000534886141.557242000000000000 ; 000000548817943.929687000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003302BE63456E02 >									
	//     < CHEMCHINA_PFI_I_metadata_line_40_____CHANGZHOU_WEIJIA_CHEMICAL_Co_Limited_20220321 >									
	//        < jliI3T4Czfql4O1q5XzV0R7kg8zQjS3s4rI4S07530bjlJ09S3pbWr2A94658VSA >									
	//        <  u =="0.000000000000000001" : ] 000000548817943.929687000000000000 ; 000000561734866.207499000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003456E0235923AF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}