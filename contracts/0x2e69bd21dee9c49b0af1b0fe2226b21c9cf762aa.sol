pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFII_III_883		"	;
		string	public		symbol =	"	NDRV_PFII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1666270461327850000000000000					;	
										
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
	//     < NDRV_PFII_III_metadata_line_1_____genworth newco properties inc_20251101 >									
	//        < pH433Xh8jfqjPKdskY0PaW9t3zt2s1Q3KjuhiXI7mq9jHtIxl0cEWHc01Ox8cZGb >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000051054138.261170000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000004DE706 >									
	//     < NDRV_PFII_III_metadata_line_2_____genworth newco properties inc_org_20251101 >									
	//        < qagEW65a2I43e2CCwq7QsU881pS0FNxE8aQftoPM15387w3l3QFgdKw3bEY56bYL >									
	//        <  u =="0.000000000000000001" : ] 000000051054138.261170000000000000 ; 000000141184373.304031000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004DE706D76E25 >									
	//     < NDRV_PFII_III_metadata_line_3_____genworth pmi mortgage insurance co canada_20251101 >									
	//        < OhaDX02LfPhX7XBf02woBKk7yx3bnY24VV1v2pVv363MxT7eOJflPpMPydFt802G >									
	//        <  u =="0.000000000000000001" : ] 000000141184373.304031000000000000 ; 000000161684313.135527000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D76E25F6B5EF >									
	//     < NDRV_PFII_III_metadata_line_4_____genworth financial mortgage indemnity limited_20251101 >									
	//        < 6AmFI72R05LuZh07m5P4k8hLvmTxaIvP0I7wGwLwElzJd4E73NJi2Nk21xWt03qY >									
	//        <  u =="0.000000000000000001" : ] 000000161684313.135527000000000000 ; 000000223967236.903320000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F6B5EF155BF34 >									
	//     < NDRV_PFII_III_metadata_line_5_____genworth mayflower assignment corporation_20251101 >									
	//        < t86QhDe2WlhNqBom30h659hKx9T1zF2Ati1Rp31BfF0uLSpW6XyuED45X4bi6r80 >									
	//        <  u =="0.000000000000000001" : ] 000000223967236.903320000000000000 ; 000000259051781.939799000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000155BF3418B481A >									
	//     < NDRV_PFII_III_metadata_line_6_____genworth seguros mexico sa de cv_20251101 >									
	//        < 3k2lj5098a8Xhyw8Bt9C62KPrJqNVhN8uSbG1kk2u0uwioxWrtF3jC3P9qUYy2Qx >									
	//        <  u =="0.000000000000000001" : ] 000000259051781.939799000000000000 ; 000000351555628.710799000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018B481A2186E6B >									
	//     < NDRV_PFII_III_metadata_line_7_____genworth seguros_org_20251101 >									
	//        < 5haZ2MPG40cMbg6wsHjCh2gQ16RnTOoUiGqD43yWSMyaXwayXuYhrFc1Xjm3D7lJ >									
	//        <  u =="0.000000000000000001" : ] 000000351555628.710799000000000000 ; 000000394493302.012616000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002186E6B259F2F2 >									
	//     < NDRV_PFII_III_metadata_line_8_____genworth life insurance co of new york_20251101 >									
	//        < 1KQpQKXCW2Oxn74qGA7yLbd92xQM2gjLZK9v2ul6UI4KRY6N35Ky1nZjd59CBvyd >									
	//        <  u =="0.000000000000000001" : ] 000000394493302.012616000000000000 ; 000000434028360.772142000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000259F2F22964654 >									
	//     < NDRV_PFII_III_metadata_line_9_____genworth mortgage insurance corp of north carolina_20251101 >									
	//        < jfpT3g2Oftq5K7Ocd105wcMkmstYdTZZoZUAQB0tEFO8uM8546bty6bg37eHfioo >									
	//        <  u =="0.000000000000000001" : ] 000000434028360.772142000000000000 ; 000000497373804.654346000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029646542F6EEA4 >									
	//     < NDRV_PFII_III_metadata_line_10_____genworth assetmark capital corp_20251101 >									
	//        < 6q07Z2Q181FNg7bJvb91XcHVnK571j0GZQ3IS48KD8lyA01OaP8Tg8zgFLRMWUXf >									
	//        <  u =="0.000000000000000001" : ] 000000497373804.654346000000000000 ; 000000590210112.511946000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F6EEA438496D3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFII_III_metadata_line_11_____assetmark capital corp_org_20251101 >									
	//        < zY62QN8Z7XTJEt0Clv6XVusCU5Qp1TiEOGJPAe3C1758NB9Co7mD9J6OuU3n84t8 >									
	//        <  u =="0.000000000000000001" : ] 000000590210112.511946000000000000 ; 000000624902871.644881000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038496D33B986AF >									
	//     < NDRV_PFII_III_metadata_line_12_____assetmark capital_holdings_20251101 >									
	//        < eA0E3J4ueDmKlG3Ca694439j15zKRNI1qh20v481mCr78OOhurL7hmxDTr3Ui5Xu >									
	//        <  u =="0.000000000000000001" : ] 000000624902871.644881000000000000 ; 000000652500537.557450000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B986AF3E3A306 >									
	//     < NDRV_PFII_III_metadata_line_13_____assetmark capital_pensions_20251101 >									
	//        < pesK7jSrQ07M8ridFyqP59zBJ0WxD8Y439LE5V9N7v2dWp0lpn32GAL26XyX0HRL >									
	//        <  u =="0.000000000000000001" : ] 000000652500537.557450000000000000 ; 000000673813091.863500000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E3A306404283D >									
	//     < NDRV_PFII_III_metadata_line_14_____genworth assetmark capital corp_org_20251101 >									
	//        < GM791ZCBXU20x51eyabTP48X3j0I2B3kG05c1gj24Pc9DM7RLPZ4Q6342UQtgMn7 >									
	//        <  u =="0.000000000000000001" : ] 000000673813091.863500000000000000 ; 000000706294364.883054000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000404283D435B83C >									
	//     < NDRV_PFII_III_metadata_line_15_____genworth financial insurance company limited_20251101 >									
	//        < Xw47RObO57tlul091o2AJZrgayI0zqwi178659X5bNjWQ5YLu3YLAA4ftYg71zMI >									
	//        <  u =="0.000000000000000001" : ] 000000706294364.883054000000000000 ; 000000749529851.967614000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000435B83C477B119 >									
	//     < NDRV_PFII_III_metadata_line_16_____genworth financial asia ltd_20251101 >									
	//        < 61zL52pe4AujKg6Uq34Q8XPgLC67DUm85x5tKL17a5f2yKf7lBMf2sKqBOPSl9tr >									
	//        <  u =="0.000000000000000001" : ] 000000749529851.967614000000000000 ; 000000778990491.777081000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000477B1194A4A529 >									
	//     < NDRV_PFII_III_metadata_line_17_____genworth financial asia ltd_org_20251101 >									
	//        < 5TPl8Tm0eFgd3DrL8jKy8f4ma65Nzna726qit4y0o287F7G3Egu98I5OR49KF3aQ >									
	//        <  u =="0.000000000000000001" : ] 000000778990491.777081000000000000 ; 000000808404305.825557000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A4A5294D186EF >									
	//     < NDRV_PFII_III_metadata_line_18_____genworth consolidated insurance group ltd_20251101 >									
	//        < 8Q1yU5uQ6eby92w8BZ67XMxC60wEh4BAgAi5j0D3Z0dxI3iEN1c8JrBr79CBiW17 >									
	//        <  u =="0.000000000000000001" : ] 000000808404305.825557000000000000 ; 000000849852722.573340000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004D186EF510C5B8 >									
	//     < NDRV_PFII_III_metadata_line_19_____genworth financial uk holdings ltd_20251101 >									
	//        < st6425G5GSLUT1ypAlXgy1qJPg4A521HHxR119O03Alb9k6tKj501sGf7TE28hv6 >									
	//        <  u =="0.000000000000000001" : ] 000000849852722.573340000000000000 ; 000000894673093.086858000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000510C5B855529AD >									
	//     < NDRV_PFII_III_metadata_line_20_____genworth financial uk holdings ltd_org_20251101 >									
	//        < Eovi2WJKpGA81T5y6EfQkI8mpU65DUD4Q9wT68j328rxhphZp7UyV0c162Z4u0kL >									
	//        <  u =="0.000000000000000001" : ] 000000894673093.086858000000000000 ; 000000914300003.654710000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000055529AD5731C70 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFII_III_metadata_line_21_____genworth mortgage services llc_20251101 >									
	//        < 2RCG18iOi1jKet7fUAkK4r5dk6fS0r514Arwm2vcjZ3Ll54A01735kkcwetL191K >									
	//        <  u =="0.000000000000000001" : ] 000000914300003.654710000000000000 ; 000000934857064.803442000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005731C705927A8A >									
	//     < NDRV_PFII_III_metadata_line_22_____genworth brookfield life assurance co ltd_20251101 >									
	//        < 9l87023xr8xx13k8PUVwiqk75pJbND3mhA7n1qiPh380Q75fi3bjCSc8n49YYS9B >									
	//        <  u =="0.000000000000000001" : ] 000000934857064.803442000000000000 ; 000000989618791.503587000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005927A8A5E609D7 >									
	//     < NDRV_PFII_III_metadata_line_23_____genworth rivermont life insurance co i_20251101 >									
	//        < 9Kyl72J720bWUp9B5W935MhvSYFTuiTrOoeZW8SRn7Chm96Aejx8PyfF9URz41f4 >									
	//        <  u =="0.000000000000000001" : ] 000000989618791.503587000000000000 ; 000001042819919.219510000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005E609D76373788 >									
	//     < NDRV_PFII_III_metadata_line_24_____genworth gna distributors inc_20251101 >									
	//        < 0v7b4bxUZ143FMLs3F68716P7q61erBG2312zO4RlOr7UR8q8hgPPM5kChrpjMZU >									
	//        <  u =="0.000000000000000001" : ] 000001042819919.219510000000000000 ; 000001092022667.969810000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000063737886824B5B >									
	//     < NDRV_PFII_III_metadata_line_25_____genworth center for financial learning llc_20251101 >									
	//        < 1Nd7SyVkKiT002YTC88cD82YwIXCgb9D5PK7Zmw9tE05VF6BeSLCk4C1LfYNh249 >									
	//        <  u =="0.000000000000000001" : ] 000001092022667.969810000000000000 ; 000001115378809.175920000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006824B5B6A5EED9 >									
	//     < NDRV_PFII_III_metadata_line_26_____genworth financial mortgage solutions ltd_20251101 >									
	//        < 8r89ziZoV8rv30n0kR4c60sfx9QgRvAu6B3P5cPYgea3vXlvY6UrfElFRK5cc4R7 >									
	//        <  u =="0.000000000000000001" : ] 000001115378809.175920000000000000 ; 000001150012909.006640000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006A5EED96DAC7CB >									
	//     < NDRV_PFII_III_metadata_line_27_____genworth hochman & baker inc_20251101 >									
	//        < 5193gXkfm53bznDMsdT0X3h59Emz6j9H3l5AurF0xLalmf83BqhCc4R40e1PI59S >									
	//        <  u =="0.000000000000000001" : ] 000001150012909.006640000000000000 ; 000001169365508.302180000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006DAC7CB6F84F67 >									
	//     < NDRV_PFII_III_metadata_line_28_____hochman baker_org_20251101 >									
	//        < 63Kd35HnQhvqWLX0uAk8wL5cC2aSNe8P3JPm0xLQ3Tv6kKef9SYX61AQj1GI25Tu >									
	//        <  u =="0.000000000000000001" : ] 000001169365508.302180000000000000 ; 000001233652351.545850000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006F84F6775A6773 >									
	//     < NDRV_PFII_III_metadata_line_29_____hochman baker_holdings_20251101 >									
	//        < Cl07NQSr1p4e23Sel66j1OVbI1SBl5JCLRxxXR30M636qHQ6J0E3r2XzNDu748Iw >									
	//        <  u =="0.000000000000000001" : ] 000001233652351.545850000000000000 ; 000001253549088.882070000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000075A6773778C39D >									
	//     < NDRV_PFII_III_metadata_line_30_____hochman  baker_pensions_20251101 >									
	//        < QzE0xvdMa2XP98W0OKitZ08b9CCuqE6Zay9L0hDFQ5QOi23DZSnVBB626l8t4j5k >									
	//        <  u =="0.000000000000000001" : ] 000001253549088.882070000000000000 ; 000001287666207.380960000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000778C39D7ACD29D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFII_III_metadata_line_31_____genworth hgi annuity service corporation_20251101 >									
	//        < gYB2LF46xl6dws7QwVB83aB6382knMOldz9yTGp9xmCwpTtc1mJvD1rFj8tH3Gsp >									
	//        <  u =="0.000000000000000001" : ] 000001287666207.380960000000000000 ; 000001306289222.309890000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007ACD29D7C93D3A >									
	//     < NDRV_PFII_III_metadata_line_32_____genworth financial service korea co_20251101 >									
	//        < lz9Yoem9Jnoa6m3b39sdOf7yPDK21TWEX5PPP33v29vv4q0d44z0CT5LbqF06IAr >									
	//        <  u =="0.000000000000000001" : ] 000001306289222.309890000000000000 ; 000001329710385.958310000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007C93D3A7ECFA1F >									
	//     < NDRV_PFII_III_metadata_line_33_____financial service korea_org_20251101 >									
	//        < 97zW4DR9q5tlQtz5h3tZlt0E1aEEC8EPz16hi55fAGA8Y7eX3i41H174BaWlta3k >									
	//        <  u =="0.000000000000000001" : ] 000001329710385.958310000000000000 ; 000001353234923.686480000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007ECFA1F810DF64 >									
	//     < NDRV_PFII_III_metadata_line_34_____genworth special purpose five llc_20251101 >									
	//        < 20Vy6uGF8qhoxLHRSH7T253bP297P9AE9ghZ95YJ576oRvC6Ci62Faa1u6aG1Uo3 >									
	//        <  u =="0.000000000000000001" : ] 000001353234923.686480000000000000 ; 000001435691052.823200000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000810DF6488EB0D1 >									
	//     < NDRV_PFII_III_metadata_line_35_____genworth special purpose five llc_org_20251101 >									
	//        < 2IwbqUTFA1c7xqH9FlcuNnOPWJd8V1QQls93U8mGf462tt3C4X86oIU041gL5REG >									
	//        <  u =="0.000000000000000001" : ] 000001435691052.823200000000000000 ; 000001474740661.885340000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000088EB0D18CA4692 >									
	//     < NDRV_PFII_III_metadata_line_36_____genworth financial securities corporation_20251101 >									
	//        < NTfksfna38894gQz405y15HgH6BkS577OsvR96iJJ2yV9gn555U68419rE135uq1 >									
	//        <  u =="0.000000000000000001" : ] 000001474740661.885340000000000000 ; 000001536423872.447540000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008CA46929286593 >									
	//     < NDRV_PFII_III_metadata_line_37_____genworth financial securities corp_org_20251101 >									
	//        < 3E2LWpC79etWEDNPe698T5Kohyv3sMIs5Z3toMXMZ5772UE20v45A5yNClCz2y41 >									
	//        <  u =="0.000000000000000001" : ] 000001536423872.447540000000000000 ; 000001581160540.864290000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000928659396CA8D6 >									
	//     < NDRV_PFII_III_metadata_line_38_____genworth special purpose one llc_20251101 >									
	//        < GQy4KO2rN15UE6DdG3bj9NfH7R48L62f5n89XHXvkN0961U9Tmx2Dkswi5Nt2LE3 >									
	//        <  u =="0.000000000000000001" : ] 000001581160540.864290000000000000 ; 000001625116259.613750000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000096CA8D69AFBB0A >									
	//     < NDRV_PFII_III_metadata_line_39_____genworth special purpose one llc_org_20251101 >									
	//        < Rm4c07jT87O81n6U6fq1K141zan01X2pt2Wgn8e6s46e358CsLGPr0Hvne2WaWe2 >									
	//        <  u =="0.000000000000000001" : ] 000001625116259.613750000000000000 ; 000001643546261.269740000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009AFBB0A9CBDA42 >									
	//     < NDRV_PFII_III_metadata_line_40_____special purpose one_pensions_20251101 >									
	//        < muL6aOS1pnrY3P0UuQNj8c3s12g98H70573P5bGoTsWbD7keO33e77nCV9jz268x >									
	//        <  u =="0.000000000000000001" : ] 000001643546261.269740000000000000 ; 000001666270461.327850000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009CBDA429EE86E6 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}