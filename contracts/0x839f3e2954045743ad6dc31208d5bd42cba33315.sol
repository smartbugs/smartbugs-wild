pragma solidity 		^0.4.21	;						
										
	contract	NBI_PFII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NBI_PFII_III_883		"	;
		string	public		symbol =	"	NBI_PFII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1059037558206030000000000000					;	
										
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
	//     < NBI_PFII_III_metadata_line_1_____CRC_CR_Beijing_group_20251101 >									
	//        < sDwxK0mI2f1au0jlCe3ry9WGX3scnPH1Y8CvY0NHmcE5YT7NIUr57Q2TJU1YY51W >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000018876926.687186400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001CCDCD >									
	//     < NBI_PFII_III_metadata_line_2_____CRC_CR_Qingzang_group_20251101 >									
	//        < M7i21MFFTSgRF5548mSFWLm8AakTf5z1D0Pw2Z3tMqF2lNH41MZC4k5fmXg1fvx2 >									
	//        <  u =="0.000000000000000001" : ] 000000018876926.687186400000000000 ; 000000038636098.197384900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001CCDCD3AF43A >									
	//     < NBI_PFII_III_metadata_line_3_____Chengdu_railway_bureau_20251101 >									
	//        < kS3J8E5BY27tChIpaP4nTcq01xe74h509gPd54pN3vQmx8q3FJS9IV8m69s5XA73 >									
	//        <  u =="0.000000000000000001" : ] 000000038636098.197384900000000000 ; 000000059041073.646919100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003AF43A5A16EB >									
	//     < NBI_PFII_III_metadata_line_4_____Chengdu_railway_bureau_Xianghu_20251101 >									
	//        < 3JeDw1B4ry9Ft9qW99kWmj72u8IM33Uz9a4w0Fz2RP7TZV6u2O6QA6ZDRPXxWPjI >									
	//        <  u =="0.000000000000000001" : ] 000000059041073.646919100000000000 ; 000000086634253.111281900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005A16EB843181 >									
	//     < NBI_PFII_III_metadata_line_5_____Chengdu_railway_bureau_Yanglao_jin_20251101 >									
	//        < aiW98lVY6an8xWKix6bDTM2YiXt2sUGfCN2K26RX0b5R1P1w49H1amRc18mQ65O3 >									
	//        <  u =="0.000000000000000001" : ] 000000086634253.111281900000000000 ; 000000109421966.414495000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000843181A6F6F5 >									
	//     < NBI_PFII_III_metadata_line_6_____cr_Chengdu_group_chengdu_railway_bureau_xichang_railway_branch_20251101 >									
	//        < aG8R8IPZrwms3JPPtqPg9Q01muYvG24QhSLKQUgj28FDGm01S96c48C72Ge4gBM1 >									
	//        <  u =="0.000000000000000001" : ] 000000109421966.414495000000000000 ; 000000138187553.441702000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A6F6F5D2DB83 >									
	//     < NBI_PFII_III_metadata_line_7_____CRC_CR_Urumqi_group_20251101 >									
	//        < 0V8QoYl3f7VdEuT1jdA0J2p515ujx8lGSq1E3AkGefdUT4w1Cm1kI8Ea4QZxksyA >									
	//        <  u =="0.000000000000000001" : ] 000000138187553.441702000000000000 ; 000000163858202.189055000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D2DB83FA071C >									
	//     < NBI_PFII_III_metadata_line_8_____CRC_CR_Urumqi_group_Xianghu_20251101 >									
	//        < 4a936F0p2bCGSSOSrhygY7C9aQJh26EY9bXRE29qPPwo9X6js500cSG6Z151BHh1 >									
	//        <  u =="0.000000000000000001" : ] 000000163858202.189055000000000000 ; 000000185177441.759177000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FA071C11A8EF0 >									
	//     < NBI_PFII_III_metadata_line_9_____CRC_CR_Urumqi_group_Yanglao_jin_20251101 >									
	//        < 1VQ0U0v7btepi5CK88w8041b2Py0SF17B9DPp5W5m7E1795g64VzZ40n808JC8h7 >									
	//        <  u =="0.000000000000000001" : ] 000000185177441.759177000000000000 ; 000000208727744.725590000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011A8EF013E7E46 >									
	//     < NBI_PFII_III_metadata_line_10_____CRC_CR_Zhengzhou_group_20251101 >									
	//        < 9JJ30p1uX2bhyTyiOt23pe47Sn2sGc4yjE46I995355izQ00MOEB8yqq9558460h >									
	//        <  u =="0.000000000000000001" : ] 000000208727744.725590000000000000 ; 000000240992274.188184000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013E7E4616FB99B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NBI_PFII_III_metadata_line_11_____CRC_CR_Zhengzhou_group_Xianghu_20251101 >									
	//        < n34L95xm6yuK0csoVMFgmIYZ7ELO1CNgU9RhthT7998yrxraraCuVX2v4J3W5wE9 >									
	//        <  u =="0.000000000000000001" : ] 000000240992274.188184000000000000 ; 000000266461972.114262000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016FB99B19696B5 >									
	//     < NBI_PFII_III_metadata_line_12_____CRC_CR_Zhengzhou_group_Yanglao_jin_20251101 >									
	//        < qc4C0H3Inh112b2zNy1VFJO5iEE7T1k71V7EvG5UuKig4c2fj5QoBT09xIIfPE9g >									
	//        <  u =="0.000000000000000001" : ] 000000266461972.114262000000000000 ; 000000301877236.979322000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019696B51CCA0CC >									
	//     < NBI_PFII_III_metadata_line_13_____CRC_Shenyang_railways_bureau_20251101 >									
	//        < 18nl89oXD0O925iZd4e7256L8ze2O8O6O6UgTSDGx7G49vc76FV7TAFQN6EOg1n6 >									
	//        <  u =="0.000000000000000001" : ] 000000301877236.979322000000000000 ; 000000325158552.724442000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CCA0CC1F0270F >									
	//     < NBI_PFII_III_metadata_line_14_____CRC_Shenyang_railways_bureau_Xianghu_20251101 >									
	//        < YkGS6UI61NrVc6o171c3stYvd6uHhzgOugqb85s5Ikq8YT2eSV76LokbCTMnbBVl >									
	//        <  u =="0.000000000000000001" : ] 000000325158552.724442000000000000 ; 000000353962125.704571000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F0270F21C1A75 >									
	//     < NBI_PFII_III_metadata_line_15_____CRC_Shenyang_railways_bureau_Yanglao_jin_20251101 >									
	//        < 36XORoavDNdBLVoCc3rESw53P2091357J8yA9M43nU3KtWtmx1It6yHFMp2586H2 >									
	//        <  u =="0.000000000000000001" : ] 000000353962125.704571000000000000 ; 000000376908228.284040000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021C1A7523F1DC7 >									
	//     < NBI_PFII_III_metadata_line_16_____CRC_CR_Harbin_group_20251101 >									
	//        < O1R200wSDg4OuNm7eP5Rsthb7y8mPh0nC6zXkTDEtqZc3cT6d3O27d5nAJP2zEuR >									
	//        <  u =="0.000000000000000001" : ] 000000376908228.284040000000000000 ; 000000395493899.992103000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023F1DC725B79CE >									
	//     < NBI_PFII_III_metadata_line_17_____CRC_CR_Harbin_group_Xianghu_20251101 >									
	//        < s970SklnT1enrl0lon480p2cITWf7B6344oaFpd6RIIrOlh7GI0YY4eO4h6tbc2O >									
	//        <  u =="0.000000000000000001" : ] 000000395493899.992103000000000000 ; 000000415869289.878158000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025B79CE27A90F1 >									
	//     < NBI_PFII_III_metadata_line_18_____CRC_CR_Harbin_group_Yanglao_jin_20251101 >									
	//        < 5Wc1i2Ua8ycl7nwlmmr15xnA03BY1tqzB0fB7yD4ksg8ReudwIqbZrnYd5r6858Q >									
	//        <  u =="0.000000000000000001" : ] 000000415869289.878158000000000000 ; 000000450543574.333451000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027A90F12AF7995 >									
	//     < NBI_PFII_III_metadata_line_19_____CRC_CR_Wuhan_group_20251101 >									
	//        < BNX04XbjVPj9K1T50I57mokV4zejeuSFq453ic14WW0fnyRMRk8r82E987s8MJL8 >									
	//        <  u =="0.000000000000000001" : ] 000000450543574.333451000000000000 ; 000000485856339.505658000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AF79952E55BA2 >									
	//     < NBI_PFII_III_metadata_line_20_____CRC_CR_Wuhan_group_Xianghu_20251101 >									
	//        < TtHfSQ4q529c5B88cIpVIqxEy2q4xJ8WB4nc7Pyc0N177S48TH7Q26141N2OnrnH >									
	//        <  u =="0.000000000000000001" : ] 000000485856339.505658000000000000 ; 000000518418203.223150000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E55BA23170B1C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NBI_PFII_III_metadata_line_21_____CRC_CR_Wuhan_group_Yanglao_jin_20251101 >									
	//        < 9C63p09anfWDK012WoMeDaz2m2UkhV1VWGxU15742vbT2dF6zq0cb8Eahh7V8P7E >									
	//        <  u =="0.000000000000000001" : ] 000000518418203.223150000000000000 ; 000000538454469.456659000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003170B1C3359DC7 >									
	//     < NBI_PFII_III_metadata_line_22_____CRC_CR_Nanchang_group_20251101 >									
	//        < umZ3J09n820Q198sBkDa7L0hfx6UMUpt54OL49V28bmS5elqCl55jzgxa3vTYmn9 >									
	//        <  u =="0.000000000000000001" : ] 000000538454469.456659000000000000 ; 000000569970038.692980000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003359DC7365B48C >									
	//     < NBI_PFII_III_metadata_line_23_____CRC_CR_Nanchang_group_Xianghu_20251101 >									
	//        < Xe8q7005bZEXhklRIyP1H1N3YLW05ymXpOkUxA7611sIpL460kwz74kxk3BjaTQE >									
	//        <  u =="0.000000000000000001" : ] 000000569970038.692980000000000000 ; 000000602881939.359929000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000365B48C397ECC2 >									
	//     < NBI_PFII_III_metadata_line_24_____CRC_CR_Nanchang_group_Yanglao_jin_20251101 >									
	//        < RG3P55AtMfe0jePLNv1ed89r9v0HAK6sL25now8wCTo7MIVzI3Dud2C538QAbTL9 >									
	//        <  u =="0.000000000000000001" : ] 000000602881939.359929000000000000 ; 000000638138138.646447000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000397ECC23CDB8B6 >									
	//     < NBI_PFII_III_metadata_line_25_____CRC_CR_Xi_an_group_20251101 >									
	//        < 8TcByTY3wfF5159Y6H5Y4EtDbPLjbRO5rZmh1GZ6i39jajeuqFSAYr41VIhh8etG >									
	//        <  u =="0.000000000000000001" : ] 000000638138138.646447000000000000 ; 000000662470190.110878000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003CDB8B63F2D96B >									
	//     < NBI_PFII_III_metadata_line_26_____CRC_CR_Xi_an_group_Xianghu_20251101 >									
	//        < 2ngiFW64kQISSLps07AqQcm693vQsGSO9LbykO1xAv46Kam6O3y0QJbQ1zNXi3J2 >									
	//        <  u =="0.000000000000000001" : ] 000000662470190.110878000000000000 ; 000000683024910.672099000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F2D96B412369B >									
	//     < NBI_PFII_III_metadata_line_27_____CRC_CR_Xi_an_group_Yanglao_jin_20251101 >									
	//        < 9Uu2m4S79wyJ3FV7qNL8P9q2zLJ61GHCv8Cq63zsWi4zx1e7Cb6O1f9i1O5fN2j0 >									
	//        <  u =="0.000000000000000001" : ] 000000683024910.672099000000000000 ; 000000718369237.307448000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000412369B44824FC >									
	//     < NBI_PFII_III_metadata_line_28_____CRC_CR_Taiyuan_group_20251101 >									
	//        < y136xi6b1O032Omo1H4OvIu3n274XNZMa3d7CWYPu7LEn3gIo16JdvMf55G7zDnK >									
	//        <  u =="0.000000000000000001" : ] 000000718369237.307448000000000000 ; 000000741676642.076521000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044824FC46BB570 >									
	//     < NBI_PFII_III_metadata_line_29_____CRC_CR_Taiyuan_group_Xianghu_20251101 >									
	//        < 4sfzvsQ0sv37gho8xyQ3s9LMXmlgIThHhQ0K7lV6Y7t4ZA1Cr2dq0At21XC9P6m4 >									
	//        <  u =="0.000000000000000001" : ] 000000741676642.076521000000000000 ; 000000771675180.499817000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046BB5704997B9E >									
	//     < NBI_PFII_III_metadata_line_30_____CRC_CR_Taiyuan_group_Yanglao_jin_20251101 >									
	//        < SLadL7b2Uwe0LL9KthCu7mP9WQJeQ7ccq1tq3mU6uWtjqg26rg1gRD052D9pR721 >									
	//        <  u =="0.000000000000000001" : ] 000000771675180.499817000000000000 ; 000000794989395.598212000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004997B9E4BD0EBC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NBI_PFII_III_metadata_line_31_____CRC_CR_container_transport_corp_ltd_20251101 >									
	//        < pyaFVJI6Hbw6AXkXiXsmUKK0P0xACS9bDk56y4GgvK00D84yWVx3rtaIpWSZL3s8 >									
	//        <  u =="0.000000000000000001" : ] 000000794989395.598212000000000000 ; 000000814594816.948797000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004BD0EBC4DAF91A >									
	//     < NBI_PFII_III_metadata_line_32_____cr_container_transport_corp_ltd_cr_international_multimodal_transport_co_ltd_20251101 >									
	//        < sq4eLq31Jh7JUsk5sF5ux6K6Rv1t736m4q2E7PHOkV3V3U9KBFwA1J7QkBQeop50 >									
	//        <  u =="0.000000000000000001" : ] 000000814594816.948797000000000000 ; 000000848648400.363664000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004DAF91A50EEF48 >									
	//     < NBI_PFII_III_metadata_line_33_____cr_container_transport_corp_ltd_lanzhou_pacific_logistics_corp_ltd_20251101 >									
	//        < BHm29iMX79C0rk0j67XFMk23U37unDUY43EmUOm0176kp8Q01C11Iyax0XB2fRrl >									
	//        <  u =="0.000000000000000001" : ] 000000848648400.363664000000000000 ; 000000875416762.174326000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000050EEF48537C7AC >									
	//     < NBI_PFII_III_metadata_line_34_____cr_corporation_china_railway_express_co_ltd_20251101 >									
	//        < MiS7IyZaz58IAc3R0H3mtSiyIUVY6Ht8W15HvS1Xd89YCXNOos154JLlW0xc20fE >									
	//        <  u =="0.000000000000000001" : ] 000000875416762.174326000000000000 ; 000000900311542.589389000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000537C7AC55DC432 >									
	//     < NBI_PFII_III_metadata_line_35_____cr_corporation_china_railway_lanzhou_group_20251101 >									
	//        < Au0u9NIggfpcgq8kC8XvM3IeflMG1u9287Nx2ZG97T0SPs3aiFy2S525ic2Oq9mP >									
	//        <  u =="0.000000000000000001" : ] 000000900311542.589389000000000000 ; 000000931208442.688640000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000055DC43258CE94C >									
	//     < NBI_PFII_III_metadata_line_36_____Kunming_group_20251101 >									
	//        < bzgfQrIEevcebzWzSVI6PQb1oO52qQ6Vbfk6EeBb6g1Hc71Y0GrF4ZkUF8A4Nd3o >									
	//        <  u =="0.000000000000000001" : ] 000000931208442.688640000000000000 ; 000000952271108.086801000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000058CE94C5AD0CE7 >									
	//     < NBI_PFII_III_metadata_line_37_____CRC_china_railway_hohhot_group_20251101 >									
	//        < GiY6v9u9aAe6V4fNYTJE2i0un3LiE27E2yXfSlT3abw4JZ7F50672qDqxrcGa07F >									
	//        <  u =="0.000000000000000001" : ] 000000952271108.086801000000000000 ; 000000977988577.658646000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005AD0CE75D44ACA >									
	//     < NBI_PFII_III_metadata_line_38_____CRC_china_railway_nanning_group_20251101 >									
	//        < ZZY4c3lZ24MQ5rGJlY9iKN0S7D1bLnP8MAEirQteNTtLM6b3e2hhrDP6JM6bx3O8 >									
	//        <  u =="0.000000000000000001" : ] 000000977988577.658646000000000000 ; 000001007453294.827300000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005D44ACA6014071 >									
	//     < NBI_PFII_III_metadata_line_39_____CRC_nanning_guangzhou_railway_co_limited_20251101 >									
	//        < 89Vldy1Fi81N5ZmTxdksRi5Kf0dDyYnVq4J3t9p1lp3A8Uz9dl37lb99dy4TxZ0X >									
	//        <  u =="0.000000000000000001" : ] 000001007453294.827300000000000000 ; 000001040716481.878350000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000601407163401E0 >									
	//     < NBI_PFII_III_metadata_line_40_____CRC_high_speed_network_technology_co_20251101 >									
	//        < beTjS294178V2sYh45yO456y6YFej58Uh0c6v29mB257S99hQkQX6yb4qknd4np4 >									
	//        <  u =="0.000000000000000001" : ] 000001040716481.878350000000000000 ; 000001059037558.206030000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000063401E064FF68C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}