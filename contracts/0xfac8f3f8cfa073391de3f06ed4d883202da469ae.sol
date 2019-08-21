pragma solidity 		^0.4.21	;						
										
	contract	NDD_SPO_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDD_SPO_I_883		"	;
		string	public		symbol =	"	NDD_SPO_I_1subDT		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		834558056880399000000000000					;	
										
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
	//     < NDD_SPO_I_metadata_line_1_____6938413225 Lab_x >									
	//        < bFiO873f158H6CfCFM66px2M3opy7UO5Tgjj6TOoEjd1YCTJ7CF01EjMaJMq20Kk >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000000F4240 >									
	//     < NDD_SPO_I_metadata_line_2_____9781285179 Lab_y >									
	//        < waRtQfN5g3HR9q2U5OdhAhRyTBils0V7KlZgupbK9eMg3lfyZp5SACzY55F0F0q6 >									
	//        <  u =="0.000000000000000001" : ] 000000010000000.000000000000000000 ; 000000020000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000F42401E8480 >									
	//     < NDD_SPO_I_metadata_line_3_____2306547830 Lab_100 >									
	//        < FIebipp526K5s5rnN3q2186q33yeMup66689hMZvY7ide2fEYJ5cCP9T7DMan1gT >									
	//        <  u =="0.000000000000000001" : ] 000000020000000.000000000000000000 ; 000000030652185.699308700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001E84802EC583 >									
	//     < NDD_SPO_I_metadata_line_4_____2399093542 Lab_110 >									
	//        < 4DDS9Xp3Cf56zvNBx6F8R76c2q0w7D44lGGZ8DOgfI003qq4p4a9518SOLacJgJV >									
	//        <  u =="0.000000000000000001" : ] 000000030652185.699308700000000000 ; 000000041555364.853395900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002EC5833F6890 >									
	//     < NDD_SPO_I_metadata_line_5_____2384962416 Lab_410/401 >									
	//        < mZp4y07R7Y58c2m0ClJO2LUJ6YhxCJkL6o1VF75DrhNq2fc534U15r8i6oq71Y33 >									
	//        <  u =="0.000000000000000001" : ] 000000041555364.853395900000000000 ; 000000055168081.469744600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003F6890542E08 >									
	//     < NDD_SPO_I_metadata_line_6_____2313733334 Lab_810/801 >									
	//        < rSizBF959tcsDz2Dz4Ug85xV4mnoxKXWnRZDrXBJ6j6nULYbww6WHzgZXHbCWpqC >									
	//        <  u =="0.000000000000000001" : ] 000000055168081.469744600000000000 ; 000000072393514.702442100000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000542E086E76B7 >									
	//     < NDD_SPO_I_metadata_line_7_____2384962416 Lab_410_3Y1Y >									
	//        < wASG5y5v2PP9967v2A76T38W1F3gh5sx8t7975SX1RJ2337eIF5tl5Uo9Ho0C32a >									
	//        <  u =="0.000000000000000001" : ] 000000072393514.702442100000000000 ; 000000097618702.662433600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006E76B794F44E >									
	//     < NDD_SPO_I_metadata_line_8_____2313733334 Lab_410_5Y1Y >									
	//        < Bh2w3pi6M9n2ASUfG2lrc09d0LQ03A8q7b90hZUdTr4G87hm2XFSU5A1uaK62s27 >									
	//        <  u =="0.000000000000000001" : ] 000000097618702.662433600000000000 ; 000000107618702.662434000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000094F44EA4368E >									
	//     < NDD_SPO_I_metadata_line_9_____2323232323 Lab_410_7Y1Y >									
	//        < Mz48oSGX511hNr0jZX5a3Ewn5zb6EWxY3Pzj3teVFjEDney7xtJVq21ygGptXBhK >									
	//        <  u =="0.000000000000000001" : ] 000000107618702.662434000000000000 ; 000000117618702.662434000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A4368EB378CE >									
	//     < NDD_SPO_I_metadata_line_10_____2323232323 Lab_810_3Y1Y >									
	//        < 71WBIkSO20cox26jj711S39F6d9cPpJi00Nc6deGfG0W839ItFgK4FUt3le26bvW >									
	//        <  u =="0.000000000000000001" : ] 000000117618702.662434000000000000 ; 000000168729241.628037000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000B378CE10175DC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_SPO_I_metadata_line_11_____2371675399 Lab_810_5Y1Y >									
	//        < 4W8Mv80Fdi3wSQ7TinvdzLKwOrMUB3269INu17G3X2AGcL7w2Qttv34dXl6V37z3 >									
	//        <  u =="0.000000000000000001" : ] 000000168729241.628037000000000000 ; 000000178729241.628037000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010175DC110B81C >									
	//     < NDD_SPO_I_metadata_line_12_____2308759869 Lab_810_7Y1Y >									
	//        < 412lvb6jV7f3sxvS0nZgWHEGUR85KS1zzct9346lbSjonyvJFGHEdBsMXfOe2z9y >									
	//        <  u =="0.000000000000000001" : ] 000000178729241.628037000000000000 ; 000000188729241.628037000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000110B81C11FFA5C >									
	//     < NDD_SPO_I_metadata_line_13_____2323232323 ro_Lab_110_3Y_1.00 >									
	//        < 0CJY6fnrHo2pf3TB2wm32S09LNfJgV8753N22CfX5d1UN39505a146inN8X6L2Ef >									
	//        <  u =="0.000000000000000001" : ] 000000188729241.628037000000000000 ; 000000209366019.604903000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011FFA5C13F779A >									
	//     < NDD_SPO_I_metadata_line_14_____2323232323 ro_Lab_110_5Y_1.00 >									
	//        < ZW8Hn7Sc74kc5f0cQRaW9hC7fG5Kek0EY6glCnB9UdoUmuIdc53FMc1OZD3U21Q4 >									
	//        <  u =="0.000000000000000001" : ] 000000209366019.604903000000000000 ; 000000219366019.604903000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013F779A14EB9DA >									
	//     < NDD_SPO_I_metadata_line_15_____2323232323 ro_Lab_110_5Y_1.10 >									
	//        < 5ZI9fr47rUJ75r6ltIx5C04HgHKDccC250dYWtDQ3CJ7nwdzM9aw0KwELZEj6fzY >									
	//        <  u =="0.000000000000000001" : ] 000000219366019.604903000000000000 ; 000000229366019.604903000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014EB9DA15DFC1A >									
	//     < NDD_SPO_I_metadata_line_16_____2323232323 ro_Lab_110_7Y_1.00 >									
	//        < hIzGB85siXay2bCqk7a31Rr9Ip4yaOtEWr4987n81nkjr9PtnTG2M6OS30M9fWPx >									
	//        <  u =="0.000000000000000001" : ] 000000229366019.604903000000000000 ; 000000239366019.604903000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015DFC1A16D3E5A >									
	//     < NDD_SPO_I_metadata_line_17_____2323232323 ro_Lab_210_3Y_1.00 >									
	//        < R5241mKb0W0m7swzo32JTaxVEy7g5FSq6cf0qjq7JZew4PuhoDWkIuUBc63L5t44 >									
	//        <  u =="0.000000000000000001" : ] 000000239366019.604903000000000000 ; 000000250689790.708465000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016D3E5A17E85B3 >									
	//     < NDD_SPO_I_metadata_line_18_____2323232323 ro_Lab_210_5Y_1.00 >									
	//        < Tu19771kpySN1933HRH2v5ZG4hTYbifPwuQk602A5d2E0EInMLKCb4yZ1zA8FW1G >									
	//        <  u =="0.000000000000000001" : ] 000000250689790.708465000000000000 ; 000000260689790.708465000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017E85B318DC7F3 >									
	//     < NDD_SPO_I_metadata_line_19_____2323232323 ro_Lab_210_5Y_1.10 >									
	//        < shPZ3kLgACb5S3Zg33k74whQAkj3bmU6v0ftY2egBUijsP3yywDK4qsg8eokKJtl >									
	//        <  u =="0.000000000000000001" : ] 000000260689790.708465000000000000 ; 000000270689790.708465000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018DC7F319D0A33 >									
	//     < NDD_SPO_I_metadata_line_20_____2323232323 ro_Lab_210_7Y_1.00 >									
	//        < 23n7A1swZ5n3D9V23O6zv4PD50pJb8FP8pPhF464vknAfSdUxHVCfdXURCPaMjYL >									
	//        <  u =="0.000000000000000001" : ] 000000270689790.708465000000000000 ; 000000280689790.708465000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019D0A331AC4C73 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_SPO_I_metadata_line_21_____2307766069 ro_Lab_310_3Y_1.00 >									
	//        < Pait6Yc67l4NDeuE81zv8yxwDhLb5RV0mEkIXHYJBnDZI1N8J8B2w4ab0Apm2y4s >									
	//        <  u =="0.000000000000000001" : ] 000000280689790.708465000000000000 ; 000000292340363.060171000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AC4C731BE1374 >									
	//     < NDD_SPO_I_metadata_line_22_____2306855487 ro_Lab_310_5Y_1.00 >									
	//        < 3pu68wNXt8s9ld33RS3L52sa1VH9zS5F33WRNPCZtx46h997EKg2W3JG7HwCRM5g >									
	//        <  u =="0.000000000000000001" : ] 000000292340363.060171000000000000 ; 000000302340363.060171000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BE13741CD55B4 >									
	//     < NDD_SPO_I_metadata_line_23_____2396967878 ro_Lab_310_5Y_1.10 >									
	//        < PCmAx6FaQEQUZ5QFnE6hnTZiE2m2O9G6PEEK7NaRy9OwFbkBT9m9h0isGb040IX8 >									
	//        <  u =="0.000000000000000001" : ] 000000302340363.060171000000000000 ; 000000312340363.060171000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CD55B41DC97F4 >									
	//     < NDD_SPO_I_metadata_line_24_____2323232323 ro_Lab_310_7Y_1.00 >									
	//        < 9bi7JvrZXJWm5W154bz489dap1FMN48NXq6c602XD2h0Bg9g5hr4l0Nk0hn0blj7 >									
	//        <  u =="0.000000000000000001" : ] 000000312340363.060171000000000000 ; 000000322340363.060171000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DC97F41EBDA34 >									
	//     < NDD_SPO_I_metadata_line_25_____2323232323 ro_Lab_410_3Y_1.00 >									
	//        < tSp0MG4EHKogNQ1TvG2B21yuxpOoQUav55ZlMoXlopxD0Y7O76vov3IjYluQW0m8 >									
	//        <  u =="0.000000000000000001" : ] 000000322340363.060171000000000000 ; 000000334367269.152105000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EBDA341FE3437 >									
	//     < NDD_SPO_I_metadata_line_26_____2323232323 ro_Lab_410_5Y_1.00 >									
	//        < eJOlv2z1v2Q3JMWOy52OWLg83rRJ1xk5E9pU843lPxRZ09r03P097IM2GqnXbk7j >									
	//        <  u =="0.000000000000000001" : ] 000000334367269.152105000000000000 ; 000000344367269.152105000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FE343720D7677 >									
	//     < NDD_SPO_I_metadata_line_27_____2323232323 ro_Lab_410_5Y_1.10 >									
	//        < qrI6hOuCM4z6QEENMfdY6H4Mj15lq9TsR55ZooF2BVK1BC6b42l1SQK5Ss6Y7MFG >									
	//        <  u =="0.000000000000000001" : ] 000000344367269.152105000000000000 ; 000000354367269.152105000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020D767721CB8B7 >									
	//     < NDD_SPO_I_metadata_line_28_____2323232323 ro_Lab_410_7Y_1.00 >									
	//        < t3hPD1qzPrNA73ARk975j5Tw63Jj3FUB8298kv8Y5wHxX2ddBFc6zaE7t8UJ5UXx >									
	//        <  u =="0.000000000000000001" : ] 000000354367269.152105000000000000 ; 000000364367269.152105000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021CB8B722BFAF7 >									
	//     < NDD_SPO_I_metadata_line_29_____2323232323 ro_Lab_810_3Y_1.00 >									
	//        < KOyOxhZRPJNoDT2hg1U516344918igHop7Zr0gP637Qri0pURu6J1C6Fdm080Ue1 >									
	//        <  u =="0.000000000000000001" : ] 000000364367269.152105000000000000 ; 000000378462441.841305000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022BFAF72417CE4 >									
	//     < NDD_SPO_I_metadata_line_30_____2323232323 ro_Lab_810_5Y_1.00 >									
	//        < f48m6Aq42tTPyEyWoRmHK4joM9G7zBemWMzIxKId04Lx9Z3EWY11Ve141wz0u7A6 >									
	//        <  u =="0.000000000000000001" : ] 000000378462441.841305000000000000 ; 000000388462441.841305000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002417CE4250BF24 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_SPO_I_metadata_line_31_____2306670051 ro_Lab_810_5Y_1.10 >									
	//        < 53vi8zm77ApD30trk6327DVy8WU5m532Fj829wO07hQp0Hd19Us54dQF8jhzj8Fw >									
	//        <  u =="0.000000000000000001" : ] 000000388462441.841305000000000000 ; 000000398462441.841305000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000250BF242600164 >									
	//     < NDD_SPO_I_metadata_line_32_____2389892087 ro_Lab_810_7Y_1.00 >									
	//        < i24MNikNGd08WPQ6w8TC5d1W15kBJ6r8eN60xx6THPaTs31qSpxK4764ovS90870 >									
	//        <  u =="0.000000000000000001" : ] 000000398462441.841305000000000000 ; 000000408462441.841305000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000260016426F43A4 >									
	//     < NDD_SPO_I_metadata_line_33_____2304588059 ro_Lab_411_3Y_1.00 >									
	//        < kxfgbQ2o9e1R63l9DbXnN2Vyp1wm904K0kM6Us1dX0fA2KN9Q32gbomN1rJKvt9S >									
	//        <  u =="0.000000000000000001" : ] 000000408462441.841305000000000000 ; 000000420479760.948035000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026F43A428199E8 >									
	//     < NDD_SPO_I_metadata_line_34_____2371926368 ro_Lab_411_5Y_1.00 >									
	//        < U0628Ko6OB239Y1ok86BiZtpNkI1nJiZ03NBO3PEtJKeWS4WrYVC4P95P7YavD56 >									
	//        <  u =="0.000000000000000001" : ] 000000420479760.948035000000000000 ; 000000439015349.727004000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028199E829DE25F >									
	//     < NDD_SPO_I_metadata_line_35_____2396299901 ro_Lab_411_5Y_1.10 >									
	//        < 518BWn3wlij8a0sOiHa043ihrv3M8R9V2hA1Os08O78U64e211GG0nFkYt48UaIG >									
	//        <  u =="0.000000000000000001" : ] 000000439015349.727004000000000000 ; 000000454031032.748457000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029DE25F2B4CBDF >									
	//     < NDD_SPO_I_metadata_line_36_____2365715313 ro_Lab_411_7Y_1.00 >									
	//        < x38r3AeDgCJG8a0Z5r1BbudTga477Quzvy3w6rHBNx15SG8RlZgSnRLXd42KLX95 >									
	//        <  u =="0.000000000000000001" : ] 000000454031032.748457000000000000 ; 000000509603266.116463000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B4CBDF30997C7 >									
	//     < NDD_SPO_I_metadata_line_37_____2376254770 ro_Lab_811_3Y_1.00 >									
	//        < SQHx8D20Sq5xbnp3UHj1l7gUia61503rbq0uOw9dw7UtCHrIJ7uHAQWM9724RJ9J >									
	//        <  u =="0.000000000000000001" : ] 000000509603266.116463000000000000 ; 000000523956126.934616000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030997C731F7E5D >									
	//     < NDD_SPO_I_metadata_line_38_____2322757456 ro_Lab_811_5Y_1.00 >									
	//        < bxRBy8q3VBUHu8z020556LstXjm70an2k9K9aI5v29v44neDMzLvoQ7h5IvxdD43 >									
	//        <  u =="0.000000000000000001" : ] 000000523956126.934616000000000000 ; 000000569255657.397456000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031F7E5D3649D7E >									
	//     < NDD_SPO_I_metadata_line_39_____2323232323 ro_Lab_811_5Y_1.10 >									
	//        < q1PniMG8Owd2e06qkWa2Etp02Ag41V1B6y1YdCX3C62LVJP58E87ys4gEW0mgax8 >									
	//        <  u =="0.000000000000000001" : ] 000000569255657.397456000000000000 ; 000000596986036.804429000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003649D7E38EEDAC >									
	//     < NDD_SPO_I_metadata_line_40_____2323232323 ro_Lab_811_7Y_1.00 >									
	//        < 3R9w54g5DrHX66Uwsq27M9RP4UDL94BC013Az533FYxyQ006URW30Wf9ZJSUw34Q >									
	//        <  u =="0.000000000000000001" : ] 000000596986036.804429000000000000 ; 000000834558056.880399000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038EEDAC4F96F3E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}