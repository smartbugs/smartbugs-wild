pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFVIII_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFVIII_I_883		"	;
		string	public		symbol =	"	RUSS_PFVIII_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		598947743475382000000000000					;	
										
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
	//     < RUSS_PFVIII_I_metadata_line_1_____NOVOLIPETSK_ORG_20211101 >									
	//        < MFObbtJD2ciuEPQ3Sr6AI5pFI7Hqc3Fogor8xL16M3Mcl2H94P309OfvlGK6682Z >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000015997621.666406900000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000186912 >									
	//     < RUSS_PFVIII_I_metadata_line_2_____LLC_NTK_20211101 >									
	//        < JKwe5i9thuu8C3Rvs784AvpW1xxw0L3z7p800ON8d34zzEr6jAYlUx1A47g66uIG >									
	//        <  u =="0.000000000000000001" : ] 000000015997621.666406900000000000 ; 000000032263725.924507700000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000186912313B05 >									
	//     < RUSS_PFVIII_I_metadata_line_3_____NATIONAL_LAMINATIONS_GROUP_20211101 >									
	//        < AofhCSF3Qn656W7qh6L5Fb03659VLh6sq5h2o6GR003nL5YU1E733ooo8MAm1poz >									
	//        <  u =="0.000000000000000001" : ] 000000032263725.924507700000000000 ; 000000046213606.784518200000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000313B05468431 >									
	//     < RUSS_PFVIII_I_metadata_line_4_____DOLOMITE_OJSC_20211101 >									
	//        < ZP81LzFiG0UW9i5YNx7T82yMFMz276F8f1aB128YwJYQ9e54TGyha8k8jH2eoWc7 >									
	//        <  u =="0.000000000000000001" : ] 000000046213606.784518200000000000 ; 000000060572811.049138000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004684315C6D41 >									
	//     < RUSS_PFVIII_I_metadata_line_5_____LLC_TRADE_HOUSE_NLMK_20211101 >									
	//        < 0P30o7u4OPE869t7No5o70bc6H3cir2J9L206R8O4s774x45ebURm0X9v65a8qGs >									
	//        <  u =="0.000000000000000001" : ] 000000060572811.049138000000000000 ; 000000074634974.537277000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005C6D4171E249 >									
	//     < RUSS_PFVIII_I_metadata_line_6_____STUDENOVSK_MINING_CO_20211101 >									
	//        < FO26Pr6S29KRg42N5UMxtQ8EeWmvhy5KaR1cYzEI712mLo6P0ceg66ZH6s8DdVUo >									
	//        <  u =="0.000000000000000001" : ] 000000074634974.537277000000000000 ; 000000090225940.960993700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000071E24989AC82 >									
	//     < RUSS_PFVIII_I_metadata_line_7_____VMI_RECYCLING_GROUP_20211101 >									
	//        < 6Q6vV0l09Mgt0Hz6X334Id9O6sDXuoGxpRfe1k9BU7AOZNdjQ4V7EcVM86376Z59 >									
	//        <  u =="0.000000000000000001" : ] 000000090225940.960993700000000000 ; 000000107442192.809775000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000089AC82A3F19B >									
	//     < RUSS_PFVIII_I_metadata_line_8_____VTORCHERMET_20211101 >									
	//        < G2ojr3hPD00I500uZFR2bL7Ss031Ow6a1qIe75WKzyWPiEHh57SVZVQ1L9h6q8I9 >									
	//        <  u =="0.000000000000000001" : ] 000000107442192.809775000000000000 ; 000000121795474.113010000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A3F19BB9D85B >									
	//     < RUSS_PFVIII_I_metadata_line_9_____KALUGA_RESEARCH_PROD_ELECTROMETALL_20211101 >									
	//        < KnpvXfDQaz8KI83S2ur69W964TL0bMnnvDA4i9Dk8x58K25d0eOs12mW56sM4S0w >									
	//        <  u =="0.000000000000000001" : ] 000000121795474.113010000000000000 ; 000000138210451.440644000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B9D85BD2E475 >									
	//     < RUSS_PFVIII_I_metadata_line_10_____DANSTEEL_AS_20211101 >									
	//        < MJYJ394Ty30Ay4zZZE2U07e1952d6f39Q105524Z7r0sQ7BZqFKN5IFcH82k9CQH >									
	//        <  u =="0.000000000000000001" : ] 000000138210451.440644000000000000 ; 000000151881295.341330000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D2E475E7C0A2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFVIII_I_metadata_line_11_____NOVATEK_ORG_20211101 >									
	//        < VqDa285YGF47dqclgzztU3l73jnff7cIu00RwTy6jS8fze28u5k9It9XCE4mY73J >									
	//        <  u =="0.000000000000000001" : ] 000000151881295.341330000000000000 ; 000000166052283.038886000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E7C0A2FD602C >									
	//     < RUSS_PFVIII_I_metadata_line_12_____NOVATEK_AB_20211101 >									
	//        < rVZgReV4IFpi2MuO9mY8G9cuXEW63mKKuoRbqM7kypp2ly4P55Io2dK1Rg2H6dy3 >									
	//        <  u =="0.000000000000000001" : ] 000000166052283.038886000000000000 ; 000000183050912.148769000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FD602C1175043 >									
	//     < RUSS_PFVIII_I_metadata_line_13_____NOVATEK_DAC_20211101 >									
	//        < gH7F7Szs3v6wx0E0Dl15vj7jhkY1Y62fGKBZg70R1Y423lONU1Pbn6V6jgD7k68F >									
	//        <  u =="0.000000000000000001" : ] 000000183050912.148769000000000000 ; 000000198204339.493630000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000117504312E6F92 >									
	//     < RUSS_PFVIII_I_metadata_line_14_____PUROVSKY_ZPK_20211101 >									
	//        < 9ao6vUZnlD2A6YEz68UD4G8vt2V6R64Tnuz7JaGIE3yYSmUh0fsIBVSQ2m1Y85fk >									
	//        <  u =="0.000000000000000001" : ] 000000198204339.493630000000000000 ; 000000214167515.392787000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012E6F92146CB30 >									
	//     < RUSS_PFVIII_I_metadata_line_15_____KOSTROMA_OOO_20211101 >									
	//        < tvaF9yleIg6T823E3722O5fNXyUnk7rH96QldUXvGS52H6kx5ufbnd73aRLNgs90 >									
	//        <  u =="0.000000000000000001" : ] 000000214167515.392787000000000000 ; 000000228953401.498360000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000146CB3015D5AEC >									
	//     < RUSS_PFVIII_I_metadata_line_16_____SHERWOOD_PREMIER_LLC_20211101 >									
	//        < TkUcIUb3pus0L3o59V9rv4ajK1DUqzatOscmrpPca0C3gXd0GQ5BMIU11n1vOJEA >									
	//        <  u =="0.000000000000000001" : ] 000000228953401.498360000000000000 ; 000000243283670.350749000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015D5AEC17338AF >									
	//     < RUSS_PFVIII_I_metadata_line_17_____GEOTRANSGAZ_JSC_20211101 >									
	//        < myAf5dFe98MEjMzzT4tA71ZjIm3bk18xfkI7sYhfnj73Ha7xka1287RWyaeBC4Uo >									
	//        <  u =="0.000000000000000001" : ] 000000243283670.350749000000000000 ; 000000259341721.928311000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017338AF18BB95C >									
	//     < RUSS_PFVIII_I_metadata_line_18_____TAILIKSNEFTEGAS_20211101 >									
	//        < 59Peg6v5b0I10WsDAKF0FqHZz8C36uJ5a6TPTQ47ZmZDI7NMWDf0iYrz798IXXhW >									
	//        <  u =="0.000000000000000001" : ] 000000259341721.928311000000000000 ; 000000276019526.853635000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018BB95C1A52C21 >									
	//     < RUSS_PFVIII_I_metadata_line_19_____URENGOYSKAYA_GAZOVAYA_KOMPANIYA_20211101 >									
	//        < Eu55U5i0V2g7BhwHsvSr8rb19MkcLzH9JAQW5S1G0b72M30P5G5rNf0wMv3hQVzt >									
	//        <  u =="0.000000000000000001" : ] 000000276019526.853635000000000000 ; 000000291381354.621064000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A52C211BC9CD7 >									
	//     < RUSS_PFVIII_I_metadata_line_20_____PURNEFTEGAZGEOLOGIYA_20211101 >									
	//        < 9840Oc6f3Tjgx43I2JVaz0gvTbq8BMa4i8weABl8X7RnRnFyu87T7Ir52lV40JWw >									
	//        <  u =="0.000000000000000001" : ] 000000291381354.621064000000000000 ; 000000306610461.417288000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BC9CD71D3D9B6 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFVIII_I_metadata_line_21_____OGK_2_20211101 >									
	//        < mxT3Wi2yLB3M7N19YUm455ZAskSz44lDOj9KztrkX8501XETUIiAC0scoq9X2CjP >									
	//        <  u =="0.000000000000000001" : ] 000000306610461.417288000000000000 ; 000000321244478.337174000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D3D9B61EA2E20 >									
	//     < RUSS_PFVIII_I_metadata_line_22_____RYAZANSKAYA_GRES_OAO_20211101 >									
	//        < ndg0m0dKr4nUwuI68G1PP5Y4AV0sQ3wcxFx31YHlHso5e1p5n7u65M273Tq266DB >									
	//        <  u =="0.000000000000000001" : ] 000000321244478.337174000000000000 ; 000000335934272.621178000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EA2E202009853 >									
	//     < RUSS_PFVIII_I_metadata_line_23_____GAZPROM_INVESTPROJECT_20211101 >									
	//        < LD0hTmuU3EhJ9PFksekGjeL9KEHoe5x2FAUQc8EhlfPi7SZ3iTD9O88x75898PBe >									
	//        <  u =="0.000000000000000001" : ] 000000335934272.621178000000000000 ; 000000348990047.695650000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002009853214843D >									
	//     < RUSS_PFVIII_I_metadata_line_24_____TROITSKAYA_GRES_JSC_20211101 >									
	//        < 59c8Nm219OgZS36si633bLh2764oME0Z6p42e4Q9vC4U268Gv7Wy4ShD26sJv9gp >									
	//        <  u =="0.000000000000000001" : ] 000000348990047.695650000000000000 ; 000000363419970.028621000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000214843D22A88ED >									
	//     < RUSS_PFVIII_I_metadata_line_25_____SURGUTSKAYA_TPP_1_20211101 >									
	//        < qKfp6Y0M91d26Sj8EUig8kK9QwMr1fy9H9IkQhofugp22N8ps57a8w0X68i790Le >									
	//        <  u =="0.000000000000000001" : ] 000000363419970.028621000000000000 ; 000000377008511.668245000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022A88ED23F44F3 >									
	//     < RUSS_PFVIII_I_metadata_line_26_____NOVOCHERKASSKAYA_TPP_20211101 >									
	//        < 8QbG7TAJ9nGlzUxYG29CkIrh6eM9x6R16K25Owb062NewO7IDYRpCs9L7qm5aMiH >									
	//        <  u =="0.000000000000000001" : ] 000000377008511.668245000000000000 ; 000000394048460.139705000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023F44F3259452E >									
	//     < RUSS_PFVIII_I_metadata_line_27_____KIRISHSKAYA_GRES_OGK_6_20211101 >									
	//        < ziJvejr305NOu5p1at16YZleeQhx1NW09NYyVl9m3HY538Cfe00p6h372Lx8xAP9 >									
	//        <  u =="0.000000000000000001" : ] 000000394048460.139705000000000000 ; 000000409098460.271646000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000259452E2703C16 >									
	//     < RUSS_PFVIII_I_metadata_line_28_____KRASNOYARSKAYA_GRES_2_20211101 >									
	//        < 6LJ4CtXr7lAEVCtXz2b08A75bPPsPTS5v4GTU44qjQ54WRYtlti8kXqyhTNyfjEf >									
	//        <  u =="0.000000000000000001" : ] 000000409098460.271646000000000000 ; 000000425424926.590873000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002703C16289259D >									
	//     < RUSS_PFVIII_I_metadata_line_29_____CHEREPOVETSKAYA_GRES_20211101 >									
	//        < A5Ft256FLQ5rAB6R5G9HaG4BI8zbFB93Bvbv9OTBPFtktB26PvuxQ2qb03jyn1YF >									
	//        <  u =="0.000000000000000001" : ] 000000425424926.590873000000000000 ; 000000439955190.015791000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000289259D29F517F >									
	//     < RUSS_PFVIII_I_metadata_line_30_____STAVROPOLSKAYA_GRES_20211101 >									
	//        < 7gZ1P7dNR7JO2G8S0014hQNW6Yql20WNs2cp558p8GA593cZs6l8V3AZrGUFFVqS >									
	//        <  u =="0.000000000000000001" : ] 000000439955190.015791000000000000 ; 000000453077164.514723000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029F517F2B35744 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFVIII_I_metadata_line_31_____OGK_2_ORG_20211101 >									
	//        < 56h0z1k8385R1hHPdpGJ2de09G0afzIKeD5vN13p9JCxxq121Z4x1NkX1b6t8PBp >									
	//        <  u =="0.000000000000000001" : ] 000000453077164.514723000000000000 ; 000000466110288.041011000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B357442C73A55 >									
	//     < RUSS_PFVIII_I_metadata_line_32_____OGK_2_PSKOV_GRES_20211101 >									
	//        < 6rRc5s1GGkPXqmNhv69cwIThURHHAJF4F3IuxhaOg0F2tbm944u0wV4Qho0Mo4HN >									
	//        <  u =="0.000000000000000001" : ] 000000466110288.041011000000000000 ; 000000482610755.518448000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C73A552E067D4 >									
	//     < RUSS_PFVIII_I_metadata_line_33_____OGK_2_SEROV_GRES_20211101 >									
	//        < 2qiyz4IjMlO6rTJS8bVqwpB11Gj1yM0MFG1648O4aNuzKhzW3XQJ9kAFJ1cH2gh8 >									
	//        <  u =="0.000000000000000001" : ] 000000482610755.518448000000000000 ; 000000495876795.698782000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E067D42F4A5E0 >									
	//     < RUSS_PFVIII_I_metadata_line_34_____OGK_2_STAVROPOL_GRES_20211101 >									
	//        < In38IzJuo056cEH2Q58kCS92a5pj638xT7KQbS7fRip8M8NBE3oAxH2v7GWraHad >									
	//        <  u =="0.000000000000000001" : ] 000000495876795.698782000000000000 ; 000000511379690.148449000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F4A5E030C4DB1 >									
	//     < RUSS_PFVIII_I_metadata_line_35_____OGK_2_SURGUT_GRES_20211101 >									
	//        < p02a4K8WM84T7boKsxaOM8zoCyo4IK5e2Zk6rZOc7HM6GTjED8m13Y7206xK9Jv3 >									
	//        <  u =="0.000000000000000001" : ] 000000511379690.148449000000000000 ; 000000524658654.932574000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030C4DB132090C9 >									
	//     < RUSS_PFVIII_I_metadata_line_36_____OGK_2_TROITSK_GRES_20211101 >									
	//        < BwQB1iyb347jkQK1Vf3N1miZCyHYrhB4vJ6k3EMw8alRrw2XNkjp8lQoi0bin5Rs >									
	//        <  u =="0.000000000000000001" : ] 000000524658654.932574000000000000 ; 000000538188031.516506000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032090C933535B3 >									
	//     < RUSS_PFVIII_I_metadata_line_37_____OGK_2_NOVOCHERKASSK_GRES_20211101 >									
	//        < MXBVnUB5nQpd8Q2r91Q842Kot5l90X88l2P4OgeCC1axZDPods206RzV08lEKYEl >									
	//        <  u =="0.000000000000000001" : ] 000000538188031.516506000000000000 ; 000000552576311.822452000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033535B334B2A1F >									
	//     < RUSS_PFVIII_I_metadata_line_38_____OGK_2_KIRISHI_GRES_20211101 >									
	//        < qN7W7K90ZnQ1UKUP1UvL636Lr7sWkE6wx43sFb2q4IWLWBnH2Br4zt4pmFd4DKHP >									
	//        <  u =="0.000000000000000001" : ] 000000552576311.822452000000000000 ; 000000568166052.437758000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034B2A1F362F3DD >									
	//     < RUSS_PFVIII_I_metadata_line_39_____OGK_2_RYAZAN_GRES_20211101 >									
	//        < 44844I310b4a0Km8FHk2n7L7Y89pLmBsE5cLGM0pE770AUA7V67j6dGbqJv9Oazy >									
	//        <  u =="0.000000000000000001" : ] 000000568166052.437758000000000000 ; 000000584058091.009368000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000362F3DD37B33B1 >									
	//     < RUSS_PFVIII_I_metadata_line_40_____OGK_2_KRASNOYARSK_GRES_20211101 >									
	//        < b5Q4Dj1C1A2A9wNVecmwf71st6S549pOWKFBY5xdx85I6Uc7f3a2j8fdx5Lk0771 >									
	//        <  u =="0.000000000000000001" : ] 000000584058091.009368000000000000 ; 000000598947743.475382000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037B33B1391EBF6 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}