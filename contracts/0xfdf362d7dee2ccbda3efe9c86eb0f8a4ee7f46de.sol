pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXII_III_883		"	;
		string	public		symbol =	"	RUSS_PFXXII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1096158977593040000000000000					;	
										
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
	//     < RUSS_PFXXII_III_metadata_line_1_____RUSSIAN_FEDERATION_BOND_1_20231101 >									
	//        < 30TX7Oz01hffrmGy5XFqqG921jj6j37fTJzvrvPSgVDxzVWWt7MWT06dA8Y3ej7f >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000033430916.896991600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000003302F4 >									
	//     < RUSS_PFXXII_III_metadata_line_2_____RF_BOND_2_20231101 >									
	//        < nQ4a572s1qCHt4KOw7fO9Xv5lNVqus65kL193xunnPGj2h5eralIikB9Bl3tK58q >									
	//        <  u =="0.000000000000000001" : ] 000000033430916.896991600000000000 ; 000000063965328.404549800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003302F4619A75 >									
	//     < RUSS_PFXXII_III_metadata_line_3_____RF_BOND_3_20231101 >									
	//        < 7XRcXcf01Ftg764hfqShVj4shlkwfs2XB9ZKNqzcqD5l0rvnVbUwHV1Vr6edCGf2 >									
	//        <  u =="0.000000000000000001" : ] 000000063965328.404549800000000000 ; 000000086749705.190673700000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000619A75845E9B >									
	//     < RUSS_PFXXII_III_metadata_line_4_____RF_BOND_4_20231101 >									
	//        < mUSB38hPw8l8284lFw32Tx2AVk324Wa1v7846297TF9yEXYugBMNfZLqaE6Yl5Y0 >									
	//        <  u =="0.000000000000000001" : ] 000000086749705.190673700000000000 ; 000000113455671.311931000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000845E9BAD1E9F >									
	//     < RUSS_PFXXII_III_metadata_line_5_____RF_BOND_5_20231101 >									
	//        < LiwRN0Fv5mMqo4jR5wH3m9LhkrpR8KYZr3sxmdi3rMXZcp2245Vij550O3jpk0u1 >									
	//        <  u =="0.000000000000000001" : ] 000000113455671.311931000000000000 ; 000000141789947.455908000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AD1E9FD85AB3 >									
	//     < RUSS_PFXXII_III_metadata_line_6_____RF_BOND_6_20231101 >									
	//        < L7Q95w72KQZ8FMT5lWZz9WCDg6qk3mpU8T9Yy1wI91B91gS8SlannhpJHtq5620w >									
	//        <  u =="0.000000000000000001" : ] 000000141789947.455908000000000000 ; 000000168036220.841568000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000D85AB31006726 >									
	//     < RUSS_PFXXII_III_metadata_line_7_____RF_BOND_7_20231101 >									
	//        < 8TcX9vNQka1FCBCqBneLIQk7Vcvf0TdRX3TqhfYk7u3xZPk0HI52GBqRl4p2hK6u >									
	//        <  u =="0.000000000000000001" : ] 000000168036220.841568000000000000 ; 000000192481746.916433000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001006726125B42F >									
	//     < RUSS_PFXXII_III_metadata_line_8_____RF_BOND_8_20231101 >									
	//        < Y23srg4G6o3VjvILpGOAXr31hiYLEFG6I9g2hqaLNjz0fMnvqPOza30rn84uxX3p >									
	//        <  u =="0.000000000000000001" : ] 000000192481746.916433000000000000 ; 000000225885288.739582000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000125B42F158AC71 >									
	//     < RUSS_PFXXII_III_metadata_line_9_____RF_BOND_9_20231101 >									
	//        < F421A03dlcVLFXiz72H2Z88S2Z640YkGbj1ln6eOXSSj7jGHB4uEK67eiGyVFB96 >									
	//        <  u =="0.000000000000000001" : ] 000000225885288.739582000000000000 ; 000000245952483.007270000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000158AC711774B30 >									
	//     < RUSS_PFXXII_III_metadata_line_10_____RF_BOND_10_20231101 >									
	//        < 4hZq697CEbIb2J15NQe3WGJfG9581k664N5dM7QZQOOs7ZiEa9R82dx00bONraO7 >									
	//        <  u =="0.000000000000000001" : ] 000000245952483.007270000000000000 ; 000000268240444.598512000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001774B301994D6C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXII_III_metadata_line_11_____RUSS_CENTRAL_BANK_BOND_1_20231101 >									
	//        < VICwYG3J61U4qsHnZx995Wi0s550fpgX125E33ytl4S17V8ngAi4kn89zsXr1s9Y >									
	//        <  u =="0.000000000000000001" : ] 000000268240444.598512000000000000 ; 000000297092286.955353000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001994D6C1C553AD >									
	//     < RUSS_PFXXII_III_metadata_line_12_____RCB_BOND_2_20231101 >									
	//        < 18C9i6229Y65rH3576RC6a9HS2269cJGPG9opr2672295Jgha3LEFDoP6Xm6VWz1 >									
	//        <  u =="0.000000000000000001" : ] 000000297092286.955353000000000000 ; 000000327099637.666621000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C553AD1F31D4C >									
	//     < RUSS_PFXXII_III_metadata_line_13_____RCB_BOND_3_20231101 >									
	//        < 0pNJj0D6Xhqg02gvVESB4106SyxO6cS1N8h24014E44uN1i60l7Awmi0aN4RSFjm >									
	//        <  u =="0.000000000000000001" : ] 000000327099637.666621000000000000 ; 000000348061069.415597000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F31D4C213195B >									
	//     < RUSS_PFXXII_III_metadata_line_14_____RCB_BOND_4_20231101 >									
	//        < u84cpnECUs0v8I2u6bNq5uNHI4mv8x3cJ1lO0hqE0l521lMI477JU7U25I0R7e7z >									
	//        <  u =="0.000000000000000001" : ] 000000348061069.415597000000000000 ; 000000379031523.110246000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000213195B2425B30 >									
	//     < RUSS_PFXXII_III_metadata_line_15_____RCB_BOND_5_20231101 >									
	//        < MqW1W6t5LMLi0BS3vsFkaniixfjnC3n87SGW5t5EGIcTWTs7JzUoW43yslvy0Y95 >									
	//        <  u =="0.000000000000000001" : ] 000000379031523.110246000000000000 ; 000000407109986.594385000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002425B3026D3357 >									
	//     < RUSS_PFXXII_III_metadata_line_16_____ROSSELKHOZBANK_20231101 >									
	//        < 95fBWTn47T94Si7FRXu8TFZ7JfyfNOHUqKXoZKnxO9Os7OgJ2817hQiPhVM2cP41 >									
	//        <  u =="0.000000000000000001" : ] 000000407109986.594385000000000000 ; 000000427936333.785940000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026D335728CFAA1 >									
	//     < RUSS_PFXXII_III_metadata_line_17_____PROMSVYAZBANK_20231101 >									
	//        < zgpGWV530U3OO1QA34ngIoJOLUpaIKuX7wc81B20W630r5VqO31bkLzT0U19JwJk >									
	//        <  u =="0.000000000000000001" : ] 000000427936333.785940000000000000 ; 000000446687017.184958000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028CFAA12A9971E >									
	//     < RUSS_PFXXII_III_metadata_line_18_____BN_BANK_20231101 >									
	//        < M9CBF2lVOy5C0eHXp30gA80iUSyE6RIS52R4aBUTiwLDUxY77G0b00x1aU8USij8 >									
	//        <  u =="0.000000000000000001" : ] 000000446687017.184958000000000000 ; 000000481009971.646378000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A9971E2DDF685 >									
	//     < RUSS_PFXXII_III_metadata_line_19_____RUSSIAN_STANDARD_BANK_20231101 >									
	//        < 1S0nQOU7dVuAH23859RYjK0Eu8z0xCCm72PnS9KSXjABgK2OlVZL3q4dUNKLfTCy >									
	//        <  u =="0.000000000000000001" : ] 000000481009971.646378000000000000 ; 000000511117936.496449000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DDF68530BE772 >									
	//     < RUSS_PFXXII_III_metadata_line_20_____OTKRITIE_20231101 >									
	//        < Ukwg9aBZab64ks4G3Dx7Q929VCx1VVU0z0N546Z4uK5qAm6UbF5FTip59M974bvT >									
	//        <  u =="0.000000000000000001" : ] 000000511117936.496449000000000000 ; 000000545585920.017066000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030BE7723407F80 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXII_III_metadata_line_21_____HOME_CREDIT_FINANCE_BANK_20231101 >									
	//        < 4sd95dk4bjF9v2Emg0NW3Ko9yBbfGMg2aOq8SGACe4CDSD571iiXECqRK2Z3Ajut >									
	//        <  u =="0.000000000000000001" : ] 000000545585920.017066000000000000 ; 000000565710513.672889000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003407F8035F34AB >									
	//     < RUSS_PFXXII_III_metadata_line_22_____UNICREDIT_BANK_RUSSIA_20231101 >									
	//        < 7VCi9dyz15WFO5k6YT0G53v3trfNuZluhxSI5Xo2JcaqCkRlKjos94Vn28oP2F7D >									
	//        <  u =="0.000000000000000001" : ] 000000565710513.672889000000000000 ; 000000597175965.965451000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035F34AB38F37DD >									
	//     < RUSS_PFXXII_III_metadata_line_23_____URAL_BANK_RECONSTRUCTION_DEV_20231101 >									
	//        < mlrAiHp5j46L1BZg9m492Pcm05E748xAz868Wh33806TbdA40X58s6NHbK8TDV1G >									
	//        <  u =="0.000000000000000001" : ] 000000597175965.965451000000000000 ; 000000631045871.413001000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038F37DD3C2E64B >									
	//     < RUSS_PFXXII_III_metadata_line_24_____AK_BARS_BANK_20231101 >									
	//        < dZjbg07h6TT5Z4Hp9J69ssfmosFnYK0P97y66diSscHB3khW7wB87U5vjpznrSym >									
	//        <  u =="0.000000000000000001" : ] 000000631045871.413001000000000000 ; 000000665622872.815288000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C2E64B3F7A8EF >									
	//     < RUSS_PFXXII_III_metadata_line_25_____SOVCOMBANK_20231101 >									
	//        < 6h30mBt1j43XXL568qFl6CJ4LyBk4wCvSJ5fjE1IPH79IcK314ri7yC94156200l >									
	//        <  u =="0.000000000000000001" : ] 000000665622872.815288000000000000 ; 000000689266748.368672000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F7A8EF41BBCD3 >									
	//     < RUSS_PFXXII_III_metadata_line_26_____MONEYGRAM_RUSS_20231101 >									
	//        < Cw4Wkzr76A3nGGx5385AB70WeIaj70d66a0bgi7ucgIQP5YxOwi4NpG1wZ56gZoC >									
	//        <  u =="0.000000000000000001" : ] 000000689266748.368672000000000000 ; 000000715171668.908793000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041BBCD344343EF >									
	//     < RUSS_PFXXII_III_metadata_line_27_____VOZROZHDENIE_BANK_20231101 >									
	//        < xE042s95K847z5Sv6T07G11h9T6XM18vj8k34r75N5A157RH147AmuK4m09XLy9K >									
	//        <  u =="0.000000000000000001" : ] 000000715171668.908793000000000000 ; 000000749415923.189746000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044343EF4778498 >									
	//     < RUSS_PFXXII_III_metadata_line_28_____MTC_BANK_20231101 >									
	//        < si0AOuO97mc6X6vsU90Qw5p23fg7uKfCjcjO8metJ8QDFhbtBE2r44D5nlQ3MAnz >									
	//        <  u =="0.000000000000000001" : ] 000000749415923.189746000000000000 ; 000000769050100.331286000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000047784984957A32 >									
	//     < RUSS_PFXXII_III_metadata_line_29_____ABSOLUT_BANK_20231101 >									
	//        < t55z3X2FyDCMs3Ehfcui0PCEkdB7ZBzm8JGeNZPSt7vOtDL0kUNxuIG4se1V7KzQ >									
	//        <  u =="0.000000000000000001" : ] 000000769050100.331286000000000000 ; 000000800305226.259323000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004957A324C52B3B >									
	//     < RUSS_PFXXII_III_metadata_line_30_____ROSBANK_20231101 >									
	//        < p3XwnO9EiBjrct6L04cn65M889ahD7qDIzMupX75Anr5UlY74wE933567XNvuITV >									
	//        <  u =="0.000000000000000001" : ] 000000800305226.259323000000000000 ; 000000836059015.617184000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004C52B3B4FBB98E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXII_III_metadata_line_31_____ALFA_BANK_20231101 >									
	//        < DD80a6csJoA3ek90Tc5P76Ew0NrxB4z5198ZUh2byuszXHJJ15MUjL4H2LoUDA5o >									
	//        <  u =="0.000000000000000001" : ] 000000836059015.617184000000000000 ; 000000857599594.511358000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004FBB98E51C97D7 >									
	//     < RUSS_PFXXII_III_metadata_line_32_____SOGAZ_20231101 >									
	//        < 6l6fo480CvqbI11D955BdaGox23q49HH90e5G46043YE877GzcP0X77d05zXr3th >									
	//        <  u =="0.000000000000000001" : ] 000000857599594.511358000000000000 ; 000000876518354.807783000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000051C97D753975FB >									
	//     < RUSS_PFXXII_III_metadata_line_33_____RENAISSANCE_20231101 >									
	//        < C2ZYLb7O1e86GG0xCp464N4UpXruLus5m10kDD1Zw42z49H2Dfiii47155HsMQXp >									
	//        <  u =="0.000000000000000001" : ] 000000876518354.807783000000000000 ; 000000895033384.839370000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000053975FB555B66A >									
	//     < RUSS_PFXXII_III_metadata_line_34_____VTB_BANK_20231101 >									
	//        < kX3hKr7iGgy49ylNuUw069Bz07P58n3r8n9lD98BY30ZJiDWT94KyAQDF9oZv66i >									
	//        <  u =="0.000000000000000001" : ] 000000895033384.839370000000000000 ; 000000927283009.578010000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000555B66A586EBED >									
	//     < RUSS_PFXXII_III_metadata_line_35_____ERGO_RUSS_20231101 >									
	//        < z80Pkr4uJVw99wv75e2HHaKd0MovJ08slApFuc4u42x9Ii53XERO57UY1uJyybmN >									
	//        <  u =="0.000000000000000001" : ] 000000927283009.578010000000000000 ; 000000960945587.087853000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000586EBED5BA495F >									
	//     < RUSS_PFXXII_III_metadata_line_36_____GAZPROMBANK_20231101 >									
	//        < 9cwgJo79kTOV2mJ6QmMZ2Ys0r6Q7WV67SPqHT9c2Yj9DDMMx243c9rJM5YmDwz94 >									
	//        <  u =="0.000000000000000001" : ] 000000960945587.087853000000000000 ; 000000988407946.091315000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005BA495F5E430DB >									
	//     < RUSS_PFXXII_III_metadata_line_37_____SBERBANK_20231101 >									
	//        < XF7fl70Lm8k8EKLe68N89aoQdRCtTIm41B7R3kD239eyt58J2D81wKfZ6Y6GnfAG >									
	//        <  u =="0.000000000000000001" : ] 000000988407946.091315000000000000 ; 000001014605232.116320000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005E430DB60C2A2B >									
	//     < RUSS_PFXXII_III_metadata_line_38_____TINKOFF_BANK_20231101 >									
	//        < MiKCOdS0aRCQc5Tqlp5AAwyFRkKuMujGg7b01Skyn9t3jnAui9CqGfK2RkCJrHEt >									
	//        <  u =="0.000000000000000001" : ] 000001014605232.116320000000000000 ; 000001048250354.757030000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000060C2A2B63F80CB >									
	//     < RUSS_PFXXII_III_metadata_line_39_____VBANK_20231101 >									
	//        < r7IZ0NpxbGYhT7M0s0EkAI1Lb2KprlguT72x2G79D9fP5895D145Gc09gGHsm3cX >									
	//        <  u =="0.000000000000000001" : ] 000001048250354.757030000000000000 ; 000001075918222.563670000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000063F80CB669B88E >									
	//     < RUSS_PFXXII_III_metadata_line_40_____CREDIT_BANK_MOSCOW_20231101 >									
	//        < nX12Y0b61fz5Np80fCZimd4xFjUwI8htpfIeHB8FqtaW1F6yA18PsXIO48jBj54k >									
	//        <  u =="0.000000000000000001" : ] 000001075918222.563670000000000000 ; 000001096158977.593040000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000669B88E6889B1A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}