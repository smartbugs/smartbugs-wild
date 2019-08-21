pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXVIII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXVIII_III_883		"	;
		string	public		symbol =	"	RUSS_PFXVIII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1072512790689600000000000000					;	
										
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
	//     < RUSS_PFXVIII_III_metadata_line_1_____RESO_GARANTIA_20251101 >									
	//        < RWX1TBbOxmOcbBp0071e7f7ko30fvOEUfmbjfri8T247BpmOYD254UIfeUft62TM >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000029101471.667483600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000002C67C3 >									
	//     < RUSS_PFXVIII_III_metadata_line_2_____RESO_CREDIT_BANK_20251101 >									
	//        < Jr8y2P3uB04dcA1E8u6OoH3p7b9W7fPZAqqyKN3GJ05dx4xihOhGZI4iM3ocgab1 >									
	//        <  u =="0.000000000000000001" : ] 000000029101471.667483600000000000 ; 000000050534886.317642500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002C67C34D1C31 >									
	//     < RUSS_PFXVIII_III_metadata_line_3_____RESO_LEASING_20251101 >									
	//        < PTNYTMuNHEkY88R75R4ycu8EG46u1w0d8f3z2hj46oqz1tDugu83jdL1ogVB7zfY >									
	//        <  u =="0.000000000000000001" : ] 000000050534886.317642500000000000 ; 000000085306918.528484600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004D1C31822B04 >									
	//     < RUSS_PFXVIII_III_metadata_line_4_____OSZH_RESO_GARANTIA_20251101 >									
	//        < HsVmu0WBoq49Oi4UsySCta6fU5M7oBge74q168wV0LQarDLDiZwDPEiqIJ8zauqK >									
	//        <  u =="0.000000000000000001" : ] 000000085306918.528484600000000000 ; 000000109438075.058757000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000822B04A6FD40 >									
	//     < RUSS_PFXVIII_III_metadata_line_5_____STRAKHOVOI_SINDIKAT_20251101 >									
	//        < 0G2M0N07586QN8l9N7fR14f34eXSwFhl3FoWlfu0L7vpSnuyd9G6lcuXUlV877Pg >									
	//        <  u =="0.000000000000000001" : ] 000000109438075.058757000000000000 ; 000000137063597.668241000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A6FD40D12478 >									
	//     < RUSS_PFXVIII_III_metadata_line_6_____RESO_FINANCIAL_MARKETS_20251101 >									
	//        < teUWxmsE1g13Bw8fptqqAyfpW5rV4y2yF6c0NF9X6z4o28QhR7167gD5jUZJ8147 >									
	//        <  u =="0.000000000000000001" : ] 000000137063597.668241000000000000 ; 000000162054256.784183000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D12478F74672 >									
	//     < RUSS_PFXVIII_III_metadata_line_7_____LIPETSK_INSURANCE_CO_CHANCE_20251101 >									
	//        < jgE3li508vAXuk3H286qq98jrw6XLKUjLe14Z136F8i2omBaa6aA58z31Sio8D03 >									
	//        <  u =="0.000000000000000001" : ] 000000162054256.784183000000000000 ; 000000195635420.208778000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F7467212A8416 >									
	//     < RUSS_PFXVIII_III_metadata_line_8_____ALVENA_RESO_GROUP_20251101 >									
	//        < 1tt0nR0T52mBb8KXv22MDD47wF3T78dGPLmdwp1Od7d23gFD9GEc1bgF7i7z52rH >									
	//        <  u =="0.000000000000000001" : ] 000000195635420.208778000000000000 ; 000000217467291.692842000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012A841614BD429 >									
	//     < RUSS_PFXVIII_III_metadata_line_9_____NADEZHNAYA_LIFE_INSURANCE_CO_20251101 >									
	//        < ckm5HC185HEv63FC77EfbB19FUT685Ose5J771o5NRlgiXvBl539a1y5W8vxAW2b >									
	//        <  u =="0.000000000000000001" : ] 000000217467291.692842000000000000 ; 000000237177449.492171000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014BD429169E771 >									
	//     < RUSS_PFXVIII_III_metadata_line_10_____MSK_URALSIB_20251101 >									
	//        < 9SQdB0j14sz0n0L8c94O79X8o5Kk6Zahy5A58b52j2PS0VPUmunv6Q9LCzn3AZbG >									
	//        <  u =="0.000000000000000001" : ] 000000237177449.492171000000000000 ; 000000264323783.046219000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000169E771193537A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVIII_III_metadata_line_11_____RESO_1_ORG_20251101 >									
	//        < 657BzPaIZ0iODYWtLor9Kp1hy9v2tQwcUNqZ9JCR8WU9D3P49Yq1P59PfG5842X7 >									
	//        <  u =="0.000000000000000001" : ] 000000264323783.046219000000000000 ; 000000291769424.656302000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000193537A1BD346E >									
	//     < RUSS_PFXVIII_III_metadata_line_12_____RESO_1_DAO_20251101 >									
	//        < 0F5ak9zHdzAm1u7JmhVOQXM2AFT72JrVHs4v5TzY3TM9oYb8by2w6k5FV6sjF6cs >									
	//        <  u =="0.000000000000000001" : ] 000000291769424.656302000000000000 ; 000000316326216.011143000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BD346E1E2ACEE >									
	//     < RUSS_PFXVIII_III_metadata_line_13_____RESO_1_DAOPI_20251101 >									
	//        < 212V77SaLpGOnV27T7M057X9duP2wTWewJIQ7NXrG3811UrfP3D5mBLKgaHIphC1 >									
	//        <  u =="0.000000000000000001" : ] 000000316326216.011143000000000000 ; 000000347251889.471976000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E2ACEE211DD45 >									
	//     < RUSS_PFXVIII_III_metadata_line_14_____RESO_1_DAC_20251101 >									
	//        < tut9Tg2C4XRm313Lhfo99TeP2ZiI2UFaD9K54wcQAdgz476z73HnJwzjbTBo9Lyb >									
	//        <  u =="0.000000000000000001" : ] 000000347251889.471976000000000000 ; 000000377847591.911171000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000211DD452408CB7 >									
	//     < RUSS_PFXVIII_III_metadata_line_15_____RESO_1_BIMI_20251101 >									
	//        < 6X95jAQ641NX0EsHyXNjpN7S0GEEl66OHCcX5I19y9b2ig72ulD64B3780QJ86Y1 >									
	//        <  u =="0.000000000000000001" : ] 000000377847591.911171000000000000 ; 000000413449378.757512000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002408CB7276DFAA >									
	//     < RUSS_PFXVIII_III_metadata_line_16_____RESO_2_ORG_20251101 >									
	//        < Jp85TvSL4lDbFQz7A8tBKtrzb84249Mu2iMNcDErYF886qn3Xshh87XB02F1V30u >									
	//        <  u =="0.000000000000000001" : ] 000000413449378.757512000000000000 ; 000000436435022.190959000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000276DFAA299F26E >									
	//     < RUSS_PFXVIII_III_metadata_line_17_____RESO_2_DAO_20251101 >									
	//        < 2TVWuDbLhPUiuwPeVtvPBm5tn2bv1EqS8Kk0zN2s1oxA9eQF7aEl85270R77E8Dq >									
	//        <  u =="0.000000000000000001" : ] 000000436435022.190959000000000000 ; 000000466546080.459436000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000299F26E2C7E490 >									
	//     < RUSS_PFXVIII_III_metadata_line_18_____RESO_2_DAOPI_20251101 >									
	//        < nkSiK9pzZVpe08pFSNH3wMeim9aDxSJdc4Wqn9oO3zcI7oPi0HQ2AszA9851ou08 >									
	//        <  u =="0.000000000000000001" : ] 000000466546080.459436000000000000 ; 000000490297620.119085000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C7E4902EC2282 >									
	//     < RUSS_PFXVIII_III_metadata_line_19_____RESO_2_DAC_20251101 >									
	//        < gF22K9LA0oZ9snb88Ddv36PdJ1jgr642qbbZ34Dugh2dz66BwldMG9502RmPetrU >									
	//        <  u =="0.000000000000000001" : ] 000000490297620.119085000000000000 ; 000000512754666.084677000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EC228230E66CB >									
	//     < RUSS_PFXVIII_III_metadata_line_20_____RESO_2_BIMI_20251101 >									
	//        < 6PnC8t80f74fA9zebe9Hfj7TuWcUK5G8CS9v6ioB9F22Yj52tx83KEAnT96YN6H5 >									
	//        <  u =="0.000000000000000001" : ] 000000512754666.084677000000000000 ; 000000536047998.686481000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030E66CB331F1C0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVIII_III_metadata_line_21_____RESO_PENSII_1_ORG_20251101 >									
	//        < h2S3bWkcQqro0Y70QObGLwxnS2lRs0m35R7jxgkiz60xBS9vZJUq91i014kmqUxU >									
	//        <  u =="0.000000000000000001" : ] 000000536047998.686481000000000000 ; 000000567158057.613705000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000331F1C03616A1E >									
	//     < RUSS_PFXVIII_III_metadata_line_22_____RESO_PENSII_1_DAO_20251101 >									
	//        < Tx31FnGxi1920K5UodEw9dKNLP7fLEp0a4nsnzAWvg7QL1EjdhgI6e5w3X23lmuN >									
	//        <  u =="0.000000000000000001" : ] 000000567158057.613705000000000000 ; 000000602869958.680623000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003616A1E397E814 >									
	//     < RUSS_PFXVIII_III_metadata_line_23_____RESO_PENSII_1_DAOPI_20251101 >									
	//        < j9MsV0uCPkah8l0k7US37uxW94mNah80cdhf5kSH7K1YSF0cQBiaaDLtdd4oPWJo >									
	//        <  u =="0.000000000000000001" : ] 000000602869958.680623000000000000 ; 000000630651234.226476000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000397E8143C24C23 >									
	//     < RUSS_PFXVIII_III_metadata_line_24_____RESO_PENSII_1_DAC_20251101 >									
	//        < soUwC29W0xjEJ3QzMiEoh9Ts822xS70C0a36AxK4RFDZ6qmO5dM130Ew9BoPCtN2 >									
	//        <  u =="0.000000000000000001" : ] 000000630651234.226476000000000000 ; 000000657042380.683465000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C24C233EA912E >									
	//     < RUSS_PFXVIII_III_metadata_line_25_____RESO_PENSII_1_BIMI_20251101 >									
	//        < 0sDdj4l60b946rcz5r1oq0t7AdgVDAC21sxx4seUE20D6j9q4Hs9BcP2L0Bg9Mhu >									
	//        <  u =="0.000000000000000001" : ] 000000657042380.683465000000000000 ; 000000687683014.670436000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003EA912E419522D >									
	//     < RUSS_PFXVIII_III_metadata_line_26_____RESO_PENSII_2_ORG_20251101 >									
	//        < T2RRZn8HNQnD0LTH2C50Slo4V4l9R81Au70ZYFO85T5fK3Nu6w3Si71hd04ke9N7 >									
	//        <  u =="0.000000000000000001" : ] 000000687683014.670436000000000000 ; 000000708980148.301559000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000419522D439D15F >									
	//     < RUSS_PFXVIII_III_metadata_line_27_____RESO_PENSII_2_DAO_20251101 >									
	//        < YwXb8JlfSzi4KST26846qT1k6bislyN001YBiDJxoQ47AJ15WqABzUTGiGrHnBJG >									
	//        <  u =="0.000000000000000001" : ] 000000708980148.301559000000000000 ; 000000734203722.822652000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000439D15F4604E54 >									
	//     < RUSS_PFXVIII_III_metadata_line_28_____RESO_PENSII_2_DAOPI_20251101 >									
	//        < G7372wAS9NiPx8p348i4xq46Aj26CYF64yLgCe4yDyiHASUrgp5K1PzIfZ9Be7Sp >									
	//        <  u =="0.000000000000000001" : ] 000000734203722.822652000000000000 ; 000000754648760.308604000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004604E5447F80AC >									
	//     < RUSS_PFXVIII_III_metadata_line_29_____RESO_PENSII_2_DAC_20251101 >									
	//        < GQ2U5F27GW65ZVNAb0yrlB6uTlCE2jZ8Xn4gLDKXI8376K68IAt5ztMA4suuJ9E5 >									
	//        <  u =="0.000000000000000001" : ] 000000754648760.308604000000000000 ; 000000773574763.841934000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000047F80AC49C61A4 >									
	//     < RUSS_PFXVIII_III_metadata_line_30_____RESO_PENSII_2_BIMI_20251101 >									
	//        < ms7CGIu3DCV5791ecS67gbuABFHI67d1AbT3PQrC0p1L0sD1428nAUxeMtNeGj7H >									
	//        <  u =="0.000000000000000001" : ] 000000773574763.841934000000000000 ; 000000794749262.140653000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049C61A44BCB0EE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVIII_III_metadata_line_31_____MIKA_ORG_20251101 >									
	//        < MM19Tj41HkUt6uQ7Srw4YKqoZf0rb9jCMmx66rpa72y03imjJrqo3q39s3aV95e6 >									
	//        <  u =="0.000000000000000001" : ] 000000794749262.140653000000000000 ; 000000818664054.586834000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004BCB0EE4E12EA5 >									
	//     < RUSS_PFXVIII_III_metadata_line_32_____MIKA_DAO_20251101 >									
	//        < ZtRI9sINC8qh1X1BQIW9i4Chq82WGYPSYy4uQ18Z03ivzCGcGi55K3Y52x0DU6yI >									
	//        <  u =="0.000000000000000001" : ] 000000818664054.586834000000000000 ; 000000846363623.077715000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004E12EA550B72CA >									
	//     < RUSS_PFXVIII_III_metadata_line_33_____MIKA_DAOPI_20251101 >									
	//        < 8JO2ePQ7M4m0OzXq3q53s2C6166z4eB7lsVsrB1t93t2Rwp4QdxE8RgV6ow0WnS8 >									
	//        <  u =="0.000000000000000001" : ] 000000846363623.077715000000000000 ; 000000868911959.840019000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000050B72CA52DDABC >									
	//     < RUSS_PFXVIII_III_metadata_line_34_____MIKA_DAC_20251101 >									
	//        < r97jCR2oZ00VvdhRrS4ZjchR0114JG7g0E13Tof2K5dlLmzUv9B6lSs4aLxf78O0 >									
	//        <  u =="0.000000000000000001" : ] 000000868911959.840019000000000000 ; 000000901566964.564355000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000052DDABC55FAE98 >									
	//     < RUSS_PFXVIII_III_metadata_line_35_____MIKA_BIMI_20251101 >									
	//        < a0fdNRKP1GVB91iHdnN77dGK4TDNB1EPfz57dQZucgWn0HbNb4wLH32cZ0898157 >									
	//        <  u =="0.000000000000000001" : ] 000000901566964.564355000000000000 ; 000000921869269.978442000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000055FAE9857EA92F >									
	//     < RUSS_PFXVIII_III_metadata_line_36_____MIKA_PENSII_ORG_20251101 >									
	//        < reyl6BXp512SizTeE75b5IcpxnVS5z8QBWHooVz64I1S0r8m9pBCQw8Gx85aceX3 >									
	//        <  u =="0.000000000000000001" : ] 000000921869269.978442000000000000 ; 000000957155126.648473000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000057EA92F5B480B9 >									
	//     < RUSS_PFXVIII_III_metadata_line_37_____MIKA_PENSII_DAO_20251101 >									
	//        < oIOp2ZdiKs329K8e5Pt7lVug49N03EkHA8QXg3C2Sn1Ao76a2tFcP5Pt543KX7Qq >									
	//        <  u =="0.000000000000000001" : ] 000000957155126.648473000000000000 ; 000000983370175.899571000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005B480B95DC80FA >									
	//     < RUSS_PFXVIII_III_metadata_line_38_____MIKA_PENSII_DAOPI_20251101 >									
	//        < 7iH1a73xovCos88xYHXWVJJQavZy65hUWMoBm1095nYwE3C8Er84VMv49Psuz5mx >									
	//        <  u =="0.000000000000000001" : ] 000000983370175.899571000000000000 ; 000001011764222.211630000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005DC80FA607D466 >									
	//     < RUSS_PFXVIII_III_metadata_line_39_____MIKA_PENSII_DAC_20251101 >									
	//        < ZIkDDJNg7p8X8TShLTYHcF7jPVFkFheDs4Guo7H391gQj1bNkw67AB71aiC0em8D >									
	//        <  u =="0.000000000000000001" : ] 000001011764222.211630000000000000 ; 000001043043601.478640000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000607D4666378EE8 >									
	//     < RUSS_PFXVIII_III_metadata_line_40_____MIKA_PENSII_BIMI_20251101 >									
	//        < R8Q4F11G449063y458p69q1S7l25267csJc241LaTE4C2dMw60gu4hyt1Cofjrk3 >									
	//        <  u =="0.000000000000000001" : ] 000001043043601.478640000000000000 ; 000001072512790.689600000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006378EE8664864F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}