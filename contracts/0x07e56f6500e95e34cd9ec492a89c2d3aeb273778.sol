pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXIII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXIII_II_883		"	;
		string	public		symbol =	"	RUSS_PFXXIII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		791054062628871000000000000					;	
										
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
	//     < RUSS_PFXXIII_II_metadata_line_1_____INGOSSTRAKH_20231101 >									
	//        < Yb8b5ZNeYqqlS4gG0EzMihjrYD8Sz3ZHwyli03nSn0YLoziKEgn9m1Jpk8WX79ID >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000021390875.788806200000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000020A3D0 >									
	//     < RUSS_PFXXIII_II_metadata_line_2_____ROSGOSSTRAKH_20231101 >									
	//        < 49URWS20j48x0eL4OoXIxo63ZPliJr4oviF8Jloz8x8am8j4xsHpOpQnyohG6Na0 >									
	//        <  u =="0.000000000000000001" : ] 000000021390875.788806200000000000 ; 000000040674670.975760100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000020A3D03E108B >									
	//     < RUSS_PFXXIII_II_metadata_line_3_____TINKOFF_INSURANCE_20231101 >									
	//        < PBc4JO8I4bd67Vxt30avRe38i6mOO1zVh4bNxYi91KqE4PB3915PiJTeQ3ibbds5 >									
	//        <  u =="0.000000000000000001" : ] 000000040674670.975760100000000000 ; 000000056373689.613101400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003E108B5604F9 >									
	//     < RUSS_PFXXIII_II_metadata_line_4_____MOSCOW_EXCHANGE_20231101 >									
	//        < 8Cm0zo6JqXS78XCJcVg6GKVDT27a8GlMfyy5ensbm874iu7B16F52HXsO9t0z1qS >									
	//        <  u =="0.000000000000000001" : ] 000000056373689.613101400000000000 ; 000000079090104.784310100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005604F978AE92 >									
	//     < RUSS_PFXXIII_II_metadata_line_5_____YANDEX_20231101 >									
	//        < rZBoq37f4h9PbfloYDx3wGna1FCx7nKs9wVyb7ss5RT4G64n0oEcuv81tN7khnP5 >									
	//        <  u =="0.000000000000000001" : ] 000000079090104.784310100000000000 ; 000000096964181.889822700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000078AE9293F4A2 >									
	//     < RUSS_PFXXIII_II_metadata_line_6_____UNIPRO_20231101 >									
	//        < OYaJ1f6Ydx64f1GZ2PCr6f827AyG87mRd0d2nd532E5SgZ2ZVRL4k5JXglnUK42n >									
	//        <  u =="0.000000000000000001" : ] 000000096964181.889822700000000000 ; 000000112738294.547464000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000093F4A2AC0665 >									
	//     < RUSS_PFXXIII_II_metadata_line_7_____DIXY_20231101 >									
	//        < 8luSgu1F8lXfwI4qKZO9GA2W44ic7d47NifLUsc7tR85WuA14sNRtU326Y6b9ZY3 >									
	//        <  u =="0.000000000000000001" : ] 000000112738294.547464000000000000 ; 000000133451358.181861000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AC0665CBA170 >									
	//     < RUSS_PFXXIII_II_metadata_line_8_____MECHEL_20231101 >									
	//        < wLM15aG0fvm209lQF8jkfwyX7r0zZb0jrzaXU75fXZRlu6AG4JlYU0MlMkp6bdh0 >									
	//        <  u =="0.000000000000000001" : ] 000000133451358.181861000000000000 ; 000000149554907.027674000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CBA170E433E3 >									
	//     < RUSS_PFXXIII_II_metadata_line_9_____VSMPO_AVISMA_20231101 >									
	//        < VZPe4Hq31265GInwax74zAOk5h7dpIQA1IB76746jNjRB6hiw0XVpf4e69hM0JV8 >									
	//        <  u =="0.000000000000000001" : ] 000000149554907.027674000000000000 ; 000000174297061.273001000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E433E3109F4CA >									
	//     < RUSS_PFXXIII_II_metadata_line_10_____AGRIUM_20231101 >									
	//        < aT6h8yLs78kR1gWw69dZ58fIT0YGSGA63Jm2T8E5v6ovU73V5iqgPZ6771Hh6mx5 >									
	//        <  u =="0.000000000000000001" : ] 000000174297061.273001000000000000 ; 000000195434719.231910000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000109F4CA12A35B0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXIII_II_metadata_line_11_____ONEXIM_20231101 >									
	//        < 4lE9sLA9o75240Ts6G99CuS0mmQc7645WA765b8WsUM2XIvoXJ6n6Gzs8UD50DHM >									
	//        <  u =="0.000000000000000001" : ] 000000195434719.231910000000000000 ; 000000219159021.345208000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012A35B014E68FE >									
	//     < RUSS_PFXXIII_II_metadata_line_12_____SILOVYE_MACHINY_20231101 >									
	//        < ka90a96F73B99tryNRE3pMJst9mikFgLMjJk1Z47m65Qs791qHiG6Cvj6UOooNF3 >									
	//        <  u =="0.000000000000000001" : ] 000000219159021.345208000000000000 ; 000000242820701.146544000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014E68FE17283D6 >									
	//     < RUSS_PFXXIII_II_metadata_line_13_____RPC_UWC_20231101 >									
	//        < LH9e6Y0PyoEmWi6CplHwq1uJ30kMws52eHyPAk4RIF29jWcYdkz7Ptl3Q438JVo2 >									
	//        <  u =="0.000000000000000001" : ] 000000242820701.146544000000000000 ; 000000265054493.169817000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017283D619470E9 >									
	//     < RUSS_PFXXIII_II_metadata_line_14_____INTERROS_20231101 >									
	//        < OwnOwAIBzZ4T9M7mpXDhN5Kb2Kl5mlzcRF77h0N87b5yuFYM5T20l61CDTHu207T >									
	//        <  u =="0.000000000000000001" : ] 000000265054493.169817000000000000 ; 000000282312540.984691000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019470E91AEC656 >									
	//     < RUSS_PFXXIII_II_metadata_line_15_____PROF_MEDIA_20231101 >									
	//        < 3v6OA4q5ZFq7F57fG4pl4BSWBtDDc5R8dWy26j7NzupVmRM65e5v3XBxx1z6j7tr >									
	//        <  u =="0.000000000000000001" : ] 000000282312540.984691000000000000 ; 000000304356094.873364000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AEC6561D06919 >									
	//     < RUSS_PFXXIII_II_metadata_line_16_____ACRON_GROUP_20231101 >									
	//        < XGgMLp2W9aHCAs7fzHL8Gd42L491MNsVouW5939PqKbn1CkOV5s0v8Sz5ZbhBr0r >									
	//        <  u =="0.000000000000000001" : ] 000000304356094.873364000000000000 ; 000000323820378.803017000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D069191EE1C56 >									
	//     < RUSS_PFXXIII_II_metadata_line_17_____RASSVET_20231101 >									
	//        < Sirl99C8E8jX2qtZSBzQ0604ZEO30O216B0miMIQ285W5UvNtQ689896g66CNgzd >									
	//        <  u =="0.000000000000000001" : ] 000000323820378.803017000000000000 ; 000000341177812.366576000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EE1C562089895 >									
	//     < RUSS_PFXXIII_II_metadata_line_18_____LUZHSKIY_KOMBIKORMOVIY_ZAVOD_20231101 >									
	//        < 758IkEZI8wh1SW5s8MkTAL9H9iCOI6UmxE7x50kmNW76OD133T39AcI1y3zukBrM >									
	//        <  u =="0.000000000000000001" : ] 000000341177812.366576000000000000 ; 000000356776839.439365000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000208989522065F4 >									
	//     < RUSS_PFXXIII_II_metadata_line_19_____LSR GROUP_20231101 >									
	//        < pQt10RByiJLlO1L07dD1NU0l7Dg2H14vz0mS0IfDhVVV7VHmrCh3mNdaCy0uKoL2 >									
	//        <  u =="0.000000000000000001" : ] 000000356776839.439365000000000000 ; 000000375382992.313530000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022065F423CC9FB >									
	//     < RUSS_PFXXIII_II_metadata_line_20_____MMK_20231101 >									
	//        < 6Oq4NrwkcPuL5o6l7O8g4C7t7VgMIOp3OHDgea86fvzd377kP1G0FRs3VwYpdgBU >									
	//        <  u =="0.000000000000000001" : ] 000000375382992.313530000000000000 ; 000000392937542.607363000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023CC9FB257933A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXIII_II_metadata_line_21_____MOESK_20231101 >									
	//        < jECN4vMhq7q8qlfHC4P8i5guk7smNqR8d0w31c1XD799560Swe93lSRyc3qve369 >									
	//        <  u =="0.000000000000000001" : ] 000000392937542.607363000000000000 ; 000000409997704.030808000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000257933A2719B5A >									
	//     < RUSS_PFXXIII_II_metadata_line_22_____MOSTOTREST_20231101 >									
	//        < Nz5V06W8YGF5pqYlE7dU1d2b3xgc1R19L7C2LSqGqb12F3AoLW790674cSYc3JLa >									
	//        <  u =="0.000000000000000001" : ] 000000409997704.030808000000000000 ; 000000433665683.435964000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002719B5A295B8A8 >									
	//     < RUSS_PFXXIII_II_metadata_line_23_____MVIDEO_20231101 >									
	//        < F3LR8CoJQv1HjsyEG20g337qx0m8h9S0tj6Vr7P6xonO769Lc8w2KihkPbEyRJ6m >									
	//        <  u =="0.000000000000000001" : ] 000000433665683.435964000000000000 ; 000000456454358.241482000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000295B8A82B87E7C >									
	//     < RUSS_PFXXIII_II_metadata_line_24_____NCSP_20231101 >									
	//        < 3r8t0a4gD08n3udPR374C8hUIr1tmybxsM40D5c4NEV1UoBxznPvMz1lXuv5B2RP >									
	//        <  u =="0.000000000000000001" : ] 000000456454358.241482000000000000 ; 000000475724887.485592000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B87E7C2D5E609 >									
	//     < RUSS_PFXXIII_II_metadata_line_25_____MOSAIC_COMPANY_20231101 >									
	//        < CjakSvYCxp4ei11X3M4cvDY9jGzOvi2ILx1h4Yb2kX1699SOIL982f8Y83QiN4lc >									
	//        <  u =="0.000000000000000001" : ] 000000475724887.485592000000000000 ; 000000491881544.310963000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D5E6092EE8D3A >									
	//     < RUSS_PFXXIII_II_metadata_line_26_____METALLOINVEST_20231101 >									
	//        < 3fxNyPAFLdQVX5DG7cLys86J68qv2brbq1Bc5whFe8DCEog9GuXI2OvfCSSO1vHd >									
	//        <  u =="0.000000000000000001" : ] 000000491881544.310963000000000000 ; 000000511752004.230806000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EE8D3A30CDF20 >									
	//     < RUSS_PFXXIII_II_metadata_line_27_____TOGLIATTIAZOT_20231101 >									
	//        < 2z3HS29piQ26JDl83bnZL7Pni805Y5An6550lr40QF1tBPBNfBIMxr903LXoky25 >									
	//        <  u =="0.000000000000000001" : ] 000000511752004.230806000000000000 ; 000000530867729.969143000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030CDF2032A0A35 >									
	//     < RUSS_PFXXIII_II_metadata_line_28_____METAFRAKS_PAO_20231101 >									
	//        < qT381J576Eo8tC572uE4MzyxsX47i0sldG8N9XaI89OpvOFe5ZQ81S5izuXCg963 >									
	//        <  u =="0.000000000000000001" : ] 000000530867729.969143000000000000 ; 000000551428889.076206000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032A0A3534969E9 >									
	//     < RUSS_PFXXIII_II_metadata_line_29_____OGK_2_CHEREPOVETS_GRES_20231101 >									
	//        < fo9sOG2n8rKD05QZHMhF2TgcpUW1eCtXAHaUk07nS1Tsn665lj32jBEew9lRtIl0 >									
	//        <  u =="0.000000000000000001" : ] 000000551428889.076206000000000000 ; 000000574648791.642141000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034969E936CD82F >									
	//     < RUSS_PFXXIII_II_metadata_line_30_____OGK_2_GRES_24_20231101 >									
	//        < dNs3t4RTSBGE415BkT8K4NU212mkIMWh4W5qwnGo2wZR4y77MCa2571l551FyL8a >									
	//        <  u =="0.000000000000000001" : ] 000000574648791.642141000000000000 ; 000000592089577.362038000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036CD82F38774FE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXIII_II_metadata_line_31_____PHOSAGRO_20231101 >									
	//        < 5f0lSmzpa4k3CNXv38d1t4M716rTUCCELbFEyykV7yolCH3nhw1cJwCzo3p0E0lm >									
	//        <  u =="0.000000000000000001" : ] 000000592089577.362038000000000000 ; 000000616406147.652264000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038774FE3AC8FA7 >									
	//     < RUSS_PFXXIII_II_metadata_line_32_____BELARUSKALI_20231101 >									
	//        < 6g8B5tCM354zsPwND4z3ocPgbv9GU5s4OdAZ72WHVhSgn97T2j7ZyAH9i40Lb4JP >									
	//        <  u =="0.000000000000000001" : ] 000000616406147.652264000000000000 ; 000000635986297.642095000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003AC8FA73CA7026 >									
	//     < RUSS_PFXXIII_II_metadata_line_33_____KPLUSS_20231101 >									
	//        < est6lzn1v1o538k882OJ197cJ9F7uZsD4hCapcxkak2JkPjhan4cSY342bBjhg2p >									
	//        <  u =="0.000000000000000001" : ] 000000635986297.642095000000000000 ; 000000660286644.379225000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003CA70263EF8478 >									
	//     < RUSS_PFXXIII_II_metadata_line_34_____KPLUSS_ORG_20231101 >									
	//        < qXe3N062guK8C9L45A6VXjMhJ5N4UopifPkgAceLoS5Lpd1agDUEfPCj21rZVL49 >									
	//        <  u =="0.000000000000000001" : ] 000000660286644.379225000000000000 ; 000000679467973.839903000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003EF847840CC92D >									
	//     < RUSS_PFXXIII_II_metadata_line_35_____POTASHCORP_20231101 >									
	//        < z785ztKQ01Q1FqbVkGYbUPzs8zkUZ1kyoG0e6n0u4283vI2CUQI1Ls41f175XXXr >									
	//        <  u =="0.000000000000000001" : ] 000000679467973.839903000000000000 ; 000000697363243.296583000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040CC92D4281784 >									
	//     < RUSS_PFXXIII_II_metadata_line_36_____BANK_URALSIB_20231101 >									
	//        < H2lvA5675jYo2JQA43TS1CrYU5d0H8sySnZVo0t29AoVuF03V18W11Qcj0DNYT5I >									
	//        <  u =="0.000000000000000001" : ] 000000697363243.296583000000000000 ; 000000716046787.501872000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000428178444499C7 >									
	//     < RUSS_PFXXIII_II_metadata_line_37_____URALSIB_LEASING_CO_20231101 >									
	//        < q33OZwwOAPRk7uG199nA6xPvlBEiYST89N7SERtB72BKdad4K4h4CEtDFbP162Dq >									
	//        <  u =="0.000000000000000001" : ] 000000716046787.501872000000000000 ; 000000736502691.629338000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044499C7463D05D >									
	//     < RUSS_PFXXIII_II_metadata_line_38_____BANK_URALSIB_AM_20231101 >									
	//        < O4Gb1uA8Uoz9Xbkj17Vsz27a1eYfhBk10n5KbrA3lEs5e1tc67bD21g80x9YB0ia >									
	//        <  u =="0.000000000000000001" : ] 000000736502691.629338000000000000 ; 000000755281935.450659000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000463D05D4807802 >									
	//     < RUSS_PFXXIII_II_metadata_line_39_____BASHKIRSKIY_20231101 >									
	//        < OsrE9ifA9cK4j7wg4WjP06p5Me6O7Ux13bm0i8u0wOFrPCy3AWH6QKGW7i9hnges >									
	//        <  u =="0.000000000000000001" : ] 000000755281935.450659000000000000 ; 000000771923414.709475000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004807802499DC95 >									
	//     < RUSS_PFXXIII_II_metadata_line_40_____URALSIB_INVESTMENT_ARM_20231101 >									
	//        < P1rF096g3m8rgFS4VfagO6L7Ib2aqo93Rz0gn51HzX8TYc189rSnU8r20gcYwv6Q >									
	//        <  u =="0.000000000000000001" : ] 000000771923414.709475000000000000 ; 000000791054062.628871000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000499DC954B70D7E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}