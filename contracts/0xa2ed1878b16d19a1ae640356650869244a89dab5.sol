pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXII_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXII_I_883		"	;
		string	public		symbol =	"	RUSS_PFXXXII_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		589228184307638000000000000					;	
										
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
	//     < RUSS_PFXXXII_I_metadata_line_1_____SOLLERS_20211101 >									
	//        < IXj0sMkL99nef0MnKF4X3ATbDP9RkR32m42YKrKi38qGOnhHF65s7t47L067Nx5e >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000014500479.030798600000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000162040 >									
	//     < RUSS_PFXXXII_I_metadata_line_2_____UAZ_20211101 >									
	//        < pr6Ju9Mgw39j4qn9fTM9tm9yUd6QH427d7i7CR1ZfdGE3JwxVsQuvHuTF10i94y2 >									
	//        <  u =="0.000000000000000001" : ] 000000014500479.030798600000000000 ; 000000029447292.252459200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001620402CEED9 >									
	//     < RUSS_PFXXXII_I_metadata_line_3_____FORD_SOLLERS_20211101 >									
	//        < 42m0hiZklOM5DIvzroCq3N6rT30xaX348hPsp07O66K4u1d7z81j7tq71dic403k >									
	//        <  u =="0.000000000000000001" : ] 000000029447292.252459200000000000 ; 000000043317224.711168500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002CEED94218CA >									
	//     < RUSS_PFXXXII_I_metadata_line_4_____URALAZ_20211101 >									
	//        < OuxHsyvvL4qnGBoP782S1TUP21Twoe02qz3AHUb7Hybdf57tH8w541C8H1069MyT >									
	//        <  u =="0.000000000000000001" : ] 000000043317224.711168500000000000 ; 000000056308288.109359900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004218CA55EB6D >									
	//     < RUSS_PFXXXII_I_metadata_line_5_____ZAVOLZHYE_ENGINE_FACTORY_20211101 >									
	//        < gJ8dm8e9snbkmXRXKY6gxGygO4Ha5kdE16lUtMy5P69SDyBa4CD75KU80neA3ESr >									
	//        <  u =="0.000000000000000001" : ] 000000056308288.109359900000000000 ; 000000069860662.999203400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000055EB6D6A9952 >									
	//     < RUSS_PFXXXII_I_metadata_line_6_____ZMA_20211101 >									
	//        < cs33U04V7p38568ppT8PJK24kV0bmkCv1UgAyN8VcfDd8pi1c7ao215B00tiO37e >									
	//        <  u =="0.000000000000000001" : ] 000000069860662.999203400000000000 ; 000000084887858.240208300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006A9952818752 >									
	//     < RUSS_PFXXXII_I_metadata_line_7_____MAZDA_MOTORS_MANUFACT_RUS_20211101 >									
	//        < V35S5nK4M8i3Rg2eaX1AMy91D72RWrZYGOC4jzcsuUF6trjJmGR69zH53X4FXnqB >									
	//        <  u =="0.000000000000000001" : ] 000000084887858.240208300000000000 ; 000000098416244.742220900000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000818752962BD8 >									
	//     < RUSS_PFXXXII_I_metadata_line_8_____REMSERVIS_20211101 >									
	//        < 0VYerJLI63XFNV9PfuIkt9447l9nxxz7273gv0cNTCd9LmQ9ZrN7AMRSQbweccJj >									
	//        <  u =="0.000000000000000001" : ] 000000098416244.742220900000000000 ; 000000113732403.224983000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000962BD8AD8AB8 >									
	//     < RUSS_PFXXXII_I_metadata_line_9_____MAZDA_SOLLERS_JV_20211101 >									
	//        < DI30QWA1W517AmsV0103N63yRSTjB55oTo24DyRInQ8PUFkVnie91aROz2Yshl7u >									
	//        <  u =="0.000000000000000001" : ] 000000113732403.224983000000000000 ; 000000127803923.043223000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AD8AB8C30368 >									
	//     < RUSS_PFXXXII_I_metadata_line_10_____SEVERSTALAVTO_ZAO_20211101 >									
	//        < 958Co67HCtfWdK1g5bhMKtB6pjfThFUIt3Efh90oXV0W8KPtFw0mCGRtK2Fyw67Z >									
	//        <  u =="0.000000000000000001" : ] 000000127803923.043223000000000000 ; 000000142513740.401566000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C30368D9756E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXII_I_metadata_line_11_____SEVERSTALAUTO_KAMA_20211101 >									
	//        < A0oo934BIV9NK0527p5RWA3KObkp23iAHbxjMC7yqy1a5JEd3a6LZRT8WlcyXyUJ >									
	//        <  u =="0.000000000000000001" : ] 000000142513740.401566000000000000 ; 000000156914506.881398000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D9756EEF6EBB >									
	//     < RUSS_PFXXXII_I_metadata_line_12_____KAMA_ORG_20211101 >									
	//        < We72jW39GGMlaiWMi5E3y0R1qBi0M6mHg5zpoT2UC2SdtC0RfS5JXtB95mu4gNpj >									
	//        <  u =="0.000000000000000001" : ] 000000156914506.881398000000000000 ; 000000173245998.903710000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EF6EBB1085A38 >									
	//     < RUSS_PFXXXII_I_metadata_line_13_____DALNIY_VOSTOK_20211101 >									
	//        < 062meautDsvtvObSK1DtP4lv9DdJ868bpO0127KErOqYvX0nbJqwE97BXF32515E >									
	//        <  u =="0.000000000000000001" : ] 000000173245998.903710000000000000 ; 000000189143657.688366000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001085A381209C3E >									
	//     < RUSS_PFXXXII_I_metadata_line_14_____DALNIY_ORG_20211101 >									
	//        < 7TZ9qRnY2J5x5Qte2r71O1CM4YdGxLI08uz5RoymSfW285fspa7M50hIZK3uKoXj >									
	//        <  u =="0.000000000000000001" : ] 000000189143657.688366000000000000 ; 000000202448747.628264000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001209C3E134E98B >									
	//     < RUSS_PFXXXII_I_metadata_line_15_____SPECIAL_VEHICLES_OOO_20211101 >									
	//        < k2ZW8U63q06D52wdvrMpNmTcpnxyw60Ch2lJ42Y91tlai289Ptw6B2Z0W6Lskzd0 >									
	//        <  u =="0.000000000000000001" : ] 000000202448747.628264000000000000 ; 000000217151915.244462000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000134E98B14B58F8 >									
	//     < RUSS_PFXXXII_I_metadata_line_16_____MAZDDA_SOLLERS_MANUFACT_RUS_20211101 >									
	//        < LFzpr9jTbq0Q4iSp4VkPUjNG049BnR91fuKso6zuiEJ40mpHhfcoX7MN0596r35I >									
	//        <  u =="0.000000000000000001" : ] 000000217151915.244462000000000000 ; 000000234012534.494136000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014B58F81651325 >									
	//     < RUSS_PFXXXII_I_metadata_line_17_____TURIN_AUTO_OOO_20211101 >									
	//        < zy3xeemXr65MG06GzBmpAR6uE0pd2Z91O9IEYJ3O3Uc6a8q3wirp2Hqd6u55zb6i >									
	//        <  u =="0.000000000000000001" : ] 000000234012534.494136000000000000 ; 000000247106514.931261000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016513251790DFB >									
	//     < RUSS_PFXXXII_I_metadata_line_18_____ZMZ_TRANSSERVICE_20211101 >									
	//        < C41710U6EbM1477347A7DuEczCX4zS8FLNMuzR2VuPx4A0QsKA65YvI9N3Gk7fA5 >									
	//        <  u =="0.000000000000000001" : ] 000000247106514.931261000000000000 ; 000000261687732.938000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001790DFB18F4DC5 >									
	//     < RUSS_PFXXXII_I_metadata_line_19_____SAPORT_OOO_20211101 >									
	//        < VzA9S97BwRUN50njRfdp0l1gy3UEI5yuUV4ptdFJ8yKKRfjS205212wC2UV345Rd >									
	//        <  u =="0.000000000000000001" : ] 000000261687732.938000000000000000 ; 000000278708267.037295000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018F4DC51A9466B >									
	//     < RUSS_PFXXXII_I_metadata_line_20_____TRANSPORTNIK_12_20211101 >									
	//        < 53rhHBVNF7I0WGl35Z3U5rW4MivfihaP339et18Lo8xh7oQQAQ0KFnA0JY5T27Sr >									
	//        <  u =="0.000000000000000001" : ] 000000278708267.037295000000000000 ; 000000294578540.457850000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A9466B1C17DBE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXII_I_metadata_line_21_____OOO_UAZ_TEKHINSTRUMENT_20211101 >									
	//        < IjU6iEAeVAaHky347vD6QGoa64p815qBo6xx4azkpWv99Hf1D3C0x2484e5ETr49 >									
	//        <  u =="0.000000000000000001" : ] 000000294578540.457850000000000000 ; 000000309178148.422947000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C17DBE1D7C4B7 >									
	//     < RUSS_PFXXXII_I_metadata_line_22_____ZAO_KAPITAL_20211101 >									
	//        < cP4Gax490EdbI3Je665Pt8xLc32R7521US3JLrfK5302GfT9SZu748246gl16e84 >									
	//        <  u =="0.000000000000000001" : ] 000000309178148.422947000000000000 ; 000000323577670.053722000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D7C4B71EDBD87 >									
	//     < RUSS_PFXXXII_I_metadata_line_23_____OOO_UAZ_DISTRIBUTION_CENTRE_20211101 >									
	//        < ECaz9I4ArvOWr56oUCPs901ar7CHk148sA3tMm8n5eUViLsivsdj366to1fyCM7T >									
	//        <  u =="0.000000000000000001" : ] 000000323577670.053722000000000000 ; 000000338829251.670337000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EDBD87205032D >									
	//     < RUSS_PFXXXII_I_metadata_line_24_____SHTAMP_20211101 >									
	//        < X4Jp9d1pKsDx5ZquWaUCh90CGWGxciu8U1N702pQ2YW6cO0P9T1Yu82YTgPWg8AL >									
	//        <  u =="0.000000000000000001" : ] 000000338829251.670337000000000000 ; 000000355094124.441267000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000205032D21DD4A4 >									
	//     < RUSS_PFXXXII_I_metadata_line_25_____SOLLERS_FINANS_20211101 >									
	//        < rjjcstIayau2rZgWvuHz5VYU8rUN0J6tx0Yc0bbzPIxU9NrA4h5k7kblxXObuZZx >									
	//        <  u =="0.000000000000000001" : ] 000000355094124.441267000000000000 ; 000000371516892.803193000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021DD4A4236E3C9 >									
	//     < RUSS_PFXXXII_I_metadata_line_26_____SOLLERS_FINANCE_LLC_20211101 >									
	//        < iu56B5rs57yq9Wn29Z6i9b4Ymj5C5oKf3I35jnJ5h034988F2D7T7SF42ZhHzuWK >									
	//        <  u =="0.000000000000000001" : ] 000000371516892.803193000000000000 ; 000000384886416.394122000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000236E3C924B4A42 >									
	//     < RUSS_PFXXXII_I_metadata_line_27_____TORGOVIY_DOM_20211101 >									
	//        < Xy2dmS92D0IYreqHe7Z3aX9c0LmeVY5M40niWt9hX2UQ0l8JLjz3297GRP7Q4XMK >									
	//        <  u =="0.000000000000000001" : ] 000000384886416.394122000000000000 ; 000000399665395.137365000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024B4A42261D74C >									
	//     < RUSS_PFXXXII_I_metadata_line_28_____SOLLERS_BUSSAN_20211101 >									
	//        < v7J7yRgA5i4999lgo79x12FbD3J94jMc7bWskz9l64d68Xj9hEpA0X1AY8113PCn >									
	//        <  u =="0.000000000000000001" : ] 000000399665395.137365000000000000 ; 000000415677511.584090000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000261D74C27A4607 >									
	//     < RUSS_PFXXXII_I_metadata_line_29_____SEVERSTALAUTO_ISUZU_20211101 >									
	//        < 5C529EI8yTVV6GXX9A60S3758YwYv760mcBk8xZUzUjb07a9AzOrBduGiQp92So1 >									
	//        <  u =="0.000000000000000001" : ] 000000415677511.584090000000000000 ; 000000429850862.327462000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027A460728FE67E >									
	//     < RUSS_PFXXXII_I_metadata_line_30_____SEVERSTALAUTO_ELABUGA_20211101 >									
	//        < GO4oSiwP68RG1Q6704z29kCrP6Kr4hX1oQkZheI5459xdh67K6u2Oa9Fygcw97n0 >									
	//        <  u =="0.000000000000000001" : ] 000000429850862.327462000000000000 ; 000000443532634.707414000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028FE67E2A4C6EF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXII_I_metadata_line_31_____SOLLERS_DEVELOPMENT_20211101 >									
	//        < J1eQmqmsPAG398r780YDI7bGT724ZGo4zse66u3g8vqfTacTNR26LG9344pgat21 >									
	//        <  u =="0.000000000000000001" : ] 000000443532634.707414000000000000 ; 000000457575689.036516000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A4C6EF2BA3481 >									
	//     < RUSS_PFXXXII_I_metadata_line_32_____TRADE_HOUSE_SOLLERS_OOO_20211101 >									
	//        < MJp4243lKo8E8sn6rkyvhf727pE8OF2rk1NVfS5YZ78gh7e7BEdF237K1d1KU4ST >									
	//        <  u =="0.000000000000000001" : ] 000000457575689.036516000000000000 ; 000000470886886.246410000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BA34812CE8431 >									
	//     < RUSS_PFXXXII_I_metadata_line_33_____SEVERSTALAUTO_ELABUGA_LLC_20211101 >									
	//        < 6eT1nDbvRPposg8GN17KBizVWz9s4y9raUeps9KiRkH35Z61k2732dxx6RqA1c0o >									
	//        <  u =="0.000000000000000001" : ] 000000470886886.246410000000000000 ; 000000484491576.079062000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CE84312E34686 >									
	//     < RUSS_PFXXXII_I_metadata_line_34_____SOLLERS_PARTNER_20211101 >									
	//        < 3xtzj6ovxh580BifjhPDMe4R0446nfZOyE7NF5wi9G2vXygX04B98B533Eu6KSqd >									
	//        <  u =="0.000000000000000001" : ] 000000484491576.079062000000000000 ; 000000499800946.340936000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E346862FAA2BF >									
	//     < RUSS_PFXXXII_I_metadata_line_35_____ULYANOVSK_CAR_PLANT_20211101 >									
	//        < VGQun0IBU6wM9TBUAYKHSC6CLAPturP5j1Db984Klb0Il5Hpg56XC8eb3oq3UZpR >									
	//        <  u =="0.000000000000000001" : ] 000000499800946.340936000000000000 ; 000000514483528.382238000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FAA2BF3110A21 >									
	//     < RUSS_PFXXXII_I_metadata_line_36_____FPT_SOLLERS_OOO_20211101 >									
	//        < rd1w81YuIw18hB953DOji8sw7FQtz0yWVulpV08zV1j8JQzh3JQ1Pv8qdC00T6gH >									
	//        <  u =="0.000000000000000001" : ] 000000514483528.382238000000000000 ; 000000531285928.948804000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003110A2132AAD91 >									
	//     < RUSS_PFXXXII_I_metadata_line_37_____OOO_SPECINSTRUMENT_20211101 >									
	//        < 1p884AQ5314gbcd1tvSsmthXEg7dq35VW757y4jHM0l896OZnHb76jfSm2T7K950 >									
	//        <  u =="0.000000000000000001" : ] 000000531285928.948804000000000000 ; 000000548282767.317057000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032AAD913449CF5 >									
	//     < RUSS_PFXXXII_I_metadata_line_38_____AVTOKOMPO_KOROBKA_PEREDACH_UZLY_TR_20211101 >									
	//        < 5rvO262PYf3DfbuaB4A3uQ5ZoViHK5pQP01O6TP723R8cnfttM18kl4VhNJyZypN >									
	//        <  u =="0.000000000000000001" : ] 000000548282767.317057000000000000 ; 000000562477294.989422000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003449CF535A45B1 >									
	//     < RUSS_PFXXXII_I_metadata_line_39_____KOLOMYAZHSKOM_AUTOCENTRE_OOO_20211101 >									
	//        < cZTf81J5R14E3XRLG1MBe734zi3MuhB122K0L8O38Y7mTVz285dX3ueVdh5v0I19 >									
	//        <  u =="0.000000000000000001" : ] 000000562477294.989422000000000000 ; 000000575754708.247587000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035A45B136E882F >									
	//     < RUSS_PFXXXII_I_metadata_line_40_____ROSALIT_20211101 >									
	//        < N58W5zFjY979R95W10wlAiE5D0HZFzvtf0IU16kpL6gZ8NpgZKUjD8C0UeRj6RMV >									
	//        <  u =="0.000000000000000001" : ] 000000575754708.247587000000000000 ; 000000589228184.307638000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036E882F3831742 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}