pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXV_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXV_II_883		"	;
		string	public		symbol =	"	RUSS_PFXXXV_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		766375613856468000000000000					;	
										
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
	//     < RUSS_PFXXXV_II_metadata_line_1_____ALROSA_20231101 >									
	//        < eAxY7VDnRanh7MLdl7YauJQ84V3MS01dicCoyXTEM8Cis93oRmFJL9AD8cRpZTL7 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000017577492.048677200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001AD235 >									
	//     < RUSS_PFXXXV_II_metadata_line_2_____ARCOS_HK_LIMITED_20231101 >									
	//        < a79iMu0t3MWM1xtXe82w735JtYWw2ZCqN27D2c4DudtW8WvqC13eVhD139XUKQ1T >									
	//        <  u =="0.000000000000000001" : ] 000000017577492.048677200000000000 ; 000000034014159.826592300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001AD23533E6C8 >									
	//     < RUSS_PFXXXV_II_metadata_line_3_____ARCOS_ORG_20231101 >									
	//        < r23War76R3ppF0619uC3Hgua5Y431nT667wZ4yhmyu1rv9ulkg0GseGqK89eeiJL >									
	//        <  u =="0.000000000000000001" : ] 000000034014159.826592300000000000 ; 000000051846273.028170500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000033E6C84F1C73 >									
	//     < RUSS_PFXXXV_II_metadata_line_4_____SUNLAND_HOLDINGS_SA_20231101 >									
	//        < FidYoi38X3X3A1L7eRqA0P12eLBtJYiF5CpXc3V4wlz5hZDallG5kP9i81SE086Z >									
	//        <  u =="0.000000000000000001" : ] 000000051846273.028170500000000000 ; 000000069506659.208994300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004F1C736A0F0A >									
	//     < RUSS_PFXXXV_II_metadata_line_5_____ARCOS_BELGIUM_NV_20231101 >									
	//        < 64w6CgJEuq3HoyYA48KCbQ39In8Iodn1OpP8D87ht24r38FZNiv0amzWmycV208g >									
	//        <  u =="0.000000000000000001" : ] 000000069506659.208994300000000000 ; 000000087162159.836151700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006A0F0A84FFB8 >									
	//     < RUSS_PFXXXV_II_metadata_line_6_____MEDIAGROUP_SITIM_20231101 >									
	//        < WcC0vbxMDq8wQ1SZX32esOG6XhrI4dOjZZXqVCk65T6wxKfm5dQGPq28naHn1M8h >									
	//        <  u =="0.000000000000000001" : ] 000000087162159.836151700000000000 ; 000000106705561.152175000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000084FFB8A2D1DC >									
	//     < RUSS_PFXXXV_II_metadata_line_7_____ALROSA_FINANCE_BV_20231101 >									
	//        < egw15KdR8T3TZoxI6uc042tcuUhpvY7V0pspWFPQNV42p5tN0F32o9aW976Os588 >									
	//        <  u =="0.000000000000000001" : ] 000000106705561.152175000000000000 ; 000000123125984.596213000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A2D1DCBBE016 >									
	//     < RUSS_PFXXXV_II_metadata_line_8_____SHIPPING_CO_ALROSA_LENA_20231101 >									
	//        < RTi2Q4ZR8woo2OFQ4aS8U892dt56o035oBhbVHyZl9Xn9RP0650079l2Ys38KZiI >									
	//        <  u =="0.000000000000000001" : ] 000000123125984.596213000000000000 ; 000000145823236.722301000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BBE016DE8234 >									
	//     < RUSS_PFXXXV_II_metadata_line_9_____LENA_ORG_20231101 >									
	//        < 0H1qJ8H1W07tfAetCfz72fTvbjgM2MTEn6067DZUbzBsbjUq9JK0OUM23P9ku0h0 >									
	//        <  u =="0.000000000000000001" : ] 000000145823236.722301000000000000 ; 000000161419404.654487000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DE8234F64E74 >									
	//     < RUSS_PFXXXV_II_metadata_line_10_____ALROSA_AFRICA_20231101 >									
	//        < MeBMAd5wA3m3y6YAhDV765M8K8gU4w12QZ7M7WDu32T6wsKgY7KymyY2P4Np2gRz >									
	//        <  u =="0.000000000000000001" : ] 000000161419404.654487000000000000 ; 000000182988466.682967000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F64E7411737DF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXV_II_metadata_line_11_____INVESTMENT_GROUP_ALROSA_20231101 >									
	//        < H24e3whKRhHDdmoaL6aj8frCVCPrfm94jUT3s43008MM6XC082263ud08d0C7GO0 >									
	//        <  u =="0.000000000000000001" : ] 000000182988466.682967000000000000 ; 000000201402464.850919000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011737DF13350D6 >									
	//     < RUSS_PFXXXV_II_metadata_line_12_____INVESTITSIONNAYA_GRUPPA_ALROSA_20231101 >									
	//        < G20OZtTaz4lMG1dl77Z8fl5Hmyh0s84fJJdE23M5dOjsD68wI3mVJynMQ5XIm2G1 >									
	//        <  u =="0.000000000000000001" : ] 000000201402464.850919000000000000 ; 000000222266963.363670000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013350D61532708 >									
	//     < RUSS_PFXXXV_II_metadata_line_13_____VILYUISKAYA_GES_3_20231101 >									
	//        < q2e3G1sYrkSZaU5lB7yZd2erbwNpOG3Er1w0090tsvf5wZ1q4KY8kRIZpU2R5XuO >									
	//        <  u =="0.000000000000000001" : ] 000000222266963.363670000000000000 ; 000000244311688.837549000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001532708174CA41 >									
	//     < RUSS_PFXXXV_II_metadata_line_14_____NPP_BUREVESTNIK_20231101 >									
	//        < srH0SDn44IWi69C1Y1C8M02mxyHPVOY0rHCd5WIdgMT6701o37oicqP10a0SRyg3 >									
	//        <  u =="0.000000000000000001" : ] 000000244311688.837549000000000000 ; 000000266726497.752847000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000174CA41196FE0A >									
	//     < RUSS_PFXXXV_II_metadata_line_15_____NARNAUL_KRISTALL_FACTORY_20231101 >									
	//        < H5My4joEzAfc5dv4CC0Hs6wfgGqMrX1eV3kg3uW1EWkZVh8WCqsxv6J8K9A1wgPh >									
	//        <  u =="0.000000000000000001" : ] 000000266726497.752847000000000000 ; 000000283252286.455337000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000196FE0A1B0356D >									
	//     < RUSS_PFXXXV_II_metadata_line_16_____NARNAUL_ORG_20231101 >									
	//        < kbCdQd8Z5q2uk7F69AZFx4G28MBvtg9a7x23Ec46P0tfs9DNHWl0z9BYZ4vUI433 >									
	//        <  u =="0.000000000000000001" : ] 000000283252286.455337000000000000 ; 000000300605641.416064000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B0356D1CAB014 >									
	//     < RUSS_PFXXXV_II_metadata_line_17_____HIDROELECTRICA_CHICAPA_SARL_20231101 >									
	//        < KtnN91hl294DOkr7fmLTJZxHKTK6cb2j6IkJwYbrdNtkfhowjS87liSgeQfBWR7e >									
	//        <  u =="0.000000000000000001" : ] 000000300605641.416064000000000000 ; 000000316511639.203208000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CAB0141E2F55C >									
	//     < RUSS_PFXXXV_II_metadata_line_18_____CHICAPA_ORG_20231101 >									
	//        < RVI2w4YJO128tBnA7vx485nlRaGuwGTIXt84T2ggu4GXLKcW60IAz5YMT41j480W >									
	//        <  u =="0.000000000000000001" : ] 000000316511639.203208000000000000 ; 000000333214782.285722000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E2F55C1FC7206 >									
	//     < RUSS_PFXXXV_II_metadata_line_19_____ALROSA_VGS_LLC_20231101 >									
	//        < I05K1OMr4Km69jM1V6s50dd4qfp8p50T4IRvg3mfWLwe44KV4kxz14R2264LhWmM >									
	//        <  u =="0.000000000000000001" : ] 000000333214782.285722000000000000 ; 000000354359445.025346000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FC720621CB5A9 >									
	//     < RUSS_PFXXXV_II_metadata_line_20_____ARCOS_DIAMOND_ISRAEL_20231101 >									
	//        < yx8wKQKyOCZ85558fpj0xw36m0ZbXPt3CSZR8OVJ1OkWw7XzVRVIctgv2O5x036X >									
	//        <  u =="0.000000000000000001" : ] 000000354359445.025346000000000000 ; 000000373370522.933952000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021CB5A9239B7DC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXV_II_metadata_line_21_____ALMAZY_ANABARA_20231101 >									
	//        < F4HNF516r23Nap7U4tVX9m0g20lT7ZV9p27Bzg0eTawY3hWaq29h4GhdSUI36pZV >									
	//        <  u =="0.000000000000000001" : ] 000000373370522.933952000000000000 ; 000000395041133.527796000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000239B7DC25AC8F1 >									
	//     < RUSS_PFXXXV_II_metadata_line_22_____ALMAZY_ORG_20231101 >									
	//        < SCmTAejumFVV09I074GJnSS8RmLD1H5xA1chP3m7L5e1bcV43wX89Ej398j6D9yr >									
	//        <  u =="0.000000000000000001" : ] 000000395041133.527796000000000000 ; 000000412636894.251267000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025AC8F1275A249 >									
	//     < RUSS_PFXXXV_II_metadata_line_23_____ALROSA_ORG_20231101 >									
	//        < eoEOurAaYfQU2T6XJq8aQ3Q938YBJN8CM9FxLxhkvEHgujkX5j7IrQ33Ne2Oz2ip >									
	//        <  u =="0.000000000000000001" : ] 000000412636894.251267000000000000 ; 000000431799907.075078000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000275A249292DFD7 >									
	//     < RUSS_PFXXXV_II_metadata_line_24_____SEVERALMAZ_20231101 >									
	//        < 0SRhSXe2oxn7Rj0DrFTE0ZIQ4nl50wP4yBI60z8Qra0761Ivd3ExQL0T7X21c8Jk >									
	//        <  u =="0.000000000000000001" : ] 000000431799907.075078000000000000 ; 000000451297828.902414000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000292DFD72B0A037 >									
	//     < RUSS_PFXXXV_II_metadata_line_25_____ARCOS_USA_20231101 >									
	//        < fL9iicd4c78npu1yF1h8lL28xMt855wmK5loaNhP1vs8tvSsKSH8kBYmliWE8fLz >									
	//        <  u =="0.000000000000000001" : ] 000000451297828.902414000000000000 ; 000000473134535.801090000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B0A0372D1F22E >									
	//     < RUSS_PFXXXV_II_metadata_line_26_____NYURBA_20231101 >									
	//        < XHkp8944x5kANLn3k8lPBOn8330H29fed4p0x92984YhP5A1LDu13IF7EP9OXPQ0 >									
	//        <  u =="0.000000000000000001" : ] 000000473134535.801090000000000000 ; 000000489641355.326801000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D1F22E2EB2228 >									
	//     < RUSS_PFXXXV_II_metadata_line_27_____NYURBA_ORG_20231101 >									
	//        < 67fLMgFQtH54UM7H1Hvt6Vs5rV7Z3stF750Gke35Gr6ke66s98aj0L0Y70PB6H3w >									
	//        <  u =="0.000000000000000001" : ] 000000489641355.326801000000000000 ; 000000505238439.394153000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EB2228302EEC4 >									
	//     < RUSS_PFXXXV_II_metadata_line_28_____EAST_DMCC_20231101 >									
	//        < hn8h4Nd65Ux03dXSD7Y2MmP5oP64p5Yt64U5L4Lnnj4tHA1cWjvmL136QP2Ka403 >									
	//        <  u =="0.000000000000000001" : ] 000000505238439.394153000000000000 ; 000000522899545.103503000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000302EEC431DE1A3 >									
	//     < RUSS_PFXXXV_II_metadata_line_29_____ALROSA_FINANCE_SA_20231101 >									
	//        < B95mv630E8TS5FSnvriC7xvOefymi6A1ot2erf170WYfi0X67hpwj5Fuo04NfZ43 >									
	//        <  u =="0.000000000000000001" : ] 000000522899545.103503000000000000 ; 000000543345962.184284000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031DE1A333D1484 >									
	//     < RUSS_PFXXXV_II_metadata_line_30_____ALROSA_OVERSEAS_SA_20231101 >									
	//        < 822ht6vv2ShH154ikAEkLpqO3HQq39c5fsBXm7N31iM0074a2dpuIeaBxGU6ugq3 >									
	//        <  u =="0.000000000000000001" : ] 000000543345962.184284000000000000 ; 000000564712787.362122000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033D148435DAEEF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXV_II_metadata_line_31_____ARCOS_EAST_DMCC_20231101 >									
	//        < b6huBkj8Mg12cRt9AMEqIacS3WLJD56q1kbHg66k65G1Xl05OLB7L091f94lSzb2 >									
	//        <  u =="0.000000000000000001" : ] 000000564712787.362122000000000000 ; 000000584234686.652163000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035DAEEF37B78AD >									
	//     < RUSS_PFXXXV_II_metadata_line_32_____HIDROCHICAPA_SARL_20231101 >									
	//        < 4bFT7ox0U16na55q56cnj40BsXps07h9FaW1cD0ecyo16kmr5KyVhgA4276YbAF7 >									
	//        <  u =="0.000000000000000001" : ] 000000584234686.652163000000000000 ; 000000607184251.321032000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037B78AD39E7D59 >									
	//     < RUSS_PFXXXV_II_metadata_line_33_____ALROSA_GAZ_20231101 >									
	//        < 8uD0OGf2G52M9Rcq6De77I14rp4T38W0hKcD1a73S67u71eH8AHS0XI0lVW59a1z >									
	//        <  u =="0.000000000000000001" : ] 000000607184251.321032000000000000 ; 000000628346590.338270000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039E7D593BEC7E3 >									
	//     < RUSS_PFXXXV_II_metadata_line_34_____SUNLAND_TRADING_SA_20231101 >									
	//        < Tg05CbGZW93Y90WoVkut4buo5TF234x36zC25PYnm7s1ukXl47j6RRP3a8f99uRt >									
	//        <  u =="0.000000000000000001" : ] 000000628346590.338270000000000000 ; 000000646918581.275620000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003BEC7E33DB1E92 >									
	//     < RUSS_PFXXXV_II_metadata_line_35_____ORYOL_ALROSA_20231101 >									
	//        < L968H8SOa10A38hfhD1EBe7X4p5RKT5Gn2jT9n3Fljh1Cp92IgzQ9k29UjL962XJ >									
	//        <  u =="0.000000000000000001" : ] 000000646918581.275620000000000000 ; 000000663379796.100532000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DB1E923F43CBC >									
	//     < RUSS_PFXXXV_II_metadata_line_36_____GOLUBAYA_VOLNA_HEALTH_RESORT_20231101 >									
	//        < OqJ87m6RX72i8f86Nq017jhmT4PKmOWEJZ77bUE0bib1Ko8hve78ocqv5Z789xSI >									
	//        <  u =="0.000000000000000001" : ] 000000663379796.100532000000000000 ; 000000680611728.576708000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F43CBC40E87F5 >									
	//     < RUSS_PFXXXV_II_metadata_line_37_____GOLUBAYA_ORG_20231101 >									
	//        < k9Ok7fV0MNkb9tN5uJ93xPa346vgPK4zTR2fR5i66GI7eb914mX88eUa4MN6IR5f >									
	//        <  u =="0.000000000000000001" : ] 000000680611728.576708000000000000 ; 000000705458862.643825000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040E87F543471DE >									
	//     < RUSS_PFXXXV_II_metadata_line_38_____SEVERNAYA_GORNO_GEOLOGIC_KOM_TERRA_20231101 >									
	//        < EYuV9gEWsF15LP04tefkmkm9as1aSe549YAwF5d1Kep6zW9vO3x65qnYn35q2819 >									
	//        <  u =="0.000000000000000001" : ] 000000705458862.643825000000000000 ; 000000722868265.923666000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000043471DE44F026B >									
	//     < RUSS_PFXXXV_II_metadata_line_39_____SEVERNAYA_ORG_20231101 >									
	//        < Ged9s790OAVSF4Hh7qzZ1hvuHM27Q4sM522n44289RliEx172JU4kcP7PJN7Up86 >									
	//        <  u =="0.000000000000000001" : ] 000000722868265.923666000000000000 ; 000000746505996.576124000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044F026B47313E8 >									
	//     < RUSS_PFXXXV_II_metadata_line_40_____ALROSA_NEVA_20231101 >									
	//        < SvUF6S1MTdec3P5yXU5nwi8BU2s1u3N7Q3zIt3G9YucwPEKkTzW9mD96CzvUQHxv >									
	//        <  u =="0.000000000000000001" : ] 000000746505996.576124000000000000 ; 000000766375613.856468000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000047313E84916579 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}