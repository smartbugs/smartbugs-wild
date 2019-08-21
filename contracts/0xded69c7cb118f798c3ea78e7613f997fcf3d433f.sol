pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXIII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXIII_II_883		"	;
		string	public		symbol =	"	RUSS_PFXXXIII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		850141716087447000000000000					;	
										
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
	//     < RUSS_PFXXXIII_II_metadata_line_1_____PIK_GROUP_20231101 >									
	//        < AJS9Ht7YSuMdpu470ML42tb941FQCzchYFr9t311WB64qs6CuiTQfSVy5h6Wdi0H >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000024031304.835845900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000024AB3A >									
	//     < RUSS_PFXXXIII_II_metadata_line_2_____PIK_INDUSTRIYA_20231101 >									
	//        < 4I3PwR4QRjAA93kmf4Tyf6B622TN7sQYw374swgD6c61nMZRibkN83YU5o69IW50 >									
	//        <  u =="0.000000000000000001" : ] 000000024031304.835845900000000000 ; 000000047761914.895965300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000024AB3A48E0FF >									
	//     < RUSS_PFXXXIII_II_metadata_line_3_____STROYINVEST_20231101 >									
	//        < Nu7Z15DU57SLsV85H03eH1FvCX5oEjc9if7G140at9NMQAQprlEirBQ4TA6x4QhE >									
	//        <  u =="0.000000000000000001" : ] 000000047761914.895965300000000000 ; 000000072057302.575564500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000048E0FF6DF362 >									
	//     < RUSS_PFXXXIII_II_metadata_line_4_____PIK_TECHNOLOGY_20231101 >									
	//        < Am4lkhRvj60y06p0nmi6DHQ2V8e8TJ42Y0907eULFZCVCeiTBik5HN3ylU7bR875 >									
	//        <  u =="0.000000000000000001" : ] 000000072057302.575564500000000000 ; 000000094052198.333697100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006DF3628F8324 >									
	//     < RUSS_PFXXXIII_II_metadata_line_5_____PIK_REGION_20231101 >									
	//        < B0S00RE21OY30k0nm80nNpv1n095TGGcWUY5hK1N1iXkG2p05Y1Xz4s9IA3JKg5m >									
	//        <  u =="0.000000000000000001" : ] 000000094052198.333697100000000000 ; 000000113793642.515855000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008F8324ADA2A4 >									
	//     < RUSS_PFXXXIII_II_metadata_line_6_____PIK_NERUD_OOO_20231101 >									
	//        < 67KX8Pdf49SEBJ5w77d2RZQOQ63W23i2ky0Cnw96dc3NNT15eP73LPl60i0J9Npp >									
	//        <  u =="0.000000000000000001" : ] 000000113793642.515855000000000000 ; 000000137911004.151375000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000ADA2A4D26F7C >									
	//     < RUSS_PFXXXIII_II_metadata_line_7_____PIK_MFS_OOO_20231101 >									
	//        < S8U12depbCrxHq2w5O5YHilxXfz828ZgU5MT35fbtALtBbqNWfG83225hd5s8EeJ >									
	//        <  u =="0.000000000000000001" : ] 000000137911004.151375000000000000 ; 000000155965717.835746000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D26F7CEDFC1C >									
	//     < RUSS_PFXXXIII_II_metadata_line_8_____PIK_COMFORT_20231101 >									
	//        < 18Av61zH9wZp3j06444p91P25je53Wvgi5Wm3BPA9gQVEn466VXmpbaxvj9rb2p7 >									
	//        <  u =="0.000000000000000001" : ] 000000155965717.835746000000000000 ; 000000177721265.656182000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EDFC1C10F2E5F >									
	//     < RUSS_PFXXXIII_II_metadata_line_9_____TRADING_HOUSE_OSNOVA_20231101 >									
	//        < y8OQYF5uzX6LLJlOl9hhtxqC0MopWk34LY640eHMPO4e1Je4K4jZgqW06quH910O >									
	//        <  u =="0.000000000000000001" : ] 000000177721265.656182000000000000 ; 000000196867824.472999000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010F2E5F12C657E >									
	//     < RUSS_PFXXXIII_II_metadata_line_10_____KHROMTSOVSKY_KARIER_20231101 >									
	//        < ADXSa1r88Adcr2V4cGf9MZq3mafBldN8139QeCen19LXk6qIuOUnY2U21sY2D60T >									
	//        <  u =="0.000000000000000001" : ] 000000196867824.472999000000000000 ; 000000219992524.855608000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012C657E14FAE94 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXIII_II_metadata_line_11_____480_KZHI_20231101 >									
	//        < hdD04Aj47Z1ZZz4rTfjx7Q0S5R0CAZcOt8hHc9Zm75r19cm58q45p07BDNEjIx6v >									
	//        <  u =="0.000000000000000001" : ] 000000219992524.855608000000000000 ; 000000239667401.148768000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014FAE9416DB414 >									
	//     < RUSS_PFXXXIII_II_metadata_line_12_____PIK_YUG_OOO_20231101 >									
	//        < 0hMT2sG3sudI7IVq385zyuSwg2VO5XDsJ9Ymra5QM5U1L17482zl6oj38ZD59W7Z >									
	//        <  u =="0.000000000000000001" : ] 000000239667401.148768000000000000 ; 000000261663988.728656000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016DB41418F447F >									
	//     < RUSS_PFXXXIII_II_metadata_line_13_____YUGOOO_ORG_20231101 >									
	//        < jDxq7bwUec6XCBM529NFtyvXrb2hhfs6PdB352A1T550SRmKRRZC0iV266QijTLw >									
	//        <  u =="0.000000000000000001" : ] 000000261663988.728656000000000000 ; 000000283424675.195652000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018F447F1B078C4 >									
	//     < RUSS_PFXXXIII_II_metadata_line_14_____KRASNAYA_PRESNYA_SUGAR_REFINERY_20231101 >									
	//        < qyoa5p90SRHlP2r2P567Fv50U0rM76SpR5L4i2KTw1NJ8kXFQhTN5O73ksFuiAkt >									
	//        <  u =="0.000000000000000001" : ] 000000283424675.195652000000000000 ; 000000300749956.185414000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B078C41CAE874 >									
	//     < RUSS_PFXXXIII_II_metadata_line_15_____NOVOROSGRAGDANPROEKT_20231101 >									
	//        < g3b5F45363GN308De58rx7187K26awXQo82n5mW7vuO3LsxwR36j3khDd1aS36B3 >									
	//        <  u =="0.000000000000000001" : ] 000000300749956.185414000000000000 ; 000000320833355.709948000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CAE8741E98D88 >									
	//     < RUSS_PFXXXIII_II_metadata_line_16_____STATUS_LAND_OOO_20231101 >									
	//        < n136TW9vY4KJBJyv2Ti3cI2l0fCmjC8XrbZ2r2QEQDrUVb8yV8D065Qgd58yod98 >									
	//        <  u =="0.000000000000000001" : ] 000000320833355.709948000000000000 ; 000000343960734.292808000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E98D8820CD7A9 >									
	//     < RUSS_PFXXXIII_II_metadata_line_17_____PIK_PODYOM_20231101 >									
	//        < opDhC1ogX2bjDv0ud430lHqiOPAMUwidqmvMU8c3ps980287600odK232OCna1ZY >									
	//        <  u =="0.000000000000000001" : ] 000000343960734.292808000000000000 ; 000000367928925.150128000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020CD7A92316A3D >									
	//     < RUSS_PFXXXIII_II_metadata_line_18_____PODYOM_ORG_20231101 >									
	//        < 8bfi91bqyTs1UvD5M65Tf6u4nJB7YF2d48oGy08BSTy267z14facr4384PDNgLC0 >									
	//        <  u =="0.000000000000000001" : ] 000000367928925.150128000000000000 ; 000000385137500.120647000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002316A3D24BAC56 >									
	//     < RUSS_PFXXXIII_II_metadata_line_19_____PIK_COMFORT_OOO_20231101 >									
	//        < I1gDxN48af4KJDGr6SSln4pAv8gh1v3n24H1C5G3g02gTOaRE4CkRjXsAR91TgW5 >									
	//        <  u =="0.000000000000000001" : ] 000000385137500.120647000000000000 ; 000000402464572.409060000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024BAC562661CB9 >									
	//     < RUSS_PFXXXIII_II_metadata_line_20_____PIK_KUBAN_20231101 >									
	//        < JpQtRd4azBVE2HxF5gpSuThHNeNela9LcA4P247F3HYzJ4JdzGSe2Sjad4e7TRRy >									
	//        <  u =="0.000000000000000001" : ] 000000402464572.409060000000000000 ; 000000425183845.752503000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002661CB9288C771 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXIII_II_metadata_line_21_____KUBAN_ORG_20231101 >									
	//        < qaDBC4348g9GcGy37md1Y83kJZ3u6CI0rV4ffcAS4du4NUTwQ6M1FjyWXCz6t0Nb >									
	//        <  u =="0.000000000000000001" : ] 000000425183845.752503000000000000 ; 000000448713533.507244000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000288C7712ACAEB9 >									
	//     < RUSS_PFXXXIII_II_metadata_line_22_____MORTON_OOO_20231101 >									
	//        < G3UCD8kR7af77x2FQ15jOrI267HmwoDVZe8Wf925nAPTny3J6Rpdq48k548iS2ni >									
	//        <  u =="0.000000000000000001" : ] 000000448713533.507244000000000000 ; 000000468175676.843743000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002ACAEB92CA6120 >									
	//     < RUSS_PFXXXIII_II_metadata_line_23_____ZAO_PIK_REGION_20231101 >									
	//        < K0WGY8KTTlSER40cHT4P1M4Dq5Txz0M6AW6RBox14Z82bB0D9kSRsZVq03EHO4Cq >									
	//        <  u =="0.000000000000000001" : ] 000000468175676.843743000000000000 ; 000000490076324.229684000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CA61202EBCC10 >									
	//     < RUSS_PFXXXIII_II_metadata_line_24_____ZAO_MONETTSCHIK_20231101 >									
	//        < 3u6b8OQrVW863AydjJWM5z1JwNbZ2244Q4qH2AKThniw3AzlvD4H7oZOn8047W66 >									
	//        <  u =="0.000000000000000001" : ] 000000490076324.229684000000000000 ; 000000513397617.570006000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EBCC1030F61F2 >									
	//     < RUSS_PFXXXIII_II_metadata_line_25_____STROYFORMAT_OOO_20231101 >									
	//        < dyIYK4dFFVib9fZr01q6kiA1geN26256VLBwJJbS5Y2zxpFZ503p989L9nga8ATL >									
	//        <  u =="0.000000000000000001" : ] 000000513397617.570006000000000000 ; 000000530534239.298511000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030F61F232987F0 >									
	//     < RUSS_PFXXXIII_II_metadata_line_26_____VOLGA_FORM_REINFORCED_CONCRETE_PLANT_20231101 >									
	//        < 0dk4Z0338q9jodknV6NWiYX97g1qiK4mme3gQ1gfE49epQL80cZ32wg994zqy4Jr >									
	//        <  u =="0.000000000000000001" : ] 000000530534239.298511000000000000 ; 000000549444391.760011000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032987F034662B7 >									
	//     < RUSS_PFXXXIII_II_metadata_line_27_____ZARECHYE_SPORT_20231101 >									
	//        < c86C50ukQ39M47vShugavmLw8WRem4Wg8XqLQtb55H4FnQdgpqQpTGCM33p7F7uj >									
	//        <  u =="0.000000000000000001" : ] 000000549444391.760011000000000000 ; 000000568144565.062235000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034662B7362EB79 >									
	//     < RUSS_PFXXXIII_II_metadata_line_28_____PIK_PROFILE_OOO_20231101 >									
	//        < 771aX8PY3ZR6mfQ9oQ91t96d5Nd6PZpykvdic3UyMxUYY4IVz6bn2Rq8dTBQDGB6 >									
	//        <  u =="0.000000000000000001" : ] 000000568144565.062235000000000000 ; 000000589106681.790431000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000362EB79382E7CC >									
	//     < RUSS_PFXXXIII_II_metadata_line_29_____FENTROUMA_HOLDINGS_LIMITED_20231101 >									
	//        < Z7c2ED3UH38t7FnCKpUAYIlC7af2f16L8Pcd0z3Hle026MhRG3GfcxIV5c3VUi0M >									
	//        <  u =="0.000000000000000001" : ] 000000589106681.790431000000000000 ; 000000610714043.637257000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000382E7CC3A3E02C >									
	//     < RUSS_PFXXXIII_II_metadata_line_30_____PODMOKOVYE_20231101 >									
	//        < K81T9LQ608rfV2zGZUKn6k83p37niQdH1h4j6JCBJPU1IZBPgN38Ln281a9eqo33 >									
	//        <  u =="0.000000000000000001" : ] 000000610714043.637257000000000000 ; 000000627783467.337205000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A3E02C3BDEBEB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXIII_II_metadata_line_31_____STROYINVESTREGION_20231101 >									
	//        < 17rt6X6z5E9FxZa6uRf1z8B35fEBD3EX6e4v0H6EtyhSZcD2TdFZZ0jwPOiN711j >									
	//        <  u =="0.000000000000000001" : ] 000000627783467.337205000000000000 ; 000000651465806.883615000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003BDEBEB3E20ED5 >									
	//     < RUSS_PFXXXIII_II_metadata_line_32_____PIK_DEVELOPMENT_20231101 >									
	//        < 6ty1E4KuBdL9bPcvM9mp0p26I7xKNsAKEK7ejOXSdiL6c96qj6q8atic98AVo9Jn >									
	//        <  u =="0.000000000000000001" : ] 000000651465806.883615000000000000 ; 000000675683431.769070000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E20ED540702D7 >									
	//     < RUSS_PFXXXIII_II_metadata_line_33_____TAKSOMOTORNIY_PARK_20231101 >									
	//        < 30JpJw48Dbz2s2Y4ag8gY18oVaBfm8A05C4t9Fvvh04s080f9WG892uPkBwl1CYP >									
	//        <  u =="0.000000000000000001" : ] 000000675683431.769070000000000000 ; 000000698782477.424879000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040702D742A41E8 >									
	//     < RUSS_PFXXXIII_II_metadata_line_34_____KALTENBERG_LIMITED_20231101 >									
	//        < fIV97Ei0z04HUcu1T3tL7xhT5wV5eAMGIUTLBoyIQ6mSwZYIJLJqYySJtYzBz1W6 >									
	//        <  u =="0.000000000000000001" : ] 000000698782477.424879000000000000 ; 000000719047054.326598000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042A41E84492DC1 >									
	//     < RUSS_PFXXXIII_II_metadata_line_35_____MAYAK_OOO_20231101 >									
	//        < 897wIiQ5FvCIYYj1S6llG3g3VsYl6MYKb39gi5dVCwk70zNMww58m086P0T50qZU >									
	//        <  u =="0.000000000000000001" : ] 000000719047054.326598000000000000 ; 000000742085345.820161000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004492DC146C5517 >									
	//     < RUSS_PFXXXIII_II_metadata_line_36_____MAYAK_ORG_20231101 >									
	//        < dlSf2OgPE6445d0brZHKfumtn61k7mye5n1D9rMC8AE50F47VzinkMYu90KKYZXw >									
	//        <  u =="0.000000000000000001" : ] 000000742085345.820161000000000000 ; 000000766456765.559561000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046C5517491852D >									
	//     < RUSS_PFXXXIII_II_metadata_line_37_____UDSK_OOO_20231101 >									
	//        < vK4g3bN6Ql7FC2DuOv0szLaPQk87R2NNR6QoQz4Nn10AhfR7awV2aO10UgB6cV6I >									
	//        <  u =="0.000000000000000001" : ] 000000766456765.559561000000000000 ; 000000791080017.306021000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000491852D4B717A2 >									
	//     < RUSS_PFXXXIII_II_metadata_line_38_____ROSTOVSKOYE_MORE_OOO_20231101 >									
	//        < 4gM4Wi9PlyWCnZ61P3Q305ekItPYUatx7P2n204Q64bzSb016K106ujXL8YkaU02 >									
	//        <  u =="0.000000000000000001" : ] 000000791080017.306021000000000000 ; 000000809490084.875371000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B717A24D32F10 >									
	//     < RUSS_PFXXXIII_II_metadata_line_39_____MONETCHIK_20231101 >									
	//        < oqhLYhJ8b4ba5sfvseuh32MxvU79Ce3B339wz9NyrbH86z3bBaID1yp8eJ12r4gQ >									
	//        <  u =="0.000000000000000001" : ] 000000809490084.875371000000000000 ; 000000826943684.961840000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004D32F104EDD0E0 >									
	//     < RUSS_PFXXXIII_II_metadata_line_40_____KUSKOVSKOGO_ORDENA_ZNAK_POCHETA_CHEM_PLANT_20231101 >									
	//        < 9LRhw1A8Q4Lv0UHdo7h05i2J8WEInFP6fymDki0dsIm1n0qCjt5v32FQ34CN65Y7 >									
	//        <  u =="0.000000000000000001" : ] 000000826943684.961840000000000000 ; 000000850141716.087447000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004EDD0E0511369C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}