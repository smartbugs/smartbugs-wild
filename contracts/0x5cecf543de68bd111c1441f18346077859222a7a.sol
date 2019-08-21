pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXVI_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXVI_I_883		"	;
		string	public		symbol =	"	RUSS_PFXXXVI_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		598028592051817000000000000					;	
										
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
	//     < RUSS_PFXXXVI_I_metadata_line_1_____ROSNEFT_20211101 >									
	//        < 6oOrwmf809Tqn0xA98D4GltDo4NS8wX80sLVeplSZu3HMS5Y83Mnu9DhGp0452WX >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000015430032.277590900000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000178B5B >									
	//     < RUSS_PFXXXVI_I_metadata_line_2_____ROSNEFT_GBP_20211101 >									
	//        < DL7GY0C8aMuj1qcUF0UJ5lv3TNjW20H5zD1275ln2I3Ys07iVb8CN654nsh5Gxz9 >									
	//        <  u =="0.000000000000000001" : ] 000000015430032.277590900000000000 ; 000000031633078.819096900000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000178B5B3044AC >									
	//     < RUSS_PFXXXVI_I_metadata_line_3_____ROSNEFT_USD_20211101 >									
	//        < LL0A15xY2jzkuYzNeRAo975R3C69y6Z1EAbmZJgJbr4H6uScWpK1K9A8Gzhr5251 >									
	//        <  u =="0.000000000000000001" : ] 000000031633078.819096900000000000 ; 000000045202749.867386900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003044AC44F953 >									
	//     < RUSS_PFXXXVI_I_metadata_line_4_____ROSNEFT_SA_CHF_20211101 >									
	//        < 0wfN15Up0REdyZwDh5LiTGbgci1IqDk8AEKg4f8uRj4v2Z2iT5mx480OHkzQk8eW >									
	//        <  u =="0.000000000000000001" : ] 000000045202749.867386900000000000 ; 000000061743402.683194000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000044F9535E3684 >									
	//     < RUSS_PFXXXVI_I_metadata_line_5_____ROSNEFT_GMBH_EUR_20211101 >									
	//        < VADx3HW4GI667Fi3ndC3a9k1O81858LpNl60338wkX67M2kv79SK0xlNvplcYbyj >									
	//        <  u =="0.000000000000000001" : ] 000000061743402.683194000000000000 ; 000000075543141.585860800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005E368473450A >									
	//     < RUSS_PFXXXVI_I_metadata_line_6_____BAIKALFINANSGRUP_20211101 >									
	//        < pZ4fUjXP0n4BMyO3NR8y6u4On5o61u72fosQ4Y2867Dt0BHKJo8o5U4utu496K42 >									
	//        <  u =="0.000000000000000001" : ] 000000075543141.585860800000000000 ; 000000088728803.259899800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000073450A8763B0 >									
	//     < RUSS_PFXXXVI_I_metadata_line_7_____BAIKAL_ORG_20211101 >									
	//        < eU4UQSGL8J5p2Q3XJ4WC69OH5PKhrMh3e1WP3wZOvyAosmD7hAPwEmPOV6Qac10o >									
	//        <  u =="0.000000000000000001" : ] 000000088728803.259899800000000000 ; 000000105979616.076433000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008763B0A1B64A >									
	//     < RUSS_PFXXXVI_I_metadata_line_8_____BAIKAL_AB_20211101 >									
	//        < 884M4umWkaB16gXeQcpn55jVbIt830H4AtaV1AfFqZa8B2n2Vent2K5El68D03u6 >									
	//        <  u =="0.000000000000000001" : ] 000000105979616.076433000000000000 ; 000000120946512.090898000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A1B64AB88CBB >									
	//     < RUSS_PFXXXVI_I_metadata_line_9_____BAIKAL_CHF_20211101 >									
	//        < sksWlrZ03yzryz8rt97ZQY84Y4TbSlLpx20Jn98c6dgTVOcwy2kX4n4NMTC5FQUF >									
	//        <  u =="0.000000000000000001" : ] 000000120946512.090898000000000000 ; 000000136552066.490448000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B88CBBD05CA7 >									
	//     < RUSS_PFXXXVI_I_metadata_line_10_____BAIKAL_BYR_20211101 >									
	//        < Mjcq9x3v1h58a7Ij4gLQik551gFLBaxGy959IVfuacTTsUI94Gqlav5av9X67wZs >									
	//        <  u =="0.000000000000000001" : ] 000000136552066.490448000000000000 ; 000000151514614.842168000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D05CA7E73165 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVI_I_metadata_line_11_____YUKOS_ABI_20211101 >									
	//        < yXfYk7x2JrL4n18jnE2Mb5YuF2of3WkAhRkt6nrNxY9crTU8Vkm6CHQ8T69r1M79 >									
	//        <  u =="0.000000000000000001" : ] 000000151514614.842168000000000000 ; 000000167892545.876698000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E731651002F07 >									
	//     < RUSS_PFXXXVI_I_metadata_line_12_____YUKOS_ABII_20211101 >									
	//        < kf241v8T6pvG08C6Llthw3kVBQtG93i8lE4m1kPS8r6by5S82BQRDhfVhXAepC6O >									
	//        <  u =="0.000000000000000001" : ] 000000167892545.876698000000000000 ; 000000183346723.427777000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001002F07117C3D0 >									
	//     < RUSS_PFXXXVI_I_metadata_line_13_____YUKOS_ABIII_20211101 >									
	//        < 8VsC5P4n6ef6BG546RzX2V04t4RCw3LBTS56PLBtHhx0sj480Idg776mCywD4AIk >									
	//        <  u =="0.000000000000000001" : ] 000000183346723.427777000000000000 ; 000000196850049.583184000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000117C3D012C5E8D >									
	//     < RUSS_PFXXXVI_I_metadata_line_14_____YUKOS_ABIV_20211101 >									
	//        < 6ERrEgpfDt1y6X17H78x99kkG6do6oP8y75dr19kZAhZHgQ5fOPGY6mk87F3W0nu >									
	//        <  u =="0.000000000000000001" : ] 000000196850049.583184000000000000 ; 000000213540595.883397000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012C5E8D145D64C >									
	//     < RUSS_PFXXXVI_I_metadata_line_15_____YUKOS_ABV_20211101 >									
	//        < GPf14b8oOavAwd2po3a5C6O6iR2BUOaOKGsg1eV80HDIQo4t28Rn5IXcv18Mzr3A >									
	//        <  u =="0.000000000000000001" : ] 000000213540595.883397000000000000 ; 000000227104931.112997000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000145D64C15A88DD >									
	//     < RUSS_PFXXXVI_I_metadata_line_16_____ROSNEFT_TRADE_LIMITED_20211101 >									
	//        < tsfEkgE5EodAh2mF3yIS09LbUQFqdnZ6sK3134W72KUC5HVJs1erx84qu3nuL9vC >									
	//        <  u =="0.000000000000000001" : ] 000000227104931.112997000000000000 ; 000000244303154.550124000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015A88DD174C6EB >									
	//     < RUSS_PFXXXVI_I_metadata_line_17_____NEFT_AKTIV_20211101 >									
	//        < 3b5h56cgV66rNv9OH218j2ls7oXzSzvrI2iZH52RgiXkq10d5LZQJDwJ86FRQya1 >									
	//        <  u =="0.000000000000000001" : ] 000000244303154.550124000000000000 ; 000000258505992.566003000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000174C6EB18A72E7 >									
	//     < RUSS_PFXXXVI_I_metadata_line_18_____ACHINSK_OIL_REFINERY_VNK_20211101 >									
	//        < ySVdpVOS0pzc82YVRrJ0PDAe1vdz4IC6kr76188RHDFG1kIYZ821QOt4243n02S9 >									
	//        <  u =="0.000000000000000001" : ] 000000258505992.566003000000000000 ; 000000272452109.233791000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018A72E719FBA9B >									
	//     < RUSS_PFXXXVI_I_metadata_line_19_____ROSPAN_INT_20211101 >									
	//        < JSs1en9u8jNWnL83Y20wDMUErU9910ru6DQm91Ha6O39XD9M6277tg09DJm7bt01 >									
	//        <  u =="0.000000000000000001" : ] 000000272452109.233791000000000000 ; 000000286577049.059721000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019FBA9B1B54829 >									
	//     < RUSS_PFXXXVI_I_metadata_line_20_____STROYTRANSGAZ_LIMITED_20211101 >									
	//        < SMwSmvi6y77e2c961xf5V6ie856C2ajP5yOJ31pXybujpxVjT56C3Ja0fc5Yp826 >									
	//        <  u =="0.000000000000000001" : ] 000000286577049.059721000000000000 ; 000000303235143.640260000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B548291CEB33A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVI_I_metadata_line_21_____ROSNEFT_LIMITED_20211101 >									
	//        < 25Q4L513r79XlnvXdvzB8KEE28KWc8324W52UN3TzKs34qE2TyBcQw9xn20N9dHL >									
	//        <  u =="0.000000000000000001" : ] 000000303235143.640260000000000000 ; 000000318178549.456692000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CEB33A1E5807F >									
	//     < RUSS_PFXXXVI_I_metadata_line_22_____TAIHU_LIMITED_20211101 >									
	//        < v22Mt59xMzlARu30Xp5q3tf9vqC29BU6b159C6ik54fPc9roUF1u5s0F0s43akXw >									
	//        <  u =="0.000000000000000001" : ] 000000318178549.456692000000000000 ; 000000333104658.008700000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E5807F1FC4702 >									
	//     < RUSS_PFXXXVI_I_metadata_line_23_____TAIHU_ORG_20211101 >									
	//        < NXc72w3AzxM3W8H5Lwybr8mLk6CF6ls4LRry8c23EZEm47QwXTI2384qve3B04h8 >									
	//        <  u =="0.000000000000000001" : ] 000000333104658.008700000000000000 ; 000000348878604.287521000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FC470221458B4 >									
	//     < RUSS_PFXXXVI_I_metadata_line_24_____EAST_SIBERIAN_GAS_CO_20211101 >									
	//        < u8432L8YbhAXjvyKkV2uv71UGa4Eth999Q3QUflw4f6PP1J6532z3aCe3OusYE89 >									
	//        <  u =="0.000000000000000001" : ] 000000348878604.287521000000000000 ; 000000362736487.275237000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021458B42297DF1 >									
	//     < RUSS_PFXXXVI_I_metadata_line_25_____RN_TUAPSINSKIY_NPZ_20211101 >									
	//        < 8haTsbPfm9PBWBI6oEEvrqspzONSep50F8X5ZS25d4j7j3bCRdk6HgYScsasrSTm >									
	//        <  u =="0.000000000000000001" : ] 000000362736487.275237000000000000 ; 000000376479024.042041000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002297DF123E761E >									
	//     < RUSS_PFXXXVI_I_metadata_line_26_____ROSPAN_ORG_20211101 >									
	//        < NEY6O5DSEj4lOFQ0TfQNxmP42KMnTuB3mp2msLbOCgXR109i3HiNyU3AV3G9458A >									
	//        <  u =="0.000000000000000001" : ] 000000376479024.042041000000000000 ; 000000390413200.596266000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023E761E253B928 >									
	//     < RUSS_PFXXXVI_I_metadata_line_27_____SYSRAN_20211101 >									
	//        < Q8U1sw4A4WK3l802uxs58QdONoR8fSQwaGvSeb9IXD0VJ0M7ihWKZ17UlL9w6d46 >									
	//        <  u =="0.000000000000000001" : ] 000000390413200.596266000000000000 ; 000000403824133.435252000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000253B9282682FCD >									
	//     < RUSS_PFXXXVI_I_metadata_line_28_____SYSRAN_ORG_20211101 >									
	//        < jhgcAEmdF7PKbR2gf300Kkpqv48xAHnHcy32OsrfVGsNB9P1wHFHE6Swkh9Cq8Ql >									
	//        <  u =="0.000000000000000001" : ] 000000403824133.435252000000000000 ; 000000419478805.902084000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002682FCD28012E9 >									
	//     < RUSS_PFXXXVI_I_metadata_line_29_____ARTAG_20211101 >									
	//        < 64435HxSev0E2w4tT1ik24x3RKKDHBkyCj88c90B90cXt9tz9hZrgn00cRMGFIZA >									
	//        <  u =="0.000000000000000001" : ] 000000419478805.902084000000000000 ; 000000434280673.257655000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028012E9296A8E3 >									
	//     < RUSS_PFXXXVI_I_metadata_line_30_____ARTAG_ORG_20211101 >									
	//        < 5DdW57E49c2L5A7erDVPbTC61gb42I6Juc2Ctx5XUBCaNP2IjT4eaGJ31R7IHhI6 >									
	//        <  u =="0.000000000000000001" : ] 000000434280673.257655000000000000 ; 000000449946478.506331000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000296A8E32AE9058 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVI_I_metadata_line_31_____RN_TUAPSE_REFINERY_LLC_20211101 >									
	//        < F1qo0fXUJ6066fona9B5Q3w0p4dW633Un1XUDB0FO18SZ79FkD91FYFUuvv9k86Q >									
	//        <  u =="0.000000000000000001" : ] 000000449946478.506331000000000000 ; 000000466641896.112142000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AE90582C809FE >									
	//     < RUSS_PFXXXVI_I_metadata_line_32_____TUAPSE_ORG_20211101 >									
	//        < HXjbA3s8m6hsqxE38631A46bhkW9081U8618i01517f73Xb9rG3Kn3VQS2cqpRNy >									
	//        <  u =="0.000000000000000001" : ] 000000466641896.112142000000000000 ; 000000480041609.093958000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C809FE2DC7C41 >									
	//     < RUSS_PFXXXVI_I_metadata_line_33_____NATIONAL_OIL_CONSORTIUM_20211101 >									
	//        < ofBkA2iKNI972IS5S1144j10g2cV1akoE2vlPOyemE2Gscrg36r0gMk86OC2BV4w >									
	//        <  u =="0.000000000000000001" : ] 000000480041609.093958000000000000 ; 000000494187512.406063000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DC7C412F211FF >									
	//     < RUSS_PFXXXVI_I_metadata_line_34_____RN_ASTRA_20211101 >									
	//        < 79403egtSnAN7hxw2v34Ajer1hQw0HwGf3Fb8UL2qIj8lY49vKF60PxsVev47bbG >									
	//        <  u =="0.000000000000000001" : ] 000000494187512.406063000000000000 ; 000000509539674.935424000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F211FF3097EEF >									
	//     < RUSS_PFXXXVI_I_metadata_line_35_____ASTRA_ORG_20211101 >									
	//        < 82DctXTOZnSuy3DlQYQ3kiYWJ36eDl8IGY476enit8GwmlSYAv6gb20PkvyyV7Sz >									
	//        <  u =="0.000000000000000001" : ] 000000509539674.935424000000000000 ; 000000526074476.867536000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003097EEF322B9D8 >									
	//     < RUSS_PFXXXVI_I_metadata_line_36_____ROSNEFT_DEUTSCHLAND_GMBH_20211101 >									
	//        < m4B8ce9MQ045cC7i5xYvjlTr7557lg3W4ZY7jJ98LwUtg3m6B0cfHP45n7Nk82e8 >									
	//        <  u =="0.000000000000000001" : ] 000000526074476.867536000000000000 ; 000000539117282.069232000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000322B9D8336A0B0 >									
	//     < RUSS_PFXXXVI_I_metadata_line_37_____ITERA_GROUP_LIMITED_20211101 >									
	//        < w2K2ZXFjOt917Dhhuu7j68dECISiM1N3p5Bkc5k63M16HE7g4tIWP0rd5x81m27W >									
	//        <  u =="0.000000000000000001" : ] 000000539117282.069232000000000000 ; 000000556012978.534754000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000336A0B03506892 >									
	//     < RUSS_PFXXXVI_I_metadata_line_38_____SAMOTLORNEFTEGAZ_20211101 >									
	//        < BFY7h0vNBQr3fbsf8FI670B37DP4BE6y63797k7A020x24FJYKR79Tn4ossHn6CW >									
	//        <  u =="0.000000000000000001" : ] 000000556012978.534754000000000000 ; 000000570029777.077363000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003506892365CBE2 >									
	//     < RUSS_PFXXXVI_I_metadata_line_39_____KUBANNEFTEPRODUCT_20211101 >									
	//        < fck36b3CZj5SVG34r490tM9RUm92811TUOBAS0L4sRdeyLzA84Tw4i4X5KIcZbz9 >									
	//        <  u =="0.000000000000000001" : ] 000000570029777.077363000000000000 ; 000000584686621.762641000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000365CBE237C2936 >									
	//     < RUSS_PFXXXVI_I_metadata_line_40_____KUBAN_ORG_20211101 >									
	//        < K2ADW5x1A48cahKdTklFzZDaJiVSXmbaYibJ911FgkUl3YtvVQnz3eG5BW7af650 >									
	//        <  u =="0.000000000000000001" : ] 000000584686621.762641000000000000 ; 000000598028592.051817000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037C293639084EB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}