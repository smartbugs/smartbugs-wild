pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXII_III_883		"	;
		string	public		symbol =	"	RUSS_PFXII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1050358181537800000000000000					;	
										
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
	//     < RUSS_PFXII_III_metadata_line_1_____TMK_20251101 >									
	//        < PfUzPNuV4hwpahID5UmVEVezg12mXNwq570pNSAP9v50pPOQgwrJf3h3rjQd4vxl >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000031350178.180726800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000002FD62A >									
	//     < RUSS_PFXII_III_metadata_line_2_____TMK_ORG_20251101 >									
	//        < D9pUcLAT8xLn9skTKY3Pg06q4q3JGlFV3e8f5FJ50cch04Oj6USEr7BRz00668d1 >									
	//        <  u =="0.000000000000000001" : ] 000000031350178.180726800000000000 ; 000000062635373.503798800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002FD62A5F92F1 >									
	//     < RUSS_PFXII_III_metadata_line_3_____TMK_STEEL_LIMITED_20251101 >									
	//        < 7CA36DFreVPX08eZ1jZbPy9uNMyz795khlna92dn37cy5Mm7rN4w3r4AsS2z84kj >									
	//        <  u =="0.000000000000000001" : ] 000000062635373.503798800000000000 ; 000000094392223.562390800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005F92F19007F6 >									
	//     < RUSS_PFXII_III_metadata_line_4_____IPSCO_TUBULARS_INC_20251101 >									
	//        < krc3vdZwO8uoHpFK1z6u1sIULR3U616d2BBxzY3p9q4Z94cJv43RjKX09aVydBqO >									
	//        <  u =="0.000000000000000001" : ] 000000094392223.562390800000000000 ; 000000116647284.673563000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009007F6B1FD58 >									
	//     < RUSS_PFXII_III_metadata_line_5_____VOLZHSKY_PIPE_PLANT_20251101 >									
	//        < HW8JK6tu9zi317fuiQNaOcwV39z2F76xSf5YC8h434d58a123sY515T0idZGteZ5 >									
	//        <  u =="0.000000000000000001" : ] 000000116647284.673563000000000000 ; 000000143835851.154376000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B1FD58DB79E1 >									
	//     < RUSS_PFXII_III_metadata_line_6_____SEVERSKY_PIPE_PLANT_20251101 >									
	//        < 2DqAr195N26C67O4h1aVC50nXt404geryH9E7J60g7Sx54vZs1nZL4gMItD53K74 >									
	//        <  u =="0.000000000000000001" : ] 000000143835851.154376000000000000 ; 000000165384928.370264000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DB79E1FC5B7D >									
	//     < RUSS_PFXII_III_metadata_line_7_____RESITA_WORKS_20251101 >									
	//        < 6q61cplu8X1TIn67iPCzHtQL2ix5rt8kRO7E00ZHX7K09Hd3VwNakIwxeuCbgQwv >									
	//        <  u =="0.000000000000000001" : ] 000000165384928.370264000000000000 ; 000000192263201.136307000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FC5B7D1255ED0 >									
	//     < RUSS_PFXII_III_metadata_line_8_____GULF_INTERNATIONAL_PIPE_INDUSTRY_20251101 >									
	//        < WdLYy3y9F50HZ5sW3D1h0DG2o3I679384x5Fzj2MGI7jdAimkANf2C1y0ty4Tzt4 >									
	//        <  u =="0.000000000000000001" : ] 000000192263201.136307000000000000 ; 000000215053411.783890000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001255ED0148253D >									
	//     < RUSS_PFXII_III_metadata_line_9_____TMK_PREMIUM_SERVICE_20251101 >									
	//        < uwX7lTk7kH5E29ESMMGvU4ClT798hJmTj35y9TB5nJo2x8235ukUpEH3M05SY3J1 >									
	//        <  u =="0.000000000000000001" : ] 000000215053411.783890000000000000 ; 000000236865658.930871000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000148253D1696DA6 >									
	//     < RUSS_PFXII_III_metadata_line_10_____ORSKY_MACHINE_BUILDING_PLANT_20251101 >									
	//        < 79jI0qJQVLpkDS6U9ORZ0z9e13gLJj1s3XWrx0AWAL74OS1Kq3M2tdyOTL0rqr6H >									
	//        <  u =="0.000000000000000001" : ] 000000236865658.930871000000000000 ; 000000261109869.637616000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001696DA618E6C0B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXII_III_metadata_line_11_____TMK_CAPITAL_SA_20251101 >									
	//        < 7o42KlrgrR0iAokM5Ab9EXaD8610Jzvc95308lDC0RK7Sx7rJy5o538Pv5tJD2eJ >									
	//        <  u =="0.000000000000000001" : ] 000000261109869.637616000000000000 ; 000000283752046.116643000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018E6C0B1B0F8A5 >									
	//     < RUSS_PFXII_III_metadata_line_12_____TMK_NSG_LLC_20251101 >									
	//        < 3n7x9e30x5NjyHIg7SI5soIzho00Rs2T9Z229YVyRLDGaHaGUUwRwBBSuomr54M9 >									
	//        <  u =="0.000000000000000001" : ] 000000283752046.116643000000000000 ; 000000312736386.543209000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B0F8A51DD32A7 >									
	//     < RUSS_PFXII_III_metadata_line_13_____TMK_GLOBAL_AG_20251101 >									
	//        < 5S8llOvsQ8oll1hEgk5m96nJmC6eLG9325emZ6JS2Sd08r2Nsi0Esv5It2N916H1 >									
	//        <  u =="0.000000000000000001" : ] 000000312736386.543209000000000000 ; 000000342195453.508539000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DD32A720A2619 >									
	//     < RUSS_PFXII_III_metadata_line_14_____TMK_EUROPE_GMBH_20251101 >									
	//        < Wow2p0ULn2Y5g59A2Ld7Lun3fkFr9hw4Z54aC1CCcsU4o25OhIUL1VC8AgrJeWtB >									
	//        <  u =="0.000000000000000001" : ] 000000342195453.508539000000000000 ; 000000375245696.730095000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020A261923C945A >									
	//     < RUSS_PFXII_III_metadata_line_15_____TMK_MIDDLE_EAST_FZCO_20251101 >									
	//        < Tyl1mvQg0kdf022Cd0wcKA2H71bjLRE4NBv4i5DQU9HDQZ3xFuoY2mcD6T8vilrd >									
	//        <  u =="0.000000000000000001" : ] 000000375245696.730095000000000000 ; 000000399871878.711094000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023C945A26227F4 >									
	//     < RUSS_PFXII_III_metadata_line_16_____TMK_EUROSINARA_SRL_20251101 >									
	//        < 16Qnc5OOn3TAVWV6i1eDuU76fpSK0JEGw7Vi587oye2FUSCUk19dGmKG41zP51s6 >									
	//        <  u =="0.000000000000000001" : ] 000000399871878.711094000000000000 ; 000000425295742.436697000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026227F4288F326 >									
	//     < RUSS_PFXII_III_metadata_line_17_____TMK_EASTERN_EUROPE_SRL_20251101 >									
	//        < QILAs85b19H08Br9sP61bmZtl7YI7SIrv74cHc1qEDM68PjCd5gFw72Kq2Eq6XUt >									
	//        <  u =="0.000000000000000001" : ] 000000425295742.436697000000000000 ; 000000444482808.061691000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000288F3262A63A19 >									
	//     < RUSS_PFXII_III_metadata_line_18_____TMK_REAL_ESTATE_SRL_20251101 >									
	//        < 06K4622Xt7UhDwqIg96HDPI82UtW5B09a6KVv5Y2AK10K9F2yX1t1OoO2699V20x >									
	//        <  u =="0.000000000000000001" : ] 000000444482808.061691000000000000 ; 000000480268293.900257000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A63A192DCD4CD >									
	//     < RUSS_PFXII_III_metadata_line_19_____POKROVKA_40_20251101 >									
	//        < iOR4fyx59KKyF5F7d7IQI8wwcFA6h38KQfGZBpU6XpzvI4EmUjZ3pJ4c7Q9lG0Ly >									
	//        <  u =="0.000000000000000001" : ] 000000480268293.900257000000000000 ; 000000502050394.815693000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DCD4CD2FE116F >									
	//     < RUSS_PFXII_III_metadata_line_20_____THREADING_MECHANICAL_KEY_PREMIUM_20251101 >									
	//        < qwbt6zd554BQz0DNPkEs91tunDD325830so38eYVR6Nza62k36Pe5kfta0hJ7WMu >									
	//        <  u =="0.000000000000000001" : ] 000000502050394.815693000000000000 ; 000000520805937.987399000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FE116F31AAFD2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXII_III_metadata_line_21_____TMK_NORTH_AMERICA_INC_20251101 >									
	//        < EUL7m0OT7YJEWEf9Bx8tK0Cg2xP5kgEK7Ef3197OJ30ul0Fq7j5fH7kLf4n4MP7S >									
	//        <  u =="0.000000000000000001" : ] 000000520805937.987399000000000000 ; 000000553792834.397345000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031AAFD234D0553 >									
	//     < RUSS_PFXII_III_metadata_line_22_____TMK_KAZAKHSTAN_20251101 >									
	//        < fdbTA0z4EznIBOe374cKy60k40630s35echKNLgokrKks7h8ghD10n1L3iGk6pCT >									
	//        <  u =="0.000000000000000001" : ] 000000553792834.397345000000000000 ; 000000580020758.523924000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034D05533750A9C >									
	//     < RUSS_PFXII_III_metadata_line_23_____KAZTRUBPROM_20251101 >									
	//        < PHYaZ33i8YkT4wKqI19B7G2HW60dflkgL4nn4OF3zp0OXL9Z96FJi1oux55yfKb8 >									
	//        <  u =="0.000000000000000001" : ] 000000580020758.523924000000000000 ; 000000613011109.263856000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003750A9C3A76177 >									
	//     < RUSS_PFXII_III_metadata_line_24_____PIPE_METALLURGIC_CO_COMPLETIONS_20251101 >									
	//        < Z0bgMKZ8429s7C9dalYX53Tj0FAk09UhNw6iJkm4gUhcw35rTfd5yBGSK76Bka1R >									
	//        <  u =="0.000000000000000001" : ] 000000613011109.263856000000000000 ; 000000644486003.776003000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A761773D76858 >									
	//     < RUSS_PFXII_III_metadata_line_25_____ZAO_TRADE_HOUSE_TMK_20251101 >									
	//        < ixvV1zTgz0RcVEUc9sCM9F3n267vJqYfj8zKKp8Ar7Qw44sW12K9Eit3m9mh7Qxh >									
	//        <  u =="0.000000000000000001" : ] 000000644486003.776003000000000000 ; 000000667505700.070462000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D768583FA886A >									
	//     < RUSS_PFXII_III_metadata_line_26_____TMK_ZAO_PIPE_REPAIR_20251101 >									
	//        < 6CyMBxHcR9vPI0e06LoU6n63v0SmWwN882588pVT1yI93zNlee14OL6meXOl6QV1 >									
	//        <  u =="0.000000000000000001" : ] 000000667505700.070462000000000000 ; 000000686722227.412127000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003FA886A417DADF >									
	//     < RUSS_PFXII_III_metadata_line_27_____SINARA_PIPE_WORKS_TRADING_HOUSE_20251101 >									
	//        < q1oe55UeV0u8IdT0ONiZN9snExzKDhy7SvDvp9o8y6JGu7MvKRj99341HF6kp3DY >									
	//        <  u =="0.000000000000000001" : ] 000000686722227.412127000000000000 ; 000000716071326.428940000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000417DADF444A35D >									
	//     < RUSS_PFXII_III_metadata_line_28_____SKLADSKOY_KOMPLEKS_20251101 >									
	//        < 8ok35mL1Us9kNlFou9a4mW3hhTKOl95P0S4fBy2Z9u1yWO7GASj5QU84lrkdoV0O >									
	//        <  u =="0.000000000000000001" : ] 000000716071326.428940000000000000 ; 000000739672473.991073000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000444A35D468A68F >									
	//     < RUSS_PFXII_III_metadata_line_29_____RUS_RESEARCH_INSTITUTE_TUBE_PIPE_IND_20251101 >									
	//        < ldqZpVqYezym02594o7br4Ghj48s1jcKCW782PzZiy7kXcOI28V4f58YJgwsuxIk >									
	//        <  u =="0.000000000000000001" : ] 000000739672473.991073000000000000 ; 000000758777413.625796000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000468A68F485CD6D >									
	//     < RUSS_PFXII_III_metadata_line_30_____TAGANROG_METALLURGICAL_PLANT_20251101 >									
	//        < yVaUwH93jPH9U6Hlwx81BmyzZ0O8THGBw11SKYHe3OW34lt707JlK1xgPe7403Ec >									
	//        <  u =="0.000000000000000001" : ] 000000758777413.625796000000000000 ; 000000792105515.713131000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000485CD6D4B8A838 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXII_III_metadata_line_31_____TAGANROG_METALLURGICAL_WORKS_20251101 >									
	//        < 52l8NRH84Pzvam2qLqG2sn0GLiS6131U5m7Pq36DjxsP3Dl8Sx7kW4cX0RJ857xD >									
	//        <  u =="0.000000000000000001" : ] 000000792105515.713131000000000000 ; 000000812746146.106185000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B8A8384D826F7 >									
	//     < RUSS_PFXII_III_metadata_line_32_____IPSCO_CANADA_LIMITED_20251101 >									
	//        < PJ3uL6dEIRz7jx9yVtPD7S1ay78IuVkpf6dBD9jTHEt3D7U2s0rn1cgvXg312MnN >									
	//        <  u =="0.000000000000000001" : ] 000000812746146.106185000000000000 ; 000000840780408.554657000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004D826F7502EDD9 >									
	//     < RUSS_PFXII_III_metadata_line_33_____SINARA_NORTH_AMERICA_INC_20251101 >									
	//        < bP7k7k2JbTzjy656555lY7ygN23cbaD3S1pZ22So66X1k5v0Fkh92pm8Z0i6Qdgb >									
	//        <  u =="0.000000000000000001" : ] 000000840780408.554657000000000000 ; 000000864886232.228838000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000502EDD9527B62F >									
	//     < RUSS_PFXII_III_metadata_line_34_____PIPE_METALLURGICAL_CO_TRADING_HOUSE_20251101 >									
	//        < 55ek5Vh7ZT451KO9aGheQsd16iELlsOzGau3dsCF5MVropWmU9hB8BblHv62XC89 >									
	//        <  u =="0.000000000000000001" : ] 000000864886232.228838000000000000 ; 000000897518932.995855000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000527B62F5598155 >									
	//     < RUSS_PFXII_III_metadata_line_35_____TAGANROG_METALLURGICAL_WORKS_20251101 >									
	//        < htm83lr690U4oiP263ML33gVzI4RVF8k4MQRa4b26G815cC3G9g5WjXfZiTx9VJu >									
	//        <  u =="0.000000000000000001" : ] 000000897518932.995855000000000000 ; 000000925917309.984853000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005598155584D673 >									
	//     < RUSS_PFXII_III_metadata_line_36_____SINARSKY_PIPE_PLANT_20251101 >									
	//        < pUkFm224j6IFaZAj7YMd712290pf8k21fs859u3b4jlmVQDRiQ8lJ5STar7Ohgtj >									
	//        <  u =="0.000000000000000001" : ] 000000925917309.984853000000000000 ; 000000946399564.834530000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000584D6735A41754 >									
	//     < RUSS_PFXII_III_metadata_line_37_____TMK_BONDS_SA_20251101 >									
	//        < fV74456HVh1wsRvN4O6aO3766OO8wuxS2J4q50O86NYH929lG5y1352Sg8vfF7F8 >									
	//        <  u =="0.000000000000000001" : ] 000000946399564.834530000000000000 ; 000000970802290.900662000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005A417545C953A5 >									
	//     < RUSS_PFXII_III_metadata_line_38_____OOO_CENTRAL_PIPE_YARD_20251101 >									
	//        < nSdH9pAL9moEseIYp2zrhNObe9Fm5GCLEe6GA0Fa66364nWod23damUSiS368M8L >									
	//        <  u =="0.000000000000000001" : ] 000000970802290.900662000000000000 ; 000000997503441.903971000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005C953A55F211C8 >									
	//     < RUSS_PFXII_III_metadata_line_39_____SINARA_PIPE_WORKS_20251101 >									
	//        < K0WkC9cAmg4lF6jH3mAFzyXA387NkJfznEyDdG252y346CUhp4oy77fbVv60OUv2 >									
	//        <  u =="0.000000000000000001" : ] 000000997503441.903971000000000000 ; 000001021251947.561820000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005F211C86164E8B >									
	//     < RUSS_PFXII_III_metadata_line_40_____ZAO_TMK_TRADE_HOUSE_20251101 >									
	//        < 9pS4W1bfEIkk7qsOnpt6F2sb9s91yWh9QpzX24K3AEo55QUl039o6Jb4nk0661fg >									
	//        <  u =="0.000000000000000001" : ] 000001021251947.561820000000000000 ; 000001050358181.537800000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006164E8B642B82A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}