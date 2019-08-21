pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXVII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXVII_II_883		"	;
		string	public		symbol =	"	RUSS_PFXVII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		830668887505646000000000000					;	
										
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
	//     < RUSS_PFXVII_II_metadata_line_1_____URALKALI_1_ORG_20231101 >									
	//        < EDP31n9cFK1yivYP5zjgSC2cN9O6Ks66I3q2oCZC8Cg8j0c1vk7kq2lVBP7g31b8 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000022166372.847208800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000021D2BD >									
	//     < RUSS_PFXVII_II_metadata_line_2_____URALKALI_1_DAO_20231101 >									
	//        < Yy8xSrLH1c84lES0410qRjxhk40zkeg4QQZN225tQqKQSK6Gj9NVp7J1KaZEb74K >									
	//        <  u =="0.000000000000000001" : ] 000000022166372.847208800000000000 ; 000000040938047.056031000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000021D2BD3E776D >									
	//     < RUSS_PFXVII_II_metadata_line_3_____URALKALI_1_DAOPI_20231101 >									
	//        < 36wt4Xl9pY3zI9hM8g254ZvWmY4Mi1pzV9Cff0BqINuorq2yyTmN5o2xZcNEixKp >									
	//        <  u =="0.000000000000000001" : ] 000000040938047.056031000000000000 ; 000000057023163.232498700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003E776D5702AC >									
	//     < RUSS_PFXVII_II_metadata_line_4_____URALKALI_1_DAC_20231101 >									
	//        < s9T5Rcd0bZqga9Qwow6x3n357C3f4N1gPih579ThtI95D2ZxhvTK67q9VD995ZcN >									
	//        <  u =="0.000000000000000001" : ] 000000057023163.232498700000000000 ; 000000077893245.605501500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005702AC76DB0D >									
	//     < RUSS_PFXVII_II_metadata_line_5_____URALKALI_1_BIMI_20231101 >									
	//        < vnB6M589IvvQ1EAnZnptgp0mkOTBUy7tL6BWUM208R38Xu49leqV6IW7DUBxHO1M >									
	//        <  u =="0.000000000000000001" : ] 000000077893245.605501500000000000 ; 000000100449495.138056000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000076DB0D994616 >									
	//     < RUSS_PFXVII_II_metadata_line_6_____URALKALI_2_ORG_20231101 >									
	//        < LxZlDX8f7MQB2Yz0v8WKEi05uRV3uUN6667yQkJz43rA0x9rUee6vVyusZ7uOTAK >									
	//        <  u =="0.000000000000000001" : ] 000000100449495.138056000000000000 ; 000000120420865.643806000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000994616B7BF67 >									
	//     < RUSS_PFXVII_II_metadata_line_7_____URALKALI_2_DAO_20231101 >									
	//        < WXZvH71r4eEMq18b0pUe4g52XTpG4cBeoeJcALe08idSCRCSzu7Bo0zl7107oky4 >									
	//        <  u =="0.000000000000000001" : ] 000000120420865.643806000000000000 ; 000000143530440.174996000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B7BF67DB0294 >									
	//     < RUSS_PFXVII_II_metadata_line_8_____URALKALI_2_DAOPI_20231101 >									
	//        < O2004190IOF2NmXK0vDA5uXw117fAU33lD66aN4vIN0gK83n7S2RG2YwZP53qeoI >									
	//        <  u =="0.000000000000000001" : ] 000000143530440.174996000000000000 ; 000000159400927.652617000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DB0294F339FD >									
	//     < RUSS_PFXVII_II_metadata_line_9_____URALKALI_2_DAC_20231101 >									
	//        < FKbErWLGdeaC43g2eH5557x680Dc7124l2fR58HV13OJKAIC6sW065g1PO5qNME8 >									
	//        <  u =="0.000000000000000001" : ] 000000159400927.652617000000000000 ; 000000178998414.033886000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F339FD1112141 >									
	//     < RUSS_PFXVII_II_metadata_line_10_____URALKALI_2_BIMI_20231101 >									
	//        < dYq728L9L01TZIt31z04BB773W5Zhy31WV20736cvAkhReuQ87w3w2VPQ8C69hli >									
	//        <  u =="0.000000000000000001" : ] 000000178998414.033886000000000000 ; 000000203127460.240141000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001112141135F2AA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVII_II_metadata_line_11_____KAMA_1_ORG_20231101 >									
	//        < 3UpQC8ij9lQ6PI8sqwCvD07H1P76s81GLKNTa0FMlZ3824Kdw7qz3Yf6C6i9PtBu >									
	//        <  u =="0.000000000000000001" : ] 000000203127460.240141000000000000 ; 000000220192549.031385000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000135F2AA14FFCB7 >									
	//     < RUSS_PFXVII_II_metadata_line_12_____KAMA_1_DAO_20231101 >									
	//        < mpqfT6prM11aN0DMNfvmiY61J5W7czs71Oy1FPh2k4fmkP2z03R49K7Q6wJiO1BH >									
	//        <  u =="0.000000000000000001" : ] 000000220192549.031385000000000000 ; 000000237620697.903377000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014FFCB716A9496 >									
	//     < RUSS_PFXVII_II_metadata_line_13_____KAMA_1_DAOPI_20231101 >									
	//        < 380g37h2obGKLoY7EGLNAi7TPxN34fQs3rbES5H5hN8UKl5hdp9nVd0gJe8DQb43 >									
	//        <  u =="0.000000000000000001" : ] 000000237620697.903377000000000000 ; 000000259764055.137544000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016A949618C5E56 >									
	//     < RUSS_PFXVII_II_metadata_line_14_____KAMA_1_DAC_20231101 >									
	//        < teDEjk8xnc0toa870kN2f3fSAOZ8NLg43iOiWr7gD7a4NRF2UFCItE8047K34g7m >									
	//        <  u =="0.000000000000000001" : ] 000000259764055.137544000000000000 ; 000000278066547.806686000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018C5E561A84BBF >									
	//     < RUSS_PFXVII_II_metadata_line_15_____KAMA_1_BIMI_20231101 >									
	//        < l8mYlR7nZGBL4J0kvD82BzU70E2F8p9w8NrvJE62YVm67M7c3bj0Z7BGXZjv1IA6 >									
	//        <  u =="0.000000000000000001" : ] 000000278066547.806686000000000000 ; 000000293764614.681944000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A84BBF1C03FCD >									
	//     < RUSS_PFXVII_II_metadata_line_16_____KAMA_2_ORG_20231101 >									
	//        < 53pzXz5m852e5ejxnyjM1vEcG4gkN8yQ69Do1WuKS9kKxzMXw4Y3Pt28y9KGwD8Q >									
	//        <  u =="0.000000000000000001" : ] 000000293764614.681944000000000000 ; 000000314407513.626898000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C03FCD1DFBF6F >									
	//     < RUSS_PFXVII_II_metadata_line_17_____KAMA_2_DAO_20231101 >									
	//        < pBiPV2KF8xDqAEPRSwhs014JV35R3GeRR1eCQbC6dttIatMuQ6N2IevCiBGTpgu6 >									
	//        <  u =="0.000000000000000001" : ] 000000314407513.626898000000000000 ; 000000336804610.865167000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DFBF6F201EC4D >									
	//     < RUSS_PFXVII_II_metadata_line_18_____KAMA_2_DAOPI_20231101 >									
	//        < 0t9lR2519220u24B7Rqwad8eX1dqN4vIvN8LF8n3m2o4l7HAXv73Z2kKHD2z3QM9 >									
	//        <  u =="0.000000000000000001" : ] 000000336804610.865167000000000000 ; 000000354802042.180710000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000201EC4D21D628C >									
	//     < RUSS_PFXVII_II_metadata_line_19_____KAMA_2_DAC_20231101 >									
	//        < eQ7OJq0Jel7295Hg7IUZ3NMc6r1Y83Zc3I9RDu7IlB3eQxcfloH5QS4UON01l6T3 >									
	//        <  u =="0.000000000000000001" : ] 000000354802042.180710000000000000 ; 000000376780723.901477000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021D628C23EEBF8 >									
	//     < RUSS_PFXVII_II_metadata_line_20_____KAMA_2_BIMI_20231101 >									
	//        < pVw123DTJz4f2OUL8pI48y7r2cQLn5Ujakr5b7hG5mU8slFH3R2Cd2smdOYoDA56 >									
	//        <  u =="0.000000000000000001" : ] 000000376780723.901477000000000000 ; 000000401010652.756006000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023EEBF8263E4C9 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVII_II_metadata_line_21_____KAMA_20231101 >									
	//        < A7D632h04O64nB9jmx3ep5gxyOq5p277Uod812S09i4bA31uBhvFB9O8C7g4S730 >									
	//        <  u =="0.000000000000000001" : ] 000000401010652.756006000000000000 ; 000000418173711.732053000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000263E4C927E151B >									
	//     < RUSS_PFXVII_II_metadata_line_22_____URALKALI_TRADING_SIA_20231101 >									
	//        < sbY781010FNTYRWE97cKgCg4f4L76J6G1rFSb8jGBuP21Bf00X34SOlv6K0cwkV3 >									
	//        <  u =="0.000000000000000001" : ] 000000418173711.732053000000000000 ; 000000436312911.400924000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027E151B299C2BB >									
	//     < RUSS_PFXVII_II_metadata_line_23_____BALTIC_BULKER_TERMINAL_20231101 >									
	//        < 10Vjz83Dh7O53t4S1KM9XiB4aR8ay13b8W4MnwR3pNy2n73WepOgfiJ39Bil48CH >									
	//        <  u =="0.000000000000000001" : ] 000000436312911.400924000000000000 ; 000000458841870.859729000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000299C2BB2BC231B >									
	//     < RUSS_PFXVII_II_metadata_line_24_____URALKALI_FINANCE_LIMITED_20231101 >									
	//        < V8Ir45v1ZHNg2m2cPuYisj8BB1bZ8PxA6vxQcV76kIeL5fo8dH4vkxztn02ADAnL >									
	//        <  u =="0.000000000000000001" : ] 000000458841870.859729000000000000 ; 000000482602661.835470000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BC231B2E064AA >									
	//     < RUSS_PFXVII_II_metadata_line_25_____SOLIKAMSK_CONSTRUCTION_TRUST_20231101 >									
	//        < gk7K1571o1T5zrdXDUfHuX151ed6r230On8H9QXJz8B6wdYlX59v9LslIu5m5REJ >									
	//        <  u =="0.000000000000000001" : ] 000000482602661.835470000000000000 ; 000000504860504.317718000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E064AA3025B22 >									
	//     < RUSS_PFXVII_II_metadata_line_26_____SILVINIT_CAPITAL_20231101 >									
	//        < 84GIIS6j0qJRQB5Kk7w9Sq98245Lg0G4J52t1wctUOsGVpJ62hR0rg6gHitO5HTc >									
	//        <  u =="0.000000000000000001" : ] 000000504860504.317718000000000000 ; 000000529619941.705992000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003025B2232822CA >									
	//     < RUSS_PFXVII_II_metadata_line_27_____AUTOMATION_MEASUREMENTS_CENTER_20231101 >									
	//        < 7smoSds3ly58c8Y9Zfhh0umf6Ek6Pb2Er4A7EanCN3Zf629H67M975y3SdEHKgN1 >									
	//        <  u =="0.000000000000000001" : ] 000000529619941.705992000000000000 ; 000000550437210.817112000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032822CA347E689 >									
	//     < RUSS_PFXVII_II_metadata_line_28_____LOVOZERSKAYA_ORE_DRESSING_CO_20231101 >									
	//        < 89F8nTz4x7ap9g5Pw341687nUsVn1p3Bt4c4cGO3g0jN6i6rOj1HBc3e98jmblnS >									
	//        <  u =="0.000000000000000001" : ] 000000550437210.817112000000000000 ; 000000573435707.906431000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000347E68936AFE53 >									
	//     < RUSS_PFXVII_II_metadata_line_29_____URALKALI_ENGINEERING_20231101 >									
	//        < D1fr5bH7a7phEgAmV6y86Mz3ogKR257DMtx5g7R1z58jy4MOEa3dQus14KGiwo80 >									
	//        <  u =="0.000000000000000001" : ] 000000573435707.906431000000000000 ; 000000597659866.211144000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036AFE5338FF4E3 >									
	//     < RUSS_PFXVII_II_metadata_line_30_____URALKALI_DEPO_20231101 >									
	//        < 5nU6U0fc3i8QnEEPL9DM9kTtdlk2kK2854ePKgV35i17xIpu9G9HaWOI844An8y1 >									
	//        <  u =="0.000000000000000001" : ] 000000597659866.211144000000000000 ; 000000614592443.795679000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038FF4E33A9CB2C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVII_II_metadata_line_31_____VAGONNOE_DEPO_BALAKHONZI_20231101 >									
	//        < E56Wr5x67BCqsHtaWUC0h1Uc1HZ1pTw4AtR2yMdl8SkRK6ggGyagKZkSK0YWKyDw >									
	//        <  u =="0.000000000000000001" : ] 000000614592443.795679000000000000 ; 000000639353457.082344000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A9CB2C3CF9372 >									
	//     < RUSS_PFXVII_II_metadata_line_32_____SILVINIT_TRANSPORT_20231101 >									
	//        < ik1TaAwODyH1v6C61yrls3JQUV08uk4U2O9IyihYVFXT8rT23Fl4sb1oCqJJ25GA >									
	//        <  u =="0.000000000000000001" : ] 000000639353457.082344000000000000 ; 000000660562584.920339000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003CF93723EFF042 >									
	//     < RUSS_PFXVII_II_metadata_line_33_____AUTOTRANSKALI_20231101 >									
	//        < RM0t6jc14U2632TZ2c49DW7P6bg7c0jT1VjeE3s6u5Gvx8ylQDPe478mRsYYPES4 >									
	//        <  u =="0.000000000000000001" : ] 000000660562584.920339000000000000 ; 000000677401526.089099000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003EFF042409A1F9 >									
	//     < RUSS_PFXVII_II_metadata_line_34_____URALKALI_REMONT_20231101 >									
	//        < dO8dzxqzL0Nmr8O05Vu13D60vRO909AjV1Z9P1cZ01Ms7VE5JeL202zalP3HEMvw >									
	//        <  u =="0.000000000000000001" : ] 000000677401526.089099000000000000 ; 000000699074639.371869000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000409A1F942AB408 >									
	//     < RUSS_PFXVII_II_metadata_line_35_____EN_RESURS_OOO_20231101 >									
	//        < 3vCVztUu8T5qB81Y28GCp93J0BUw5ra4a4euvU7rd8gZl322Dm2E59gDbdFwyxEX >									
	//        <  u =="0.000000000000000001" : ] 000000699074639.371869000000000000 ; 000000720357252.766382000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042AB40844B2D8D >									
	//     < RUSS_PFXVII_II_metadata_line_36_____BSHSU_20231101 >									
	//        < iBLM473hes6csIZa8oOUwM4GH47UceIJ50EORd811V459DS7pn2hsykl90xgvrBV >									
	//        <  u =="0.000000000000000001" : ] 000000720357252.766382000000000000 ; 000000744531356.188900000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044B2D8D4701090 >									
	//     < RUSS_PFXVII_II_metadata_line_37_____URALKALI_TECHNOLOGY_20231101 >									
	//        < 314me1RXF8jI1th6lF82cB46pP9y6ldY06K4526R5qq45qTBAFi0705R083rF4Uy >									
	//        <  u =="0.000000000000000001" : ] 000000744531356.188900000000000000 ; 000000767354547.575712000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004701090492E3DF >									
	//     < RUSS_PFXVII_II_metadata_line_38_____KAMA_MINERAL_OOO_20231101 >									
	//        < K632KK3GLSK152iXn7aRchv1aCakI65sAmZ9Min948SXWHYjhk5f7010610o80oK >									
	//        <  u =="0.000000000000000001" : ] 000000767354547.575712000000000000 ; 000000788668620.361344000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000492E3DF4B369AE >									
	//     < RUSS_PFXVII_II_metadata_line_39_____SOLIKAMSKSTROY_ZAO_20231101 >									
	//        < 2M0F0jsg8v7IVzTFW9hR2kJM208i3c87K9ltV27eHg0UYu4Lqx9657Jz1wdYiWM5 >									
	//        <  u =="0.000000000000000001" : ] 000000788668620.361344000000000000 ; 000000808074717.993874000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B369AE4D10630 >									
	//     < RUSS_PFXVII_II_metadata_line_40_____NOVAYA_NEDVIZHIMOST_20231101 >									
	//        < AUu01FF2p29E533FZ4gY717huMTZlyJ93kn24qzgaL92k303zE08FK7g4s4N3dR4 >									
	//        <  u =="0.000000000000000001" : ] 000000808074717.993874000000000000 ; 000000830668887.505646000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004D106304F38009 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}