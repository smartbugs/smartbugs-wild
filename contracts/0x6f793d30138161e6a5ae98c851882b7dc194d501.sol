pragma solidity 		^0.4.25	;						
										
	contract	EUROSIBENERGO_PFXXI_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	EUROSIBENERGO_PFXXI_I_883		"	;
		string	public		symbol =	"	EUROSIBENERGO_PFXXI_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		597902679176595000000000000					;	
										
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
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_1_____Irkutskenergo_JSC_20220321 >									
	//        < 9d4J1uuTPV0NLcg01HmE35nX8oY45Dc0WFu18N3g3TmxY77KJ13oicrMUiHcS5vn >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000015917430.145098400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001849BF >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_2_____Irkutskenergo_PCI_20220321 >									
	//        < 8hc5XM6t2b9sgP2yy26Tw2zL7dplRgx9512HEM5sW2DvNa94J5q0nm4v9yAjIIjI >									
	//        <  u =="0.000000000000000001" : ] 000000015917430.145098400000000000 ; 000000031554741.996618700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001849BF302612 >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_3_____Irkutskenergo_PCI_Bratsk_20220321 >									
	//        < 6qYcu04Vayg4qCFuaRL004Jmyd7FGlImG3Kb1y4bpq276OWtotFeA5DKaW3q0z3s >									
	//        <  u =="0.000000000000000001" : ] 000000031554741.996618700000000000 ; 000000046245219.370264600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000030261246908A >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_4_____Irkutskenergo_PCI_Ust_Ilimsk_20220321 >									
	//        < Ze8Cto3hzexJSEQOu8Q7j4qK19UQ1p5fB9S2zm2Y3Y1F9aEj89jC6z3YOMR91yWm >									
	//        <  u =="0.000000000000000001" : ] 000000046245219.370264600000000000 ; 000000058695111.883866400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000046908A598FC7 >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_5_____Irkutskenergo_Bratsk_org_spe_20220321 >									
	//        < TIM2KRIowSDOyifm2jiqxaPSbmWC4ETNy38355Qp3g0G7qDo2Qo7F88qEPrb0835 >									
	//        <  u =="0.000000000000000001" : ] 000000058695111.883866400000000000 ; 000000073183801.956631900000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000598FC76FAB6C >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_6_____Irkutskenergo_Ust_Ilimsk_org_spe_20220321 >									
	//        < qA853yddUlk8ALvAS78d15ilxVkjWl4wV53RKb81428LL7ndhag9a1HZ2ccq3QYu >									
	//        <  u =="0.000000000000000001" : ] 000000073183801.956631900000000000 ; 000000086063518.377191000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006FAB6C835290 >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_7_____Oui_Energo_Limited_s_China_Yangtze_Power_Company_20220321 >									
	//        < V5xYuQg329y3e71mI2fY6rFBWeUs6o229mq7Lw45Wsav2fcBEnu3zqN5aKD66D6V >									
	//        <  u =="0.000000000000000001" : ] 000000086063518.377191000000000000 ; 000000100498919.928642000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000835290995964 >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_8_____China_Yangtze_Power_Company_limited_20220321 >									
	//        < b8ya6w4ODy4scNtR10NG7AJuVr02d7Ph1C55hCgp1u42ElNHoNyehbi0QSUeEoX7 >									
	//        <  u =="0.000000000000000001" : ] 000000100498919.928642000000000000 ; 000000115342118.378487000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000995964AFFF84 >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_9_____Three_Gorges_Electric_Power_Company_Limited_20220321 >									
	//        < y7z7WZYSfN27B83K2czI9jj4s8WcRyysF40MFG4Rxf49g11iSi7MeRhj7EHvmSS6 >									
	//        <  u =="0.000000000000000001" : ] 000000115342118.378487000000000000 ; 000000129777732.598005000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AFFF84C6066D >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_10_____Beijing_Yangtze_Power_Innovative_Investment_Management_Company_Limited_20220321 >									
	//        < 1mG6Uwv9I8Rat2XbriDnkxwrYWR4901l6xzO7i3txm582Xvmq2O5YJCq6x45c9rJ >									
	//        <  u =="0.000000000000000001" : ] 000000129777732.598005000000000000 ; 000000146859268.387679000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C6066DE016E7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_11_____Three_Gorges_Jinsha_River_Chuanyun_Hydropower_Development_Company_Limited_20220321 >									
	//        < vaRwhJ9F1kfMz2OA4T07qXa8MZ5eqy9khb1Po52520Blk38mipO1ZWbM5e650Q1S >									
	//        <  u =="0.000000000000000001" : ] 000000146859268.387679000000000000 ; 000000160616605.533210000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E016E7F514DD >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_12_____Changdian_Capital_Holding_Company_Limited_20220321 >									
	//        < 1NCzV6zO20W3COW1KUXStp24x220A1Q50EKKcr428Tal71TcTv8ioQ3337KjfXU2 >									
	//        <  u =="0.000000000000000001" : ] 000000160616605.533210000000000000 ; 000000177250853.914666000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F514DD10E769D >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_13_____Eurosibenergo_OJSC_20220321 >									
	//        < 9Z01U7up543N3E303atMNM7185lk6DOE4QkNC6pyxudbt7Mic3hOrOOq0br66780 >									
	//        <  u =="0.000000000000000001" : ] 000000177250853.914666000000000000 ; 000000191557392.920394000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010E769D1244B1B >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_14_____Baikalenergo_JSC_20220321 >									
	//        < 78CBmqJ9L0HmW2lKv9ZgS235Y3Y3LqhTWr8kk2c4274KBk6JgJGcCLmCzc4hled0 >									
	//        <  u =="0.000000000000000001" : ] 000000191557392.920394000000000000 ; 000000206462008.762096000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001244B1B13B0939 >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_15_____Sayanogorsk_Teploseti_20220321 >									
	//        < 7lmPVawpdPDwjsJmz0q2bUH55wjxN9X6V52F91rF3Ljzm6OERTx6hRkBPN3Gjk0z >									
	//        <  u =="0.000000000000000001" : ] 000000206462008.762096000000000000 ; 000000219415957.860617000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013B093914ECD5C >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_16_____China_Yangtze_Power_International_Hong_Kong_Company_Limited_20220321 >									
	//        < 6JBBmNrvoAidY69KhCP6h2Z4e23E53ov4T310COUy1TpZwWhFUtuuA2km9ju8m25 >									
	//        <  u =="0.000000000000000001" : ] 000000219415957.860617000000000000 ; 000000235045971.965548000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014ECD5C166A6D5 >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_17_____Fujian_Electric_Distribution_Sale_COmpany_Limited_20220321 >									
	//        < 5gyALP61FqVo3kZ26sk8544dzsK28HsSBo0f4iau2d3QTL2JdMDgBe98f066J27r >									
	//        <  u =="0.000000000000000001" : ] 000000235045971.965548000000000000 ; 000000247533658.336166000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000166A6D5179B4D6 >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_18_____Bohai_Ferry_Group_20220321 >									
	//        < 06Vf8px6y7f427Dw9iJg38W2YT4rc13Hna1kvLKzJa81UriN7JSgjBnvuKU2UUGw >									
	//        <  u =="0.000000000000000001" : ] 000000247533658.336166000000000000 ; 000000263081382.423645000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000179B4D61916E2A >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_19_____Eurosibenergo_OJSC_20220321 >									
	//        < DAKP1s9RrPHxDeAXL7lZuXyCZA1L4wVdg4sQD481c74vdu2P88azdHM90hMKd0Z2 >									
	//        <  u =="0.000000000000000001" : ] 000000263081382.423645000000000000 ; 000000279417885.783541000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001916E2A1AA5B9D >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_20_____Krasnoyarskaya_HPP_20220321 >									
	//        < o57t055k5mtfcT3c83dV1AX3eDCseud941I5rkLxgfCu6BqPbbu3ODamDx1zY1Mk >									
	//        <  u =="0.000000000000000001" : ] 000000279417885.783541000000000000 ; 000000295806732.726728000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AA5B9D1C35D81 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_21_____ERA_Group_OJSC_20220321 >									
	//        < 2SB2MwNtYkrcWKyTIc54qVtvl6aQ78gbnEz9V8e4L7E9eejmTL71gGQQm92uDABs >									
	//        <  u =="0.000000000000000001" : ] 000000295806732.726728000000000000 ; 000000311217258.931558000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C35D811DAE13E >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_22_____Russky_Kremny_LLC_20220321 >									
	//        < 5801BlPh6xR3YkdKXgv342K5fV2Ni2Z4Ml2F8a8yMm496Tn4ma7imVZT990991Ug >									
	//        <  u =="0.000000000000000001" : ] 000000311217258.931558000000000000 ; 000000328884934.697418000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DAE13E1F5D6AD >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_23_____Avtozavodskaya_org_spe_20220321 >									
	//        < 3vjZnWE63L0p8q63i1jW7h8766x3M3YCo8t0dHC3pVvKWgCBthVZl11JD5K0bl6o >									
	//        <  u =="0.000000000000000001" : ] 000000328884934.697418000000000000 ; 000000346582534.906910000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F5D6AD210D7CD >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_24_____Irkutsk_Electric_Grid_Company_20220321 >									
	//        < 3bB17D3xdRUZ238Uz4mz70BVE2zlW5D47eB7w9rn90aSD1cq3WOS2890TO3Z1OJ0 >									
	//        <  u =="0.000000000000000001" : ] 000000346582534.906910000000000000 ; 000000359198286.827691000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000210D7CD22417D5 >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_25_____Eurosibenergo_OJSC_20220321 >									
	//        < mkvaN8825uwKEGa6itOt4e28O7XHES0B45Z0upIWuurfF58Xzm4C4B8X144rOl70 >									
	//        <  u =="0.000000000000000001" : ] 000000359198286.827691000000000000 ; 000000374283459.694493000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022417D523B1C7A >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_26_____Eurosibenergo_LLC_distributed_generation_20220321 >									
	//        < uo5E6VX9Oou0Ylm43N4pv8UKMKuJuG948Mn2dru6D26RuV3Dp9e9CTZ866JgQUn9 >									
	//        <  u =="0.000000000000000001" : ] 000000374283459.694493000000000000 ; 000000386553440.093710000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023B1C7A24DD570 >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_27_____Generatsiya_OOO_20220321 >									
	//        < 8AulUBc6d4PhM61t5W9Y2zRF0jA1G9urO5RFWf1m1o8K4LtNQ7F0fnXy4A034X3h >									
	//        <  u =="0.000000000000000001" : ] 000000386553440.093710000000000000 ; 000000401619289.865238000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024DD570264D289 >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_28_____Eurosibenergo_LLC_distributed_gen_NIZHEGORODSKIY_20220321 >									
	//        < b4I8Maslo4C6Dd7yLnWPGF30EfE8Uj2PcBq93u1Jo38M3QHp5116t7JbT2aG2eTu >									
	//        <  u =="0.000000000000000001" : ] 000000401619289.865238000000000000 ; 000000415088296.142031000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000264D2892795FDE >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_29_____Angara_Yenisei_org_spe_20220321 >									
	//        < wT6kf6CB9A36sMw69D1U53Z9N5DVZrleGzTM1jN9T166629j1j85aE83704AM89G >									
	//        <  u =="0.000000000000000001" : ] 000000415088296.142031000000000000 ; 000000430986878.067614000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002795FDE291A240 >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_30_____Yuzhno_Yeniseisk_org_spe_20220321 >									
	//        < 1ki7U1Isi6d18L16kUzDac1BUqYCp731uSI7gDJ26N7O0N59j9zXw0VzX5oFgZyg >									
	//        <  u =="0.000000000000000001" : ] 000000430986878.067614000000000000 ; 000000448099795.716108000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000291A2402ABBEFC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_31_____Teploseti_LLC_20220321 >									
	//        < BrX0sQBcRmFhsH89qA3XnJ6HE6T1p3lS4ksN5vQQ042o2969aLme7HU9n6NwJBbW >									
	//        <  u =="0.000000000000000001" : ] 000000448099795.716108000000000000 ; 000000463079494.690487000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002ABBEFC2C29A6D >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_32_____Eurosibenergo_Engineering_LLC_20220321 >									
	//        < Lt8GLz71J90fYk0RJDmskCU5Yz619gH5mEP15822vs318469gizeVC2U49zZ2Ptk >									
	//        <  u =="0.000000000000000001" : ] 000000463079494.690487000000000000 ; 000000479751711.696986000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C29A6D2DC0B03 >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_33_____EurosibPower_Engineering_20220321 >									
	//        < ThxbWz9HkVBd5rjX1wpQsimS06dYzfHhCDo01z65J036JXreDUHKMN8X909Nxg5A >									
	//        <  u =="0.000000000000000001" : ] 000000479751711.696986000000000000 ; 000000494158229.361846000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DC0B032F2068F >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_34_____Eurosibenergo_hydrogeneration_LLC_20220321 >									
	//        < pyHyK92M401zZdCSfxx0Hi1E8f7Jj2oPzDKLk40Mjc1w57EE22u2b8c797D3pbB6 >									
	//        <  u =="0.000000000000000001" : ] 000000494158229.361846000000000000 ; 000000507581908.388285000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F2068F306822F >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_35_____Mostootryad_org_spe_20220321 >									
	//        < 445gRD40buY2171mUin049QbbVAEsBozbNW7NqdoVWNn5gJ1VPsEZb0X2N6ry837 >									
	//        <  u =="0.000000000000000001" : ] 000000507581908.388285000000000000 ; 000000522127437.653289000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000306822F31CB408 >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_36_____Irkutskenergoremont_CJSC_20220321 >									
	//        < F4dmw6LneLly217exrnqlIwaDwtKZ7f91i79ON6U45hk13u7o30YST90R8F5d409 >									
	//        <  u =="0.000000000000000001" : ] 000000522127437.653289000000000000 ; 000000538724992.140041000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031CB4083360773 >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_37_____Irkutsk_Energy_Retail_20220321 >									
	//        < 1CZ4IAS5OZHNL5yq4ePG7r7Emyql0KArRw7CM2c9UiV328G7h10zxZ99GK0VoW2X >									
	//        <  u =="0.000000000000000001" : ] 000000538724992.140041000000000000 ; 000000551156017.568457000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003360773348FF52 >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_38_____Iirkutskenergo_PCI_Irkutsk_20220321 >									
	//        < 86L7hfd4W5LC91X48Dv77a1YWW9L0Ud2b6wa9885onmLAmy31e8TnJewsa5SpE6p >									
	//        <  u =="0.000000000000000001" : ] 000000551156017.568457000000000000 ; 000000566404518.412285000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000348FF5236043C4 >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_39_____Iirkutskenergo_Irkutsk_org_spe_20220321 >									
	//        < E2Ro2O9km7SbzKVb3d4N9t4QrCc7q7MOj2uzrPdL6Ls7J6qlrX2t6lL5gtja7N3t >									
	//        <  u =="0.000000000000000001" : ] 000000566404518.412285000000000000 ; 000000581565235.348535000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036043C437765EC >									
	//     < EUROSIBENERGO_PFXXI_I_metadata_line_40_____Monchegorskaya_org_spe_20220321 >									
	//        < 116rNY8OCG6mzWWkXt2xWolAcJM3BkG9Jt076Q6wfR8wcn40714kTFC1u5ij57PY >									
	//        <  u =="0.000000000000000001" : ] 000000581565235.348535000000000000 ; 000000597902679.176595000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037765EC39053BC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}