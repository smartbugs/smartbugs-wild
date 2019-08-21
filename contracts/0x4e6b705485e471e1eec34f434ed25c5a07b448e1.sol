pragma solidity 		^0.4.21	;						
										
	contract	NBI_PFII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NBI_PFII_II_883		"	;
		string	public		symbol =	"	NBI_PFII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		795030739719161000000000000					;	
										
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
	//     < NBI_PFII_II_metadata_line_1_____CRC_CR_Beijing_group_20231101 >									
	//        < KAhDV21BoIwWK2g3ihw8P6o0yEPr1a3Avg8Y1wjvpc22ANhH8H1YJZ4BN5AuQYRL >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000015808030.962754000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000181F03 >									
	//     < NBI_PFII_II_metadata_line_2_____CRC_CR_Qingzang_group_20231101 >									
	//        < 10gi3hu2i2Z4arns045oeH3dNB98UNl11bA6fGFXPt25FWUsgz262v7o2a99rnKg >									
	//        <  u =="0.000000000000000001" : ] 000000015808030.962754000000000000 ; 000000038810243.113468800000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000181F033B3840 >									
	//     < NBI_PFII_II_metadata_line_3_____Chengdu_railway_bureau_20231101 >									
	//        < ln7EZ78OEu3B46s1fTP491UIgCda3o8Kdo492vJDU3w7q2Fec7HHGfdo9992ej6L >									
	//        <  u =="0.000000000000000001" : ] 000000038810243.113468800000000000 ; 000000056573147.443451400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003B38405652E3 >									
	//     < NBI_PFII_II_metadata_line_4_____Chengdu_railway_bureau_Xianghu_20231101 >									
	//        < b4xj1m5iP3l666T953YysQd66K5FgMR7VbdF73OBEZOy2zT2Whe2AXS279n84dLy >									
	//        <  u =="0.000000000000000001" : ] 000000056573147.443451400000000000 ; 000000079860473.156829400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005652E379DB7F >									
	//     < NBI_PFII_II_metadata_line_5_____Chengdu_railway_bureau_Yanglao_jin_20231101 >									
	//        < G5tBcMHid36Qlpv2JF5afMqZ8rf14H6Rk4kW8k52rxa190c065qp8xtmY3quU42B >									
	//        <  u =="0.000000000000000001" : ] 000000079860473.156829400000000000 ; 000000100379709.261233000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000079DB7F992AD3 >									
	//     < NBI_PFII_II_metadata_line_6_____cr_Chengdu_group_chengdu_railway_bureau_xichang_railway_branch_20231101 >									
	//        < Ci1f8fLub5W098z8P466NgM04k9qr54TbQlBX2BWRq7x9QNC8r7olopgPu6Uupz4 >									
	//        <  u =="0.000000000000000001" : ] 000000100379709.261233000000000000 ; 000000119844132.893923000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000992AD3B6DE1D >									
	//     < NBI_PFII_II_metadata_line_7_____CRC_CR_Urumqi_group_20231101 >									
	//        < 8O5x6hQM97vsb825Ai5TY41orm910ZHih3qb6Bn50Rx1C6F5UMuW45KaOJ75glc6 >									
	//        <  u =="0.000000000000000001" : ] 000000119844132.893923000000000000 ; 000000137975906.480705000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B6DE1DD288D7 >									
	//     < NBI_PFII_II_metadata_line_8_____CRC_CR_Urumqi_group_Xianghu_20231101 >									
	//        < USIt951r7B154T9R7231ua9O5ZBmub5JQou3MHRW0f40JRmmK3GmJil741lZCzMI >									
	//        <  u =="0.000000000000000001" : ] 000000137975906.480705000000000000 ; 000000156505681.406597000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D288D7EECF08 >									
	//     < NBI_PFII_II_metadata_line_9_____CRC_CR_Urumqi_group_Yanglao_jin_20231101 >									
	//        < 65plDu0CESQGVJu4GGW669xmBrNx4p1ECGjog261P5dJn1E3116CSl8kb4p992MI >									
	//        <  u =="0.000000000000000001" : ] 000000156505681.406597000000000000 ; 000000177001236.998062000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EECF0810E151C >									
	//     < NBI_PFII_II_metadata_line_10_____CRC_CR_Zhengzhou_group_20231101 >									
	//        < QR3Ch7e8kmW58RUI7GESRXBgb1A5hYb48ix4VpuKu8hz6056g07U87Qp0N4X9aOa >									
	//        <  u =="0.000000000000000001" : ] 000000177001236.998062000000000000 ; 000000193608184.653548000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010E151C1276C32 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NBI_PFII_II_metadata_line_11_____CRC_CR_Zhengzhou_group_Xianghu_20231101 >									
	//        < Aap641Hz0EG3l2gFgHtdaq80j2Eq3w9avMPF1i4386lijx5k29C55e3pHr2x8myT >									
	//        <  u =="0.000000000000000001" : ] 000000193608184.653548000000000000 ; 000000215605718.233565000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001276C32148FCFC >									
	//     < NBI_PFII_II_metadata_line_12_____CRC_CR_Zhengzhou_group_Yanglao_jin_20231101 >									
	//        < 1M1SkbJY7FN5Y5O5LSqRCyKVWBXhhvzY58Rff91JB9P99i31CWsB3Kb3lSa1U097 >									
	//        <  u =="0.000000000000000001" : ] 000000215605718.233565000000000000 ; 000000236813175.508350000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000148FCFC1695926 >									
	//     < NBI_PFII_II_metadata_line_13_____CRC_Shenyang_railways_bureau_20231101 >									
	//        < E4w6OG1H9Ydo6395sW0M8Gw9Kwx4wJEu3uyYV2ph7W06C1kSh9Qd9qJlHs3X87qi >									
	//        <  u =="0.000000000000000001" : ] 000000236813175.508350000000000000 ; 000000258429214.323895000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000169592618A54E9 >									
	//     < NBI_PFII_II_metadata_line_14_____CRC_Shenyang_railways_bureau_Xianghu_20231101 >									
	//        < 233KB49s8Q69gBQTd27686k6N71x4qgCuME17BKgr29k7RiErA7t3u1YxRSyw9VW >									
	//        <  u =="0.000000000000000001" : ] 000000258429214.323895000000000000 ; 000000282176642.813646000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018A54E91AE9140 >									
	//     < NBI_PFII_II_metadata_line_15_____CRC_Shenyang_railways_bureau_Yanglao_jin_20231101 >									
	//        < 3t9w5d5RSY7Q019917cO94irC1c55Y1SUgzkc4dX8QRM7Qmsa188S9D79Akpe2TJ >									
	//        <  u =="0.000000000000000001" : ] 000000282176642.813646000000000000 ; 000000304598321.854746000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AE91401D0C7B8 >									
	//     < NBI_PFII_II_metadata_line_16_____CRC_CR_Harbin_group_20231101 >									
	//        < qo12Tz165k45c9Lm09HW2Or9ceaNFKVbEFSaC25Z5AAMIYnKdvkEn96q0A5XZc2a >									
	//        <  u =="0.000000000000000001" : ] 000000304598321.854746000000000000 ; 000000321022243.736304000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D0C7B81E9D750 >									
	//     < NBI_PFII_II_metadata_line_17_____CRC_CR_Harbin_group_Xianghu_20231101 >									
	//        < o58MR1QSV727p1g61p2MgXICu594L9I8hUuSIGeWA9Gc4A65CmSU6UaMB9lQ6rgF >									
	//        <  u =="0.000000000000000001" : ] 000000321022243.736304000000000000 ; 000000341172587.344658000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E9D750208968B >									
	//     < NBI_PFII_II_metadata_line_18_____CRC_CR_Harbin_group_Yanglao_jin_20231101 >									
	//        < o573CNAWZP2N26N7hEYPJ05P3bt2FLG1m8gDKd6h3pG36jSIP0GbVf65i8wPzM7T >									
	//        <  u =="0.000000000000000001" : ] 000000341172587.344658000000000000 ; 000000360584874.915022000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000208968B2263577 >									
	//     < NBI_PFII_II_metadata_line_19_____CRC_CR_Wuhan_group_20231101 >									
	//        < 36327nT9PI8G8K0K4J98y2O3M2iR4JNHhLYRY84k8U4lnG652BM41D2G3YdD337M >									
	//        <  u =="0.000000000000000001" : ] 000000360584874.915022000000000000 ; 000000377360958.701376000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000226357723FCEA0 >									
	//     < NBI_PFII_II_metadata_line_20_____CRC_CR_Wuhan_group_Xianghu_20231101 >									
	//        < mMErD3Di2yB1uke19ej3943Y0WM05yXAnLCAxmBNan24ynK1HXw6C0EjhLGmh0np >									
	//        <  u =="0.000000000000000001" : ] 000000377360958.701376000000000000 ; 000000393139482.505920000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023FCEA0257E21C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NBI_PFII_II_metadata_line_21_____CRC_CR_Wuhan_group_Yanglao_jin_20231101 >									
	//        < iSl8TqQ21Aa0t7527qqB9PfXgCVF62NkF152Tyq1E2742bd21HS6y5v3sAA341bs >									
	//        <  u =="0.000000000000000001" : ] 000000393139482.505920000000000000 ; 000000413607813.297000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000257E21C2771D8D >									
	//     < NBI_PFII_II_metadata_line_22_____CRC_CR_Nanchang_group_20231101 >									
	//        < 3fVLoXG18w5NFX6A9pK08Gv0R29oewhxe70fxfQFoyZ3gN88LGmMEF34CEzh1fnY >									
	//        <  u =="0.000000000000000001" : ] 000000413607813.297000000000000000 ; 000000437937066.843783000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002771D8D29C3D2B >									
	//     < NBI_PFII_II_metadata_line_23_____CRC_CR_Nanchang_group_Xianghu_20231101 >									
	//        < zbEhJ3sM1HxDZ62HMdCAOd9AnGcbf04WAPpb20m2WgJgHLW8ndY561p0xA78x62L >									
	//        <  u =="0.000000000000000001" : ] 000000437937066.843783000000000000 ; 000000454883455.403172000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029C3D2B2B618DA >									
	//     < NBI_PFII_II_metadata_line_24_____CRC_CR_Nanchang_group_Yanglao_jin_20231101 >									
	//        < eOB5kq9G96281122rTW4u58P4hh68BXUlO8JZzWAyqxQGbew491yU60TD40JP8ai >									
	//        <  u =="0.000000000000000001" : ] 000000454883455.403172000000000000 ; 000000476898051.692593000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B618DA2D7B04D >									
	//     < NBI_PFII_II_metadata_line_25_____CRC_CR_Xi_an_group_20231101 >									
	//        < a2P3Y6XMCa8X22x7gL80Qpo51wP8KhbBr75KYY64uhj64RXGc309Png2hjW3i4F5 >									
	//        <  u =="0.000000000000000001" : ] 000000476898051.692593000000000000 ; 000000500538935.897380000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D7B04D2FBC306 >									
	//     < NBI_PFII_II_metadata_line_26_____CRC_CR_Xi_an_group_Xianghu_20231101 >									
	//        < 8CuazewSU6JMQKkKgHe29X7gC4VBSzyOGmS3o9J6ei8ft1qSDJr270yAP351OlzO >									
	//        <  u =="0.000000000000000001" : ] 000000500538935.897380000000000000 ; 000000516589405.541191000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FBC30631440BD >									
	//     < NBI_PFII_II_metadata_line_27_____CRC_CR_Xi_an_group_Yanglao_jin_20231101 >									
	//        < 5Abzg8cJ2pYa4aaY2mNKLFC3D4UxvFv15Zcl8rwa418KH8g86zw0GNFVBnp9p28R >									
	//        <  u =="0.000000000000000001" : ] 000000516589405.541191000000000000 ; 000000532513073.123700000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031440BD32C8CEB >									
	//     < NBI_PFII_II_metadata_line_28_____CRC_CR_Taiyuan_group_20231101 >									
	//        < Z3j7qO10eQBl4eKctyah87rui2B2ZjevgZo5RwT3Ncx29825V3wGPx7AUJ0Mw38a >									
	//        <  u =="0.000000000000000001" : ] 000000532513073.123700000000000000 ; 000000553555188.013326000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032C8CEB34CA87F >									
	//     < NBI_PFII_II_metadata_line_29_____CRC_CR_Taiyuan_group_Xianghu_20231101 >									
	//        < no45o491O61l99kBgAZzd21Otpm5X2J18a1d3yKm581cJC3vefsD2ne6GytKtSLu >									
	//        <  u =="0.000000000000000001" : ] 000000553555188.013326000000000000 ; 000000574454994.820814000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034CA87F36C8C7B >									
	//     < NBI_PFII_II_metadata_line_30_____CRC_CR_Taiyuan_group_Yanglao_jin_20231101 >									
	//        < 8I6w8Yy0fiT727iLiJYk0y9rHm5BSFcuSFdoDL1eHstAZk1wCNFO5F8L7a7a302K >									
	//        <  u =="0.000000000000000001" : ] 000000574454994.820814000000000000 ; 000000598678180.988469000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036C8C7B39182AA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NBI_PFII_II_metadata_line_31_____CRC_CR_container_transport_corp_ltd_20231101 >									
	//        < 8jWW66zanFNMJ3i2vDSjQKsy792O978Ao1TJV0mbLNWzM68r2S729XDGp0uBona7 >									
	//        <  u =="0.000000000000000001" : ] 000000598678180.988469000000000000 ; 000000619097990.218210000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039182AA3B0AB27 >									
	//     < NBI_PFII_II_metadata_line_32_____cr_container_transport_corp_ltd_cr_international_multimodal_transport_co_ltd_20231101 >									
	//        < 5r3G4YsYF4s76nRiG5lyKK0E4402uYTV4vKEGJV9B5tq3Mv9zCet1LC8574xOxwu >									
	//        <  u =="0.000000000000000001" : ] 000000619097990.218210000000000000 ; 000000636233891.100776000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B0AB273CAD0DD >									
	//     < NBI_PFII_II_metadata_line_33_____cr_container_transport_corp_ltd_lanzhou_pacific_logistics_corp_ltd_20231101 >									
	//        < 5dB0Fs3dgr949391DUbT18Cre71vK5p5NRWjUR9w9BwccT1F7nqyf02VxP131MSi >									
	//        <  u =="0.000000000000000001" : ] 000000636233891.100776000000000000 ; 000000657562588.433337000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003CAD0DD3EB5C63 >									
	//     < NBI_PFII_II_metadata_line_34_____cr_corporation_china_railway_express_co_ltd_20231101 >									
	//        < 9J04byQX1M923Mb89PyjzP3Ok97F5y6H9Ey99PL2Qjo2qsIF2iGmwi85TDu4Z2FH >									
	//        <  u =="0.000000000000000001" : ] 000000657562588.433337000000000000 ; 000000681380421.306180000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003EB5C6340FB43A >									
	//     < NBI_PFII_II_metadata_line_35_____cr_corporation_china_railway_lanzhou_group_20231101 >									
	//        < Ft1c64SR3gl0Tn9FxXc1YBwXWiVL4C4J80NSCloOMNla2PT1y39jhXCGac56I937 >									
	//        <  u =="0.000000000000000001" : ] 000000681380421.306180000000000000 ; 000000701784933.728229000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040FB43A42ED6BD >									
	//     < NBI_PFII_II_metadata_line_36_____Kunming_group_20231101 >									
	//        < CrXQeX13AJhL3pVKRU9CQ2dCW5O1T68Q37ak1UA6gKVStinXPU8SZnRvQIIV63IJ >									
	//        <  u =="0.000000000000000001" : ] 000000701784933.728229000000000000 ; 000000717341200.999445000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042ED6BD4469368 >									
	//     < NBI_PFII_II_metadata_line_37_____CRC_china_railway_hohhot_group_20231101 >									
	//        < LB63FyL7rth42t1UmifK05W99e6E199S30Z1eM846sOn9n1Gcj8DsV4qsFv31wHI >									
	//        <  u =="0.000000000000000001" : ] 000000717341200.999445000000000000 ; 000000734446144.578456000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004469368460AD06 >									
	//     < NBI_PFII_II_metadata_line_38_____CRC_china_railway_nanning_group_20231101 >									
	//        < P7LhBYzvl6XBWUPJOI6TcRoq5AN7KSO25BDfZh1T6LL1169H9V587196T1Caf8aB >									
	//        <  u =="0.000000000000000001" : ] 000000734446144.578456000000000000 ; 000000753285881.378370000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000460AD0647D6C4C >									
	//     < NBI_PFII_II_metadata_line_39_____CRC_nanning_guangzhou_railway_co_limited_20231101 >									
	//        < D0AVl5WXAF09X57IHahVJ0LQV2Zf92tcmFsM7YlHpJx2CJQ8JN65Dn661xG1DJhc >									
	//        <  u =="0.000000000000000001" : ] 000000753285881.378370000000000000 ; 000000777639696.915918000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000047D6C4C4A29582 >									
	//     < NBI_PFII_II_metadata_line_40_____CRC_high_speed_network_technology_co_20231101 >									
	//        < o2tJ2Fz4OBNy4i4529Rr47tv8I2x49x3j2yqCkX81LKy148ZROY4xJ3Fwc2ZlayO >									
	//        <  u =="0.000000000000000001" : ] 000000777639696.915918000000000000 ; 000000795030739.719161000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A295824BD1EE2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}