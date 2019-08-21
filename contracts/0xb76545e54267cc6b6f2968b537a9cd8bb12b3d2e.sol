pragma solidity 		^0.4.21	;						
										
	contract	NDD_LYF_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDD_LYF_I_883		"	;
		string	public		symbol =	"	NDD_LYF_I_1subDT		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		353882411198897000000000000000					;	
										
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
	//     < NDD_LYF_I_metadata_line_1_____6938413225 Lab_x >									
	//        < a0uMBlhd3hh2vbL5t9yf3vLFwYlg8W438N2c44EoFKIz0EEflU6GnO1BdnuucGQS >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000000F4240 >									
	//     < NDD_LYF_I_metadata_line_2_____9781285179 Lab_y >									
	//        < 3Dqn3756n7j4Dj2AqnkYK58BR1qkPtvEn3kJN7Sb4736SWZ1gbR4F9h9So2GHsA2 >									
	//        <  u =="0.000000000000000001" : ] 000000010000000.000000000000000000 ; 000000020000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000F42401E8480 >									
	//     < NDD_LYF_I_metadata_line_3_____2397920782 Lab_100 >									
	//        < s7nXYV06Dk76Yjy98v2th326PUL8opae6845TTcNcPwSaakOi6VV2gO75T02169U >									
	//        <  u =="0.000000000000000001" : ] 000000020000000.000000000000000000 ; 000000031176054.961972600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001E84802F9225 >									
	//     < NDD_LYF_I_metadata_line_4_____2371344966 Lab_110 >									
	//        < uoV3X07uM0U9j0y85w1jp3IOY3fKH8qTxbMZ959G1hxmPYmVQf2g20dSZv7Fm131 >									
	//        <  u =="0.000000000000000001" : ] 000000031176054.961972600000000000 ; 000000043908878.268800200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002F922542FFE8 >									
	//     < NDD_LYF_I_metadata_line_5_____1199676934 Lab_410/401 >									
	//        < 363y8BX9awQI95ZyAa92zn3hx527a5DgPUNf4f81qb1b83aV5cn0vhney90RTpR9 >									
	//        <  u =="0.000000000000000001" : ] 000000043908878.268800200000000000 ; 000000064840171.496110400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000042FFE862F031 >									
	//     < NDD_LYF_I_metadata_line_6_____1078250318 Lab_810/801 >									
	//        < 4tYPv096J4K3uG068Z2J2q1yfD4PV8FYzrb0dSmI9f31sEkSDuns7a5moBSqb9vJ >									
	//        <  u =="0.000000000000000001" : ] 000000064840171.496110400000000000 ; 000000096702757.950730700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000062F031938E84 >									
	//     < NDD_LYF_I_metadata_line_7_____2324797178 Lab_410_3Y1Y >									
	//        < WMyw36Y0R8BVEA7noSW1O7GkGRr355IXJmWHpVsT79uaSN742J1ZuX7D5R8kf5QN >									
	//        <  u =="0.000000000000000001" : ] 000000096702757.950730700000000000 ; 000000146847745.732335000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000938E84E01267 >									
	//     < NDD_LYF_I_metadata_line_8_____2344345782 Lab_410_5Y1Y >									
	//        < 15HiZ3LG52AbTtXIC7eMEnsV0b9C7LdoE9u4DlrYgYY00gv10ycM0gh6A6I8GzkY >									
	//        <  u =="0.000000000000000001" : ] 000000146847745.732335000000000000 ; 000000383733062.832692000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E0126724987BA >									
	//     < NDD_LYF_I_metadata_line_9_____1123854124 Lab_410_7Y1Y >									
	//        < CmuBUa1AGPtgS16ySq7TYEZX86WqJte5zdCyoCOZvOgYX1zdvuCVCTqe80Fcro2M >									
	//        <  u =="0.000000000000000001" : ] 000000383733062.832692000000000000 ; 000001679462657.514470000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024987BAA02A81A >									
	//     < NDD_LYF_I_metadata_line_10_____1115858736 Lab_810_3Y1Y >									
	//        < ea10u99p333353pwQ2dGn4FIZHvV4El5uXhY5J5iUb3Ss4P47OmJy0bm8O1ECd7f >									
	//        <  u =="0.000000000000000001" : ] 000001679462657.514470000000000000 ; 000001872688650.439570000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A02A81AB297F01 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_LYF_I_metadata_line_11_____1125179233 Lab_810_5Y1Y >									
	//        < Wp81C773LK57tUk0dEoBcXT0fd1ME121PuHHgjaf16OXP1F30K26Eo9hGCyC5Mc3 >									
	//        <  u =="0.000000000000000001" : ] 000001872688650.439570000000000000 ; 000003122804367.900620000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000B297F01129D0575 >									
	//     < NDD_LYF_I_metadata_line_12_____1145415595 Lab_810_7Y1Y >									
	//        < HoK3ss1SY8XL9G5wBJ8e79S3mnfjN3dGhOt26Rb1xXW4cxPsQ9cWBzr8SJJ4W6Z5 >									
	//        <  u =="0.000000000000000001" : ] 000003122804367.900620000000000000 ; 000019132384492.426200000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000129D05757209B3B1 >									
	//     < NDD_LYF_I_metadata_line_13_____2334135152 ro_Lab_110_3Y_1.00 >									
	//        < s95SV4QuF16U8r9OYZ9gH4cAMK119AA85a0t8Kpe605HV4RMuaM2E3zvHqB5m0Cj >									
	//        <  u =="0.000000000000000001" : ] 000019132384492.426200000000000000 ; 000019155765522.877200000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000007209B3B1722D60E8 >									
	//     < NDD_LYF_I_metadata_line_14_____2371414779 ro_Lab_110_5Y_1.00 >									
	//        < kWrsCoLO91m1LWyXM7OGG86BJS4ZHBVagqNLAb6p77n5ie7qOoQgz55wbITc8HKz >									
	//        <  u =="0.000000000000000001" : ] 000019155765522.877200000000000000 ; 000019190029290.612100000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000722D60E87261A931 >									
	//     < NDD_LYF_I_metadata_line_15_____2370194139 ro_Lab_110_5Y_1.10 >									
	//        < o9zIb2skN47PQT2RsO8ASpGfqrdnVoS85aBfiFFQK79QxnVCS9iM0Xoof81i4dhD >									
	//        <  u =="0.000000000000000001" : ] 000019190029290.612100000000000000 ; 000019225255691.288000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000007261A93172976981 >									
	//     < NDD_LYF_I_metadata_line_16_____2372806858 ro_Lab_110_7Y_1.00 >									
	//        < 842E346cb40n3M2W0Re7mw0t97mjuV1R1HTGevKB07Ww4Trx1M7GehlZjjHIkXHN >									
	//        <  u =="0.000000000000000001" : ] 000019225255691.288000000000000000 ; 000019278493502.254800000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000007297698172E8A586 >									
	//     < NDD_LYF_I_metadata_line_17_____2306718397 ro_Lab_210_3Y_1.00 >									
	//        < u97vsQxU2I2Sk7Y9vC9r0aCTrRolnpsZ1Bz5Lk2H2oCiB85Y8oIe45FVMdrj5TLD >									
	//        <  u =="0.000000000000000001" : ] 000019278493502.254800000000000000 ; 000019290496197.142100000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000072E8A58672FAF614 >									
	//     < NDD_LYF_I_metadata_line_18_____2389399848 ro_Lab_210_5Y_1.00 >									
	//        < EO1ptqI5q8lw8Hb03F8C8EByvk8OP309Y81VFhJqNnv0zakbVk1HwuBeR9aKb83J >									
	//        <  u =="0.000000000000000001" : ] 000019290496197.142100000000000000 ; 000019309709069.654000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000072FAF6147318471B >									
	//     < NDD_LYF_I_metadata_line_19_____2304414641 ro_Lab_210_5Y_1.10 >									
	//        < M9fOl3F9F80YP81K2P9fJu0xRgy0T14G389212reXCy7991Gb4MwMur8r5bT621r >									
	//        <  u =="0.000000000000000001" : ] 000019309709069.654000000000000000 ; 000019325044976.178700000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000007318471B732FADB2 >									
	//     < NDD_LYF_I_metadata_line_20_____2373115472 ro_Lab_210_7Y_1.00 >									
	//        < uXO0w9wO9g8Cee778Y7tV1Vulp21q4XtE28ARWU2cr4ydYJZWGj816gSLKVyr5pv >									
	//        <  u =="0.000000000000000001" : ] 000019325044976.178700000000000000 ; 000019372769365.042900000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000732FADB273788009 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_LYF_I_metadata_line_21_____2304475159 ro_Lab_310_3Y_1.00 >									
	//        < 756T3zc81OR941wd50Nm5w6kbftPPB9Byl2f37k7704iT9389KSiQEx0tz40QKzD >									
	//        <  u =="0.000000000000000001" : ] 000019372769365.042900000000000000 ; 000019385664680.353500000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000073788009738C2D44 >									
	//     < NDD_LYF_I_metadata_line_22_____2375632581 ro_Lab_310_5Y_1.00 >									
	//        < xBsGaP3l00IkMjqtyskIosmvOA22vgAG0C9dQvZC4kf0fXg4fBprN8p4Tv201Fh8 >									
	//        <  u =="0.000000000000000001" : ] 000019385664680.353500000000000000 ; 000019414274196.354700000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000738C2D4473B7D4DC >									
	//     < NDD_LYF_I_metadata_line_23_____2395254848 ro_Lab_310_5Y_1.10 >									
	//        < RIi4Ep5bWvs09qb57J58qC2l3u1Imx7dJy577O5U83x8ckxk28ny00CVO3HH4KTQ >									
	//        <  u =="0.000000000000000001" : ] 000019414274196.354700000000000000 ; 000019434064881.759600000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000073B7D4DC73D60798 >									
	//     < NDD_LYF_I_metadata_line_24_____2360668275 ro_Lab_310_7Y_1.00 >									
	//        < zQg89E7645m9J91c78HTpijp3i0W4IEde5YNg74Jw9LD28uYsTZqrMzTt9P66C9d >									
	//        <  u =="0.000000000000000001" : ] 000019434064881.759600000000000000 ; 000019552418166.354000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000073D60798748A9F59 >									
	//     < NDD_LYF_I_metadata_line_25_____2397421216 ro_Lab_410_3Y_1.00 >									
	//        < 6z8Wo3qK5AGlhF3S70X4CuE6gAx9J9J20UJdW6509Kk8dDf9d40pHq9KCnj09y2M >									
	//        <  u =="0.000000000000000001" : ] 000019552418166.354000000000000000 ; 000019566436372.491200000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000748A9F5974A00335 >									
	//     < NDD_LYF_I_metadata_line_26_____2385140623 ro_Lab_410_5Y_1.00 >									
	//        < 7Dk3j3N18IT5BJLEOBo8mWlW4m0Ngp1Zo4V5j6Ph6ATT6nLZwEy807471mU1h11j >									
	//        <  u =="0.000000000000000001" : ] 000019566436372.491200000000000000 ; 000019610781679.466000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000074A0033574E3AD98 >									
	//     < NDD_LYF_I_metadata_line_27_____2376768392 ro_Lab_410_5Y_1.10 >									
	//        < 15rHM71lRepM79KoMS04Lmw349urwMs67AoqhB0vk6E8q6JHFnn4oqz2H2cic0HU >									
	//        <  u =="0.000000000000000001" : ] 000019610781679.466000000000000000 ; 000019638057653.599400000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000074E3AD98750D4C45 >									
	//     < NDD_LYF_I_metadata_line_28_____2302404415 ro_Lab_410_7Y_1.00 >									
	//        < Th77ZPei2wp7tA36M7Yq072SmgueLo8R7F2QZyDNhsjZN72isEpQ2lCD6M4Hb6n8 >									
	//        <  u =="0.000000000000000001" : ] 000019638057653.599400000000000000 ; 000019917715238.819900000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000750D4C4576B80584 >									
	//     < NDD_LYF_I_metadata_line_29_____2384697138 ro_Lab_810_3Y_1.00 >									
	//        < O32W1bqppT81zsnrB92N30rnNnu5Y0rh3549N47QEJGySC1m6j8W6eaPYt2280do >									
	//        <  u =="0.000000000000000001" : ] 000019917715238.819900000000000000 ; 000019943032616.463000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000076B8058476DEA71E >									
	//     < NDD_LYF_I_metadata_line_30_____2390740875 ro_Lab_810_5Y_1.00 >									
	//        < 1kfULREVDKsjE2IZ9wY9Zx1jAdJX52grO8p5Esrk5hh90LLtk0A2SXR8u75ABKiZ >									
	//        <  u =="0.000000000000000001" : ] 000019943032616.463000000000000000 ; 000020128036057.338700000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000076DEA71E77F8F216 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_LYF_I_metadata_line_31_____2330180608 ro_Lab_810_5Y_1.10 >									
	//        < fyC5573oDEYTBx6XHxb3QS5zm83bNufm4k56k5m1Oz3GqtcTKGUVTZx9Tfq0Zz7V >									
	//        <  u =="0.000000000000000001" : ] 000020128036057.338700000000000000 ; 000020222338240.365800000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000077F8F2167888D6E0 >									
	//     < NDD_LYF_I_metadata_line_32_____1171634194 ro_Lab_810_7Y_1.00 >									
	//        < 62oX0x1TR40IhiaE50P2lMMpBRP3180ypYq2H7wY0cEkPVUSNS7ZB4d1504H3EBm >									
	//        <  u =="0.000000000000000001" : ] 000020222338240.365800000000000000 ; 000023366634953.113500000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000007888D6E08B46A7C7 >									
	//     < NDD_LYF_I_metadata_line_33_____2359077375 ro_Lab_411_3Y_1.00 >									
	//        < r3I3WGqcFbet3Rwi1k4c1dJXp5W1s6691c109wuW83xOPpelgQ7BUr5Glka7P097 >									
	//        <  u =="0.000000000000000001" : ] 000023366634953.113500000000000000 ; 000023396527479.100700000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000008B46A7C78B74448C >									
	//     < NDD_LYF_I_metadata_line_34_____2327097624 ro_Lab_411_5Y_1.00 >									
	//        < C0ebvA3Oq3Y1tF5AGtTaHr0a6R89ubsyCI1WL1MiQ6F96Lt0X5Ou6I2J14cEMH97 >									
	//        <  u =="0.000000000000000001" : ] 000023396527479.100700000000000000 ; 000023671550999.633000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000008B74448C8D17EB9C >									
	//     < NDD_LYF_I_metadata_line_35_____2315490262 ro_Lab_411_5Y_1.10 >									
	//        < SDh2m8A31fLxaf9QbWz75fFj37jxq1z91t7Yd8hfb3C4fM3wr8NKp6mmwbk99031 >									
	//        <  u =="0.000000000000000001" : ] 000023671550999.633000000000000000 ; 000023808701431.017200000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000008D17EB9C8DE931FF >									
	//     < NDD_LYF_I_metadata_line_36_____1100569824 ro_Lab_411_7Y_1.00 >									
	//        < 0cgWD6yjgrF047sjj5510IC8R745lz0AzHp40UIs4435y1P7163b97fzjtRgNEoO >									
	//        <  u =="0.000000000000000001" : ] 000023808701431.017200000000000000 ; 000034134495767.447800000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000008DE931FFCB751B69 >									
	//     < NDD_LYF_I_metadata_line_37_____1123911314 ro_Lab_811_3Y_1.00 >									
	//        < V5vKoup910vNT5O2SdxS1Xu38WOdAZyphy08asndBhHceEV232GHP0Wsq2RJ2Vg9 >									
	//        <  u =="0.000000000000000001" : ] 000034134495767.447800000000000000 ; 000034215432121.587200000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000CB751B69CBF09B2C >									
	//     < NDD_LYF_I_metadata_line_38_____1059306871 ro_Lab_811_5Y_1.00 >									
	//        < 1w27gsq23Ub1S07g0oqyn4T407871JEqY1LQnfYRKl5m63JFLW26oHn9cBKOZm51 >									
	//        <  u =="0.000000000000000001" : ] 000034215432121.587200000000000000 ; 000039072155573.046400000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000CBF09B2CE8E360C5 >									
	//     < NDD_LYF_I_metadata_line_39_____1126468524 ro_Lab_811_5Y_1.10 >									
	//        < thiNeUu59HGa2pK1J6WI9247oTK1aVHji63s0QHyU02tMf7xYzKjS2DZmEbjPWkh >									
	//        <  u =="0.000000000000000001" : ] 000039072155573.046400000000000000 ; 000041377366437.532300000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000E8E360C5F6A0D9C4 >									
	//     < NDD_LYF_I_metadata_line_40_____983173360 ro_Lab_811_7Y_1.00 >									
	//        < cp12URj13YL1qdLbdFUNt6KTkRz0y60r2R3e9aniP6ai5kb17pjy0Eg346Z94TFz >									
	//        <  u =="0.000000000000000001" : ] 000041377366437.532300000000000000 ; 000353882411198.897000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000F6A0D9C483D4DB4E0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}