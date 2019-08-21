pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFI_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFI_II_883		"	;
		string	public		symbol =	"	NDRV_PFI_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1195841904494910000000000000					;	
										
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
	//     < NDRV_PFI_II_metadata_line_1_____genworth_20231101 >									
	//        < ClJXOx3F5JbJ7D939a5YADg1XU64q38Kn7q9EcWRvL8c0w6F4023x1t25x08FWbr >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000025441440.789803500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000026D210 >									
	//     < NDRV_PFI_II_metadata_line_2_____genworth_org_20231101 >									
	//        < dr3oB0EFMGFNJ8xn506N7z0gQ2oe8D6Ry2nRYfQmX6Hmaa29JrDz5C585WUbWU30 >									
	//        <  u =="0.000000000000000001" : ] 000000025441440.789803500000000000 ; 000000048706923.850375700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000026D2104A5224 >									
	//     < NDRV_PFI_II_metadata_line_3_____genworth_pensions_20231101 >									
	//        < ThJE4y7oV9yTge0CZ6Voxs87aWifqAgX230jP42intpoa4lBhMuVvGZb5f508F93 >									
	//        <  u =="0.000000000000000001" : ] 000000048706923.850375700000000000 ; 000000097431388.097495200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004A522494AB23 >									
	//     < NDRV_PFI_II_metadata_line_4_____genworth gna corporation_20231101 >									
	//        < v7D764aW69Ek1s1PQBI7DfYy88F2N47yGn43hkwH2G4zCly5f2u0ZGfgpXQ9Q9eS >									
	//        <  u =="0.000000000000000001" : ] 000000097431388.097495200000000000 ; 000000132793591.833270000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000094AB23CAA07F >									
	//     < NDRV_PFI_II_metadata_line_5_____gna corporation_org_20231101 >									
	//        < 4RK7h56yK7wgczygQYiLJ1j9RDBQ1W87F597P1yc4xrV46WZ85Rd1de5Hq3jt8BR >									
	//        <  u =="0.000000000000000001" : ] 000000132793591.833270000000000000 ; 000000152108087.099291000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CAA07FE81939 >									
	//     < NDRV_PFI_II_metadata_line_6_____gna corporation_holdings_20231101 >									
	//        < 95Z8TutNyTe4hIa28U790sI80Six0j0NG90ZBI383C3U8MdyQ1Q1pKwio7u1u02i >									
	//        <  u =="0.000000000000000001" : ] 000000152108087.099291000000000000 ; 000000180564414.753262000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E8193911384F9 >									
	//     < NDRV_PFI_II_metadata_line_7_____genworth assetmark_20231101 >									
	//        < iCaLCUqORgDazGNKIDI377Wo9P0d30JbLukbozPUZ308G384jIwd99jNL5IFw5Nz >									
	//        <  u =="0.000000000000000001" : ] 000000180564414.753262000000000000 ; 000000216910701.631172000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011384F914AFABE >									
	//     < NDRV_PFI_II_metadata_line_8_____genworth assetmark_org_20231101 >									
	//        < nB7byMrVxUcu7CSxN78K5j9GzDfuJZLL7xCTDRXo5T2EF2fa1fWKezluXmn4S2RW >									
	//        <  u =="0.000000000000000001" : ] 000000216910701.631172000000000000 ; 000000250061353.511205000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014AFABE17D9037 >									
	//     < NDRV_PFI_II_metadata_line_9_____assetmark_holdings_20231101 >									
	//        < 8OI0WLrD60AGFc85h85hro7Pi9G6PhGPa3kwk6WuBt9iT4BxGX4a7cwQdbCDJJ35 >									
	//        <  u =="0.000000000000000001" : ] 000000250061353.511205000000000000 ; 000000294496470.434666000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017D90371C15DAF >									
	//     < NDRV_PFI_II_metadata_line_10_____genworth life & annuity insurance co_20231101 >									
	//        < nzXI84gSypJ5b157snE9Cc6UUjt4T55gg1K7Zc34XsG306OK5XyXS5GFEZIqw8n2 >									
	//        <  u =="0.000000000000000001" : ] 000000294496470.434666000000000000 ; 000000332866949.959659000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C15DAF1FBEA27 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFI_II_metadata_line_11_____genworth financial services inc_20231101 >									
	//        < sXZpaA44rIcWP7H8OHjwkU38ufLQxFYCp9Hrp96uePy99d6A79I2z1165f4O3B4g >									
	//        <  u =="0.000000000000000001" : ] 000000332866949.959659000000000000 ; 000000376642347.822705000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FBEA2723EB5EB >									
	//     < NDRV_PFI_II_metadata_line_12_____genworth financial agency inc_20231101 >									
	//        < JIU341cp1DP56DbEu6bu48pI56S0VL7j858yO04e9qapvuRC65a7Qz6Up4yi9Pp0 >									
	//        <  u =="0.000000000000000001" : ] 000000376642347.822705000000000000 ; 000000394099700.222809000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023EB5EB2595932 >									
	//     < NDRV_PFI_II_metadata_line_13_____genworth financial services pty limited_20231101 >									
	//        < w109m67c6x894Dh2u5VX7qrAnuXL529K8kHHy4r8H2PCtieSC4AVn63VTP04l2w2 >									
	//        <  u =="0.000000000000000001" : ] 000000394099700.222809000000000000 ; 000000415896219.345293000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000259593227A9B76 >									
	//     < NDRV_PFI_II_metadata_line_14_____genworth american continental insurance company_20231101 >									
	//        < 8I62HLwLWgSR0uX7Zz0gbg5eTUDf7KMHiMJbjp05zMT47OswX6vW930Q31HW3maw >									
	//        <  u =="0.000000000000000001" : ] 000000415896219.345293000000000000 ; 000000444043504.140628000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027A9B762A58E7E >									
	//     < NDRV_PFI_II_metadata_line_15_____continental insurance company_org_20231101 >									
	//        < BBiV01VABejOH8I7s3CK0L0Q7IG1b598sh30WyI7mRho9R1B0m32HaJ8TcgU6D1u >									
	//        <  u =="0.000000000000000001" : ] 000000444043504.140628000000000000 ; 000000461186900.852004000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A58E7E2BFB722 >									
	//     < NDRV_PFI_II_metadata_line_16_____genworth north america corp_20231101 >									
	//        < BhyzC6ctWxGB2Lk09FJksjD4uHz0jj4MVv1uL59J047KZdrB98sb20oDPyyo2S7D >									
	//        <  u =="0.000000000000000001" : ] 000000461186900.852004000000000000 ; 000000481743790.806009000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BFB7222DF152B >									
	//     < NDRV_PFI_II_metadata_line_17_____genworth holdings inc_20231101 >									
	//        < BRK3j8Bwu4hU8JRX6yK099DuU1fplGTJhEUn5pHZzgiv3POY4lC6AA2QAR5kYoMC >									
	//        <  u =="0.000000000000000001" : ] 000000481743790.806009000000000000 ; 000000497895990.267791000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DF152B2F7BA9F >									
	//     < NDRV_PFI_II_metadata_line_18_____genworth holdings inc_org_20231101 >									
	//        < 3qYbe7Ie248g28yVLXv7497aX6ZX8Y9N35rRrG5oXV0oRQApFoRy4oyIVEaci94f >									
	//        <  u =="0.000000000000000001" : ] 000000497895990.267791000000000000 ; 000000526101266.242755000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F7BA9F322C44F >									
	//     < NDRV_PFI_II_metadata_line_19_____genworth mortgage insurance corp_20231101 >									
	//        < H7rNT4p4t9R7VK87FJ3nb9wUM26ILH46uCIFmFjj4S5c5Mh9rAqc23r8oL4rNOFW >									
	//        <  u =="0.000000000000000001" : ] 000000526101266.242755000000000000 ; 000000572682258.627808000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000322C44F369D802 >									
	//     < NDRV_PFI_II_metadata_line_20_____genworth mortgage insurance corp_org_20231101 >									
	//        < q8D448z3t0q7SSECT9sbPq61dPU7Y4pf23VY4N0BAvm8et398vSwDnP0917RZY5e >									
	//        <  u =="0.000000000000000001" : ] 000000572682258.627808000000000000 ; 000000594712213.540847000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000369D80238B7575 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFI_II_metadata_line_21_____genworth financial mortgage insurance pty limited_20231101 >									
	//        < uXHK8Hd4p78w7WQQRRzz027Je40LBLn58r17pY2AcZ2n492qjQ3x12y02M4lSnyy >									
	//        <  u =="0.000000000000000001" : ] 000000594712213.540847000000000000 ; 000000618095471.776821000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038B75753AF238B >									
	//     < NDRV_PFI_II_metadata_line_22_____genworth financial international holdings inc_20231101 >									
	//        < 5H96nWn4keFO3C77VF4hFz7z20DgWBq77w4x8SFR9ag8zkKg1ARHM4ygqr7512uN >									
	//        <  u =="0.000000000000000001" : ] 000000618095471.776821000000000000 ; 000000637434921.521898000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003AF238B3CCA604 >									
	//     < NDRV_PFI_II_metadata_line_23_____genworth financial wealth management inc_20231101 >									
	//        < ML5e1ndLiE1BGtA9p1yIBrUIN65b0IglXR118pQnXvGTz4g2I3wTqoPyEHIxWO1T >									
	//        <  u =="0.000000000000000001" : ] 000000637434921.521898000000000000 ; 000000680949113.919436000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003CCA60440F0BBF >									
	//     < NDRV_PFI_II_metadata_line_24_____genworth ltc incorporated_org_20231101 >									
	//        < AzNAO1aWy3Mj0eEbW6qi6j1MtbtQos4v6LFzh9I4U82PfRQ5Y9o4IhDY9hUA201c >									
	//        <  u =="0.000000000000000001" : ] 000000680949113.919436000000000000 ; 000000715822442.566347000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040F0BBF4444224 >									
	//     < NDRV_PFI_II_metadata_line_25_____genworth jamestown life insurance co_20231101 >									
	//        < lqxu0rpBi93g185WT759o60ZBwn9GOfp2G1C1zxV5bPYwSFUAw0mPNG6287W4Gvk >									
	//        <  u =="0.000000000000000001" : ] 000000715822442.566347000000000000 ; 000000735598347.217417000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044442244626F1B >									
	//     < NDRV_PFI_II_metadata_line_26_____genworth financial assurance co ltd_20231101 >									
	//        < XeKBB90V6tAnnz4GoBi5jeJMXtu1Z1TlH2aw0rQ13cigWv2LKfhaM2SbDp6R52i9 >									
	//        <  u =="0.000000000000000001" : ] 000000735598347.217417000000000000 ; 000000770214556.855819000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004626F1B4974110 >									
	//     < NDRV_PFI_II_metadata_line_27_____genworth financial mortgage insurance company canada_20231101 >									
	//        < 1ui3o87SIROr0Kr57hoj9uN2z1tnYYZnjrjTu7wWU72OQtsDEJlpd0U5V4aeP72i >									
	//        <  u =="0.000000000000000001" : ] 000000770214556.855819000000000000 ; 000000786025889.152197000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049741104AF615D >									
	//     < NDRV_PFI_II_metadata_line_28_____genworth financial insurance group services ltd_20231101 >									
	//        < i84feT20867Bm8eQ97B66c0bbpJ9XEslIvw27oJ37r6cWZJ1QhZGYzePgs3jKh9w >									
	//        <  u =="0.000000000000000001" : ] 000000786025889.152197000000000000 ; 000000810280884.851768000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004AF615D4D463F8 >									
	//     < NDRV_PFI_II_metadata_line_29_____genworth financial trust co_20231101 >									
	//        < 49sK4PO80JSvjz66fU4902mo12fvwJo4i3izWj4viNTpQjja1FCg5b7I6M13KVTz >									
	//        <  u =="0.000000000000000001" : ] 000000810280884.851768000000000000 ; 000000841707336.754135000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004D463F850457EE >									
	//     < NDRV_PFI_II_metadata_line_30_____financial trust co_holdings_20231101 >									
	//        < KjN0P0Ir94gQB77dUHor8rKe28KAeVF19246IZX2R807FXUFA0kRT9l94Tj903fv >									
	//        <  u =="0.000000000000000001" : ] 000000841707336.754135000000000000 ; 000000867377899.623833000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000050457EE52B837E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFI_II_metadata_line_31_____financial trust co_pensions_20231101 >									
	//        < VH8w7pc04f3r0Q1CX5lcHD73iU8r62Osw9p3mO8BdyO7dGnk4qU7Oy1mSha2aLn1 >									
	//        <  u =="0.000000000000000001" : ] 000000867377899.623833000000000000 ; 000000911991984.270792000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000052B837E56F96DE >									
	//     < NDRV_PFI_II_metadata_line_32_____genworth financial trust co_org_20231101 >									
	//        < nF8ZXi9ixwDE02f7ov2bBe0YapPNC99IvVw99r28Zoz1ZjSZQgxYQ4m5KosCjpmg >									
	//        <  u =="0.000000000000000001" : ] 000000911991984.270792000000000000 ; 000000954633789.965623000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000056F96DE5B0A7D3 >									
	//     < NDRV_PFI_II_metadata_line_33_____genworth financial european group holdings limited_20231101 >									
	//        < 7CeD8iC6i07vgr63D5sUY5EGrwFj6UpLepMolL92m0CAUY17C7c3e3OQdrSYZ1p8 >									
	//        <  u =="0.000000000000000001" : ] 000000954633789.965623000000000000 ; 000000992747767.983020000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005B0A7D35EAD019 >									
	//     < NDRV_PFI_II_metadata_line_34_____genworth financial mortgage insurance limited_20231101 >									
	//        < 253vMi06ySAzrvdTiqC6Ee4F7erxX4b6Nnvam5nZoGdw27L05tKtm7V556G7SmPg >									
	//        <  u =="0.000000000000000001" : ] 000000992747767.983020000000000000 ; 000001009588444.936070000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005EAD019604827C >									
	//     < NDRV_PFI_II_metadata_line_35_____genworth servicios s de rl de cv_20231101 >									
	//        < T2jdm87Sk68U996fsAiT1siQ2L044A8kO8WL7g2XvK6KOWBlnob133zMT3aVYHy3 >									
	//        <  u =="0.000000000000000001" : ] 000001009588444.936070000000000000 ; 000001042546646.750520000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000604827C636CCC9 >									
	//     < NDRV_PFI_II_metadata_line_36_____genworth liberty reverse mortgage incorporated_20231101 >									
	//        < p0blH8V9W9jjEWgUYl0Gk7N3on6JTX22IGOYf9AW0dMV8Ue393zsdx7W9asr30u8 >									
	//        <  u =="0.000000000000000001" : ] 000001042546646.750520000000000000 ; 000001074591822.808970000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000636CCC9667B26E >									
	//     < NDRV_PFI_II_metadata_line_37_____genworth quantuvis consulting inc_20231101 >									
	//        < CKokN6688PckOM4AHcw1WGdx11p2VXNgFNv5bRYrsQKz4K21M61D9V6ndmCwVboS >									
	//        <  u =="0.000000000000000001" : ] 000001074591822.808970000000000000 ; 000001118308468.564790000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000667B26E6AA673F >									
	//     < NDRV_PFI_II_metadata_line_38_____genworth seguros de credito a la vivienda sa de cv_20231101 >									
	//        < Lj187jQ857H9N33O7O1ol03ziC9Z6NrcJP45eiHsh118Dq59u0vQt4XLKh820g4l >									
	//        <  u =="0.000000000000000001" : ] 000001118308468.564790000000000000 ; 000001147192125.206460000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006AA673F6D679ED >									
	//     < NDRV_PFI_II_metadata_line_39_____genworth mortgage insurance limited_20231101 >									
	//        < p1RFRqtptVtSCM04avGAegpICrVTtxIuyn8lm9RH9TcL3NMR6p0tKQ4h3ULq18uL >									
	//        <  u =="0.000000000000000001" : ] 000001147192125.206460000000000000 ; 000001166699276.782110000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006D679ED6F43DE8 >									
	//     < NDRV_PFI_II_metadata_line_40_____genworth financial investment services inc_20231101 >									
	//        < F5t6wrqw3o1VGSMo5wcV33a7H5L9IlCtnhZpuVZUf3Eoky5HckI23bUQy12ZJZOb >									
	//        <  u =="0.000000000000000001" : ] 000001166699276.782110000000000000 ; 000001195841904.494910000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006F43DE8720B5BE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}