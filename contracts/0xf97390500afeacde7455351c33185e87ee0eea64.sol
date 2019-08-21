pragma solidity 		^0.4.21	;						
										
	contract	AZOV_PFII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	AZOV_PFII_III_883		"	;
		string	public		symbol =	"	AZOV_PFII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1619444852181480000000000000					;	
										
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
	//     < AZOV_PFII_III_metadata_line_1_____Td_Yug_Rusi_20251101 >									
	//        < 8CsyPlu6Mz5FL7c3608H8yAf0XlLqT4VGq7bJ42l8VN3Nr3X2zQt0rEJdjXSC732 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000035389211.760980700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000035FFE9 >									
	//     < AZOV_PFII_III_metadata_line_2_____LLC_MEZ_Yug_Rusi_20251101 >									
	//        < WTDAnw4tJR2f5lZ75DalRk3R5Xo8zeVj28F1eE82tODlpqcJjnL94X5KI0qDH11T >									
	//        <  u =="0.000000000000000001" : ] 000000035389211.760980700000000000 ; 000000087925990.534512100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000035FFE9862A17 >									
	//     < AZOV_PFII_III_metadata_line_3_____savola_foods_cis_20251101 >									
	//        < 2F7LHqTLvOZW5Q8e68T09w55Vpq86g94g7ri22K8mUj419m9DI2u996tmG321nnf >									
	//        <  u =="0.000000000000000001" : ] 000000087925990.534512100000000000 ; 000000144547285.046391000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000862A17DC8FC9 >									
	//     < AZOV_PFII_III_metadata_line_4_____labinsky_cannery_20251101 >									
	//        < trLTFzzxpsBKWSzjFMqlf4u4Ljl6Rt1A7e40O1804IOye7V6urm68Q2wXDn1cI8W >									
	//        <  u =="0.000000000000000001" : ] 000000144547285.046391000000000000 ; 000000164854000.297852000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DC8FC9FB8C18 >									
	//     < AZOV_PFII_III_metadata_line_5_____jsc_chernyansky_vegetable_oil_plant_20251101 >									
	//        < XhxDWmx2Z0vRtu9G327P3QZbl3UO16Gt6aPNDn15uxsxd71Uy80hWuVYP71vx591 >									
	//        <  u =="0.000000000000000001" : ] 000000164854000.297852000000000000 ; 000000215296455.205933000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FB8C18148842E >									
	//     < AZOV_PFII_III_metadata_line_6_____urazovsky_elevator_jsc_20251101 >									
	//        < oHPuYe2yLvriUKrH2RUIH7ea7e0aTG5hJlt271V4xxbr62M6PRMF1lVSILvRc3B4 >									
	//        <  u =="0.000000000000000001" : ] 000000215296455.205933000000000000 ; 000000298771553.715088000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000148842E1C7E3A3 >									
	//     < AZOV_PFII_III_metadata_line_7_____ooo_orskmelprom_20251101 >									
	//        < 074cLk4LDJO1ZZHg27OF3iDD89TJhluUa17393a1uMrkdf08b82iyB5OKOe9RdxR >									
	//        <  u =="0.000000000000000001" : ] 000000298771553.715088000000000000 ; 000000345673345.201016000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C7E3A320F74A7 >									
	//     < AZOV_PFII_III_metadata_line_8_____zolotaya_semechka_ooo_20251101 >									
	//        < SX38g1SaNoDp8ow4Ji8xLwSlClrqQh5s96sCQ9WZUsq2ouHZ7o108y8KYSa7qwdd >									
	//        <  u =="0.000000000000000001" : ] 000000345673345.201016000000000000 ; 000000393945627.590971000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020F74A72591D03 >									
	//     < AZOV_PFII_III_metadata_line_9_____ooo_grain_union_20251101 >									
	//        < 2O8Rb73U2i1IOIook96MuM9PhwDqGN2Tuf547Bx1SJ0EibO86Y5zOH3Sz1P9BC07 >									
	//        <  u =="0.000000000000000001" : ] 000000393945627.590971000000000000 ; 000000431963673.524645000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002591D032931FCF >									
	//     < AZOV_PFII_III_metadata_line_10_____valuysky_vegetable_oil_plant_20251101 >									
	//        < 6eB2Wp1PcBySm5TuJ3jjR8o0AO7X3vVquJn4eF70gbWA6vNk8c09k3Dvh6573Aao >									
	//        <  u =="0.000000000000000001" : ] 000000431963673.524645000000000000 ; 000000467181773.580263000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002931FCF2C8DCE1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < AZOV_PFII_III_metadata_line_11_____ooo_yugagro_leasing_20251101 >									
	//        < 48kCFalZQxaYV9wW1Ap2XPSbs59RXH3Hm2k7rjl6d55HsmR0UGcIpMBy50YE5E0c >									
	//        <  u =="0.000000000000000001" : ] 000000467181773.580263000000000000 ; 000000531326781.071899000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C8DCE132ABD86 >									
	//     < AZOV_PFII_III_metadata_line_12_____torgovy_dom_yug_rusi_ooo_20251101 >									
	//        < yMd7rKP253c4po8n7bdvj45eIhsWrtn3dYZ8X203KMyag8a9SjDCU7O0JvZljvnj >									
	//        <  u =="0.000000000000000001" : ] 000000531326781.071899000000000000 ; 000000572957266.043690000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032ABD8636A436F >									
	//     < AZOV_PFII_III_metadata_line_13_____trading_house_wj_cis_20251101 >									
	//        < 9j0EKoj33t0x5m9n85jI66qd91Jg6aWRoA0M2jT29152P850O2RyhvkLg28o7t0r >									
	//        <  u =="0.000000000000000001" : ] 000000572957266.043690000000000000 ; 000000613134981.353707000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036A436F3A791DA >									
	//     < AZOV_PFII_III_metadata_line_14_____ojsc_tselinkhlebprodukt_20251101 >									
	//        < 5dXZ5Rx62Q3r55hpye5luu2q66BsKwav046Id7C56WUCU4jy262Z73A707tJ3FMs >									
	//        <  u =="0.000000000000000001" : ] 000000613134981.353707000000000000 ; 000000636438396.148976000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A791DA3CB20C0 >									
	//     < AZOV_PFII_III_metadata_line_15_____ooo_orskaya_pasta_factory_20251101 >									
	//        < q3O8t6Yisr6kr4P0rtS4MWCEQP8317oerP9QX3ca4cHAlaW4rFKJoeE2cc257Ekv >									
	//        <  u =="0.000000000000000001" : ] 000000636438396.148976000000000000 ; 000000669284684.407867000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003CB20C03FD3F54 >									
	//     < AZOV_PFII_III_metadata_line_16_____Azs Yug Rusi_20251101 >									
	//        < 0jgH7ku8FTR0y1uMML2Cla22uSOuUCkF3rwS9Jh1y49WH1N9I61l2i65omhgGM6n >									
	//        <  u =="0.000000000000000001" : ] 000000669284684.407867000000000000 ; 000000690877332.207445000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003FD3F5441E31F5 >									
	//     < AZOV_PFII_III_metadata_line_17_____Bina_grup_20251101 >									
	//        < f1FT7985a4Rbn06Az1jP3Xwu4a7AHTed9927O4052u928mmL1n5Tlt3vT6S5BNI2 >									
	//        <  u =="0.000000000000000001" : ] 000000690877332.207445000000000000 ; 000000742609658.158802000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041E31F546D21E6 >									
	//     < AZOV_PFII_III_metadata_line_18_____BINA_INTEGRATED_TECHNOLOGY_SDN_BHD_20251101 >									
	//        < n2pkTK6VTej2a0cGhL9u01270s2APm2HODbTtI8x1W6RJjo201klL4877oMBEEXW >									
	//        <  u =="0.000000000000000001" : ] 000000742609658.158802000000000000 ; 000000790853316.586885000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046D21E64B6BF14 >									
	//     < AZOV_PFII_III_metadata_line_19_____BINA_INTEGRATED_INDUSTRIES_SDN_BHD_20251101 >									
	//        < LymzJVP4DERUgJlLEWlBfxPa4B9Kdeaery1VDT8tXid1xl2LCLh0n00pPv8t8HrL >									
	//        <  u =="0.000000000000000001" : ] 000000790853316.586885000000000000 ; 000000812637955.156666000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B6BF144D7FCB4 >									
	//     < AZOV_PFII_III_metadata_line_20_____BINA_PAINT_MARKETING_SDN_BHD_20251101 >									
	//        < RM7fFq2mU11306WLz3EgNhP0X2aLVMo720w33kBq71kf81F1pzii0t67f2Mm6ODg >									
	//        <  u =="0.000000000000000001" : ] 000000812637955.156666000000000000 ; 000000841256983.334850000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004D7FCB4503A802 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < AZOV_PFII_III_metadata_line_21_____Yevroplast_20251101 >									
	//        < 81566C4501YH4eSV93WtxNf3u64Jivjc1TysAeQyu3snE4F0ScZQ9MeQlJ1wq441 >									
	//        <  u =="0.000000000000000001" : ] 000000841256983.334850000000000000 ; 000000876616909.641619000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000503A8025399C7B >									
	//     < AZOV_PFII_III_metadata_line_22_____Grain_export_infrastructure_org_20251101 >									
	//        < rxe3PYGm3Oji4YnjviAMD5AfY6gdNWlV0doBQM92O14Uk5uI0o6zFLiO9Hk2ehxe >									
	//        <  u =="0.000000000000000001" : ] 000000876616909.641619000000000000 ; 000000897813919.186313000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005399C7B559F490 >									
	//     < AZOV_PFII_III_metadata_line_23_____Kherson_Port_org_20251101 >									
	//        < Tc7h3oOqtAMX64M6Uyz0c5KD0848yTYU2b9nbNxxN5q9m07k46sKsM34fuHrmkEj >									
	//        <  u =="0.000000000000000001" : ] 000000897813919.186313000000000000 ; 000000919611095.575742000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000559F49057B3716 >									
	//     < AZOV_PFII_III_metadata_line_24_____Donskoy_Tabak_20251101 >									
	//        < 899zTJWnTMlr6yU85b5BD158l64mA0x30uk2j0Pp5GgUt6BY9J8vOIu8a3CX54ye >									
	//        <  u =="0.000000000000000001" : ] 000000919611095.575742000000000000 ; 000000938346444.773220000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000057B3716597CD94 >									
	//     < AZOV_PFII_III_metadata_line_25_____Japan_Tobacco_International_20251101 >									
	//        < 5g7doFhzYNoQ18p01TGf9FLWf0h4fCA2mdC2w2n2xTAoQQ7Luu3Z8D2X2NwCxNR6 >									
	//        <  u =="0.000000000000000001" : ] 000000938346444.773220000000000000 ; 000000961364192.881439000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000597CD945BAECE3 >									
	//     < AZOV_PFII_III_metadata_line_26_____Akhra_2006_20251101 >									
	//        < PdJn4PnBBxe403q2ey5qLs0t2BDw3ACW675iwH0QTq4F6MJlNL6302Hnczc7HB6C >									
	//        <  u =="0.000000000000000001" : ] 000000961364192.881439000000000000 ; 000001029963917.792510000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005BAECE362399A8 >									
	//     < AZOV_PFII_III_metadata_line_27_____Sekap_SA_20251101 >									
	//        < 9Wp44TG93E7ZPFiz2Wp24c7cTMwlbjHY9gOI5DkF4pj7R1wfz12o7a2JrO4XI31G >									
	//        <  u =="0.000000000000000001" : ] 000001029963917.792510000000000000 ; 000001067494261.894200000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000062399A865CDDF2 >									
	//     < AZOV_PFII_III_metadata_line_28_____jt_international_korea_inc_20251101 >									
	//        < g54yN92NPnuNtDhC99YD2L8rEw8PvLDvhiSzHRUByl7bZbiX55FWMVNuuXR3W2KA >									
	//        <  u =="0.000000000000000001" : ] 000001067494261.894200000000000000 ; 000001093664194.335240000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000065CDDF2684CC93 >									
	//     < AZOV_PFII_III_metadata_line_29_____tanzania_cigarette_company_20251101 >									
	//        < 66xu2U8gnmJaw3AJ0Fz2jGt0h5x6mwbBCI4Qb352JwFn34h4G9B1wmrWi4TbU90k >									
	//        <  u =="0.000000000000000001" : ] 000001093664194.335240000000000000 ; 000001145642580.929750000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000684CC936D41CA2 >									
	//     < AZOV_PFII_III_metadata_line_30_____jt_international_holding_bv_20251101 >									
	//        < 6JLe66H4Xy4Y1F0PF5WH383n3j3Ds7HSeI5o3AjqDbAlP0lzZbY64l5q0yP8Q7l4 >									
	//        <  u =="0.000000000000000001" : ] 000001145642580.929750000000000000 ; 000001169934295.990190000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006D41CA26F92D96 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < AZOV_PFII_III_metadata_line_31_____kannenberg_barker_hail_cotton_tabacos_ltda_20251101 >									
	//        < zplEyAPvPdLsRS92Dp3m8iJm7DjZ1kP0UxHisOkmn1i0D22pRqzmvj3X7s48PBV5 >									
	//        <  u =="0.000000000000000001" : ] 000001169934295.990190000000000000 ; 000001190464714.174080000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006F92D967188147 >									
	//     < AZOV_PFII_III_metadata_line_32_____jt_international_iberia_sl_20251101 >									
	//        < 4Y08d8x4IKqPQoJY4XPRev9vQUiejWATGclk23Ak3rpo23yrHhN9Ck6NVWDuj86A >									
	//        <  u =="0.000000000000000001" : ] 000001190464714.174080000000000000 ; 000001253026057.489360000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007188147777F74E >									
	//     < AZOV_PFII_III_metadata_line_33_____jt_international_company_netherlands_bv_20251101 >									
	//        < 2EfbTlr2z159Z1C7399FI0I9yu9XFXwk1thmJH3MT0z5UvD5sXL70ilzC3QJuM62 >									
	//        <  u =="0.000000000000000001" : ] 000001253026057.489360000000000000 ; 000001284861570.116360000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000777F74E7A88B0D >									
	//     < AZOV_PFII_III_metadata_line_34_____Gryson_nv_20251101 >									
	//        < 75gc4b97oEz0As6F8Km99v52oH5vz9ha2ivRlgm88d9hrVQZRHx434ess8b4PBgO >									
	//        <  u =="0.000000000000000001" : ] 000001284861570.116360000000000000 ; 000001359789202.843730000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007A88B0D81ADFA8 >									
	//     < AZOV_PFII_III_metadata_line_35_____duvanska_industrija_senta_20251101 >									
	//        < xke0rY1pukbF4TV0j7G4cH3YE28mVFjnZe1OaNv2QD11Jb8NiM8uuVD7IKNrQuY0 >									
	//        <  u =="0.000000000000000001" : ] 000001359789202.843730000000000000 ; 000001390128129.880070000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000081ADFA88492ACD >									
	//     < AZOV_PFII_III_metadata_line_36_____kannenberg_cia_ltda_20251101 >									
	//        < 73Ql217772JXdS12irhKa92fCEK50aejw7lbRz2eB22A3OU8QdI6E83hD29DVn04 >									
	//        <  u =="0.000000000000000001" : ] 000001390128129.880070000000000000 ; 000001458823498.320960000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008492ACD8B1FCEE >									
	//     < AZOV_PFII_III_metadata_line_37_____jti_leaf_services_us_llc_20251101 >									
	//        < M0CJ0VACTAasSO3HN3khgus7Uv348Y6K5SrS0QA8P20AXoXD73cynU461CT1O14K >									
	//        <  u =="0.000000000000000001" : ] 000001458823498.320960000000000000 ; 000001482031489.114280000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008B1FCEE8D5668D >									
	//     < AZOV_PFII_III_metadata_line_38_____cigarros_la_tabacalera_mexicana_sa_cv_20251101 >									
	//        < Jl2GN7Oxfp93vy4Xb0GUbw7Uokx77r5uO3lyWlexT1UZhIR986evT5VYWuIEVj1L >									
	//        <  u =="0.000000000000000001" : ] 000001482031489.114280000000000000 ; 000001555299558.022900000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008D5668D94532E4 >									
	//     < AZOV_PFII_III_metadata_line_39_____jti_pars_pjsco_20251101 >									
	//        < xZpicpkbJQY846uPPEdE05eAra6AjurEBYxoAodAE0VKx983i4tkT7xzXAVgE5K0 >									
	//        <  u =="0.000000000000000001" : ] 000001555299558.022900000000000000 ; 000001578566060.104220000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000094532E4968B35E >									
	//     < AZOV_PFII_III_metadata_line_40_____jti_uk_finance_limited_20251101 >									
	//        < 7SXWOEy8OZ2v5qtseoDw8039XuXBgf57UHF53FaY1ZHbed02301n6lLT5ZwD43r6 >									
	//        <  u =="0.000000000000000001" : ] 000001578566060.104220000000000000 ; 000001619444852.181480000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000968B35E9A713A5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}