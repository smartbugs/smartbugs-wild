pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXI_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXI_I_883		"	;
		string	public		symbol =	"	RUSS_PFXI_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		588697076269048000000000000					;	
										
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
	//     < RUSS_PFXI_I_metadata_line_1_____STRAKHOVOI_SINDIKAT_20211101 >									
	//        < Tg9xUoXKddtM4dcrO3QklFI9PkqF8Z626K1C0L18DS47flkX5vp5bL1quBfI5V0v >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000013083085.938328900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000013F695 >									
	//     < RUSS_PFXI_I_metadata_line_2_____MIKA_RG_20211101 >									
	//        < cs87hnmzi3s94HhzT3dLE9ECvS2Bs0g9I58c0E1D7G2ZvhsfE3xgPDLS9aK91401 >									
	//        <  u =="0.000000000000000001" : ] 000000013083085.938328900000000000 ; 000000026889622.642390100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000013F6952907C2 >									
	//     < RUSS_PFXI_I_metadata_line_3_____RESO_FINANCIAL_MARKETS_20211101 >									
	//        < 2qtsOp48E3lD193PmaB5GkbJK4m7ZlSzutK024025kYVRzcJnH1Qu044ovOvTj4l >									
	//        <  u =="0.000000000000000001" : ] 000000026889622.642390100000000000 ; 000000044106767.407816400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002907C2434D35 >									
	//     < RUSS_PFXI_I_metadata_line_4_____LIPETSK_INSURANCE_CHANCE_20211101 >									
	//        < g2VbwKKrgLNG61HcE8gykNewap7gIE7xjN85e7OY8h89L0EJ4Qg0MLg90gZbmMX5 >									
	//        <  u =="0.000000000000000001" : ] 000000044106767.407816400000000000 ; 000000057434558.335735000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000434D3557A360 >									
	//     < RUSS_PFXI_I_metadata_line_5_____ALVENA_RESO_GROUP_20211101 >									
	//        < 357zmBHWH8l6qk5lh0Kd30vveM2xC49O2yS6zXP33N89Q8rm4en57s363Xo21VQ8 >									
	//        <  u =="0.000000000000000001" : ] 000000057434558.335735000000000000 ; 000000070864481.653991800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000057A3606C2170 >									
	//     < RUSS_PFXI_I_metadata_line_6_____NADEZHNAYA_LIFE_INSURANCE_20211101 >									
	//        < U85594AmuuvHMt5O6z00WH811teOzN4Iz6UlfqWo1l27ZlK46ux4Qq6khr73QNbN >									
	//        <  u =="0.000000000000000001" : ] 000000070864481.653991800000000000 ; 000000086802054.837741800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006C217084730D >									
	//     < RUSS_PFXI_I_metadata_line_7_____MSK_URALSIB_20211101 >									
	//        < xeP2Pv7Av8Yl0dY3jD2Z00Z5k5u220E90b0QH9s6VOLXDo9PGG2uWIQT42hu6G6J >									
	//        <  u =="0.000000000000000001" : ] 000000086802054.837741800000000000 ; 000000103799749.464755000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000084730D9E62C7 >									
	//     < RUSS_PFXI_I_metadata_line_8_____SMO_SIBERIA_20211101 >									
	//        < RfsH9ub6Ixp8T3bb9QciHiBPBiR3UCfK2SXY6T8dEfCXSIMYEnsmkQ71158GcH7D >									
	//        <  u =="0.000000000000000001" : ] 000000103799749.464755000000000000 ; 000000117199070.838498000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009E62C7B2D4E3 >									
	//     < RUSS_PFXI_I_metadata_line_9_____ALFASTRAKHOVANIE_LIFE_20211101 >									
	//        < AYEs708sAKmjFCEIhclbr4J48Vm9dt1hgLP3YYu2pNqhx86J7dNtSEpDmxf600eM >									
	//        <  u =="0.000000000000000001" : ] 000000117199070.838498000000000000 ; 000000133298943.174971000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B2D4E3CB65E6 >									
	//     < RUSS_PFXI_I_metadata_line_10_____AVERS_OOO_20211101 >									
	//        < 34Aru4ME0ZFc4eIAFI0BRWx2Xmuw1TFr6wikJK0MKrXbu4tKHgu7g23p24gmvesa >									
	//        <  u =="0.000000000000000001" : ] 000000133298943.174971000000000000 ; 000000149664217.045919000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CB65E6E45E96 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXI_I_metadata_line_11_____ALFASTRAKHOVANIE_PLC_20211101 >									
	//        < 8Ru9ESyQ3tO7TjM13XK2o8JEIT2KqG4ehkQ045Z791qn3363Y3lg1zyWuyY58VgY >									
	//        <  u =="0.000000000000000001" : ] 000000149664217.045919000000000000 ; 000000164940782.502305000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E45E96FBADFE >									
	//     < RUSS_PFXI_I_metadata_line_12_____MIDITSINSKAYA_STRAKHOVAYA_KOMP_VIRMED_20211101 >									
	//        < m1LGRlc3C9Yku673pB9I70SYIFj37ToPtaDpq7TDR0WMKye8t1VINL4A860Jbe8G >									
	//        <  u =="0.000000000000000001" : ] 000000164940782.502305000000000000 ; 000000181165638.843390000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FBADFE1146FD4 >									
	//     < RUSS_PFXI_I_metadata_line_13_____MSK_ASSTRA_20211101 >									
	//        < siS4G7YG0OlB4LrTHgD4RV4wd7sRGUszy4w67jeXZXt7g91p2NIkvrb5Fag0uDE8 >									
	//        <  u =="0.000000000000000001" : ] 000000181165638.843390000000000000 ; 000000194456435.585089000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001146FD4128B78C >									
	//     < RUSS_PFXI_I_metadata_line_14_____AVICOS_AFES_INSURANCE_20211101 >									
	//        < 685D9dRdH6T2sqCy8Ped26VUJq4zh6Io6i21zYP8VjRtAR97njtlYQBbq62O6VdL >									
	//        <  u =="0.000000000000000001" : ] 000000194456435.585089000000000000 ; 000000208253653.865940000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000128B78C13DC515 >									
	//     < RUSS_PFXI_I_metadata_line_15_____RUSSIA_AGRICULTURAL_BANK_20211101 >									
	//        < ty0HUV4dpezqgeq51h1cmHw3r36KalI0mxOaA0rEczhkF85vKP1v2N3q0q0wQlz8 >									
	//        <  u =="0.000000000000000001" : ] 000000208253653.865940000000000000 ; 000000222175320.723552000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013DC515153033C >									
	//     < RUSS_PFXI_I_metadata_line_16_____BELOGLINSKI_ELEVATOR_20211101 >									
	//        < 1xzp6O05S22aY2xoqv7R537OHLM3tTT47cCqO82LkzPHI8k45GdG4zz99iPlEs5H >									
	//        <  u =="0.000000000000000001" : ] 000000222175320.723552000000000000 ; 000000235778234.505646000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000153033C167C4DF >									
	//     < RUSS_PFXI_I_metadata_line_17_____RSHB_CAPITAL_20211101 >									
	//        < R3539ywMgT0XLxdNlZT20xgwd7x5ZlyMJIeBQ7V2l95l25ylKq1L7mhoK448m60c >									
	//        <  u =="0.000000000000000001" : ] 000000235778234.505646000000000000 ; 000000248823812.511525000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000167C4DF17BACCD >									
	//     < RUSS_PFXI_I_metadata_line_18_____ALBASHSKIY_ELEVATOR_20211101 >									
	//        < 8EGjxDI6T8E6uUJ9U45y78Qc6FX4K1OyCJyZAz2pFDs3i3j8Ts6IpBV1PTIASB6j >									
	//        <  u =="0.000000000000000001" : ] 000000248823812.511525000000000000 ; 000000264913545.602202000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017BACCD19439DB >									
	//     < RUSS_PFXI_I_metadata_line_19_____AGROTORG_TRADING_CO_20211101 >									
	//        < w5Rt77Cnb26A2qE17Qhqy7O8RI0OJW675587rgoIE3idZJ766Tby0Y5Es552FNsS >									
	//        <  u =="0.000000000000000001" : ] 000000264913545.602202000000000000 ; 000000281019464.618251000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019439DB1ACCD3A >									
	//     < RUSS_PFXI_I_metadata_line_20_____HOMIAKOVSKIY_COLD_STORAGE_COMPLEX_20211101 >									
	//        < HFSObQeyOv6d1yXf6x7b4gTfq61mJMf9WE7r40Agvm0b3859Gr5QoPdHR8E56pbl >									
	//        <  u =="0.000000000000000001" : ] 000000281019464.618251000000000000 ; 000000294356153.862518000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001ACCD3A1C126DF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXI_I_metadata_line_21_____AGROCREDIT_INFORM_20211101 >									
	//        < 6vU65G4498pKtY9jXFTfU4b58N1isS0cr9V0mUI1fau5495jrK2Y4s5sLQWmw847 >									
	//        <  u =="0.000000000000000001" : ] 000000294356153.862518000000000000 ; 000000307634521.361888000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C126DF1D569BC >									
	//     < RUSS_PFXI_I_metadata_line_22_____LADOSHSKIY_ELEVATOR_20211101 >									
	//        < PgPr6cFuOA4rev1j3kh2c2aci8Mc39NL2zkF20K39eF048I1HCJ0mEW8h0oGuu8O >									
	//        <  u =="0.000000000000000001" : ] 000000307634521.361888000000000000 ; 000000324763997.720757000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D569BC1EF8CF0 >									
	//     < RUSS_PFXI_I_metadata_line_23_____VELICHKOVSKIY_ELEVATOR_20211101 >									
	//        < U0Dgp5Pc7rZ8Huxol38j59KFvJ71POON41GADMrgK6djB9KlXhmcM0EXB3BHq0O0 >									
	//        <  u =="0.000000000000000001" : ] 000000324763997.720757000000000000 ; 000000338661819.087063000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EF8CF0204C1C6 >									
	//     < RUSS_PFXI_I_metadata_line_24_____UMANSKIY_ELEVATOR_20211101 >									
	//        < N3rOcO02I2Z7RnN7l7VnezdgU39ryY59m8xJ8x0nd5aOJ25xBWszKjjnL9Q0Iwp6 >									
	//        <  u =="0.000000000000000001" : ] 000000338661819.087063000000000000 ; 000000352982477.746754000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000204C1C621A9BC8 >									
	//     < RUSS_PFXI_I_metadata_line_25_____MALOROSSIYSKIY_ELEVATOR_20211101 >									
	//        < v2fi4T2GJM7s3VKy0r9a24S3dwcIg03JQD28F7620BAx0libL95pQ828LoRHLm9m >									
	//        <  u =="0.000000000000000001" : ] 000000352982477.746754000000000000 ; 000000369200925.546866000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021A9BC82335B1D >									
	//     < RUSS_PFXI_I_metadata_line_26_____ROSSELKHOZBANK_DOMINANT_20211101 >									
	//        < 2s4hN46osJjeXkJUwDlt41ZnxpccI6vOno7rdA0t1yf4rNwP2M032x82n69f0SnD >									
	//        <  u =="0.000000000000000001" : ] 000000369200925.546866000000000000 ; 000000382506350.819087000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002335B1D247A88B >									
	//     < RUSS_PFXI_I_metadata_line_27_____RAEVSAKHAR_20211101 >									
	//        < 0h5a57TMXYc1e8Gjt56Je61dMX5C38WNaOgEV12KBE9F33UM9f9D3N63ZqTVeoUy >									
	//        <  u =="0.000000000000000001" : ] 000000382506350.819087000000000000 ; 000000397907391.810819000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000247A88B25F2893 >									
	//     < RUSS_PFXI_I_metadata_line_28_____OPTOVYE_TEKHNOLOGII_20211101 >									
	//        < XF8h794gLyjOSa60PBDcHY3tr9KG239Gy8s5gOfF5NlJ8yiI0mNyV2UMr1cabX4h >									
	//        <  u =="0.000000000000000001" : ] 000000397907391.810819000000000000 ; 000000412775261.829023000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025F2893275D856 >									
	//     < RUSS_PFXI_I_metadata_line_29_____EYANSKI_ELEVATOR_20211101 >									
	//        < hzf4LOytH4q4HvBfjgWceU1TPnMGwdq0v4nNf2Bav4Xm3JvQRw8clJ3zU9pUVsra >									
	//        <  u =="0.000000000000000001" : ] 000000412775261.829023000000000000 ; 000000427217883.767235000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000275D85628BE1FC >									
	//     < RUSS_PFXI_I_metadata_line_30_____RUSSIAN_AGRARIAN_FUEL_CO_20211101 >									
	//        < y11hk7xuDr7fl99UT92p081E57xcdQVkaaR2rZh273o6s37wX94sf8DZOH0g1B42 >									
	//        <  u =="0.000000000000000001" : ] 000000427217883.767235000000000000 ; 000000441853269.614553000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028BE1FC2A236EF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXI_I_metadata_line_31_____KHOMYAKOVSKY_KHLADOKOMBINAT_20211101 >									
	//        < 9iIR6958FWNsyq9TuLedn6Vtk2D2t32s7XgkwXBN6ko6wCxqYQC602D817m58i2V >									
	//        <  u =="0.000000000000000001" : ] 000000441853269.614553000000000000 ; 000000457277186.906099000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A236EF2B9BFE7 >									
	//     < RUSS_PFXI_I_metadata_line_32_____STEPNYANSKIY_ELEVATOR_20211101 >									
	//        < 01m7t3M3q6bqYw7GKq8du0et0ELX6Qa719o69jb8N39P0fp643DmwGK6gKcx0v3O >									
	//        <  u =="0.000000000000000001" : ] 000000457277186.906099000000000000 ; 000000471576405.120118000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B9BFE72CF9189 >									
	//     < RUSS_PFXI_I_metadata_line_33_____ROVNENSKIY_ELEVATOR_20211101 >									
	//        < maL5998ZDm1lWNsykmV9UbWH0t65D563XTR8GKN90FLS8AhkREy03kqs7lQhTlO9 >									
	//        <  u =="0.000000000000000001" : ] 000000471576405.120118000000000000 ; 000000484949427.110639000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CF91892E3F95F >									
	//     < RUSS_PFXI_I_metadata_line_34_____KHOMYAKOVSKIY_COLD_STORAGE_FACILITY_20211101 >									
	//        < UUoWUzi5WV6r1Z14u207Bl61o107X667ja5Y7o348Pgk1B6zP52D82gC920txl41 >									
	//        <  u =="0.000000000000000001" : ] 000000484949427.110639000000000000 ; 000000500581017.439984000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E3F95F2FBD376 >									
	//     < RUSS_PFXI_I_metadata_line_35_____BRIGANTINA_OOO_20211101 >									
	//        < Lm20MOr4muW21h2A2sL08w9tO08G8Tzgg03u74fk3KNDoH67Hu0V4f7Pwuo6y6hz >									
	//        <  u =="0.000000000000000001" : ] 000000500581017.439984000000000000 ; 000000513623979.859412000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FBD37630FBA5E >									
	//     < RUSS_PFXI_I_metadata_line_36_____RUS_AGRICULTURAL_BANK_AM_ARM_20211101 >									
	//        < 7x8O0a77E89MgqA66bfThhV6b4TmKdEz6WNVy228RX8PV85b09MQ8xQt8JJta9h1 >									
	//        <  u =="0.000000000000000001" : ] 000000513623979.859412000000000000 ; 000000528059654.622653000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030FBA5E325C14D >									
	//     < RUSS_PFXI_I_metadata_line_37_____LUZHSKIY_FEEDSTUFF_PLANT_20211101 >									
	//        < Twj3ZEvd2L2KfviG0Zt3xLd3m2PnD6k5xpHeI4l44mL4qSSj60Sz4ypzAhw7SWlk >									
	//        <  u =="0.000000000000000001" : ] 000000528059654.622653000000000000 ; 000000543842346.347348000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000325C14D33DD66B >									
	//     < RUSS_PFXI_I_metadata_line_38_____LUZHSKIY_MYASOKOMBINAT_20211101 >									
	//        < 0q8U6Fp0a9Hv6x0V6M5L1rE9IhIdW8kvMT0mo2OfCYifPUdn413cKPr2dlElL0aO >									
	//        <  u =="0.000000000000000001" : ] 000000543842346.347348000000000000 ; 000000560114533.022122000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033DD66B356AABD >									
	//     < RUSS_PFXI_I_metadata_line_39_____LUGA_FODDER_PLANT_20211101 >									
	//        < U0g9ZJ2m21e2614f4R7R5A612KM1n9mdYb869lkCX9V0dWdGN0TPkc7hUHgX08s9 >									
	//        <  u =="0.000000000000000001" : ] 000000560114533.022122000000000000 ; 000000575553329.444818000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000356AABD36E3985 >									
	//     < RUSS_PFXI_I_metadata_line_40_____KRILOVSKIY_ELEVATOR_20211101 >									
	//        < G5y16O4KcKl8Uz0IHk6Ya0s9wXzbHY2WG21mx5s3JBGfB6bB5rIcLs7cdx61fZ9Q >									
	//        <  u =="0.000000000000000001" : ] 000000575553329.444818000000000000 ; 000000588697076.269049000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036E398538247CC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}