pragma solidity 		^0.4.21	;						
									
contract	NDD_SPX_I_883				{				
									
	mapping (address => uint256) public balanceOf;								
									
	string	public		name =	"	NDD_SPX_I_883		"	;
	string	public		symbol =	"	NDD_SPX_I_1subDT		"	;
	uint8	public		decimals =		18			;
									
	uint256 public totalSupply =		42919915474153900000000000000					;	
									
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
// }									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
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
//     < NDD_SPX_I_metadata_line_1_____6938413225 Lab_x >									
//        < wJ05MFSS4t53ncyBOod70ceAtuti43D0T6I6Zp33Ogr9GN1psR865S0z08769O9P >									
//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010000000.000000000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000000000000F4240 >									
//     < NDD_SPX_I_metadata_line_2_____9781285179 Lab_y >									
//        < 90aGUG4B4ta7Co8clvt5s6C8vw7SUF9we25prviGQaGtKc4G6Z07SthK8DIEcA36 >									
//        <  u =="0.000000000000000001" : ] 000000010000000.000000000000000000 ; 000000020000000.000000000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000000F42401E8480 >									
//     < NDD_SPX_I_metadata_line_3_____2398386216 Lab_100 >									
//        < p6qe44sRY95Vq0LV8480O0jsH8W4E99d5tCYSvgir878pdnu0756L3w6q83KLMlm >									
//        <  u =="0.000000000000000001" : ] 000000020000000.000000000000000000 ; 000000031097406.649392600000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000001E84802F736D >									
//     < NDD_SPX_I_metadata_line_4_____2377316426 Lab_110 >									
//        < 2CJ1lSCm9H97n4mea293r6m4FVN3a4jicKEC6q6bIZXXyMaXbb04JZ0k1027TW23 >									
//        <  u =="0.000000000000000001" : ] 000000031097406.649392600000000000 ; 000000043144786.265994900000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000002F736D41D56F >									
//     < NDD_SPX_I_metadata_line_5_____2350815547 Lab_410/401 >									
//        < y317Wg931Z52i2q39N7NTRn8P4jDzLxBKD84V11WWA19QD30PzBH2W5ZluSi7y14 >									
//        <  u =="0.000000000000000001" : ] 000000043144786.265994900000000000 ; 000000061334304.732404200000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000000041D56F5D96B6 >									
//     < NDD_SPX_I_metadata_line_6_____1119900900 Lab_810/801 >									
//        < PrC7L6MqH209piY3W70SPpTHnr0SvH5T5NIKVt0OO1pz5l0AnYu7SEZZKO7URqOB >									
//        <  u =="0.000000000000000001" : ] 000000061334304.732404200000000000 ; 000000087713341.665222700000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000005D96B685D706 >									
//     < NDD_SPX_I_metadata_line_7_____2330936625 Lab_410_3Y1Y >									
//        < 6NuWk03Jar6976xnFlY6K4BckImerQwCcB77mW2Qb5yBItGlqw4T4iWB9Q20E0zj >									
//        <  u =="0.000000000000000001" : ] 000000087713341.665222700000000000 ; 000000126230177.340727000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000000085D706C09CAA >									
//     < NDD_SPX_I_metadata_line_8_____2350815547 Lab_410_5Y1Y >									
//        < DcHT88pcBBeVsc3X1hkwEMm9cA0zf49OG2YhA0sP25B3cI1cKTi94VJZ9hnaD66B >									
//        <  u =="0.000000000000000001" : ] 000000126230177.340727000000000000 ; 000000325346109.099472000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000000C09CAA1F07053 >									
//     < NDD_SPX_I_metadata_line_9_____1136903842 Lab_410_7Y1Y >									
//        < a9gcgRk0NDQ0fysTu5EBjUygL9f7qw3Gs2LY42B2X74ag3I9Blc86UVEI726n5ro >									
//        <  u =="0.000000000000000001" : ] 000000325346109.099472000000000000 ; 000000335346109.099472000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000001F070531FFB293 >									
//     < NDD_SPX_I_metadata_line_10_____2323232323 Lab_810_3Y1Y >									
//        < ATtU48C5AajF0i3hDhB2v1pgwYruY4C95GhD6t7c370h84WRp7AvzUAr4kP80ILX >									
//        <  u =="0.000000000000000001" : ] 000000335346109.099472000000000000 ; 000000435843100.388815000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000001FFB2932990B36 >									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
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
//     < NDD_SPX_I_metadata_line_11_____1119900900 Lab_810_5Y1Y >									
//        < 8AD23RuMyXfE6V73g8Vh07V4cPGle01rSy5JnmK2B773PAE119NbN8HCrl8QHEB0 >									
//        <  u =="0.000000000000000001" : ] 000000435843100.388815000000000000 ; 000001713148298.647080000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000002990B36A360E8E >									
//     < NDD_SPX_I_metadata_line_12_____2368322003 Lab_810_7Y1Y >									
//        < 90R55zY32eGNh2w70Vo851l0B84YHC73N0CWmRVe20upvt32so53eK202v0NV1hO >									
//        <  u =="0.000000000000000001" : ] 000001713148298.647080000000000000 ; 000001723148298.647080000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000A360E8EA4550CE >									
//     < NDD_SPX_I_metadata_line_13_____2372925832 ro_Lab_110_3Y_1.00 >									
//        < J91qP29z7A29ukGMg1228xu3Mj6Gi7ZykR41Ocy98C54Qv8WqDv00mDEUQovsyEX >									
//        <  u =="0.000000000000000001" : ] 000001723148298.647080000000000000 ; 000001745350383.420790000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000A4550CEA67317E >									
//     < NDD_SPX_I_metadata_line_14_____2371567118 ro_Lab_110_5Y_1.00 >									
//        < v3CnXH1Tn1144M0Z1164Mo9yA3WmQ0xw75l4dn80Em9646J3YWQfGc15t8U8K3x1 >									
//        <  u =="0.000000000000000001" : ] 000001745350383.420790000000000000 ; 000001778083754.282230000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000A67317EA9923F7 >									
//     < NDD_SPX_I_metadata_line_15_____2307645270 ro_Lab_110_5Y_1.10 >									
//        < t1x6fcB8agZTIdNuQ5FBlgUoT9Z0z67den5rk63dl604oe9zl1eQ0C308vv8QG64 >									
//        <  u =="0.000000000000000001" : ] 000001778083754.282230000000000000 ; 000001811781279.002060000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000A9923F7ACC8F10 >									
//     < NDD_SPX_I_metadata_line_16_____2396918555 ro_Lab_110_7Y_1.00 >									
//        < 7A0Snm9TCip5A7Uk8Y32luc87X80b2hvV8A831LVF288BujhZ0vTpuSEkY835G03 >									
//        <  u =="0.000000000000000001" : ] 000001811781279.002060000000000000 ; 000001821781279.002060000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000ACC8F10ADBD150 >									
//     < NDD_SPX_I_metadata_line_17_____2304729374 ro_Lab_210_3Y_1.00 >									
//        < Z8ubgcUtK81Z2CNK9UpQGkqBb9i718Zt7m452466m3ULFoca94V8PRZaaMC42G6x >									
//        <  u =="0.000000000000000001" : ] 000001821781279.002060000000000000 ; 000001833482146.393340000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000ADBD150AEDABF7 >									
//     < NDD_SPX_I_metadata_line_18_____2323232323 ro_Lab_210_5Y_1.00 >									
//        < Z1P3AR8Rq3R5XG2R5p4aQ2qOd6TN6u14y5KffZ89He5t7agU49fZfp73YmItnX3p >									
//        <  u =="0.000000000000000001" : ] 000001833482146.393340000000000000 ; 000001851722546.956980000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000AEDABF7B09811F >									
//     < NDD_SPX_I_metadata_line_19_____2323232323 ro_Lab_210_5Y_1.10 >									
//        < 7iUtUBWi99Qol5zYFxlfl2b40pQ6dtKh397L0763P3unGsD7nMh77M38FG6gZ2gk >									
//        <  u =="0.000000000000000001" : ] 000001851722546.956980000000000000 ; 000001866598713.820710000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000B09811FB20341F >									
//     < NDD_SPX_I_metadata_line_20_____2323232323 ro_Lab_210_7Y_1.00 >									
//        < 6cV3Zly1Bg4xI688IW3XQB28fJDX6D8qjl6zNhNxwZ28fMl5m4b4Z1e1Qj24a337 >									
//        <  u =="0.000000000000000001" : ] 000001866598713.820710000000000000 ; 000001876598713.820710000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000B20341FB2F765F >									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
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
//     < NDD_SPX_I_metadata_line_21_____2305763456 ro_Lab_310_3Y_1.00 >									
//        < g2PxU9HLLgYP3VyNPqQTL5S5z16Ok5ar4FlDUGKwlQt295Bw70TJv9X3GHN2CuJH >									
//        <  u =="0.000000000000000001" : ] 000001876598713.820710000000000000 ; 000001888925983.797500000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000B2F765FB4245B6 >									
//     < NDD_SPX_I_metadata_line_22_____2386953858 ro_Lab_310_5Y_1.00 >									
//        < 2kb81FIR0KaqE44ZVD3iiiPVWT817xkG72pwrYE5T5rn3iZu3uISu2HT1C952i94 >									
//        <  u =="0.000000000000000001" : ] 000001888925983.797500000000000000 ; 000001915024303.586160000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000B4245B6B6A185E >									
//     < NDD_SPX_I_metadata_line_23_____2389867115 ro_Lab_310_5Y_1.10 >									
//        < W60540S3V6M2BIa73qFmg3BAfhzI3P068wZg5k9xRA3DqN8SJ61d4l8681K5D6ud >									
//        <  u =="0.000000000000000001" : ] 000001915024303.586160000000000000 ; 000001933622766.749710000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000B6A185EB867965 >									
//     < NDD_SPX_I_metadata_line_24_____2399639697 ro_Lab_310_7Y_1.00 >									
//        < 8dhe83x2TXrDSkdH32mbemjhH07w3q7T93LvT887thtE9NdL1vXs7E2bW7SnK6n3 >									
//        <  u =="0.000000000000000001" : ] 000001933622766.749710000000000000 ; 000001943622766.749710000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000B867965B95BBA5 >									
//     < NDD_SPX_I_metadata_line_25_____2367732810 ro_Lab_410_3Y_1.00 >									
//        < n37tQU13178iF6Xng6fw35n3G5Jn8isz7cG8ud9iI51mQ864Ffl6ixy1Jerh00Y9 >									
//        <  u =="0.000000000000000001" : ] 000001943622766.749710000000000000 ; 000001956712997.477070000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000B95BBA5BA9B504 >									
//     < NDD_SPX_I_metadata_line_26_____2387485114 ro_Lab_410_5Y_1.00 >									
//        < p3vfXAK35wB6EdtPw27n2lSSJm2EVIb58dH3n9P4YzoT2uD6WHpFlEJ1hTIbKcR2 >									
//        <  u =="0.000000000000000001" : ] 000001956712997.477070000000000000 ; 000001995674934.027550000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000BA9B504BE52885 >									
//     < NDD_SPX_I_metadata_line_27_____2386159977 ro_Lab_410_5Y_1.10 >									
//        < kpETOM7xiB9QTWeJ8QUz45nOFVzjbTzn92GYJWBYC0Fke088H0oGl3b5mhfq59w4 >									
//        <  u =="0.000000000000000001" : ] 000001995674934.027550000000000000 ; 000002020388119.697410000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000BE52885C0ADE1C >									
//     < NDD_SPX_I_metadata_line_28_____2390392184 ro_Lab_410_7Y_1.00 >									
//        < 77z1l9IrnQ3PZrs6ZXDDbuwSmBfOYHt0LkhpG20w5cohcZcI55XC9T8SPzm3DZz4 >									
//        <  u =="0.000000000000000001" : ] 000002020388119.697410000000000000 ; 000002030388119.697410000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000C0ADE1CC1A205C >									
//     < NDD_SPX_I_metadata_line_29_____2323232323 ro_Lab_810_3Y_1.00 >									
//        < e48u9rWS6057fS5qU3yXt837G15AXMhA0x0E7z7DELaO35Mfx5ztsA0P3q55i8KJ >									
//        <  u =="0.000000000000000001" : ] 000002030388119.697410000000000000 ; 000002048404496.772020000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000C1A205CC359E02 >									
//     < NDD_SPX_I_metadata_line_30_____2323232323 ro_Lab_810_5Y_1.00 >									
//        < 673DQYCv19DvOX9q7C5kuK83XvHinjPNs314j7EogF4ngg97BDmzgn1pENWE9E8M >									
//        <  u =="0.000000000000000001" : ] 000002048404496.772020000000000000 ; 000002237130126.925030000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000C359E02D5596F5 >									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
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
//     < NDD_SPX_I_metadata_line_31_____2322765647 ro_Lab_810_5Y_1.10 >									
//        < 8kCHNw2N1V4LIda7zb43Sf7OhO8GCLg7104RRIvqQWxhsETyIuLSedIwfu1qU4PB >									
//        <  u =="0.000000000000000001" : ] 000002237130126.925030000000000000 ; 000002333204858.076410000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000D5596F5DE83026 >									
//     < NDD_SPX_I_metadata_line_32_____2375382333 ro_Lab_810_7Y_1.00 >									
//        < ma5Fq9SEjta1pLYs4qfDG2o21ehdB11aJOom07JHt90LgeHa7h0d3gTanc9P7sJA >									
//        <  u =="0.000000000000000001" : ] 000002333204858.076410000000000000 ; 000002343204858.076410000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000DE83026DF77266 >									
//     < NDD_SPX_I_metadata_line_33_____2330200609 ro_Lab_411_3Y_1.00 >									
//        < 36Wk0Hbxn5629rPMx809W904l01vdsLkEBHIy22e3hwFM088kK3Uux9e5LZymz76 >									
//        <  u =="0.000000000000000001" : ] 000002343204858.076410000000000000 ; 000002362257282.936790000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000DF77266E1484C0 >									
//     < NDD_SPX_I_metadata_line_34_____2383528591 ro_Lab_411_5Y_1.00 >									
//        < 6N6882MazgAipst86g96C31s4NIUGkTc93sXPf2fn7GFO7b1e9X5t6wrb022Q3z8 >									
//        <  u =="0.000000000000000001" : ] 000002362257282.936790000000000000 ; 000002456469195.248640000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000E1484C0EA44648 >									
//     < NDD_SPX_I_metadata_line_35_____1199662128 ro_Lab_411_5Y_1.10 >									
//        < 2yvMu0MVnvZe950TEU43Ee2wGa4ZMgz8vzpYaGN2O0393A8c1ighoO77Jcp5z0gJ >									
//        <  u =="0.000000000000000001" : ] 000002456469195.248640000000000000 ; 000002507511516.385670000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000EA44648EF228B0 >									
//     < NDD_SPX_I_metadata_line_36_____2325334377 ro_Lab_411_7Y_1.00 >									
//        < nv6uXl1M4OFH0D9FqMkixb4zRjLMK7V1325STPWz92qZZagj0S7Rel2jWrYusiga >									
//        <  u =="0.000000000000000001" : ] 000002507511516.385670000000000000 ; 000004269111394.580050000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000EF228B0197225A3 >									
//     < NDD_SPX_I_metadata_line_37_____1183934058 ro_Lab_811_3Y_1.00 >									
//        < 82KxrxffCbguVr2M0o1BJdXzc7102npGxDw3BHqIZkw7806wSeaqw7u1CMz4k2bT >									
//        <  u =="0.000000000000000001" : ] 000004269111394.580050000000000000 ; 000004311973261.674480000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000197225A319B38C8E >									
//     < NDD_SPX_I_metadata_line_38_____1106327918 ro_Lab_811_5Y_1.00 >									
//        < y0lDOONnMjeoh2N63kJa7qLhAW8Qy0a21kOTC6QUVs9TxK7BswQ7ErjlOjlgV98P >									
//        <  u =="0.000000000000000001" : ] 000004311973261.674480000000000000 ; 000005087866394.968000000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000019B38C8E1E5377CF >									
//     < NDD_SPX_I_metadata_line_39_____1075263785 ro_Lab_811_5Y_1.10 >									
//        < MKc9d0764G8g1hBot45jo8dnKy0FhHGtz673HbU9h47t24WCz7uUxt7a35x2Gt5E >									
//        <  u =="0.000000000000000001" : ] 000005087866394.968000000000000000 ; 000005462918785.859100000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000001E5377CF208FC0A7 >									
//     < NDD_SPX_I_metadata_line_40_____2323232323 ro_Lab_811_7Y_1.00 >									
//        < 3qkUWBNC6TQa0760Hwr7IoF4arF8u00T5bQK26jlfSYtBXOyltSQ2x8tlFN53ROJ >									
//        <  u =="0.000000000000000001" : ] 000005462918785.859100000000000000 ; 000042919915474.153900000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000208FC0A7FFD297FB >									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
}