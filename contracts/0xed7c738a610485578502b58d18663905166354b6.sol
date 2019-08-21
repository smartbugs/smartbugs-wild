pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFIII_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFIII_I_883		"	;
		string	public		symbol =	"	RUSS_PFIII_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		575487268745056000000000000					;	
										
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
	//     < RUSS_PFIII_I_metadata_line_1_____MOSENERGO_20211101 >									
	//        < 9qi0K6IKsljxpHA90o4t87543H35309I55ziZM2y12Qn0ID4b2k44wUs4JKn9hTs >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000014261482.495416200000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000015C2E4 >									
	//     < RUSS_PFIII_I_metadata_line_2_____CENTRAL_REPAIRS_A_MECHANICAL_PLANT_20211101 >									
	//        < 80V6YJYyr0S27Xi0riCdzRiK6Z33318g2rIiFKmKHX0jCMNuC7a932pjgif7CmMr >									
	//        <  u =="0.000000000000000001" : ] 000000014261482.495416200000000000 ; 000000028986815.431527200000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000015C2E42C3AFA >									
	//     < RUSS_PFIII_I_metadata_line_3_____CENT_REMONTNO_MEKHANICHESK_ZAVOD_20211101 >									
	//        < Wy68yPWznG706kHKkIJ4705Ccf784n5w1NC5T1rC478dAr855x3GXA88869Fgido >									
	//        <  u =="0.000000000000000001" : ] 000000028986815.431527200000000000 ; 000000042023465.424191800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002C3AFA401F6B >									
	//     < RUSS_PFIII_I_metadata_line_4_____ENERGOINVEST_ME_20211101 >									
	//        < fgv432l2S264oGk1L3XM87a56kb8pGW657B9rLozXLJ74suWJpNQMpRC1B013KG5 >									
	//        <  u =="0.000000000000000001" : ] 000000042023465.424191800000000000 ; 000000057051832.795405300000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000401F6B570DDF >									
	//     < RUSS_PFIII_I_metadata_line_5_____ENERGOKONSALT_20211101 >									
	//        < em6XCQG4P027T1M3gG68Y6XD0is5x0BN8r1Ka6MT94UK56J101hdYphE9Ln6DGa0 >									
	//        <  u =="0.000000000000000001" : ] 000000057051832.795405300000000000 ; 000000070843422.337362600000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000570DDF6C1936 >									
	//     < RUSS_PFIII_I_metadata_line_6_____REMONT_INGENERNYH_KOMMUNIKACIY_20211101 >									
	//        < f4qWPQ7AmoXh6H35Vly7qV3yMEy0074jkj6cRHjf05I1kwlk4be4c5wPxyd5DOYt >									
	//        <  u =="0.000000000000000001" : ] 000000070843422.337362600000000000 ; 000000084675221.337900200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006C1936813442 >									
	//     < RUSS_PFIII_I_metadata_line_7_____KVALITEK_NCO_20211101 >									
	//        < yOkfhL08dK52B73Wh2hMO55f663a9SOc0X2Rv974eemBD20X61DIMI4Q02Ujs71e >									
	//        <  u =="0.000000000000000001" : ] 000000084675221.337900200000000000 ; 000000099439152.888193400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000081344297BB6B >									
	//     < RUSS_PFIII_I_metadata_line_8_____CENT_MECHA_MAINTENANCE_PLANT_20211101 >									
	//        < j1rFittWb5gD4iy0020f8IO76299F5K3WobyY8GjTen2WtOFCAl8oK4XTd409LEE >									
	//        <  u =="0.000000000000000001" : ] 000000099439152.888193400000000000 ; 000000114034070.432413000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000097BB6BAE008F >									
	//     < RUSS_PFIII_I_metadata_line_9_____EPA_ENERGY_A_INDUSTRIAL_20211101 >									
	//        < FfGix6A81yWyWP0A556Mybz2VVs0vzzgbmgCk8086865gVTIRXy9p0a4S255P1o6 >									
	//        <  u =="0.000000000000000001" : ] 000000114034070.432413000000000000 ; 000000127867948.048366000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AE008FC31C6B >									
	//     < RUSS_PFIII_I_metadata_line_10_____VYATENERGOMONTAZH_20211101 >									
	//        < vdYc1TCNfng1qMYM9YvUqQa7V3N8w3X4vQQ102m4DuSvCvKZ4GeC5v5Hc98leUu9 >									
	//        <  u =="0.000000000000000001" : ] 000000127867948.048366000000000000 ; 000000142342143.343331000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C31C6BD93266 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIII_I_metadata_line_11_____TELPOENERGOREMONT_20211101 >									
	//        < Dz8Z456KRF97RaVI663HXumgR1395K8I3yKT6M6Gvv5RjnMugUwpOv2R0Mc2v9HD >									
	//        <  u =="0.000000000000000001" : ] 000000142342143.343331000000000000 ; 000000157343939.439754000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D93266F0167A >									
	//     < RUSS_PFIII_I_metadata_line_12_____TSK_NOVAYA_MOSKVA_20211101 >									
	//        < 67f1eCf2QvwYQ74J1511977jRGFeW7lM8Y7C695bPmtf8wq3VVX3yU5vEFJduqh7 >									
	//        <  u =="0.000000000000000001" : ] 000000157343939.439754000000000000 ; 000000172019127.963665000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F0167A1067AF9 >									
	//     < RUSS_PFIII_I_metadata_line_13_____ENERGO_KRAN_20211101 >									
	//        < B40ALPyY88fjX9dXvrZ0SYNdORZpiRbbZ4S37zK0NVw7VV55LyFCwTPS09520jEs >									
	//        <  u =="0.000000000000000001" : ] 000000172019127.963665000000000000 ; 000000185102229.691949000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001067AF911A718F >									
	//     < RUSS_PFIII_I_metadata_line_14_____TELPOENERGOREMONT_MOSKVA_20211101 >									
	//        < 7t12nrDhpOM7lk3CQG0nuDka7ZoS9n9lIYpCBmQpMi21A32s882SPm4SielZshiZ >									
	//        <  u =="0.000000000000000001" : ] 000000185102229.691949000000000000 ; 000000198884090.306478000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011A718F12F7919 >									
	//     < RUSS_PFIII_I_metadata_line_15_____TELPOENERGOREMONT_NOVOMICHURINSK_20211101 >									
	//        < 1ivLk1aV83yXI3Kk1u97d5rspWRD5R0X2PyVstrs52Fs2LM0uaI3iyUv0lc295ck >									
	//        <  u =="0.000000000000000001" : ] 000000198884090.306478000000000000 ; 000000213772045.894262000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012F791914630B5 >									
	//     < RUSS_PFIII_I_metadata_line_16_____TREST_GIDROMONTAZH_20211101 >									
	//        < D5H84CyE9rOkQi081zyGaE38J6Jh6qJ6MvFPGN1nbFefme74mEkjy5AzDTi0093H >									
	//        <  u =="0.000000000000000001" : ] 000000213772045.894262000000000000 ; 000000229265172.236468000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014630B515DD4B5 >									
	//     < RUSS_PFIII_I_metadata_line_17_____MTS_20211101 >									
	//        < Hfi1lLwM4T3Ag2ZJap5OxKVhM34BvdRVi6RE3SrE0vnfsAW861h3WM9eca2Zg6zK >									
	//        <  u =="0.000000000000000001" : ] 000000229265172.236468000000000000 ; 000000242524018.970839000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015DD4B51720FF2 >									
	//     < RUSS_PFIII_I_metadata_line_18_____MTS_USD_20211101 >									
	//        < 2673eSl5NYmZGyb3C82p701w8AT4naoyv4Yw53gaSlUbiH6W0fe1Mb4U5xv61L88 >									
	//        <  u =="0.000000000000000001" : ] 000000242524018.970839000000000000 ; 000000256148905.576571000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001720FF2186DA2B >									
	//     < RUSS_PFIII_I_metadata_line_19_____UZDUNROBITA_20211101 >									
	//        < lZaN50CbuaiWxaGEB7p49J8gGVU76Xx393Djl43j73p9Cbc3J034Ak3ImZV9r3wC >									
	//        <  u =="0.000000000000000001" : ] 000000256148905.576571000000000000 ; 000000271379887.971756000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000186DA2B19E17C5 >									
	//     < RUSS_PFIII_I_metadata_line_20_____UZDUNROBITA_SUM_20211101 >									
	//        < 3r29rv8IBZ4os725n6OMQlWmOEe4T1o1Buy54kkp0R8YRds7l5j9Gis6a69U7DQw >									
	//        <  u =="0.000000000000000001" : ] 000000271379887.971756000000000000 ; 000000285801598.097838000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019E17C51B41940 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIII_I_metadata_line_21_____BELARUSKALI_20211101 >									
	//        < e7vuxvho5CdT8EbDjpqv2JrRHlxarzcaN4O03z1iTYlQwWbY53um7Yw229HTG0os >									
	//        <  u =="0.000000000000000001" : ] 000000285801598.097838000000000000 ; 000000299071281.984436000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B419401C858B8 >									
	//     < RUSS_PFIII_I_metadata_line_22_____URALKALI_20211101 >									
	//        < Z748x3vnrL2UOEkvPXo5QFGVIeSZQ8w3398U2eQ0qG8VrH8vi5654LSJ5R7Z3n0L >									
	//        <  u =="0.000000000000000001" : ] 000000299071281.984436000000000000 ; 000000312759001.567986000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C858B81DD3B7C >									
	//     < RUSS_PFIII_I_metadata_line_23_____POTASH_CORP_20211101 >									
	//        < kPZFH5LrSDtyl71F8rsHjBG819tK07T0gNYRVsk0RfX8V93z79akGrG8P6QO89E2 >									
	//        <  u =="0.000000000000000001" : ] 000000312759001.567986000000000000 ; 000000327837643.203770000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DD3B7C1F43D94 >									
	//     < RUSS_PFIII_I_metadata_line_24_____K+S_20211101 >									
	//        < Pi673V8C9SL6l9qZ84loe6H2NKI8G7QplUHpWZ0BEfqv6V9K8Jl0x6NjxttwacBW >									
	//        <  u =="0.000000000000000001" : ] 000000327837643.203770000000000000 ; 000000340903114.393701000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F43D942082D47 >									
	//     < RUSS_PFIII_I_metadata_line_25_____FIRMA MORTDATEL OOO_20211101 >									
	//        < l7Y3Bo1gMqc28DUgWyGZ3C61m5FIyAgsTxd854oUJ0aGt4033W319OwH8swAJ4jh >									
	//        <  u =="0.000000000000000001" : ] 000000340903114.393701000000000000 ; 000000353863610.595328000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002082D4721BF3F9 >									
	//     < RUSS_PFIII_I_metadata_line_26_____CHELYABINSK_METTALURGICAL_PLANT_20211101 >									
	//        < T5xW5Pv2uzesRi0y5KX8R15851ZVFMhX2jmz5zl1Elu5SIkerzaJ243iWN1ZCcuN >									
	//        <  u =="0.000000000000000001" : ] 000000353863610.595328000000000000 ; 000000366881555.852169000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021BF3F922FD11C >									
	//     < RUSS_PFIII_I_metadata_line_27_____RASPADSKAYA_20211101 >									
	//        < 3F1KPHwb6vF3OQuTS2EVfubV88UGPELadSS8p8hIJQ4Ii70TU6RMknFI4wPJT2Fr >									
	//        <  u =="0.000000000000000001" : ] 000000366881555.852169000000000000 ; 000000382424038.773128000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022FD11C2478864 >									
	//     < RUSS_PFIII_I_metadata_line_28_____ROSNEFT_20211101 >									
	//        < 3Ud5w9a65l04C9PJ5qKT9OLt2eTQ8rp7A8tJ88Ti5k5Gy4c1uygg5Rsnjhgy4R37 >									
	//        <  u =="0.000000000000000001" : ] 000000382424038.773128000000000000 ; 000000397876664.880403000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000247886425F1C92 >									
	//     < RUSS_PFIII_I_metadata_line_29_____ROSTELECOM_20211101 >									
	//        < K3G13Q3t6ej5azrY92vk38gz5p4PbA6Lpp64V8GtwbF76U2dd3F07JtVCTlkmSi6 >									
	//        <  u =="0.000000000000000001" : ] 000000397876664.880403000000000000 ; 000000413371631.795037000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025F1C92276C14B >									
	//     < RUSS_PFIII_I_metadata_line_30_____ROSTELECOM_USD_20211101 >									
	//        < JNMhGTq2SzHtPZqXz9u42IJcgGJhVQz3z4i81mTLXJoJ64AcPDZySwYeDD45w5MF >									
	//        <  u =="0.000000000000000001" : ] 000000413371631.795037000000000000 ; 000000427019108.025160000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000276C14B28B9457 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIII_I_metadata_line_31_____SBERBANK_20211101 >									
	//        < XVH5APY93VkDhGg7Xg3zogRCp92v4lk893AlrP5PD6ohJi75o8YA2KXH4s746MG3 >									
	//        <  u =="0.000000000000000001" : ] 000000427019108.025160000000000000 ; 000000441586973.172105000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028B94572A1CEE9 >									
	//     < RUSS_PFIII_I_metadata_line_32_____SBERBANK_USD_20211101 >									
	//        < CTNtl2200Ral6HvD4i82p0eI18F9pqypRGpPKT4S2qHSs2d43PzjVRF8s6G66ulW >									
	//        <  u =="0.000000000000000001" : ] 000000441586973.172105000000000000 ; 000000456228382.927509000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A1CEE92B82636 >									
	//     < RUSS_PFIII_I_metadata_line_33_____TATNEFT_20211101 >									
	//        < Lo6ui4zevS78H1022o50993vDzpuf78439zodEwF5vidnS8gzTZy90r2wVw82z4g >									
	//        <  u =="0.000000000000000001" : ] 000000456228382.927509000000000000 ; 000000471495516.634085000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B826362CF71F0 >									
	//     < RUSS_PFIII_I_metadata_line_34_____TATNEFT_USD_20211101 >									
	//        < Rf8ziT96Z95I62tODXKOUXQI4P860Wx44dUr9iRMtKX7Lm661Bl3P9R5e27RVPcH >									
	//        <  u =="0.000000000000000001" : ] 000000471495516.634085000000000000 ; 000000486980316.027341000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CF71F02E712B0 >									
	//     < RUSS_PFIII_I_metadata_line_35_____TRANSNEFT_20211101 >									
	//        < os4ZlhE580kJeu25jmV8191iOWvzMo0zpSRm91k1RDy3T8LZ9R7oHugJs0x8F5c6 >									
	//        <  u =="0.000000000000000001" : ] 000000486980316.027341000000000000 ; 000000502424300.219763000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E712B02FEA37E >									
	//     < RUSS_PFIII_I_metadata_line_36_____TRANSNEFT_USD_20211101 >									
	//        < c24B0IiluKA47A01LT42l5VSyC5eW0PT433QBvVdI2Vp1vksN5ZqchC6GIX94eLV >									
	//        <  u =="0.000000000000000001" : ] 000000502424300.219763000000000000 ; 000000517300333.574592000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FEA37E3155671 >									
	//     < RUSS_PFIII_I_metadata_line_37_____ROSOBORONEKSPORT_20211101 >									
	//        < EGjp104XOFvSRD8yAXFpv1Np5b2pw8ZY65iEGA5BKcFZDC4eEBT3554QpaJuL4FR >									
	//        <  u =="0.000000000000000001" : ] 000000517300333.574592000000000000 ; 000000531336094.477699000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000315567132AC129 >									
	//     < RUSS_PFIII_I_metadata_line_38_____BASHNEFT_20211101 >									
	//        < 55Yhi25j2B7B04Vr6zg4WpwxJtVBLT219WFQUq7M6rYS7l0Nx8662PvG2NnN3Aqz >									
	//        <  u =="0.000000000000000001" : ] 000000531336094.477699000000000000 ; 000000546449237.535151000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032AC129341D0BC >									
	//     < RUSS_PFIII_I_metadata_line_39_____BASHNEFT_AB_20211101 >									
	//        < tHA96256R36DhC5QEg3WKG2r7U72SAG59lfIZUjkr2GD2QGrnhFv6ru4EVz6MORK >									
	//        <  u =="0.000000000000000001" : ] 000000546449237.535151000000000000 ; 000000560682895.071678000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000341D0BC35788C2 >									
	//     < RUSS_PFIII_I_metadata_line_40_____RAIFFEISENBANK_20211101 >									
	//        < 6EBC5qN0TRoDgh3vZX2gaQm22293RlVO79cf146mZOjI7ok78AAl4P486xfXSG2k >									
	//        <  u =="0.000000000000000001" : ] 000000560682895.071678000000000000 ; 000000575487268.745056000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035788C236E1FB7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}