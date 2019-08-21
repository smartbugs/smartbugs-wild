pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXII_II_883		"	;
		string	public		symbol =	"	RUSS_PFXXII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		801919187065569000000000000					;	
										
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
	//     < RUSS_PFXXII_II_metadata_line_1_____RUSSIAN_FEDERATION_BOND_1_20231101 >									
	//        < emhq523qf8Zkj799iP264IfIHuJo557Vt93ix25o4249B3pv17H0ubn0oS6q2iKS >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000018702612.087663200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001C89B5 >									
	//     < RUSS_PFXXII_II_metadata_line_2_____RF_BOND_2_20231101 >									
	//        < MDYzxhO449WleXip4S2bYQ3hhb9mkdgq5eBdfLvM00iiyl4X93VjwgPFnXA00KTs >									
	//        <  u =="0.000000000000000001" : ] 000000018702612.087663200000000000 ; 000000037624815.609906900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001C89B5396932 >									
	//     < RUSS_PFXXII_II_metadata_line_3_____RF_BOND_3_20231101 >									
	//        < CLv0LAnqMuL9e9L3gLtEhVxr950ij13uHi0Sv0rF4i2d4ts6AOUWVyh760B1ubth >									
	//        <  u =="0.000000000000000001" : ] 000000037624815.609906900000000000 ; 000000053752547.201252700000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000396932520517 >									
	//     < RUSS_PFXXII_II_metadata_line_4_____RF_BOND_4_20231101 >									
	//        < J6C5GUSG8N4oxh7L591I78w0dLeMmvL2jpEr09FyB00KkEIOHO51prH593fCQe82 >									
	//        <  u =="0.000000000000000001" : ] 000000053752547.201252700000000000 ; 000000071317444.840300700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005205176CD260 >									
	//     < RUSS_PFXXII_II_metadata_line_5_____RF_BOND_5_20231101 >									
	//        < 211YjbMTUCA1xh9P9s4ec4nF1Z3UQ09701v19AK9bb3PqC9d8dl8aO62jInMY5E2 >									
	//        <  u =="0.000000000000000001" : ] 000000071317444.840300700000000000 ; 000000089301994.408455300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006CD260884397 >									
	//     < RUSS_PFXXII_II_metadata_line_6_____RF_BOND_6_20231101 >									
	//        < XJSDa3744d1o2jDFV5q4y7EfJrUaklGxr9ZWo8849Br4N177U264P4p8fzqi9NB5 >									
	//        <  u =="0.000000000000000001" : ] 000000089301994.408455300000000000 ; 000000107375480.024003000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000884397A3D78C >									
	//     < RUSS_PFXXII_II_metadata_line_7_____RF_BOND_7_20231101 >									
	//        < 4iiT1m45j056PPxiA3vuifpq6k3gJ6gOV7u4n8sqRw2uMS9j1210Mz29JhExo148 >									
	//        <  u =="0.000000000000000001" : ] 000000107375480.024003000000000000 ; 000000123102206.040356000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A3D78CBBD6CD >									
	//     < RUSS_PFXXII_II_metadata_line_8_____RF_BOND_8_20231101 >									
	//        < 8cY19yL6Ys6V9wzr6ZXsLgUdarIfQM0UpOh56Et4AdL6rPPaHswDctPQaA50Ooxq >									
	//        <  u =="0.000000000000000001" : ] 000000123102206.040356000000000000 ; 000000144772980.935691000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BBD6CDDCE7F2 >									
	//     < RUSS_PFXXII_II_metadata_line_9_____RF_BOND_9_20231101 >									
	//        < V0aP8l5rK7Nz5N41y6496Y3HeYIbr6sa3MLntZ19UIn9yr58x4gptb04mnna9bmu >									
	//        <  u =="0.000000000000000001" : ] 000000144772980.935691000000000000 ; 000000167222820.948815000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DCE7F2FF296A >									
	//     < RUSS_PFXXII_II_metadata_line_10_____RF_BOND_10_20231101 >									
	//        < JiT2o8ikLn7sYJ3DJ1Y4AEyahfdizhTuLcbG0VqBvtceka7eQjVJezTE71f56D4P >									
	//        <  u =="0.000000000000000001" : ] 000000167222820.948815000000000000 ; 000000189202984.129903000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FF296A120B36A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXII_II_metadata_line_11_____RUSS_CENTRAL_BANK_BOND_1_20231101 >									
	//        < 87Vao7ITJ2wC5jq2N1cRZr546U65f5O05HzCg881z1T2ztZjWBwMDZm5l5M4pf78 >									
	//        <  u =="0.000000000000000001" : ] 000000189202984.129903000000000000 ; 000000213243626.311873000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000120B36A145624B >									
	//     < RUSS_PFXXII_II_metadata_line_12_____RCB_BOND_2_20231101 >									
	//        < wWG8DjIKSQ187vr0b93NlX7a3RNk54Wg0QlfH85QRDcerqt1p1i7ZYOp393lr3pr >									
	//        <  u =="0.000000000000000001" : ] 000000213243626.311873000000000000 ; 000000231980726.239679000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000145624B161F979 >									
	//     < RUSS_PFXXII_II_metadata_line_13_____RCB_BOND_3_20231101 >									
	//        < Ax178Ijm7lPp5Z6R5d0q496ueN8xdYuM714v3395iSi5jL07N4dQdOyUr3rI93KM >									
	//        <  u =="0.000000000000000001" : ] 000000231980726.239679000000000000 ; 000000250369922.535957000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000161F97917E08C0 >									
	//     < RUSS_PFXXII_II_metadata_line_14_____RCB_BOND_4_20231101 >									
	//        < Z6kdf5tPvD9f08qj0v43tNKqh9L3rY1tMc6tLaFekpi2Zdlg7W3TaU0eL7X9W4np >									
	//        <  u =="0.000000000000000001" : ] 000000250369922.535957000000000000 ; 000000268011360.384105000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017E08C0198F3F0 >									
	//     < RUSS_PFXXII_II_metadata_line_15_____RCB_BOND_5_20231101 >									
	//        < 9Q7sRIDE6V7M30Q2H3M9nbNe5Z4k4GK2KjQow08Wa4Wc8WOqn84MlJ88wgGOB8K5 >									
	//        <  u =="0.000000000000000001" : ] 000000268011360.384105000000000000 ; 000000291748082.047949000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000198F3F01BD2C18 >									
	//     < RUSS_PFXXII_II_metadata_line_16_____ROSSELKHOZBANK_20231101 >									
	//        < TxT30SQ629D1Vgv6x9Z2z048tDOKqlKMkMgsf1qZ03TeZj4kVetqmzM6P5odgh8F >									
	//        <  u =="0.000000000000000001" : ] 000000291748082.047949000000000000 ; 000000316465173.750922000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BD2C181E2E335 >									
	//     < RUSS_PFXXII_II_metadata_line_17_____PROMSVYAZBANK_20231101 >									
	//        < g832TAl38GcXfLzD20xEwZ7e4W2WkVPz7446IeTI7lK3w77L3OM77eDGGW692uG2 >									
	//        <  u =="0.000000000000000001" : ] 000000316465173.750922000000000000 ; 000000334408209.674004000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E2E3351FE4435 >									
	//     < RUSS_PFXXII_II_metadata_line_18_____BN_BANK_20231101 >									
	//        < dlpIwmnhq4Bz6zir512JKZslD8p38PXn6cdDdMh1ntOKhjSiyx1nyzgoYg3VQKHc >									
	//        <  u =="0.000000000000000001" : ] 000000334408209.674004000000000000 ; 000000352302388.015568000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FE4435219921F >									
	//     < RUSS_PFXXII_II_metadata_line_19_____RUSSIAN_STANDARD_BANK_20231101 >									
	//        < OdE1OyTOVxhUbxk8cV9tTe82mndRVSBzXF406S1y2KiY8pHnRwA51854Q1BYwz49 >									
	//        <  u =="0.000000000000000001" : ] 000000352302388.015568000000000000 ; 000000371085947.426386000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000219921F2363B73 >									
	//     < RUSS_PFXXII_II_metadata_line_20_____OTKRITIE_20231101 >									
	//        < 261gM75xxt72Dx976e34NwqY0O5R2Wc2d8XSnny63Azh6ZFD1l8XOcZOwf15XQvB >									
	//        <  u =="0.000000000000000001" : ] 000000371085947.426386000000000000 ; 000000392811565.506897000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002363B732576205 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXII_II_metadata_line_21_____HOME_CREDIT_FINANCE_BANK_20231101 >									
	//        < 4Q2IfG27D85w3X5vIPdroSwSC1IB65gwE2GwqwxF8k9Bv4tfCu4D8o009e6Cgad4 >									
	//        <  u =="0.000000000000000001" : ] 000000392811565.506897000000000000 ; 000000412928954.877824000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002576205276145F >									
	//     < RUSS_PFXXII_II_metadata_line_22_____UNICREDIT_BANK_RUSSIA_20231101 >									
	//        < myiv51oCRP0O51rcu6yiV5cnR8sXpZQ8zDGc418EJkwL0eV4KuWE0Bo9j0ibtP1V >									
	//        <  u =="0.000000000000000001" : ] 000000412928954.877824000000000000 ; 000000436308250.639877000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000276145F299C0E9 >									
	//     < RUSS_PFXXII_II_metadata_line_23_____URAL_BANK_RECONSTRUCTION_DEV_20231101 >									
	//        < SBaXzF2lShnewo8laYOquFyDBMzJ18j882Fs9943EuWM7Ow3LxF9VKpMVc4uiQ79 >									
	//        <  u =="0.000000000000000001" : ] 000000436308250.639877000000000000 ; 000000461180246.923821000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000299C0E92BFB489 >									
	//     < RUSS_PFXXII_II_metadata_line_24_____AK_BARS_BANK_20231101 >									
	//        < Z80IevtbSe690P1J8tT1LcDIRtI3XE2g54q63LFZW2tdwvhQqnn7t50JtsceA5dx >									
	//        <  u =="0.000000000000000001" : ] 000000461180246.923821000000000000 ; 000000485906806.006555000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BFB4892E56F59 >									
	//     < RUSS_PFXXII_II_metadata_line_25_____SOVCOMBANK_20231101 >									
	//        < C6xoJ24PAKeA75l4ietCchGPM69739SyOjy4V2e8t9JCw5eV10Zx0m38poH50JU8 >									
	//        <  u =="0.000000000000000001" : ] 000000485906806.006555000000000000 ; 000000509020057.168293000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E56F59308B3F6 >									
	//     < RUSS_PFXXII_II_metadata_line_26_____MONEYGRAM_RUSS_20231101 >									
	//        < 0m36aD1J2Pgt66dQI42e38XD4earx01xeTtou6G8QlzO5HeYoOmah7Fd44597VnJ >									
	//        <  u =="0.000000000000000001" : ] 000000509020057.168293000000000000 ; 000000526763683.939834000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000308B3F6323C710 >									
	//     < RUSS_PFXXII_II_metadata_line_27_____VOZROZHDENIE_BANK_20231101 >									
	//        < u3Xq9984wyM31X4b42Pc37QS7FOF7vbw0fMss1hBO31PySuP5l7vNv4RS0iXFy52 >									
	//        <  u =="0.000000000000000001" : ] 000000526763683.939834000000000000 ; 000000544100320.606237000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000323C71033E3B30 >									
	//     < RUSS_PFXXII_II_metadata_line_28_____MTC_BANK_20231101 >									
	//        < x4ao0m2sagfhxx9Sp96iZjhySD7yg1RIDl21CZEuA1e1DFHV8v4PNM0IfKuv838v >									
	//        <  u =="0.000000000000000001" : ] 000000544100320.606237000000000000 ; 000000560200267.633859000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033E3B30356CC3B >									
	//     < RUSS_PFXXII_II_metadata_line_29_____ABSOLUT_BANK_20231101 >									
	//        < 7ey69T66sWt89Kf8igA747ok5kbNcAYI7sW3480q24kXOD5E04p1b4FCJrG19kpZ >									
	//        <  u =="0.000000000000000001" : ] 000000560200267.633859000000000000 ; 000000581018781.744465000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000356CC3B3769076 >									
	//     < RUSS_PFXXII_II_metadata_line_30_____ROSBANK_20231101 >									
	//        < 4ly10wh1pK4Pydn1I30KN9jLF8YDocxw9wZFC1L22427bQUeOrxMzUlFKE80872Z >									
	//        <  u =="0.000000000000000001" : ] 000000581018781.744465000000000000 ; 000000597320371.567328000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000376907638F7045 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXII_II_metadata_line_31_____ALFA_BANK_20231101 >									
	//        < 8Z5F05599d8H5ipK2f1kf1CW3A27q90q57w5tXi4U7GrJm7c9uKf8xY504O359LR >									
	//        <  u =="0.000000000000000001" : ] 000000597320371.567328000000000000 ; 000000620899835.583905000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038F70453B36B00 >									
	//     < RUSS_PFXXII_II_metadata_line_32_____SOGAZ_20231101 >									
	//        < DUzBw798O75x77RTvB5Q22b84fTARAW0083fU3g7JBld0O6H1vaF1gmoTjh0pcc8 >									
	//        <  u =="0.000000000000000001" : ] 000000620899835.583905000000000000 ; 000000636428458.277997000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B36B003CB1CDE >									
	//     < RUSS_PFXXII_II_metadata_line_33_____RENAISSANCE_20231101 >									
	//        < 9r4eH81j7gJ15gpw4hxkL2riV7c2a3maMIQb8eOM2NL7woBwzj0DF8EHpfjn6WMV >									
	//        <  u =="0.000000000000000001" : ] 000000636428458.277997000000000000 ; 000000655242193.493115000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003CB1CDE3E7D1FB >									
	//     < RUSS_PFXXII_II_metadata_line_34_____VTB_BANK_20231101 >									
	//        < oM4I38QRoSao19v5Wr7s67fKceD7W2n8Rhe09C91FlD497lerW5v213K6hHCf3nQ >									
	//        <  u =="0.000000000000000001" : ] 000000655242193.493115000000000000 ; 000000679667208.097653000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E7D1FB40D1701 >									
	//     < RUSS_PFXXII_II_metadata_line_35_____ERGO_RUSS_20231101 >									
	//        < IumhWPQLcq5ZY7P8X7cpx0tDq939NP5c0VnSn6WOBld1P37710foxGjK7CCJ6FGr >									
	//        <  u =="0.000000000000000001" : ] 000000679667208.097653000000000000 ; 000000702799275.839551000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040D170143062F8 >									
	//     < RUSS_PFXXII_II_metadata_line_36_____GAZPROMBANK_20231101 >									
	//        < xuWT5Xh42kvy7FfTb2UQ2t6fiQ8r2fYb2zUeV6pV5pwA0R2W2wb33kw12v49GNgz >									
	//        <  u =="0.000000000000000001" : ] 000000702799275.839551000000000000 ; 000000720097090.452266000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000043062F844AC7ED >									
	//     < RUSS_PFXXII_II_metadata_line_37_____SBERBANK_20231101 >									
	//        < 3W66dg2H00XXJrXLKSk6Skt604m78h2FE0XoI5FmF9179SD44gYiR5SKJjZ0E05H >									
	//        <  u =="0.000000000000000001" : ] 000000720097090.452266000000000000 ; 000000744907574.614608000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044AC7ED470A385 >									
	//     < RUSS_PFXXII_II_metadata_line_38_____TINKOFF_BANK_20231101 >									
	//        < pRj170w0eV55p633WS8D2ah9hS66si5tIhFk42nIW5m8y5uAt1gtRSG6Xp4rs712 >									
	//        <  u =="0.000000000000000001" : ] 000000744907574.614608000000000000 ; 000000762985271.271475000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000470A38548C391F >									
	//     < RUSS_PFXXII_II_metadata_line_39_____VBANK_20231101 >									
	//        < dOyLf9Mb1H55JTfR2ypNa7iNLb7advNWR2wxS7W0370LKWVW5FLv47AxS5f3qQpo >									
	//        <  u =="0.000000000000000001" : ] 000000762985271.271475000000000000 ; 000000778979080.614302000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048C391F4A4A0B4 >									
	//     < RUSS_PFXXII_II_metadata_line_40_____CREDIT_BANK_MOSCOW_20231101 >									
	//        < T0t0H8969GZbZbtx5Ey0kQ3lYsk20SJHxVi6kGd6sU2BCwpQo8DGCo9IS736zkKb >									
	//        <  u =="0.000000000000000001" : ] 000000778979080.614302000000000000 ; 000000801919187.065569000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A4A0B44C7A1AF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}