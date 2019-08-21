pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFI_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFI_III_883		"	;
		string	public		symbol =	"	NDRV_PFI_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1731062230839880000000000000					;	
										
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
	//     < NDRV_PFI_III_metadata_line_1_____genworth_20271101 >									
	//        < NQ5248H7MJ22n1D9VMt2kQ5IjaFn4tUyw86c5fbmNTyBtgmL4s3VwU0XFmA7u21Q >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000042375176.494543800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000040A8CE >									
	//     < NDRV_PFI_III_metadata_line_2_____genworth_org_20271101 >									
	//        < 1iSiewUF3gu1fXa27Sq6p7u628O1V3kohCVEx0yKZNuYrY7725O4FaeBo3183025 >									
	//        <  u =="0.000000000000000001" : ] 000000042375176.494543800000000000 ; 000000078456104.920292600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000040A8CE77B6EA >									
	//     < NDRV_PFI_III_metadata_line_3_____genworth_pensions_20271101 >									
	//        < 7favpt57XBtqB35Rv4M8o9nHal8a490xgW08jN4ZF46D6IXr155AqV1oM1338W3c >									
	//        <  u =="0.000000000000000001" : ] 000000078456104.920292600000000000 ; 000000125288473.760387000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000077B6EABF2CCF >									
	//     < NDRV_PFI_III_metadata_line_4_____genworth gna corporation_20271101 >									
	//        < iI3qCW4JpyCW63rpcT6n7lnd7e3uoqd82vrLjzRTzk6Dkxm5yHrqGj7j55KG6UUU >									
	//        <  u =="0.000000000000000001" : ] 000000125288473.760387000000000000 ; 000000167256444.072603000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BF2CCFFF368C >									
	//     < NDRV_PFI_III_metadata_line_5_____gna corporation_org_20271101 >									
	//        < n2NXI2919M2XZbo1Wl57hIj1d57EWKYkWEF9Z1G02r4P0481h3Gz697v7zdFewDM >									
	//        <  u =="0.000000000000000001" : ] 000000167256444.072603000000000000 ; 000000195202653.946511000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FF368C129DB09 >									
	//     < NDRV_PFI_III_metadata_line_6_____gna corporation_holdings_20271101 >									
	//        < PF3jIkYud2aPwua0eRJyP2w1Xl2ju988E8ryz71Olr03Pz6MKU48xju2530d85F1 >									
	//        <  u =="0.000000000000000001" : ] 000000195202653.946511000000000000 ; 000000218347368.746798000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000129DB0914D2BF1 >									
	//     < NDRV_PFI_III_metadata_line_7_____genworth assetmark_20271101 >									
	//        < iNcE9Ag0L36lif46MfG19n961ri9PX99o021TC8ze7JKQ4pGrzVD36G1mNdJk1gk >									
	//        <  u =="0.000000000000000001" : ] 000000218347368.746798000000000000 ; 000000248045837.357632000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014D2BF117A7CE8 >									
	//     < NDRV_PFI_III_metadata_line_8_____genworth assetmark_org_20271101 >									
	//        < TKe4uVi8o12tPW8Z0qodZ6xw1B4zF4Yz0283liSZ02VSQ22955O0dl4QuVBJQMz1 >									
	//        <  u =="0.000000000000000001" : ] 000000248045837.357632000000000000 ; 000000305683187.842335000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017A7CE81D26F7F >									
	//     < NDRV_PFI_III_metadata_line_9_____assetmark_holdings_20271101 >									
	//        < 3if3UkrxeglJ41S4lZ4Wy676EcIZQ6vbkL4P6VsTnpp6G0m21NMmyHhKL9XTQuiN >									
	//        <  u =="0.000000000000000001" : ] 000000305683187.842335000000000000 ; 000000341503104.359734000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D26F7F20917A6 >									
	//     < NDRV_PFI_III_metadata_line_10_____genworth life & annuity insurance co_20271101 >									
	//        < yJLtkLsCW420PXkU7Y37tDG6g6kH2MP61J44WrKxpKDZeIkykqB94o13l4A63ksJ >									
	//        <  u =="0.000000000000000001" : ] 000000341503104.359734000000000000 ; 000000379925210.828794000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020917A6243B849 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFI_III_metadata_line_11_____genworth financial services inc_20271101 >									
	//        < UFWPRLE99a3667uENW8D34td4IDL6YYctJR9OVTe730eWVf35me4cMvSEewG8RUh >									
	//        <  u =="0.000000000000000001" : ] 000000379925210.828794000000000000 ; 000000428674346.568688000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000243B84928E1AEB >									
	//     < NDRV_PFI_III_metadata_line_12_____genworth financial agency inc_20271101 >									
	//        < XlFiLLh4X3KuNrSIVjCN1Kszb21OyKSrMTEcG69d1GFu6X55zM8493M4Hta26cm2 >									
	//        <  u =="0.000000000000000001" : ] 000000428674346.568688000000000000 ; 000000466722390.882509000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028E1AEB2C8296F >									
	//     < NDRV_PFI_III_metadata_line_13_____genworth financial services pty limited_20271101 >									
	//        < m81WQi3G6O79702zREGBe01yf4n5kGnYOT6xH87U32NXH9597bOrO250aERvWW72 >									
	//        <  u =="0.000000000000000001" : ] 000000466722390.882509000000000000 ; 000000550484533.434260000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C8296F347F905 >									
	//     < NDRV_PFI_III_metadata_line_14_____genworth american continental insurance company_20271101 >									
	//        < OnWta9hrGe2MoF85dE046PIY382hR55RZc6V8MR2SFFVy63N94MRk8lct2k3Hh2I >									
	//        <  u =="0.000000000000000001" : ] 000000550484533.434260000000000000 ; 000000613674164.024207000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000347F9053A86478 >									
	//     < NDRV_PFI_III_metadata_line_15_____continental insurance company_org_20271101 >									
	//        < 3Vf7YQTEp8Y5yrQf81tFN1310Wpl8yKs89o1kbVB6OxX8GA2I5bL41aVqmg8z2kX >									
	//        <  u =="0.000000000000000001" : ] 000000613674164.024207000000000000 ; 000000651035171.236897000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A864783E1669D >									
	//     < NDRV_PFI_III_metadata_line_16_____genworth north america corp_20271101 >									
	//        < QPPAB9QA7T4R8eC4uWMTkW9O3mbKr2o6JVmw8zulNFRRUYKn122u03bLXQY53v80 >									
	//        <  u =="0.000000000000000001" : ] 000000651035171.236897000000000000 ; 000000672010689.701946000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E1669D401682D >									
	//     < NDRV_PFI_III_metadata_line_17_____genworth holdings inc_20271101 >									
	//        < J78m0B1q3fHhv2ZYuYswdNEGUyKP35O1eBj1tkwr1d0f17hfMjVP4kORLUqW31BM >									
	//        <  u =="0.000000000000000001" : ] 000000672010689.701946000000000000 ; 000000730188037.149889000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000401682D45A2DB4 >									
	//     < NDRV_PFI_III_metadata_line_18_____genworth holdings inc_org_20271101 >									
	//        < ty4D114k8gJWFc9RU3k9oAXgic957s22iQE6RnZK4zwolx5fF0TG8bRN2Z6NYfhG >									
	//        <  u =="0.000000000000000001" : ] 000000730188037.149889000000000000 ; 000000815816290.509235000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000045A2DB44DCD63D >									
	//     < NDRV_PFI_III_metadata_line_19_____genworth mortgage insurance corp_20271101 >									
	//        < eNKIWMO8L262YL4H531DVk3MPUu7IFX4p8gk7JQ6j8C3kpifyjFSw51zqjS2fb50 >									
	//        <  u =="0.000000000000000001" : ] 000000815816290.509235000000000000 ; 000000849365903.595075000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004DCD63D510078E >									
	//     < NDRV_PFI_III_metadata_line_20_____genworth mortgage insurance corp_org_20271101 >									
	//        < aa5I5jM5OGb2N9Umqa4LoaU87lUnJV847Ww96ZsYMhZ5H05v8A84teb75o762cxY >									
	//        <  u =="0.000000000000000001" : ] 000000849365903.595075000000000000 ; 000000874834144.537551000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000510078E536E416 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFI_III_metadata_line_21_____genworth financial mortgage insurance pty limited_20271101 >									
	//        < 5vpLfXVMoMlhEx3GK8x8rTSJm28DzNbvD3WeT4Q7Me8YO1HZcjZ9zN07963Obao8 >									
	//        <  u =="0.000000000000000001" : ] 000000874834144.537551000000000000 ; 000000917800849.724599000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000536E41657873F5 >									
	//     < NDRV_PFI_III_metadata_line_22_____genworth financial international holdings inc_20271101 >									
	//        < 90l4v27z21rm10328F1Jb5cQ9z03hwLx0444qVe530T11GRr1yeR283y4d7N39H9 >									
	//        <  u =="0.000000000000000001" : ] 000000917800849.724599000000000000 ; 000000951273060.479065000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000057873F55AB870A >									
	//     < NDRV_PFI_III_metadata_line_23_____genworth financial wealth management inc_20271101 >									
	//        < nNh8xniR50xv2Jmd8SdBI52jUK29Ch645mZqgsKvNERiYU4572AAL8wBx65Oy8Z7 >									
	//        <  u =="0.000000000000000001" : ] 000000951273060.479065000000000000 ; 000001028229815.914390000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005AB870A620F446 >									
	//     < NDRV_PFI_III_metadata_line_24_____genworth ltc incorporated_org_20271101 >									
	//        < FMU3Yk83OVGwpB9f2F4j4dhkmi4C0cEL5w2O99BrqTF3Hpd00px4m1bxO1tJ4zCn >									
	//        <  u =="0.000000000000000001" : ] 000001028229815.914390000000000000 ; 000001055141612.541690000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000620F44664A04B1 >									
	//     < NDRV_PFI_III_metadata_line_25_____genworth jamestown life insurance co_20271101 >									
	//        < 5f3fdl798I5K88ELUYU9MtOCbap4zS06Y8l7ilW9Cijh828Zv8KI2h7R9403rtrI >									
	//        <  u =="0.000000000000000001" : ] 000001055141612.541690000000000000 ; 000001081687274.793770000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000064A04B16728617 >									
	//     < NDRV_PFI_III_metadata_line_26_____genworth financial assurance co ltd_20271101 >									
	//        < b9vqr29mCAZGgv43u5003J0fk8xxb9wC4coubkdxs1VTRn0xuHNJIhBBSeqqVGrG >									
	//        <  u =="0.000000000000000001" : ] 000001081687274.793770000000000000 ; 000001109025033.517800000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000672861769C3CE7 >									
	//     < NDRV_PFI_III_metadata_line_27_____genworth financial mortgage insurance company canada_20271101 >									
	//        < 8qT6ZZg1100JP6yjdqM10TyWk98wS9OJvKh3Jj8dAQ5W98D9g6q43UzBLViYsvKh >									
	//        <  u =="0.000000000000000001" : ] 000001109025033.517800000000000000 ; 000001138200111.274020000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000069C3CE76C8C16B >									
	//     < NDRV_PFI_III_metadata_line_28_____genworth financial insurance group services ltd_20271101 >									
	//        < qHKv6bj5TlRC5biAzzR2iatwCc29t4K6U02OxK1fLjZ3se5M98bedCr4t9fyb5mm >									
	//        <  u =="0.000000000000000001" : ] 000001138200111.274020000000000000 ; 000001161240963.495670000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006C8C16B6EBE9C0 >									
	//     < NDRV_PFI_III_metadata_line_29_____genworth financial trust co_20271101 >									
	//        < xQ200DFJrpxE74K4on4R55e0NOF2IDex32e6xzF9OmVuu95stRjtwC57Gg1895hs >									
	//        <  u =="0.000000000000000001" : ] 000001161240963.495670000000000000 ; 000001237011747.905350000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006EBE9C075F87B7 >									
	//     < NDRV_PFI_III_metadata_line_30_____financial trust co_holdings_20271101 >									
	//        < ss43OKLL35CnN5TohJY6yDWM4l03BPXKEM0q487c66RJM08MM32pYyx31KN94TT7 >									
	//        <  u =="0.000000000000000001" : ] 000001237011747.905350000000000000 ; 000001263405375.960170000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000075F87B7787CDBA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFI_III_metadata_line_31_____financial trust co_pensions_20271101 >									
	//        < ygH1BUFtGr8wW51M3M5PRxfm72U43ywr7488H07TBCcN2btaf0GsQb5IHnFloHD1 >									
	//        <  u =="0.000000000000000001" : ] 000001263405375.960170000000000000 ; 000001331468906.149800000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000787CDBA7EFA90B >									
	//     < NDRV_PFI_III_metadata_line_32_____genworth financial trust co_org_20271101 >									
	//        < 8Jap6CUFf4o8luojY3UeDjvy4smIo1js5qHE9di0w75tsE178X3o8a42fIdWtsJ0 >									
	//        <  u =="0.000000000000000001" : ] 000001331468906.149800000000000000 ; 000001399644705.045090000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007EFA90B857B037 >									
	//     < NDRV_PFI_III_metadata_line_33_____genworth financial european group holdings limited_20271101 >									
	//        < 9x4MQR17x1U6t500J724D0e23S1JrOJ2hP2K3yES7832110zhcKawHDvrw2V0V4o >									
	//        <  u =="0.000000000000000001" : ] 000001399644705.045090000000000000 ; 000001468738699.696020000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000857B0378C11E0E >									
	//     < NDRV_PFI_III_metadata_line_34_____genworth financial mortgage insurance limited_20271101 >									
	//        < rZa01ag525qpGO3a33FEEnTohozBS23k8usB76i7SMKugkPO479102szt4hzC884 >									
	//        <  u =="0.000000000000000001" : ] 000001468738699.696020000000000000 ; 000001537956340.712570000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008C11E0E92ABC32 >									
	//     < NDRV_PFI_III_metadata_line_35_____genworth servicios s de rl de cv_20271101 >									
	//        < 2vtHq40HwSetj1Vi2y5dZ5W5zxQ65cZnyE6veWq74wpAFsYX78uOBd8x1LCnAOp4 >									
	//        <  u =="0.000000000000000001" : ] 000001537956340.712570000000000000 ; 000001558787289.665890000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000092ABC3294A8549 >									
	//     < NDRV_PFI_III_metadata_line_36_____genworth liberty reverse mortgage incorporated_20271101 >									
	//        < C5q4Wa6OIm3jIluFF3qOH9Lab1wZ2PNxa31EpUnSZk19EE86P1t8vP68J3PZt0b8 >									
	//        <  u =="0.000000000000000001" : ] 000001558787289.665890000000000000 ; 000001608976096.672380000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000094A85499971A4A >									
	//     < NDRV_PFI_III_metadata_line_37_____genworth quantuvis consulting inc_20271101 >									
	//        < Q01657Gn8K4LMn03jsIL302rX6AkfYva7TZiMsS1Yc3uRZ0p434arx6A2klO2X4A >									
	//        <  u =="0.000000000000000001" : ] 000001608976096.672380000000000000 ; 000001631639369.889210000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009971A4A9B9AF21 >									
	//     < NDRV_PFI_III_metadata_line_38_____genworth seguros de credito a la vivienda sa de cv_20271101 >									
	//        < Kv2KZLI29XO6DZIubNBrQU5nIkuN91a9h08jAW8E8JSBG1461sEkkq2yA3K7k1zF >									
	//        <  u =="0.000000000000000001" : ] 000001631639369.889210000000000000 ; 000001672898347.842600000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009B9AF219F8A3EB >									
	//     < NDRV_PFI_III_metadata_line_39_____genworth mortgage insurance limited_20271101 >									
	//        < 75I7AzQlR1OuM52O96V8rY98i1udBc8SA7JH2vF1PsgHqkaEAA8Y2Dsmj59Fu6wv >									
	//        <  u =="0.000000000000000001" : ] 000001672898347.842600000000000000 ; 000001712280225.581270000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009F8A3EBA34BB77 >									
	//     < NDRV_PFI_III_metadata_line_40_____genworth financial investment services inc_20271101 >									
	//        < iQafBrlYJXqqnIA0uh9ft0tDv4waYxS6C6Lq6JXC6G766nOE5ZIDFHrzCijxNY99 >									
	//        <  u =="0.000000000000000001" : ] 000001712280225.581270000000000000 ; 000001731062230.839880000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A34BB77A51642F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}