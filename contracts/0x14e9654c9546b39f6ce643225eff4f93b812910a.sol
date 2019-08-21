pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXVI_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXVI_II_883		"	;
		string	public		symbol =	"	RUSS_PFXVI_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		765536332851386000000000000					;	
										
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
	//     < RUSS_PFXVI_II_metadata_line_1_____KYZYL_GOLD_20231101 >									
	//        < Ppj09084TbKtMz1pQPZ6fpq3Gag65DSxhtjVxZtuM45Qa159WtfR09HDFB0PxZNJ >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000020010580.733756100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001E88A2 >									
	//     < RUSS_PFXVI_II_metadata_line_2_____SEREBRO_MAGADANA_20231101 >									
	//        < tV7a32sJ8ZHd76h5GRLr4k6SD2n7Kst41da7Hm16p7Ued2R2YAe68RYVn12eBts4 >									
	//        <  u =="0.000000000000000001" : ] 000000020010580.733756100000000000 ; 000000040062716.133866900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001E88A23D2180 >									
	//     < RUSS_PFXVI_II_metadata_line_3_____OMOLON_GOLD_MINING_CO_20231101 >									
	//        < 5v1B1oEuRgCTcful2g05cZx2MmyZPjkDW7kLiNuI39XJsRMBizHJbvauYc4qKbaQ >									
	//        <  u =="0.000000000000000001" : ] 000000040062716.133866900000000000 ; 000000060311310.355414500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003D21805C071B >									
	//     < RUSS_PFXVI_II_metadata_line_4_____AMUR_CHEMICAL_METALL_PLANT_20231101 >									
	//        < 9S6o3a1BaxXqpLG06MQffQ2oNmTxJluR9qsvlvcW4b7C931C3k90FDueSJm9j58K >									
	//        <  u =="0.000000000000000001" : ] 000000060311310.355414500000000000 ; 000000078993603.156666800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005C071B7888E0 >									
	//     < RUSS_PFXVI_II_metadata_line_5_____AMUR_CHEMICAL_METALL_PLANT_ORG_20231101 >									
	//        < yHH4d90D2b15Vdc7FGK9IBtmPRn97NqQm35HBGo7l673jhs0t2nEq5xrVhzQe8F5 >									
	//        <  u =="0.000000000000000001" : ] 000000078993603.156666800000000000 ; 000000096059486.321301800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007888E092933D >									
	//     < RUSS_PFXVI_II_metadata_line_6_____KAPAN_MINING_PROCESS_CO_20231101 >									
	//        < 2SXg2727xg43ci2qzCV6y378KodUluWyd12mG8Ns3M6eqn82xge8WbTk768xWW8M >									
	//        <  u =="0.000000000000000001" : ] 000000096059486.321301800000000000 ; 000000116976857.812344000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000092933DB27E16 >									
	//     < RUSS_PFXVI_II_metadata_line_7_____VARVARINSKOYE_20231101 >									
	//        < I39thN0gaTVM3zvLsvp8e319p1Zt6JXdW8Oc3yU9Gsbf3LW4lH1t1HsZ68Vo4fih >									
	//        <  u =="0.000000000000000001" : ] 000000116976857.812344000000000000 ; 000000132442769.204929000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B27E16CA1775 >									
	//     < RUSS_PFXVI_II_metadata_line_8_____KAPAN_MPC_20231101 >									
	//        < XFF5C0RfN1ISw80J13nzhCN69yvbp2atMt1tYbUcJs1h9YlioYo068535d55uoku >									
	//        <  u =="0.000000000000000001" : ] 000000132442769.204929000000000000 ; 000000155981736.243818000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CA1775EE025E >									
	//     < RUSS_PFXVI_II_metadata_line_9_____ORION_MINERALS_LLP_20231101 >									
	//        < 4xZWDXeESk06g418kEMkt78bUEfds8AqvtnPgi19M976FchFp8URcTToWDNHQ3eH >									
	//        <  u =="0.000000000000000001" : ] 000000155981736.243818000000000000 ; 000000177852620.631621000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EE025E10F61AE >									
	//     < RUSS_PFXVI_II_metadata_line_10_____IMITZOLOTO_LIMITED_20231101 >									
	//        < q0T5sn12A5hDw45p5e1Hg7Cb9WWGSQuvrPoKiD7Vvfv8li9f2upd69gK10XTRZK4 >									
	//        <  u =="0.000000000000000001" : ] 000000177852620.631621000000000000 ; 000000198253755.843012000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010F61AE12E82E0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVI_II_metadata_line_11_____ZAO_ZOLOTO_SEVERNOGO_URALA_20231101 >									
	//        < uqNkDp99z21ST9We219wCcUr0dyz87rAtyxE3YzDKV3p5beQfB8s4Duy1303rVbX >									
	//        <  u =="0.000000000000000001" : ] 000000198253755.843012000000000000 ; 000000218616908.366991000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012E82E014D953B >									
	//     < RUSS_PFXVI_II_metadata_line_12_____OKHOTSKAYA_GGC_20231101 >									
	//        < Th597M14NUaM9395F04Y3Zk0xioT2rxZD1MT5clIq9IpvKW1oG9YDyFEs09UO7v3 >									
	//        <  u =="0.000000000000000001" : ] 000000218616908.366991000000000000 ; 000000239075181.925248000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014D953B16CCCBE >									
	//     < RUSS_PFXVI_II_metadata_line_13_____INTER_GOLD_CAPITAL_20231101 >									
	//        < P08j2E6YJdZv8wKvrSxWHtdh9o39nw868KueO0S83C1W89972h3L6P4gcaaHBAw0 >									
	//        <  u =="0.000000000000000001" : ] 000000239075181.925248000000000000 ; 000000255488687.579891000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016CCCBE185D845 >									
	//     < RUSS_PFXVI_II_metadata_line_14_____POLYMETAL_AURUM_20231101 >									
	//        < 0d6R2551qg8FFo1yKgug0yWGxy6N8ifsH2652650J66w8Mk9m0yBjycj80N8UCU3 >									
	//        <  u =="0.000000000000000001" : ] 000000255488687.579891000000000000 ; 000000276644489.713922000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000185D8451A62041 >									
	//     < RUSS_PFXVI_II_metadata_line_15_____KIRANKAN_OOO_20231101 >									
	//        < KNLU18x18c6YQ9eD8Akb52z20jHS3TXzZelyD8f790ssoQ1X6uhfbntdQXXH9vim >									
	//        <  u =="0.000000000000000001" : ] 000000276644489.713922000000000000 ; 000000293589299.224178000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A620411BFFB52 >									
	//     < RUSS_PFXVI_II_metadata_line_16_____OKHOTSK_MINING_GEOLOGICAL_CO_20231101 >									
	//        < Q9YTSMAbE8zL8x572rUp54v648j1KoH2No8FUueJ5hd968qKb5epYPB1Cp8rB1tw >									
	//        <  u =="0.000000000000000001" : ] 000000293589299.224178000000000000 ; 000000309869172.244152000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BFFB521D8D2A5 >									
	//     < RUSS_PFXVI_II_metadata_line_17_____AYAX_PROSPECTORS_ARTEL_CO_20231101 >									
	//        < kKp5s3F2003Dsy07HYZ8w05hQ4780F2Y217Yr0F5l0x43x0gSuqobsNW498PFoMI >									
	//        <  u =="0.000000000000000001" : ] 000000309869172.244152000000000000 ; 000000325656855.605076000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D8D2A51F0E9B6 >									
	//     < RUSS_PFXVI_II_metadata_line_18_____POLYMETAL_INDUSTRIA_20231101 >									
	//        < 6bo027pM82JeY4kMGnBXvCShhD3KGa3A6J0en4GoZf0cwcxQmhCqajbwHgM8nTO6 >									
	//        <  u =="0.000000000000000001" : ] 000000325656855.605076000000000000 ; 000000341077435.673515000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F0E9B62087160 >									
	//     < RUSS_PFXVI_II_metadata_line_19_____ASHANTI_POLYMET_STRATE_ALL_MANCO_20231101 >									
	//        < 46wNY592mTIfq643LM14db7yDukU11f5L2CWhq5zk18g8RvJt0Pf5W58FkzL76t0 >									
	//        <  u =="0.000000000000000001" : ] 000000341077435.673515000000000000 ; 000000356608072.766447000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020871602202407 >									
	//     < RUSS_PFXVI_II_metadata_line_20_____RUDNIK_AVLAYAKAN_20231101 >									
	//        < 5mg7c0MojTwZm4Ia4but2xNMP12kfkayg8L219QV4bVkL95YUm249N9pw6c0eidI >									
	//        <  u =="0.000000000000000001" : ] 000000356608072.766447000000000000 ; 000000376028691.155326000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000220240723DC635 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVI_II_metadata_line_21_____OLYMP_OOO_20231101 >									
	//        < BcK2Ou45o3N4Mj92e7qyz4pEZ1QelE6nF9boIh08MO6QtbNLrD7Bl53O8b08x2wd >									
	//        <  u =="0.000000000000000001" : ] 000000376028691.155326000000000000 ; 000000394242013.339997000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023DC63525990C9 >									
	//     < RUSS_PFXVI_II_metadata_line_22_____SEMCHENSKOYE_ZOLOTO_20231101 >									
	//        < 03slUlEgh55Gvfnj3lr32rV0rm70DKy4vJqO0I1QR2D1iI0tcC3wPVs6i5L885Uv >									
	//        <  u =="0.000000000000000001" : ] 000000394242013.339997000000000000 ; 000000414101235.511458000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025990C9277DE4C >									
	//     < RUSS_PFXVI_II_metadata_line_23_____MAYSKOYE_20231101 >									
	//        < gtvsK01HI2FeRbPT3mYgvMWPVoWzCy40k9519EOHg6MWYWEAnH6a14mQWAURr9u7 >									
	//        <  u =="0.000000000000000001" : ] 000000414101235.511458000000000000 ; 000000430426649.182435000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000277DE4C290C769 >									
	//     < RUSS_PFXVI_II_metadata_line_24_____FIANO_INVESTMENTS_20231101 >									
	//        < vWoRxF8dS0X6y8u497MhV126TfvPox8MA6EH1JCyqdpr61n9y5o619E800a0bfLd >									
	//        <  u =="0.000000000000000001" : ] 000000430426649.182435000000000000 ; 000000454607916.037733000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000290C7692B5AD38 >									
	//     < RUSS_PFXVI_II_metadata_line_25_____URAL_POLYMETAL_20231101 >									
	//        < G14v9661sOb693sHl979csHtBS6800z6xlwGfht88n54N5QQd9m4gW29mM69bU7p >									
	//        <  u =="0.000000000000000001" : ] 000000454607916.037733000000000000 ; 000000477071344.160923000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B5AD382D7F3FE >									
	//     < RUSS_PFXVI_II_metadata_line_26_____POLYMETAL_PDRUS_LLC_20231101 >									
	//        < 5102j08t11TD7zv03895j6boq833qoeFG9E2bpm2P1Dde6TVG6u8n2CA2lx960Cz >									
	//        <  u =="0.000000000000000001" : ] 000000477071344.160923000000000000 ; 000000496170712.152229000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D7F3FE2F518AF >									
	//     < RUSS_PFXVI_II_metadata_line_27_____VOSTOCHNY_BASIS_20231101 >									
	//        < ARS6HU1F6Z3GUs09cH0D88T1E2S7cdL2qdgD23Tf71yQh96DF9fd5j3m3ToFTM55 >									
	//        <  u =="0.000000000000000001" : ] 000000496170712.152229000000000000 ; 000000520049568.461858000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F518AF319885D >									
	//     < RUSS_PFXVI_II_metadata_line_28_____SAUM_MINING_CO_20231101 >									
	//        < xMhuqC4HrVr55f4uXqrxEHn42KkFUdstoYXn8U5VcoIt1pAI19lclim092giOG16 >									
	//        <  u =="0.000000000000000001" : ] 000000520049568.461858000000000000 ; 000000536236745.808849000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000319885D3323B7B >									
	//     < RUSS_PFXVI_II_metadata_line_29_____ALBAZINO_RESOURCES_20231101 >									
	//        < 48yfyFA12vW9zJ5vFLcegCqs24bT77C3EcK82HtabEZQ36HbKnteH5V35B7w5og3 >									
	//        <  u =="0.000000000000000001" : ] 000000536236745.808849000000000000 ; 000000551638052.832288000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003323B7B349BB9D >									
	//     < RUSS_PFXVI_II_metadata_line_30_____POLYMETAL_INDUSTRIYA_20231101 >									
	//        < B68PR99cAh55unKbwl3elXNXcQEz8C1uJ0sPTUgCOio5tWwrK346o726rt2724ys >									
	//        <  u =="0.000000000000000001" : ] 000000551638052.832288000000000000 ; 000000575299732.633624000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000349BB9D36DD675 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVI_II_metadata_line_31_____AS_APK_HOLDINGS_LIMITED_20231101 >									
	//        < dt7p7HKIO94t77QDr8S9f27baQJ44k95uTXzR1dx5Z2n32bDxEzj703K1XRuY1g9 >									
	//        <  u =="0.000000000000000001" : ] 000000575299732.633624000000000000 ; 000000593887997.328932000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036DD67538A3380 >									
	//     < RUSS_PFXVI_II_metadata_line_32_____POLAR_SILVER_RESOURCES_20231101 >									
	//        < wpk89k7spk1215ZmTOax1Na5d2K5DKv58IB30Q8VWUR3P4gE3M7K314cId52nV76 >									
	//        <  u =="0.000000000000000001" : ] 000000593887997.328932000000000000 ; 000000614548746.382771000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038A33803A9BA1B >									
	//     < RUSS_PFXVI_II_metadata_line_33_____PMTL_HOLDING_LIMITED_20231101 >									
	//        < 0oDsDh39x02BWKMpxKg45gTUy23qnBS6u95ve52b9ZjvBAPqFT93JaI2Ltc803cP >									
	//        <  u =="0.000000000000000001" : ] 000000614548746.382771000000000000 ; 000000631264523.329106000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A9BA1B3C33BB4 >									
	//     < RUSS_PFXVI_II_metadata_line_34_____ALBAZINO_RESOURCES_LIMITED_20231101 >									
	//        < 54pZFiVQwJ3miP5Wl22Fj9v538V2voc0tohp9Aq2W9x3MzGFT63PgVY9x8FExpW8 >									
	//        <  u =="0.000000000000000001" : ] 000000631264523.329106000000000000 ; 000000648686963.414261000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C33BB43DDD158 >									
	//     < RUSS_PFXVI_II_metadata_line_35_____RUDNIK_KVARTSEVYI_20231101 >									
	//        < RkS7g4oUnM255WcK4K1IsSvd6VWce1Bxpdip92zp2NJFr88KvFyxLV18fZL6GN58 >									
	//        <  u =="0.000000000000000001" : ] 000000648686963.414261000000000000 ; 000000668380306.776045000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DDD1583FBDE0F >									
	//     < RUSS_PFXVI_II_metadata_line_36_____NEVYANSK_GROUP_20231101 >									
	//        < 71aQ3COyp06eB2y3P64Z356Ge24kKOko1avLP1t12wp9F4a0YaPkne4ctpRS3FJe >									
	//        <  u =="0.000000000000000001" : ] 000000668380306.776045000000000000 ; 000000685300085.300022000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003FBDE0F415AF59 >									
	//     < RUSS_PFXVI_II_metadata_line_37_____AMURSK_HYDROMETALL_PLANT_20231101 >									
	//        < S1Xh3vJqcSYZt3Uh3hn22m77Jjx053pZf2ZCrL5T620hULlq0yU2bJ98xV5U7P11 >									
	//        <  u =="0.000000000000000001" : ] 000000685300085.300022000000000000 ; 000000705636381.450369000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000415AF59434B736 >									
	//     < RUSS_PFXVI_II_metadata_line_38_____AMURSK_HYDROMETALL_PLANT_ORG_20231101 >									
	//        < iY7D9v1x16mjdHOdwE2cIasZ76ejxJMb4r1FwA8Hj4zV89aV79VkK7WmEi1o6ZE9 >									
	//        <  u =="0.000000000000000001" : ] 000000705636381.450369000000000000 ; 000000728606180.887268000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000434B736457C3CA >									
	//     < RUSS_PFXVI_II_metadata_line_39_____OKHOTSKAYA_MINING_GEO_COMPANY_20231101 >									
	//        < ujNFSu3LkhI4F4sex9bAKdIoZk6jYG8MU88b8S2x1gK3yBNV719Au1v857z4QY2M >									
	//        <  u =="0.000000000000000001" : ] 000000728606180.887268000000000000 ; 000000748397332.236107000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000457C3CA475F6B5 >									
	//     < RUSS_PFXVI_II_metadata_line_40_____DUNDEE_PRECIOUS_METALS_KAPAN_20231101 >									
	//        < psp771aEa6m9GB6LLA7IKDAqNo037y9i9S1zxTbGKrY4ARutA3QJMQ5u1KUQ8853 >									
	//        <  u =="0.000000000000000001" : ] 000000748397332.236107000000000000 ; 000000765536332.851386000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000475F6B54901DA1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}