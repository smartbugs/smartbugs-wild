pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFVI_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFVI_I_883		"	;
		string	public		symbol =	"	NDRV_PFVI_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		743409861810792000000000000					;	
										
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
	//     < NDRV_PFVI_I_metadata_line_1_____Hannover_Re_20211101 >									
	//        < 8hlcBfe0k8f4zysAVYe3BOwH2aNot2bBUkr0BLSDT5iD18M43DG7C7qjM9nyddP3 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000023418776.587192300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000023BBF6 >									
	//     < NDRV_PFVI_I_metadata_line_2_____International Insurance Company of Hannover SE_20211101 >									
	//        < J5K3NnT5cz4J5jFLJ5Txpg0OU9c48qZ2v213No7Tlro24f89301s7A1D150cwgc7 >									
	//        <  u =="0.000000000000000001" : ] 000000023418776.587192300000000000 ; 000000040813913.556725200000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000023BBF63E46EF >									
	//     < NDRV_PFVI_I_metadata_line_3_____Hannover Life Reassurance Company of America_20211101 >									
	//        < 4ik7XUCW6U36vzP47B4ROK50neJlhTBzuX5mhbkbzWumo6iF9Ub2Ybz44VxkVY95 >									
	//        <  u =="0.000000000000000001" : ] 000000040813913.556725200000000000 ; 000000062377967.646944800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003E46EF5F2E65 >									
	//     < NDRV_PFVI_I_metadata_line_4_____Hannover Reinsurance_20211101 >									
	//        < nHyqL964Ig33ZT7TxiCtnsJ8zOy48nP0j8xQeJ0f2483XW1K6inpXuON2bRNiu81 >									
	//        <  u =="0.000000000000000001" : ] 000000062377967.646944800000000000 ; 000000077118454.042802700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005F2E6575AC65 >									
	//     < NDRV_PFVI_I_metadata_line_5_____Clarendon Insurance Group Inc_20211101 >									
	//        < 4WQ70Em5Nxa8TN1gT68C5v3Bef20KAn6zP1nVja2D10IgFkqR7q7J3KxrMg6WIz2 >									
	//        <  u =="0.000000000000000001" : ] 000000077118454.042802700000000000 ; 000000091164362.485341700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000075AC658B1B14 >									
	//     < NDRV_PFVI_I_metadata_line_6_____Argenta Holdings plc_20211101 >									
	//        < O8zhqI2uVwG0q62abZE3u1Z0x1yr31J25bPc4j1e33GDjP1gCPuB9YN3eDQWwdgB >									
	//        <  u =="0.000000000000000001" : ] 000000091164362.485341700000000000 ; 000000104877703.232926000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008B1B14A007DA >									
	//     < NDRV_PFVI_I_metadata_line_7_____Argenta Syndicate Management Limited_20211101 >									
	//        < 0sePLbl9NI72sf878PDW30T6r6cVer89HZJq900LOsEGs4U1eafg7Q13WHyjNFe2 >									
	//        <  u =="0.000000000000000001" : ] 000000104877703.232926000000000000 ; 000000124439343.512811000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A007DABDE11E >									
	//     < NDRV_PFVI_I_metadata_line_8_____Argenta Private Capital Limited_20211101 >									
	//        < nxN767PyRhd4HyXY75Z32Y78mX8BqF9nq5w2369sYOjP9eW16kG8nZWGJsU1N4m2 >									
	//        <  u =="0.000000000000000001" : ] 000000124439343.512811000000000000 ; 000000150103455.271710000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BDE11EE50A2A >									
	//     < NDRV_PFVI_I_metadata_line_9_____Argenta Tax & Corporate Services Limited_20211101 >									
	//        < SFqIOZK5qSozm85rHrQ5k4AaqpXFEYjsWQ0Gg911VglOLH2BF8v985n4I11hym51 >									
	//        <  u =="0.000000000000000001" : ] 000000150103455.271710000000000000 ; 000000168665940.051404000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E50A2A1015D22 >									
	//     < NDRV_PFVI_I_metadata_line_10_____Hannover Life Re AG_20211101 >									
	//        < e17evP0uH83n53slezAb6H38yP34lw5463MNp3N0997rP5QMyo8f1WRc94VdP47h >									
	//        <  u =="0.000000000000000001" : ] 000000168665940.051404000000000000 ; 000000184725053.440398000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001015D22119DE39 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFVI_I_metadata_line_11_____Hannover Life Re of Australasia Ltd_20211101 >									
	//        < U68Ko6az806cx3qHv9fZhC285w5XGFE18cu84q2YUI1uQ45Ek6l5e672FFyN5amy >									
	//        <  u =="0.000000000000000001" : ] 000000184725053.440398000000000000 ; 000000204286942.885720000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000119DE39137B796 >									
	//     < NDRV_PFVI_I_metadata_line_12_____Hannover Life Re of Australasia Ltd New Zealand_20211101 >									
	//        < xn01395t3p64xzzrIX2328Re4x3hf0dfPFljTVah71FG36OUOvq41g5dBwiv2WlT >									
	//        <  u =="0.000000000000000001" : ] 000000204286942.885720000000000000 ; 000000225130726.878783000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000137B79615785B1 >									
	//     < NDRV_PFVI_I_metadata_line_13_____Hannover Re Ireland Designated Activity Company_20211101 >									
	//        < JR7QwS20k4w555DbwEsM7xO4for6Uqkx0o04LfDV73B689e1Wq0sDexKime0v8sx >									
	//        <  u =="0.000000000000000001" : ] 000000225130726.878783000000000000 ; 000000245118799.460504000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015785B11760588 >									
	//     < NDRV_PFVI_I_metadata_line_14_____Hannover Re Guernsey PCC Limited_20211101 >									
	//        < oM0Oareg28wPWuJimE3s30S6JX21MrwAgYs0dp9cLW81Ny7z76R7ZjSMQP62kv3F >									
	//        <  u =="0.000000000000000001" : ] 000000245118799.460504000000000000 ; 000000258293775.061058000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000176058818A2002 >									
	//     < NDRV_PFVI_I_metadata_line_15_____Hannover Re Euro RE Holdings GmbH_20211101 >									
	//        < Dmvdv1Fg5XZ951I34IxXFI6KD8m88ZzeG56f4L2ZPD7Mh59m9bT2M9btI9UZShCV >									
	//        <  u =="0.000000000000000001" : ] 000000258293775.061058000000000000 ; 000000281646926.622341000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018A20021ADC255 >									
	//     < NDRV_PFVI_I_metadata_line_16_____Skandia Portfolio Management GmbH_20211101 >									
	//        < KRNSN3AcB8ic5uBQ90X2ZNyFNMcG6Cep56TY2I1x10mu0F3F068niarVS1lohPuu >									
	//        <  u =="0.000000000000000001" : ] 000000281646926.622341000000000000 ; 000000297304754.554171000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001ADC2551C5A6AB >									
	//     < NDRV_PFVI_I_metadata_line_17_____Skandia Lebensversicherung AG_20211101 >									
	//        < fb0jGQ3HC7dH8tf3IW0uw5EbK2c7NzmF8flG6KGW1ut1784wztp3Tq1Rt265987c >									
	//        <  u =="0.000000000000000001" : ] 000000297304754.554171000000000000 ; 000000311089681.628032000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C5A6AB1DAAF68 >									
	//     < NDRV_PFVI_I_metadata_line_18_____Hannover Life Reassurance Bermuda Ltd_20211101 >									
	//        < 1WoR74NMjc5eo7s1nk9r5IPaWEYTK59m006DflU4NWY8RB9Wy1I1LFaS71Ojd6yt >									
	//        <  u =="0.000000000000000001" : ] 000000311089681.628032000000000000 ; 000000336199716.055087000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DAAF682010004 >									
	//     < NDRV_PFVI_I_metadata_line_19_____Hannover Re Services Japan KK_20211101 >									
	//        < o4W4wI9vxz58qSb02tk2b4Q6hj258r3Gb6a3fb4D8lA0K78T4lp07E2t4ecPr9T3 >									
	//        <  u =="0.000000000000000001" : ] 000000336199716.055087000000000000 ; 000000349736273.829617000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002010004215A7BB >									
	//     < NDRV_PFVI_I_metadata_line_20_____Hannover Finance Inc_20211101 >									
	//        < v4nGqsPtK6J8N9mo82b9U0b7JLnG2PwU34m4VBx5H9Jje967H0xQ85rFm4Xpp978 >									
	//        <  u =="0.000000000000000001" : ] 000000349736273.829617000000000000 ; 000000373966626.002661000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000215A7BB23AA0B7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFVI_I_metadata_line_21_____Atlantic Capital Corp_20211101 >									
	//        < p3Y21003rfjL2cGM3wH2HD1Z3x5nJC34BE7liTmv8YFbS1803zg9noB5ROvHPT56 >									
	//        <  u =="0.000000000000000001" : ] 000000373966626.002661000000000000 ; 000000387089252.778285000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023AA0B724EA6BD >									
	//     < NDRV_PFVI_I_metadata_line_22_____Hannover Re Bermuda Ltd_20211101 >									
	//        < 5fc28tZX0kxR7e24CSnaOIlVYw1h2QIu4ecR5Z1h1i3W8eACrn6I3Br14RYopRJk >									
	//        <  u =="0.000000000000000001" : ] 000000387089252.778285000000000000 ; 000000412434692.316941000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024EA6BD275534D >									
	//     < NDRV_PFVI_I_metadata_line_23_____Hannover Re Consulting Services India Private Limited_20211101 >									
	//        < m24pFj0q67Q0DMWti5V5E5Njjy27UP03DD9d7N1nkxTB0V25R43ZKD7RpJ2Wt468 >									
	//        <  u =="0.000000000000000001" : ] 000000412434692.316941000000000000 ; 000000428098094.820377000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000275534D28D39D1 >									
	//     < NDRV_PFVI_I_metadata_line_24_____HDI Global Specialty SE_20211101 >									
	//        < pb2EfIm6q3QL29OtgIXQB8CI76y6iBKekPVKVKCw8i8xVy7AzviKIR47cV04Iy0P >									
	//        <  u =="0.000000000000000001" : ] 000000428098094.820377000000000000 ; 000000447480667.276588000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028D39D12AACD23 >									
	//     < NDRV_PFVI_I_metadata_line_25_____Hannover Services México SA de CV_20211101 >									
	//        < Q70nhssl55uENCg4x3Da87FNI3zm50yKttGhW4lMzb2p6Z4Dg1V8698wP28TcME3 >									
	//        <  u =="0.000000000000000001" : ] 000000447480667.276588000000000000 ; 000000472659112.428697000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AACD232D13877 >									
	//     < NDRV_PFVI_I_metadata_line_26_____Hannover Re Real Estate Holdings Inc_20211101 >									
	//        < 4ZTwJp0r5C7J537q1HEBT6eP0VUXr2rElenXOAgEmG03j12c9CS17Ey7voZM776e >									
	//        <  u =="0.000000000000000001" : ] 000000472659112.428697000000000000 ; 000000498386915.514868000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D138772F87A64 >									
	//     < NDRV_PFVI_I_metadata_line_27_____GLL HRE Core Properties LP_20211101 >									
	//        < u55oJbAghF52LC1fUcLjgZ857A0Rz8u6uEkCpdlJ04c38Oy8r9x7pn07HsD5YUmV >									
	//        <  u =="0.000000000000000001" : ] 000000498386915.514868000000000000 ; 000000512208437.350474000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F87A6430D916C >									
	//     < NDRV_PFVI_I_metadata_line_28_____Broadway101 Office Park Inc_20211101 >									
	//        < Bi47Y6xuiJtb05l7HcQi0f4yfQb8JMYTHx7BUUVG7Rc06cx5o7d93l43r5IA1gQO >									
	//        <  u =="0.000000000000000001" : ] 000000512208437.350474000000000000 ; 000000530207933.547349000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030D916C3290879 >									
	//     < NDRV_PFVI_I_metadata_line_29_____Broadway 101 LLC_20211101 >									
	//        < kL1biYyWZeACiFxn0cnWYIV9F14a7UXP9UYkWOFIAfRJ6PFr1jPGNfSo1q2cQAHi >									
	//        <  u =="0.000000000000000001" : ] 000000530207933.547349000000000000 ; 000000544022668.292347000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000329087933E1CDB >									
	//     < NDRV_PFVI_I_metadata_line_30_____5115 Sedge Corporation_20211101 >									
	//        < 8NALNtJln4081tfh4bHmT4B4eGu9Vfx7B7Wgxf0pr2S7mqVr1IjcFuRHZ532tuL5 >									
	//        <  u =="0.000000000000000001" : ] 000000544022668.292347000000000000 ; 000000561386883.163478000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033E1CDB3589BC0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFVI_I_metadata_line_31_____Hannover Re Euro Pe Holdings Gmbh & Co Kg_20211101 >									
	//        < gtR3YM69ESngx7802B5IV6XOhnKw05RWOZ3gIbv24DPVR84fr8CqdwKM5EYZ9yJd >									
	//        <  u =="0.000000000000000001" : ] 000000561386883.163478000000000000 ; 000000582160163.098432000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003589BC03784E50 >									
	//     < NDRV_PFVI_I_metadata_line_32_____Compass Insurance Company Ltd_20211101 >									
	//        < P86WiE426y6nA233Jveo9lz846s8P4jX89Z74XbTCeDii2Rs4rn6Hd9pb8an4wMQ >									
	//        <  u =="0.000000000000000001" : ] 000000582160163.098432000000000000 ; 000000599371458.356071000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003784E50392917A >									
	//     < NDRV_PFVI_I_metadata_line_33_____Commercial & Industrial Acceptances Pty Ltd_20211101 >									
	//        < nSl6BJbLh6ft8R0Wy0k6u8P1s1jwg31o1pl08vdSL1C67Z1k3sn60La0i164zg56 >									
	//        <  u =="0.000000000000000001" : ] 000000599371458.356071000000000000 ; 000000614582451.690861000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000392917A3A9C745 >									
	//     < NDRV_PFVI_I_metadata_line_34_____Kaith Re Ltd_20211101 >									
	//        < M9A61rVnptfbVHD07P33zCgDxF0x65783UD7UWf8w439NT88oeF22FfH5r9WXt70 >									
	//        <  u =="0.000000000000000001" : ] 000000614582451.690861000000000000 ; 000000630480421.045723000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A9C7453C2096A >									
	//     < NDRV_PFVI_I_metadata_line_35_____Leine Re_20211101 >									
	//        < iTvSRqR31g0H1Y00pwVed9f6yvo2U6Kh880y6jb7qEmRCR9pNlMW4jRz5LN7vw8Q >									
	//        <  u =="0.000000000000000001" : ] 000000630480421.045723000000000000 ; 000000646473100.102288000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C2096A3DA708E >									
	//     < NDRV_PFVI_I_metadata_line_36_____Hannover Re Services Italy Srl_20211101 >									
	//        < 0xb1O1x58L3591ldG72B6iDR9yVHKLD2bNmE3Z773i89qKaGcjq3O5eZxzA8278o >									
	//        <  u =="0.000000000000000001" : ] 000000646473100.102288000000000000 ; 000000659950840.850856000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DA708E3EF014C >									
	//     < NDRV_PFVI_I_metadata_line_37_____Hannover Services UK Ltd_20211101 >									
	//        < p6i1A1P7DsjLi498D27vOx04JEm95CNF9gb8l6522r0VFOB266Kqq0MtX0rc0oES >									
	//        <  u =="0.000000000000000001" : ] 000000659950840.850856000000000000 ; 000000675141997.412482000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003EF014C4062F58 >									
	//     < NDRV_PFVI_I_metadata_line_38_____Hr Gll Central Europe Holding Gmbh_20211101 >									
	//        < zc4CX1qhcoIQaQK1hCj0bEQ7MeZrlNm1Nd9H02j16ei7j57m3b4wH909adB0UMY1 >									
	//        <  u =="0.000000000000000001" : ] 000000675141997.412482000000000000 ; 000000694648516.764139000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004062F58423F314 >									
	//     < NDRV_PFVI_I_metadata_line_39_____Hannover Re Risk Management Services India Private Limited_20211101 >									
	//        < e06WJVF2tbu29ZBcOeOor6B45tzKpWrQ5ezlXvJh0szZnsudv9ZJtE5zE0y42859 >									
	//        <  u =="0.000000000000000001" : ] 000000694648516.764139000000000000 ; 000000719107753.733148000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000423F3144494577 >									
	//     < NDRV_PFVI_I_metadata_line_40_____HAPEP II Holding GmbH_20211101 >									
	//        < 3CqA9p1kmt1s9zrFX632zv01N0cIXWI87FEKtWhkkgjG20zB96EQqZ9k5Nk1z6zg >									
	//        <  u =="0.000000000000000001" : ] 000000719107753.733148000000000000 ; 000000743409861.810792000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000449457746E5A7A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}