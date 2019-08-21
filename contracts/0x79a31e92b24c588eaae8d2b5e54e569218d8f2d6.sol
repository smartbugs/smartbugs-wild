pragma solidity 		^0.4.21	;						
										
	contract	ASFGGGGN_1_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	ASFGGGGN_1_883		"	;
		string	public		symbol =	"	ASFGGGGN_1_1MTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		668342310604717000000000000					;	
										
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
	//     < ASFGGGGN_1_metadata_line_1_____AEROFLOT_ABC_Y8,65 >									
	//        < 5DA7kamqbrOF690pzrrFPip9zJ2442EGDmlM9j3CL6oW3exMHpmE3aTJvAynX077 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000017027272.786027500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000019FB47 >									
	//     < ASFGGGGN_1_metadata_line_2_____AEROFLOT_RO_Y3K1.00 >									
	//        < 8pcf3I26p1vv91M1633ue3y3G796R34NRVkFSF9GCj4Ox6tVm2Og2n8R8775oPEe >									
	//        <  u =="0.000000000000000001" : ] 000000017027272.786027500000000000 ; 000000028285649.994297500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000019FB472B2915 >									
	//     < ASFGGGGN_1_metadata_line_3_____AEROFLOT_RO_Y3K0.90 >									
	//        < MurCvi9Ah7oQSdE2c2LeXlgJwk3jhf8H4g9PSe8r8N166m014Q9RzHFaY3APJtE2 >									
	//        <  u =="0.000000000000000001" : ] 000000028285649.994297500000000000 ; 000000039769536.734777500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002B29153CAEFA >									
	//     < ASFGGGGN_1_metadata_line_4_____AEROFLOT_RO_Y7K1.00 >									
	//        < ZOtw2r3uKjQ1je17U4212Q53gt58dvAm3WEU1oM4HF1nUeB9bESuQU68p9CVTh61 >									
	//        <  u =="0.000000000000000001" : ] 000000039769536.734777500000000000 ; 000000054191316.539385100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003CAEFA52B07C >									
	//     < ASFGGGGN_1_metadata_line_5_____AEROFLOT_RO_Y7K0.90 >									
	//        < Po34UKRs7UR6BxQQUHLdtRg5xH3wQ2Q63p0sO63CSEU6W5mJHTzour9C4Vnq4eLf >									
	//        <  u =="0.000000000000000001" : ] 000000054191316.539385100000000000 ; 000000069317213.787936200000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000052B07C69C509 >									
	//     < ASFGGGGN_1_metadata_line_6_____SEVERSTAL_ABC_Y8,65 >									
	//        < MnLdemxFhfk4i3Rq5F6pZ4Di705HZgPk8EDBj8mnBfT8Jvjxt9rP54aT686ow1BC >									
	//        <  u =="0.000000000000000001" : ] 000000069317213.787936200000000000 ; 000000085209920.531197600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000069C509820520 >									
	//     < ASFGGGGN_1_metadata_line_7_____SEVERSTAL_RO_Y3K1.00 >									
	//        < 4WGa0DUcTX6h0B0vhqZ7KsMliBbFYRqW7wOzC9KcpfM9yRa0DwJV3Yt2rK16qD24 >									
	//        <  u =="0.000000000000000001" : ] 000000085209920.531197600000000000 ; 000000096413194.455757600000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000820520931D67 >									
	//     < ASFGGGGN_1_metadata_line_8_____SEVERSTAL_RO_Y3K0.90 >									
	//        < 9h1r5mTJE430e67Mjg80hdilm33lsP98eBE0574vEP13ZH25RjKOndbk609OiGyw >									
	//        <  u =="0.000000000000000001" : ] 000000096413194.455757600000000000 ; 000000107788856.800948000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000931D67A47906 >									
	//     < ASFGGGGN_1_metadata_line_9_____SEVERSTAL_RO_Y7K1.00 >									
	//        < Pt8KvetaFWTat9i9NWap6R36UC8GDAm5i4PYOkJgx1HEjCC2Fx31uZP8DdCd8Mlz >									
	//        <  u =="0.000000000000000001" : ] 000000107788856.800948000000000000 ; 000000121766321.926772000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A47906B9CCF8 >									
	//     < ASFGGGGN_1_metadata_line_10_____SEVERSTAL_RO_Y7K0.90 >									
	//        < IxciVZhr0PWf627ceCZ8k7HCu5G21J0zQLkkT5nqTA2308fMTOL5H4a029v2Y4Qs >									
	//        <  u =="0.000000000000000001" : ] 000000121766321.926772000000000000 ; 000000136546346.036053000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B9CCF8D05A6B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < ASFGGGGN_1_metadata_line_11_____FEDERAL_GRID_ABC_Y8,65 >									
	//        < 9Uzkb2H0p07OB2ZywlS6wj9wC7o4MXqtf2Ol81If9U1MX2VoMqeG66b30w5DO0eG >									
	//        <  u =="0.000000000000000001" : ] 000000136546346.036053000000000000 ; 000000156256214.062058000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D05A6BEE6D95 >									
	//     < ASFGGGGN_1_metadata_line_12_____FEDERAL_GRID_RO_Y3K1.00 >									
	//        < 8p7lVGVUujLXB32GgFFu705xAqGyic0o7k6xt9O2yiaw6qOvTtV3FXMNG71HV87l >									
	//        <  u =="0.000000000000000001" : ] 000000156256214.062058000000000000 ; 000000167641686.770938000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000EE6D95FFCD09 >									
	//     < ASFGGGGN_1_metadata_line_13_____FEDERAL_GRID_RO_Y3K0.90 >									
	//        < gqHhCqEohroSxL7GdFJ8UcCJt7t2uY7m20Itq1aZ235u7ug7LekupPp5JIjQIBcR >									
	//        <  u =="0.000000000000000001" : ] 000000167641686.770938000000000000 ; 000000179374086.144168000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FFCD09111B401 >									
	//     < ASFGGGGN_1_metadata_line_14_____FEDERAL_GRID_RO_Y7K1.00 >									
	//        < vC8jNP1UJUTT5Q34J7Snk4640ZNEY7VKMX3WKUmKz5WKe1f8hFtWMzd32jp0e2Rl >									
	//        <  u =="0.000000000000000001" : ] 000000179374086.144168000000000000 ; 000000194883335.496551000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000111B4011295E4E >									
	//     < ASFGGGGN_1_metadata_line_15_____FEDERAL_GRID_RO_Y7K0.90 >									
	//        < J6jCKdB5Tm97Sw2Y1792gSyGAyFBri3H4exhBceaZDZlkhSinebOQDfQGu1lKZ9F >									
	//        <  u =="0.000000000000000001" : ] 000000194883335.496551000000000000 ; 000000211517087.606913000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001295E4E142BFDD >									
	//     < ASFGGGGN_1_metadata_line_16_____GAZPROM_USD_ABC_Y12,85 >									
	//        < rfcbTY9b4ciY8mn1u5YFVAjI0ToCw2uH47tZlD9Y1DiJsx80oSn4Wgg6tmqmA170 >									
	//        <  u =="0.000000000000000001" : ] 000000211517087.606913000000000000 ; 000000225354727.200592000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000142BFDD157DD31 >									
	//     < ASFGGGGN_1_metadata_line_17_____GAZPROM_USD_RO_Y3K1.00 >									
	//        < MPIjMwICUam73NTr890UnMTxn6m8WYi3gC6iC0GGSXaC49FM1l2r335DViv0jo2z >									
	//        <  u =="0.000000000000000001" : ] 000000225354727.200592000000000000 ; 000000236377756.570592000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000157DD31168AF10 >									
	//     < ASFGGGGN_1_metadata_line_18_____GAZPROM_USD_RO_Y3K0.90 >									
	//        < 3UqDHn1zPtbmBDIYv3tJ98fna6H0akd4nZLY0fvL24UD0gV0WLi80VfNpUxag2wV >									
	//        <  u =="0.000000000000000001" : ] 000000236377756.570592000000000000 ; 000000247394384.646112000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000168AF101797E6E >									
	//     < ASFGGGGN_1_metadata_line_19_____GAZPROM_USD_RO_Y7K1.00 >									
	//        < qCe3957q08VCVvTx1ai2qB71HlCcc6P134qF4E67wP0a1b4Vj37O2dnMy5kb0A5P >									
	//        <  u =="0.000000000000000001" : ] 000000247394384.646112000000000000 ; 000000260117177.273778000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001797E6E18CE846 >									
	//     < ASFGGGGN_1_metadata_line_20_____GAZPROM_USD_RO_Y7K0.90 >									
	//        < 2pKCjPA09dm2t208q0w50P3UhgRe751sHlSPr1ms31gdy614ZQj2n4Y2139peU3V >									
	//        <  u =="0.000000000000000001" : ] 000000260117177.273778000000000000 ; 000000272900325.763209000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018CE8461A069B1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < ASFGGGGN_1_metadata_line_21_____GAZPROM_USD_ABC_Y5 >									
	//        < Y149H067tA44X4YIDlPpUG5hxJ5g7JxTw823An7tpFqKSgEF56WNJAZtcKqe11OZ >									
	//        <  u =="0.000000000000000001" : ] 000000272900325.763209000000000000 ; 000000285300257.478259000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A069B11B3556A >									
	//     < ASFGGGGN_1_metadata_line_22_____GAZPROM_USD_RO_Y3K1.00 >									
	//        < kzbR11cdx84DQf2K51w497164Jfa7Gz9edv1Fo55w60f1CUhGmyG03JU4C6dLDg7 >									
	//        <  u =="0.000000000000000001" : ] 000000285300257.478259000000000000 ; 000000296432488.563699000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B3556A1C451F1 >									
	//     < ASFGGGGN_1_metadata_line_23_____GAZPROM_USD_RO_Y3K0.90 >									
	//        < 4t41Uuj0MGgUDuOY46NF3i8I9My3B61FMPiSTvzsY6uGMXMVWEzLI869AtasKvm6 >									
	//        <  u =="0.000000000000000001" : ] 000000296432488.563699000000000000 ; 000000307668154.355059000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C451F11D576DF >									
	//     < ASFGGGGN_1_metadata_line_24_____GAZPROM_USD_RO_Y7K1.00 >									
	//        < z66TYr1Lv5CxWB5Hyr6MwvuU9KrmEE8zn64cf6B5yzXSI01l2viC1rIV59N4SEr1 >									
	//        <  u =="0.000000000000000001" : ] 000000307668154.355059000000000000 ; 000000321131587.766162000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D576DF1EA0207 >									
	//     < ASFGGGGN_1_metadata_line_25_____GAZPROM_USD_RO_Y7K0.90 >									
	//        < 843lJ0k3MZo1892P03q45ZvFc5tFH1R204dc3YX25l3scx9lXBiC05QDxYW1QICq >									
	//        <  u =="0.000000000000000001" : ] 000000321131587.766162000000000000 ; 000000334932796.271411000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EA02071FF1120 >									
	//     < ASFGGGGN_1_metadata_line_26_____GAZPROM_ABC_Y8,65 >									
	//        < K8TQ5qNC1I99N6hKY5wQC3u1uU0qW363os0GJNO0JR02Yz5OfRo46L0O0HAtSBFR >									
	//        <  u =="0.000000000000000001" : ] 000000334932796.271411000000000000 ; 000000347123227.781412000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FF1120211AB03 >									
	//     < ASFGGGGN_1_metadata_line_27_____GAZPROM_RO_Y3K1.00 >									
	//        < AfCHfP7Ei08AK7k8UCUR2aio80t99v6o0mJkBb7vH9Z05kPSXwxYb2S3l2QaWr99 >									
	//        <  u =="0.000000000000000001" : ] 000000347123227.781412000000000000 ; 000000358130258.562662000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000211AB0322276A2 >									
	//     < ASFGGGGN_1_metadata_line_28_____GAZPROM_RO_Y3K0.90 >									
	//        < xf2YQ7j9tfW426Fi9K2NhQvmQ6544BUP4fKn9K5Pjh0E62Fk0VWX4c6p3rqnGJ2c >									
	//        <  u =="0.000000000000000001" : ] 000000358130258.562662000000000000 ; 000000369121306.242662000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022276A22333C03 >									
	//     < ASFGGGGN_1_metadata_line_29_____GAZPROM_RO_Y7K1.00 >									
	//        < L7vvk91522u2pIV9QSC8Siz00l1vM8Jko30m5TOpYeuQbgVGb66q2C48n3vno8FL >									
	//        <  u =="0.000000000000000001" : ] 000000369121306.242662000000000000 ; 000000381758300.010363000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002333C032468456 >									
	//     < ASFGGGGN_1_metadata_line_30_____GAZPROM_RO_Y7K0.90 >									
	//        < d522FInxN4eh13x05Gie7xHB4KyPih7r4h5vrxwxnYDS2BJie5gGRWLL0CvnaRbq >									
	//        <  u =="0.000000000000000001" : ] 000000381758300.010363000000000000 ; 000000394420981.202291000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002468456259D6B2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < ASFGGGGN_1_metadata_line_31_____GAZPROM_ABC_Y5 >									
	//        < u6QgeUOxZ4aC7uVsW9PF1QeH4Ai438iwah09NLA9HR1Qei8KrtePJpC0W1pF8u48 >									
	//        <  u =="0.000000000000000001" : ] 000000394420981.202291000000000000 ; 000000404779978.026586000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000259D6B2269A52E >									
	//     < ASFGGGGN_1_metadata_line_32_____GAZPROM_RO_Y3K1.00 >									
	//        < kbm7aXzhX8uN3BvR3i5zzli17IvM1hd4H1aN1UnlDGEj5iO1PlGG59nqstrKa5gk >									
	//        <  u =="0.000000000000000001" : ] 000000404779978.026586000000000000 ; 000000415697702.707316000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000269A52E27A4DEA >									
	//     < ASFGGGGN_1_metadata_line_33_____GAZPROM_RO_Y3K0.90 >									
	//        < kflXIKHr3ezeQOC0Qh8h103i869Hjf12414pl0JflT5Xr5La8cdLp5oou09EU6i3 >									
	//        <  u =="0.000000000000000001" : ] 000000415697702.707316000000000000 ; 000000426510795.504756000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027A4DEA28ACDC8 >									
	//     < ASFGGGGN_1_metadata_line_34_____GAZPROM_RO_Y7K1.00 >									
	//        < CFJ29T3YiI9h65rn80U65vwK3wRs74nS9k2f09J4D06hCxH9T7tY3b40281od0Vn >									
	//        <  u =="0.000000000000000001" : ] 000000426510795.504756000000000000 ; 000000438635078.434396000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028ACDC829D4DD4 >									
	//     < ASFGGGGN_1_metadata_line_35_____GAZPROM_RO_Y7K0.90 >									
	//        < D4fj26CJ4mvztAQ0C4eT4LYcqns33qof3BD4zm42iDc5601fQHrv77p5mkE4PpkF >									
	//        <  u =="0.000000000000000001" : ] 000000438635078.434396000000000000 ; 000000450578877.503079000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029D4DD42AF8760 >									
	//     < ASFGGGGN_1_metadata_line_36_____NORILSK_NICKEL_USD_ABC_Y14 >									
	//        < Zu5L30S96RccgY4V6xX44uE5fVRy9fOA1pjm5sA81KeJb7wU758G49y8MOCB964g >									
	//        <  u =="0.000000000000000001" : ] 000000450578877.503079000000000000 ; 000000576780354.185417000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AF876037018D3 >									
	//     < ASFGGGGN_1_metadata_line_37_____NORILSK_NICKEL_USD_RO_Y3K1.00 >									
	//        < 01a15aM955cs6iY9dJRYR4496LARp5tI11mk6XwmfQ0bE67JuS24Pb3KwVqz5z5B >									
	//        <  u =="0.000000000000000001" : ] 000000576780354.185417000000000000 ; 000000589175608.570297000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037018D338302B9 >									
	//     < ASFGGGGN_1_metadata_line_38_____NORILSK_NICKEL_USD_RO_Y3K0.90 >									
	//        < nWVzkO1JtC82moMC3mFeT1f9BDZ4gDx510aEnid40k0GJcQHwE190EZvUngZU9Y5 >									
	//        <  u =="0.000000000000000001" : ] 000000589175608.570297000000000000 ; 000000602892618.176607000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038302B9397F0EE >									
	//     < ASFGGGGN_1_metadata_line_39_____NORILSK_NICKEL_USD_RO_Y7K1.00 >									
	//        < w3vdrSk1fNt5dEE1EbbISfcjIa0lUJynB207091GF73E16EEj4p8QM2jetu4IA07 >									
	//        <  u =="0.000000000000000001" : ] 000000602892618.176607000000000000 ; 000000632405862.437160000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000397F0EE3C4F98A >									
	//     < ASFGGGGN_1_metadata_line_40_____NORILSK_NICKEL_USD_RO_Y7K0.90 >									
	//        < 5FCjQ03h7j69dWZ85DCmJZCwlZct1EC7Ih9AuDhWxY111AcuVn5oBta5w499J1aw >									
	//        <  u =="0.000000000000000001" : ] 000000632405862.437160000000000000 ; 000000668342310.604717000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C4F98A3FBCF37 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}