pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXVI_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXVI_I_883		"	;
		string	public		symbol =	"	RUSS_PFXVI_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		601718865595943000000000000					;	
										
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
	//     < RUSS_PFXVI_I_metadata_line_1_____KYZYL_GOLD_20211101 >									
	//        < lhwuaLHd06uI2f8278h1BIQ5e3039953V3DmXkiWP612ZSy0h8Gm0zAAh3776939 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000017275151.685507300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001A5C1B >									
	//     < RUSS_PFXVI_I_metadata_line_2_____SEREBRO_MAGADANA_20211101 >									
	//        < 822zOa20x1h0Hp1uUtIX7XV9C2jLQ3NSqFiCpsk2ta0e76ec660OV57SXS5Xi0Bx >									
	//        <  u =="0.000000000000000001" : ] 000000017275151.685507300000000000 ; 000000033014214.652327800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001A5C1B32602D >									
	//     < RUSS_PFXVI_I_metadata_line_3_____OMOLON_GOLD_MINING_CO_20211101 >									
	//        < 00pDkQAqWhchFQ9MM9JcJt1nIa842QODPSEptsVG89Y886EMiWDJ5pB74Eb0Y2A2 >									
	//        <  u =="0.000000000000000001" : ] 000000033014214.652327800000000000 ; 000000049266590.599018200000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000032602D4B2CC3 >									
	//     < RUSS_PFXVI_I_metadata_line_4_____AMUR_CHEMICAL_METALL_PLANT_20211101 >									
	//        < 99eg4EK4kxu85aD94YPp3bTf0TArmbb6Bj8KXDwGH5xufc51A02O1c0Zm59skI1Z >									
	//        <  u =="0.000000000000000001" : ] 000000049266590.599018200000000000 ; 000000063618150.754077000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004B2CC36112D7 >									
	//     < RUSS_PFXVI_I_metadata_line_5_____AMUR_CHEMICAL_METALL_PLANT_ORG_20211101 >									
	//        < x9T6GHWdOzqQ390nanu01jQXZ1gE9OoHA9u4mIcRfC2hx3216d1Rrpf644o6kesP >									
	//        <  u =="0.000000000000000001" : ] 000000063618150.754077000000000000 ; 000000077943703.182237900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006112D776EEC2 >									
	//     < RUSS_PFXVI_I_metadata_line_6_____KAPAN_MINING_PROCESS_CO_20211101 >									
	//        < DDYBDT1A3373wF2688Bf3u6Xg0VoLWXTPOKKhVHSu64w2tWKypg8EU8y13yeNk5I >									
	//        <  u =="0.000000000000000001" : ] 000000077943703.182237900000000000 ; 000000094579238.269087800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000076EEC2905104 >									
	//     < RUSS_PFXVI_I_metadata_line_7_____VARVARINSKOYE_20211101 >									
	//        < 3XSRia3wisomFfXJDyG0Ao3ZhMbIKc8wS192i96k03W4AEgX4x8E17LSphVp466u >									
	//        <  u =="0.000000000000000001" : ] 000000094579238.269087800000000000 ; 000000108862863.528485000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000905104A61C8E >									
	//     < RUSS_PFXVI_I_metadata_line_8_____KAPAN_MPC_20211101 >									
	//        < 0U98Gb4M4ImmnSUR549uf5x2rDEuPy5uUtW1Iq86444538xwRBirIFaEnsWH3Sy9 >									
	//        <  u =="0.000000000000000001" : ] 000000108862863.528485000000000000 ; 000000125338324.363156000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A61C8EBF4048 >									
	//     < RUSS_PFXVI_I_metadata_line_9_____ORION_MINERALS_LLP_20211101 >									
	//        < 9dL90OJ1CTK4C2xXkX7E9U2h232M6NFC7QwOD6G592QS66M99Lf1u46Luc6elQd7 >									
	//        <  u =="0.000000000000000001" : ] 000000125338324.363156000000000000 ; 000000138368603.481528000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BF4048D3223C >									
	//     < RUSS_PFXVI_I_metadata_line_10_____IMITZOLOTO_LIMITED_20211101 >									
	//        < kvO9UOJVPKZ11oPOvR353QFS0GzX6828uk6BUCTQfwWJKD3g2GFfeCGwPgF6WY3Q >									
	//        <  u =="0.000000000000000001" : ] 000000138368603.481528000000000000 ; 000000153700229.474332000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D3223CEA8727 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVI_I_metadata_line_11_____ZAO_ZOLOTO_SEVERNOGO_URALA_20211101 >									
	//        < H5KeCZIybuRY77gl7347QSS0aeYV8trIc10109J6A09O7Zk1MoFAc24EyE3DbGkD >									
	//        <  u =="0.000000000000000001" : ] 000000153700229.474332000000000000 ; 000000167263039.180982000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000EA8727FF3920 >									
	//     < RUSS_PFXVI_I_metadata_line_12_____OKHOTSKAYA_GGC_20211101 >									
	//        < QloD5nHpVrv6agp897MmP8Y1REDJ5206wwr7t8E38425oQ36Lz0e9i2s8Zwef8im >									
	//        <  u =="0.000000000000000001" : ] 000000167263039.180982000000000000 ; 000000182697409.443974000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FF3920116C62D >									
	//     < RUSS_PFXVI_I_metadata_line_13_____INTER_GOLD_CAPITAL_20211101 >									
	//        < D6czw3SL6sPSmZ1x7cENeS3tRF9At57Fcrj12wMf1n24py3G33o4eE86iw3yrIX9 >									
	//        <  u =="0.000000000000000001" : ] 000000182697409.443974000000000000 ; 000000197467930.446776000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000116C62D12D4FE9 >									
	//     < RUSS_PFXVI_I_metadata_line_14_____POLYMETAL_AURUM_20211101 >									
	//        < 6sB02HcD08GuEcfgTc2Lp7y50mRTIsP8HTfurDqF458Ols5qKe1692q25Lulpoly >									
	//        <  u =="0.000000000000000001" : ] 000000197467930.446776000000000000 ; 000000210952386.279435000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012D4FE9141E347 >									
	//     < RUSS_PFXVI_I_metadata_line_15_____KIRANKAN_OOO_20211101 >									
	//        < Bp5Aui8lB47gaoz8X29Q0ur498Dwr9t7SJZw7af36OD1Q5P99I8putCu4k9t98C6 >									
	//        <  u =="0.000000000000000001" : ] 000000210952386.279435000000000000 ; 000000225558286.390600000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000141E3471582CB5 >									
	//     < RUSS_PFXVI_I_metadata_line_16_____OKHOTSK_MINING_GEOLOGICAL_CO_20211101 >									
	//        < 27qZ46F8oNhB14KOHN6z6oI1fU7BbUTp1P8a4nNG9BWPb31007Fr30d6bRg2rb77 >									
	//        <  u =="0.000000000000000001" : ] 000000225558286.390600000000000000 ; 000000240304109.967268000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001582CB516EACCB >									
	//     < RUSS_PFXVI_I_metadata_line_17_____AYAX_PROSPECTORS_ARTEL_CO_20211101 >									
	//        < MB9Q5GX06IcKQUB0GHc7QODAuEa99B3Wfoibml4U57c0Rl344Jk3KzgK5n3qLb7m >									
	//        <  u =="0.000000000000000001" : ] 000000240304109.967268000000000000 ; 000000254600075.128677000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016EACCB1847D28 >									
	//     < RUSS_PFXVI_I_metadata_line_18_____POLYMETAL_INDUSTRIA_20211101 >									
	//        < 149bvi1f323Cb2tg28q4JABB85fof6E1s4rR6D3hO94sWqj388s4Q66G5NTXQgfW >									
	//        <  u =="0.000000000000000001" : ] 000000254600075.128677000000000000 ; 000000270876620.479893000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001847D2819D532E >									
	//     < RUSS_PFXVI_I_metadata_line_19_____ASHANTI_POLYMET_STRATE_ALL_MANCO_20211101 >									
	//        < 4H39M7yhE6Zumo7wAWffLkwYzBmcRP3S6QIK7Y0e878e32tBe8C0FMeVYoeZmznq >									
	//        <  u =="0.000000000000000001" : ] 000000270876620.479893000000000000 ; 000000284332899.057164000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019D532E1B1DB8A >									
	//     < RUSS_PFXVI_I_metadata_line_20_____RUDNIK_AVLAYAKAN_20211101 >									
	//        < 563pdfM0u8E005956jTkWwLtyf054VsYZKtZFUxHOc6BjXecm196mvw4tTCSjVrD >									
	//        <  u =="0.000000000000000001" : ] 000000284332899.057164000000000000 ; 000000298008668.665221000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B1DB8A1C6B9A3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVI_I_metadata_line_21_____OLYMP_OOO_20211101 >									
	//        < 09C87liyiMz8L3p10GUsSv90kM2ATX1eqKZH97WSLSQz8Jj7vcTTvlIDhZHZV0jY >									
	//        <  u =="0.000000000000000001" : ] 000000298008668.665221000000000000 ; 000000314875823.703410000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C6B9A31E0765E >									
	//     < RUSS_PFXVI_I_metadata_line_22_____SEMCHENSKOYE_ZOLOTO_20211101 >									
	//        < f64Uiu8ztjavJvszRHmj6rR2pvk7fhi2HEFW823Q2uB1Rd9d7acSaOe8WIv0Dcfz >									
	//        <  u =="0.000000000000000001" : ] 000000314875823.703410000000000000 ; 000000328355937.284932000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E0765E1F5080A >									
	//     < RUSS_PFXVI_I_metadata_line_23_____MAYSKOYE_20211101 >									
	//        < 20EtY2VQ8xc7n0oLA7ti2CLv9HmJl41dYz2RtAdwbERi0o7kcV8RT6i3w0t24W8X >									
	//        <  u =="0.000000000000000001" : ] 000000328355937.284932000000000000 ; 000000344874196.315213000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F5080A20E3C7C >									
	//     < RUSS_PFXVI_I_metadata_line_24_____FIANO_INVESTMENTS_20211101 >									
	//        < 1TQq1KhQ60JHkuT6Z4qoiw40nMl6Dk8Iu67T689R7q7b8xUV03N356JxL5m840qJ >									
	//        <  u =="0.000000000000000001" : ] 000000344874196.315213000000000000 ; 000000359566022.872497000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020E3C7C224A77A >									
	//     < RUSS_PFXVI_I_metadata_line_25_____URAL_POLYMETAL_20211101 >									
	//        < PI3mU92d4EvYHj707EXYaFEzr5O04RAhIwl8CGoj4zk90260Qc3YzAQJO9Dfjsll >									
	//        <  u =="0.000000000000000001" : ] 000000359566022.872497000000000000 ; 000000376215933.135652000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000224A77A23E0F59 >									
	//     < RUSS_PFXVI_I_metadata_line_26_____POLYMETAL_PDRUS_LLC_20211101 >									
	//        < JO8C96gojWk1bOdBweHIuwe02HU0O96FiY9ai6BtqAlH81ZzF1145cQ729xzXdtL >									
	//        <  u =="0.000000000000000001" : ] 000000376215933.135652000000000000 ; 000000391693253.510770000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023E0F59255AD2D >									
	//     < RUSS_PFXVI_I_metadata_line_27_____VOSTOCHNY_BASIS_20211101 >									
	//        < 7amWjlGl4uadmiUx3aqprB0l1nXYgYz238m2Re3ox3aBF1b6RBePK78JrYGTRmj2 >									
	//        <  u =="0.000000000000000001" : ] 000000391693253.510770000000000000 ; 000000408955674.051511000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000255AD2D270044F >									
	//     < RUSS_PFXVI_I_metadata_line_28_____SAUM_MINING_CO_20211101 >									
	//        < 1Hm2qcBBAI3f90q28tIbyGAk318KFacMZrTN3LQExC0ZOrgBlZUprZhsOE2M5QEg >									
	//        <  u =="0.000000000000000001" : ] 000000408955674.051511000000000000 ; 000000424033267.962039000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000270044F28705FF >									
	//     < RUSS_PFXVI_I_metadata_line_29_____ALBAZINO_RESOURCES_20211101 >									
	//        < h774nrpmG2H68b15GwfmPrCKb896LeqQw9Lh5Cyk8J47qZk9643768mWsvGJL7E6 >									
	//        <  u =="0.000000000000000001" : ] 000000424033267.962039000000000000 ; 000000437380812.724830000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028705FF29B63E1 >									
	//     < RUSS_PFXVI_I_metadata_line_30_____POLYMETAL_INDUSTRIYA_20211101 >									
	//        < oD2XCBMblBcKOgCYa8Df8x1dNG648u226f65MWK10fv6Db5Taxg6mi7fEvB6xIhX >									
	//        <  u =="0.000000000000000001" : ] 000000437380812.724830000000000000 ; 000000450891474.004395000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029B63E12B0017B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVI_I_metadata_line_31_____AS_APK_HOLDINGS_LIMITED_20211101 >									
	//        < J8H76BJrWbl69wbMcuNH23zWvh5X9pb8BIJ012PMJP71Xs586Cw2CFG8p7BO4XoM >									
	//        <  u =="0.000000000000000001" : ] 000000450891474.004395000000000000 ; 000000467755125.680552000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B0017B2C9BCD9 >									
	//     < RUSS_PFXVI_I_metadata_line_32_____POLAR_SILVER_RESOURCES_20211101 >									
	//        < 3xzPQQkE0iyV2dYvwAlI3FBDsKkuvUCt05z3mur8z04bzz2eQcD52U0u56Hyp5mo >									
	//        <  u =="0.000000000000000001" : ] 000000467755125.680552000000000000 ; 000000483684835.367231000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C9BCD92E20B64 >									
	//     < RUSS_PFXVI_I_metadata_line_33_____PMTL_HOLDING_LIMITED_20211101 >									
	//        < DSgTv17z2x99Jm9qI56R031tTUCOl9tYv9h8rd95Im2mgdhrJr1yrKaz5epLWg9C >									
	//        <  u =="0.000000000000000001" : ] 000000483684835.367231000000000000 ; 000000500550651.827518000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E20B642FBC799 >									
	//     < RUSS_PFXVI_I_metadata_line_34_____ALBAZINO_RESOURCES_LIMITED_20211101 >									
	//        < yzzM8nr3vlZ4gF45O4YSo02i24fVZ7M67JRQR88r16n5CM94j9n3mUO80Kmq0Rs3 >									
	//        <  u =="0.000000000000000001" : ] 000000500550651.827518000000000000 ; 000000514835667.073618000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FBC79931193AF >									
	//     < RUSS_PFXVI_I_metadata_line_35_____RUDNIK_KVARTSEVYI_20211101 >									
	//        < 4GNy8So78Q6zoJf33pc072S9TELH2Wxe7a2AwQLO1MWn3il5HU8VV054s6s41Wz0 >									
	//        <  u =="0.000000000000000001" : ] 000000514835667.073618000000000000 ; 000000530457479.734098000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031193AF32969F4 >									
	//     < RUSS_PFXVI_I_metadata_line_36_____NEVYANSK_GROUP_20211101 >									
	//        < vMdLJJzZpkW412p9ZXh8FA4Xt1AWCTINPSRQ3y6JvS1J8WY56BrYj5M2tf9M6oKI >									
	//        <  u =="0.000000000000000001" : ] 000000530457479.734098000000000000 ; 000000543530032.656885000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032969F433D5C6B >									
	//     < RUSS_PFXVI_I_metadata_line_37_____AMURSK_HYDROMETALL_PLANT_20211101 >									
	//        < A5N2q9fm4P1Xa3sjDa9Te12HU6ox6Pz9337x3znmFJnDh25nF8W6GH24XnW226HF >									
	//        <  u =="0.000000000000000001" : ] 000000543530032.656885000000000000 ; 000000557330037.062591000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033D5C6B3526B0C >									
	//     < RUSS_PFXVI_I_metadata_line_38_____AMURSK_HYDROMETALL_PLANT_ORG_20211101 >									
	//        < Rxu1VZ4uD2nD824a8dy5cN8P791IF8382g3FnKv17rV8y14RZf1ov86zKOnPsE8A >									
	//        <  u =="0.000000000000000001" : ] 000000557330037.062591000000000000 ; 000000571182511.920873000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003526B0C3678E2B >									
	//     < RUSS_PFXVI_I_metadata_line_39_____OKHOTSKAYA_MINING_GEO_COMPANY_20211101 >									
	//        < afum541TctdtnqX88B3W3hH3SDg5K048c6rKDKXS36i1qmbL1AmY2GY3qyEh075E >									
	//        <  u =="0.000000000000000001" : ] 000000571182511.920873000000000000 ; 000000585529587.965165000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003678E2B37D727F >									
	//     < RUSS_PFXVI_I_metadata_line_40_____DUNDEE_PRECIOUS_METALS_KAPAN_20211101 >									
	//        < mzwQA974Di1Q6Q9ef0HA036n9o61B0uesF7nl5B8P442kb2G4lhF3Aix2f39Sp7g >									
	//        <  u =="0.000000000000000001" : ] 000000585529587.965165000000000000 ; 000000601718865.595943000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037D727F396266F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}