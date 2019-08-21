pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXV_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXV_I_883		"	;
		string	public		symbol =	"	RUSS_PFXV_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		613997134018603000000000000					;	
										
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
	//     < RUSS_PFXV_I_metadata_line_1_____POLYMETAL_20211101 >									
	//        < wQ8fudfviVXn7Tnk8qtXaffgATTj6396DgBWVy8zU2p3z5g8QR57cLv7iDb1tvJ0 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000016424582.865973100000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000190FDA >									
	//     < RUSS_PFXV_I_metadata_line_2_____POLYMETAL_GBP_20211101 >									
	//        < QxWP0uYQp25BVkVJ0WJ3a9NV7du8JxB5rr6rDA6vZkVdbCgSzt2z4v5Kgialz9a5 >									
	//        <  u =="0.000000000000000001" : ] 000000016424582.865973100000000000 ; 000000031281695.212333800000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000190FDA2FBB6A >									
	//     < RUSS_PFXV_I_metadata_line_3_____POLYMETAL_USD_20211101 >									
	//        < FZ8U1XYCJe2N0AWOrvA80DdEF3xp9aiV35tQu1n2JrP21fG21RHP13j4UXZfg98f >									
	//        <  u =="0.000000000000000001" : ] 000000031281695.212333800000000000 ; 000000046757277.559557500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002FBB6A475890 >									
	//     < RUSS_PFXV_I_metadata_line_4_____POLYMETAL_ORG_20211101 >									
	//        < 7Mok1CiRH29E5S7Cn40MR8rFdUhu17PoxyI5EnmTYhYfR7c93aG8vKB5ZfchY4zX >									
	//        <  u =="0.000000000000000001" : ] 000000046757277.559557500000000000 ; 000000061626945.326917700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004758905E0907 >									
	//     < RUSS_PFXV_I_metadata_line_5_____POLYMETAL_DAO_20211101 >									
	//        < 8Bk749F538kuKS9r48E56UtD7KkcF4qT7EJJdd8tiG7NC4M62DG8Bp592d68Y63b >									
	//        <  u =="0.000000000000000001" : ] 000000061626945.326917700000000000 ; 000000076946204.851110200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005E090775691C >									
	//     < RUSS_PFXV_I_metadata_line_6_____POLYMETAL_DAC_20211101 >									
	//        < Jw7T68vx9v4tceCcR6VS39ZNTULd5nZS2Eyxsk1deQjVb2atiy676UxEWf4U0mn7 >									
	//        <  u =="0.000000000000000001" : ] 000000076946204.851110200000000000 ; 000000092903348.960087900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000075691C8DC25F >									
	//     < RUSS_PFXV_I_metadata_line_7_____PPF_GROUP_RUB_20211101 >									
	//        < jHWrwa95x4Tm6grjpNWa00d9e2DOD50Zwb1232CX534DHrRdLVK0mdorurf54nkT >									
	//        <  u =="0.000000000000000001" : ] 000000092903348.960087900000000000 ; 000000109288010.662260000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008DC25FA6C2A1 >									
	//     < RUSS_PFXV_I_metadata_line_8_____PPF_GROUP_RUB_AB_20211101 >									
	//        < TANowkT3ymhL6ilDJxJ73Oa21w72amZ0vtup3Xu9qpw48gf1ppVD5zMp8HUO0A29 >									
	//        <  u =="0.000000000000000001" : ] 000000109288010.662260000000000000 ; 000000125687571.849210000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A6C2A1BFC8B5 >									
	//     < RUSS_PFXV_I_metadata_line_9_____ICT_GROUP_20211101 >									
	//        < F7mpOk3USfX1gbRF2w6cORC6jx8M4bt368cb24PYM9cgNv4hqHEbfq1FfYbQsNcP >									
	//        <  u =="0.000000000000000001" : ] 000000125687571.849210000000000000 ; 000000141040946.104540000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BFC8B5D7361F >									
	//     < RUSS_PFXV_I_metadata_line_10_____ICT_GROUP_ORG_20211101 >									
	//        < r5ET6owwz3BXZNG721jBzNZ4Pru9a12bQok0kicBc6y7cOmvn109WIc8bkqTrj79 >									
	//        <  u =="0.000000000000000001" : ] 000000141040946.104540000000000000 ; 000000155107974.050185000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D7361FECAD0D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXV_I_metadata_line_11_____ENISEYSKAYA_1_ORG_20211101 >									
	//        < 7O46En2rwNVhujeL52FmLyx2dB6lCl1oLs2vVtvZvtj4xq0SH6rysrOoWZ685669 >									
	//        <  u =="0.000000000000000001" : ] 000000155107974.050185000000000000 ; 000000169138329.894194000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000ECAD0D10215A9 >									
	//     < RUSS_PFXV_I_metadata_line_12_____ENISEYSKAYA_1_DAO_20211101 >									
	//        < 96j0h8a3n32Ea8r6Pyfvi1iZd3J2fyBWo09tCb6AwkCWm1dT5P5ORu0g2Ufbboer >									
	//        <  u =="0.000000000000000001" : ] 000000169138329.894194000000000000 ; 000000185815284.697002000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010215A911B8818 >									
	//     < RUSS_PFXV_I_metadata_line_13_____ENISEYSKAYA_1_DAOPI_20211101 >									
	//        < DV9d0Z6c0Ci8F69mdtc6ZdyT62tG73RQNcm3NPfMsld573qWQs62XofauxmGtX63 >									
	//        <  u =="0.000000000000000001" : ] 000000185815284.697002000000000000 ; 000000202231618.806737000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011B881813494BA >									
	//     < RUSS_PFXV_I_metadata_line_14_____ENISEYSKAYA_1_DAC_20211101 >									
	//        < n9o56DzCJaerVd6OX2461ILf3PQQvB1j83OtwvZkPxVG60zZN6qU5x5mo8H1C33m >									
	//        <  u =="0.000000000000000001" : ] 000000202231618.806737000000000000 ; 000000218445562.627732000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013494BA14D524C >									
	//     < RUSS_PFXV_I_metadata_line_15_____ENISEYSKAYA_1_BIMI_20211101 >									
	//        < d0NSmg1QUVS05Svh04ID6h2AIs75Vxbt9sQ3G04zYgiJpp5y4dZG9uGUmbv8T4xN >									
	//        <  u =="0.000000000000000001" : ] 000000218445562.627732000000000000 ; 000000233882962.911607000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014D524C164E088 >									
	//     < RUSS_PFXV_I_metadata_line_16_____ENISEYSKAYA_2_ORG_20211101 >									
	//        < 1Mwm4Gv7oW31F6kQi4EZs7ke2e7Vjey1OjrXR1OInAKdT85GntfJ03n70Je7nNbx >									
	//        <  u =="0.000000000000000001" : ] 000000233882962.911607000000000000 ; 000000250047864.246865000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000164E08817D8AF2 >									
	//     < RUSS_PFXV_I_metadata_line_17_____ENISEYSKAYA_2_DAO_20211101 >									
	//        < 5sl1mJXfSsXfbvr88zGbV3p3W5EsP7JM4nH489V2dF3e44bNW39g2Q9G63kLNef9 >									
	//        <  u =="0.000000000000000001" : ] 000000250047864.246865000000000000 ; 000000263612736.193668000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017D8AF21923DBA >									
	//     < RUSS_PFXV_I_metadata_line_18_____ENISEYSKAYA_2_DAOPI_20211101 >									
	//        < aK07fRL7AT89Jz5E950oRV4zcH43X98bVha8DoMovAJ07r53tp6rxgGrAPSHGTp6 >									
	//        <  u =="0.000000000000000001" : ] 000000263612736.193668000000000000 ; 000000277962074.213674000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001923DBA1A822EF >									
	//     < RUSS_PFXV_I_metadata_line_19_____ENISEYSKAYA_2_DAC_20211101 >									
	//        < EoyLhTc5fz4ohaIizR5t81FnaUi8DF8XNxT0BNX8IF4u0Z6oQT1vB0Iw8zABrD2h >									
	//        <  u =="0.000000000000000001" : ] 000000277962074.213674000000000000 ; 000000293347164.438231000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A822EF1BF9CBC >									
	//     < RUSS_PFXV_I_metadata_line_20_____ENISEYSKAYA_2_BIMI_20211101 >									
	//        < qhrBDQWXOgD11C8bpKY3tu79o25F74hbq9yZXWEZ4gxu38m1f5ItfdZQ2jwX8b9h >									
	//        <  u =="0.000000000000000001" : ] 000000293347164.438231000000000000 ; 000000306563375.135059000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BF9CBC1D3C752 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXV_I_metadata_line_21_____YENISEISKAYA_GTK_1_ORG_20211101 >									
	//        < k927ZM1997qBcssb1N25t2hxJJ3ya4Or5TK34S3Tfn2vwUMm8ObB4vgYD2HRh8VY >									
	//        <  u =="0.000000000000000001" : ] 000000306563375.135059000000000000 ; 000000322964715.320743000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D3C7521ECCE18 >									
	//     < RUSS_PFXV_I_metadata_line_22_____YENISEISKAYA_GTK_1_DAO_20211101 >									
	//        < f7mfxYCZ4c17vmOE2r9mF8VqMrRcI39WW16004wLBm4aEN0MHk5z33f9glZ1yRJG >									
	//        <  u =="0.000000000000000001" : ] 000000322964715.320743000000000000 ; 000000340113445.947355000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001ECCE18206F8D1 >									
	//     < RUSS_PFXV_I_metadata_line_23_____YENISEISKAYA_GTK_1_DAOPI_20211101 >									
	//        < 375LD0QRZmyTOc8hAGhTJd9m3rqyvEa9B99NfmCfStM9Y84V6aY1C67R0p6T81GI >									
	//        <  u =="0.000000000000000001" : ] 000000340113445.947355000000000000 ; 000000355663716.767617000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000206F8D121EB324 >									
	//     < RUSS_PFXV_I_metadata_line_24_____YENISEISKAYA_GTK_1_DAC_20211101 >									
	//        < D8y9FlQn0x25kYqXYi24n38Tt00iEw7FjNNsn48Yzi7bW16HG8ZMK08LuGPHw2Jh >									
	//        <  u =="0.000000000000000001" : ] 000000355663716.767617000000000000 ; 000000372372304.601126000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021EB32423831EE >									
	//     < RUSS_PFXV_I_metadata_line_25_____YENISEISKAYA_GTK_1_BIMI_20211101 >									
	//        < ekD69F8JXDn6n4uX84ep45S03py5dCj0rk8iMp5DThIXJ9hfYj6TBVrjTKNNCev6 >									
	//        <  u =="0.000000000000000001" : ] 000000372372304.601126000000000000 ; 000000389219464.012577000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023831EE251E6DA >									
	//     < RUSS_PFXV_I_metadata_line_26_____YENISEISKAYA_GTK_2_ORG_20211101 >									
	//        < m4O6v17P6tot1zO51g3OV3L257LX58LLmFxwWYtF6VKDw25h6vDCK365IHJcV726 >									
	//        <  u =="0.000000000000000001" : ] 000000389219464.012577000000000000 ; 000000406063395.063456000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000251E6DA26B9A84 >									
	//     < RUSS_PFXV_I_metadata_line_27_____YENISEISKAYA_GTK_2_DAO_20211101 >									
	//        < 6vV6c4p7TaF1PxL1A7d54IFhzEartWx33PPC0GpoZ21GiWwRwQ283Hl3AvbPB66Q >									
	//        <  u =="0.000000000000000001" : ] 000000406063395.063456000000000000 ; 000000423340524.582415000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026B9A84285F764 >									
	//     < RUSS_PFXV_I_metadata_line_28_____YENISEISKAYA_GTK_2_DAOPI_20211101 >									
	//        < RVCye9fU8NDoe6VO4fRN7hS92k4gPg7IdB3489ys8NFUF2GA8hV3G4NQ5a3xsxN5 >									
	//        <  u =="0.000000000000000001" : ] 000000423340524.582415000000000000 ; 000000439205940.832589000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000285F76429E2CD2 >									
	//     < RUSS_PFXV_I_metadata_line_29_____YENISEISKAYA_GTK_2_DAC_20211101 >									
	//        < Y58BH9h9Zjl82U7X55z0TdMB1FUdWFdA7He6RQ4Vt8NlDY7R0C3h74mVd5SUBsz8 >									
	//        <  u =="0.000000000000000001" : ] 000000439205940.832589000000000000 ; 000000453420221.106103000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029E2CD22B3DD46 >									
	//     < RUSS_PFXV_I_metadata_line_30_____YENISEISKAYA_GTK_2_BIMI_20211101 >									
	//        < p8Ewo81APt9O4uwZ8MDmGDbnL90x0o4g86H6BCmC0T66q03yxMMT2L3jYK4n3aL9 >									
	//        <  u =="0.000000000000000001" : ] 000000453420221.106103000000000000 ; 000000467227938.857222000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B3DD462C8EEEA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXV_I_metadata_line_31_____ZAO_ENISEY_MINING_GEOLOGIC_CO_1_ORG_20211101 >									
	//        < Fg2HMod244x67d2Y0Gun46Ymyx9E976B80xrS027nRPFl5R4FRZQo0i5H53Ko63y >									
	//        <  u =="0.000000000000000001" : ] 000000467227938.857222000000000000 ; 000000481237441.048791000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C8EEEA2DE4F60 >									
	//     < RUSS_PFXV_I_metadata_line_32_____ZAO_ENISEY_MINING_GEOLOGIC_CO_1_DAO_20211101 >									
	//        < VsJ4OqedBKmcm23T7XhgLwNMExS0sxFN60l6L0aX65Rpwt3gzM71bGD9W5t9Uphs >									
	//        <  u =="0.000000000000000001" : ] 000000481237441.048791000000000000 ; 000000494274973.921026000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DE4F602F23429 >									
	//     < RUSS_PFXV_I_metadata_line_33_____ZAO_ENISEY_MINING_GEOLOGIC_CO_1_DAOPI_20211101 >									
	//        < t812PD6Q03OGYSfh5y05b9Gdnvq5EonT7E19Edzo7z4BK47MA5md8317poA5mJ02 >									
	//        <  u =="0.000000000000000001" : ] 000000494274973.921026000000000000 ; 000000508349409.730517000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F23429307ADFD >									
	//     < RUSS_PFXV_I_metadata_line_34_____ZAO_ENISEY_MINING_GEOLOGIC_CO_1_DAC_20211101 >									
	//        < C8rnKXp7HMkb3vqWnpoEuH3u8qBSq4lm6tTPKt90u4RiKrxYZ66KwNwU45qAdoE7 >									
	//        <  u =="0.000000000000000001" : ] 000000508349409.730517000000000000 ; 000000522736936.438777000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000307ADFD31DA21E >									
	//     < RUSS_PFXV_I_metadata_line_35_____ZAO_ENISEY_MINING_GEOLOGIC_CO_1_BIMI_20211101 >									
	//        < 03R9Y6E24wQTD571P64PT9j16eM5Co74bCFyKKXta557MH5PzOjsPOZH14eR2bQv >									
	//        <  u =="0.000000000000000001" : ] 000000522736936.438777000000000000 ; 000000539027609.148154000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031DA21E3367DA9 >									
	//     < RUSS_PFXV_I_metadata_line_36_____ZAO_ENISEY_MINING_GEOLOGIC_CO_2_ORG_20211101 >									
	//        < MWVKGG4cy3d9s78T64nUlrE2wIlOA1R0MMttk4p0H3y21APdkLBL8NKa97bbJcev >									
	//        <  u =="0.000000000000000001" : ] 000000539027609.148154000000000000 ; 000000552478932.249207000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003367DA934B0415 >									
	//     < RUSS_PFXV_I_metadata_line_37_____ZAO_ENISEY_MINING_GEOLOGIC_CO_2_DAO_20211101 >									
	//        < WD7a1TcHetuBuvdg49364u9EA8DsgybbLb47oWoQKcrq3fMcp2DMJxW01ZLcS7A6 >									
	//        <  u =="0.000000000000000001" : ] 000000552478932.249207000000000000 ; 000000566235429.267452000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034B041536001B7 >									
	//     < RUSS_PFXV_I_metadata_line_38_____ZAO_ENISEY_MINING_GEOLOGIC_CO_2_DAOPI_20211101 >									
	//        < Nj5tYKw1qfzm99ElEFmq9wY10E2aO9W9z45vO30SQyk7hs2uAo4Qr3fIJ9oD3d91 >									
	//        <  u =="0.000000000000000001" : ] 000000566235429.267452000000000000 ; 000000582694466.688049000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036001B73791F07 >									
	//     < RUSS_PFXV_I_metadata_line_39_____ZAO_ENISEY_MINING_GEOLOGIC_CO_2_DAC_20211101 >									
	//        < 1AZ04l80TRMx048N2Akax9h2ej32QmPLADsbb49UdpyBSDvR4ghOTXK0yGI03HiG >									
	//        <  u =="0.000000000000000001" : ] 000000582694466.688049000000000000 ; 000000599761372.605876000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003791F0739329C9 >									
	//     < RUSS_PFXV_I_metadata_line_40_____ZAO_ENISEY_MINING_GEOLOGIC_CO_2_BIMI_20211101 >									
	//        < M8Z19r1s5u6X277wcA7z6dN75p2ShORCuz40VC5YseXaE93wn6euMsgeeumPEEAm >									
	//        <  u =="0.000000000000000001" : ] 000000599761372.605876000000000000 ; 000000613997134.018603000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039329C93A8E2A1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}