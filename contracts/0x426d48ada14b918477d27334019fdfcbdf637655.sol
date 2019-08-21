pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFVI_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFVI_II_883		"	;
		string	public		symbol =	"	RUSS_PFVI_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		798915299627427000000000000					;	
										
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
	//     < RUSS_PFVI_II_metadata_line_1_____UPRECHISTENKA1_3319C1_MOS_RUS_I_20231101 >									
	//        < VnsG1apr7Kw90LCnFys5Xq26Do1p9RTOW8nCYf9q8ny2eXPNe6N7Pakb317Mv3Rc >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000022446769.344987100000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000224045 >									
	//     < RUSS_PFVI_II_metadata_line_2_____UPRECHISTENKA1_3319C1_MOS_RUS_II_20231101 >									
	//        < zCS2jkfBBdg8TZBP74CiDWa9Y78PfFlte28U7yYDhArS2m42frafu18YwlJxBl1z >									
	//        <  u =="0.000000000000000001" : ] 000000022446769.344987100000000000 ; 000000038806348.630402300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002240453B36BB >									
	//     < RUSS_PFVI_II_metadata_line_3_____UPRECHISTENKA1_3319C1_MOS_RUS_III_20231101 >									
	//        < 0XiwSJ1Q59qXC5VTPx6rgm86Mou0KWGE73Fv240NiFCWPhTEyNpwahee68VHwt5z >									
	//        <  u =="0.000000000000000001" : ] 000000038806348.630402300000000000 ; 000000061356867.029025400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003B36BB5D9F87 >									
	//     < RUSS_PFVI_II_metadata_line_4_____UPRECHISTENKA1_3319C1_MOS_RUS_IV_20231101 >									
	//        < fv06WWd4kIa37x8d4sYY6tTs66BNPV529NXwpd25zm98FnANQtr3vi8hROGeQTUI >									
	//        <  u =="0.000000000000000001" : ] 000000061356867.029025400000000000 ; 000000080537618.936690600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005D9F877AE402 >									
	//     < RUSS_PFVI_II_metadata_line_5_____UPRECHISTENKA1_3319C1_MOS_RUS_V_20231101 >									
	//        < 3wa581uZZ36kP5TBsS5lG00uq540H351x3Vj26UvBgEro7fP3O58g1S36GWO895V >									
	//        <  u =="0.000000000000000001" : ] 000000080537618.936690600000000000 ; 000000103321583.058244000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007AE4029DA7FE >									
	//     < RUSS_PFVI_II_metadata_line_6_____UPRECHISTENKA1_3319C1_MOS_RUS_VI_20231101 >									
	//        < d60gYtj8znMbK6cL9vt16a2Jd6J7dRD1A20spe98c08wvYRFCyGLLc9KcGTMDuL1 >									
	//        <  u =="0.000000000000000001" : ] 000000103321583.058244000000000000 ; 000000118863519.020541000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009DA7FEB55F10 >									
	//     < RUSS_PFVI_II_metadata_line_7_____UPRECHISTENKA1_3319C1_MOS_RUS_VII_20231101 >									
	//        < r4F2Mk4Gj31q81M0KLy7MK9KCwN220345uGY89pWWjHy0vYt0UisXbPHs7Nita5Q >									
	//        <  u =="0.000000000000000001" : ] 000000118863519.020541000000000000 ; 000000141303473.179551000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B55F10D79CAB >									
	//     < RUSS_PFVI_II_metadata_line_8_____UPRECHISTENKA1_3319C1_MOS_RUS_VIII_20231101 >									
	//        < R80T1wG7IRkA1X4v19PWC0GC6AB93N8HdO3v1n4nVTp4g97nk72ko1QUNo3fPt43 >									
	//        <  u =="0.000000000000000001" : ] 000000141303473.179551000000000000 ; 000000159665864.078373000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D79CABF3A17A >									
	//     < RUSS_PFVI_II_metadata_line_9_____UPRECHISTENKA1_3319C1_MOS_RUS_IX_20231101 >									
	//        < NU98Sj7Fxhz02PQ1q4QskS43RdmEpy2Z9ws33vPf48pl7tS3ei14ZVAEGjaD6fhM >									
	//        <  u =="0.000000000000000001" : ] 000000159665864.078373000000000000 ; 000000175940780.832781000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F3A17A10C76DE >									
	//     < RUSS_PFVI_II_metadata_line_10_____UPRECHISTENKA1_3319C1_MOS_RUS_X_20231101 >									
	//        < wE63LUQGlF34I5Wj7dyjyg9bk6Ma86Fr2lqd07192v7w1gR5W539f9cfFd7Q2Jeg >									
	//        <  u =="0.000000000000000001" : ] 000000175940780.832781000000000000 ; 000000196318413.570130000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010C76DE12B8EE1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFVI_II_metadata_line_11_____UPRECHISTENKA2_3319C1_MOS_RUS_I_20231101 >									
	//        < 924c81POqSLfriOX5x5dFOp2je2B635i4Wv51Zu5Rgk2u7HOI7ljsw905VEcz71u >									
	//        <  u =="0.000000000000000001" : ] 000000196318413.570130000000000000 ; 000000215455929.812996000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012B8EE1148C279 >									
	//     < RUSS_PFVI_II_metadata_line_12_____UPRECHISTENKA2_3319C1_MOS_RUS_II_20231101 >									
	//        < qQYcU8qMgJGNX3ep9P3C2Wrr9Upkk7ds4GqDZ2C5x8241l761t3GT8954ygh71CP >									
	//        <  u =="0.000000000000000001" : ] 000000215455929.812996000000000000 ; 000000240312392.908691000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000148C27916EB007 >									
	//     < RUSS_PFVI_II_metadata_line_13_____UPRECHISTENKA2_3319C1_MOS_RUS_III_20231101 >									
	//        < v3Q02xvYJPTpIe7y2yKYK5NXPDB16Zg9Hblm0ModVb3nN2YQLaQ6088Fg5aypel2 >									
	//        <  u =="0.000000000000000001" : ] 000000240312392.908691000000000000 ; 000000260298218.707069000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016EB00718D2EFE >									
	//     < RUSS_PFVI_II_metadata_line_14_____UPRECHISTENKA2_3319C1_MOS_RUS_IV_20231101 >									
	//        < S4y2bYT6zj891CD8XasIqJf7B3FWereL8ufjkx12Q4N3R6lA758iaif57I8Cl3y3 >									
	//        <  u =="0.000000000000000001" : ] 000000260298218.707069000000000000 ; 000000284599753.703762000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018D2EFE1B243C7 >									
	//     < RUSS_PFVI_II_metadata_line_15_____UPRECHISTENKA2_3319C1_MOS_RUS_V_20231101 >									
	//        < XN9d0sFfNIpIKPtJ6Eb0PvE50pvcEmWsh8nS3L8mO61hi3KZW76DfHQq8IwB8uzZ >									
	//        <  u =="0.000000000000000001" : ] 000000284599753.703762000000000000 ; 000000304508677.217467000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B243C71D0A4B4 >									
	//     < RUSS_PFVI_II_metadata_line_16_____UPRECHISTENKA2_3319C1_MOS_RUS_VI_20231101 >									
	//        < 5O7qZ63QDyZCaThqaDvBSKKwrK092iZrJ9T1164ztyioNH7Uo0O5iqE1aPtY272a >									
	//        <  u =="0.000000000000000001" : ] 000000304508677.217467000000000000 ; 000000322350255.372609000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D0A4B41EBDE12 >									
	//     < RUSS_PFVI_II_metadata_line_17_____UPRECHISTENKA2_3319C1_MOS_RUS_VII_20231101 >									
	//        < ERGRIs328DQYCfsAvg2is8UDqJvN9m6gFy4oxdIRURvY2EN0XWOc802d38594sqc >									
	//        <  u =="0.000000000000000001" : ] 000000322350255.372609000000000000 ; 000000345129447.761815000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EBDE1220EA031 >									
	//     < RUSS_PFVI_II_metadata_line_18_____UPRECHISTENKA2_3319C1_MOS_RUS_VIII_20231101 >									
	//        < 1b43egtvf89SXM08tAUMHB17351i7655xcRKe9nTH7XZm2TSg2q7ZGm822xJHujv >									
	//        <  u =="0.000000000000000001" : ] 000000345129447.761815000000000000 ; 000000363347349.587894000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020EA03122A6C8F >									
	//     < RUSS_PFVI_II_metadata_line_19_____UPRECHISTENKA2_3319C1_MOS_RUS_IX_20231101 >									
	//        < 9328lE7aIXv3o6thdg04xDXpH25Yg993dO3s43cNB5l6yp2r0LOO1Gh7q2R4iO05 >									
	//        <  u =="0.000000000000000001" : ] 000000363347349.587894000000000000 ; 000000380448600.807730000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022A6C8F24484BC >									
	//     < RUSS_PFVI_II_metadata_line_20_____UPRECHISTENKA2_3319C1_MOS_RUS_X_20231101 >									
	//        < hsXxJ90K60S88HweR87rBasa5M52p7YNFm4LRTnwQew5n233V8satr8a84ilLol9 >									
	//        <  u =="0.000000000000000001" : ] 000000380448600.807730000000000000 ; 000000400076963.963727000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024484BC2627810 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFVI_II_metadata_line_21_____UPRECHISTENKA2_3319C1_MOS_RUS_I_20231101 >									
	//        < scp2046ol8rf3ySpe9dcTDGmK1trH8uuM25hC7ghv4hl2ji7uN0M6I6Z7Hve1TK9 >									
	//        <  u =="0.000000000000000001" : ] 000000400076963.963727000000000000 ; 000000416239555.437980000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000262781027B2194 >									
	//     < RUSS_PFVI_II_metadata_line_22_____UPRECHISTENKA2_3319C1_MOS_RUS_II_20231101 >									
	//        < A0NE4Ra4Jw0B6b8XDD8Md7Ye1ircy7Hpe5Jm4H21Ii0vNzpf5bM5fPI475cn6CTh >									
	//        <  u =="0.000000000000000001" : ] 000000416239555.437980000000000000 ; 000000435899176.884680000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027B2194299211E >									
	//     < RUSS_PFVI_II_metadata_line_23_____UPRECHISTENKA2_3319C1_MOS_RUS_III_20231101 >									
	//        < E91F23191J57b77oxX5Itpq7l2A8O2YRl1CfolQ3EaspZgumI8Bg5t862tyfkLG0 >									
	//        <  u =="0.000000000000000001" : ] 000000435899176.884680000000000000 ; 000000459082266.194224000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000299211E2BC8103 >									
	//     < RUSS_PFVI_II_metadata_line_24_____UPRECHISTENKA2_3319C1_MOS_RUS_IV_20231101 >									
	//        < z1CHHo5uF0c8ni6DQ7BkDZy4vYb9hGl0AzYpQlD1R9AL12307Uv31olOV2sEp2xB >									
	//        <  u =="0.000000000000000001" : ] 000000459082266.194224000000000000 ; 000000474694334.893265000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BC81032D45379 >									
	//     < RUSS_PFVI_II_metadata_line_25_____UPRECHISTENKA2_3319C1_MOS_RUS_V_20231101 >									
	//        < B18qRk6YG7k1NBrUE8NzYNqr2h426yX82G27hj1x7E62NaS3Bgh0056476kHB06b >									
	//        <  u =="0.000000000000000001" : ] 000000474694334.893265000000000000 ; 000000495994724.995499000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D453792F4D3F0 >									
	//     < RUSS_PFVI_II_metadata_line_26_____UPRECHISTENKA2_3319C1_MOS_RUS_VI_20231101 >									
	//        < drHO2a895k1aUV5H9MJePj5IwG0qlMikhhI4LqR1kONtdX1OLmlry7C3o59aWNE9 >									
	//        <  u =="0.000000000000000001" : ] 000000495994724.995499000000000000 ; 000000515872599.296615000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F4D3F031328BC >									
	//     < RUSS_PFVI_II_metadata_line_27_____UPRECHISTENKA2_3319C1_MOS_RUS_VII_20231101 >									
	//        < wOMKukT4Er08dgX7NS44ScB9qB8i86p3bt1rTs3j2IrEUu90ZrMxw37P1kO2nab9 >									
	//        <  u =="0.000000000000000001" : ] 000000515872599.296615000000000000 ; 000000531815626.807050000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031328BC32B7C7B >									
	//     < RUSS_PFVI_II_metadata_line_28_____UPRECHISTENKA2_3319C1_MOS_RUS_VIII_20231101 >									
	//        < bSq5oaAhRS47c6W61t6L1Isz5Y79Cu1fIFx3G78Hn01dUm631VzB8sHFUN403T75 >									
	//        <  u =="0.000000000000000001" : ] 000000531815626.807050000000000000 ; 000000555444065.940756000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032B7C7B34F8A57 >									
	//     < RUSS_PFVI_II_metadata_line_29_____UPRECHISTENKA2_3319C1_MOS_RUS_IX_20231101 >									
	//        < CC2486cCGYsbbdU2372z74vPgmbowQ0c7GPz5lCITYW8vYzJ2gVY3vb1761Q7DFw >									
	//        <  u =="0.000000000000000001" : ] 000000555444065.940756000000000000 ; 000000574438744.177598000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034F8A5736C8622 >									
	//     < RUSS_PFVI_II_metadata_line_30_____UPRECHISTENKA2_3319C1_MOS_RUS_X_20231101 >									
	//        < o9EXe7VWGF8B49mC4Dp8YLPZ2k0536ZK4eGznjBU8Sd9fwao7trCnw79836QtE1V >									
	//        <  u =="0.000000000000000001" : ] 000000574438744.177598000000000000 ; 000000591034410.497250000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036C8622385D8D1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFVI_II_metadata_line_31_____UPRECHISTENKA3_3319C1_MOS_RUS_I_20231101 >									
	//        < MrZO18BojhQu23U9ShlRPOR0G00NvN5HlZOpmm5Lm52MlW4S33E63w086q6048vT >									
	//        <  u =="0.000000000000000001" : ] 000000591034410.497250000000000000 ; 000000615761316.191241000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000385D8D13AB93C4 >									
	//     < RUSS_PFVI_II_metadata_line_32_____UPRECHISTENKA3_3319C1_MOS_RUS_II_20231101 >									
	//        < tSzr5JrraUeqL9xvBg62g1g92xBSKWr600EM5Mj0t2KRM0l7FnNi9WoP1ZcKejb6 >									
	//        <  u =="0.000000000000000001" : ] 000000615761316.191241000000000000 ; 000000634377421.568422000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003AB93C43C7FBAE >									
	//     < RUSS_PFVI_II_metadata_line_33_____UPRECHISTENKA3_3319C1_MOS_RUS_III_20231101 >									
	//        < OLMR2I4jxt8AfmAbYlmHWd5QhVktrXWg2U8sBbl6Y0G3eZTex74Sd2I53jTIxMF3 >									
	//        <  u =="0.000000000000000001" : ] 000000634377421.568422000000000000 ; 000000650577541.105366000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C7FBAE3E0B3DA >									
	//     < RUSS_PFVI_II_metadata_line_34_____UPRECHISTENKA3_3319C1_MOS_RUS_IV_20231101 >									
	//        < 0rpnimfuQE1Rv5TtIKk3mop7II0A90m78rlB6MbFwMJO5sg2XSoea0wfvG1G4hZy >									
	//        <  u =="0.000000000000000001" : ] 000000650577541.105366000000000000 ; 000000674949613.463135000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E0B3DA405E431 >									
	//     < RUSS_PFVI_II_metadata_line_35_____UPRECHISTENKA3_3319C1_MOS_RUS_V_20231101 >									
	//        < FDVzdu71d2IxIb9KeUQ423E9NtC485l0Guk4DiMe2xEi2QVA11hcq8dPvzjKaZdO >									
	//        <  u =="0.000000000000000001" : ] 000000674949613.463135000000000000 ; 000000693245907.486132000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000405E431421CF2F >									
	//     < RUSS_PFVI_II_metadata_line_36_____UPRECHISTENKA3_3319C1_MOS_RUS_VI_20231101 >									
	//        < Sm68oJL8GBo06Yr49W90P1cF10RHc0gym65uh5n0akF9ah6j71j9v2VtPI7vTG3Y >									
	//        <  u =="0.000000000000000001" : ] 000000693245907.486132000000000000 ; 000000708695176.251644000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000421CF2F439620E >									
	//     < RUSS_PFVI_II_metadata_line_37_____UPRECHISTENKA3_3319C1_MOS_RUS_VII_20231101 >									
	//        < coeBz4lN0YSA3kSqBVSeqWVhj6dkg524imOHcmkAtGZXMtu76F6QbOU8hQsAd9q6 >									
	//        <  u =="0.000000000000000001" : ] 000000708695176.251644000000000000 ; 000000732825622.523219000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000439620E45E3402 >									
	//     < RUSS_PFVI_II_metadata_line_38_____UPRECHISTENKA3_3319C1_MOS_RUS_VIII_20231101 >									
	//        < MIlKQ385M8R9nMIPEnq1101zO2zCZV52RK81NoqyL3sei3tOuZhTo1ALT59euFVn >									
	//        <  u =="0.000000000000000001" : ] 000000732825622.523219000000000000 ; 000000752653809.966159000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000045E340247C7565 >									
	//     < RUSS_PFVI_II_metadata_line_39_____UPRECHISTENKA3_3319C1_MOS_RUS_IX_20231101 >									
	//        < Vlkp9o73S9d1ox0OzidMvdZ83EXgWIWZ3L701Gb66l60zv8iU7FsaRuKMo5tIUOK >									
	//        <  u =="0.000000000000000001" : ] 000000752653809.966159000000000000 ; 000000776488818.223982000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000047C75654A0D3F2 >									
	//     < RUSS_PFVI_II_metadata_line_40_____UPRECHISTENKA3_3319C1_MOS_RUS_X_20231101 >									
	//        < ZB07LwGCzwiibeR4AvbG34GL53v9778f47Q1v4lq1o8a7VY8l9T5lmQkk72aK6qt >									
	//        <  u =="0.000000000000000001" : ] 000000776488818.223982000000000000 ; 000000798915299.627427000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A0D3F24C30C4A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}