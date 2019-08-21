pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXVII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXVII_II_883		"	;
		string	public		symbol =	"	RUSS_PFXXVII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		807837516650864000000000000					;	
										
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
	//     < RUSS_PFXXVII_II_metadata_line_1_____SIBUR_20231101 >									
	//        < 9v49V0SnhzcB57DSnlrWiMeMK0Ve1D662e9No6T43anNc66nCKZgwdPSDoyU1HgN >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000019786508.253109800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001E311B >									
	//     < RUSS_PFXXVII_II_metadata_line_2_____SIBURTYUMENGAZ_20231101 >									
	//        < 7MDXcD6Uwthyf0NMh7907r16kXgTDtT476Q28J965std9xx76926b29F122N8bMD >									
	//        <  u =="0.000000000000000001" : ] 000000019786508.253109800000000000 ; 000000035925097.346869500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001E311B36D13E >									
	//     < RUSS_PFXXVII_II_metadata_line_3_____VOLGOPROMGAZ_GROUP_20231101 >									
	//        < iS4ALDQhB2yAer2Ok8d7dKh0hj0807n77cr3foN9SYhm9aTl382ICaJWQ7m3lGVO >									
	//        <  u =="0.000000000000000001" : ] 000000035925097.346869500000000000 ; 000000052797858.948898200000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000036D13E50902A >									
	//     < RUSS_PFXXVII_II_metadata_line_4_____KSTOVO_20231101 >									
	//        < zwl4l4RmXH2Us0c4F2ReMk22gStxu5bo5HqcIh90vhnsY7IpI5h3e4Yc2Bwvp9Qn >									
	//        <  u =="0.000000000000000001" : ] 000000052797858.948898200000000000 ; 000000077250728.222993200000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000050902A75E011 >									
	//     < RUSS_PFXXVII_II_metadata_line_5_____SIBUR_MOTORS_20231101 >									
	//        < 7C25QkldZRP3b61qX79Cg16mVBH7x7c71ye0yWdb18B02U4d3bwBRgHI435G2l9I >									
	//        <  u =="0.000000000000000001" : ] 000000077250728.222993200000000000 ; 000000100947604.380362000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000075E0119A08A8 >									
	//     < RUSS_PFXXVII_II_metadata_line_6_____SIBUR_FINANCE_20231101 >									
	//        < 2PzWn2nnqoBjB4oUEM30D63I275B532nxwl9kc7MR9991RV33TB4Dk7kzn00R2GY >									
	//        <  u =="0.000000000000000001" : ] 000000100947604.380362000000000000 ; 000000119007217.178692000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009A08A8B59732 >									
	//     < RUSS_PFXXVII_II_metadata_line_7_____AKRILAT_20231101 >									
	//        < a8HC4fhLW90j3gKhT8If4qKmK770WGuAJ29ZC0j17wu9Ekb0RqI9t1Wq86AXUdDQ >									
	//        <  u =="0.000000000000000001" : ] 000000119007217.178692000000000000 ; 000000142920556.790933000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B59732DA1458 >									
	//     < RUSS_PFXXVII_II_metadata_line_8_____SINOPEC_RUBBER_20231101 >									
	//        < 647T25nQuVRXG8mApJFRD2W83XXYVtIHAa1i3tS0pm4715T2xD2Q5ZDSWrUZ021U >									
	//        <  u =="0.000000000000000001" : ] 000000142920556.790933000000000000 ; 000000165483156.016621000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DA1458FC81DC >									
	//     < RUSS_PFXXVII_II_metadata_line_9_____TOBOLSK_NEFTEKHIM_20231101 >									
	//        < S8u84bwW76w97X5oX3wjukg8J6P9ooe7gk0Hqm26kz93YyKk3cZ9Fxa0JizK2sl7 >									
	//        <  u =="0.000000000000000001" : ] 000000165483156.016621000000000000 ; 000000184490168.258179000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FC81DC1198279 >									
	//     < RUSS_PFXXVII_II_metadata_line_10_____SIBUR_PETF_20231101 >									
	//        < 66B46o3W352h62GidFLVJ16F0mo9YZ64fwej4x18r4uYDxuUcnJ9Mx26Uj2iQbm0 >									
	//        <  u =="0.000000000000000001" : ] 000000184490168.258179000000000000 ; 000000205561260.340694000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001198279139A95E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVII_II_metadata_line_11_____MURAVLENKOVSKY_GAS_PROCESS_PLANT_20231101 >									
	//        < xp2V7ZMmJ8sQNOIT8y7vzhorBw6ti63dZ35372Cifn112yv8D7oQY38lp287I7MH >									
	//        <  u =="0.000000000000000001" : ] 000000205561260.340694000000000000 ; 000000230100655.393408000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000139A95E15F1B12 >									
	//     < RUSS_PFXXVII_II_metadata_line_12_____OOO_IT_SERVICE_20231101 >									
	//        < Bkn94G1OJeUyg6zcOla96zCSdp8GQJ757l5JqK9bMPxP8PHz8loEOW6evlT93lSr >									
	//        <  u =="0.000000000000000001" : ] 000000230100655.393408000000000000 ; 000000245830024.059699000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015F1B121771B5A >									
	//     < RUSS_PFXXVII_II_metadata_line_13_____ZAO_MIRACLE_20231101 >									
	//        < hOA7hRIekqwXUY9jlU5E4RAmu4vOInPrZ74CNfNM6EeC23bb7Yt7YIMNU3M0NjoP >									
	//        <  u =="0.000000000000000001" : ] 000000245830024.059699000000000000 ; 000000267497256.947116000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001771B5A1982B1E >									
	//     < RUSS_PFXXVII_II_metadata_line_14_____NOVATEK_POLYMER_20231101 >									
	//        < 04GQltwSrFMl9ID27vkVfvH8k55dX4VjFIFHRD118u7xqxpcm019MGwS09p4mg1m >									
	//        <  u =="0.000000000000000001" : ] 000000267497256.947116000000000000 ; 000000291828972.827602000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001982B1E1BD4BB1 >									
	//     < RUSS_PFXXVII_II_metadata_line_15_____SOUTHWEST_GAS_PIPELINES_20231101 >									
	//        < Lk6e5o5M366dH26WNyWA30L84qQ7A4h8yuu7NtOesfH0KZRq15cdHGDXoCfssE69 >									
	//        <  u =="0.000000000000000001" : ] 000000291828972.827602000000000000 ; 000000315406246.125984000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BD4BB11E14591 >									
	//     < RUSS_PFXXVII_II_metadata_line_16_____YUGRAGAZPERERABOTKA_20231101 >									
	//        < 2eITbr1E0ZTkB5ll9Wi7CAASMaIImOdAD4uh5g9qxd6813QHJAulTN94esmjRqEI >									
	//        <  u =="0.000000000000000001" : ] 000000315406246.125984000000000000 ; 000000338075350.025492000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E14591203DCAF >									
	//     < RUSS_PFXXVII_II_metadata_line_17_____TOMSKNEFTEKHIM_20231101 >									
	//        < B3BLkg376D2151t0XI63gG7JvudtKG1lptnf9iA80KUW4LebggVeOJ43o07bj1c7 >									
	//        <  u =="0.000000000000000001" : ] 000000338075350.025492000000000000 ; 000000357347870.301198000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000203DCAF2214503 >									
	//     < RUSS_PFXXVII_II_metadata_line_18_____BALTIC_LNG_20231101 >									
	//        < PmN91EDGYgd0E3jBwWQ1MwooPDyROY6A68zXW36EGoQaB0h6i4soS7M42NMn203N >									
	//        <  u =="0.000000000000000001" : ] 000000357347870.301198000000000000 ; 000000376132450.568840000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000221450323DEEBD >									
	//     < RUSS_PFXXVII_II_metadata_line_19_____SIBUR_INT_GMBH_20231101 >									
	//        < 4ups4LOYd3msI49uZPg5l02yUrh09g0oYeIf1t19zIdgKfe2p0cFaQyJbJ67cHTP >									
	//        <  u =="0.000000000000000001" : ] 000000376132450.568840000000000000 ; 000000396293995.290200000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023DEEBD25CB258 >									
	//     < RUSS_PFXXVII_II_metadata_line_20_____TOBOL_SK_POLIMER_20231101 >									
	//        < 0Xkrk9UYBLL84Y4VNzKJPJRdBba2I35pTQsihmq7e0vw4kTtA1F3j5g7Uk0F2cA9 >									
	//        <  u =="0.000000000000000001" : ] 000000396293995.290200000000000000 ; 000000413273552.755682000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025CB2582769AFB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVII_II_metadata_line_21_____SIBUR_SCIENT_RD_INSTITUTE_GAS_PROCESS_20231101 >									
	//        < Pu0IsEFj75wn1a2QpzGgIT0eMZ3l8hX6U1495g089HQiAwLUoo6MdKNxmWnzn5Rb >									
	//        <  u =="0.000000000000000001" : ] 000000413273552.755682000000000000 ; 000000429399285.169023000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002769AFB28F3619 >									
	//     < RUSS_PFXXVII_II_metadata_line_22_____ZAPSIBNEFTEKHIM_20231101 >									
	//        < pMR6TYAe94xL8tS2rVRHKgXR395LGb4C8i07ahVkUFv3GfquPVx30PWv8xW58h24 >									
	//        <  u =="0.000000000000000001" : ] 000000429399285.169023000000000000 ; 000000446500132.395753000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028F36192A94E1D >									
	//     < RUSS_PFXXVII_II_metadata_line_23_____RUSVINYL_20231101 >									
	//        < dY4VK4Rq43vJ3rEG2duwdpi7Q1qi5RjY8fA6uP385t7X7y7W64kZj2q1sL7mqYMN >									
	//        <  u =="0.000000000000000001" : ] 000000446500132.395753000000000000 ; 000000470534721.460244000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A94E1D2CDFAA0 >									
	//     < RUSS_PFXXVII_II_metadata_line_24_____SIBUR_SECURITIES_LIMITED_20231101 >									
	//        < irXz8cN6JeSNR29aDS7jTXMSO2KwS6HXNJ9457k63LuSi8LXnuvD6BYQ1063Lpt0 >									
	//        <  u =="0.000000000000000001" : ] 000000470534721.460244000000000000 ; 000000489395856.360040000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CDFAA02EAC242 >									
	//     < RUSS_PFXXVII_II_metadata_line_25_____ACRYLATE_20231101 >									
	//        < Jq536EOXTufGUvOv74J565WUwldgP7O4590D7Zz1QlN3y4k9nE1hG4UnVvpx51aG >									
	//        <  u =="0.000000000000000001" : ] 000000489395856.360040000000000000 ; 000000509505844.776635000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EAC24230971B8 >									
	//     < RUSS_PFXXVII_II_metadata_line_26_____BIAXPLEN_20231101 >									
	//        < Q8tOmsB4O87Eq4x177EKGApsXi6f4T88w7A7u58N14zRT60v83C7QUok9o1Rxo8j >									
	//        <  u =="0.000000000000000001" : ] 000000509505844.776635000000000000 ; 000000531117074.236206000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030971B832A6B9B >									
	//     < RUSS_PFXXVII_II_metadata_line_27_____PORTENERGO_20231101 >									
	//        < Om0e096P6S182G02aa246V3m7jYQ5EerqaTAPJc0LeZjkJAtr3n2QiKt1g7I4ln0 >									
	//        <  u =="0.000000000000000001" : ] 000000531117074.236206000000000000 ; 000000555053793.050291000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032A6B9B34EF1E3 >									
	//     < RUSS_PFXXVII_II_metadata_line_28_____POLIEF_20231101 >									
	//        < o26ePQDTC4114opQdV5O7zVRBleirz23r6SZ13t6gwj6t3D4IV9qDk19JLFBfMsL >									
	//        <  u =="0.000000000000000001" : ] 000000555053793.050291000000000000 ; 000000579324941.325985000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034EF1E3373FACE >									
	//     < RUSS_PFXXVII_II_metadata_line_29_____RUSPAV_20231101 >									
	//        < 575xZBiN2h08M86j9FqffGSZWP60WE036C5Z1962Wr1Hw60snor51Fuggai2JDq6 >									
	//        <  u =="0.000000000000000001" : ] 000000579324941.325985000000000000 ; 000000604190311.404956000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000373FACE399EBD7 >									
	//     < RUSS_PFXXVII_II_metadata_line_30_____NEFTEKHIMIA_20231101 >									
	//        < gmYKJ3lxoVk3Ji11v858FfYqoNEozQoz9SNMF8S33n2IzTxK1FbH9Dg6WInWJO6c >									
	//        <  u =="0.000000000000000001" : ] 000000604190311.404956000000000000 ; 000000628222306.937613000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000399EBD73BE9757 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVII_II_metadata_line_31_____OTECHESTVENNYE_POLIMERY_20231101 >									
	//        < 2502vR782WEuILeSUBzc7muhzjDlrf2pHoZ8YvINravUu72G9J4cX5Dk2Wy5M5rk >									
	//        <  u =="0.000000000000000001" : ] 000000628222306.937613000000000000 ; 000000644215795.234901000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003BE97573D6FECC >									
	//     < RUSS_PFXXVII_II_metadata_line_32_____SIBUR_TRANS_20231101 >									
	//        < fYdCK6lyNUBi9jXP2Dpj41s9IzCWCRQnrkLLVuzpXzxG65V1XQP19RYs65L4c6uY >									
	//        <  u =="0.000000000000000001" : ] 000000644215795.234901000000000000 ; 000000663382370.306951000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D6FECC3F43DBD >									
	//     < RUSS_PFXXVII_II_metadata_line_33_____TOGLIATTIKAUCHUK_20231101 >									
	//        < 1K2GO73iwa7Km7258s3y9y5TWtAFy9Ff4nWKYK8rk6IZO5NNCxT4Z617D3JU5v89 >									
	//        <  u =="0.000000000000000001" : ] 000000663382370.306951000000000000 ; 000000684481999.911044000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F43DBD4146FC8 >									
	//     < RUSS_PFXXVII_II_metadata_line_34_____NPP_NEFTEKHIMIYA_OOO_20231101 >									
	//        < SL6rJPRp2l9N335yRbZsg2W47ogIV9730xhx6mrxgqX9IW92u143v2bHirxL0uT4 >									
	//        <  u =="0.000000000000000001" : ] 000000684481999.911044000000000000 ; 000000705569993.366206000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004146FC84349D47 >									
	//     < RUSS_PFXXVII_II_metadata_line_35_____SIBUR_KHIMPROM_20231101 >									
	//        < bc3q4SIn44N28iWL8HQ4Fke1U2S03Kl38H92nQiLaJ31Ba1t7juY321KZG5lJ1N2 >									
	//        <  u =="0.000000000000000001" : ] 000000705569993.366206000000000000 ; 000000723739802.067457000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004349D4745056DC >									
	//     < RUSS_PFXXVII_II_metadata_line_36_____SIBUR_VOLZHSKY_20231101 >									
	//        < 4Ha3eG28ZnlhT8T9uoXAefJwblW1k2v6cVgR2F1p7VMHnZAx5a9V1mybNz1I8qF6 >									
	//        <  u =="0.000000000000000001" : ] 000000723739802.067457000000000000 ; 000000740329220.202653000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000045056DC469A71A >									
	//     < RUSS_PFXXVII_II_metadata_line_37_____VORONEZHSINTEZKAUCHUK_20231101 >									
	//        < m2z4iJq5x4MZ2fFp3ytR00ae21580Azq31bcJ4x5i08oTwWJTD8nwtFEFC3x9nAl >									
	//        <  u =="0.000000000000000001" : ] 000000740329220.202653000000000000 ; 000000759744228.853584000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000469A71A4874717 >									
	//     < RUSS_PFXXVII_II_metadata_line_38_____INFO_TECH_SERVICE_CO_20231101 >									
	//        < dL212iA8oNCM8mD91U3R1H52T44h0z1T1Ag8LILEqJaE092tI1qF4x114bJEsi71 >									
	//        <  u =="0.000000000000000001" : ] 000000759744228.853584000000000000 ; 000000775692093.113185000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000487471749F9CB9 >									
	//     < RUSS_PFXXVII_II_metadata_line_39_____LNG_NOVAENGINEERING_20231101 >									
	//        < 4FRw80BwnNk7YOSbxzr0qxa379pgr1rYS6d7pYe9p3Z5Tjd4wvy5c52ef6QfEbHK >									
	//        <  u =="0.000000000000000001" : ] 000000775692093.113185000000000000 ; 000000792188799.138194000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049F9CB94B8C8C0 >									
	//     < RUSS_PFXXVII_II_metadata_line_40_____SIBGAZPOLIMER_20231101 >									
	//        < YhHb77I6ZQg584M82jZSnt4wYH19fon9j1sFw9c6RY3asW6IGvf09bS0UU8dN35J >									
	//        <  u =="0.000000000000000001" : ] 000000792188799.138194000000000000 ; 000000807837516.650864000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B8C8C04D0A988 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}