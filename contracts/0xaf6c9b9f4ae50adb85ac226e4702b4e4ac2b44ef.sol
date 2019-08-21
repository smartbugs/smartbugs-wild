pragma solidity 		^0.4.21	;						
										
	contract	NDD_PAL_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDD_PAL_I_883		"	;
		string	public		symbol =	"	NDD_PAL_I_1subDT		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		192808679821221000000000000000					;	
										
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
	//     < NDD_PAL_I_metadata_line_1_____6938413225 Lab_x >									
	//        < xLxlZ5XGROm4xn1MjzKOVAnbW6skMJ11rl23xjRQqXj8i66ivyRJx20lgbFIB00T >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000000F4240 >									
	//     < NDD_PAL_I_metadata_line_2_____9781285179 Lab_y >									
	//        < 2gSjuE903f0a67E0TN182HS7NdnFCaUj6q7BiHRjU7jJMr2ng2fNzV4y9HTM43Wh >									
	//        <  u =="0.000000000000000001" : ] 000000010000000.000000000000000000 ; 000000020000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000F42401E8480 >									
	//     < NDD_PAL_I_metadata_line_3_____2397950323 Lab_100 >									
	//        < omWX5z54O5quqn20CW13oBz1fzJ87oY45Fp971rE0Thsrqup1eV56x39jVmSY8XD >									
	//        <  u =="0.000000000000000001" : ] 000000020000000.000000000000000000 ; 000000031114580.020562500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001E84802F7A22 >									
	//     < NDD_PAL_I_metadata_line_4_____2373453588 Lab_110 >									
	//        < 9zTpNMh43uygFJpXME414o6DKVUfW3s195M61vXJ5n10IdsyI7398KJfPZi8afZM >									
	//        <  u =="0.000000000000000001" : ] 000000031114580.020562500000000000 ; 000000043700757.839436700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002F7A2242AE9C >									
	//     < NDD_PAL_I_metadata_line_5_____1109592496 Lab_410/401 >									
	//        < b3gu6ov3zQQ754K7nJyl7P22Z5AJ2d25O6Bv4hl9jeXnQ2Cd8Ee4nJ1kuWG129nq >									
	//        <  u =="0.000000000000000001" : ] 000000043700757.839436700000000000 ; 000000064045469.114933800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000042AE9C61B9C3 >									
	//     < NDD_PAL_I_metadata_line_6_____1006816073 Lab_810/801 >									
	//        < ftAz9u5ZTcU2O7GpXVWA5dOD71NsrYhRC9b0n5B73D2zJuwjyTRp4ZLNkKN31to5 >									
	//        <  u =="0.000000000000000001" : ] 000000064045469.114933800000000000 ; 000000094734891.665928000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000061B9C3908DD1 >									
	//     < NDD_PAL_I_metadata_line_7_____2388401131 Lab_410_3Y1Y >									
	//        < yO3ykAWA5sggf9rOnbNA3rcq5gp7sOI9C15BJnbp9xiHPSD7nt55ZJE9u58hf32C >									
	//        <  u =="0.000000000000000001" : ] 000000094734891.665928000000000000 ; 000000152021163.096708000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000908DD1E7F744 >									
	//     < NDD_PAL_I_metadata_line_8_____2345069038 Lab_410_5Y1Y >									
	//        < 6PlN0Pn5Wc0m0952seu6YPeqD66kHpq30ZzBQ19861e732P35q9Xi8r0I8NQtZ1k >									
	//        <  u =="0.000000000000000001" : ] 000000152021163.096708000000000000 ; 000000375048666.110444000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E7F74423C4763 >									
	//     < NDD_PAL_I_metadata_line_9_____2337203900 Lab_410_7Y1Y >									
	//        < W28vyNqzK1HCs062rnPLGW3zi0q8vKe238XAF14iZMlwzjbfi4CRG87olu3gZgxs >									
	//        <  u =="0.000000000000000001" : ] 000000375048666.110444000000000000 ; 000001638102332.434830000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023C47639C38BB9 >									
	//     < NDD_PAL_I_metadata_line_10_____1167907986 Lab_810_3Y1Y >									
	//        < 6n4jfhCId3WEU33vKHFY6sX0yb8p90jEQ42g4fD29t55902y88m71guwubE97aw8 >									
	//        <  u =="0.000000000000000001" : ] 000001638102332.434830000000000000 ; 000001762637841.868660000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009C38BB9A819268 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_PAL_I_metadata_line_11_____2331073380 Lab_810_5Y1Y >									
	//        < 0Xm56FZh9zz93W706LeS10Kz2VmU8FjPhHAIia9zELHowyG5H156u8j79Ji621Yv >									
	//        <  u =="0.000000000000000001" : ] 000001762637841.868660000000000000 ; 000003255191489.370860000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000A8192681367072D >									
	//     < NDD_PAL_I_metadata_line_12_____2389358431 Lab_810_7Y1Y >									
	//        < a204kf6d9hCQ363wN1xmo5nmmc4yT43yw8SQUitY326j8fzQlfUPbNM1uF453X39 >									
	//        <  u =="0.000000000000000001" : ] 000003255191489.370860000000000000 ; 000016334242382.218200000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000001367072D615C136E >									
	//     < NDD_PAL_I_metadata_line_13_____2323232323 ro_Lab_110_3Y_1.00 >									
	//        < OcVOyh44sA975Ibz00LA473IeVar3guD8D6W1Tb7J9tDgUK8JXBKcHXQM3GOOXZU >									
	//        <  u =="0.000000000000000001" : ] 000016334242382.218200000000000000 ; 000016358288937.519000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000615C136E6180C49E >									
	//     < NDD_PAL_I_metadata_line_14_____2323232323 ro_Lab_110_5Y_1.00 >									
	//        < eJ28w5sPnZ6irL5GnVt3KUqU5C286213SX8dtKjz94RJ2l3X9vI19927yAYLDQ8s >									
	//        <  u =="0.000000000000000001" : ] 000016358288937.519000000000000000 ; 000016392006529.246700000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000006180C49E61B4378D >									
	//     < NDD_PAL_I_metadata_line_15_____2323232323 ro_Lab_110_5Y_1.10 >									
	//        < 126MZg5e188CIC0rursXSPo5eO8O297X3jyx9C3AjNwH58385d83vJ4K18k86GJb >									
	//        <  u =="0.000000000000000001" : ] 000016392006529.246700000000000000 ; 000016426687292.730500000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000061B4378D61E922B9 >									
	//     < NDD_PAL_I_metadata_line_16_____2323232323 ro_Lab_110_7Y_1.00 >									
	//        < 5TeScTXf311K1t6qV6a0DJmVk4iM9V3mWM47310S5vd4xog8TAE482m51Dk5HLNa >									
	//        <  u =="0.000000000000000001" : ] 000016426687292.730500000000000000 ; 000016479495558.693100000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000061E922B96239B6F4 >									
	//     < NDD_PAL_I_metadata_line_17_____2323232323 ro_Lab_210_3Y_1.00 >									
	//        < yyrVbxcYog2sBLI6rf74g58a8930X36jGf4I4Wu8FyOj9nL1u2Q3vm16254Je7t8 >									
	//        <  u =="0.000000000000000001" : ] 000016479495558.693100000000000000 ; 000016491674763.265900000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000006239B6F4624C4C74 >									
	//     < NDD_PAL_I_metadata_line_18_____2323232323 ro_Lab_210_5Y_1.00 >									
	//        < x8g14adent9qV800PGcA71l0QgCu4Vt82d1996P5J62hZuvkE5ESOjDtH6enz871 >									
	//        <  u =="0.000000000000000001" : ] 000016491674763.265900000000000000 ; 000016510536483.256600000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000624C4C7462691450 >									
	//     < NDD_PAL_I_metadata_line_19_____2323232323 ro_Lab_210_5Y_1.10 >									
	//        < w6Xw548x6UV00LQlGAff87j00yR60vmkAbZrMzO6Ql96hKL4XUMf5qtSFdpg27I2 >									
	//        <  u =="0.000000000000000001" : ] 000016510536483.256600000000000000 ; 000016525706343.244300000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000006269145062803A0A >									
	//     < NDD_PAL_I_metadata_line_20_____2323232323 ro_Lab_210_7Y_1.00 >									
	//        < GcSzwp0ol0U372Eayg6gM00t064tDbdyR57UHOd0jdQTOyuxr7ZGXIkiiP4ROXH0 >									
	//        <  u =="0.000000000000000001" : ] 000016525706343.244300000000000000 ; 000016572807692.783300000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000062803A0A62C81901 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_PAL_I_metadata_line_21_____2386281206 ro_Lab_310_3Y_1.00 >									
	//        < OxZ830GJf412yHCI03iHFDrIss60fQUU5dLb5Gn1RMy5isy3dX3v71Izoepvb1P6 >									
	//        <  u =="0.000000000000000001" : ] 000016572807692.783300000000000000 ; 000016586044100.752000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000062C8190162DC4B7A >									
	//     < NDD_PAL_I_metadata_line_22_____2334594893 ro_Lab_310_5Y_1.00 >									
	//        < U7S27VAgd17sz1KT6PY59KokQc591t0SdNr89639Y19Pec7x09xtqBKE190sCB5w >									
	//        <  u =="0.000000000000000001" : ] 000016586044100.752000000000000000 ; 000016613739265.111700000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000062DC4B7A63068DE7 >									
	//     < NDD_PAL_I_metadata_line_23_____2346942038 ro_Lab_310_5Y_1.10 >									
	//        < L0d23gHWRRfH8jd97tCuGSPzP5F92j7G7x3b832Q55ca9Igk798xjfHrK45226Vx >									
	//        <  u =="0.000000000000000001" : ] 000016613739265.111700000000000000 ; 000016633095740.467100000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000063068DE763241706 >									
	//     < NDD_PAL_I_metadata_line_24_____2323232323 ro_Lab_310_7Y_1.00 >									
	//        < 4tfCbEHjr61zDkbENCa5eL49tOceeA4zm3p7HuF5uG0g7Wd24uKdg5I0TLYD21fo >									
	//        <  u =="0.000000000000000001" : ] 000016633095740.467100000000000000 ; 000016749162876.058800000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000006324170663D531C0 >									
	//     < NDD_PAL_I_metadata_line_25_____2323232323 ro_Lab_410_3Y_1.00 >									
	//        < 7KlIT6o5fbNUx1hdAv2U1g9JcJhP9Y6cfoCAN1pwKW3KHm85Eyp1fq6L91GI25hC >									
	//        <  u =="0.000000000000000001" : ] 000016749162876.058800000000000000 ; 000016763750027.081500000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000063D531C063EB73DB >									
	//     < NDD_PAL_I_metadata_line_26_____2323232323 ro_Lab_410_5Y_1.00 >									
	//        < v85K922fsckvdq0x9efbD6xTu0i9MdFv418C02DF76U594i2kQgC2egLF55luHx2 >									
	//        <  u =="0.000000000000000001" : ] 000016763750027.081500000000000000 ; 000016806122651.903400000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000063EB73DB642C1BA9 >									
	//     < NDD_PAL_I_metadata_line_27_____2323232323 ro_Lab_410_5Y_1.10 >									
	//        < ghmSf57nS4BP34qjph0ybr5tW5c88e6G0kh2tHWQPVq6ojrHb78IrAWv8Z78Tz56 >									
	//        <  u =="0.000000000000000001" : ] 000016806122651.903400000000000000 ; 000016832459350.128100000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000642C1BA964544B6F >									
	//     < NDD_PAL_I_metadata_line_28_____2323232323 ro_Lab_410_7Y_1.00 >									
	//        < LB95Tgn5k8ka8m2ez2F47pYX9BnnbkpB370k6SIVwEcDd46dLF85EO7vq4u0Yow4 >									
	//        <  u =="0.000000000000000001" : ] 000016832459350.128100000000000000 ; 000017105494234.800800000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000064544B6F65F4E9AF >									
	//     < NDD_PAL_I_metadata_line_29_____2323232323 ro_Lab_810_3Y_1.00 >									
	//        < 8j3V8ipnQkI101o63xs2Ufl5un4Z4euc0LHury01190JKShF1AO4136Ngvm8heAu >									
	//        <  u =="0.000000000000000001" : ] 000017105494234.800800000000000000 ; 000017125409911.068100000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000065F4E9AF66134D3F >									
	//     < NDD_PAL_I_metadata_line_30_____2323232323 ro_Lab_810_5Y_1.00 >									
	//        < d90Qx0q99kKM77dTAjgW6FbW8qR2yz9L2zvueHJES9G27L89np9cokC2vp901gy7 >									
	//        <  u =="0.000000000000000001" : ] 000017125409911.068100000000000000 ; 000017343546532.585900000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000066134D3F676026DD >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_PAL_I_metadata_line_31_____2323232323 ro_Lab_810_5Y_1.10 >									
	//        < mr8LI9BUD1ANI3Sr1lYw8h3npJYX5f9kT1BU46vV2pz3Pc4rZl7eq8EsebT4u798 >									
	//        <  u =="0.000000000000000001" : ] 000017343546532.585900000000000000 ; 000017453624441.963000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000676026DD68081E0C >									
	//     < NDD_PAL_I_metadata_line_32_____2323232323 ro_Lab_810_7Y_1.00 >									
	//        < fvRpROm8sR7cbj121Ii6Lid29V32Y2qKs9Rm556Z1u67LmnT51O54Cm6ZK1st0Rf >									
	//        <  u =="0.000000000000000001" : ] 000017453624441.963000000000000000 ; 000020035436752.104800000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000068081E0C776BA67B >									
	//     < NDD_PAL_I_metadata_line_33_____2323232323 ro_Lab_411_3Y_1.00 >									
	//        < wVV9GqJRz1M525kp3IFDz37M7fL8Dp3046Nhn86Xry8Lit356564ob52phaeE7yC >									
	//        <  u =="0.000000000000000001" : ] 000020035436752.104800000000000000 ; 000020060515209.821800000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000776BA67B7791EAC1 >									
	//     < NDD_PAL_I_metadata_line_34_____2323232323 ro_Lab_411_5Y_1.00 >									
	//        < 2RsC3mOj5hN5983YCf13W8g1a2CdRozlYpHxqjYld8law3178qqm9pFj7Hl5cDHD >									
	//        <  u =="0.000000000000000001" : ] 000020060515209.821800000000000000 ; 000020349181139.697500000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000007791EAC1794A62E2 >									
	//     < NDD_PAL_I_metadata_line_35_____2323232323 ro_Lab_411_5Y_1.10 >									
	//        < 0hXW8yX15s3f2W5hxk1d6QR9kYG22b3B336Y6bP5aES7uIsrc12Mb1eYrZxCA546 >									
	//        <  u =="0.000000000000000001" : ] 000020349181139.697500000000000000 ; 000020492821758.251500000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000794A62E27A259080 >									
	//     < NDD_PAL_I_metadata_line_36_____2323232323 ro_Lab_411_7Y_1.00 >									
	//        < 0M59VCYjx00rRBYjH1yMMBQ0UF4uqizTmTSt89MPExs4K6A6WW8Zz8a20Is4m8g3 >									
	//        <  u =="0.000000000000000001" : ] 000020492821758.251500000000000000 ; 000028992267584.068000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000007A259080ACCEB086 >									
	//     < NDD_PAL_I_metadata_line_37_____2323232323 ro_Lab_811_3Y_1.00 >									
	//        < T3vBa7N6jR825Vtl5yJTAjTVFiCrwWKOw2KaGYZsOSdaN6cwlazIlMYC7zLJBSMS >									
	//        <  u =="0.000000000000000001" : ] 000028992267584.068000000000000000 ; 000029073279921.202200000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000ACCEB086AD4A4DF8 >									
	//     < NDD_PAL_I_metadata_line_38_____2323232323 ro_Lab_811_5Y_1.00 >									
	//        < kgGjNk00mMSEiRkl5Ex6jW5Rtt9wtl7q39Mnm6uauEmmzF5v9VT2x9b09Q4lxbiU >									
	//        <  u =="0.000000000000000001" : ] 000029073279921.202200000000000000 ; 000032003940517.838900000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000AD4A4DF8BEC22344 >									
	//     < NDD_PAL_I_metadata_line_39_____2323232323 ro_Lab_811_5Y_1.10 >									
	//        < 2O7EBc8KVaF0Rk0ytTi6AAw4DR7Wa003fEF1Zgo9KB42MrbDmqA2MYC3Lm3h8o5j >									
	//        <  u =="0.000000000000000001" : ] 000032003940517.838900000000000000 ; 000033399074258.393300000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000BEC22344C712F162 >									
	//     < NDD_PAL_I_metadata_line_40_____2323232323 ro_Lab_811_7Y_1.00 >									
	//        < DUiq4BLMZz7xU04806G8W0rU8k89kpb97YzVd1eoA6NaF9STj0J4MiECYVLB111m >									
	//        <  u =="0.000000000000000001" : ] 000033399074258.393300000000000000 ; 000192808679821.221000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000C712F16247D3AB28E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}