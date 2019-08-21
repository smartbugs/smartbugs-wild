pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXII_III_883		"	;
		string	public		symbol =	"	RUSS_PFXXXII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1014664476197950000000000000					;	
										
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
	//     < RUSS_PFXXXII_III_metadata_line_1_____SOLLERS_20251101 >									
	//        < QB0WkDoK55Ye8nkH567c62I944krhB1zaS4UDXaac76dgecPnwpTnxfyG0a3Doil >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000020411808.213200000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001F255D >									
	//     < RUSS_PFXXXII_III_metadata_line_2_____UAZ_20251101 >									
	//        < A767aHWm01gL36h0p6vF4X3y5taA95a2et7r3W4Og2BfgO4bm2u0Eab2ksYZVIEA >									
	//        <  u =="0.000000000000000001" : ] 000000020411808.213200000000000000 ; 000000054233804.459359100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001F255D52C114 >									
	//     < RUSS_PFXXXII_III_metadata_line_3_____FORD_SOLLERS_20251101 >									
	//        < J53aUw5HWQ2txgH9nM573EaQ33pyb2bwvsKR03A0LWJ9P1DaSEGeScd63wBTjKsF >									
	//        <  u =="0.000000000000000001" : ] 000000054233804.459359100000000000 ; 000000079285051.072379400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000052C11478FAB9 >									
	//     < RUSS_PFXXXII_III_metadata_line_4_____URALAZ_20251101 >									
	//        < 2mo6hOdVaA6RSG3L0RvCvIm2F66UQm9zt6Oe52Ho8W6o73OCqMS6UmLMrI6hHirl >									
	//        <  u =="0.000000000000000001" : ] 000000079285051.072379400000000000 ; 000000113072838.467520000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000078FAB9AC8914 >									
	//     < RUSS_PFXXXII_III_metadata_line_5_____ZAVOLZHYE_ENGINE_FACTORY_20251101 >									
	//        < YJQgmcHIsntt2BcS0usa1oE8ImDz7n48ECl4ZFXrQFAdsR95NnK82k3zOut6Mus0 >									
	//        <  u =="0.000000000000000001" : ] 000000113072838.467520000000000000 ; 000000140151447.655070000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AC8914D5DAA9 >									
	//     < RUSS_PFXXXII_III_metadata_line_6_____ZMA_20251101 >									
	//        < EuUSij5oavIe1StYtHaz93yyct34Zo4z6Y418QY3pdatWF087JU6v675W3M4ia4C >									
	//        <  u =="0.000000000000000001" : ] 000000140151447.655070000000000000 ; 000000165634089.976039000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D5DAA9FCBCD1 >									
	//     < RUSS_PFXXXII_III_metadata_line_7_____MAZDA_MOTORS_MANUFACT_RUS_20251101 >									
	//        < ZjEn0vAWa3Oo5Juy99BoCP8ug02Ly6n98h7Q420HN3j61v3iXuRw25Vecp1FoHht >									
	//        <  u =="0.000000000000000001" : ] 000000165634089.976039000000000000 ; 000000190729925.956328000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FCBCD112307E1 >									
	//     < RUSS_PFXXXII_III_metadata_line_8_____REMSERVIS_20251101 >									
	//        < Av8dg50cA4QVlOJ3MygVI3051V9Y8E2u5I2g99cEg04DOyt23bNzFfl8KGB53N28 >									
	//        <  u =="0.000000000000000001" : ] 000000190729925.956328000000000000 ; 000000212756622.539535000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012307E1144A40E >									
	//     < RUSS_PFXXXII_III_metadata_line_9_____MAZDA_SOLLERS_JV_20251101 >									
	//        < V8ZN71SS8nO9BPxSumb0YkT759iD530hTkUhlsh8x2FkExV614uYY9I340685763 >									
	//        <  u =="0.000000000000000001" : ] 000000212756622.539535000000000000 ; 000000240299437.999191000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000144A40E16EAAF8 >									
	//     < RUSS_PFXXXII_III_metadata_line_10_____SEVERSTALAVTO_ZAO_20251101 >									
	//        < 6VJl2JXl78WFal3z7NqH50gEPk1eS1uNS1K1V5BjFToYkiBD49B2nH15emK5uOSy >									
	//        <  u =="0.000000000000000001" : ] 000000240299437.999191000000000000 ; 000000262491982.127573000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016EAAF819087EE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXII_III_metadata_line_11_____SEVERSTALAUTO_KAMA_20251101 >									
	//        < oe3OW4446Sxfz53sK72RH2USKn007mV028kt22cvuG932Q58fz9PdF8B7TK83RE9 >									
	//        <  u =="0.000000000000000001" : ] 000000262491982.127573000000000000 ; 000000281797085.567755000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019087EE1ADFCFD >									
	//     < RUSS_PFXXXII_III_metadata_line_12_____KAMA_ORG_20251101 >									
	//        < Dw6OrEn72t7sTh5DP333maIcymIZit5Jf85q6974pr0geAXBBCYJ584d1KHfU8Pi >									
	//        <  u =="0.000000000000000001" : ] 000000281797085.567755000000000000 ; 000000313874133.790690000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001ADFCFD1DEEF15 >									
	//     < RUSS_PFXXXII_III_metadata_line_13_____DALNIY_VOSTOK_20251101 >									
	//        < 96UVaKCrJbXp2910J4cML0W5IyPxtL17YPl084AzlO5HxTOkg33OaRYb14u4dt4n >									
	//        <  u =="0.000000000000000001" : ] 000000313874133.790690000000000000 ; 000000340370935.188923000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DEEF152075D66 >									
	//     < RUSS_PFXXXII_III_metadata_line_14_____DALNIY_ORG_20251101 >									
	//        < 1Qc9iI6PTiHjD0s0g92VeJY4H6JyEVbNrGFA77221r6Y9qd3HtfQR22glUCJQPC0 >									
	//        <  u =="0.000000000000000001" : ] 000000340370935.188923000000000000 ; 000000361851469.935255000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002075D66228243B >									
	//     < RUSS_PFXXXII_III_metadata_line_15_____SPECIAL_VEHICLES_OOO_20251101 >									
	//        < HqO1Bofo9QoDOp7wVGQ1hsiwgGE621uhXWFm6MlX55Kje296qdBzQFjVsPy6w2cf >									
	//        <  u =="0.000000000000000001" : ] 000000361851469.935255000000000000 ; 000000387186195.691127000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000228243B24ECC9C >									
	//     < RUSS_PFXXXII_III_metadata_line_16_____MAZDDA_SOLLERS_MANUFACT_RUS_20251101 >									
	//        < ZqV0D0yaT1I0XOtbF488bjMUjkQktD0IvkyLpdO26Qal8Ur6XN903PMa6lv8k3J9 >									
	//        <  u =="0.000000000000000001" : ] 000000387186195.691127000000000000 ; 000000418169947.955252000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024ECC9C27E13A3 >									
	//     < RUSS_PFXXXII_III_metadata_line_17_____TURIN_AUTO_OOO_20251101 >									
	//        < ZIQCuOmooKHb7wGw7fdHo8VyQG2ik4R0hR5T53335VX86sgWz90gLPVc51DVLR14 >									
	//        <  u =="0.000000000000000001" : ] 000000418169947.955252000000000000 ; 000000443260074.489246000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027E13A32A45C77 >									
	//     < RUSS_PFXXXII_III_metadata_line_18_____ZMZ_TRANSSERVICE_20251101 >									
	//        < S88s2vVantlXvPF90j72cJ2BFau3o5dC459jfX5OK382SkB9utRQ0t0RMXiJLymY >									
	//        <  u =="0.000000000000000001" : ] 000000443260074.489246000000000000 ; 000000465518192.930966000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A45C772C6530B >									
	//     < RUSS_PFXXXII_III_metadata_line_19_____SAPORT_OOO_20251101 >									
	//        < Ph41I4cd76ltP17v39Nxvh3cjApB703O9vOLXHd4Jfb7eKCTm8s03DIgFXwzrAvD >									
	//        <  u =="0.000000000000000001" : ] 000000465518192.930966000000000000 ; 000000486773925.534241000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C6530B2E6C211 >									
	//     < RUSS_PFXXXII_III_metadata_line_20_____TRANSPORTNIK_12_20251101 >									
	//        < 2D919eFYDir0bXTl759yzkUmI2I4p7ncR5zGtTU7268Us1OAe9EDyQJSHop9x05E >									
	//        <  u =="0.000000000000000001" : ] 000000486773925.534241000000000000 ; 000000512975493.163988000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E6C21130EBD0D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXII_III_metadata_line_21_____OOO_UAZ_TEKHINSTRUMENT_20251101 >									
	//        < 1Lp57G2qR6klPM6o04aNs3e3Jw5gW8xV836eORzkBPftVmm235mKZT8Y91az8uK6 >									
	//        <  u =="0.000000000000000001" : ] 000000512975493.163988000000000000 ; 000000533965050.951276000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030EBD0D32EC419 >									
	//     < RUSS_PFXXXII_III_metadata_line_22_____ZAO_KAPITAL_20251101 >									
	//        < u33571P51169GRAm20F5x6FmTuJt3l7AW92BGNfNne0wg68XQOxL71f91KafK93Y >									
	//        <  u =="0.000000000000000001" : ] 000000533965050.951276000000000000 ; 000000558300983.333920000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032EC419353E652 >									
	//     < RUSS_PFXXXII_III_metadata_line_23_____OOO_UAZ_DISTRIBUTION_CENTRE_20251101 >									
	//        < jnkk1cCE6X8f33xtGy3iCTI03z9SA1B671U78m37N61L34lz4uxNR9kQehGL6KFD >									
	//        <  u =="0.000000000000000001" : ] 000000558300983.333920000000000000 ; 000000585420808.298532000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000353E65237D4801 >									
	//     < RUSS_PFXXXII_III_metadata_line_24_____SHTAMP_20251101 >									
	//        < h1d8ReU9U5Z04pXMMG41PY2F311x4IFN5bycx5PwuD6OA274Ie8j3m40g2jmD6ea >									
	//        <  u =="0.000000000000000001" : ] 000000585420808.298532000000000000 ; 000000604499477.168302000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037D480139A649C >									
	//     < RUSS_PFXXXII_III_metadata_line_25_____SOLLERS_FINANS_20251101 >									
	//        < 9xp3cd1i8FX49Sdac2AdVLP9htEHAnK8uf04SZ2a6CMT8DqA7lYlQ6qJ18sl3LaG >									
	//        <  u =="0.000000000000000001" : ] 000000604499477.168302000000000000 ; 000000626592776.467805000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039A649C3BC1ACE >									
	//     < RUSS_PFXXXII_III_metadata_line_26_____SOLLERS_FINANCE_LLC_20251101 >									
	//        < 1i2Yz911JrC16IW51uC0u360tJs410Yci3O7qIs4O555s2m1oyr8ZSM6s3CZfDTr >									
	//        <  u =="0.000000000000000001" : ] 000000626592776.467805000000000000 ; 000000660287294.755474000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003BC1ACE3EF84B9 >									
	//     < RUSS_PFXXXII_III_metadata_line_27_____TORGOVIY_DOM_20251101 >									
	//        < rQE76S86PDaw3vVTuT01G54FC6WDxzM9gEYc918nnWb9MmvuoIRv5vG5F4r1735A >									
	//        <  u =="0.000000000000000001" : ] 000000660287294.755474000000000000 ; 000000690288757.197870000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003EF84B941D4C0C >									
	//     < RUSS_PFXXXII_III_metadata_line_28_____SOLLERS_BUSSAN_20251101 >									
	//        < r8U32IbS3nTOR3uOAIg4xkT762583509XmipPQgX0EB105UEozj043bhJ4qowDur >									
	//        <  u =="0.000000000000000001" : ] 000000690288757.197870000000000000 ; 000000714348134.106394000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041D4C0C442023D >									
	//     < RUSS_PFXXXII_III_metadata_line_29_____SEVERSTALAUTO_ISUZU_20251101 >									
	//        < ow4jGL24yX2xMwuS5HDuhjEDQtqgA11570rvmNj16Q1ZbOz53qkRlet6GrLREN8B >									
	//        <  u =="0.000000000000000001" : ] 000000714348134.106394000000000000 ; 000000743327638.713846000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000442023D46E3A5C >									
	//     < RUSS_PFXXXII_III_metadata_line_30_____SEVERSTALAUTO_ELABUGA_20251101 >									
	//        < f5QFaAgXoZfEVYtK7L6OVyLBr09X2C17tgAfqyjb3p8md79tj5600T6lU1q8IK2F >									
	//        <  u =="0.000000000000000001" : ] 000000743327638.713846000000000000 ; 000000765086415.999337000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046E3A5C48F6DE2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXII_III_metadata_line_31_____SOLLERS_DEVELOPMENT_20251101 >									
	//        < hm89kcwmX7x7tkIe121iPnBf660Y88S1201t6PrdkIdZTo82uhBviHlWa9K21941 >									
	//        <  u =="0.000000000000000001" : ] 000000765086415.999337000000000000 ; 000000783994008.956945000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048F6DE24AC47A9 >									
	//     < RUSS_PFXXXII_III_metadata_line_32_____TRADE_HOUSE_SOLLERS_OOO_20251101 >									
	//        < 2NcgjH9FZqT5l7I11ywUHGztL8qsjP7OV07qVghFuFWt6zd98wgyn60nkWUs63dz >									
	//        <  u =="0.000000000000000001" : ] 000000783994008.956945000000000000 ; 000000813164258.676340000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004AC47A94D8CA4A >									
	//     < RUSS_PFXXXII_III_metadata_line_33_____SEVERSTALAUTO_ELABUGA_LLC_20251101 >									
	//        < o260cQEi3hW4l8RV7pG90s7Q9rqZr2qE904a4Q2JcRtKl1649K0P01Ig5Yew7DFD >									
	//        <  u =="0.000000000000000001" : ] 000000813164258.676340000000000000 ; 000000845564889.605658000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004D8CA4A50A3AC9 >									
	//     < RUSS_PFXXXII_III_metadata_line_34_____SOLLERS_PARTNER_20251101 >									
	//        < 6HD39Pbj2BVrShl6a7X5260h31k03111Ed6c8j419q0f1AJ7QtWijeuT7300r6t8 >									
	//        <  u =="0.000000000000000001" : ] 000000845564889.605658000000000000 ; 000000877838162.557437000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000050A3AC953B7988 >									
	//     < RUSS_PFXXXII_III_metadata_line_35_____ULYANOVSK_CAR_PLANT_20251101 >									
	//        < zd8b564pHksp05Zer1uvh9nSiQv3pwXgVy9ye2E3a0GKV9EeN27r153xLmc1rPh3 >									
	//        <  u =="0.000000000000000001" : ] 000000877838162.557437000000000000 ; 000000901007478.681242000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000053B798855ED40C >									
	//     < RUSS_PFXXXII_III_metadata_line_36_____FPT_SOLLERS_OOO_20251101 >									
	//        < 4RNz8BkaLpXPch35RRD6lw0bKn4HM6kamfOiLmv4pPU8pLG6YF468n6Cl9Q9t2Z1 >									
	//        <  u =="0.000000000000000001" : ] 000000901007478.681242000000000000 ; 000000920764707.665833000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000055ED40C57CF9B7 >									
	//     < RUSS_PFXXXII_III_metadata_line_37_____OOO_SPECINSTRUMENT_20251101 >									
	//        < 5iZko5iT8rcfv1pn9c8W0Ghk6z8g1Uxs8aVmwshYhCJ9CqoX23WNE4EoTHAHqMIG >									
	//        <  u =="0.000000000000000001" : ] 000000920764707.665833000000000000 ; 000000946027326.155457000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000057CF9B75A385ED >									
	//     < RUSS_PFXXXII_III_metadata_line_38_____AVTOKOMPO_KOROBKA_PEREDACH_UZLY_TR_20251101 >									
	//        < HapG1yYeveeI6x791ZYakQZCnzP2pyGHOrq43Vaq4h837e50AY6e0dMD31DZ3K1h >									
	//        <  u =="0.000000000000000001" : ] 000000946027326.155457000000000000 ; 000000975477798.533991000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005A385ED5D07604 >									
	//     < RUSS_PFXXXII_III_metadata_line_39_____KOLOMYAZHSKOM_AUTOCENTRE_OOO_20251101 >									
	//        < aU7ZN1gO6a4PXi43SRCkBMtxKcsAd7dIYwY6ZFmRrhCqtmhtr67K68jQqu8z1U79 >									
	//        <  u =="0.000000000000000001" : ] 000000975477798.533991000000000000 ; 000000995608251.814218000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005D076045EF2D79 >									
	//     < RUSS_PFXXXII_III_metadata_line_40_____ROSALIT_20251101 >									
	//        < o7LaVQi75ZOGytYs6Lxs31HHOplNae29X9p8oyiUY4VME1YjsmYMXp0cY5H6bDpn >									
	//        <  u =="0.000000000000000001" : ] 000000995608251.814218000000000000 ; 000001014664476.197950000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005EF2D7960C4150 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}