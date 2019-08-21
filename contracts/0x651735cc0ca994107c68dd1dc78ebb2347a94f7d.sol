pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFVII_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFVII_I_883		"	;
		string	public		symbol =	"	RUSS_PFVII_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		612375923861292000000000000					;	
										
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
	//     < RUSS_PFVII_I_metadata_line_1_____NOVATEK_20211101 >									
	//        < 63B5S7L1s4k05LekWN3C32FzRqTf0ZqwKFSxanu6lgZ69V63GOi9714WXm68Lyk3 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000013588231.378455900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000014BBE7 >									
	//     < RUSS_PFVII_I_metadata_line_2_____NORTHGAS_20211101 >									
	//        < 4ZuFrrr1i63F62zXK9q865ND8ytoO7439ZbD73L745NYGn0W6hfkYdaZB8DkVWi6 >									
	//        <  u =="0.000000000000000001" : ] 000000013588231.378455900000000000 ; 000000028410091.679849600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000014BBE72B59B1 >									
	//     < RUSS_PFVII_I_metadata_line_3_____SEVERENERGIA_20211101 >									
	//        < 35X0qo56c1n9HU79THnLRwS5U7e5350d17Rico7W34s1rPy611m1atcHWX0VCp99 >									
	//        <  u =="0.000000000000000001" : ] 000000028410091.679849600000000000 ; 000000044622403.806168400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002B59B14416A0 >									
	//     < RUSS_PFVII_I_metadata_line_4_____NOVATEK_ARCTIC_LNG_1_20211101 >									
	//        < 0G8yXWM3449qenJkmD1bxP6QkhhJh5k28ow4V3X9N539HXPbVEFEBIc1830jgXN8 >									
	//        <  u =="0.000000000000000001" : ] 000000044622403.806168400000000000 ; 000000061535517.638086300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004416A05DE550 >									
	//     < RUSS_PFVII_I_metadata_line_5_____NOVATEK_YURKHAROVNEFTEGAS_20211101 >									
	//        < 2vF9oIaowA6z7463Xwat29HkQtEtK5ExCVf1bFANrexBVDpSMI9T3ou4L948F3uC >									
	//        <  u =="0.000000000000000001" : ] 000000061535517.638086300000000000 ; 000000078577848.839927600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005DE55077E679 >									
	//     < RUSS_PFVII_I_metadata_line_6_____NOVATEK_GAS_POWER_GMBH_20211101 >									
	//        < fm8051LEZFdm3574OabM1V9tTfh31LE44GHMP6N6glc023pFaJSuA5hndqHXb0t9 >									
	//        <  u =="0.000000000000000001" : ] 000000078577848.839927600000000000 ; 000000092957138.541491600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000077E6798DD762 >									
	//     < RUSS_PFVII_I_metadata_line_7_____OOO_CHERNICHNOYE_20211101 >									
	//        < utla4s1QCJIn7ggi91DCeQ1B5W6Z6YwXi1B91Q1XN1xGOsP1vryT6TOH1Na8iO50 >									
	//        <  u =="0.000000000000000001" : ] 000000092957138.541491600000000000 ; 000000109840429.246471000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008DD762A79A6B >									
	//     < RUSS_PFVII_I_metadata_line_8_____OAO_TAMBEYNEFTEGAS_20211101 >									
	//        < 64dHO61D6MbMAtMSd0t53900957t5oGAwr80yjazx01h93lM6YzHhv2sl1X86nm8 >									
	//        <  u =="0.000000000000000001" : ] 000000109840429.246471000000000000 ; 000000125657170.680854000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A79A6BBFBCD5 >									
	//     < RUSS_PFVII_I_metadata_line_9_____NOVATEK_TRANSERVICE_20211101 >									
	//        < 4P9fhCLLM2yRhVI8JYY2q3J9YOlDaZiyH7zmqwd22BehjNK5KS6Mkco4Eu50B5P7 >									
	//        <  u =="0.000000000000000001" : ] 000000125657170.680854000000000000 ; 000000140004956.930148000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BFBCD5D5A170 >									
	//     < RUSS_PFVII_I_metadata_line_10_____NOVATEK_ARCTIC_LNG_2_20211101 >									
	//        < 28Z7pY6wkA9FkrX9oxTl6Y68u0f9EItfCCBB8gBZ7hisXLny59zn3UanioNd9xYp >									
	//        <  u =="0.000000000000000001" : ] 000000140004956.930148000000000000 ; 000000154481816.830488000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D5A170EBB876 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFVII_I_metadata_line_11_____YAMAL_LNG_20211101 >									
	//        < 4zXNZ8Z8cxX7Ir50yB26ZNVO61zcnkmjHQM22Av0kzfqc9bSp83JtH9a867A3SWK >									
	//        <  u =="0.000000000000000001" : ] 000000154481816.830488000000000000 ; 000000169599437.834371000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EBB876102C9C8 >									
	//     < RUSS_PFVII_I_metadata_line_12_____OOO_YARGEO_20211101 >									
	//        < 61j8kr15O5MK34sM5dR0jq9ou2852GK4mB316Kc9YJchKOpFR0qi391C8tEz8u2H >									
	//        <  u =="0.000000000000000001" : ] 000000169599437.834371000000000000 ; 000000185883580.872533000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000102C9C811BA2C6 >									
	//     < RUSS_PFVII_I_metadata_line_13_____NOVATEK_ARCTIC_LNG_3_20211101 >									
	//        < 3pUe24729Q7M639a1gDhNen5ui375L4i5AxP1z8a75l1864pz8k05whRrVWlbDpW >									
	//        <  u =="0.000000000000000001" : ] 000000185883580.872533000000000000 ; 000000200332263.814627000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011BA2C6131AECA >									
	//     < RUSS_PFVII_I_metadata_line_14_____TERNEFTEGAZ_JSC_20211101 >									
	//        < m3aMXEBqrev6hz035O3Iv5N6BFZh2B3hx0Zwb397zBT6BYa226yi2bC6HA0DE0QS >									
	//        <  u =="0.000000000000000001" : ] 000000200332263.814627000000000000 ; 000000215650437.388532000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000131AECA1490E74 >									
	//     < RUSS_PFVII_I_metadata_line_15_____OOO_UNITEX_20211101 >									
	//        < uL9jN26RBCfrn9ZhGnTz5bXaDn8Tsp0GyDNAJ7qRi3s752Y8u0F03j295PDlv5zM >									
	//        <  u =="0.000000000000000001" : ] 000000215650437.388532000000000000 ; 000000231395652.875224000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001490E7416114ED >									
	//     < RUSS_PFVII_I_metadata_line_16_____NOVATEK_FINANCE_DESIGNATED_ACTIVITY_CO_20211101 >									
	//        < qRarFHVlFUUXVzkJRZm28b9dt6GsPCB61oI0l50cWpKh27Ch3aC2mSkKh81msDUV >									
	//        <  u =="0.000000000000000001" : ] 000000231395652.875224000000000000 ; 000000245279328.172585000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016114ED176443D >									
	//     < RUSS_PFVII_I_metadata_line_17_____NOVATEK_EQUITY_CYPRUS_LIMITED_20211101 >									
	//        < jhNNZu7PT0xXL1v023GVCjja5nQCN8ADqcF61zHMzkbevqqYosagKMJJN8W776yL >									
	//        <  u =="0.000000000000000001" : ] 000000245279328.172585000000000000 ; 000000260278155.058946000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000176443D18D2728 >									
	//     < RUSS_PFVII_I_metadata_line_18_____BLUE_GAZ_SP_ZOO_20211101 >									
	//        < ie39Vj2sFgAx2H0bnv9F17B2DP2g0VtE8x799GC0myihxPI997V9tz7mIUtjs6SV >									
	//        <  u =="0.000000000000000001" : ] 000000260278155.058946000000000000 ; 000000273648427.943480000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018D27281A18DEB >									
	//     < RUSS_PFVII_I_metadata_line_19_____NOVATEK_OVERSEAS_AG_20211101 >									
	//        < UyZ30pYDztW538v9MsJ5530h5wgCo67ubLhT89fDe3dem71HnHj99C0gOa0k95zu >									
	//        <  u =="0.000000000000000001" : ] 000000273648427.943480000000000000 ; 000000290674738.307496000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A18DEB1BB88D2 >									
	//     < RUSS_PFVII_I_metadata_line_20_____NOVATEK_POLSKA_SP_ZOO_20211101 >									
	//        < oMuoVC82NR6yb2MLyzmVd5m991119GiHrR52vorpIUw4ri1lSsV76CkHkRWZwWF0 >									
	//        <  u =="0.000000000000000001" : ] 000000290674738.307496000000000000 ; 000000305099667.679298000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BB88D21D18B8F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFVII_I_metadata_line_21_____CRYOGAS_VYSOTSK_CJSC_20211101 >									
	//        < 9FB5c60pPS0XgQy57T3O94aD4Va3G6nl6pFZrCZ9a23GP4hx630peb0vKfPz8LIV >									
	//        <  u =="0.000000000000000001" : ] 000000305099667.679298000000000000 ; 000000320150619.303392000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D18B8F1E882D6 >									
	//     < RUSS_PFVII_I_metadata_line_22_____OOO_PETRA_INVEST_M_20211101 >									
	//        < fgldPbWFILqUD6C3IBLjE5JT70rPs4GDT15N94QHNqUhom11t2EasdvT6PHFqDDd >									
	//        <  u =="0.000000000000000001" : ] 000000320150619.303392000000000000 ; 000000334485179.208799000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E882D61FE6246 >									
	//     < RUSS_PFVII_I_metadata_line_23_____ARCTICGAS_20211101 >									
	//        < qW3q00fI98jZQ310ekzz02MW88m7au43dcJH2WQFfH7oUzWAx2d8m7vV6x9hJH0Z >									
	//        <  u =="0.000000000000000001" : ] 000000334485179.208799000000000000 ; 000000349155467.084207000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FE6246214C4DB >									
	//     < RUSS_PFVII_I_metadata_line_24_____YARSALENEFTEGAZ_LLC_20211101 >									
	//        < c39NX2zSnIaR3PIch55RO809U2tD9xsi067ZYBch9L57eX8Vbb8e40VrN988CE17 >									
	//        <  u =="0.000000000000000001" : ] 000000349155467.084207000000000000 ; 000000364793305.573425000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000214C4DB22CA163 >									
	//     < RUSS_PFVII_I_metadata_line_25_____NOVATEK_CHELYABINSK_20211101 >									
	//        < QHjx88z8mcJ8DTe111ERvyT6KpVOV2l86z7n9suHt74zt4sW1G987xmB24u3ns37 >									
	//        <  u =="0.000000000000000001" : ] 000000364793305.573425000000000000 ; 000000378646152.486809000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022CA163241C4A7 >									
	//     < RUSS_PFVII_I_metadata_line_26_____EVROTEK_ZAO_20211101 >									
	//        < M1Fd6RP6UToyy1n279a1yT832wrP6Uj4Ka3i4BIUarRf6T3F2ZUfiz98S9YEY8w7 >									
	//        <  u =="0.000000000000000001" : ] 000000378646152.486809000000000000 ; 000000394659909.752730000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000241C4A725A3407 >									
	//     < RUSS_PFVII_I_metadata_line_27_____OOO_NOVASIB_20211101 >									
	//        < Ub62pGFk9Lcv4K72weX5pitofDO4d7iUnQeD30IJ57Csio5PfGjw72W44vIs5rQE >									
	//        <  u =="0.000000000000000001" : ] 000000394659909.752730000000000000 ; 000000408930793.802615000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025A340726FFA97 >									
	//     < RUSS_PFVII_I_metadata_line_28_____NOVATEK_PERM_OOO_20211101 >									
	//        < 9rs0Aq3GaDlg6R9n81zm6zJhaMq3513T526Kvt985z0jD1LtMA66OsaV57bmbS5B >									
	//        <  u =="0.000000000000000001" : ] 000000408930793.802615000000000000 ; 000000424466195.230706000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026FFA97287AF1C >									
	//     < RUSS_PFVII_I_metadata_line_29_____NOVATEK_AZK_20211101 >									
	//        < 5akM3r8g998bO9F530B9GczC882BuEi66j7nGVxU6z9Vn983Txd6P3Q9t4Us13u7 >									
	//        <  u =="0.000000000000000001" : ] 000000424466195.230706000000000000 ; 000000441012877.838483000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000287AF1C2A0EEA8 >									
	//     < RUSS_PFVII_I_metadata_line_30_____NOVATEK_NORTH_WEST_20211101 >									
	//        < 1l7jiNK2UnnA3f1oMx1zIt5PDA5ag06U1hu1hPEfLa2rDi6K8N8pKbpjUPz3E9Ci >									
	//        <  u =="0.000000000000000001" : ] 000000441012877.838483000000000000 ; 000000455105362.945307000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A0EEA82B66F88 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFVII_I_metadata_line_31_____OOO_EKOPROMSTROY_20211101 >									
	//        < ayk741LdVF2Y7VA63vcYjlI0GzH2Cf7YW69lF12v9c10sDXjoxislLoX55HB9nc3 >									
	//        <  u =="0.000000000000000001" : ] 000000455105362.945307000000000000 ; 000000469250070.917711000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B66F882CC04CF >									
	//     < RUSS_PFVII_I_metadata_line_32_____OVERSEAS_EP_20211101 >									
	//        < 75ZMtNXQ26nWk07i6E7768zDQ2qt0i42RbeS7EKxxwJE23CGp6ijkKQgkVS2A9W2 >									
	//        <  u =="0.000000000000000001" : ] 000000469250070.917711000000000000 ; 000000486519864.767735000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CC04CF2E65ED2 >									
	//     < RUSS_PFVII_I_metadata_line_33_____KOL_SKAYA_VERF_20211101 >									
	//        < wn58M3IfxSiX3Lc9j2zRA48Z9TDa17omzV9z8fNs7OU64qsZmsX0W36e090awI8B >									
	//        <  u =="0.000000000000000001" : ] 000000486519864.767735000000000000 ; 000000501701967.951776000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E65ED22FD8955 >									
	//     < RUSS_PFVII_I_metadata_line_34_____TARKOSELENEFTEGAS_20211101 >									
	//        < Yw1E50E1Jy1v8HFy02u6aX67e4dk3dzzKw9Ny3E89PD5JgxnidGuT3cl3IRDlpvO >									
	//        <  u =="0.000000000000000001" : ] 000000501701967.951776000000000000 ; 000000518961775.070482000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FD8955317DF72 >									
	//     < RUSS_PFVII_I_metadata_line_35_____TAMBEYNEFTEGAS_OAO_20211101 >									
	//        < 83Jhz2Lo5RQ54867n0t55UH5297CLCbU3CaK7az5MmBsB3Uk042v7p8Z6vP5wJ2x >									
	//        <  u =="0.000000000000000001" : ] 000000518961775.070482000000000000 ; 000000533737434.233774000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000317DF7232E6B2F >									
	//     < RUSS_PFVII_I_metadata_line_36_____OOO_NOVATEK_MOSCOW_REGION_20211101 >									
	//        < 3ZOnv7prtf114h49b1SXmgdt155mV9Jd19hh0cTd3CQEvCON6SOJC6R8747L52qy >									
	//        <  u =="0.000000000000000001" : ] 000000533737434.233774000000000000 ; 000000550720472.602375000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032E6B2F348552F >									
	//     < RUSS_PFVII_I_metadata_line_37_____OILTECHPRODUKT_INVEST_20211101 >									
	//        < 1i48O4ntVN08GyBjeEQht9a13OF6oja3a1t9z019ew1fPHqf31P0sEHIPyHNL198 >									
	//        <  u =="0.000000000000000001" : ] 000000550720472.602375000000000000 ; 000000566314126.832885000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000348552F3602075 >									
	//     < RUSS_PFVII_I_metadata_line_38_____NOVATEK_UST_LUGA_20211101 >									
	//        < 2z71CnsA30aR1SX15ZFw43104dsjS5DJ3skD4c245Pl5oPzS44x9dT53Tp0P2aGh >									
	//        <  u =="0.000000000000000001" : ] 000000566314126.832885000000000000 ; 000000582341269.829540000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003602075378950F >									
	//     < RUSS_PFVII_I_metadata_line_39_____NOVATEK_SCIENTIFIC_TECHNICAL_CENTER_20211101 >									
	//        < 0OvE338ij00upOKy9Kec2atD918xp98dwk16B2aQ18kiO0jrW203uUpbAH8hfD3d >									
	//        <  u =="0.000000000000000001" : ] 000000582341269.829540000000000000 ; 000000596926724.276381000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000378950F38ED680 >									
	//     < RUSS_PFVII_I_metadata_line_40_____NOVATEK_GAS_POWER_ASIA_PTE_LTD_20211101 >									
	//        < uR7Ha24Ylx048jNh3ps73CKGXErHdBsU6990wThR385Ed1iuOl0VHtTavDx4Cq3w >									
	//        <  u =="0.000000000000000001" : ] 000000596926724.276381000000000000 ; 000000612375923.861292000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038ED6803A66958 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}