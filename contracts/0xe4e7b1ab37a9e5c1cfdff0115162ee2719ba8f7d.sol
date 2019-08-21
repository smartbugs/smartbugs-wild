pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXIV_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXIV_II_883		"	;
		string	public		symbol =	"	RUSS_PFXIV_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		795614035169367000000000000					;	
										
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
	//     < RUSS_PFXIV_II_metadata_line_1_____NORIMET_LIMITED_20231101 >									
	//        < 1U2F5daAm15re7K282ZR6aU0h61QuEo06iSmjY1ewkKFR6XQ8672J8vHKg50xW30 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000018302113.161568100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001BED43 >									
	//     < RUSS_PFXIV_II_metadata_line_2_____NORNICKEL_AUSTRALIA_PTY_LIMITED_20231101 >									
	//        < 3q5O7zNld33a1enA5qg2oKDv3rr1371UUn046mNsUWLyW4On6vadB093hDa0RJ45 >									
	//        <  u =="0.000000000000000001" : ] 000000018302113.161568100000000000 ; 000000043182994.963161200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001BED4341E45B >									
	//     < RUSS_PFXIV_II_metadata_line_3_____NORILSKGAZPROM_20231101 >									
	//        < M66W5Q45n8eXNHSjw6rR5EOSDannzgVE9AT4UE1BLDCp96dFYhKcewjY39R4p7Ps >									
	//        <  u =="0.000000000000000001" : ] 000000043182994.963161200000000000 ; 000000060024825.897479800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000041E45B5B9733 >									
	//     < RUSS_PFXIV_II_metadata_line_4_____NORILSK_NICKEL_USA_INC_20231101 >									
	//        < 4A36dHNh4E2XKOy9110sIW43xr7N99r47qp0wV9P0hnZfJ08ybI0465mVPuOlDM5 >									
	//        <  u =="0.000000000000000001" : ] 000000060024825.897479800000000000 ; 000000082697463.639882300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005B97337E2FB2 >									
	//     < RUSS_PFXIV_II_metadata_line_5_____DALRYMPLE_RESOURCES_PTY_LTD_20231101 >									
	//        < 4v6548v0l5Qw4iS3v9upsVNzD7UdTK4io4JN8Fh5QAL7aZfZg5WE69qg4FOusJ3V >									
	//        <  u =="0.000000000000000001" : ] 000000082697463.639882300000000000 ; 000000107343629.529494000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007E2FB2A3CB1B >									
	//     < RUSS_PFXIV_II_metadata_line_6_____MPI_NICKEL_PTY_LTD_20231101 >									
	//        < zX6awTcsviUqEi13xWQ6955X9oFNu51p4I8d2ap68G74xEtu7xjeZ0p47NqFQp47 >									
	//        <  u =="0.000000000000000001" : ] 000000107343629.529494000000000000 ; 000000130754847.489930000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A3CB1BC7841D >									
	//     < RUSS_PFXIV_II_metadata_line_7_____CAWSE_PROPRIETARY_LIMITED_20231101 >									
	//        < ZZ3hZmufHQbV0ZYG7Cd73vwFs0H6S2p6rpVTQVtjWXNLUnj8h3uU4W1UaWxDlW5R >									
	//        <  u =="0.000000000000000001" : ] 000000130754847.489930000000000000 ; 000000153270986.315656000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C7841DE9DF7B >									
	//     < RUSS_PFXIV_II_metadata_line_8_____NORNICKEL_TERMINAL_20231101 >									
	//        < HB56tuas2Y6RwRVUhLQDCwMl2kil9V9zs12mQ1ZhQXWUat73rqr8bEs43m0U1EaB >									
	//        <  u =="0.000000000000000001" : ] 000000153270986.315656000000000000 ; 000000176785154.324262000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E9DF7B10DC0B3 >									
	//     < RUSS_PFXIV_II_metadata_line_9_____NORILSKPROMTRANSPORT_20231101 >									
	//        < 0m7vx5C10pPZcXC2v1sgfjoxxE4Wj0AJ6i08R1gjunG7ftYB8Vip8ygj3nv5d9vJ >									
	//        <  u =="0.000000000000000001" : ] 000000176785154.324262000000000000 ; 000000201295160.252180000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010DC0B313326EC >									
	//     < RUSS_PFXIV_II_metadata_line_10_____NORILSKGEOLOGIYA_OOO_20231101 >									
	//        < K83Ef53VmA0F6R9G16eYqSD8G11jW2Arho5SF1N73w15A8K8X2j6Ae9BvmBS95yd >									
	//        <  u =="0.000000000000000001" : ] 000000201295160.252180000000000000 ; 000000219365751.984581000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013326EC14EB9BF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXIV_II_metadata_line_11_____NORNICKEL_FINLAND_OY_20231101 >									
	//        < 6dE542nLhjB68njMR4HMYVDDY7G3BLSGup2koKkcv9wH1R1jDBGUF9WLf3F4OFvk >									
	//        <  u =="0.000000000000000001" : ] 000000219365751.984581000000000000 ; 000000239998988.351648000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014EB9BF16E359B >									
	//     < RUSS_PFXIV_II_metadata_line_12_____CORBIERE_HOLDINGS_LTD_20231101 >									
	//        < 1DRu36Z2b9wUzh2LId5R1YvcDKfl32iwv8OBH04GV0K62EYvmLJ40MATF7y90q09 >									
	//        <  u =="0.000000000000000001" : ] 000000239998988.351648000000000000 ; 000000256995378.637184000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016E359B18824D2 >									
	//     < RUSS_PFXIV_II_metadata_line_13_____MEDVEZHY_RUCHEY_20231101 >									
	//        < Jxq7T5EwF61Q16vzuz3Eo0hkN8Y28Fn3R0hGDD4JY2bh8u3gW94iV64b5J7F9Hh7 >									
	//        <  u =="0.000000000000000001" : ] 000000256995378.637184000000000000 ; 000000277365208.828360000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018824D21A739C9 >									
	//     < RUSS_PFXIV_II_metadata_line_14_____NNK_TRADITSIYA_20231101 >									
	//        < 2x2Zb64F9N5Kt7575nsXG9WG5k0Auy24FHW824a0VNQgnqk0E701sS9GOmRBvLN9 >									
	//        <  u =="0.000000000000000001" : ] 000000277365208.828360000000000000 ; 000000299283325.266470000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A739C91C8AB8D >									
	//     < RUSS_PFXIV_II_metadata_line_15_____RADIO_SEVERNY_GOROD_20231101 >									
	//        < e0UDV7CZPyK9D3ZKhJ8dcdlrwr2zb6x3iXh46ch0oRVF6QlhIpdA5X2wZjn0oS48 >									
	//        <  u =="0.000000000000000001" : ] 000000299283325.266470000000000000 ; 000000315034454.157685000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C8AB8D1E0B455 >									
	//     < RUSS_PFXIV_II_metadata_line_16_____ALYKEL_20231101 >									
	//        < vs47slmvlJK7F31uCDf521BCK1TaHECm87uoU9jUTWOW69tSDWckJG36pqZiMU9L >									
	//        <  u =="0.000000000000000001" : ] 000000315034454.157685000000000000 ; 000000330693513.460782000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E0B4551F89927 >									
	//     < RUSS_PFXIV_II_metadata_line_17_____GEOKOMP_OOO_20231101 >									
	//        < D6u496p87W8bT9Bt512l9Ukx6Xw42IJQXz9wMd7BJlQwIFgb02706PXJ5vUDKV0Q >									
	//        <  u =="0.000000000000000001" : ] 000000330693513.460782000000000000 ; 000000346582786.981683000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F89927210D7E7 >									
	//     < RUSS_PFXIV_II_metadata_line_18_____LIONORE_SOUTH_AFRICA_20231101 >									
	//        < rmBM00Y8H4bdzVg6CvQtg616dlNKGrbtJ03Oy9Do0gA32fW0Ubh9DR3Fpu2rR996 >									
	//        <  u =="0.000000000000000001" : ] 000000346582786.981683000000000000 ; 000000368924926.266501000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000210D7E7232EF4D >									
	//     < RUSS_PFXIV_II_metadata_line_19_____VESHCHATELNAYA_KORPORATSIYA_TELESFERA_20231101 >									
	//        < 83F35Zt1ulwa5O4gg03RhWx6Z3fdB3tJjR9c5YlDv8w2C26zsNKXEa1YZ30kF8Fm >									
	//        <  u =="0.000000000000000001" : ] 000000368924926.266501000000000000 ; 000000390676618.411542000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000232EF4D254200E >									
	//     < RUSS_PFXIV_II_metadata_line_20_____SRETENSKAYA_COPPER_COMPANY_20231101 >									
	//        < E66Wbdge6JfJV1se711tnnRj2G5wd2xxMh0DcTW9op6w4LZlp1eld03Q4RcPm0m2 >									
	//        <  u =="0.000000000000000001" : ] 000000390676618.411542000000000000 ; 000000407952485.322903000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000254200E26E7C71 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXIV_II_metadata_line_21_____NORILSKNICKELREMONT_20231101 >									
	//        < I7np9wG8wy9yh5y22ymDCdgua87A5y066BGm9h9BqMYqwIv1Bx2TKAWdw8N13iwb >									
	//        <  u =="0.000000000000000001" : ] 000000407952485.322903000000000000 ; 000000430820521.818804000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026E7C712916144 >									
	//     < RUSS_PFXIV_II_metadata_line_22_____NORILSK_NICKEL_INTERGENERATION_20231101 >									
	//        < 02RZDQi6BC2G8R7ZxINQ66081yVw411DQpjJq0jTRm740Mxtzq43nmL9ktR7dxlv >									
	//        <  u =="0.000000000000000001" : ] 000000430820521.818804000000000000 ; 000000454958525.923392000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029161442B6362D >									
	//     < RUSS_PFXIV_II_metadata_line_23_____PERVAYA_MILYA_OOO_20231101 >									
	//        < Qt0jPwTwGP4C5H35H274yR0vi061Ov8XgBbbd31y1B4e9Wpfwb8k00N2G5mvLg1F >									
	//        <  u =="0.000000000000000001" : ] 000000454958525.923392000000000000 ; 000000479287503.513851000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B6362D2DB55AE >									
	//     < RUSS_PFXIV_II_metadata_line_24_____NORILSKNICKELREMONT_OOO_20231101 >									
	//        < QB1Ki4RPBQD8l3Xp7yQNN0XG9bXvN66a7Ks06v9E9iTCE3o8sS6PC5jam8T8Wl0r >									
	//        <  u =="0.000000000000000001" : ] 000000479287503.513851000000000000 ; 000000497976882.719101000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DB55AE2F7DA38 >									
	//     < RUSS_PFXIV_II_metadata_line_25_____NORNICKEL_INT_HOLDINS_CANADA_20231101 >									
	//        < A28FL8Sd0rym81MkeBaSOG0Kz69AlGAxc53R1q40Ae2E47bo6u4NFmM12rToWeb9 >									
	//        <  u =="0.000000000000000001" : ] 000000497976882.719101000000000000 ; 000000514655660.286860000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F7DA383114D5E >									
	//     < RUSS_PFXIV_II_metadata_line_26_____INTERGEOPROYEKT_LLC_20231101 >									
	//        < 2g63Cv6r6K3BSKLBnYSN4IxGPrj3IUX9QqE98vse4KbMgtngHuyzi9yH0Y2rJ8hs >									
	//        <  u =="0.000000000000000001" : ] 000000514655660.286860000000000000 ; 000000532284738.582108000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003114D5E32C33BA >									
	//     < RUSS_PFXIV_II_metadata_line_27_____WESTERN_MINERALS_TECHNOLOGY_20231101 >									
	//        < n6Bab2p8dkwXgYg31or4cMKmkBBLGH2y2Ne74aFq4j6CL3I0IND6J7597UMqk8Y7 >									
	//        <  u =="0.000000000000000001" : ] 000000532284738.582108000000000000 ; 000000551111516.618316000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032C33BA348EDF0 >									
	//     < RUSS_PFXIV_II_metadata_line_28_____NORMETIMPEX_20231101 >									
	//        < Pf8ZP0e770W7qXFAw7U9WK155M915707UYnJE2oE5j0ejvVR0fV6FK11t4H6PP2x >									
	//        <  u =="0.000000000000000001" : ] 000000551111516.618316000000000000 ; 000000575608422.996390000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000348EDF036E4F0A >									
	//     < RUSS_PFXIV_II_metadata_line_29_____RAO_NORNICKEL_20231101 >									
	//        < 9c1U4A1s4hJ1asMIid5JIx4690z1hZ5HRRqZB0WYE9862Z3SiVDJbAQys0sjLFv7 >									
	//        <  u =="0.000000000000000001" : ] 000000575608422.996390000000000000 ; 000000595878641.493135000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036E4F0A38D3D18 >									
	//     < RUSS_PFXIV_II_metadata_line_30_____ZAPOLYARNAYA_STROITELNAYA_KOMPANIYA_20231101 >									
	//        < Pp5PC07ZncJWd6izdS3gH2ekU926GUc0RNnPuuPAl4BTVxmDrP9LdzLWFdpc53P0 >									
	//        <  u =="0.000000000000000001" : ] 000000595878641.493135000000000000 ; 000000615708850.365732000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038D3D183AB7F45 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXIV_II_metadata_line_31_____NORNICKEL_PROCESSING_TECH_20231101 >									
	//        < sfy3454POypvZf7Ctt8feP1DE6msHBN2Tnmf47ECisYklrQ5hL4pYQb0DBfdf424 >									
	//        <  u =="0.000000000000000001" : ] 000000615708850.365732000000000000 ; 000000635017208.584079000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003AB7F453C8F599 >									
	//     < RUSS_PFXIV_II_metadata_line_32_____NORNICKEL_KTK_20231101 >									
	//        < 2xi7ZD39G6t42277ywvNsb3gBN6IsGs54hi32W2cFDP9Fn5F59jEUNo92OuBhtqW >									
	//        <  u =="0.000000000000000001" : ] 000000635017208.584079000000000000 ; 000000652676485.964560000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C8F5993E3E7C1 >									
	//     < RUSS_PFXIV_II_metadata_line_33_____NORILSKYI_OBESPECHIVAUSHYI_COMPLEX_20231101 >									
	//        < 0Uo4Pv6q15c7jM1YGIJI4mknA6x97wAJD7aTm6F30h203z9Q55ZCEyp04QDvTe7o >									
	//        <  u =="0.000000000000000001" : ] 000000652676485.964560000000000000 ; 000000670787259.130409000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E3E7C13FF8A46 >									
	//     < RUSS_PFXIV_II_metadata_line_34_____GRK_BYSTRINSKOYE_20231101 >									
	//        < rvZnVd73lf3XR85Iu11n24j1F9wr09236yrhlzYA0UCiDfW3j43nw308LV2VQqhc >									
	//        <  u =="0.000000000000000001" : ] 000000670787259.130409000000000000 ; 000000686352635.314784000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003FF8A464174A80 >									
	//     < RUSS_PFXIV_II_metadata_line_35_____NORILSKIY_KOMBINAT_20231101 >									
	//        < 293cUrj44J97oE59KbBd4A35042cHOD42HRs74TKR6AzON9u4ZGin1Il5IeYtQ29 >									
	//        <  u =="0.000000000000000001" : ] 000000686352635.314784000000000000 ; 000000701841387.125964000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004174A8042EECCB >									
	//     < RUSS_PFXIV_II_metadata_line_36_____HARJAVALTA_OY_20231101 >									
	//        < CuWPCjFTjoUbL15rxq57A0C0pAVpO814hfT5V6F46zzNUd58G790t9vkt7iZHzXd >									
	//        <  u =="0.000000000000000001" : ] 000000701841387.125964000000000000 ; 000000720058609.500941000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042EECCB44AB8E5 >									
	//     < RUSS_PFXIV_II_metadata_line_37_____ZAPOLYARNYI_TORGOVYI_ALIANS_20231101 >									
	//        < 15u6Ajc6RDzSpfsX9l5M754Jar39TBn0xWp52TH58moCL458qDj76F24wNoXhsqV >									
	//        <  u =="0.000000000000000001" : ] 000000720058609.500941000000000000 ; 000000735729946.216526000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044AB8E5462A283 >									
	//     < RUSS_PFXIV_II_metadata_line_38_____AVALON_20231101 >									
	//        < Tw1y2CMkfuaev15LZuwH1sWk0KilPe7a56gV0P3L7Zi1wS8702gdiqqxF7CDpDYM >									
	//        <  u =="0.000000000000000001" : ] 000000735729946.216526000000000000 ; 000000756087375.536758000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000462A283481B2A2 >									
	//     < RUSS_PFXIV_II_metadata_line_39_____GUSINOOZERSKAYA_20231101 >									
	//        < u7W7P81mLqwy2O8pnTyF760C9r5m7qG216hkhsXQqNV7l21DnXuMiaiF7ZCT3u3j >									
	//        <  u =="0.000000000000000001" : ] 000000756087375.536758000000000000 ; 000000773446333.332972000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000481B2A249C2F79 >									
	//     < RUSS_PFXIV_II_metadata_line_40_____NORNICKEL_PSMK_OOO_20231101 >									
	//        < hiu1533HbIu3zS47us3HgP1636cN73ghy7iAsnmun21izo1OBV26NMzLV2a9JwE1 >									
	//        <  u =="0.000000000000000001" : ] 000000773446333.332972000000000000 ; 000000795614035.169367000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049C2F794BE02BC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}