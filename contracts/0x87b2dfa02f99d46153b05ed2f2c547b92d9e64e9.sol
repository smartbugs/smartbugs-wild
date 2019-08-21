pragma solidity 		^0.4.21	;						
									
contract	NDD_ETH_I_883				{				
									
	mapping (address => uint256) public balanceOf;								
									
	string	public		name =	"	NDD_ETH_I_883		"	;
	string	public		symbol =	"	NDD_ETH_I_1subDT		"	;
	uint8	public		decimals =		18			;
									
	uint256 public totalSupply =		37743339574653100000000000000					;	
									
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
//     < NDD_ETH_I_metadata_line_1_____6938413225 Lab_x >									
//        < mc1FFbSDcUJ2XKqntFm51CB3qb9zk5uIit85eP4Myzw450VDCVR324E2aZU3Crp6 >									
//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010000000.000000000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000000000000F4240 >									
//     < NDD_ETH_I_metadata_line_2_____9781285179 Lab_y >									
//        < 53C3RX02L4XC5pllOK208aHZdgpKK7AL0di1Marg6k8c88DI6No8S3b5068hr7ci >									
//        <  u =="0.000000000000000001" : ] 000000010000000.000000000000000000 ; 000000020000000.000000000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000000F42401E8480 >									
//     < NDD_ETH_I_metadata_line_3_____2386357399 Lab_100 >									
//        < 3am264J3rcyP0owvlJSRP9pb4lkAva18zDNSGs520jq49Pfaad00RvWV6lNjHDVi >									
//        <  u =="0.000000000000000001" : ] 000000020000000.000000000000000000 ; 000000032117250.936895100000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000001E84803101CD >									
//     < NDD_ETH_I_metadata_line_4_____2360855678 Lab_110 >									
//        < S4Z0przy2Men1842s2vyB9179UNGmXnAqG37Y18zhbvhPqFZ2D1w97rE82OLmMNh >									
//        <  u =="0.000000000000000001" : ] 000000032117250.936895100000000000 ; 000000046351752.810685300000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000003101CD46BA27 >									
//     < NDD_ETH_I_metadata_line_5_____1100832394 Lab_410/401 >									
//        < fy66Loc8z41kxWpsz52n1hNpEkLudlTBVw6VJVfZPnv4oBAPWUotJM3eiHyUI3ZI >									
//        <  u =="0.000000000000000001" : ] 000000046351752.810685300000000000 ; 000000073289760.305846100000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000000046BA276FD4D0 >									
//     < NDD_ETH_I_metadata_line_6_____983921182 Lab_810/801 >									
//        < g40hgCX74i52v3ryWqT29kyW26p8SVv8pVntU4IfZbSwI0Augzkr77IYz4p9jc09 >									
//        <  u =="0.000000000000000001" : ] 000000073289760.305846100000000000 ; 000000117165775.296168000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000006FD4D0B2C7E2 >									
//     < NDD_ETH_I_metadata_line_7_____1100832394 Lab_410_3Y1Y >									
//        < 2p78JL45XYYrU2V6uZdRB9HgC67QODD842zG1eYJ2xm8sRX79Er2RL28Pa708EIq >									
//        <  u =="0.000000000000000001" : ] 000000117165775.296168000000000000 ; 000000312643109.720150000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000000B2C7E21DD0E37 >									
//     < NDD_ETH_I_metadata_line_8_____983921182 Lab_410_5Y1Y >									
//        < 3VRlZbgngDgDD04b714tGG5l6LI7kgjeFC4B3O9BLqqy9G6h0360RdT00MwVxZq7 >									
//        <  u =="0.000000000000000001" : ] 000000312643109.720150000000000000 ; 000000322643109.720150000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000001DD0E371EC5077 >									
//     < NDD_ETH_I_metadata_line_9_____2323232323 Lab_410_7Y1Y >									
//        < i32o75LnfQ82VpNa98945495b02Md40T2jA15i9MOV3X45e78Ve91W2HZtvy3UYG >									
//        <  u =="0.000000000000000001" : ] 000000322643109.720150000000000000 ; 000000332643109.720150000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000001EC50771FB92B7 >									
//     < NDD_ETH_I_metadata_line_10_____2323232323 Lab_810_3Y1Y >									
//        < 8E6o6C38V0O9L5FdFzx5uUa1ymdMtABkqkGuD7v09LbxP30uX41J6y1JxPwk5XD7 >									
//        <  u =="0.000000000000000001" : ] 000000332643109.720150000000000000 ; 000001177302332.711770000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000001FB92B77046BB9 >									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
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
//     < NDD_ETH_I_metadata_line_11_____2305878630 Lab_810_5Y1Y >									
//        < C3ue6OM33IHoca7Jcr1iXLILG2451aK1m352V45YPj85W80N1daKU2Oo78op44Rw >									
//        <  u =="0.000000000000000001" : ] 000001177302332.711770000000000000 ; 000001187302332.711770000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000007046BB9713ADF9 >									
//     < NDD_ETH_I_metadata_line_12_____2395229364 Lab_810_7Y1Y >									
//        < J6l0mj95I7VkU21JniIFxftV98A2CC047IVj35O1L1pz7CCF1i0isO9m02h1l2Qk >									
//        <  u =="0.000000000000000001" : ] 000001187302332.711770000000000000 ; 000001197302332.711770000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000713ADF9722F039 >									
//     < NDD_ETH_I_metadata_line_13_____2323232323 ro_Lab_110_3Y_1.00 >									
//        < C8WhW6JLunkwD7RG8gfBsxDNK8Ne59LsKXj48kB8uoDeh264B2JJXI96cDT0CX5u >									
//        <  u =="0.000000000000000001" : ] 000001197302332.711770000000000000 ; 000001209618881.164870000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000722F039735BB60 >									
//     < NDD_ETH_I_metadata_line_14_____2323232323 ro_Lab_110_5Y_1.00 >									
//        < bxe375cadK83p3nL21X0Va3JavlXmw2k3fSKe306OJki4UyA8g007SIBuW0781qy >									
//        <  u =="0.000000000000000001" : ] 000001209618881.164870000000000000 ; 000001219618881.164870000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000735BB60744FDA0 >									
//     < NDD_ETH_I_metadata_line_15_____2323232323 ro_Lab_110_5Y_1.10 >									
//        < kh0Loiw86g242z18REjnvW6pV6l04U9101KWru7XVg41525J5o46gYpaQUcR6Bww >									
//        <  u =="0.000000000000000001" : ] 000001219618881.164870000000000000 ; 000001229618881.164870000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000744FDA07543FE0 >									
//     < NDD_ETH_I_metadata_line_16_____2323232323 ro_Lab_110_7Y_1.00 >									
//        < T3bw3OYh6DvRx5AKi49p2p120atK6y1466y95eA8CII3OmVAX5JXywi9zTInYjrL >									
//        <  u =="0.000000000000000001" : ] 000001229618881.164870000000000000 ; 000001239618881.164870000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000007543FE07638220 >									
//     < NDD_ETH_I_metadata_line_17_____2323232323 ro_Lab_210_3Y_1.00 >									
//        < 3s734cBE3Bmy2V3hOnyx6O4qXCmZlE8lJ8EO65yKpBoAb3kWEA5EaYugTlfE6Xg7 >									
//        <  u =="0.000000000000000001" : ] 000001239618881.164870000000000000 ; 000001254660634.253560000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000763822077A75CF >									
//     < NDD_ETH_I_metadata_line_18_____2323232323 ro_Lab_210_5Y_1.00 >									
//        < zzB8W080PxM3smqbTZD14YqCdEYclFEb3kDnDPSjyWF0jD1hCg3zX14FN7T7O1L1 >									
//        <  u =="0.000000000000000001" : ] 000001254660634.253560000000000000 ; 000001264660634.253560000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000077A75CF789B80F >									
//     < NDD_ETH_I_metadata_line_19_____2323232323 ro_Lab_210_5Y_1.10 >									
//        < 57081v8V49NKbcz22z4Xs90G6x3GmZapp676w4E7f31f22PYuwyFuQ1n2yeysse6 >									
//        <  u =="0.000000000000000001" : ] 000001264660634.253560000000000000 ; 000001274660634.253560000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000789B80F798FA4F >									
//     < NDD_ETH_I_metadata_line_20_____2323232323 ro_Lab_210_7Y_1.00 >									
//        < xO98s92y9DMd4z7354zgJYbua3A2HV9HAa38745NVJ1pbVvR8M9zjtsqM58dNDEU >									
//        <  u =="0.000000000000000001" : ] 000001274660634.253560000000000000 ; 000001284660634.253560000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000798FA4F7A83C8F >									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
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
//     < NDD_ETH_I_metadata_line_21_____2374516427 ro_Lab_310_3Y_1.00 >									
//        < qeJ1g2V4oi85RflNbSMcO704ZCI110vl1gx25AhJ68Z0z1TvsHB9GYvT4HqGC0fw >									
//        <  u =="0.000000000000000001" : ] 000001284660634.253560000000000000 ; 000001303983471.317180000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000007A83C8F7C5B88B >									
//     < NDD_ETH_I_metadata_line_22_____2384022891 ro_Lab_310_5Y_1.00 >									
//        < 8SQ5ke8tsmfcC11Y9653ZYD8801a045m1O74WRc7507TGMG73jwO9ql8ITG4fs97 >									
//        <  u =="0.000000000000000001" : ] 000001303983471.317180000000000000 ; 000001313983471.317180000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000007C5B88B7D4FACB >									
//     < NDD_ETH_I_metadata_line_23_____2326679014 ro_Lab_310_5Y_1.10 >									
//        < 6cVd4KS0h1BNJ2FeqwbeH0x7ePYeBciobrY05gA94Xc20oQt0F83RS35XP5ir26d >									
//        <  u =="0.000000000000000001" : ] 000001313983471.317180000000000000 ; 000001323983471.317180000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000007D4FACB7E43D0B >									
//     < NDD_ETH_I_metadata_line_24_____2323232323 ro_Lab_310_7Y_1.00 >									
//        < 345M991HUD5LDlO41p297zUD48NMj3w9d2wZ19p9jZWWp232X3BKip5a4pRn1k6U >									
//        <  u =="0.000000000000000001" : ] 000001323983471.317180000000000000 ; 000001333983471.317180000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000007E43D0B7F37F4B >									
//     < NDD_ETH_I_metadata_line_25_____2323232323 ro_Lab_410_3Y_1.00 >									
//        < 9mH9TbKwmrjOH0ctt4KAaw33558C23d2cw16sCiKYs94o35o8azm07qZN7jN17nB >									
//        <  u =="0.000000000000000001" : ] 000001333983471.317180000000000000 ; 000001359477343.966160000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000007F37F4B81A65D6 >									
//     < NDD_ETH_I_metadata_line_26_____2323232323 ro_Lab_410_5Y_1.00 >									
//        < jhaKx415zlXevgH0gOqMUaJlS62QY2ZM4CMNb12OGkeQMwY07aW9Lz5tHSIGRdR4 >									
//        <  u =="0.000000000000000001" : ] 000001359477343.966160000000000000 ; 000001369477343.966160000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000081A65D6829A816 >									
//     < NDD_ETH_I_metadata_line_27_____2323232323 ro_Lab_410_5Y_1.10 >									
//        < hs99yWv5k8wB5f7NsOq4b4oh9wx9dBU0H3W656KCaKU28MLLC6uK5tS4AEFM7BMm >									
//        <  u =="0.000000000000000001" : ] 000001369477343.966160000000000000 ; 000001379477343.966160000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000829A816838EA56 >									
//     < NDD_ETH_I_metadata_line_28_____2323232323 ro_Lab_410_7Y_1.00 >									
//        < 48SJ8S0Bs4I7McdOs8w6BN2Sdjc94PPFWYVud8NfYfNnA6Ym5wIorhNk6MTBE1NL >									
//        <  u =="0.000000000000000001" : ] 000001379477343.966160000000000000 ; 000001389477343.966160000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000838EA568482C96 >									
//     < NDD_ETH_I_metadata_line_29_____2323232323 ro_Lab_810_3Y_1.00 >									
//        < abFpf6loe7UOOjkU4nNkJI0UQYfgIcdRNHS5hczKKh795dxNQ1Egms27W4B48S60 >									
//        <  u =="0.000000000000000001" : ] 000001389477343.966160000000000000 ; 000001465139753.700040000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000008482C968BBA037 >									
//     < NDD_ETH_I_metadata_line_30_____2323232323 ro_Lab_810_5Y_1.00 >									
//        < abDoAN163oMbac5c1232b744Ta7SW8Pf8Wn7BssY56xAk471ET2z368kctj43Iz6 >									
//        <  u =="0.000000000000000001" : ] 000001465139753.700040000000000000 ; 000001475139753.700040000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000008BBA0378CAE277 >									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
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
//     < NDD_ETH_I_metadata_line_31_____621353071 ro_Lab_810_5Y_1.10 >									
//        < px4NQ25l7J4JkTgoc6ygQboUN33ik56axNQoLUxj5CEYT6iUuIN1L2bEZ823Dz8h >									
//        <  u =="0.000000000000000001" : ] 000001475139753.700040000000000000 ; 000001485139753.700040000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000008CAE2778DA24B7 >									
//     < NDD_ETH_I_metadata_line_32_____8914127767 ro_Lab_810_7Y_1.00 >									
//        < 5RS904S8Gkbz20R8MtQ988X707HDXU89G8z67VLXMA3a7b46uaiQ4LR3Tpjg8S0w >									
//        <  u =="0.000000000000000001" : ] 000001485139753.700040000000000000 ; 000001495139753.700040000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000008DA24B78E966F7 >									
//     < NDD_ETH_I_metadata_line_33_____2323232323 ro_Lab_411_3Y_1.00 >									
//        < tEzSLmcMTZAQ84Dxu6j41T3vvyuw1OsLfM0sJ3YMSx6rlhnm5vJ1g9Gsyrc1LKDG >									
//        <  u =="0.000000000000000001" : ] 000001495139753.700040000000000000 ; 000005870630512.910660000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000008E966F722FDDF0B >									
//     < NDD_ETH_I_metadata_line_34_____2323232323 ro_Lab_411_5Y_1.00 >									
//        < r3eai8r33o6VhNswkU8AkGU55ldiSwLuZ6u4kxQy088v172INboFaJXuG0Nq5IFM >									
//        <  u =="0.000000000000000001" : ] 000005870630512.910660000000000000 ; 000005880630512.910660000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000022FDDF0B230D214B >									
//     < NDD_ETH_I_metadata_line_35_____2323232323 ro_Lab_411_5Y_1.10 >									
//        < Wp4Vu4rf64A29670b24233B46Rb33s4m0np5UT7BgNy843BBvsXrS97bU0xm3zL4 >									
//        <  u =="0.000000000000000001" : ] 000005880630512.910660000000000000 ; 000005890630512.910660000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000230D214B231C638B >									
//     < NDD_ETH_I_metadata_line_36_____2323232323 ro_Lab_411_7Y_1.00 >									
//        < 1HO5MVbqRxJ5DW8HlZF3744PGF4S9f161NYy0we17z2Poi6G2s9Ue2awNDpLzuD0 >									
//        <  u =="0.000000000000000001" : ] 000005890630512.910660000000000000 ; 000005900630512.910660000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000231C638B232BA5CB >									
//     < NDD_ETH_I_metadata_line_37_____2323232323 ro_Lab_811_3Y_1.00 >									
//        < mjP7162bx13YLFOAD33wl2CjE8VT7uZ8sF95YsMXK23sbg0UmjzTNiuM49rx2UzE >									
//        <  u =="0.000000000000000001" : ] 000005900630512.910660000000000000 ; 000037713339574.653100000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000232BA5CBE0C9FD45 >									
//     < NDD_ETH_I_metadata_line_38_____2323232323 ro_Lab_811_5Y_1.00 >									
//        < fq5E4K095Dg0VYE08435xeWX1Hg8gH0T5BCb258qA8Wzm2P7HTAuc569g5JO34aM >									
//        <  u =="0.000000000000000001" : ] 000037713339574.653100000000000000 ; 000037723339574.653100000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000E0C9FD45E0D93F85 >									
//     < NDD_ETH_I_metadata_line_39_____2323232323 ro_Lab_811_5Y_1.10 >									
//        < TXHir5DP7jWB09E8gZ6Pq03lx32EZlin2h7jlBFYF9Z7wxI64Hf1f1hluQFkQXnT >									
//        <  u =="0.000000000000000001" : ] 000037723339574.653100000000000000 ; 000037733339574.653100000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000E0D93F85E0E881C5 >									
//     < NDD_ETH_I_metadata_line_40_____2323232323 ro_Lab_811_7Y_1.00 >									
//        < CvBSv9dWxShg997XQ1khfhOsv2q3ojR42S3745U0f1ktJWMJyCcDe51oE60h9WN5 >									
//        <  u =="0.000000000000000001" : ] 000037733339574.653100000000000000 ; 000037743339574.653100000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000E0E881C5E0F7C405 >									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
}