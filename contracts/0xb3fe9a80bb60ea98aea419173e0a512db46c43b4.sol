pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXX_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXX_I_883		"	;
		string	public		symbol =	"	RUSS_PFXX_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		609784078829287000000000000					;	
										
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
	//     < RUSS_PFXX_I_metadata_line_1_____Eurochem_20211101 >									
	//        < cE33a9EqTa7l2GsvlnqCSK02R7K1g0reyGdar04NheUhkUqb7FCsQ0TWj5Y2yM9Q >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000016111592.837910700000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000189597 >									
	//     < RUSS_PFXX_I_metadata_line_2_____Eurochem_Group_AG_Switzerland_20211101 >									
	//        < n3J0Ea77Aw1M1b7STX1u5fl9vefLsX2d7sSwba07IVef5ru7IfcBLLDBSfZi0ULq >									
	//        <  u =="0.000000000000000001" : ] 000000016111592.837910700000000000 ; 000000030189882.593236800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001895972E10EC >									
	//     < RUSS_PFXX_I_metadata_line_3_____Industrial _Group_Phosphorite_20211101 >									
	//        < jBQ8fXdX1Zqb2q70nsqdf9KK7ng8OES2PLE89x9YXDtx1pU0BtAK37YPPQZtEAly >									
	//        <  u =="0.000000000000000001" : ] 000000030189882.593236800000000000 ; 000000045359079.216669600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002E10EC453664 >									
	//     < RUSS_PFXX_I_metadata_line_4_____Novomoskovsky_Azot_20211101 >									
	//        < TE5B6FbMDBFzdO3r990687Q39QE704MRZ5Fl4677Tap9L7LYhM8zOk5KN34KzNsG >									
	//        <  u =="0.000000000000000001" : ] 000000045359079.216669600000000000 ; 000000060979268.249103100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004536645D0C07 >									
	//     < RUSS_PFXX_I_metadata_line_5_____Novomoskovsky_Chlor_20211101 >									
	//        < Cyu21LFX770RvdPAogU7fp9sB962l562NZgqTC394EgYOxttff9QXItLy0L3lWN3 >									
	//        <  u =="0.000000000000000001" : ] 000000060979268.249103100000000000 ; 000000076709616.097860600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005D0C07750CB2 >									
	//     < RUSS_PFXX_I_metadata_line_6_____Nevinnomyssky_Azot_20211101 >									
	//        < 9E3XoEW5MuX6Va933473mK2ENbh8xdPt09WD5o61CDIpwa8GCE7YiGFtE9DI6G8D >									
	//        <  u =="0.000000000000000001" : ] 000000076709616.097860600000000000 ; 000000092746205.347996800000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000750CB28D84FD >									
	//     < RUSS_PFXX_I_metadata_line_7_____EuroChem_Belorechenskie_Minudobrenia_20211101 >									
	//        < h4157Vz53B3ABoU81dv78ElPtb1x7utp9D8Ow0ac4xDi6Dkoo6RKA3R148C3R7V0 >									
	//        <  u =="0.000000000000000001" : ] 000000092746205.347996800000000000 ; 000000109131414.089109000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008D84FDA68575 >									
	//     < RUSS_PFXX_I_metadata_line_8_____Kovdorsky_GOK_20211101 >									
	//        < x3nyFu3j2D06B4n9F16dGjZY22yRo029fmTRy166bD9B7TbHy2dg6LcsncletCHS >									
	//        <  u =="0.000000000000000001" : ] 000000109131414.089109000000000000 ; 000000126188513.155551000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A68575C08C63 >									
	//     < RUSS_PFXX_I_metadata_line_9_____Lifosa_AB_20211101 >									
	//        < QQ7Wh64681aoNX7Jy0GMsbnu7RE4nwF9aEFCp526F1clsrUfY40V6X11g0b89lh9 >									
	//        <  u =="0.000000000000000001" : ] 000000126188513.155551000000000000 ; 000000142661605.898496000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C08C63D9AF31 >									
	//     < RUSS_PFXX_I_metadata_line_10_____EuroChem_Antwerpen_NV_20211101 >									
	//        < N1Z9zH7gCVr12s8cP8y5XpNPD9Z9rrh87B7Qmt9fssA9fCO9ap8ML85WUlh9D7sb >									
	//        <  u =="0.000000000000000001" : ] 000000142661605.898496000000000000 ; 000000157884725.945988000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D9AF31F0E9B9 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXX_I_metadata_line_11_____EuroChem_VolgaKaliy_20211101 >									
	//        < J85M87t17MYo9CvF7z8mg73D0w4nk085Aplw622ZdNt0oGV76Ac9JbNgcA09HVZ4 >									
	//        <  u =="0.000000000000000001" : ] 000000157884725.945988000000000000 ; 000000172115563.201456000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F0E9B9106A0A4 >									
	//     < RUSS_PFXX_I_metadata_line_12_____EuroChem_Usolsky_potash_complex_20211101 >									
	//        < 430r05Dn1t6OqK22cD6F6t69frzed5BZTd3wd9Zys7MV7dEQZBeI3T8UW1715mua >									
	//        <  u =="0.000000000000000001" : ] 000000172115563.201456000000000000 ; 000000185989190.901685000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000106A0A411BCC07 >									
	//     < RUSS_PFXX_I_metadata_line_13_____EuroChem_ONGK_20211101 >									
	//        < 5ls26f25J455UUc9qcd14JCoCI84Yo0T8UQl71wy1YN3fQ3bM9j776av9T6zv1q2 >									
	//        <  u =="0.000000000000000001" : ] 000000185989190.901685000000000000 ; 000000201666989.675295000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011BCC07133B82B >									
	//     < RUSS_PFXX_I_metadata_line_14_____EuroChem_Northwest_20211101 >									
	//        < kqJ7373ksjhpN2k9y2ICNYs7IT6oGUTq095L6J16GbB75vfce5ntaSft8g0pfLMs >									
	//        <  u =="0.000000000000000001" : ] 000000201666989.675295000000000000 ; 000000215946371.333988000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000133B82B149820D >									
	//     < RUSS_PFXX_I_metadata_line_15_____EuroChem_Fertilizers_20211101 >									
	//        < fVe1KA61zu56fBcMgG68IYS6wH3hf9sApI961RysU5tRXxX72GLaMadZNlms6qSV >									
	//        <  u =="0.000000000000000001" : ] 000000215946371.333988000000000000 ; 000000229274549.931733000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000149820D15DD85F >									
	//     < RUSS_PFXX_I_metadata_line_16_____Astrakhan_Oil_and_Gas_Company_20211101 >									
	//        < 625VD130WHzs22fKcXeC0rnvN76r1NOi8JiR77A6D9808QUo7DFm4MeFvjOvIK3K >									
	//        <  u =="0.000000000000000001" : ] 000000229274549.931733000000000000 ; 000000242724829.006200000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015DD85F1725E63 >									
	//     < RUSS_PFXX_I_metadata_line_17_____Sary_Tas_Fertilizers_20211101 >									
	//        < 44z732H3ch434VneTO72rl90Jj1QP4TqOaiBT0Rio4SbNaE3geKX4RzL2855n35q >									
	//        <  u =="0.000000000000000001" : ] 000000242724829.006200000000000000 ; 000000258760667.746152000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001725E6318AD663 >									
	//     < RUSS_PFXX_I_metadata_line_18_____EuroChem_Karatau_20211101 >									
	//        < 03A6ULXI6PO03H0BQGoNq0K2fSB916DmoJ0PhEuCGNI2843DI3s947nag050xkh5 >									
	//        <  u =="0.000000000000000001" : ] 000000258760667.746152000000000000 ; 000000272140467.618992000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018AD66319F40DF >									
	//     < RUSS_PFXX_I_metadata_line_19_____Kamenkovskaya_Oil_Gas_Company_20211101 >									
	//        < Hdnsp31g7w1KMm1WTMK9xg2qr83hGjhN85Od9WND3yE6Fq5j7piVSiGyUNk6o0GP >									
	//        <  u =="0.000000000000000001" : ] 000000272140467.618992000000000000 ; 000000287465872.260319000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019F40DF1B6A35B >									
	//     < RUSS_PFXX_I_metadata_line_20_____EuroChem_Trading_GmbH_Trading_20211101 >									
	//        < jv1z68svE6gi0tP2efZ6JZ6u0TGib17755s0CY26VF6CA8H1K06Nx93639dYcr9z >									
	//        <  u =="0.000000000000000001" : ] 000000287465872.260319000000000000 ; 000000303065939.264622000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B6A35B1CE7122 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXX_I_metadata_line_21_____EuroChem_Trading_USA_Corp_20211101 >									
	//        < kf89qO8C461hX4m2Q0m1T3Kgaxe9v4y0RCiAJ75Trvrft66puiJ14AVl756FKf87 >									
	//        <  u =="0.000000000000000001" : ] 000000303065939.264622000000000000 ; 000000318275794.636901000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CE71221E5A67B >									
	//     < RUSS_PFXX_I_metadata_line_22_____Ben_Trei_Ltd_20211101 >									
	//        < cq6660u6t02Eo0v0oO8HLairR90BZoQ2z8KE8pm4cwuT88Fj3jt3RiHtHd517jwd >									
	//        <  u =="0.000000000000000001" : ] 000000318275794.636901000000000000 ; 000000331880057.569792000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E5A67B1FA68A6 >									
	//     < RUSS_PFXX_I_metadata_line_23_____EuroChem_Agro_SAS_20211101 >									
	//        < U252Kb5l93tIM2t998n9g0588bwZfPZyhJOCZw2PQQwvH6tvSLcpjsIJBAmSGB1x >									
	//        <  u =="0.000000000000000001" : ] 000000331880057.569792000000000000 ; 000000347922319.971058000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FA68A6212E328 >									
	//     < RUSS_PFXX_I_metadata_line_24_____EuroChem_Agro_Asia_20211101 >									
	//        < 0ucP6WlHKD263yCxQ9Cy0HRHesSv563xrHXQZEpnA2jtmMS75fSMEuxGuTDlt5mP >									
	//        <  u =="0.000000000000000001" : ] 000000347922319.971058000000000000 ; 000000361971593.197299000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000212E3282285327 >									
	//     < RUSS_PFXX_I_metadata_line_25_____EuroChem_Agro_Iberia_20211101 >									
	//        < g0y7G6y1s91DkNBUC6WXiVvXiLuw9ONzMz1mL6BfxhQ6zNdf2XcPliFEXhIMi0Uj >									
	//        <  u =="0.000000000000000001" : ] 000000361971593.197299000000000000 ; 000000375193158.975513000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000228532723C7FD4 >									
	//     < RUSS_PFXX_I_metadata_line_26_____EuroChem_Agricultural_Trading_Hellas_20211101 >									
	//        < XKkJDyad45c0irr3GbVbUt6P6uwmMsYWMrLm5MyeB8twV78SB4uU980KE2Bw1SAZ >									
	//        <  u =="0.000000000000000001" : ] 000000375193158.975513000000000000 ; 000000391532381.469029000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023C7FD42556E56 >									
	//     < RUSS_PFXX_I_metadata_line_27_____EuroChem_Agro_Spa_20211101 >									
	//        < eskEVBA1N1HmBOI26eIc5142r55SfVFdFJe12vn1B45DX97KxN5d1XPfXJ8L8e11 >									
	//        <  u =="0.000000000000000001" : ] 000000391532381.469029000000000000 ; 000000407665316.549712000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002556E5626E0C44 >									
	//     < RUSS_PFXX_I_metadata_line_28_____EuroChem_Agro_GmbH_20211101 >									
	//        < 68OWTV2l6be555sX13e45N2tZWe93i45gwk9uR8txCoxsMiWn2MsonFawmig3Fc9 >									
	//        <  u =="0.000000000000000001" : ] 000000407665316.549712000000000000 ; 000000424872043.003303000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026E0C442884DA4 >									
	//     < RUSS_PFXX_I_metadata_line_29_____EuroChem_Agro_México_SA_20211101 >									
	//        < 56va1f7i9K1WcmV69PATjIynI4r3R78f75b9P64VBI9S9EoIj06o1ZVSJm5wNV65 >									
	//        <  u =="0.000000000000000001" : ] 000000424872043.003303000000000000 ; 000000442042258.452476000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002884DA42A280C2 >									
	//     < RUSS_PFXX_I_metadata_line_30_____EuroChem_Agro_Hungary_Kft_20211101 >									
	//        < a30iV30MtkZeVf3X1TVIr3I74N9168cBLX3d87r0A5zMX8h0o8UtF640M0a0D0oj >									
	//        <  u =="0.000000000000000001" : ] 000000442042258.452476000000000000 ; 000000459124621.619294000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A280C22BC918E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXX_I_metadata_line_31_____Agrocenter_EuroChem_Srl_20211101 >									
	//        < JTRy6A8yzRkQ67ByFH0XbtC1CfLgITRA2m0b1YfMQo66n5paCO1LXJxQWPh20y43 >									
	//        <  u =="0.000000000000000001" : ] 000000459124621.619294000000000000 ; 000000473241598.640035000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BC918E2D21C00 >									
	//     < RUSS_PFXX_I_metadata_line_32_____EuroChem_Agro_Bulgaria_Ead_20211101 >									
	//        < 3O51EZBcR8YMy842AOr52HRh9f5g753bCrU5k2022k1QVq8s1r8elja1B7d8BmNi >									
	//        <  u =="0.000000000000000001" : ] 000000473241598.640035000000000000 ; 000000487452653.924520000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D21C002E7CB31 >									
	//     < RUSS_PFXX_I_metadata_line_33_____EuroChem_Agro_doo_Beograd_20211101 >									
	//        < pWwLs77NliLSY7g11AN93j1OK3H7vDCHTcg3a0t1Gp1365ytwkpfdEW23k9449hU >									
	//        <  u =="0.000000000000000001" : ] 000000487452653.924520000000000000 ; 000000503305875.501125000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E7CB312FFFBDC >									
	//     < RUSS_PFXX_I_metadata_line_34_____EuroChem_Agro_Turkey_Tarim_Sanayi_ve_Ticaret_20211101 >									
	//        < r5OE971baG2j5C2PLbq9TCBa7glSpixWL5950hBUS92716dWx4D357o6BY9l9Emg >									
	//        <  u =="0.000000000000000001" : ] 000000503305875.501125000000000000 ; 000000519215334.708827000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FFFBDC318427D >									
	//     < RUSS_PFXX_I_metadata_line_35_____Emerger_Fertilizantes_SA_20211101 >									
	//        < ruUm2matD5N0wEkXX14YL4v5Cej1d5800daBg2X6cp3ccyuVDiB5KaIbh3Z5x0JA >									
	//        <  u =="0.000000000000000001" : ] 000000519215334.708827000000000000 ; 000000533047118.812317000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000318427D32D5D88 >									
	//     < RUSS_PFXX_I_metadata_line_36_____EuroChem_Comercio_Produtos_Quimicos_20211101 >									
	//        < G6Axr6Uvp28xXV8lzhk66kf8ak83wd7YX16a0050kp4bE0LsLQQes08cAX4L96Q8 >									
	//        <  u =="0.000000000000000001" : ] 000000533047118.812317000000000000 ; 000000549787930.348375000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032D5D88346E8E9 >									
	//     < RUSS_PFXX_I_metadata_line_37_____Fertilizantes_Tocantines_Ltda_20211101 >									
	//        < I47eSl05Miz4M4T3090l5cffrX3jiiFbNW83un92n4N40lP571cb1ONnjS0i8v23 >									
	//        <  u =="0.000000000000000001" : ] 000000549787930.348375000000000000 ; 000000562796574.459039000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000346E8E935AC269 >									
	//     < RUSS_PFXX_I_metadata_line_38_____EuroChem_Agro_Trading_Shenzhen_20211101 >									
	//        < VS6m4Cx8nbcR9i91r655E6mCb29n0Z4Hw868n05wpBFf4YnV95QdAmp682EU5F1K >									
	//        <  u =="0.000000000000000001" : ] 000000562796574.459039000000000000 ; 000000579018227.768272000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035AC26937382FF >									
	//     < RUSS_PFXX_I_metadata_line_39_____EuroChem_Trading_RUS_20211101 >									
	//        < 0Jd91bE55404lMytd28GZIu9R6NxkUAVh6VnoM4KNFiBvJB33A9AuU3cWV1aK3w6 >									
	//        <  u =="0.000000000000000001" : ] 000000579018227.768272000000000000 ; 000000596102622.194973000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037382FF38D9496 >									
	//     < RUSS_PFXX_I_metadata_line_40_____AgroCenter_EuroChem_Ukraine_20211101 >									
	//        < eg7aPg58g0jf0nWRlfELlSYw8u3L5Mkf3mYh8oK1dO9LMjD87Ikbk9viSIeAz0q9 >									
	//        <  u =="0.000000000000000001" : ] 000000596102622.194973000000000000 ; 000000609784078.829287000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038D94963A274E8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}