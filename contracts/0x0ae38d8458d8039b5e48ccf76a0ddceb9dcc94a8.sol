pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXIV_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXIV_II_883		"	;
		string	public		symbol =	"	RUSS_PFXXIV_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		792519793159009000000000000					;	
										
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
	//     < RUSS_PFXXIV_II_metadata_line_1_____ALFASTRAKHOVANIE_20231101 >									
	//        < Oax03K75o9I283yReBg1f53WnB24i0rW0H5P109tW3Z7ciW0T357uMgxjQ2q29E8 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000016417329.998510900000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000190D05 >									
	//     < RUSS_PFXXIV_II_metadata_line_2_____ALFA_DAO_20231101 >									
	//        < n9wa4e1E0LByq49604edmTMy3U2xetN84QP6u06g3jw097T2L81BC2p091hT1kfE >									
	//        <  u =="0.000000000000000001" : ] 000000016417329.998510900000000000 ; 000000038616667.535204200000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000190D053AECA3 >									
	//     < RUSS_PFXXIV_II_metadata_line_3_____ALFA_DAOPI_20231101 >									
	//        < GWwYmC7V4EP3HXEM3fWU7O2Z7BFt13rRcnFjXEH8ysmPV3NiqG69FOC1e2gAsKGM >									
	//        <  u =="0.000000000000000001" : ] 000000038616667.535204200000000000 ; 000000063346097.625443800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003AECA360A892 >									
	//     < RUSS_PFXXIV_II_metadata_line_4_____ALFA_DAC_20231101 >									
	//        < LgUi59zHo4Jq74tT3xWAq1v9CYu85y7r9s39iKNx87vIv236HRtNLSb0Y8o1StOp >									
	//        <  u =="0.000000000000000001" : ] 000000063346097.625443800000000000 ; 000000088022201.296572500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000060A892864FAC >									
	//     < RUSS_PFXXIV_II_metadata_line_5_____ALFA_BIMI_20231101 >									
	//        < 7TD4tpXzA8Em0ry5AROWoNkJ3kd6y9S9XUD4As1dbLiv2UEAmtPmOFuTciyZ2U3p >									
	//        <  u =="0.000000000000000001" : ] 000000088022201.296572500000000000 ; 000000111175552.412070000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000864FACA9A3F3 >									
	//     < RUSS_PFXXIV_II_metadata_line_6_____SMO_SIBERIA_20231101 >									
	//        < l4a48d9tk28fn586ReK3j6X8OIdFkB9hTgXUw0iN9fX1iWQzZ6EFA986OfeJIyFx >									
	//        <  u =="0.000000000000000001" : ] 000000111175552.412070000000000000 ; 000000127363897.025312000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A9A3F3C25786 >									
	//     < RUSS_PFXXIV_II_metadata_line_7_____SIBERIA_DAO_20231101 >									
	//        < QFW7RSxaC125GKyPu4XD463wvVG7I9wUT2F27W3EDkg0S31UeHwFFB7870pBA8Qu >									
	//        <  u =="0.000000000000000001" : ] 000000127363897.025312000000000000 ; 000000148540759.931991000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C25786E2A7BC >									
	//     < RUSS_PFXXIV_II_metadata_line_8_____SIBERIA_DAOPI_20231101 >									
	//        < 0XhIbP0f8CpYwXre4JFe6ZR6NJ2dVmcjMX91nNf0Vbbv22Vo97DPSm9ZcskauhPL >									
	//        <  u =="0.000000000000000001" : ] 000000148540759.931991000000000000 ; 000000165051164.300834000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E2A7BCFBD91C >									
	//     < RUSS_PFXXIV_II_metadata_line_9_____SIBERIA_DAC_20231101 >									
	//        < qq4lX1PJVX9F5cD17uG521xRiX9C0loO2lrj2H6JDIB9H75t58opwmJoaQ10NM89 >									
	//        <  u =="0.000000000000000001" : ] 000000165051164.300834000000000000 ; 000000182408370.132553000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FBD91C1165545 >									
	//     < RUSS_PFXXIV_II_metadata_line_10_____SIBERIA_BIMI_20231101 >									
	//        < 54ao2zTb59a0oEm2nnb5o9GP4T9Gg21X4V6K2f5l8A5VNLhNv8FG350Mzf7x5oZ3 >									
	//        <  u =="0.000000000000000001" : ] 000000182408370.132553000000000000 ; 000000202861473.420384000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011655451358AC3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXIV_II_metadata_line_11_____ALFASTRAKHOVANIE_LIFE_20231101 >									
	//        < TVikt5HI60ILr767596T9iZ0ht7VGOlRry8tH0jbGrDYndUT0C2cmfJ3B2e7Hj22 >									
	//        <  u =="0.000000000000000001" : ] 000000202861473.420384000000000000 ; 000000221011002.002595000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001358AC31513C6C >									
	//     < RUSS_PFXXIV_II_metadata_line_12_____ALFA_LIFE_DAO_20231101 >									
	//        < bp6Rq8mY445d7hX2430YYooYiNmxE1H416XTiVeC56h8DvbszJSRsJPYm3hcXQrv >									
	//        <  u =="0.000000000000000001" : ] 000000221011002.002595000000000000 ; 000000237634719.103105000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001513C6C16A9A10 >									
	//     < RUSS_PFXXIV_II_metadata_line_13_____ALFA_LIFE_DAOPI_20231101 >									
	//        < z3s4MMcW2mR0t0grDoZd4D9VH3L073O2F9znRs52as395ftqO15pT51R19qqGKpm >									
	//        <  u =="0.000000000000000001" : ] 000000237634719.103105000000000000 ; 000000256472444.292328000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016A9A10187588C >									
	//     < RUSS_PFXXIV_II_metadata_line_14_____ALFA_LIFE_DAC_20231101 >									
	//        < 7fc9MKZuI6Je5WF8Y2zg7021xYpFGcE793k4472Cfxw66XSp1sor51hdGmsnwaCk >									
	//        <  u =="0.000000000000000001" : ] 000000256472444.292328000000000000 ; 000000271917447.209354000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000187588C19EE9C1 >									
	//     < RUSS_PFXXIV_II_metadata_line_15_____ALFA_LIFE_BIMI_20231101 >									
	//        < 3ncCbVcN4z59TDikMKzTIxa4Xu0k4vMQ27e471xoFdnw9OetPxbWStixgxr438Xw >									
	//        <  u =="0.000000000000000001" : ] 000000271917447.209354000000000000 ; 000000294372108.734802000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019EE9C11C12D1B >									
	//     < RUSS_PFXXIV_II_metadata_line_16_____ALFASTRAKHOVANIE_AVERS_20231101 >									
	//        < aG78Jp3B9Hxw0k1f9x35cGI45F21dSP61za4HeHGO9D8w1lMFFL8Az6vcy7IkvTP >									
	//        <  u =="0.000000000000000001" : ] 000000294372108.734802000000000000 ; 000000316364607.375739000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C12D1B1E2BBED >									
	//     < RUSS_PFXXIV_II_metadata_line_17_____AVERS_DAO_20231101 >									
	//        < 47f9DFtZreMqCh4l7N0ITIMvteF7I3So8rm22qCpv3m2Fq9mD4Y3HtO1g9DV084F >									
	//        <  u =="0.000000000000000001" : ] 000000316364607.375739000000000000 ; 000000334719915.326089000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E2BBED1FEBDF8 >									
	//     < RUSS_PFXXIV_II_metadata_line_18_____AVERS_DAOPI_20231101 >									
	//        < L5F05N59Ocn1ZIuvfG86r9lNzjynz95OE23f39OAVO7K8x1C3yhex7q22Xb6M4pd >									
	//        <  u =="0.000000000000000001" : ] 000000334719915.326089000000000000 ; 000000354918755.561358000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FEBDF821D9024 >									
	//     < RUSS_PFXXIV_II_metadata_line_19_____AVERS_DAC_20231101 >									
	//        < cveep350z7x88W944CSlT2BYx95DVycH0421ek1B0IAsU1TVoT9YJNRtO9E6gpg6 >									
	//        <  u =="0.000000000000000001" : ] 000000354918755.561358000000000000 ; 000000372292478.536944000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021D902423812C0 >									
	//     < RUSS_PFXXIV_II_metadata_line_20_____AVERS_BIMI_20231101 >									
	//        < W1UrK91iJeM0xhKCNzZ2WG4xL0VFOb416DSkAOeUjjmM281YQ5zZ21D4105h7f88 >									
	//        <  u =="0.000000000000000001" : ] 000000372292478.536944000000000000 ; 000000391535625.832875000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023812C02556F9B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXIV_II_metadata_line_21_____ALFASTRAKHOVANIE_PLC_20231101 >									
	//        < vpuV7Y7GIioBPajBzTS5ie3W9E6o0f3OS3O59ZG1lbJJ22X2wWaLDZFGMbly6652 >									
	//        <  u =="0.000000000000000001" : ] 000000391535625.832875000000000000 ; 000000413732501.131512000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002556F9B2774E42 >									
	//     < RUSS_PFXXIV_II_metadata_line_22_____ALFASTRA_DAO_20231101 >									
	//        < 008X74owq53Nox4PAS1ufxF5V898fj90vOaX8tqqHA1E30pJOVA0R6YQ986fVkFr >									
	//        <  u =="0.000000000000000001" : ] 000000413732501.131512000000000000 ; 000000435565289.492534000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002774E422989EB1 >									
	//     < RUSS_PFXXIV_II_metadata_line_23_____ALFASTRA_DAOPI_20231101 >									
	//        < t7uxMwtHmnJVGkr8IciuUU0pVQ7yZ7A7m4xgUVDs2420fmn0x6xVO7LrlG00NxM5 >									
	//        <  u =="0.000000000000000001" : ] 000000435565289.492534000000000000 ; 000000458750398.098953000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002989EB12BBFF60 >									
	//     < RUSS_PFXXIV_II_metadata_line_24_____ALFASTRA_DAC_20231101 >									
	//        < z9qEUe1V7aC7Jf4C8m49lG1T3gyYV84zg4dJA582yPIturZGOZDKi0763hGTzFCV >									
	//        <  u =="0.000000000000000001" : ] 000000458750398.098953000000000000 ; 000000477870797.617751000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BBFF602D92C48 >									
	//     < RUSS_PFXXIV_II_metadata_line_25_____ALFASTRA_BIMI_20231101 >									
	//        < MXSrqJAEIjH9yudwmEuy6gW18PP4B8Dh796JZc4bN8b6Pt65C4101688pY80zR35 >									
	//        <  u =="0.000000000000000001" : ] 000000477870797.617751000000000000 ; 000000496481679.660000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D92C482F59228 >									
	//     < RUSS_PFXXIV_II_metadata_line_26_____MEDITSINSKAYA_STRAKHOVAYA_KOMP_VIRMED_20231101 >									
	//        < jTNBOSWx4IydHeG40Iw27mvwx7UbqOtFFv01uQI4wr94f9a4P7ncAsZ2hpX5Io68 >									
	//        <  u =="0.000000000000000001" : ] 000000496481679.660000000000000000 ; 000000517178310.921082000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F5922831526C7 >									
	//     < RUSS_PFXXIV_II_metadata_line_27_____VIRMED_DAO_20231101 >									
	//        < 66S5oDc0H633XBZ3Z64oR24ShGKv8yP8sPO1kFa6fUMzXsarblVRl3XRW4Vqj17E >									
	//        <  u =="0.000000000000000001" : ] 000000517178310.921082000000000000 ; 000000540706971.570198000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031526C73390DA9 >									
	//     < RUSS_PFXXIV_II_metadata_line_28_____VIRMED_DAOPI_20231101 >									
	//        < Qo7xNgUb8NB0lphiH6HW7c9ykAb6E83WZ7HOl3iTzU2S56Inpx5we8pxa0K3N1q1 >									
	//        <  u =="0.000000000000000001" : ] 000000540706971.570198000000000000 ; 000000565496131.143225000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003390DA935EE0ED >									
	//     < RUSS_PFXXIV_II_metadata_line_29_____VIRMED_DAC_20231101 >									
	//        < eS3K0QY86NGg42Z0G1Kw9NihRp4RVjTg88LV2bm6KpAsNxtVJQZRBZs676l9B0dw >									
	//        <  u =="0.000000000000000001" : ] 000000565496131.143225000000000000 ; 000000582945235.705385000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035EE0ED37980FC >									
	//     < RUSS_PFXXIV_II_metadata_line_30_____VIRMED_BIMI_20231101 >									
	//        < Vn8ecaGwWW6NF7S8ec4GE9yWI2QLFd6Fg8a0gW1CJYNr3c9ilsL9jpvf8OH81wy9 >									
	//        <  u =="0.000000000000000001" : ] 000000582945235.705385000000000000 ; 000000600788952.074354000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037980FC394BB2F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXIV_II_metadata_line_31_____MSK_ASSTRA_20231101 >									
	//        < B4V00YiMano5S4fL9PUHq66D76010iwyFF9y9Lg30L7I2Q8e340g6pRuWj8sT70r >									
	//        <  u =="0.000000000000000001" : ] 000000600788952.074354000000000000 ; 000000623817336.095239000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000394BB2F3B7DEA6 >									
	//     < RUSS_PFXXIV_II_metadata_line_32_____ASSTRA_DAO_20231101 >									
	//        < 70B1SHXgEjyfvu20rAL0l9iaSUQv4222YRiHSUu1fAUbCC8iUjOG7PYeba8mA7V4 >									
	//        <  u =="0.000000000000000001" : ] 000000623817336.095239000000000000 ; 000000644171965.656131000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B7DEA63D6EDAD >									
	//     < RUSS_PFXXIV_II_metadata_line_33_____ASSTRA_DAOPI_20231101 >									
	//        < kbfK67fwPp641z8CiXoZNbv63WcBb16MC99O63u5r3mo0IJIiZWN4ZW3or29iB5O >									
	//        <  u =="0.000000000000000001" : ] 000000644171965.656131000000000000 ; 000000661997972.263010000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D6EDAD3F220F5 >									
	//     < RUSS_PFXXIV_II_metadata_line_34_____ASSTRA_DAC_20231101 >									
	//        < kk3lV243T1X31Pg9oJvOCIj6l1M9UU3c22m2qd7cnS0xm160QXzVb3NmX1I79K1j >									
	//        <  u =="0.000000000000000001" : ] 000000661997972.263010000000000000 ; 000000678217639.871391000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F220F540AE0C4 >									
	//     < RUSS_PFXXIV_II_metadata_line_35_____ASSTRA_BIMI_20231101 >									
	//        < jzU5D4YPi7SWZd7VWk8GpOl4ZAUhgZrz7kGihCC56A7e1GQDIwqyuC1c1dKU5VL4 >									
	//        <  u =="0.000000000000000001" : ] 000000678217639.871391000000000000 ; 000000695954696.364195000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040AE0C4425F14E >									
	//     < RUSS_PFXXIV_II_metadata_line_36_____AVICOS_AFES_INSURANCE_GROUP_20231101 >									
	//        < ao85q7Mz3e6w0FBtKSR0QheX96QHYN2CjC4P51IPlHW2ZD12eT67InZsmo5305Vc >									
	//        <  u =="0.000000000000000001" : ] 000000695954696.364195000000000000 ; 000000712165778.600852000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000425F14E43EADC2 >									
	//     < RUSS_PFXXIV_II_metadata_line_37_____AVICOS_DAO_20231101 >									
	//        < Pq1gIGk9JIn5Vr7FzirC1EaSj1ha9a8h3nLQL5svkT7ViAqW4mom6yO1Y767Cn60 >									
	//        <  u =="0.000000000000000001" : ] 000000712165778.600852000000000000 ; 000000735779088.336977000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000043EADC2462B5B5 >									
	//     < RUSS_PFXXIV_II_metadata_line_38_____AVICOS_DAOPI_20231101 >									
	//        < 5Y7qH2uxndT3248TB7d940uOYxSiY4rh21sqt5okSDRxGDRmglhb38620lSfu55h >									
	//        <  u =="0.000000000000000001" : ] 000000735779088.336977000000000000 ; 000000755794716.555455000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000462B5B54814050 >									
	//     < RUSS_PFXXIV_II_metadata_line_39_____AVICOS_DAC_20231101 >									
	//        < mY4mKFI62v1M0BF0Z62GW958074189Zurog5e65W474fIFd7F34mCbJbL6423sHQ >									
	//        <  u =="0.000000000000000001" : ] 000000755794716.555455000000000000 ; 000000772732021.282954000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000481405049B1872 >									
	//     < RUSS_PFXXIV_II_metadata_line_40_____AVICOS_BIMI_20231101 >									
	//        < 0SnAnD5oz91x46C9m6jNxc2WYBLFjCLl0222wED82oMYbHh1q3qFOWwh453pxRF1 >									
	//        <  u =="0.000000000000000001" : ] 000000772732021.282954000000000000 ; 000000792519793.159009000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049B18724B94A0B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}