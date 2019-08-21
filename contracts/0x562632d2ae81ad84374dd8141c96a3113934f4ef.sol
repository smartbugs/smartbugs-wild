pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXX_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXX_II_883		"	;
		string	public		symbol =	"	RUSS_PFXXX_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		796077025090406000000000000					;	
										
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
	//     < RUSS_PFXXX_II_metadata_line_1_____CANPOTEX_20231101 >									
	//        < oju43e603a00XL9rzHSszfRE7h3glIEz8s7bS28QY7UW4hnh6LwE8LKs747M7LpE >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000016979768.242053300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000019E8B9 >									
	//     < RUSS_PFXXX_II_metadata_line_2_____CANPOTEX_SHIPPING_SERVICES_20231101 >									
	//        < F0nBr5z2hz99BK0T0sNWy9t17oStt9GjeeXdA3MqT63w0ycMj18cTA1jzA7Y7x30 >									
	//        <  u =="0.000000000000000001" : ] 000000016979768.242053300000000000 ; 000000038364988.464842100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000019E8B93A8A53 >									
	//     < RUSS_PFXXX_II_metadata_line_3_____CANPOTEX_INT_PTE_LIMITED_20231101 >									
	//        < s8XA6bp8To6i2858P67Yqjfae8i6hTmkg5b3NiM0rb3fN0fOSHsucGo26s9ISZc8 >									
	//        <  u =="0.000000000000000001" : ] 000000038364988.464842100000000000 ; 000000060084410.668212000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003A8A535BAE79 >									
	//     < RUSS_PFXXX_II_metadata_line_4_____PORTLAND_BULK_TERMINALS_LLC_20231101 >									
	//        < eowjc7cgGtU6vf3PPir7l12jmWU0YQ3lciwdjqzL517kC00uHNvd5JZD5zKFuuq1 >									
	//        <  u =="0.000000000000000001" : ] 000000060084410.668212000000000000 ; 000000078567091.377297200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005BAE7977E245 >									
	//     < RUSS_PFXXX_II_metadata_line_5_____CANPOTEX_INT_CANCADA_LTD_20231101 >									
	//        < NjbQ223Ati1r36G3YO6Go9Rq63t3m1kk2LVFbAPz4yw44JsAve4m4P9C3YotO4ll >									
	//        <  u =="0.000000000000000001" : ] 000000078567091.377297200000000000 ; 000000094890965.801275500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000077E24590CAC9 >									
	//     < RUSS_PFXXX_II_metadata_line_6_____CANPOTEX_HK_LIMITED_20231101 >									
	//        < VFc3uLuoNArlnqJGYeMAMYN43ah30yVL96o9K7KADLylVm7NMy3F9YFyaPr92d1M >									
	//        <  u =="0.000000000000000001" : ] 000000094890965.801275500000000000 ; 000000112029406.292658000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000090CAC9AAF17D >									
	//     < RUSS_PFXXX_II_metadata_line_7_____CANPOTEX_ORG_20231101 >									
	//        < 9ZhZysLfBP45w3cSqHF3zueVhp1ltg7RZ00PuxELdek2qBQseEcqX9pceBhHTyVZ >									
	//        <  u =="0.000000000000000001" : ] 000000112029406.292658000000000000 ; 000000130984169.363765000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AAF17DC7DDB1 >									
	//     < RUSS_PFXXX_II_metadata_line_8_____CANPOTEX_FND_20231101 >									
	//        < EHeue3dVSB1B4KqLJ9u46pc98irY5cloHs0kC64jJ8f7ca762qtSjls6TN8n5piA >									
	//        <  u =="0.000000000000000001" : ] 000000130984169.363765000000000000 ; 000000148309068.518726000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C7DDB1E24D3B >									
	//     < RUSS_PFXXX_II_metadata_line_9_____CANPOTEX_gbp_20231101 >									
	//        < GohStP4NaPpKvoV9L2BYP6MGu5n8uIC6Sr84i9L4mbmyVX8t9jgg62S044M95YaK >									
	//        <  u =="0.000000000000000001" : ] 000000148309068.518726000000000000 ; 000000167291581.131645000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E24D3BFF4446 >									
	//     < RUSS_PFXXX_II_metadata_line_10_____CANPOTEX_SHIPPING_SERVICES_gbp_20231101 >									
	//        < YiqAphWQqxI67hXrFRH6s53oMM72p7lmQMQHJH4QgBZc02Nv9y294Its9FYtN638 >									
	//        <  u =="0.000000000000000001" : ] 000000167291581.131645000000000000 ; 000000185214381.011149000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FF444611A9D5E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXX_II_metadata_line_11_____CANPOTEX_INT_PTE_LIMITED_gbp_20231101 >									
	//        < p36sLy3Zx7aA5D77kQwdN6lzMFgRQYt42tHaEH10K511zk0X7OfiCO9D5YVluIni >									
	//        <  u =="0.000000000000000001" : ] 000000185214381.011149000000000000 ; 000000205086091.519594000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011A9D5E138EFC1 >									
	//     < RUSS_PFXXX_II_metadata_line_12_____PORTLAND_BULK_TERMINALS_LLC_gbp_20231101 >									
	//        < dQ66IgB7qwFdHoJK8q6m17lYMBR3w8kYWwyrOh74pP25wqC68DI3Rvu3e9Fd9FPZ >									
	//        <  u =="0.000000000000000001" : ] 000000205086091.519594000000000000 ; 000000224285262.093701000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000138EFC11563B6E >									
	//     < RUSS_PFXXX_II_metadata_line_13_____CANPOTEX_INT_CANCADA_LTD_gbp_20231101 >									
	//        < 1I5KJbpFKv9YoXY4Ujx2ya8sv997SgkdT3r3B8XRQg3XwE6Tew68r1DCAnwL4IOS >									
	//        <  u =="0.000000000000000001" : ] 000000224285262.093701000000000000 ; 000000246708419.724455000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001563B6E178727A >									
	//     < RUSS_PFXXX_II_metadata_line_14_____CANPOTEX_HK_LIMITED_gbp_20231101 >									
	//        < mqXh50fcU7m7z2Efvcz5b98p32M1nlSlyjFkIjSfIo2631klLzd1RZhA0qAF2q9z >									
	//        <  u =="0.000000000000000001" : ] 000000246708419.724455000000000000 ; 000000270756130.126162000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000178727A19D241D >									
	//     < RUSS_PFXXX_II_metadata_line_15_____CANPOTEX_ORG_gbp_20231101 >									
	//        < 9w7WI05AMKBsZVGKt017401Jn0j9BqnvYP78shetBVjA3v2CeFy2e965vQUJqhb5 >									
	//        <  u =="0.000000000000000001" : ] 000000270756130.126162000000000000 ; 000000288096482.667216000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019D241D1B799B0 >									
	//     < RUSS_PFXXX_II_metadata_line_16_____CANPOTEX_FND_gbp_20231101 >									
	//        < JOdoU9qNBg9Br2e0UJ0G6Ph4V6ni52bW6I647FdH27340O9T6iV7EiWzHW6w4QcI >									
	//        <  u =="0.000000000000000001" : ] 000000288096482.667216000000000000 ; 000000308221736.244338000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B799B01D64F1E >									
	//     < RUSS_PFXXX_II_metadata_line_17_____CANPOTEX_usd_20231101 >									
	//        < sP4rtBFt9kZ2Qzx5dOWNb36Rol2l8afrYxU2ul5YB47b2Wy1fHMT496sn6H41dnk >									
	//        <  u =="0.000000000000000001" : ] 000000308221736.244338000000000000 ; 000000327706011.821959000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D64F1E1F40A29 >									
	//     < RUSS_PFXXX_II_metadata_line_18_____CANPOTEX_SHIPPING_SERVICES_usd_20231101 >									
	//        < zjdI2dUGyC4um1PXs231OhI7BIwF1tBhRO00AO2908B553B9176s5h17D6QyJo93 >									
	//        <  u =="0.000000000000000001" : ] 000000327706011.821959000000000000 ; 000000351233529.412103000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F40A29217F099 >									
	//     < RUSS_PFXXX_II_metadata_line_19_____CANPOTEX_INT_PTE_LIMITED_usd_20231101 >									
	//        < 95JwleoFewesiUxYsW6IXP5BbpfEO7Mx30JpHTY5JXr1Kis5AJeV1D9ZxfhmIOf0 >									
	//        <  u =="0.000000000000000001" : ] 000000351233529.412103000000000000 ; 000000371390240.759689000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000217F099236B250 >									
	//     < RUSS_PFXXX_II_metadata_line_20_____PORTLAND_BULK_TERMINALS_LLC_usd_20231101 >									
	//        < p899e39hfpFpkZ30234h5wVP8hYW0ma1cDJN0q62AYRFzHbgKW7c31jgjf24AW0k >									
	//        <  u =="0.000000000000000001" : ] 000000371390240.759689000000000000 ; 000000388475400.375084000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000236B250250C434 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXX_II_metadata_line_21_____CANPOTEX_INT_CANCADA_LTD_usd_20231101 >									
	//        < j76q0kvrQMC4vJNvb616YlCKOmH356bmnstU515Q81cxTZzW2e4TL46510q1mxaV >									
	//        <  u =="0.000000000000000001" : ] 000000388475400.375084000000000000 ; 000000406911717.244640000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000250C43426CE5E4 >									
	//     < RUSS_PFXXX_II_metadata_line_22_____CANPOTEX_HK_LIMITED_usd_20231101 >									
	//        < Zw6uy7Dj8Y45QVgyxFqZlJdh5Lj994vkrjFveEeq5hM1afY964G9vVoYGkPSML65 >									
	//        <  u =="0.000000000000000001" : ] 000000406911717.244640000000000000 ; 000000427255127.021215000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026CE5E428BF089 >									
	//     < RUSS_PFXXX_II_metadata_line_23_____CANPOTEX_ORG_usd_20231101 >									
	//        < F1r4CMEi7P49UyqWXq1H06VFKWIIhCkx29z7dkz3opE05fyYKzttsf8sUQW81UUl >									
	//        <  u =="0.000000000000000001" : ] 000000427255127.021215000000000000 ; 000000446881724.472845000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028BF0892A9E32C >									
	//     < RUSS_PFXXX_II_metadata_line_24_____CANPOTEX_FND_usd_20231101 >									
	//        < kp3Q1V1ViDp281jde774nJFgml5U0637p6CJ0z038226GiEYTPLJcQCwca46JIV6 >									
	//        <  u =="0.000000000000000001" : ] 000000446881724.472845000000000000 ; 000000468936245.218499000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A9E32C2CB8A39 >									
	//     < RUSS_PFXXX_II_metadata_line_25_____CANPOTEX_chf_20231101 >									
	//        < 9bSb268wJb874e58uAu0fibIcksjMO8omjx1Qvi9344q7C1D1uFSs7RAUXiVcnXD >									
	//        <  u =="0.000000000000000001" : ] 000000468936245.218499000000000000 ; 000000487538622.022687000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CB8A392E7ECC6 >									
	//     < RUSS_PFXXX_II_metadata_line_26_____CANPOTEX_SHIPPING_SERVICES_chf_20231101 >									
	//        < 60LALE6yLsM3WwiOe9US949sp1w7e0661aYe6YjbNkOfN0A6RcTqOLjL0mL3DCd5 >									
	//        <  u =="0.000000000000000001" : ] 000000487538622.022687000000000000 ; 000000506672344.226696000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E7ECC63051EE2 >									
	//     < RUSS_PFXXX_II_metadata_line_27_____CANPOTEX_INT_PTE_LIMITED_chf_20231101 >									
	//        < haU7qDNXm7P0Mu0RW9JVf9O9Gxd10vkbyzhDUI56h50grYK5HT7wGbVJM5hL2yK2 >									
	//        <  u =="0.000000000000000001" : ] 000000506672344.226696000000000000 ; 000000523950418.069970000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003051EE231F7C22 >									
	//     < RUSS_PFXXX_II_metadata_line_28_____PORTLAND_BULK_TERMINALS_LLC_chf_20231101 >									
	//        < cXAs4ak3s4NNi2ZcYU4zfp7E23aw0rc1U68279u2Mj3I1Wo2N4r9hUtaXJm8TncL >									
	//        <  u =="0.000000000000000001" : ] 000000523950418.069970000000000000 ; 000000546281792.847544000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031F7C223418F53 >									
	//     < RUSS_PFXXX_II_metadata_line_29_____CANPOTEX_INT_CANCADA_LTD_chf_20231101 >									
	//        < Flh9xao12Rr9T27N9rWZBQlqb21Z0YU20x3cnd0Zx3I2hcwfys42RY4T2TV6LhJ0 >									
	//        <  u =="0.000000000000000001" : ] 000000546281792.847544000000000000 ; 000000567679153.295709000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003418F5336235AB >									
	//     < RUSS_PFXXX_II_metadata_line_30_____CANPOTEX_HK_LIMITED_chf_20231101 >									
	//        < 4ob7Ep10hfK5FXzD4577dHf7SPnVW4GNsnYQ6b6ka09Awug74u02I7F8J9Il0vm1 >									
	//        <  u =="0.000000000000000001" : ] 000000567679153.295709000000000000 ; 000000591331894.444568000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036235AB3864D05 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXX_II_metadata_line_31_____CANPOTEX_ORG_chf_20231101 >									
	//        < c6awI0a862gv0i1N7DTFHYA04Xv3wesMM60dO6s9sR1sSUa341lSo657jd29lD16 >									
	//        <  u =="0.000000000000000001" : ] 000000591331894.444568000000000000 ; 000000609603881.996833000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003864D053A22E84 >									
	//     < RUSS_PFXXX_II_metadata_line_32_____CANPOTEX_FND_chf_20231101 >									
	//        < Kn4D5pu86seVK43ZWt3l9i7BgBQTeZ3D3r59AcCZYj27fw2yf84G0783VGufTynk >									
	//        <  u =="0.000000000000000001" : ] 000000609603881.996833000000000000 ; 000000632362254.878915000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A22E843C4E881 >									
	//     < RUSS_PFXXX_II_metadata_line_33_____CANPOTEX_eur_20231101 >									
	//        < Kc8i4Sih12qp4cLQZ3bkct40Z5diPA16kvbwh6r3Wv3auRqLg40wi54Zrphp2btI >									
	//        <  u =="0.000000000000000001" : ] 000000632362254.878915000000000000 ; 000000655364871.081235000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C4E8813E801E7 >									
	//     < RUSS_PFXXX_II_metadata_line_34_____CANPOTEX_SHIPPING_SERVICES_eur_20231101 >									
	//        < hVLF5A1F2IzG72jK5hSJ6TZ5Lm30Expi9HD0nrxJTc0skXNf48kNa4XyULTw0llP >									
	//        <  u =="0.000000000000000001" : ] 000000655364871.081235000000000000 ; 000000676946599.921874000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E801E7408F044 >									
	//     < RUSS_PFXXX_II_metadata_line_35_____CANPOTEX_INT_PTE_LIMITED_eur_20231101 >									
	//        < tZ5Uj85O8x31WXO176UkPecGd4NCXU0ksLaB5oK676W3TDRWluYzpO944iZ414m8 >									
	//        <  u =="0.000000000000000001" : ] 000000676946599.921874000000000000 ; 000000694285168.608272000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000408F0444236525 >									
	//     < RUSS_PFXXX_II_metadata_line_36_____PORTLAND_BULK_TERMINALS_LLC_eur_20231101 >									
	//        < kWN1x8Th68z5fMSJLdhTlB1hso48GcgNf9UpxBmi85xtGgF8p4uYwdmqBkXN0902 >									
	//        <  u =="0.000000000000000001" : ] 000000694285168.608272000000000000 ; 000000715417671.317604000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004236525443A407 >									
	//     < RUSS_PFXXX_II_metadata_line_37_____CANPOTEX_INT_CANCADA_LTD_eur_20231101 >									
	//        < hc0p0Eg295U46sC5mc0VV5S75i8JmmI3NRiXE4NODEIz8YXggOM573RqmPxsAD08 >									
	//        <  u =="0.000000000000000001" : ] 000000715417671.317604000000000000 ; 000000739005083.267993000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000443A407467A1DC >									
	//     < RUSS_PFXXX_II_metadata_line_38_____CANPOTEX_HK_LIMITED_eur_20231101 >									
	//        < 4xRw7uw9v66PkrDXQAW1A365d2Yfmvbn5LHFhiX0l6990EBT63Gmq9QnI79zM5kb >									
	//        <  u =="0.000000000000000001" : ] 000000739005083.267993000000000000 ; 000000757436169.901528000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000467A1DC483C181 >									
	//     < RUSS_PFXXX_II_metadata_line_39_____CANPOTEX_ORG_eur_20231101 >									
	//        < Eq50sz282To6g0WQqse0U3Z9mH6th2OSMEZPVv1E7JQG1PPLj8U1zEjucPhM7gd8 >									
	//        <  u =="0.000000000000000001" : ] 000000757436169.901528000000000000 ; 000000774498728.550001000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000483C18149DCA91 >									
	//     < RUSS_PFXXX_II_metadata_line_40_____CANPOTEX_FND_eur_20231101 >									
	//        < hza8aPB5W2Ws23z7ae9Raa7Ew516qM30gA7p9uB7dMzJgL8ah6ZiXdG50cL8BcZf >									
	//        <  u =="0.000000000000000001" : ] 000000774498728.550001000000000000 ; 000000796077025.090406000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049DCA914BEB797 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}