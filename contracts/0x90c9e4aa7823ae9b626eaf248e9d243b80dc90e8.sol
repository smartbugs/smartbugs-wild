pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXVII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXVII_III_883		"	;
		string	public		symbol =	"	RUSS_PFXXXVII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1066454337805580000000000000					;	
										
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
	//     < RUSS_PFXXXVII_III_metadata_line_1_____ROSNEFTTRANS_20251101 >									
	//        < 2NFx8zEZC4yVQ7j54G1234312oh8LCm1E1y7LZJp1ZNByTq1M0oB2u7tuZPYnm0i >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000033934942.159368800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000033C7D6 >									
	//     < RUSS_PFXXXVII_III_metadata_line_2_____ROSNEFT_MARINE_UK_LIMITED_20251101 >									
	//        < sB66wuaqFB04QWalLJ0U8A8WEDfkK6XFc6ht9yyywkf33on7hIHebUB93wJdxu2G >									
	//        <  u =="0.000000000000000001" : ] 000000033934942.159368800000000000 ; 000000065994165.279852200000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000033C7D664B2F9 >									
	//     < RUSS_PFXXXVII_III_metadata_line_3_____MARINE_ORG_20251101 >									
	//        < 5J8iZFqscBUgozJ1p3uvmgJ77QbuJ34BCPw73bd8523l5E8lTwg38qF4fEOn3t6W >									
	//        <  u =="0.000000000000000001" : ] 000000065994165.279852200000000000 ; 000000096936445.799423500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000064B2F993E9CD >									
	//     < RUSS_PFXXXVII_III_metadata_line_4_____ORENBURGNEFT_ORG_20251101 >									
	//        < A99qK0fKDc4V105wK6n6Qer8WioseC3lWt2YKTL7nW968V3rrk358TJ029MZcWFs >									
	//        <  u =="0.000000000000000001" : ] 000000096936445.799423500000000000 ; 000000116200835.968078000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000093E9CDB14EF4 >									
	//     < RUSS_PFXXXVII_III_metadata_line_5_____ORENBURGNEFT_EUR_20251101 >									
	//        < 5eGR51rPwRY65g92sYg28DgO6u3VG1GdRYrfpGtw344IfMaFL7TQXlcXB18SKzQ3 >									
	//        <  u =="0.000000000000000001" : ] 000000116200835.968078000000000000 ; 000000146341803.519453000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B14EF4DF4CC4 >									
	//     < RUSS_PFXXXVII_III_metadata_line_6_____KUIBYSHEV_ORG_20251101 >									
	//        < Z35BN02j1RmVp39RuvKtD4sQyswxcEnHt0b08A65Nr3lum3d9pa19c1Cy0OWAKD9 >									
	//        <  u =="0.000000000000000001" : ] 000000146341803.519453000000000000 ; 000000172613629.279405000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000DF4CC41076333 >									
	//     < RUSS_PFXXXVII_III_metadata_line_7_____SAMARA_ORG_20251101 >									
	//        < 355NRJu0KRQpkp7wXVyvnM1U68Mc2mk8zSG3aCv2h0lc1oj67szZ6svNpz72LqHa >									
	//        <  u =="0.000000000000000001" : ] 000000172613629.279405000000000000 ; 000000194060716.819045000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010763331281CF8 >									
	//     < RUSS_PFXXXVII_III_metadata_line_8_____SARATOV_ORG_20251101 >									
	//        < CbK3yfjJrm6JW1IF3y0fKAxZc3EMK0Zu7jbBrUPyOtjY55rh9U43E6Y2ZTc930qp >									
	//        <  u =="0.000000000000000001" : ] 000000194060716.819045000000000000 ; 000000213625334.224676000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001281CF8145F765 >									
	//     < RUSS_PFXXXVII_III_metadata_line_9_____RYAZAN_ORG_20251101 >									
	//        < VIPRHXJUnYSlJT5QCecSSgob9ZIDQ16V9yr7t47ik4Fimn3i57qK0E2j60clQx1a >									
	//        <  u =="0.000000000000000001" : ] 000000213625334.224676000000000000 ; 000000234550441.814910000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000145F765165E544 >									
	//     < RUSS_PFXXXVII_III_metadata_line_10_____NYAGAN_ORG_20251101 >									
	//        < K40F5vEZPhNuB3pYc1aY3FjS8w2R2Xl4a50sQM45rlqGrl859mb6B1AaVt5U44tH >									
	//        <  u =="0.000000000000000001" : ] 000000234550441.814910000000000000 ; 000000267421383.695481000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000165E5441980D7A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVII_III_metadata_line_11_____ROSNEFT_MONGOLIA_20251101 >									
	//        < ToZ9LfJHRMA9zk1bzdG59BmogD8X59jDcp7Ez0y73UvYzl3Bom428Zwr3APV9VJ3 >									
	//        <  u =="0.000000000000000001" : ] 000000267421383.695481000000000000 ; 000000301060813.195455000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001980D7A1CB61E1 >									
	//     < RUSS_PFXXXVII_III_metadata_line_12_____ORENBURGNEFT_20251101 >									
	//        < N8AGy26H5QEmy4V7u7c07iOl4SX1WgM3psk5v9W9znpXq8X0c4UopcibhuO77O8D >									
	//        <  u =="0.000000000000000001" : ] 000000301060813.195455000000000000 ; 000000328322298.363103000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CB61E11F4FAE6 >									
	//     < RUSS_PFXXXVII_III_metadata_line_13_____KAMTCHATKA_HOLDING_BV_20251101 >									
	//        < O8oY01O08D388d4019Gubv3563531tl0or2OQOaaR0qF96b2A6X6bmHls3iYNp43 >									
	//        <  u =="0.000000000000000001" : ] 000000328322298.363103000000000000 ; 000000356304442.095586000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F4FAE621FAD6C >									
	//     < RUSS_PFXXXVII_III_metadata_line_14_____ROSNEFT_SHELL_CASPIAN_VENTURES_LIMITED_20251101 >									
	//        < HGoyM62gRV4x3000z0x47D2X26sUsc47i5I8t6Jg73e6IBWFa800uESsZ7Zb3sG2 >									
	//        <  u =="0.000000000000000001" : ] 000000356304442.095586000000000000 ; 000000382908235.604878000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021FAD6C2484588 >									
	//     < RUSS_PFXXXVII_III_metadata_line_15_____KUIBYSHEV_REFINERY_20251101 >									
	//        < A7Q58313LNNgIc13RBq67Pt4sZJZgD96r2JXNx4njCzyZTFYO6h89BESsHAm2tju >									
	//        <  u =="0.000000000000000001" : ] 000000382908235.604878000000000000 ; 000000408289968.941487000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000248458826F0045 >									
	//     < RUSS_PFXXXVII_III_metadata_line_16_____SAMARA_TERMINAL_LLC_20251101 >									
	//        < U9xrJRfPB6BlXx8Gs738I350MgPzNJtSlDIN43cg33SAzju7f77d7CD93VjThs80 >									
	//        <  u =="0.000000000000000001" : ] 000000408289968.941487000000000000 ; 000000428455988.685672000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026F004528DC59F >									
	//     < RUSS_PFXXXVII_III_metadata_line_17_____ROSNEFT_FINANCE_SA_20251101 >									
	//        < 8aQq5K50JN4Z002Kc3mNUx46Pxfy0EoQvBOJi23DAY1QjmVJ2N17E7h7yY9K6813 >									
	//        <  u =="0.000000000000000001" : ] 000000428455988.685672000000000000 ; 000000459474612.030490000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028DC59F2BD1A45 >									
	//     < RUSS_PFXXXVII_III_metadata_line_18_____YUKOS_MOSKVA_20251101 >									
	//        < M5laXpaCYb9zXq5ZhqNiJUGyFQO7XxC74xQ6ER1higYU4Gf1Hy5996s37s0Mz74Y >									
	//        <  u =="0.000000000000000001" : ] 000000459474612.030490000000000000 ; 000000485693507.183014000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BD1A452E51C07 >									
	//     < RUSS_PFXXXVII_III_metadata_line_19_____RN_SEVERNAYA_NEFT_20251101 >									
	//        < 9j3567wVUh0RMxsyqpWcWIZDx5sb1Hf91tDOXD2ofDOC22TjtL60V70cc5Igu810 >									
	//        <  u =="0.000000000000000001" : ] 000000485693507.183014000000000000 ; 000000514524526.544861000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E51C073111A25 >									
	//     < RUSS_PFXXXVII_III_metadata_line_20_____KARACHAEVO_CHERKESSKNEFTPRODUKT_20251101 >									
	//        < LpinG4iOOcajY2u8FOiC5nYbgkaa4U6c49TsZujQI4ifZV5NlIizcI1fMD6RH1Nt >									
	//        <  u =="0.000000000000000001" : ] 000000514524526.544861000000000000 ; 000000545577487.004486000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003111A253407C35 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVII_III_metadata_line_21_____RN_BURENIE_LLC_20251101 >									
	//        < 5K6Cn3eTHj3zPHkSkim0u3iA3clSrC5n297K176ufP26t5FwEoZuub62Ir5M4gwF >									
	//        <  u =="0.000000000000000001" : ] 000000545577487.004486000000000000 ; 000000575659269.547787000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003407C3536E62E7 >									
	//     < RUSS_PFXXXVII_III_metadata_line_22_____RN_MOSKVA_20251101 >									
	//        < r8IC13R3RRF3fE52zx1I4i52uJp2mM2081cWs4tnaY4mKDP47203Y9D37f15REXm >									
	//        <  u =="0.000000000000000001" : ] 000000575659269.547787000000000000 ; 000000608067898.845985000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036E62E739FD686 >									
	//     < RUSS_PFXXXVII_III_metadata_line_23_____BASHNEFT_AB_20251101 >									
	//        < 7eyQiq8Se17A2X079L57eePUV22EB8obaHkiR6A3xEW4vdoAmOQXBF7pGr82oY3D >									
	//        <  u =="0.000000000000000001" : ] 000000608067898.845985000000000000 ; 000000641465383.106470000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039FD6863D2CC6A >									
	//     < RUSS_PFXXXVII_III_metadata_line_24_____TNK_BP_AB_20251101 >									
	//        < TAcb8vPs31uM789iy3Gap9mxpZm87j1DX9F49u00A7qHQ3dlf18TK5jeKolDZ6Ot >									
	//        <  u =="0.000000000000000001" : ] 000000641465383.106470000000000000 ; 000000667450840.666380000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D2CC6A3FA72FC >									
	//     < RUSS_PFXXXVII_III_metadata_line_25_____IOUGANSKNEFTEGAS_20251101 >									
	//        < g4Pjr2gdgw1v4KI8OR5fiPSB5F1ddbXdqlJffsh748E0o69OY0QSUB4ASZb6wqMY >									
	//        <  u =="0.000000000000000001" : ] 000000667450840.666380000000000000 ; 000000696424172.114252000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003FA72FC426A8B1 >									
	//     < RUSS_PFXXXVII_III_metadata_line_26_____RUSS_REGIONAL_DEV_BANK_20251101 >									
	//        < lYkEPlGt8w8BAjZAXGXcE6L439mKtIASZs9I2P9Jcb2Dx8weWWKa687YAn3Hi256 >									
	//        <  u =="0.000000000000000001" : ] 000000696424172.114252000000000000 ; 000000717216165.606616000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000426A8B14466291 >									
	//     < RUSS_PFXXXVII_III_metadata_line_27_____ANGARSK_PETROCHEM_CO_20251101 >									
	//        < v5f33I3R3p34Fb6rE7ImZczEpY6601L5L7NRt5kM52XQyCk0U74Muyy110p91jGD >									
	//        <  u =="0.000000000000000001" : ] 000000717216165.606616000000000000 ; 000000744902523.931872000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004466291470A18C >									
	//     < RUSS_PFXXXVII_III_metadata_line_28_____TNK_NYAGAN_20251101 >									
	//        < M3ATUEsKRM87Ic0w6YEZ08ZH4m1qSHq3suGBhPrp92A61c4ph65rNyGKp0658552 >									
	//        <  u =="0.000000000000000001" : ] 000000744902523.931872000000000000 ; 000000772507048.551161000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000470A18C49AC091 >									
	//     < RUSS_PFXXXVII_III_metadata_line_29_____VERKHNECHONSKNEFTEGAZ_20251101 >									
	//        < phr30iU61Dm5NGMb6c97e34G1A8hVAL16h0hmBe33Q5564rq3uOoQ8oVdS0SpibI >									
	//        <  u =="0.000000000000000001" : ] 000000772507048.551161000000000000 ; 000000790980137.243732000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049AC0914B6F09E >									
	//     < RUSS_PFXXXVII_III_metadata_line_30_____VANKORNEFT_20251101 >									
	//        < 1t5uuq1CViP2xyAsWLko650Zr7I9f7wB20Q263i9qdjs0csL15t79D41Sn49519x >									
	//        <  u =="0.000000000000000001" : ] 000000790980137.243732000000000000 ; 000000814612073.706382000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B6F09E4DAFFD7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVII_III_metadata_line_31_____ROSNEFT_TRADING_SA_20251101 >									
	//        < rcTCiwN334l5UZ3M55r4bwpM9qEMPV2YQl433FYzCHrJkVDw8G83zoDti6252AmR >									
	//        <  u =="0.000000000000000001" : ] 000000814612073.706382000000000000 ; 000000841663404.739730000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004DAFFD750446C4 >									
	//     < RUSS_PFXXXVII_III_metadata_line_32_____ROSNEFT_VIETNAM_BV_20251101 >									
	//        < d3fdMZ6Q6hH4MX3KJ2osg8gdV1HLCkYrLIaMqLvQ3q1J5p583nGK28n72W468Xb0 >									
	//        <  u =="0.000000000000000001" : ] 000000841663404.739730000000000000 ; 000000863649548.773537000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000050446C4525D31B >									
	//     < RUSS_PFXXXVII_III_metadata_line_33_____SARATOV_OIL_REFINERY_20251101 >									
	//        < f0Qi3nQTT6fmO8C1gXn45RH3CxsH5dc6DBlu65EG1ILDrO8pRIuT7109O8pYz1NF >									
	//        <  u =="0.000000000000000001" : ] 000000863649548.773537000000000000 ; 000000882456859.601261000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000525D31B54285B6 >									
	//     < RUSS_PFXXXVII_III_metadata_line_34_____ITERA_LATVIJA_20251101 >									
	//        < BuwxfLkfLPR2qMRC54abG0BjAA79nEJco4T8234Rk6U2OdEUoHgl25jSZF1WPi7F >									
	//        <  u =="0.000000000000000001" : ] 000000882456859.601261000000000000 ; 000000902693100.517258000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000054285B6561667E >									
	//     < RUSS_PFXXXVII_III_metadata_line_35_____EP_ITDA_20251101 >									
	//        < D5Lf9kI17Ju0dW5s7gFe3DnUq5BSThzufmU6Tj0f32Z7Nt4i3prz7c3BzJ7EGdzj >									
	//        <  u =="0.000000000000000001" : ] 000000902693100.517258000000000000 ; 000000922235251.665592000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000561667E57F3825 >									
	//     < RUSS_PFXXXVII_III_metadata_line_36_____RYAZAN_OIL_REFINERY_20251101 >									
	//        < PvQC6MxJZm5v2G22929z9EP8f2uvd1MO99IT8D60dzkDo3rI51k2w6Q2FHyXb6u8 >									
	//        <  u =="0.000000000000000001" : ] 000000922235251.665592000000000000 ; 000000957222383.683188000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000057F38255B49AFE >									
	//     < RUSS_PFXXXVII_III_metadata_line_37_____RN_PURNEFTEGAZ_20251101 >									
	//        < 9HFbU64d8A0AUq2a042X0fc2Ue60x14T095V5rWjKN20GsM9WXN2B2Z44oDAuTfD >									
	//        <  u =="0.000000000000000001" : ] 000000957222383.683188000000000000 ; 000000980692365.389488000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005B49AFE5D86AF5 >									
	//     < RUSS_PFXXXVII_III_metadata_line_38_____NOVY_INVESTMENTS_LIMITED_20251101 >									
	//        < 84A8Ojnnj1n8fz04iy0xpYrq6Dv7J9D42xO4WjHwBJ4HJaRODP94fqsJ4s0hnXI1 >									
	//        <  u =="0.000000000000000001" : ] 000000980692365.389488000000000000 ; 000001006238824.270160000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005D86AF55FF660A >									
	//     < RUSS_PFXXXVII_III_metadata_line_39_____ROSNEFT_STS_20251101 >									
	//        < T87jVUjc07wq9MH901y7tOKVt5svjiUIOrARYSPhR43ZDEAQ13GYb2EdS43G1IJi >									
	//        <  u =="0.000000000000000001" : ] 000001006238824.270160000000000000 ; 000001040897368.510190000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005FF660A6344889 >									
	//     < RUSS_PFXXXVII_III_metadata_line_40_____ROSNEFT_INT_HOLDINGS_LIMITED_20251101 >									
	//        < 9J9qwpGyE3uUP1i5e9aR4e6712swga4UeawIM1lQATy7qB8ZdZN8P9RrpL30S0uD >									
	//        <  u =="0.000000000000000001" : ] 000001040897368.510190000000000000 ; 000001066454337.805580000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000634488965B47BA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}