pragma solidity 		^0.4.25	;						
										
	contract	CHEMCHINA_PFVI_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	CHEMCHINA_PFVI_I_883		"	;
		string	public		symbol =	"	CHEMCHINA_PFVI_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		565621903296050000000000000					;	
										
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
	//     < CHEMCHINA_PFVI_I_metadata_line_1_____Shanghai_PI_Chemicals_Limited_20220321 >									
	//        < LIP4FBx4jPIX9Oe202XO8n5KpISiQs19AF6WGy20n7z6P702MfT4b64FLgZ24946 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000013662100.063394300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000014D8C2 >									
	//     < CHEMCHINA_PFVI_I_metadata_line_2_____Shanghai_PI_Chemicals_Limited_20220321 >									
	//        < n0f7qIJ9iP1R2vEBOP7M2O0Bx8zKW2GbqfB3xifN2E6k96acEo8M2rmE37834Rhm >									
	//        <  u =="0.000000000000000001" : ] 000000013662100.063394300000000000 ; 000000026986745.948062100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000014D8C2292DB3 >									
	//     < CHEMCHINA_PFVI_I_metadata_line_3_____Shanghai_Race_Chemical_Co_Limited_20220321 >									
	//        < 5A8zL57W5g7uyo1rMGn0qSM2INf973G71RGFstoeQ4jE4DbYClS7Hp04qRcB9B8I >									
	//        <  u =="0.000000000000000001" : ] 000000026986745.948062100000000000 ; 000000041677026.378821600000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000292DB33F9817 >									
	//     < CHEMCHINA_PFVI_I_metadata_line_4_____Shanghai_Sinch_Parmaceuticals_Tech__Co__Limited_20220321 >									
	//        < lB29db0S9TB57f2wt81Rh8M7D9z60PS5fNlHZMjP422d5Q2Dn9tixd5SdL8wEwQp >									
	//        <  u =="0.000000000000000001" : ] 000000041677026.378821600000000000 ; 000000055213537.163629000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003F9817543FCA >									
	//     < CHEMCHINA_PFVI_I_metadata_line_5_____Shanghai_Sunway_Pharmaceutical_Technology_Co_Limited_20220321 >									
	//        < EnSuJ3Nb6VDfQbP6mNRurnKnoywaNPQZM1S32w7ORafJKFW7f3qS42Thsix6oW29 >									
	//        <  u =="0.000000000000000001" : ] 000000055213537.163629000000000000 ; 000000069648298.807548900000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000543FCA6A465E >									
	//     < CHEMCHINA_PFVI_I_metadata_line_6_____Shanghai_Tauto_Biotech_Co_Limited_20220321 >									
	//        < AF1ECq1LXez1C2eO93dezUKNRp2s5zijzaSmTT8vmGHS1PGN2i9enIaouv5gm01X >									
	//        <  u =="0.000000000000000001" : ] 000000069648298.807548900000000000 ; 000000083146413.543644900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006A465E7EDF11 >									
	//     < CHEMCHINA_PFVI_I_metadata_line_7_____Shanghai_UCHEM_org__20220321 >									
	//        < 6Wl5MTf4532q1Jp0To4Tpn9g7WB3U54Opazxm4EA1bxA1jT4Y60LmPl2fQqyH2nF >									
	//        <  u =="0.000000000000000001" : ] 000000083146413.543644900000000000 ; 000000098086659.865351400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007EDF1195AB1A >									
	//     < CHEMCHINA_PFVI_I_metadata_line_8_____Shanghai_UCHEM_inc__20220321 >									
	//        < Qb6plq5Y8pvsn59vh83gkqM7crYIvPb2Le0tT4pg8VAcuF5e3I5yHvTu7H0sUxB5 >									
	//        <  u =="0.000000000000000001" : ] 000000098086659.865351400000000000 ; 000000110952710.952777000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000095AB1AA94CE7 >									
	//     < CHEMCHINA_PFVI_I_metadata_line_9_____Shanghai_UDChem_Technology_Co_Limited_20220321 >									
	//        < rr15G536C12gu8y09PYxww3v4a3rnhTWvAU3yRmy0uYW14E9cf3RFYp6314GGeYS >									
	//        <  u =="0.000000000000000001" : ] 000000110952710.952777000000000000 ; 000000124741581.657180000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A94CE7BE572E >									
	//     < CHEMCHINA_PFVI_I_metadata_line_10_____Shanghai_Witofly_Chemical_Co_Limited_20220321 >									
	//        < 7Rk6Tz1NZVP38ZzfrIyA0IxriU9jWhX6IYP65vL3njAX2xHgv1BjC2T8jgBxzqha >									
	//        <  u =="0.000000000000000001" : ] 000000124741581.657180000000000000 ; 000000140711566.758158000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BE572ED6B575 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFVI_I_metadata_line_11_____Shanghai_Worldyang_Chemical_Co_Limited_20220321 >									
	//        < RkToH57zMesf4OetLQWLM4474D83Y1h1W8I89hLQ0lg2UxhihS6hRTmHlm63rr55 >									
	//        <  u =="0.000000000000000001" : ] 000000140711566.758158000000000000 ; 000000156112707.371814000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D6B575EE3587 >									
	//     < CHEMCHINA_PFVI_I_metadata_line_12_____Shanghai_Yingxuan_Chempharm_Co__Limited_20220321 >									
	//        < 1L9pCm54f39uUqY7fNh4360ASvR82vOjRm0l54IT41eTI0dxj14XnkZJi8wh1EzR >									
	//        <  u =="0.000000000000000001" : ] 000000156112707.371814000000000000 ; 000000170076171.316953000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EE35871038401 >									
	//     < CHEMCHINA_PFVI_I_metadata_line_13_____SHANXI_WUCHAN_FINE_CHEMICAL_Co_Limited_20220321 >									
	//        < KF4HL1Jh4buzzKm1IiSTCH6eXZ2N0et93G9JR1NmJsSZ1DXBAd3AxD8M2BzKW401 >									
	//        <  u =="0.000000000000000001" : ] 000000170076171.316953000000000000 ; 000000183198992.988704000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010384011178A1B >									
	//     < CHEMCHINA_PFVI_I_metadata_line_14_____SHENYANG_OLLYCHEM_CO_LTD_20220321 >									
	//        < 0mR05MPT3iESF56H7IBvr220dXHNb9Dc2RXguh2hH3X203r2y2r4Q0VRQ11Nurj8 >									
	//        <  u =="0.000000000000000001" : ] 000000183198992.988704000000000000 ; 000000199257983.368087000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001178A1B1300B26 >									
	//     < CHEMCHINA_PFVI_I_metadata_line_15_____ShenZhen_Cerametek_Materials_org_20220321 >									
	//        < b7DS1usWVx9xJpVN4MKShg2ii2Y3P3aMQ78b8xr7o15MczkdJkoQmKh1p4Y2baum >									
	//        <  u =="0.000000000000000001" : ] 000000199257983.368087000000000000 ; 000000213479968.956006000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001300B26145BE9D >									
	//     < CHEMCHINA_PFVI_I_metadata_line_16_____ShenZhen_Cerametek_Materials_Co_Limited_20220321 >									
	//        < YGUd280CYX3yOXWc2gD7u990P8lH9o9a7aFa9NzeVKCalBb016Bq4QvUix111Fyp >									
	//        <  u =="0.000000000000000001" : ] 000000213479968.956006000000000000 ; 000000229716941.647591000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000145BE9D15E852E >									
	//     < CHEMCHINA_PFVI_I_metadata_line_17_____SHENZHEN_CHEMICAL_Co__Limited_20220321 >									
	//        < gIo6kw7a41MqrUmBOPk2F0d3iKQ2bd1HlG0A4sRJ7Y5qvA47np1Z1v9LCT0T23e0 >									
	//        <  u =="0.000000000000000001" : ] 000000229716941.647591000000000000 ; 000000244129688.205064000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015E852E1748329 >									
	//     < CHEMCHINA_PFVI_I_metadata_line_18_____SHOUGUANG_FUKANG_PHARMACEUTICAL_Co_Limited_20220321 >									
	//        < 7z5N1emd3qxUhG69bJ5Vtip6Hds2yM14uG66NKfWp586TMJ4c8tCVop25Y7z7579 >									
	//        <  u =="0.000000000000000001" : ] 000000244129688.205064000000000000 ; 000000258637598.461510000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000174832918AA650 >									
	//     < CHEMCHINA_PFVI_I_metadata_line_19_____Shouyuan_Chemical_20220321 >									
	//        < KO88Oy5ptvL39KEkkT8Bhs4PTZf6H850BNokha5n7uux4s3cHi0N5OiXNHg106vn >									
	//        <  u =="0.000000000000000001" : ] 000000258637598.461510000000000000 ; 000000273209109.431222000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018AA6501A0E24F >									
	//     < CHEMCHINA_PFVI_I_metadata_line_20_____Sichuan_Apothe_Pharmaceuticals_Limited_20220321 >									
	//        < 6kKZQ8l5982F73nPJ732yoGeIr19x4jwKbrfKzcGm7H9n4fR0ysw9XXV2t68M3M7 >									
	//        <  u =="0.000000000000000001" : ] 000000273209109.431222000000000000 ; 000000287674665.531201000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A0E24F1B6F4EB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFVI_I_metadata_line_21_____Sichuan_Highlight_Fine_Chemicals_Co__Limited_20220321 >									
	//        < Z55kGVrccjT84rm9ZOSz3Qty1lpWmeKlneEI7M43S6IOZ7W7F8O1H6j865M0fa0u >									
	//        <  u =="0.000000000000000001" : ] 000000287674665.531201000000000000 ; 000000303094541.498588000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B6F4EB1CE7C4E >									
	//     < CHEMCHINA_PFVI_I_metadata_line_22_____SICHUAN_TONGSHENG_AMINO_ACID_org_20220321 >									
	//        < Og7U8MvbV8IlvdGQV6B93v0289scER7SUxerU4q8d73s6nJ7sB2l5t3TFm32ZaJe >									
	//        <  u =="0.000000000000000001" : ] 000000303094541.498588000000000000 ; 000000318480556.904090000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CE7C4E1E5F678 >									
	//     < CHEMCHINA_PFVI_I_metadata_line_23_____SICHUAN_TONGSHENG_AMINO_ACID_Co_Limited_20220321 >									
	//        < 9v46Z4PCecT03TOA9O7hiHy7z63R1i4mvh7G7Q7dig5502azgZgvsqG6h33TVicL >									
	//        <  u =="0.000000000000000001" : ] 000000318480556.904090000000000000 ; 000000334762067.885727000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E5F6781FECE6F >									
	//     < CHEMCHINA_PFVI_I_metadata_line_24_____SightChem_Co__Limited_20220321 >									
	//        < 24Z83479KksP96TXSq7Q415X2NXRJ0526E8uYZnDQeRLXFCccRK0kragCoeJcQ2f >									
	//        <  u =="0.000000000000000001" : ] 000000334762067.885727000000000000 ; 000000348001100.839438000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FECE6F21301EE >									
	//     < CHEMCHINA_PFVI_I_metadata_line_25_____Simagchem_Corporation_20220321 >									
	//        < lkP80f8VpVS938r97C5N4Nl7i0UMG0Fz0b90Er2S2RY20Q0F87SLC3hW0Bwdy0ks >									
	//        <  u =="0.000000000000000001" : ] 000000348001100.839438000000000000 ; 000000360746672.540924000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021301EE22674AB >									
	//     < CHEMCHINA_PFVI_I_metadata_line_26_____SINO_GREAT_ENTERPRISE_Limited_20220321 >									
	//        < 0w4bbwkwjC2dKG6TOCSAppx4k62877Upv6Y6gdk3F9ASZ289DnkHDP3OqV71ICOQ >									
	//        <  u =="0.000000000000000001" : ] 000000360746672.540924000000000000 ; 000000376798979.382669000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022674AB23EF31A >									
	//     < CHEMCHINA_PFVI_I_metadata_line_27_____SINO_High_Goal_chemical_Techonology_Co_Limited_20220321 >									
	//        < u842527GpN32r3fYBuPAPQP8eS35ennoz1sIFv1C2ru1A8xGHviP9sOc3z1aP1k5 >									
	//        <  u =="0.000000000000000001" : ] 000000376798979.382669000000000000 ; 000000391393395.130659000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023EF31A255380C >									
	//     < CHEMCHINA_PFVI_I_metadata_line_28_____Sino_Rarechem_Labs_Co_Limited_20220321 >									
	//        < CjF298inmK0GwxlLSB1kUI23I3hO8634O92df25n8y6LDNqax9O5bN8K2u86Upwg >									
	//        <  u =="0.000000000000000001" : ] 000000391393395.130659000000000000 ; 000000403644197.455911000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000255380C267E984 >									
	//     < CHEMCHINA_PFVI_I_metadata_line_29_____Sinofi_Ingredients_20220321 >									
	//        < vq6vQeo48TJ7bcOgaMx7NASyZ05JnX0r16Y62vazx9d2McBH4E6xNgSh65qdcGi4 >									
	//        <  u =="0.000000000000000001" : ] 000000403644197.455911000000000000 ; 000000418175881.448011000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000267E98427E15F4 >									
	//     < CHEMCHINA_PFVI_I_metadata_line_30_____Sinoway_20220321 >									
	//        < kVKorbzJgpmQKDr8FU6Evsamug9F6724bY256T8qjxNIAFf1pKwL0xlL7T8NJ6O0 >									
	//        <  u =="0.000000000000000001" : ] 000000418175881.448011000000000000 ; 000000433128768.028890000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027E15F4294E6ED >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFVI_I_metadata_line_31_____Skyrun_Industrial_Co_Limited_20220321 >									
	//        < 2or0VUw745Q0woH5w4jx5359m8u6co9Ki8tV79uPvw9U873WB3299gfxQ290EX6Q >									
	//        <  u =="0.000000000000000001" : ] 000000433128768.028890000000000000 ; 000000446945446.819696000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000294E6ED2A9FC11 >									
	//     < CHEMCHINA_PFVI_I_metadata_line_32_____Spec_Chem_Industry_org_20220321 >									
	//        < f4HIP3e3ah5e909A8486kgdG0mURXh16iVLM0s6Y3x6EhZO969jGrPxp1MXd9lmt >									
	//        <  u =="0.000000000000000001" : ] 000000446945446.819696000000000000 ; 000000459324216.206273000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A9FC112BCDF86 >									
	//     < CHEMCHINA_PFVI_I_metadata_line_33_____Spec_Chem_Industry_inc__20220321 >									
	//        < 37LzRDp0gO0c40v7kmI115Xva3t9XIeLIEz5mxeyxxP77q7t0lI2G4V9TEqQn8TT >									
	//        <  u =="0.000000000000000001" : ] 000000459324216.206273000000000000 ; 000000472526382.651629000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BCDF862D1049E >									
	//     < CHEMCHINA_PFVI_I_metadata_line_34_____Stone_Lake_Pharma_Tech_Co_Limited_20220321 >									
	//        < sNrWn7A9vhJcQUo7g3iNfW2J4LaCTCAel4nO24t3pRB9HRx7VxY62WDH8dJXk9pL >									
	//        <  u =="0.000000000000000001" : ] 000000472526382.651629000000000000 ; 000000485258097.929442000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D1049E2E471F2 >									
	//     < CHEMCHINA_PFVI_I_metadata_line_35_____Suzhou_ChonTech_PharmaChem_Technology_Co__Limited_20220321 >									
	//        < 4551jz39YrMZOicL2fI37HHV044A1sTS8kjiVZ5db2Qx4MoTDP8eFXLCA70ohduo >									
	//        <  u =="0.000000000000000001" : ] 000000485258097.929442000000000000 ; 000000497983269.405695000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E471F22F7DCB7 >									
	//     < CHEMCHINA_PFVI_I_metadata_line_36_____Suzhou_Credit_International_Trading_Co__Limited_20220321 >									
	//        < rD7mk8zM2v1dBy0J8o8wh5Z8OfXg758f29f4570YLYWhb130rh5p6L0NrR9cg7z1 >									
	//        <  u =="0.000000000000000001" : ] 000000497983269.405695000000000000 ; 000000511455241.034529000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F7DCB730C6B34 >									
	//     < CHEMCHINA_PFVI_I_metadata_line_37_____Suzhou_KPChemical_Co_Limited_20220321 >									
	//        < D6p7iC69oI2DjAp10po7QpJ9L751pvW8Pmmvfo6Cl1tQ7jL4l4U169r5R0kcX6mM >									
	//        <  u =="0.000000000000000001" : ] 000000511455241.034529000000000000 ; 000000524583307.646943000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030C6B34320735B >									
	//     < CHEMCHINA_PFVI_I_metadata_line_38_____Suzhou_Rovathin_Foreign_Trade_Co_Limited_20220321 >									
	//        < 2y319mR3v91U79ypH2WGjgWWFzU8ZTJx1v13kHX2l8ET9JuKwwGIE9vCi9tvLHl2 >									
	//        <  u =="0.000000000000000001" : ] 000000524583307.646943000000000000 ; 000000537931410.306172000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000320735B334D175 >									
	//     < CHEMCHINA_PFVI_I_metadata_line_39_____SUZHOU_SINOERA_CHEM_org_20220321 >									
	//        < bo9IuoLiOhYiTb2sWfBqYuiw0rlf35244wEkzyrbz8X5ajL2N3Sv8T7lQNy02e17 >									
	//        <  u =="0.000000000000000001" : ] 000000537931410.306172000000000000 ; 000000551287152.691199000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000334D175349328B >									
	//     < CHEMCHINA_PFVI_I_metadata_line_40_____SUZHOU_SINOERA_CHEM_Co__Limited_20220321 >									
	//        < JMO11I58F9N5v1yKdv4zpx94a4o7lJq7SK9072jdf3zlJ8q76nAg2dlvFwmGXhOo >									
	//        <  u =="0.000000000000000001" : ] 000000551287152.691199000000000000 ; 000000565621903.296050000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000349328B35F120E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}