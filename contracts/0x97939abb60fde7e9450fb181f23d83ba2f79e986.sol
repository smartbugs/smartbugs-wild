pragma solidity 		^0.4.21	;						
										
	contract	NDD_WEW_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDD_WEW_I_883		"	;
		string	public		symbol =	"	NDD_WEW_I_1subDT		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		11239081973726600000000000000					;	
										
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
	//     < NDD_WEW_I_metadata_line_1_____6938413225 Lab_x >									
	//        < NUx261K29Dex330s72teRw0oZnMOXd7VWnP938M1m389o50jura283M8yBSM8pU2 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000000F4240 >									
	//     < NDD_WEW_I_metadata_line_2_____9781285179 Lab_y >									
	//        < 90JL7g9Oa9zy8IA700a39pyi83LiOhP9a8TjwSfu44B6gwQ3RTu8BLf0eb43b4HQ >									
	//        <  u =="0.000000000000000001" : ] 000000010000000.000000000000000000 ; 000000020000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000F42401E8480 >									
	//     < NDD_WEW_I_metadata_line_3_____2306252680 Lab_100 >									
	//        < 88f76sAfq6gqz7b01dVUTr47f9w8JqmXvZr7RSF25b81LAvFSe1D4pk9aM7pyvq3 >									
	//        <  u =="0.000000000000000001" : ] 000000020000000.000000000000000000 ; 000000030662969.891202800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001E84802EC9B9 >									
	//     < NDD_WEW_I_metadata_line_4_____2336571274 Lab_110 >									
	//        < 1uh0t0Hg9PLxaV8ugT90DpWfx1AR1DYpa7cUS03PSovsrx4F82I118zI36Br27t2 >									
	//        <  u =="0.000000000000000001" : ] 000000030662969.891202800000000000 ; 000000042211702.367640700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002EC9B94068F2 >									
	//     < NDD_WEW_I_metadata_line_5_____2320274137 Lab_410/401 >									
	//        < 73VFz6YQNGbfOdh5QS831iif471Du68P128IqG6Bnl4M5nwItY52vq3w95893Wfy >									
	//        <  u =="0.000000000000000001" : ] 000000042211702.367640700000000000 ; 000000058406632.273392200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004068F2591F17 >									
	//     < NDD_WEW_I_metadata_line_6_____1175814680 Lab_810/801 >									
	//        < 2mOR8r2Ag72u33hI231p0uV9i4CZMAGK1QZW50F9G3ggRj9RF19w92qD48fP5ho0 >									
	//        <  u =="0.000000000000000001" : ] 000000058406632.273392200000000000 ; 000000080796492.084895300000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000591F177B4921 >									
	//     < NDD_WEW_I_metadata_line_7_____2363583509 Lab_410_3Y1Y >									
	//        < aA9U54DGpFmQV7GF407lf26iH5dI94d1VyQ8323E0yg1uFBE5b0p6D8YvnfOoz3e >									
	//        <  u =="0.000000000000000001" : ] 000000080796492.084895300000000000 ; 000000107921189.188011000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007B4921A4ACB7 >									
	//     < NDD_WEW_I_metadata_line_8_____2331049501 Lab_410_5Y1Y >									
	//        < M23ZLAi7N74c8WV9mLDHSTaw5vlG2aB1m4157X3mL144QhrVkkYvBG0YNNc4kyX1 >									
	//        <  u =="0.000000000000000001" : ] 000000107921189.188011000000000000 ; 000000176753090.919955000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000A4ACB710DB42D >									
	//     < NDD_WEW_I_metadata_line_9_____2351933300 Lab_410_7Y1Y >									
	//        < 4H27pQ7p7onBSbo5nQy094428m8xA883B1hQ4nUIl1El5nlVLclul82f5O2197H4 >									
	//        <  u =="0.000000000000000001" : ] 000000176753090.919955000000000000 ; 000000399125892.171671000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010DB42D261048D >									
	//     < NDD_WEW_I_metadata_line_10_____2388072079 Lab_810_3Y1Y >									
	//        < iQZOQ4bGuJUbVKtLjVxZQ86PUP1UvPMFT3Vywqh8T3d426A8W14h11TaZH2m7YY5 >									
	//        <  u =="0.000000000000000001" : ] 000000399125892.171671000000000000 ; 000000455576769.142203000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000261048D2B727AD >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_WEW_I_metadata_line_11_____2342784015 Lab_810_5Y1Y >									
	//        < gOxFMf63K2K9u62Z6sl3QhIOFCX28SujnDqT4HZ9wVdGCt3445sz44fs28r56BSc >									
	//        <  u =="0.000000000000000001" : ] 000000455576769.142203000000000000 ; 000000711034288.352475000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B727AD43CF3C5 >									
	//     < NDD_WEW_I_metadata_line_12_____1123658818 Lab_810_7Y1Y >									
	//        < Y81WXp0E1m404V1l4k6GPAG1vr209ri34Efo0h7W09p4292L5w9paq51a67s64OT >									
	//        <  u =="0.000000000000000001" : ] 000000711034288.352475000000000000 ; 000002007152934.873270000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000043CF3C5BF6AC1D >									
	//     < NDD_WEW_I_metadata_line_13_____2371506186 ro_Lab_110_3Y_1.00 >									
	//        < 8O83w281u5v0FJVom7dJ9041WGycl1i6C7RtEDGuj3jhA2sWp5Qwfi1vd562ZE23 >									
	//        <  u =="0.000000000000000001" : ] 000002007152934.873270000000000000 ; 000002028033224.273900000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000BF6AC1DC16887A >									
	//     < NDD_WEW_I_metadata_line_14_____2377906350 ro_Lab_110_5Y_1.00 >									
	//        < jnZ4T2rT49E6eBmkn5nDZN2zH82bIHFMdihRyipp6t175IUfTT5AA60wR628wPD1 >									
	//        <  u =="0.000000000000000001" : ] 000002028033224.273900000000000000 ; 000002053750590.237330000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000C16887AC3DC653 >									
	//     < NDD_WEW_I_metadata_line_15_____2386006673 ro_Lab_110_5Y_1.10 >									
	//        < n7qu2u4Hi2PoyhmZqRlJ5GhG6j4p3N6j598DQD1g6kc817W11YvljongmbANyTH5 >									
	//        <  u =="0.000000000000000001" : ] 000002053750590.237330000000000000 ; 000002080439682.376580000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000C3DC653C667FC0 >									
	//     < NDD_WEW_I_metadata_line_16_____2378825292 ro_Lab_110_7Y_1.00 >									
	//        < d1y4oq9TkQ0nxocdh3Lx6d5FW0Cs1mJVySRD5Y0ARPh7AAr2Juv1B5VR0uY3rjPX >									
	//        <  u =="0.000000000000000001" : ] 000002080439682.376580000000000000 ; 000002113242595.529710000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000C667FC0C988D64 >									
	//     < NDD_WEW_I_metadata_line_17_____2308625793 ro_Lab_210_3Y_1.00 >									
	//        < ux5Nc5aJMv0jT7dJ1o0u3d3lvu9UQ4NeckTC7Z50DWy8I59y6UD1Gg6Gg0pr42m2 >									
	//        <  u =="0.000000000000000001" : ] 000002113242595.529710000000000000 ; 000002124623121.783230000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000C988D64CA9EAE8 >									
	//     < NDD_WEW_I_metadata_line_18_____2305632270 ro_Lab_210_5Y_1.00 >									
	//        < Og4G3cmx1nHLalx48iLlL43NbfEg0o5qXH00hzm5210OPoX9Fn4nDZ1U2qO1ktt3 >									
	//        <  u =="0.000000000000000001" : ] 000002124623121.783230000000000000 ; 000002138909924.544380000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000CA9EAE8CBFB7B0 >									
	//     < NDD_WEW_I_metadata_line_19_____2307625218 ro_Lab_210_5Y_1.10 >									
	//        < SmHkpmCqBQLuJ394gdA3w9dqbPBalhRx5Ok92rmcn22sC88wLG46MVE6Gu2kttTs >									
	//        <  u =="0.000000000000000001" : ] 000002138909924.544380000000000000 ; 000002151921073.106910000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000CBFB7B0CD3922B >									
	//     < NDD_WEW_I_metadata_line_20_____2396706358 ro_Lab_210_7Y_1.00 >									
	//        < Z6SWRNX42P101C1qxI0lnK1DjskFVbuWJoMvPfoBS66n4x2w2J6MZQe87t7XEXxx >									
	//        <  u =="0.000000000000000001" : ] 000002151921073.106910000000000000 ; 000002174423205.324600000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000CD3922BCF5E811 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_WEW_I_metadata_line_21_____2307543560 ro_Lab_310_3Y_1.00 >									
	//        < 50SXgviNbN253AkK98ojlf9lhofwX57x4U049551K1DIb6dtGT9hIct465IG32Ha >									
	//        <  u =="0.000000000000000001" : ] 000002174423205.324600000000000000 ; 000002186172880.390900000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000CF5E811D07D5C8 >									
	//     < NDD_WEW_I_metadata_line_22_____2398473379 ro_Lab_310_5Y_1.00 >									
	//        < 8COk2v69naF17n5MAUrV1CH03DsDU4QS9BX4U8lj21YLBlH65utBJmo4pM4bA1Mv >									
	//        <  u =="0.000000000000000001" : ] 000002186172880.390900000000000000 ; 000002202905623.883600000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000D07D5C8D215E02 >									
	//     < NDD_WEW_I_metadata_line_23_____2305860657 ro_Lab_310_5Y_1.10 >									
	//        < 1V0SAfCFRh1mP0DM0yD85hvk9Jk42Ooh3UJ9tgeIbE79a84WNWp0il8mnPl15c8j >									
	//        <  u =="0.000000000000000001" : ] 000002202905623.883600000000000000 ; 000002217069744.465150000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000D215E02D36FADE >									
	//     < NDD_WEW_I_metadata_line_24_____2387494028 ro_Lab_310_7Y_1.00 >									
	//        < 715Xsaa776190mJZnubIVGfaxpIqNQeu6DGAiN9x7h64STxY1K5MJ7fo4iuB17w0 >									
	//        <  u =="0.000000000000000001" : ] 000002217069744.465150000000000000 ; 000002252546456.603560000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000D36FADED6D1CF6 >									
	//     < NDD_WEW_I_metadata_line_25_____2306903516 ro_Lab_410_3Y_1.00 >									
	//        < xCJA2hKDO34vDV7la1htA4QPe780mimniMNA7aSyUU3I51lyBQzbVNv1r9y37z1A >									
	//        <  u =="0.000000000000000001" : ] 000002252546456.603560000000000000 ; 000002264725503.709520000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000D6D1CF6D7FB266 >									
	//     < NDD_WEW_I_metadata_line_26_____2336061272 ro_Lab_410_5Y_1.00 >									
	//        < xvUw7w1PPV19eRKXABik8Jk81HhUbS42dI3UeTQQkCW8uz5RcRsbicIU9mU4U8np >									
	//        <  u =="0.000000000000000001" : ] 000002264725503.709520000000000000 ; 000002284898022.182970000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000D7FB266D9E7A4A >									
	//     < NDD_WEW_I_metadata_line_27_____2399300209 ro_Lab_410_5Y_1.10 >									
	//        < 6z0nU2AVRYre3xJW58xu79A5Ucptp6ntLh83g2Zky63c2CpB385tbC0iB5230vvx >									
	//        <  u =="0.000000000000000001" : ] 000002284898022.182970000000000000 ; 000002300687912.275030000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000D9E7A4ADB69237 >									
	//     < NDD_WEW_I_metadata_line_28_____2370018155 ro_Lab_410_7Y_1.00 >									
	//        < Rsoq1PCsDyuo25CkLF0OjYlYm779YsS2Z1YLn9KL6ldh6H97189h286iEZe6M4Ql >									
	//        <  u =="0.000000000000000001" : ] 000002300687912.275030000000000000 ; 000002359106707.141630000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000DB69237E0FB60F >									
	//     < NDD_WEW_I_metadata_line_29_____2389752893 ro_Lab_810_3Y_1.00 >									
	//        < 3HsE977k19GlP24GBE4w89I5lmKw2oBtfY9ePV87Fg6OO1h4OIxCOc7H3684668K >									
	//        <  u =="0.000000000000000001" : ] 000002359106707.141630000000000000 ; 000002373627338.360800000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000E0FB60FE25DE2E >									
	//     < NDD_WEW_I_metadata_line_30_____2384721381 ro_Lab_810_5Y_1.00 >									
	//        < jSIjj7q1oBX4gF0i0506fjxTL15I58Bkknr9Bts2up0k9x6OW0t6nLWNgBJrb5t9 >									
	//        <  u =="0.000000000000000001" : ] 000002373627338.360800000000000000 ; 000002420612214.328980000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000E25DE2EE6D8FA5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_WEW_I_metadata_line_31_____2375661033 ro_Lab_810_5Y_1.10 >									
	//        < 9I81okOGJ60LaqXVz0kT5DocMkX8E7X9sia43n88qZ0DhqrYBAO88tHCR2s28VOX >									
	//        <  u =="0.000000000000000001" : ] 000002420612214.328980000000000000 ; 000002449145247.966010000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000E6D8FA5E99195D >									
	//     < NDD_WEW_I_metadata_line_32_____2302275357 ro_Lab_810_7Y_1.00 >									
	//        < VE53i2W6ljk1sFsFHfHKhd6x18g9Uo5DyS3v4He1w8fdKvgm2dFd3dabc1nOf80s >									
	//        <  u =="0.000000000000000001" : ] 000002449145247.966010000000000000 ; 000002728881659.343960000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000E99195D1043F166 >									
	//     < NDD_WEW_I_metadata_line_33_____2379945505 ro_Lab_411_3Y_1.00 >									
	//        < Ig1vQ78ao2VMxMs2K3CndJ2DQ70LQ26Az5T3DdG65P7604R2pple227s61dv688s >									
	//        <  u =="0.000000000000000001" : ] 000002728881659.343960000000000000 ; 000002744793340.684810000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000001043F166105C38E6 >									
	//     < NDD_WEW_I_metadata_line_34_____2358112474 ro_Lab_411_5Y_1.00 >									
	//        < wfc6bZ0T2IkCHga3H0j4SKl1r9d98MMJ8c28E64EzNUHYrd150ReWporJZ6uqew4 >									
	//        <  u =="0.000000000000000001" : ] 000002744793340.684810000000000000 ; 000002811170544.280640000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000105C38E610C1817E >									
	//     < NDD_WEW_I_metadata_line_35_____2368595079 ro_Lab_411_5Y_1.10 >									
	//        < eTOB64fABZYk7zKo8D2yovoHdSugk12megLo0oG4bvj0W3itba5Uat9h4gnUfFO7 >									
	//        <  u =="0.000000000000000001" : ] 000002811170544.280640000000000000 ; 000002848944203.718410000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000010C1817E10FB24D4 >									
	//     < NDD_WEW_I_metadata_line_36_____2391341953 ro_Lab_411_7Y_1.00 >									
	//        < J70CB4Fl4lVIhu2IyYn8OZtBIB3o7s3cedcIneJ1bU483Ms2F83o2iP2xow9E9sL >									
	//        <  u =="0.000000000000000001" : ] 000002848944203.718410000000000000 ; 000003400275920.085480000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000010FB24D4144468C8 >									
	//     < NDD_WEW_I_metadata_line_37_____2364481704 ro_Lab_811_3Y_1.00 >									
	//        < zze9MXgv489YvYU892XC443SREo5963jca89mZ24LfVr0eKnONPb4Q15MSLR90cf >									
	//        <  u =="0.000000000000000001" : ] 000003400275920.085480000000000000 ; 000003426463344.480990000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000144468C8146C5E3E >									
	//     < NDD_WEW_I_metadata_line_38_____1187860614 ro_Lab_811_5Y_1.00 >									
	//        < 0cT3n8kZ88d54w49o3SG3v5muDdFWC92n55q1VR7AZtXuA51s8qK69GjGnv1jBBp >									
	//        <  u =="0.000000000000000001" : ] 000003426463344.480990000000000000 ; 000003932647394.579280000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000146C5E3E1770BE63 >									
	//     < NDD_WEW_I_metadata_line_39_____2381420543 ro_Lab_811_5Y_1.10 >									
	//        < p37XK5uoMtNXYy6gQCHr9OTrNKQKG0WJpMM3s7dze5V2c7UPvlLG8Ha4ZHIq00dt >									
	//        <  u =="0.000000000000000001" : ] 000003932647394.579280000000000000 ; 000004179676546.707900000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000001770BE6318E9AE27 >									
	//     < NDD_WEW_I_metadata_line_40_____1151730602 ro_Lab_811_7Y_1.00 >									
	//        < 0yya5iK7tQS7bipu27nRTqPX3z5CU0IaP7417I9URv5F432o19IrHAjTNCmF6UOg >									
	//        <  u =="0.000000000000000001" : ] 000004179676546.707900000000000000 ; 000011239081973.726600000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000018E9AE2742FD7A65 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}