pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXVI_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXVI_II_883		"	;
		string	public		symbol =	"	RUSS_PFXXVI_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		769120423719425000000000000					;	
										
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
	//     < RUSS_PFXXVI_II_metadata_line_1_____BLUE_STREAM_PIPE_CO_20231101 >									
	//        < FWb0oPDiu4dQUgyCeS8TknZ6KSdlWc7j6v2I0ZUDw77H2MO106B10fEVe3qJNN95 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000017868734.624426400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001B43F9 >									
	//     < RUSS_PFXXVI_II_metadata_line_2_____BLUESTREAM_DAO_20231101 >									
	//        < IEse27L0Im2PM04Bp56zq1TS405Hr85VO53gMz3v0M3itEUz4rv9eV71s2gKF20B >									
	//        <  u =="0.000000000000000001" : ] 000000017868734.624426400000000000 ; 000000040175797.792688400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001B43F93D4DAC >									
	//     < RUSS_PFXXVI_II_metadata_line_3_____BLUESTREAM_DAOPI_20231101 >									
	//        < 3f6A7QQpB6fN546n7nHJP1J5x8QQxdA29xk47srwg8siN1W626488K28r1k63ba8 >									
	//        <  u =="0.000000000000000001" : ] 000000040175797.792688400000000000 ; 000000055594972.295531200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003D4DAC54D4C9 >									
	//     < RUSS_PFXXVI_II_metadata_line_4_____BLUESTREAM_DAC_20231101 >									
	//        < r4o9P9yWkaw5WDlu4S31478FSZjsA4nwwhcm1O9JV2DsUV4lx2Y11yx201uFyRfL >									
	//        <  u =="0.000000000000000001" : ] 000000055594972.295531200000000000 ; 000000076714935.008278300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000054D4C9750EC6 >									
	//     < RUSS_PFXXVI_II_metadata_line_5_____BLUESTREAM_BIMI_20231101 >									
	//        < tC8Bf28d5fHUQa0a972aPc3vR5flC6IaMBF3Sg5JjcFvu05Pxa6IUJb6tEsvS3k2 >									
	//        <  u =="0.000000000000000001" : ] 000000076714935.008278300000000000 ; 000000092223027.458686200000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000750EC68CB89F >									
	//     < RUSS_PFXXVI_II_metadata_line_6_____PANRUSGAZ_20231101 >									
	//        < 10OxFe0Io9TBYhQi3wKj4Sxukk4TYBaHfBKw6vmpq5S243TI94ozPN902gc3RJKu >									
	//        <  u =="0.000000000000000001" : ] 000000092223027.458686200000000000 ; 000000109568515.711387000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008CB89FA73034 >									
	//     < RUSS_PFXXVI_II_metadata_line_7_____OKHRANA_PSC_20231101 >									
	//        < SXh0DlJMf9jHkn7094K535Ng7Ee0C8191sLbI5y4Mdlog0W5izUQrVznzu40RxuZ >									
	//        <  u =="0.000000000000000001" : ] 000000109568515.711387000000000000 ; 000000127258827.416919000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A73034C22E7B >									
	//     < RUSS_PFXXVI_II_metadata_line_8_____PROEKTIROVANYE_OOO_20231101 >									
	//        < 8911DGQ6d1t0IUJhA57DvcwmQKIA3uD9Pr0tR7H5aA5ga1hNw7LlRVKmG7Hfi4O1 >									
	//        <  u =="0.000000000000000001" : ] 000000127258827.416919000000000000 ; 000000151832734.790328000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C22E7BE7ADA9 >									
	//     < RUSS_PFXXVI_II_metadata_line_9_____YUGOROSGAZ_20231101 >									
	//        < i91D9hg43X1iSxF43qnTdk525zyaaT0tB9t9DRD60J6aeS5qic4N9uWUbhHvieU7 >									
	//        <  u =="0.000000000000000001" : ] 000000151832734.790328000000000000 ; 000000170262842.874408000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E7ADA9103CCEC >									
	//     < RUSS_PFXXVI_II_metadata_line_10_____GAZPROM_FINANCE_BV_20231101 >									
	//        < Uh5Z1B2mRLR3V3X8tE9P2Dk0na6T24u547f7N6336neh0z46INQgrU4i0m5HFd4S >									
	//        <  u =="0.000000000000000001" : ] 000000170262842.874408000000000000 ; 000000193568625.196509000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000103CCEC1275CBF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVI_II_metadata_line_11_____WINTERSHALL_NOORDZEE_BV_20231101 >									
	//        < Bc1cxsiD91Q6vbTd76v1TXpE0nQ4Znr8rBcmBJN1ChalKmC617uNj2axgN79KxKR >									
	//        <  u =="0.000000000000000001" : ] 000000193568625.196509000000000000 ; 000000211463275.020702000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001275CBF142AAD8 >									
	//     < RUSS_PFXXVI_II_metadata_line_12_____WINTERSHALL_DAO_20231101 >									
	//        < v35bArdg0w9kXn545YVV319Ak3KkDVk19xOPChsKjw5a0YpeY8nb496bOw473D42 >									
	//        <  u =="0.000000000000000001" : ] 000000211463275.020702000000000000 ; 000000230153411.225504000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000142AAD815F2FAD >									
	//     < RUSS_PFXXVI_II_metadata_line_13_____WINTERSHALL_DAOPI_20231101 >									
	//        < TKxfIEgmqilF6m33PZVk4KOTVW8M0rNm8J33fW6zhm9zMkDmhOV0j9M1tZBf6678 >									
	//        <  u =="0.000000000000000001" : ] 000000230153411.225504000000000000 ; 000000245816517.278960000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015F2FAD1771614 >									
	//     < RUSS_PFXXVI_II_metadata_line_14_____WINTERSHALL_DAC_20231101 >									
	//        < c35hvZpU40L2tK0fEK09vtz716UZg5lXKVR3qMdVa1KbnL7fj1MVqvm5fiWue8MM >									
	//        <  u =="0.000000000000000001" : ] 000000245816517.278960000000000000 ; 000000264741701.625890000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001771614193F6BA >									
	//     < RUSS_PFXXVI_II_metadata_line_15_____WINTERSHALL_BIMI_20231101 >									
	//        < 52SMpWbd8U6OH8S80EEyM5LimgskILTc8hYDU8umsi4f69rGFokw81m2p4l93P6U >									
	//        <  u =="0.000000000000000001" : ] 000000264741701.625890000000000000 ; 000000281814523.780066000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000193F6BA1AE03CC >									
	//     < RUSS_PFXXVI_II_metadata_line_16_____SAKHALIN_HOLDINGS_BV_20231101 >									
	//        < r2N6VcOl95MFQD9z0OA3wk5CLc9Dt30SL5UddS8EEL6a9Oo105PNd3e591X34G4d >									
	//        <  u =="0.000000000000000001" : ] 000000281814523.780066000000000000 ; 000000302615412.989228000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AE03CC1CDC125 >									
	//     < RUSS_PFXXVI_II_metadata_line_17_____TRANSGAS_KAZAN_20231101 >									
	//        < Ozbf1nZ574dKn9HjN7V57ro1x2crQ16AS8dCun0E6gdxOB5S95qcVoC1LtJkvBl5 >									
	//        <  u =="0.000000000000000001" : ] 000000302615412.989228000000000000 ; 000000321166661.335245000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CDC1251EA0FBA >									
	//     < RUSS_PFXXVI_II_metadata_line_18_____SOUTH_STREAM_SERBIA_20231101 >									
	//        < iv2GO2eQ5blV3m093phI4Tb117RYa9BGcIk0YlL58iWe7e3Ge63h6NC7dWshf9X1 >									
	//        <  u =="0.000000000000000001" : ] 000000321166661.335245000000000000 ; 000000341718490.098023000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EA0FBA2096BC9 >									
	//     < RUSS_PFXXVI_II_metadata_line_19_____WINTERSHALL_ERDGAS_HANDELSHAUS_ZUG_AG_20231101 >									
	//        < DledGw7a7Nz3E2prTumKpJFg5I0AFOX5O3wIcoy8473376VdHO40Ko42r13SBSeK >									
	//        <  u =="0.000000000000000001" : ] 000000341718490.098023000000000000 ; 000000359293367.070677000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002096BC92243CF9 >									
	//     < RUSS_PFXXVI_II_metadata_line_20_____TRANSGAZ_MOSCOW_OOO_20231101 >									
	//        < 8a1Y3wYH45B7lwX0mei6NIFa16W5IxDo9QEn33e9JPcaFA5R775uNGyJDNf0Z0rI >									
	//        <  u =="0.000000000000000001" : ] 000000359293367.070677000000000000 ; 000000378301264.438315000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002243CF92413DEE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVI_II_metadata_line_21_____PERERABOTKA_20231101 >									
	//        < B9L60Vyv5I1qe0TsvkUF0CEIObT9aUb7Y1IhCCE6Uu76DBoI4657z56j5YMRd86e >									
	//        <  u =="0.000000000000000001" : ] 000000378301264.438315000000000000 ; 000000398829675.934494000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002413DEE26090D8 >									
	//     < RUSS_PFXXVI_II_metadata_line_22_____GAZPROM_EXPORT_20231101 >									
	//        < Sycd2C15Udvq7ppQ4CKb3AFT6C4fS0ppcWfkrB54X77g818Knc8pzACpR9DL01Dq >									
	//        <  u =="0.000000000000000001" : ] 000000398829675.934494000000000000 ; 000000419436425.739025000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026090D8280025B >									
	//     < RUSS_PFXXVI_II_metadata_line_23_____WINGAS_20231101 >									
	//        < 11jK80i600SgVYi7C2jyV51huGrZIAU00pb4Ul2x72z71MUo4xuK0B9Y9pMgUc2v >									
	//        <  u =="0.000000000000000001" : ] 000000419436425.739025000000000000 ; 000000434854115.600797000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000280025B29788E4 >									
	//     < RUSS_PFXXVI_II_metadata_line_24_____DOBYCHA_URENGOY_20231101 >									
	//        < n34YJ6hQ3A0R9f5Km8Wo902nq6wJJ3cMPqUAu5IeG1mWJHPd0EdS5dXt19p4k1i8 >									
	//        <  u =="0.000000000000000001" : ] 000000434854115.600797000000000000 ; 000000458795822.279469000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029788E42BC111E >									
	//     < RUSS_PFXXVI_II_metadata_line_25_____MOSENERGO_20231101 >									
	//        < Cu1zd9d7ms5s3xB944dy802perDBXMg8Wdo5y03MG2v8gAwM3C65V5VO842t2G1W >									
	//        <  u =="0.000000000000000001" : ] 000000458795822.279469000000000000 ; 000000475143362.866011000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BC111E2D502E0 >									
	//     < RUSS_PFXXVI_II_metadata_line_26_____OGK_2_AB_20231101 >									
	//        < 6IJH833Y0u6Z3EU6N590qq5uZ8vwn3w89Arcc57S87Lhg9g31bQD18iXl9oMbx7Q >									
	//        <  u =="0.000000000000000001" : ] 000000475143362.866011000000000000 ; 000000495122880.677946000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D502E02F37F60 >									
	//     < RUSS_PFXXVI_II_metadata_line_27_____TGC_1_20231101 >									
	//        < 00dn6XH65IdEl8VhAjpjiY3MtMo3gFCg7Z5E9d9IDhBY1KckC8r1X8mqX4Z3Xki8 >									
	//        <  u =="0.000000000000000001" : ] 000000495122880.677946000000000000 ; 000000511220999.595797000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F37F6030C0FB4 >									
	//     < RUSS_PFXXVI_II_metadata_line_28_____GAZPROM_MEDIA_20231101 >									
	//        < vhphUS9gcQ8nF5130E7cjSp1U308E63oOsdyMsxZozEUxE6ZMy9E0Tfj2gA3HBP6 >									
	//        <  u =="0.000000000000000001" : ] 000000511220999.595797000000000000 ; 000000529085912.922383000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030C0FB4327522F >									
	//     < RUSS_PFXXVI_II_metadata_line_29_____ENERGOHOLDING_LLC_20231101 >									
	//        < Ax4Yt9C3Rs0B1904U6DM6A9Z0EqVs9f8850xz70u3soA04DalCzs7HD4delYhWX1 >									
	//        <  u =="0.000000000000000001" : ] 000000529085912.922383000000000000 ; 000000551931448.827089000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000327522F34A2E39 >									
	//     < RUSS_PFXXVI_II_metadata_line_30_____TRANSGAZ_TOMSK_OOO_20231101 >									
	//        < NsLYMU511476v8xcr9M7y873IzsuI44Yi0TS852k5MB3wiApXb860F08lYlrKwzx >									
	//        <  u =="0.000000000000000001" : ] 000000551931448.827089000000000000 ; 000000575690060.595997000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034A2E3936E6EEE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVI_II_metadata_line_31_____DOBYCHA_YAMBURG_20231101 >									
	//        < 6Zqf0R0pm0WZQycBsi34GcHBeTTpOap0e4FHpPTkQ7tUEEq3FT5UU3d11zNE28kd >									
	//        <  u =="0.000000000000000001" : ] 000000575690060.595997000000000000 ; 000000595126654.026952000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036E6EEE38C1759 >									
	//     < RUSS_PFXXVI_II_metadata_line_32_____YAMBURG_DAO_20231101 >									
	//        < CXqu854wexIU5ZR8241Oni2hdZRQ2XpM5k2f41lKxN14Vl25Nked32XMKOYwlj2D >									
	//        <  u =="0.000000000000000001" : ] 000000595126654.026952000000000000 ; 000000611654503.160962000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038C17593A54F8A >									
	//     < RUSS_PFXXVI_II_metadata_line_33_____YAMBURG_DAOPI_20231101 >									
	//        < BuRVjpTrYooEUwH7U05CFt7K0J375uxN27U24l6YS2FbWueDob67116tRCMWZpQ2 >									
	//        <  u =="0.000000000000000001" : ] 000000611654503.160962000000000000 ; 000000632459019.178094000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A54F8A3C50E4E >									
	//     < RUSS_PFXXVI_II_metadata_line_34_____YAMBURG_DAC_20231101 >									
	//        < n4y57Gmyd66ZWlEdDb386sbKbPGvTt3C831r2ENBkZrUASb7Z6Yr4BB4IOcKRDhh >									
	//        <  u =="0.000000000000000001" : ] 000000632459019.178094000000000000 ; 000000655049095.568018000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C50E4E3E7868E >									
	//     < RUSS_PFXXVI_II_metadata_line_35_____YAMBURG_BIMI_20231101 >									
	//        < I88p4yaYsZ89B8TMTPQ4qWw64fGX21FFDk67wZi7Bqqw5HXAUdOjDKQq5ns7XO6p >									
	//        <  u =="0.000000000000000001" : ] 000000655049095.568018000000000000 ; 000000679273789.677686000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E7868E40C7D53 >									
	//     < RUSS_PFXXVI_II_metadata_line_36_____EP_INTERNATIONAL_BV_20231101 >									
	//        < 1H979gIQQM8Fn1ll02BKb66m33p05tKf89Altd7XbX5xWWWCDp3Dxql76771C7PQ >									
	//        <  u =="0.000000000000000001" : ] 000000679273789.677686000000000000 ; 000000695758234.633372000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040C7D53425A48F >									
	//     < RUSS_PFXXVI_II_metadata_line_37_____TRANSGAZ_YUGORSK_20231101 >									
	//        < FGri4hWkTr0XXe1Ce5RSQ56s4N4J9OljTiIi333G3tSBQeq1k68xwAdcRl10BJ0S >									
	//        <  u =="0.000000000000000001" : ] 000000695758234.633372000000000000 ; 000000714900660.911152000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000425A48F442DA12 >									
	//     < RUSS_PFXXVI_II_metadata_line_38_____GAZPROM_GERMANIA_20231101 >									
	//        < kpBWjknE7E4U7H00F3V114HL2pMj7cmGMG16ZOUgyh4V9bZywwd6T4Zqi4qSuYi1 >									
	//        <  u =="0.000000000000000001" : ] 000000714900660.911152000000000000 ; 000000734524058.293910000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000442DA12460CB76 >									
	//     < RUSS_PFXXVI_II_metadata_line_39_____GAZPROMENERGO_20231101 >									
	//        < 5rP1PS7YFp981X0IlZ23860o5fgfz60F8WrTxgzTM9spM63uObx58sKl38a5z8SD >									
	//        <  u =="0.000000000000000001" : ] 000000734524058.293910000000000000 ; 000000752779715.616834000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000460CB7647CA694 >									
	//     < RUSS_PFXXVI_II_metadata_line_40_____INDUSTRIJA_SRBIJE_20231101 >									
	//        < 99AtRNS3XQXO6ftABBoJsTo80l598bjAiCAA24iPwk9YuFlk73U4Tlp99v5X1xQM >									
	//        <  u =="0.000000000000000001" : ] 000000752779715.616834000000000000 ; 000000769120423.719425000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000047CA69449595AA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}