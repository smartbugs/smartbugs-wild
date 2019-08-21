pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXI_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXI_III_883		"	;
		string	public		symbol =	"	RUSS_PFXI_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1054250897049520000000000000					;	
										
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
	//     < RUSS_PFXI_III_metadata_line_1_____STRAKHOVOI_SINDIKAT_20251101 >									
	//        < Z427SCGN33dB199Xhe260jf91XrZOD8D01ONCCainQ7I4u0F7L0XH8k47sS2C0A4 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000018791631.614103000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001CAC7B >									
	//     < RUSS_PFXI_III_metadata_line_2_____MIKA_RG_20251101 >									
	//        < 8k0T2m75Vp4LzDQ1FRZbrZ7Y3S91UMXXZxoU1GO1UXSso9yDM1H0wBz5B826sOC5 >									
	//        <  u =="0.000000000000000001" : ] 000000018791631.614103000000000000 ; 000000042994918.488799100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001CAC7B419AE4 >									
	//     < RUSS_PFXI_III_metadata_line_3_____RESO_FINANCIAL_MARKETS_20251101 >									
	//        < 237Ll9Bn19222L3KqyIkxn1OjR1NsyHYA15mx1iDi19515N8wgAYtGi9ECoycqtL >									
	//        <  u =="0.000000000000000001" : ] 000000042994918.488799100000000000 ; 000000064355983.038429800000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000419AE462330E >									
	//     < RUSS_PFXI_III_metadata_line_4_____LIPETSK_INSURANCE_CHANCE_20251101 >									
	//        < zCdRv27K6YyyPi3I608hC7M9fQ1Qg6585TqiE5QvVl9dnkHS39vplPSgYGY10CEv >									
	//        <  u =="0.000000000000000001" : ] 000000064355983.038429800000000000 ; 000000095895714.541865400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000062330E925343 >									
	//     < RUSS_PFXI_III_metadata_line_5_____ALVENA_RESO_GROUP_20251101 >									
	//        < 8ArAIs71429r5RcFwHGieaV357bP7ElxG3B7LE7B025mj084r33JV45Vr2B5dEoR >									
	//        <  u =="0.000000000000000001" : ] 000000095895714.541865400000000000 ; 000000117704289.101458000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000925343B39A3D >									
	//     < RUSS_PFXI_III_metadata_line_6_____NADEZHNAYA_LIFE_INSURANCE_20251101 >									
	//        < cq4nLUzi5wbysHgwJcJ68x1ahb6U1d6s7iqMWE20831462M5K1y8C9X6J9Qg6O67 >									
	//        <  u =="0.000000000000000001" : ] 000000117704289.101458000000000000 ; 000000141238516.574863000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B39A3DD7834C >									
	//     < RUSS_PFXI_III_metadata_line_7_____MSK_URALSIB_20251101 >									
	//        < zpiytj6N9u5G1E9CH5uKTmYf290H3Qw4kdx0o65b1O92n471P049rmz50BWSmx2Y >									
	//        <  u =="0.000000000000000001" : ] 000000141238516.574863000000000000 ; 000000160400421.065045000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D7834CF4C06A >									
	//     < RUSS_PFXI_III_metadata_line_8_____SMO_SIBERIA_20251101 >									
	//        < 340LN455Is0NOUEyOEOFc952jH32MjnOhZqPmfL3z3gsfy0Z0YUq0kR8YtD4LGZZ >									
	//        <  u =="0.000000000000000001" : ] 000000160400421.065045000000000000 ; 000000195907563.337607000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F4C06A12AEE64 >									
	//     < RUSS_PFXI_III_metadata_line_9_____ALFASTRAKHOVANIE_LIFE_20251101 >									
	//        < pHb0xqEG6W12Jc42fN344TIx38dkTZxAHU3IJmEm6nSa6IcVZz2e32UU9Y9N08ER >									
	//        <  u =="0.000000000000000001" : ] 000000195907563.337607000000000000 ; 000000222561990.829425000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012AEE641539A47 >									
	//     < RUSS_PFXI_III_metadata_line_10_____AVERS_OOO_20251101 >									
	//        < GazrC35qA10DvDaosQSZShK8246dGE93555fh3pPQ3tL58FZRFtT8Zzg7Jmx6Ulz >									
	//        <  u =="0.000000000000000001" : ] 000000222561990.829425000000000000 ; 000000252259030.529030000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001539A47180EAAF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXI_III_metadata_line_11_____ALFASTRAKHOVANIE_PLC_20251101 >									
	//        < vLKOQ4Z0iz8vUXB55GO6CKZ6iddHK3plX3KKbf0t7Vq9Gb2Z21y2dp7pB5DGSt95 >									
	//        <  u =="0.000000000000000001" : ] 000000252259030.529030000000000000 ; 000000287597924.492162000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000180EAAF1B6D6F0 >									
	//     < RUSS_PFXI_III_metadata_line_12_____MIDITSINSKAYA_STRAKHOVAYA_KOMP_VIRMED_20251101 >									
	//        < 6lk1E6AI9akKPoL15927F2svkZPwoCjeG8ms8Ow0p29NoQul23xq6IV0NrrD64G9 >									
	//        <  u =="0.000000000000000001" : ] 000000287597924.492162000000000000 ; 000000316688305.351477000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B6D6F01E33A5F >									
	//     < RUSS_PFXI_III_metadata_line_13_____MSK_ASSTRA_20251101 >									
	//        < gCTSHB4oxf3Nnjv1NXcf2xK6d9796Ar1U1oVvt7wM98JS31zsq7x7u90T57I35M1 >									
	//        <  u =="0.000000000000000001" : ] 000000316688305.351477000000000000 ; 000000350943858.541571000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E33A5F2177F72 >									
	//     < RUSS_PFXI_III_metadata_line_14_____AVICOS_AFES_INSURANCE_20251101 >									
	//        < y0MVPr2h4omcWygz2KLuVGIZ6d7y551hWvdg80XSPxFpq99gMcFeVLNcqPL01poC >									
	//        <  u =="0.000000000000000001" : ] 000000350943858.541571000000000000 ; 000000375297816.316844000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002177F7223CA8B6 >									
	//     < RUSS_PFXI_III_metadata_line_15_____RUSSIA_AGRICULTURAL_BANK_20251101 >									
	//        < Vz1IiLFF6lVf68YkO1q295Lk680E4IisFUEL9dIBRHX2mF1tzTuc7fU1sf8jaE7c >									
	//        <  u =="0.000000000000000001" : ] 000000375297816.316844000000000000 ; 000000400462653.990943000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023CA8B62630EB9 >									
	//     < RUSS_PFXI_III_metadata_line_16_____BELOGLINSKI_ELEVATOR_20251101 >									
	//        < 6r6p48GRy5WNiR5h3t767q9Qi707QBU126dJFHva7o3Pz3E4wkzRuJDe785ZE0Zg >									
	//        <  u =="0.000000000000000001" : ] 000000400462653.990943000000000000 ; 000000422276122.264311000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002630EB9284579C >									
	//     < RUSS_PFXI_III_metadata_line_17_____RSHB_CAPITAL_20251101 >									
	//        < GIqC0k4Z7V6roVi28J5QOVN8Gn8BRm3S3edZRqQdsbpbSpQ2Jgrp3v7QvhWJv1um >									
	//        <  u =="0.000000000000000001" : ] 000000422276122.264311000000000000 ; 000000455422137.440102000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000284579C2B6EB46 >									
	//     < RUSS_PFXI_III_metadata_line_18_____ALBASHSKIY_ELEVATOR_20251101 >									
	//        < 08OSh68aD8N2t9QK4g7QDl2bBjF3qs0KFJRTEnTo6rMI9iukP2GCkD61DDZ4ZQvz >									
	//        <  u =="0.000000000000000001" : ] 000000455422137.440102000000000000 ; 000000473736129.457419000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B6EB462D2DD2D >									
	//     < RUSS_PFXI_III_metadata_line_19_____AGROTORG_TRADING_CO_20251101 >									
	//        < 2z3k1e3mekfB8ZTV89IT5oqSk301bdHC9YG5n1TGenG427EKz18mHw9vDl3A5b4V >									
	//        <  u =="0.000000000000000001" : ] 000000473736129.457419000000000000 ; 000000496443541.109804000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D2DD2D2F58342 >									
	//     < RUSS_PFXI_III_metadata_line_20_____HOMIAKOVSKIY_COLD_STORAGE_COMPLEX_20251101 >									
	//        < Asf85fYPC7391gLlgSR76m9IR5iq023x5p6BalTHV7B7BZ59DDsJ02UCsMkzDqr7 >									
	//        <  u =="0.000000000000000001" : ] 000000496443541.109804000000000000 ; 000000517482204.626121000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F583423159D7C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXI_III_metadata_line_21_____AGROCREDIT_INFORM_20251101 >									
	//        < 2Zc07b2Es0OwzdtGPP3LfuFB9j3suhDPZGchk0DX1313x39l00424FVImS87jvpX >									
	//        <  u =="0.000000000000000001" : ] 000000517482204.626121000000000000 ; 000000549407666.262706000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003159D7C346545F >									
	//     < RUSS_PFXI_III_metadata_line_22_____LADOSHSKIY_ELEVATOR_20251101 >									
	//        < lEKsPy40z1dQf02hQ0INuJC3ENzvr2Dceo9c7lO85gvny225kDwJWTO4jw2k8G6x >									
	//        <  u =="0.000000000000000001" : ] 000000549407666.262706000000000000 ; 000000574414498.927685000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000346545F36C7CAA >									
	//     < RUSS_PFXI_III_metadata_line_23_____VELICHKOVSKIY_ELEVATOR_20251101 >									
	//        < q38556g8r4Emj28CjYlAXiNXC03dr0skinxNoyBFXkxshG41tI960rsWSK284Q05 >									
	//        <  u =="0.000000000000000001" : ] 000000574414498.927685000000000000 ; 000000609994799.835445000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036C7CAA3A2C738 >									
	//     < RUSS_PFXI_III_metadata_line_24_____UMANSKIY_ELEVATOR_20251101 >									
	//        < 6tIS2r3Vp58656KA305ep54H7kxTDoKJoYMULrxBVwILQ5km17jcSO9rc099d1Ru >									
	//        <  u =="0.000000000000000001" : ] 000000609994799.835445000000000000 ; 000000629128161.610083000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A2C7383BFF930 >									
	//     < RUSS_PFXI_III_metadata_line_25_____MALOROSSIYSKIY_ELEVATOR_20251101 >									
	//        < 1L3iOu2lI5k9Zbw1B0p0U0PNrPJ8yflI1p51b1jaHry08Q798cQ2tqTaZSAb22fS >									
	//        <  u =="0.000000000000000001" : ] 000000629128161.610083000000000000 ; 000000652428381.957122000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003BFF9303E386D6 >									
	//     < RUSS_PFXI_III_metadata_line_26_____ROSSELKHOZBANK_DOMINANT_20251101 >									
	//        < 1k82e4k96cF390pbgHEcE2u2UlA0IO5Ox51Z03Jcio08ns211ZV7W0DBDxtwEam4 >									
	//        <  u =="0.000000000000000001" : ] 000000652428381.957122000000000000 ; 000000685136930.450852000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E386D64156F9D >									
	//     < RUSS_PFXI_III_metadata_line_27_____RAEVSAKHAR_20251101 >									
	//        < UG6PALkiCH9WbzTNsMlu009lrAPq8176wl71pYtaUKZY61743QDU7dGl1qT1uIGt >									
	//        <  u =="0.000000000000000001" : ] 000000685136930.450852000000000000 ; 000000720122764.131123000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004156F9D44AD1F4 >									
	//     < RUSS_PFXI_III_metadata_line_28_____OPTOVYE_TEKHNOLOGII_20251101 >									
	//        < c0gvTbVQaob3f0DYJR9WjT300Iz2pKm78cs4Y9o0XDInF7v57ggUF5iDf68ics0X >									
	//        <  u =="0.000000000000000001" : ] 000000720122764.131123000000000000 ; 000000744886673.783332000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044AD1F44709B5B >									
	//     < RUSS_PFXI_III_metadata_line_29_____EYANSKI_ELEVATOR_20251101 >									
	//        < 2K3kwJeLb5ig6WKCP9742zQv9xdkq3Y0K9NxLInDUhfjSoaoWOCD47r8N5swlz9y >									
	//        <  u =="0.000000000000000001" : ] 000000744886673.783332000000000000 ; 000000770280082.387970000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004709B5B4975AA8 >									
	//     < RUSS_PFXI_III_metadata_line_30_____RUSSIAN_AGRARIAN_FUEL_CO_20251101 >									
	//        < V92Nujt1yuqAV8aqfMraX0uusQ8xJk3DLfMpx78LXBZw0cu086wD9gQgKLgW7050 >									
	//        <  u =="0.000000000000000001" : ] 000000770280082.387970000000000000 ; 000000803029634.844571000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004975AA84C95373 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXI_III_metadata_line_31_____KHOMYAKOVSKY_KHLADOKOMBINAT_20251101 >									
	//        < 38n4riQy77n5zls0fP9A4WPM832hd6boy18XZID3TD9u81zvsx9VKwwm8DC4DdF5 >									
	//        <  u =="0.000000000000000001" : ] 000000803029634.844571000000000000 ; 000000830521961.912672000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004C953734F346A4 >									
	//     < RUSS_PFXI_III_metadata_line_32_____STEPNYANSKIY_ELEVATOR_20251101 >									
	//        < q195JyzhF0b2o7vYvEunO92W8BE4XrTnWF0q8wciNsDPal96D8B69GoSb0UjfckW >									
	//        <  u =="0.000000000000000001" : ] 000000830521961.912672000000000000 ; 000000851579802.792898000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004F346A4513685C >									
	//     < RUSS_PFXI_III_metadata_line_33_____ROVNENSKIY_ELEVATOR_20251101 >									
	//        < 1440IQkYBq7Zr40a5XAY1pZos78a72Yq0wF7KCjCi0wq3o069u8Zkj0v28q7z4OW >									
	//        <  u =="0.000000000000000001" : ] 000000851579802.792898000000000000 ; 000000872833769.326588000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000513685C533D6B1 >									
	//     < RUSS_PFXI_III_metadata_line_34_____KHOMYAKOVSKIY_COLD_STORAGE_FACILITY_20251101 >									
	//        < 497ej61xW0q30Vtz2L3gD9DIDRq80T9K40McuGiKoxc3q5984LW90U2GsnXnM99s >									
	//        <  u =="0.000000000000000001" : ] 000000872833769.326588000000000000 ; 000000898330901.199223000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000533D6B155ABE82 >									
	//     < RUSS_PFXI_III_metadata_line_35_____BRIGANTINA_OOO_20251101 >									
	//        < 4kpq7rio1mKlD1I45aVXtx7J3uO1gzWV25A6OwS4a7nJ1Pgsl1zPr0c1P2iV5ODQ >									
	//        <  u =="0.000000000000000001" : ] 000000898330901.199223000000000000 ; 000000918538119.473603000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000055ABE8257993F4 >									
	//     < RUSS_PFXI_III_metadata_line_36_____RUS_AGRICULTURAL_BANK_AM_ARM_20251101 >									
	//        < rqgFaP720cm0C6h1r1J743E5Z14829Q7Rp9007mlKU13i42f2SnID118Lh47f6Mf >									
	//        <  u =="0.000000000000000001" : ] 000000918538119.473603000000000000 ; 000000949110249.902403000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000057993F45A83A31 >									
	//     < RUSS_PFXI_III_metadata_line_37_____LUZHSKIY_FEEDSTUFF_PLANT_20251101 >									
	//        < M3b1F53DRgT6y1YNpvDB2VxTKPSHH0v06WFSl5iwM96ihza6SFuo0xEZQR0i6Y5Z >									
	//        <  u =="0.000000000000000001" : ] 000000949110249.902403000000000000 ; 000000976006371.995578000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005A83A315D1447D >									
	//     < RUSS_PFXI_III_metadata_line_38_____LUZHSKIY_MYASOKOMBINAT_20251101 >									
	//        < r5IIrHLz4Zpd52WkC1hDAxNB2KPKU6kBoumD0K2ZslCZ8gFt59hG8R2K955oi9Bi >									
	//        <  u =="0.000000000000000001" : ] 000000976006371.995578000000000000 ; 000001007007298.976190000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005D1447D600923A >									
	//     < RUSS_PFXI_III_metadata_line_39_____LUGA_FODDER_PLANT_20251101 >									
	//        < k2SdL7Z3w21Z9Ygg3dSw51L4D5iFJ8aLWz1vYfXJyVgvcRcOjq9pi398qN9f67X3 >									
	//        <  u =="0.000000000000000001" : ] 000001007007298.976190000000000000 ; 000001029145041.049190000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000600923A62259C8 >									
	//     < RUSS_PFXI_III_metadata_line_40_____KRILOVSKIY_ELEVATOR_20251101 >									
	//        < 3tXTO6vwxVeediWEj2rzPJ84Bni09K25r2I3T7tsf3HIF18Y7DkybxuraGH1grD0 >									
	//        <  u =="0.000000000000000001" : ] 000001029145041.049190000000000000 ; 000001054250897.049520000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000062259C8648A8C2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}