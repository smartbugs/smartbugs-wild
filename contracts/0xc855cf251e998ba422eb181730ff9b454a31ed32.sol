pragma solidity 		^0.4.21	;						
										
	contract	NBI_PFII_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NBI_PFII_I_883		"	;
		string	public		symbol =	"	NBI_PFII_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		609466353628362000000000000					;	
										
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
	//     < NBI_PFII_I_metadata_line_1_____CRC_CR_Beijing_group_20211101 >									
	//        < 2mKsPH0Nb7Xd4Q18Vk350a0S5j8fUeAG34EP2XKMWSF77u7KoZwgIiy56EBSP55p >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000015705501.025992900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000017F6F6 >									
	//     < NBI_PFII_I_metadata_line_2_____CRC_CR_Qingzang_group_20211101 >									
	//        < RkDMG081m86PY776n9Xc6x8lSvfUgNxpcOhks56CULqd5PX4j3fs753ogVcm9oy5 >									
	//        <  u =="0.000000000000000001" : ] 000000015705501.025992900000000000 ; 000000029444948.332818600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000017F6F62CEDEF >									
	//     < NBI_PFII_I_metadata_line_3_____Chengdu_railway_bureau_20211101 >									
	//        < DvdW155xFI7T53r366Gvr2aH5yThC1141aGE9t58LNZ0kl7HCO4T2H7rLesaReDF >									
	//        <  u =="0.000000000000000001" : ] 000000029444948.332818600000000000 ; 000000044960512.921416100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002CEDEF449AB3 >									
	//     < NBI_PFII_I_metadata_line_4_____Chengdu_railway_bureau_Xianghu_20211101 >									
	//        < HfQoHyjZnGwc3RhkBXW18h3Bu8L5fhxd0VQKvz2DJOC962OkO0z4cXgml88276xb >									
	//        <  u =="0.000000000000000001" : ] 000000044960512.921416100000000000 ; 000000062110444.463517300000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000449AB35EC5E4 >									
	//     < NBI_PFII_I_metadata_line_5_____Chengdu_railway_bureau_Yanglao_jin_20211101 >									
	//        < I13ts56zlHTywqo6LB1M1S2vKFTC5qCU6BDm6zNQoiD500FpT10A2N4NzVV0uNMg >									
	//        <  u =="0.000000000000000001" : ] 000000062110444.463517300000000000 ; 000000079020746.901151700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005EC5E478937B >									
	//     < NBI_PFII_I_metadata_line_6_____cr_Chengdu_group_chengdu_railway_bureau_xichang_railway_branch_20211101 >									
	//        < ne32NjsMLmV0Ve96rT7E80mhlbyzLbfURNLgEO86aC68qKk4m7hQp8ActQQS9kmO >									
	//        <  u =="0.000000000000000001" : ] 000000079020746.901151700000000000 ; 000000092912733.661768700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000078937B8DC609 >									
	//     < NBI_PFII_I_metadata_line_7_____CRC_CR_Urumqi_group_20211101 >									
	//        < O53Ee0InXR754IdkE201ij75Dqh72MG6t2h67Gw8pgLgoG44x9kgaqO732lg1TP6 >									
	//        <  u =="0.000000000000000001" : ] 000000092912733.661768700000000000 ; 000000108865767.994065000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008DC609A61DB1 >									
	//     < NBI_PFII_I_metadata_line_8_____CRC_CR_Urumqi_group_Xianghu_20211101 >									
	//        < 5H052nk1R0Ue8YTUf5l6qZ3c038d0PVom9v6t07kMXdSFv5QjR0llZek4UbR8Qjq >									
	//        <  u =="0.000000000000000001" : ] 000000108865767.994065000000000000 ; 000000123505757.389317000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A61DB1BC7470 >									
	//     < NBI_PFII_I_metadata_line_9_____CRC_CR_Urumqi_group_Yanglao_jin_20211101 >									
	//        < I0j672GC4w890gcIZfFXpNAyi4OG64mNL0JH3n6eXFFcIYAgjCZgDC1EL59N26fE >									
	//        <  u =="0.000000000000000001" : ] 000000123505757.389317000000000000 ; 000000137804829.007366000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BC7470D24603 >									
	//     < NBI_PFII_I_metadata_line_10_____CRC_CR_Zhengzhou_group_20211101 >									
	//        < drkL1w3aP78MvWqGBehwC2lW345YB3y855Uzg8dcFA8rC1G8Rz05721pq8oQ6T56 >									
	//        <  u =="0.000000000000000001" : ] 000000137804829.007366000000000000 ; 000000151438943.378785000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D24603E713D6 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NBI_PFII_I_metadata_line_11_____CRC_CR_Zhengzhou_group_Xianghu_20211101 >									
	//        < g99TvMeU4b9jK45FtKpK84njW1Y80WHqCGs9S1i157Qm2cHUC0pYQ45Hava2HBP1 >									
	//        <  u =="0.000000000000000001" : ] 000000151438943.378785000000000000 ; 000000164728459.279127000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E713D6FB5B0E >									
	//     < NBI_PFII_I_metadata_line_12_____CRC_CR_Zhengzhou_group_Yanglao_jin_20211101 >									
	//        < 33ZcC84bLCnC29IVGU2DIgw2aXZ1g6PNF5MCg3v347ql7b5s1JcwI4LchP8d0M74 >									
	//        <  u =="0.000000000000000001" : ] 000000164728459.279127000000000000 ; 000000181797732.443428000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FB5B0E11566BD >									
	//     < NBI_PFII_I_metadata_line_13_____CRC_Shenyang_railways_bureau_20211101 >									
	//        < 0A2y5Sj5x01gd64948vjf2WL7Rdt8qs3DQNYy9m2SuRo0k1U909eq9jS6fZT8e58 >									
	//        <  u =="0.000000000000000001" : ] 000000181797732.443428000000000000 ; 000000198088192.910014000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011566BD12E4233 >									
	//     < NBI_PFII_I_metadata_line_14_____CRC_Shenyang_railways_bureau_Xianghu_20211101 >									
	//        < 5rkK5zyfQqC4cq1eha2G9c0b1XF7HE29BV3604NcY5RIE6cal8rgnkVkSwx8632Q >									
	//        <  u =="0.000000000000000001" : ] 000000198088192.910014000000000000 ; 000000211785559.700446000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012E423314328BC >									
	//     < NBI_PFII_I_metadata_line_15_____CRC_Shenyang_railways_bureau_Yanglao_jin_20211101 >									
	//        < 6Jzh1ch2A04k8cnTr821p4R83o9EstZ5WBfHW7CjO8QGqBvzmLvB11C88fjxAM8r >									
	//        <  u =="0.000000000000000001" : ] 000000211785559.700446000000000000 ; 000000225620244.460788000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014328BC15844E8 >									
	//     < NBI_PFII_I_metadata_line_16_____CRC_CR_Harbin_group_20211101 >									
	//        < 78r13k1tOWkJeRHn71gz53aTA2Y2p3IQ1lE71gnGJtj88rd39P75tR0VArpyMbPL >									
	//        <  u =="0.000000000000000001" : ] 000000225620244.460788000000000000 ; 000000238765213.064064000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015844E816C53A9 >									
	//     < NBI_PFII_I_metadata_line_17_____CRC_CR_Harbin_group_Xianghu_20211101 >									
	//        < G6961N68OXH16w4xBh3Lz1QA8tCuHti2IP808q80nog25Ak350i1zKF5Q1N7iu3B >									
	//        <  u =="0.000000000000000001" : ] 000000238765213.064064000000000000 ; 000000255145063.266141000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016C53A9185520A >									
	//     < NBI_PFII_I_metadata_line_18_____CRC_CR_Harbin_group_Yanglao_jin_20211101 >									
	//        < sMF1ZeOqkQ6vqaJZ8JulQ4U6C7i6760g1Pq7xBjKtSqA200vi17zVz3kWR6xYRVG >									
	//        <  u =="0.000000000000000001" : ] 000000255145063.266141000000000000 ; 000000268409417.475554000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000185520A1998F6E >									
	//     < NBI_PFII_I_metadata_line_19_____CRC_CR_Wuhan_group_20211101 >									
	//        < 0WvV83w1JMZ6k08FBaVLQCpkD33hBq0ahbF1KwEZuQ5fRGHiHO9jIk08AtNPmWwB >									
	//        <  u =="0.000000000000000001" : ] 000000268409417.475554000000000000 ; 000000283938735.247388000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001998F6E1B14192 >									
	//     < NBI_PFII_I_metadata_line_20_____CRC_CR_Wuhan_group_Xianghu_20211101 >									
	//        < 5uBiQ09mXF4T6fXHU27LB84r554T9o3u91slI71w1b37o1Q7M4h6VpuJXAo0dn6r >									
	//        <  u =="0.000000000000000001" : ] 000000283938735.247388000000000000 ; 000000297159015.240529000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B141921C56DBE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NBI_PFII_I_metadata_line_21_____CRC_CR_Wuhan_group_Yanglao_jin_20211101 >									
	//        < zkVRW3IjVrS7TIB0Ff3LyrEU05FsxcMma3K7zke76fc4BheRoM5rb5xv990vA8T3 >									
	//        <  u =="0.000000000000000001" : ] 000000297159015.240529000000000000 ; 000000312768399.108366000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C56DBE1DD3F28 >									
	//     < NBI_PFII_I_metadata_line_22_____CRC_CR_Nanchang_group_20211101 >									
	//        < e3xy3p82ooC6Qw96lOia6dD9bRk8MqjRq04ySShxt4iSTL97LveXh2AJ05rS5NBt >									
	//        <  u =="0.000000000000000001" : ] 000000312768399.108366000000000000 ; 000000329728843.188886000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DD3F281F72054 >									
	//     < NBI_PFII_I_metadata_line_23_____CRC_CR_Nanchang_group_Xianghu_20211101 >									
	//        < yKUp205MCKYGsAK50BybLhlA070EGMh6NTq9RQA27rUZ52EjanxkHBf9G02y4zve >									
	//        <  u =="0.000000000000000001" : ] 000000329728843.188886000000000000 ; 000000344936003.863751000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F7205420E54A0 >									
	//     < NBI_PFII_I_metadata_line_24_____CRC_CR_Nanchang_group_Yanglao_jin_20211101 >									
	//        < fX39pWRa89olk090Ua8hrqkg109bbd9h192nrsJx384VCV3H5v3wg2xBDflL1c9o >									
	//        <  u =="0.000000000000000001" : ] 000000344936003.863751000000000000 ; 000000360281791.409287000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020E54A0225BF13 >									
	//     < NBI_PFII_I_metadata_line_25_____CRC_CR_Xi_an_group_20211101 >									
	//        < 10D02y6BY5ORFn543P80AHh2tAtdhg1Qg666rlcGm96gQs0LAf7h43Y67eIfskB9 >									
	//        <  u =="0.000000000000000001" : ] 000000360281791.409287000000000000 ; 000000375449795.917882000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000225BF1323CE414 >									
	//     < NBI_PFII_I_metadata_line_26_____CRC_CR_Xi_an_group_Xianghu_20211101 >									
	//        < 2fP775E829UP0Om0bb1ZDW18CX8bdK1K48OwOra2v6H631p93P9deJnNwZRtzwTJ >									
	//        <  u =="0.000000000000000001" : ] 000000375449795.917882000000000000 ; 000000388463762.140414000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023CE414250BFA8 >									
	//     < NBI_PFII_I_metadata_line_27_____CRC_CR_Xi_an_group_Yanglao_jin_20211101 >									
	//        < 28hdZVdppLMMNQNAq2C0Z09nj0w493mg8GetxhmOG57n1of4B7x8IIqjGkaH4369 >									
	//        <  u =="0.000000000000000001" : ] 000000388463762.140414000000000000 ; 000000405055929.968404000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000250BFA826A10F9 >									
	//     < NBI_PFII_I_metadata_line_28_____CRC_CR_Taiyuan_group_20211101 >									
	//        < 2Ov0g8bj9018KFivC5HZ5do2P6zTxl5O8FNLj7573yOWM1w0bJO3prBzcv1O8X36 >									
	//        <  u =="0.000000000000000001" : ] 000000405055929.968404000000000000 ; 000000422206171.849249000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026A10F92843C49 >									
	//     < NBI_PFII_I_metadata_line_29_____CRC_CR_Taiyuan_group_Xianghu_20211101 >									
	//        < 6foLc3gkM1y2XEJs0VLS1R3y2N6iLO1o67FopFay2UR6C8hDam8MJ5oNn6KS1jZ6 >									
	//        <  u =="0.000000000000000001" : ] 000000422206171.849249000000000000 ; 000000436402552.089575000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002843C49299E5BF >									
	//     < NBI_PFII_I_metadata_line_30_____CRC_CR_Taiyuan_group_Yanglao_jin_20211101 >									
	//        < b1GzBM6PXrPhvN5C3429U5I05khbklqc6G5tvWc6Az57IHAU5rTCA5CB05Nk71bQ >									
	//        <  u =="0.000000000000000001" : ] 000000436402552.089575000000000000 ; 000000449518497.468659000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000299E5BF2ADE92A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NBI_PFII_I_metadata_line_31_____CRC_CR_container_transport_corp_ltd_20211101 >									
	//        < ZvVN8I3w6Z92PqAzcyNU65AOp68xHe2Jn77vqq1Dbn0rxVC0Sh16746HPuGg97SG >									
	//        <  u =="0.000000000000000001" : ] 000000449518497.468659000000000000 ; 000000466681715.890358000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002ADE92A2C8198C >									
	//     < NBI_PFII_I_metadata_line_32_____cr_container_transport_corp_ltd_cr_international_multimodal_transport_co_ltd_20211101 >									
	//        < MKVFJakK7WUSGv2nu4u0gMh2v86J5M04q48Lg01Sw47Lt9UMSXMav6AThV8PB1E7 >									
	//        <  u =="0.000000000000000001" : ] 000000466681715.890358000000000000 ; 000000481466285.993653000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C8198C2DEA8C5 >									
	//     < NBI_PFII_I_metadata_line_33_____cr_container_transport_corp_ltd_lanzhou_pacific_logistics_corp_ltd_20211101 >									
	//        < l439Jg8Pbbsy9O93cAOV1J08XuDrM63982LWam4nRW235BCTTx5UPq318vnXOb6E >									
	//        <  u =="0.000000000000000001" : ] 000000481466285.993653000000000000 ; 000000498557543.222353000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DEA8C52F8BD0A >									
	//     < NBI_PFII_I_metadata_line_34_____cr_corporation_china_railway_express_co_ltd_20211101 >									
	//        < usyrwcNbTlMC4vV5kqU99p1Mn50t8dno011Jo51DIs7zyIkW81Fk63z0TRqJtIk4 >									
	//        <  u =="0.000000000000000001" : ] 000000498557543.222353000000000000 ; 000000514396309.015603000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F8BD0A310E80F >									
	//     < NBI_PFII_I_metadata_line_35_____cr_corporation_china_railway_lanzhou_group_20211101 >									
	//        < CyfE1Dj0589T71RU18rtHbwL1IvCY4jiKdrIhnvM0SIl1NQg7Z5h8yd1W9BDf4J6 >									
	//        <  u =="0.000000000000000001" : ] 000000514396309.015603000000000000 ; 000000528396925.042688000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000310E80F326450D >									
	//     < NBI_PFII_I_metadata_line_36_____Kunming_group_20211101 >									
	//        < 9i7s1m0lF3Nn4ohmxUZ258rq2Z6d6QTDs3oLtQBg2pqimyvAHQ99TD1il919m7Ep >									
	//        <  u =="0.000000000000000001" : ] 000000528396925.042688000000000000 ; 000000544270769.836030000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000326450D33E7DC5 >									
	//     < NBI_PFII_I_metadata_line_37_____CRC_china_railway_hohhot_group_20211101 >									
	//        < 479JO1P2tP1Vfxsz916V8XizdGw46Kp09bL9110501Lizp509b0y20VOiy45OmJA >									
	//        <  u =="0.000000000000000001" : ] 000000544270769.836030000000000000 ; 000000560844114.543666000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033E7DC5357C7BB >									
	//     < NBI_PFII_I_metadata_line_38_____CRC_china_railway_nanning_group_20211101 >									
	//        < sfqXg1oiYGI7b50IY295jczQ6wyCuum5dK8xAkha4EwsY0IK3df4S7Ox7tlB5c91 >									
	//        <  u =="0.000000000000000001" : ] 000000560844114.543666000000000000 ; 000000576110628.938947000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000357C7BB36F1337 >									
	//     < NBI_PFII_I_metadata_line_39_____CRC_nanning_guangzhou_railway_co_limited_20211101 >									
	//        < 4j60r6DanZ9CVx686WK93zm5099Q25ecl0tybBKcrZC5KyEDqcEK7V114cZHM38z >									
	//        <  u =="0.000000000000000001" : ] 000000576110628.938947000000000000 ; 000000593026049.351810000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036F1337388E2CD >									
	//     < NBI_PFII_I_metadata_line_40_____CRC_high_speed_network_technology_co_20211101 >									
	//        < tQElwiDt287TA4UT4iLeVpffHj7LqF11uvZKDE5hf587213W8q3MjVNvk8ZzEhT4 >									
	//        <  u =="0.000000000000000001" : ] 000000593026049.351810000000000000 ; 000000609466353.628362000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000388E2CD3A1F8CB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}