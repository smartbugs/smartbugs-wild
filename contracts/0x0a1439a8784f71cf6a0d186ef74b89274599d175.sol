pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXII_II_883		"	;
		string	public		symbol =	"	RUSS_PFXXXII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		805054958985656000000000000					;	
										
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
	//     < RUSS_PFXXXII_II_metadata_line_1_____SOLLERS_20231101 >									
	//        < 3YU2n3m9y55ay2o763436Q247bior1a000B37S5GsDr059s7vrdFshyDZ00461vQ >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000024449551.666655900000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000254E9B >									
	//     < RUSS_PFXXXII_II_metadata_line_2_____UAZ_20231101 >									
	//        < 16Jql59s7im9EWfUI9k3y96ZPOIgfcfyqD2Q266fICh4NiwQ5011sDvR51z1CUuR >									
	//        <  u =="0.000000000000000001" : ] 000000024449551.666655900000000000 ; 000000049283318.010454700000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000254E9B4B334C >									
	//     < RUSS_PFXXXII_II_metadata_line_3_____FORD_SOLLERS_20231101 >									
	//        < 638D8x8P314Gucrqqq5zQaxaB5IEnFf25tpIll0LX8rQj5m123GPBBNVnRkOA1qo >									
	//        <  u =="0.000000000000000001" : ] 000000049283318.010454700000000000 ; 000000071273602.885158800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004B334C6CC140 >									
	//     < RUSS_PFXXXII_II_metadata_line_4_____URALAZ_20231101 >									
	//        < 3n42t1qEumQ13Qh125kSND52FWY25OPBr72lCV84z1eE6p7tqV2Lp65362NBql0x >									
	//        <  u =="0.000000000000000001" : ] 000000071273602.885158800000000000 ; 000000091547116.119433000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006CC1408BB098 >									
	//     < RUSS_PFXXXII_II_metadata_line_5_____ZAVOLZHYE_ENGINE_FACTORY_20231101 >									
	//        < B70NBL8g8mDKLFS12xWA3AhfCd3HCW73O9AJ5Ov8cO12jL94NZ7b0r62i9JdnN11 >									
	//        <  u =="0.000000000000000001" : ] 000000091547116.119433000000000000 ; 000000107248562.066637000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008BB098A3A5F8 >									
	//     < RUSS_PFXXXII_II_metadata_line_6_____ZMA_20231101 >									
	//        < Yf82A9A66VUxkb02uz3fI7T38BCY0A2JAP0gF3I59y03tqLgr2pZ3awffB44jNq3 >									
	//        <  u =="0.000000000000000001" : ] 000000107248562.066637000000000000 ; 000000130768765.329529000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A3A5F8C7898D >									
	//     < RUSS_PFXXXII_II_metadata_line_7_____MAZDA_MOTORS_MANUFACT_RUS_20231101 >									
	//        < Xwh47W1xYnD5Vp78w16wwVjxnjcu6GiE24mNDDu0j5LYbbtQ76Pk5dnbVk8mv8Jc >									
	//        <  u =="0.000000000000000001" : ] 000000130768765.329529000000000000 ; 000000149716118.999891000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C7898DE472DC >									
	//     < RUSS_PFXXXII_II_metadata_line_8_____REMSERVIS_20231101 >									
	//        < 5Iq6v5yC7B0G82NNy7jA822m75T12ssrluihu0UxwTq37BFA8U5KI2G8W52itG36 >									
	//        <  u =="0.000000000000000001" : ] 000000149716118.999891000000000000 ; 000000173299001.497678000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E472DC1086EEC >									
	//     < RUSS_PFXXXII_II_metadata_line_9_____MAZDA_SOLLERS_JV_20231101 >									
	//        < nYN30VlCAj3MAKCaAyoo68mujB4aAwqT6VeVNj1ddvfE19vF8a2rnwPJr96roHJW >									
	//        <  u =="0.000000000000000001" : ] 000000173299001.497678000000000000 ; 000000198102443.397413000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001086EEC12E47C4 >									
	//     < RUSS_PFXXXII_II_metadata_line_10_____SEVERSTALAVTO_ZAO_20231101 >									
	//        < 00UD7CNg6xt4Pd63bAD926TJ49ic9g7q7s7FzX9yF6C10560VY7G8uLkYsH3kSXe >									
	//        <  u =="0.000000000000000001" : ] 000000198102443.397413000000000000 ; 000000218982324.731038000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012E47C414E23F8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXII_II_metadata_line_11_____SEVERSTALAUTO_KAMA_20231101 >									
	//        < o6sdnxZJ65KWKAg2zgyqs5Y7lbeYUvx5c3g8GiAZkHA9btX7J1w4B6w9zt7DvD78 >									
	//        <  u =="0.000000000000000001" : ] 000000218982324.731038000000000000 ; 000000235553127.186240000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014E23F81676CF1 >									
	//     < RUSS_PFXXXII_II_metadata_line_12_____KAMA_ORG_20231101 >									
	//        < 56akqf2yM3w9ss470A8c0bc9IN8xE42oy311g9MyB6D1X955Fn40lzF3337KjnPS >									
	//        <  u =="0.000000000000000001" : ] 000000235553127.186240000000000000 ; 000000260036390.019909000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001676CF118CC8B7 >									
	//     < RUSS_PFXXXII_II_metadata_line_13_____DALNIY_VOSTOK_20231101 >									
	//        < qenDFc2DuEFkTmzOd19s19OzfOlI22KHlfZJ53oJmKQjTjcg4W3hJd1P6Nfcy3Qy >									
	//        <  u =="0.000000000000000001" : ] 000000260036390.019909000000000000 ; 000000283613247.239266000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018CC8B71B0C26D >									
	//     < RUSS_PFXXXII_II_metadata_line_14_____DALNIY_ORG_20231101 >									
	//        < 0f7N1X1wNbStt53tj0c370RZ98d1RD9NWkLU0u925rc7fTRIpBa8GItG6ALmr7i3 >									
	//        <  u =="0.000000000000000001" : ] 000000283613247.239266000000000000 ; 000000303221608.518033000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B0C26D1CEADF1 >									
	//     < RUSS_PFXXXII_II_metadata_line_15_____SPECIAL_VEHICLES_OOO_20231101 >									
	//        < YzPns87839fzrkNj4e5un35TL9rU5RRImiUaA79w7PXGIpe03U3QydxizPz7d9oE >									
	//        <  u =="0.000000000000000001" : ] 000000303221608.518033000000000000 ; 000000318678427.843762000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CEADF11E643C3 >									
	//     < RUSS_PFXXXII_II_metadata_line_16_____MAZDDA_SOLLERS_MANUFACT_RUS_20231101 >									
	//        < tn1R7youI3DAW71LCKAwIgnTORcPVzM7n2POb9Ih8l4ir55OZcImtn2W7P8840Rx >									
	//        <  u =="0.000000000000000001" : ] 000000318678427.843762000000000000 ; 000000336855194.430389000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E643C3202000F >									
	//     < RUSS_PFXXXII_II_metadata_line_17_____TURIN_AUTO_OOO_20231101 >									
	//        < bqmQ3K9ulVb9DNN1YSo6hcg3jo9rO6aN6if64J89yT6hWm0Sg0r3wzTJA8QquFJF >									
	//        <  u =="0.000000000000000001" : ] 000000336855194.430389000000000000 ; 000000353176000.327161000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000202000F21AE760 >									
	//     < RUSS_PFXXXII_II_metadata_line_18_____ZMZ_TRANSSERVICE_20231101 >									
	//        < UX53Jp9428098mGKB10Wxi10Og11mo9djunoMHiVSXm4siFsjb84D1x2E28O619w >									
	//        <  u =="0.000000000000000001" : ] 000000353176000.327161000000000000 ; 000000375583481.248401000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021AE76023D184C >									
	//     < RUSS_PFXXXII_II_metadata_line_19_____SAPORT_OOO_20231101 >									
	//        < Jf8DrO58fL7cTiA48YPRaCxUC8W3m294VDcgJAJST8w6K8694kqe6gxy7m4OLu4W >									
	//        <  u =="0.000000000000000001" : ] 000000375583481.248401000000000000 ; 000000398947171.056680000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023D184C260BEBD >									
	//     < RUSS_PFXXXII_II_metadata_line_20_____TRANSPORTNIK_12_20231101 >									
	//        < D3k1LUCnNlMhL58WbqHIUGAqkqwY2r1JdT1jU3IO7DFFduoNvjW8G4y9m6I5cBa1 >									
	//        <  u =="0.000000000000000001" : ] 000000398947171.056680000000000000 ; 000000414772540.716246000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000260BEBD278E486 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXII_II_metadata_line_21_____OOO_UAZ_TEKHINSTRUMENT_20231101 >									
	//        < I2zvGv0hETXwa6vx4rU94f8Nq79pdcwsJl8l0idR9db80Qw167X845Mt4mI7U6wG >									
	//        <  u =="0.000000000000000001" : ] 000000414772540.716246000000000000 ; 000000430886648.409896000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000278E4862917B19 >									
	//     < RUSS_PFXXXII_II_metadata_line_22_____ZAO_KAPITAL_20231101 >									
	//        < i3fS7QV0NM840URn98jx0wsS67547I72YE762xPmj3NdWwZ8Wy62E79Gdrmk2tI6 >									
	//        <  u =="0.000000000000000001" : ] 000000430886648.409896000000000000 ; 000000447914268.910757000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002917B192AB7683 >									
	//     < RUSS_PFXXXII_II_metadata_line_23_____OOO_UAZ_DISTRIBUTION_CENTRE_20231101 >									
	//        < B7vaqXJD01Vk69UMk1868IKHXQ5Mjd12Ir2YhVb0Hf58m14767MoR0Hl6Dk6QMV4 >									
	//        <  u =="0.000000000000000001" : ] 000000447914268.910757000000000000 ; 000000472610018.857414000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AB76832D1254A >									
	//     < RUSS_PFXXXII_II_metadata_line_24_____SHTAMP_20231101 >									
	//        < wisB6ua00F6KSr4bfbPCU3EUQuJu0E1NpGgcC2ZKt4qz2LPy3hwTOPl4AXL3ZpJO >									
	//        <  u =="0.000000000000000001" : ] 000000472610018.857414000000000000 ; 000000492988199.479686000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D1254A2F03D84 >									
	//     < RUSS_PFXXXII_II_metadata_line_25_____SOLLERS_FINANS_20231101 >									
	//        < 9gBlHyATuv44q58jDAFNHy2RC03frcvs9NcGp3kZk2aEsnbJdbfkHWgkuBpJvZ0G >									
	//        <  u =="0.000000000000000001" : ] 000000492988199.479686000000000000 ; 000000514060316.321885000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F03D8431064D0 >									
	//     < RUSS_PFXXXII_II_metadata_line_26_____SOLLERS_FINANCE_LLC_20231101 >									
	//        < P227CQ9cgwcl07907i0ytj7BzKM4664lpI18ar8TiVLO2A8cK1Xvs5EZ9P5tEl4f >									
	//        <  u =="0.000000000000000001" : ] 000000514060316.321885000000000000 ; 000000530068273.529148000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031064D0328D1EB >									
	//     < RUSS_PFXXXII_II_metadata_line_27_____TORGOVIY_DOM_20231101 >									
	//        < S4gI93RRjattW9xHi6B0Sf8r7pS2rijh5Uqt99t7V71Dxfw2h2T89cU6dE5c0qwW >									
	//        <  u =="0.000000000000000001" : ] 000000530068273.529148000000000000 ; 000000552961248.166516000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000328D1EB34BC07D >									
	//     < RUSS_PFXXXII_II_metadata_line_28_____SOLLERS_BUSSAN_20231101 >									
	//        < oM5rmCto9SgVbe10x9y0sB8b1z597ARs9eW64CK0z44H79tp9hzLE8220264b5oe >									
	//        <  u =="0.000000000000000001" : ] 000000552961248.166516000000000000 ; 000000577615487.795056000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034BC07D3715F0D >									
	//     < RUSS_PFXXXII_II_metadata_line_29_____SEVERSTALAUTO_ISUZU_20231101 >									
	//        < 0LlvVbOnJJjSRZ4ybwC6T1nb9B87SMz5epZiB26V760q6J90IXc6c15K2SFwFhPu >									
	//        <  u =="0.000000000000000001" : ] 000000577615487.795056000000000000 ; 000000593290142.386744000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003715F0D38949F6 >									
	//     < RUSS_PFXXXII_II_metadata_line_30_____SEVERSTALAUTO_ELABUGA_20231101 >									
	//        < 2GRk89OG498Njnuu0A2MwHO97VqyPMhG4Y1NpzAuw7SpX430wheqT37U39LdCx2d >									
	//        <  u =="0.000000000000000001" : ] 000000593290142.386744000000000000 ; 000000612727857.297763000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038949F63A6F2D2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXII_II_metadata_line_31_____SOLLERS_DEVELOPMENT_20231101 >									
	//        < qO4uLgQFLG05ZfB357GF2lU2LxKe871V802ezJb0z45E6xJoQ1O6L3t53xReld40 >									
	//        <  u =="0.000000000000000001" : ] 000000612727857.297763000000000000 ; 000000628881091.390766000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A6F2D23BF98AD >									
	//     < RUSS_PFXXXII_II_metadata_line_32_____TRADE_HOUSE_SOLLERS_OOO_20231101 >									
	//        < 1by7r3O7Fb994jJiVj5928G28yXvTTTuDNu1v7IIAU6VrBm10VOwjSP8k7KrAHbh >									
	//        <  u =="0.000000000000000001" : ] 000000628881091.390766000000000000 ; 000000646097698.798608000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003BF98AD3D9DDEA >									
	//     < RUSS_PFXXXII_II_metadata_line_33_____SEVERSTALAUTO_ELABUGA_LLC_20231101 >									
	//        < ispLF970q1F7sLKC586qim4xN0Xq70CCpMFeme24tBM44SVaP36lbq23euHb828V >									
	//        <  u =="0.000000000000000001" : ] 000000646097698.798608000000000000 ; 000000662447662.117510000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D9DDEA3F2D09E >									
	//     < RUSS_PFXXXII_II_metadata_line_34_____SOLLERS_PARTNER_20231101 >									
	//        < 8037BGG1sUOLyb73ZJ7KuRH4dJWUVyw4S3bnNeGK9EXW1CxbODmpw7R9ia35Pg2k >									
	//        <  u =="0.000000000000000001" : ] 000000662447662.117510000000000000 ; 000000684476511.909012000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F2D09E4146DA3 >									
	//     < RUSS_PFXXXII_II_metadata_line_35_____ULYANOVSK_CAR_PLANT_20231101 >									
	//        < MRx5O5M5wSkxsx0Q0zBRVnp8CPvHR3VREZu49p83fK2Jx6a4vK75US38Q9ZMxset >									
	//        <  u =="0.000000000000000001" : ] 000000684476511.909012000000000000 ; 000000703881153.864926000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004146DA34320993 >									
	//     < RUSS_PFXXXII_II_metadata_line_36_____FPT_SOLLERS_OOO_20231101 >									
	//        < 0GQsJw7F729G4i6e6LWiYL0P7EgO5FE8rok80Rbm6osLOC50A5ui7aNHNK04NrwO >									
	//        <  u =="0.000000000000000001" : ] 000000703881153.864926000000000000 ; 000000726277021.673872000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000432099345435F6 >									
	//     < RUSS_PFXXXII_II_metadata_line_37_____OOO_SPECINSTRUMENT_20231101 >									
	//        < GtKG490KVt92H90CT8k4XO0265w05X2R5A8Sa7BFE5qnz73nEkXGbnWvj9C8gh6O >									
	//        <  u =="0.000000000000000001" : ] 000000726277021.673872000000000000 ; 000000746266389.725212000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000045435F6472B64F >									
	//     < RUSS_PFXXXII_II_metadata_line_38_____AVTOKOMPO_KOROBKA_PEREDACH_UZLY_TR_20231101 >									
	//        < 538dCZq2Ks1LAzk2L8k4o668RMMS8IR6l2Z9w5oT52H7y3w0f9bhi2b9qQ4RL8p8 >									
	//        <  u =="0.000000000000000001" : ] 000000746266389.725212000000000000 ; 000000762532723.545830000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000472B64F48B8858 >									
	//     < RUSS_PFXXXII_II_metadata_line_39_____KOLOMYAZHSKOM_AUTOCENTRE_OOO_20231101 >									
	//        < Pnt52f6uJ7CzMQ01anj2R9JS629WZ51xBtAs36bE17W40dusDNEsxaoWj9AS608T >									
	//        <  u =="0.000000000000000001" : ] 000000762532723.545830000000000000 ; 000000786185704.629903000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048B88584AF9FCA >									
	//     < RUSS_PFXXXII_II_metadata_line_40_____ROSALIT_20231101 >									
	//        < 43Rsmm5mfXsO5wR8Hee5owsYkltEN4ll8h4EFV75NjYrnthIUt7PrRf8m3qjfBSz >									
	//        <  u =="0.000000000000000001" : ] 000000786185704.629903000000000000 ; 000000805054958.985656000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004AF9FCA4CC6A98 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}