pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFII_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFII_I_883		"	;
		string	public		symbol =	"	NDRV_PFII_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		691763419150721000000000000					;	
										
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
	//     < NDRV_PFII_I_metadata_line_1_____genworth newco properties inc_20211101 >									
	//        < DWLY125o46O3U1376A2xVzk7f4lc4WS1I636ufeL93lQjJdE8R19EE0073Ut12U8 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000021169588.317181700000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000204D5F >									
	//     < NDRV_PFII_I_metadata_line_2_____genworth newco properties inc_org_20211101 >									
	//        < itQiE4Q2fWF495E3OLOgH872sLLiB9beLZ388g30a8dtk98p5j7JU3JaF0Dbbe2X >									
	//        <  u =="0.000000000000000001" : ] 000000021169588.317181700000000000 ; 000000044565950.356580000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000204D5F440093 >									
	//     < NDRV_PFII_I_metadata_line_3_____genworth pmi mortgage insurance co canada_20211101 >									
	//        < y6Uz3OJ151hDYMW6281YOiP4RDF7VYiS1iZ41H5g9Ve5ugpxDT5d44Z534gh52vU >									
	//        <  u =="0.000000000000000001" : ] 000000044565950.356580000000000000 ; 000000062714706.440704400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004400935FB1EF >									
	//     < NDRV_PFII_I_metadata_line_4_____genworth financial mortgage indemnity limited_20211101 >									
	//        < j7JlvO01j977G3B73C34l3845aosU9V9ekIwb0W8GZ26T7v8Au2SA465GbqfgF9d >									
	//        <  u =="0.000000000000000001" : ] 000000062714706.440704400000000000 ; 000000079205792.155435000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005FB1EF78DBC3 >									
	//     < NDRV_PFII_I_metadata_line_5_____genworth mayflower assignment corporation_20211101 >									
	//        < nD0QwNdOZY804por9nlvrjN93ok0ZPM86YHTis0Lh0989bgTxKALC1bd9J5e1LQ3 >									
	//        <  u =="0.000000000000000001" : ] 000000079205792.155435000000000000 ; 000000092662749.033687400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000078DBC38D6463 >									
	//     < NDRV_PFII_I_metadata_line_6_____genworth seguros mexico sa de cv_20211101 >									
	//        < 12o0jW6l51w5Lcx50g63Kp8wqPCq7VNZynmr4uz8bK45OzH2XEjDpGeW6Q1NVy25 >									
	//        <  u =="0.000000000000000001" : ] 000000092662749.033687400000000000 ; 000000113797861.983530000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008D6463ADA44A >									
	//     < NDRV_PFII_I_metadata_line_7_____genworth seguros_org_20211101 >									
	//        < fq39v7pl60M6YMDs4RVs5i49NbL7QXOx286hgR56XTI1ck8m7i58422j7HIxDuqe >									
	//        <  u =="0.000000000000000001" : ] 000000113797861.983530000000000000 ; 000000133911022.294484000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000ADA44ACC54FE >									
	//     < NDRV_PFII_I_metadata_line_8_____genworth life insurance co of new york_20211101 >									
	//        < J44vM4x7u636hzJEXE8MD1j9F2c7PUi1My1Aj14Lpeo5m8pt841U66WoRx0JAFt9 >									
	//        <  u =="0.000000000000000001" : ] 000000133911022.294484000000000000 ; 000000151433796.125809000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CC54FEE711D4 >									
	//     < NDRV_PFII_I_metadata_line_9_____genworth mortgage insurance corp of north carolina_20211101 >									
	//        < A9W40D58556Vpof99jl3LPj3mk098yJGpn9ee8bKkPGh9D99UcBk90VW1dW1nENc >									
	//        <  u =="0.000000000000000001" : ] 000000151433796.125809000000000000 ; 000000173600335.303965000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E711D4108E4A2 >									
	//     < NDRV_PFII_I_metadata_line_10_____genworth assetmark capital corp_20211101 >									
	//        < JOkpo8v9Ds612f0T6Gev1N5XG1j8tULaMjbBdrEd2TwOb6A23Ux6qeK3oBCgpv5h >									
	//        <  u =="0.000000000000000001" : ] 000000173600335.303965000000000000 ; 000000190971182.076609000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000108E4A2123661E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFII_I_metadata_line_11_____assetmark capital corp_org_20211101 >									
	//        < 42lkw8F54j3URV9OuctcSSh7RM5OXTgjOolM9179z3ALaORk1cz70pe6CM2mW2wi >									
	//        <  u =="0.000000000000000001" : ] 000000190971182.076609000000000000 ; 000000206646610.884058000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000123661E13B5155 >									
	//     < NDRV_PFII_I_metadata_line_12_____assetmark capital_holdings_20211101 >									
	//        < vQ1vFFCeXJ6A984t4pZ2duq43l9i2en7m7GR28u1D7uptDRFoyV5zy7Q4vu2oenO >									
	//        <  u =="0.000000000000000001" : ] 000000206646610.884058000000000000 ; 000000219916528.071719000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013B515514F90E5 >									
	//     < NDRV_PFII_I_metadata_line_13_____assetmark capital_pensions_20211101 >									
	//        < Q1nG284nJ85tv4OH8x6t66aVJf6L1q7Bxl0W18R11Q5p5302vhkEyWy5fr16U21N >									
	//        <  u =="0.000000000000000001" : ] 000000219916528.071719000000000000 ; 000000233270644.924879000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014F90E5163F158 >									
	//     < NDRV_PFII_I_metadata_line_14_____genworth assetmark capital corp_org_20211101 >									
	//        < R0hcdcASfr5CEL6Vwt1E82W4z76iMzFKKKB7Am9hoed8iyK31p1uoQYSLy9TS7EC >									
	//        <  u =="0.000000000000000001" : ] 000000233270644.924879000000000000 ; 000000248500843.385952000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000163F15817B2EA4 >									
	//     < NDRV_PFII_I_metadata_line_15_____genworth financial insurance company limited_20211101 >									
	//        < vWPEYvtZ9jZmx5746Bf68PX1962E4542645aKJiXsnqE3mn66ZLnas8zqjx9falw >									
	//        <  u =="0.000000000000000001" : ] 000000248500843.385952000000000000 ; 000000262639079.094533000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017B2EA4190C164 >									
	//     < NDRV_PFII_I_metadata_line_16_____genworth financial asia ltd_20211101 >									
	//        < W5OApjOK8m57A436YxRnl8u7tDeR5Ol9j9RRfz17a7BE1s1DyT7dT11R732QMbpB >									
	//        <  u =="0.000000000000000001" : ] 000000262639079.094533000000000000 ; 000000276115833.380041000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000190C1641A551BF >									
	//     < NDRV_PFII_I_metadata_line_17_____genworth financial asia ltd_org_20211101 >									
	//        < RcLT6Ea0ALnJzN15657Aj7CLMLV5eI4wCC23FXh0t6OYtr1V92SLE5KWMyxdY2Vd >									
	//        <  u =="0.000000000000000001" : ] 000000276115833.380041000000000000 ; 000000295250876.085890000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A551BF1C28460 >									
	//     < NDRV_PFII_I_metadata_line_18_____genworth consolidated insurance group ltd_20211101 >									
	//        < BGJMNeMOL6DF249f3V1VAGvEl3v6O5LoJ6reNC44e0qP8q7CwdnwV6v636WhNapM >									
	//        <  u =="0.000000000000000001" : ] 000000295250876.085890000000000000 ; 000000308302521.821867000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C284601D66EAC >									
	//     < NDRV_PFII_I_metadata_line_19_____genworth financial uk holdings ltd_20211101 >									
	//        < 5f9c55GYX8F5D0Ha6X3ajXVbsMzhj72ySrsRZNoQ1XwHtS28H0PdFTrr6f95Yq0F >									
	//        <  u =="0.000000000000000001" : ] 000000308302521.821867000000000000 ; 000000325184352.724417000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D66EAC1F03123 >									
	//     < NDRV_PFII_I_metadata_line_20_____genworth financial uk holdings ltd_org_20211101 >									
	//        < KUGO3l4mn6Yu10Im4q4zXzQ5A9dX530B4ey3hExCIe0IZUjqdyEznyw8OEsR6ra1 >									
	//        <  u =="0.000000000000000001" : ] 000000325184352.724417000000000000 ; 000000343527599.844675000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F0312320C2E78 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFII_I_metadata_line_21_____genworth mortgage services llc_20211101 >									
	//        < Vw8uNVs178mjLOV6QSom6869sFLTU2js50if8nNISX3mHiYDZ668z6kCDNn86JfE >									
	//        <  u =="0.000000000000000001" : ] 000000343527599.844675000000000000 ; 000000359121680.893275000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020C2E78223F9E8 >									
	//     < NDRV_PFII_I_metadata_line_22_____genworth brookfield life assurance co ltd_20211101 >									
	//        < 5RB9EkZTck9877e5775718V0512sEy37l6s7et2UVZt9550bdj5MM28U7eM5JTeA >									
	//        <  u =="0.000000000000000001" : ] 000000359121680.893275000000000000 ; 000000375251876.863706000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000223F9E823C96C4 >									
	//     < NDRV_PFII_I_metadata_line_23_____genworth rivermont life insurance co i_20211101 >									
	//        < eFc6RGJonZ9qq95W4A27PV55tBFv250ET9P3ZpSmo7uJOg4Uh7u435gH75rygGxh >									
	//        <  u =="0.000000000000000001" : ] 000000375251876.863706000000000000 ; 000000391557207.090082000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023C96C42557809 >									
	//     < NDRV_PFII_I_metadata_line_24_____genworth gna distributors inc_20211101 >									
	//        < 8ouWjwiyl4QX0c0u45OAGd0Kes916RSEhD23bC6flMW6rk21pSpQ8FqZR9JBFY1W >									
	//        <  u =="0.000000000000000001" : ] 000000391557207.090082000000000000 ; 000000414499603.306762000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000255780927879E8 >									
	//     < NDRV_PFII_I_metadata_line_25_____genworth center for financial learning llc_20211101 >									
	//        < w2oVaI14gXFMiX17oH2g9MaTvT1l85INrRw07C2Judn2j1EltRao4VpSn3vsC3MO >									
	//        <  u =="0.000000000000000001" : ] 000000414499603.306762000000000000 ; 000000432600748.968348000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027879E829418AB >									
	//     < NDRV_PFII_I_metadata_line_26_____genworth financial mortgage solutions ltd_20211101 >									
	//        < 9uUl69uz5kDU5jCK3WqKbq800wuYGZu5781QrtRW6AYHTAGM5mfUpP6ou0VZ392H >									
	//        <  u =="0.000000000000000001" : ] 000000432600748.968348000000000000 ; 000000448596323.468187000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029418AB2AC80F0 >									
	//     < NDRV_PFII_I_metadata_line_27_____genworth hochman & baker inc_20211101 >									
	//        < 9xlL5a71g8M5Unpnx4e3298u45oPh56w1LPzqPDOAku6j3DyD1D01feb87C1eJrs >									
	//        <  u =="0.000000000000000001" : ] 000000448596323.468187000000000000 ; 000000461578569.786189000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AC80F02C05021 >									
	//     < NDRV_PFII_I_metadata_line_28_____hochman baker_org_20211101 >									
	//        < 88iaql44Dqmgazv912sgNa5B6s8BKK5O3ODCdhLW3BlKWWK920EZruupRt8stHxK >									
	//        <  u =="0.000000000000000001" : ] 000000461578569.786189000000000000 ; 000000484714548.706540000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C050212E39D9F >									
	//     < NDRV_PFII_I_metadata_line_29_____hochman baker_holdings_20211101 >									
	//        < W1PGwPtcgyaJditBNz0Y5uXQ8o2Ht38B5689BXe11nD1a27XQ9h87426OwTX7I31 >									
	//        <  u =="0.000000000000000001" : ] 000000484714548.706540000000000000 ; 000000500720955.188005000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E39D9F2FC0A20 >									
	//     < NDRV_PFII_I_metadata_line_30_____hochman  baker_pensions_20211101 >									
	//        < 2of3ywKQeCog029K7FoJufVTX8H2d6o7xulQ2yBiiMMUA2qw8zB5zd4BMe4XfkqF >									
	//        <  u =="0.000000000000000001" : ] 000000500720955.188005000000000000 ; 000000518719023.808416000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FC0A20317809E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFII_I_metadata_line_31_____genworth hgi annuity service corporation_20211101 >									
	//        < qx45ykyBog1wV0L8CqGc09Y94Jvb3yArlJmHt1Y59BjLhZ2OA0Zytq1b54tKIgKi >									
	//        <  u =="0.000000000000000001" : ] 000000518719023.808416000000000000 ; 000000533651002.188674000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000317809E32E496C >									
	//     < NDRV_PFII_I_metadata_line_32_____genworth financial service korea co_20211101 >									
	//        < RJdPnLUyh97j1w55kQ4r8m724ULvUK9DzBB4Zof3SiNVHurH8DEy1wG8z99LML2h >									
	//        <  u =="0.000000000000000001" : ] 000000533651002.188674000000000000 ; 000000553786612.214123000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032E496C34D02E5 >									
	//     < NDRV_PFII_I_metadata_line_33_____financial service korea_org_20211101 >									
	//        < lO3pf6Z6pgez7MAYTdKhgR2Eyr4PKR4H1wBl1pStNpcdaUaCcWjNr172PsbHqFar >									
	//        <  u =="0.000000000000000001" : ] 000000553786612.214123000000000000 ; 000000569544596.603022000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034D02E53650E5C >									
	//     < NDRV_PFII_I_metadata_line_34_____genworth special purpose five llc_20211101 >									
	//        < GE288ELoI92R58geckZl47JNn1L94IJ3Ns4y2cz35EJ53eN7Duu3ciue9cON73tP >									
	//        <  u =="0.000000000000000001" : ] 000000569544596.603022000000000000 ; 000000583877670.254920000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003650E5C37AED37 >									
	//     < NDRV_PFII_I_metadata_line_35_____genworth special purpose five llc_org_20211101 >									
	//        < QffO3XFv0FOC4ZeW3WM30MrX85s56Bce0BxgoPgLy15tBD29Gh6YZSx02mM06p1I >									
	//        <  u =="0.000000000000000001" : ] 000000583877670.254920000000000000 ; 000000599689878.564933000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037AED373930DDC >									
	//     < NDRV_PFII_I_metadata_line_36_____genworth financial securities corporation_20211101 >									
	//        < 6Ync4eqYL7k9G2ILnp5L2krEvpe40mASPY7BSWttkOiW9190TJKg2803o5n0G7AX >									
	//        <  u =="0.000000000000000001" : ] 000000599689878.564933000000000000 ; 000000618503940.537477000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003930DDC3AFC31A >									
	//     < NDRV_PFII_I_metadata_line_37_____genworth financial securities corp_org_20211101 >									
	//        < A0Zbm4A4S2rp7mX86EzZ07XwSp8kbdJya5gu2mEXvXqV1y65498EO9VbpYM1K7B8 >									
	//        <  u =="0.000000000000000001" : ] 000000618503940.537477000000000000 ; 000000641096969.722598000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003AFC31A3D23C81 >									
	//     < NDRV_PFII_I_metadata_line_38_____genworth special purpose one llc_20211101 >									
	//        < uoPP4i5hCzs1Wv6dWCqhe5hXViUOnbTG4jXJ20Y6d5g625XYokU132G06s1C4eBY >									
	//        <  u =="0.000000000000000001" : ] 000000641096969.722598000000000000 ; 000000664930142.923059000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D23C813F69A56 >									
	//     < NDRV_PFII_I_metadata_line_39_____genworth special purpose one llc_org_20211101 >									
	//        < 7f4Y7pycsWJs6ia8O6pelOfoM68DXmHVNf9sA8Q84sBEfUe3QSn815rwZ6ztYKBZ >									
	//        <  u =="0.000000000000000001" : ] 000000664930142.923059000000000000 ; 000000678355633.478352000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F69A5640B16AB >									
	//     < NDRV_PFII_I_metadata_line_40_____special purpose one_pensions_20211101 >									
	//        < 824rzPYIlLV2QA21QYKHHGu0qY1IQTB648l13bn382o77n5ZT51QpOF73H5ciAMj >									
	//        <  u =="0.000000000000000001" : ] 000000678355633.478352000000000000 ; 000000691763419.150721000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040B16AB41F8C16 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}