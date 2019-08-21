pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXIII_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXIII_I_883		"	;
		string	public		symbol =	"	RUSS_PFXXIII_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		598460805690771000000000000					;	
										
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
	//     < RUSS_PFXXIII_I_metadata_line_1_____INGOSSTRAKH_20211101 >									
	//        < QvyMJQJ6hMy6bzJmm424h8SK0q0yzJ7731KKqzQ6RT6t67S95q3APTjyv30Hql39 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000014096008.185657300000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000158241 >									
	//     < RUSS_PFXXIII_I_metadata_line_2_____ROSGOSSTRAKH_20211101 >									
	//        < t3aDjneP7xOo7NzIDMjs51px81Crv56kvZ69u5L2xJE0132bL3tBlc1AR5FzAU6J >									
	//        <  u =="0.000000000000000001" : ] 000000014096008.185657300000000000 ; 000000027649262.267274100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001582412A307E >									
	//     < RUSS_PFXXIII_I_metadata_line_3_____TINKOFF_INSURANCE_20211101 >									
	//        < 20tY5X450A0oJBDe4hsgLEe7HLVN019u37dBErp8fuBZQcfsKX3PAvGXT3Pa28Y3 >									
	//        <  u =="0.000000000000000001" : ] 000000027649262.267274100000000000 ; 000000041064563.359106500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002A307E3EA8D8 >									
	//     < RUSS_PFXXIII_I_metadata_line_4_____MOSCOW_EXCHANGE_20211101 >									
	//        < doEz8N9aE0oF122puXzslG4k65Ybb1RVkWXwhLC2Cf7WJT3Mf0Pt6MKtzI33VIlS >									
	//        <  u =="0.000000000000000001" : ] 000000041064563.359106500000000000 ; 000000054423401.823059000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003EA8D8530B24 >									
	//     < RUSS_PFXXIII_I_metadata_line_5_____YANDEX_20211101 >									
	//        < a0fkmK1CXlHD7z5cmcQWAB95qYgP4j7UkkHLLK2w5U6HD82D4OleGuY0094L85dX >									
	//        <  u =="0.000000000000000001" : ] 000000054423401.823059000000000000 ; 000000071684069.261187600000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000530B246D6197 >									
	//     < RUSS_PFXXIII_I_metadata_line_6_____UNIPRO_20211101 >									
	//        < q5b5UjPpnux4cVn51anFG42YuJ1tE5S2PuP9BRIt37mXU9HA2rLo6F4amgeV7XGB >									
	//        <  u =="0.000000000000000001" : ] 000000071684069.261187600000000000 ; 000000087884076.198637200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006D61978619B8 >									
	//     < RUSS_PFXXIII_I_metadata_line_7_____DIXY_20211101 >									
	//        < 74g1hC70wIvDx5hRq6c58w92q8JL3FMb4I0V7uZH4uW67KTjE686n63Q98O73UbN >									
	//        <  u =="0.000000000000000001" : ] 000000087884076.198637200000000000 ; 000000104898213.236019000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008619B8A00FDD >									
	//     < RUSS_PFXXIII_I_metadata_line_8_____MECHEL_20211101 >									
	//        < d4XyJ7ERHX0TQTdj53P18AOJgnqF1QU4S70xLn0e9zfu7Ea0fPlv091siyZyZWeS >									
	//        <  u =="0.000000000000000001" : ] 000000104898213.236019000000000000 ; 000000118747513.221717000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A00FDDB531BF >									
	//     < RUSS_PFXXIII_I_metadata_line_9_____VSMPO_AVISMA_20211101 >									
	//        < Gs7B515x00zt9uO6k2F092z5OLGB6E6n8Kf5u12T1VvP8rRu91qz3An0zx6xjFG3 >									
	//        <  u =="0.000000000000000001" : ] 000000118747513.221717000000000000 ; 000000132235981.522588000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B531BFC9C6AE >									
	//     < RUSS_PFXXIII_I_metadata_line_10_____AGRIUM_20211101 >									
	//        < S2KE5T1BTfH0Kex8Xrttn9M2Y6Wuz9HP0e28z06eZ4ak0Y0z2e4295Y9tZ6mK5pQ >									
	//        <  u =="0.000000000000000001" : ] 000000132235981.522588000000000000 ; 000000145667875.433190000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C9C6AEDE4584 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXIII_I_metadata_line_11_____ONEXIM_20211101 >									
	//        < fkp1oq43y4cz2YIHHqdiWjSeq4Mh57rS09fqr2OPY81E44S7Y4qOUJrTI15KxMxv >									
	//        <  u =="0.000000000000000001" : ] 000000145667875.433190000000000000 ; 000000161653260.605247000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DE4584F6A9CE >									
	//     < RUSS_PFXXIII_I_metadata_line_12_____SILOVYE_MACHINY_20211101 >									
	//        < un104nGc21N42OrNKAc5Yu7xW86nm6DpzIAZq13IaUbRuF218te4OveP3v8W5Wmv >									
	//        <  u =="0.000000000000000001" : ] 000000161653260.605247000000000000 ; 000000176151520.985544000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F6A9CE10CC930 >									
	//     < RUSS_PFXXIII_I_metadata_line_13_____RPC_UWC_20211101 >									
	//        < 8R19VM5xRZUTP5rxqnbA9Sk2VB16P5F6hfT33DDgy00ul64682hYD6WI2D06e1ZY >									
	//        <  u =="0.000000000000000001" : ] 000000176151520.985544000000000000 ; 000000191302935.049666000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010CC930123E7B6 >									
	//     < RUSS_PFXXIII_I_metadata_line_14_____INTERROS_20211101 >									
	//        < lmV8D7Ge1seC0XDMEObO0ihe7FRV4OAhDOclyw07G2WK53VS2n4Ee906p8WF0erM >									
	//        <  u =="0.000000000000000001" : ] 000000191302935.049666000000000000 ; 000000207653460.535938000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000123E7B613CDAA2 >									
	//     < RUSS_PFXXIII_I_metadata_line_15_____PROF_MEDIA_20211101 >									
	//        < 55NN50B5eO47Wj1FH7y1WGbfhod1S6Y5b1FMB9YE4j7YzC1AACNH560vEM5HB25R >									
	//        <  u =="0.000000000000000001" : ] 000000207653460.535938000000000000 ; 000000223174995.797754000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013CDAA215489BC >									
	//     < RUSS_PFXXIII_I_metadata_line_16_____ACRON_GROUP_20211101 >									
	//        < pkU575658M1X830Vq0vfc7yUWZgkjqJbVj3Wi4FU3MuzrAg17n938rY9Ez3477br >									
	//        <  u =="0.000000000000000001" : ] 000000223174995.797754000000000000 ; 000000239038084.826515000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015489BC16CBE40 >									
	//     < RUSS_PFXXIII_I_metadata_line_17_____RASSVET_20211101 >									
	//        < q0TTN4jpyhewDc8JI02lG688fmtMDRyi8652A4ohxt709zfjnMSt1ihiut8edim3 >									
	//        <  u =="0.000000000000000001" : ] 000000239038084.826515000000000000 ; 000000254427122.721591000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016CBE401843998 >									
	//     < RUSS_PFXXIII_I_metadata_line_18_____LUZHSKIY_KOMBIKORMOVIY_ZAVOD_20211101 >									
	//        < WM514wRHiw3O22t3afw8htpBR9zn0Z38pPqOaVPP6m5HXDUcgB8H4I1U2Mum5897 >									
	//        <  u =="0.000000000000000001" : ] 000000254427122.721591000000000000 ; 000000267725679.523566000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018439981988458 >									
	//     < RUSS_PFXXIII_I_metadata_line_19_____LSR GROUP_20211101 >									
	//        < h0JQ0T9jSgK2q1Yq2mUJn4VG1LVSc6njv4R2bM6nCwOogzefUc6PSrsr6s1P4T9z >									
	//        <  u =="0.000000000000000001" : ] 000000267725679.523566000000000000 ; 000000282477603.146494000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019884581AF06D0 >									
	//     < RUSS_PFXXIII_I_metadata_line_20_____MMK_20211101 >									
	//        < 63uk9vOx1k86gse8b5pX27Gf1p0mExrAeBd1880NAY6FBr0j6OEaWSc33zByvhe0 >									
	//        <  u =="0.000000000000000001" : ] 000000282477603.146494000000000000 ; 000000298256034.981207000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AF06D01C71A43 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXIII_I_metadata_line_21_____MOESK_20211101 >									
	//        < vbV5h0vdF750mAfug9fvHCApFqWVZS1HW7tS5W6Zh1cusZ2uAY2910eFjY9SOc3J >									
	//        <  u =="0.000000000000000001" : ] 000000298256034.981207000000000000 ; 000000312269962.316714000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C71A431DC7C74 >									
	//     < RUSS_PFXXIII_I_metadata_line_22_____MOSTOTREST_20211101 >									
	//        < cOOIjS9o7D26qgASNFmhgu931d9SYK8bFNqu83c6390l0B6OH9UVTt9Geg7wRn88 >									
	//        <  u =="0.000000000000000001" : ] 000000312269962.316714000000000000 ; 000000326510104.875940000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DC7C741F23702 >									
	//     < RUSS_PFXXIII_I_metadata_line_23_____MVIDEO_20211101 >									
	//        < b46Zd5doN3Qi2t0o055WcLm3pLgCOog8Kj7f1KVq8Vp31CEM7Z3egmFW6RQTr11U >									
	//        <  u =="0.000000000000000001" : ] 000000326510104.875940000000000000 ; 000000340426535.487920000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F23702207731E >									
	//     < RUSS_PFXXIII_I_metadata_line_24_____NCSP_20211101 >									
	//        < 60N7REeJmsu1MHscYwlZER4VRGyZ088Z34Wv9UW1Boy6Uzq8m6MWEKM29k6AF85H >									
	//        <  u =="0.000000000000000001" : ] 000000340426535.487920000000000000 ; 000000354959635.905771000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000207731E21DA01C >									
	//     < RUSS_PFXXIII_I_metadata_line_25_____MOSAIC_COMPANY_20211101 >									
	//        < 66g0fdfKOmNWLFfxGv4C5tFi05nE5O1977qt9N40q02fVb52YmmZtQw6Rhtx40QA >									
	//        <  u =="0.000000000000000001" : ] 000000354959635.905771000000000000 ; 000000368170048.341126000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021DA01C231C86D >									
	//     < RUSS_PFXXIII_I_metadata_line_26_____METALLOINVEST_20211101 >									
	//        < 3F7V8V39p0W28b6GoD96FOfpN1K4xYTEsC8QuOH7CA0hm5j3hkT17txZW7eC9oNK >									
	//        <  u =="0.000000000000000001" : ] 000000368170048.341126000000000000 ; 000000384333035.767007000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000231C86D24A7218 >									
	//     < RUSS_PFXXIII_I_metadata_line_27_____TOGLIATTIAZOT_20211101 >									
	//        < xc6UBuLkQIck06U0dieeIIp2KIrnd3a80Zyw3O5G7eZ4981GlDo3uiE2Z38Fut2i >									
	//        <  u =="0.000000000000000001" : ] 000000384333035.767007000000000000 ; 000000399357060.106974000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024A72182615EDA >									
	//     < RUSS_PFXXIII_I_metadata_line_28_____METAFRAKS_PAO_20211101 >									
	//        < c07rfY8GS2bRnIEfhX9D8r1wlHa11x5B49hJlJa5674BKdsyUJxAUlBw10cY59DT >									
	//        <  u =="0.000000000000000001" : ] 000000399357060.106974000000000000 ; 000000414280900.532851000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002615EDA278247A >									
	//     < RUSS_PFXXIII_I_metadata_line_29_____OGK_2_CHEREPOVETS_GRES_20211101 >									
	//        < JU2dHIzm70nXRk6iaN9TB6494CqHVIZ76xI2p9clUL6TB3C0Gq8J618gXuh9kR61 >									
	//        <  u =="0.000000000000000001" : ] 000000414280900.532851000000000000 ; 000000429284273.186281000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000278247A28F092B >									
	//     < RUSS_PFXXIII_I_metadata_line_30_____OGK_2_GRES_24_20211101 >									
	//        < Oy4IZ7e6Gwnb0ym6D9wCyHJtVwIKB1M7247D5wBvq9c2Bda532hOgcwZkS2q3Vs3 >									
	//        <  u =="0.000000000000000001" : ] 000000429284273.186281000000000000 ; 000000445137246.364960000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028F092B2A739BD >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXIII_I_metadata_line_31_____PHOSAGRO_20211101 >									
	//        < psL4iZEe29fF9lcNyD29Cj434N0kszi8uc1Buv75R5By2McHR46888lFOYm7EjKA >									
	//        <  u =="0.000000000000000001" : ] 000000445137246.364960000000000000 ; 000000461219836.047514000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A739BD2BFC400 >									
	//     < RUSS_PFXXIII_I_metadata_line_32_____BELARUSKALI_20211101 >									
	//        < 7xeZAXnVY3yYbROWAZlu7QSWF136u76CFBYR7MUo3qAMEDG1SVCYPQ25X41NesiK >									
	//        <  u =="0.000000000000000001" : ] 000000461219836.047514000000000000 ; 000000477297572.681284000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BFC4002D84C5D >									
	//     < RUSS_PFXXIII_I_metadata_line_33_____KPLUSS_20211101 >									
	//        < L8ql160fICfY3SZ80Fd1C97698asR5857x2160j2cKKvj8DYDfoSsQxba1P88uHo >									
	//        <  u =="0.000000000000000001" : ] 000000477297572.681284000000000000 ; 000000494391390.692455000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D84C5D2F261A3 >									
	//     < RUSS_PFXXIII_I_metadata_line_34_____KPLUSS_ORG_20211101 >									
	//        < vPFi218g57436c88OvUI57Es2wx0z07Fl4LAT7X00bNGX5t5NfEw0gsu13oFL4gy >									
	//        <  u =="0.000000000000000001" : ] 000000494391390.692455000000000000 ; 000000507861903.009261000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F261A3306EF8E >									
	//     < RUSS_PFXXIII_I_metadata_line_35_____POTASHCORP_20211101 >									
	//        < Xp2zvRF5EsFjq667RC0uXRd1i8dkJYK41Ujj0La41f77uLl1zaA3O9uPW82xksLC >									
	//        <  u =="0.000000000000000001" : ] 000000507861903.009261000000000000 ; 000000523523803.618245000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000306EF8E31ED57C >									
	//     < RUSS_PFXXIII_I_metadata_line_36_____BANK_URALSIB_20211101 >									
	//        < CuD3GY67kj7ki8EJ17y4uTLntM2Nh0N18JM1CUx9oN7n48lM48UKv7S636zNC8xZ >									
	//        <  u =="0.000000000000000001" : ] 000000523523803.618245000000000000 ; 000000539349611.048488000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031ED57C336FB71 >									
	//     < RUSS_PFXXIII_I_metadata_line_37_____URALSIB_LEASING_CO_20211101 >									
	//        < S985E8657SmHyJ757sl87IXo041nnu6O5Z4c8XA941r04C1LE7I35Ng7pen6HUhG >									
	//        <  u =="0.000000000000000001" : ] 000000539349611.048488000000000000 ; 000000552620564.720052000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000336FB7134B3B68 >									
	//     < RUSS_PFXXIII_I_metadata_line_38_____BANK_URALSIB_AM_20211101 >									
	//        < 0Xc3DFt23NbEc2i1v5H645wG4qTP5xw1X2N9HOhq82k35u57TqziK8RgJoS9f707 >									
	//        <  u =="0.000000000000000001" : ] 000000552620564.720052000000000000 ; 000000568650115.877424000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034B3B68363B0F4 >									
	//     < RUSS_PFXXIII_I_metadata_line_39_____BASHKIRSKIY_20211101 >									
	//        < Imj40g36Z6Gd1P3DuPz776MV04pW1k5niwuaR68v554p1rJTBlxYO5I79es97bRA >									
	//        <  u =="0.000000000000000001" : ] 000000568650115.877424000000000000 ; 000000585010430.843006000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000363B0F437CA7B3 >									
	//     < RUSS_PFXXIII_I_metadata_line_40_____URALSIB_INVESTMENT_ARM_20211101 >									
	//        < S0M3fH4NZM3CG4BwNbbo4J1l2ODnn8hOc5s1hwW7Ywtrl4vf4ZXDrQ252Ejpr8E9 >									
	//        <  u =="0.000000000000000001" : ] 000000585010430.843006000000000000 ; 000000598460805.690771000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037CA7B33912DC1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}