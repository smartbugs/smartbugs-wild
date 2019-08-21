pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXVIII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXVIII_III_883		"	;
		string	public		symbol =	"	RUSS_PFXXVIII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1096063256603100000000000000					;	
										
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
	//     < RUSS_PFXXVIII_III_metadata_line_1_____SIBUR_GBP_20251101 >									
	//        < ls3FG6tXXpn0CYZ947Xz6734SzITZ1euf9wlr7v6Htq37Ue71L73roAYj2uZ0dD6 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000034614903.152719100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000034D172 >									
	//     < RUSS_PFXXVIII_III_metadata_line_2_____SIBUR_USD_20251101 >									
	//        < U9576TCrS7t3sjW8kNvR2R7EWQ1AwJHDdjyuR8aS893sG3V4pbUzy3k1YVGhO9hp >									
	//        <  u =="0.000000000000000001" : ] 000000034614903.152719100000000000 ; 000000062635282.059273500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000034D1725F92E8 >									
	//     < RUSS_PFXXVIII_III_metadata_line_3_____SIBUR_FINANCE_CHF_20251101 >									
	//        < T2DGj4NBHu5avxyQ7LU2yfzsW404sc90P2a755UvhY9gQINv66c2x42q4rgvbFem >									
	//        <  u =="0.000000000000000001" : ] 000000062635282.059273500000000000 ; 000000081380776.892829800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005F92E87C2D5E >									
	//     < RUSS_PFXXVIII_III_metadata_line_4_____SIBUR_FINANS_20251101 >									
	//        < k21FF0PnA4A41e3EdpddaK6YE69cYnEs42Mq6C9KeXZ827jxn368ZrGNyeykGc10 >									
	//        <  u =="0.000000000000000001" : ] 000000081380776.892829800000000000 ; 000000114678631.728210000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007C2D5EAEFC57 >									
	//     < RUSS_PFXXVIII_III_metadata_line_5_____SIBUR_SA_20251101 >									
	//        < uFQJdVVaGi17CsFJ2ycRFP6kHNAGCFBt70Z35DN26215VMOX8N1SVA1186216gyH >									
	//        <  u =="0.000000000000000001" : ] 000000114678631.728210000000000000 ; 000000143214419.334007000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AEFC57DA8722 >									
	//     < RUSS_PFXXVIII_III_metadata_line_6_____VOSTOK_LLC_20251101 >									
	//        < g4zytZArTP1vAVw9vB9hdZP7u01510ER9G6buvd674KE95y8IsQ7DDdXivR3p7p1 >									
	//        <  u =="0.000000000000000001" : ] 000000143214419.334007000000000000 ; 000000162937888.599849000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DA8722F89F9D >									
	//     < RUSS_PFXXVIII_III_metadata_line_7_____BELOZERNYI_GPP_20251101 >									
	//        < o91hIcf28Op79gmTx3fT3ak7N21mBEVtwJy8OU0LE4Xx9hqi2d7c0HJbgeQ1AJNm >									
	//        <  u =="0.000000000000000001" : ] 000000162937888.599849000000000000 ; 000000195459573.104516000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F89F9D12A3F65 >									
	//     < RUSS_PFXXVIII_III_metadata_line_8_____KRASNOYARSK_SYNTHETIC_RUBBERS_PLANT_20251101 >									
	//        < r0wtjSe6W68Dk0733k3uhCIlBcIm2CZGFSa0eTHdKBqaWFaf46nBQVdnhM2R947A >									
	//        <  u =="0.000000000000000001" : ] 000000195459573.104516000000000000 ; 000000227239506.732921000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012A3F6515ABD6F >									
	//     < RUSS_PFXXVIII_III_metadata_line_9_____ORTON_20251101 >									
	//        < 4EY43fNF666j58i2AK7rqgl9QL63254W96v2d7nxsnVdG7XUq46S7h9h7zxpngYe >									
	//        <  u =="0.000000000000000001" : ] 000000227239506.732921000000000000 ; 000000253091731.252027000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015ABD6F1822FF5 >									
	//     < RUSS_PFXXVIII_III_metadata_line_10_____PLASTIC_GEOSYNTHETIC_20251101 >									
	//        < JCbC91WdGUPvrT6eGUF86P11Vns8Uaf21cbAK4BuH9aB5v5Tk3l0ROI6tKV5Rk3f >									
	//        <  u =="0.000000000000000001" : ] 000000253091731.252027000000000000 ; 000000283059563.389634000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001822FF51AFEA24 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVIII_III_metadata_line_11_____TOBOLSK_COMBINED_HEAT_POWER_PLANT_20251101 >									
	//        < JhWb0C2uo0jfO07SSgQ7K145Zp6pF1O272Fb999q2AB01Hcz9kblrp5x1Fb63ahI >									
	//        <  u =="0.000000000000000001" : ] 000000283059563.389634000000000000 ; 000000302244705.432703000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AFEA241CD3057 >									
	//     < RUSS_PFXXVIII_III_metadata_line_12_____UGRAGAZPERERABOTKA_20251101 >									
	//        < Efy2z96pN0fmrg90jqf19ZB1zXhu4gu64MMRG14GfM0ex535Racw9Z79R6762dkG >									
	//        <  u =="0.000000000000000001" : ] 000000302244705.432703000000000000 ; 000000333277947.776662000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CD30571FC8AB3 >									
	//     < RUSS_PFXXVIII_III_metadata_line_13_____UGRAGAZPERERABOTKA_GBP_20251101 >									
	//        < z9cy8AbcvpXB1z90tUR6k421CkhsHJU9oXo4MAwL5vcRJjNR70d1J571wEtuh3GY >									
	//        <  u =="0.000000000000000001" : ] 000000333277947.776662000000000000 ; 000000360932974.942781000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FC8AB3226BD71 >									
	//     < RUSS_PFXXVIII_III_metadata_line_14_____UGRAGAZPERERABOTKA_BYR_20251101 >									
	//        < b62vFH4wC850z61bT0G7832r343zQi4spT48x9898RFJ39t3hk0N7Ysk5Znh1nY6 >									
	//        <  u =="0.000000000000000001" : ] 000000360932974.942781000000000000 ; 000000395683869.738726000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000226BD7125BC403 >									
	//     < RUSS_PFXXVIII_III_metadata_line_15_____RUSTEP_20251101 >									
	//        < bYvYfx4Dintg74H3bv18T2nQDcJS45h0fAKslMXtdpa229C5k4TtT7V41iwX4w7s >									
	//        <  u =="0.000000000000000001" : ] 000000395683869.738726000000000000 ; 000000420400822.418885000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025BC4032817B12 >									
	//     < RUSS_PFXXVIII_III_metadata_line_16_____RUSTEP_RYB_20251101 >									
	//        < e33Yce54NVEI9T1A62hh5p0rwjJJ592i47gDS861Xi33sXVyPSWsX2z13974zngW >									
	//        <  u =="0.000000000000000001" : ] 000000420400822.418885000000000000 ; 000000450734437.868044000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002817B122AFC424 >									
	//     < RUSS_PFXXVIII_III_metadata_line_17_____BALTIC_BYR_20251101 >									
	//        < m7uj64152Ef1Hn3KScwDfJvP0s25KDiY5rqpsk54rGH1v2wi3D1vbBJp310kCRcc >									
	//        <  u =="0.000000000000000001" : ] 000000450734437.868044000000000000 ; 000000471145308.008337000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AFC4242CEE923 >									
	//     < RUSS_PFXXVIII_III_metadata_line_18_____ARKTIK_BYR_20251101 >									
	//        < 42Lic22k26Tj590GyQ934RclAU3Qz1GyKekeCLGFj3fE6e8n3iI8SM381YHHqa2w >									
	//        <  u =="0.000000000000000001" : ] 000000471145308.008337000000000000 ; 000000495942626.988662000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CEE9232F4BF97 >									
	//     < RUSS_PFXXVIII_III_metadata_line_19_____VOSTOK_BYR_20251101 >									
	//        < 4018g986gA2tTa8VE2OZfF67U6l42jsr13CFye0f5NNdPZa8MvT6ZRFMK4Xj2L60 >									
	//        <  u =="0.000000000000000001" : ] 000000495942626.988662000000000000 ; 000000522477214.739798000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F4BF9731D3CA9 >									
	//     < RUSS_PFXXVIII_III_metadata_line_20_____VINYL_BYR_20251101 >									
	//        < 9U4q99HZ0X0ypjv0HQ4Ds45NKbQkw2pr7VYAN9m8I3BJz8TkX2O5cXcK0kc85n4n >									
	//        <  u =="0.000000000000000001" : ] 000000522477214.739798000000000000 ; 000000547321539.048822000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031D3CA9343257A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVIII_III_metadata_line_21_____TOBOLSK_BYR_20251101 >									
	//        < pR33KFyQBdq5P8B0VwGl73HyNumbV33QpK3RB6Ji7vj514b3fkiTUpmPfdd1dKuD >									
	//        <  u =="0.000000000000000001" : ] 000000547321539.048822000000000000 ; 000000569964265.553246000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000343257A365B24B >									
	//     < RUSS_PFXXVIII_III_metadata_line_22_____ACRYLATE_BYR_20251101 >									
	//        < UE21hOhyaJv8Wgh0wXVO437KSBu1c7A1T5pux0Clo4KXQxXHT0Zjy1tGU6BfW1T0 >									
	//        <  u =="0.000000000000000001" : ] 000000569964265.553246000000000000 ; 000000589157740.639807000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000365B24B382FBBE >									
	//     < RUSS_PFXXVIII_III_metadata_line_23_____POLIEF_BYR_20251101 >									
	//        < mlGOMO6Mh1urmRFjocFATZ9jGXKd9Kj3l87yHY3K261504Zc49D16aGB0h1ploW2 >									
	//        <  u =="0.000000000000000001" : ] 000000589157740.639807000000000000 ; 000000615334735.959140000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000382FBBE3AAED22 >									
	//     < RUSS_PFXXVIII_III_metadata_line_24_____NOVAENG_BYR_20251101 >									
	//        < G56dhTvO0a69WnSZCAJq9NQOz4l8SLNaSCnaEH2IgIx5He3AWJ0C2kfC4zf0DfTH >									
	//        <  u =="0.000000000000000001" : ] 000000615334735.959140000000000000 ; 000000649412448.225848000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003AAED223DEECBD >									
	//     < RUSS_PFXXVIII_III_metadata_line_25_____BIAXP_BYR_20251101 >									
	//        < TBsm3Ea1ODmX2ia3WJE28F4v88sjaI3gE8uVWhNF1BLy6IV46t7586vo08H8on60 >									
	//        <  u =="0.000000000000000001" : ] 000000649412448.225848000000000000 ; 000000681610934.114153000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DEECBD4100E45 >									
	//     < RUSS_PFXXVIII_III_metadata_line_26_____YUGRAGAZPERERABOTKA_AB_20251101 >									
	//        < 99H4kH6AyGL0GLPT2784R8DCR79w79iAaiER7p1Ym7aD0U7Q4s7NO1zX23J7RIl5 >									
	//        <  u =="0.000000000000000001" : ] 000000681610934.114153000000000000 ; 000000705913332.908093000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004100E454352365 >									
	//     < RUSS_PFXXVIII_III_metadata_line_27_____TOMSKNEFTEKHIM_AB_20251101 >									
	//        < 6Xp3ggqhpS34XY3U6EC504P2ZGmMyNlTSu60TvG82vhJhfAW2FTjzEqYeMnt2moC >									
	//        <  u =="0.000000000000000001" : ] 000000705913332.908093000000000000 ; 000000737668539.536531000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000435236546597C6 >									
	//     < RUSS_PFXXVIII_III_metadata_line_28_____BALTIC_LNG_AB_20251101 >									
	//        < o67l5X7FoX2I5mmVkTg0V869MV180h289OK18245TaJc1FPnxlJ8JRoi9760geCc >									
	//        <  u =="0.000000000000000001" : ] 000000737668539.536531000000000000 ; 000000767523542.209878000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046597C649325E2 >									
	//     < RUSS_PFXXVIII_III_metadata_line_29_____SIBUR_INT_AB_20251101 >									
	//        < I48hjPD0b4w8vW9uN0kd8AEbef25Sga35796S76Spog1F6gwfyI1GDummt34u0CY >									
	//        <  u =="0.000000000000000001" : ] 000000767523542.209878000000000000 ; 000000802118042.914061000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049325E24C7EF5C >									
	//     < RUSS_PFXXVIII_III_metadata_line_30_____TOBOL_SK_POLIMER_AB_20251101 >									
	//        < Q2a6A4OKFp0WaY28VJc1blQ95IS68VRxEm0x40IDbYXDis9iIot038997f1ft452 >									
	//        <  u =="0.000000000000000001" : ] 000000802118042.914061000000000000 ; 000000834554868.877842000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004C7EF5C4F96DFF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVIII_III_metadata_line_31_____SIBUR_SCIENT_RD_INSTITUTE_GAS_PROCESS_AB_20251101 >									
	//        < eGuiWPv45ejTq5g3W0TOu1ls8Vy6nPS2PKe64p4xSztp13iq3e9yO723cNrg202Y >									
	//        <  u =="0.000000000000000001" : ] 000000834554868.877842000000000000 ; 000000855976035.555451000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004F96DFF51A1DA4 >									
	//     < RUSS_PFXXVIII_III_metadata_line_32_____ZAPSIBNEFTEKHIM_AB_20251101 >									
	//        < 44GOof3U4ObNlw0482rl28bsE2728KojjtR2Z8nmh7AkJ6tGjKbm1BVG7WDm4Cc2 >									
	//        <  u =="0.000000000000000001" : ] 000000855976035.555451000000000000 ; 000000876900854.478369000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000051A1DA453A0B65 >									
	//     < RUSS_PFXXVIII_III_metadata_line_33_____NEFTEKHIMIA_AB_20251101 >									
	//        < 51b2911O2v1K8FWHB1YxSLuyt4wp8UpLK7L41wxaK4g9hN8C82PFw73yrNMRacv7 >									
	//        <  u =="0.000000000000000001" : ] 000000876900854.478369000000000000 ; 000000908972570.815035000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000053A0B6556AFB69 >									
	//     < RUSS_PFXXVIII_III_metadata_line_34_____OTECHESTVENNYE_POLIMERY_AB_20251101 >									
	//        < 3j9H2g80TO0oF7qP4nLIV58SNp5cM10Q9UE4cURQKY0J7sPRrhxzc7C1rF0hE81e >									
	//        <  u =="0.000000000000000001" : ] 000000908972570.815035000000000000 ; 000000936846606.897790000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000056AFB6959583B5 >									
	//     < RUSS_PFXXVIII_III_metadata_line_35_____SIBUR_TRANS_AB_20251101 >									
	//        < d6g0i0seLpx89Sme9a6109ocUMzL4WD7eYdJ89Mg74t42umjs3W8Pnxl4rnfO896 >									
	//        <  u =="0.000000000000000001" : ] 000000936846606.897790000000000000 ; 000000958875872.428238000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000059583B55B720E3 >									
	//     < RUSS_PFXXVIII_III_metadata_line_36_____TOGLIATTIKAUCHUK_AB_20251101 >									
	//        < DF20s8TgCnFf9qGJ99Ck2FK8133iD7PZ20W2GpqFCMl1RPS6l1L7Qr6uPuSKa7Yp >									
	//        <  u =="0.000000000000000001" : ] 000000958875872.428238000000000000 ; 000000992944221.641723000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005B720E35EB1CD6 >									
	//     < RUSS_PFXXVIII_III_metadata_line_37_____NPP_NEFTEKHIMIYA_AB_20251101 >									
	//        < 0JP7e22pyWu27GiLlEebe390Lz3c286iw896seIX7b4oGi15IVA6Aq6a9xoL7z19 >									
	//        <  u =="0.000000000000000001" : ] 000000992944221.641723000000000000 ; 000001020710231.109300000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005EB1CD66157AEF >									
	//     < RUSS_PFXXVIII_III_metadata_line_38_____SIBUR_KHIMPROM_AB_20251101 >									
	//        < M75kc5LH6R9q5o9RTDEL2rHZci558BGfjGQ8571RCJ2rwjwNOhoj8ugJ03b3SUaK >									
	//        <  u =="0.000000000000000001" : ] 000001020710231.109300000000000000 ; 000001039186731.631560000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006157AEF631AC51 >									
	//     < RUSS_PFXXVIII_III_metadata_line_39_____SIBUR_VOLZHSKY_AB_20251101 >									
	//        < md19b0Dc8MkAi0Dd31P9w38QwtP75vUmX0S57d8Zc2bnKCud2qI8GKm40Il9Z4N6 >									
	//        <  u =="0.000000000000000001" : ] 000001039186731.631560000000000000 ; 000001071425882.854170000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000631AC51662DDBC >									
	//     < RUSS_PFXXVIII_III_metadata_line_40_____VORONEZHSINTEZKAUCHUK_AB_20251101 >									
	//        < O48k56sk717VlHP4mqjLWJS870N5EdiTw193tES1C6S2fNw4q0DYQ9hqGo70p5l4 >									
	//        <  u =="0.000000000000000001" : ] 000001071425882.854170000000000000 ; 000001096063256.603100000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000662DDBC68875B6 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}