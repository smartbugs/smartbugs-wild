pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFII_II_883		"	;
		string	public		symbol =	"	NDRV_PFII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1127036398400930000000000000					;	
										
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
	//     < NDRV_PFII_II_metadata_line_1_____genworth newco properties inc_20231101 >									
	//        < O9zVKvaBfH9UwC57tuLruF6Hi9rH8gfvAX90MU18uxY72Z4JyphLPP6jNU827C9s >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000024901500.754260400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000025FF26 >									
	//     < NDRV_PFII_II_metadata_line_2_____genworth newco properties inc_org_20231101 >									
	//        < S74j95fenMFsDtDoRcCF897g192BS25rVEE5SfPdwlF4J6v9QGftEH3sV4ffwPSP >									
	//        <  u =="0.000000000000000001" : ] 000000024901500.754260400000000000 ; 000000073017121.871229400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000025FF266F6A50 >									
	//     < NDRV_PFII_II_metadata_line_3_____genworth pmi mortgage insurance co canada_20231101 >									
	//        < N2CD84453d6d7B52jgq9kyqS05rD5rGzkn0315gPU0BDe7TjPzGG116l34Lw5AZn >									
	//        <  u =="0.000000000000000001" : ] 000000073017121.871229400000000000 ; 000000112409196.258613000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006F6A50AB85D8 >									
	//     < NDRV_PFII_II_metadata_line_4_____genworth financial mortgage indemnity limited_20231101 >									
	//        < 4752n2x9O36CON7ghtK1A9wPCU0JJ2FAns0nRvzKa931e03g70i0yUWJ1NSQ1w08 >									
	//        <  u =="0.000000000000000001" : ] 000000112409196.258613000000000000 ; 000000159492556.388202000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AB85D8F35DC8 >									
	//     < NDRV_PFII_II_metadata_line_5_____genworth mayflower assignment corporation_20231101 >									
	//        < ml3IQr72TmHlfvm688H54TByLwFmvBC8dz0BGNW8zzRjgAibBXOy45Yshgc84V0n >									
	//        <  u =="0.000000000000000001" : ] 000000159492556.388202000000000000 ; 000000184210522.611480000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F35DC8119153C >									
	//     < NDRV_PFII_II_metadata_line_6_____genworth seguros mexico sa de cv_20231101 >									
	//        < 75c5h5r6DipVurf8y07iFe4qHj4iKwDbAZr74A7aKpWdM37FiNlSEbVh89E4KjO8 >									
	//        <  u =="0.000000000000000001" : ] 000000184210522.611480000000000000 ; 000000204244079.152896000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000119153C137A6D8 >									
	//     < NDRV_PFII_II_metadata_line_7_____genworth seguros_org_20231101 >									
	//        < Sxb9FGbAmvDGDaLTrO6N0tb0k366MsGSGc1cyFDC6RLBD1WZH2Oh99Cmd55FAV1P >									
	//        <  u =="0.000000000000000001" : ] 000000204244079.152896000000000000 ; 000000220452611.651734000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000137A6D8150624D >									
	//     < NDRV_PFII_II_metadata_line_8_____genworth life insurance co of new york_20231101 >									
	//        < 2zHKgbvA5M5lAd330j4HG166zX5z614b9WbNzqg34IHNA854bLtAB4Je9eP6nBvj >									
	//        <  u =="0.000000000000000001" : ] 000000220452611.651734000000000000 ; 000000256164640.361617000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000150624D186E050 >									
	//     < NDRV_PFII_II_metadata_line_9_____genworth mortgage insurance corp of north carolina_20231101 >									
	//        < u0SN2L3b33FVy08X7l5tI22l1bW6P6tSz0GSZV4Cd1XTY6uH93C3O0999SMeR678 >									
	//        <  u =="0.000000000000000001" : ] 000000256164640.361617000000000000 ; 000000273825322.074321000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000186E0501A1D304 >									
	//     < NDRV_PFII_II_metadata_line_10_____genworth assetmark capital corp_20231101 >									
	//        < z9kDU29yo4BHHn7hjpZtd50wCu4512u6vC9u3LMQKXVIZw5LTg2OW64my9vtdWI0 >									
	//        <  u =="0.000000000000000001" : ] 000000273825322.074321000000000000 ; 000000301816159.896943000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A1D3041CC88F0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFII_II_metadata_line_11_____assetmark capital corp_org_20231101 >									
	//        < 1y465Db849d0T980zUlA8tiUOL3B1VfXkZsGv5mmJO874vFDFtOlytzrq49HcW9B >									
	//        <  u =="0.000000000000000001" : ] 000000301816159.896943000000000000 ; 000000324763712.951654000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CC88F01EF8CD3 >									
	//     < NDRV_PFII_II_metadata_line_12_____assetmark capital_holdings_20231101 >									
	//        < Z5AYxkA1I3fBc8t9600SovvuJsBCIVmIJlCpT9ogc5GWqC5f6Cxl1cylO92uAJxb >									
	//        <  u =="0.000000000000000001" : ] 000000324763712.951654000000000000 ; 000000341701189.165569000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EF8CD32096507 >									
	//     < NDRV_PFII_II_metadata_line_13_____assetmark capital_pensions_20231101 >									
	//        < 7iM9W6SRDfsTWH0IA003e406W0j33Z8p5mnpQT58kz73cDgzU6bZSkvLfUSzZTeu >									
	//        <  u =="0.000000000000000001" : ] 000000341701189.165569000000000000 ; 000000374212850.505321000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000209650723B00E5 >									
	//     < NDRV_PFII_II_metadata_line_14_____genworth assetmark capital corp_org_20231101 >									
	//        < n4P14HSqoX0f6h6Utxno635813R3GE859DvsN5Jf0uUxGYyh0c00Gb39HluUgpm4 >									
	//        <  u =="0.000000000000000001" : ] 000000374212850.505321000000000000 ; 000000394750977.770234000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023B00E525A579A >									
	//     < NDRV_PFII_II_metadata_line_15_____genworth financial insurance company limited_20231101 >									
	//        < 3o45Xm7WInlxGNFMF4GabesHbk3XH7HZx5O6y44V56rI813Rt60X3iv3R1cjPT63 >									
	//        <  u =="0.000000000000000001" : ] 000000394750977.770234000000000000 ; 000000416067154.728191000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025A579A27ADE3B >									
	//     < NDRV_PFII_II_metadata_line_16_____genworth financial asia ltd_20231101 >									
	//        < 6fYqFDN77TwyZ3E31B39wmXiSAh8aG4a5DvGSfA0RZaKTlDIglRZdNN85SGq98JH >									
	//        <  u =="0.000000000000000001" : ] 000000416067154.728191000000000000 ; 000000432508784.646588000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027ADE3B293F4BE >									
	//     < NDRV_PFII_II_metadata_line_17_____genworth financial asia ltd_org_20231101 >									
	//        < 2RNdR6vZNQ4gpVQxO4n9wkaDd3V2wy59po7KuvrhCRBq3u2FJ8tdxACr71W2bWAg >									
	//        <  u =="0.000000000000000001" : ] 000000432508784.646588000000000000 ; 000000455356904.099408000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000293F4BE2B6D1CA >									
	//     < NDRV_PFII_II_metadata_line_18_____genworth consolidated insurance group ltd_20231101 >									
	//        < XPNV0kL1eC79B0Je2z2y9dp570yAufge9RT5TSlwaGumC86F412z9xruKB3jfFjy >									
	//        <  u =="0.000000000000000001" : ] 000000455356904.099408000000000000 ; 000000478132663.345542000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B6D1CA2D99292 >									
	//     < NDRV_PFII_II_metadata_line_19_____genworth financial uk holdings ltd_20231101 >									
	//        < uoU0nWUCRN4117d9yVU7E2r89QGs82RcA7t2DaHz7n8o1xNA7MPn0Z6yH5UyTOG5 >									
	//        <  u =="0.000000000000000001" : ] 000000478132663.345542000000000000 ; 000000505592224.098083000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D9929230378F6 >									
	//     < NDRV_PFII_II_metadata_line_20_____genworth financial uk holdings ltd_org_20231101 >									
	//        < 3aXe0uCfKNpgL5So6FMXpmzhTYFhrWLpESR6jcFG84VE025PIB2ryyavGsX736Tz >									
	//        <  u =="0.000000000000000001" : ] 000000505592224.098083000000000000 ; 000000555275999.183461000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030378F634F48B0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFII_II_metadata_line_21_____genworth mortgage services llc_20231101 >									
	//        < kIu91B1440jIxi40cR7VtuzkYk5t8jXE0056vGVpcM53RNel5o1tI1ae364y6584 >									
	//        <  u =="0.000000000000000001" : ] 000000555275999.183461000000000000 ; 000000584930259.882238000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034F48B037C8862 >									
	//     < NDRV_PFII_II_metadata_line_22_____genworth brookfield life assurance co ltd_20231101 >									
	//        < 6pyLpJDhK12yzem4ZoKLO43G104T7aO61tKTSVwVVqgRMz8U8fYKXt4bP6Be2284 >									
	//        <  u =="0.000000000000000001" : ] 000000584930259.882238000000000000 ; 000000615055798.363690000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037C88623AA802C >									
	//     < NDRV_PFII_II_metadata_line_23_____genworth rivermont life insurance co i_20231101 >									
	//        < V1CyypZ6pX1xyln2y975u201q5Ufm43z4WU35dH793m98NB2FOJ90yIJru40m25F >									
	//        <  u =="0.000000000000000001" : ] 000000615055798.363690000000000000 ; 000000637554405.393129000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003AA802C3CCD4B1 >									
	//     < NDRV_PFII_II_metadata_line_24_____genworth gna distributors inc_20231101 >									
	//        < 3CPk795K218rBaFlcM70zZPADlCQ2pB2j8L5ySF7I8nK4Z23Br220jJOvjdgn1F3 >									
	//        <  u =="0.000000000000000001" : ] 000000637554405.393129000000000000 ; 000000677985320.805669000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003CCD4B140A8604 >									
	//     < NDRV_PFII_II_metadata_line_25_____genworth center for financial learning llc_20231101 >									
	//        < TyWHcSHnx2R49568V1p7j9ucVA76Y3v689w61R6xmhMEGRtSdhqo8g8oS4x4N8cB >									
	//        <  u =="0.000000000000000001" : ] 000000677985320.805669000000000000 ; 000000706505139.940036000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040A86044360A92 >									
	//     < NDRV_PFII_II_metadata_line_26_____genworth financial mortgage solutions ltd_20231101 >									
	//        < EA7Dp4zyOv8ZqK8FC0QNh9l7b49yp0oWeP80a516KcC7x0b3u5863mCo86vGBfve >									
	//        <  u =="0.000000000000000001" : ] 000000706505139.940036000000000000 ; 000000729035628.652819000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004360A924586B8B >									
	//     < NDRV_PFII_II_metadata_line_27_____genworth hochman & baker inc_20231101 >									
	//        < H8Bni72k3id21GtNl8v0xvgv4c6tYaBpWxt3Uq2xf39Jo9Btr9syO8k6AlLLBBOJ >									
	//        <  u =="0.000000000000000001" : ] 000000729035628.652819000000000000 ; 000000759223834.779988000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004586B8B4867BCF >									
	//     < NDRV_PFII_II_metadata_line_28_____hochman baker_org_20231101 >									
	//        < w4Eh29IwHKF377CJN8Mz215CYMB533nEP2QA94JnVZ1XK7Y44RWcd9g04I92Wbt5 >									
	//        <  u =="0.000000000000000001" : ] 000000759223834.779988000000000000 ; 000000777930776.420971000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004867BCF4A30736 >									
	//     < NDRV_PFII_II_metadata_line_29_____hochman baker_holdings_20231101 >									
	//        < 3yryoEhY366bkon6HGOuAhvU5pxKq1hKUt7N1OEpx7h7nW3I8OO5cAr2xVf4VEp3 >									
	//        <  u =="0.000000000000000001" : ] 000000777930776.420971000000000000 ; 000000806915963.495621000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A307364CF418C >									
	//     < NDRV_PFII_II_metadata_line_30_____hochman  baker_pensions_20231101 >									
	//        < iH4kMLujxB673Ge24AXqDMciRdNl7n287i8LXRsXqAx3b1q23N9tzT0Gj65YKJ0z >									
	//        <  u =="0.000000000000000001" : ] 000000806915963.495621000000000000 ; 000000843049319.483444000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004CF418C5066424 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFII_II_metadata_line_31_____genworth hgi annuity service corporation_20231101 >									
	//        < Q8TZi2c862uop7kQG18Ba348pF5CHu08yKyB1zoxs8RWUV7tPsLeCy5lPoN6ZGXv >									
	//        <  u =="0.000000000000000001" : ] 000000843049319.483444000000000000 ; 000000867778427.693957000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000506642452C1FF3 >									
	//     < NDRV_PFII_II_metadata_line_32_____genworth financial service korea co_20231101 >									
	//        < Ff37n6gzr01VJbE4SXLijZGWE1FopHS5Nq14g33joVgCxt0Tk24nF8EPF0j37Wl7 >									
	//        <  u =="0.000000000000000001" : ] 000000867778427.693957000000000000 ; 000000899858360.831220000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000052C1FF355D132C >									
	//     < NDRV_PFII_II_metadata_line_33_____financial service korea_org_20231101 >									
	//        < yhoWhzE1dk6k5w5KPq179yRjV2mbEehwq0u3vJ2f8c148i65L44iB171318QPipj >									
	//        <  u =="0.000000000000000001" : ] 000000899858360.831220000000000000 ; 000000919894288.560228000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000055D132C57BA5B5 >									
	//     < NDRV_PFII_II_metadata_line_34_____genworth special purpose five llc_20231101 >									
	//        < d7y8o3iXj3d03Ru5CAEeacOM5b0NVGGeq0I92l0joo6ns4IxZebf1u6bo32qYhAJ >									
	//        <  u =="0.000000000000000001" : ] 000000919894288.560228000000000000 ; 000000937372063.571101000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000057BA5B559650F6 >									
	//     < NDRV_PFII_II_metadata_line_35_____genworth special purpose five llc_org_20231101 >									
	//        < y8y0g7l0Bd4PsgepFlQe4OBONq5p6j7X8IlG9jCXJN5S6Z2rC41StVBmZRK6n7qD >									
	//        <  u =="0.000000000000000001" : ] 000000937372063.571101000000000000 ; 000000982685003.778213000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000059650F65DB7554 >									
	//     < NDRV_PFII_II_metadata_line_36_____genworth financial securities corporation_20231101 >									
	//        < 72PY0zeOyKhjXfFTY8mTsH400s3zhrL8IWLiPlgEmoKA66PXeX12bS8o7V0dm8e8 >									
	//        <  u =="0.000000000000000001" : ] 000000982685003.778213000000000000 ; 000001027763976.615890000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005DB75546203E4E >									
	//     < NDRV_PFII_II_metadata_line_37_____genworth financial securities corp_org_20231101 >									
	//        < wHgJQ38dpSRm67eYh4D17RA4Yf265fZ4HdRfL6cqmTa07wM8QBmUu1l744Hf0xRQ >									
	//        <  u =="0.000000000000000001" : ] 000001027763976.615890000000000000 ; 000001045262728.435820000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006203E4E63AF1C1 >									
	//     < NDRV_PFII_II_metadata_line_38_____genworth special purpose one llc_20231101 >									
	//        < iWtL6a72d2PWjrtd184PA1cJG1qINK5mT0Nu62C1T39zf4OJsYrsRqaSKt32q14t >									
	//        <  u =="0.000000000000000001" : ] 000001045262728.435820000000000000 ; 000001073674117.020040000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000063AF1C16664BF4 >									
	//     < NDRV_PFII_II_metadata_line_39_____genworth special purpose one llc_org_20231101 >									
	//        < 95516VLyiKI5A6F45OJRwCam9scz0d9sq5013lJwS7ko61RJZ3hrK1teaWU3V0d7 >									
	//        <  u =="0.000000000000000001" : ] 000001073674117.020040000000000000 ; 000001104235535.011780000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006664BF4694EE02 >									
	//     < NDRV_PFII_II_metadata_line_40_____special purpose one_pensions_20231101 >									
	//        < R2nKY56064iQAPQEu4IS8Dm4o7HZ9NP4ot0UDb0zEjraA1dJqM7NwwOT7R0jsIwn >									
	//        <  u =="0.000000000000000001" : ] 000001104235535.011780000000000000 ; 000001127036398.400930000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000694EE026B7B898 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}