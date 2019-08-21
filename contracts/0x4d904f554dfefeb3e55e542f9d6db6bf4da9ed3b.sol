pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFIII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFIII_III_883		"	;
		string	public		symbol =	"	NDRV_PFIII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		2174046187107010000000000000					;	
										
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
	//     < NDRV_PFIII_III_metadata_line_1_____talanx_20251101 >									
	//        < JiYYkj2z15dYjvD7X40AJbT3KY14311L3TX0CVAMu1543SK7q9yK8eDQMdaiHn7V >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000081184242.498472600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000007BE098 >									
	//     < NDRV_PFIII_III_metadata_line_2_____hdi haftpflichtverband der deutsch_indus_versicherungsverein gegenseitigkeit_20251101 >									
	//        < NZ0cAvNESU53mEgHTk0gv1n3y056p26R7E212B3939f1Pfv0T1iQCLDfYlQA491v >									
	//        <  u =="0.000000000000000001" : ] 000000081184242.498472600000000000 ; 000000105937935.628475000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007BE098A1A602 >									
	//     < NDRV_PFIII_III_metadata_line_3_____hdi global se_20251101 >									
	//        < 6si3lCIbxbU7962KNShzgmJIuhhXtgBlMA4dVS5k2TGXWQr21O53CCHhe4AK3P3o >									
	//        <  u =="0.000000000000000001" : ] 000000105937935.628475000000000000 ; 000000128225308.674943000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A1A602C3A803 >									
	//     < NDRV_PFIII_III_metadata_line_4_____hdi global network ag_20251101 >									
	//        < pjwfS0db0KWHKaewhh9HAi2H51h15TotiZ66Z59VrjZ2sMT9XAb76xtMXc7Ob4y8 >									
	//        <  u =="0.000000000000000001" : ] 000000128225308.674943000000000000 ; 000000181515294.357525000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000C3A803114F869 >									
	//     < NDRV_PFIII_III_metadata_line_5_____hdi global network ag hdi global seguros sa_20251101 >									
	//        < wlku4nvE0OH3g1mrEZAvpG0D2Dtmv1M50vq3fZKbjT08Z3cp85QUvkh3UCX63yw0 >									
	//        <  u =="0.000000000000000001" : ] 000000181515294.357525000000000000 ; 000000214939405.068123000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000114F869147F8B5 >									
	//     < NDRV_PFIII_III_metadata_line_6_____hdi global se hdi-gerling industrial insurance company_20251101 >									
	//        < M2fl7nXFv90s7FvC7hnLXlG3z275f0I2X33TYc94230lHopeLRo77zi9ZC0Piad6 >									
	//        <  u =="0.000000000000000001" : ] 000000214939405.068123000000000000 ; 000000261387670.403607000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000147F8B518ED88F >									
	//     < NDRV_PFIII_III_metadata_line_7_____hdi_gerling industrial insurance company uk branch_20251101 >									
	//        < MYFM7zohdSIsf40yBh1KQS94oH8O6In0Qg33YE9n5er99n3ES0wTxQ43482r93pu >									
	//        <  u =="0.000000000000000001" : ] 000000261387670.403607000000000000 ; 000000311432415.662002000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018ED88F1DB354A >									
	//     < NDRV_PFIII_III_metadata_line_8_____hdi global se hdi_gerling de méxico seguros sa_20251101 >									
	//        < w5tV1vU61uOn4BPbgVd0ibDqhM10681Qb4G39iDKpfT37vsS3dU8V82E42u7ntaI >									
	//        <  u =="0.000000000000000001" : ] 000000311432415.662002000000000000 ; 000000372284781.967981000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DB354A2380FBE >									
	//     < NDRV_PFIII_III_metadata_line_9_____hdi global se spain branch_20251101 >									
	//        < G8vHcxAmost5r8w59ZXJ2b1h5H37Wm31eOl3dQw3VeF32VmgmxAnU59vugz5ENr1 >									
	//        <  u =="0.000000000000000001" : ] 000000372284781.967981000000000000 ; 000000398274348.589884000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002380FBE25FB7EB >									
	//     < NDRV_PFIII_III_metadata_line_10_____hdi global se nassau verzekering maatschappij nv_20251101 >									
	//        < 56nAIVEmSqVzR0b9qMBK1nyoqDoOMpj8EC1W1b27Q04951OY9sx8h9Ci25n543t2 >									
	//        <  u =="0.000000000000000001" : ] 000000398274348.589884000000000000 ; 000000488133185.808166000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025FB7EB2E8D507 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFIII_III_metadata_line_11_____hdi_gerling industrie versicherung ag_20251101 >									
	//        < r5wFAV3yw9T1yuj0455oo9wQEPEqftlJ7i6wUf8Grb5L5A82qiPGuI2dI920EFfb >									
	//        <  u =="0.000000000000000001" : ] 000000488133185.808166000000000000 ; 000000512415101.624211000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E8D50730DE226 >									
	//     < NDRV_PFIII_III_metadata_line_12_____hdi global se gerling norge as_20251101 >									
	//        < A5xESv9DDKfJd4JiDzswKwVf5OyFf8029Cy04fNsUqP69R735fX7qn9n6CxLUHZX >									
	//        <  u =="0.000000000000000001" : ] 000000512415101.624211000000000000 ; 000000585306399.565215000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030DE22637D1B50 >									
	//     < NDRV_PFIII_III_metadata_line_13_____hdi_gerling industrie versicherung ag hellas branch_20251101 >									
	//        < D3q2G208SDH1WJPt143IyPi9Ss9cIyw9UDwqU8qfuuD5dt555dbF358nP08BILrE >									
	//        <  u =="0.000000000000000001" : ] 000000585306399.565215000000000000 ; 000000604398535.033127000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037D1B5039A3D2E >									
	//     < NDRV_PFIII_III_metadata_line_14_____hdi_gerling verzekeringen nv_20251101 >									
	//        < DQ35F1I9XcOYLEeg8R2o1Is02c3s0mW9ZE6m1B6O2wqW420l5T6Qbt669LOxBt0S >									
	//        <  u =="0.000000000000000001" : ] 000000604398535.033127000000000000 ; 000000685655944.088030000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039A3D2E4163A5A >									
	//     < NDRV_PFIII_III_metadata_line_15_____hdi_gerling verzekeringen nv hj roelofs_assuradeuren bv_20251101 >									
	//        < 9gA4k67iTGOn34sud1n4nZyTd5Vfc6wRNMNPfgdtMOnn4GtT7E6g39M19TXm1OBG >									
	//        <  u =="0.000000000000000001" : ] 000000685655944.088030000000000000 ; 000000723708222.408522000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004163A5A4504A86 >									
	//     < NDRV_PFIII_III_metadata_line_16_____hdi global sa ltd_20251101 >									
	//        < vr0Q2uPmNI179vbn90Yg6KRaBOq01pB097P6hwuAr0t88Pw7u095l0t1fVzxgUZ3 >									
	//        <  u =="0.000000000000000001" : ] 000000723708222.408522000000000000 ; 000000754090011.981749000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004504A8647EA669 >									
	//     < NDRV_PFIII_III_metadata_line_17_____Hannover Re_20251101 >									
	//        < x2D8Vr9Og9fg494nX187ik6UY938i4E0urAT3RWbiIY0M5R5vF6c1WENRov7mUxL >									
	//        <  u =="0.000000000000000001" : ] 000000754090011.981749000000000000 ; 000000831975259.603049000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000047EA6694F57E56 >									
	//     < NDRV_PFIII_III_metadata_line_18_____hdi versicherung ag_20251101 >									
	//        < j1ZbCqKJP4p6WI5UC4ETiA2esgg47wAb3l3PViw63Cx8M2e5P8EKGC67Gx8fi6P8 >									
	//        <  u =="0.000000000000000001" : ] 000000831975259.603049000000000000 ; 000000888203227.320160000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004F57E5654B4A63 >									
	//     < NDRV_PFIII_III_metadata_line_19_____talanx asset management gmbh_20251101 >									
	//        < qqKHRH396QiA87y0W3Q7H6Z4m4D3HVP8Gj19euxbwESPx503i70XZiXXYVyUgyi9 >									
	//        <  u =="0.000000000000000001" : ] 000000888203227.320160000000000000 ; 000000968644873.809999000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000054B4A635C608E7 >									
	//     < NDRV_PFIII_III_metadata_line_20_____talanx immobilien management gmbh_20251101 >									
	//        < 7RK930nGX8vhjlf1udLj2Yahj5BQ2FdqmCVt3OdG7ZUg0p9HREu8Sxp96PeEmK7W >									
	//        <  u =="0.000000000000000001" : ] 000000968644873.809999000000000000 ; 000000987874437.396875000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005C608E75E36074 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFIII_III_metadata_line_21_____talanx ampega investment gmbh_20251101 >									
	//        < 8J17rQS0dWi4108696PftlwITnNn80735Uk49qX0iqGKIEB9isOD1s7eJeJAixxS >									
	//        <  u =="0.000000000000000001" : ] 000000987874437.396875000000000000 ; 000001054025382.089020000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005E3607464850AA >									
	//     < NDRV_PFIII_III_metadata_line_22_____talanx hdi pensionskasse ag_20251101 >									
	//        < V8NKNUD5A3o5vNOnGIWeqr74heK8qUZULT1ouIdYICco07ma5h39UIyT9zgAq0j0 >									
	//        <  u =="0.000000000000000001" : ] 000001054025382.089020000000000000 ; 000001118157024.589750000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000064850AA6AA2C16 >									
	//     < NDRV_PFIII_III_metadata_line_23_____talanx international ag_20251101 >									
	//        < Q7b4jYoinf2RR3hDxj0a6Cv60jZtj7SFek8b70K7QmR5e37NW1wUnRWFUHz91Yr1 >									
	//        <  u =="0.000000000000000001" : ] 000001118157024.589750000000000000 ; 000001201208317.287060000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006AA2C16728E600 >									
	//     < NDRV_PFIII_III_metadata_line_24_____talanx targo versicherung ag_20251101 >									
	//        < VOchOwczRyJ6EbQ80snAxW8tredqwGkt0So7094UJkc24bM1598Mp3Smc2gwtgb5 >									
	//        <  u =="0.000000000000000001" : ] 000001201208317.287060000000000000 ; 000001282770578.079560000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000728E6007A55A42 >									
	//     < NDRV_PFIII_III_metadata_line_25_____talanx pb lebensversicherung ag_20251101 >									
	//        < k1g4578SPG2H8u1IS6600F87A5SwTgfc5dd9e9bzX93dt4WA2b4uU8S3V7fnzrAB >									
	//        <  u =="0.000000000000000001" : ] 000001282770578.079560000000000000 ; 000001351064384.678380000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007A55A4280D8F86 >									
	//     < NDRV_PFIII_III_metadata_line_26_____talanx targo lebensversicherung ag_20251101 >									
	//        < 7H52hS4K3bLUNETtiXBJdsWWV7J1C8xFsc4JlzRjI83bOP3YOyNk6qtRrHi81SWz >									
	//        <  u =="0.000000000000000001" : ] 000001351064384.678380000000000000 ; 000001433232606.824530000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000080D8F8688AF07D >									
	//     < NDRV_PFIII_III_metadata_line_27_____talanx hdi global insurance company_20251101 >									
	//        < NQ4ANXaxd6F4lHc5F2DHJ35ur8eZ7D6nCs9Tl8F48T44i29N6zume2XRrjK7iIIt >									
	//        <  u =="0.000000000000000001" : ] 000001433232606.824530000000000000 ; 000001525768780.256120000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000088AF07D918236E >									
	//     < NDRV_PFIII_III_metadata_line_28_____talanx civ life russia_20251101 >									
	//        < 9448zT5YCtNeMTRfe8oirkNO1pm7HW1pqr612C4R6NSGN18b1sAB86zk4aq1W76W >									
	//        <  u =="0.000000000000000001" : ] 000001525768780.256120000000000000 ; 000001581150300.362750000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000918236E96CA4D6 >									
	//     < NDRV_PFIII_III_metadata_line_29_____talanx reinsurance ireland limited_20251101 >									
	//        < twi3FJlezJffU7lA5LT5jrb3lAjIIQ6t5Cxhf7Yn6aO98YLn99eteu53OrT6Xd3M >									
	//        <  u =="0.000000000000000001" : ] 000001581150300.362750000000000000 ; 000001632690506.987450000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000096CA4D69BB49BB >									
	//     < NDRV_PFIII_III_metadata_line_30_____talanx deutschland ag_20251101 >									
	//        < Bb8yvwUOLMj6x1FM8O4nmc4bG3iw0ot12nR6985tMaA6AeNDCEOG5tf8UOI1f2PC >									
	//        <  u =="0.000000000000000001" : ] 000001632690506.987450000000000000 ; 000001697285610.637560000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009BB49BBA1DDA31 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFIII_III_metadata_line_31_____talanx service ag_20251101 >									
	//        < vz0WhJmk7cG1VyL2ehb5qCC8l7neU5nha8Wl8HHf2GQ4jmPT8h66gimsvKZ5Zk96 >									
	//        <  u =="0.000000000000000001" : ] 000001697285610.637560000000000000 ; 000001733354215.199920000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A1DDA31A54E37E >									
	//     < NDRV_PFIII_III_metadata_line_32_____talanx service ag hdi risk consulting gmbh_20251101 >									
	//        < h035MYea6ya0O154hb66yA8Hz5vLrGkf9glrG8OKdrzbD155vGN25ug7Hs5489yl >									
	//        <  u =="0.000000000000000001" : ] 000001733354215.199920000000000000 ; 000001805029093.676040000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A54E37EAC2417D >									
	//     < NDRV_PFIII_III_metadata_line_33_____talanx deutschland bancassurance kundenservice gmbh_20251101 >									
	//        < me246Kh6Atvlw1cKLM4lO13I7xSv02rUHRcg54aFuro6P9eomsXq3DSky49YmAZt >									
	//        <  u =="0.000000000000000001" : ] 000001805029093.676040000000000000 ; 000001833557967.412280000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000AC2417DAEDC995 >									
	//     < NDRV_PFIII_III_metadata_line_34_____magyar posta eletbiztosito zrt_20251101 >									
	//        < YCJL772zutk0PjDSc7w78WmXKxVoc2ShGL8ge89EY11TQtiOoGZg3PRC1214FGu6 >									
	//        <  u =="0.000000000000000001" : ] 000001833557967.412280000000000000 ; 000001853649058.256600000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000AEDC995B0C71AA >									
	//     < NDRV_PFIII_III_metadata_line_35_____magyar posta biztosito zrt_20251101 >									
	//        < 0c1o0tS3aJU69NW5ip8hlJ6e9VGp84ZeO1e7bRDbs02I0d1ViG4qOf6419HC9PXk >									
	//        <  u =="0.000000000000000001" : ] 000001853649058.256600000000000000 ; 000001946925280.651540000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000B0C71AAB9AC5B0 >									
	//     < NDRV_PFIII_III_metadata_line_36_____civ hayat sigorta as_20251101 >									
	//        < c4p4465RM55JblCH1h8rTmvfB3F485q790TF0cFTx2H67lfd25h94IZY074I51T1 >									
	//        <  u =="0.000000000000000001" : ] 000001946925280.651540000000000000 ; 000002003448295.679820000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000B9AC5B0BF104FE >									
	//     < NDRV_PFIII_III_metadata_line_37_____lifestyle protection lebensversicherung ag_20251101 >									
	//        < r4fGYxFM3CoYea9l6WykhfuT7Ma69t4N4sE8B19I81V7Y748aLA4GU4XFTko0880 >									
	//        <  u =="0.000000000000000001" : ] 000002003448295.679820000000000000 ; 000002037743042.762860000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000BF104FEC255960 >									
	//     < NDRV_PFIII_III_metadata_line_38_____pbv lebensversicherung ag_20251101 >									
	//        < 2a9e998dzIqZCBOe8VpeeU534HIUfn4UjsETfqU7BKY7b116U0q4569KDpQJeg3A >									
	//        <  u =="0.000000000000000001" : ] 000002037743042.762860000000000000 ; 000002060930103.102540000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000C255960C48BAD2 >									
	//     < NDRV_PFIII_III_metadata_line_39_____generali colombia seguros generales sa_20251101 >									
	//        < oo43jtxQh04IHsXhuj8XU3nfQ9B2FOgei4f2RamOj3HaP2G2nA8elnUhB0DJ2974 >									
	//        <  u =="0.000000000000000001" : ] 000002060930103.102540000000000000 ; 000002099214646.794460000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000C48BAD2C8325B9 >									
	//     < NDRV_PFIII_III_metadata_line_40_____generali colombia vida sa_20251101 >									
	//        < i456EPt2s8K34VmfS4HLVG1fF6zRU3OFHJgMMg67m1X0GjsxTCv49bQ5fPuRfcB4 >									
	//        <  u =="0.000000000000000001" : ] 000002099214646.794460000000000000 ; 000002174046187.107010000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000C8325B9CF554CB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}