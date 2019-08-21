pragma solidity 		^0.4.25	;						
										
	contract	CHEMCHINA_PFVII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	CHEMCHINA_PFVII_II_883		"	;
		string	public		symbol =	"	CHEMCHINA_PFVII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		639925018567807000000000000					;	
										
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
	//     < CHEMCHINA_PFVII_II_metadata_line_1_____Taizhou_Creating_Chemical_Co_Limited_20240321 >									
	//        < 871Q7M0xhk88i2mOV73XqA4H9X00IZlILK89ZUFdWDNf1TL2O4jAtHdSJyapZ0A1 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000015327686.841937000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000176361 >									
	//     < CHEMCHINA_PFVII_II_metadata_line_2_____Tetrahedron_Scientific_Inc_20240321 >									
	//        < c18s21mF025euL8ya3549hbAee8i65516VP3Nb1OLRYV6Gfb8Ugtosa8P3LuSy3P >									
	//        <  u =="0.000000000000000001" : ] 000000015327686.841937000000000000 ; 000000032019790.130029500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000017636130DBBB >									
	//     < CHEMCHINA_PFVII_II_metadata_line_3_____Tianjin_Boai_NKY_International_Limited_20240321 >									
	//        < 8BpVzIx8gN1V69vw0D32Xb39mVR1yz92k36KCc1v6EdUMqt68Aq3r3c1Bb8W1dvt >									
	//        <  u =="0.000000000000000001" : ] 000000032019790.130029500000000000 ; 000000048706246.550719200000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000030DBBB4A51E1 >									
	//     < CHEMCHINA_PFVII_II_metadata_line_4_____Tianjin_Boron_PharmaTech_Co__Limited_20240321 >									
	//        < 30qC2ceO9m9c80W02d1IPTr1T5847xUsGK7RR5LkM7Xc375V2ByuShsw0t1D4h6a >									
	//        <  u =="0.000000000000000001" : ] 000000048706246.550719200000000000 ; 000000065201419.823025500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004A51E1637D4E >									
	//     < CHEMCHINA_PFVII_II_metadata_line_5_____TianJin_HuiQuan_Chemical_Industry_Co_Limited_20240321 >									
	//        < 4w2go3TMny5004i2L3GtchwM8t0ZE6N1mY8iWu8xoyG4lf01JQ735rR4vmW7n8R1 >									
	//        <  u =="0.000000000000000001" : ] 000000065201419.823025500000000000 ; 000000080075630.302174300000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000637D4E7A2F8B >									
	//     < CHEMCHINA_PFVII_II_metadata_line_6_____Tianjin_McEIT_Co_Limited_20240321 >									
	//        < pCikWAyNY0X81M3qAna5TN48krjFhtITKqdo5v7oQ6eOK4lF8ky4NW80S32b15s1 >									
	//        <  u =="0.000000000000000001" : ] 000000080075630.302174300000000000 ; 000000095955815.855138800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007A2F8B926ABE >									
	//     < CHEMCHINA_PFVII_II_metadata_line_7_____Tianjin_Norland_Biotech_org_20240321 >									
	//        < c8z3lGEPA4Rnbx5F21GS6DD70mk6RFd70qTMnJA03WTi4DE99JlpwLu02NPQr6x1 >									
	//        <  u =="0.000000000000000001" : ] 000000095955815.855138800000000000 ; 000000112649972.791570000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000926ABEABE3E5 >									
	//     < CHEMCHINA_PFVII_II_metadata_line_8_____Tianjin_Norland_Biotech_Co_Limited_20240321 >									
	//        < txIGnp9N95s6w9GasYdDn8GKkDTr21DJ6vSP28UcznM5Ob2E1LBfCLIg41zniwSc >									
	//        <  u =="0.000000000000000001" : ] 000000112649972.791570000000000000 ; 000000128149201.816878000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000ABE3E5C38A48 >									
	//     < CHEMCHINA_PFVII_II_metadata_line_9_____Tianjin_Tiandingren_Technology_Co_Limited_20240321 >									
	//        < Po652JJ1JKHXwGkJLSWZ1TFC8qZ9513g8ovvEMRO7DB7eWDF9C4PPlqPQ8O06VT4 >									
	//        <  u =="0.000000000000000001" : ] 000000128149201.816878000000000000 ; 000000143407615.500441000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C38A48DAD29A >									
	//     < CHEMCHINA_PFVII_II_metadata_line_10_____TOP_FINE_CHEM_20240321 >									
	//        < fmkbJX58ry62r38kXbM4Fhbc0xe1mBP1p1Bu8GcR5InCGsLEOe24E1U1tL33mGUv >									
	//        <  u =="0.000000000000000001" : ] 000000143407615.500441000000000000 ; 000000160191921.660074000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DAD29AF46EF8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFVII_II_metadata_line_11_____Trust_We_Co__Limited_20240321 >									
	//        < EogUdY2i86hZ4Bd625uWcfejimoq74e9Zi1f26Mj3Quk0mb7R8l8LhmygqYIUPfz >									
	//        <  u =="0.000000000000000001" : ] 000000160191921.660074000000000000 ; 000000175771228.696114000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F46EF810C34A3 >									
	//     < CHEMCHINA_PFVII_II_metadata_line_12_____Unispec_Chemicals_Co__20240321 >									
	//        < 5xrc5t7n66j2LwmT3FwI5t8RMX30qJicEh2t8jPT51SB8ASU8684e2vhQ6e8oNZ8 >									
	//        <  u =="0.000000000000000001" : ] 000000175771228.696114000000000000 ; 000000191190887.499471000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010C34A3123BBF1 >									
	//     < CHEMCHINA_PFVII_II_metadata_line_13_____Varnor_Chemical_Co_Limited_20240321 >									
	//        < gQ376hjnWH83bu3rm59MtNXE148FWVzvpDXuPCaNtcgz923tc620W336g4Ye318D >									
	//        <  u =="0.000000000000000001" : ] 000000191190887.499471000000000000 ; 000000206806701.834199000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000123BBF113B8FDE >									
	//     < CHEMCHINA_PFVII_II_metadata_line_14_____VEGSCI,_inc__20240321 >									
	//        < RiNmv2QQC879Jlh064x2LZZ4xZVzVpLWtz1JWhcWgGkJ3g8mBTefvaSJ9r8eWV2K >									
	//        <  u =="0.000000000000000001" : ] 000000206806701.834199000000000000 ; 000000224421460.504361000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013B8FDE15670A2 >									
	//     < CHEMCHINA_PFVII_II_metadata_line_15_____Vesino_Industrial_Co__Limited_20240321 >									
	//        < xO1HkH4KiIgp0RuUawEWocgk7uYm1I7erHXEm3o1kQjv47hv5exg8m4ywq005160 >									
	//        <  u =="0.000000000000000001" : ] 000000224421460.504361000000000000 ; 000000240190434.549131000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015670A216E8063 >									
	//     < CHEMCHINA_PFVII_II_metadata_line_16_____Volant_Chem_org_20240321 >									
	//        < KKeom38OgLsulN38M5K41zkNpI77a0uY4A4i9F6GxEbbgvl9ffn3cxe97ht7fByE >									
	//        <  u =="0.000000000000000001" : ] 000000240190434.549131000000000000 ; 000000255350025.652543000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016E8063185A21B >									
	//     < CHEMCHINA_PFVII_II_metadata_line_17_____Volant_Chem_Corp__20240321 >									
	//        < TMt3VDj0nC1e95emUVKAq8Uq6PT9O5965EYZnM7NFt0NNz12IIqg1355hkPkEj7v >									
	//        <  u =="0.000000000000000001" : ] 000000255350025.652543000000000000 ; 000000271310249.285748000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000185A21B19DFC91 >									
	//     < CHEMCHINA_PFVII_II_metadata_line_18_____Win_Win_chemical_Co_Limited_20240321 >									
	//        < MaqBEgt4jKW064f2k9eY5X8NK4606FRu1Jkz5dpvNtFV06mkiss49CQES065L0a9 >									
	//        <  u =="0.000000000000000001" : ] 000000271310249.285748000000000000 ; 000000287027829.692363000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019DFC911B5F83F >									
	//     < CHEMCHINA_PFVII_II_metadata_line_19_____WJF_Chemicals_Co__20240321 >									
	//        < 2Z65oYX012wrewEd7Qukm5F8Ut9nQAe0yglsasKGipB3SJ50ev79nLa6EQY6nv10 >									
	//        <  u =="0.000000000000000001" : ] 000000287027829.692363000000000000 ; 000000303578027.933420000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B5F83F1CF392B >									
	//     < CHEMCHINA_PFVII_II_metadata_line_20_____Wuhan_Bright_Chemical_Co__Limited_20240321 >									
	//        < XCpvCrdjh0PeQ66zhIAJs0w408L6LrnFv337lZ7rtoeJY4D6OzBJ41Kxs4uqXGtw >									
	//        <  u =="0.000000000000000001" : ] 000000303578027.933420000000000000 ; 000000319215986.543088000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CF392B1E715BF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFVII_II_metadata_line_21_____Wuhan_Yuancheng_Chemical_Manufactory_org_20240321 >									
	//        < 7082MxY70D2LZ0B11Aipnrv71aNHO6PqW6i119Za94T36R9kNtU833A5Ai63m4N5 >									
	//        <  u =="0.000000000000000001" : ] 000000319215986.543088000000000000 ; 000000336295317.200602000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E715BF201255C >									
	//     < CHEMCHINA_PFVII_II_metadata_line_22_____Wuhan_Yuancheng_Chemical_Manufactory_20240321 >									
	//        < bN0nK6Ok8pQvmk31ItpC9pHQl731WNGCAs8qMMeuvb26a5f7Q3O8umPeMLd5PRj4 >									
	//        <  u =="0.000000000000000001" : ] 000000336295317.200602000000000000 ; 000000352632041.236324000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000201255C21A12E4 >									
	//     < CHEMCHINA_PFVII_II_metadata_line_23_____Wuhu_Foman_Biopharma_Co_Limited_20240321 >									
	//        < 48x6HdYug39Its5pI53wKq9QRtMnkrqmQBjaUuKsPi44a9UQ9sN7L9R9MJG6z7O3 >									
	//        <  u =="0.000000000000000001" : ] 000000352632041.236324000000000000 ; 000000369384584.013979000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021A12E4233A2DA >									
	//     < CHEMCHINA_PFVII_II_metadata_line_24_____Xi_an_Caijing_Opto_Electrical_Science___Technology_Co__Limited_20240321 >									
	//        < op1nf1h21L23k72Z7o9mt0VKgU7kvX6GoCL7ctTl85TSdSYSm4C1TPcCL5rCUfmc >									
	//        <  u =="0.000000000000000001" : ] 000000369384584.013979000000000000 ; 000000385784809.235663000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000233A2DA24CA931 >									
	//     < CHEMCHINA_PFVII_II_metadata_line_25_____XIAMEN_EQUATION_CHEMICAL_org_20240321 >									
	//        < 27dYD8D4PTy5N798L3sto4ESxVWvSDLN6ZR10B6rQrsL356L478e207qIi7ws6J0 >									
	//        <  u =="0.000000000000000001" : ] 000000385784809.235663000000000000 ; 000000402412247.876250000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024CA9312660849 >									
	//     < CHEMCHINA_PFVII_II_metadata_line_26_____XIAMEN_EQUATION_CHEMICAL_Co_Limited_20240321 >									
	//        < ThaGPp2h41956c3NK7qQ6d524K1ci92X4o44aQU7QT8bBI571F2af1z893aAG6jL >									
	//        <  u =="0.000000000000000001" : ] 000000402412247.876250000000000000 ; 000000418688331.049594000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000266084927EDE21 >									
	//     < CHEMCHINA_PFVII_II_metadata_line_27_____Yacoo_Chemical_Reagent_Co_Limited_20240321 >									
	//        < 8DsX2gvX97sTl66s3gQ6NnNqNximMerztbXRg7u03lrK7r8YkKcplfqCe47Z6k35 >									
	//        <  u =="0.000000000000000001" : ] 000000418688331.049594000000000000 ; 000000434026683.134766000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027EDE2129645AC >									
	//     < CHEMCHINA_PFVII_II_metadata_line_28_____Yantai_Taroke_Bio_engineering_Co_Limited_20240321 >									
	//        < 00Z6aWY80sXnEq9jo37CREtI4OjfIS55a6hLaoTFMK0PdGTOhy35Eo1Pj549e54A >									
	//        <  u =="0.000000000000000001" : ] 000000434026683.134766000000000000 ; 000000450043614.020663000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029645AC2AEB649 >									
	//     < CHEMCHINA_PFVII_II_metadata_line_29_____Zehao_Industry_Co__Limited_20240321 >									
	//        < 53VV4O6q15IMmoFyJQs34QhE5a9uWQZl68731n4lCQJc3j7d50o9Athx5XKY3UO3 >									
	//        <  u =="0.000000000000000001" : ] 000000450043614.020663000000000000 ; 000000465132865.960461000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AEB6492C5BC87 >									
	//     < CHEMCHINA_PFVII_II_metadata_line_30_____Zeroschem_org_20240321 >									
	//        < 67oO22Wt30aWjSHywxqlh51644f3SanGY22pBV0HUG7e6ygOBv7y2oN58h18znM0 >									
	//        <  u =="0.000000000000000001" : ] 000000465132865.960461000000000000 ; 000000480957705.059898000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C5BC872DDE21B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFVII_II_metadata_line_31_____Zeroschem_Co_Limited_20240321 >									
	//        < 8qVN6G3OJeD7qrcDrjfQi0zwU5SGeV8oGmY7411JbrFncA7mYd02WGr1dPF265ou >									
	//        <  u =="0.000000000000000001" : ] 000000480957705.059898000000000000 ; 000000496804898.475490000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DDE21B2F6106A >									
	//     < CHEMCHINA_PFVII_II_metadata_line_32_____ZHANGJIAGANG_HUACHANG_PHARMACEUTICAL_Co__Limited_20240321 >									
	//        < W5s4B3KiVhk8W35nL0JTjJ8q9N13kWi3757afB78Uf4QRr5iC6b51T4Js5S13c2B >									
	//        <  u =="0.000000000000000001" : ] 000000496804898.475490000000000000 ; 000000512509236.928547000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F6106A30E06EC >									
	//     < CHEMCHINA_PFVII_II_metadata_line_33_____Zheda_Panaco_Chemical_Engineering_Co___Ltd___ZhedaChem__20240321 >									
	//        < P8G49e56e39G891wwkvoOsylkPtdLEr2P7wj96ZED9ZYRY22eUf2jkz1TqJC8Br2 >									
	//        <  u =="0.000000000000000001" : ] 000000512509236.928547000000000000 ; 000000527790541.801412000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030E06EC325582E >									
	//     < CHEMCHINA_PFVII_II_metadata_line_34_____Zhejiang_J_C_Biological_Technology_Co_Limited_20240321 >									
	//        < 5R2bA7kC4UiUTR1ZMsbln0Svrgc4oVzQ8ZCP2QrMUc2hpVzDqHW6sl9H7u8rXI8H >									
	//        <  u =="0.000000000000000001" : ] 000000527790541.801412000000000000 ; 000000542774071.350047000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000325582E33C351F >									
	//     < CHEMCHINA_PFVII_II_metadata_line_35_____Zhengzhou_Meitong_Pharmaceutical_Technology_20240321 >									
	//        < 7nzRFr3YfhLg50366g2F92wST1cNMCCIN7k9j9p1SZ0k5mPRDXWLNEJpq8qqA7GM >									
	//        <  u =="0.000000000000000001" : ] 000000542774071.350047000000000000 ; 000000557933622.000758000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033C351F35356D2 >									
	//     < CHEMCHINA_PFVII_II_metadata_line_36_____ZHIWE_ChemTech_org_20240321 >									
	//        < jke72j7A23q4v71ssn92cBvlyf01GYm2Sy0N1idD6eF9V3O4Yv5kAK6AXR2Vvb1q >									
	//        <  u =="0.000000000000000001" : ] 000000557933622.000758000000000000 ; 000000575175870.797473000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035356D236DA613 >									
	//     < CHEMCHINA_PFVII_II_metadata_line_37_____ZHIWE_ChemTech_Co_Limited_20240321 >									
	//        < EcgwhJVxm7YtO6ti8K0ghICkV1SK6L7pC294s83zpbsX8EE4fT17e83YI5sMb14e >									
	//        <  u =="0.000000000000000001" : ] 000000575175870.797473000000000000 ; 000000592026171.507320000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036DA6133875C39 >									
	//     < CHEMCHINA_PFVII_II_metadata_line_38_____Zhongtian_Kosen_Corporation_Limited_20240321 >									
	//        < 1Fh6pI93vd1LdoKAK859DcC2g4l97xC5XNzB44359z90GjP3d65h7gknqW961C2r >									
	//        <  u =="0.000000000000000001" : ] 000000592026171.507320000000000000 ; 000000608083326.719452000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003875C3939FDC8D >									
	//     < CHEMCHINA_PFVII_II_metadata_line_39_____Zibo_Honors_chemical_Co_Limited_20240321 >									
	//        < Adfjjyc9KE5WzJQF6n5q5kTJciyIf0Mlo6hby847WxOCy1co507a5w00t20FfP4l >									
	//        <  u =="0.000000000000000001" : ] 000000608083326.719452000000000000 ; 000000624655621.858327000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039FDC8D3B9261A >									
	//     < CHEMCHINA_PFVII_II_metadata_line_40_____Zouping_Mingxing_Chemical_Co__Limited_20240321 >									
	//        < VnD663WDVE7d3aOqUlU7h6x27rs27j031HvbxJyGtYgazvgF38d4R2F44R2DmYiv >									
	//        <  u =="0.000000000000000001" : ] 000000624655621.858327000000000000 ; 000000639925018.567807000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B9261A3D072B6 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}