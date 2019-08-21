pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFVI_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFVI_I_883		"	;
		string	public		symbol =	"	RUSS_PFVI_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		608977150836653000000000000					;	
										
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
	//     < RUSS_PFVI_I_metadata_line_1_____UPRECHISTENKA1_3319C1_MOS_RUS_I_20211101 >									
	//        < M06WwQ9GwHa8cz4RWEuBcHGGRT30f35TGu0IN7c53WpXyPRCHzC8czxjB3511c07 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000015978024.622414400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000018616A >									
	//     < RUSS_PFVI_I_metadata_line_2_____UPRECHISTENKA1_3319C1_MOS_RUS_II_20211101 >									
	//        < 6d7al54Hei11M7nNt2IX8p90P382qD4newuikQaDYxD2RsPAN8X4VXH9116Je6K1 >									
	//        <  u =="0.000000000000000001" : ] 000000015978024.622414400000000000 ; 000000032982302.805799800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000018616A3253B6 >									
	//     < RUSS_PFVI_I_metadata_line_3_____UPRECHISTENKA1_3319C1_MOS_RUS_III_20211101 >									
	//        < 3CU653Fh4j5PcXTaT2BbeU705BMve6tFo91EEgk8f12LCdc3ZKZ3Bi90DtIu1sit >									
	//        <  u =="0.000000000000000001" : ] 000000032982302.805799800000000000 ; 000000047434219.360019100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003253B64860FE >									
	//     < RUSS_PFVI_I_metadata_line_4_____UPRECHISTENKA1_3319C1_MOS_RUS_IV_20211101 >									
	//        < MlJHhB3tPCbEKsx678F3Y4748pBjqjJNfNf38Z1AH6f0D6MQW1ZVKJ1rok2G6rpS >									
	//        <  u =="0.000000000000000001" : ] 000000047434219.360019100000000000 ; 000000062565321.422385300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004860FE5F7794 >									
	//     < RUSS_PFVI_I_metadata_line_5_____UPRECHISTENKA1_3319C1_MOS_RUS_V_20211101 >									
	//        < dySEK2hEBshSLD50Zg0faVN2zo941ngLG62DpCUdXGmn8v4bxx51o8gjm595ANUK >									
	//        <  u =="0.000000000000000001" : ] 000000062565321.422385300000000000 ; 000000075702115.555311900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005F7794738324 >									
	//     < RUSS_PFVI_I_metadata_line_6_____UPRECHISTENKA1_3319C1_MOS_RUS_VI_20211101 >									
	//        < 9QZgNW8Tz9Dnna6ezNV19E6Qz17s27e68vI33WYkCO4g2X0HdjA4e0xTxMa2EMN5 >									
	//        <  u =="0.000000000000000001" : ] 000000075702115.555311900000000000 ; 000000092479067.607412100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007383248D1CA3 >									
	//     < RUSS_PFVI_I_metadata_line_7_____UPRECHISTENKA1_3319C1_MOS_RUS_VII_20211101 >									
	//        < QjdigSi4xVemtlZD2zmk8ux0W3NB9781Qa39A4Ll90fD2570J7RJ8xGFpAVfb6sY >									
	//        <  u =="0.000000000000000001" : ] 000000092479067.607412100000000000 ; 000000106227108.111923000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008D1CA3A216F7 >									
	//     < RUSS_PFVI_I_metadata_line_8_____UPRECHISTENKA1_3319C1_MOS_RUS_VIII_20211101 >									
	//        < BWF314Y1N6y9zcSDQ230UrN0eQiN5h8KuRv7J4193l8EAwBgSDCr2J2r16wcCNUP >									
	//        <  u =="0.000000000000000001" : ] 000000106227108.111923000000000000 ; 000000121578377.957438000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A216F7B9838E >									
	//     < RUSS_PFVI_I_metadata_line_9_____UPRECHISTENKA1_3319C1_MOS_RUS_IX_20211101 >									
	//        < iH4L6SBZ7OMv4MCX8ITWaa2UssS9AhI7Um8FfFCZ23ME0W4566RDKp9VExVe21H9 >									
	//        <  u =="0.000000000000000001" : ] 000000121578377.957438000000000000 ; 000000134786752.319081000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B9838ECDAB13 >									
	//     < RUSS_PFVI_I_metadata_line_10_____UPRECHISTENKA1_3319C1_MOS_RUS_X_20211101 >									
	//        < WT7CX448jo930DC7t2Ns95cnIH5xfIRW7bqRf3B52406HSNmeF1b9C81Bav69rwF >									
	//        <  u =="0.000000000000000001" : ] 000000134786752.319081000000000000 ; 000000149005685.491154000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CDAB13E35D59 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFVI_I_metadata_line_11_____UPRECHISTENKA2_3319C1_MOS_RUS_I_20211101 >									
	//        < mYIFDSAWh95BET61PT530xzVnY225SptR6tGoy7XhAp8NpuPG3z5hRiYZA5CcI3Q >									
	//        <  u =="0.000000000000000001" : ] 000000149005685.491154000000000000 ; 000000164355630.747045000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E35D59FAC96B >									
	//     < RUSS_PFVI_I_metadata_line_12_____UPRECHISTENKA2_3319C1_MOS_RUS_II_20211101 >									
	//        < 8p508rlcK5v9jJ7N2UVnjVQvnR3bov5t5b3AE2dbJB5n3AcTKV8TwiL8OEDc7ZM2 >									
	//        <  u =="0.000000000000000001" : ] 000000164355630.747045000000000000 ; 000000180375077.136172000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FAC96B1133B04 >									
	//     < RUSS_PFVI_I_metadata_line_13_____UPRECHISTENKA2_3319C1_MOS_RUS_III_20211101 >									
	//        < B2b9sIF6h9uO2IsNftlG5OB1JsCU34bLL8Fa0WKC05zmEILo1F8A2p2Es09j55Rk >									
	//        <  u =="0.000000000000000001" : ] 000000180375077.136172000000000000 ; 000000196271203.152651000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001133B0412B7C70 >									
	//     < RUSS_PFVI_I_metadata_line_14_____UPRECHISTENKA2_3319C1_MOS_RUS_IV_20211101 >									
	//        < boMjrR01b2x8Yx906H5avyJ07zv6nwP66I89csH59p1bXE6eiO88EZXqNARsB73Z >									
	//        <  u =="0.000000000000000001" : ] 000000196271203.152651000000000000 ; 000000210442757.079127000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012B7C701411C34 >									
	//     < RUSS_PFVI_I_metadata_line_15_____UPRECHISTENKA2_3319C1_MOS_RUS_V_20211101 >									
	//        < Z38133ndGWmfpGSnp2HOLUK20cI1Uawvkoa8e0Ywq2GFU4F83IgVN07N5D2XNIwm >									
	//        <  u =="0.000000000000000001" : ] 000000210442757.079127000000000000 ; 000000225203507.035794000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001411C34157A21F >									
	//     < RUSS_PFVI_I_metadata_line_16_____UPRECHISTENKA2_3319C1_MOS_RUS_VI_20211101 >									
	//        < 75UgJl1s00UHo1fi90D57G4k2SyQ45e2u24W9eg1ckjxy5r14HfAIrI06tdgQDsP >									
	//        <  u =="0.000000000000000001" : ] 000000225203507.035794000000000000 ; 000000239807116.743309000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000157A21F16DEAA8 >									
	//     < RUSS_PFVI_I_metadata_line_17_____UPRECHISTENKA2_3319C1_MOS_RUS_VII_20211101 >									
	//        < VkD6qiA8N0HUHUGa7Y7nJ5xt840D7jC96sQ9evg8bSUPo4UQ4KegCg00ekdgpHV7 >									
	//        <  u =="0.000000000000000001" : ] 000000239807116.743309000000000000 ; 000000254710636.963116000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016DEAA8184A858 >									
	//     < RUSS_PFVI_I_metadata_line_18_____UPRECHISTENKA2_3319C1_MOS_RUS_VIII_20211101 >									
	//        < Hm4Zq4sO0DUPT05nUa55w11j6qZqhqnTuk9lrHz8u44FMoafC48t52f1A236uHhM >									
	//        <  u =="0.000000000000000001" : ] 000000254710636.963116000000000000 ; 000000269838066.466455000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000184A85819BBD7F >									
	//     < RUSS_PFVI_I_metadata_line_19_____UPRECHISTENKA2_3319C1_MOS_RUS_IX_20211101 >									
	//        < Q9T6zL6fz1197qMja18m433J3My8xM776xU27RwhQ0MD2FlD4XurD8k72w1t7uWw >									
	//        <  u =="0.000000000000000001" : ] 000000269838066.466455000000000000 ; 000000285211450.000160000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019BBD7F1B332B9 >									
	//     < RUSS_PFVI_I_metadata_line_20_____UPRECHISTENKA2_3319C1_MOS_RUS_X_20211101 >									
	//        < g546lrTwFHYQmucedCM822o7AdPYed2s3fmIfJPrf0lsgfGre3HEag0D5Si3ZkHD >									
	//        <  u =="0.000000000000000001" : ] 000000285211450.000160000000000000 ; 000000300361522.108105000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B332B91CA50B8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFVI_I_metadata_line_21_____UPRECHISTENKA2_3319C1_MOS_RUS_I_20211101 >									
	//        < Kd0W578Pl1k41L69vM8TjCI2hJS56KFRz97V2409SEBR3V0DA4ATtNQ599f8yA7m >									
	//        <  u =="0.000000000000000001" : ] 000000300361522.108105000000000000 ; 000000314892441.345543000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CA50B81E07CDC >									
	//     < RUSS_PFVI_I_metadata_line_22_____UPRECHISTENKA2_3319C1_MOS_RUS_II_20211101 >									
	//        < 0F3ya0K8V94v2R2WNhqO7kBM9S48Jmm8EfyjKVBG1SKJ71aE2nyl8Vb28De8qX69 >									
	//        <  u =="0.000000000000000001" : ] 000000314892441.345543000000000000 ; 000000328709903.909305000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E07CDC1F5924E >									
	//     < RUSS_PFVI_I_metadata_line_23_____UPRECHISTENKA2_3319C1_MOS_RUS_III_20211101 >									
	//        < qmCwX3777cZIXgcxZo8684qviHQ07IA9804O84iycQc328VXc24nB0COS2PZ4nfd >									
	//        <  u =="0.000000000000000001" : ] 000000328709903.909305000000000000 ; 000000344273491.521433000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F5924E20D51D5 >									
	//     < RUSS_PFVI_I_metadata_line_24_____UPRECHISTENKA2_3319C1_MOS_RUS_IV_20211101 >									
	//        < 8rQqFVj7Jn0YcjlIQ7g1YQ5xZz7z5Fvv5oSn60e60tn3m5B2GlyQfMCL9RFE1N09 >									
	//        <  u =="0.000000000000000001" : ] 000000344273491.521433000000000000 ; 000000360202948.738353000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020D51D5225A047 >									
	//     < RUSS_PFVI_I_metadata_line_25_____UPRECHISTENKA2_3319C1_MOS_RUS_V_20211101 >									
	//        < n2ieezB7hJ0Xl6zzbM1uM6Y4510ydcmApqO8ia7a79IHY7bioH587Pn9Gnk32BAM >									
	//        <  u =="0.000000000000000001" : ] 000000360202948.738353000000000000 ; 000000377087539.810240000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000225A04723F63D2 >									
	//     < RUSS_PFVI_I_metadata_line_26_____UPRECHISTENKA2_3319C1_MOS_RUS_VI_20211101 >									
	//        < uFsZMj6h433I775LBu69tQVw6n76XQQ2ugkTi4sXstRGvLZ8Z901LnhR9TuENXp0 >									
	//        <  u =="0.000000000000000001" : ] 000000377087539.810240000000000000 ; 000000391987678.776099000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023F63D22562030 >									
	//     < RUSS_PFVI_I_metadata_line_27_____UPRECHISTENKA2_3319C1_MOS_RUS_VII_20211101 >									
	//        < qrUJe06a8teSqe6PEXRa43vvoo1G5bu6ULD2IVTZ4178U0z4lQakLd4La2j99CX1 >									
	//        <  u =="0.000000000000000001" : ] 000000391987678.776099000000000000 ; 000000407835298.366159000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000256203026E4EAA >									
	//     < RUSS_PFVI_I_metadata_line_28_____UPRECHISTENKA2_3319C1_MOS_RUS_VIII_20211101 >									
	//        < 77P91C3F34p5a861bRmQkp6j7N6lQ9QW5w2w42YXbN0kA4TzL5nUCnG6z32xiUtp >									
	//        <  u =="0.000000000000000001" : ] 000000407835298.366159000000000000 ; 000000424567947.982681000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026E4EAA287D6DB >									
	//     < RUSS_PFVI_I_metadata_line_29_____UPRECHISTENKA2_3319C1_MOS_RUS_IX_20211101 >									
	//        < EXs1VJvrZSaoFU5NX51P1199J0UyqvSs5xxq44Q20H9I2Dp6hYVMUeAWSm2e2l1y >									
	//        <  u =="0.000000000000000001" : ] 000000424567947.982681000000000000 ; 000000440346593.281607000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000287D6DB29FEA63 >									
	//     < RUSS_PFVI_I_metadata_line_30_____UPRECHISTENKA2_3319C1_MOS_RUS_X_20211101 >									
	//        < ASi872i027366MTORFh8Q8f4vt7s8AWeCj19lf8WZvl3JGsl8RL40aZHwB88LN2J >									
	//        <  u =="0.000000000000000001" : ] 000000440346593.281607000000000000 ; 000000456851628.116457000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029FEA632B919AB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFVI_I_metadata_line_31_____UPRECHISTENKA3_3319C1_MOS_RUS_I_20211101 >									
	//        < TulWOt4tVHI53E3RxxbL0YYbxPM709tY2XI8G34XHQVa11T9nVDGcEgGg1lCs8ZK >									
	//        <  u =="0.000000000000000001" : ] 000000456851628.116457000000000000 ; 000000473178871.873356000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B919AB2D2037F >									
	//     < RUSS_PFVI_I_metadata_line_32_____UPRECHISTENKA3_3319C1_MOS_RUS_II_20211101 >									
	//        < 91lcqooe8b2nhzE1iB54Ka3YPr1JD6jx1h1VL8H0c2C7ebJfs6yb3WaqCc2j4iod >									
	//        <  u =="0.000000000000000001" : ] 000000473178871.873356000000000000 ; 000000486229537.001495000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D2037F2E5ED6A >									
	//     < RUSS_PFVI_I_metadata_line_33_____UPRECHISTENKA3_3319C1_MOS_RUS_III_20211101 >									
	//        < d1JWeSHN0Vng32s52fBRmZGNVa7d22K3vVQ3Z0ZA65B43qnRvCTvq653K3aA2unI >									
	//        <  u =="0.000000000000000001" : ] 000000486229537.001495000000000000 ; 000000500750980.049652000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E5ED6A2FC15DA >									
	//     < RUSS_PFVI_I_metadata_line_34_____UPRECHISTENKA3_3319C1_MOS_RUS_IV_20211101 >									
	//        < D9LSGD750sZLUqwI9P0kmsGqam8C7zS103TPP43d38msct52mC6sVBUVu15440xp >									
	//        <  u =="0.000000000000000001" : ] 000000500750980.049652000000000000 ; 000000517097936.286066000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FC15DA3150762 >									
	//     < RUSS_PFVI_I_metadata_line_35_____UPRECHISTENKA3_3319C1_MOS_RUS_V_20211101 >									
	//        < FC1ECY9XgqO8O3dq32Yf3oEZyoAqb8y0G4ABHQi4wIrFW0U1ca0cmWP0R4pkSVAm >									
	//        <  u =="0.000000000000000001" : ] 000000517097936.286066000000000000 ; 000000534279329.072216000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000315076232F3EDD >									
	//     < RUSS_PFVI_I_metadata_line_36_____UPRECHISTENKA3_3319C1_MOS_RUS_VI_20211101 >									
	//        < cS50D91G3AZZ83052ll0jN1c286RieFiZbfmLusK6o60UDb2JCVxL0464KbVRtGE >									
	//        <  u =="0.000000000000000001" : ] 000000534279329.072216000000000000 ; 000000549105308.467278000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032F3EDD345DE43 >									
	//     < RUSS_PFVI_I_metadata_line_37_____UPRECHISTENKA3_3319C1_MOS_RUS_VII_20211101 >									
	//        < V2F1jZKk391UlFuE8075ixU8SVIPb497wLwhRLyur8HVLhh1IrLfdYFH8PQGwuEx >									
	//        <  u =="0.000000000000000001" : ] 000000549105308.467278000000000000 ; 000000564206564.148881000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000345DE4335CE930 >									
	//     < RUSS_PFVI_I_metadata_line_38_____UPRECHISTENKA3_3319C1_MOS_RUS_VIII_20211101 >									
	//        < y2UbYL4Z6783jW9SECKgR4qJK14GJExYr5E2id303ua919qCZz43lPhISm247v36 >									
	//        <  u =="0.000000000000000001" : ] 000000564206564.148881000000000000 ; 000000578278886.012927000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035CE9303726231 >									
	//     < RUSS_PFVI_I_metadata_line_39_____UPRECHISTENKA3_3319C1_MOS_RUS_IX_20211101 >									
	//        < v8xKFbhN2GPS4je8Kkwm3Id9JIT0Bb1fiCWW9rh7TF4z4iEz72M8AK51h9nvgOW9 >									
	//        <  u =="0.000000000000000001" : ] 000000578278886.012927000000000000 ; 000000594991496.060338000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000372623138BE28E >									
	//     < RUSS_PFVI_I_metadata_line_40_____UPRECHISTENKA3_3319C1_MOS_RUS_X_20211101 >									
	//        < qs8jeWntq3spt0rkB25T7k0voDTL84zDO0BMUxr30x3x1r15F4c690Uog0Yr99yp >									
	//        <  u =="0.000000000000000001" : ] 000000594991496.060338000000000000 ; 000000608977150.836653000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038BE28E3A139B3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}