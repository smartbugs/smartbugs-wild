pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXIX_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXIX_I_883		"	;
		string	public		symbol =	"	RUSS_PFXIX_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		592718827615176000000000000					;	
										
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
	//     < RUSS_PFXIX_I_metadata_line_1_____Eurochem_20211101 >									
	//        < 3l20zn6l4h9LABClV9UXViED79X996a4z215ZS1Wq1FUqaZa696RBaJQKq2k1891 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000013971455.532103900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000015519A >									
	//     < RUSS_PFXIX_I_metadata_line_2_____Eurochem_Group_AG_Switzerland_20211101 >									
	//        < I39CB7bge5asl7LgB9T37l0Uj176lEdIkMs8h1GV78bUE2C1J77LeXZ8l1uqfN3K >									
	//        <  u =="0.000000000000000001" : ] 000000013971455.532103900000000000 ; 000000027208746.573885800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000015519A29846B >									
	//     < RUSS_PFXIX_I_metadata_line_3_____Industrial _Group_Phosphorite_20211101 >									
	//        < f1VDKuQ5C3yOsnd2S6swkis417h2UprxHb1Y6BcEe6TwdYQ94T2J48dB7Jn5dhH2 >									
	//        <  u =="0.000000000000000001" : ] 000000027208746.573885800000000000 ; 000000043801938.239866600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000029846B42D622 >									
	//     < RUSS_PFXIX_I_metadata_line_4_____Novomoskovsky_Azot_20211101 >									
	//        < kcp9TqPF7l879MWkcWk57yYK5Bc4ebT7QTFHrX6yz07lccaKBshh9c174vgfgY7G >									
	//        <  u =="0.000000000000000001" : ] 000000043801938.239866600000000000 ; 000000057114368.672785600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000042D62257264D >									
	//     < RUSS_PFXIX_I_metadata_line_5_____Novomoskovsky_Chlor_20211101 >									
	//        < UQjrs28v6TEh20hHnf07VaTQ60Zx7BUqLNQ6JG4M4ce2ZW0BZYiqCoSmrK2o6V44 >									
	//        <  u =="0.000000000000000001" : ] 000000057114368.672785600000000000 ; 000000070167974.696827800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000057264D6B115D >									
	//     < RUSS_PFXIX_I_metadata_line_6_____Nevinnomyssky_Azot_20211101 >									
	//        < xd0I407dHEtv77FzA0DY8fV3lLnkikzGSR9bkI4DQWvv25bp8glPoNmN99Z5wB7V >									
	//        <  u =="0.000000000000000001" : ] 000000070167974.696827800000000000 ; 000000084707543.730440300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006B115D8140E2 >									
	//     < RUSS_PFXIX_I_metadata_line_7_____EuroChem_Belorechenskie_Minudobrenia_20211101 >									
	//        < 0bgKAZS6XFS9thN2pXlfrHjpd5lfFF2wJba37ENoAIbAen2Lsm2bDu32GQsAn7Or >									
	//        <  u =="0.000000000000000001" : ] 000000084707543.730440300000000000 ; 000000099031317.378488000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008140E2971C1C >									
	//     < RUSS_PFXIX_I_metadata_line_8_____Kovdorsky_GOK_20211101 >									
	//        < z2e8GE2Mr3iKe3GTj8no2B5Hbt1SJNbGM86WCXRfz963aA01zn5y7626M665s2gN >									
	//        <  u =="0.000000000000000001" : ] 000000099031317.378488000000000000 ; 000000112820189.569512000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000971C1CAC2663 >									
	//     < RUSS_PFXIX_I_metadata_line_9_____Lifosa_AB_20211101 >									
	//        < j0QCPQDn0Ry0rwAoDc7uPov50KnUjEnBVFwh6KaV29izwlJuZzQb7sy0Yu1J63OF >									
	//        <  u =="0.000000000000000001" : ] 000000112820189.569512000000000000 ; 000000125795249.051677000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AC2663BFF2C5 >									
	//     < RUSS_PFXIX_I_metadata_line_10_____EuroChem_Antwerpen_NV_20211101 >									
	//        < YVNw518rc7f2Od0714Zx3vxS0F55YLscea3w1dnu7FAOy29HjKyG57IMB022d13d >									
	//        <  u =="0.000000000000000001" : ] 000000125795249.051677000000000000 ; 000000141068019.380112000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BFF2C5D740B2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXIX_I_metadata_line_11_____EuroChem_VolgaKaliy_20211101 >									
	//        < NMs1qZ01FUsIJXwrL9Z5h9YiKtLN8g7OzA6XzE6cWQ51kwblgZ1s27o1IF911FzX >									
	//        <  u =="0.000000000000000001" : ] 000000141068019.380112000000000000 ; 000000157960282.146175000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D740B2F1073C >									
	//     < RUSS_PFXIX_I_metadata_line_12_____EuroChem_Usolsky_potash_complex_20211101 >									
	//        < VJLfHpGOG8Q7X6Z1k1AkiTp9Pk7A2Tz0eW3q42Zv57GJBRieWWwnKHY5oTx62l5D >									
	//        <  u =="0.000000000000000001" : ] 000000157960282.146175000000000000 ; 000000173136839.184379000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F1073C1082F94 >									
	//     < RUSS_PFXIX_I_metadata_line_13_____EuroChem_ONGK_20211101 >									
	//        < 12b62gmxEVF4kR8B6T8f653b12P50E089I1qov79su0qRxnkW71YKdLES9GYqP5r >									
	//        <  u =="0.000000000000000001" : ] 000000173136839.184379000000000000 ; 000000190315404.693409000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001082F9412265F4 >									
	//     < RUSS_PFXIX_I_metadata_line_14_____EuroChem_Northwest_20211101 >									
	//        < Ju3l626jrBH6q0G2o99s74f5x4P11Zt962tg5l44LN21s5k9OogU1sI6eF49915o >									
	//        <  u =="0.000000000000000001" : ] 000000190315404.693409000000000000 ; 000000205246133.661621000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012265F41392E45 >									
	//     < RUSS_PFXIX_I_metadata_line_15_____EuroChem_Fertilizers_20211101 >									
	//        < a2EkV1pkK5x7VaMDo4PR2tGujw4w8i0A7SynlymWi9kh4SdqgJ717lnYLQLL7PE1 >									
	//        <  u =="0.000000000000000001" : ] 000000205246133.661621000000000000 ; 000000219825309.164864000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001392E4514F6D43 >									
	//     < RUSS_PFXIX_I_metadata_line_16_____Astrakhan_Oil_and_Gas_Company_20211101 >									
	//        < zfJb47NY3CHvAx9uDr1sW93CM61c2xWO2Ni7g3e4eyKKpna3s35e45MzwGh5Hm21 >									
	//        <  u =="0.000000000000000001" : ] 000000219825309.164864000000000000 ; 000000233088933.978069000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014F6D43163AA5D >									
	//     < RUSS_PFXIX_I_metadata_line_17_____Sary_Tas_Fertilizers_20211101 >									
	//        < I645x97x5jXc78EPatSwXQKv8c43N5H98lDPCOSc5tIcy1IbMZJ1gSLLc3Z48MOk >									
	//        <  u =="0.000000000000000001" : ] 000000233088933.978069000000000000 ; 000000248173593.084223000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000163AA5D17AAECF >									
	//     < RUSS_PFXIX_I_metadata_line_18_____EuroChem_Karatau_20211101 >									
	//        < kD51V9XKlcBRx18jsd43waCpQB4YPLiBLEg4pa9t2wq150WED2W14xjPixYNr6ru >									
	//        <  u =="0.000000000000000001" : ] 000000248173593.084223000000000000 ; 000000263087541.306558000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017AAECF1917092 >									
	//     < RUSS_PFXIX_I_metadata_line_19_____Kamenkovskaya_Oil_Gas_Company_20211101 >									
	//        < Wive3T4m1z9Q35xnq977a3V5D28N8Bu4687R0jZGz1cYAVT51V8EHH6cU09Rz4Ll >									
	//        <  u =="0.000000000000000001" : ] 000000263087541.306558000000000000 ; 000000277718908.395665000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019170921A7C3F3 >									
	//     < RUSS_PFXIX_I_metadata_line_20_____EuroChem_Trading_GmbH_Trading_20211101 >									
	//        < k2S4Ybm25465Lr1MXJ8han2L9BVS60S6GvaTg7cRyUz1n1JdiigfB81U3butxUR0 >									
	//        <  u =="0.000000000000000001" : ] 000000277718908.395665000000000000 ; 000000291586070.320202000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A7C3F31BCECCF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXIX_I_metadata_line_21_____EuroChem_Trading_USA_Corp_20211101 >									
	//        < mB4z62T37B0gS8tlwcUjAAOhM7rPlnuIBxVc31C59xOnJ8M0VZ04N54R266TP36n >									
	//        <  u =="0.000000000000000001" : ] 000000291586070.320202000000000000 ; 000000304695733.287555000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BCECCF1D0EDC5 >									
	//     < RUSS_PFXIX_I_metadata_line_22_____Ben_Trei_Ltd_20211101 >									
	//        < 7hf81y8eS2u42c5OVaO21V5ZC0JCxkl6brFy88kAd08FInjdI0J4B3232GRVZ41q >									
	//        <  u =="0.000000000000000001" : ] 000000304695733.287555000000000000 ; 000000319235479.048364000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D0EDC51E71D5C >									
	//     < RUSS_PFXIX_I_metadata_line_23_____EuroChem_Agro_SAS_20211101 >									
	//        < 22de32pSMy3GhOqDWsbg3xsYHnkBY4P3h4okECX8bzH5QZDhePXo5BP6IRkTAN70 >									
	//        <  u =="0.000000000000000001" : ] 000000319235479.048364000000000000 ; 000000334599887.134484000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E71D5C1FE8F15 >									
	//     < RUSS_PFXIX_I_metadata_line_24_____EuroChem_Agro_Asia_20211101 >									
	//        < Wyp01psvt27IuP0tvVQ3uYWI604O4k9V0h1xd3of2HOCoq1plT925RE1E14I5TDF >									
	//        <  u =="0.000000000000000001" : ] 000000334599887.134484000000000000 ; 000000350219238.951943000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FE8F152166464 >									
	//     < RUSS_PFXIX_I_metadata_line_25_____EuroChem_Agro_Iberia_20211101 >									
	//        < nA161JnsayLak5GkRW88vGMAIwTisSvg6mb7c4vtDsR30luSVna5XYPLGW66xDdM >									
	//        <  u =="0.000000000000000001" : ] 000000350219238.951943000000000000 ; 000000367024299.004900000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000216646423008DE >									
	//     < RUSS_PFXIX_I_metadata_line_26_____EuroChem_Agricultural_Trading_Hellas_20211101 >									
	//        < 15HPKa3ny9lcOtCZa43PUHNw6zMzTh2S5SgxA49KOOHwFGtfnd17BanBQ137w3t6 >									
	//        <  u =="0.000000000000000001" : ] 000000367024299.004900000000000000 ; 000000383106217.865982000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023008DE24892DE >									
	//     < RUSS_PFXIX_I_metadata_line_27_____EuroChem_Agro_Spa_20211101 >									
	//        < 0h5inh1frI36DU082Ucp2rq3446mhBF4DU5zFG03D5NxQL98aO190Vp6pf5y44kO >									
	//        <  u =="0.000000000000000001" : ] 000000383106217.865982000000000000 ; 000000397548508.242207000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024892DE25E9C63 >									
	//     < RUSS_PFXIX_I_metadata_line_28_____EuroChem_Agro_GmbH_20211101 >									
	//        < 2WGOtIe4UH81wV32zwQ9QO2xtt4Q3F6Fv1ZtM38JOkyrs2VddMFdK82MlM276XBh >									
	//        <  u =="0.000000000000000001" : ] 000000397548508.242207000000000000 ; 000000411085700.755757000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025E9C63273445A >									
	//     < RUSS_PFXIX_I_metadata_line_29_____EuroChem_Agro_México_SA_20211101 >									
	//        < XkOk6M9d201iQB0t30yk27lQJH7yN9SP6t5h4R9khPAzo6zW2kqJ2PtD65vYRrts >									
	//        <  u =="0.000000000000000001" : ] 000000411085700.755757000000000000 ; 000000426289512.546324000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000273445A28A7757 >									
	//     < RUSS_PFXIX_I_metadata_line_30_____EuroChem_Agro_Hungary_Kft_20211101 >									
	//        < FbE7DSNU984t386v9y751N7whmTKeCyh7pmDj973200Y6H53upt5fIf8h27uLvT0 >									
	//        <  u =="0.000000000000000001" : ] 000000426289512.546324000000000000 ; 000000442313360.274946000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028A77572A2EAA8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXIX_I_metadata_line_31_____Agrocenter_EuroChem_Srl_20211101 >									
	//        < M6SC7X2Aak71rhs82r4Kg24991hFTge0kFHQQ4tkBXROTs3u7ft6BG8PdNE44qVv >									
	//        <  u =="0.000000000000000001" : ] 000000442313360.274946000000000000 ; 000000458719200.266083000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A2EAA82BBF330 >									
	//     < RUSS_PFXIX_I_metadata_line_32_____EuroChem_Agro_Bulgaria_Ead_20211101 >									
	//        < p5As0rFzgdbB6yB0Ey0H8I9883JR6pRXOE74LlXO994bZh9j5slk6k65k2AyTvI1 >									
	//        <  u =="0.000000000000000001" : ] 000000458719200.266083000000000000 ; 000000472416136.000198000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BBF3302D0D98E >									
	//     < RUSS_PFXIX_I_metadata_line_33_____EuroChem_Agro_doo_Beograd_20211101 >									
	//        < 4mDMZdDqKHYG1Yn1N7782GaCKDQmn1GA2N51bSmHIDrEi3nkg65uUJjb6X52UhrE >									
	//        <  u =="0.000000000000000001" : ] 000000472416136.000198000000000000 ; 000000485817548.591120000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D0D98E2E54C7B >									
	//     < RUSS_PFXIX_I_metadata_line_34_____EuroChem_Agro_Turkey_Tarim_Sanayi_ve_Ticaret_20211101 >									
	//        < z2j2W879O8k81g9UWRR6l2y4rhG1UVQwtz6YPG24P80mXK595WlII2t9LnMapXWt >									
	//        <  u =="0.000000000000000001" : ] 000000485817548.591120000000000000 ; 000000499334214.844985000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E54C7B2F9EC6D >									
	//     < RUSS_PFXIX_I_metadata_line_35_____Emerger_Fertilizantes_SA_20211101 >									
	//        < VJx85gjiD0Utnf4lyy56B63B8vg1i357caX9naIZ5AgVpMIxR013t130sjOC6z55 >									
	//        <  u =="0.000000000000000001" : ] 000000499334214.844985000000000000 ; 000000514623507.996935000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F9EC6D31140CF >									
	//     < RUSS_PFXIX_I_metadata_line_36_____EuroChem_Comercio_Produtos_Quimicos_20211101 >									
	//        < pj3zE6E915F6tYO1Sroc5eq9K52UtPvLBR2SDs54tkjzFgWnYNqw678J9DriLADH >									
	//        <  u =="0.000000000000000001" : ] 000000514623507.996935000000000000 ; 000000531661320.460459000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031140CF32B4034 >									
	//     < RUSS_PFXIX_I_metadata_line_37_____Fertilizantes_Tocantines_Ltda_20211101 >									
	//        < 73KHv6LCE7A5yBHbV9waB6v79tk4BHCGFRu3V7S2V2K7FSA3wK0TS22rMoeqGo6S >									
	//        <  u =="0.000000000000000001" : ] 000000531661320.460459000000000000 ; 000000548851000.633491000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032B40343457AEC >									
	//     < RUSS_PFXIX_I_metadata_line_38_____EuroChem_Agro_Trading_Shenzhen_20211101 >									
	//        < LYm5OmpR5wbxVWLp33QoA2p6G917MGniV7Lo70ID3rF0smUj98BuKEM2Zi2M744r >									
	//        <  u =="0.000000000000000001" : ] 000000548851000.633491000000000000 ; 000000564582543.099929000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003457AEC35D7C0E >									
	//     < RUSS_PFXIX_I_metadata_line_39_____EuroChem_Trading_RUS_20211101 >									
	//        < 8jn8fjaeC8RNi43137m84iQs0vWW3Wu9MC2qEnoX4HgE24JhQUmXYn9r56f4qh8M >									
	//        <  u =="0.000000000000000001" : ] 000000564582543.099929000000000000 ; 000000577807836.608177000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035D7C0E371AA30 >									
	//     < RUSS_PFXIX_I_metadata_line_40_____AgroCenter_EuroChem_Ukraine_20211101 >									
	//        < hfiR516V8SQgSwfk0At26CNSl1h2x26MJ0Y9bhVL6xLWcK8qgFB97T41X65RYDO6 >									
	//        <  u =="0.000000000000000001" : ] 000000577807836.608177000000000000 ; 000000592718827.615176000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000371AA303886ACB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}