pragma solidity 		^0.4.21	;						
										
	contract	AZOV_PFII_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	AZOV_PFII_I_883		"	;
		string	public		symbol =	"	AZOV_PFII_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		805185563730986000000000000					;	
										
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
	//     < AZOV_PFII_I_metadata_line_1_____Td_Yug_Rusi_20211101 >									
	//        < 0QlzYD69674p36j15g56S1p2IcPsy45x85ANQo78DUpHUh7S4K9b59e7335ow2Ki >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000024734931.266157000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000025BE15 >									
	//     < AZOV_PFII_I_metadata_line_2_____LLC_MEZ_Yug_Rusi_20211101 >									
	//        < 4N1F141tr67ya33tJgpKAtCqPQ78520Z7G9v5C1tt44tpHY009gOkenF2nP1LplB >									
	//        <  u =="0.000000000000000001" : ] 000000024734931.266157000000000000 ; 000000049426857.978467100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000025BE154B6B5E >									
	//     < AZOV_PFII_I_metadata_line_3_____savola_foods_cis_20211101 >									
	//        < 55zvO2Z11BWo5xKwVH33Lv1W7qao817270cjRrqersAYc09IZOlo4JJyy51N3S1W >									
	//        <  u =="0.000000000000000001" : ] 000000049426857.978467100000000000 ; 000000066970121.748416000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004B6B5E663034 >									
	//     < AZOV_PFII_I_metadata_line_4_____labinsky_cannery_20211101 >									
	//        < 39wPDXKj5z7qABzArec74lj667Jd9lK54PgsDSncyGAWhEk1Fg8IM0YNdN74JT6r >									
	//        <  u =="0.000000000000000001" : ] 000000066970121.748416000000000000 ; 000000088283148.705335800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000066303486B59B >									
	//     < AZOV_PFII_I_metadata_line_5_____jsc_chernyansky_vegetable_oil_plant_20211101 >									
	//        < 2h6O9K8L85qZha7f1U7l5SgSUcogQ7jH94KIZi142sRFutMQdYqVt53kZpJLf677 >									
	//        <  u =="0.000000000000000001" : ] 000000088283148.705335800000000000 ; 000000101244939.827303000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000086B59B9A7CCE >									
	//     < AZOV_PFII_I_metadata_line_6_____urazovsky_elevator_jsc_20211101 >									
	//        < YlMr5TwcrVw407cCnBxfS4Rjgp5N7mVMwa1AAxKYFGtFzFZ8t3re5o7E025P8Ubt >									
	//        <  u =="0.000000000000000001" : ] 000000101244939.827303000000000000 ; 000000127097143.502009000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009A7CCEC1EF52 >									
	//     < AZOV_PFII_I_metadata_line_7_____ooo_orskmelprom_20211101 >									
	//        < Qh2qL9L71SX62b4K33R14HwWFR0l7drqP1am241DTF1FznAlMlObEIpMj8gCOG74 >									
	//        <  u =="0.000000000000000001" : ] 000000127097143.502009000000000000 ; 000000149238888.167364000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C1EF52E3B871 >									
	//     < AZOV_PFII_I_metadata_line_8_____zolotaya_semechka_ooo_20211101 >									
	//        < jG31sNcH4hfDUgk1NZsKkMJ0S9vZqBCVed27F9Xw0m04N6PMNY137roYh8uljvDG >									
	//        <  u =="0.000000000000000001" : ] 000000149238888.167364000000000000 ; 000000166471850.687895000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E3B871FE0411 >									
	//     < AZOV_PFII_I_metadata_line_9_____ooo_grain_union_20211101 >									
	//        < Rm4bz0MZNkC47238P7vf4l91MR2Qx0nzugocH0fpl4n6QzsNKo7WwpK9j5C0ud2M >									
	//        <  u =="0.000000000000000001" : ] 000000166471850.687895000000000000 ; 000000190132151.931367000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FE04111221E5F >									
	//     < AZOV_PFII_I_metadata_line_10_____valuysky_vegetable_oil_plant_20211101 >									
	//        < 3o5skmpbxV5W33Om8cH3yY5mC3shGD02Wy7mrCavUygmhk9Shh3mY80BGIbZg8M1 >									
	//        <  u =="0.000000000000000001" : ] 000000190132151.931367000000000000 ; 000000213633480.013637000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001221E5F145FA94 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < AZOV_PFII_I_metadata_line_11_____ooo_yugagro_leasing_20211101 >									
	//        < kpL5Z51Ef5D1vxx0N9DXcSi8jU0S9Ue5W14PQ9R24ati2j2xn3GK90p57E33T6kq >									
	//        <  u =="0.000000000000000001" : ] 000000213633480.013637000000000000 ; 000000238519482.920000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000145FA9416BF3AC >									
	//     < AZOV_PFII_I_metadata_line_12_____torgovy_dom_yug_rusi_ooo_20211101 >									
	//        < 62AJqgwpy1Jr22KwatUZ24kwz57cDARfNZ9e37Ad7hCVz11Q04dgbUDaK59l7oxO >									
	//        <  u =="0.000000000000000001" : ] 000000238519482.920000000000000000 ; 000000262707093.760388000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016BF3AC190DBF5 >									
	//     < AZOV_PFII_I_metadata_line_13_____trading_house_wj_cis_20211101 >									
	//        < QANwr2i36iQd0cdW80FT4tTT1HdezCk2NZXDiQg096HUi4hoU9Ed46WeM2m7Xt25 >									
	//        <  u =="0.000000000000000001" : ] 000000262707093.760388000000000000 ; 000000282191553.518457000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000190DBF51AE9713 >									
	//     < AZOV_PFII_I_metadata_line_14_____ojsc_tselinkhlebprodukt_20211101 >									
	//        < RuNqul876DZAmPEJ3ejN3PP1xtV2H3R6vRK41wR1n922tW0vab61i6yo54u08kl9 >									
	//        <  u =="0.000000000000000001" : ] 000000282191553.518457000000000000 ; 000000297603001.120459000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AE97131C61B2C >									
	//     < AZOV_PFII_I_metadata_line_15_____ooo_orskaya_pasta_factory_20211101 >									
	//        < 5F86y3Y36L6F6wSo8P07EP8kFwRv0y4Z1KKI8F93vU4EV0LZhrci0MuhhV3SctaH >									
	//        <  u =="0.000000000000000001" : ] 000000297603001.120459000000000000 ; 000000313343704.061238000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C61B2C1DE1FE2 >									
	//     < AZOV_PFII_I_metadata_line_16_____Azs Yug Rusi_20211101 >									
	//        < BvGEm7CsfW388Dq68RS3T881o9yTt98f7V6UNt301tV7T30m08Ye6pCH0echNUrW >									
	//        <  u =="0.000000000000000001" : ] 000000313343704.061238000000000000 ; 000000329456623.305375000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DE1FE21F6B5FE >									
	//     < AZOV_PFII_I_metadata_line_17_____Bina_grup_20211101 >									
	//        < VfDBulV8VO062ism3bBwKzl3KYoz1zDto03z34Uo3CNSSPx81ezQ8074SeOQFOgq >									
	//        <  u =="0.000000000000000001" : ] 000000329456623.305375000000000000 ; 000000343811248.719089000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F6B5FE20C9D45 >									
	//     < AZOV_PFII_I_metadata_line_18_____BINA_INTEGRATED_TECHNOLOGY_SDN_BHD_20211101 >									
	//        < peBp1NoHN0gHxkq8qlbPs0hioV53S4BZrexe6pcRgTg737P2Nqt3ExdnkfWjEi1L >									
	//        <  u =="0.000000000000000001" : ] 000000343811248.719089000000000000 ; 000000362703653.575107000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020C9D45229711D >									
	//     < AZOV_PFII_I_metadata_line_19_____BINA_INTEGRATED_INDUSTRIES_SDN_BHD_20211101 >									
	//        < 2VtDhV32582sxf9j86081eAZ90240lY6d7W54Z96Z7tb3jRsWipgCFg3j8U3hL25 >									
	//        <  u =="0.000000000000000001" : ] 000000362703653.575107000000000000 ; 000000386787210.955550000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000229711D24E30C1 >									
	//     < AZOV_PFII_I_metadata_line_20_____BINA_PAINT_MARKETING_SDN_BHD_20211101 >									
	//        < 1jgn88CEJwNGODyPeXofM4tCVH0kb3n34Ay12G389qdft138UHhP3u90l453w4yd >									
	//        <  u =="0.000000000000000001" : ] 000000386787210.955550000000000000 ; 000000410441778.339486000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024E30C127248D2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < AZOV_PFII_I_metadata_line_21_____Yevroplast_20211101 >									
	//        < C481IDt54xb1NmH94OfjT9PLlM3f1498ZIHZDGOB8SC4tgKA40tXUtaAFs3fm5k6 >									
	//        <  u =="0.000000000000000001" : ] 000000410441778.339486000000000000 ; 000000424697068.764348000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027248D2288094B >									
	//     < AZOV_PFII_I_metadata_line_22_____Grain_export_infrastructure_org_20211101 >									
	//        < BYGfnjwNDRJ97VGN4291y4j684vZvo09Epbp8eiT2kjy7YHTykKb9j4m70fpiEh2 >									
	//        <  u =="0.000000000000000001" : ] 000000424697068.764348000000000000 ; 000000440744867.487203000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000288094B2A085F7 >									
	//     < AZOV_PFII_I_metadata_line_23_____Kherson_Port_org_20211101 >									
	//        < 02R4ur9u888yNqB207jnY8cDQ7ysF6M7TC4uJ94M96y3Y3GKUyYflQv846RR5WOy >									
	//        <  u =="0.000000000000000001" : ] 000000440744867.487203000000000000 ; 000000460967225.611508000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A085F72BF6153 >									
	//     < AZOV_PFII_I_metadata_line_24_____Donskoy_Tabak_20211101 >									
	//        < DXy5o0dwm4fIUG8O0YUJ1hvoA54TOUgFequKL2MKsXvOFUy138w747fDOF3Sjl8p >									
	//        <  u =="0.000000000000000001" : ] 000000460967225.611508000000000000 ; 000000479369149.411271000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BF61532DB7593 >									
	//     < AZOV_PFII_I_metadata_line_25_____Japan_Tobacco_International_20211101 >									
	//        < 2PnegISMg3F3JnZQDYV0or7iaq70jr6a3cmoiar1P1Ncm11392iauV638KwinV1O >									
	//        <  u =="0.000000000000000001" : ] 000000479369149.411271000000000000 ; 000000504145586.061400000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DB759330143DF >									
	//     < AZOV_PFII_I_metadata_line_26_____Akhra_2006_20211101 >									
	//        < hNp5ma2hZL84tcbPrGR6Sc81cRv6uyh80w8oHL1tYe4yIMwO95GiZ7YS5H4SJEkF >									
	//        <  u =="0.000000000000000001" : ] 000000504145586.061400000000000000 ; 000000528496214.191541000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030143DF3266BD5 >									
	//     < AZOV_PFII_I_metadata_line_27_____Sekap_SA_20211101 >									
	//        < l68ggH19k58HaZS5xhO806Mx9qEFBB5hSQdlnKtB4xx5Lr2gl3OCJ1VyMKuvh1fP >									
	//        <  u =="0.000000000000000001" : ] 000000528496214.191541000000000000 ; 000000545121484.017047000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003266BD533FCA14 >									
	//     < AZOV_PFII_I_metadata_line_28_____jt_international_korea_inc_20211101 >									
	//        < kUn0grU301057b4H52LoO7KRiV1BpHS9lvEM017A1J5Q61K5E3KBlY3m1z1AtpI4 >									
	//        <  u =="0.000000000000000001" : ] 000000545121484.017047000000000000 ; 000000570932488.350807000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033FCA143672C81 >									
	//     < AZOV_PFII_I_metadata_line_29_____tanzania_cigarette_company_20211101 >									
	//        < A6VArYa1SNaEXAH9GVg05s5rav2D1F4o67Z70312o8YS7PyVhI0UR9kq5KHnYGSu >									
	//        <  u =="0.000000000000000001" : ] 000000570932488.350807000000000000 ; 000000592244261.303952000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003672C81387B16A >									
	//     < AZOV_PFII_I_metadata_line_30_____jt_international_holding_bv_20211101 >									
	//        < La9IFbYcUR8S8h3sp5U69XvGwRjERg4qeQB78ASfImIIhsqGG7lp51uua4na5mul >									
	//        <  u =="0.000000000000000001" : ] 000000592244261.303952000000000000 ; 000000613892246.135326000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000387B16A3A8B9A9 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < AZOV_PFII_I_metadata_line_31_____kannenberg_barker_hail_cotton_tabacos_ltda_20211101 >									
	//        < JyC1prL55HMouz03KtSX3cvhN84rrICCkaL66iW9mr14FkQrG0DT6H5Yz0qT7kg1 >									
	//        <  u =="0.000000000000000001" : ] 000000613892246.135326000000000000 ; 000000629397266.866346000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A8B9A93C0624F >									
	//     < AZOV_PFII_I_metadata_line_32_____jt_international_iberia_sl_20211101 >									
	//        < 4luZWs2Pe415avGvuMKECf8p2gGH3DZX24r79gipWH4sNj5Qi3S4PX7I5kXwzb5w >									
	//        <  u =="0.000000000000000001" : ] 000000629397266.866346000000000000 ; 000000644754783.829534000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C0624F3D7D156 >									
	//     < AZOV_PFII_I_metadata_line_33_____jt_international_company_netherlands_bv_20211101 >									
	//        < 92O7aJT0F5DZdL749nKgm9hae789l94l0ApJ18x2OEI1m0r0M91l1eNu84F8frZI >									
	//        <  u =="0.000000000000000001" : ] 000000644754783.829534000000000000 ; 000000660508446.975832000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D7D1563EFDB1D >									
	//     < AZOV_PFII_I_metadata_line_34_____Gryson_nv_20211101 >									
	//        < 1z6CUv6c75v9X0Y34g7RJj3YH5h7NFNGh2GFeaWM6t8r3tUYkup7479z2k2760oo >									
	//        <  u =="0.000000000000000001" : ] 000000660508446.975832000000000000 ; 000000685161979.296545000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003EFDB1D4157966 >									
	//     < AZOV_PFII_I_metadata_line_35_____duvanska_industrija_senta_20211101 >									
	//        < 7S95F3E3cchQunhDka3a0NtSS82K6M7x53psiZX5Ps08rW654E7MDsh5ogKQaJY8 >									
	//        <  u =="0.000000000000000001" : ] 000000685161979.296545000000000000 ; 000000710351665.666279000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000415796643BE91F >									
	//     < AZOV_PFII_I_metadata_line_36_____kannenberg_cia_ltda_20211101 >									
	//        < f7JomfdXF3jo0VP77OCQa8qWceycTW9d1VSt839A9bZlebSff44N2s72STuw2uhb >									
	//        <  u =="0.000000000000000001" : ] 000000710351665.666279000000000000 ; 000000732807329.622129000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000043BE91F45E2CDD >									
	//     < AZOV_PFII_I_metadata_line_37_____jti_leaf_services_us_llc_20211101 >									
	//        < zd99ehqqv1j12j0pymu09DfP05SBt334Kq6obsfm52S50tySC76xyklReW0Iptwo >									
	//        <  u =="0.000000000000000001" : ] 000000732807329.622129000000000000 ; 000000756093825.124011000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000045E2CDD481B527 >									
	//     < AZOV_PFII_I_metadata_line_38_____cigarros_la_tabacalera_mexicana_sa_cv_20211101 >									
	//        < 27a9S5hfZ44HRRA33UYi9FA4T3jhmQqEcVlwAiWWmbM3pmmmLVliNnD65nV7cuiM >									
	//        <  u =="0.000000000000000001" : ] 000000756093825.124011000000000000 ; 000000773887308.031796000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000481B52749CDBBB >									
	//     < AZOV_PFII_I_metadata_line_39_____jti_pars_pjsco_20211101 >									
	//        < WuX10M84b9YrV95P1AywFZpK07aha57Rm70cRl9Uyz9VaGESN6CddqdxDX51B55x >									
	//        <  u =="0.000000000000000001" : ] 000000773887308.031796000000000000 ; 000000788695494.718646000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049CDBBB4B3742D >									
	//     < AZOV_PFII_I_metadata_line_40_____jti_uk_finance_limited_20211101 >									
	//        < n654V65h0HOKKkx1w9y8dY5rVEOf7KfDtSAfx015e5cFJG6u6Sew79DxNw0xs8cz >									
	//        <  u =="0.000000000000000001" : ] 000000788695494.718646000000000000 ; 000000805185563.730986000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B3742D4CC9D9C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}