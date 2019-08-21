pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFIV_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFIV_II_883		"	;
		string	public		symbol =	"	RUSS_PFIV_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		730675751330868000000000000					;	
										
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
	//     < RUSS_PFIV_II_metadata_line_1_____NOVOLIPETSK_20231101 >									
	//        < FJk86Jh1bX15AG0582sBfk6309m46gkq1w32I9f343dM0uyP47pma0We6YY49g5C >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000015414940.043051200000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000178576 >									
	//     < RUSS_PFIV_II_metadata_line_2_____FLETCHER_GROUP_HOLDINGS_LIMITED_20231101 >									
	//        < mZcKwz90z4hMAIDqXxgX1dvcbsu2NJ8C6OADnK2zv9QyXurI663B5W35WhSGItN2 >									
	//        <  u =="0.000000000000000001" : ] 000000015414940.043051200000000000 ; 000000035431556.973579000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000178576361074 >									
	//     < RUSS_PFIV_II_metadata_line_3_____UNIVERSAL_CARGO_LOGISTICS_HOLDINGS_BV_20231101 >									
	//        < ThwS829y2kOLspsPosWaBULgdr5NTjhDeSR6F62XPz6yE0Q9NzPdcQ30knN4rFDQ >									
	//        <  u =="0.000000000000000001" : ] 000000035431556.973579000000000000 ; 000000055153692.228725600000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000361074542869 >									
	//     < RUSS_PFIV_II_metadata_line_4_____STOILENSKY_GOK_20231101 >									
	//        < BAD5sr3E38YDsPcx3iUnT87XLn9soch2p8kdIT9wL3b7238u9BTdxdf3eF28NH34 >									
	//        <  u =="0.000000000000000001" : ] 000000055153692.228725600000000000 ; 000000075974527.501017300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000054286973ED8D >									
	//     < RUSS_PFIV_II_metadata_line_5_____ALTAI_KOKS_20231101 >									
	//        < 314pGof6IK4x4KBX6F35i6apM0PTSdJW8Pd49z6gMfrmzR7GynCTY8V23zjcXeri >									
	//        <  u =="0.000000000000000001" : ] 000000075974527.501017300000000000 ; 000000096154822.250900600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000073ED8D92B87A >									
	//     < RUSS_PFIV_II_metadata_line_6_____VIZ_STAL_20231101 >									
	//        < W01WufMxgb6hJ46k64mRR4YJiuo793Iv5pBIUYoPE5Hd6h66rQNyMBf7yzEK10tM >									
	//        <  u =="0.000000000000000001" : ] 000000096154822.250900600000000000 ; 000000112119375.037622000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000092B87AAB14A2 >									
	//     < RUSS_PFIV_II_metadata_line_7_____NLMK_PLATE_SALES_SA_20231101 >									
	//        < N9STZDO1dOP9T43rxcV50jHd4npP1nZpG1sNbhUGwv0293dIB3wqjwQgflH969SE >									
	//        <  u =="0.000000000000000001" : ] 000000112119375.037622000000000000 ; 000000133118240.966023000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AB14A2CB1F50 >									
	//     < RUSS_PFIV_II_metadata_line_8_____NLMK_INDIANA_LLC_20231101 >									
	//        < 1bno43AgMaXY0lG8FWbqceast1inJdXW8yYE03v14HS6V4D0Jwfa4Vd52S67xz9i >									
	//        <  u =="0.000000000000000001" : ] 000000133118240.966023000000000000 ; 000000153701727.443600000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CB1F50EA87BD >									
	//     < RUSS_PFIV_II_metadata_line_9_____STEEL_FUNDING_DAC_20231101 >									
	//        < x92zY9LPs4sL6r366VBBnGE4OBoeBja7nsvQdMB079k1Va0DVF5Y2UV8RE9A1FK3 >									
	//        <  u =="0.000000000000000001" : ] 000000153701727.443600000000000000 ; 000000171823037.001792000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EA87BD1062E60 >									
	//     < RUSS_PFIV_II_metadata_line_10_____ZAO_URALS_PRECISION_ALLOYS_PLANT_20231101 >									
	//        < T25Em50813y91ik8Y3143S9XG3f2b09CRAal8v5hn0tck3WF5k2BKwstG2K3a5yl >									
	//        <  u =="0.000000000000000001" : ] 000000171823037.001792000000000000 ; 000000188894292.931306000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001062E601203AD5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIV_II_metadata_line_11_____TOP_GUN_INVESTMENT_CORP_20231101 >									
	//        < 5e04KIdBSQ3hx1V5o90A81Y92ealOu5hlgXCK13PV1L1Oz3iG6qWsfc8fMlYG7qd >									
	//        <  u =="0.000000000000000001" : ] 000000188894292.931306000000000000 ; 000000204811856.830267000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001203AD513884A2 >									
	//     < RUSS_PFIV_II_metadata_line_12_____NLMK_ARKTIKGAZ_20231101 >									
	//        < ixbHu8EmvZ9h4SE85RLS3Rmwi2zsJrgXXwyiw5yciw1sx7y1MU8Dwr1laIN9961z >									
	//        <  u =="0.000000000000000001" : ] 000000204811856.830267000000000000 ; 000000220594434.777025000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013884A215099B3 >									
	//     < RUSS_PFIV_II_metadata_line_13_____TUSCANY_INTERTRADE_20231101 >									
	//        < 221Od354Yys25ybuAvP1NZ91m5RPI591v2158lOTe7Oy45K887XHD08JToXH5oVY >									
	//        <  u =="0.000000000000000001" : ] 000000220594434.777025000000000000 ; 000000238446388.879603000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015099B316BD71F >									
	//     < RUSS_PFIV_II_metadata_line_14_____MOORFIELD_COMMODITIES_20231101 >									
	//        < ADPDwvg84Td6P1e35c5RPgXMj4BqwkcCmAhsG2k449SCg6cBP9h81mJBzFxqT9SG >									
	//        <  u =="0.000000000000000001" : ] 000000238446388.879603000000000000 ; 000000254156306.940616000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016BD71F183CFCF >									
	//     < RUSS_PFIV_II_metadata_line_15_____NLMK_COATING_20231101 >									
	//        < 92pAGm67CKI9Nu0nQKX04bEsPUNz7cO29bFaQqUW931X67Ka8J6CSF5wMm9aDn02 >									
	//        <  u =="0.000000000000000001" : ] 000000254156306.940616000000000000 ; 000000272135350.124129000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000183CFCF19F3EDF >									
	//     < RUSS_PFIV_II_metadata_line_16_____NLMK_MAXI_GROUP_20231101 >									
	//        < XEvD3x3TrOpME5665QMKH6Fs4ELOII174roAH9ig6HByc766yW4ElvO6N5SZXIj8 >									
	//        <  u =="0.000000000000000001" : ] 000000272135350.124129000000000000 ; 000000291229122.341858000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019F3EDF1BC6160 >									
	//     < RUSS_PFIV_II_metadata_line_17_____NLMK_SERVICES_LLC_20231101 >									
	//        < qm85c55LnAm63cL909QEA13b2hd88w68hdpNs7INldC83j8krP22WRzeBQ3QGpH5 >									
	//        <  u =="0.000000000000000001" : ] 000000291229122.341858000000000000 ; 000000311290890.508093000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BC61601DAFE01 >									
	//     < RUSS_PFIV_II_metadata_line_18_____STEEL_INVEST_FINANCE_20231101 >									
	//        < lz3I7c9o3784J44U6BLn9ic172rW6R7VEzi9XR662BT8Fa4j19sNz7D55tntnJYI >									
	//        <  u =="0.000000000000000001" : ] 000000311290890.508093000000000000 ; 000000327255148.888426000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DAFE011F35A0B >									
	//     < RUSS_PFIV_II_metadata_line_19_____CLABECQ_20231101 >									
	//        < N5QqUhTfmphDwYSgxh9ikI1E3HI14KGP0AkSwc2PRecu63SR6Dc5M61oPW9vX608 >									
	//        <  u =="0.000000000000000001" : ] 000000327255148.888426000000000000 ; 000000346178529.204376000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F35A0B21039FD >									
	//     < RUSS_PFIV_II_metadata_line_20_____HOLIDAY_HOTEL_NLMK_20231101 >									
	//        < D81DKTviXKN382LGS1QNo5zxfcA6APhHRf10LrG69cckTUoRc8Ut5egk1KCwEw6O >									
	//        <  u =="0.000000000000000001" : ] 000000346178529.204376000000000000 ; 000000366705895.372140000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021039FD22F8C7E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIV_II_metadata_line_21_____STEELCO_MED_TRADING_20231101 >									
	//        < 33Y6nDLs31pLjfu1fv007jljNCzp8Vd8AK9rq87874nXY1s330K3Ibvvk19bvDa2 >									
	//        <  u =="0.000000000000000001" : ] 000000366705895.372140000000000000 ; 000000382798458.529083000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022F8C7E2481AA6 >									
	//     < RUSS_PFIV_II_metadata_line_22_____LIPETSKY_GIPROMEZ_20231101 >									
	//        < 7gzEa6cgLp74JcR1K7h21gto11KPsum0LBwTDAVR0AGLV56Rd19rur66h1ev9o9q >									
	//        <  u =="0.000000000000000001" : ] 000000382798458.529083000000000000 ; 000000403548524.200841000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002481AA6267C424 >									
	//     < RUSS_PFIV_II_metadata_line_23_____NORTH_OIL_GAS_CO_20231101 >									
	//        < 78M8HO7bTj4SZx1fQngDa66Lp6wj13nmk0GE4c0YT6m4SFf3gMqO43M25otTR3xl >									
	//        <  u =="0.000000000000000001" : ] 000000403548524.200841000000000000 ; 000000422850479.544462000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000267C42428537F8 >									
	//     < RUSS_PFIV_II_metadata_line_24_____STOYLENSKY_GOK_20231101 >									
	//        < 3aF59ChyZ2SL8Sr00kxp66p9ioygG9Fai063yY1fsV6MT2CZkhLrw92CVi9zGCk5 >									
	//        <  u =="0.000000000000000001" : ] 000000422850479.544462000000000000 ; 000000443677113.231462000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028537F82A4FF5F >									
	//     < RUSS_PFIV_II_metadata_line_25_____NLMK_RECORDING_CENTER_OOO_20231101 >									
	//        < W3v039JP7xOwrT0k23Fk07p1V1hSZ1U6Bj06Uets79nU90e1Tj5fQOJ1gI9CVNxC >									
	//        <  u =="0.000000000000000001" : ] 000000443677113.231462000000000000 ; 000000461459855.481975000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A4FF5F2C021C2 >									
	//     < RUSS_PFIV_II_metadata_line_26_____URAL_ARCHI_CONSTRUCTION_RD_INSTITUTE_20231101 >									
	//        < jggXyw2Zh3No1ZnrwMxT6yZ8ieRnID0clb8M340OeLJUhC7sY35YxhOS8lrBy9Zu >									
	//        <  u =="0.000000000000000001" : ] 000000461459855.481975000000000000 ; 000000482419935.813270000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C021C22E01D4A >									
	//     < RUSS_PFIV_II_metadata_line_27_____PO_URALMETALLURGSTROY_ZAO_20231101 >									
	//        < 6xOY7XEirM25B8UXrLiJ542687G5OBNc5Rf8c7GZ4539h9k0Fe8WH2EiYk3Pk7Cb >									
	//        <  u =="0.000000000000000001" : ] 000000482419935.813270000000000000 ; 000000498809703.381804000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E01D4A2F91F8A >									
	//     < RUSS_PFIV_II_metadata_line_28_____NLMK_LONG_PRODUCTS_20231101 >									
	//        < UD54R8lOl5Nk9w571D8k72pbMkOxFHhVz8lr0h4hAz13d4YkdwZ8Ja79pmJ0A5K4 >									
	//        <  u =="0.000000000000000001" : ] 000000498809703.381804000000000000 ; 000000516435560.090676000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F91F8A31404A4 >									
	//     < RUSS_PFIV_II_metadata_line_29_____USSURIYSKAYA_SCRAP_METAL_20231101 >									
	//        < FRMmJPn76UHJbJ47578RMZ765TEm4lZZ1fdjoI6nJJV5E6zZ0ek8fzSJ679lg38f >									
	//        <  u =="0.000000000000000001" : ] 000000516435560.090676000000000000 ; 000000534981261.197227000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031404A4330510E >									
	//     < RUSS_PFIV_II_metadata_line_30_____NOVOLIPETSKY_PRINTING_HOUSE_20231101 >									
	//        < vS5N6Gp2xssmR4l40mG3aC7fuFF31tiN3PsGM19q3Lj5AUGEyNx84oZe3qYZkkDj >									
	//        <  u =="0.000000000000000001" : ] 000000534981261.197227000000000000 ; 000000551841592.534046000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000330510E34A0B1F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIV_II_metadata_line_31_____CHUPIT_LIMITED_20231101 >									
	//        < nWMKbA0d7abVZkPagZzV2ZtGZ671pH3E1AgU34SgYuXx6W41KHaI309lJG3840hg >									
	//        <  u =="0.000000000000000001" : ] 000000551841592.534046000000000000 ; 000000567550579.832675000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034A0B1F3620372 >									
	//     < RUSS_PFIV_II_metadata_line_32_____ZHERNOVSKY_I_MINING_PROCESS_COMPLEX_20231101 >									
	//        < 18djWov969ZU7seO61kCebU8PZ949vo02S1Qo7U2W46BB69jO97Moi180bi5fD9r >									
	//        <  u =="0.000000000000000001" : ] 000000567550579.832675000000000000 ; 000000586783537.694751000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000362037237F5C52 >									
	//     < RUSS_PFIV_II_metadata_line_33_____KSIEMP_20231101 >									
	//        < Z8Y2U2T1ftxUFB4SSD2CAi1Yd0g9O0WN5P99SDUL1gn498266gT6Uc72OeU3Pxg6 >									
	//        <  u =="0.000000000000000001" : ] 000000586783537.694751000000000000 ; 000000605160186.472480000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037F5C5239B66B3 >									
	//     < RUSS_PFIV_II_metadata_line_34_____STROITELNY_MONTAZHNYI_TREST_20231101 >									
	//        < J20d8W1iqJierUq6T1Oi9IVb8uQV808Y4c7Y0mI3vl2a08sxp16aw36i3Yy477M3 >									
	//        <  u =="0.000000000000000001" : ] 000000605160186.472480000000000000 ; 000000623534624.133811000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039B66B33B77036 >									
	//     < RUSS_PFIV_II_metadata_line_35_____VTORMETSNAB_20231101 >									
	//        < ZDCocO9mq2TX4z8sN4uP3XIR5mH21851DI8vGmIYmH64hGW45MN8ou5SAk9juCM3 >									
	//        <  u =="0.000000000000000001" : ] 000000623534624.133811000000000000 ; 000000642083765.060993000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B770363D3BDF9 >									
	//     < RUSS_PFIV_II_metadata_line_36_____DOLOMIT_20231101 >									
	//        < 0k573gBUlm4Ayf4Jd3LsAX1C8kU84sv431v1b008BB270HR5Is229n0SrFGNm7Re >									
	//        <  u =="0.000000000000000001" : ] 000000642083765.060993000000000000 ; 000000658720285.824485000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D3BDF93ED209D >									
	//     < RUSS_PFIV_II_metadata_line_37_____KALUGA_ELECTRIC_STEELMAKING_PLANT_20231101 >									
	//        < q0z7X1iZn2n05i459vAm07kz80ld7T06cGGb2a1TO10Ht2gcmG41Abdc638q9vG5 >									
	//        <  u =="0.000000000000000001" : ] 000000658720285.824485000000000000 ; 000000676961791.964287000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003ED209D408F633 >									
	//     < RUSS_PFIV_II_metadata_line_38_____LIPETSKOMBANK_20231101 >									
	//        < EM68QDAQ8V1fSwz0Zbu513CJ9qtmb0d37O53X852i6fT63uo3i0XMuCh8u57MT99 >									
	//        <  u =="0.000000000000000001" : ] 000000676961791.964287000000000000 ; 000000692883564.049294000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000408F63342141A4 >									
	//     < RUSS_PFIV_II_metadata_line_39_____NIZHNESERGINSKY_HARDWARE_METALL_WORKS_20231101 >									
	//        < Q0B55X3Id5229g0Id65hMsOBqtWWZ317CFu273c4k51iLUdAJt9A61Y0xhShFNRu >									
	//        <  u =="0.000000000000000001" : ] 000000692883564.049294000000000000 ; 000000712949463.921407000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042141A443FDFE2 >									
	//     < RUSS_PFIV_II_metadata_line_40_____KALUGA_SCIENTIFIC_PROD_ELECTROMETALL_PLANT_20231101 >									
	//        < Ik9oOZqM9440au3Pg7422R1d07foj9mN5o0dm1p5kjF7qbR8eMxvN1nO27KGWI71 >									
	//        <  u =="0.000000000000000001" : ] 000000712949463.921407000000000000 ; 000000730675751.330868000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000043FDFE245AEC37 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}