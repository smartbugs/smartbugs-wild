pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFI_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFI_I_883		"	;
		string	public		symbol =	"	NDRV_PFI_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		817796213918659000000000000					;	
										
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
	//     < NDRV_PFI_I_metadata_line_1_____genworth_20211101 >									
	//        < n6LLFf3v2yiUANlPJDcoYvF34WLsRX4qgf3Ltkk22XOcT2vlpXt57as1159R5h9p >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000020180846.529036400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001ECB25 >									
	//     < NDRV_PFI_I_metadata_line_2_____genworth_org_20211101 >									
	//        < 06bf0Ur546w1o3Qevy4MDpb2ZNOVNcrXnKnCiJfXx1h40J24h8pVznj69AlgaTu7 >									
	//        <  u =="0.000000000000000001" : ] 000000020180846.529036400000000000 ; 000000041785336.707469900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001ECB253FC266 >									
	//     < NDRV_PFI_I_metadata_line_3_____genworth_pensions_20211101 >									
	//        < 8dzdFP090z801m9kGvbVmm7Cdbu7DKV6y9huww2RxmtpGP0kOrN70tX7534LQsMd >									
	//        <  u =="0.000000000000000001" : ] 000000041785336.707469900000000000 ; 000000067787452.184867100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003FC266676F79 >									
	//     < NDRV_PFI_I_metadata_line_4_____genworth gna corporation_20211101 >									
	//        < 0YV3ytrKvHZyASDDMIYcx7VfP1O8L0GzO03RAleMVPt39mp7UpxQhttHjk7hQlb9 >									
	//        <  u =="0.000000000000000001" : ] 000000067787452.184867100000000000 ; 000000087090713.370721800000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000676F7984E3CF >									
	//     < NDRV_PFI_I_metadata_line_5_____gna corporation_org_20211101 >									
	//        < ad2R0LtqP18PDpH1XKBTqf05r41j4CeFMtrz8xsvTk6P4W95S1gD1PaR64qegeo0 >									
	//        <  u =="0.000000000000000001" : ] 000000087090713.370721800000000000 ; 000000111233184.665382000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000084E3CFA9BA76 >									
	//     < NDRV_PFI_I_metadata_line_6_____gna corporation_holdings_20211101 >									
	//        < e1SrY20YA1Rs3tozSSS4eG14K9Q64DXW59QaMjIKkt6YA5z8PBclxz363X6p6ZID >									
	//        <  u =="0.000000000000000001" : ] 000000111233184.665382000000000000 ; 000000124357705.107595000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A9BA76BDC13B >									
	//     < NDRV_PFI_I_metadata_line_7_____genworth assetmark_20211101 >									
	//        < 79Wu2HuJW9b7s8165dX50Ti9H9WOw0gd9gj9TO0tazK6cs9AviUt46Qxnj1p7E05 >									
	//        <  u =="0.000000000000000001" : ] 000000124357705.107595000000000000 ; 000000142273169.761469000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BDC13BD91775 >									
	//     < NDRV_PFI_I_metadata_line_8_____genworth assetmark_org_20211101 >									
	//        < 610f976c2R4TNR14Tk5rncE4o5A8BghumX4W7T4jrJCi9dJf2dLQWzLva17Df786 >									
	//        <  u =="0.000000000000000001" : ] 000000142273169.761469000000000000 ; 000000162010300.992051000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D91775F73546 >									
	//     < NDRV_PFI_I_metadata_line_9_____assetmark_holdings_20211101 >									
	//        < M5zp6W20Y17iiFpGw8699D3aPZpH309mygG5IlQ2Yu9Yeykz6A9f8EP16kNXDWqG >									
	//        <  u =="0.000000000000000001" : ] 000000162010300.992051000000000000 ; 000000176240488.458992000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F7354610CEBF1 >									
	//     < NDRV_PFI_I_metadata_line_10_____genworth life & annuity insurance co_20211101 >									
	//        < a5334vX0c88h0uJUwJ7ubl6F460DJJoOVR16US6xm0O546064Mw44A56pw17x9x7 >									
	//        <  u =="0.000000000000000001" : ] 000000176240488.458992000000000000 ; 000000193516846.954819000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010CEBF11274885 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFI_I_metadata_line_11_____genworth financial services inc_20211101 >									
	//        < hw25YYMD493wK8dVOD2l4yErtKAvkiGzL32i0limKsoQtY9q90Rf7B0K9W6cLUSn >									
	//        <  u =="0.000000000000000001" : ] 000000193516846.954819000000000000 ; 000000208164760.131018000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000127488513DA25C >									
	//     < NDRV_PFI_I_metadata_line_12_____genworth financial agency inc_20211101 >									
	//        < 5jx8sbb012gw5Il8h9HM2cj6NnDTr7D4Zxt71Eqxy1D1yvxbjYt38LQ25km5DHn0 >									
	//        <  u =="0.000000000000000001" : ] 000000208164760.131018000000000000 ; 000000223627608.270457000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013DA25C1553A89 >									
	//     < NDRV_PFI_I_metadata_line_13_____genworth financial services pty limited_20211101 >									
	//        < 824MEl8ILYk3LN5SG6JEw2bD3cS1kPjZMqzeeKEe8cII4MV4N06v68nXZ0Apy1sv >									
	//        <  u =="0.000000000000000001" : ] 000000223627608.270457000000000000 ; 000000244356271.979041000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001553A89174DBAB >									
	//     < NDRV_PFI_I_metadata_line_14_____genworth american continental insurance company_20211101 >									
	//        < 5F9eOFY6D43Xw5L6g19ddOQsgJ7dgsQX49mY1BILtzOg3q6W9EE7Byj7uSZBGJ8i >									
	//        <  u =="0.000000000000000001" : ] 000000244356271.979041000000000000 ; 000000265384675.824407000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000174DBAB194F1E4 >									
	//     < NDRV_PFI_I_metadata_line_15_____continental insurance company_org_20211101 >									
	//        < quCVx1hKn2SbC7Mojgb1ux4M712JMYx22gOAXoVP0OBC77OhQ1aSAxS9Vos0HRX1 >									
	//        <  u =="0.000000000000000001" : ] 000000265384675.824407000000000000 ; 000000289001384.129005000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000194F1E41B8FB2A >									
	//     < NDRV_PFI_I_metadata_line_16_____genworth north america corp_20211101 >									
	//        < MQUciLxZN0Qfar5D51e1ZiW1iKyY98WJ6gB06YUuPDS915a0Ng4EKKOJQB4Lzk1b >									
	//        <  u =="0.000000000000000001" : ] 000000289001384.129005000000000000 ; 000000309123501.379007000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B8FB2A1D7AF5E >									
	//     < NDRV_PFI_I_metadata_line_17_____genworth holdings inc_20211101 >									
	//        < ayscbrl6FqVZIoSX4EdOhBwNP6D7WNh1Jdto25eP0y1iV4MB92FoyLvlkcpatHWq >									
	//        <  u =="0.000000000000000001" : ] 000000309123501.379007000000000000 ; 000000322901256.630118000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D7AF5E1ECB54E >									
	//     < NDRV_PFI_I_metadata_line_18_____genworth holdings inc_org_20211101 >									
	//        < mNvde528wg4hPu0hmSo407TO81xBjXd6WDgB0yOSQSpX17U331931cPP3wMLr6cu >									
	//        <  u =="0.000000000000000001" : ] 000000322901256.630118000000000000 ; 000000346614235.498893000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001ECB54E210E430 >									
	//     < NDRV_PFI_I_metadata_line_19_____genworth mortgage insurance corp_20211101 >									
	//        < 8o6xNY1PO7128K2Bu88nSh4cPq04YE4tGmF3ixj9jgY2ih749a3YkBT4H8Gg83Tw >									
	//        <  u =="0.000000000000000001" : ] 000000346614235.498893000000000000 ; 000000364322319.041274000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000210E43022BE968 >									
	//     < NDRV_PFI_I_metadata_line_20_____genworth mortgage insurance corp_org_20211101 >									
	//        < 4qUlwCl131U3Y20gLj5M1343jQg7DO5XrxA4hj1hEDSHXYfpP1Sx4UZynw6z6G53 >									
	//        <  u =="0.000000000000000001" : ] 000000364322319.041274000000000000 ; 000000386627636.423453000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022BE96824DF26C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFI_I_metadata_line_21_____genworth financial mortgage insurance pty limited_20211101 >									
	//        < LOCqSS9k1BZGF6c2uz19tEZTTW16Chi1mID4sKKAzoV8xz9Alol7rL65ye58ngDI >									
	//        <  u =="0.000000000000000001" : ] 000000386627636.423453000000000000 ; 000000411582860.295522000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024DF26C274068E >									
	//     < NDRV_PFI_I_metadata_line_22_____genworth financial international holdings inc_20211101 >									
	//        < 91L0VHrM5W99u68VlB9S1m34E7wEQlto1g8G1ycOY4nw82dS1E57kbx4N980nu9L >									
	//        <  u =="0.000000000000000001" : ] 000000411582860.295522000000000000 ; 000000430107750.303276000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000274068E2904AD7 >									
	//     < NDRV_PFI_I_metadata_line_23_____genworth financial wealth management inc_20211101 >									
	//        < heJB0R3BlZE7nzI7T98C9Kx62Zh9904J0PR4dKi0X85E46O9Hbo9O4l262NBrf4P >									
	//        <  u =="0.000000000000000001" : ] 000000430107750.303276000000000000 ; 000000447053587.265940000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002904AD72AA264F >									
	//     < NDRV_PFI_I_metadata_line_24_____genworth ltc incorporated_org_20211101 >									
	//        < 97n1L7Yfr2Z1QR5B7R73ye8816HAvb819Rl1jSRAk6ZHz7DB04Tst32O68mZ0A5q >									
	//        <  u =="0.000000000000000001" : ] 000000447053587.265940000000000000 ; 000000473045147.749786000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AA264F2D1CF43 >									
	//     < NDRV_PFI_I_metadata_line_25_____genworth jamestown life insurance co_20211101 >									
	//        < Mj51xY9Pm6XUY8GzZAK0yMpln6wKrGGs0eK12lAu0b9XhACU24wJ7u8mVmA2A6e1 >									
	//        <  u =="0.000000000000000001" : ] 000000473045147.749786000000000000 ; 000000495791196.474182000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D1CF432F48470 >									
	//     < NDRV_PFI_I_metadata_line_26_____genworth financial assurance co ltd_20211101 >									
	//        < 3e4ZAOwy8306B3IZeaIYd3p14oU7sEWtf2EN0rvlw76nlvHFX6TU5EV7RUY1Euuo >									
	//        <  u =="0.000000000000000001" : ] 000000495791196.474182000000000000 ; 000000521746091.655611000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F4847031C1F11 >									
	//     < NDRV_PFI_I_metadata_line_27_____genworth financial mortgage insurance company canada_20211101 >									
	//        < XX256ndk5hoK0kKLglvEs2y2KIScaukjIdTe0Y69t9Xh2U1J4DmENmJX303j7ymO >									
	//        <  u =="0.000000000000000001" : ] 000000521746091.655611000000000000 ; 000000546836296.699733000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031C1F1134267EE >									
	//     < NDRV_PFI_I_metadata_line_28_____genworth financial insurance group services ltd_20211101 >									
	//        < QSHvjq0mA4t1aAvfvkx8hc99q6mFhTBDfU67ls0h7S5f4Ls0NqWJY9vSuOn61jW4 >									
	//        <  u =="0.000000000000000001" : ] 000000546836296.699733000000000000 ; 000000569196874.593912000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034267EE3648687 >									
	//     < NDRV_PFI_I_metadata_line_29_____genworth financial trust co_20211101 >									
	//        < 2KQg8LYHLNJ39RCDS2RM9S0p7zm1kOJY80JY9JCC3yOL5bRYuJL4Cv0F01O2Atu6 >									
	//        <  u =="0.000000000000000001" : ] 000000569196874.593912000000000000 ; 000000592739844.670270000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036486873887300 >									
	//     < NDRV_PFI_I_metadata_line_30_____financial trust co_holdings_20211101 >									
	//        < DTnyB939to673RQ293Pyum260Vy9xrjC5SXs22aTv5wKyl24vHRo9FB206081X28 >									
	//        <  u =="0.000000000000000001" : ] 000000592739844.670270000000000000 ; 000000617321921.306385000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038873003ADF560 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFI_I_metadata_line_31_____financial trust co_pensions_20211101 >									
	//        < 2Ki0ed5f0O12s4yhfVHd3wepWRzl6Yr1237kfa4yk067TyEr3s6TdXB0U4bV8m9O >									
	//        <  u =="0.000000000000000001" : ] 000000617321921.306385000000000000 ; 000000635671913.310101000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003ADF5603C9F557 >									
	//     < NDRV_PFI_I_metadata_line_32_____genworth financial trust co_org_20211101 >									
	//        < 69b9bp8688J8MsM50Yg42kWf5G5ff7f08gstY3W7XrMJkiVoLPr3o9J7XtIg99FP >									
	//        <  u =="0.000000000000000001" : ] 000000635671913.310101000000000000 ; 000000658814949.181409000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C9F5573ED4597 >									
	//     < NDRV_PFI_I_metadata_line_33_____genworth financial european group holdings limited_20211101 >									
	//        < JUcShe80QfV1aw4T15CbOer5dTz3bpvYXfjF1327AIUL43u5dHBW5L858Jbz37G1 >									
	//        <  u =="0.000000000000000001" : ] 000000658814949.181409000000000000 ; 000000684316297.110407000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003ED45974142F0E >									
	//     < NDRV_PFI_I_metadata_line_34_____genworth financial mortgage insurance limited_20211101 >									
	//        < 5q4CcIo0nY9CR78Si1ff69g5J3o50919E4D25vyBggIFMvHD5W8kHhq9B2OwA0YU >									
	//        <  u =="0.000000000000000001" : ] 000000684316297.110407000000000000 ; 000000704100401.272008000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004142F0E4325F38 >									
	//     < NDRV_PFI_I_metadata_line_35_____genworth servicios s de rl de cv_20211101 >									
	//        < 132PHuTS2zBFccPg1kmFE303Rj67X3875ANNgB1KBR8K7B9AEj25Ab39T7je602n >									
	//        <  u =="0.000000000000000001" : ] 000000704100401.272008000000000000 ; 000000727651906.381144000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004325F384564F07 >									
	//     < NDRV_PFI_I_metadata_line_36_____genworth liberty reverse mortgage incorporated_20211101 >									
	//        < PH3y0506kT9d62s0Ndpu7MI3w1hg7gVZ5CGX5zo495JuUYvUp6vZLuQ4k6D49WWv >									
	//        <  u =="0.000000000000000001" : ] 000000727651906.381144000000000000 ; 000000746337283.903238000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004564F07472D200 >									
	//     < NDRV_PFI_I_metadata_line_37_____genworth quantuvis consulting inc_20211101 >									
	//        < IQTh8F0GbPhvovp4dWGyNjKacw05olCq2dTmP1c48kxpFo89j96mGNLuliR0ZneW >									
	//        <  u =="0.000000000000000001" : ] 000000746337283.903238000000000000 ; 000000765259698.326872000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000472D20048FB192 >									
	//     < NDRV_PFI_I_metadata_line_38_____genworth seguros de credito a la vivienda sa de cv_20211101 >									
	//        < yeRk7AaQ9j883QroMyZn93A8tOT20cB3T05s7P3e8tx5nVv04vsDtYN6g22T9IkH >									
	//        <  u =="0.000000000000000001" : ] 000000765259698.326872000000000000 ; 000000787561705.363058000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048FB1924B1B94B >									
	//     < NDRV_PFI_I_metadata_line_39_____genworth mortgage insurance limited_20211101 >									
	//        < 4k5m0HY25rmOZV9Z7o7O10u8YBznFiGcj9UvVNo17fc9Op0G3OX47NGzY76nQK6o >									
	//        <  u =="0.000000000000000001" : ] 000000787561705.363058000000000000 ; 000000804316244.208590000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B1B94B4CB4A08 >									
	//     < NDRV_PFI_I_metadata_line_40_____genworth financial investment services inc_20211101 >									
	//        < 05Z6lKrM83XRcOliiZqgW3qmTfq8Mgw18XcnBKMfy4Wn05h12cRb049Dfyto4hnw >									
	//        <  u =="0.000000000000000001" : ] 000000804316244.208590000000000000 ; 000000817796213.918659000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004CB4A084DFDBA5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}