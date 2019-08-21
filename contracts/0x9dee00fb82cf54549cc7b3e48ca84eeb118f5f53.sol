pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXIII_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXIII_I_883		"	;
		string	public		symbol =	"	RUSS_PFXXXIII_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		613007041352206000000000000					;	
										
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
	//     < RUSS_PFXXXIII_I_metadata_line_1_____PIK_GROUP_20211101 >									
	//        < z3zUewe64j5qYRI19PtHpqVTN91R2qZ325aox2q7fHExFfD1b2fhR9DXoenHdmr8 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000016187729.897294500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000018B355 >									
	//     < RUSS_PFXXXIII_I_metadata_line_2_____PIK_INDUSTRIYA_20211101 >									
	//        < laIhRgC7TSL1NdODDsKChdQ12C31NDBnC7wOfPv6JcOgA0tXvBxfsRAq7C16dN7F >									
	//        <  u =="0.000000000000000001" : ] 000000016187729.897294500000000000 ; 000000032943540.059724900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000018B355324492 >									
	//     < RUSS_PFXXXIII_I_metadata_line_3_____STROYINVEST_20211101 >									
	//        < 5izj01U2N6IipFs0aP2621F4p4OuU4bs8qteHwmyF7L6A6qnvAhrtatVBd1je6PR >									
	//        <  u =="0.000000000000000001" : ] 000000032943540.059724900000000000 ; 000000046438645.309193900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000032449246DC19 >									
	//     < RUSS_PFXXXIII_I_metadata_line_4_____PIK_TECHNOLOGY_20211101 >									
	//        < GMhLH3EBX187RW2pmvsEThZ9kTfYJHaq4208bH8Zb7f1z9U1l2dZbLa090c04oKT >									
	//        <  u =="0.000000000000000001" : ] 000000046438645.309193900000000000 ; 000000062322647.909619700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000046DC195F18C9 >									
	//     < RUSS_PFXXXIII_I_metadata_line_5_____PIK_REGION_20211101 >									
	//        < 7XR7NC0j0AHV18y4r6as20hlK8T09oso4pe5EpoUMtZtys01MeI8GZZlzoO8xe2p >									
	//        <  u =="0.000000000000000001" : ] 000000062322647.909619700000000000 ; 000000079480616.368655700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005F18C979471E >									
	//     < RUSS_PFXXXIII_I_metadata_line_6_____PIK_NERUD_OOO_20211101 >									
	//        < WNkt40rq13368IwI6Ob5Hs40U3y220wm069zc5GUE21092yvCqaB0vwI9Qbv5ryu >									
	//        <  u =="0.000000000000000001" : ] 000000079480616.368655700000000000 ; 000000094795865.626811300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000079471E90A5A3 >									
	//     < RUSS_PFXXXIII_I_metadata_line_7_____PIK_MFS_OOO_20211101 >									
	//        < F1MQ6PIqh3hP7wW4X49pRoK8g7yggWtpK2jZO9141282L2z5po20G63l29l65AtO >									
	//        <  u =="0.000000000000000001" : ] 000000094795865.626811300000000000 ; 000000111472047.961209000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000090A5A3AA17C5 >									
	//     < RUSS_PFXXXIII_I_metadata_line_8_____PIK_COMFORT_20211101 >									
	//        < deZD82iv135tkCeXUv5UZFmjC2Z0Oe5SFfOMZ7k9YY75CUq8Z5rc7Gi0oxVBp7q4 >									
	//        <  u =="0.000000000000000001" : ] 000000111472047.961209000000000000 ; 000000125528580.142460000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AA17C5BF8A9A >									
	//     < RUSS_PFXXXIII_I_metadata_line_9_____TRADING_HOUSE_OSNOVA_20211101 >									
	//        < k9hGmWYoZJhUu62QhMLUHdDHCabqO53G6tUP516UO4IBt6zDTVK65VS80O23NlV1 >									
	//        <  u =="0.000000000000000001" : ] 000000125528580.142460000000000000 ; 000000139414144.338201000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BF8A9AD4BAA6 >									
	//     < RUSS_PFXXXIII_I_metadata_line_10_____KHROMTSOVSKY_KARIER_20211101 >									
	//        < TfF8aEydHnNNd1etIXLPTM6RD6v9mD44lpPalQww94x7nNgXJV84x2ceqtwLF69f >									
	//        <  u =="0.000000000000000001" : ] 000000139414144.338201000000000000 ; 000000154222771.839772000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D4BAA6EB5345 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXIII_I_metadata_line_11_____480_KZHI_20211101 >									
	//        < 6M00Q0lADW1mbi2BXMz3y4Fu87BV6O9lGwJyX9N7xp4JEh8Tmw6YZGN9AW1zHTcW >									
	//        <  u =="0.000000000000000001" : ] 000000154222771.839772000000000000 ; 000000170050296.565889000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EB534510379E6 >									
	//     < RUSS_PFXXXIII_I_metadata_line_12_____PIK_YUG_OOO_20211101 >									
	//        < 3ORx1jIN8HwJEc1H7ZclAr6O1D99eCQ2kW9BuPpyAt6c0SIC4MkqczmE4cjGMbI0 >									
	//        <  u =="0.000000000000000001" : ] 000000170050296.565889000000000000 ; 000000186653376.006379000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010379E611CCF7A >									
	//     < RUSS_PFXXXIII_I_metadata_line_13_____YUGOOO_ORG_20211101 >									
	//        < P9y9aI1NRz4BoeOh05MD75r0U5YXTCU3d1P3oZl9Gw2mfB7TaAQb847571eSzhJ3 >									
	//        <  u =="0.000000000000000001" : ] 000000186653376.006379000000000000 ; 000000200674537.715874000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011CCF7A132347E >									
	//     < RUSS_PFXXXIII_I_metadata_line_14_____KRASNAYA_PRESNYA_SUGAR_REFINERY_20211101 >									
	//        < 0IzgWy6LWL3ai5WEN9JG88UR78ge7E7oM6EiTZLm6DQgV4Zy901hztM5VYFNhp4m >									
	//        <  u =="0.000000000000000001" : ] 000000200674537.715874000000000000 ; 000000217172201.181365000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000132347E14B60E4 >									
	//     < RUSS_PFXXXIII_I_metadata_line_15_____NOVOROSGRAGDANPROEKT_20211101 >									
	//        < u769yQ27OkLdv2jp9SfW58T85f64IAxI1mbJAe4BG2k60D7y49D9H55IKfj80E27 >									
	//        <  u =="0.000000000000000001" : ] 000000217172201.181365000000000000 ; 000000232516706.758014000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014B60E4162CAD7 >									
	//     < RUSS_PFXXXIII_I_metadata_line_16_____STATUS_LAND_OOO_20211101 >									
	//        < xJQ9V70OT1553c4LRaFm8ut5qvWVi7Xv1y675H1e8aou0Q53r7fIsQaH8s73OoU5 >									
	//        <  u =="0.000000000000000001" : ] 000000232516706.758014000000000000 ; 000000247657972.835506000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000162CAD7179E565 >									
	//     < RUSS_PFXXXIII_I_metadata_line_17_____PIK_PODYOM_20211101 >									
	//        < it59pS19C0gSmg3Nd42nxjrYf3i9H7rB199j3b476IQ7s1Nl1JdP0kRJEB4M8LnX >									
	//        <  u =="0.000000000000000001" : ] 000000247657972.835506000000000000 ; 000000263327663.945916000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000179E565191CE5E >									
	//     < RUSS_PFXXXIII_I_metadata_line_18_____PODYOM_ORG_20211101 >									
	//        < k1M4f3ZiLmbd5n9DF2921m1pN6A25q1n9aWz7b0yvZgi8TZvxnjAFww67H6n6v21 >									
	//        <  u =="0.000000000000000001" : ] 000000263327663.945916000000000000 ; 000000278988882.017683000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000191CE5E1A9B408 >									
	//     < RUSS_PFXXXIII_I_metadata_line_19_____PIK_COMFORT_OOO_20211101 >									
	//        < DU9lfmSeAZ180K2juVV0vSQQFaBb80hK2fyii6T9Qy5bJ6gaIS0tDHzs5zdh0S2n >									
	//        <  u =="0.000000000000000001" : ] 000000278988882.017683000000000000 ; 000000292381121.488323000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A9B4081BE2360 >									
	//     < RUSS_PFXXXIII_I_metadata_line_20_____PIK_KUBAN_20211101 >									
	//        < 50X8IDPDD1mH8Ih95WGV8Ot80nZai1Jsh4YO120g456b2pKroc6iXQZskwF54L09 >									
	//        <  u =="0.000000000000000001" : ] 000000292381121.488323000000000000 ; 000000306703437.073479000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BE23601D3FE08 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXIII_I_metadata_line_21_____KUBAN_ORG_20211101 >									
	//        < vGvaz0h65TIMPCrzry2Z4YuL6bj2zV26701k086gdg2HB3Ih36d30hkUL5z9UeG1 >									
	//        <  u =="0.000000000000000001" : ] 000000306703437.073479000000000000 ; 000000321573864.237981000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D3FE081EAAECA >									
	//     < RUSS_PFXXXIII_I_metadata_line_22_____MORTON_OOO_20211101 >									
	//        < w3ROwK4J1DU1gHjNJVQHx2xqsJU7h47Ql1eD27WyZe67psTfm72R8V0kvZPc4a6d >									
	//        <  u =="0.000000000000000001" : ] 000000321573864.237981000000000000 ; 000000337170267.103618000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EAAECA2027B23 >									
	//     < RUSS_PFXXXIII_I_metadata_line_23_____ZAO_PIK_REGION_20211101 >									
	//        < vTJPeGbIWcb2lXFI3N76Bb4n4U74GBsk14UAGegcGgXHFXbfWj81Nqt1qx2IsvLq >									
	//        <  u =="0.000000000000000001" : ] 000000337170267.103618000000000000 ; 000000351909814.360443000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002027B23218F8C5 >									
	//     < RUSS_PFXXXIII_I_metadata_line_24_____ZAO_MONETTSCHIK_20211101 >									
	//        < 7HbMXaUGFp00q0GYsF2stz7Ik7r066aKqOEZeIeRA1V95Y3S216Jj7963N6cz170 >									
	//        <  u =="0.000000000000000001" : ] 000000351909814.360443000000000000 ; 000000367934567.924359000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000218F8C52316C71 >									
	//     < RUSS_PFXXXIII_I_metadata_line_25_____STROYFORMAT_OOO_20211101 >									
	//        < VOak7ot2nVj8VRE8xO3lM2fc9R6d3AR1Mos18G359kYWtZQVf2tL4FCyn4Gq84i1 >									
	//        <  u =="0.000000000000000001" : ] 000000367934567.924359000000000000 ; 000000384598034.749177000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002316C7124AD99B >									
	//     < RUSS_PFXXXIII_I_metadata_line_26_____VOLGA_FORM_REINFORCED_CONCRETE_PLANT_20211101 >									
	//        < DLxCsh2SjGd4oOZkxLiI2okRa64d46tUTH8dMW3F64tOv6kSvZP01Kli4jZbwY54 >									
	//        <  u =="0.000000000000000001" : ] 000000384598034.749177000000000000 ; 000000399701350.999592000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024AD99B261E557 >									
	//     < RUSS_PFXXXIII_I_metadata_line_27_____ZARECHYE_SPORT_20211101 >									
	//        < hI2I7f1HY6xSKlUjj5j53RYGGsQ2VOFHP45p6rU81M8XSBhvTTp8zOB9hTS23l1c >									
	//        <  u =="0.000000000000000001" : ] 000000399701350.999592000000000000 ; 000000415911051.234629000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000261E55727AA141 >									
	//     < RUSS_PFXXXIII_I_metadata_line_28_____PIK_PROFILE_OOO_20211101 >									
	//        < Q8xeZLTUk79T6G8p005401aMtlZ3txHcEUI59Tqsn1JSjq3OVdD77MUOFTu4C2z9 >									
	//        <  u =="0.000000000000000001" : ] 000000415911051.234629000000000000 ; 000000432761905.439778000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027AA141294579F >									
	//     < RUSS_PFXXXIII_I_metadata_line_29_____FENTROUMA_HOLDINGS_LIMITED_20211101 >									
	//        < 7HKntZI8pj4cd79uOCqu70L7FTLY6lLBJZ6Z7x85TjVwXWBRFkOfv31nm6H2nY86 >									
	//        <  u =="0.000000000000000001" : ] 000000432761905.439778000000000000 ; 000000447779577.906738000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000294579F2AB41E6 >									
	//     < RUSS_PFXXXIII_I_metadata_line_30_____PODMOKOVYE_20211101 >									
	//        < x3OsfZ59Mtx8On965s6mbU261sz9epQR0w9Oq840o6e6h7c397g9nOv1CoYw0196 >									
	//        <  u =="0.000000000000000001" : ] 000000447779577.906738000000000000 ; 000000463796659.858658000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AB41E62C3B292 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXIII_I_metadata_line_31_____STROYINVESTREGION_20211101 >									
	//        < 4kXpRpB439zf4sWeR4N5zt5v2zi04nReSPj49d2ON90EO4PQJsH40Q8ryqQ5dVr3 >									
	//        <  u =="0.000000000000000001" : ] 000000463796659.858658000000000000 ; 000000478509824.184394000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C3B2922DA25E6 >									
	//     < RUSS_PFXXXIII_I_metadata_line_32_____PIK_DEVELOPMENT_20211101 >									
	//        < g6jq1g8SfUZZ78I9qip0ZB0JW0Jlemm647ehM3Vw57ko8HfOe0ERN8zdjgtAOBaW >									
	//        <  u =="0.000000000000000001" : ] 000000478509824.184394000000000000 ; 000000491523817.941947000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DA25E62EE017E >									
	//     < RUSS_PFXXXIII_I_metadata_line_33_____TAKSOMOTORNIY_PARK_20211101 >									
	//        < q2gceUc2wajEI4PqIuG9M8X4pk3J5WIm69nx8q9a781Ch95dFKESU951OY0z5oL5 >									
	//        <  u =="0.000000000000000001" : ] 000000491523817.941947000000000000 ; 000000505004720.088999000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EE017E3029378 >									
	//     < RUSS_PFXXXIII_I_metadata_line_34_____KALTENBERG_LIMITED_20211101 >									
	//        < 28XNr5xcR359juzGQx7bBW5Kkz9ZFv6vZ8299NPi38OXrHyVc8So0WuOeQOP7NM8 >									
	//        <  u =="0.000000000000000001" : ] 000000505004720.088999000000000000 ; 000000521022862.045571000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000302937831B048E >									
	//     < RUSS_PFXXXIII_I_metadata_line_35_____MAYAK_OOO_20211101 >									
	//        < LVmv2V48Y2cQcc2w3KV9KLhEDAdmzJf0J5naS9b04pJes5yyq82PETT04Sw65995 >									
	//        <  u =="0.000000000000000001" : ] 000000521022862.045571000000000000 ; 000000535712292.695713000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031B048E3316E9D >									
	//     < RUSS_PFXXXIII_I_metadata_line_36_____MAYAK_ORG_20211101 >									
	//        < fAs5s4A5OB8MlRp65yPAKBvYyOPesXD5ze3YxNTEzlLxc17GBCmTqqnmlmS3W0b6 >									
	//        <  u =="0.000000000000000001" : ] 000000535712292.695713000000000000 ; 000000551476226.076981000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003316E9D3497C67 >									
	//     < RUSS_PFXXXIII_I_metadata_line_37_____UDSK_OOO_20211101 >									
	//        < 5ZW2r8YyHuKmh6r0el9YiEbG4DCjXP5sUk7Z2xU8Ff72lg6Efyfy1zol2KHgw3jM >									
	//        <  u =="0.000000000000000001" : ] 000000551476226.076981000000000000 ; 000000565121164.831142000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003497C6735E4E74 >									
	//     < RUSS_PFXXXIII_I_metadata_line_38_____ROSTOVSKOYE_MORE_OOO_20211101 >									
	//        < 4K2JW8HWbTFE29VYpMJLttKW441b7t294W9v39K3F63vmLb9bpF0NpIVy3NT836P >									
	//        <  u =="0.000000000000000001" : ] 000000565121164.831142000000000000 ; 000000581839536.204972000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035E4E74377D112 >									
	//     < RUSS_PFXXXIII_I_metadata_line_39_____MONETCHIK_20211101 >									
	//        < 6FsG9cp2j7mW8Sfofq266914oWv45f0iha82wZMZYwANlW1am9N1dt6NW3ojLS3u >									
	//        <  u =="0.000000000000000001" : ] 000000581839536.204972000000000000 ; 000000595983530.105555000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000377D11238D6611 >									
	//     < RUSS_PFXXXIII_I_metadata_line_40_____KUSKOVSKOGO_ORDENA_ZNAK_POCHETA_CHEM_PLANT_20211101 >									
	//        < OR3pem0z9pfNDFAs3X7MGNrRChpbbHlA4VkB1rZjR4etT4NZBmo77F0In1fm9EvT >									
	//        <  u =="0.000000000000000001" : ] 000000595983530.105555000000000000 ; 000000613007041.352206000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038D66113A75FE0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}