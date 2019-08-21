pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXIX_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXIX_III_883		"	;
		string	public		symbol =	"	RUSS_PFXXIX_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1062738178999180000000000000					;	
										
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
	//     < RUSS_PFXXIX_III_metadata_line_1_____INGOSSTRAKH_ORG_20251101 >									
	//        < oP54iBdbiY5x8rTv3ke7CdCL22CODU93FpGNbi3DL8536f73BM6LgyFk8l32wWNl >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000021589251.983080200000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000020F14D >									
	//     < RUSS_PFXXIX_III_metadata_line_2_____INGO_gbp_20251101 >									
	//        < I3yh35Sd4PEd9V7genN16wUIC36Xec57v4mbk2QiLQAg4sj0zNM3ry4HeDX3vHhm >									
	//        <  u =="0.000000000000000001" : ] 000000021589251.983080200000000000 ; 000000040342024.352102400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000020F14D3D8E9A >									
	//     < RUSS_PFXXIX_III_metadata_line_3_____INGO_usd_20251101 >									
	//        < qK2oA04mhtSbhlzh62cDe0Y63PMcA08hgsUonwv8ogg99S29WVJONfX3FeC435W7 >									
	//        <  u =="0.000000000000000001" : ] 000000040342024.352102400000000000 ; 000000072140159.337467100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003D8E9A6E13C0 >									
	//     < RUSS_PFXXIX_III_metadata_line_4_____INGO_chf_20251101 >									
	//        < MBGK36yD7ZW1Xz3dFKQ44j9XWA2M3E76rUHm121gFv4Ks2a3IrJB3mKgvQ6LfnlC >									
	//        <  u =="0.000000000000000001" : ] 000000072140159.337467100000000000 ; 000000097745586.351242100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006E13C09525DF >									
	//     < RUSS_PFXXIX_III_metadata_line_5_____INGO_eur_20251101 >									
	//        < jGNBGRjP52n8ws8VuPj8vnZ73ylDSQedze73T4i3wH94WIsm9823UMqUj19z10f2 >									
	//        <  u =="0.000000000000000001" : ] 000000097745586.351242100000000000 ; 000000121221269.853584000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009525DFB8F80F >									
	//     < RUSS_PFXXIX_III_metadata_line_6_____SIBAL_ORG_20251101 >									
	//        < 8v663miH6k8Hb4EQnu8pJv98CoCh2JIgjs8bqG4JOb00cjc7AUn9uD8uECZ7xD8z >									
	//        <  u =="0.000000000000000001" : ] 000000121221269.853584000000000000 ; 000000152445704.714074000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B8F80FE89D1A >									
	//     < RUSS_PFXXIX_III_metadata_line_7_____SIBAL_DAO_20251101 >									
	//        < 5nUnNckN5t76h67Z1VZU38C7f1Nv6v44En3XEnDV6878C4Zj8zsf7X8PB36dO44g >									
	//        <  u =="0.000000000000000001" : ] 000000152445704.714074000000000000 ; 000000176592443.577200000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E89D1A10D756C >									
	//     < RUSS_PFXXIX_III_metadata_line_8_____SIBAL_DAOPI_20251101 >									
	//        < U13ArF2QN1b8kdMU7ja650ov0Bp907Ip2dYAyzNNxGuDq0L8ZKaFINnY84231WE3 >									
	//        <  u =="0.000000000000000001" : ] 000000176592443.577200000000000000 ; 000000196429089.096809000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010D756C12BBA1D >									
	//     < RUSS_PFXXIX_III_metadata_line_9_____SIBAL_DAC_20251101 >									
	//        < vAykz08j2W9bPA7jK6IgGFpICM6zUL1JL705uaRd360VbjpJxUv2FSee5UGgUDzp >									
	//        <  u =="0.000000000000000001" : ] 000000196429089.096809000000000000 ; 000000225326749.528079000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012BBA1D157D243 >									
	//     < RUSS_PFXXIX_III_metadata_line_10_____SIBAL_BIMI_20251101 >									
	//        < t3Rd06LlYhz98u3TP6EDtmA4x5R8My1JDKheFkmoJ6C1hDQwj6Uf9fW6jp4qHDm6 >									
	//        <  u =="0.000000000000000001" : ] 000000225326749.528079000000000000 ; 000000252441127.633128000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000157D24318131D1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXIX_III_metadata_line_11_____INGO_ARMENIA_20251101 >									
	//        < 8QNs34UrS7yOrGg46vpdMo56IO4Ih8Ge8cV804m6PPdiQApi7Hyc9Uk702zj2xSy >									
	//        <  u =="0.000000000000000001" : ] 000000252441127.633128000000000000 ; 000000277006341.659856000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018131D11A6AD9A >									
	//     < RUSS_PFXXIX_III_metadata_line_12_____INGO_INSURANCE_COMPANY_20251101 >									
	//        < TF683AA18xB7te9DPHRNRJf9CLs4Vs0YQ8A6g88nDEqrpxPm8f6SYXKndJei3t5x >									
	//        <  u =="0.000000000000000001" : ] 000000277006341.659856000000000000 ; 000000297977595.488732000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A6AD9A1C6AD80 >									
	//     < RUSS_PFXXIX_III_metadata_line_13_____ONDD_CREDIT_INSURANCE_20251101 >									
	//        < EE1nn3TIV328TY6wO3HFM897uy0CTl99PbQn630yG6n4m7i6Wcrb70qTsIk8o107 >									
	//        <  u =="0.000000000000000001" : ] 000000297977595.488732000000000000 ; 000000325933885.900514000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C6AD801F155ED >									
	//     < RUSS_PFXXIX_III_metadata_line_14_____BANK_SOYUZ_INGO_20251101 >									
	//        < qdKu0JrL5Z8Tiv26hpcH39ZE26pVyKsJD1Zjt05gnSPo8ApdMi429fTu03uOF3wu >									
	//        <  u =="0.000000000000000001" : ] 000000325933885.900514000000000000 ; 000000360299508.354960000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F155ED225C5FF >									
	//     < RUSS_PFXXIX_III_metadata_line_15_____CHREZVYCHAJNAYA_STRAKHOVAYA_KOMP_20251101 >									
	//        < oyQI28KCiKpAap2WyxDJhi9ajC3M22f82w3UED1c692B4g50w1R638D420B24GER >									
	//        <  u =="0.000000000000000001" : ] 000000360299508.354960000000000000 ; 000000382090389.814067000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000225C5FF247060F >									
	//     < RUSS_PFXXIX_III_metadata_line_16_____ONDD_ORG_20251101 >									
	//        < RXTwtK90Zg2Uec18RGbipQi1hpRj11w93z62u1O37229uL48H5FMHf9eLriBd7Kq >									
	//        <  u =="0.000000000000000001" : ] 000000382090389.814067000000000000 ; 000000416207857.037586000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000247060F27B1532 >									
	//     < RUSS_PFXXIX_III_metadata_line_17_____ONDD_DAO_20251101 >									
	//        < 905l9UEvEfWn95HViC7Jluhi1dfuNG6mJoDb7TC821LBOCz4VQIVVaKQp8E939X5 >									
	//        <  u =="0.000000000000000001" : ] 000000416207857.037586000000000000 ; 000000439701594.841927000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027B153229EEE6F >									
	//     < RUSS_PFXXIX_III_metadata_line_18_____ONDD_DAOPI_20251101 >									
	//        < Q6n272VKhFk086xi2c8PB5Pe4c33VHXnH1HPa9233akZ0Ea6VF9Do68yo5IIy0QY >									
	//        <  u =="0.000000000000000001" : ] 000000439701594.841927000000000000 ; 000000460323170.962053000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029EEE6F2BE65BD >									
	//     < RUSS_PFXXIX_III_metadata_line_19_____ONDD_DAC_20251101 >									
	//        < 7SWKI153e0E7RvNv2gHhA2Rd589YOTuv1KIiCAn3mF2n7C93AZUzR706b7rx5o7j >									
	//        <  u =="0.000000000000000001" : ] 000000460323170.962053000000000000 ; 000000480700720.281028000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BE65BD2DD7DB8 >									
	//     < RUSS_PFXXIX_III_metadata_line_20_____ONDD_BIMI_20251101 >									
	//        < 8dIATp0h9M7H798Q185jNk5KW9uc1LO8NBDcZ1Y09NKRpm1523xSho9OS697n2Ey >									
	//        <  u =="0.000000000000000001" : ] 000000480700720.281028000000000000 ; 000000510944836.617959000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DD7DB830BA3D4 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXIX_III_metadata_line_21_____SOYUZ_ORG_20251101 >									
	//        < 9UK8XBgq4Q48dar1hwuGq17P0rpJ9m07Lm4kDtKBGizMbw3gFPxJJAJg47848NyW >									
	//        <  u =="0.000000000000000001" : ] 000000510944836.617959000000000000 ; 000000544052438.330435000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030BA3D433E287C >									
	//     < RUSS_PFXXIX_III_metadata_line_22_____SOYUZ_DAO_20251101 >									
	//        < YG5sR340JrQ7NweWZfFx6aa5AKHk1wHvVF4j81xBCk4h6r9DvxeKyrfB9soBj79I >									
	//        <  u =="0.000000000000000001" : ] 000000544052438.330435000000000000 ; 000000565588411.113473000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033E287C35F04F9 >									
	//     < RUSS_PFXXIX_III_metadata_line_23_____SOYUZ_DAOPI_20251101 >									
	//        < VG2Nr29I86QKbDH624Oap4I7M2mE76I0l86k7Y1T5Y5L2p9O2UpLx4yOnwfF4wlE >									
	//        <  u =="0.000000000000000001" : ] 000000565588411.113473000000000000 ; 000000592995273.189449000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035F04F9388D6C7 >									
	//     < RUSS_PFXXIX_III_metadata_line_24_____SOYUZ_DAC_20251101 >									
	//        < 5P58qa3MS3eui1Bkb3gend1Cu3N3920DXEKhWqH60q9t0xWn1dyLT28x0a6446gs >									
	//        <  u =="0.000000000000000001" : ] 000000592995273.189449000000000000 ; 000000620453981.536793000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000388D6C73B2BCD6 >									
	//     < RUSS_PFXXIX_III_metadata_line_25_____SOYUZ_BIMI_20251101 >									
	//        < J2s9E1F919q7B73u5yBS4cf0FZ6qqYs8Iue51fq2UnMwwjriQ30V1Td82EmXqzV6 >									
	//        <  u =="0.000000000000000001" : ] 000000620453981.536793000000000000 ; 000000647245398.207369000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B2BCD63DB9E3C >									
	//     < RUSS_PFXXIX_III_metadata_line_26_____PIFAGOR_AM_20251101 >									
	//        < 1S8b5862KpA14fsMlTtG2i0W06ISX0iqWeV2KDg7M9TehK41y5f6sk7e7t8Ez60O >									
	//        <  u =="0.000000000000000001" : ] 000000647245398.207369000000000000 ; 000000676805896.304523000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DB9E3C408B94E >									
	//     < RUSS_PFXXIX_III_metadata_line_27_____SK_INGO_LMT_20251101 >									
	//        < pz20R8c5qB1m6jFMA3q19mcLiHZ0SWyh7n49u00eR61a3q37a30dPha3U0LlCs58 >									
	//        <  u =="0.000000000000000001" : ] 000000676805896.304523000000000000 ; 000000705968597.784051000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000408B94E43538FC >									
	//     < RUSS_PFXXIX_III_metadata_line_28_____AKVAMARIN_20251101 >									
	//        < 6rxPhFMO7lPP7oA4N2g7RLfNT6qy64AseM49E88784CeWYq9o68F936c2CwzZDBg >									
	//        <  u =="0.000000000000000001" : ] 000000705968597.784051000000000000 ; 000000725145315.702916000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000043538FC4527BE4 >									
	//     < RUSS_PFXXIX_III_metadata_line_29_____INVEST_POLIS_20251101 >									
	//        < R00ulStGibjt8q4YqSHvXL0xN8uHfz050w4256h1IS7GGyfnjOvtD6DN3Ist4ZFW >									
	//        <  u =="0.000000000000000001" : ] 000000725145315.702916000000000000 ; 000000753770774.713067000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004527BE447E29B5 >									
	//     < RUSS_PFXXIX_III_metadata_line_30_____INGOSSTRAKH_LIFE_INSURANCE_CO_20251101 >									
	//        < 11qF64XPdCQz7935TiG6T77YJ8mDnCmK4TZ22ojOQqPy3mzFC7x04B1vA9m8rHu7 >									
	//        <  u =="0.000000000000000001" : ] 000000753770774.713067000000000000 ; 000000778008605.198574000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000047E29B54A3259D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXIX_III_metadata_line_31_____SIBAL_gbp_20251101 >									
	//        < z6C5r6pm12S137kYlbI0m6goR4Bp4tf308D6N7Bbb8b36z97T8zcE6013n99OILE >									
	//        <  u =="0.000000000000000001" : ] 000000778008605.198574000000000000 ; 000000810535749.131085000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A3259D4D4C787 >									
	//     < RUSS_PFXXIX_III_metadata_line_32_____SIBAL_PENSII_20251101 >									
	//        < dsw7wxs85IED2FWI3WJX0XD4eNdmjE1P2EYYPEYFm9upr064uCg5zUaCbePt39xj >									
	//        <  u =="0.000000000000000001" : ] 000000810535749.131085000000000000 ; 000000843586355.113046000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004D4C78750735EC >									
	//     < RUSS_PFXXIX_III_metadata_line_33_____SOYUZ_gbp_20251101 >									
	//        < SX3XkwSEUP753clkD6s21FZ30j56WSodH94848e0h6c0vg3Lqd3p5FatC81ow696 >									
	//        <  u =="0.000000000000000001" : ] 000000843586355.113046000000000000 ; 000000868447424.200800000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000050735EC52D2546 >									
	//     < RUSS_PFXXIX_III_metadata_line_34_____SOYUZ_PENSII_20251101 >									
	//        < 192pMVYJ17PRoW9mf9ZK63nU4L3CWn47PVi3nJ3xVpKAHw3RDF3pHk773Ko8KNlm >									
	//        <  u =="0.000000000000000001" : ] 000000868447424.200800000000000000 ; 000000892352618.798944000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000052D25465519F3E >									
	//     < RUSS_PFXXIX_III_metadata_line_35_____PIFAGOR_gbp_20251101 >									
	//        < 0Y7LlOTgKmZ97sTItHH6p22AFavV1Jue1R7LrKWX7c9v1D6A3CB8i34Jo52NLyRr >									
	//        <  u =="0.000000000000000001" : ] 000000892352618.798944000000000000 ; 000000914925863.558319000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005519F3E57410EA >									
	//     < RUSS_PFXXIX_III_metadata_line_36_____PIFAGOR_PENSII_20251101 >									
	//        < 2P40B13j73fDNNv8GDxY175ABQ0u2TN8pZcHe37HP84uSI31A56TUnzmh3BlLPVU >									
	//        <  u =="0.000000000000000001" : ] 000000914925863.558319000000000000 ; 000000950443138.291033000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000057410EA5AA42DA >									
	//     < RUSS_PFXXIX_III_metadata_line_37_____AKVAMARIN_gbp_20251101 >									
	//        < 6IM2lUoimWx1MEG3tVhya21a6m3eQ7s7875q9WC5DXw82x491UXI2MI5coaGkafg >									
	//        <  u =="0.000000000000000001" : ] 000000950443138.291033000000000000 ; 000000972358615.737720000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005AA42DA5CBB396 >									
	//     < RUSS_PFXXIX_III_metadata_line_38_____AKVAMARIN_PENSII_20251101 >									
	//        < 5lF6oe81oFY6XY7830kzANrBa15m438GR2fl2Q2r53X70SM5c6BUi86H4nlhy6sE >									
	//        <  u =="0.000000000000000001" : ] 000000972358615.737720000000000000 ; 000001006701893.757880000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005CBB3966001AED >									
	//     < RUSS_PFXXIX_III_metadata_line_39_____POLIS_gbp_20251101 >									
	//        < W0GPF4WPgZVVR5r8Jy6ghx91nfdnOOync98OlT16fb4KRYol4eT41sJc96093J9F >									
	//        <  u =="0.000000000000000001" : ] 000001006701893.757880000000000000 ; 000001033585234.484540000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006001AED629203B >									
	//     < RUSS_PFXXIX_III_metadata_line_40_____POLIS_PENSII_20251101 >									
	//        < JL41751CLvK2jjvI3S53LoPi0WptB8jKfrQfkY0STeqKn18378Qm9D2ep815hcw2 >									
	//        <  u =="0.000000000000000001" : ] 000001033585234.484540000000000000 ; 000001062738178.999180000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000629203B6559C1A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}