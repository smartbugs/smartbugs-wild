pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXIII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXIII_III_883		"	;
		string	public		symbol =	"	RUSS_PFXXXIII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1030594566749250000000000000					;	
										
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
	//     < RUSS_PFXXXIII_III_metadata_line_1_____PIK_GROUP_20251101 >									
	//        < 9Bi56P9xi4XtcVs488k8DW27EIJzXqZhzsE3095m2850vMhqUHbkN2hGT3Kp8f81 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000026942407.981191100000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000291C61 >									
	//     < RUSS_PFXXXIII_III_metadata_line_2_____PIK_INDUSTRIYA_20251101 >									
	//        < lQDrGxUDL5S7u2gBV99o2xOrhP695R66v9RyMLLq9yRIM290yLcHQM1Wo630p4mv >									
	//        <  u =="0.000000000000000001" : ] 000000026942407.981191100000000000 ; 000000062644460.320875100000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000291C615F967E >									
	//     < RUSS_PFXXXIII_III_metadata_line_3_____STROYINVEST_20251101 >									
	//        < Gx4OEo4xQO18l046gKAvW9T8qxdsT5gTCWDbX0M0Oem0cE437aIbwxTpa0CaO6d0 >									
	//        <  u =="0.000000000000000001" : ] 000000062644460.320875100000000000 ; 000000094809191.423854400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005F967E90AAD7 >									
	//     < RUSS_PFXXXIII_III_metadata_line_4_____PIK_TECHNOLOGY_20251101 >									
	//        < B5Xi35S4biDXLRXtSqn73Up8r4plaDcvzAYCYg97655MW8jDR9C3Bq2TlJqhLDXN >									
	//        <  u =="0.000000000000000001" : ] 000000094809191.423854400000000000 ; 000000124417879.653184000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000090AAD7BDD8BC >									
	//     < RUSS_PFXXXIII_III_metadata_line_5_____PIK_REGION_20251101 >									
	//        < J20H2Y5gp197hJO7815x7FlO6RtC0uO602hfB9Mpqse2nq70Y2E2hCLo0yRCpC2V >									
	//        <  u =="0.000000000000000001" : ] 000000124417879.653184000000000000 ; 000000151550959.431489000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BDD8BCE73F98 >									
	//     < RUSS_PFXXXIII_III_metadata_line_6_____PIK_NERUD_OOO_20251101 >									
	//        < yUWnVJ6UlVL6LbGb100kL8B4xD5uEN2V0mui1RbPDY87nJHO7588m276KX9fkzlU >									
	//        <  u =="0.000000000000000001" : ] 000000151550959.431489000000000000 ; 000000182382731.099086000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E73F981164B41 >									
	//     < RUSS_PFXXXIII_III_metadata_line_7_____PIK_MFS_OOO_20251101 >									
	//        < R5ppbccw5o05PC8Q3V34X2n94ZFk082Rb23393c16g1kzb9vKH56Fy8xNfi4BrBg >									
	//        <  u =="0.000000000000000001" : ] 000000182382731.099086000000000000 ; 000000203005450.154404000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001164B41135C301 >									
	//     < RUSS_PFXXXIII_III_metadata_line_8_____PIK_COMFORT_20251101 >									
	//        < ELB3HN65hrZmV2ly0EmjsLP20CNbR4tyle9pr8T1uTQq3LUZ304SrCa2bgh9htPp >									
	//        <  u =="0.000000000000000001" : ] 000000203005450.154404000000000000 ; 000000226781125.259280000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000135C30115A0A61 >									
	//     < RUSS_PFXXXIII_III_metadata_line_9_____TRADING_HOUSE_OSNOVA_20251101 >									
	//        < aTRjxgw4UKG3u91pzQB3r5XuU3kxIwAf6QPVX76498K3x88CT73x37Vy0BNm8uKc >									
	//        <  u =="0.000000000000000001" : ] 000000226781125.259280000000000000 ; 000000248467049.468427000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015A0A6117B2171 >									
	//     < RUSS_PFXXXIII_III_metadata_line_10_____KHROMTSOVSKY_KARIER_20251101 >									
	//        < D3Wg30Q8ojVre9nh1IUPTYuIvXINjA989y0a6Gk2Ez9uq7JyrZVC6Ki8MG2SSe00 >									
	//        <  u =="0.000000000000000001" : ] 000000248467049.468427000000000000 ; 000000281032679.820549000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017B21711ACD264 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXIII_III_metadata_line_11_____480_KZHI_20251101 >									
	//        < 26Uyl6tnB86EhpVaV48nk0g4b20Sy498Kj9Pv9445BrnG55i5Tv6segY4Zyd3J6p >									
	//        <  u =="0.000000000000000001" : ] 000000281032679.820549000000000000 ; 000000304850329.929269000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001ACD2641D12A29 >									
	//     < RUSS_PFXXXIII_III_metadata_line_12_____PIK_YUG_OOO_20251101 >									
	//        < r0nXaRX6YZH39bzc3D4xrTMH1V5U649QA2ZLI22IGjCG9O0jM941hAi84i7erR46 >									
	//        <  u =="0.000000000000000001" : ] 000000304850329.929269000000000000 ; 000000324077772.587878000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D12A291EE80E1 >									
	//     < RUSS_PFXXXIII_III_metadata_line_13_____YUGOOO_ORG_20251101 >									
	//        < KC7Wg86oLrZ2f1Z3cKOQ05V61O40aFPM32m3MQh4lmm6qi39t28rvjYAO0DKz6kx >									
	//        <  u =="0.000000000000000001" : ] 000000324077772.587878000000000000 ; 000000343716357.218880000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EE80E120C7834 >									
	//     < RUSS_PFXXXIII_III_metadata_line_14_____KRASNAYA_PRESNYA_SUGAR_REFINERY_20251101 >									
	//        < 1Pu334U7N1cJ577qQ1L6bB5PT3nzg5ryhmwu6x8hoK57P841FB1LNHJ6VSy4hL9d >									
	//        <  u =="0.000000000000000001" : ] 000000343716357.218880000000000000 ; 000000365403587.554265000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020C783422D8FC7 >									
	//     < RUSS_PFXXXIII_III_metadata_line_15_____NOVOROSGRAGDANPROEKT_20251101 >									
	//        < Q1jO8j0U75qSUis1Sw5052mFt3v3WDYv5EiYoia72u1V6J39Fan21pKioi4eKD1T >									
	//        <  u =="0.000000000000000001" : ] 000000365403587.554265000000000000 ; 000000397896233.723898000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022D8FC725F2437 >									
	//     < RUSS_PFXXXIII_III_metadata_line_16_____STATUS_LAND_OOO_20251101 >									
	//        < Auj1X4Z34q7ja41L7Efeita0Wn7Bo6H9i7ld906z4NP23OQCs8DKADr4vc3Pvq7q >									
	//        <  u =="0.000000000000000001" : ] 000000397896233.723898000000000000 ; 000000425405640.846182000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025F24372891E14 >									
	//     < RUSS_PFXXXIII_III_metadata_line_17_____PIK_PODYOM_20251101 >									
	//        < Kb2PXK8Sw5lPWy5rv8340711B7c7f2Ew9S4FUD7l0YC04Ihf414i7eRSt4z90tDW >									
	//        <  u =="0.000000000000000001" : ] 000000425405640.846182000000000000 ; 000000453138389.278019000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002891E142B36F2F >									
	//     < RUSS_PFXXXIII_III_metadata_line_18_____PODYOM_ORG_20251101 >									
	//        < Qg6MzDn3CX8n0krX8ab8l9h5P0Gp3cFabdgiAmDu3F2hwjZZYuwlAxhV3F7Whw17 >									
	//        <  u =="0.000000000000000001" : ] 000000453138389.278019000000000000 ; 000000475598163.398340000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B36F2F2D5B488 >									
	//     < RUSS_PFXXXIII_III_metadata_line_19_____PIK_COMFORT_OOO_20251101 >									
	//        < 093DVg5TOsd6qywJ09D02dQ79I1xa5gcYsE4LN3K1y4533xIZ42sYf1qFY0B7Scf >									
	//        <  u =="0.000000000000000001" : ] 000000475598163.398340000000000000 ; 000000494379668.826883000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D5B4882F25D0F >									
	//     < RUSS_PFXXXIII_III_metadata_line_20_____PIK_KUBAN_20251101 >									
	//        < Hnhx7KMF2mS2gUBHj6E7y9G5H8dcyls9LfNG0AsdzbL4M71X4G6NL3HeE60beeCb >									
	//        <  u =="0.000000000000000001" : ] 000000494379668.826883000000000000 ; 000000523374648.746946000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F25D0F31E9B39 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXIII_III_metadata_line_21_____KUBAN_ORG_20251101 >									
	//        < nxMAcu0cH7mMk7Xkc2cakA1pOb8l8Iz7Bs33DFYU081wlEU59v7FfuL6C8LQ5PCZ >									
	//        <  u =="0.000000000000000001" : ] 000000523374648.746946000000000000 ; 000000543993008.537921000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031E9B3933E1145 >									
	//     < RUSS_PFXXXIII_III_metadata_line_22_____MORTON_OOO_20251101 >									
	//        < H2t6vRR29WLrgtWNsXMAbG6o6F3Ia4dnCqwQuKW916cA9IVLKATn0au5hjOs18cQ >									
	//        <  u =="0.000000000000000001" : ] 000000543993008.537921000000000000 ; 000000572797212.496707000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033E114536A04E9 >									
	//     < RUSS_PFXXXIII_III_metadata_line_23_____ZAO_PIK_REGION_20251101 >									
	//        < F55nb79SE5BSpPXKv1vBDZB3tylo770eZHSwj6OKq43p86tiLd3aR943MS3Js843 >									
	//        <  u =="0.000000000000000001" : ] 000000572797212.496707000000000000 ; 000000594734042.253125000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036A04E938B7DFC >									
	//     < RUSS_PFXXXIII_III_metadata_line_24_____ZAO_MONETTSCHIK_20251101 >									
	//        < 86c3VPA7hr1uCM7od65WwA6lSVO9p42ggJk299Y3Oub6u6YwzVtPG0IgOPx9fsp1 >									
	//        <  u =="0.000000000000000001" : ] 000000594734042.253125000000000000 ; 000000613291545.922557000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038B7DFC3A7CF03 >									
	//     < RUSS_PFXXXIII_III_metadata_line_25_____STROYFORMAT_OOO_20251101 >									
	//        < 703TGIbfrt32lPLcNu20EqkRu1H2v4g13tR5KkiESC3z5ZJCd7csqj18fXar1pBK >									
	//        <  u =="0.000000000000000001" : ] 000000613291545.922557000000000000 ; 000000632437549.895199000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A7CF033C505EB >									
	//     < RUSS_PFXXXIII_III_metadata_line_26_____VOLGA_FORM_REINFORCED_CONCRETE_PLANT_20251101 >									
	//        < 5EExOf0ZhhALUSP0y19x5JjR0CAAJdAT9RF08tG1saP2hGy35bqOhXU6424Lcjv5 >									
	//        <  u =="0.000000000000000001" : ] 000000632437549.895199000000000000 ; 000000662951837.404015000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C505EB3F39590 >									
	//     < RUSS_PFXXXIII_III_metadata_line_27_____ZARECHYE_SPORT_20251101 >									
	//        < i2xHa7E7aB2O79K9d450pJ90V69ZdDvz0q05GD4U74hS4875MTE9l14uI1SV94SN >									
	//        <  u =="0.000000000000000001" : ] 000000662951837.404015000000000000 ; 000000681960361.055407000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F3959041096C4 >									
	//     < RUSS_PFXXXIII_III_metadata_line_28_____PIK_PROFILE_OOO_20251101 >									
	//        < 2C2I1j04Z9rTvJp1Hy4kj2f5bfBku1p6UpJ48bGSyA5N0lMpd70nzM6VjIEs9CdZ >									
	//        <  u =="0.000000000000000001" : ] 000000681960361.055407000000000000 ; 000000700669970.356907000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041096C442D2335 >									
	//     < RUSS_PFXXXIII_III_metadata_line_29_____FENTROUMA_HOLDINGS_LIMITED_20251101 >									
	//        < piBNh4M7Q9yals9whuM8uKzqmu1FBcF83lUGcaQ0K04vVYP2sIbGtZa6ly55NVGg >									
	//        <  u =="0.000000000000000001" : ] 000000700669970.356907000000000000 ; 000000735893207.040821000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042D2335462E249 >									
	//     < RUSS_PFXXXIII_III_metadata_line_30_____PODMOKOVYE_20251101 >									
	//        < 8C69U4MpJDBcddaOf0Dj72ly49HST5PLvsDPn8z71AQyP2Z7019V5wZdk94V2SVh >									
	//        <  u =="0.000000000000000001" : ] 000000735893207.040821000000000000 ; 000000764690528.078836000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000462E24948ED33D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXIII_III_metadata_line_31_____STROYINVESTREGION_20251101 >									
	//        < 97ApH1GYmy39j00VNtgPb6W9c8lz8PP575juMYqe6uckoy09CUO0WEKTRjN528IJ >									
	//        <  u =="0.000000000000000001" : ] 000000764690528.078836000000000000 ; 000000797310004.706217000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048ED33D4C09938 >									
	//     < RUSS_PFXXXIII_III_metadata_line_32_____PIK_DEVELOPMENT_20251101 >									
	//        < nRx0NGm996d1XneN458R6DgejmKw1v17z9taeX93dY4geKI98LI1U95t6bR7k6C0 >									
	//        <  u =="0.000000000000000001" : ] 000000797310004.706217000000000000 ; 000000821449942.837276000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004C099384E56EE2 >									
	//     < RUSS_PFXXXIII_III_metadata_line_33_____TAKSOMOTORNIY_PARK_20251101 >									
	//        < a354B1PyFu2H6pKt19394ng5aU2ycYH1de322QfwWDVZNNphzShDMdWP85PQSYa3 >									
	//        <  u =="0.000000000000000001" : ] 000000821449942.837276000000000000 ; 000000840282799.207051000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004E56EE25022B78 >									
	//     < RUSS_PFXXXIII_III_metadata_line_34_____KALTENBERG_LIMITED_20251101 >									
	//        < 6ISVkF8ymZ33808lgE29FE5eI8PKc4ofrgeW5fNXWdkyR10m7r9X31PE7v2Ahx1i >									
	//        <  u =="0.000000000000000001" : ] 000000840282799.207051000000000000 ; 000000864906460.875193000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005022B78527BE16 >									
	//     < RUSS_PFXXXIII_III_metadata_line_35_____MAYAK_OOO_20251101 >									
	//        < QSKhSh7c5yt3f67CznqFwg208QgC83003F3Yx3d32LHn9u13a4YJ9M749C9rUsnX >									
	//        <  u =="0.000000000000000001" : ] 000000864906460.875193000000000000 ; 000000896198855.921040000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000527BE165577DAE >									
	//     < RUSS_PFXXXIII_III_metadata_line_36_____MAYAK_ORG_20251101 >									
	//        < 194GP7P4yIRoTk0wK68Ig5b0waEgFr4DJqydmn5rzVFFw6dd2YZc4OMf4W8sa6D4 >									
	//        <  u =="0.000000000000000001" : ] 000000896198855.921040000000000000 ; 000000925196979.175898000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005577DAE583BD12 >									
	//     < RUSS_PFXXXIII_III_metadata_line_37_____UDSK_OOO_20251101 >									
	//        < 6hHM5qPnvUQmCEK2898u5v852z3x5LB6x7G6GFtlU4M9zdNgN5ztveT49UF22q9p >									
	//        <  u =="0.000000000000000001" : ] 000000925196979.175898000000000000 ; 000000951275893.814168000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000583BD125AB8825 >									
	//     < RUSS_PFXXXIII_III_metadata_line_38_____ROSTOVSKOYE_MORE_OOO_20251101 >									
	//        < 18EkM82YO5A2hrf1gX2Rg6vJIl0aj0Y09w8h9pjRZ2LU57863c0B0h507tNZ8faW >									
	//        <  u =="0.000000000000000001" : ] 000000951275893.814168000000000000 ; 000000985711032.309320000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005AB88255E0135F >									
	//     < RUSS_PFXXXIII_III_metadata_line_39_____MONETCHIK_20251101 >									
	//        < 2O7lPMEe69mV7C9JYb241cE0R35pOTw3NUyQ0D36bV5cP3S6cTV2X42turA9989D >									
	//        <  u =="0.000000000000000001" : ] 000000985711032.309320000000000000 ; 000001008473296.295620000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005E0135F602CEE2 >									
	//     < RUSS_PFXXXIII_III_metadata_line_40_____KUSKOVSKOGO_ORDENA_ZNAK_POCHETA_CHEM_PLANT_20251101 >									
	//        < z70Q1bKF5i09dHcNc0LyH27n8qJMU63439sS625pH1r8p6tefAfcd93dvG8fv0I3 >									
	//        <  u =="0.000000000000000001" : ] 000001008473296.295620000000000000 ; 000001030594566.749250000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000602CEE26249001 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}