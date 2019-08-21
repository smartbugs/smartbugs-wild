pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXVIII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXVIII_II_883		"	;
		string	public		symbol =	"	RUSS_PFXXXVIII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		821170410821043000000000000					;	
										
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
	//     < RUSS_PFXXXVIII_II_metadata_line_1_____AgroCenter_Ukraine_20231101 >									
	//        < H0ctP38J3gsZISkxAZrMagEi6FL0lw9KWUp0RVMS4R5Bi9W7QsbMAg4kUxRgo578 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000021030904.691012100000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000201732 >									
	//     < RUSS_PFXXXVIII_II_metadata_line_2_____Ural_RemStroiService_20231101 >									
	//        < aq3wKkrkoG3hsuRQ3B4odHSBlqx98737jF4NPCQarn05plY4P0AyOakA1MZ468DM >									
	//        <  u =="0.000000000000000001" : ] 000000021030904.691012100000000000 ; 000000042495746.178993000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000020173240D7E7 >									
	//     < RUSS_PFXXXVIII_II_metadata_line_3_____Kingisepp_RemStroiService_20231101 >									
	//        < ybk06fgK1g9gV7P3E336xs4O2n5Kx6Y233VI81PREhHd20R78nZAI7d1h0yiml71 >									
	//        <  u =="0.000000000000000001" : ] 000000042495746.178993000000000000 ; 000000064889708.955665200000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000040D7E763038B >									
	//     < RUSS_PFXXXVIII_II_metadata_line_4_____Novomoskovsk_RemStroiService_20231101 >									
	//        < uk7afUftRSkeEMEki60u9R85D4KW2UJUUbQ763djPTmJ49gHU3Eb69Ax0BVRcaF1 >									
	//        <  u =="0.000000000000000001" : ] 000000064889708.955665200000000000 ; 000000085595619.287340400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000063038B829BCA >									
	//     < RUSS_PFXXXVIII_II_metadata_line_5_____Nevinnomyssk_RemStroiService_20231101 >									
	//        < GTe8v2qYAxrc3f3F3xZ3W2Q95DO0q7KHY2hygK5ywlvLqB15n40bMFAums8A7kyx >									
	//        <  u =="0.000000000000000001" : ] 000000085595619.287340400000000000 ; 000000102992727.837550000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000829BCA9D2789 >									
	//     < RUSS_PFXXXVIII_II_metadata_line_6_____Volgograd_RemStroiService_20231101 >									
	//        < r8Kp8U0rZ6Qb5vfh033C4FRxjdrXwRI1lgYrAO7v4l8t50OB2Ry6cqiB2RIt4agD >									
	//        <  u =="0.000000000000000001" : ] 000000102992727.837550000000000000 ; 000000121088919.007727000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009D2789B8C45C >									
	//     < RUSS_PFXXXVIII_II_metadata_line_7_____Berezniki_Mechanical_Works_20231101 >									
	//        < 6Cd1Hq0ukltDeJ51VkCF3u87q06kHcN51Y0ePiB0n3fO8hZCcIAT7mq2ym72g2ud >									
	//        <  u =="0.000000000000000001" : ] 000000121088919.007727000000000000 ; 000000145148536.262514000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B8C45CDD7AA6 >									
	//     < RUSS_PFXXXVIII_II_metadata_line_8_____Tulagiprochim_JSC_20231101 >									
	//        < 2fR43V5aJKWZha0jEjh0LT43KU3118ZEwt465j1VePeB25Nzp5X1bB5LuUwVwMp8 >									
	//        <  u =="0.000000000000000001" : ] 000000145148536.262514000000000000 ; 000000168137141.519079000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000DD7AA61008E92 >									
	//     < RUSS_PFXXXVIII_II_metadata_line_9_____TOMS_project_LLC_20231101 >									
	//        < Aj1Wbo1Y22FE40TabIB90rx1Q9r81KuCRZ27yB8TK3rU6Wc5rKb638lhlXl53xho >									
	//        <  u =="0.000000000000000001" : ] 000000168137141.519079000000000000 ; 000000189021339.274211000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001008E921206C76 >									
	//     < RUSS_PFXXXVIII_II_metadata_line_10_____Harvester_Shipmanagement_Ltd_20231101 >									
	//        < WAWoKtKWMKH4fTB0QG12rCArh52U0vt72yiQPVd1QxlF7ggN9R4uPlj831t75NFH >									
	//        <  u =="0.000000000000000001" : ] 000000189021339.274211000000000000 ; 000000213332969.230156000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001206C761458531 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVIII_II_metadata_line_11_____EuroChem_Logistics_International_20231101 >									
	//        < aZJzM92YxvKm8sixCOn85y6RTiix4RjkS335Jh4d52WlBglBpNtzpETEnJajEW8V >									
	//        <  u =="0.000000000000000001" : ] 000000213332969.230156000000000000 ; 000000235647990.739676000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000145853116791FF >									
	//     < RUSS_PFXXXVIII_II_metadata_line_12_____EuroChem_Terminal_Sillamäe_Aktsiaselts_Logistics_20231101 >									
	//        < wrO1618Vxp13P48cg3cv2XH9Md71ZligHl1708vg87hSQzOAUI82wZgluSvphUXk >									
	//        <  u =="0.000000000000000001" : ] 000000235647990.739676000000000000 ; 000000256853398.958347000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016791FF187ED5C >									
	//     < RUSS_PFXXXVIII_II_metadata_line_13_____EuroChem_Terminal_Ust_Luga_20231101 >									
	//        < 0dGbykbLjAEyp22k7M4u2W4ZNH45D3g7X60rVw2HlTM6Ws9kiqp6s7TS79Fu38AU >									
	//        <  u =="0.000000000000000001" : ] 000000256853398.958347000000000000 ; 000000276011508.457638000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000187ED5C1A528FF >									
	//     < RUSS_PFXXXVIII_II_metadata_line_14_____Tuapse_Bulk_Terminal_20231101 >									
	//        < c6A2FQBCx13DCR0nN1VFvKJjJvctLL0234EL8yD2pb150LNtrz9kHKIw079lUOQO >									
	//        <  u =="0.000000000000000001" : ] 000000276011508.457638000000000000 ; 000000298291405.349352000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A528FF1C72815 >									
	//     < RUSS_PFXXXVIII_II_metadata_line_15_____Murmansk_Bulkcargo_Terminal_20231101 >									
	//        < eJ8fCvJyiOs5E1od1zKFP5A4w7a51ULAfp2A9LUcs97hE7b86uU8JU97qVX21fe1 >									
	//        <  u =="0.000000000000000001" : ] 000000298291405.349352000000000000 ; 000000321075850.649663000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C728151E9EC41 >									
	//     < RUSS_PFXXXVIII_II_metadata_line_16_____Depo_EuroChem_20231101 >									
	//        < av80m9Jw4rhMuHncjIeiTZo4GYW6wXb4sLS1Ef8bY8g759wkDe73lK85azdMEdD1 >									
	//        <  u =="0.000000000000000001" : ] 000000321075850.649663000000000000 ; 000000338675977.554594000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E9EC41204C74E >									
	//     < RUSS_PFXXXVIII_II_metadata_line_17_____EuroChem_Energo_20231101 >									
	//        < icaHuue3H4d5LSmV1fDIqBrQp125uF2ynTPt9CcfL2zWRabfsX7xDo8c6jhhCvqW >									
	//        <  u =="0.000000000000000001" : ] 000000338675977.554594000000000000 ; 000000356241010.157128000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000204C74E21F94A5 >									
	//     < RUSS_PFXXXVIII_II_metadata_line_18_____EuroChem_Usolsky_Mining_sarl_20231101 >									
	//        < UKNot1s9iAl0B2M11YP0374sIq6wNk0P8ZZkoiD9hQ3jZ7Hjoy0t3O8y1tHXItY5 >									
	//        <  u =="0.000000000000000001" : ] 000000356241010.157128000000000000 ; 000000372323482.773939000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021F94A52381EDC >									
	//     < RUSS_PFXXXVIII_II_metadata_line_19_____EuroChem_International_Holding_BV_20231101 >									
	//        < j9Os0NYNW7J002nRliw9Ecx8O241FQZrAcbK9f9XwdiVqo3raUVq7Ih47KrN74Tq >									
	//        <  u =="0.000000000000000001" : ] 000000372323482.773939000000000000 ; 000000391137730.311323000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002381EDC254D42D >									
	//     < RUSS_PFXXXVIII_II_metadata_line_20_____Severneft_Urengoy_LLC_20231101 >									
	//        < YUlx5pL8aGiME44fac416cBjvCn7JktW4hW82ep2ouNKX2FVDnLK3276Q5dR7rpa >									
	//        <  u =="0.000000000000000001" : ] 000000391137730.311323000000000000 ; 000000408094392.043982000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000254D42D26EB3DF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVIII_II_metadata_line_21_____Agrinos_AS_20231101 >									
	//        < 4p905Gt5T15MPKdRn5QZYLcOofzzj92F0e6NGf28t3K1jm6nx3f1L583r2q5Rycn >									
	//        <  u =="0.000000000000000001" : ] 000000408094392.043982000000000000 ; 000000424378941.879076000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026EB3DF2878D06 >									
	//     < RUSS_PFXXXVIII_II_metadata_line_22_____Hispalense_de_Líquidos_SL_20231101 >									
	//        < RU1452yEip4pV5CmagpX5iJ9sOLQx8jgMNy7S7YCc77Vv6T8q18x83FP93GHmJ3f >									
	//        <  u =="0.000000000000000001" : ] 000000424378941.879076000000000000 ; 000000448330546.330970000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002878D062AC191F >									
	//     < RUSS_PFXXXVIII_II_metadata_line_23_____Azottech_LLC_20231101 >									
	//        < X6lg8I8AcmItA64qZPvZKTUJARKU7hOIx3A6xr14738018Zh29J6yon3M7C3RJ70 >									
	//        <  u =="0.000000000000000001" : ] 000000448330546.330970000000000000 ; 000000472386812.036159000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AC191F2D0CE19 >									
	//     < RUSS_PFXXXVIII_II_metadata_line_24_____EuroChem_Migao_Ltd_20231101 >									
	//        < HohRK4MPsz086A1ZjC5G0u0H1l5yY2MF10TlFx6iQAJFA198NfHZ0844g3bwgAiH >									
	//        <  u =="0.000000000000000001" : ] 000000472386812.036159000000000000 ; 000000494827736.009935000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D0CE192F30C16 >									
	//     < RUSS_PFXXXVIII_II_metadata_line_25_____Thyssen_Schachtbau_EuroChem_Drilling_20231101 >									
	//        < 4pQ79G0WQ3799lNHIm13i7Cgf64K0VcFpwZDNNJh9rAXcZT55334LzO1ErsKRoEU >									
	//        <  u =="0.000000000000000001" : ] 000000494827736.009935000000000000 ; 000000517532666.447238000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F30C16315B133 >									
	//     < RUSS_PFXXXVIII_II_metadata_line_26_____Biochem_Technologies_LLC_20231101 >									
	//        < Gl7nO4M7Hm1oLg6qkTe8y2CJP0FCSFeqa3Cj72IwW27bGqo9mmVso29C4qK44nkX >									
	//        <  u =="0.000000000000000001" : ] 000000517532666.447238000000000000 ; 000000538083616.187707000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000315B1333350CEA >									
	//     < RUSS_PFXXXVIII_II_metadata_line_27_____EuroChem_Agro_Bulgaria_Ead_20231101 >									
	//        < 91vDr2MNMB952Zw8U0D2tzZ5R380mJR3JWz90prns06z35MSJhK0ufr780Ro545q >									
	//        <  u =="0.000000000000000001" : ] 000000538083616.187707000000000000 ; 000000555448975.219862000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003350CEA34F8C42 >									
	//     < RUSS_PFXXXVIII_II_metadata_line_28_____Emerger_Fertilizantes_SA_20231101 >									
	//        < QL34JHu7PIs7qVPDM8VlA0C80i4PWYRxW2b7B6TF4sD81XX7R1F0Cm32Rgt80IVy >									
	//        <  u =="0.000000000000000001" : ] 000000555448975.219862000000000000 ; 000000580256255.052675000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034F8C42375669A >									
	//     < RUSS_PFXXXVIII_II_metadata_line_29_____Agrocenter_EuroChem_Srl_20231101 >									
	//        < 00gLF641z9w1w96f3d2jQ4DtV2x3NMf2EzFcm383ik41NmJsD25wJ8G1xrN9sF0r >									
	//        <  u =="0.000000000000000001" : ] 000000580256255.052675000000000000 ; 000000598899888.802294000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000375669A391D945 >									
	//     < RUSS_PFXXXVIII_II_metadata_line_30_____AgroCenter_Ukraine_LLC_20231101 >									
	//        < 492YHI16Xz3F7P10tL82kF1nw8v3L2zIbPPrw98rNmqUNgt0g54nq6CO6chT8ePF >									
	//        <  u =="0.000000000000000001" : ] 000000598899888.802294000000000000 ; 000000621020720.422880000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000391D9453B39A38 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVIII_II_metadata_line_31_____EuroChem_Agro_doo_Beograd_20231101 >									
	//        < SBLtKz7eqVbAr4g8nw5jFzN1Skl26FiH1m4a0j464C55hoJ578488pjb2VnDTibE >									
	//        <  u =="0.000000000000000001" : ] 000000621020720.422880000000000000 ; 000000639375295.246686000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B39A383CF9BFA >									
	//     < RUSS_PFXXXVIII_II_metadata_line_32_____TOMS_project_LLC_20231101 >									
	//        < Og1FG4nrNEXZZOwl8t17X6rFM6jljyrS17DyInN8YB3j7maP1Em69D3iH50DmFNS >									
	//        <  u =="0.000000000000000001" : ] 000000639375295.246686000000000000 ; 000000657817744.250553000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003CF9BFA3EBC00E >									
	//     < RUSS_PFXXXVIII_II_metadata_line_33_____Agrosphere_20231101 >									
	//        < ObA1jYmUC51gQZqwKHfW8Y26C1kiNf0h2yB3xi3m8T3YfL5dtgB9q8M3NGOyL6NI >									
	//        <  u =="0.000000000000000001" : ] 000000657817744.250553000000000000 ; 000000681498703.573722000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003EBC00E40FE26E >									
	//     < RUSS_PFXXXVIII_II_metadata_line_34_____Bulkcargo_Terminal_LLC_20231101 >									
	//        < VBcb0De8C5ABkZj8t9MYT450YWctbl62ZOssx9Z21981DSLq0k54RK3H312dU3a0 >									
	//        <  u =="0.000000000000000001" : ] 000000681498703.573722000000000000 ; 000000703709370.977334000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040FE26E431C679 >									
	//     < RUSS_PFXXXVIII_II_metadata_line_35_____AgroCenter_EuroChem_Volgograd_20231101 >									
	//        < nYL2moT9tTRSRzQ5vf9pa1l5b03y64h33ZZKoMJV7kYJ9dYXsVGX0Q0GApVRJzXp >									
	//        <  u =="0.000000000000000001" : ] 000000703709370.977334000000000000 ; 000000719688798.754498000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000431C67944A2870 >									
	//     < RUSS_PFXXXVIII_II_metadata_line_36_____Trading_RUS_LLC_20231101 >									
	//        < c0GuU89t7Xe4ztA5Ei3X9uO6We98uF2iS79gu3jXtT71INuy5y35exjgK0vWRRnB >									
	//        <  u =="0.000000000000000001" : ] 000000719688798.754498000000000000 ; 000000743483030.265779000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044A287046E770F >									
	//     < RUSS_PFXXXVIII_II_metadata_line_37_____AgroCenter_EuroChem_Krasnodar_LLC_20231101 >									
	//        < KATSKKuo6Aa362Xqzu6xMRN4P0RKNqHzoCftg2Clz3dLdRW30fCbL8KjAaV3UifB >									
	//        <  u =="0.000000000000000001" : ] 000000743483030.265779000000000000 ; 000000759718072.149314000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046E770F4873CDF >									
	//     < RUSS_PFXXXVIII_II_metadata_line_38_____AgroCenter_EuroChem_Lipetsk_LLC_20231101 >									
	//        < V6ola9QEY9mU09j6PG74K4X41ky8pWV33d9obsUz290dgpmcq0j6LOLTa831mK0M >									
	//        <  u =="0.000000000000000001" : ] 000000759718072.149314000000000000 ; 000000779013627.162869000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004873CDF4A4AE33 >									
	//     < RUSS_PFXXXVIII_II_metadata_line_39_____AgroCenter_EuroChem_Orel_LLC_20231101 >									
	//        < kEHuxgT7KQTr6ldNFMX4fPg1DHIu36L73O15SUxk2S83X215AKiTQ1v61v40542z >									
	//        <  u =="0.000000000000000001" : ] 000000779013627.162869000000000000 ; 000000798702917.498653000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A4AE334C2B954 >									
	//     < RUSS_PFXXXVIII_II_metadata_line_40_____AgroCenter_EuroChem_Nevinnomyssk_LLC_20231101 >									
	//        < 3okXq7pe3nhR6HVJC9ERA0G1I1In49mF5I664tyb2dAMC2d0fkQN2m227TgzVVJZ >									
	//        <  u =="0.000000000000000001" : ] 000000798702917.498653000000000000 ; 000000821170410.821043000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004C2B9544E501B1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}