pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXVI_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXVI_III_883		"	;
		string	public		symbol =	"	RUSS_PFXXXVI_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1038844884363090000000000000					;	
										
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
	//     < RUSS_PFXXXVI_III_metadata_line_1_____ROSNEFT_20251101 >									
	//        < u7ibKG9DRUoum6vkaN86Y0P2wOyP89675ZLdF7Y8F5g0jDJ42GCSig8s650us1Tp >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000028612772.667186600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000002BA8DD >									
	//     < RUSS_PFXXXVI_III_metadata_line_2_____ROSNEFT_GBP_20251101 >									
	//        < Qr572wj120gf990wbkd560WE0WkVF4y13h4DAJbahsJ8Ue405zspDvMH6TBiOxwo >									
	//        <  u =="0.000000000000000001" : ] 000000028612772.667186600000000000 ; 000000061888608.793526800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002BA8DD5E6F3D >									
	//     < RUSS_PFXXXVI_III_metadata_line_3_____ROSNEFT_USD_20251101 >									
	//        < 4T68I4U4At37u4rA347P2YmTifH732s3Mq15w01UOPu3Lmic2hM6iZ8W7coiqrDF >									
	//        <  u =="0.000000000000000001" : ] 000000061888608.793526800000000000 ; 000000093026829.080469400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005E6F3D8DF29B >									
	//     < RUSS_PFXXXVI_III_metadata_line_4_____ROSNEFT_SA_CHF_20251101 >									
	//        < qRnQl3SfnL11pgG83d7NwhB9DbKLo0LrnaN3eTwZdT3z3Z98UwmtDYe72I15e69P >									
	//        <  u =="0.000000000000000001" : ] 000000093026829.080469400000000000 ; 000000124287620.302420000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008DF29BBDA5DA >									
	//     < RUSS_PFXXXVI_III_metadata_line_5_____ROSNEFT_GMBH_EUR_20251101 >									
	//        < 13nr729e3015qav9Mou6Sp58bjUyyjpTBSPx0XNgYf690hAzpOnFfB9DPpD6t633 >									
	//        <  u =="0.000000000000000001" : ] 000000124287620.302420000000000000 ; 000000148255681.261607000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BDA5DAE23860 >									
	//     < RUSS_PFXXXVI_III_metadata_line_6_____BAIKALFINANSGRUP_20251101 >									
	//        < wmwNb6wM8kn57sw18dtzP3Eb19V1W9veZZz4iV1oxDHobXCeJ3Vf0iBpHXHvsH2z >									
	//        <  u =="0.000000000000000001" : ] 000000148255681.261607000000000000 ; 000000169804900.410884000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E238601031A0A >									
	//     < RUSS_PFXXXVI_III_metadata_line_7_____BAIKAL_ORG_20251101 >									
	//        < 4m6U3MVz5sbHcRC6m2NTo4GkK8TmJ5c9OG1b3Gwe1jTEJz7j52FsFd4P9Vlsu2q3 >									
	//        <  u =="0.000000000000000001" : ] 000000169804900.410884000000000000 ; 000000200814621.862343000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001031A0A1326B36 >									
	//     < RUSS_PFXXXVI_III_metadata_line_8_____BAIKAL_AB_20251101 >									
	//        < VVB2zaOD5a60p2xr36P184RLc3MGS6E9ZG62Ma543TuLv3GnwDX1XqjUl0105YUQ >									
	//        <  u =="0.000000000000000001" : ] 000000200814621.862343000000000000 ; 000000234695857.733732000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001326B361661E12 >									
	//     < RUSS_PFXXXVI_III_metadata_line_9_____BAIKAL_CHF_20251101 >									
	//        < F8x89X12uKCO25br1945e3OoeX5mX13o1C6D4b39EZWr9Mer27gKA099tQTTM3ju >									
	//        <  u =="0.000000000000000001" : ] 000000234695857.733732000000000000 ; 000000253921188.245162000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001661E1218373F7 >									
	//     < RUSS_PFXXXVI_III_metadata_line_10_____BAIKAL_BYR_20251101 >									
	//        < 99984omTN89bsewk0f746K1sipQ2C29dR0V4Qtv5kVTPXRKrCU3tn2h5xI51x9e9 >									
	//        <  u =="0.000000000000000001" : ] 000000253921188.245162000000000000 ; 000000272859894.339781000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018373F71A059E5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVI_III_metadata_line_11_____YUKOS_ABI_20251101 >									
	//        < 9AgQ8076xn5fyHTj575810rx18Ou8nf58aQZ2s02zZG3rq00grM6o7AR9HhV5Q15 >									
	//        <  u =="0.000000000000000001" : ] 000000272859894.339781000000000000 ; 000000292958201.441655000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A059E51BF04CC >									
	//     < RUSS_PFXXXVI_III_metadata_line_12_____YUKOS_ABII_20251101 >									
	//        < y1l3kUtBKmrEBK2DcD358sMYtZA2mFc5WjmF6x38iwP65f9lkKLdVN64O17yD1GU >									
	//        <  u =="0.000000000000000001" : ] 000000292958201.441655000000000000 ; 000000314371286.803040000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BF04CC1DFB149 >									
	//     < RUSS_PFXXXVI_III_metadata_line_13_____YUKOS_ABIII_20251101 >									
	//        < w153YhrLfvYYPL7MF9t5h367nLs8UmFzKsh1Snr227HO50fGL01k9KGQv6FyCoNK >									
	//        <  u =="0.000000000000000001" : ] 000000314371286.803040000000000000 ; 000000333253398.218041000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DFB1491FC811C >									
	//     < RUSS_PFXXXVI_III_metadata_line_14_____YUKOS_ABIV_20251101 >									
	//        < 1Z367tS9sLzVN9Yn3jmOi1LYyx8YA4HxW1ROtofUg7mLRFK61X2VC2L2zW02bwr0 >									
	//        <  u =="0.000000000000000001" : ] 000000333253398.218041000000000000 ; 000000363504043.813640000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FC811C22AA9C4 >									
	//     < RUSS_PFXXXVI_III_metadata_line_15_____YUKOS_ABV_20251101 >									
	//        < xnG83gh1M956NLY2Sn2MccSVv3dFSzhNga52czgx7ZcdF3zg4SwPCm8R5Q8HxoM9 >									
	//        <  u =="0.000000000000000001" : ] 000000363504043.813640000000000000 ; 000000394472970.183508000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022AA9C4259EB01 >									
	//     < RUSS_PFXXXVI_III_metadata_line_16_____ROSNEFT_TRADE_LIMITED_20251101 >									
	//        < 2Qwhndb6iYXl677b1dh8b22k1Sze9aH7MRaqX20xQjp7gEwuKn72cKLvmy6i36qV >									
	//        <  u =="0.000000000000000001" : ] 000000394472970.183508000000000000 ; 000000427396042.656004000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000259EB0128C2794 >									
	//     < RUSS_PFXXXVI_III_metadata_line_17_____NEFT_AKTIV_20251101 >									
	//        < 9Mb6383BbznrVvOfBhotNAU4Gn4Fvv9QTv296moRHzaHaaw1ONr6q447ZV909qhn >									
	//        <  u =="0.000000000000000001" : ] 000000427396042.656004000000000000 ; 000000453757100.988328000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028C27942B460DE >									
	//     < RUSS_PFXXXVI_III_metadata_line_18_____ACHINSK_OIL_REFINERY_VNK_20251101 >									
	//        < Ax9Hcwl5up5GV0iOV9u9aUEhE9D1cUrjV8OT9EZ3e5c58SeyYUvw4t9fPlei0Uss >									
	//        <  u =="0.000000000000000001" : ] 000000453757100.988328000000000000 ; 000000489186189.315643000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B460DE2EA705B >									
	//     < RUSS_PFXXXVI_III_metadata_line_19_____ROSPAN_INT_20251101 >									
	//        < 83nv32YgkXfRFD4939B5FHVry9Tf0C6mbeDQt9Be2N7A6atwriqnym2C1wJeP36q >									
	//        <  u =="0.000000000000000001" : ] 000000489186189.315643000000000000 ; 000000520574976.450271000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EA705B31A559A >									
	//     < RUSS_PFXXXVI_III_metadata_line_20_____STROYTRANSGAZ_LIMITED_20251101 >									
	//        < T0SvddpM3dXSbB2uT2QEMwn1TZS5Y44P0NDLGXW0Jo1gBae357PnE4UpEW1N959O >									
	//        <  u =="0.000000000000000001" : ] 000000520574976.450271000000000000 ; 000000539473715.946206000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031A559A3372BEC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVI_III_metadata_line_21_____ROSNEFT_LIMITED_20251101 >									
	//        < eyGjQ6TAE27gWo7RJb3F1D9t4GR5sn7un0Be9s3OF9kecn9TKAqa41QV3pn6R81n >									
	//        <  u =="0.000000000000000001" : ] 000000539473715.946206000000000000 ; 000000564564538.581836000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003372BEC35D7506 >									
	//     < RUSS_PFXXXVI_III_metadata_line_22_____TAIHU_LIMITED_20251101 >									
	//        < rOT17GG10hXzmnb7MP95rEum81awTE89W1X9BS43TnjPJp4Y6Smwh6wvd2QwN9U2 >									
	//        <  u =="0.000000000000000001" : ] 000000564564538.581836000000000000 ; 000000584325346.558466000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035D750637B9C17 >									
	//     < RUSS_PFXXXVI_III_metadata_line_23_____TAIHU_ORG_20251101 >									
	//        < QJ555FCZqm8y542y2TTrW2DfeG1Ogr1025A3arC0kMxw2A95dxD4B7mVig7nCWW9 >									
	//        <  u =="0.000000000000000001" : ] 000000584325346.558466000000000000 ; 000000604149248.149153000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037B9C17399DBCD >									
	//     < RUSS_PFXXXVI_III_metadata_line_24_____EAST_SIBERIAN_GAS_CO_20251101 >									
	//        < d773irhEHMi3F72ZnEf82gQE89UAw713pH9s3uir8IFVYzrC41i4YvJpzA3178Il >									
	//        <  u =="0.000000000000000001" : ] 000000604149248.149153000000000000 ; 000000633846971.156365000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000399DBCD3C72C79 >									
	//     < RUSS_PFXXXVI_III_metadata_line_25_____RN_TUAPSINSKIY_NPZ_20251101 >									
	//        < GBA5pA4WT4p52TQBy1ae8w468s46NgpAnb5Bj6f45L19740J9m0QjoYvyVOW2CX8 >									
	//        <  u =="0.000000000000000001" : ] 000000633846971.156365000000000000 ; 000000654359136.286270000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C72C793E6790A >									
	//     < RUSS_PFXXXVI_III_metadata_line_26_____ROSPAN_ORG_20251101 >									
	//        < 4o5FX6mNwBNdH5crEfyD9m4kdX5C80844C3236zqf2cn9JCsKu3a2z179DFvWgC1 >									
	//        <  u =="0.000000000000000001" : ] 000000654359136.286270000000000000 ; 000000685797100.474919000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E6790A416717E >									
	//     < RUSS_PFXXXVI_III_metadata_line_27_____SYSRAN_20251101 >									
	//        < NHP12D3NmIRoHO43EUsB8K5v9jR4OJk922wR4fhKN5Fk445642351KNzEUkX1GQI >									
	//        <  u =="0.000000000000000001" : ] 000000685797100.474919000000000000 ; 000000710531551.901457000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000416717E43C2F63 >									
	//     < RUSS_PFXXXVI_III_metadata_line_28_____SYSRAN_ORG_20251101 >									
	//        < KQ3Y7k1034T6CFyE3y9qE039WV8g62JZLT4ch0Kg4Xc90d7Kr6D6dDc7W1XL6OG4 >									
	//        <  u =="0.000000000000000001" : ] 000000710531551.901457000000000000 ; 000000737290268.193669000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000043C2F634650403 >									
	//     < RUSS_PFXXXVI_III_metadata_line_29_____ARTAG_20251101 >									
	//        < sKama0tGpg8bIr022pI3Fq6Py89doblNqEqi3Sv90hSlH22vpW4IA3O2o0PFI8qp >									
	//        <  u =="0.000000000000000001" : ] 000000737290268.193669000000000000 ; 000000764631310.690316000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000465040348EBC1B >									
	//     < RUSS_PFXXXVI_III_metadata_line_30_____ARTAG_ORG_20251101 >									
	//        < 80rqW057Sird1F3iXv9F666Idp37A3kY4S3pWO6va5kTDTJ535a4Wlhhp85xslaq >									
	//        <  u =="0.000000000000000001" : ] 000000764631310.690316000000000000 ; 000000788220455.858044000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048EBC1B4B2BA9E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVI_III_metadata_line_31_____RN_TUAPSE_REFINERY_LLC_20251101 >									
	//        < Xw9jEV7p9M9l1IM6e7WabTqZ2Z22aS50Z07SBEWzOiVYWXuXcQ61ni11PJ6kmb5g >									
	//        <  u =="0.000000000000000001" : ] 000000788220455.858044000000000000 ; 000000823604173.204043000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B2BA9E4E8B861 >									
	//     < RUSS_PFXXXVI_III_metadata_line_32_____TUAPSE_ORG_20251101 >									
	//        < D3c825eZ3MHEuwJ1ahpIjyf6Cgllvk4Sbe6PXs97clmR577Rz4opcmRH1F84vD3S >									
	//        <  u =="0.000000000000000001" : ] 000000823604173.204043000000000000 ; 000000845373274.662750000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004E8B861509EFEF >									
	//     < RUSS_PFXXXVI_III_metadata_line_33_____NATIONAL_OIL_CONSORTIUM_20251101 >									
	//        < VMVhA3O3PT4ZS4p4gD91I41E98Mz6kK22xy74D9N6Ov1gj3v4Ra2N80BUDrOkjG0 >									
	//        <  u =="0.000000000000000001" : ] 000000845373274.662750000000000000 ; 000000873729032.234296000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000509EFEF5353467 >									
	//     < RUSS_PFXXXVI_III_metadata_line_34_____RN_ASTRA_20251101 >									
	//        < C7Vj0p5G0miBV5EEPX6j73Zfv0A0Y0M1Rh136aV2yjpb7cc9iH4l50N2Vg02Y97h >									
	//        <  u =="0.000000000000000001" : ] 000000873729032.234296000000000000 ; 000000893354174.863966000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000053534675532679 >									
	//     < RUSS_PFXXXVI_III_metadata_line_35_____ASTRA_ORG_20251101 >									
	//        < s77D90smN2Iu5y0zbiYxfXI8d6UTfQqu7wiRn4UdklVZSg5r0QdE0Q2PEu69nvtQ >									
	//        <  u =="0.000000000000000001" : ] 000000893354174.863966000000000000 ; 000000914627084.442496000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000055326795739C34 >									
	//     < RUSS_PFXXXVI_III_metadata_line_36_____ROSNEFT_DEUTSCHLAND_GMBH_20251101 >									
	//        < Q1b2oM736nd4tbI3Kb29VphRdK46H81LqAYDrtUInhQg6OZkSvgSz4r0aVT6iXnt >									
	//        <  u =="0.000000000000000001" : ] 000000914627084.442496000000000000 ; 000000941752607.473413000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005739C3459D001D >									
	//     < RUSS_PFXXXVI_III_metadata_line_37_____ITERA_GROUP_LIMITED_20251101 >									
	//        < P6f2M031Rv7iuptc01WT6s6b575suGgU46m5Y60lnR78E9PI4YpTkk014D1099i5 >									
	//        <  u =="0.000000000000000001" : ] 000000941752607.473413000000000000 ; 000000964119408.120088000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000059D001D5BF2125 >									
	//     < RUSS_PFXXXVI_III_metadata_line_38_____SAMOTLORNEFTEGAZ_20251101 >									
	//        < O7QQKdHmW31Y9st737IRKM25JwdZ7u0gT85b4vMu7UaHCI4K8kh5WztrBcRTr4VO >									
	//        <  u =="0.000000000000000001" : ] 000000964119408.120088000000000000 ; 000000989195369.810607000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005BF21255E56471 >									
	//     < RUSS_PFXXXVI_III_metadata_line_39_____KUBANNEFTEPRODUCT_20251101 >									
	//        < 9Z5eELrPX12nj8ZZ4w6KMN706Nl95b7nQgd0360TCKTD9A0UMegi330iBwpG3Vpb >									
	//        <  u =="0.000000000000000001" : ] 000000989195369.810607000000000000 ; 000001008513503.130520000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005E56471602DE96 >									
	//     < RUSS_PFXXXVI_III_metadata_line_40_____KUBAN_ORG_20251101 >									
	//        < cMMNnxdx9l5uq5vYW9WjkdnlW6t7N0MR1sKnvdjLcpFl22MQ79FRomco69xx68J9 >									
	//        <  u =="0.000000000000000001" : ] 000001008513503.130520000000000000 ; 000001038844884.363090000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000602DE9663126C8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}