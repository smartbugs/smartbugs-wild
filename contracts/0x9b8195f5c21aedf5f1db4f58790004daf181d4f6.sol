pragma solidity 		^0.4.21	;						
										
	contract	AZOV_PFII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	AZOV_PFII_II_883		"	;
		string	public		symbol =	"	AZOV_PFII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1111554565905540000000000000					;	
										
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
	//     < AZOV_PFII_II_metadata_line_1_____Td_Yug_Rusi_20231101 >									
	//        < Y7ylR6COm2MgQ0H7542JG8V6zaXiPU9zpyi5G187CNIf0I3Wur7sD5R03rWf20qS >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000024232775.969419900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000024F9EE >									
	//     < AZOV_PFII_II_metadata_line_2_____LLC_MEZ_Yug_Rusi_20231101 >									
	//        < KQy6oX22982IUbkX7OR6T46sq54m3dd2h1RXgmKe7rbH1fY5S4CXnMWmwulx2nXv >									
	//        <  u =="0.000000000000000001" : ] 000000024232775.969419900000000000 ; 000000051122495.647172400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000024F9EE4E01BA >									
	//     < AZOV_PFII_II_metadata_line_3_____savola_foods_cis_20231101 >									
	//        < 3t5c6FoIJ3qhnQD2kHqvVDIW2BuZDa4756ojX5w99z6Eb4DFeSiyIxLtPcO80lbp >									
	//        <  u =="0.000000000000000001" : ] 000000051122495.647172400000000000 ; 000000070037722.060565600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004E01BA6ADE7C >									
	//     < AZOV_PFII_II_metadata_line_4_____labinsky_cannery_20231101 >									
	//        < 0vY479B1821uZsh72vpLPArdsjG68cfDvEWNSfp38023kp975Mmwg9TsqCLijHLM >									
	//        <  u =="0.000000000000000001" : ] 000000070037722.060565600000000000 ; 000000099705006.618981900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006ADE7C982345 >									
	//     < AZOV_PFII_II_metadata_line_5_____jsc_chernyansky_vegetable_oil_plant_20231101 >									
	//        < 56GK59rRWDCr5gRhR5L28sP0C93EMErDIX2h0oP8HA4AoG89mFm9s8796dYpG07B >									
	//        <  u =="0.000000000000000001" : ] 000000099705006.618981900000000000 ; 000000121779170.746487000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000982345B9D1FD >									
	//     < AZOV_PFII_II_metadata_line_6_____urazovsky_elevator_jsc_20231101 >									
	//        < 5damdpE9u7afsDXEu3QcN21oZ512MqG6fZYslGp7T77227t8KzH4Lgn9391NgAj1 >									
	//        <  u =="0.000000000000000001" : ] 000000121779170.746487000000000000 ; 000000166898839.740828000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B9D1FDFEAADC >									
	//     < AZOV_PFII_II_metadata_line_7_____ooo_orskmelprom_20231101 >									
	//        < my6KzLbr1hVL736Lm152siHrE351o9sMfHB1N8RcR0Il04WnFQ1BS2XK2eNa48Tk >									
	//        <  u =="0.000000000000000001" : ] 000000166898839.740828000000000000 ; 000000189092641.806765000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FEAADC1208850 >									
	//     < AZOV_PFII_II_metadata_line_8_____zolotaya_semechka_ooo_20231101 >									
	//        < 2Qx8hG3Bai64j96xak3GX3i8fD0zh46JtcpuyttPKV9y7ord767fFFa22P3g3Szn >									
	//        <  u =="0.000000000000000001" : ] 000000189092641.806765000000000000 ; 000000231393161.966597000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000120885016113F4 >									
	//     < AZOV_PFII_II_metadata_line_9_____ooo_grain_union_20231101 >									
	//        < 4NBLzJUe34Hd1PBJdb0767UL7u3ROcnSB7nQBvuNI5B0pp021iizAo6G0pqo4wBh >									
	//        <  u =="0.000000000000000001" : ] 000000231393161.966597000000000000 ; 000000263324892.516756000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016113F4191CD49 >									
	//     < AZOV_PFII_II_metadata_line_10_____valuysky_vegetable_oil_plant_20231101 >									
	//        < 8JWCAmm4U1zp7j8nj1qf8T01wdH7vDV9sFRid9FmKOO6Dmy9zEe0gXwV82WUhthv >									
	//        <  u =="0.000000000000000001" : ] 000000263324892.516756000000000000 ; 000000285085961.767028000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000191CD491B301B4 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < AZOV_PFII_II_metadata_line_11_____ooo_yugagro_leasing_20231101 >									
	//        < 1U0K9Hdwe1DjOg7A88J46NDFVHiMe8l8vSJ57zGaHB989Y7S8Gdj893KWYowpznf >									
	//        <  u =="0.000000000000000001" : ] 000000285085961.767028000000000000 ; 000000318913690.571486000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B301B41E69FA9 >									
	//     < AZOV_PFII_II_metadata_line_12_____torgovy_dom_yug_rusi_ooo_20231101 >									
	//        < j3gW9VA1WQ43Vm96Hmec8bzHZH2l68YGH59Hu8bPiigCl488jOX47mQhc2j1wMAn >									
	//        <  u =="0.000000000000000001" : ] 000000318913690.571486000000000000 ; 000000343595476.674746000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E69FA920C48FC >									
	//     < AZOV_PFII_II_metadata_line_13_____trading_house_wj_cis_20231101 >									
	//        < LYmas41AqxZA1wG94rSd5GFd6IzR1EGdxie766eRl67Dh6eZ4uJp4P4M51sf13NJ >									
	//        <  u =="0.000000000000000001" : ] 000000343595476.674746000000000000 ; 000000385654612.006987000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020C48FC24C7655 >									
	//     < AZOV_PFII_II_metadata_line_14_____ojsc_tselinkhlebprodukt_20231101 >									
	//        < WWCPf8z64NeEETNVd5gqTA8Bn65fcOL1L1jLS9R4g6JlA4z9B8m043MqGLGUAHTD >									
	//        <  u =="0.000000000000000001" : ] 000000385654612.006987000000000000 ; 000000407054220.126794000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024C765526D1D8E >									
	//     < AZOV_PFII_II_metadata_line_15_____ooo_orskaya_pasta_factory_20231101 >									
	//        < l77oKlF2oL45M2G4R8ULWqacI239Y9hH96936367N93gvN2KAod812eGt6Ntvyhj >									
	//        <  u =="0.000000000000000001" : ] 000000407054220.126794000000000000 ; 000000433589794.900725000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026D1D8E2959B03 >									
	//     < AZOV_PFII_II_metadata_line_16_____Azs Yug Rusi_20231101 >									
	//        < 4Cv9VlSxni9Qv02VcW1XV35Dim77rJZ78xpBnxpl86X3ZX131c27Ng4M2lm175wx >									
	//        <  u =="0.000000000000000001" : ] 000000433589794.900725000000000000 ; 000000475377999.349242000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002959B032D55E88 >									
	//     < AZOV_PFII_II_metadata_line_17_____Bina_grup_20231101 >									
	//        < ho95Jr6Y5AqvDl0UEp7r2Devdyg8lS7qfE6Ih04Ki6e65AcmXj6JTQY2s8Yn98Hn >									
	//        <  u =="0.000000000000000001" : ] 000000475377999.349242000000000000 ; 000000522031435.931234000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D55E8831C8E88 >									
	//     < AZOV_PFII_II_metadata_line_18_____BINA_INTEGRATED_TECHNOLOGY_SDN_BHD_20231101 >									
	//        < cGorZawlYkAB7Z9agU9wUSea1aG498k76JqKToU0lMX6B4B2M82OKPhm7m7iX80v >									
	//        <  u =="0.000000000000000001" : ] 000000522031435.931234000000000000 ; 000000544901026.850364000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031C8E8833F73F7 >									
	//     < AZOV_PFII_II_metadata_line_19_____BINA_INTEGRATED_INDUSTRIES_SDN_BHD_20231101 >									
	//        < topVDAa4al60cFD5u84OolD4zJq3R3e5S1h1YdFb3b5o8O43242Ru8DygF9vipS1 >									
	//        <  u =="0.000000000000000001" : ] 000000544901026.850364000000000000 ; 000000575515523.514171000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033F73F736E2AC0 >									
	//     < AZOV_PFII_II_metadata_line_20_____BINA_PAINT_MARKETING_SDN_BHD_20231101 >									
	//        < M36u7YNDJ22XmkRIyLg7d282DTIjuOM1OmMm566SKX8Y247PuPCUeQH97OB27J35 >									
	//        <  u =="0.000000000000000001" : ] 000000575515523.514171000000000000 ; 000000612463795.257609000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036E2AC03A68BAC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < AZOV_PFII_II_metadata_line_21_____Yevroplast_20231101 >									
	//        < 4DY65l6Gh6968o1uCVc1mX7VdsU2NX35A6XqLE2grRw737w8jq3W6d7F3sTIQ8q9 >									
	//        <  u =="0.000000000000000001" : ] 000000612463795.257609000000000000 ; 000000632891629.531270000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A68BAC3C5B74B >									
	//     < AZOV_PFII_II_metadata_line_22_____Grain_export_infrastructure_org_20231101 >									
	//        < oC7q7RoVbr7nnk46K3KalpCE5gn61lH65u1KuObewtwP0G116s0K872TMO5dkeoe >									
	//        <  u =="0.000000000000000001" : ] 000000632891629.531270000000000000 ; 000000664604067.477923000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C5B74B3F61AF7 >									
	//     < AZOV_PFII_II_metadata_line_23_____Kherson_Port_org_20231101 >									
	//        < OpypFV3JuzW274p06Of656zJ4B4Yo91KEpkAb6f01224t87zXQ9Z4NYm3Ot5a9I7 >									
	//        <  u =="0.000000000000000001" : ] 000000664604067.477923000000000000 ; 000000705493307.142781000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F61AF74347F53 >									
	//     < AZOV_PFII_II_metadata_line_24_____Donskoy_Tabak_20231101 >									
	//        < v1ecNw8NN19l087DaAV9m8WeIeX8Ppt1wdVY9eW7Snjq6OY3LDfqdHdc71Isel1y >									
	//        <  u =="0.000000000000000001" : ] 000000705493307.142781000000000000 ; 000000725393040.752823000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004347F53452DCA8 >									
	//     < AZOV_PFII_II_metadata_line_25_____Japan_Tobacco_International_20231101 >									
	//        < lfpeAmu6lnOn1ZftiIcIw660E4wuGv52d1B962t250t29206Hnlwv20G50R2lxjt >									
	//        <  u =="0.000000000000000001" : ] 000000725393040.752823000000000000 ; 000000744296703.140597000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000452DCA846FB4E6 >									
	//     < AZOV_PFII_II_metadata_line_26_____Akhra_2006_20231101 >									
	//        < 5R0RjcvtNXrd3b8uR45fmFWfM28M4wA01p4Rry563F6V52kClSLcQr0JRtH6766v >									
	//        <  u =="0.000000000000000001" : ] 000000744296703.140597000000000000 ; 000000791120657.435997000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046FB4E64B72782 >									
	//     < AZOV_PFII_II_metadata_line_27_____Sekap_SA_20231101 >									
	//        < l38Yyi032BE3h8cW6wQL1Cu3iUY5EyoZXH7m1iZ3RI4S6H336T2HBpvlXd8s38zE >									
	//        <  u =="0.000000000000000001" : ] 000000791120657.435997000000000000 ; 000000823741678.953094000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B727824E8EE18 >									
	//     < AZOV_PFII_II_metadata_line_28_____jt_international_korea_inc_20231101 >									
	//        < Gc8DKgjNe1V76WK7oWs6DQ60ecYOmrH04WpzYPyxD6ZR160W7QX6DdZj3v0ImUNz >									
	//        <  u =="0.000000000000000001" : ] 000000823741678.953094000000000000 ; 000000852975481.869905000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004E8EE18515898C >									
	//     < AZOV_PFII_II_metadata_line_29_____tanzania_cigarette_company_20231101 >									
	//        < 2p923g9u392215IG44C8gC2tQId88W0NdW6HQzA9N2v4ZL341hZ7iR73yJxHbhPf >									
	//        <  u =="0.000000000000000001" : ] 000000852975481.869905000000000000 ; 000000876090337.917131000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000515898C538CECA >									
	//     < AZOV_PFII_II_metadata_line_30_____jt_international_holding_bv_20231101 >									
	//        < kd1wCTzlJqWTatQ3r3W282fhEiLZ71i88zC42xe409a6916aPg2EC5V2Ouoa52cq >									
	//        <  u =="0.000000000000000001" : ] 000000876090337.917131000000000000 ; 000000897433997.953125000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000538CECA5596028 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < AZOV_PFII_II_metadata_line_31_____kannenberg_barker_hail_cotton_tabacos_ltda_20231101 >									
	//        < Vi8z6a325Wh0NIuvNap3kwkLY822CxvM2vVkvozgLf0oO47X915b68J4uw9L2CGJ >									
	//        <  u =="0.000000000000000001" : ] 000000897433997.953125000000000000 ; 000000922425833.339983000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000559602857F8297 >									
	//     < AZOV_PFII_II_metadata_line_32_____jt_international_iberia_sl_20231101 >									
	//        < axty1cGqPD4s3JUzI5o372dXlnxXz4r6j18pL1R8j5gmS7tbA5ofxg3mCwlI0e9Z >									
	//        <  u =="0.000000000000000001" : ] 000000922425833.339983000000000000 ; 000000947727031.708146000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000057F82975A61DDF >									
	//     < AZOV_PFII_II_metadata_line_33_____jt_international_company_netherlands_bv_20231101 >									
	//        < 6ud5vA7538Lv2ISAtyzqf5515f7F3EMKnZTtzz22N44N1kI8BjKVi9fzB0VGnBI3 >									
	//        <  u =="0.000000000000000001" : ] 000000947727031.708146000000000000 ; 000000965158615.773311000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005A61DDF5C0B716 >									
	//     < AZOV_PFII_II_metadata_line_34_____Gryson_nv_20231101 >									
	//        < TQhw0QV0mXK9L88jfT9AhJW7Ylx2qU0A8H4Ua9eL25qhDjm48EvCVYS30O0e56o4 >									
	//        <  u =="0.000000000000000001" : ] 000000965158615.773311000000000000 ; 000000981904477.217685000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005C0B7165DA4470 >									
	//     < AZOV_PFII_II_metadata_line_35_____duvanska_industrija_senta_20231101 >									
	//        < KC76vTnJl401Zc9ugtBU30gSsHldzd0V89A483dSqi8AZqrrbgk14c00Hc82Ao1r >									
	//        <  u =="0.000000000000000001" : ] 000000981904477.217685000000000000 ; 000001001442559.993730000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005DA44705F81480 >									
	//     < AZOV_PFII_II_metadata_line_36_____kannenberg_cia_ltda_20231101 >									
	//        < TLQ11ZX72S1sKUO04VU032NXOoLVD80a2Hj78nlCu825WxiWDSiB9TWQI7n0VJqZ >									
	//        <  u =="0.000000000000000001" : ] 000001001442559.993730000000000000 ; 000001017985328.534820000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005F814806115285 >									
	//     < AZOV_PFII_II_metadata_line_37_____jti_leaf_services_us_llc_20231101 >									
	//        < r1VY88TNRvXli0498B5T0KlY1942kk609q24ppEY1mD63IwLe6QnfxH6veJv8Ylw >									
	//        <  u =="0.000000000000000001" : ] 000001017985328.534820000000000000 ; 000001034115658.327840000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006115285629EF6E >									
	//     < AZOV_PFII_II_metadata_line_38_____cigarros_la_tabacalera_mexicana_sa_cv_20231101 >									
	//        < gelwsktRiPYw7My5sdsRuHZFo6JWK7KcZer76WP9S2j7tF421j9h0d0Yq7l58EqS >									
	//        <  u =="0.000000000000000001" : ] 000001034115658.327840000000000000 ; 000001050497903.964440000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000629EF6E642EEBE >									
	//     < AZOV_PFII_II_metadata_line_39_____jti_pars_pjsco_20231101 >									
	//        < pk6Ql060FNiR40QV0w9TAg0d8WU1IYR360b6Bb829lD4zMfNthyn9a9A58wx0Joz >									
	//        <  u =="0.000000000000000001" : ] 000001050497903.964440000000000000 ; 000001080725506.560070000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000642EEBE6710E67 >									
	//     < AZOV_PFII_II_metadata_line_40_____jti_uk_finance_limited_20231101 >									
	//        < 43iMZvXBdp25M9k03R0gGGKI63vtSP7HgzaXF7NMnVeVee9f3L855hsOF21Xvkl6 >									
	//        <  u =="0.000000000000000001" : ] 000001080725506.560070000000000000 ; 000001111554565.905540000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006710E676A01901 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}