pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFIX_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFIX_I_883		"	;
		string	public		symbol =	"	RUSS_PFIX_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		615632658459955000000000000					;	
										
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
	//     < RUSS_PFIX_I_metadata_line_1_____POLYUS_GOLD_20211101 >									
	//        < J7z1CC0c4ern255f73Bg02Pw41j041lJXNSJW2BoV20RErL4a37vLb7Gnm6h2v90 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000015844402.796562900000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000182D38 >									
	//     < RUSS_PFIX_I_metadata_line_2_____POLYUS_GOLD_GBP_20211101 >									
	//        < KL5jv233yIs4A13sa271ZV4rK1ZVpwy1NUS8aobeHVZTrnFRcGkc0T1EqLzRCtKH >									
	//        <  u =="0.000000000000000001" : ] 000000015844402.796562900000000000 ; 000000030006234.895564300000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000182D382DC92F >									
	//     < RUSS_PFIX_I_metadata_line_3_____POLYUS_GOLD_USD_20211101 >									
	//        < VXjxVvIWyI9r0ptxjt1VM9FB2Q43077zeWz1UoH76C1t2G48GYP8DqL48l1k0hH8 >									
	//        <  u =="0.000000000000000001" : ] 000000030006234.895564300000000000 ; 000000046920139.993992300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002DC92F47982E >									
	//     < RUSS_PFIX_I_metadata_line_4_____POLYUS_KRASNOYARSK_20211101 >									
	//        < muBDi6XLz7mBF444i6WinkVNMt0623gqC28hsc54ETeawsfAt29XGIQI7Rl47JCj >									
	//        <  u =="0.000000000000000001" : ] 000000046920139.993992300000000000 ; 000000063436234.322709300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000047982E60CBC7 >									
	//     < RUSS_PFIX_I_metadata_line_5_____POLYUS_FINANCE_PLC_20211101 >									
	//        < wCN0OIfWFcy6jaCpgQ623Fv85yZ2uHJS5OlN2M79MNz933znFq8i8u5Wu5B8Ss0Z >									
	//        <  u =="0.000000000000000001" : ] 000000063436234.322709300000000000 ; 000000078618216.243421500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000060CBC777F63E >									
	//     < RUSS_PFIX_I_metadata_line_6_____POLYUS_FINANS_FI_20211101 >									
	//        < sbKXk6M6n1Y3kTFc6oJ48R47veAdBOA0q9bawbZ1FiEO7EWYMhiNn6KP07FxpdhO >									
	//        <  u =="0.000000000000000001" : ] 000000078618216.243421500000000000 ; 000000093115809.497139200000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000077F63E8E155D >									
	//     < RUSS_PFIX_I_metadata_line_7_____POLYUS_FINANS_FII_20211101 >									
	//        < gFfL1T2mlnHe4opP44L8Nsr19p8M7z2FX03PwbU8218Hiba4F7jsa025qh045oSh >									
	//        <  u =="0.000000000000000001" : ] 000000093115809.497139200000000000 ; 000000106921585.530960000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008E155DA3263F >									
	//     < RUSS_PFIX_I_metadata_line_8_____POLYUS_FINANS_FIII_20211101 >									
	//        < SIsXH0690bR4VkgE00XKZgf0v9dKxKcE87PImN355eC42Hl8i1BYITDstjkKw86x >									
	//        <  u =="0.000000000000000001" : ] 000000106921585.530960000000000000 ; 000000121082446.486278000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A3263FB8C1D5 >									
	//     < RUSS_PFIX_I_metadata_line_9_____POLYUS_FINANS_FIV_20211101 >									
	//        < YX7k14673m4E27rnJmZ5Cpo1cY0pct3jWd8V6aT2k2r1uGgupmL6mty9KHMb30IC >									
	//        <  u =="0.000000000000000001" : ] 000000121082446.486278000000000000 ; 000000137547659.917771000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B8C1D5D1E18E >									
	//     < RUSS_PFIX_I_metadata_line_10_____POLYUS_FINANS_FV_20211101 >									
	//        < zmL0EBmVcY5KJk7pk1HZS8ssWx5idGWqch7m7Eq8dXoF7V0SO735JGG3721omIfc >									
	//        <  u =="0.000000000000000001" : ] 000000137547659.917771000000000000 ; 000000154300152.264400000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D1E18EEB717F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIX_I_metadata_line_11_____POLYUS_FINANS_FVI_20211101 >									
	//        < C0RYqDwldJ902iveOj0NK6kNj31yIeR75xFQbe7Sp8R8I4TSz76kctku3l013s7i >									
	//        <  u =="0.000000000000000001" : ] 000000154300152.264400000000000000 ; 000000169065961.480563000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EB717F101F964 >									
	//     < RUSS_PFIX_I_metadata_line_12_____POLYUS_FINANS_FVII_20211101 >									
	//        < NcIL8yB27P3d3c98TcE50JgS0w36z74k6M8pQpx8HM796Q92171CWmB4yyROyrrb >									
	//        <  u =="0.000000000000000001" : ] 000000169065961.480563000000000000 ; 000000185747046.082186000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000101F96411B6D71 >									
	//     < RUSS_PFIX_I_metadata_line_13_____POLYUS_FINANS_FVIII_20211101 >									
	//        < dB0Df72VTBpm8984awniQ7BWw7h1BPgT504gKz6db4xD766x80hbUNUdwk07JJtY >									
	//        <  u =="0.000000000000000001" : ] 000000185747046.082186000000000000 ; 000000199727498.841276000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011B6D71130C28E >									
	//     < RUSS_PFIX_I_metadata_line_14_____POLYUS_FINANS_FIX_20211101 >									
	//        < 4EdEUIW6V67es25QRFkeInzwlsPNe1J7g20429M4Fk1124Z9AuxlYI4wf60x256U >									
	//        <  u =="0.000000000000000001" : ] 000000199727498.841276000000000000 ; 000000215505687.125840000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000130C28E148D5E9 >									
	//     < RUSS_PFIX_I_metadata_line_15_____POLYUS_FINANS_FX_20211101 >									
	//        < 9p1wdLv8T744Mh4z98knL8RA284h97FDwwMb8VguxEbQbqG5z98N9O9SGMYEoPiA >									
	//        <  u =="0.000000000000000001" : ] 000000215505687.125840000000000000 ; 000000231461718.211558000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000148D5E91612EBC >									
	//     < RUSS_PFIX_I_metadata_line_16_____SVETLIY_20211101 >									
	//        < 2429Z38892MaUHNqv75D2fFi9UGqk1jsOI80ScI1p9wyr2Jv8LJbxCgh4WVn9TNE >									
	//        <  u =="0.000000000000000001" : ] 000000231461718.211558000000000000 ; 000000247603837.226593000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001612EBC179D040 >									
	//     < RUSS_PFIX_I_metadata_line_17_____POLYUS_EXPLORATION_20211101 >									
	//        < 6PvLoxBV921D1mMecVy6R4P79TXGwDtdxE4R9p2y1JmmswR33AtiwxpS618Fe1RL >									
	//        <  u =="0.000000000000000001" : ] 000000247603837.226593000000000000 ; 000000263154621.856222000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000179D0401918AC6 >									
	//     < RUSS_PFIX_I_metadata_line_18_____ZL_ZOLOTO_20211101 >									
	//        < s1O6KLj2u3x60aT5a3ec622Xnsn4R7H6J7PP4L251l8WlH2BN1c6PIVPyLeGEx8E >									
	//        <  u =="0.000000000000000001" : ] 000000263154621.856222000000000000 ; 000000276243580.380859000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001918AC61A583A6 >									
	//     < RUSS_PFIX_I_metadata_line_19_____SK_FOUNDATION_LUZERN_20211101 >									
	//        < 9a02frf5xa68e3WN7UpdUVpMd580PaAx0EF9mHX9sr8Yk2mXL7O3c9AN3sD2MAGF >									
	//        <  u =="0.000000000000000001" : ] 000000276243580.380859000000000000 ; 000000292553119.738765000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A583A61BE6690 >									
	//     < RUSS_PFIX_I_metadata_line_20_____SKFL_AB_20211101 >									
	//        < k44iqybU4sXR0GlWx3621cTL93V7vLgoe2gYd39vbV2sXUk7r2pGb9P0xl9q6SiQ >									
	//        <  u =="0.000000000000000001" : ] 000000292553119.738765000000000000 ; 000000309617698.470363000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BE66901D8706A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIX_I_metadata_line_21_____AB_URALKALI_20211101 >									
	//        < IdMj2g2mfBvsCH561o8D6BnX4DtutyT8w1Rp2is5kT6NudffVwY9xP1e2178aDha >									
	//        <  u =="0.000000000000000001" : ] 000000309617698.470363000000000000 ; 000000325017669.653738000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D8706A1EFF007 >									
	//     < RUSS_PFIX_I_metadata_line_22_____AB_FK_ANZHI_MAKHA_20211101 >									
	//        < YBg38IciEW8YguU3LgJrRXn0O43oEo06dBBjy9N0LQ595880yz5RJf7B3W5a47U9 >									
	//        <  u =="0.000000000000000001" : ] 000000325017669.653738000000000000 ; 000000341168539.987585000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EFF00720894F6 >									
	//     < RUSS_PFIX_I_metadata_line_23_____AB_NAFTA_MOSKVA_20211101 >									
	//        < d8Fi55kMo4jM3m3lD9SSuSBvUL24xcBfXi7S83k57F00zxp7y63nagp0n67xV5I5 >									
	//        <  u =="0.000000000000000001" : ] 000000341168539.987585000000000000 ; 000000356951050.338223000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020894F6220AA01 >									
	//     < RUSS_PFIX_I_metadata_line_24_____AB_SOYUZNEFTEEXPOR_20211101 >									
	//        < EA52wWUpl9xU8VZz5pNCnHwY5f7adUv2Mhx14f9MYeb8iXv14x6v35C3fB8sLplN >									
	//        <  u =="0.000000000000000001" : ] 000000356951050.338223000000000000 ; 000000370826176.397159000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000220AA01235D5FA >									
	//     < RUSS_PFIX_I_metadata_line_25_____AB_FEDPROMBANK_20211101 >									
	//        < 6v7wWzP79Vab0l1Y345RPq1sSxd4hauL3v8XK32c02T4yJ29g9hRfFx641537x5A >									
	//        <  u =="0.000000000000000001" : ] 000000370826176.397159000000000000 ; 000000385197134.051317000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000235D5FA24BC3A1 >									
	//     < RUSS_PFIX_I_metadata_line_26_____AB_ELTAV_ELEC_20211101 >									
	//        < Zp76YEIdE0RZ5BUyzsbHtigR0Tl682OaYixW8y2C4v28mnp16ry356gUFGscO6mE >									
	//        <  u =="0.000000000000000001" : ] 000000385197134.051317000000000000 ; 000000402041494.054118000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024BC3A12657775 >									
	//     < RUSS_PFIX_I_metadata_line_27_____AB_SOYUZ_FINANS_20211101 >									
	//        < kIm677ffVw5WD1vfzwMTT0IRwMAWK3S0iy54m1TM38I3fY2Ul29LHishiKQY6YR4 >									
	//        <  u =="0.000000000000000001" : ] 000000402041494.054118000000000000 ; 000000415512210.917087000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000265777527A0575 >									
	//     < RUSS_PFIX_I_metadata_line_28_____AB_VNUKOVO_20211101 >									
	//        < k8Q7cs16zGFBVO678aIl78AAgJjH21sTsvH47R2QV9OPw8vMmmCl3G6z7JwdL1V5 >									
	//        <  u =="0.000000000000000001" : ] 000000415512210.917087000000000000 ; 000000430025350.922537000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027A05752902AA7 >									
	//     < RUSS_PFIX_I_metadata_line_29_____AB_AVTOBANK_20211101 >									
	//        < RkUkC9mTdYs5268oCxq4mSBI9TG004K3qLkeqGn68O49wDZ78n6K6M457hM3ggTM >									
	//        <  u =="0.000000000000000001" : ] 000000430025350.922537000000000000 ; 000000444152426.579161000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002902AA72A5B90B >									
	//     < RUSS_PFIX_I_metadata_line_30_____AB_SMOLENSKY_PASSAZH_20211101 >									
	//        < mD29y6zvjB13qwA6xYEV83HKTv1m6VjOD1r75PdW9f1T38CkYP0Y3o1wXkTF520b >									
	//        <  u =="0.000000000000000001" : ] 000000444152426.579161000000000000 ; 000000459465040.445254000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A5B90B2BD1688 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIX_I_metadata_line_31_____MAKHA_PORT_20211101 >									
	//        < ntAM1ldyFVscuG6z3D4P6YrDIlnOSxZu2Lk2x421YlQyibjMe4Je9FQYz62IouDY >									
	//        <  u =="0.000000000000000001" : ] 000000459465040.445254000000000000 ; 000000474948509.184825000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BD16882D4B6C3 >									
	//     < RUSS_PFIX_I_metadata_line_32_____MAKHA_AIRPORT_AB_20211101 >									
	//        < 8H79d2ed41uQlPqaGnqYA3832j1Cw574FkdUO66e844dH72UG171tud9H0V85SOI >									
	//        <  u =="0.000000000000000001" : ] 000000474948509.184825000000000000 ; 000000491694980.222395000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D4B6C32EE445A >									
	//     < RUSS_PFIX_I_metadata_line_33_____DAG_ORG_20211101 >									
	//        < B05987FarBBy4h4tJ6HSM3y71z28QU2iR7iqfikhhek577m650mEzTVL6MkkN224 >									
	//        <  u =="0.000000000000000001" : ] 000000491694980.222395000000000000 ; 000000506316851.458482000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EE445A3049405 >									
	//     < RUSS_PFIX_I_metadata_line_34_____DAG_DAO_20211101 >									
	//        < NW6l2j3Uc45Qap98XW39ZIg5XBiPC5VrJX9E0gS77wmts7St89ylB1EnSw500V10 >									
	//        <  u =="0.000000000000000001" : ] 000000506316851.458482000000000000 ; 000000523077359.787811000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000304940531E2718 >									
	//     < RUSS_PFIX_I_metadata_line_35_____DAG_DAOPI_20211101 >									
	//        < KRw1RJp3Ww4u592MucLCQBa17Mgov4qAC48LU7S7P6G23y83GswCxt5fZe1Db69J >									
	//        <  u =="0.000000000000000001" : ] 000000523077359.787811000000000000 ; 000000540120230.740823000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031E27183382877 >									
	//     < RUSS_PFIX_I_metadata_line_36_____DAG_DAC_20211101 >									
	//        < 59W4nD0O7IIhjo1wv55QANry1MHljC9877MU1IIWJ068S9CQu231wVS8D80gD1De >									
	//        <  u =="0.000000000000000001" : ] 000000540120230.740823000000000000 ; 000000554475237.147435000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000338287734E0FE4 >									
	//     < RUSS_PFIX_I_metadata_line_37_____MAKHA_ORG_20211101 >									
	//        < 2Bo3S2e8mrwcRSz91r4xfAmQF7nc618hkk61jhy4SEW36fR5igfJfl56vSAcKmIT >									
	//        <  u =="0.000000000000000001" : ] 000000554475237.147435000000000000 ; 000000568422601.604920000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034E0FE43635814 >									
	//     < RUSS_PFIX_I_metadata_line_38_____MAKHA_DAO_20211101 >									
	//        < P880Ao3li34JCnxzdntfoANd8USb0RV58VYPUvW35hrjY5C90vWeRMpJohWy9L3E >									
	//        <  u =="0.000000000000000001" : ] 000000568422601.604920000000000000 ; 000000583883313.682322000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000363581437AEF6B >									
	//     < RUSS_PFIX_I_metadata_line_39_____MAKHA_DAOPI_20211101 >									
	//        < zSdsC6Yz2aX8C1f4aWgHkPNKYOnx1d3AqZ5CTO0e32tXJQ1UvZ25dziQ44kfyyvm >									
	//        <  u =="0.000000000000000001" : ] 000000583883313.682322000000000000 ; 000000598444229.700738000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037AEF6B3912747 >									
	//     < RUSS_PFIX_I_metadata_line_40_____MAKHA_DAC_20211101 >									
	//        < XFDj7Dj3hfU6swNZZa5QgY2409SFlW08p6QXIhs1sDfb1fd908Gusa2C4DOPRp54 >									
	//        <  u =="0.000000000000000001" : ] 000000598444229.700738000000000000 ; 000000615632658.459955000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039127473AB6182 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}