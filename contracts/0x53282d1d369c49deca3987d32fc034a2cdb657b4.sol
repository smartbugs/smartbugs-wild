pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFIII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFIII_II_883		"	;
		string	public		symbol =	"	NDRV_PFIII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1105550122503160000000000000					;	
										
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
	//     < NDRV_PFIII_II_metadata_line_1_____talanx_20231101 >									
	//        < 536G7BrWIHoG95W7aTs3fku8Tmz6c1v0ybZHwjI39653g1O5M4865nofKXp00P7t >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000049934888.669521500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000004C31D1 >									
	//     < NDRV_PFIII_II_metadata_line_2_____hdi haftpflichtverband der deutsch_indus_versicherungsverein gegenseitigkeit_20231101 >									
	//        < LlrL9QhQtLP0elIAFoH7Z0D3z3qaWQnQOJ7LQW78I9lAAzqcj9UpWm16ly5nr1jS >									
	//        <  u =="0.000000000000000001" : ] 000000049934888.669521500000000000 ; 000000095601154.058605300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004C31D191E033 >									
	//     < NDRV_PFIII_II_metadata_line_3_____hdi global se_20231101 >									
	//        < mgPV11eeEz6Vm8WItEc67E5GL4M3309gsf64BSL0LZJhT4eK9z891s7nuhaUQP05 >									
	//        <  u =="0.000000000000000001" : ] 000000095601154.058605300000000000 ; 000000112226564.392239000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000091E033AB3E80 >									
	//     < NDRV_PFIII_II_metadata_line_4_____hdi global network ag_20231101 >									
	//        < 596al56J26qtx3cZ4Uhq8Ag2t6lMqSU4n1Z7CY4ZhTU7BJ1Z347p95A1v2BrN712 >									
	//        <  u =="0.000000000000000001" : ] 000000112226564.392239000000000000 ; 000000128297799.728564000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AB3E80C3C454 >									
	//     < NDRV_PFIII_II_metadata_line_5_____hdi global network ag hdi global seguros sa_20231101 >									
	//        < zEn3WXi5ptJ8F7p837DSDBunpIlA1jaD77i58RV201Qc9d6w45pBaH7JA8s5ns63 >									
	//        <  u =="0.000000000000000001" : ] 000000128297799.728564000000000000 ; 000000150284908.437216000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C3C454E5510B >									
	//     < NDRV_PFIII_II_metadata_line_6_____hdi global se hdi-gerling industrial insurance company_20231101 >									
	//        < 636d6j1jZc49c72Ghag95v2yfhY6rEt88xhdZW5fDA0U1bRJgK91cCIpx9CSf9PX >									
	//        <  u =="0.000000000000000001" : ] 000000150284908.437216000000000000 ; 000000200333485.464792000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E5510B131AF45 >									
	//     < NDRV_PFIII_II_metadata_line_7_____hdi_gerling industrial insurance company uk branch_20231101 >									
	//        < C8szsm8R7vDC9XuAF668hCA9T4Ay8H85ABRRa34RxZrChjP1bYF1cgi4m9gtT2d1 >									
	//        <  u =="0.000000000000000001" : ] 000000200333485.464792000000000000 ; 000000241207036.069840000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000131AF451700D80 >									
	//     < NDRV_PFIII_II_metadata_line_8_____hdi global se hdi_gerling de méxico seguros sa_20231101 >									
	//        < 7ha28Hy7SzmG753kDB76vx88NYK6BiaTdgnL1v67Y0T1nSZKBm6YoV8Tf4Dm2b8p >									
	//        <  u =="0.000000000000000001" : ] 000000241207036.069840000000000000 ; 000000266966921.577538000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001700D801975BF4 >									
	//     < NDRV_PFIII_II_metadata_line_9_____hdi global se spain branch_20231101 >									
	//        < xjW7PPWeCfQ7dc09F9AIxEF6K6oyYSC6w071t3c8J3780P697WA9WfrfRTT09CdY >									
	//        <  u =="0.000000000000000001" : ] 000000266966921.577538000000000000 ; 000000283478328.111384000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001975BF41B08DB9 >									
	//     < NDRV_PFIII_II_metadata_line_10_____hdi global se nassau verzekering maatschappij nv_20231101 >									
	//        < 78stxnE3ezbvL8fcLIB5ch5466fegfNv1OC29m2fPoQyzHRz5JPexBUqiUPocJ03 >									
	//        <  u =="0.000000000000000001" : ] 000000283478328.111384000000000000 ; 000000318816753.462197000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B08DB91E679CB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFIII_II_metadata_line_11_____hdi_gerling industrie versicherung ag_20231101 >									
	//        < 0IuGVEP64wkI9Ki30T6rg09hi3pM7iYUWt36knk0t7E00cz3mE1p610Nn335S7E5 >									
	//        <  u =="0.000000000000000001" : ] 000000318816753.462197000000000000 ; 000000361429166.149065000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E679CB2277F45 >									
	//     < NDRV_PFIII_II_metadata_line_12_____hdi global se gerling norge as_20231101 >									
	//        < RSDK6umN4L4K2J96r4tbACf99926VUt1O9a855Jr9H5YTT21W3Xdpg7NEQEq93N5 >									
	//        <  u =="0.000000000000000001" : ] 000000361429166.149065000000000000 ; 000000378975000.688759000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002277F45242451C >									
	//     < NDRV_PFIII_II_metadata_line_13_____hdi_gerling industrie versicherung ag hellas branch_20231101 >									
	//        < py44g9Vau4Du8477sO7r6BRjkz4iHqaYJWQ0Tt02zOph7z623qI6qE4PO66j2TSp >									
	//        <  u =="0.000000000000000001" : ] 000000378975000.688759000000000000 ; 000000402664755.676626000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000242451C2666AEC >									
	//     < NDRV_PFIII_II_metadata_line_14_____hdi_gerling verzekeringen nv_20231101 >									
	//        < 7N3lVtNvq3K09d1tX9D3gZ91do7iQmlxo1e29252Fj2Q9j7jYCwXI28aG5oK9J9u >									
	//        <  u =="0.000000000000000001" : ] 000000402664755.676626000000000000 ; 000000427353937.615898000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002666AEC28C1722 >									
	//     < NDRV_PFIII_II_metadata_line_15_____hdi_gerling verzekeringen nv hj roelofs_assuradeuren bv_20231101 >									
	//        < 8wR5QJ54Xn4yRDkj601GGjB1m8M32h5FeqwK0t06D1s2nkaxIzQI5lDd3smV3vt1 >									
	//        <  u =="0.000000000000000001" : ] 000000427353937.615898000000000000 ; 000000454575103.766785000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028C17222B5A066 >									
	//     < NDRV_PFIII_II_metadata_line_16_____hdi global sa ltd_20231101 >									
	//        < S6llOTEcEX55bAso2kHHN6SdPJ9n2asjVRK0aB0McBe9TI929CbyO2ZdH37k241x >									
	//        <  u =="0.000000000000000001" : ] 000000454575103.766785000000000000 ; 000000472898254.220884000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B5A0662D195E1 >									
	//     < NDRV_PFIII_II_metadata_line_17_____Hannover Re_20231101 >									
	//        < CK33yhlK4f9A915KQVhUGfKZ4nn25uuCU85jSfpcO9SbS1mbB40dPiTbxsDdu6ve >									
	//        <  u =="0.000000000000000001" : ] 000000472898254.220884000000000000 ; 000000490294506.254472000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D195E12EC214B >									
	//     < NDRV_PFIII_II_metadata_line_18_____hdi versicherung ag_20231101 >									
	//        < f524Q3wXxJz4X3maHF8EU9YL4rYJ191HbI02Jv7WTD2HegrrRwDTTpmGLyYiA96S >									
	//        <  u =="0.000000000000000001" : ] 000000490294506.254472000000000000 ; 000000516571276.016631000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EC214B31439A8 >									
	//     < NDRV_PFIII_II_metadata_line_19_____talanx asset management gmbh_20231101 >									
	//        < NgZC9i0OHPiok06c56rFjE9L8Xs2OEEzN904u7ov2WWXjk7QsP4dsBF00514Lt9Z >									
	//        <  u =="0.000000000000000001" : ] 000000516571276.016631000000000000 ; 000000536494130.911033000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031439A8332A005 >									
	//     < NDRV_PFIII_II_metadata_line_20_____talanx immobilien management gmbh_20231101 >									
	//        < c22GXWQ17KZDNU7wCPVwE3vRQtdudrQq451AYC5Brj3A03uZ3uL0z6aMdhpoC1yM >									
	//        <  u =="0.000000000000000001" : ] 000000536494130.911033000000000000 ; 000000561172076.082281000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000332A00535847D8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFIII_II_metadata_line_21_____talanx ampega investment gmbh_20231101 >									
	//        < b06FgdqOwN3M1UfnHmRKyxtQMN0xEafi3F0Mnb6aV5zw8972KqL06mWP0y95hLJe >									
	//        <  u =="0.000000000000000001" : ] 000000561172076.082281000000000000 ; 000000582848197.353500000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035847D83795B14 >									
	//     < NDRV_PFIII_II_metadata_line_22_____talanx hdi pensionskasse ag_20231101 >									
	//        < ad4iD134e6Xc7ft0nR960emj8GNa4T4c4X8Iv84Zi5X0bZTOVMKO38QOq1470O33 >									
	//        <  u =="0.000000000000000001" : ] 000000582848197.353500000000000000 ; 000000600715746.701114000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003795B143949E97 >									
	//     < NDRV_PFIII_II_metadata_line_23_____talanx international ag_20231101 >									
	//        < H3R7Lc0hmQ47jJZqJx044168imS7QhGMEWXINWLM9Bt939vzE3kfD2u8R21VobFl >									
	//        <  u =="0.000000000000000001" : ] 000000600715746.701114000000000000 ; 000000617061513.022162000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003949E973AD8FA7 >									
	//     < NDRV_PFIII_II_metadata_line_24_____talanx targo versicherung ag_20231101 >									
	//        < c1Z32449FWFuDr1HLiwt3z7IIgyvy8Ya1cOq2O95u0w0IUybN83YEP9AAd6rNAyO >									
	//        <  u =="0.000000000000000001" : ] 000000617061513.022162000000000000 ; 000000640231839.242403000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003AD8FA73D0EA90 >									
	//     < NDRV_PFIII_II_metadata_line_25_____talanx pb lebensversicherung ag_20231101 >									
	//        < 5O4CkO531amAD1X64r9w61SRQ9xUl0SE9K8F78QrT80RxTv2n7p0d5Fms7Qry2v0 >									
	//        <  u =="0.000000000000000001" : ] 000000640231839.242403000000000000 ; 000000676550919.551325000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D0EA9040855B4 >									
	//     < NDRV_PFIII_II_metadata_line_26_____talanx targo lebensversicherung ag_20231101 >									
	//        < vP63I9zq8HKBcF27qv55537kJUL2LwNN1bF01CYWCXl15ynE7V1f7iOGC0UZh6UH >									
	//        <  u =="0.000000000000000001" : ] 000000676550919.551325000000000000 ; 000000725416957.635089000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040855B4452E600 >									
	//     < NDRV_PFIII_II_metadata_line_27_____talanx hdi global insurance company_20231101 >									
	//        < yFjB6dqnxhPI8Lnu7k5q9m56KMQ8rM3QTkpZlTJqsoQ4D78ixpXG72650c5xaigk >									
	//        <  u =="0.000000000000000001" : ] 000000725416957.635089000000000000 ; 000000767035358.491812000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000452E6004926730 >									
	//     < NDRV_PFIII_II_metadata_line_28_____talanx civ life russia_20231101 >									
	//        < 1CHpjnyLL4e6a0p1qt78uVRo7I5mHs5k53cc8joQM4g17v8DxCqw5rFic8SfZ0oX >									
	//        <  u =="0.000000000000000001" : ] 000000767035358.491812000000000000 ; 000000786441705.969043000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049267304B003CB >									
	//     < NDRV_PFIII_II_metadata_line_29_____talanx reinsurance ireland limited_20231101 >									
	//        < nJN6R6WWPMHeHsmH0crfEa7Quu5gt53mRWrM2002NDA7ZCssk3QOH872XqljVXb9 >									
	//        <  u =="0.000000000000000001" : ] 000000786441705.969043000000000000 ; 000000810157460.560207000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B003CB4D433C2 >									
	//     < NDRV_PFIII_II_metadata_line_30_____talanx deutschland ag_20231101 >									
	//        < 6SnaP13l6h87JWY60TK7BCJ781g87jvJNM181GpHBK3D2a8Yzzd1q07wrvpCJNBc >									
	//        <  u =="0.000000000000000001" : ] 000000810157460.560207000000000000 ; 000000832136309.387202000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004D433C24F5BD3F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFIII_II_metadata_line_31_____talanx service ag_20231101 >									
	//        < Pnmdhc5IRE2hm9ci1F5JZRpNkdj2mk8cCiij70b7s2587Ix3aonB00p6zLORIyWt >									
	//        <  u =="0.000000000000000001" : ] 000000832136309.387202000000000000 ; 000000877370830.570398000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004F5BD3F53AC2FB >									
	//     < NDRV_PFIII_II_metadata_line_32_____talanx service ag hdi risk consulting gmbh_20231101 >									
	//        < mYFt1iVXZON18JPvB2mc5bM5W4ae2m1Oe7xS454oxyXWz4jADvOnBZ971KtQu43x >									
	//        <  u =="0.000000000000000001" : ] 000000877370830.570398000000000000 ; 000000901699876.385988000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000053AC2FB55FE284 >									
	//     < NDRV_PFIII_II_metadata_line_33_____talanx deutschland bancassurance kundenservice gmbh_20231101 >									
	//        < 002x7PLfg4z428g1D4y5I0WRI499F6E6Bm8beqt4m3ytXC9IOT83RzBC4C7oY0Hk >									
	//        <  u =="0.000000000000000001" : ] 000000901699876.385988000000000000 ; 000000936996777.255690000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000055FE284595BE5E >									
	//     < NDRV_PFIII_II_metadata_line_34_____magyar posta eletbiztosito zrt_20231101 >									
	//        < a16FZaSW9HF598W4kNg3guNZZpGU4yhGm0lHtCp8G8MeWAUP4KOCvdzhyC6BECJK >									
	//        <  u =="0.000000000000000001" : ] 000000936996777.255690000000000000 ; 000000960101283.260537000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000595BE5E5B8FF90 >									
	//     < NDRV_PFIII_II_metadata_line_35_____magyar posta biztosito zrt_20231101 >									
	//        < w3lV4vUGm9iZ143F4zOfZ7AdceJb29Y6ZBjKawEzd901o9ZdK3aFN792KF0707b0 >									
	//        <  u =="0.000000000000000001" : ] 000000960101283.260537000000000000 ; 000000977701918.666623000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005B8FF905D3DAD0 >									
	//     < NDRV_PFIII_II_metadata_line_36_____civ hayat sigorta as_20231101 >									
	//        < wcaQ86U86Jx8OB6pZho7FhJj3g8K6k3PuX48u732Hd14C1ZkMCRw2pd0WhG5z5Yb >									
	//        <  u =="0.000000000000000001" : ] 000000977701918.666623000000000000 ; 000000999609920.331246000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005D3DAD05F548A0 >									
	//     < NDRV_PFIII_II_metadata_line_37_____lifestyle protection lebensversicherung ag_20231101 >									
	//        < GzpHW59X4lC4jX8tWMO8Jiub50kDoV35o4a8772W9bSpPou1lEkP46Ekph21TQiM >									
	//        <  u =="0.000000000000000001" : ] 000000999609920.331246000000000000 ; 000001022838306.635000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005F548A0618BA37 >									
	//     < NDRV_PFIII_II_metadata_line_38_____pbv lebensversicherung ag_20231101 >									
	//        < 0L2gZ9ljI9LNXjP3f8nJ39YgIRc9b726405E6dP7PPJeE7s01iCuu7Mw7I90HOhF >									
	//        <  u =="0.000000000000000001" : ] 000001022838306.635000000000000000 ; 000001041234190.849300000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000618BA37634CC1B >									
	//     < NDRV_PFIII_II_metadata_line_39_____generali colombia seguros generales sa_20231101 >									
	//        < WGa2Pajy2x5R0RsXogZ28h7F8l6cf5fFNnS36s5l440j014JYT4uHd3Yn2b24lwz >									
	//        <  u =="0.000000000000000001" : ] 000001041234190.849300000000000000 ; 000001072506760.618760000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000634CC1B66483F4 >									
	//     < NDRV_PFIII_II_metadata_line_40_____generali colombia vida sa_20231101 >									
	//        < t5OG96w5AV0yl0U4YGw36sfosrmduzm823JG337KKRTf65bKuEEHjZaLlS86g7ZG >									
	//        <  u =="0.000000000000000001" : ] 000001072506760.618760000000000000 ; 000001105550122.503160000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000066483F4696EF84 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}