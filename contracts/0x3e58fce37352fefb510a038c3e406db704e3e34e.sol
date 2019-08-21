pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFVII_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFVII_I_883		"	;
		string	public		symbol =	"	NDRV_PFVII_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		756107420564358000000000000					;	
										
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
	//     < NDRV_PFVII_I_metadata_line_1_____Hannover Re_20211101 >									
	//        < c5br4GhSHgiu46MmLTz19moCb9l58l9fi2T27160scyP1lM70sDiwiSb7sr95F5e >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000023019861.846765200000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000232022 >									
	//     < NDRV_PFVII_I_metadata_line_2_____Hannover Reinsurance Ireland Ltd_20211101 >									
	//        < D7XSB64t0zKokRayXbGA95G51Q57446T4KTW30D9y23wj4449sS1t73zwL2DuG1w >									
	//        <  u =="0.000000000000000001" : ] 000000023019861.846765200000000000 ; 000000045530114.468847200000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000232022457933 >									
	//     < NDRV_PFVII_I_metadata_line_3_____975 Carroll Square Llc_20211101 >									
	//        < GmS11WMhtEWllPT2m3f5SM9092yQ7t7Jq1b4l8tPs669MKSkHf3vIlGy7hSmX7L1 >									
	//        <  u =="0.000000000000000001" : ] 000000045530114.468847200000000000 ; 000000063739540.408119500000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000457933614242 >									
	//     < NDRV_PFVII_I_metadata_line_4_____Caroll_Holdings_20211101 >									
	//        < A0Wyd51Q8Bv401mm84Xqu08OAjOeOZ036HV0dPZH0V9sCu6fTJqQGs0J6wguer8J >									
	//        <  u =="0.000000000000000001" : ] 000000063739540.408119500000000000 ; 000000081330605.462984200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006142427C19C5 >									
	//     < NDRV_PFVII_I_metadata_line_5_____Skandia Versicherung Management & Service Gmbh_20211101 >									
	//        < O6N1136Ho75e9jA0db9aecM8h52w6dJfW53q7y9Yhv6p6U921Y6UH7F02zDXWI5A >									
	//        <  u =="0.000000000000000001" : ] 000000081330605.462984200000000000 ; 000000098136760.430684600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007C19C595BEAC >									
	//     < NDRV_PFVII_I_metadata_line_6_____Skandia PortfolioManagement Gmbh, Asset Management Arm_20211101 >									
	//        < 3Pz2U7X93Q3XTNR4Rx7md9XIe0S576F2ADT2YdWI4SGAv25Dn72yFRDBrcOuz7Xd >									
	//        <  u =="0.000000000000000001" : ] 000000098136760.430684600000000000 ; 000000112695846.638089000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000095BEACABF5D1 >									
	//     < NDRV_PFVII_I_metadata_line_7_____Argenta Underwriting No8 Limited_20211101 >									
	//        < gMP7Mt41sFhC17T497tgw0v0w9SXcl6rPS756LOn326grh8H0k1PfyYHni8e7ALr >									
	//        <  u =="0.000000000000000001" : ] 000000112695846.638089000000000000 ; 000000126038991.328500000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000ABF5D1C051FB >									
	//     < NDRV_PFVII_I_metadata_line_8_____Oval Office Grundstücks GmbH_20211101 >									
	//        < ueHAuS5R0lxe2a14apOT4D6c9Th0sWGSC2E38jvx90lLa807KPcfWJ043Wnq4i1h >									
	//        <  u =="0.000000000000000001" : ] 000000126038991.328500000000000000 ; 000000141702444.004636000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C051FBD83884 >									
	//     < NDRV_PFVII_I_metadata_line_9_____Hannover Rückversicherung AG Asset Management Arm_20211101 >									
	//        < I997OG8CI3U9Z0S1lrW45M3uQ4t8dw6ic2iPs8f70mjOstrk9YT040jv50JrhvQ8 >									
	//        <  u =="0.000000000000000001" : ] 000000141702444.004636000000000000 ; 000000166092633.790300000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D83884FD6FEF >									
	//     < NDRV_PFVII_I_metadata_line_10_____Hannover Rueckversicherung Ag Korea Branch_20211101 >									
	//        < xkM9cj1r5wGml3RcFjvFRaq87xsjbR92y65U8TL2x59QE2sMP4gsW2K30Rq26MK2 >									
	//        <  u =="0.000000000000000001" : ] 000000166092633.790300000000000000 ; 000000183258950.058894000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FD6FEF117A187 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFVII_I_metadata_line_11_____Nashville West LLC_20211101 >									
	//        < 9ZDMDHQ4560vkWH5GLW4bj0RAwPRfqZ835l6sFP6hknWB8eeP84jatsd404paw98 >									
	//        <  u =="0.000000000000000001" : ] 000000183258950.058894000000000000 ; 000000204408536.222121000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000117A187137E716 >									
	//     < NDRV_PFVII_I_metadata_line_12_____WRH Offshore High Yield Partners LP_20211101 >									
	//        < dqfymKTqOwSyPGyFqOtmD9T1Jo83H571e3n27sN673oP3AdAaV6SLr71430n3PjG >									
	//        <  u =="0.000000000000000001" : ] 000000204408536.222121000000000000 ; 000000225974929.832197000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000137E716158CF75 >									
	//     < NDRV_PFVII_I_metadata_line_13_____111Ord Llc_20211101 >									
	//        < FjgrFORaJOjN566ibUCSv795C9eCQmwQLB0x74ecY4gONt104DTMszkV20GArqwN >									
	//        <  u =="0.000000000000000001" : ] 000000225974929.832197000000000000 ; 000000251210492.556194000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000158CF7517F5119 >									
	//     < NDRV_PFVII_I_metadata_line_14_____Hannover Insurance_Linked Securities GmbH & Co KG_20211101 >									
	//        < HM2dhzj90HR70Zv6rEg0PvNx070af4BH4UoegWmz947MfsOvbCRJdiegWg9b4i4w >									
	//        <  u =="0.000000000000000001" : ] 000000251210492.556194000000000000 ; 000000274190158.710934000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017F51191A26188 >									
	//     < NDRV_PFVII_I_metadata_line_15_____Hannover Ruckversicherung AG Hong Kong_20211101 >									
	//        < 77AkBn2WvJ4d0q4xvNyLe5tuj77vCSoRCijG7AAl2HfS6x6h2aThfUzM7V23E6qo >									
	//        <  u =="0.000000000000000001" : ] 000000274190158.710934000000000000 ; 000000291065536.780856000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A261881BC217A >									
	//     < NDRV_PFVII_I_metadata_line_16_____Hannover Reinsurance Mauritius Ltd_20211101 >									
	//        < XD7QXFR6gwf988XizXbtZndjemwDcpNKMpSvkPLFT2E1cLzp58rTTn8TM3bd1N35 >									
	//        <  u =="0.000000000000000001" : ] 000000291065536.780856000000000000 ; 000000310073776.225605000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BC217A1D92292 >									
	//     < NDRV_PFVII_I_metadata_line_17_____HEPEP II Holding GmbH_20211101 >									
	//        < 8cRg5oOx57t0V1moAFbHMYPu5IhXkaX8v4DB9CTs75Vj1q5Z5cusB1n8xnIU21hd >									
	//        <  u =="0.000000000000000001" : ] 000000310073776.225605000000000000 ; 000000326249330.366688000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D922921F1D125 >									
	//     < NDRV_PFVII_I_metadata_line_18_____International Insurance Company Of Hannover Limited Sweden_20211101 >									
	//        < wuDt3QCf40g1KGYjsKw2Xdpn3fTEhE1y7BZ6L6yZ9qbqO1436Hc3n29ITpJElFSR >									
	//        <  u =="0.000000000000000001" : ] 000000326249330.366688000000000000 ; 000000343960919.520275000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F1D12520CD7BC >									
	//     < NDRV_PFVII_I_metadata_line_19_____HEPEP III Holding GmbH_20211101 >									
	//        < 7M25S2i13pBv2nh1Svvn22YO911Vu7aycSZ998jsHovadZw6261pPyPJ943Dr300 >									
	//        <  u =="0.000000000000000001" : ] 000000343960919.520275000000000000 ; 000000361054072.329564000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020CD7BC226ECBF >									
	//     < NDRV_PFVII_I_metadata_line_20_____Hannover Rueck Beteiligung Verwaltungs_GmbH_20211101 >									
	//        < g5b1e98QLGSeDFU0F3EnwAS64ADWkH88AppwCpu7aSvlMeimq8vkM6Cci4F1RQ8U >									
	//        <  u =="0.000000000000000001" : ] 000000361054072.329564000000000000 ; 000000378568587.177376000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000226ECBF241A65B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFVII_I_metadata_line_21_____EplusS Rückversicherung AG_20211101 >									
	//        < 3SOiJ5dNkskLz7H9M2zGN1G4Z7rT4W3d0t34a7X57oKqhEhR232VO8G8A8bS1fD8 >									
	//        <  u =="0.000000000000000001" : ] 000000378568587.177376000000000000 ; 000000399643168.374624000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000241A65B261CE9D >									
	//     < NDRV_PFVII_I_metadata_line_22_____HILSP Komplementaer GmbH_20211101 >									
	//        < 9q7b6uqca80aG1y4C7om2YcWMkgJu1auE5b1Pc0G2R823g32mMhT0MuLV7VUuxfC >									
	//        <  u =="0.000000000000000001" : ] 000000399643168.374624000000000000 ; 000000415776096.852679000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000261CE9D27A6C8A >									
	//     < NDRV_PFVII_I_metadata_line_23_____Hannover Life Reassurance UK Limited_20211101 >									
	//        < 8Y1yOl71H33Im2c2Vl7Lv0DfPo91k5fOEbu5QHBYKWFV4xd3lN69o4vITj7po74Y >									
	//        <  u =="0.000000000000000001" : ] 000000415776096.852679000000000000 ; 000000432455670.462925000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027A6C8A293DFFF >									
	//     < NDRV_PFVII_I_metadata_line_24_____EplusS Reinsurance Ireland Ltd_20211101 >									
	//        < 5XtdefFgov3bVsH8Gk7627aRy1c3JQYV3nViwGfAb75KQS09sJS1V7fS9oFmwhZ6 >									
	//        <  u =="0.000000000000000001" : ] 000000432455670.462925000000000000 ; 000000449195382.734069000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000293DFFF2AD6AF2 >									
	//     < NDRV_PFVII_I_metadata_line_25_____Svedea Skadeservice Ab_20211101 >									
	//        < 8AQ1q8FeUxlj57gN11DRq3zM00CR13k91wG1HrAN4hFCs11O9Q98ennKnBUSVz2S >									
	//        <  u =="0.000000000000000001" : ] 000000449195382.734069000000000000 ; 000000468374408.713786000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AD6AF22CAAEC1 >									
	//     < NDRV_PFVII_I_metadata_line_26_____Hannover Finance Luxembourg SA_20211101 >									
	//        < 54RB16Ux88HUe6oqTZLHCnqiTY5069mzuo6l732UpxEmaViwevkFe5mIx26xxA8d >									
	//        <  u =="0.000000000000000001" : ] 000000468374408.713786000000000000 ; 000000485298279.579397000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CAAEC12E481A4 >									
	//     < NDRV_PFVII_I_metadata_line_27_____Hannover Ruckversicherung AG Australia_20211101 >									
	//        < Gy71u7NJ52hR53d0664Hg3QpnLm8bAlBuZ2uWtY5VsSr7R4HJ06VoOxUWinUSK7Y >									
	//        <  u =="0.000000000000000001" : ] 000000485298279.579397000000000000 ; 000000500314648.290489000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E481A42FB6B69 >									
	//     < NDRV_PFVII_I_metadata_line_28_____Cargo Transit Insurance Pty Limited_20211101 >									
	//        < x001s15tfv309q48Iumx11ulhemwLZEk99Ba62LQ9O2apOGogcKk88QRKPZzU90u >									
	//        <  u =="0.000000000000000001" : ] 000000500314648.290489000000000000 ; 000000518841937.139793000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FB6B69317B0A2 >									
	//     < NDRV_PFVII_I_metadata_line_29_____Hannover Life Re Africa_20211101 >									
	//        < lYNv19Q1RcWi2Y9M0D2l32QmdagU64J2MrS2Gdt1upq5f213D5wkbPu3T5w9qUdh >									
	//        <  u =="0.000000000000000001" : ] 000000518841937.139793000000000000 ; 000000542273687.389949000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000317B0A233B71A9 >									
	//     < NDRV_PFVII_I_metadata_line_30_____Hannover Re Services USA Inc_20211101 >									
	//        < S6tC8Y0pV89RSK3qsSrKBeBw6YikJL7z9L7A81s9w0CQ4SF5r99hNb4l9EN5fmTg >									
	//        <  u =="0.000000000000000001" : ] 000000542273687.389949000000000000 ; 000000556702297.307145000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033B71A935175D6 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFVII_I_metadata_line_31_____Talanx Deutschland AG_20211101 >									
	//        < Ura6Hu92X7Qx90EheC85e30cLCbjjxvE14OV7pDdjeKmR3q6ZL50gL9U4bME93oA >									
	//        <  u =="0.000000000000000001" : ] 000000556702297.307145000000000000 ; 000000571417993.635643000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035175D6367EA27 >									
	//     < NDRV_PFVII_I_metadata_line_32_____HDI Lebensversicherung AG_20211101 >									
	//        < FMOQc5zfLkf1K3Cimx51fVB0JYXlm18IRP11U2wNcd0NsL3kXLoaszswoSC6m752 >									
	//        <  u =="0.000000000000000001" : ] 000000571417993.635643000000000000 ; 000000591344194.730547000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000367EA2738651D3 >									
	//     < NDRV_PFVII_I_metadata_line_33_____casa altra development GmbH_20211101 >									
	//        < p4g9b6e1x56sv2dbPX6g0nShzxnk70J6DayTcgma5ba4vj3nWh1HO3nuuY2404dI >									
	//        <  u =="0.000000000000000001" : ] 000000591344194.730547000000000000 ; 000000608768240.919799000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038651D33A0E818 >									
	//     < NDRV_PFVII_I_metadata_line_34_____Credit Life International Services GmbH_20211101 >									
	//        < tVZR8zJmWN8eSB43N20DDjQUH41NNr3h3CI0ZI48j8f809B3Tb61SJi9cYLqa8P3 >									
	//        <  u =="0.000000000000000001" : ] 000000608768240.919799000000000000 ; 000000626799665.107055000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A0E8183BC6B9F >									
	//     < NDRV_PFVII_I_metadata_line_35_____FVB Gesellschaft für Finanz_und Versorgungsberatung mbH_20211101 >									
	//        < GS904r6i23b4c9J19e4m23bj08qi3SFa61HvhLE2mJ0dhZ4ycsIbd3ks9Fk01024 >									
	//        <  u =="0.000000000000000001" : ] 000000626799665.107055000000000000 ; 000000647236813.932272000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003BC6B9F3DB9AE1 >									
	//     < NDRV_PFVII_I_metadata_line_36_____ASPECTA Assurance International AG_20211101 >									
	//        < JuSvBweO1f65317Lw6T1P9cI1Rc1w0L7e5YO6Z659I2btx36Hk4R20Mf65M0xmVQ >									
	//        <  u =="0.000000000000000001" : ] 000000647236813.932272000000000000 ; 000000667176540.330644000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DB9AE13FA07D6 >									
	//     < NDRV_PFVII_I_metadata_line_37_____Life Re_Holdings_20211101 >									
	//        < Ty0zM52K39g420wA31jO3uYG30eXd6KLtD8ar0TF9Qfqh93MsP81ACzMa40G4Kx9 >									
	//        <  u =="0.000000000000000001" : ] 000000667176540.330644000000000000 ; 000000686148780.604753000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003FA07D6416FADE >									
	//     < NDRV_PFVII_I_metadata_line_38_____Credit Life_Pensions_20211101 >									
	//        < rf0V48C5KShG5AtByovExoni6F93FI6zXeQ9myM26gK81i0Hpul53j920W84069I >									
	//        <  u =="0.000000000000000001" : ] 000000686148780.604753000000000000 ; 000000711876245.725396000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000416FADE43E3CA9 >									
	//     < NDRV_PFVII_I_metadata_line_39_____ASPECTA_org_20211101 >									
	//        < kOh5JxEuCiH7495kBZw183qgjOCtiFcG12Og88y0Lq5Us7c47PpY07tefM8D607n >									
	//        <  u =="0.000000000000000001" : ] 000000711876245.725396000000000000 ; 000000732652708.351949000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000043E3CA945DF077 >									
	//     < NDRV_PFVII_I_metadata_line_40_____Cargo Transit_Holdings_20211101 >									
	//        < 2z6135i3Qny0BtCI4Is8P1j02bI5GXE7ZAwhLFi6600i19bdD5BT17M93mH66C8r >									
	//        <  u =="0.000000000000000001" : ] 000000732652708.351949000000000000 ; 000000756107420.564358000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000045DF077481BA76 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}