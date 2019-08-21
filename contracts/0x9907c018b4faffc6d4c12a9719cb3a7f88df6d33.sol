pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFV_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFV_III_883		"	;
		string	public		symbol =	"	NDRV_PFV_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1910474611608440000000000000					;	
										
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
	//     < NDRV_PFV_III_metadata_line_1_____talanx primary insurance group_20251101 >									
	//        < KG4ctam18oEiuQv35Eqr3UfLmt1iML40Qg78jJ9VcGuVNO68OvW1aMt1Ff8nE4v4 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000042589615.897509700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000040FC92 >									
	//     < NDRV_PFV_III_metadata_line_2_____primary_pensions_20251101 >									
	//        < 59gMV96858yR83S5r6ATEYvfS44d4HVoE9oE05X72ul3gMOS8533S0Kr6L26z68n >									
	//        <  u =="0.000000000000000001" : ] 000000042589615.897509700000000000 ; 000000096236947.808051400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000040FC9292D88F >									
	//     < NDRV_PFV_III_metadata_line_3_____hdi rechtsschutz ag_20251101 >									
	//        < AnP10u7skfDEVhLk784paZ08dAFW8O2BE82z877ya29i57Ub1WW3y787WFRHOP75 >									
	//        <  u =="0.000000000000000001" : ] 000000096236947.808051400000000000 ; 000000190827391.101527000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000092D88F1232DF3 >									
	//     < NDRV_PFV_III_metadata_line_4_____Gerling Insurance Of South Africa Ltd_20251101 >									
	//        < 2Ib3sJM30wljWSi7Tnl0BSRnP9T7R6ZICO0IYr45309uN5drTvwp4ia23wCwUUGK >									
	//        <  u =="0.000000000000000001" : ] 000000190827391.101527000000000000 ; 000000228946796.230624000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001232DF315D5858 >									
	//     < NDRV_PFV_III_metadata_line_5_____Gerling Global Life Sweden Reinsurance Co LTd_20251101 >									
	//        < nGLwK76kdzfR6IRvj2tl9yt4Akp2U5zR4kSFF36g4rtO6d7711AQOWi3XZQSS9b8 >									
	//        <  u =="0.000000000000000001" : ] 000000228946796.230624000000000000 ; 000000272156511.736473000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015D585819F4723 >									
	//     < NDRV_PFV_III_metadata_line_6_____Amtrust Corporate Member Ltd_20251101 >									
	//        < CQ8PlpteRL2lJTbBLM07k27u07LB189f9jq7DSuOgP2u9ZofCe4Yfdcb423dxX8G >									
	//        <  u =="0.000000000000000001" : ] 000000272156511.736473000000000000 ; 000000337259852.030440000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019F47232029E21 >									
	//     < NDRV_PFV_III_metadata_line_7_____HDI_Gerling Australia Insurance Company Pty Ltd_20251101 >									
	//        < 8hZ75Q2O6qXshTK9bVf4kJKo52ujz13Htj4vC1z06VN1Tm4qnD8Wvo5rgwK69QEj >									
	//        <  u =="0.000000000000000001" : ] 000000337259852.030440000000000000 ; 000000376281728.294519000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002029E2123E290D >									
	//     < NDRV_PFV_III_metadata_line_8_____Gerling Institut GIBA_20251101 >									
	//        < chBHaZ8BEc5Oa45zIT9UKvt284sfBJ9RjcR5gEjY7XmJyDj83S3mL6HDjsOid3tl >									
	//        <  u =="0.000000000000000001" : ] 000000376281728.294519000000000000 ; 000000418554462.571547000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023E290D27EA9D6 >									
	//     < NDRV_PFV_III_metadata_line_9_____Gerling_org_20251101 >									
	//        < 3DvCEcze3B9kxGTb88PhsU4C6kMs723BvC5kbY7Li10d7A6lIHM6e75jiFQ2dYl5 >									
	//        <  u =="0.000000000000000001" : ] 000000418554462.571547000000000000 ; 000000477565998.718189000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027EA9D62D8B538 >									
	//     < NDRV_PFV_III_metadata_line_10_____Gerling_Holdings_20251101 >									
	//        < 8vk3wxzcw6O8eCus6MVmi6xYYeL9K63K63iYJT75Pf9g3MNr99i0eJ6OPWd8Oesr >									
	//        <  u =="0.000000000000000001" : ] 000000477565998.718189000000000000 ; 000000511367460.923697000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D8B53830C48EA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFV_III_metadata_line_11_____Gerling_Pensions_20251101 >									
	//        < fDh55dSYQIWe856se5kr1Fe0IeXiumz31nk5p1208r9zvS6ue6k6eH947u3y8950 >									
	//        <  u =="0.000000000000000001" : ] 000000511367460.923697000000000000 ; 000000537837853.353632000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030C48EA334ACE9 >									
	//     < NDRV_PFV_III_metadata_line_12_____talanx international ag_20251101 >									
	//        < GDgKm9p7cueqOVj0QSCd5SH6r74nShCs94I010BDhyRwaTPV4ub7N5c42PWkMbpB >									
	//        <  u =="0.000000000000000001" : ] 000000537837853.353632000000000000 ; 000000619929590.335821000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000334ACE93B1EFFF >									
	//     < NDRV_PFV_III_metadata_line_13_____tuir warta_20251101 >									
	//        < AEEU06WNmM4XkK90b9F2UO5Ezhs11N0mtHpI5KYG31ht7q2uFp8fhHglC5dac875 >									
	//        <  u =="0.000000000000000001" : ] 000000619929590.335821000000000000 ; 000000658440031.004939000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B1EFFF3ECB323 >									
	//     < NDRV_PFV_III_metadata_line_14_____tuir warta_org_20251101 >									
	//        < 05q6QaXF6D4FzjTTd44dzyPVI388682BL140yPGX2hFzxQ10D463eB6zXnVQ99Qj >									
	//        <  u =="0.000000000000000001" : ] 000000658440031.004939000000000000 ; 000000679368771.613549000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003ECB32340CA26D >									
	//     < NDRV_PFV_III_metadata_line_15_____towarzystwo ubezpieczen na zycie warta sa_20251101 >									
	//        < cu7oHw07Oz99o3pBYRAY6mLu5cU237HEeBWKFhnEBL32Tr4w8EGpVRruVnjt69ZK >									
	//        <  u =="0.000000000000000001" : ] 000000679368771.613549000000000000 ; 000000705567962.630880000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040CA26D4349C7C >									
	//     < NDRV_PFV_III_metadata_line_16_____HDI-Gerling Zycie Towarzystwo Ubezpieczen Spolka Akcyjna_20251101 >									
	//        < tx9D4EGi9fb9Fw87Z7sYLXfn3ku24PpAb5Bt9d0zXWIxHm1Zfdp9H38H5MWWu08J >									
	//        <  u =="0.000000000000000001" : ] 000000705567962.630880000000000000 ; 000000745911116.028055000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004349C7C4722B88 >									
	//     < NDRV_PFV_III_metadata_line_17_____TUiR Warta SA Asset Management Arm_20251101 >									
	//        < 026kq691h6lZ465R8op8BDN15Cb1loWP556UzW0mb7p3i1uHQZ84s6e0I3Rf82IN >									
	//        <  u =="0.000000000000000001" : ] 000000745911116.028055000000000000 ; 000000796701379.973674000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004722B884BFAB7A >									
	//     < NDRV_PFV_III_metadata_line_18_____HDI Seguros SA de CV_20251101 >									
	//        < 71zAGl1974kfDbgCpQPHvfmXAQCRS7Un00LJtltn3Wu11HH3JR4sYE9iN4Sq6RQK >									
	//        <  u =="0.000000000000000001" : ] 000000796701379.973674000000000000 ; 000000816865306.758990000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004BFAB7A4DE7003 >									
	//     < NDRV_PFV_III_metadata_line_19_____Towarzystwo Ubezpieczen Europa SA_20251101 >									
	//        < 3eEUYTv2M0i0f5537dKxPt08J1WVw5aO4Nn26EgxP3n4yh802okKBiX3CSlEJe9D >									
	//        <  u =="0.000000000000000001" : ] 000000816865306.758990000000000000 ; 000000876266871.284998000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004DE700353913BF >									
	//     < NDRV_PFV_III_metadata_line_20_____Towarzystwo Ubezpieczen Na Zycie EUROPA SA_20251101 >									
	//        < 3aduF8R9e9M1S7xa44jLXpWfWc4ZO5vsN63iD7a66rXpFEKHphX7dmTQD850SB5O >									
	//        <  u =="0.000000000000000001" : ] 000000876266871.284998000000000000 ; 000000944874879.152858000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000053913BF5A1C3C0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFV_III_metadata_line_21_____TU na ycie EUROPA SA_20251101 >									
	//        < FdZsUjuT5XUDCJ7wkanK1tG88fl03pX2C4JnHO7hrJiZ28bO1zd7auZ706f1B76p >									
	//        <  u =="0.000000000000000001" : ] 000000944874879.152858000000000000 ; 000000980527015.155292000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005A1C3C05D82A5E >									
	//     < NDRV_PFV_III_metadata_line_22_____Liberty Sigorta_20251101 >									
	//        < 8ZY0O6xnY3DR7P9971w96mx6h734a62eDU3zy1979266Dj73H7702M8254FEXn92 >									
	//        <  u =="0.000000000000000001" : ] 000000980527015.155292000000000000 ; 000001021927867.013220000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005D82A5E6175693 >									
	//     < NDRV_PFV_III_metadata_line_23_____Aspecta Versicherung Ag_20251101 >									
	//        < 1D00y1hK2igq18dmkitUN968UvbGNP2fErDsJLcuDo6C012ejD0J1cUpy5P88y1o >									
	//        <  u =="0.000000000000000001" : ] 000001021927867.013220000000000000 ; 000001099881605.212380000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000617569368E4941 >									
	//     < NDRV_PFV_III_metadata_line_24_____HDI Sigorta AS_20251101 >									
	//        < iPkdFYY4YvEfrVUsaXJu86slyXAP5gRDCy4p14RF6WQJHHmIthCVIVGFRz7Jz0mG >									
	//        <  u =="0.000000000000000001" : ] 000001099881605.212380000000000000 ; 000001153294261.557370000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000068E49416DFC992 >									
	//     < NDRV_PFV_III_metadata_line_25_____HDI Seguros SA_20251101 >									
	//        < k33rH0XbCEkdcBLr1W54W35LLid2qF3GuBg39rd37c6Sx10O7g6Phio4IFO9fbtM >									
	//        <  u =="0.000000000000000001" : ] 000001153294261.557370000000000000 ; 000001177861658.019410000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006DFC9927054636 >									
	//     < NDRV_PFV_III_metadata_line_26_____Aseguradora Magallanes SA_20251101 >									
	//        < hj4N6C370ptnCni0j9n43K2GeE2rMGaMDMzIxj71c0O74PS3WaU79mHQJ83J79H2 >									
	//        <  u =="0.000000000000000001" : ] 000001177861658.019410000000000000 ; 000001209418351.920810000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000070546367356D0B >									
	//     < NDRV_PFV_III_metadata_line_27_____Asset Management Arm_20251101 >									
	//        < d7Q72CMDXmdxBK27v1YIDnmy70CqCyGVGrz36hpTq17Mb8bl4M1eAa5d07sG5OFo >									
	//        <  u =="0.000000000000000001" : ] 000001209418351.920810000000000000 ; 000001245079667.036640000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007356D0B76BD73F >									
	//     < NDRV_PFV_III_metadata_line_28_____HDI Assicurazioni SpA_20251101 >									
	//        < xW1SPsIFWmrf4ZLi8fc4x7YtrofaBDFn4FkLcpIZZCNq0LfbVOgl6v2bQQ6Q4zjB >									
	//        <  u =="0.000000000000000001" : ] 000001245079667.036640000000000000 ; 000001267342897.583190000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000076BD73F78DCFD2 >									
	//     < NDRV_PFV_III_metadata_line_29_____InChiaro Assicurazioni SPA_20251101 >									
	//        < HQd0gd56aM9EOBg61hd76iry5L97VD70TlwK0gmJ9p6MwsxVDY8NYfhhIh3e4cUj >									
	//        <  u =="0.000000000000000001" : ] 000001267342897.583190000000000000 ; 000001326645765.025700000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000078DCFD27E84D01 >									
	//     < NDRV_PFV_III_metadata_line_30_____Inlinea SpA_20251101 >									
	//        < 3l45F5Vmd3389qo72pY30Wzac0P21dkj99U1v6UKzl3k2333S6tH3C13DK21w1uX >									
	//        <  u =="0.000000000000000001" : ] 000001326645765.025700000000000000 ; 000001411627188.905020000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007E84D01869F8DF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFV_III_metadata_line_31_____Inversiones HDI Limitada_20251101 >									
	//        < 2K3N2w5dDs801F31Gh038wmm0AlTZq8ys47tyy97T1qGmotqT5LN49VAe4R04dIV >									
	//        <  u =="0.000000000000000001" : ] 000001411627188.905020000000000000 ; 000001449130190.846340000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000869F8DF8A3327B >									
	//     < NDRV_PFV_III_metadata_line_32_____HDI Seguros de Garantía y Crédito SA_20251101 >									
	//        < 5gDDVTM9n211pR9W83S9MhXkwOTEAR310erR0HmvVl6KZ0I4Z01dL3W74ilh343K >									
	//        <  u =="0.000000000000000001" : ] 000001449130190.846340000000000000 ; 000001478708284.642800000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008A3327B8D0546C >									
	//     < NDRV_PFV_III_metadata_line_33_____HDI Seguros_20251101 >									
	//        < Dl39nB1MTeE2xx8wgT7m36IosST6xgvo1n3I8W00scWD7h3W7795AAcN986lWD33 >									
	//        <  u =="0.000000000000000001" : ] 000001478708284.642800000000000000 ; 000001552860594.099310000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008D0546C9417A2B >									
	//     < NDRV_PFV_III_metadata_line_34_____HDI Seguros_Holdings_20251101 >									
	//        < EAbhx0YDLt6G141N810vMAQzNQZ107tx4a3N2hh1Yh7fd3o4fvzyF6J9u270MPDB >									
	//        <  u =="0.000000000000000001" : ] 000001552860594.099310000000000000 ; 000001642778923.482200000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009417A2B9CAAE84 >									
	//     < NDRV_PFV_III_metadata_line_35_____Aseguradora Magallanes Peru SA Compania De Seguros_20251101 >									
	//        < u2237173QJOTjR1diUZ85ci8K36oU91vvBLd7UN4jS5uc4CCoCL1aKO49kYE0N7o >									
	//        <  u =="0.000000000000000001" : ] 000001642778923.482200000000000000 ; 000001713134891.940710000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009CAAE84A360951 >									
	//     < NDRV_PFV_III_metadata_line_36_____Saint Honoré Iberia SL_20251101 >									
	//        < uipanEW36xnmi6dCl1HFZ8o8C0Udd9RbvatJcHXD8x5F9QvODGH47a53Eb2dS3nx >									
	//        <  u =="0.000000000000000001" : ] 000001713134891.940710000000000000 ; 000001736782280.405670000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A360951A5A1E94 >									
	//     < NDRV_PFV_III_metadata_line_37_____HDI Seguros SA_20251101 >									
	//        < 8sLRCPscTP00F3J0tHyP3cFLd9VYtWWMPSkW1RTK98Kf7LzMRo1SHJU3KOkS2oxz >									
	//        <  u =="0.000000000000000001" : ] 000001736782280.405670000000000000 ; 000001828552783.069300000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A5A1E94AE6266E >									
	//     < NDRV_PFV_III_metadata_line_38_____L_UNION de Paris Cia Uruguaya de Seguros SA_20251101 >									
	//        < BQAhX6TyCW84M9h1ou0MyL2uSi47M6s650xdb0rN7iK0Bvnflr35wXcztYWAUZbq >									
	//        <  u =="0.000000000000000001" : ] 000001828552783.069300000000000000 ; 000001847027743.462680000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000AE6266EB025736 >									
	//     < NDRV_PFV_III_metadata_line_39_____L_UNION_org_20251101 >									
	//        < 7y45808EitCZriox8Yv1jC543x75s97UDN8167mMqUt56N5jN4DzGr2fal6x31CH >									
	//        <  u =="0.000000000000000001" : ] 000001847027743.462680000000000000 ; 000001884532931.974440000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000B025736B3B91AD >									
	//     < NDRV_PFV_III_metadata_line_40_____Protecciones Esenciales SA_20251101 >									
	//        < 55aIknGuj7RNW5I5H72CUXcIc0QiMfTnHdSTgTdQgu43p6yIkEgnKxHfHEaH27k1 >									
	//        <  u =="0.000000000000000001" : ] 000001884532931.974440000000000000 ; 000001910474611.608440000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000B3B91ADB632725 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}