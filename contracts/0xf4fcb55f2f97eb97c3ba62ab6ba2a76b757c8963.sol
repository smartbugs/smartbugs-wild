pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXII_II_883		"	;
		string	public		symbol =	"	RUSS_PFXII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		771267165988295000000000000					;	
										
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
	//     < RUSS_PFXII_II_metadata_line_1_____TMK_20231101 >									
	//        < hgE05676RoARsX1qSd30Fwjzc5kc3GTU2lp0oC7a88M1i3T816AP33OYC5aUzVTL >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000018613309.041651500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001C66D3 >									
	//     < RUSS_PFXII_II_metadata_line_2_____TMK_ORG_20231101 >									
	//        < KndK1JeqjQDBTkV1Xz95tAbC87ixgYuJ85Ot87G99rl7d48I65WsWLYFHP5U26xe >									
	//        <  u =="0.000000000000000001" : ] 000000018613309.041651500000000000 ; 000000038717214.268966400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001C66D33B13E9 >									
	//     < RUSS_PFXII_II_metadata_line_3_____TMK_STEEL_LIMITED_20231101 >									
	//        < Qd07EsG8ZONzrRUX2P4dLRy4gDjWYuKO8hyv6NlmAK0G4hUQ55GAXzh5UxsZYoGu >									
	//        <  u =="0.000000000000000001" : ] 000000038717214.268966400000000000 ; 000000054168081.288761600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003B13E952A768 >									
	//     < RUSS_PFXII_II_metadata_line_4_____IPSCO_TUBULARS_INC_20231101 >									
	//        < NgY66yD7Vm551J35s5o869932600nd3lqJ6OYR2y1vgC0J2FgDCFS77r96gc1hE2 >									
	//        <  u =="0.000000000000000001" : ] 000000054168081.288761600000000000 ; 000000072847161.800515000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000052A7686F27EC >									
	//     < RUSS_PFXII_II_metadata_line_5_____VOLZHSKY_PIPE_PLANT_20231101 >									
	//        < YrjAxmXi1TCXm7y5gW5EndDrdn74X5cj7EH9509m2No199K95Whr1LHppQ8I31Se >									
	//        <  u =="0.000000000000000001" : ] 000000072847161.800515000000000000 ; 000000094063881.032758400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006F27EC8F87B4 >									
	//     < RUSS_PFXII_II_metadata_line_6_____SEVERSKY_PIPE_PLANT_20231101 >									
	//        < 11k22O9qgGEARd2M593NUKM36W6ZJ7Sy854Qb85TrF96NFJ0c78uaWXdcZ8gpo1c >									
	//        <  u =="0.000000000000000001" : ] 000000094063881.032758400000000000 ; 000000114122960.551995000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008F87B4AE2348 >									
	//     < RUSS_PFXII_II_metadata_line_7_____RESITA_WORKS_20231101 >									
	//        < 1LZHH0cX8iB0Sh0gUUI9lUuf52ynF2Je58Ry4yQ4SSbqGf8CdONZJMKmJC3VNWl9 >									
	//        <  u =="0.000000000000000001" : ] 000000114122960.551995000000000000 ; 000000134234323.529141000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AE2348CCD348 >									
	//     < RUSS_PFXII_II_metadata_line_8_____GULF_INTERNATIONAL_PIPE_INDUSTRY_20231101 >									
	//        < gc6q80hq1bIWqS2d45txkr72JcJAJozs9khtpdVw6nd129xUdJj3L88rhyy0ShwP >									
	//        <  u =="0.000000000000000001" : ] 000000134234323.529141000000000000 ; 000000153389605.387935000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CCD348EA0DD1 >									
	//     < RUSS_PFXII_II_metadata_line_9_____TMK_PREMIUM_SERVICE_20231101 >									
	//        < n5ykg86E3Vm2uXXocT6T81Vf5M13VN9wy870v5DpShugWNb4PAe8EK7kA61OiU3e >									
	//        <  u =="0.000000000000000001" : ] 000000153389605.387935000000000000 ; 000000170720124.092163000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EA0DD11047F8C >									
	//     < RUSS_PFXII_II_metadata_line_10_____ORSKY_MACHINE_BUILDING_PLANT_20231101 >									
	//        < 1282TfzK0TQ15s71fO9Xe4BDYWctcB0fSInGuc49ZkEJVMW09I2EN40I21Tw14Fs >									
	//        <  u =="0.000000000000000001" : ] 000000170720124.092163000000000000 ; 000000187379052.009477000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001047F8C11DEAF1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXII_II_metadata_line_11_____TMK_CAPITAL_SA_20231101 >									
	//        < 9cZ2BmaogS13rL5bvT2oulKlsIoqA8CbjIk69Oy84j44450P05v6qhHIm0aAU9D6 >									
	//        <  u =="0.000000000000000001" : ] 000000187379052.009477000000000000 ; 000000204989989.648518000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011DEAF1138CA37 >									
	//     < RUSS_PFXII_II_metadata_line_12_____TMK_NSG_LLC_20231101 >									
	//        < L3TmfiK23B4lKPgn1MsJG5r51Z2a0XxcQ7pPCAhf6K7GpEA7nLJrUsG38dR0A66b >									
	//        <  u =="0.000000000000000001" : ] 000000204989989.648518000000000000 ; 000000220497463.473259000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000138CA3715073D2 >									
	//     < RUSS_PFXII_II_metadata_line_13_____TMK_GLOBAL_AG_20231101 >									
	//        < VfP0O6bVYPnH98cPC9SK370sXl3JtjOn6p0x8e9SET4u039NQ1i2tT88bH1DakY5 >									
	//        <  u =="0.000000000000000001" : ] 000000220497463.473259000000000000 ; 000000242408305.326265000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015073D2171E2BF >									
	//     < RUSS_PFXII_II_metadata_line_14_____TMK_EUROPE_GMBH_20231101 >									
	//        < tMRVTL7wso2U6JX4tg191G0sBm9rPc9z99mbw5gd502D9F7e35aiVpPT8EY2rev8 >									
	//        <  u =="0.000000000000000001" : ] 000000242408305.326265000000000000 ; 000000259395831.754933000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000171E2BF18BCE7F >									
	//     < RUSS_PFXII_II_metadata_line_15_____TMK_MIDDLE_EAST_FZCO_20231101 >									
	//        < x1llnP7190votLm54Zh2IoOA18RG52N2t45v4RYnl1DYOH0FCo5Cz9b451hRppVG >									
	//        <  u =="0.000000000000000001" : ] 000000259395831.754933000000000000 ; 000000281599418.632856000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018BCE7F1ADAFC6 >									
	//     < RUSS_PFXII_II_metadata_line_16_____TMK_EUROSINARA_SRL_20231101 >									
	//        < 5PY3VN909NA8N8HUFemCK6UWPvTm4303xMUGixGLpS8m04u26uK2nKJL1Ay0A6D2 >									
	//        <  u =="0.000000000000000001" : ] 000000281599418.632856000000000000 ; 000000303564100.837930000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001ADAFC61CF33BA >									
	//     < RUSS_PFXII_II_metadata_line_17_____TMK_EASTERN_EUROPE_SRL_20231101 >									
	//        < Cuo34boIqt8Y727DB7HBC4P0zfBFEBhrlzik9oGK5071f64iRtl0TQYWcd8GqrQb >									
	//        <  u =="0.000000000000000001" : ] 000000303564100.837930000000000000 ; 000000326648075.077173000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CF33BA1F26CE8 >									
	//     < RUSS_PFXII_II_metadata_line_18_____TMK_REAL_ESTATE_SRL_20231101 >									
	//        < mBxp2Cs60NyNeJ9xejdYB0Pbt3R2IFhgZ34XSfNY9u4Pmsk12G21Tc2gw6pWbP3M >									
	//        <  u =="0.000000000000000001" : ] 000000326648075.077173000000000000 ; 000000342391782.303527000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F26CE820A72CA >									
	//     < RUSS_PFXII_II_metadata_line_19_____POKROVKA_40_20231101 >									
	//        < 1HP8Zg4lPwWo57jD4v3vhrVE00w34r6B7xe71931cC7SiVG2505iRK7D02bq9kO8 >									
	//        <  u =="0.000000000000000001" : ] 000000342391782.303527000000000000 ; 000000364585776.436535000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020A72CA22C5052 >									
	//     < RUSS_PFXII_II_metadata_line_20_____THREADING_MECHANICAL_KEY_PREMIUM_20231101 >									
	//        < HMyw0MVetO8Pv4jg2U6nvaK3O5PqX4gJ93h2q095Ihdq3qK1pCAKQscxGQ5D40pQ >									
	//        <  u =="0.000000000000000001" : ] 000000364585776.436535000000000000 ; 000000383098203.962833000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022C50522488FBC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXII_II_metadata_line_21_____TMK_NORTH_AMERICA_INC_20231101 >									
	//        < a13V2W4ToVKoc6GteU49zp2KOP1l48MSYJpwK5sZGaK14yOfgHEz55t4hXW862gl >									
	//        <  u =="0.000000000000000001" : ] 000000383098203.962833000000000000 ; 000000405974037.653412000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002488FBC26B779C >									
	//     < RUSS_PFXII_II_metadata_line_22_____TMK_KAZAKHSTAN_20231101 >									
	//        < o9WmWK68bBCmTtOa0SDTk8f4HvRynz583vHkDFQAs5NVqUx0KM068TgcqjLE65kO >									
	//        <  u =="0.000000000000000001" : ] 000000405974037.653412000000000000 ; 000000423976233.204620000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026B779C286EFB7 >									
	//     < RUSS_PFXII_II_metadata_line_23_____KAZTRUBPROM_20231101 >									
	//        < RF2Z0k64lRqq53943A8b0d0i2B8n5UOH3AV1qI4H8WD3h5538C0IQl5e5P01n09N >									
	//        <  u =="0.000000000000000001" : ] 000000423976233.204620000000000000 ; 000000444659599.985529000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000286EFB72A67F28 >									
	//     < RUSS_PFXII_II_metadata_line_24_____PIPE_METALLURGIC_CO_COMPLETIONS_20231101 >									
	//        < g0lNrDS4uqMY1k42Z4l11X4RFRI93gI6R0cU0qh84Ss8Awk93gRwvW680LtubeLG >									
	//        <  u =="0.000000000000000001" : ] 000000444659599.985529000000000000 ; 000000463467234.615357000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A67F282C331E3 >									
	//     < RUSS_PFXII_II_metadata_line_25_____ZAO_TRADE_HOUSE_TMK_20231101 >									
	//        < tvjPiQF56AQd5yfNB4zbO03tS0scUN92n60Pn4ou1792O20kYH1wgT05DBL7IB7r >									
	//        <  u =="0.000000000000000001" : ] 000000463467234.615357000000000000 ; 000000484277291.093159000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C331E32E2F2D1 >									
	//     < RUSS_PFXII_II_metadata_line_26_____TMK_ZAO_PIPE_REPAIR_20231101 >									
	//        < 53lG4EKvJi48OCmGRaQprG6jxNNdeXLpZ4a41O7107ji0y29zweqOMXFuh3kf47a >									
	//        <  u =="0.000000000000000001" : ] 000000484277291.093159000000000000 ; 000000507533713.819676000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E2F2D13066F5B >									
	//     < RUSS_PFXII_II_metadata_line_27_____SINARA_PIPE_WORKS_TRADING_HOUSE_20231101 >									
	//        < Q389xII5NVn6hGmu3idgc1vZ7eNN4L73E1Xa433hZq0oB6CuG3wbICC92p82ADx3 >									
	//        <  u =="0.000000000000000001" : ] 000000507533713.819676000000000000 ; 000000523436328.523965000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003066F5B31EB351 >									
	//     < RUSS_PFXII_II_metadata_line_28_____SKLADSKOY_KOMPLEKS_20231101 >									
	//        < qFr0f7dB9PtA6Lg17GG8vODC8f379Il47Lh0pvnIJy37289IM2aq3WE8G45HADMY >									
	//        <  u =="0.000000000000000001" : ] 000000523436328.523965000000000000 ; 000000540598249.834114000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031EB351338E331 >									
	//     < RUSS_PFXII_II_metadata_line_29_____RUS_RESEARCH_INSTITUTE_TUBE_PIPE_IND_20231101 >									
	//        < k7AuCtS8fwc5DjJR07Hb0i5q208MGR3u9JvcL5AkPMx2DqaQX8V3zXPkllJ2dlkn >									
	//        <  u =="0.000000000000000001" : ] 000000540598249.834114000000000000 ; 000000562298721.173643000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000338E331359FFF0 >									
	//     < RUSS_PFXII_II_metadata_line_30_____TAGANROG_METALLURGICAL_PLANT_20231101 >									
	//        < zAUNVb58qb38pX62276Yf11zKOCB18E3oqcHT4u1t0OohUriZjNfk8qAnH06dr3L >									
	//        <  u =="0.000000000000000001" : ] 000000562298721.173643000000000000 ; 000000578220612.946035000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000359FFF03724B6D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXII_II_metadata_line_31_____TAGANROG_METALLURGICAL_WORKS_20231101 >									
	//        < vKn5EZhNWxsRCF17962YSCP1Qnelaw0IYfzN9MqS33Z1I3a8Gp90CE5SZA2T15oQ >									
	//        <  u =="0.000000000000000001" : ] 000000578220612.946035000000000000 ; 000000593851983.104765000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003724B6D38A256E >									
	//     < RUSS_PFXII_II_metadata_line_32_____IPSCO_CANADA_LIMITED_20231101 >									
	//        < q3F84N2585jf0zXYKou5SSQFZA2hkB7D1dh15l01g5D4an35fvxqy11o3IcsIVgR >									
	//        <  u =="0.000000000000000001" : ] 000000593851983.104765000000000000 ; 000000609723472.663691000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038A256E3A25D3B >									
	//     < RUSS_PFXII_II_metadata_line_33_____SINARA_NORTH_AMERICA_INC_20231101 >									
	//        < t3wJ80RIM7ML0X3w7Xkj4R63m2QC2Jx440fu5D2TL4q4s4G4uZTeRbPL8uJ4aP4b >									
	//        <  u =="0.000000000000000001" : ] 000000609723472.663691000000000000 ; 000000628445271.417052000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A25D3B3BEEE6F >									
	//     < RUSS_PFXII_II_metadata_line_34_____PIPE_METALLURGICAL_CO_TRADING_HOUSE_20231101 >									
	//        < Xy6DhOY1ED1UFm6Q0d64GikzoIq526VNXS9H29W1942f62c71K529ZUqs4oEnCJM >									
	//        <  u =="0.000000000000000001" : ] 000000628445271.417052000000000000 ; 000000651219295.895214000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003BEEE6F3E1AE8A >									
	//     < RUSS_PFXII_II_metadata_line_35_____TAGANROG_METALLURGICAL_WORKS_20231101 >									
	//        < VbiHy6PeJreW4F9M9Xo7nE6nf99JJw69df91jcnR3k8V1FW20HXC36JQz8z9UxE1 >									
	//        <  u =="0.000000000000000001" : ] 000000651219295.895214000000000000 ; 000000669472332.985249000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E1AE8A3FD88A1 >									
	//     < RUSS_PFXII_II_metadata_line_36_____SINARSKY_PIPE_PLANT_20231101 >									
	//        < 681fe1ZZ8Ty3jK8936h2vxt0CCEdty68TUZmHkSPn1okki1dyujA97hoiTq8YMdy >									
	//        <  u =="0.000000000000000001" : ] 000000669472332.985249000000000000 ; 000000691477942.240443000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003FD88A141F1C92 >									
	//     < RUSS_PFXII_II_metadata_line_37_____TMK_BONDS_SA_20231101 >									
	//        < c63qzA23g4As1ZQdZZaU4JsJBrC8y6mSSz9Kxav51024XEcnJVt41JCG51OXlDww >									
	//        <  u =="0.000000000000000001" : ] 000000691477942.240443000000000000 ; 000000708120554.026407000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041F1C924388197 >									
	//     < RUSS_PFXII_II_metadata_line_38_____OOO_CENTRAL_PIPE_YARD_20231101 >									
	//        < 8C99tA76wCo8KY6bS90zg6m2879dUt94k0hLXHz7B3J910J7OHTklb7hhl1O2nc5 >									
	//        <  u =="0.000000000000000001" : ] 000000708120554.026407000000000000 ; 000000727300469.096228000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004388197455C5BF >									
	//     < RUSS_PFXII_II_metadata_line_39_____SINARA_PIPE_WORKS_20231101 >									
	//        < K14ex2bDf8Uvpe7B9n23imxNby171RoX9X8bpvyZrx5LmGTZ1Ysp6wKogFq9978a >									
	//        <  u =="0.000000000000000001" : ] 000000727300469.096228000000000000 ; 000000746988422.612878000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000455C5BF473D05A >									
	//     < RUSS_PFXII_II_metadata_line_40_____ZAO_TMK_TRADE_HOUSE_20231101 >									
	//        < 2eC1U4dn4V5S1d5500pWw98G26W60eh4o57V69mv4hPqB09YnRXI61n207dan1Oq >									
	//        <  u =="0.000000000000000001" : ] 000000746988422.612878000000000000 ; 000000771267165.988295000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000473D05A498DC3D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}