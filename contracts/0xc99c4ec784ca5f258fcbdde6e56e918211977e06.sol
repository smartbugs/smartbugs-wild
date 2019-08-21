pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXVII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXVII_III_883		"	;
		string	public		symbol =	"	RUSS_PFXXVII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		977766545891770000000000000					;	
										
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
	//     < RUSS_PFXXVII_III_metadata_line_1_____SIBUR_20251101 >									
	//        < eI8PvFr82tEfaZba2ZM4UT0265Np7g3rHXq72B9hlNmJnUc52JU5JvrE17DaaTP5 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000035148812.221975300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000035A201 >									
	//     < RUSS_PFXXVII_III_metadata_line_2_____SIBURTYUMENGAZ_20251101 >									
	//        < 4YnN352a7ij0P1217t8jmBo5Q44W56Ze2Mz2q2mad461x80eftL5SbRtug9UC7h6 >									
	//        <  u =="0.000000000000000001" : ] 000000035148812.221975300000000000 ; 000000067074561.638749500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000035A201665900 >									
	//     < RUSS_PFXXVII_III_metadata_line_3_____VOLGOPROMGAZ_GROUP_20251101 >									
	//        < 9JE6a3g6F081CIA3587nY0E92R76zM6kwNWNwwi5z0rj3qJl9q0b9991Bimg62eh >									
	//        <  u =="0.000000000000000001" : ] 000000067074561.638749500000000000 ; 000000097646210.460877400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000066590094FF0D >									
	//     < RUSS_PFXXVII_III_metadata_line_4_____KSTOVO_20251101 >									
	//        < 0699Jx54hX2tO1hWPY4zMYp9bPN58VLcs26UZMEQpctRKMF0821leb0XOsy2j1QM >									
	//        <  u =="0.000000000000000001" : ] 000000097646210.460877400000000000 ; 000000122926235.130098000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000094FF0DBB9210 >									
	//     < RUSS_PFXXVII_III_metadata_line_5_____SIBUR_MOTORS_20251101 >									
	//        < 19MFDD47S86W36Mzq2Ou1cig3r6Nrp8fdod7C5e6PdiFEz5XCW8ZLGzBwmlhGa9l >									
	//        <  u =="0.000000000000000001" : ] 000000122926235.130098000000000000 ; 000000141286790.870610000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BB9210D79627 >									
	//     < RUSS_PFXXVII_III_metadata_line_6_____SIBUR_FINANCE_20251101 >									
	//        < VvRL8j1J54ShMt6a4wFwkN376fwuF6D8fVUN5gMClHfXKfB9rfi2e2G9Gv6y5U7e >									
	//        <  u =="0.000000000000000001" : ] 000000141286790.870610000000000000 ; 000000169488397.183643000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000D796271029E68 >									
	//     < RUSS_PFXXVII_III_metadata_line_7_____AKRILAT_20251101 >									
	//        < 06099O4M89rFc3Y18I3jPm3B0RN9mC98e550Ii2T5D6DfOK6X677kX5M657TKW58 >									
	//        <  u =="0.000000000000000001" : ] 000000169488397.183643000000000000 ; 000000189760396.757534000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001029E681218D28 >									
	//     < RUSS_PFXXVII_III_metadata_line_8_____SINOPEC_RUBBER_20251101 >									
	//        < sRexl8790WW7Qne9aAS6ykH2rOO3xjdGrS3Zz1Hj4J2E79Rz56nIONNdRgL2E8zK >									
	//        <  u =="0.000000000000000001" : ] 000000189760396.757534000000000000 ; 000000211879870.088352000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001218D281434D93 >									
	//     < RUSS_PFXXVII_III_metadata_line_9_____TOBOLSK_NEFTEKHIM_20251101 >									
	//        < uUaCHzAanhCGpVEulGL8j5dfqx8cKTWk0fC54tIp3RbJt6C4550200TJrf0PVbC8 >									
	//        <  u =="0.000000000000000001" : ] 000000211879870.088352000000000000 ; 000000230991434.698647000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001434D931607707 >									
	//     < RUSS_PFXXVII_III_metadata_line_10_____SIBUR_PETF_20251101 >									
	//        < ILfxHP52Tu2Z0Ss8yzqz40W1bt0eP622s2DE84HD56NQt0jK4DE3ZI2Sn7QvmuZo >									
	//        <  u =="0.000000000000000001" : ] 000000230991434.698647000000000000 ; 000000250016065.875906000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000160770717D7E87 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVII_III_metadata_line_11_____MURAVLENKOVSKY_GAS_PROCESS_PLANT_20251101 >									
	//        < LlG8agWy654eY75qpJaXNc4sk1x4w4q2iifooU11lvaC41QNOQv26hxai6hn702D >									
	//        <  u =="0.000000000000000001" : ] 000000250016065.875906000000000000 ; 000000276853204.454416000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017D7E871A671C8 >									
	//     < RUSS_PFXXVII_III_metadata_line_12_____OOO_IT_SERVICE_20251101 >									
	//        < Un1IrH72dj89Dpbt1H3snkoEQvz6t89f6H3osJldnSofEH4Gy09YYD9yj40i46W2 >									
	//        <  u =="0.000000000000000001" : ] 000000276853204.454416000000000000 ; 000000308097671.529702000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A671C81D61EA7 >									
	//     < RUSS_PFXXVII_III_metadata_line_13_____ZAO_MIRACLE_20251101 >									
	//        < mdLcG2O97lq9Rwg05N8wSeN23H6x78l2eM6vKXK0yhc3riFEDG8MDZR0KrI3840y >									
	//        <  u =="0.000000000000000001" : ] 000000308097671.529702000000000000 ; 000000328699161.425356000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D61EA71F58E1C >									
	//     < RUSS_PFXXVII_III_metadata_line_14_____NOVATEK_POLYMER_20251101 >									
	//        < YUWk3Ov401i0Mi3l0iz28yn2dTK99d35aBk5Tw5kGKi65HYHuxo80M6mrLw959AS >									
	//        <  u =="0.000000000000000001" : ] 000000328699161.425356000000000000 ; 000000348041806.004110000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F58E1C21311D5 >									
	//     < RUSS_PFXXVII_III_metadata_line_15_____SOUTHWEST_GAS_PIPELINES_20251101 >									
	//        < SJZI1D8qt2dZAYD7XA06OvkSBHT78ou023KgVf4Zn4gA23HQ7nJNRUaw9Nsa5v1a >									
	//        <  u =="0.000000000000000001" : ] 000000348041806.004110000000000000 ; 000000370247223.437212000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021311D5234F3D2 >									
	//     < RUSS_PFXXVII_III_metadata_line_16_____YUGRAGAZPERERABOTKA_20251101 >									
	//        < NvEK4sOs6Wi3D140C235XEqhV5h35ldCPXN7354wPW6n1D3G0271A6M14UnLi1oz >									
	//        <  u =="0.000000000000000001" : ] 000000370247223.437212000000000000 ; 000000401413287.535144000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000234F3D22648211 >									
	//     < RUSS_PFXXVII_III_metadata_line_17_____TOMSKNEFTEKHIM_20251101 >									
	//        < fzxe4jZP5040LxzqL0SFcJtHr0ruUex4V9crm4WTd6qmogy52GYKx357Q12k7211 >									
	//        <  u =="0.000000000000000001" : ] 000000401413287.535144000000000000 ; 000000428088173.191310000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000264821128D35F1 >									
	//     < RUSS_PFXXVII_III_metadata_line_18_____BALTIC_LNG_20251101 >									
	//        < u346tmjsI2q7d8zU6k10UH59fJHFi7o8q0tPGh31fWoYyUo7J6QN6eIrX71fgCM8 >									
	//        <  u =="0.000000000000000001" : ] 000000428088173.191310000000000000 ; 000000451470165.029559000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028D35F12B0E389 >									
	//     < RUSS_PFXXVII_III_metadata_line_19_____SIBUR_INT_GMBH_20251101 >									
	//        < Z91ucZ9sIb7I64X2rULF763J8vhVYkItC3MczvO1nq0r3Ao8WozB8hvgtPgkVHYc >									
	//        <  u =="0.000000000000000001" : ] 000000451470165.029559000000000000 ; 000000486534331.139315000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B0E3892E66479 >									
	//     < RUSS_PFXXVII_III_metadata_line_20_____TOBOL_SK_POLIMER_20251101 >									
	//        < 4l7dlr4jEY5UH06RE8245viJI19MKivue2tlv1eGI823DqAr2Q27r66YFMH57Ni0 >									
	//        <  u =="0.000000000000000001" : ] 000000486534331.139315000000000000 ; 000000505918446.675376000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E66479303F865 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVII_III_metadata_line_21_____SIBUR_SCIENT_RD_INSTITUTE_GAS_PROCESS_20251101 >									
	//        < 9ngRHUD6Om725FmjbuCdCx5wl50cH0GY7jKJ3Bb6Pv4yN7ynIp3VF77949Xl82cF >									
	//        <  u =="0.000000000000000001" : ] 000000505918446.675376000000000000 ; 000000524412861.051729000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000303F86532030C6 >									
	//     < RUSS_PFXXVII_III_metadata_line_22_____ZAPSIBNEFTEKHIM_20251101 >									
	//        < 5Gl6Xv0auAjBYVHzfg5bj6DmJsU4U2VvqecB456g5uS1Pm9YG19hJard6MQI82p1 >									
	//        <  u =="0.000000000000000001" : ] 000000524412861.051729000000000000 ; 000000544545261.489014000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032030C633EE8FE >									
	//     < RUSS_PFXXVII_III_metadata_line_23_____RUSVINYL_20251101 >									
	//        < hLUWiQ6418t0jw81H0YPRk8zo3msgNpVVItvTS8KUnfYs8nw45KI5qSVb703yX0s >									
	//        <  u =="0.000000000000000001" : ] 000000544545261.489014000000000000 ; 000000578777289.442239000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033EE8FE37324E1 >									
	//     < RUSS_PFXXVII_III_metadata_line_24_____SIBUR_SECURITIES_LIMITED_20251101 >									
	//        < 0rN5SBaiVP2Ep1T1Zl6sJvXNBy5L5CWZzOW5y6UeMYIRt7a60Yv7xJI4Z0Ye42V2 >									
	//        <  u =="0.000000000000000001" : ] 000000578777289.442239000000000000 ; 000000611656542.684196000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037324E13A55056 >									
	//     < RUSS_PFXXVII_III_metadata_line_25_____ACRYLATE_20251101 >									
	//        < W5wvcFE0WoC089EphT57AX5c953htQvTW8Gs26J5t3B9K3LNtVOMp9B7nDXgQ9is >									
	//        <  u =="0.000000000000000001" : ] 000000611656542.684196000000000000 ; 000000630474161.311568000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A550563C206F8 >									
	//     < RUSS_PFXXVII_III_metadata_line_26_____BIAXPLEN_20251101 >									
	//        < 7kUKF4Tztk5WF3IBu5y2lN8cKiw0kwaYb6mw7j07W9Vjk9kn021JTx918MdgalyV >									
	//        <  u =="0.000000000000000001" : ] 000000630474161.311568000000000000 ; 000000648922568.247624000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C206F83DE2D61 >									
	//     < RUSS_PFXXVII_III_metadata_line_27_____PORTENERGO_20251101 >									
	//        < C6x8ua8814dFZYjq1p1H3bQT8luM7197z5Knka9J9W18IKK3vhacdCUgHSpZW5Ul >									
	//        <  u =="0.000000000000000001" : ] 000000648922568.247624000000000000 ; 000000672299082.168602000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DE2D61401D8D4 >									
	//     < RUSS_PFXXVII_III_metadata_line_28_____POLIEF_20251101 >									
	//        < kRH917fvJA6IFcDo8O66009ehHvIR7S5199sD05APZ6HWgv9h7JO4tZW5ojC8431 >									
	//        <  u =="0.000000000000000001" : ] 000000672299082.168602000000000000 ; 000000693947836.576159000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000401D8D4422E160 >									
	//     < RUSS_PFXXVII_III_metadata_line_29_____RUSPAV_20251101 >									
	//        < KM122KB5pSgg15XY8mr516J48WVEWn5bzk1FGeA6cVLkafU0LYAjD91EN2x8Ogv1 >									
	//        <  u =="0.000000000000000001" : ] 000000693947836.576159000000000000 ; 000000723384499.214861000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000422E16044FCC12 >									
	//     < RUSS_PFXXVII_III_metadata_line_30_____NEFTEKHIMIA_20251101 >									
	//        < 6s4xSoXvauOTV7FfZX8H2jK1wH1CQL38iEbRHQ3J6247mkZ04z9h9XUOF9f4rGqG >									
	//        <  u =="0.000000000000000001" : ] 000000723384499.214861000000000000 ; 000000754008020.109827000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044FCC1247E8662 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVII_III_metadata_line_31_____OTECHESTVENNYE_POLIMERY_20251101 >									
	//        < CMC7LnHohGK9QZ2lsd9Z6t7T9MXa4FUM0ekIBR10JpRPOAa3RfzPFbg5BxLjKffx >									
	//        <  u =="0.000000000000000001" : ] 000000754008020.109827000000000000 ; 000000773341699.712229000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000047E866249C069A >									
	//     < RUSS_PFXXVII_III_metadata_line_32_____SIBUR_TRANS_20251101 >									
	//        < k1CLuYuOoRWb96pAz71zg5pF9L8m4980W7xzzDp28GGib8Syv2ur9Ay07rB5tg53 >									
	//        <  u =="0.000000000000000001" : ] 000000773341699.712229000000000000 ; 000000793123459.445885000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049C069A4BA35DA >									
	//     < RUSS_PFXXVII_III_metadata_line_33_____TOGLIATTIKAUCHUK_20251101 >									
	//        < MxQ2FHq0vnnnGd7JSxTOQnBr8qFjsW0M3pIYw1HIS9Yrw2bnP6UuRvn2H5hoMZWN >									
	//        <  u =="0.000000000000000001" : ] 000000793123459.445885000000000000 ; 000000815544296.063335000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004BA35DA4DC6BFE >									
	//     < RUSS_PFXXVII_III_metadata_line_34_____NPP_NEFTEKHIMIYA_OOO_20251101 >									
	//        < 0Fj641Pv5gS426oY32QEXU9UnlmTKOVJPHe61b9X01Z1t6M6xMw4vm81Bq7bXCCo >									
	//        <  u =="0.000000000000000001" : ] 000000815544296.063335000000000000 ; 000000837301744.448902000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004DC6BFE4FD9EFE >									
	//     < RUSS_PFXXVII_III_metadata_line_35_____SIBUR_KHIMPROM_20251101 >									
	//        < 87MF9R2TA78Ynagozb3fPgW1Ohou340KnN5UfKP1n53nD92VT5x2xm4i2H5Rfwh1 >									
	//        <  u =="0.000000000000000001" : ] 000000837301744.448902000000000000 ; 000000856370921.552576000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004FD9EFE51AB7E4 >									
	//     < RUSS_PFXXVII_III_metadata_line_36_____SIBUR_VOLZHSKY_20251101 >									
	//        < qwi9ICd3STk69mAm5A1sO0ay43Z4Ks6N854hm271eLdZb4A9NKqCnk8hgZyt9rK1 >									
	//        <  u =="0.000000000000000001" : ] 000000856370921.552576000000000000 ; 000000880639253.133402000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000051AB7E453FBFB5 >									
	//     < RUSS_PFXXVII_III_metadata_line_37_____VORONEZHSINTEZKAUCHUK_20251101 >									
	//        < 9768k3gYpdiO37NY9CWq6EPr09njRf9d6wp4bFcdkI48R9J6v5jG92Ll5iN47gpg >									
	//        <  u =="0.000000000000000001" : ] 000000880639253.133402000000000000 ; 000000908154021.721867000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000053FBFB5569BBAA >									
	//     < RUSS_PFXXVII_III_metadata_line_38_____INFO_TECH_SERVICE_CO_20251101 >									
	//        < 16lAYvgO5zlT6ScXHgXgMz3CB8XMe4LIb3N932W62K52v4B4SA5W182Qr361yDA2 >									
	//        <  u =="0.000000000000000001" : ] 000000908154021.721867000000000000 ; 000000932915513.188169000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000569BBAA58F841F >									
	//     < RUSS_PFXXVII_III_metadata_line_39_____LNG_NOVAENGINEERING_20251101 >									
	//        < DI74eCN58o3qzEh8f44Em7Bx877H0agQep78dl1YZ4380pS3D3YuUV8Oq1nb7Sc9 >									
	//        <  u =="0.000000000000000001" : ] 000000932915513.188169000000000000 ; 000000955113558.609519000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000058F841F5B1633C >									
	//     < RUSS_PFXXVII_III_metadata_line_40_____SIBGAZPOLIMER_20251101 >									
	//        < 6068mMjiXQ8iGJDgo08K20754yI5EQ65TQp0KEQkneY1Wx9yN9hhBICSrzVW6os0 >									
	//        <  u =="0.000000000000000001" : ] 000000955113558.609519000000000000 ; 000000977766545.891770000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005B1633C5D3F40F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}