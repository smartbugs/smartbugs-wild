pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFIX_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFIX_III_883		"	;
		string	public		symbol =	"	RUSS_PFIX_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1056649107163550000000000000					;	
										
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
	//     < RUSS_PFIX_III_metadata_line_1_____POLYUS_GOLD_20251101 >									
	//        < 7FAvAz1dlcsMsUfOz9bA3YAuH180N8uWVGhMr5x77JVfdi0TcM4sV6fiTG60MzOX >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000020931579.115583100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001FF066 >									
	//     < RUSS_PFIX_III_metadata_line_2_____POLYUS_GOLD_GBP_20251101 >									
	//        < cQCW8kIV9g4ghl60ACQVi1y5Ga9W1CrRKEm6m6XDKej7GG9ur5trmcX91wU5ocof >									
	//        <  u =="0.000000000000000001" : ] 000000020931579.115583100000000000 ; 000000055037451.881143100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001FF06653FB01 >									
	//     < RUSS_PFIX_III_metadata_line_3_____POLYUS_GOLD_USD_20251101 >									
	//        < W850b6x73s93Mp6I23S7HaDct58GK7C3C4T6QhJmkM58EbC3z9A53m1FVt6HTcYn >									
	//        <  u =="0.000000000000000001" : ] 000000055037451.881143100000000000 ; 000000086668074.228881500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000053FB01843EB7 >									
	//     < RUSS_PFIX_III_metadata_line_4_____POLYUS_KRASNOYARSK_20251101 >									
	//        < 44T7ZLqKN5Mw7oZ4b6CZqxcUZsca8KGkKM39vHUVxd6zUO3oT2tdT5fZhV9csbC5 >									
	//        <  u =="0.000000000000000001" : ] 000000086668074.228881500000000000 ; 000000110761956.974495000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000843EB7A90264 >									
	//     < RUSS_PFIX_III_metadata_line_5_____POLYUS_FINANCE_PLC_20251101 >									
	//        < uZXxGXPGeZ8rz0YIeeB0n471UyK2rSWXB6vj5b95Ois14VsVMf9FhVX2XcoTHgu5 >									
	//        <  u =="0.000000000000000001" : ] 000000110761956.974495000000000000 ; 000000137776879.942687000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A90264D23B18 >									
	//     < RUSS_PFIX_III_metadata_line_6_____POLYUS_FINANS_FI_20251101 >									
	//        < 68Lf6QqKJ24G3i48FF232S1LFNxx5i8zqYhHG396BjHRCg1cMQ1S38yX435WmUi1 >									
	//        <  u =="0.000000000000000001" : ] 000000137776879.942687000000000000 ; 000000166551054.487248000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D23B18FE2301 >									
	//     < RUSS_PFIX_III_metadata_line_7_____POLYUS_FINANS_FII_20251101 >									
	//        < 2N8mB1xupHuxt7YPzR1Nkfwx9469N4mNg8MjXU5FfMN2d4t1A07E4ucMHJ0gjN8P >									
	//        <  u =="0.000000000000000001" : ] 000000166551054.487248000000000000 ; 000000192728830.767712000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FE230112614B3 >									
	//     < RUSS_PFIX_III_metadata_line_8_____POLYUS_FINANS_FIII_20251101 >									
	//        < mmV7Kl5DxuZ5TJlF0WROkG2RB7715KE7PFt7M0FlxoJArU0B8S64I26ghXMBPgfy >									
	//        <  u =="0.000000000000000001" : ] 000000192728830.767712000000000000 ; 000000219473801.731417000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012614B314EE3F4 >									
	//     < RUSS_PFIX_III_metadata_line_9_____POLYUS_FINANS_FIV_20251101 >									
	//        < vuQi2RbT1luG5jLDbGE20aWOH33156C2AxX6hKqE11aW5drT7pRvSt4okW1267jy >									
	//        <  u =="0.000000000000000001" : ] 000000219473801.731417000000000000 ; 000000250235109.924257000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014EE3F417DD417 >									
	//     < RUSS_PFIX_III_metadata_line_10_____POLYUS_FINANS_FV_20251101 >									
	//        < czRWVED1R7D68M7tHO1lYU518L7HVBun6ua65HIZ8l63WfjWhQQBNcCd26TwITPE >									
	//        <  u =="0.000000000000000001" : ] 000000250235109.924257000000000000 ; 000000270171624.156869000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017DD41719C3FCA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIX_III_metadata_line_11_____POLYUS_FINANS_FVI_20251101 >									
	//        < 5g1Z2P54ev5I9T92MUkpv8QIawxNCw4mJc9spvaI8HWQRygKk431uH61lhMW6o2U >									
	//        <  u =="0.000000000000000001" : ] 000000270171624.156869000000000000 ; 000000289734488.388797000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019C3FCA1BA1989 >									
	//     < RUSS_PFIX_III_metadata_line_12_____POLYUS_FINANS_FVII_20251101 >									
	//        < T77FFopHV80lQOo52j90TA5lW0L5DH2xB6KDIZco17e2J6PyVH4x4s506qRVDn4H >									
	//        <  u =="0.000000000000000001" : ] 000000289734488.388797000000000000 ; 000000317262495.316675000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BA19891E41AAA >									
	//     < RUSS_PFIX_III_metadata_line_13_____POLYUS_FINANS_FVIII_20251101 >									
	//        < eaOhro0FX5yL1762AvXcneL768biMv0SsfjHOSB9061NL2yGmCI9210T0dS90SPO >									
	//        <  u =="0.000000000000000001" : ] 000000317262495.316675000000000000 ; 000000352241627.038582000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E41AAA2197A63 >									
	//     < RUSS_PFIX_III_metadata_line_14_____POLYUS_FINANS_FIX_20251101 >									
	//        < VDwDbYQX3WbIOr24S62vu76SEpuHC3jNykSo49yAnmf2XJ9Wm0H7W85wxPrMM6i7 >									
	//        <  u =="0.000000000000000001" : ] 000000352241627.038582000000000000 ; 000000374782466.213340000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002197A6323BDF67 >									
	//     < RUSS_PFIX_III_metadata_line_15_____POLYUS_FINANS_FX_20251101 >									
	//        < 5HE2t86Z4jMJqwHq0lnicU03pSNILyntb1M1oIJ35go9w5hsFP8kRG9MHM3WQe1H >									
	//        <  u =="0.000000000000000001" : ] 000000374782466.213340000000000000 ; 000000394231224.350087000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023BDF672598C92 >									
	//     < RUSS_PFIX_III_metadata_line_16_____SVETLIY_20251101 >									
	//        < v26iSr1N1Y0Ofq3cHXSy7r561y6F6etlD750y2X67oyY8hP6URh65SYl7HBq9sPI >									
	//        <  u =="0.000000000000000001" : ] 000000394231224.350087000000000000 ; 000000429911137.019477000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002598C9228FFE0A >									
	//     < RUSS_PFIX_III_metadata_line_17_____POLYUS_EXPLORATION_20251101 >									
	//        < 07INTk4W8NWYEytPfp9sq73LSlIkelrUc76C74wbXF521OV9ct0Y97c9byzRohO3 >									
	//        <  u =="0.000000000000000001" : ] 000000429911137.019477000000000000 ; 000000448552978.985361000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028FFE0A2AC7002 >									
	//     < RUSS_PFIX_III_metadata_line_18_____ZL_ZOLOTO_20251101 >									
	//        < wDEU9H2N8w2oPo23e13G0v5KO9u8rbcsmU9q66jQ7TF2uGuQC21I89ZaGa07a6xt >									
	//        <  u =="0.000000000000000001" : ] 000000448552978.985361000000000000 ; 000000476420690.450888000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AC70022D6F5D5 >									
	//     < RUSS_PFIX_III_metadata_line_19_____SK_FOUNDATION_LUZERN_20251101 >									
	//        < am8Pq4YKF72X2DsseOZ58ja5WY8n52v87hs1eNygmJQalH9ayjI0kStuNQ1EO6s5 >									
	//        <  u =="0.000000000000000001" : ] 000000476420690.450888000000000000 ; 000000494905282.010972000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D6F5D52F32A60 >									
	//     < RUSS_PFIX_III_metadata_line_20_____SKFL_AB_20251101 >									
	//        < 5xPgyVJ7K25hPFnm6Y0hF39ATG3u08Nam0r8S56y9CtLnA9G0AUDi552PonQ9Y5x >									
	//        <  u =="0.000000000000000001" : ] 000000494905282.010972000000000000 ; 000000513853994.396595000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F32A603101437 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIX_III_metadata_line_21_____AB_URALKALI_20251101 >									
	//        < vnmW5QdHScAGx8BTh6ewoL09lEevMW4F9Vmr6SCnEAP4Y136sfWg66TUeXg8nh2J >									
	//        <  u =="0.000000000000000001" : ] 000000513853994.396595000000000000 ; 000000534921916.151287000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000310143733039E0 >									
	//     < RUSS_PFIX_III_metadata_line_22_____AB_FK_ANZHI_MAKHA_20251101 >									
	//        < q08Y4yqANors0SQJt53f1nRr9a61n86hZnUO8t80is30Nx2hn0U30kBXB17Be79A >									
	//        <  u =="0.000000000000000001" : ] 000000534921916.151287000000000000 ; 000000554903565.879158000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033039E034EB735 >									
	//     < RUSS_PFIX_III_metadata_line_23_____AB_NAFTA_MOSKVA_20251101 >									
	//        < 4ZXpvLfxS6aO2Ola4cWc1Cy1J1B434zg2JoSss1F977yKhq89kR7jLbAcw9iCow9 >									
	//        <  u =="0.000000000000000001" : ] 000000554903565.879158000000000000 ; 000000585173741.382743000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034EB73537CE77E >									
	//     < RUSS_PFIX_III_metadata_line_24_____AB_SOYUZNEFTEEXPOR_20251101 >									
	//        < QVGca4Vu5DjpKGgdQvpdjPptogyCXORbPSJ4353LkMRQO46GCAGGy083MJl0U511 >									
	//        <  u =="0.000000000000000001" : ] 000000585173741.382743000000000000 ; 000000610118563.084978000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037CE77E3A2F790 >									
	//     < RUSS_PFIX_III_metadata_line_25_____AB_FEDPROMBANK_20251101 >									
	//        < n52cXJrn33zwV72cQKhvG07I0Ez1hu24Yv7LN5Vz8wCs38cmNo1LD5yKnnPEX9Pv >									
	//        <  u =="0.000000000000000001" : ] 000000610118563.084978000000000000 ; 000000641776396.803725000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A2F7903D345E8 >									
	//     < RUSS_PFIX_III_metadata_line_26_____AB_ELTAV_ELEC_20251101 >									
	//        < VmUG4yQng0WdHshin8co7csmzscTwTmyNSJ3we5DrArKq68Vb2ixxiqAPOxu17Pl >									
	//        <  u =="0.000000000000000001" : ] 000000641776396.803725000000000000 ; 000000669841617.443422000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D345E83FE18E2 >									
	//     < RUSS_PFIX_III_metadata_line_27_____AB_SOYUZ_FINANS_20251101 >									
	//        < nh0qs0c8uWxj80Fd6MRF27ZPRc2zvc4F0JL0dS6nmFAxI28N8x0EX7tURKq0E9B9 >									
	//        <  u =="0.000000000000000001" : ] 000000669841617.443422000000000000 ; 000000690443337.551817000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003FE18E241D886E >									
	//     < RUSS_PFIX_III_metadata_line_28_____AB_VNUKOVO_20251101 >									
	//        < nAm9Ytd1oFIs3JPi0lM9ELp2G000s58Z70274EESI3IaDhFPGVRgtaH7y77A4Q3v >									
	//        <  u =="0.000000000000000001" : ] 000000690443337.551817000000000000 ; 000000720712545.347270000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041D886E44BB857 >									
	//     < RUSS_PFIX_III_metadata_line_29_____AB_AVTOBANK_20251101 >									
	//        < 7ppMB33S76Zbl0zhg0pmh5PdYY3qW2MF2IdZZwXH8wJMr00JCcb9TdD6swJrO1Ef >									
	//        <  u =="0.000000000000000001" : ] 000000720712545.347270000000000000 ; 000000753181847.384444000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044BB85747D43A9 >									
	//     < RUSS_PFIX_III_metadata_line_30_____AB_SMOLENSKY_PASSAZH_20251101 >									
	//        < 51WLhq4KsKpo3TSIc8D5BpLnRPLi35hf8Av0djnMg7C7ny3evT17q131j7DmDsk3 >									
	//        <  u =="0.000000000000000001" : ] 000000753181847.384444000000000000 ; 000000783121444.219346000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000047D43A94AAF2D0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIX_III_metadata_line_31_____MAKHA_PORT_20251101 >									
	//        < Ed70A56x2LUSiW44Sbu72qScRvWPaFsw5476tQAycM8OEb0SYsVj49KBs82Qn3NT >									
	//        <  u =="0.000000000000000001" : ] 000000783121444.219346000000000000 ; 000000813943568.196401000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004AAF2D04D9FAB5 >									
	//     < RUSS_PFIX_III_metadata_line_32_____MAKHA_AIRPORT_AB_20251101 >									
	//        < dkuM5X8ZP9Lv409gBvY57z13bhz93CFeE50oxCTZtXtjIklijtheJkoK2q6wQe25 >									
	//        <  u =="0.000000000000000001" : ] 000000813943568.196401000000000000 ; 000000833939469.872086000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004D9FAB54F87D9B >									
	//     < RUSS_PFIX_III_metadata_line_33_____DAG_ORG_20251101 >									
	//        < Of0s21v0j6A0zJquCHtVdFK154nigdN65c32r8h12veCMlZLpBLPr1VU0dvZgWfR >									
	//        <  u =="0.000000000000000001" : ] 000000833939469.872086000000000000 ; 000000853493595.130085000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004F87D9B51653F0 >									
	//     < RUSS_PFIX_III_metadata_line_34_____DAG_DAO_20251101 >									
	//        < 5LVOPjtJbALHVFqMnoVyb092oo2yzMJ3PGb3228lIv613WFW3l0496MDRl1ex3mI >									
	//        <  u =="0.000000000000000001" : ] 000000853493595.130085000000000000 ; 000000887426059.602530000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000051653F054A1ACE >									
	//     < RUSS_PFIX_III_metadata_line_35_____DAG_DAOPI_20251101 >									
	//        < 3JMGm65wvYYH7N0D8140O0cOO297YJoF4q4J24ICa4bTpqv7M0u0E8wjP9jlf1f1 >									
	//        <  u =="0.000000000000000001" : ] 000000887426059.602530000000000000 ; 000000922341314.894016000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000054A1ACE57F6193 >									
	//     < RUSS_PFIX_III_metadata_line_36_____DAG_DAC_20251101 >									
	//        < vxBCjI44687guRXJ4rQkfSeokiExQ5M6MBLC3fA3j6me907mSTgyuHqB1mb2w829 >									
	//        <  u =="0.000000000000000001" : ] 000000922341314.894016000000000000 ; 000000947125083.251276000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000057F61935A532BC >									
	//     < RUSS_PFIX_III_metadata_line_37_____MAKHA_ORG_20251101 >									
	//        < 51u95MXuo91Cu8Cl91z29e3QF1nBPscj718G27iGyEdgda73ADVfmZdfg4lo7bI6 >									
	//        <  u =="0.000000000000000001" : ] 000000947125083.251276000000000000 ; 000000970828131.930115000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005A532BC5C95DBD >									
	//     < RUSS_PFIX_III_metadata_line_38_____MAKHA_DAO_20251101 >									
	//        < 392Y3aXcCE6IWCBkEZ94T3YE6S7u9w76W6sUj15T3FZU4722TXa0YlD9MYrk08m5 >									
	//        <  u =="0.000000000000000001" : ] 000000970828131.930115000000000000 ; 000000996177267.351476000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005C95DBD5F00BBF >									
	//     < RUSS_PFIX_III_metadata_line_39_____MAKHA_DAOPI_20251101 >									
	//        < 6Ees8FEe164HSm3VoyofrY0xTHk39DVcRKU9C0t1WIJ5B9v8Fk51J2gpm12688Hn >									
	//        <  u =="0.000000000000000001" : ] 000000996177267.351476000000000000 ; 000001025384422.052440000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005F00BBF61C9CCA >									
	//     < RUSS_PFIX_III_metadata_line_40_____MAKHA_DAC_20251101 >									
	//        < tpPB22jdfqz3QQQ1FPZ55u7kEm3FZ3YZG5OXw6aNYEJjgz76662u56fm3279LrOV >									
	//        <  u =="0.000000000000000001" : ] 000001025384422.052440000000000000 ; 000001056649107.163550000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000061C9CCA64C518F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}