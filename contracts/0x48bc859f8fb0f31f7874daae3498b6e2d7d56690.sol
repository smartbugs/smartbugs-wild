pragma solidity 		^0.4.21	;						
										
	contract	RENAULT_19_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RENAULT_19_883		"	;
		string	public		symbol =	"	RENAULT_19_1subDT		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1608532486248800000000000000					;	
										
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
	//     < RENAULT_19_metadata_line_1_____RENAULT_19Y_abc_i >									
	//        < 3P9BtMSji0u11bU076O6967tg7ikSKz9bp2cQj449c50D6vautGH6Ql541B4OpKL >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000040217789.914816800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000003D5E13 >									
	//     < RENAULT_19_metadata_line_2_____RENAULT_19Y_abc_ii >									
	//        < i6Af8113W7OA4rubhmI0aRvJr0IWXUcEGfX0dPd7WE4Gy2oT1Ck70858S1uOCR23 >									
	//        <  u =="0.000000000000000001" : ] 000000040217789.914816800000000000 ; 000000080426604.271242500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003D5E137AB8A4 >									
	//     < RENAULT_19_metadata_line_3_____RENAULT_19Y_abc_iii >									
	//        < KBjRScQm5X6vVGLR9L892GQZ4OXK907e5117Citq4SbF6b1bHq77Q48L423E2cCb >									
	//        <  u =="0.000000000000000001" : ] 000000080426604.271242500000000000 ; 000000120660319.110139000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007AB8A4B81CF0 >									
	//     < RENAULT_19_metadata_line_4_____RENAULT_19Y_abc_iv >									
	//        < 1zfsMQ6UZ697m8sz20RNegb7Bdtzx0ctNZ6kJvhT9uTF9G2n8H618wPfRx79tNwx >									
	//        <  u =="0.000000000000000001" : ] 000000120660319.110139000000000000 ; 000000160847497.677953000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B81CF0F56F0E >									
	//     < RENAULT_19_metadata_line_5_____RENAULT_19Y_abc_v >									
	//        < RvDDWPamI3137q3u2rv16qpFH5w2vVq7k02vbI28240q63Q4pQ04e0a60aq994sb >									
	//        <  u =="0.000000000000000001" : ] 000000160847497.677953000000000000 ; 000000201115831.816620000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F56F0E132E0DF >									
	//     < RENAULT_19_metadata_line_6_____RENAULT_19Y_abc_vi >									
	//        < 4Fn7StR4ZV8Ep7hI3f6IWuJ4fxTcMtf74d1NcZcTJ1dW5v6r6nD9b9079IUKb1ZZ >									
	//        <  u =="0.000000000000000001" : ] 000000201115831.816620000000000000 ; 000000241298993.929413000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000132E0DF170316B >									
	//     < RENAULT_19_metadata_line_7_____RENAULT_19Y_abc_vii >									
	//        < yn3In9AB6t8L4bV95zPWFE9MfKChw2DNyCEqImHCPHj7wkD57046ekQ43KA0tUGW >									
	//        <  u =="0.000000000000000001" : ] 000000241298993.929413000000000000 ; 000000281534563.039237000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000170316B1AD9670 >									
	//     < RENAULT_19_metadata_line_8_____RENAULT_19Y_abc_viii >									
	//        < u40Xbhyyiq232RKRueBFyQIrdfZkh3wNSR05ucX17631ZzQ2941fPx04OMOWtdu9 >									
	//        <  u =="0.000000000000000001" : ] 000000281534563.039237000000000000 ; 000000321734929.039404000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AD96701EAEDB5 >									
	//     < RENAULT_19_metadata_line_9_____RENAULT_19Y_abc_ix >									
	//        < b390kK2h31R2QWW5M5jQ6m5Nw96s41ZL94y45GIM7z6qIv1Zl257D51nT8XrrH9Z >									
	//        <  u =="0.000000000000000001" : ] 000000321734929.039404000000000000 ; 000000361908541.180619000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EAEDB52283A86 >									
	//     < RENAULT_19_metadata_line_10_____RENAULT_19Y_abc_x >									
	//        < kKJLElp3Cq233r7TkVOXUVQhYq7LvA69uX8cHV1364St0XiepX3V21KSvc79ucpT >									
	//        <  u =="0.000000000000000001" : ] 000000361908541.180619000000000000 ; 000000402120785.055641000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002283A86265966F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RENAULT_19_metadata_line_11_____RENAULT_19Y_abc_xi >									
	//        < KCYfoN8YppuocLFw75Zw0B5Y3gU2Vim0M99szg71eeew9rgwVPl8Mf6Rs9s5jjz6 >									
	//        <  u =="0.000000000000000001" : ] 000000402120785.055641000000000000 ; 000000442317736.693274000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000265966F2A2EC5E >									
	//     < RENAULT_19_metadata_line_12_____RENAULT_19Y_abc_xii >									
	//        < dYr87cb263jmBz6vj0D3n4i46AK21rgsdePyicQjYxU7wew4ocA2CAZC9354862z >									
	//        <  u =="0.000000000000000001" : ] 000000442317736.693274000000000000 ; 000000482587158.694577000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A2EC5E2E05E9C >									
	//     < RENAULT_19_metadata_line_13_____RENAULT_19Y_abc_xiii >									
	//        < wm5581008k4E7MPup8SxTYF8Ur5j19RxFq52Uf1Vw5FCGU6monKxtY74Z993h2Wv >									
	//        <  u =="0.000000000000000001" : ] 000000482587158.694577000000000000 ; 000000522787524.694743000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E05E9C31DB5E0 >									
	//     < RENAULT_19_metadata_line_14_____RENAULT_19Y_abc_xiv >									
	//        < 5xdwtgzO97tak2271SFVXMV0K5RllI96q0DB7Gnjx8D06grNr6vJbv5nzyYp9A58 >									
	//        <  u =="0.000000000000000001" : ] 000000522787524.694743000000000000 ; 000000563039920.928003000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031DB5E035B2178 >									
	//     < RENAULT_19_metadata_line_15_____RENAULT_19Y_abc_xv >									
	//        < 0aRJ73d4yuNTy49i3ADK8Pe51Fl7fA4mQDP9Oee4HKnZtc64ma7gGtO1OwIh9UWb >									
	//        <  u =="0.000000000000000001" : ] 000000563039920.928003000000000000 ; 000000603323971.341770000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035B2178398996D >									
	//     < RENAULT_19_metadata_line_16_____RENAULT_19Y_abc_xvi >									
	//        < z1837c16O04k8S4x789n89TSXd3gz5UdEZzI7F83GJ82fi3R90uwUSLNWY487k4L >									
	//        <  u =="0.000000000000000001" : ] 000000603323971.341770000000000000 ; 000000643575514.688839000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000398996D3D604AF >									
	//     < RENAULT_19_metadata_line_17_____RENAULT_19Y_abc_xvii >									
	//        < dQ0Cf38ij5CQ0tJ92qr60oW7vtU0Ic61UJH39KDat939985c0HTACFnsbcD9C7X9 >									
	//        <  u =="0.000000000000000001" : ] 000000643575514.688839000000000000 ; 000000683808867.208388000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D604AF41368D7 >									
	//     < RENAULT_19_metadata_line_18_____RENAULT_19Y_abc_xviii >									
	//        < I3dP37996G7mCjQpElCaB3Ih2570vJtOc44x0OtyjksIb4CmV7K23Pinmcq8sOM3 >									
	//        <  u =="0.000000000000000001" : ] 000000683808867.208388000000000000 ; 000000724044429.213572000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041368D7450CDDB >									
	//     < RENAULT_19_metadata_line_19_____RENAULT_19Y_abc_xix >									
	//        < Fx7q8ZnG9A7KP3hr4mB488Iue82DnB9S6804HNU3N2lV2A2g13tPR9072y4SKeH9 >									
	//        <  u =="0.000000000000000001" : ] 000000724044429.213572000000000000 ; 000000764284261.322175000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000450CDDB48E348A >									
	//     < RENAULT_19_metadata_line_20_____RENAULT_19Y_abc_xx >									
	//        < 740I8493j2I77nTvWq1O5Bt9DW89r0AnZA5B7qkbVP81xTGM0norqd47h1XClmTD >									
	//        <  u =="0.000000000000000001" : ] 000000764284261.322175000000000000 ; 000000804556712.421027000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048E348A4CBA7F7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RENAULT_19_metadata_line_21_____RENAULT_19Y_abc_xxi >									
	//        < G67x6R99wBG5P3x5ss5b0c3tH390Zi157TlZKlT87J459y199jSCO8VS55JgoLg6 >									
	//        <  u =="0.000000000000000001" : ] 000000804556712.421027000000000000 ; 000000844705594.033725000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004CBA7F7508EB1F >									
	//     < RENAULT_19_metadata_line_22_____RENAULT_19Y_abc_xxii >									
	//        < T5VHP71a4eu5dD9mQto96ZZij31u06fO916bF5SD0F77Xcnph6HcIOqOEt1kn7Nf >									
	//        <  u =="0.000000000000000001" : ] 000000844705594.033725000000000000 ; 000000884855432.826035000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000508EB1F5462EA7 >									
	//     < RENAULT_19_metadata_line_23_____RENAULT_19Y_abc_xxiii >									
	//        < OJME84H6QIIZDXAU72sZf3293silv2u42sJn1cYP097fVb0jq44U1vqCWDMS6f0c >									
	//        <  u =="0.000000000000000001" : ] 000000884855432.826035000000000000 ; 000000925045059.772961000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005462EA758381BA >									
	//     < RENAULT_19_metadata_line_24_____RENAULT_19Y_abc_xxiv >									
	//        < V76cH8K36ncAAhaOe7v2q553uX1heQk47FxR17nbKfMp23sP71ROtdtUQuB8L2a8 >									
	//        <  u =="0.000000000000000001" : ] 000000925045059.772961000000000000 ; 000000965325369.044164000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000058381BA5C0F839 >									
	//     < RENAULT_19_metadata_line_25_____RENAULT_19Y_abc_xxv >									
	//        < 8tZa6xrL4uakUET6Fs2w13C8U4t590RmC8PcWVQ5WTiOWMiR26A7f6LnvOx45HII >									
	//        <  u =="0.000000000000000001" : ] 000000965325369.044164000000000000 ; 000001005504444.130260000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005C0F8395FE472C >									
	//     < RENAULT_19_metadata_line_26_____RENAULT_19Y_abc_xxvi >									
	//        < 9qrgTISWd42PlZ4Gm4pY0LR6OSYd2C5UkZGppfg0y0I5L35o8YhyZnUSP8K280uP >									
	//        <  u =="0.000000000000000001" : ] 000001005504444.130260000000000000 ; 000001045757977.571740000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005FE472C63BB336 >									
	//     < RENAULT_19_metadata_line_27_____RENAULT_19Y_abc_xxvii >									
	//        < tZsr5n50kB1NRAa6788CKkT2E8063sP6Kfw0rxuNHYFjezAcX6SJ2f36hq0shX08 >									
	//        <  u =="0.000000000000000001" : ] 000001045757977.571740000000000000 ; 000001085948484.550320000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000063BB33667906A0 >									
	//     < RENAULT_19_metadata_line_28_____RENAULT_19Y_abc_xxviii >									
	//        < y8zC1KR3AU76H80l0qwPpi31tVLBVpotmBZ7vqUa64DvERNmo70nGLZtJ1NC47hJ >									
	//        <  u =="0.000000000000000001" : ] 000001085948484.550320000000000000 ; 000001126161154.471850000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000067906A06B662B3 >									
	//     < RENAULT_19_metadata_line_29_____RENAULT_19Y_abc_xxix >									
	//        < MDWr3u415rU61cZZisoG6A4sAqJqeKeRNMuA7JYhY9BTTVrtHY65936SN22bDVQG >									
	//        <  u =="0.000000000000000001" : ] 000001126161154.471850000000000000 ; 000001166310766.375190000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006B662B36F3A625 >									
	//     < RENAULT_19_metadata_line_30_____RENAULT_19Y_abc_xxx >									
	//        < q4V1hV50GDtMF1jz942YoJsi1NmyI8rNi0XZ3Q9QR90D5Lc7zHT11x94lg526Idc >									
	//        <  u =="0.000000000000000001" : ] 000001166310766.375190000000000000 ; 000001206483009.343110000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006F3A625730F26D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RENAULT_19_metadata_line_31_____RENAULT_19Y_abc_xxxi >									
	//        < 2fW1zK6n1V5rjlbsjLNXm6aJ7NP69xq7pGC1d960StO8e37QkU41t6sSRI4Ik7NG >									
	//        <  u =="0.000000000000000001" : ] 000001206483009.343110000000000000 ; 000001246700231.128350000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000730F26D76E5047 >									
	//     < RENAULT_19_metadata_line_32_____RENAULT_19Y_abc_xxxii >									
	//        < iwV0Y06wXIhr2m9Tril9RHGm3KB1yvKJb8d6KA5S8mPwJG8019I2kP2y2m8le0Fc >									
	//        <  u =="0.000000000000000001" : ] 000001246700231.128350000000000000 ; 000001286896217.424320000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000076E50477ABA5D6 >									
	//     < RENAULT_19_metadata_line_33_____RENAULT_19Y_abc_xxxiii >									
	//        < 3dRE4yY0OD4WV8r10wuv565F8l6nRJJaaojQiPg8xVN3Gcp45u844038zu5HH6BH >									
	//        <  u =="0.000000000000000001" : ] 000001286896217.424320000000000000 ; 000001327118382.191550000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007ABA5D67E9059E >									
	//     < RENAULT_19_metadata_line_34_____RENAULT_19Y_abc_xxxiv >									
	//        < 9ayZwS708QF90Pp1mJViXU7y10uEXo9T17JdocRtA6SFCOk49URRSUsMq6d03vdH >									
	//        <  u =="0.000000000000000001" : ] 000001327118382.191550000000000000 ; 000001367306071.713780000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007E9059E82657EF >									
	//     < RENAULT_19_metadata_line_35_____RENAULT_19Y_abc_xxxv >									
	//        < A4152VDedKwkG45BGCqjAoVX2mD90h1R9cbUW71TrG2UKnpR2A5dm4k17v3cc53V >									
	//        <  u =="0.000000000000000001" : ] 000001367306071.713780000000000000 ; 000001407503037.547770000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000082657EF863ADE0 >									
	//     < RENAULT_19_metadata_line_36_____RENAULT_19Y_abc_xxxvi >									
	//        < 59u6jv9kA5lzviu5QxXNr53KD1HeFij1naERG5s8sm72340v72532aaqe5z14Uir >									
	//        <  u =="0.000000000000000001" : ] 000001407503037.547770000000000000 ; 000001447651359.043170000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000863ADE08A0F0D0 >									
	//     < RENAULT_19_metadata_line_37_____RENAULT_19Y_abc_xxxvii >									
	//        < OW89Cc7k22jAUZv6j8Zg6ZJn214KZd5wq3brF22ySE50KUtFoNc6k37i49578Tk2 >									
	//        <  u =="0.000000000000000001" : ] 000001447651359.043170000000000000 ; 000001487894921.626710000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008A0F0D08DE58F4 >									
	//     < RENAULT_19_metadata_line_38_____RENAULT_19Y_abc_xxxviii >									
	//        < 147KgvBjiul12oRA124v5XHAs6JhbDHLUetDyv48O5VQUj398ZrfAb0GWG0y496i >									
	//        <  u =="0.000000000000000001" : ] 000001487894921.626710000000000000 ; 000001528093555.566640000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008DE58F491BAF8C >									
	//     < RENAULT_19_metadata_line_39_____RENAULT_19Y_abc_xxxix >									
	//        < 95m3Nr3T7vo44iV6A53e48ob4XJH6HPpf588idL56wY996Fyh9hCuSO55MDoWmls >									
	//        <  u =="0.000000000000000001" : ] 000001528093555.566640000000000000 ; 000001568382108.590310000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000091BAF8C9592943 >									
	//     < RENAULT_19_metadata_line_40_____RENAULT_19Y_abc_xxxx >									
	//        < 5f1S2TZIbgvTT1UuO1Aq6T9P65LxtG7nhQYOwJcbCL0lgq4Uh5pStqjQAX3TdYQ3 >									
	//        <  u =="0.000000000000000001" : ] 000001568382108.590310000000000000 ; 000001608532486.248800000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000095929439966D01 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}