pragma solidity 		^0.4.21	;						
										
	contract	NDD_DBX_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDD_DBX_I_883		"	;
		string	public		symbol =	"	NDD_DBX_I_1subDT		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		505773630192928000000000000					;	
										
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
	//     < NDD_DBX_I_metadata_line_1_____6938413225 Lab_x >									
	//        < wJ05MFSS4t53ncyBOod70ceAtuti43D0T6I6Zp33Ogr9GN1psR865S0z08769O9P >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000000F4240 >									
	//     < NDD_DBX_I_metadata_line_2_____9781285179 Lab_y >									
	//        < 90aGUG4B4ta7Co8clvt5s6C8vw7SUF9we25prviGQaGtKc4G6Z07SthK8DIEcA36 >									
	//        <  u =="0.000000000000000001" : ] 000000010000000.000000000000000000 ; 000000020000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000F42401E8480 >									
	//     < NDD_DBX_I_metadata_line_3_____2308636778 Lab_100 >									
	//        < p6qe44sRY95Vq0LV8480O0jsH8W4E99d5tCYSvgir878pdnu0756L3w6q83KLMlm >									
	//        <  u =="0.000000000000000001" : ] 000000020000000.000000000000000000 ; 000000030439311.800000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001E84802E725B >									
	//     < NDD_DBX_I_metadata_line_4_____2399595409 Lab_110 >									
	//        < 2CJ1lSCm9H97n4mea293r6m4FVN3a4jicKEC6q6bIZXXyMaXbb04JZ0k1027TW23 >									
	//        <  u =="0.000000000000000001" : ] 000000030439311.800000000000000000 ; 000000041383832.100000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002E725B3F258F >									
	//     < NDD_DBX_I_metadata_line_5_____2364880496 Lab_410/401 >									
	//        < y317Wg931Z52i2q39N7NTRn8P4jDzLxBKD84V11WWA19QD30PzBH2W5ZluSi7y14 >									
	//        <  u =="0.000000000000000001" : ] 000000041383832.100000000000000000 ; 000000055161913.300000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003F258F542B9F >									
	//     < NDD_DBX_I_metadata_line_6_____2393307974 Lab_810/801 >									
	//        < PrC7L6MqH209piY3W70SPpTHnr0SvH5T5NIKVt0OO1pz5l0AnYu7SEZZKO7URqOB >									
	//        <  u =="0.000000000000000001" : ] 000000055161913.300000000000000000 ; 000000072718075.700000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000542B9F6EF580 >									
	//     < NDD_DBX_I_metadata_line_7_____2364880496 Lab_410_3Y1Y >									
	//        < 6NuWk03Jar6976xnFlY6K4BckImerQwCcB77mW2Qb5yBItGlqw4T4iWB9Q20E0zj >									
	//        <  u =="0.000000000000000001" : ] 000000072718075.700000000000000000 ; 000000098873768.006125200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006EF58096DE91 >									
	//     < NDD_DBX_I_metadata_line_8_____2393307974 Lab_410_5Y1Y >									
	//        < DcHT88pcBBeVsc3X1hkwEMm9cA0zf49OG2YhA0sP25B3cI1cKTi94VJZ9hnaD66B >									
	//        <  u =="0.000000000000000001" : ] 000000098873768.006125200000000000 ; 000000108873768.006125000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000096DE91A620D1 >									
	//     < NDD_DBX_I_metadata_line_9_____2323232323 Lab_410_7Y1Y >									
	//        < a9gcgRk0NDQ0fysTu5EBjUygL9f7qw3Gs2LY42B2X74ag3I9Blc86UVEI726n5ro >									
	//        <  u =="0.000000000000000001" : ] 000000108873768.006125000000000000 ; 000000118873768.006125000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A620D1B56311 >									
	//     < NDD_DBX_I_metadata_line_10_____2323232323 Lab_810_3Y1Y >									
	//        < ATtU48C5AajF0i3hDhB2v1pgwYruY4C95GhD6t7c370h84WRp7AvzUAr4kP80ILX >									
	//        <  u =="0.000000000000000001" : ] 000000118873768.006125000000000000 ; 000000172985167.790574000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000B56311107F455 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_DBX_I_metadata_line_11_____2371307665 Lab_810_5Y1Y >									
	//        < 8AD23RuMyXfE6V73g8Vh07V4cPGle01rSy5JnmK2B773PAE119NbN8HCrl8QHEB0 >									
	//        <  u =="0.000000000000000001" : ] 000000172985167.790574000000000000 ; 000000182985167.790574000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000107F4551173695 >									
	//     < NDD_DBX_I_metadata_line_12_____2308670199 Lab_810_7Y1Y >									
	//        < 90R55zY32eGNh2w70Vo851l0B84YHC73N0CWmRVe20upvt32so53eK202v0NV1hO >									
	//        <  u =="0.000000000000000001" : ] 000000182985167.790574000000000000 ; 000000192985167.790574000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000117369512678D5 >									
	//     < NDD_DBX_I_metadata_line_13_____2323232323 ro_Lab_110_3Y_1.00 >									
	//        < J91qP29z7A29ukGMg1228xu3Mj6Gi7ZykR41Ocy98C54Qv8WqDv00mDEUQovsyEX >									
	//        <  u =="0.000000000000000001" : ] 000000192985167.790574000000000000 ; 000000213742252.705376000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012678D51462511 >									
	//     < NDD_DBX_I_metadata_line_14_____2323232323 ro_Lab_110_5Y_1.00 >									
	//        < v3CnXH1Tn1144M0Z1164Mo9yA3WmQ0xw75l4dn80Em9646J3YWQfGc15t8U8K3x1 >									
	//        <  u =="0.000000000000000001" : ] 000000213742252.705376000000000000 ; 000000223742252.705376000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014625111556751 >									
	//     < NDD_DBX_I_metadata_line_15_____2323232323 ro_Lab_110_5Y_1.10 >									
	//        < t1x6fcB8agZTIdNuQ5FBlgUoT9Z0z67den5rk63dl604oe9zl1eQ0C308vv8QG64 >									
	//        <  u =="0.000000000000000001" : ] 000000223742252.705376000000000000 ; 000000233742252.705376000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001556751164A991 >									
	//     < NDD_DBX_I_metadata_line_16_____2323232323 ro_Lab_110_7Y_1.00 >									
	//        < 7A0Snm9TCip5A7Uk8Y32luc87X80b2hvV8A831LVF288BujhZ0vTpuSEkY835G03 >									
	//        <  u =="0.000000000000000001" : ] 000000233742252.705376000000000000 ; 000000243742252.705376000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000164A991173EBD1 >									
	//     < NDD_DBX_I_metadata_line_17_____2323232323 ro_Lab_210_3Y_1.00 >									
	//        < Z8ubgcUtK81Z2CNK9UpQGkqBb9i718Zt7m452466m3ULFoca94V8PRZaaMC42G6x >									
	//        <  u =="0.000000000000000001" : ] 000000243742252.705376000000000000 ; 000000255093971.762262000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000173EBD11853E15 >									
	//     < NDD_DBX_I_metadata_line_18_____2323232323 ro_Lab_210_5Y_1.00 >									
	//        < Z1P3AR8Rq3R5XG2R5p4aQ2qOd6TN6u14y5KffZ89He5t7agU49fZfp73YmItnX3p >									
	//        <  u =="0.000000000000000001" : ] 000000255093971.762262000000000000 ; 000000265093971.762262000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001853E151948055 >									
	//     < NDD_DBX_I_metadata_line_19_____2323232323 ro_Lab_210_5Y_1.10 >									
	//        < 7iUtUBWi99Qol5zYFxlfl2b40pQ6dtKh397L0763P3unGsD7nMh77M38FG6gZ2gk >									
	//        <  u =="0.000000000000000001" : ] 000000265093971.762262000000000000 ; 000000275093971.762262000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019480551A3C295 >									
	//     < NDD_DBX_I_metadata_line_20_____2323232323 ro_Lab_210_7Y_1.00 >									
	//        < 6cV3Zly1Bg4xI688IW3XQB28fJDX6D8qjl6zNhNxwZ28fMl5m4b4Z1e1Qj24a337 >									
	//        <  u =="0.000000000000000001" : ] 000000275093971.762262000000000000 ; 000000285093971.762262000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A3C2951B304D5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_DBX_I_metadata_line_21_____2307640761 ro_Lab_310_3Y_1.00 >									
	//        < g2PxU9HLLgYP3VyNPqQTL5S5z16Ok5ar4FlDUGKwlQt295Bw70TJv9X3GHN2CuJH >									
	//        <  u =="0.000000000000000001" : ] 000000285093971.762262000000000000 ; 000000296793211.373125000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B304D51C4DED9 >									
	//     < NDD_DBX_I_metadata_line_22_____2306305903 ro_Lab_310_5Y_1.00 >									
	//        < 2kb81FIR0KaqE44ZVD3iiiPVWT817xkG72pwrYE5T5rn3iZu3uISu2HT1C952i94 >									
	//        <  u =="0.000000000000000001" : ] 000000296793211.373125000000000000 ; 000000306793211.373125000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C4DED91D42119 >									
	//     < NDD_DBX_I_metadata_line_23_____2396937597 ro_Lab_310_5Y_1.10 >									
	//        < W60540S3V6M2BIa73qFmg3BAfhzI3P068wZg5k9xRA3DqN8SJ61d4l8681K5D6ud >									
	//        <  u =="0.000000000000000001" : ] 000000306793211.373125000000000000 ; 000000316793211.373125000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D421191E36359 >									
	//     < NDD_DBX_I_metadata_line_24_____2323232323 ro_Lab_310_7Y_1.00 >									
	//        < 8dhe83x2TXrDSkdH32mbemjhH07w3q7T93LvT887thtE9NdL1vXs7E2bW7SnK6n3 >									
	//        <  u =="0.000000000000000001" : ] 000000316793211.373125000000000000 ; 000000326793211.373125000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E363591F2A599 >									
	//     < NDD_DBX_I_metadata_line_25_____2323232323 ro_Lab_410_3Y_1.00 >									
	//        < n37tQU13178iF6Xng6fw35n3G5Jn8isz7cG8ud9iI51mQ864Ffl6ixy1Jerh00Y9 >									
	//        <  u =="0.000000000000000001" : ] 000000326793211.373125000000000000 ; 000000338894653.969958000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F2A5992051CB9 >									
	//     < NDD_DBX_I_metadata_line_26_____2323232323 ro_Lab_410_5Y_1.00 >									
	//        < p3vfXAK35wB6EdtPw27n2lSSJm2EVIb58dH3n9P4YzoT2uD6WHpFlEJ1hTIbKcR2 >									
	//        <  u =="0.000000000000000001" : ] 000000338894653.969958000000000000 ; 000000348894653.969958000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002051CB92145EF9 >									
	//     < NDD_DBX_I_metadata_line_27_____2323232323 ro_Lab_410_5Y_1.10 >									
	//        < kpETOM7xiB9QTWeJ8QUz45nOFVzjbTzn92GYJWBYC0Fke088H0oGl3b5mhfq59w4 >									
	//        <  u =="0.000000000000000001" : ] 000000348894653.969958000000000000 ; 000000358894653.969958000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002145EF9223A139 >									
	//     < NDD_DBX_I_metadata_line_28_____2323232323 ro_Lab_410_7Y_1.00 >									
	//        < 77z1l9IrnQ3PZrs6ZXDDbuwSmBfOYHt0LkhpG20w5cohcZcI55XC9T8SPzm3DZz4 >									
	//        <  u =="0.000000000000000001" : ] 000000358894653.969958000000000000 ; 000000368894653.969958000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000223A139232E379 >									
	//     < NDD_DBX_I_metadata_line_29_____2323232323 ro_Lab_810_3Y_1.00 >									
	//        < e48u9rWS6057fS5qU3yXt837G15AXMhA0x0E7z7DELaO35Mfx5ztsA0P3q55i8KJ >									
	//        <  u =="0.000000000000000001" : ] 000000368894653.969958000000000000 ; 000000383228949.920530000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000232E379248C2CF >									
	//     < NDD_DBX_I_metadata_line_30_____2323232323 ro_Lab_810_5Y_1.00 >									
	//        < 673DQYCv19DvOX9q7C5kuK83XvHinjPNs314j7EogF4ngg97BDmzgn1pENWE9E8M >									
	//        <  u =="0.000000000000000001" : ] 000000383228949.920530000000000000 ; 000000393228949.920530000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000248C2CF258050F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_DBX_I_metadata_line_31_____2310203219 ro_Lab_810_5Y_1.10 >									
	//        < 8kCHNw2N1V4LIda7zb43Sf7OhO8GCLg7104RRIvqQWxhsETyIuLSedIwfu1qU4PB >									
	//        <  u =="0.000000000000000001" : ] 000000393228949.920530000000000000 ; 000000403228949.920530000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000258050F267474F >									
	//     < NDD_DBX_I_metadata_line_32_____2310498165 ro_Lab_810_7Y_1.00 >									
	//        < ma5Fq9SEjta1pLYs4qfDG2o21ehdB11aJOom07JHt90LgeHa7h0d3gTanc9P7sJA >									
	//        <  u =="0.000000000000000001" : ] 000000403228949.920530000000000000 ; 000000413228949.920530000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000267474F276898F >									
	//     < NDD_DBX_I_metadata_line_33_____2309870589 ro_Lab_411_3Y_1.00 >									
	//        < 36Wk0Hbxn5629rPMx809W904l01vdsLkEBHIy22e3hwFM088kK3Uux9e5LZymz76 >									
	//        <  u =="0.000000000000000001" : ] 000000413228949.920530000000000000 ; 000000424034005.488683000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000276898F2870649 >									
	//     < NDD_DBX_I_metadata_line_34_____2310263036 ro_Lab_411_5Y_1.00 >									
	//        < 6N6882MazgAipst86g96C31s4NIUGkTc93sXPf2fn7GFO7b1e9X5t6wrb022Q3z8 >									
	//        <  u =="0.000000000000000001" : ] 000000424034005.488683000000000000 ; 000000435530798.410602000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028706492989138 >									
	//     < NDD_DBX_I_metadata_line_35_____2310203219 ro_Lab_411_5Y_1.10 >									
	//        < 2yvMu0MVnvZe950TEU43Ee2wGa4ZMgz8vzpYaGN2O0393A8c1ighoO77Jcp5z0gJ >									
	//        <  u =="0.000000000000000001" : ] 000000435530798.410602000000000000 ; 000000447231262.292887000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029891382AA6BB6 >									
	//     < NDD_DBX_I_metadata_line_36_____2310498165 ro_Lab_411_7Y_1.00 >									
	//        < nv6uXl1M4OFH0D9FqMkixb4zRjLMK7V1325STPWz92qZZagj0S7Rel2jWrYusiga >									
	//        <  u =="0.000000000000000001" : ] 000000447231262.292887000000000000 ; 000000459501290.056729000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AA6BB62BD24B1 >									
	//     < NDD_DBX_I_metadata_line_37_____2309870589 ro_Lab_811_3Y_1.00 >									
	//        < 82KxrxffCbguVr2M0o1BJdXzc7102npGxDw3BHqIZkw7806wSeaqw7u1CMz4k2bT >									
	//        <  u =="0.000000000000000001" : ] 000000459501290.056729000000000000 ; 000000470306345.624882000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BD24B12CDA16B >									
	//     < NDD_DBX_I_metadata_line_38_____2310263036 ro_Lab_811_5Y_1.00 >									
	//        < y0lDOONnMjeoh2N63kJa7qLhAW8Qy0a21kOTC6QUVs9TxK7BswQ7ErjlOjlgV98P >									
	//        <  u =="0.000000000000000001" : ] 000000470306345.624882000000000000 ; 000000481803138.546801000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CDA16B2DF2C5A >									
	//     < NDD_DBX_I_metadata_line_39_____2323232323 ro_Lab_811_5Y_1.10 >									
	//        < MKc9d0764G8g1hBot45jo8dnKy0FhHGtz673HbU9h47t24WCz7uUxt7a35x2Gt5E >									
	//        <  u =="0.000000000000000001" : ] 000000481803138.546801000000000000 ; 000000493503602.429086000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DF2C5A2F106D8 >									
	//     < NDD_DBX_I_metadata_line_40_____2323232323 ro_Lab_811_7Y_1.00 >									
	//        < 3qkUWBNC6TQa0760Hwr7IoF4arF8u00T5bQK26jlfSYtBXOyltSQ2x8tlFN53ROJ >									
	//        <  u =="0.000000000000000001" : ] 000000493503602.429086000000000000 ; 000000505773630.192929000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F106D8303BFD3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}