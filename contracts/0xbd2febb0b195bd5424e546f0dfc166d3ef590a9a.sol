pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFIV_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFIV_III_883		"	;
		string	public		symbol =	"	RUSS_PFIV_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1033526008926500000000000000					;	
										
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
	//     < RUSS_PFIV_III_metadata_line_1_____NOVOLIPETSK_20251101 >									
	//        < 8CeE78RDnYuIxB0WFQ3j99CoTxtgTw343fReEl9NMe6qE266X7OqJr2Me1Kpey0q >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000024540476.260893400000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000257220 >									
	//     < RUSS_PFIV_III_metadata_line_2_____FLETCHER_GROUP_HOLDINGS_LIMITED_20251101 >									
	//        < fQxNTT38wLIqO0A1MYZgOUcy79x4An3FHxUkzILF93vMBj9phaflq5qfY7X1lwg1 >									
	//        <  u =="0.000000000000000001" : ] 000000024540476.260893400000000000 ; 000000044848157.598577700000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000257220446ED0 >									
	//     < RUSS_PFIV_III_metadata_line_3_____UNIVERSAL_CARGO_LOGISTICS_HOLDINGS_BV_20251101 >									
	//        < 193oWU51kXgj0U01ZFcHOWkNyPziaoXKf35m9T6H3sg2A8OX8nP41vyJC429mxYr >									
	//        <  u =="0.000000000000000001" : ] 000000044848157.598577700000000000 ; 000000063663366.989519900000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000446ED0612481 >									
	//     < RUSS_PFIV_III_metadata_line_4_____STOILENSKY_GOK_20251101 >									
	//        < 1s0r73c5ZebAf8ikGESkMn81q4yCswt2RAN5mDkhRSEW74RCfdFdPFj7Cioifb6t >									
	//        <  u =="0.000000000000000001" : ] 000000063663366.989519900000000000 ; 000000089715390.295300700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000061248188E513 >									
	//     < RUSS_PFIV_III_metadata_line_5_____ALTAI_KOKS_20251101 >									
	//        < 07qUQLVtg42dO28h85UxGZ5CqzM141EH13a6v9nD4nB30PMHzFD7K6MSZNAPeK6G >									
	//        <  u =="0.000000000000000001" : ] 000000089715390.295300700000000000 ; 000000108058263.476625000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000088E513A4E242 >									
	//     < RUSS_PFIV_III_metadata_line_6_____VIZ_STAL_20251101 >									
	//        < 0RJ6LMT2Bb8R0O00K0wZb2I7CLm9z1QCY167H2Qh469emWw9JV386Molzz02Rzg0 >									
	//        <  u =="0.000000000000000001" : ] 000000108058263.476625000000000000 ; 000000143286194.537546000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A4E242DAA32B >									
	//     < RUSS_PFIV_III_metadata_line_7_____NLMK_PLATE_SALES_SA_20251101 >									
	//        < 7vF9pXeC4cH8u8XK1BSWt4aoRyqQ0blv15TNC1XothZ0R01jZzbmNk4R90RwrKxO >									
	//        <  u =="0.000000000000000001" : ] 000000143286194.537546000000000000 ; 000000167736993.792812000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DAA32BFFF243 >									
	//     < RUSS_PFIV_III_metadata_line_8_____NLMK_INDIANA_LLC_20251101 >									
	//        < k6AxSD8ac8nqd6zV6R8SHg4H0jp65za3V8PnmCeoC1TWcD8W0Lrb6c89TY6YZCsK >									
	//        <  u =="0.000000000000000001" : ] 000000167736993.792812000000000000 ; 000000197998797.237869000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FFF24312E1F48 >									
	//     < RUSS_PFIV_III_metadata_line_9_____STEEL_FUNDING_DAC_20251101 >									
	//        < 48nUu66B6Y04gtjFBDtKzHsajRz3Yc7LMrCV0YJvx0eHnq9KaDORgY1P1ULk8ga1 >									
	//        <  u =="0.000000000000000001" : ] 000000197998797.237869000000000000 ; 000000222170928.179213000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012E1F481530185 >									
	//     < RUSS_PFIV_III_metadata_line_10_____ZAO_URALS_PRECISION_ALLOYS_PLANT_20251101 >									
	//        < jNB4HydClxl0ug3XdKcuR9N7H26p43umQUe3BZfCl8CuuGW68265IyR8juSHv6cm >									
	//        <  u =="0.000000000000000001" : ] 000000222170928.179213000000000000 ; 000000243036375.400457000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001530185172D816 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIV_III_metadata_line_11_____TOP_GUN_INVESTMENT_CORP_20251101 >									
	//        < Z6S7Vr55e7w0ETAQ28FWpuQlQ20fJ1JuTz8w1KkVzLF94ZAET6wL4OMh6g0Dz0P7 >									
	//        <  u =="0.000000000000000001" : ] 000000243036375.400457000000000000 ; 000000274694342.576110000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000172D8161A3267A >									
	//     < RUSS_PFIV_III_metadata_line_12_____NLMK_ARKTIKGAZ_20251101 >									
	//        < Re5QT2uN3iBn62ESEqqQ9OTtgBSRxTh0G87dwKy9Ng5v13U6wk637LHH1agjbFez >									
	//        <  u =="0.000000000000000001" : ] 000000274694342.576110000000000000 ; 000000294796954.008178000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A3267A1C1D30F >									
	//     < RUSS_PFIV_III_metadata_line_13_____TUSCANY_INTERTRADE_20251101 >									
	//        < ZS4R3f655hCE65H1935vc41u2MSu35iID7aM54lNd170ERj6PW4SdEmRC35MHSG0 >									
	//        <  u =="0.000000000000000001" : ] 000000294796954.008178000000000000 ; 000000324930785.551723000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C1D30F1EFCE17 >									
	//     < RUSS_PFIV_III_metadata_line_14_____MOORFIELD_COMMODITIES_20251101 >									
	//        < M6Hk3uG85cLXaSQ2Hvm056oRL001922G3mnZI6ko1lkq14oBfN8mc92Z1FGMG7s7 >									
	//        <  u =="0.000000000000000001" : ] 000000324930785.551723000000000000 ; 000000360476209.785900000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EFCE172260B05 >									
	//     < RUSS_PFIV_III_metadata_line_15_____NLMK_COATING_20251101 >									
	//        < 3SnwOM4W970pjbUP9h2R7bb8j8aso40EBhcgIH56Rd1732y46DFs7K5yhHI4w843 >									
	//        <  u =="0.000000000000000001" : ] 000000360476209.785900000000000000 ; 000000383488202.844901000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002260B052492814 >									
	//     < RUSS_PFIV_III_metadata_line_16_____NLMK_MAXI_GROUP_20251101 >									
	//        < 6aWi6L3E3kesGe16x1arZ5CQ50N136otl9418fEK7e81R6BUmKQ1i1foubHNS8X2 >									
	//        <  u =="0.000000000000000001" : ] 000000383488202.844901000000000000 ; 000000416193960.160315000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000249281427B0FC4 >									
	//     < RUSS_PFIV_III_metadata_line_17_____NLMK_SERVICES_LLC_20251101 >									
	//        < dBo8H42i796W481Nx93RKyW7f6uqNn1u7G544u0A80e1LEdddLoo1ZPi5SV8TZb4 >									
	//        <  u =="0.000000000000000001" : ] 000000416193960.160315000000000000 ; 000000434889010.822678000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027B0FC42979685 >									
	//     < RUSS_PFIV_III_metadata_line_18_____STEEL_INVEST_FINANCE_20251101 >									
	//        < 3V41ZCIE2bp09xZ8pa0XU17Nn455aWRfc1nKoBiZ98tNd12TR7DnHo347WNyX1JB >									
	//        <  u =="0.000000000000000001" : ] 000000434889010.822678000000000000 ; 000000456481358.017160000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029796852B88908 >									
	//     < RUSS_PFIV_III_metadata_line_19_____CLABECQ_20251101 >									
	//        < 105mB3cBIyu4g1V9CTONBBeDo428tnOSYVZxS67Wp18pWv0efan9V84ys20Lwx45 >									
	//        <  u =="0.000000000000000001" : ] 000000456481358.017160000000000000 ; 000000491782577.618663000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B889082EE6692 >									
	//     < RUSS_PFIV_III_metadata_line_20_____HOLIDAY_HOTEL_NLMK_20251101 >									
	//        < p7Fls3f62v750znN74rg1S5f8jZ0o1GWTWwhD0GwG234mI39NsEzr6Tj4cBK77gQ >									
	//        <  u =="0.000000000000000001" : ] 000000491782577.618663000000000000 ; 000000524005593.687532000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EE669231F91AF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIV_III_metadata_line_21_____STEELCO_MED_TRADING_20251101 >									
	//        < 194uBx5IsfO2BoP0c4xF2fL3t7xP7oK90j5S5G3qBZwLJno438ivGX5sVRnqSX4h >									
	//        <  u =="0.000000000000000001" : ] 000000524005593.687532000000000000 ; 000000547148995.015397000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031F91AF342E214 >									
	//     < RUSS_PFIV_III_metadata_line_22_____LIPETSKY_GIPROMEZ_20251101 >									
	//        < pyNx18AaBnr4PC7V27rVfw7jYjv907B63U11ycH3M1C97N1686644lqY9dkn7g8y >									
	//        <  u =="0.000000000000000001" : ] 000000547148995.015397000000000000 ; 000000568479806.802570000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000342E2143636E6D >									
	//     < RUSS_PFIV_III_metadata_line_23_____NORTH_OIL_GAS_CO_20251101 >									
	//        < R2jjObMX6v969CHQErNB4f0PX3JEarbg9r0UVJxeDEPzZd1hYBtEOzY5iUdH2XP9 >									
	//        <  u =="0.000000000000000001" : ] 000000568479806.802570000000000000 ; 000000586975233.825807000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003636E6D37FA733 >									
	//     < RUSS_PFIV_III_metadata_line_24_____STOYLENSKY_GOK_20251101 >									
	//        < novxzC54N9i3M7r1j3O08eD9k6sxYtp4hC1m9C9w8Ohcejn105Xo00Z5C51TZB3A >									
	//        <  u =="0.000000000000000001" : ] 000000586975233.825807000000000000 ; 000000618693911.811821000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037FA7333B00D4F >									
	//     < RUSS_PFIV_III_metadata_line_25_____NLMK_RECORDING_CENTER_OOO_20251101 >									
	//        < r7JesgOmzn4SL6Nw77M2E83Uf0KbM4RC2wt4V9635oRLF9MS4hx115R52834QYG3 >									
	//        <  u =="0.000000000000000001" : ] 000000618693911.811821000000000000 ; 000000642973364.496419000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B00D4F3D51978 >									
	//     < RUSS_PFIV_III_metadata_line_26_____URAL_ARCHI_CONSTRUCTION_RD_INSTITUTE_20251101 >									
	//        < 0qf1c4Mwko17T952QMqQSK32o24LCDINgXHy9hmX3gfS3KE0r5ytfhJ4Xr048nnm >									
	//        <  u =="0.000000000000000001" : ] 000000642973364.496419000000000000 ; 000000664812217.867446000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D519783F66C46 >									
	//     < RUSS_PFIV_III_metadata_line_27_____PO_URALMETALLURGSTROY_ZAO_20251101 >									
	//        < TaPraxnI26ar4T803Wh7xl1u0Dpnhx19dYppraJYe257JO1s6xi91rOie4cEfm6i >									
	//        <  u =="0.000000000000000001" : ] 000000664812217.867446000000000000 ; 000000690177161.202707000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F66C4641D2074 >									
	//     < RUSS_PFIV_III_metadata_line_28_____NLMK_LONG_PRODUCTS_20251101 >									
	//        < Ph99LlrKctOeLE6c95Of2NhpDY3CrzC135nzIERT997S0JWNtrY68hXPgl7EgX7I >									
	//        <  u =="0.000000000000000001" : ] 000000690177161.202707000000000000 ; 000000721168278.861431000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041D207444C6A5C >									
	//     < RUSS_PFIV_III_metadata_line_29_____USSURIYSKAYA_SCRAP_METAL_20251101 >									
	//        < EsjD92HUmg975510mFBnJLp2oe7TmDjw6J1RNdKqS03FF3iERG359J6wjTBeV2EN >									
	//        <  u =="0.000000000000000001" : ] 000000721168278.861431000000000000 ; 000000749968161.547086000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044C6A5C4785C50 >									
	//     < RUSS_PFIV_III_metadata_line_30_____NOVOLIPETSKY_PRINTING_HOUSE_20251101 >									
	//        < 2icN1aZ69Z10JPuQfpD5M2q8t0iW354VzhAQuI72I6P0ddg87RST4Hs6x081P182 >									
	//        <  u =="0.000000000000000001" : ] 000000749968161.547086000000000000 ; 000000776190426.458500000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004785C504A05F63 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIV_III_metadata_line_31_____CHUPIT_LIMITED_20251101 >									
	//        < k7idfZcFqlOBdwMZ4T49Q7nMwn1jMd31IeFEXmDq83r8nvP5EMwjmrM1cfAj4afQ >									
	//        <  u =="0.000000000000000001" : ] 000000776190426.458500000000000000 ; 000000800483251.504878000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A05F634C570C5 >									
	//     < RUSS_PFIV_III_metadata_line_32_____ZHERNOVSKY_I_MINING_PROCESS_COMPLEX_20251101 >									
	//        < uGjOf1643r1Xge9wPDhTXSJ8OcBDWWfXW85AH4p24RUg8Q0EqS5BwPfHcTS031c0 >									
	//        <  u =="0.000000000000000001" : ] 000000800483251.504878000000000000 ; 000000823246104.851463000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004C570C54E82C82 >									
	//     < RUSS_PFIV_III_metadata_line_33_____KSIEMP_20251101 >									
	//        < YP16fG4u5gp58x68ewGxh8v32Hjxz2147sl46Uo2vi3YCm1exz4HAg8qgryL3J3z >									
	//        <  u =="0.000000000000000001" : ] 000000823246104.851463000000000000 ; 000000856199319.306518000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004E82C8251A74DC >									
	//     < RUSS_PFIV_III_metadata_line_34_____STROITELNY_MONTAZHNYI_TREST_20251101 >									
	//        < j70FHkESu70I1ekX85p6U4lgrPv0lH3eS92SzD4elFvTY382l1v5xr2w195SSEat >									
	//        <  u =="0.000000000000000001" : ] 000000856199319.306518000000000000 ; 000000879896092.435373000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000051A74DC53E9D69 >									
	//     < RUSS_PFIV_III_metadata_line_35_____VTORMETSNAB_20251101 >									
	//        < VvnMi3z1164MvRk3mC42iGIS95vB29o8R1toBDyKn07fqQXNm1542b88fYIgjRNr >									
	//        <  u =="0.000000000000000001" : ] 000000879896092.435373000000000000 ; 000000906703237.270110000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000053E9D6956784F4 >									
	//     < RUSS_PFIV_III_metadata_line_36_____DOLOMIT_20251101 >									
	//        < OpGW75c9FHPU8ToSu24O4a0rznI6zD1U7I8g67BMkqI8yyB4EH2W9cK3n6b0910k >									
	//        <  u =="0.000000000000000001" : ] 000000906703237.270110000000000000 ; 000000932306155.460950000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000056784F458E9618 >									
	//     < RUSS_PFIV_III_metadata_line_37_____KALUGA_ELECTRIC_STEELMAKING_PLANT_20251101 >									
	//        < 92nxm8954Ny0B3hT20Dx8LALKjan3iMhfMlsYe9VH4fc0qn376ThnMzD3Kig4v6K >									
	//        <  u =="0.000000000000000001" : ] 000000932306155.460950000000000000 ; 000000951232495.215573000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000058E96185AB7732 >									
	//     < RUSS_PFIV_III_metadata_line_38_____LIPETSKOMBANK_20251101 >									
	//        < ZcXO88iRcShjX98tEj7mozY961S287t9eH9e8rW91pN31wN8JcbF7Ut6fw2pLaS3 >									
	//        <  u =="0.000000000000000001" : ] 000000951232495.215573000000000000 ; 000000986362069.920746000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005AB77325E111AF >									
	//     < RUSS_PFIV_III_metadata_line_39_____NIZHNESERGINSKY_HARDWARE_METALL_WORKS_20251101 >									
	//        < Ri2aftym1wwC8P34PnkFc6vnWjojOys8nh10I6VMwfaH7scn0esa8P3wP8F871kC >									
	//        <  u =="0.000000000000000001" : ] 000000986362069.920746000000000000 ; 000001006895927.422190000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005E111AF60066B9 >									
	//     < RUSS_PFIV_III_metadata_line_40_____KALUGA_SCIENTIFIC_PROD_ELECTROMETALL_PLANT_20251101 >									
	//        < 9BQ4123PgeIhp57j2xe7j59c9cOPk12ZJB0xmt38Mm425IWQ5VEEzxAK60N4tjm3 >									
	//        <  u =="0.000000000000000001" : ] 000001006895927.422190000000000000 ; 000001033526008.926500000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000060066B96290919 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}