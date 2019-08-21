pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFVII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFVII_III_883		"	;
		string	public		symbol =	"	NDRV_PFVII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		2150247123531500000000000000					;	
										
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
	//     < NDRV_PFVII_III_metadata_line_1_____Hannover Re_20251101 >									
	//        < 4pVGJBK25H1exlwJiGRak0K852Ik51ptH7482EHNc6dG9CUj47Qc9STQlT899767 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000028915833.975073400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000002C1F3F >									
	//     < NDRV_PFVII_III_metadata_line_2_____Hannover Reinsurance Ireland Ltd_20251101 >									
	//        < 2oWhh65Pw1q2Soat74I8R7648qbPmype2W70as0K156Bqu79c5gx7kZV1d1qZvNY >									
	//        <  u =="0.000000000000000001" : ] 000000028915833.975073400000000000 ; 000000069455843.328465000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002C1F3F69FB30 >									
	//     < NDRV_PFVII_III_metadata_line_3_____975 Carroll Square Llc_20251101 >									
	//        < q0E29gXBY6kzEZ3jbA48WJUR545m341COwDA5wS7EP571HYbspWOeM1TSziED3s8 >									
	//        <  u =="0.000000000000000001" : ] 000000069455843.328465000000000000 ; 000000150187224.228747000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000069FB30E52AE2 >									
	//     < NDRV_PFVII_III_metadata_line_4_____Caroll_Holdings_20251101 >									
	//        < lic28Lgj6860Wt56M73Q5BYc64fyrDR3Ts6Z0c86IRFluyyZoP0v1b3zhU04pqK7 >									
	//        <  u =="0.000000000000000001" : ] 000000150187224.228747000000000000 ; 000000170201229.365145000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E52AE2103B4DB >									
	//     < NDRV_PFVII_III_metadata_line_5_____Skandia Versicherung Management & Service Gmbh_20251101 >									
	//        < bGq7faaUQ7iHRv5r3bQy1457RaDKV7K990jJnB3sU7ZvBIjVc1KEXPb5uVb4YxBx >									
	//        <  u =="0.000000000000000001" : ] 000000170201229.365145000000000000 ; 000000203343436.079184000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000103B4DB1364708 >									
	//     < NDRV_PFVII_III_metadata_line_6_____Skandia PortfolioManagement Gmbh, Asset Management Arm_20251101 >									
	//        < 8Tw2uDcTL2NwAaR92Gz9LW6c0lVZo2mAL709Re6Z44S6GdoySdwg8vjOd77HBh6N >									
	//        <  u =="0.000000000000000001" : ] 000000203343436.079184000000000000 ; 000000230504870.145462000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000136470815FB8F7 >									
	//     < NDRV_PFVII_III_metadata_line_7_____Argenta Underwriting No8 Limited_20251101 >									
	//        < SF37DtR7ZIo0tMW97I5O2vcj22pwLry9tvB8qDJk9N6x0oUC99qJQ3rnzY1qITY7 >									
	//        <  u =="0.000000000000000001" : ] 000000230504870.145462000000000000 ; 000000290332423.930498000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015FB8F71BB031A >									
	//     < NDRV_PFVII_III_metadata_line_8_____Oval Office Grundstücks GmbH_20251101 >									
	//        < JrUhKFvN3q66UiSVrFC9h0fGJQ8Ob0rlt5Cho3t2i6l93POQH8q9Xg2t25I74Ag1 >									
	//        <  u =="0.000000000000000001" : ] 000000290332423.930498000000000000 ; 000000360436415.634567000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BB031A225FB7A >									
	//     < NDRV_PFVII_III_metadata_line_9_____Hannover Rückversicherung AG Asset Management Arm_20251101 >									
	//        < YbWIXl76yoNppGtXUb741xNxB1277JU81zo3pW59xxdM9tvoJggQwU2nUtxbCcJ5 >									
	//        <  u =="0.000000000000000001" : ] 000000360436415.634567000000000000 ; 000000417925192.320195000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000225FB7A27DB407 >									
	//     < NDRV_PFVII_III_metadata_line_10_____Hannover Rueckversicherung Ag Korea Branch_20251101 >									
	//        < 4G9Hu1tZ8XBr3JR4wuTS1b8Nt7xE6Y7119PyTjC59p776JFrr6wJH82YG5jrc74T >									
	//        <  u =="0.000000000000000001" : ] 000000417925192.320195000000000000 ; 000000454120432.111565000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027DB4072B4EECB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFVII_III_metadata_line_11_____Nashville West LLC_20251101 >									
	//        < 4XAbqx9vaZwQ5dUTDMr4rR49UM3dQGGllPqJ3JQf4BI2gTHoAm89Fl19oGtA8j3I >									
	//        <  u =="0.000000000000000001" : ] 000000454120432.111565000000000000 ; 000000511978582.882640000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B4EECB30D37A2 >									
	//     < NDRV_PFVII_III_metadata_line_12_____WRH Offshore High Yield Partners LP_20251101 >									
	//        < 9yKdDNF8LMoXYjZn77099zVl3Ixz5ke7hhxFR9Oqnou4PTB71CiXJ0020VPzfze7 >									
	//        <  u =="0.000000000000000001" : ] 000000511978582.882640000000000000 ; 000000596698293.911666000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030D37A238E7D45 >									
	//     < NDRV_PFVII_III_metadata_line_13_____111Ord Llc_20251101 >									
	//        < utG5z53ZWdTG76rJ6LE442nwJhZb7oPN0a9L4tS1H93gkO9nU8yDNNy0LZDcg4i2 >									
	//        <  u =="0.000000000000000001" : ] 000000596698293.911666000000000000 ; 000000661572563.409641000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038E7D453F17AC8 >									
	//     < NDRV_PFVII_III_metadata_line_14_____Hannover Insurance_Linked Securities GmbH & Co KG_20251101 >									
	//        < nK16Uai1J6Jt9Q4bXVfU8CWdcQBR42e8gd18M8zA4U229592atW4og5P4E38bquU >									
	//        <  u =="0.000000000000000001" : ] 000000661572563.409641000000000000 ; 000000693940382.505975000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F17AC8422DE76 >									
	//     < NDRV_PFVII_III_metadata_line_15_____Hannover Ruckversicherung AG Hong Kong_20251101 >									
	//        < 2oR7R0MQhib3vZGzKpfD1f6HE1XJ66bY85f1VEc8LA7YjbA35Dmvi04HZK2tokcW >									
	//        <  u =="0.000000000000000001" : ] 000000693940382.505975000000000000 ; 000000778549520.768611000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000422DE764A3F8E8 >									
	//     < NDRV_PFVII_III_metadata_line_16_____Hannover Reinsurance Mauritius Ltd_20251101 >									
	//        < 5137pM6epDJJ1o3PeDZ2kTo2ZFYpFORnJU1Tm54Z6Stx3Q04300vae58IWyRxFtW >									
	//        <  u =="0.000000000000000001" : ] 000000778549520.768611000000000000 ; 000000840433902.970571000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A3F8E8502667E >									
	//     < NDRV_PFVII_III_metadata_line_17_____HEPEP II Holding GmbH_20251101 >									
	//        < B5T1z39tBA4EgqMhDc9u9P02z604Z0Ij7A73P029i2Sy9zx72qOZakgMW9B5Jpfg >									
	//        <  u =="0.000000000000000001" : ] 000000840433902.970571000000000000 ; 000000882847611.706438000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000502667E5431E59 >									
	//     < NDRV_PFVII_III_metadata_line_18_____International Insurance Company Of Hannover Limited Sweden_20251101 >									
	//        < 62e97vWKtX2yZ21xdbT6WKCf3RLjwZI7a4O26CX2m48VE85X4O7diJ2622j4lE5c >									
	//        <  u =="0.000000000000000001" : ] 000000882847611.706438000000000000 ; 000000969578452.798993000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005431E595C77595 >									
	//     < NDRV_PFVII_III_metadata_line_19_____HEPEP III Holding GmbH_20251101 >									
	//        < 60Mkjci02gI8idmKRrV2bNLSY980fxhEb1xv4OMPksT3JlLv9pCL6eRh5tMyEe8J >									
	//        <  u =="0.000000000000000001" : ] 000000969578452.798993000000000000 ; 000001020685548.062470000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005C77595615714B >									
	//     < NDRV_PFVII_III_metadata_line_20_____Hannover Rueck Beteiligung Verwaltungs_GmbH_20251101 >									
	//        < B4FN8H5HD488jKde51YDgw7d7474j4aX53RHfDfCFTuglu9jaV20gWVYkBJPDDDZ >									
	//        <  u =="0.000000000000000001" : ] 000001020685548.062470000000000000 ; 000001082200354.840590000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000615714B6734E83 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFVII_III_metadata_line_21_____EplusS Rückversicherung AG_20251101 >									
	//        < 19H63g1jE23x5rDTIbBgGrtUeiZD16z3WnZXomZ9nlGZmw73WP3Y4EPM4B5hnez7 >									
	//        <  u =="0.000000000000000001" : ] 000001082200354.840590000000000000 ; 000001122163417.643670000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006734E836B04916 >									
	//     < NDRV_PFVII_III_metadata_line_22_____HILSP Komplementaer GmbH_20251101 >									
	//        < v790nUjvDnM5w53rECCaheR6dK8ioGv06ec41rw0w37cN4CBXx6Y6IuQb984OQlO >									
	//        <  u =="0.000000000000000001" : ] 000001122163417.643670000000000000 ; 000001162171895.449730000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006B049166ED5566 >									
	//     < NDRV_PFVII_III_metadata_line_23_____Hannover Life Reassurance UK Limited_20251101 >									
	//        < ZYhn68SwIsaYY44Jcb2obDVE2nSqsAwRVZC7J793x37A2YOpZzJkr1YX62qu2Yi9 >									
	//        <  u =="0.000000000000000001" : ] 000001162171895.449730000000000000 ; 000001188321189.955220000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006ED55667153BF7 >									
	//     < NDRV_PFVII_III_metadata_line_24_____EplusS Reinsurance Ireland Ltd_20251101 >									
	//        < iG749beS3On8useRd2TuXI8MB5G3C2pJt3viV08GsCvTW5WiNAQlt7660c2NvW1A >									
	//        <  u =="0.000000000000000001" : ] 000001188321189.955220000000000000 ; 000001248336040.487450000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007153BF7770CF44 >									
	//     < NDRV_PFVII_III_metadata_line_25_____Svedea Skadeservice Ab_20251101 >									
	//        < 8jT3M41O850N0bR06Adyj9wDklGq7samjD1eeuVHVC7dJh6B5iy6bTlMf8GbybCK >									
	//        <  u =="0.000000000000000001" : ] 000001248336040.487450000000000000 ; 000001305076728.899210000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000770CF447C76399 >									
	//     < NDRV_PFVII_III_metadata_line_26_____Hannover Finance Luxembourg SA_20251101 >									
	//        < 8GVlV0XDsUcK6u0hA1jCIY0Zs7sVFcMxFaBx8xJJ8CxD4S9X7u1Fr7FM64blY9XK >									
	//        <  u =="0.000000000000000001" : ] 000001305076728.899210000000000000 ; 000001349593623.215880000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007C7639980B5102 >									
	//     < NDRV_PFVII_III_metadata_line_27_____Hannover Ruckversicherung AG Australia_20251101 >									
	//        < 0YI0m6j4EaQrvglacSimbZ311eoTC8P3a6NabjAOKNnCl8tI9mUdHwGX107V7KBC >									
	//        <  u =="0.000000000000000001" : ] 000001349593623.215880000000000000 ; 000001425846980.445430000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000080B510287FAB7A >									
	//     < NDRV_PFVII_III_metadata_line_28_____Cargo Transit Insurance Pty Limited_20251101 >									
	//        < p2xyFD3R9uzy31eO51dk5L1FyVb4TygYgmBfVbvp3r6GghFX43QN59G2bsq4AwKk >									
	//        <  u =="0.000000000000000001" : ] 000001425846980.445430000000000000 ; 000001445147594.267070000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000087FAB7A89D1EC7 >									
	//     < NDRV_PFVII_III_metadata_line_29_____Hannover Life Re Africa_20251101 >									
	//        < LsALDmy4idQMuKI4WNo2ts6NfvSnml9nztX6KEjw27zzx84pz4b5BEK1kwGtNALk >									
	//        <  u =="0.000000000000000001" : ] 000001445147594.267070000000000000 ; 000001528333743.004380000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000089D1EC791C0D5E >									
	//     < NDRV_PFVII_III_metadata_line_30_____Hannover Re Services USA Inc_20251101 >									
	//        < 4s02tK9PQSOiZhZ2Q0HLDUAU4yNOyEER3BEd5VT0eoPfj8nP35GWi4tUhx4qcmUH >									
	//        <  u =="0.000000000000000001" : ] 000001528333743.004380000000000000 ; 000001587087262.840730000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000091C0D5E975B3F6 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFVII_III_metadata_line_31_____Talanx Deutschland AG_20251101 >									
	//        < B4W2XAP154A9jI2YINoVx7j4Dmdz3c5vM707j5q7mVIbyAR34EJG4mk4iY3Qdr57 >									
	//        <  u =="0.000000000000000001" : ] 000001587087262.840730000000000000 ; 000001651995231.991380000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000975B3F69D8BEA3 >									
	//     < NDRV_PFVII_III_metadata_line_32_____HDI Lebensversicherung AG_20251101 >									
	//        < qfzyLWeEd9wglzlF865G9gVYLl8184Cbdrm5ocguG6q1No770ecmnFAbIsLY5EQi >									
	//        <  u =="0.000000000000000001" : ] 000001651995231.991380000000000000 ; 000001681266320.194790000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009D8BEA3A0568A8 >									
	//     < NDRV_PFVII_III_metadata_line_33_____casa altra development GmbH_20251101 >									
	//        < 64cqwV2OjAcNWx6Ly6blp5B71DN56Be5TBo315Bui5H2N4T9m40QH2DOD2ciVjTq >									
	//        <  u =="0.000000000000000001" : ] 000001681266320.194790000000000000 ; 000001746206069.291110000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A0568A8A687FBF >									
	//     < NDRV_PFVII_III_metadata_line_34_____Credit Life International Services GmbH_20251101 >									
	//        < 4V9L68B11wvL2IpR2774LLfQl043FiqxDlg6EP88go5wRaOGFe8U4XX6v0YAkQPA >									
	//        <  u =="0.000000000000000001" : ] 000001746206069.291110000000000000 ; 000001810020940.868950000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A687FBFAC9DF6E >									
	//     < NDRV_PFVII_III_metadata_line_35_____FVB Gesellschaft für Finanz_und Versorgungsberatung mbH_20251101 >									
	//        < vxkeRbUQAf6ZrgoCBSYEVo6Qxx080M8UFbohtUj8yxl7HON42n29yQtL8Lgq0J7a >									
	//        <  u =="0.000000000000000001" : ] 000001810020940.868950000000000000 ; 000001859643792.639710000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000AC9DF6EB15975B >									
	//     < NDRV_PFVII_III_metadata_line_36_____ASPECTA Assurance International AG_20251101 >									
	//        < 40Dx6atZ7O4oo8XA3i98RKvIQ6Y3fDLwfxnFiSgrcuMAs9Tj2Q9s7gMo30CT6Xz8 >									
	//        <  u =="0.000000000000000001" : ] 000001859643792.639710000000000000 ; 000001938267221.613400000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000B15975BB8D8FA2 >									
	//     < NDRV_PFVII_III_metadata_line_37_____Life Re_Holdings_20251101 >									
	//        < muMPRLH6LOk66xd6F388wICcmJt6Wdp236MW72h5628vkC5q3p08vI3P46ODldVx >									
	//        <  u =="0.000000000000000001" : ] 000001938267221.613400000000000000 ; 000001983864859.664970000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000B8D8FA2BD32336 >									
	//     < NDRV_PFVII_III_metadata_line_38_____Credit Life_Pensions_20251101 >									
	//        < 92Xqwq71r2p2MUU4X6VJ0O135E8wpgV64IH541xr0sP2dI4d97Iv5rAXHN1QG45i >									
	//        <  u =="0.000000000000000001" : ] 000001983864859.664970000000000000 ; 000002027207941.959980000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000BD32336C15461A >									
	//     < NDRV_PFVII_III_metadata_line_39_____ASPECTA_org_20251101 >									
	//        < tJ8h45eAczPvhQ7FGNIx39983LlOy83n7h7ossKstUP99UfQG863EZ8lkd6IOdqV >									
	//        <  u =="0.000000000000000001" : ] 000002027207941.959980000000000000 ; 000002121283515.615840000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000C15461ACA4D260 >									
	//     < NDRV_PFVII_III_metadata_line_40_____Cargo Transit_Holdings_20251101 >									
	//        < o6VYp145u1ed18Pg5Ll22u1C0cv3s5zoViQl0nMHqSYN0qwq6zEQ7327GUW15658 >									
	//        <  u =="0.000000000000000001" : ] 000002121283515.615840000000000000 ; 000002150247123.531500000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000CA4D260CD10448 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}