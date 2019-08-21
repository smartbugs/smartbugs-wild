pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFVIII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFVIII_II_883		"	;
		string	public		symbol =	"	RUSS_PFVIII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		790133932048657000000000000					;	
										
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
	//     < RUSS_PFVIII_II_metadata_line_1_____NOVOLIPETSK_ORG_20231101 >									
	//        < 7eoMnfNAhtVZ69U537pT23uf6TBi3D8btU5eS68R213gr1NHb3q5sXIcJ94U2455 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000024872823.363313300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000025F3F2 >									
	//     < RUSS_PFVIII_II_metadata_line_2_____LLC_NTK_20231101 >									
	//        < y0KE40g2ewxn01gFRMIdjVzgthHQ62t7dAVDOD4qtS10lPRQ0JSMzpuH5X0e49Z5 >									
	//        <  u =="0.000000000000000001" : ] 000000024872823.363313300000000000 ; 000000042972717.020102600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000025F3F2419238 >									
	//     < RUSS_PFVIII_II_metadata_line_3_____NATIONAL_LAMINATIONS_GROUP_20231101 >									
	//        < nBs99MQ9VR5ZIbbTfLMR9In1JPyXvsfxSLV77fAQcS5FP38SFoom66CKrWB223CY >									
	//        <  u =="0.000000000000000001" : ] 000000042972717.020102600000000000 ; 000000063213731.066333000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004192386074DD >									
	//     < RUSS_PFVIII_II_metadata_line_4_____DOLOMITE_OJSC_20231101 >									
	//        < 04S1fV4uT24Pd812k2O35hW5Tf53IZsyXuvhu5t8a51i3R4TS6g8gu4TnnD1dV4w >									
	//        <  u =="0.000000000000000001" : ] 000000063213731.066333000000000000 ; 000000081056025.114908400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006074DD7BAE83 >									
	//     < RUSS_PFVIII_II_metadata_line_5_____LLC_TRADE_HOUSE_NLMK_20231101 >									
	//        < 7AV53Y57Y8Tek9wf2cJ3L834l4GvEjqHn76djzXeOtii2r95Te16bdMgmC27y4fw >									
	//        <  u =="0.000000000000000001" : ] 000000081056025.114908400000000000 ; 000000102543710.933873000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007BAE839C7823 >									
	//     < RUSS_PFVIII_II_metadata_line_6_____STUDENOVSK_MINING_CO_20231101 >									
	//        < Pw06U9PW0Y8VnG2vY9jBLRzU2nzJ9zvDqwCZ5dcs8xBDS80nAUTaQ8mTYLkB47Aw >									
	//        <  u =="0.000000000000000001" : ] 000000102543710.933873000000000000 ; 000000119331663.687261000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009C7823B615EE >									
	//     < RUSS_PFVIII_II_metadata_line_7_____VMI_RECYCLING_GROUP_20231101 >									
	//        < ml1b7DL7h7eo49E91bGJ56w1O2N8f8nrZ3TrXyCy9O272eGh8eL5cb6YBper9v35 >									
	//        <  u =="0.000000000000000001" : ] 000000119331663.687261000000000000 ; 000000135117972.411358000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B615EECE2C75 >									
	//     < RUSS_PFVIII_II_metadata_line_8_____VTORCHERMET_20231101 >									
	//        < e43X5th3lp918l568o6ytspn31Uf41fnzX40KzSVT45v9520KHjgZok0rMVQhc0B >									
	//        <  u =="0.000000000000000001" : ] 000000135117972.411358000000000000 ; 000000156109798.927944000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CE2C75EE3464 >									
	//     < RUSS_PFVIII_II_metadata_line_9_____KALUGA_RESEARCH_PROD_ELECTROMETALL_20231101 >									
	//        < xtBm24P3Jd1kx940F6AagLy1Z6o929h8tc9DE503E43xSk2zu4VUg81X1Muv3rm4 >									
	//        <  u =="0.000000000000000001" : ] 000000156109798.927944000000000000 ; 000000179572952.705409000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EE346411201AF >									
	//     < RUSS_PFVIII_II_metadata_line_10_____DANSTEEL_AS_20231101 >									
	//        < jfQcM878dYPWX0gVw37fdVmuufA7kXYdb3k4aBPB43rjC1oSlM0YDq3k6x6S92Lb >									
	//        <  u =="0.000000000000000001" : ] 000000179572952.705409000000000000 ; 000000200039247.436597000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011201AF1313C55 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFVIII_II_metadata_line_11_____NOVATEK_ORG_20231101 >									
	//        < 4i2s77AxTQ574fUwRZ2o9GnZOYv8drf2V4F5YXHrCT5b0x2BWusj7nmJ0tQ1pCJ1 >									
	//        <  u =="0.000000000000000001" : ] 000000200039247.436597000000000000 ; 000000218046474.776500000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001313C5514CB667 >									
	//     < RUSS_PFVIII_II_metadata_line_12_____NOVATEK_AB_20231101 >									
	//        < 5T6ZCqifnNYun5DGFL8ny7m8z6byv1U24wXjnwz4pm358Pc8F68vAa1Kmfd0qIx8 >									
	//        <  u =="0.000000000000000001" : ] 000000218046474.776500000000000000 ; 000000236261998.208497000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014CB66716881D8 >									
	//     < RUSS_PFVIII_II_metadata_line_13_____NOVATEK_DAC_20231101 >									
	//        < CX9oF5GckH8H46V5tnrm5Hms3086pJZADEnD3tV3rhx1uuFRVV01bKO29sOX0tOA >									
	//        <  u =="0.000000000000000001" : ] 000000236261998.208497000000000000 ; 000000255136818.078852000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016881D81854ED2 >									
	//     < RUSS_PFVIII_II_metadata_line_14_____PUROVSKY_ZPK_20231101 >									
	//        < GA5PsWyqh42OugmQ7KL8JFFEWQHqsi3Wqn7v2pz9N9ahWari743jOFId86u4Ibii >									
	//        <  u =="0.000000000000000001" : ] 000000255136818.078852000000000000 ; 000000271718694.268209000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001854ED219E9C1D >									
	//     < RUSS_PFVIII_II_metadata_line_15_____KOSTROMA_OOO_20231101 >									
	//        < zL2olfRKQ3TXZiho0l897M6s9pz6o1zwGPeR6H4W1s7860CQ2M10q3x7UAYiEc7q >									
	//        <  u =="0.000000000000000001" : ] 000000271718694.268209000000000000 ; 000000293199184.993519000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019E9C1D1BF62EE >									
	//     < RUSS_PFVIII_II_metadata_line_16_____SHERWOOD_PREMIER_LLC_20231101 >									
	//        < O1UM1G7W9aqLjLra1MV1CFkvi1jfien3bSN0S88F33xocyqga2fP9PITtHCJfdsS >									
	//        <  u =="0.000000000000000001" : ] 000000293199184.993519000000000000 ; 000000315771727.658092000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BF62EE1E1D455 >									
	//     < RUSS_PFVIII_II_metadata_line_17_____GEOTRANSGAZ_JSC_20231101 >									
	//        < 0M1k1hiqUeKl61DO7Kz0P2zb7UI9I5Yz96UZEl3sNL381OV8cDhV0nm16OJpgXPD >									
	//        <  u =="0.000000000000000001" : ] 000000315771727.658092000000000000 ; 000000331534793.737828000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E1D4551F9E1C7 >									
	//     < RUSS_PFVIII_II_metadata_line_18_____TAILIKSNEFTEGAS_20231101 >									
	//        < m95P2X6X2C1dRlY2XoM9DamWyUlpM7fQQ8Fn8D88G2I30i7zL87hoE3Mo63o43nZ >									
	//        <  u =="0.000000000000000001" : ] 000000331534793.737828000000000000 ; 000000353126221.417810000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F9E1C721AD3EE >									
	//     < RUSS_PFVIII_II_metadata_line_19_____URENGOYSKAYA_GAZOVAYA_KOMPANIYA_20231101 >									
	//        < 5YPVozw7j1eFTnO3QC5GOOg1Q28JAkm3Q9Vxh7yF2C7804F25a16iEdXQQg68QT2 >									
	//        <  u =="0.000000000000000001" : ] 000000353126221.417810000000000000 ; 000000374586685.738381000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021AD3EE23B92ED >									
	//     < RUSS_PFVIII_II_metadata_line_20_____PURNEFTEGAZGEOLOGIYA_20231101 >									
	//        < yj80RIVp2q3949o82650yqWnKj257US9Ig2TPk42y5A95xAsQD36VfLUNynV7hp5 >									
	//        <  u =="0.000000000000000001" : ] 000000374586685.738381000000000000 ; 000000399369362.848150000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023B92ED26163A8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFVIII_II_metadata_line_21_____OGK_2_20231101 >									
	//        < la80P14YrGP3E9Stw08kI02DJQwwGXUE53Ybhk0EV0Cvs0XCJfEPS7uUTK4KpD6Z >									
	//        <  u =="0.000000000000000001" : ] 000000399369362.848150000000000000 ; 000000419380078.574714000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026163A827FEC58 >									
	//     < RUSS_PFVIII_II_metadata_line_22_____RYAZANSKAYA_GRES_OAO_20231101 >									
	//        < bGlb14q75r08mwejv2mL3PsJiUEvwH0g7gm2Xx4u2J92BNpad77uXgyJJr92XZyT >									
	//        <  u =="0.000000000000000001" : ] 000000419380078.574714000000000000 ; 000000443465750.937851000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027FEC582A4ACCF >									
	//     < RUSS_PFVIII_II_metadata_line_23_____GAZPROM_INVESTPROJECT_20231101 >									
	//        < pU81NiZe788v8JnMm9dK2uMvW0wbT9c0U21Ab5fw8LOScp417g2aXsMWd82xyb04 >									
	//        <  u =="0.000000000000000001" : ] 000000443465750.937851000000000000 ; 000000461787315.477904000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A4ACCF2C0A1AC >									
	//     < RUSS_PFVIII_II_metadata_line_24_____TROITSKAYA_GRES_JSC_20231101 >									
	//        < Aa2p30fQ3lkW0V0Bn2K4eX55C0J5436sm4naewaf22sFe18De4GL673RUHZk5evV >									
	//        <  u =="0.000000000000000001" : ] 000000461787315.477904000000000000 ; 000000479479975.023002000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C0A1AC2DBA0DE >									
	//     < RUSS_PFVIII_II_metadata_line_25_____SURGUTSKAYA_TPP_1_20231101 >									
	//        < 502diBnAEO9QEr8DWv0753qj343X6269aH8s6oIZ2IZY5mZ7lIFkuze527390sfl >									
	//        <  u =="0.000000000000000001" : ] 000000479479975.023002000000000000 ; 000000502788087.259779000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DBA0DE2FF3199 >									
	//     < RUSS_PFVIII_II_metadata_line_26_____NOVOCHERKASSKAYA_TPP_20231101 >									
	//        < z162Mq1CbLt5oPGA7q773Rxnqo7m32B5bwQlO7F88XILlFkxfJveWFog3162n4LN >									
	//        <  u =="0.000000000000000001" : ] 000000502788087.259779000000000000 ; 000000518590637.654371000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FF31993174E78 >									
	//     < RUSS_PFVIII_II_metadata_line_27_____KIRISHSKAYA_GRES_OGK_6_20231101 >									
	//        < lAirvl42yTiLTdEy4ZE89285LNPi4nXWAs014IfF85HlXImFawXaBo78t22d9N8F >									
	//        <  u =="0.000000000000000001" : ] 000000518590637.654371000000000000 ; 000000541339796.836599000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003174E7833A04DC >									
	//     < RUSS_PFVIII_II_metadata_line_28_____KRASNOYARSKAYA_GRES_2_20231101 >									
	//        < Fa0728S9fPpw4T9HgwA6Eo8S2P75yo870xaZnP204332YMZTT15J2FMF3q21qcV0 >									
	//        <  u =="0.000000000000000001" : ] 000000541339796.836599000000000000 ; 000000566029704.135077000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033A04DC35FB15A >									
	//     < RUSS_PFVIII_II_metadata_line_29_____CHEREPOVETSKAYA_GRES_20231101 >									
	//        < 13zyjEP710qxoek4m3a96Y2ujjl8x3CIsaHfLpC5842SP19Qed01Zm98j5g2gYUw >									
	//        <  u =="0.000000000000000001" : ] 000000566029704.135077000000000000 ; 000000585955863.203769000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035FB15A37E1902 >									
	//     < RUSS_PFVIII_II_metadata_line_30_____STAVROPOLSKAYA_GRES_20231101 >									
	//        < NN594232H1ml7wnoe55JRI6t3vMsCLOeff18vSrgEFFyJ8Mq4w660W8F8Q84cuD3 >									
	//        <  u =="0.000000000000000001" : ] 000000585955863.203769000000000000 ; 000000609064720.445857000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037E19023A15BE8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFVIII_II_metadata_line_31_____OGK_2_ORG_20231101 >									
	//        < huo6W3ZN01eRl8OVPyTU1zc1gwp0Ga5Ku8ci9FK5DC7a6U0wXjf0b89N091ckGcC >									
	//        <  u =="0.000000000000000001" : ] 000000609064720.445857000000000000 ; 000000629949066.900460000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A15BE83C139DB >									
	//     < RUSS_PFVIII_II_metadata_line_32_____OGK_2_PSKOV_GRES_20231101 >									
	//        < u4S4M51gy4RCrIHQNgz2us8ph820RRV6G80k6243PXJ9y8K0Pwt29wl28jpZ2ok8 >									
	//        <  u =="0.000000000000000001" : ] 000000629949066.900460000000000000 ; 000000647755326.285052000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C139DB3DC656D >									
	//     < RUSS_PFVIII_II_metadata_line_33_____OGK_2_SEROV_GRES_20231101 >									
	//        < Ud1bs3y8R53QspVXXT1N3j6bxC5w50KnNpU8L8sPX9m21YpKNsFxFsJnwkVn4Pgv >									
	//        <  u =="0.000000000000000001" : ] 000000647755326.285052000000000000 ; 000000664249045.263960000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DC656D3F59049 >									
	//     < RUSS_PFVIII_II_metadata_line_34_____OGK_2_STAVROPOL_GRES_20231101 >									
	//        < 6ABU438Fybv25SQYlen74Z28w99qBix238d5C71FQ38302Yp13ea941py1HGmkU2 >									
	//        <  u =="0.000000000000000001" : ] 000000664249045.263960000000000000 ; 000000686024781.684246000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F59049416CA6E >									
	//     < RUSS_PFVIII_II_metadata_line_35_____OGK_2_SURGUT_GRES_20231101 >									
	//        < Nm3acRs1a33be17tGGC5W8e6k30Y4231JYx4I8j7puT34hxIrv4oQUfmmHBg8pJJ >									
	//        <  u =="0.000000000000000001" : ] 000000686024781.684246000000000000 ; 000000701636262.715802000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000416CA6E42E9CAA >									
	//     < RUSS_PFVIII_II_metadata_line_36_____OGK_2_TROITSK_GRES_20231101 >									
	//        < vahnFqN8uqUF89Swa0gDr99LH0sp7fj453vQSoRx49W3N9BUi4g4xom4xCmdL1RH >									
	//        <  u =="0.000000000000000001" : ] 000000701636262.715802000000000000 ; 000000721211517.449627000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042E9CAA44C7B40 >									
	//     < RUSS_PFVIII_II_metadata_line_37_____OGK_2_NOVOCHERKASSK_GRES_20231101 >									
	//        < w316dXd5oTkzJ3Yj4Id50692L004q5Q2nMv53ABDSCaa1Zy3B6Kmfa9MKqBT0OGs >									
	//        <  u =="0.000000000000000001" : ] 000000721211517.449627000000000000 ; 000000740302587.051378000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044C7B404699CB3 >									
	//     < RUSS_PFVIII_II_metadata_line_38_____OGK_2_KIRISHI_GRES_20231101 >									
	//        < ucD2783d8CqjEIQZ6HAh4Y3q1k2KXkk4u668D3dEj0SwX0k1zLut1OKF60UEIfY3 >									
	//        <  u =="0.000000000000000001" : ] 000000740302587.051378000000000000 ; 000000756422985.385360000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004699CB348235BB >									
	//     < RUSS_PFVIII_II_metadata_line_39_____OGK_2_RYAZAN_GRES_20231101 >									
	//        < sQPqBTup5aXyGQTXRiK87SNI7yM2rk5VXbE8iZ3o38C35pX0q4w71S46Yh5e6T2r >									
	//        <  u =="0.000000000000000001" : ] 000000756422985.385360000000000000 ; 000000772329017.238177000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048235BB49A7B06 >									
	//     < RUSS_PFVIII_II_metadata_line_40_____OGK_2_KRASNOYARSK_GRES_20231101 >									
	//        < 5Lvqzzu22ojIYNclO4QpGcc8Oi4JOAJRmD2105r694M0UK8NX0dFbSy119WM1hb6 >									
	//        <  u =="0.000000000000000001" : ] 000000772329017.238177000000000000 ; 000000790133932.048658000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049A7B064B5A611 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}