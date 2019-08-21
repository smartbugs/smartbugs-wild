pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXI_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXI_II_883		"	;
		string	public		symbol =	"	RUSS_PFXI_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		781414319750896000000000000					;	
										
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
	//     < RUSS_PFXI_II_metadata_line_1_____STRAKHOVOI_SINDIKAT_20231101 >									
	//        < k7s29F1Ym80O31V24GyL5aU3LhqoXf17423Otc7x7XZaE1SC2e7808rHZi36p9Wk >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000020737465.608736500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001FA493 >									
	//     < RUSS_PFXI_II_metadata_line_2_____MIKA_RG_20231101 >									
	//        < qppCpLl416AAlx1MtkH49s5phN34Pza5h8SZeM8EVP2n4en0QTBENgtM04jHa53D >									
	//        <  u =="0.000000000000000001" : ] 000000020737465.608736500000000000 ; 000000039416205.711292700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001FA4933C24F5 >									
	//     < RUSS_PFXI_II_metadata_line_3_____RESO_FINANCIAL_MARKETS_20231101 >									
	//        < p8M3mb96HQzxl9SESanPSm9q255TZ5GoyIxD5k55WCL1B3mnG6p0h7m8o6CTo83H >									
	//        <  u =="0.000000000000000001" : ] 000000039416205.711292700000000000 ; 000000061776491.138781200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003C24F55E4371 >									
	//     < RUSS_PFXI_II_metadata_line_4_____LIPETSK_INSURANCE_CHANCE_20231101 >									
	//        < DhMMth64maHJ476M5135x32bLi383Ow6Ze279O7m2c1mto9d5s8soCVqvj4cU800 >									
	//        <  u =="0.000000000000000001" : ] 000000061776491.138781200000000000 ; 000000083906265.293335800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005E43718007E3 >									
	//     < RUSS_PFXI_II_metadata_line_5_____ALVENA_RESO_GROUP_20231101 >									
	//        < lsZ15W2OLZ8sDTmVL23H72xPuYTiz3CDjfBQ6X2N6jiRV7cjqDI76Uxfe5v0Op23 >									
	//        <  u =="0.000000000000000001" : ] 000000083906265.293335800000000000 ; 000000099532861.357230000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008007E397E006 >									
	//     < RUSS_PFXI_II_metadata_line_6_____NADEZHNAYA_LIFE_INSURANCE_20231101 >									
	//        < 2nzZ4dg3V4pFOaRYH3jcV9OQwZDUG9J2T993TsnzX5m6C8VKf986Mo3Q849Y3MtS >									
	//        <  u =="0.000000000000000001" : ] 000000099532861.357230000000000000 ; 000000118223618.517885000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000097E006B4651A >									
	//     < RUSS_PFXI_II_metadata_line_7_____MSK_URALSIB_20231101 >									
	//        < A2m0yoeZdLI9oAaMGWvn0RWg3rTVfITu87w5h1HAgX52P4XKYmupxoHF4S9u6hQc >									
	//        <  u =="0.000000000000000001" : ] 000000118223618.517885000000000000 ; 000000137502964.987871000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B4651AD1D018 >									
	//     < RUSS_PFXI_II_metadata_line_8_____SMO_SIBERIA_20231101 >									
	//        < qotwu46ZuTW38c2EPCS82YeJSOZ7L7Yq1MVUA7k5gmS9025Z72jNwVkd1T7P24Cm >									
	//        <  u =="0.000000000000000001" : ] 000000137502964.987871000000000000 ; 000000160020254.292031000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D1D018F42BE9 >									
	//     < RUSS_PFXI_II_metadata_line_9_____ALFASTRAKHOVANIE_LIFE_20231101 >									
	//        < 4KzWU1fe5m73ydcCRMP39Nq7WR0Pl9e3sI160A5PGjI8ck3NMfPr6YpB5at39Wz0 >									
	//        <  u =="0.000000000000000001" : ] 000000160020254.292031000000000000 ; 000000179474302.898036000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F42BE9111DB26 >									
	//     < RUSS_PFXI_II_metadata_line_10_____AVERS_OOO_20231101 >									
	//        < d710AzTP2qxxA65RnXjG9z1q78pj5L072Mgy7M6ZJFu5C02fCTe2Ns5WJ692RM1h >									
	//        <  u =="0.000000000000000001" : ] 000000179474302.898036000000000000 ; 000000202953484.919966000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000111DB26135AEB4 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXI_II_metadata_line_11_____ALFASTRAKHOVANIE_PLC_20231101 >									
	//        < Z1r3y3HVHiaV870b1H83y88Mo6ql8sn6M49Q9V7SXWd4O64f4e009y4xMss1PPa8 >									
	//        <  u =="0.000000000000000001" : ] 000000202953484.919966000000000000 ; 000000224685295.639775000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000135AEB4156D7B2 >									
	//     < RUSS_PFXI_II_metadata_line_12_____MIDITSINSKAYA_STRAKHOVAYA_KOMP_VIRMED_20231101 >									
	//        < p0u0HB47tMQ2LwWBH46Ks91k7fCC61Q9A0EjB5zaKbRU7cT9Nrn3d7u461e43Bi6 >									
	//        <  u =="0.000000000000000001" : ] 000000224685295.639775000000000000 ; 000000242943063.609943000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000156D7B2172B3A2 >									
	//     < RUSS_PFXI_II_metadata_line_13_____MSK_ASSTRA_20231101 >									
	//        < 54Nd905B29Y6edd4x18M5zD5u9iY5ptNGXhz8Jg38UccW05iK98Jnla6VFPyMu0o >									
	//        <  u =="0.000000000000000001" : ] 000000242943063.609943000000000000 ; 000000259946986.495280000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000172B3A218CA5CB >									
	//     < RUSS_PFXI_II_metadata_line_14_____AVICOS_AFES_INSURANCE_20231101 >									
	//        < VW5kY50Ak459tE64606KEC5L7v5peNSZT0rVUS77178fK25WbXzl1vMwu9s4a9Av >									
	//        <  u =="0.000000000000000001" : ] 000000259946986.495280000000000000 ; 000000278049143.572314000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018CA5CB1A844F2 >									
	//     < RUSS_PFXI_II_metadata_line_15_____RUSSIA_AGRICULTURAL_BANK_20231101 >									
	//        < BuH4435zL6Hu6NTrWt80Va3HG5v0l2l6LFu1kQPtMHS60vta00Bh0kaVuFj7P3kj >									
	//        <  u =="0.000000000000000001" : ] 000000278049143.572314000000000000 ; 000000299242971.124817000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A844F21C89BC9 >									
	//     < RUSS_PFXI_II_metadata_line_16_____BELOGLINSKI_ELEVATOR_20231101 >									
	//        < TIXEE10dR1TTYF4sEex3WFwypc7zQN9eiw29GJNSLeQn28N3c3ibywJ33P1zY8VW >									
	//        <  u =="0.000000000000000001" : ] 000000299242971.124817000000000000 ; 000000318816659.925792000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C89BC91E679C2 >									
	//     < RUSS_PFXI_II_metadata_line_17_____RSHB_CAPITAL_20231101 >									
	//        < 2rpPkFPJos8Hx66eEOyf4f04zpT35F7vNEHiq6sKYM3k7020IC59m1bYsa7v7f58 >									
	//        <  u =="0.000000000000000001" : ] 000000318816659.925792000000000000 ; 000000336689058.964772000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E679C2201BF2A >									
	//     < RUSS_PFXI_II_metadata_line_18_____ALBASHSKIY_ELEVATOR_20231101 >									
	//        < uX6OWNhAuQzopKIHEC1S204lORo6uj5tnK6iEHfn6sDw9EbaKXMiYz8h98p8r971 >									
	//        <  u =="0.000000000000000001" : ] 000000336689058.964772000000000000 ; 000000353317986.858622000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000201BF2A21B1ED7 >									
	//     < RUSS_PFXI_II_metadata_line_19_____AGROTORG_TRADING_CO_20231101 >									
	//        < WY0Qh92312YJwPydDiCB1Fx2K0g84u84nL86vKzR8wRLvhKEe36Y2Ei4WqP246m0 >									
	//        <  u =="0.000000000000000001" : ] 000000353317986.858622000000000000 ; 000000370502853.379319000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021B1ED723557AD >									
	//     < RUSS_PFXI_II_metadata_line_20_____HOMIAKOVSKIY_COLD_STORAGE_COMPLEX_20231101 >									
	//        < xtTVDX4uhV0tUl357k6I884eV3QZlW4AHXAecj9Ej5C2Z9Hk76k1C39D5yut8S3R >									
	//        <  u =="0.000000000000000001" : ] 000000370502853.379319000000000000 ; 000000386862867.806161000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023557AD24E4E4F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXI_II_metadata_line_21_____AGROCREDIT_INFORM_20231101 >									
	//        < 7SFGuH09qigNvL7YY12782DpU9c9pnih544PRgkV1AV92piBjtiP9xkUt991T4nM >									
	//        <  u =="0.000000000000000001" : ] 000000386862867.806161000000000000 ; 000000409050467.672135000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024E4E4F2702957 >									
	//     < RUSS_PFXI_II_metadata_line_22_____LADOSHSKIY_ELEVATOR_20231101 >									
	//        < 35ApgQ2FW8TEx1w2E0TJUV9LY9h5QNbi0944WA4u3A7BzkPQXrIl6p9D7TkgnjW6 >									
	//        <  u =="0.000000000000000001" : ] 000000409050467.672135000000000000 ; 000000425761986.988834000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002702957289A947 >									
	//     < RUSS_PFXI_II_metadata_line_23_____VELICHKOVSKIY_ELEVATOR_20231101 >									
	//        < SwkeZV3F7lU8P07KE130imo57NAJH0tVkYCBeEfRj9P90SNIe87Q6s67w95o5aSU >									
	//        <  u =="0.000000000000000001" : ] 000000425761986.988834000000000000 ; 000000443307289.207365000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000289A9472A46EE9 >									
	//     < RUSS_PFXI_II_metadata_line_24_____UMANSKIY_ELEVATOR_20231101 >									
	//        < R0pow955GJQVWuc04QHq741Te09i1E1tUaL6rxh21xF8hf6br2qloNwI1auS8Spx >									
	//        <  u =="0.000000000000000001" : ] 000000443307289.207365000000000000 ; 000000462390827.155040000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A46EE92C18D6B >									
	//     < RUSS_PFXI_II_metadata_line_25_____MALOROSSIYSKIY_ELEVATOR_20231101 >									
	//        < h1vdKx1y945nH6516gy2i99T8tul9wVXP8jtB96XAobS13S4L5uNicHU5JAAudLQ >									
	//        <  u =="0.000000000000000001" : ] 000000462390827.155040000000000000 ; 000000482253438.557762000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C18D6B2DFDC40 >									
	//     < RUSS_PFXI_II_metadata_line_26_____ROSSELKHOZBANK_DOMINANT_20231101 >									
	//        < E3atn5snOMaOtxG4H2g1Pemj186Or1IL40us0qMCsx31368hjn32n79E8Vh9caKE >									
	//        <  u =="0.000000000000000001" : ] 000000482253438.557762000000000000 ; 000000505211129.834329000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DFDC40302E419 >									
	//     < RUSS_PFXI_II_metadata_line_27_____RAEVSAKHAR_20231101 >									
	//        < rW383Xq6f3I7NJ69658370obsKd68GR6Odf5yb5CdRVcKr83vv2e8OnFOsZkwc9x >									
	//        <  u =="0.000000000000000001" : ] 000000505211129.834329000000000000 ; 000000521223904.565231000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000302E41931B5316 >									
	//     < RUSS_PFXI_II_metadata_line_28_____OPTOVYE_TEKHNOLOGII_20231101 >									
	//        < E25q0H945U35VA82S8oX51wQGmxnAXsHf64795j2967wT4Ev7YehXGgKWtTA6085 >									
	//        <  u =="0.000000000000000001" : ] 000000521223904.565231000000000000 ; 000000538567690.099945000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031B5316335CA01 >									
	//     < RUSS_PFXI_II_metadata_line_29_____EYANSKI_ELEVATOR_20231101 >									
	//        < K22M2L9B1chde2wyrPG6762y1K94qIlBZV3Mr33XBgbKWA67K1Kyfhq0nzIIhoHT >									
	//        <  u =="0.000000000000000001" : ] 000000538567690.099945000000000000 ; 000000556743423.633663000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000335CA0135185E6 >									
	//     < RUSS_PFXI_II_metadata_line_30_____RUSSIAN_AGRARIAN_FUEL_CO_20231101 >									
	//        < qb9WK17L715xivf2R4kyPV5993i1Wi90IUR6ro8tn92W47IB1pOK50cv80v6ZaxN >									
	//        <  u =="0.000000000000000001" : ] 000000556743423.633663000000000000 ; 000000576169658.160185000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035185E636F2A46 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXI_II_metadata_line_31_____KHOMYAKOVSKY_KHLADOKOMBINAT_20231101 >									
	//        < pwBBouU7a132u23Ndpqlq7tIrqam55c6LibQUEyO39QGmU71Ri454j8H8fKC5Li4 >									
	//        <  u =="0.000000000000000001" : ] 000000576169658.160185000000000000 ; 000000597733735.199822000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036F2A4639011BE >									
	//     < RUSS_PFXI_II_metadata_line_32_____STEPNYANSKIY_ELEVATOR_20231101 >									
	//        < 390B30x689t3Hij7C7AO800GEK2507ntZsw4iCPG2O5dq781ey6ho65f5kupPl83 >									
	//        <  u =="0.000000000000000001" : ] 000000597733735.199822000000000000 ; 000000620750642.901849000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039011BE3B330B8 >									
	//     < RUSS_PFXI_II_metadata_line_33_____ROVNENSKIY_ELEVATOR_20231101 >									
	//        < 6ekM0aoaEF238OD4lizYq5bl85T56nHj0W4N4nRd17eBfi97ACl7XQh75R1uFXQ7 >									
	//        <  u =="0.000000000000000001" : ] 000000620750642.901849000000000000 ; 000000645444872.829188000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B330B83D8DEE7 >									
	//     < RUSS_PFXI_II_metadata_line_34_____KHOMYAKOVSKIY_COLD_STORAGE_FACILITY_20231101 >									
	//        < Bo1K888re8R8K7K9CD8K3IxiU5U2zNp6Z8qwqB95W1vFNET9i9WUG26QVhaUoRMr >									
	//        <  u =="0.000000000000000001" : ] 000000645444872.829188000000000000 ; 000000666819654.019824000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D8DEE73F97C6D >									
	//     < RUSS_PFXI_II_metadata_line_35_____BRIGANTINA_OOO_20231101 >									
	//        < phs2V7229ZEVGs36G9EbmjS0W3M4805YrbYjv42VZOh045Y0eV9g04n5tJ5mFqe2 >									
	//        <  u =="0.000000000000000001" : ] 000000666819654.019824000000000000 ; 000000684104766.771969000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F97C6D413DC6D >									
	//     < RUSS_PFXI_II_metadata_line_36_____RUS_AGRICULTURAL_BANK_AM_ARM_20231101 >									
	//        < oQ3t5O3nHPR1HOM5qmIiqk7hWVMFRnzxit1CV5ipZ4wky3W4BcV42ZkdqMoOQcI8 >									
	//        <  u =="0.000000000000000001" : ] 000000684104766.771969000000000000 ; 000000705315854.531033000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000413DC6D4343A01 >									
	//     < RUSS_PFXI_II_metadata_line_37_____LUZHSKIY_FEEDSTUFF_PLANT_20231101 >									
	//        < KmqTbYlQ8UVl1pWPbS4itV7a56K8dho8CC6mK6VWoC2IUlXk2Y4HuBKRktJYT7C4 >									
	//        <  u =="0.000000000000000001" : ] 000000705315854.531033000000000000 ; 000000720737221.562994000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004343A0144BC1FA >									
	//     < RUSS_PFXI_II_metadata_line_38_____LUZHSKIY_MYASOKOMBINAT_20231101 >									
	//        < 5G6A6VE6cB5Mu7xs0237C9eY76nfCV83mN3E7HBCYS2Jsk94g7F4qRJs1v29PDCw >									
	//        <  u =="0.000000000000000001" : ] 000000720737221.562994000000000000 ; 000000742110217.103215000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044BC1FA46C5ECE >									
	//     < RUSS_PFXI_II_metadata_line_39_____LUGA_FODDER_PLANT_20231101 >									
	//        < 52MsR6e04tvmYWkc2ObJEISqEYt0557yYqL0bfRAYhx7xCGrpFGQ56u49BqxYFbk >									
	//        <  u =="0.000000000000000001" : ] 000000742110217.103215000000000000 ; 000000762091958.318148000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046C5ECE48ADC2C >									
	//     < RUSS_PFXI_II_metadata_line_40_____KRILOVSKIY_ELEVATOR_20231101 >									
	//        < uDQ4fzjCc763QfKkYAUHRh19V4q2CsCF4aVa3nrXg30vk3O3618xskts4AKEBwXw >									
	//        <  u =="0.000000000000000001" : ] 000000762091958.318148000000000000 ; 000000781414319.750896000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048ADC2C4A857F8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}