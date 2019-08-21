pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFIV_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFIV_I_883		"	;
		string	public		symbol =	"	RUSS_PFIV_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		551263562969539000000000000					;	
										
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
	//     < RUSS_PFIV_I_metadata_line_1_____NOVOLIPETSK_20211101 >									
	//        < 61ZI82xVUb0S9W2nYw9313355On9C7924rHJZpC45GLEPP735QQCYtvQ864grmB2 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000013782853.736402000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001507ED >									
	//     < RUSS_PFIV_I_metadata_line_2_____FLETCHER_GROUP_HOLDINGS_LIMITED_20211101 >									
	//        < EFWA1XnDfcF1kGKj1367oUc7d87OR138VFWBsQtV5iBZgLdcCBwJk6lq6215eAqf >									
	//        <  u =="0.000000000000000001" : ] 000000013782853.736402000000000000 ; 000000027930828.071557100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001507ED2A9E7B >									
	//     < RUSS_PFIV_I_metadata_line_3_____UNIVERSAL_CARGO_LOGISTICS_HOLDINGS_BV_20211101 >									
	//        < 2skK6Ky1Wv829d37f457W3hDYWz8m2MKb8sPv6IxukjHtCtJznU3B0dS481nytir >									
	//        <  u =="0.000000000000000001" : ] 000000027930828.071557100000000000 ; 000000041954110.627371000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002A9E7B400453 >									
	//     < RUSS_PFIV_I_metadata_line_4_____STOILENSKY_GOK_20211101 >									
	//        < rN4it883XZbvtO4SIfGW36W5ZMeqVy59HYR95e7O3yklg7tbY5tJafT9wmB99xwR >									
	//        <  u =="0.000000000000000001" : ] 000000041954110.627371000000000000 ; 000000055456022.849798600000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000400453549E82 >									
	//     < RUSS_PFIV_I_metadata_line_5_____ALTAI_KOKS_20211101 >									
	//        < 1nKM6MwjJsr01xG5WxmXeJforv7GE3fHFd0jJ8421TisGp6ugUy0L176Tm9xXWhH >									
	//        <  u =="0.000000000000000001" : ] 000000055456022.849798600000000000 ; 000000068577751.402161800000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000549E8268A42F >									
	//     < RUSS_PFIV_I_metadata_line_6_____VIZ_STAL_20211101 >									
	//        < IXZSs11b78oGHXCkS8PgW8rqBDv28f0e4r7qX8Noji8S0D9sOfrYnr0gZtFCT7pR >									
	//        <  u =="0.000000000000000001" : ] 000000068577751.402161800000000000 ; 000000082432226.787404900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000068A42F7DC817 >									
	//     < RUSS_PFIV_I_metadata_line_7_____NLMK_PLATE_SALES_SA_20211101 >									
	//        < DwcbY8LW9G9KxZ7rX3Fiuf6vaLBwN9cttSVc75abQWys6GDtMc564GZAYRS4Q62V >									
	//        <  u =="0.000000000000000001" : ] 000000082432226.787404900000000000 ; 000000096098225.224516200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007DC81792A25F >									
	//     < RUSS_PFIV_I_metadata_line_8_____NLMK_INDIANA_LLC_20211101 >									
	//        < sw158DEI1v370EpbceozLRI0T30KtDQKAVbGz3x6itq8f2t2i9h1pw4KFhxSUB30 >									
	//        <  u =="0.000000000000000001" : ] 000000096098225.224516200000000000 ; 000000110065453.483729000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000092A25FA7F251 >									
	//     < RUSS_PFIV_I_metadata_line_9_____STEEL_FUNDING_DAC_20211101 >									
	//        < x0ETTL6eR393Ci57MEDU8rS2D61copn0AgVd3sPB2h67aPy6x4i6x2ePu2GwU75X >									
	//        <  u =="0.000000000000000001" : ] 000000110065453.483729000000000000 ; 000000124395942.359507000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A7F251BDD02A >									
	//     < RUSS_PFIV_I_metadata_line_10_____ZAO_URALS_PRECISION_ALLOYS_PLANT_20211101 >									
	//        < 4S66XjwzzTle5Nn41y1v5EfdnL5OMyhxgS2F7R9TtQc0fuYF1xtSte7l8W2VZH8S >									
	//        <  u =="0.000000000000000001" : ] 000000124395942.359507000000000000 ; 000000138846338.101156000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BDD02AD3DCDA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIV_I_metadata_line_11_____TOP_GUN_INVESTMENT_CORP_20211101 >									
	//        < Xfe7HJ7ud6dE6678HUe6i8x8AJ47F0TZNZ0gj4Mqh5aUuo7JJuMPe93tm39fbm2y >									
	//        <  u =="0.000000000000000001" : ] 000000138846338.101156000000000000 ; 000000152729279.018380000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D3DCDAE90BE0 >									
	//     < RUSS_PFIV_I_metadata_line_12_____NLMK_ARKTIKGAZ_20211101 >									
	//        < 34ml3Q99iO3bpc239xqsui8HxnooGMToDjt5Ntffh67mjHaD46sifEA1fIVp2or9 >									
	//        <  u =="0.000000000000000001" : ] 000000152729279.018380000000000000 ; 000000165748651.789575000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E90BE0FCE991 >									
	//     < RUSS_PFIV_I_metadata_line_13_____TUSCANY_INTERTRADE_20211101 >									
	//        < mF07dBxEfzb3tQ4vpCW6Fv7SPgJyjjiLPmHqkYfj3860Vt6QeO1w96F399fPMOkM >									
	//        <  u =="0.000000000000000001" : ] 000000165748651.789575000000000000 ; 000000179771111.613534000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FCE9911124F17 >									
	//     < RUSS_PFIV_I_metadata_line_14_____MOORFIELD_COMMODITIES_20211101 >									
	//        < LiiQ6J803VWo1miRm8932lQ3N5DyFcd43W48iDWVx7jrLAN64S5k6T0ln21LwcE8 >									
	//        <  u =="0.000000000000000001" : ] 000000179771111.613534000000000000 ; 000000193095443.275374000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001124F17126A3E8 >									
	//     < RUSS_PFIV_I_metadata_line_15_____NLMK_COATING_20211101 >									
	//        < M2SMwINvi3GF1tuo15l7Xd08yO4FhEpX3H7RKl16m9aZo6u0x1317C368n8B36dY >									
	//        <  u =="0.000000000000000001" : ] 000000193095443.275374000000000000 ; 000000207766999.303434000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000126A3E813D06FC >									
	//     < RUSS_PFIV_I_metadata_line_16_____NLMK_MAXI_GROUP_20211101 >									
	//        < 1ueMIwx8rAnyh02SPajax71421q3631u46Q0P6jC9fnufzN1xN62SMK1nS220f3s >									
	//        <  u =="0.000000000000000001" : ] 000000207766999.303434000000000000 ; 000000222341826.973281000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013D06FC1534447 >									
	//     < RUSS_PFIV_I_metadata_line_17_____NLMK_SERVICES_LLC_20211101 >									
	//        < FY38FdlPJ549Pe6XoUGDZ4boMp6w1m8sr63IZi2A5WyE50tKM48w5b984nMI8Nke >									
	//        <  u =="0.000000000000000001" : ] 000000222341826.973281000000000000 ; 000000235562833.688552000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000153444716770BB >									
	//     < RUSS_PFIV_I_metadata_line_18_____STEEL_INVEST_FINANCE_20211101 >									
	//        < ugzAAMMkwxek2u58O7f12PD22TQIrlUg0l3e2MkJBrB295Yyn7xGIZ40TO9f010Q >									
	//        <  u =="0.000000000000000001" : ] 000000235562833.688552000000000000 ; 000000249795749.489214000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016770BB17D2877 >									
	//     < RUSS_PFIV_I_metadata_line_19_____CLABECQ_20211101 >									
	//        < P269kGO3iwW6pTKc5i2w1VlE7kXREa9c2jmeC6Lq8rwgh88Fls6846ct25Kd19eV >									
	//        <  u =="0.000000000000000001" : ] 000000249795749.489214000000000000 ; 000000263218381.539435000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017D2877191A3AE >									
	//     < RUSS_PFIV_I_metadata_line_20_____HOLIDAY_HOTEL_NLMK_20211101 >									
	//        < 9beGFsR9k19G7Uh20k0FGh8i8SEfz6y8Fl30KKyX6c0P4DnU65p48Ktl8arGfA8F >									
	//        <  u =="0.000000000000000001" : ] 000000263218381.539435000000000000 ; 000000276566093.596788000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000191A3AE1A601A1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIV_I_metadata_line_21_____STEELCO_MED_TRADING_20211101 >									
	//        < a02Gc0d7rKmw97FCT8Lc8x5TZrj8SvdAY5yNU1a87Wnicb0DYNYtbf3hjIGWDy7E >									
	//        <  u =="0.000000000000000001" : ] 000000276566093.596788000000000000 ; 000000289715111.459232000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A601A11BA11F7 >									
	//     < RUSS_PFIV_I_metadata_line_22_____LIPETSKY_GIPROMEZ_20211101 >									
	//        < 4l227lg01RghWSx3v737M3zLO6TwgrKWh2a5ppFqwVZMC4ZxY12k87wzFfVxWOXh >									
	//        <  u =="0.000000000000000001" : ] 000000289715111.459232000000000000 ; 000000304183023.711150000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BA11F71D0257E >									
	//     < RUSS_PFIV_I_metadata_line_23_____NORTH_OIL_GAS_CO_20211101 >									
	//        < 813rmKx8gnIlaS9U9Hjf7m98kyZ0xcPwHYy144nvPj15E5Bg13FtLerKE4g5bT5g >									
	//        <  u =="0.000000000000000001" : ] 000000304183023.711150000000000000 ; 000000317733198.767461000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D0257E1E4D288 >									
	//     < RUSS_PFIV_I_metadata_line_24_____STOYLENSKY_GOK_20211101 >									
	//        < YXj8GH79T4iGA0aJJrm794wywdYG11P5t51S86ytf646ds9bJ964s941hwCx06jy >									
	//        <  u =="0.000000000000000001" : ] 000000317733198.767461000000000000 ; 000000331095428.221367000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E4D2881F93627 >									
	//     < RUSS_PFIV_I_metadata_line_25_____NLMK_RECORDING_CENTER_OOO_20211101 >									
	//        < jvIM50v28xXR0acoa29kjI1BEPIWLeay2Nd1xp4cY2ou1ZDJXdh3YJ3TQkg12FNw >									
	//        <  u =="0.000000000000000001" : ] 000000331095428.221367000000000000 ; 000000345486027.219160000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F9362720F2B7B >									
	//     < RUSS_PFIV_I_metadata_line_26_____URAL_ARCHI_CONSTRUCTION_RD_INSTITUTE_20211101 >									
	//        < r278QpX9X8U8512US3A6eTcmgUWKK3eLmKcqaVdPd4jjCV08HV0C08G7P15rdySl >									
	//        <  u =="0.000000000000000001" : ] 000000345486027.219160000000000000 ; 000000358990234.108993000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020F2B7B223C68F >									
	//     < RUSS_PFIV_I_metadata_line_27_____PO_URALMETALLURGSTROY_ZAO_20211101 >									
	//        < RbQftdpJjr4u8yGQzz1Au466O2r5RzX167Ut2OKVUeT4VKSScL0ySM3Of2W2ckqg >									
	//        <  u =="0.000000000000000001" : ] 000000358990234.108993000000000000 ; 000000372237511.749523000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000223C68F237FD47 >									
	//     < RUSS_PFIV_I_metadata_line_28_____NLMK_LONG_PRODUCTS_20211101 >									
	//        < HF24kh36gPwc2o19dz95bSr89Ko0xfb6wxgk3Ksk62iSLZs65SdZuk53oD5wS92Z >									
	//        <  u =="0.000000000000000001" : ] 000000372237511.749523000000000000 ; 000000386175018.750232000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000237FD4724D419E >									
	//     < RUSS_PFIV_I_metadata_line_29_____USSURIYSKAYA_SCRAP_METAL_20211101 >									
	//        < GE4lTR982A4dWrucKpJc36CNhjep488LY3Dax8XMiOW8aB3wpZZ4l7sjsrU2840C >									
	//        <  u =="0.000000000000000001" : ] 000000386175018.750232000000000000 ; 000000399573745.069331000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024D419E261B37F >									
	//     < RUSS_PFIV_I_metadata_line_30_____NOVOLIPETSKY_PRINTING_HOUSE_20211101 >									
	//        < 8CWR2fj5U6Zh3oIL3N4AM9oY8V9fd565M2WJbr83JdipM9K92i4W8I7y9L8CwUF9 >									
	//        <  u =="0.000000000000000001" : ] 000000399573745.069331000000000000 ; 000000412616871.512249000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000261B37F2759A77 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIV_I_metadata_line_31_____CHUPIT_LIMITED_20211101 >									
	//        < Thf1W3VF29r3DDuHkNE9W9SjKjNikwx8X9pi3Bf546OyWzpsU798Se35H1Z88jb0 >									
	//        <  u =="0.000000000000000001" : ] 000000412616871.512249000000000000 ; 000000426546396.884615000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002759A7728ADBB0 >									
	//     < RUSS_PFIV_I_metadata_line_32_____ZHERNOVSKY_I_MINING_PROCESS_COMPLEX_20211101 >									
	//        < 6EovEiv7MNNTz8WJ7VD91prrbS7c39h67Qwt20iUe00N5Dl8JAXiO23GiFW10207 >									
	//        <  u =="0.000000000000000001" : ] 000000426546396.884615000000000000 ; 000000439891253.488242000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028ADBB029F3885 >									
	//     < RUSS_PFIV_I_metadata_line_33_____KSIEMP_20211101 >									
	//        < n6ju30Q1E7Sm6W83js3cCRCjV8yX8vk31wmAXurjAAB4280sMMfhCqDi90mKxmBX >									
	//        <  u =="0.000000000000000001" : ] 000000439891253.488242000000000000 ; 000000453066313.816076000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029F38852B35307 >									
	//     < RUSS_PFIV_I_metadata_line_34_____STROITELNY_MONTAZHNYI_TREST_20211101 >									
	//        < 9Dq521y2mg3I879l1nYUco6YJww30s1DvF0bA2IjYcb9JQ16rL4l51KePvQSN6pp >									
	//        <  u =="0.000000000000000001" : ] 000000453066313.816076000000000000 ; 000000467758676.192767000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B353072C9BE3C >									
	//     < RUSS_PFIV_I_metadata_line_35_____VTORMETSNAB_20211101 >									
	//        < qnmiyydPSu3g15B94nLHE9qsLPUo075A91Y0gDkDj0MTQ93IvHy6l756DeO4259N >									
	//        <  u =="0.000000000000000001" : ] 000000467758676.192767000000000000 ; 000000482526459.327522000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C9BE3C2E046E6 >									
	//     < RUSS_PFIV_I_metadata_line_36_____DOLOMIT_20211101 >									
	//        < a4Bc63HU4lZY4SJ45j1a8586L171JqKkW76stGAD85wpwbfo91romang34gRdUdF >									
	//        <  u =="0.000000000000000001" : ] 000000482526459.327522000000000000 ; 000000495829496.749937000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E046E62F49366 >									
	//     < RUSS_PFIV_I_metadata_line_37_____KALUGA_ELECTRIC_STEELMAKING_PLANT_20211101 >									
	//        < qJ8qGgOLLx72su7290so8GaRlOm1eYOs96BKRqnT1WY8f4p26pHi1T1I8i9HMiU4 >									
	//        <  u =="0.000000000000000001" : ] 000000495829496.749937000000000000 ; 000000510228335.542233000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F4936630A8BF2 >									
	//     < RUSS_PFIV_I_metadata_line_38_____LIPETSKOMBANK_20211101 >									
	//        < 65H80RwFEoi5eV8q5FFsLrbsjf31VGmK1L30539S8k13QfxdyFa2sCZQuWP0Wlm5 >									
	//        <  u =="0.000000000000000001" : ] 000000510228335.542233000000000000 ; 000000524430421.901071000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030A8BF232037A2 >									
	//     < RUSS_PFIV_I_metadata_line_39_____NIZHNESERGINSKY_HARDWARE_METALL_WORKS_20211101 >									
	//        < W8NOHc56sFHo6857xTV846A3a0N5xnZ3OcTg9oeOW879TN939cgkwX93rT3kCLJj >									
	//        <  u =="0.000000000000000001" : ] 000000524430421.901071000000000000 ; 000000537919573.612975000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032037A2334CCD5 >									
	//     < RUSS_PFIV_I_metadata_line_40_____KALUGA_SCIENTIFIC_PROD_ELECTROMETALL_PLANT_20211101 >									
	//        < PpkCSQ6MTU8dFm13u4pW25WsiyfcMEMtwn8kPWw8kxck1ltsKBF6pNPoITD8dd69 >									
	//        <  u =="0.000000000000000001" : ] 000000537919573.612975000000000000 ; 000000551263562.969539000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000334CCD53492954 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}