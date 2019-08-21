pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFIII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFIII_III_883		"	;
		string	public		symbol =	"	RUSS_PFIII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1078457842134810000000000000					;	
										
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
	//     < RUSS_PFIII_III_metadata_line_1_____MOSENERGO_20251101 >									
	//        < KU0tV07E5w2pu55F4iKf4Ul447N717k7NInvZitTM2thMO8o7deh1i980BaOmrFf >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000026348683.132683100000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000283474 >									
	//     < RUSS_PFIII_III_metadata_line_2_____CENTRAL_REPAIRS_A_MECHANICAL_PLANT_20251101 >									
	//        < 7mhR5JUKJAKg51NMmBs8G3Nc4GWA9HPv03ly0na6W4ds7N8Jg0sJ8CmtV71SWAnr >									
	//        <  u =="0.000000000000000001" : ] 000000026348683.132683100000000000 ; 000000048960344.108822700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002834744AB522 >									
	//     < RUSS_PFIII_III_metadata_line_3_____CENT_REMONTNO_MEKHANICHESK_ZAVOD_20251101 >									
	//        < 1gjh1SLsMi9fQoGGY8D9hZSkwbRl3m0VnpkGI5z7PwAD5evYU9du93XIiay3l8NU >									
	//        <  u =="0.000000000000000001" : ] 000000048960344.108822700000000000 ; 000000076994608.250975800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004AB522757C05 >									
	//     < RUSS_PFIII_III_metadata_line_4_____ENERGOINVEST_ME_20251101 >									
	//        < HWwYRfK10FhSc806gZmi67MJt15w3CwJgA3WQle0YUaM9yH2y5Cr2B1DCmS6jl2Z >									
	//        <  u =="0.000000000000000001" : ] 000000076994608.250975800000000000 ; 000000107388070.869304000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000757C05A3DC77 >									
	//     < RUSS_PFIII_III_metadata_line_5_____ENERGOKONSALT_20251101 >									
	//        < 2uT8JkW99nrV5L7cJXO6Gw361bjGf6h9B6U9501QXj913NG91Y8VeQh8MYcwur7v >									
	//        <  u =="0.000000000000000001" : ] 000000107388070.869304000000000000 ; 000000128539849.595112000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A3DC77C422E1 >									
	//     < RUSS_PFIII_III_metadata_line_6_____REMONT_INGENERNYH_KOMMUNIKACIY_20251101 >									
	//        < 5izo3UtLAPqU9wHd5ph7khJ9tk0cHs6F1S0A2nOhb5fbI0r78345UwFX4Z6I00B2 >									
	//        <  u =="0.000000000000000001" : ] 000000128539849.595112000000000000 ; 000000147601305.755336000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C422E1E138C3 >									
	//     < RUSS_PFIII_III_metadata_line_7_____KVALITEK_NCO_20251101 >									
	//        < 77rn34FjRrL54V3pZYL1tV326TRhcnAvDO537VR646Fk84MQJEeHi534fzsV1BNa >									
	//        <  u =="0.000000000000000001" : ] 000000147601305.755336000000000000 ; 000000167529964.589131000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E138C3FFA164 >									
	//     < RUSS_PFIII_III_metadata_line_8_____CENT_MECHA_MAINTENANCE_PLANT_20251101 >									
	//        < JH3UUItWchIfc3zHTr7947210gV0VflrTXJMpxo9g9c6pDQ791HhKhKiywT5E6k4 >									
	//        <  u =="0.000000000000000001" : ] 000000167529964.589131000000000000 ; 000000199798271.310913000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FFA164130DE33 >									
	//     < RUSS_PFIII_III_metadata_line_9_____EPA_ENERGY_A_INDUSTRIAL_20251101 >									
	//        < 1hO26sf0Hp4iHh4vfxx5D757HoAsdK971X54CD2Fs6hTaS9e8g5xOi90KE8ZWkNg >									
	//        <  u =="0.000000000000000001" : ] 000000199798271.310913000000000000 ; 000000234648490.856804000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000130DE331660B91 >									
	//     < RUSS_PFIII_III_metadata_line_10_____VYATENERGOMONTAZH_20251101 >									
	//        < 6mC4r5DUm2WVa5v4vqtPYao6Ie8ZLOS974X4ElxTvWGTXoFWwfXMZG1nGkp1760a >									
	//        <  u =="0.000000000000000001" : ] 000000234648490.856804000000000000 ; 000000262156538.172327000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001660B9119004E6 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIII_III_metadata_line_11_____TELPOENERGOREMONT_20251101 >									
	//        < J81n352Cdp6zr6o420EN757AI3Y9B40Thqn3st46I2zvT4yYd3jMFAP2JugHkE52 >									
	//        <  u =="0.000000000000000001" : ] 000000262156538.172327000000000000 ; 000000282666271.217647000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019004E61AF5083 >									
	//     < RUSS_PFIII_III_metadata_line_12_____TSK_NOVAYA_MOSKVA_20251101 >									
	//        < R727rCUo5q39Ze6bri9l443wV07wF7F4fr1qn7V6uVely6yEWd79a5gK9C31Noum >									
	//        <  u =="0.000000000000000001" : ] 000000282666271.217647000000000000 ; 000000304736618.275600000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AF50831D0FDBE >									
	//     < RUSS_PFIII_III_metadata_line_13_____ENERGO_KRAN_20251101 >									
	//        < qVuxrs044Uy8ap5HrdzEQM52xr79uZonp63XRz8Pp4ifPqdoT7SG8kB5EiD8iwtL >									
	//        <  u =="0.000000000000000001" : ] 000000304736618.275600000000000000 ; 000000328503713.695989000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D0FDBE1F541C3 >									
	//     < RUSS_PFIII_III_metadata_line_14_____TELPOENERGOREMONT_MOSKVA_20251101 >									
	//        < u7cizu6QTn2EA139L1uS6ds2iAHxkwcT96tskplYxgV889QVt7G3NKiZYbXo55w6 >									
	//        <  u =="0.000000000000000001" : ] 000000328503713.695989000000000000 ; 000000356064807.811843000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F541C321F4FD1 >									
	//     < RUSS_PFIII_III_metadata_line_15_____TELPOENERGOREMONT_NOVOMICHURINSK_20251101 >									
	//        < OSs0RY6FjXIbZbKQqiXo43KjgM77nv4UrP261EMK0lX647a6OT69qZ360w1AuFBh >									
	//        <  u =="0.000000000000000001" : ] 000000356064807.811843000000000000 ; 000000382600573.444353000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021F4FD1247CD59 >									
	//     < RUSS_PFIII_III_metadata_line_16_____TREST_GIDROMONTAZH_20251101 >									
	//        < zTq4rQcCHXeI55i2J4GeI8M5w7c13GZ4Jh5n4YpKvzToVoY99U63X420WqOIHv6g >									
	//        <  u =="0.000000000000000001" : ] 000000382600573.444353000000000000 ; 000000403418303.703349000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000247CD592679146 >									
	//     < RUSS_PFIII_III_metadata_line_17_____MTS_20251101 >									
	//        < B6K83kndVzu71x8I2ocfIW8n31yl2b3wunX0DOvMBQJ9Ikop7CFM31LKdq39qnJ9 >									
	//        <  u =="0.000000000000000001" : ] 000000403418303.703349000000000000 ; 000000425448616.170663000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026791462892EDE >									
	//     < RUSS_PFIII_III_metadata_line_18_____MTS_USD_20251101 >									
	//        < B2k06RCJ2jG8ph024I4aAC0JF5J8UEEpNXNJdC6H7NWO0M84JnQQRB9201x2qqgB >									
	//        <  u =="0.000000000000000001" : ] 000000425448616.170663000000000000 ; 000000448511636.722500000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002892EDE2AC5FDC >									
	//     < RUSS_PFIII_III_metadata_line_19_____UZDUNROBITA_20251101 >									
	//        < c64lvHl4OzLz96O8614BXw4NtQ6JxXRBaAdnPW7rx2w73MG6m9HlishK9C0R4Tlv >									
	//        <  u =="0.000000000000000001" : ] 000000448511636.722500000000000000 ; 000000484095357.512453000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AC5FDC2E2ABC0 >									
	//     < RUSS_PFIII_III_metadata_line_20_____UZDUNROBITA_SUM_20251101 >									
	//        < QyEGdYm5nMVbzbYlHrvIMQm9P9y6Ew6nP5ov22Xr4vVog8oIPabcUU4ZhehinjB7 >									
	//        <  u =="0.000000000000000001" : ] 000000484095357.512453000000000000 ; 000000517792435.753567000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E2ABC031616AC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIII_III_metadata_line_21_____BELARUSKALI_20251101 >									
	//        < Ajvi12p0FHXC9ex3AW87w15519xacTp0j9GG1pOThAab5dA5qW8d6n4lYfpm39C7 >									
	//        <  u =="0.000000000000000001" : ] 000000517792435.753567000000000000 ; 000000546405842.709607000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031616AC341BFC8 >									
	//     < RUSS_PFIII_III_metadata_line_22_____URALKALI_20251101 >									
	//        < 5o42JVA9JO2ak1K405Xx13aB51n4lchy4bVAqmHy2p0sE702GrP59L6kK3EmA0zN >									
	//        <  u =="0.000000000000000001" : ] 000000546405842.709607000000000000 ; 000000565920449.939658000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000341BFC835F86AD >									
	//     < RUSS_PFIII_III_metadata_line_23_____POTASH_CORP_20251101 >									
	//        < ik7UL83M8xPJtk5b66fJZO4WjHg58HZ1wi55BV6P239BvDjbi4uWX943I0Y8C10e >									
	//        <  u =="0.000000000000000001" : ] 000000565920449.939658000000000000 ; 000000591224179.208149000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035F86AD38622F2 >									
	//     < RUSS_PFIII_III_metadata_line_24_____K+S_20251101 >									
	//        < 4Dj3LUavT34T1P0902K71M9Avj5G46mXPtrzi9iM3H8U6nxKK9dRvz318762Yhtl >									
	//        <  u =="0.000000000000000001" : ] 000000591224179.208149000000000000 ; 000000625745990.982924000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038622F23BAD007 >									
	//     < RUSS_PFIII_III_metadata_line_25_____FIRMA MORTDATEL OOO_20251101 >									
	//        < d38h3Iie9M5ccPIU6tqugpPbp8AE9Ktq8iXeTkWQMuvcmENT3V63aCRgetN8YYw7 >									
	//        <  u =="0.000000000000000001" : ] 000000625745990.982924000000000000 ; 000000646002266.335273000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003BAD0073D9B8A3 >									
	//     < RUSS_PFIII_III_metadata_line_26_____CHELYABINSK_METTALURGICAL_PLANT_20251101 >									
	//        < P5RyEa2OET9625IlI6RzeBvEc1MZ4129kch6dP95bcm5l1L15c6P8R1uf6IWl4Pe >									
	//        <  u =="0.000000000000000001" : ] 000000646002266.335273000000000000 ; 000000678195546.056294000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D9B8A340AD823 >									
	//     < RUSS_PFIII_III_metadata_line_27_____RASPADSKAYA_20251101 >									
	//        < WYPNpI1q8Ci9kZpeT9q783eyDKp5if3LlnRoN4xX7EKvPqa4s2smLD2Upu1gcz7z >									
	//        <  u =="0.000000000000000001" : ] 000000678195546.056294000000000000 ; 000000710561156.361060000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040AD82343C3AF4 >									
	//     < RUSS_PFIII_III_metadata_line_28_____ROSNEFT_20251101 >									
	//        < Hf2XXX1p1ZCq0o2N82E4WX7t6pLmjCHpM0sS09YhaJdKKaOUD503CDN1OqgGwWO4 >									
	//        <  u =="0.000000000000000001" : ] 000000710561156.361060000000000000 ; 000000735399171.427242000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000043C3AF4462214D >									
	//     < RUSS_PFIII_III_metadata_line_29_____ROSTELECOM_20251101 >									
	//        < r89v8Y8zIj48Mj419sD438Z1S3FmOLN4x5aNVweXwF7vI2W6N9i16GGw53u7kY2V >									
	//        <  u =="0.000000000000000001" : ] 000000735399171.427242000000000000 ; 000000765414377.697473000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000462214D48FEDFE >									
	//     < RUSS_PFIII_III_metadata_line_30_____ROSTELECOM_USD_20251101 >									
	//        < 4KI53toyir6nVXQhYS6sP65O4Yq8U6y80aLd4k0LBahOzZymlvW9QK926jpFv9Qt >									
	//        <  u =="0.000000000000000001" : ] 000000765414377.697473000000000000 ; 000000798515339.044887000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048FEDFE4C2700E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIII_III_metadata_line_31_____SBERBANK_20251101 >									
	//        < AC1UWf17bVQh699h2Zi8ShT4lRbrvjmAfRyFmJJZE01q35S4GKtR0N4lG8oFIF57 >									
	//        <  u =="0.000000000000000001" : ] 000000798515339.044887000000000000 ; 000000828814559.936298000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004C2700E4F0ABB0 >									
	//     < RUSS_PFIII_III_metadata_line_32_____SBERBANK_USD_20251101 >									
	//        < lUXzT91tyX71i2iP6C24T44s297K91y3K1jb7Y62i2Oah3q1BftEUOyzc0O4Tc8o >									
	//        <  u =="0.000000000000000001" : ] 000000828814559.936298000000000000 ; 000000850603091.432855000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004F0ABB0511EAD5 >									
	//     < RUSS_PFIII_III_metadata_line_33_____TATNEFT_20251101 >									
	//        < 3U0fpsB3yV02Y98jIQHI38fObNfmo8PKF0tWN29Xf31986Fb4610s4T4Ir5S6Vj0 >									
	//        <  u =="0.000000000000000001" : ] 000000850603091.432855000000000000 ; 000000875847428.467596000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000511EAD55386FE7 >									
	//     < RUSS_PFIII_III_metadata_line_34_____TATNEFT_USD_20251101 >									
	//        < 7V4n7by5126105a5zw7EFrTvpS8aQx3IONLwc37ZG5P2S5H0o6COMMbw8xB1gE3r >									
	//        <  u =="0.000000000000000001" : ] 000000875847428.467596000000000000 ; 000000898107241.103375000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005386FE755A6724 >									
	//     < RUSS_PFIII_III_metadata_line_35_____TRANSNEFT_20251101 >									
	//        < A5UlDlr5rYAu8CCyJtL1FApSFDo7Kt88r2uIER7jckP586dlm5GTJu3A68KT1AkJ >									
	//        <  u =="0.000000000000000001" : ] 000000898107241.103375000000000000 ; 000000917574796.104108000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000055A67245781BA8 >									
	//     < RUSS_PFIII_III_metadata_line_36_____TRANSNEFT_USD_20251101 >									
	//        < EuU8BeibJ9pKyNVK2BY6epaNyvrkWH08UGMEr4ztxfs9GRS2hfHRsX908wpNTL6j >									
	//        <  u =="0.000000000000000001" : ] 000000917574796.104108000000000000 ; 000000952573584.289162000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005781BA85AD830E >									
	//     < RUSS_PFIII_III_metadata_line_37_____ROSOBORONEKSPORT_20251101 >									
	//        < aw5iDHFoqwaH1NlDXJ95EF19e6i0aiLwSs23pO68uPzu4PIdn3l193iAJj3uMEP6 >									
	//        <  u =="0.000000000000000001" : ] 000000952573584.289162000000000000 ; 000000986266960.467029000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005AD830E5E0EC88 >									
	//     < RUSS_PFIII_III_metadata_line_38_____BASHNEFT_20251101 >									
	//        < 3S43e81x3U17Uxi9143FuXqcX7D3MaT2sw8Z20bh16SpU3503BM36cNemoV8jcMe >									
	//        <  u =="0.000000000000000001" : ] 000000986266960.467029000000000000 ; 000001013961666.278180000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005E0EC8860B2EC7 >									
	//     < RUSS_PFIII_III_metadata_line_39_____BASHNEFT_AB_20251101 >									
	//        < 4JFC2Sdh8wl1B5rp5379p942rO11WtyETK9q1Fd6Y38ww5HHkV76JDOldNQ1XwTc >									
	//        <  u =="0.000000000000000001" : ] 000001013961666.278180000000000000 ; 000001049358698.036490000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000060B2EC764131BE >									
	//     < RUSS_PFIII_III_metadata_line_40_____RAIFFEISENBANK_20251101 >									
	//        < 60D7K6h1jXvwj1XvGz8Snsh5q4w7Ex4JSOo5jZ3bxQa0Iq6W94qOi370fyEuHJ68 >									
	//        <  u =="0.000000000000000001" : ] 000001049358698.036490000000000000 ; 000001078457842.134810000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000064131BE66D9898 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}