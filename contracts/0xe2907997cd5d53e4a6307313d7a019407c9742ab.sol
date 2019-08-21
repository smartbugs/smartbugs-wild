pragma solidity 		^0.4.25	;						
									
contract	NDD_RUSAL_I_883				{				
									
	mapping (address => uint256) public balanceOf;								
									
	string	public		name =	"	NDD_RUSAL_I_883		"	;
	string	public		symbol =	"	NDD_RUSAL_I_1subDT		"	;
	uint8	public		decimals =		18			;
									
	uint256 public totalSupply =		437384439013129000000000000000000					;	
									
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
// }									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
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
//     < NDD_RUSAL_I_metadata_line_1_____6938413225 Lab_x >									
//        < 3P9BtMSji0u11bU076O6967tg7ikSKz9bp2cQj449c50D6vautGH6Ql541B4OpKL >									
//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010000000.000000000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000000000003D5E13 >									
//     < NDD_RUSAL_I_metadata_line_2_____9781285179 Lab_y >									
//        < i6Af8113W7OA4rubhmI0aRvJr0IWXUcEGfX0dPd7WE4Gy2oT1Ck70858S1uOCR23 >									
//        <  u =="0.000000000000000001" : ] 000000010000000.000000000000000000 ; 000000020000000.000000000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000003D5E137AB8A4 >									
//     < NDD_RUSAL_I_metadata_line_3_____2370460781 Lab_100 >									
//        < KBjRScQm5X6vVGLR9L892GQZ4OXK907e5117Citq4SbF6b1bHq77Q48L423E2cCb >									
//        <  u =="0.000000000000000001" : ] 000000020000000.000000000000000000 ; 000000032885058.983233900000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000007AB8A4B81CF0 >									
//     < NDD_RUSAL_I_metadata_line_4_____2383457453 Lab_110 >									
//        < 1zfsMQ6UZ697m8sz20RNegb7Bdtzx0ctNZ6kJvhT9uTF9G2n8H618wPfRx79tNwx >									
//        <  u =="0.000000000000000001" : ] 000000032885058.983233900000000000 ; 000000046771304.283233900000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000000B81CF0F56F0E >									
//     < NDD_RUSAL_I_metadata_line_5_____1151598096 Lab_410/401 >									
//        < RvDDWPamI3137q3u2rv16qpFH5w2vVq7k02vbI28240q63Q4pQ04e0a60aq994sb >									
//        <  u =="0.000000000000000001" : ] 000000046771304.283233900000000000 ; 000000072316285.483233900000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000000F56F0E132E0DF >									
//     < NDD_RUSAL_I_metadata_line_6_____998812674 Lab_810/801 >									
//        < 4Fn7StR4ZV8Ep7hI3f6IWuJ4fxTcMtf74d1NcZcTJ1dW5v6r6nD9b9079IUKb1ZZ >									
//        <  u =="0.000000000000000001" : ] 000000072316285.483233900000000000 ; 000000113406247.883234000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000132E0DF170316B >									
//     < NDD_RUSAL_I_metadata_line_7_____1151598096 Lab_410_3Y1Y >									
//        < yn3In9AB6t8L4bV95zPWFE9MfKChw2DNyCEqImHCPHj7wkD57046ekQ43KA0tUGW >									
//        <  u =="0.000000000000000001" : ] 000000113406247.883234000000000000 ; 000000280099017.383233000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000170316B1AD9670 >									
//     < NDD_RUSAL_I_metadata_line_8_____998812674 Lab_410_5Y1Y >									
//        < u40Xbhyyiq232RKRueBFyQIrdfZkh3wNSR05ucX17631ZzQ2941fPx04OMOWtdu9 >									
//        <  u =="0.000000000000000001" : ] 000000280099017.383233000000000000 ; 000000290099017.383233000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000001AD96701EAEDB5 >									
//     < NDD_RUSAL_I_metadata_line_9_____2323232323 Lab_410_7Y1Y >									
//        < b390kK2h31R2QWW5M5jQ6m5Nw96s41ZL94y45GIM7z6qIv1Zl257D51nT8XrrH9Z >									
//        <  u =="0.000000000000000001" : ] 000000290099017.383233000000000000 ; 000000300099017.383233000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000001EAEDB52283A86 >									
//     < NDD_RUSAL_I_metadata_line_10_____2323232323 Lab_810_3Y1Y >									
//        < kKJLElp3Cq233r7TkVOXUVQhYq7LvA69uX8cHV1364St0XiepX3V21KSvc79ucpT >									
//        <  u =="0.000000000000000001" : ] 000000300099017.383233000000000000 ; 000000993855783.173198000000000000 ] >									
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
//     < NDD_RUSAL_I_metadata_line_11_____2331073380 Lab_810_5Y1Y >									
//        < KCYfoN8YppuocLFw75Zw0B5Y3gU2Vim0M99szg71eeew9rgwVPl8Mf6Rs9s5jjz6 >									
//        <  u =="0.000000000000000001" : ] 000000993855783.173198000000000000 ; 000001003855783.173200000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000265966F2A2EC5E >									
//     < NDD_RUSAL_I_metadata_line_12_____2389358431 Lab_810_7Y1Y >									
//        < dYr87cb263jmBz6vj0D3n4i46AK21rgsdePyicQjYxU7wew4ocA2CAZC9354862z >									
//        <  u =="0.000000000000000001" : ] 000001003855783.173200000000000000 ; 000001013855783.173200000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000002A2EC5E2E05E9C >									
//     < NDD_RUSAL_I_metadata_line_13_____2323232323 ro_Lab_110_3Y_1.00 >									
//        < wm5581008k4E7MPup8SxTYF8Ur5j19RxFq52Uf1Vw5FCGU6monKxtY74Z993h2Wv >									
//        <  u =="0.000000000000000001" : ] 000001013855783.173200000000000000 ; 000001045656291.313420000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000002E05E9C31DB5E0 >									
//     < NDD_RUSAL_I_metadata_line_14_____2323232323 ro_Lab_110_5Y_1.00 >									
//        < 5xdwtgzO97tak2271SFVXMV0K5RllI96q0DB7Gnjx8D06grNr6vJbv5nzyYp9A58 >									
//        <  u =="0.000000000000000001" : ] 000001045656291.313420000000000000 ; 000001055656291.313420000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000031DB5E035B2178 >									
//     < NDD_RUSAL_I_metadata_line_15_____2323232323 ro_Lab_110_5Y_1.10 >									
//        < 0aRJ73d4yuNTy49i3ADK8Pe51Fl7fA4mQDP9Oee4HKnZtc64ma7gGtO1OwIh9UWb >									
//        <  u =="0.000000000000000001" : ] 000001055656291.313420000000000000 ; 000001065656291.313420000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000035B2178398996D >									
//     < NDD_RUSAL_I_metadata_line_16_____2323232323 ro_Lab_110_7Y_1.00 >									
//        < z1837c16O04k8S4x789n89TSXd3gz5UdEZzI7F83GJ82fi3R90uwUSLNWY487k4L >									
//        <  u =="0.000000000000000001" : ] 000001065656291.313420000000000000 ; 000001075656291.313420000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000398996D3D604AF >									
//     < NDD_RUSAL_I_metadata_line_17_____2323232323 ro_Lab_210_3Y_1.00 >									
//        < dQ0Cf38ij5CQ0tJ92qr60oW7vtU0Ic61UJH39KDat939985c0HTACFnsbcD9C7X9 >									
//        <  u =="0.000000000000000001" : ] 000001075656291.313420000000000000 ; 000001090151882.612820000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000003D604AF41368D7 >									
//     < NDD_RUSAL_I_metadata_line_18_____2323232323 ro_Lab_210_5Y_1.00 >									
//        < I3dP37996G7mCjQpElCaB3Ih2570vJtOc44x0OtyjksIb4CmV7K23Pinmcq8sOM3 >									
//        <  u =="0.000000000000000001" : ] 000001090151882.612820000000000000 ; 000001100151882.612820000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000041368D7450CDDB >									
//     < NDD_RUSAL_I_metadata_line_19_____2323232323 ro_Lab_210_5Y_1.10 >									
//        < Fx7q8ZnG9A7KP3hr4mB488Iue82DnB9S6804HNU3N2lV2A2g13tPR9072y4SKeH9 >									
//        <  u =="0.000000000000000001" : ] 000001100151882.612820000000000000 ; 000001110151882.612820000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000450CDDB48E348A >									
//     < NDD_RUSAL_I_metadata_line_20_____2323232323 ro_Lab_210_7Y_1.00 >									
//        < 740I8493j2I77nTvWq1O5Bt9DW89r0AnZA5B7qkbVP81xTGM0norqd47h1XClmTD >									
//        <  u =="0.000000000000000001" : ] 000001110151882.612820000000000000 ; 000001120151882.612820000000000000 ] >									
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
//     < NDD_RUSAL_I_metadata_line_21_____2386281206 ro_Lab_310_3Y_1.00 >									
//        < G67x6R99wBG5P3x5ss5b0c3tH390Zi157TlZKlT87J459y199jSCO8VS55JgoLg6 >									
//        <  u =="0.000000000000000001" : ] 000001120151882.612820000000000000 ; 000001138255632.418510000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000004CBA7F7508EB1F >									
//     < NDD_RUSAL_I_metadata_line_22_____2334594893 ro_Lab_310_5Y_1.00 >									
//        < T5VHP71a4eu5dD9mQto96ZZij31u06fO916bF5SD0F77Xcnph6HcIOqOEt1kn7Nf >									
//        <  u =="0.000000000000000001" : ] 000001138255632.418510000000000000 ; 000001148255632.418510000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000508EB1F5462EA7 >									
//     < NDD_RUSAL_I_metadata_line_23_____2346942038 ro_Lab_310_5Y_1.10 >									
//        < OJME84H6QIIZDXAU72sZf3293silv2u42sJn1cYP097fVb0jq44U1vqCWDMS6f0c >									
//        <  u =="0.000000000000000001" : ] 000001148255632.418510000000000000 ; 000001158255632.418510000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000005462EA758381BA >									
//     < NDD_RUSAL_I_metadata_line_24_____2323232323 ro_Lab_310_7Y_1.00 >									
//        < V76cH8K36ncAAhaOe7v2q553uX1heQk47FxR17nbKfMp23sP71ROtdtUQuB8L2a8 >									
//        <  u =="0.000000000000000001" : ] 000001158255632.418510000000000000 ; 000001168255632.418510000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000058381BA5C0F839 >									
//     < NDD_RUSAL_I_metadata_line_25_____2323232323 ro_Lab_410_3Y_1.00 >									
//        < 8tZa6xrL4uakUET6Fs2w13C8U4t590RmC8PcWVQ5WTiOWMiR26A7f6LnvOx45HII >									
//        <  u =="0.000000000000000001" : ] 000001168255632.418510000000000000 ; 000001191490484.395810000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000005C0F8395FE472C >									
//     < NDD_RUSAL_I_metadata_line_26_____2323232323 ro_Lab_410_5Y_1.00 >									
//        < 9qrgTISWd42PlZ4Gm4pY0LR6OSYd2C5UkZGppfg0y0I5L35o8YhyZnUSP8K280uP >									
//        <  u =="0.000000000000000001" : ] 000001191490484.395810000000000000 ; 000001201490484.395810000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000005FE472C63BB336 >									
//     < NDD_RUSAL_I_metadata_line_27_____2323232323 ro_Lab_410_5Y_1.10 >									
//        < tZsr5n50kB1NRAa6788CKkT2E8063sP6Kfw0rxuNHYFjezAcX6SJ2f36hq0shX08 >									
//        <  u =="0.000000000000000001" : ] 000001201490484.395810000000000000 ; 000001211490484.395810000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000063BB33667906A0 >									
//     < NDD_RUSAL_I_metadata_line_28_____2323232323 ro_Lab_410_7Y_1.00 >									
//        < y8zC1KR3AU76H80l0qwPpi31tVLBVpotmBZ7vqUa64DvERNmo70nGLZtJ1NC47hJ >									
//        <  u =="0.000000000000000001" : ] 000001211490484.395810000000000000 ; 000001221490484.395810000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000067906A06B662B3 >									
//     < NDD_RUSAL_I_metadata_line_29_____2323232323 ro_Lab_810_3Y_1.00 >									
//        < MDWr3u415rU61cZZisoG6A4sAqJqeKeRNMuA7JYhY9BTTVrtHY65936SN22bDVQG >									
//        <  u =="0.000000000000000001" : ] 000001221490484.395810000000000000 ; 000001285575986.964080000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000006B662B36F3A625 >									
//     < NDD_RUSAL_I_metadata_line_30_____2323232323 ro_Lab_810_5Y_1.00 >									
//        < q4V1hV50GDtMF1jz942YoJsi1NmyI8rNi0XZ3Q9QR90D5Lc7zHT11x94lg526Idc >									
//        <  u =="0.000000000000000001" : ] 000001285575986.964080000000000000 ; 000001295575986.964080000000000000 ] >									
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
//     < NDD_RUSAL_I_metadata_line_31_____1004711092 ro_Lab_810_5Y_1.10 >									
//        < 2fW1zK6n1V5rjlbsjLNXm6aJ7NP69xq7pGC1d960StO8e37QkU41t6sSRI4Ik7NG >									
//        <  u =="0.000000000000000001" : ] 000001295575986.964080000000000000 ; 000001305575986.964080000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000730F26D76E5047 >									
//     < NDD_RUSAL_I_metadata_line_32_____859658446 ro_Lab_810_7Y_1.00 >									
//        < iwV0Y06wXIhr2m9Tril9RHGm3KB1yvKJb8d6KA5S8mPwJG8019I2kP2y2m8le0Fc >									
//        <  u =="0.000000000000000001" : ] 000001305575986.964080000000000000 ; 000001315575986.964080000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000076E50477ABA5D6 >									
//     < NDD_RUSAL_I_metadata_line_33_____915347120 ro_Lab_411_3Y_1.00 >									
//        < 3dRE4yY0OD4WV8r10wuv565F8l6nRJJaaojQiPg8xVN3Gcp45u844038zu5HH6BH >									
//        <  u =="0.000000000000000001" : ] 000001315575986.964080000000000000 ; 000001608526968.325850000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000007ABA5D67E9059E >									
//     < NDD_RUSAL_I_metadata_line_34_____722798607 ro_Lab_411_5Y_1.00 >									
//        < 9ayZwS708QF90Pp1mJViXU7y10uEXo9T17JdocRtA6SFCOk49URRSUsMq6d03vdH >									
//        <  u =="0.000000000000000001" : ] 000001608526968.325850000000000000 ; 000049406099180.331000000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000007E9059E82657EF >									
//     < NDD_RUSAL_I_metadata_line_35_____821604662 ro_Lab_411_5Y_1.10 >									
//        < A4152VDedKwkG45BGCqjAoVX2mD90h1R9cbUW71TrG2UKnpR2A5dm4k17v3cc53V >									
//        <  u =="0.000000000000000001" : ] 000049406099180.331000000000000000 ; 000071934290631.993100000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000082657EF863ADE0 >									
//     < NDD_RUSAL_I_metadata_line_36_____9935800175 ro_Lab_411_7Y_1.00 >									
//        < 59u6jv9kA5lzviu5QxXNr53KD1HeFij1naERG5s8sm72340v72532aaqe5z14Uir >									
//        <  u =="0.000000000000000001" : ] 000071934290631.993100000000000000 ; 005365003670456.820000000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000863ADE08A0F0D0 >									
//     < NDD_RUSAL_I_metadata_line_37_____593061702 ro_Lab_811_3Y_1.00 >									
//        < OW89Cc7k22jAUZv6j8Zg6ZJn214KZd5wq3brF22ySE50KUtFoNc6k37i49578Tk2 >									
//        <  u =="0.000000000000000001" : ] 005365003670456.820000000000000000 ; 005366754459653.040000000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000008A0F0D08DE58F4 >									
//     < NDD_RUSAL_I_metadata_line_38_____9767479521 ro_Lab_811_5Y_1.00 >									
//        < 147KgvBjiul12oRA124v5XHAs6JhbDHLUetDyv48O5VQUj398ZrfAb0GWG0y496i >									
//        <  u =="0.000000000000000001" : ] 005366754459653.040000000000000000 ; 006459982015938.470000000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000008DE58F491BAF8C >									
//     < NDD_RUSAL_I_metadata_line_39_____2323232323 ro_Lab_811_5Y_1.10 >									
//        < 95m3Nr3T7vo44iV6A53e48ob4XJH6HPpf588idL56wY996Fyh9hCuSO55MDoWmls >									
//        <  u =="0.000000000000000001" : ] 006459982015938.470000000000000000 ; 006973086062871.720000000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000091BAF8C9592943 >									
//     < NDD_RUSAL_I_metadata_line_40_____2323232323 ro_Lab_811_7Y_1.00 >									
//        < 5f1S2TZIbgvTT1UuO1Aq6T9P65LxtG7nhQYOwJcbCL0lgq4Uh5pStqjQAX3TdYQ3 >									
//        <  u =="0.000000000000000001" : ] 006973086062871.720000000000000000 ; 437384439013129.000000000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000095929439966D01 >									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
}