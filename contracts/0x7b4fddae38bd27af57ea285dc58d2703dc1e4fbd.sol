pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXV_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXV_I_883		"	;
		string	public		symbol =	"	RUSS_PFXXXV_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		609163517964717000000000000					;	
										
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
	//     < RUSS_PFXXXV_I_metadata_line_1_____ALROSA_20211101 >									
	//        < 034fwi6jkd3IFspeO6j6245R56z6MdJ9Abbc0tOgg1VYuO97dlv2pbIM79b5mK12 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000016086611.296269000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000188BD5 >									
	//     < RUSS_PFXXXV_I_metadata_line_2_____ARCOS_HK_LIMITED_20211101 >									
	//        < DDml7X6053RhX4lRvxHl9pG1B33B949OW2zuNCc4XW55olk5qDULMC9yu1iUL3Jf >									
	//        <  u =="0.000000000000000001" : ] 000000016086611.296269000000000000 ; 000000031051618.523242900000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000188BD52F618A >									
	//     < RUSS_PFXXXV_I_metadata_line_3_____ARCOS_ORG_20211101 >									
	//        < XIm5f8uur4fFaI480FuH0ujtM9KK11LSx79HuZ7T4o337A8f2wdxXT68NPwoBAI8 >									
	//        <  u =="0.000000000000000001" : ] 000000031051618.523242900000000000 ; 000000046882482.859321100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002F618A478978 >									
	//     < RUSS_PFXXXV_I_metadata_line_4_____SUNLAND_HOLDINGS_SA_20211101 >									
	//        < 72TZD3p7NPFR7JAtY9415S52b6Qr4d84Kgl5wc06VMWp71J81DtTTrU262My6sOf >									
	//        <  u =="0.000000000000000001" : ] 000000046882482.859321100000000000 ; 000000062717945.428371800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004789785FB333 >									
	//     < RUSS_PFXXXV_I_metadata_line_5_____ARCOS_BELGIUM_NV_20211101 >									
	//        < Et0bc92fHsPdgO6vPr1SmL8dOrlMoBL7v6JYE5278cci6y3BgVnjum2zEOY35O21 >									
	//        <  u =="0.000000000000000001" : ] 000000062717945.428371800000000000 ; 000000075770223.551683000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005FB333739DBE >									
	//     < RUSS_PFXXXV_I_metadata_line_6_____MEDIAGROUP_SITIM_20211101 >									
	//        < 4Bu2cZMU7Biw7up90HDG4gzt64J9SsX9EUQ1ChImto3glwaNbk68P0yu8xLWufmC >									
	//        <  u =="0.000000000000000001" : ] 000000075770223.551683000000000000 ; 000000091491540.279097300000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000739DBE8B9AE2 >									
	//     < RUSS_PFXXXV_I_metadata_line_7_____ALROSA_FINANCE_BV_20211101 >									
	//        < WM832Wi19ruYjgNrA5ru4B19GRVRfJjyNiJX6gd6x0I9ZzVG0RV53CjU3Num7G5A >									
	//        <  u =="0.000000000000000001" : ] 000000091491540.279097300000000000 ; 000000108400271.929440000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008B9AE2A567DB >									
	//     < RUSS_PFXXXV_I_metadata_line_8_____SHIPPING_CO_ALROSA_LENA_20211101 >									
	//        < 7l7r4d3lyRd9SZfxW0L6affVEi24YWk7A30417717TrZs41JtMj3ltwfqB4p8Op2 >									
	//        <  u =="0.000000000000000001" : ] 000000108400271.929440000000000000 ; 000000122963911.366629000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A567DBBBA0C7 >									
	//     < RUSS_PFXXXV_I_metadata_line_9_____LENA_ORG_20211101 >									
	//        < fWrXyF748jRq84rpRfPiljx8k5zTxzaoM215340l0FwViC36w61vl4ZV1gA23Aq3 >									
	//        <  u =="0.000000000000000001" : ] 000000122963911.366629000000000000 ; 000000138975325.284652000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BBA0C7D40F3D >									
	//     < RUSS_PFXXXV_I_metadata_line_10_____ALROSA_AFRICA_20211101 >									
	//        < 69Yr87A0j5EmkfU1Wuwa97i1TK9Yi9I1NgJL1Pr5yMl4vO4N3TY6e80Se4uLXu96 >									
	//        <  u =="0.000000000000000001" : ] 000000138975325.284652000000000000 ; 000000154424908.153007000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D40F3DEBA23B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXV_I_metadata_line_11_____INVESTMENT_GROUP_ALROSA_20211101 >									
	//        < f96RRb66w8riePRa1tM908kC6Q9Y0dE69u8VPm5T16ge8nhR63AatMuVaRgld4wp >									
	//        <  u =="0.000000000000000001" : ] 000000154424908.153007000000000000 ; 000000169941514.523430000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EBA23B1034F67 >									
	//     < RUSS_PFXXXV_I_metadata_line_12_____INVESTITSIONNAYA_GRUPPA_ALROSA_20211101 >									
	//        < 23HHBShMaLo8tS34hNsE2TUsjz4B0V15bZTQ4eEbsUk93S3mIbxH1Uft19iPm647 >									
	//        <  u =="0.000000000000000001" : ] 000000169941514.523430000000000000 ; 000000183291056.365387000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001034F67117AE12 >									
	//     < RUSS_PFXXXV_I_metadata_line_13_____VILYUISKAYA_GES_3_20211101 >									
	//        < 8uv1ny9iz23WVYd8Q0ZePle6vrcOQ6z5Up09y5v4SSj74dvw575huE5y1Pv1Hi9H >									
	//        <  u =="0.000000000000000001" : ] 000000183291056.365387000000000000 ; 000000199791985.902766000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000117AE12130DBBF >									
	//     < RUSS_PFXXXV_I_metadata_line_14_____NPP_BUREVESTNIK_20211101 >									
	//        < QL5z0a6fl4i272x41jYMdOz23ob1Uk1qg0Yaa07sRRY9NkQjO5L4a72a5t2uAql8 >									
	//        <  u =="0.000000000000000001" : ] 000000199791985.902766000000000000 ; 000000216652191.648589000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000130DBBF14A95C3 >									
	//     < RUSS_PFXXXV_I_metadata_line_15_____NARNAUL_KRISTALL_FACTORY_20211101 >									
	//        < R1J5Tnrz1c8Sz6E2cE49tref79u469sfn97DD598KeJ16rRYqWhGuU48eGhg77o0 >									
	//        <  u =="0.000000000000000001" : ] 000000216652191.648589000000000000 ; 000000231555530.639939000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014A95C31615361 >									
	//     < RUSS_PFXXXV_I_metadata_line_16_____NARNAUL_ORG_20211101 >									
	//        < AEu4eJ6Xl21Tjsr0SNXudw5Q5rSE13DN94F9Gw2og1TkX6I3yk023672JeN6O36G >									
	//        <  u =="0.000000000000000001" : ] 000000231555530.639939000000000000 ; 000000248633127.109067000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000161536117B6251 >									
	//     < RUSS_PFXXXV_I_metadata_line_17_____HIDROELECTRICA_CHICAPA_SARL_20211101 >									
	//        < dAnXFR5xEpP4Tf59fp9I39b976H7Qb324zIyG7KiL1V2AtBl6r3airV8oeMIW83a >									
	//        <  u =="0.000000000000000001" : ] 000000248633127.109067000000000000 ; 000000263061166.652039000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017B62511916645 >									
	//     < RUSS_PFXXXV_I_metadata_line_18_____CHICAPA_ORG_20211101 >									
	//        < eJEhXmh5PR7g8nIDCW729W5DHujGr3ndu3e7993Z5CVieft8W8Qee1Oj3Lgb2DOz >									
	//        <  u =="0.000000000000000001" : ] 000000263061166.652039000000000000 ; 000000279402798.498408000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019166451AA55B8 >									
	//     < RUSS_PFXXXV_I_metadata_line_19_____ALROSA_VGS_LLC_20211101 >									
	//        < MS9ubC87vglJJprb4Nlt59xdVrCupH4m464jMxGf0kSv7SEUQ5LQ7OHoF5E918Vg >									
	//        <  u =="0.000000000000000001" : ] 000000279402798.498408000000000000 ; 000000294522018.390423000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AA55B81C167AA >									
	//     < RUSS_PFXXXV_I_metadata_line_20_____ARCOS_DIAMOND_ISRAEL_20211101 >									
	//        < 2v9MV5sVvVI3tGUQ9A2N4ZU2C3ZLJfS5Ob9fBQ3t7X24WM9SK85h0FO2sFsVPB9o >									
	//        <  u =="0.000000000000000001" : ] 000000294522018.390423000000000000 ; 000000308743706.911977000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C167AA1D71B03 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXV_I_metadata_line_21_____ALMAZY_ANABARA_20211101 >									
	//        < z5ujhC91tR27fi70eb2KI89cTpUSPI4P57M95fhuXY0v0sj1whg14l92zz3Z8Q8V >									
	//        <  u =="0.000000000000000001" : ] 000000308743706.911977000000000000 ; 000000323927629.916064000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D71B031EE463B >									
	//     < RUSS_PFXXXV_I_metadata_line_22_____ALMAZY_ORG_20211101 >									
	//        < A99PsS7AI6hK7iOO53DGW4gW93Ng8JSRhZ315xz1kT4i7YAi63fQ04Op36xV9kKD >									
	//        <  u =="0.000000000000000001" : ] 000000323927629.916064000000000000 ; 000000339710420.055066000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EE463B2065B62 >									
	//     < RUSS_PFXXXV_I_metadata_line_23_____ALROSA_ORG_20211101 >									
	//        < ot4weY8uO0qvLyl9t4nJGe8N7t92me09p1A4TKj6IBu2I5e3VW44ysumJj3HYH2h >									
	//        <  u =="0.000000000000000001" : ] 000000339710420.055066000000000000 ; 000000353420174.789605000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002065B6221B46C1 >									
	//     < RUSS_PFXXXV_I_metadata_line_24_____SEVERALMAZ_20211101 >									
	//        < gH97b631LQaAKfDuA7q7oEoYYbVs421Z7FvL7N3h9D6b4h1drwwzM6e3glx1oo1w >									
	//        <  u =="0.000000000000000001" : ] 000000353420174.789605000000000000 ; 000000367594450.686049000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021B46C1230E795 >									
	//     < RUSS_PFXXXV_I_metadata_line_25_____ARCOS_USA_20211101 >									
	//        < 07d2dZq0Hf9rI6R5DG46j3c40A35uFa1C9UaDTm5A4F61mzzQe82gdb7Oh55dRv5 >									
	//        <  u =="0.000000000000000001" : ] 000000367594450.686049000000000000 ; 000000384127130.933510000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000230E79524A21A9 >									
	//     < RUSS_PFXXXV_I_metadata_line_26_____NYURBA_20211101 >									
	//        < eS38S95VvhT79954SOnDE3Ryt4x31BnU7p35JHM1t8OGQf0M9DBi45AvsvJEFY1M >									
	//        <  u =="0.000000000000000001" : ] 000000384127130.933510000000000000 ; 000000399985012.185506000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024A21A92625425 >									
	//     < RUSS_PFXXXV_I_metadata_line_27_____NYURBA_ORG_20211101 >									
	//        < EB53ZDth0hN7yecuf3537r85ysk1cpZkMUSZ62H0PX2p47Vvz4HR6y4u5Kv5B5A5 >									
	//        <  u =="0.000000000000000001" : ] 000000399985012.185506000000000000 ; 000000414491494.582439000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000262542527876BD >									
	//     < RUSS_PFXXXV_I_metadata_line_28_____EAST_DMCC_20211101 >									
	//        < 57zW7y2S8e0Jize1wP681L49c1229qzggR8bnNS1tVh68os4sC48kebfC7vRwu6f >									
	//        <  u =="0.000000000000000001" : ] 000000414491494.582439000000000000 ; 000000428722908.769532000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027876BD28E2DE3 >									
	//     < RUSS_PFXXXV_I_metadata_line_29_____ALROSA_FINANCE_SA_20211101 >									
	//        < R9dV4p82qLzm5Hen2a1Qn1v42LL24Yv0myFhuyy8oik9Kq72Lf21v7cwdZealTZB >									
	//        <  u =="0.000000000000000001" : ] 000000428722908.769532000000000000 ; 000000444049519.341692000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028E2DE32A590D8 >									
	//     < RUSS_PFXXXV_I_metadata_line_30_____ALROSA_OVERSEAS_SA_20211101 >									
	//        < it8bd4529Eo11z62rdn72X5n592RLStHyMIDNQQ6TG3p39q0gboyfCi1zlCmG867 >									
	//        <  u =="0.000000000000000001" : ] 000000444049519.341692000000000000 ; 000000457157433.438598000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A590D82B9911F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXV_I_metadata_line_31_____ARCOS_EAST_DMCC_20211101 >									
	//        < 6N892ck4or776pFTW28dwFVt73E90AlZ01bF47kzp08951G97qJdh7u49Wuv4HTs >									
	//        <  u =="0.000000000000000001" : ] 000000457157433.438598000000000000 ; 000000474086165.930988000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B9911F2D365E9 >									
	//     < RUSS_PFXXXV_I_metadata_line_32_____HIDROCHICAPA_SARL_20211101 >									
	//        < aVNKO3tQR3OZ4PIZw4AojioTwIR5F3l6t7Lh863sGCqLh42Tqa4Cx4sSw24vIIbB >									
	//        <  u =="0.000000000000000001" : ] 000000474086165.930988000000000000 ; 000000487495429.364214000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D365E92E7DBE7 >									
	//     < RUSS_PFXXXV_I_metadata_line_33_____ALROSA_GAZ_20211101 >									
	//        < jIDC01OaP1h924A6YN9A7g4x58W056woi0wp212NMgOeA2qKo5vX7S10GKU8HqTb >									
	//        <  u =="0.000000000000000001" : ] 000000487495429.364214000000000000 ; 000000504095363.014267000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E7DBE73013040 >									
	//     < RUSS_PFXXXV_I_metadata_line_34_____SUNLAND_TRADING_SA_20211101 >									
	//        < 8OeE23Ldz2WBU0XdNwyL7Jj2xpoeELowVe69i64wQhHz6NmRW4Fko1c7zA13JPlm >									
	//        <  u =="0.000000000000000001" : ] 000000504095363.014267000000000000 ; 000000517743574.156170000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030130403160395 >									
	//     < RUSS_PFXXXV_I_metadata_line_35_____ORYOL_ALROSA_20211101 >									
	//        < tLFgJ5pe6oC887futVf0ku90J1U7n5r716xK4iD1xbphe96728kQSf6RZ8vH38v4 >									
	//        <  u =="0.000000000000000001" : ] 000000517743574.156170000000000000 ; 000000531955109.517475000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000316039532BB2F7 >									
	//     < RUSS_PFXXXV_I_metadata_line_36_____GOLUBAYA_VOLNA_HEALTH_RESORT_20211101 >									
	//        < 02uUX08gg3BcDQ4u0nt5cSTdzvgq29UFr735QCo38d05NDB5Fn4Y7vB8E49EWN0a >									
	//        <  u =="0.000000000000000001" : ] 000000531955109.517475000000000000 ; 000000546395351.604759000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032BB2F7341BBAF >									
	//     < RUSS_PFXXXV_I_metadata_line_37_____GOLUBAYA_ORG_20211101 >									
	//        < 5A447xnU7vLlu2XfhCDWDGUdDeO32hnofE6UwTU1E94F23cL6r0LWP9nk10h0lcz >									
	//        <  u =="0.000000000000000001" : ] 000000546395351.604759000000000000 ; 000000563522273.927722000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000341BBAF35BDDE3 >									
	//     < RUSS_PFXXXV_I_metadata_line_38_____SEVERNAYA_GORNO_GEOLOGIC_KOM_TERRA_20211101 >									
	//        < O13c99IN29ODuOReoBI9aBa5hg4f941Fp968Q7107n9P7WE0C6hImOpO9YQ6op82 >									
	//        <  u =="0.000000000000000001" : ] 000000563522273.927722000000000000 ; 000000580116892.309645000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035BDDE33753029 >									
	//     < RUSS_PFXXXV_I_metadata_line_39_____SEVERNAYA_ORG_20211101 >									
	//        < VKZmE05gDdh477gfoxY2Nku726ajz7DDmOK88VHjGvm6WyHu27ELoN90UyFdi9M2 >									
	//        <  u =="0.000000000000000001" : ] 000000580116892.309645000000000000 ; 000000593445902.588076000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000375302938986CE >									
	//     < RUSS_PFXXXV_I_metadata_line_40_____ALROSA_NEVA_20211101 >									
	//        < ujITbwz99fmen7S9GlQpvIb02662xf3dwW9C5agJZdPq9BN6kj1v411M4T05nR69 >									
	//        <  u =="0.000000000000000001" : ] 000000593445902.588076000000000000 ; 000000609163517.964717000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038986CE3A18280 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}