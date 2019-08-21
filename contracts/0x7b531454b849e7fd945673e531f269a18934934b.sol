pragma solidity 		^0.4.25	;						
										
	contract	CHEMCHINA_PFII_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	CHEMCHINA_PFII_I_883		"	;
		string	public		symbol =	"	CHEMCHINA_PFII_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		562437397317196000000000000					;	
										
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
	//     < CHEMCHINA_PFII_I_metadata_line_1_____CHANGZHOU_WUJIN_LINCHUAN_CHEMICAL_Co_Limited_20220321 >									
	//        < 91FsvSyof0Oi3nHqLqdpnZ55haDhCL4EaX8CszM9UbEsi3255wHz3KJ07xF86D7L >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000014381151.812580400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000015F1A3 >									
	//     < CHEMCHINA_PFII_I_metadata_line_2_____Chem_Stone_Co__Limited_20220321 >									
	//        < vp6NY4xV3DPCb2OM2vR0Nt3VzVJSBh65UW41cE0VhWD9De7N3r36bGoBPo5y39iL >									
	//        <  u =="0.000000000000000001" : ] 000000014381151.812580400000000000 ; 000000028424445.411850500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000015F1A32B5F4D >									
	//     < CHEMCHINA_PFII_I_metadata_line_3_____Chemleader_Biomedical_Co_Limited_20220321 >									
	//        < m2XN31HOKXiqOlQW2R618KQo0GzHilFbY2BeWF1Rqf9BqRMUaaQJGkC0892Lvt2q >									
	//        <  u =="0.000000000000000001" : ] 000000028424445.411850500000000000 ; 000000042186755.371384700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002B5F4D405F34 >									
	//     < CHEMCHINA_PFII_I_metadata_line_4_____Chemner_Pharma_20220321 >									
	//        < X4GQ5h5fNzQqBvfD365iNRCeyg7VzlmH1bCDT6rv0QU9bc3xvR9J8CWM099Z02Sm >									
	//        <  u =="0.000000000000000001" : ] 000000042186755.371384700000000000 ; 000000056108691.537899000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000405F34559D75 >									
	//     < CHEMCHINA_PFII_I_metadata_line_5_____Chemtour_Biotech__Suzhou__org_20220321 >									
	//        < TFLSoLnqk5D8eWOVRFpp3gBLg6DRAt1570Nq4WFMk2P708xfClC8uTxK4FFHgu8u >									
	//        <  u =="0.000000000000000001" : ] 000000056108691.537899000000000000 ; 000000070974303.241395100000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000559D756C4C56 >									
	//     < CHEMCHINA_PFII_I_metadata_line_6_____Chemtour_Biotech__Suzhou__Co__Ltd_20220321 >									
	//        < K75Lk6unACL05aY5m3bFt40gAVj4n9NyhaQ9DNA0in3wKT70ej80hlUExWKOk6yp >									
	//        <  u =="0.000000000000000001" : ] 000000070974303.241395100000000000 ; 000000083759223.972409200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006C4C567FCE72 >									
	//     < CHEMCHINA_PFII_I_metadata_line_7_____Chemvon_Biotechnology_Co__Limited_20220321 >									
	//        < rFM32Y9Ch732y5U1yr8Xj1025lOr33dSnIOLu3Wy3vMAsB22NgBc32YXQ6K25PsL >									
	//        <  u =="0.000000000000000001" : ] 000000083759223.972409200000000000 ; 000000097803707.191067200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007FCE72953C93 >									
	//     < CHEMCHINA_PFII_I_metadata_line_8_____Chengdu_Aslee_Biopharmaceuticals,_inc__20220321 >									
	//        < O55QMj1HqHXJXMAaX2GYz25dxH1g0Yy1i0ty4ne9AcUH2Y3A77P1gv0B0Np3IZuj >									
	//        <  u =="0.000000000000000001" : ] 000000097803707.191067200000000000 ; 000000111758583.176953000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000953C93AA87B2 >									
	//     < CHEMCHINA_PFII_I_metadata_line_9_____Chuxiong_Yunzhi_Phytopharmaceutical_Co_Limited_20220321 >									
	//        < QAPIi6wtUxYn7OhrUDIiY1UuJySLmi781933df32Fn5J9d01y2VjslC0Fe8bdI79 >									
	//        <  u =="0.000000000000000001" : ] 000000111758583.176953000000000000 ; 000000127947806.209361000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AA87B2C33B9D >									
	//     < CHEMCHINA_PFII_I_metadata_line_10_____Conier_Chem_Pharma__Limited_20220321 >									
	//        < F81bufJGG5QMkQv7m6W8JK3W2pPOj2kwm2eI7Tn3cMMHHlZ4JUu0n9LMw0Hw30Vf >									
	//        <  u =="0.000000000000000001" : ] 000000127947806.209361000000000000 ; 000000141859134.979930000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C33B9DD875B9 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFII_I_metadata_line_11_____Cool_Pharm_Ltd_20220321 >									
	//        < a4rNwB2jtCzk4a86A9qSFCiEFA02IqcW3a2Tss039kfWySZ12iA0HIPlvEY3kgK2 >									
	//        <  u =="0.000000000000000001" : ] 000000141859134.979930000000000000 ; 000000155404743.239708000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D875B9ED20FA >									
	//     < CHEMCHINA_PFII_I_metadata_line_12_____Coresyn_Pharmatech_Co__Limited_20220321 >									
	//        < K84OKG51eN1RKkM7mCtcrCzf3Zsab484PaMV587u0A949aJLBiyKt4HWrSg7N1z5 >									
	//        <  u =="0.000000000000000001" : ] 000000155404743.239708000000000000 ; 000000167840007.502558000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000ED20FA1001A81 >									
	//     < CHEMCHINA_PFII_I_metadata_line_13_____Dalian_Join_King_Fine_Chemical_org_20220321 >									
	//        < SQ2R01oMH6M2TxyKYP5pQ2QrG43cs9EJ0S0F8U5qIBalx13fmGWlr6794DS57r6A >									
	//        <  u =="0.000000000000000001" : ] 000000167840007.502558000000000000 ; 000000180494661.587986000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001001A8111369BA >									
	//     < CHEMCHINA_PFII_I_metadata_line_14_____Dalian_Join_King_Fine_Chemical_Co_Limited_20220321 >									
	//        < axQyBBLfHo8ynISaGXl3XscnO5EnPZY2fugLy0q8h9jUgTaRTgyd5MrkD4eV8O64 >									
	//        <  u =="0.000000000000000001" : ] 000000180494661.587986000000000000 ; 000000193710263.154628000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011369BA1279412 >									
	//     < CHEMCHINA_PFII_I_metadata_line_15_____Dalian_Richfortune_Chemicals_Co_Limited_20220321 >									
	//        < nWhGN424A87P26u0ZxZpN7m8KrUEwaPZ45OB1ME418kl4064UWY6XP4OrQ44H93X >									
	//        <  u =="0.000000000000000001" : ] 000000193710263.154628000000000000 ; 000000206742032.251600000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000127941213B769B >									
	//     < CHEMCHINA_PFII_I_metadata_line_16_____Daming_Changda_Co_Limited__LLBCHEM__20220321 >									
	//        < 1gC9Kp09uj4N2nFLo4byZDiP5ukvh4HMY0x2pZyP2vf0BpMd9wa6Tm5OqPwbYmKV >									
	//        <  u =="0.000000000000000001" : ] 000000206742032.251600000000000000 ; 000000222901020.045138000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013B769B1541EB6 >									
	//     < CHEMCHINA_PFII_I_metadata_line_17_____DATO_Chemicals_Co_Limited_20220321 >									
	//        < quj5b3KpcFHo3TWVbLug5XC90vlF3mcFM516q3OqGKeH0zokM3F2CgspUcdosITc >									
	//        <  u =="0.000000000000000001" : ] 000000222901020.045138000000000000 ; 000000238227099.425683000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001541EB616B8176 >									
	//     < CHEMCHINA_PFII_I_metadata_line_18_____DC_Chemicals_20220321 >									
	//        < wTApc70lyr3Vz5bzamY5b6i3gU4Qq8Zn3fiuVQ28MgmA40mTy0Ne3jxpN3P5qYaS >									
	//        <  u =="0.000000000000000001" : ] 000000238227099.425683000000000000 ; 000000251661441.141712000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016B81761800140 >									
	//     < CHEMCHINA_PFII_I_metadata_line_19_____Depont_Molecular_Co_Limited_20220321 >									
	//        < 8j066TqFac8NTmSZRw9HSiDYN0Lgo8aP6Ddfus6G5D92luUmKI6Es9a369X9BNnu >									
	//        <  u =="0.000000000000000001" : ] 000000251661441.141712000000000000 ; 000000265877277.199360000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001800140195B250 >									
	//     < CHEMCHINA_PFII_I_metadata_line_20_____DSL_Chemicals_Co_Ltd_20220321 >									
	//        < YZMQ0ADO4sC75N98rU1IhCW5J261D8oz7tgwdO7eQ6JMUPc1ILp2PHTA7owh5NM9 >									
	//        <  u =="0.000000000000000001" : ] 000000265877277.199360000000000000 ; 000000278986312.395237000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000195B2501A9B307 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFII_I_metadata_line_21_____Elsa_Biotechnology_org_20220321 >									
	//        < 9reYX9YyLX35GJ37haW3X8obl7Tj451HaGLs53H1b93BpO8svuAbPLlc95gUSqUd >									
	//        <  u =="0.000000000000000001" : ] 000000278986312.395237000000000000 ; 000000293694008.912164000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A9B3071C02439 >									
	//     < CHEMCHINA_PFII_I_metadata_line_22_____Elsa_Biotechnology_Co_Limited_20220321 >									
	//        < D7p7iQl1965C9zwLOXHfD6lG1ICwf21zL81B6c9SZXVlYwGh7E2zvE9JepsDHy2T >									
	//        <  u =="0.000000000000000001" : ] 000000293694008.912164000000000000 ; 000000308615843.125382000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C024391D6E910 >									
	//     < CHEMCHINA_PFII_I_metadata_line_23_____Enze_Chemicals_Co_Limited_20220321 >									
	//        < drzu1BbJj2P3pxM66fZgQEZgs840Ge3Y090p4R4o7R800VXXtV3Q5S7s902l7ElD >									
	//        <  u =="0.000000000000000001" : ] 000000308615843.125382000000000000 ; 000000321743321.302683000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D6E9101EAF0FC >									
	//     < CHEMCHINA_PFII_I_metadata_line_24_____EOS_Med_Chem_20220321 >									
	//        < jmORQ1L55Oe07d43q29i99dv11L2ygCwB48339N30RMa3115OUa97mU3q4gGMM5g >									
	//        <  u =="0.000000000000000001" : ] 000000321743321.302683000000000000 ; 000000334313855.260277000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EAF0FC1FE1F5A >									
	//     < CHEMCHINA_PFII_I_metadata_line_25_____EOS_Med_Chem_20220321 >									
	//        < 9VyF9DQGB7ImZezJmr08vchnTt5gSIXR2Hy926oW60T101zN8TsyBJK4ycaW05q4 >									
	//        <  u =="0.000000000000000001" : ] 000000334313855.260277000000000000 ; 000000349879610.963648000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FE1F5A215DFB9 >									
	//     < CHEMCHINA_PFII_I_metadata_line_26_____ETA_ChemTech_Co_Ltd_20220321 >									
	//        < 174cRc0bl0ToN0fwl4p6024TxRdOw4It5GK6yH7xFTU8BA2c6Etr69LjZ8ogO45L >									
	//        <  u =="0.000000000000000001" : ] 000000349879610.963648000000000000 ; 000000363675544.696950000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000215DFB922AECC2 >									
	//     < CHEMCHINA_PFII_I_metadata_line_27_____FEIMING_CHEMICAL_LIMITED_20220321 >									
	//        < wt8ED4Emyq4ZAc5eQrQAQ3I681pKS61lP5YabPw28C92ot80d7hx3n7dv17C7ys1 >									
	//        <  u =="0.000000000000000001" : ] 000000363675544.696950000000000000 ; 000000377542665.584837000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022AECC2240159B >									
	//     < CHEMCHINA_PFII_I_metadata_line_28_____FINETECH_INDUSTRY_LIMITED_20220321 >									
	//        < s6J5CYfs30Odu8058gw3oDxw2N34EY1GVpp93mFH1jTf5eL01yr9nlq0nJLP3Q89 >									
	//        <  u =="0.000000000000000001" : ] 000000377542665.584837000000000000 ; 000000390169499.629399000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000240159B25359F6 >									
	//     < CHEMCHINA_PFII_I_metadata_line_29_____Finetech_Industry_Limited_20220321 >									
	//        < I2H9ADbbUbNdt0oAyC1WnpIxv4m0NxZ4rk7v8wcke9R5A2zyhFgxdUf7988Jo0x4 >									
	//        <  u =="0.000000000000000001" : ] 000000390169499.629399000000000000 ; 000000403182626.588839000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025359F62673537 >									
	//     < CHEMCHINA_PFII_I_metadata_line_30_____Fluoropharm_org_20220321 >									
	//        < 8Y5p52pu8p92CPIw5b06bPPo44jy8x7h8JsQYPOcW5Rk5cOlCrGp87d427plk65R >									
	//        <  u =="0.000000000000000001" : ] 000000403182626.588839000000000000 ; 000000419357041.451906000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000267353727FE358 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFII_I_metadata_line_31_____Fluoropharm_Co_Limited_20220321 >									
	//        < oyO8123RI8PxMSf8UL1XH6mVRmv3gRc0b0qI7GG1a20l4PnR2PsW3Hi7QwI21tUy >									
	//        <  u =="0.000000000000000001" : ] 000000419357041.451906000000000000 ; 000000432169817.796599000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027FE3582937056 >									
	//     < CHEMCHINA_PFII_I_metadata_line_32_____Fond_Chemical_Co_Limited_20220321 >									
	//        < VU8DT8zmma2w95aX5R82rA7S68PS5s5KGD0BjM5WXIIsoESnVPZNKMk28uQuEy4e >									
	//        <  u =="0.000000000000000001" : ] 000000432169817.796599000000000000 ; 000000447163398.319946000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029370562AA5134 >									
	//     < CHEMCHINA_PFII_I_metadata_line_33_____Gansu_Research_Institute_of_Chemical_Industry_20220321 >									
	//        < ho0CrUB9P09SPgl3BT2po7Xh3V68GjGX19s7unQ92826l82zkAvKwyJi1YJYl97d >									
	//        <  u =="0.000000000000000001" : ] 000000447163398.319946000000000000 ; 000000461549108.243350000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AA51342C0449F >									
	//     < CHEMCHINA_PFII_I_metadata_line_34_____GL_Biochem__Shanghai__Ltd__20220321 >									
	//        < Ee7V0p1nH0WE31LT14Ebe1ep2KnelnQ61gq5ot6W0Jjm5feaKW0U6F0s8BGWfI5m >									
	//        <  u =="0.000000000000000001" : ] 000000461549108.243350000000000000 ; 000000476914473.437534000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C0449F2D7B6B7 >									
	//     < CHEMCHINA_PFII_I_metadata_line_35_____Guangzhou_Topwork_Chemical_Co__Limited_20220321 >									
	//        < A5100nzwmkaMHP0AG8o02dtg7y5hyC1U25F62dT3j9fohI9z2B5xx4n1hPkX84R3 >									
	//        <  u =="0.000000000000000001" : ] 000000476914473.437534000000000000 ; 000000493056084.688255000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D7B6B72F05808 >									
	//     < CHEMCHINA_PFII_I_metadata_line_36_____Hallochem_Pharma_Co_Limited_20220321 >									
	//        < 4s7n74xd2vFKW5dYbfWF3u11hH4AyIF279OfeJ8KKN91wr7208xT911uFdZUlfr2 >									
	//        <  u =="0.000000000000000001" : ] 000000493056084.688255000000000000 ; 000000508803657.272489000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F058083085F6E >									
	//     < CHEMCHINA_PFII_I_metadata_line_37_____Hanghzou_Fly_Source_Chemical_Co_Limited_20220321 >									
	//        < r9DjGKIFL2WMT2ni4K26ZeCb4cQbJrtgVNY8L7bmogLhC13vOlQ2EwTAog6a0R76 >									
	//        <  u =="0.000000000000000001" : ] 000000508803657.272489000000000000 ; 000000522776833.424361000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003085F6E31DB1B3 >									
	//     < CHEMCHINA_PFII_I_metadata_line_38_____Hangzhou_Best_Chemicals_Co__Limited_20220321 >									
	//        < 1g0Lb432a38PEdIil4y53bqEOd5mxnDYBg00HMd5ShHGrNR1Qo8SzIcDlhVD2pr8 >									
	//        <  u =="0.000000000000000001" : ] 000000522776833.424361000000000000 ; 000000535365127.354788000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031DB1B3330E701 >									
	//     < CHEMCHINA_PFII_I_metadata_line_39_____Hangzhou_Dayangchem_Co__Limited_20220321 >									
	//        < A57DKeJHInpcIW2h9blUczsHwbtL1s1K0aMoLyUl9y2tP6o5WcNGgl09Y62I8mt4 >									
	//        <  u =="0.000000000000000001" : ] 000000535365127.354788000000000000 ; 000000549188184.000230000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000330E701345FEA2 >									
	//     < CHEMCHINA_PFII_I_metadata_line_40_____Hangzhou_Dayangchem_org_20220321 >									
	//        < 6Oi0nP6vKCbwofVexA33zQZJE7T7xu99cW9s9QoJqPHg93BQX95b1TllARuHDPC8 >									
	//        <  u =="0.000000000000000001" : ] 000000549188184.000230000000000000 ; 000000562437397.317196000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000345FEA235A361C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}