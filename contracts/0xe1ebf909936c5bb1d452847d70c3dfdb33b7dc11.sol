pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXIV_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXIV_I_883		"	;
		string	public		symbol =	"	RUSS_PFXXXIV_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		612358508633320000000000000					;	
										
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
	//     < RUSS_PFXXXIV_I_metadata_line_1_____PHARMSTANDARD_20211101 >									
	//        < ZV19PdLX3KmN47U3O5Fhd81wV919Vaw5cms4uvExkiKw9SI6Dlplk3oNQxlI9YnI >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000014853431.925197200000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000016AA1F >									
	//     < RUSS_PFXXXIV_I_metadata_line_2_____PHARM_DAO_20211101 >									
	//        < wJ1cMNx3k9LI3u6FDPJc3N9C0ZP222636aq7k9k3aTk9qVSpusY6vf053JxACM81 >									
	//        <  u =="0.000000000000000001" : ] 000000014853431.925197200000000000 ; 000000031872441.873093400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000016AA1F30A22C >									
	//     < RUSS_PFXXXIV_I_metadata_line_3_____PHARM_DAOPI_20211101 >									
	//        < b6LLUn8NwK2ig799fSB6tRM9mAXO4el8QLxh5A3qkgQse34PyvOQwBhC9Xj11xbI >									
	//        <  u =="0.000000000000000001" : ] 000000031872441.873093400000000000 ; 000000045025769.849747800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000030A22C44B431 >									
	//     < RUSS_PFXXXIV_I_metadata_line_4_____PHARM_DAC_20211101 >									
	//        < 19V6T21UhtpLsJ820E6xfw8GlFiTae03I5n7RukTR9Z98raaR3FSguKYFZqZwi0o >									
	//        <  u =="0.000000000000000001" : ] 000000045025769.849747800000000000 ; 000000061364778.430482300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000044B4315DA29E >									
	//     < RUSS_PFXXXIV_I_metadata_line_5_____PHARM_BIMI_20211101 >									
	//        < 92MlQCyAg8RS5VNcQk0RTHYnpUZcd7j8M3Y0HtpZiRfUzTUH7bP4IK9Wz59n7hZy >									
	//        <  u =="0.000000000000000001" : ] 000000061364778.430482300000000000 ; 000000078012306.021574200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005DA29E77098F >									
	//     < RUSS_PFXXXIV_I_metadata_line_6_____GENERIUM_20211101 >									
	//        < W01eHS6ed7TXi0kEG2ZLkyeA1Agr7KJ495ZM9c18bw78J5jrGEat8MFtaNLYGt5K >									
	//        <  u =="0.000000000000000001" : ] 000000078012306.021574200000000000 ; 000000093972832.121620400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000077098F8F6423 >									
	//     < RUSS_PFXXXIV_I_metadata_line_7_____GENERIUM_DAO_20211101 >									
	//        < M3N72k75L4ONyCwZGx09bLOj1CqKsJp5o3PRpmj09s45HloHVTwlBsNVN2vRhLoB >									
	//        <  u =="0.000000000000000001" : ] 000000093972832.121620400000000000 ; 000000108823150.439228000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008F6423A60D0B >									
	//     < RUSS_PFXXXIV_I_metadata_line_8_____GENERIUM_DAOPI_20211101 >									
	//        < 2HDSsJk9ykK6qW96R1sw7liPjx1T0Gu1h49bWF38202fnpe72GeJg3S264XBEF8F >									
	//        <  u =="0.000000000000000001" : ] 000000108823150.439228000000000000 ; 000000125308910.236396000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A60D0BBF34CB >									
	//     < RUSS_PFXXXIV_I_metadata_line_9_____GENERIUM_DAC_20211101 >									
	//        < L18RYrhYl8B9HvGdR8xiCD3FetC5MjWWD3B1qs97yj5UxoGg85Tzjp7jGKs4F3sj >									
	//        <  u =="0.000000000000000001" : ] 000000125308910.236396000000000000 ; 000000139047753.943815000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BF34CBD42B87 >									
	//     < RUSS_PFXXXIV_I_metadata_line_10_____GENERIUM_BIMI_20211101 >									
	//        < VBD8oDkUn1eINLV9VhgowBG4pVRSzjv17Rn75w4vabL39l22MD5PQ0e6bbOrP8hV >									
	//        <  u =="0.000000000000000001" : ] 000000139047753.943815000000000000 ; 000000156138989.730097000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D42B87EE3FCB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXIV_I_metadata_line_11_____MASTERLEK_20211101 >									
	//        < bptX8c9vr6wix1kQYoiAuOcNEIc74nz3j64IrBhxztexGM458444NJlew1eLCxWJ >									
	//        <  u =="0.000000000000000001" : ] 000000156138989.730097000000000000 ; 000000172506261.359860000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EE3FCB1073942 >									
	//     < RUSS_PFXXXIV_I_metadata_line_12_____MASTERLEK_DAO_20211101 >									
	//        < 963zKT05cu1vYgGZ6aPb7I4Wci8mmpJf3G8II9Z6r9S8V7I02rkQmPm7Z6v4La8Y >									
	//        <  u =="0.000000000000000001" : ] 000000172506261.359860000000000000 ; 000000186520125.204117000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000107394211C9B6D >									
	//     < RUSS_PFXXXIV_I_metadata_line_13_____MASTERLEK_DAOPI_20211101 >									
	//        < kvgeZcgtL1rV02rjAsiN2O9QiuEbxG09wW2mE3ZBx4Awg50jCn8jyUbi7u7spZh1 >									
	//        <  u =="0.000000000000000001" : ] 000000186520125.204117000000000000 ; 000000201204601.262499000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011C9B6D133038C >									
	//     < RUSS_PFXXXIV_I_metadata_line_14_____MASTERLEK_DAC_20211101 >									
	//        < E716m6YUAN00EI8262w3x2LHj94J544DE697TB0c7GJNAtt400s32L1eOnv0ILok >									
	//        <  u =="0.000000000000000001" : ] 000000201204601.262499000000000000 ; 000000217967224.476750000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000133038C14C9772 >									
	//     < RUSS_PFXXXIV_I_metadata_line_15_____MASTERLEK_BIMI_20211101 >									
	//        < WV34e1b10aCdUyx4V0LtdVguYY25PuOO6DQkM1vOhD0b7KUD1HqhZ0LIhitKZ466 >									
	//        <  u =="0.000000000000000001" : ] 000000217967224.476750000000000000 ; 000000231889804.754476000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014C9772161D5F4 >									
	//     < RUSS_PFXXXIV_I_metadata_line_16_____PHARMSTANDARD_TMK_20211101 >									
	//        < 0gb3he52HB4NRkc541Sd3hV1g9EU9QF5ug73ju0Sh5wF2jQF41HituSt910T35L9 >									
	//        <  u =="0.000000000000000001" : ] 000000231889804.754476000000000000 ; 000000247732672.500096000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000161D5F417A0293 >									
	//     < RUSS_PFXXXIV_I_metadata_line_17_____PHARMSTANDARD_OCTOBER_20211101 >									
	//        < vu2A3K5lM35gfT13tx8dx0T6hPCib2VX6mU12WS1r1VTT1Uwx7C7ceda6fHTC0Dv >									
	//        <  u =="0.000000000000000001" : ] 000000247732672.500096000000000000 ; 000000261703299.455510000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017A029318F53DA >									
	//     < RUSS_PFXXXIV_I_metadata_line_18_____LEKSREDSTVA_20211101 >									
	//        < tw20w94kUfaSN05vTz7PfY8248OTO92ylj3Xq1tHnO4VZ3YZTK0lP1vWvbdTmh7J >									
	//        <  u =="0.000000000000000001" : ] 000000261703299.455510000000000000 ; 000000274957921.289468000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018F53DA1A38D70 >									
	//     < RUSS_PFXXXIV_I_metadata_line_19_____TYUMEN_PLANT_MED_EQUIP_TOOLS_20211101 >									
	//        < T68bUCJ6pbx7St82tnQPcDH5PE9clxvB6qt3pYJsJGZ94pQ277s1iE34A3iWWoMt >									
	//        <  u =="0.000000000000000001" : ] 000000274957921.289468000000000000 ; 000000290948005.944984000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A38D701BBF391 >									
	//     < RUSS_PFXXXIV_I_metadata_line_20_____MASTERPLAZMA_LLC_20211101 >									
	//        < vxAIRdb9jWMlCk8t2o1Sb9h9bzzkQjq7d7FR7rTNEEQsSe88GXYqj19vArgSN77P >									
	//        <  u =="0.000000000000000001" : ] 000000290948005.944984000000000000 ; 000000305802253.736215000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BBF3911D29E01 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXIV_I_metadata_line_21_____BIGPEARL_TRADING_LIMITED_20211101 >									
	//        < XorXc7EVXw21g8Ei5fzkS3K3eDkFeadoQzZ9FLrvPs27q9Y7yd603Gs7ZjPSRuYD >									
	//        <  u =="0.000000000000000001" : ] 000000305802253.736215000000000000 ; 000000323059683.362161000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D29E011ECF330 >									
	//     < RUSS_PFXXXIV_I_metadata_line_22_____BIGPEARL_DAO_20211101 >									
	//        < lhSyR7M78aqeQ9348ECxZ2EhQslsao4Bx2Mil62mQ9BtbK8HN7dZpSHNGc1pJm8Y >									
	//        <  u =="0.000000000000000001" : ] 000000323059683.362161000000000000 ; 000000339777675.254774000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001ECF33020675A8 >									
	//     < RUSS_PFXXXIV_I_metadata_line_23_____BIGPEARL_DAOPI_20211101 >									
	//        < Z0hZDK810jZDh4gm65cOoaa3VaGh559q6MYuvJ1VPo46M0DHyfCE616FxFK48y54 >									
	//        <  u =="0.000000000000000001" : ] 000000339777675.254774000000000000 ; 000000354581644.048266000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020675A821D0C74 >									
	//     < RUSS_PFXXXIV_I_metadata_line_24_____BIGPEARL_DAC_20211101 >									
	//        < Y39fchv0H7330s8DP97xA3r5D7d3w57Lx2yuIqjR9J73ln8KKdKoF07NH2xdddAr >									
	//        <  u =="0.000000000000000001" : ] 000000354581644.048266000000000000 ; 000000369454672.822745000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021D0C74233BE3B >									
	//     < RUSS_PFXXXIV_I_metadata_line_25_____BIGPEARL_BIMI_20211101 >									
	//        < 172kUp04uPE4nSk470p6yNijes9XSB3XDly1st86nZ9M4XyefxC468pWJuD10D20 >									
	//        <  u =="0.000000000000000001" : ] 000000369454672.822745000000000000 ; 000000386618659.757840000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000233BE3B24DEEEA >									
	//     < RUSS_PFXXXIV_I_metadata_line_26_____UFAVITA_20211101 >									
	//        < LBvPW75Gx54H01iZp3w23KmZtGd4uyvnJf17VI9zP03xiw5Cb720IiRdwEDa2QI0 >									
	//        <  u =="0.000000000000000001" : ] 000000386618659.757840000000000000 ; 000000401993544.268231000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024DEEEA26564BA >									
	//     < RUSS_PFXXXIV_I_metadata_line_27_____DONELLE_COMPANY_LIMITED_20211101 >									
	//        < 7r113cf67vA840PjStD7zi45sNn6i630JPmgi61cWl93bYwBC6y4APvlRPBu5k5E >									
	//        <  u =="0.000000000000000001" : ] 000000401993544.268231000000000000 ; 000000415893618.253927000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026564BA27A9A72 >									
	//     < RUSS_PFXXXIV_I_metadata_line_28_____DONELLE_CHF_20211101 >									
	//        < uNASgYv0J2iFnqW30V4V41NN5msspyO67vgx1Zu35hJhMlNk2PUO0s0X20963kbS >									
	//        <  u =="0.000000000000000001" : ] 000000415893618.253927000000000000 ; 000000431379734.322525000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027A9A722923BB5 >									
	//     < RUSS_PFXXXIV_I_metadata_line_29_____VINDEKSFARM_20211101 >									
	//        < oTfW0aauT4vqk07PoD2k3k06gQfQap0xnPf93J6MMeZvvxK6u2bZa1hDMKcbKy5G >									
	//        <  u =="0.000000000000000001" : ] 000000431379734.322525000000000000 ; 000000444416959.292249000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002923BB52A62060 >									
	//     < RUSS_PFXXXIV_I_metadata_line_30_____TYUMEN_PLANT_CHF_20211101 >									
	//        < IIJRY7C5bY7DvCIP5D8b77GU56zmAMe1KPfN5U34f4MkM72tQKGIrg5yrGMz7QJ8 >									
	//        <  u =="0.000000000000000001" : ] 000000444416959.292249000000000000 ; 000000459622101.533059000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A620602BD53E2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXIV_I_metadata_line_31_____LEKKO_20211101 >									
	//        < zThJ8o0hNJpOu204RA2hWvlboGg97E0W6GuMqp75mmKJYLz8003oi5xhe5946SK0 >									
	//        <  u =="0.000000000000000001" : ] 000000459622101.533059000000000000 ; 000000473496695.783591000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BD53E22D27FA6 >									
	//     < RUSS_PFXXXIV_I_metadata_line_32_____LEKKO_DAO_20211101 >									
	//        < 7aG4DVa1BG6I5Pe4WT52El0wMXo26IM93248pT493U9jcR0x2v3aOBKB7c2G97ux >									
	//        <  u =="0.000000000000000001" : ] 000000473496695.783591000000000000 ; 000000487641601.462500000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D27FA62E81500 >									
	//     < RUSS_PFXXXIV_I_metadata_line_33_____LEKKO_DAOPI_20211101 >									
	//        < w8v9i1784P47Aas0AoX36M608cKc417KTSHX6z8BrSaYNUtk0jbp8RAGi3GkO9km >									
	//        <  u =="0.000000000000000001" : ] 000000487641601.462500000000000000 ; 000000501288124.672039000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E815002FCE7AC >									
	//     < RUSS_PFXXXIV_I_metadata_line_34_____LEKKO_DAC_20211101 >									
	//        < TR42QRKr8PScvxS7L7Dem05H9qK7JKcgKbOMN60bp7u9XzFhD2ODFV7G8z582Sg7 >									
	//        <  u =="0.000000000000000001" : ] 000000501288124.672039000000000000 ; 000000517410618.711822000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FCE7AC3158186 >									
	//     < RUSS_PFXXXIV_I_metadata_line_35_____LEKKO_BIMI_20211101 >									
	//        < 7z2xG8TQb9qC41dw8w9JcT0jts8DX7g3X4R0d5V3B0w9RA5dMCasDXdWBREqmYF3 >									
	//        <  u =="0.000000000000000001" : ] 000000517410618.711822000000000000 ; 000000532688028.986038000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000315818632CD143 >									
	//     < RUSS_PFXXXIV_I_metadata_line_36_____TOMSKHIMPHARM_20211101 >									
	//        < L6I8SLwKd182LJqH6vTT8Q24y40Ly43O7l8KO5xbFsafMhiVv093O7VLt1713134 >									
	//        <  u =="0.000000000000000001" : ] 000000532688028.986038000000000000 ; 000000547229052.307609000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032CD1433430159 >									
	//     < RUSS_PFXXXIV_I_metadata_line_37_____TOMSKHIM_CHF_20211101 >									
	//        < 3jdZ171sSBq74Fu095c7E7gYTRpocq7n7M04t0Iec0VV2DG8cxsD5v77z2AF704t >									
	//        <  u =="0.000000000000000001" : ] 000000547229052.307609000000000000 ; 000000564089209.181378000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000343015935CBB59 >									
	//     < RUSS_PFXXXIV_I_metadata_line_38_____FF_LEKKO_ZAO_20211101 >									
	//        < i0u4IjJ5GAv3gz5I76ndBDN0UV8HWnEbkpgc8ejynJQMQxhmp5BiD6r6LI13p9d7 >									
	//        <  u =="0.000000000000000001" : ] 000000564089209.181378000000000000 ; 000000580621451.104200000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035CBB59375F541 >									
	//     < RUSS_PFXXXIV_I_metadata_line_39_____PHARMSTANDARD_PLAZMA_OOO_20211101 >									
	//        < Nkuxk7lmaJ0CzajqH0Lxr9nZoP563744M8ug6HM1ovSLB0l8t48w4R1T842Ki9BG >									
	//        <  u =="0.000000000000000001" : ] 000000580621451.104200000000000000 ; 000000595191176.871077000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000375F54138C308E >									
	//     < RUSS_PFXXXIV_I_metadata_line_40_____FARMSTANDARD_TOMSKKHIMFOARM_OAO_20211101 >									
	//        < 8euSni2PM9a3R4k7ph6VGT02S7IIZne5z8NChoMjX5PeNgT4xViPmRlnK59UE7bF >									
	//        <  u =="0.000000000000000001" : ] 000000595191176.871077000000000000 ; 000000612358508.633321000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038C308E3A6628B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}