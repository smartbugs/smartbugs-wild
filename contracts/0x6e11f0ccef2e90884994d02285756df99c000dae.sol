pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXVIII_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXVIII_I_883		"	;
		string	public		symbol =	"	RUSS_PFXVIII_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		604142944846809000000000000					;	
										
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
	//     < RUSS_PFXVIII_I_metadata_line_1_____RESO_GARANTIA_20211101 >									
	//        < 60nwRgE01XXJ2v80SLk3y5ZYOH8PP5Lb9O7UGMY3Opq027lIo1vZi1t4slgXjd0S >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000017238132.451084700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001A4DA5 >									
	//     < RUSS_PFXVIII_I_metadata_line_2_____RESO_CREDIT_BANK_20211101 >									
	//        < K2f185KLnRxjBG2KkMt6n7yTgO4ulDpa7i6N9dK31r4gYVepcwIQiI33z5a03Bsg >									
	//        <  u =="0.000000000000000001" : ] 000000017238132.451084700000000000 ; 000000031401541.097964200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001A4DA52FEA3A >									
	//     < RUSS_PFXVIII_I_metadata_line_3_____RESO_LEASING_20211101 >									
	//        < F1KX70iA11pKg9cUqJqr225atvu88fH369s1902vSn05fR6Q7cQzAUZ62nmsC7W7 >									
	//        <  u =="0.000000000000000001" : ] 000000031401541.097964200000000000 ; 000000046518632.193703500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002FEA3A46FB57 >									
	//     < RUSS_PFXVIII_I_metadata_line_4_____OSZH_RESO_GARANTIA_20211101 >									
	//        < 0KJJQ2ZMM3g4o288201ih5c7ELAdUnxZm8YKKT320L62vk2Jrx3fWt1b9V23sYIB >									
	//        <  u =="0.000000000000000001" : ] 000000046518632.193703500000000000 ; 000000062445856.990240800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000046FB575F48EA >									
	//     < RUSS_PFXVIII_I_metadata_line_5_____STRAKHOVOI_SINDIKAT_20211101 >									
	//        < 3of29jy8lI5l7gd61uaQ6lcE3nxlri5js0FX04Go7PPtEAWT2797D2X73d009CzD >									
	//        <  u =="0.000000000000000001" : ] 000000062445856.990240800000000000 ; 000000077455157.070667500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005F48EA762FEC >									
	//     < RUSS_PFXVIII_I_metadata_line_6_____RESO_FINANCIAL_MARKETS_20211101 >									
	//        < Sbzp1Zda2Z0vmJb5ybVr5GYy2AWI16a0PKO9U5u3xWs603p3LZCyV174qn769QiW >									
	//        <  u =="0.000000000000000001" : ] 000000077455157.070667500000000000 ; 000000093144714.877161200000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000762FEC8E20A7 >									
	//     < RUSS_PFXVIII_I_metadata_line_7_____LIPETSK_INSURANCE_CO_CHANCE_20211101 >									
	//        < 3NH6JOyS2x50t373BQggnvBYPPenx5A8xCRwpwSE76DyMbmhwa7IouvrT16Darz4 >									
	//        <  u =="0.000000000000000001" : ] 000000093144714.877161200000000000 ; 000000109340490.176763000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008E20A7A6D721 >									
	//     < RUSS_PFXVIII_I_metadata_line_8_____ALVENA_RESO_GROUP_20211101 >									
	//        < 40R2N0MypkO7lLiM5eqiTB1P35iq4x2k4gbfaa5FUmLH00gwqZnlu310FxotZZaM >									
	//        <  u =="0.000000000000000001" : ] 000000109340490.176763000000000000 ; 000000125601615.343752000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A6D721BFA722 >									
	//     < RUSS_PFXVIII_I_metadata_line_9_____NADEZHNAYA_LIFE_INSURANCE_CO_20211101 >									
	//        < lPGzBwppjcF2dLmtYhpf51z6f7749iygM2780BTM5H49tPEoOAiUL08gPqXwJMd6 >									
	//        <  u =="0.000000000000000001" : ] 000000125601615.343752000000000000 ; 000000139935199.275881000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BFA722D58630 >									
	//     < RUSS_PFXVIII_I_metadata_line_10_____MSK_URALSIB_20211101 >									
	//        < G4fb022AYY3Os4DJM5Y9Fv0rbvxNORXPH5AoZc00drB2W4s5OnJ8EKCruQ4M54Mt >									
	//        <  u =="0.000000000000000001" : ] 000000139935199.275881000000000000 ; 000000153686115.733859000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D58630EA81A4 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVIII_I_metadata_line_11_____RESO_1_ORG_20211101 >									
	//        < 9R3yV67pQ3t2bR4754S555DM3H41uMU174XOB2tZmua5RVEE0YsNFuPbLW02zqD3 >									
	//        <  u =="0.000000000000000001" : ] 000000153686115.733859000000000000 ; 000000170699507.976927000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EA81A4104777F >									
	//     < RUSS_PFXVIII_I_metadata_line_12_____RESO_1_DAO_20211101 >									
	//        < z3heqIh4HSum2dLy9b5Jpb5ZP7DdCVmIF2ih7Gp4bES0CE663UW9qep4wmD883Z5 >									
	//        <  u =="0.000000000000000001" : ] 000000170699507.976927000000000000 ; 000000184405554.428286000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000104777F119616B >									
	//     < RUSS_PFXVIII_I_metadata_line_13_____RESO_1_DAOPI_20211101 >									
	//        < A0F4UM1P4fpaRW2I0Dxll8L78764t63my9s4rLCdGLPvOQ1J6hDmtHI7ao05nwnM >									
	//        <  u =="0.000000000000000001" : ] 000000184405554.428286000000000000 ; 000000200926662.567848000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000119616B13296FA >									
	//     < RUSS_PFXVIII_I_metadata_line_14_____RESO_1_DAC_20211101 >									
	//        < 6ZZN2qv5cYH8y55q8C32zTqz8U1j12tPGeWnUzpm06bA0afuc0w0L5aX7eoBJKb7 >									
	//        <  u =="0.000000000000000001" : ] 000000200926662.567848000000000000 ; 000000216619563.641489000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013296FA14A8904 >									
	//     < RUSS_PFXVIII_I_metadata_line_15_____RESO_1_BIMI_20211101 >									
	//        < UtUYrwOV8bN0C7Kflq2qi3J2pU19ofmB6iQrY40U3dFSzFid841vN78iSS7BIowe >									
	//        <  u =="0.000000000000000001" : ] 000000216619563.641489000000000000 ; 000000230121735.334113000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014A890415F234E >									
	//     < RUSS_PFXVIII_I_metadata_line_16_____RESO_2_ORG_20211101 >									
	//        < Q3UL04IfKC5Kx65sXH0px8y909g9zFG198BBE5Dy0afJ2H7PAai3mz0eR6RQ84d0 >									
	//        <  u =="0.000000000000000001" : ] 000000230121735.334113000000000000 ; 000000243204005.236136000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015F234E1731991 >									
	//     < RUSS_PFXVIII_I_metadata_line_17_____RESO_2_DAO_20211101 >									
	//        < mpP4EIMsjG33nb4xOQ78Abt0dZhTag1722WB3R1A0T67FTYUqiIsLUEWv2Jkr75I >									
	//        <  u =="0.000000000000000001" : ] 000000243204005.236136000000000000 ; 000000259900910.723113000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000173199118C93CB >									
	//     < RUSS_PFXVIII_I_metadata_line_18_____RESO_2_DAOPI_20211101 >									
	//        < Qgxr6d00V9eYAi13Aol2PraUpE25tKVm76x922WVQ9v7pB7wuL7xhSVydkvX0JcP >									
	//        <  u =="0.000000000000000001" : ] 000000259900910.723113000000000000 ; 000000275336430.119526000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018C93CB1A4214B >									
	//     < RUSS_PFXVIII_I_metadata_line_19_____RESO_2_DAC_20211101 >									
	//        < d3UJ6FW6bl7P30H3P122r2du7GIAD0Sx4kSvFOs8Ki7dSaA4jTr28wE2iFfQid7M >									
	//        <  u =="0.000000000000000001" : ] 000000275336430.119526000000000000 ; 000000290324291.662090000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A4214B1BAFFED >									
	//     < RUSS_PFXVIII_I_metadata_line_20_____RESO_2_BIMI_20211101 >									
	//        < vXE46mCE7I1P98m7iKN31pD6Ui5qPg4060b415UQ300RAt73lde65CgKDUQQQq08 >									
	//        <  u =="0.000000000000000001" : ] 000000290324291.662090000000000000 ; 000000307008085.812411000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BAFFED1D47509 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVIII_I_metadata_line_21_____RESO_PENSII_1_ORG_20211101 >									
	//        < SE90uixRtoXwUJUIqjJ0zuHt8Ec3mKb6DvWHt9O4ENYkC4I7Jvp8B2jr8Vpl35or >									
	//        <  u =="0.000000000000000001" : ] 000000307008085.812411000000000000 ; 000000322186567.226410000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D475091EB9E21 >									
	//     < RUSS_PFXVIII_I_metadata_line_22_____RESO_PENSII_1_DAO_20211101 >									
	//        < 9k8H1iRoEBMx1mZnVx351LT345e72o5UTf1vgQ0V54xFQB34aOj19og8C12i4EAy >									
	//        <  u =="0.000000000000000001" : ] 000000322186567.226410000000000000 ; 000000339299240.655128000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EB9E21205BAC4 >									
	//     < RUSS_PFXVIII_I_metadata_line_23_____RESO_PENSII_1_DAOPI_20211101 >									
	//        < 9V184Q7p18i88Ayr4dQw73N62c8oLI2Ya1p6pSaD9R2j8Ibvo3y90384e8MWPC1j >									
	//        <  u =="0.000000000000000001" : ] 000000339299240.655128000000000000 ; 000000353430558.396331000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000205BAC421B4AD0 >									
	//     < RUSS_PFXVIII_I_metadata_line_24_____RESO_PENSII_1_DAC_20211101 >									
	//        < l312Ug26dbQItluZmfGwyWXKlJNTkXd7Ztvz6h5vle3zu84jVMz4m7YWm552hg94 >									
	//        <  u =="0.000000000000000001" : ] 000000353430558.396331000000000000 ; 000000369788074.422272000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021B4AD02344077 >									
	//     < RUSS_PFXVIII_I_metadata_line_25_____RESO_PENSII_1_BIMI_20211101 >									
	//        < 17Ttfh0fZxSLyTSH5Q14j9C4bbAD3p8b553RQxHjOWzIRupo4YK0EXHnSmLv392y >									
	//        <  u =="0.000000000000000001" : ] 000000369788074.422272000000000000 ; 000000383092894.721326000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023440772488DA9 >									
	//     < RUSS_PFXVIII_I_metadata_line_26_____RESO_PENSII_2_ORG_20211101 >									
	//        < l5m5y0T9pkuZWa8WoLyGPd96Wo9j3i120eaD3PW07guV9269V2dX2Zvft9k7EXqF >									
	//        <  u =="0.000000000000000001" : ] 000000383092894.721326000000000000 ; 000000397880061.083928000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002488DA925F1DE6 >									
	//     < RUSS_PFXVIII_I_metadata_line_27_____RESO_PENSII_2_DAO_20211101 >									
	//        < pjka9NPAH3H7tuu9kv7nxc77GwJKBuN82K4X92u82VdX3shUDOqTQFwHwmOaHWNF >									
	//        <  u =="0.000000000000000001" : ] 000000397880061.083928000000000000 ; 000000411761602.009088000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025F1DE62744C60 >									
	//     < RUSS_PFXVIII_I_metadata_line_28_____RESO_PENSII_2_DAOPI_20211101 >									
	//        < Grv70e1W798QgT8akl8wZhO6HqF0mgXkz4kf8aM52yraC5Q56g9H4WC2geyAlLgv >									
	//        <  u =="0.000000000000000001" : ] 000000411761602.009088000000000000 ; 000000426977547.808152000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002744C6028B841B >									
	//     < RUSS_PFXVIII_I_metadata_line_29_____RESO_PENSII_2_DAC_20211101 >									
	//        < ISGYoB07Ee227DlA95RzyrvvIKJ51Pyz8mTYXbn7g1Ai6Dn5wj7IKD6AelL4b7z2 >									
	//        <  u =="0.000000000000000001" : ] 000000426977547.808152000000000000 ; 000000444163917.699796000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028B841B2A5BD88 >									
	//     < RUSS_PFXVIII_I_metadata_line_30_____RESO_PENSII_2_BIMI_20211101 >									
	//        < jtZ2T4g97O3iOSth70C4bB511QYY7p673vUY9IUINhys8Rs7Q7fI233tQ3n7UQ5T >									
	//        <  u =="0.000000000000000001" : ] 000000444163917.699796000000000000 ; 000000458151690.866141000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A5BD882BB1581 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVIII_I_metadata_line_31_____MIKA_ORG_20211101 >									
	//        < U1Ww63GTtC8Z8Z59dinJcB4r5ZXwoT5QzVipgA70L37wq62fdZ6Iud01OZ4g01Lu >									
	//        <  u =="0.000000000000000001" : ] 000000458151690.866141000000000000 ; 000000473213454.887405000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BB15812D21101 >									
	//     < RUSS_PFXVIII_I_metadata_line_32_____MIKA_DAO_20211101 >									
	//        < CSf7g9v0q7j1drPQyOS3q7Y83JFR693V5o0b11NnF6JevieZsbPX4o5VE32y8bh2 >									
	//        <  u =="0.000000000000000001" : ] 000000473213454.887405000000000000 ; 000000487802227.763905000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D211012E853BF >									
	//     < RUSS_PFXVIII_I_metadata_line_33_____MIKA_DAOPI_20211101 >									
	//        < O9YhkcKu6z20Zc2RYIvd45MJFqa2JKw0prk38p9776KIdak4x7JXEjfY9k5bwRg1 >									
	//        <  u =="0.000000000000000001" : ] 000000487802227.763905000000000000 ; 000000503893868.976847000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E853BF300E18B >									
	//     < RUSS_PFXVIII_I_metadata_line_34_____MIKA_DAC_20211101 >									
	//        < UkYf47jlA7lGihjV3AcAE94DZZ0Qc2axMe3DZjUoS5eRrrc9Gevv77jg23d4a7PV >									
	//        <  u =="0.000000000000000001" : ] 000000503893868.976847000000000000 ; 000000517694438.238585000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000300E18B315F064 >									
	//     < RUSS_PFXVIII_I_metadata_line_35_____MIKA_BIMI_20211101 >									
	//        < yGz52l40z3Xr0tIh7g9b2E0w1hUJGStMqwSB2mqIY22pr14509fb4OEFQk7FM7aC >									
	//        <  u =="0.000000000000000001" : ] 000000517694438.238585000000000000 ; 000000532609110.552695000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000315F06432CB26F >									
	//     < RUSS_PFXVIII_I_metadata_line_36_____MIKA_PENSII_ORG_20211101 >									
	//        < Z75Z2H6GxBsYJ06A4G1xdIRzH14t08oE07Jij79B1m5bleGcDkbF3QnO37qxyb4B >									
	//        <  u =="0.000000000000000001" : ] 000000532609110.552695000000000000 ; 000000545926656.570301000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032CB26F341049A >									
	//     < RUSS_PFXVIII_I_metadata_line_37_____MIKA_PENSII_DAO_20211101 >									
	//        < dC349T5MUkJ81Qos1iso5DT995z34SMe3Z0M8TqlTOg5fp713xcMfnFAsN456oPw >									
	//        <  u =="0.000000000000000001" : ] 000000545926656.570301000000000000 ; 000000561423356.937724000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000341049A358AA00 >									
	//     < RUSS_PFXVIII_I_metadata_line_38_____MIKA_PENSII_DAOPI_20211101 >									
	//        < Gun03c2Mn0Kse21c63TErI897jGHN04045Gf82Bu47coKAJnqvK6o5bcTtNr78ax >									
	//        <  u =="0.000000000000000001" : ] 000000561423356.937724000000000000 ; 000000575011929.125263000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000358AA0036D6609 >									
	//     < RUSS_PFXVIII_I_metadata_line_39_____MIKA_PENSII_DAC_20211101 >									
	//        < cz1qtCBx5OG49zJGhyvmwHos8PxY6k170W1p5T6LTc7AJx19xX5gi3n8s9m20p35 >									
	//        <  u =="0.000000000000000001" : ] 000000575011929.125263000000000000 ; 000000590400730.692894000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036D6609384E149 >									
	//     < RUSS_PFXVIII_I_metadata_line_40_____MIKA_PENSII_BIMI_20211101 >									
	//        < Clva2k5W5p9XaBdp9CDRt1QDq273BjU0CbBcPJN8XZ32bcHVm9ajcG7HEU6kW74O >									
	//        <  u =="0.000000000000000001" : ] 000000590400730.692894000000000000 ; 000000604142944.846810000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000384E149399D956 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}