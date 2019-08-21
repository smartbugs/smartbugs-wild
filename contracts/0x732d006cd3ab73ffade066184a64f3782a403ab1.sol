pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXVI_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXVI_III_883		"	;
		string	public		symbol =	"	RUSS_PFXVI_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1018840408998560000000000000					;	
										
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
	//     < RUSS_PFXVI_III_metadata_line_1_____KYZYL_GOLD_20251101 >									
	//        < jc2Ky9wQ424FyzH6QX8sDbZy223w3vze9CPE7e9jJqiWH27Pnz3VI5Fg0Y6J94bj >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000035540679.086492500000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000363B14 >									
	//     < RUSS_PFXVI_III_metadata_line_2_____SEREBRO_MAGADANA_20251101 >									
	//        < mr69dRMlM5PU533AdX0X1nInrC70DwJvXcCq8A8Oh62FXgS621kGZn9gc5VA76NV >									
	//        <  u =="0.000000000000000001" : ] 000000035540679.086492500000000000 ; 000000056374199.103820300000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000363B1456052C >									
	//     < RUSS_PFXVI_III_metadata_line_3_____OMOLON_GOLD_MINING_CO_20251101 >									
	//        < 7E2oHrRa4StWc8rGu1HK7vA7cWeIoOQmCM8YNwPBSdHq119a8c89PSuSry8Bvi13 >									
	//        <  u =="0.000000000000000001" : ] 000000056374199.103820300000000000 ; 000000078362639.839283600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000056052C779268 >									
	//     < RUSS_PFXVI_III_metadata_line_4_____AMUR_CHEMICAL_METALL_PLANT_20251101 >									
	//        < Pgd1q5Km2LI9U41Yo1rxd4B0W38Q81LMC02VQe2l8ylgAK3BZs60Hd5kIp84B8x3 >									
	//        <  u =="0.000000000000000001" : ] 000000078362639.839283600000000000 ; 000000105388682.533683000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000779268A0CF74 >									
	//     < RUSS_PFXVI_III_metadata_line_5_____AMUR_CHEMICAL_METALL_PLANT_ORG_20251101 >									
	//        < 2Mv69Lg2M9oskxBbq6zJ2f52VNrsw32XNm4uvcN186K4w85fN44v1MytIM6N0wk5 >									
	//        <  u =="0.000000000000000001" : ] 000000105388682.533683000000000000 ; 000000133821404.750068000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A0CF74CC31FC >									
	//     < RUSS_PFXVI_III_metadata_line_6_____KAPAN_MINING_PROCESS_CO_20251101 >									
	//        < TrDVx2v1jZ29S62VVT7O8DJM4392KLfaD308ylA97ZShnPI5aQpbuP580jSj9Y1B >									
	//        <  u =="0.000000000000000001" : ] 000000133821404.750068000000000000 ; 000000157491687.857519000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CC31FCF05031 >									
	//     < RUSS_PFXVI_III_metadata_line_7_____VARVARINSKOYE_20251101 >									
	//        < 49PNhGNSNS2GZEv9TZNF3w2OP3UPPT95Xo1eNh691MY4aLj5gNIrS2g1GC40Fh36 >									
	//        <  u =="0.000000000000000001" : ] 000000157491687.857519000000000000 ; 000000178823925.444125000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F05031110DD19 >									
	//     < RUSS_PFXVI_III_metadata_line_8_____KAPAN_MPC_20251101 >									
	//        < OE00qFWDs2Az9X4Qui208xWAQ62fFdR196Ot4A5JntqLWsHN7E2XaOxim3VuLtH5 >									
	//        <  u =="0.000000000000000001" : ] 000000178823925.444125000000000000 ; 000000206662291.491525000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000110DD1913B5775 >									
	//     < RUSS_PFXVI_III_metadata_line_9_____ORION_MINERALS_LLP_20251101 >									
	//        < efJTl1ok333YTy427Z9eB4ZacJR6QrScsHvg28TwMPW6115bntf13uPrii2NrGTq >									
	//        <  u =="0.000000000000000001" : ] 000000206662291.491525000000000000 ; 000000237763283.487543000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013B577516ACC48 >									
	//     < RUSS_PFXVI_III_metadata_line_10_____IMITZOLOTO_LIMITED_20251101 >									
	//        < K5p73HYL3m4g9CMBpL1d4fVswLGAM6lsra6ncLivsvZUmDKY0q2dxuYD74f857cb >									
	//        <  u =="0.000000000000000001" : ] 000000237763283.487543000000000000 ; 000000262792425.333223000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016ACC48190FD4B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVI_III_metadata_line_11_____ZAO_ZOLOTO_SEVERNOGO_URALA_20251101 >									
	//        < dgt3lXM73067wz245yB46yGOf6bPxZ0zV3tf89wDzL7W9hket0bxAGua80V1xTE3 >									
	//        <  u =="0.000000000000000001" : ] 000000262792425.333223000000000000 ; 000000296344019.942736000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000190FD4B1C42F62 >									
	//     < RUSS_PFXVI_III_metadata_line_12_____OKHOTSKAYA_GGC_20251101 >									
	//        < TCLa4oXlWh27nKqf923il21NU4db2RzlMR9D7Qqw4Wjh03g5vg5od83e88Fh4MOa >									
	//        <  u =="0.000000000000000001" : ] 000000296344019.942736000000000000 ; 000000325842854.227431000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C42F621F1325D >									
	//     < RUSS_PFXVI_III_metadata_line_13_____INTER_GOLD_CAPITAL_20251101 >									
	//        < k7Hpc20M859T1EkG888400r6d38n4sDbL75I8eTaopEY8v4Dxr8T19pbb4j9j824 >									
	//        <  u =="0.000000000000000001" : ] 000000325842854.227431000000000000 ; 000000347791526.464735000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F1325D212B011 >									
	//     < RUSS_PFXVI_III_metadata_line_14_____POLYMETAL_AURUM_20251101 >									
	//        < mmE16KoQU2mYrWWNkxicI0djYu1xw97LYwxa1gmRX9Cz3i1nH0WWa280H6OVjO7Z >									
	//        <  u =="0.000000000000000001" : ] 000000347791526.464735000000000000 ; 000000374621754.785601000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000212B01123BA09F >									
	//     < RUSS_PFXVI_III_metadata_line_15_____KIRANKAN_OOO_20251101 >									
	//        < Ahgp8i7Ovz6Ek8h5Wum0S8m6O13OZFcxaDhD0wsKOG9I07T33NOwB7ouaMPnC8fv >									
	//        <  u =="0.000000000000000001" : ] 000000374621754.785601000000000000 ; 000000395266132.174766000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023BA09F25B20D5 >									
	//     < RUSS_PFXVI_III_metadata_line_16_____OKHOTSK_MINING_GEOLOGICAL_CO_20251101 >									
	//        < fIBF931Fg5uMLU1AciNwM25BZ0hcZlC4qYl5nzphWUd35EJsjuGnKYdBA5pX4607 >									
	//        <  u =="0.000000000000000001" : ] 000000395266132.174766000000000000 ; 000000429821840.496470000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025B20D528FDB28 >									
	//     < RUSS_PFXVI_III_metadata_line_17_____AYAX_PROSPECTORS_ARTEL_CO_20251101 >									
	//        < 0B8D3oOY18BYgzS65CAsh569H5WEmiVhCri57sH2ZHp19Z61o3n6FQ5um8SJ820h >									
	//        <  u =="0.000000000000000001" : ] 000000429821840.496470000000000000 ; 000000448384608.238369000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028FDB282AC2E3D >									
	//     < RUSS_PFXVI_III_metadata_line_18_____POLYMETAL_INDUSTRIA_20251101 >									
	//        < ntFKt1E2NZGLq95sFSYtQ89n936zI8Q72qVMJCTMF7O9kyhSRQu7tXw4p0dw5ENf >									
	//        <  u =="0.000000000000000001" : ] 000000448384608.238369000000000000 ; 000000467877991.711332000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AC2E3D2C9ECD7 >									
	//     < RUSS_PFXVI_III_metadata_line_19_____ASHANTI_POLYMET_STRATE_ALL_MANCO_20251101 >									
	//        < KG6551508GJPH38ATq4e9H3HbQj3z2Jt8P56755r0WpkI88D19H95n5kq3Tb87L4 >									
	//        <  u =="0.000000000000000001" : ] 000000467877991.711332000000000000 ; 000000490422606.109529000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C9ECD72EC5355 >									
	//     < RUSS_PFXVI_III_metadata_line_20_____RUDNIK_AVLAYAKAN_20251101 >									
	//        < BW8F6hP3Ak6zw9BGbTAFbC3J3JXj2zcOWrGz9ZDWm7Nh6Eu24r0Vfawqv9VWkXLX >									
	//        <  u =="0.000000000000000001" : ] 000000490422606.109529000000000000 ; 000000509744103.639282000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EC5355309CECA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVI_III_metadata_line_21_____OLYMP_OOO_20251101 >									
	//        < 5M1i4LQbQDm066b3UhT2b13iPiPq06h49w5p4sl59L8A38r5kq7CWbXvSZ01Bzed >									
	//        <  u =="0.000000000000000001" : ] 000000509744103.639282000000000000 ; 000000529892861.721213000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000309CECA3288D66 >									
	//     < RUSS_PFXVI_III_metadata_line_22_____SEMCHENSKOYE_ZOLOTO_20251101 >									
	//        < fKCqh10ouhd1JoWa8fH8SzO0N4Vr6gCLVGa3Cz647YdC63F5CfwgS8Fm63JlP9B0 >									
	//        <  u =="0.000000000000000001" : ] 000000529892861.721213000000000000 ; 000000564074767.116254000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003288D6635CB5B5 >									
	//     < RUSS_PFXVI_III_metadata_line_23_____MAYSKOYE_20251101 >									
	//        < S8VUllfvbm9YR1O1Im5Wf3449UT5Mf83L1S538K0n2El6806BI4vzTN19t7q1vX0 >									
	//        <  u =="0.000000000000000001" : ] 000000564074767.116254000000000000 ; 000000599508625.083021000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035CB5B5392C70F >									
	//     < RUSS_PFXVI_III_metadata_line_24_____FIANO_INVESTMENTS_20251101 >									
	//        < i728M8ai0AfvVAf3GCU5g86GV6QJG57Dn78xNKhSDH1y3Aeiys2tJcjf7uO064e8 >									
	//        <  u =="0.000000000000000001" : ] 000000599508625.083021000000000000 ; 000000619663108.414655000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000392C70F3B187E7 >									
	//     < RUSS_PFXVI_III_metadata_line_25_____URAL_POLYMETAL_20251101 >									
	//        < VUHHEGLpFhSKJ4zdg37f4vGPh7Y13jEsd02m5z14r66N15Z6UEKoSEH154osR9O7 >									
	//        <  u =="0.000000000000000001" : ] 000000619663108.414655000000000000 ; 000000648507917.513124000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B187E73DD8B68 >									
	//     < RUSS_PFXVI_III_metadata_line_26_____POLYMETAL_PDRUS_LLC_20251101 >									
	//        < Uaw15718949Cd64I51q5i0jsvOOp62C9h08ay6qB9BTbVAhX2eZgQrxan4WAw30H >									
	//        <  u =="0.000000000000000001" : ] 000000648507917.513124000000000000 ; 000000675474637.505246000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DD8B68406B148 >									
	//     < RUSS_PFXVI_III_metadata_line_27_____VOSTOCHNY_BASIS_20251101 >									
	//        < ri71y3abqmfDf2puHssVQA9G0Sq3slqw5iDX0EY49OpIBOTGDVDHo0S490U12Yl1 >									
	//        <  u =="0.000000000000000001" : ] 000000675474637.505246000000000000 ; 000000695030970.515408000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000406B1484248879 >									
	//     < RUSS_PFXVI_III_metadata_line_28_____SAUM_MINING_CO_20251101 >									
	//        < 99FjKwpOiZ619455L58XYq9UXYO49Cf020D5nzN0Rd59GGuanKawB877H4PNH8H5 >									
	//        <  u =="0.000000000000000001" : ] 000000695030970.515408000000000000 ; 000000718769782.817639000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004248879448C172 >									
	//     < RUSS_PFXVI_III_metadata_line_29_____ALBAZINO_RESOURCES_20251101 >									
	//        < L6xP0aAooywa8r8muEciVvWkgGEnzOvX7u09wM983745G9776mWX4Pp8ST6sv9Uo >									
	//        <  u =="0.000000000000000001" : ] 000000718769782.817639000000000000 ; 000000739804087.282481000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000448C172468D9F9 >									
	//     < RUSS_PFXVI_III_metadata_line_30_____POLYMETAL_INDUSTRIYA_20251101 >									
	//        < n9B2uT94hUpCF7yAK19W8L1ubOyXCEh4FI6xpOETam5vwpq2ejeCO9ApcrtuD5I3 >									
	//        <  u =="0.000000000000000001" : ] 000000739804087.282481000000000000 ; 000000761933558.351376000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000468D9F948A9E4C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVI_III_metadata_line_31_____AS_APK_HOLDINGS_LIMITED_20251101 >									
	//        < 883aXa5S5We182Pd57E2sYW742fVbcHY66M5RZz5fUGg69v6oygtsPTlgu63helY >									
	//        <  u =="0.000000000000000001" : ] 000000761933558.351376000000000000 ; 000000780953211.754184000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048A9E4C4A7A3D9 >									
	//     < RUSS_PFXVI_III_metadata_line_32_____POLAR_SILVER_RESOURCES_20251101 >									
	//        < t1KECiJPZ4UH2ScSlj303iAj3Iu7LQ8Oxc7K1bznedn5XJ80f6702uKA5w13qR03 >									
	//        <  u =="0.000000000000000001" : ] 000000780953211.754184000000000000 ; 000000805299197.686481000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A7A3D94CCCA00 >									
	//     < RUSS_PFXVI_III_metadata_line_33_____PMTL_HOLDING_LIMITED_20251101 >									
	//        < s8yNn7xv11G3bN15bHD4Ats4P5Q35x2TNzbFzi4Ogd0Me0LoeEOJ1uA9xw0QI230 >									
	//        <  u =="0.000000000000000001" : ] 000000805299197.686481000000000000 ; 000000829262945.395416000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004CCCA004F15AD7 >									
	//     < RUSS_PFXVI_III_metadata_line_34_____ALBAZINO_RESOURCES_LIMITED_20251101 >									
	//        < WQuOgW4GH7526sTT88o0pb7S3449MUPLVO8977E2kq365G7LCOMv887f86Bh7O0u >									
	//        <  u =="0.000000000000000001" : ] 000000829262945.395416000000000000 ; 000000858264111.146505000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004F15AD751D9B6B >									
	//     < RUSS_PFXVI_III_metadata_line_35_____RUDNIK_KVARTSEVYI_20251101 >									
	//        < bHm823p4gPv3jpi07R5fCnI5yGcCh74J51T4fN4F4wvZO0178Fmdpto0790l75Ce >									
	//        <  u =="0.000000000000000001" : ] 000000858264111.146505000000000000 ; 000000887590833.535521000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000051D9B6B54A5B2B >									
	//     < RUSS_PFXVI_III_metadata_line_36_____NEVYANSK_GROUP_20251101 >									
	//        < 6BU305Rhx9JbhsPTFYUW8U5tDmZPOn1h533seU0PxXz0NflFrpUlih1I80Nz2q3n >									
	//        <  u =="0.000000000000000001" : ] 000000887590833.535521000000000000 ; 000000913056474.236194000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000054A5B2B57136AF >									
	//     < RUSS_PFXVI_III_metadata_line_37_____AMURSK_HYDROMETALL_PLANT_20251101 >									
	//        < s98Trr18Q6Wh06YUszawUCrmyel59t0Q1O938f7DCm0DtGPZ131657LxVQ5F9c78 >									
	//        <  u =="0.000000000000000001" : ] 000000913056474.236194000000000000 ; 000000942271283.542679000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000057136AF59DCAB8 >									
	//     < RUSS_PFXVI_III_metadata_line_38_____AMURSK_HYDROMETALL_PLANT_ORG_20251101 >									
	//        < dsa9m44f490sBB881yJ3konGuUQyN4I89ijz4O12ija1zARL8HaqVtU8sm0eU98h >									
	//        <  u =="0.000000000000000001" : ] 000000942271283.542679000000000000 ; 000000960554545.300849000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000059DCAB85B9B09F >									
	//     < RUSS_PFXVI_III_metadata_line_39_____OKHOTSKAYA_MINING_GEO_COMPANY_20251101 >									
	//        < tDd7ViQF76x84aRX5aavby9FeY7FV679GFwmGF49QP3jC4ZHIVxMa59TZkL9VIZL >									
	//        <  u =="0.000000000000000001" : ] 000000960554545.300849000000000000 ; 000000991554850.120859000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005B9B09F5E8FE1D >									
	//     < RUSS_PFXVI_III_metadata_line_40_____DUNDEE_PRECIOUS_METALS_KAPAN_20251101 >									
	//        < c16FwTZX4D5KG843LT304hh13rl1a2624mxoFa3b2T2KQ4aF4pFciJSc94nz6V4t >									
	//        <  u =="0.000000000000000001" : ] 000000991554850.120859000000000000 ; 000001018840408.998560000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005E8FE1D612A089 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}