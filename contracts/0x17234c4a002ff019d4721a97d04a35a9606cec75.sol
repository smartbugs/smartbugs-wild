pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXI_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXI_III_883		"	;
		string	public		symbol =	"	RUSS_PFXXXI_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1064147230230680000000000000					;	
										
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
	//     < RUSS_PFXXXI_III_metadata_line_1_____MEGAFON_20251101 >									
	//        < mLQJo5evhTve7yNnx1C2nlBm8aP3shjbcu8pTe6FC42xXW4kWeMICmp29tOKie3o >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000024621740.134977200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000002591DE >									
	//     < RUSS_PFXXXI_III_metadata_line_2_____EUROSET_20251101 >									
	//        < 4tvZiZSYTuleQpvO5x4wAYmfSbCyYVA4C0H4WijMouuX4YhsHq9b546JU57F19Va >									
	//        <  u =="0.000000000000000001" : ] 000000024621740.134977200000000000 ; 000000054004562.896780700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002591DE526788 >									
	//     < RUSS_PFXXXI_III_metadata_line_3_____OSTELECOM_20251101 >									
	//        < hbKDW4zAdmO4onmQ16ae1cxuW300ggY1FnGxA52lO1Y5vQ44O3Ohus50V3jOICnO >									
	//        <  u =="0.000000000000000001" : ] 000000054004562.896780700000000000 ; 000000086855715.031473200000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000526788848804 >									
	//     < RUSS_PFXXXI_III_metadata_line_4_____GARS_TELECOM_20251101 >									
	//        < oE2wjTGyFJZEut89V4mh5oLMAN3BPjF7lxEYX6x811y0fMQTr24Jk1fj82ni42R3 >									
	//        <  u =="0.000000000000000001" : ] 000000086855715.031473200000000000 ; 000000118348350.425549000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000848804B495D3 >									
	//     < RUSS_PFXXXI_III_metadata_line_5_____MEGAFON_INVESTMENT_CYPRUS_LIMITED_20251101 >									
	//        < H2P4FF3t9pDv723V19NH6IOvZ9F8LHsThpqWj8q5wR6x0bXckzX2q5JDPpur900r >									
	//        <  u =="0.000000000000000001" : ] 000000118348350.425549000000000000 ; 000000147597295.658691000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B495D3E13732 >									
	//     < RUSS_PFXXXI_III_metadata_line_6_____YOTA_20251101 >									
	//        < jmWaXGDn7ijc31h8FY95s5zNi5GO17BV492ebQ4A9or30140f0rKr0mq99YhW95R >									
	//        <  u =="0.000000000000000001" : ] 000000147597295.658691000000000000 ; 000000166029047.042928000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E13732FD5719 >									
	//     < RUSS_PFXXXI_III_metadata_line_7_____YOTA_DAO_20251101 >									
	//        < 6nCG4my1u9hIhn2XJppX13rO8v9CAlUIzdij590BxtImS8t8a9uuJgmARhlK8T8g >									
	//        <  u =="0.000000000000000001" : ] 000000166029047.042928000000000000 ; 000000187997789.588179000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FD571911EDCA3 >									
	//     < RUSS_PFXXXI_III_metadata_line_8_____YOTA_DAOPI_20251101 >									
	//        < Qkvyv80r7aoA7NOFYrC056e526y6Bt2azz1MkbJ41N5749id0X92T9q2iaKFcJ2T >									
	//        <  u =="0.000000000000000001" : ] 000000187997789.588179000000000000 ; 000000220465800.806494000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011EDCA31506774 >									
	//     < RUSS_PFXXXI_III_metadata_line_9_____YOTA_DAC_20251101 >									
	//        < 7nQ423E9gX8j9265230149IG6mIlhJeu70o29kXbVMK5TpgjV6D924os2B7SUC2A >									
	//        <  u =="0.000000000000000001" : ] 000000220465800.806494000000000000 ; 000000239831260.100111000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000150677416DF416 >									
	//     < RUSS_PFXXXI_III_metadata_line_10_____YOTA_BIMI_20251101 >									
	//        < iyA8mguC4f592fztS3AHjO161SccPwhG8ZWYRM934CrH3640y77tLYtBJQZqNrA1 >									
	//        <  u =="0.000000000000000001" : ] 000000239831260.100111000000000000 ; 000000259643912.739484000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016DF41618C2F67 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXI_III_metadata_line_11_____KAVKAZ_20251101 >									
	//        < R49sb9zLm7rTh48119VaShZi8eS3XG2KmMcwu0Oq8VPeEe4eB45Hq7kuiPI1JMg9 >									
	//        <  u =="0.000000000000000001" : ] 000000259643912.739484000000000000 ; 000000284078803.542672000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018C2F671B17848 >									
	//     < RUSS_PFXXXI_III_metadata_line_12_____KAVKAZ_KZT_20251101 >									
	//        < K551xNIfVx5XmDa7W80Su96D5quJusOGHIISFpq2AhF52mLf1z8595Gk0sTv52KG >									
	//        <  u =="0.000000000000000001" : ] 000000284078803.542672000000000000 ; 000000304768665.547643000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B178481D10A43 >									
	//     < RUSS_PFXXXI_III_metadata_line_13_____KAVKAZ_CHF_20251101 >									
	//        < 32Cm9tZN98NjorPgXaQ2lRh52EhbLgnxr4CTqfkpr0UcrDjuMzmKLn7Y1VRG77WT >									
	//        <  u =="0.000000000000000001" : ] 000000304768665.547643000000000000 ; 000000335590205.344696000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D10A4320011ED >									
	//     < RUSS_PFXXXI_III_metadata_line_14_____KAVKAZ_USD_20251101 >									
	//        < z7g67zutk3WJVwwnL6Il5dFJD9o6QN5bKW720TGUA9YA0C14RyeXeP6onUU5hHvK >									
	//        <  u =="0.000000000000000001" : ] 000000335590205.344696000000000000 ; 000000355331777.128289000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020011ED21E317A >									
	//     < RUSS_PFXXXI_III_metadata_line_15_____PETERSTAR_20251101 >									
	//        < LnZ84z2VX3oA2769g7QD16t080q0J96a9xeKAS3pblnNK7R33468Za1K6IvC5oY1 >									
	//        <  u =="0.000000000000000001" : ] 000000355331777.128289000000000000 ; 000000390935923.346225000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021E317A2548558 >									
	//     < RUSS_PFXXXI_III_metadata_line_16_____MEGAFON_FINANCE_LLC_20251101 >									
	//        < 9Z9D94HfaIwZaTR8YLpTaj94Uc35KGOW6T0Phx1jG3L8VK5uNSjCWg25Aw3zhsl1 >									
	//        <  u =="0.000000000000000001" : ] 000000390935923.346225000000000000 ; 000000419613996.126049000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000254855828047B8 >									
	//     < RUSS_PFXXXI_III_metadata_line_17_____LEFBORD_INVESTMENTS_LIMITED_20251101 >									
	//        < P0Ue3LC1kKJ8Vl926O1OZ5wXtZ42dagtOf5bNZw53OWu3CEco6C8YbNbdhZ85HZj >									
	//        <  u =="0.000000000000000001" : ] 000000419613996.126049000000000000 ; 000000441082738.153009000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028047B82A109F2 >									
	//     < RUSS_PFXXXI_III_metadata_line_18_____TT_MOBILE_20251101 >									
	//        < g9BTndOalfeS0A277maU7p9KIWbri444oTD3n1gH188vE7PPqgiQ4in5279ghqFd >									
	//        <  u =="0.000000000000000001" : ] 000000441082738.153009000000000000 ; 000000475643982.485799000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A109F22D5C66E >									
	//     < RUSS_PFXXXI_III_metadata_line_19_____SMARTS_SAMARA_20251101 >									
	//        < f7Q0yRwF5hfE7ymTOd0uRgAxmd9r09IGx9h4mk68lk0D9Pbul8HT3U95045I778t >									
	//        <  u =="0.000000000000000001" : ] 000000475643982.485799000000000000 ; 000000497081417.877395000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D5C66E2F67C6E >									
	//     < RUSS_PFXXXI_III_metadata_line_20_____MEGAFON_NORTH_WEST_20251101 >									
	//        < F1b4tV6aH9tKCK3EVF11IpADXYSfqJkqR9FS7pp3M4zB25j6QW4HlhN7Ds2v04yD >									
	//        <  u =="0.000000000000000001" : ] 000000497081417.877395000000000000 ; 000000524872524.577966000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F67C6E320E454 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXI_III_metadata_line_21_____GARS_HOLDING_LIMITED_20251101 >									
	//        < j2zmDz7KP2Za476xV9XXL645q0h76q0kffN8c7Sh33Uk1cwD5091PH9W54Jg5xFt >									
	//        <  u =="0.000000000000000001" : ] 000000524872524.577966000000000000 ; 000000546785702.257845000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000320E454342542A >									
	//     < RUSS_PFXXXI_III_metadata_line_22_____SMARTS_CHEBOKSARY_20251101 >									
	//        < 7H0niee078ZtzSw7rG6p6pKQ5OVZoyC5Xly5z1qB2yFJtJHCq7zM2232wMahhiAx >									
	//        <  u =="0.000000000000000001" : ] 000000546785702.257845000000000000 ; 000000567826091.335569000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000342542A3626F11 >									
	//     < RUSS_PFXXXI_III_metadata_line_23_____MEGAFON_ORG_20251101 >									
	//        < M1J9KowYU5MWWGFkF0kif8VVuPHF724EJs0SI82BAIGak2JFC63RDdvAuGaTL115 >									
	//        <  u =="0.000000000000000001" : ] 000000567826091.335569000000000000 ; 000000597359335.158389000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003626F1138F7F7E >									
	//     < RUSS_PFXXXI_III_metadata_line_24_____NAKHODKA_TELECOM_20251101 >									
	//        < 2kYk899LQik6IwsL1l91YBOG5um8ywD2SYG65wpKr97zUj6dJWIUgy1GqR100EWn >									
	//        <  u =="0.000000000000000001" : ] 000000597359335.158389000000000000 ; 000000623777473.093808000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038F7F7E3B7CF13 >									
	//     < RUSS_PFXXXI_III_metadata_line_25_____NEOSPRINT_20251101 >									
	//        < yZT6344tJPTqk9OocSI9u0wZuVa5pvLtj89H30LzgoMe37T3dARi83b8I7zRAb4L >									
	//        <  u =="0.000000000000000001" : ] 000000623777473.093808000000000000 ; 000000648919708.188235000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B7CF133DE2C43 >									
	//     < RUSS_PFXXXI_III_metadata_line_26_____SMARTS_PENZA_20251101 >									
	//        < U8s8981pQ8au6LwDUYcrX1jLrI10D5M80OpJWV8P2vu04GH48oOV87kS0qnaTrGu >									
	//        <  u =="0.000000000000000001" : ] 000000648919708.188235000000000000 ; 000000668657107.183544000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DE2C433FC4A2F >									
	//     < RUSS_PFXXXI_III_metadata_line_27_____MEGAFON_RETAIL_20251101 >									
	//        < kv8fyuJhvlOr0X96AD67zlZkd67ER6o4sT2b244ZckAZPMp73Gmpbg4Ej6kn80mV >									
	//        <  u =="0.000000000000000001" : ] 000000668657107.183544000000000000 ; 000000696627872.593231000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003FC4A2F426F843 >									
	//     < RUSS_PFXXXI_III_metadata_line_28_____FIRST_TOWER_COMPANY_20251101 >									
	//        < 3J1TeTN9LVXG3z07EZUD105RGmSvKcQCuRxmZzKvhdTCl0KSe8JpiZzlqEs4nJ0t >									
	//        <  u =="0.000000000000000001" : ] 000000696627872.593231000000000000 ; 000000717928922.062344000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000426F84344778FC >									
	//     < RUSS_PFXXXI_III_metadata_line_29_____MEGAFON_SA_20251101 >									
	//        < 2LJpTQ3t1S974dUrGrWnsa9JwC2iQ91ml2TkkGTY0ma8HVfE050ld5rq3o41L661 >									
	//        <  u =="0.000000000000000001" : ] 000000717928922.062344000000000000 ; 000000750944356.171165000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044778FC479D9A4 >									
	//     < RUSS_PFXXXI_III_metadata_line_30_____MOBICOM_KHABAROVSK_20251101 >									
	//        < h16xJvwn182ABlM5ub1MwZhVduo007bfWJW48jeJtIi22H3362Zg1m1MfU860LO7 >									
	//        <  u =="0.000000000000000001" : ] 000000750944356.171165000000000000 ; 000000771928896.347809000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000479D9A4499DEBA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXI_III_metadata_line_31_____AQUAFON_GSM_20251101 >									
	//        < 3ZUB5S2tm4j1M6T7JN2My7LCCV3ifTM7c7o2UDCQ5gf6VYSE30BWw1H10TVQhe4e >									
	//        <  u =="0.000000000000000001" : ] 000000771928896.347809000000000000 ; 000000796450857.461330000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000499DEBA4BF499E >									
	//     < RUSS_PFXXXI_III_metadata_line_32_____DIGITAL_BUSINESS_SOLUTIONS_20251101 >									
	//        < BD1455fIYF30L5i1CYxVc0W93fM2c71Cf0IxX9q107018Y28QFe1wURzCVJ3zN21 >									
	//        <  u =="0.000000000000000001" : ] 000000796450857.461330000000000000 ; 000000828768163.393180000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004BF499E4F09990 >									
	//     < RUSS_PFXXXI_III_metadata_line_33_____KOMBELL_OOO_20251101 >									
	//        < 779cOVLV1FfSu5u8Fkqz8GEckD3t1Gf4yrNTiWahJJ05SAU891P190V8w3yKMj4P >									
	//        <  u =="0.000000000000000001" : ] 000000828768163.393180000000000000 ; 000000855951947.487877000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004F0999051A143B >									
	//     < RUSS_PFXXXI_III_metadata_line_34_____URALSKI_GSM_ZAO_20251101 >									
	//        < 899p3Pc7n1u4kpxA7rvm6z38G7sZsDj0R5hBIA49kWYE975GHTKeP8MJVZ95U58Q >									
	//        <  u =="0.000000000000000001" : ] 000000855951947.487877000000000000 ; 000000878940449.750962000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000051A143B53D281D >									
	//     < RUSS_PFXXXI_III_metadata_line_35_____INCORE_20251101 >									
	//        < m196szyPi3crjrjKyyeNasfzSwvq629X7lziUUL958okyAS69d6ONYtP75dsm9GO >									
	//        <  u =="0.000000000000000001" : ] 000000878940449.750962000000000000 ; 000000911440573.540710000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000053D281D56EBF79 >									
	//     < RUSS_PFXXXI_III_metadata_line_36_____MEGALABS_20251101 >									
	//        < 3m5485m702OW5fre1w9S36h99b6Y1QVBeVwQEc9v3S1pr5J4y5PuKGne5lX0Ja3o >									
	//        <  u =="0.000000000000000001" : ] 000000911440573.540710000000000000 ; 000000946002371.111112000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000056EBF795A37C2D >									
	//     < RUSS_PFXXXI_III_metadata_line_37_____AQUAPHONE_GSM_20251101 >									
	//        < 3BL5OA288Rxe69RTn3aGl5ihrJwgaGz8U2Ex8ue9xDG6PMMqK7T7tsCuVo627pSP >									
	//        <  u =="0.000000000000000001" : ] 000000946002371.111112000000000000 ; 000000976860747.499742000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005A37C2D5D2923B >									
	//     < RUSS_PFXXXI_III_metadata_line_38_____TC_COMET_20251101 >									
	//        < L0TtNijUgu85rP2d018nrG8wU245TwVrOh3FzURP2u4D9RsW77lJ2JtC4CQb3vE8 >									
	//        <  u =="0.000000000000000001" : ] 000000976860747.499742000000000000 ; 000001002617616.090640000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005D2923B5F9DF82 >									
	//     < RUSS_PFXXXI_III_metadata_line_39_____DEBTON_INVESTMENTS_LIMITED_20251101 >									
	//        < DPTO6t8vAW9Tt73LB2P79sFNRS6hEF5z6XqkURs5cS1f0k1D9aSiyoBLh66Y3BL1 >									
	//        <  u =="0.000000000000000001" : ] 000001002617616.090640000000000000 ; 000001029622448.382140000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005F9DF826231445 >									
	//     < RUSS_PFXXXI_III_metadata_line_40_____NETBYNET_HOLDING_20251101 >									
	//        < a16fpXn0603u7pwP18qhF26qbwJ1M6Yc8b8x6zx2KMPzYFJuJGJEKb7mxDLH22ll >									
	//        <  u =="0.000000000000000001" : ] 000001029622448.382140000000000000 ; 000001064147230.230680000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006231445657C283 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}