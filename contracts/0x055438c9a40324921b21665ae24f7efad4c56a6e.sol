pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXVII_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXVII_I_883		"	;
		string	public		symbol =	"	RUSS_PFXXVII_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		599305625295470000000000000					;	
										
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
	//     < RUSS_PFXXVII_I_metadata_line_1_____SIBUR_20211101 >									
	//        < 8K9kSf1xGeTK7KPmVk67PMCjtnABtcuYjRf7egLYX0O15ipCo02w33X5ebZC7HjK >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000017257679.537300900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001A5548 >									
	//     < RUSS_PFXXVII_I_metadata_line_2_____SIBURTYUMENGAZ_20211101 >									
	//        < vE16vkfm4F6vz1Wc3tf1l62IEzA7V6H8OlC81Rlz0282l1Yh8sbiFcSn7IvljoU1 >									
	//        <  u =="0.000000000000000001" : ] 000000017257679.537300900000000000 ; 000000032353933.847403600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001A5548315E41 >									
	//     < RUSS_PFXXVII_I_metadata_line_3_____VOLGOPROMGAZ_GROUP_20211101 >									
	//        < T9T7V51Ly83DpPXFfm59brD7e957kLTCRWjwJmed1TLqf2JS7B0C0q87099AG1Qk >									
	//        <  u =="0.000000000000000001" : ] 000000032353933.847403600000000000 ; 000000047525316.440998000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000315E41488494 >									
	//     < RUSS_PFXXVII_I_metadata_line_4_____KSTOVO_20211101 >									
	//        < i5uw584vxUl6gGDvR2D3Hua09y4MLClsrQatUdvYv9DL69Bxmp9UcABRv28xC24r >									
	//        <  u =="0.000000000000000001" : ] 000000047525316.440998000000000000 ; 000000060879903.331445900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004884945CE536 >									
	//     < RUSS_PFXXVII_I_metadata_line_5_____SIBUR_MOTORS_20211101 >									
	//        < I94XCT9Vg8SiwhIxPzGWks54Sn81xw7zmZ205oJLr2rEzRfcUgU3mjF57gbxojv4 >									
	//        <  u =="0.000000000000000001" : ] 000000060879903.331445900000000000 ; 000000076390357.391254800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005CE536748FFC >									
	//     < RUSS_PFXXVII_I_metadata_line_6_____SIBUR_FINANCE_20211101 >									
	//        < A04IEQ6Yytjuhkl5wd8pR508kK8aH2mE8d4K37o9rF858sr5pI28wkdRjBM41W8L >									
	//        <  u =="0.000000000000000001" : ] 000000076390357.391254800000000000 ; 000000091190359.609649600000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000748FFC8B253C >									
	//     < RUSS_PFXXVII_I_metadata_line_7_____AKRILAT_20211101 >									
	//        < 15i2ezMOuA6EFfSrZANjS1fsR17lQAW5fojq4E3nqF0FXl4j99vO5F7u99UN2a5X >									
	//        <  u =="0.000000000000000001" : ] 000000091190359.609649600000000000 ; 000000107761294.927459000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008B253CA46E41 >									
	//     < RUSS_PFXXVII_I_metadata_line_8_____SINOPEC_RUBBER_20211101 >									
	//        < GGQx9J3renhMSZlAlW6BkjbdJJLOLA6V6O240S1peCX7rA1MrUDn5A2ZRZIADs53 >									
	//        <  u =="0.000000000000000001" : ] 000000107761294.927459000000000000 ; 000000124531258.968237000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A46E41BE0506 >									
	//     < RUSS_PFXXVII_I_metadata_line_9_____TOBOLSK_NEFTEKHIM_20211101 >									
	//        < 8x43jIC3Zp4722H0e1756EJ2hTbT9cxOmBsPp6vpoJMY202blB94r3Ng2Rt406n3 >									
	//        <  u =="0.000000000000000001" : ] 000000124531258.968237000000000000 ; 000000140669467.234452000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BE0506D6A503 >									
	//     < RUSS_PFXXVII_I_metadata_line_10_____SIBUR_PETF_20211101 >									
	//        < 2Jzbrh8qan13X31qlPKTXau19sJs7M4ZO8K1pb5803Hlslr1a3j4qN04vkct3k0M >									
	//        <  u =="0.000000000000000001" : ] 000000140669467.234452000000000000 ; 000000154387122.393533000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D6A503EB9378 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVII_I_metadata_line_11_____MURAVLENKOVSKY_GAS_PROCESS_PLANT_20211101 >									
	//        < 0bp61Ifza0e867qO62u2fXU8330g19OY1HTO21r6MjvXYcVRCrujvC2U1oN84m7b >									
	//        <  u =="0.000000000000000001" : ] 000000154387122.393533000000000000 ; 000000168587176.416669000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EB93781013E5E >									
	//     < RUSS_PFXXVII_I_metadata_line_12_____OOO_IT_SERVICE_20211101 >									
	//        < 4SX73K299gMo16U5aV2i11g709Jsr7JWxBmnUN6D5P307u2n2st25nV6fAIp161I >									
	//        <  u =="0.000000000000000001" : ] 000000168587176.416669000000000000 ; 000000181679373.475449000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001013E5E1153881 >									
	//     < RUSS_PFXXVII_I_metadata_line_13_____ZAO_MIRACLE_20211101 >									
	//        < 2RlfnIesgQn2E9ZBFa0V2E7aZIUqE8jWebh1IK98G0G1ECQdTj3Fq1xRw19ITz37 >									
	//        <  u =="0.000000000000000001" : ] 000000181679373.475449000000000000 ; 000000198505792.945183000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000115388112EE553 >									
	//     < RUSS_PFXXVII_I_metadata_line_14_____NOVATEK_POLYMER_20211101 >									
	//        < JNyB9U1Q2G54W7SfENBBh0ASihAGqJOe8IEw5M75fUP8uB6ES1r4sq64cAEg6H6T >									
	//        <  u =="0.000000000000000001" : ] 000000198505792.945183000000000000 ; 000000213027140.586721000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012EE5531450DBA >									
	//     < RUSS_PFXXVII_I_metadata_line_15_____SOUTHWEST_GAS_PIPELINES_20211101 >									
	//        < 52P98440V3w1S0213S7GX71a0fn4BTu7ZVSMr3greLwfJKig6J26hKSVw994AZ89 >									
	//        <  u =="0.000000000000000001" : ] 000000213027140.586721000000000000 ; 000000229322634.320575000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001450DBA15DEB27 >									
	//     < RUSS_PFXXVII_I_metadata_line_16_____YUGRAGAZPERERABOTKA_20211101 >									
	//        < n581mTmm9Wwiv6k8YNuZcAdB90yBVfZhKz62vrSloAV3J6H4Kqce8e3N18LDqPev >									
	//        <  u =="0.000000000000000001" : ] 000000229322634.320575000000000000 ; 000000244431834.372375000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015DEB27174F92F >									
	//     < RUSS_PFXXVII_I_metadata_line_17_____TOMSKNEFTEKHIM_20211101 >									
	//        < LTf4qCa1FG72h2FqN89HSq7G31Iu33YlTE0m33q12LKj428IRn0p2QGPNhvTv690 >									
	//        <  u =="0.000000000000000001" : ] 000000244431834.372375000000000000 ; 000000258491235.293890000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000174F92F18A6D24 >									
	//     < RUSS_PFXXVII_I_metadata_line_18_____BALTIC_LNG_20211101 >									
	//        < 92w7EL6rASFGccvfNM6Jr2lf1wfF1jrWJN41OT91na90yH2MU0G69tUFRt03oM32 >									
	//        <  u =="0.000000000000000001" : ] 000000258491235.293890000000000000 ; 000000273497901.774534000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018A6D241A1531E >									
	//     < RUSS_PFXXVII_I_metadata_line_19_____SIBUR_INT_GMBH_20211101 >									
	//        < Uy3Sh6bjsxxzOAUNGkj56MvEVP561KkS2zvgN8H559Gg0m5dT4Av5n56Df80rBQs >									
	//        <  u =="0.000000000000000001" : ] 000000273497901.774534000000000000 ; 000000289975135.374181000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A1531E1BA778A >									
	//     < RUSS_PFXXVII_I_metadata_line_20_____TOBOL_SK_POLIMER_20211101 >									
	//        < wjKkz9QFvX8tQdprU563tkQSr4PB87fwAX376Jotz647TXISO3OGZ3Ih3unefAd8 >									
	//        <  u =="0.000000000000000001" : ] 000000289975135.374181000000000000 ; 000000306389865.149331000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BA778A1D3838B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVII_I_metadata_line_21_____SIBUR_SCIENT_RD_INSTITUTE_GAS_PROCESS_20211101 >									
	//        < S6Qj3brPs2f97iGb03r7KWO8GK0l08Ru0cs80F5Eq1ucadBI36hMlejqYa85Zhvr >									
	//        <  u =="0.000000000000000001" : ] 000000306389865.149331000000000000 ; 000000319846099.848078000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D3838B1E80BE2 >									
	//     < RUSS_PFXXVII_I_metadata_line_22_____ZAPSIBNEFTEKHIM_20211101 >									
	//        < neUMv58F04h30Agj833W24jpV6OSx7qGMRR95mAfNceQYO757lPkLK73LE92M529 >									
	//        <  u =="0.000000000000000001" : ] 000000319846099.848078000000000000 ; 000000336418942.492715000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E80BE220155A6 >									
	//     < RUSS_PFXXVII_I_metadata_line_23_____RUSVINYL_20211101 >									
	//        < 0X6GNbFQ03nMbPk07jN0p4NS7fEH2n21Z2IaFI73X7qe19jX9tGUN7MOPnZ16llk >									
	//        <  u =="0.000000000000000001" : ] 000000336418942.492715000000000000 ; 000000353015357.315876000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020155A621AA8A0 >									
	//     < RUSS_PFXXVII_I_metadata_line_24_____SIBUR_SECURITIES_LIMITED_20211101 >									
	//        < TRUkGxsi1xMR3k2VIOenK1P79fXyK4r9r12ED9T0j8X4UBdswUyv7s98zu8h9IOX >									
	//        <  u =="0.000000000000000001" : ] 000000353015357.315876000000000000 ; 000000367266911.247305000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021AA8A023067A3 >									
	//     < RUSS_PFXXVII_I_metadata_line_25_____ACRYLATE_20211101 >									
	//        < NpDw4Q030Ou7ntzKHgGqNx9B2F163nK8JVjJJRwf99C8M58gzsNp2HlcLoiGRqQ7 >									
	//        <  u =="0.000000000000000001" : ] 000000367266911.247305000000000000 ; 000000380464462.375954000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023067A32448AEE >									
	//     < RUSS_PFXXVII_I_metadata_line_26_____BIAXPLEN_20211101 >									
	//        < nhSJmS7PfLRoY0rMKtQSkIW7fR7w3C0G4fTR2kyMI17fgU664741Lf10Lj1inpTk >									
	//        <  u =="0.000000000000000001" : ] 000000380464462.375954000000000000 ; 000000393999685.391001000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002448AEE2593221 >									
	//     < RUSS_PFXXVII_I_metadata_line_27_____PORTENERGO_20211101 >									
	//        < xi3Fet5k4lh2cVTw3yAq2U4vZ2DfQCjuX1Ce2h6r1E4rQtrU9JwcV2WYmnmxbj93 >									
	//        <  u =="0.000000000000000001" : ] 000000393999685.391001000000000000 ; 000000407290538.706300000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000259322126D79DE >									
	//     < RUSS_PFXXVII_I_metadata_line_28_____POLIEF_20211101 >									
	//        < 8hEu9bC497cjY2T5UXa4dZ51106et9mj8Y1Q5AdK4Gt6MpE1nbciq26adc540UsC >									
	//        <  u =="0.000000000000000001" : ] 000000407290538.706300000000000000 ; 000000422591035.734203000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026D79DE284D2A0 >									
	//     < RUSS_PFXXVII_I_metadata_line_29_____RUSPAV_20211101 >									
	//        < V1bg1419r7UV81QPICTY6xheF3ms8j9KphPWeFD26tCEMk9xj4rr64vIEWf0qyr1 >									
	//        <  u =="0.000000000000000001" : ] 000000422591035.734203000000000000 ; 000000435898143.922659000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000284D2A029920B6 >									
	//     < RUSS_PFXXVII_I_metadata_line_30_____NEFTEKHIMIA_20211101 >									
	//        < SbY27RP9juS9qq1q3ALurGFAq11wDEzx2GK40UI21V6XVA9KaaVmC38aID2J6ifC >									
	//        <  u =="0.000000000000000001" : ] 000000435898143.922659000000000000 ; 000000452643994.759795000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029920B62B2AE0F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVII_I_metadata_line_31_____OTECHESTVENNYE_POLIMERY_20211101 >									
	//        < a10ezn304TBz6dWV5k7FywiINzD4k12KIEyS3U52xljuQsJIOPPE6Ll1MN44587Y >									
	//        <  u =="0.000000000000000001" : ] 000000452643994.759795000000000000 ; 000000466705109.205646000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B2AE0F2C822AF >									
	//     < RUSS_PFXXVII_I_metadata_line_32_____SIBUR_TRANS_20211101 >									
	//        < 4N52Hblpe55me8WBZ2b9f96HS8TZXCCk1q9110Y6meqnAr0D1wUw6gFema218JRK >									
	//        <  u =="0.000000000000000001" : ] 000000466705109.205646000000000000 ; 000000480031086.142136000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C822AF2DC7825 >									
	//     < RUSS_PFXXVII_I_metadata_line_33_____TOGLIATTIKAUCHUK_20211101 >									
	//        < tCKxc4x2GqYDP85v6OG48Nx46p5NscO42kz1jJnRgcFlTly7iNqGO2WEBiS1kc1p >									
	//        <  u =="0.000000000000000001" : ] 000000480031086.142136000000000000 ; 000000496617277.446981000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DC78252F5C720 >									
	//     < RUSS_PFXXVII_I_metadata_line_34_____NPP_NEFTEKHIMIYA_OOO_20211101 >									
	//        < c085E0tH627KlFgc5b5Ap6u1MW9FNIl3qYaGG4wPg9TX8u0cT3QbXLH2YRfl42Fn >									
	//        <  u =="0.000000000000000001" : ] 000000496617277.446981000000000000 ; 000000509660581.882011000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F5C720309AE2A >									
	//     < RUSS_PFXXVII_I_metadata_line_35_____SIBUR_KHIMPROM_20211101 >									
	//        < 32yPwNFx0HVi0h89WU4t950IYm522Pz98lL335C9fmobhp77QsGolH39wOg5Fp8D >									
	//        <  u =="0.000000000000000001" : ] 000000509660581.882011000000000000 ; 000000525970778.839256000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000309AE2A3229156 >									
	//     < RUSS_PFXXVII_I_metadata_line_36_____SIBUR_VOLZHSKY_20211101 >									
	//        < 5Lc953OKuSPK6p62JD80EqNYLY3v20zNLqGcVTxCZ0Qt8Do61H0TMgDLxVl5IJa6 >									
	//        <  u =="0.000000000000000001" : ] 000000525970778.839256000000000000 ; 000000542918459.250042000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000322915633C6D86 >									
	//     < RUSS_PFXXVII_I_metadata_line_37_____VORONEZHSINTEZKAUCHUK_20211101 >									
	//        < jgK5nKNS0YzsxA8oO5l5sK3EZq27d4Zp8vr30Fb9hpH6j5v5rD23WSF7I72XZEeZ >									
	//        <  u =="0.000000000000000001" : ] 000000542918459.250042000000000000 ; 000000556004765.884488000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033C6D86350655D >									
	//     < RUSS_PFXXVII_I_metadata_line_38_____INFO_TECH_SERVICE_CO_20211101 >									
	//        < Kk8g4f1mtZ2iX3IHssA8R3I832wKp1ZAwPMC6n83NNWwORSO3URIi3Rk90cGgPnP >									
	//        <  u =="0.000000000000000001" : ] 000000556004765.884488000000000000 ; 000000571446217.767880000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000350655D367F52E >									
	//     < RUSS_PFXXVII_I_metadata_line_39_____LNG_NOVAENGINEERING_20211101 >									
	//        < SfQ4z5s6gnk5sxIruYSZ9nOI66j79u708DE220UPmdpJe7RF22Gt5lJ3QN2kIY0C >									
	//        <  u =="0.000000000000000001" : ] 000000571446217.767880000000000000 ; 000000586346398.609783000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000367F52E37EB190 >									
	//     < RUSS_PFXXVII_I_metadata_line_40_____SIBGAZPOLIMER_20211101 >									
	//        < 2uzeoPUdX26oi0RNqbs5HQt4P7v6y3e99vQc3K5D5YGWg8KdT6YS9Tu6AASW33Fj >									
	//        <  u =="0.000000000000000001" : ] 000000586346398.609783000000000000 ; 000000599305625.295470000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037EB19039277C3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}