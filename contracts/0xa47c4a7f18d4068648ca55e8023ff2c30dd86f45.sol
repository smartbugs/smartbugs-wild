pragma solidity 		^0.4.25	;						
										
	contract	CHEMCHINA_PFII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	CHEMCHINA_PFII_II_883		"	;
		string	public		symbol =	"	CHEMCHINA_PFII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		766244968597695000000000000					;	
										
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
	//     < CHEMCHINA_PFII_II_metadata_line_1_____CHANGZHOU_WUJIN_LINCHUAN_CHEMICAL_Co_Limited_20240321 >									
	//        < 9KuqH90MivL0s53GFd8GdAUnoiZiXy0AaAee41m142z79F26CdIksK82gPQP5Zrf >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000022716158.769144000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000022A980 >									
	//     < CHEMCHINA_PFII_II_metadata_line_2_____Chem_Stone_Co__Limited_20240321 >									
	//        < 7R9fDkd70mbWhJjh8Okew8z78f47T8u4aWh9jU809RIr57jG3dp0kgBHXC9bh30x >									
	//        <  u =="0.000000000000000001" : ] 000000022716158.769144000000000000 ; 000000038958182.762099900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000022A9803B720A >									
	//     < CHEMCHINA_PFII_II_metadata_line_3_____Chemleader_Biomedical_Co_Limited_20240321 >									
	//        < mmvQe2798090HygXUNPF1rEk3Fx65oamFi4ChmJ5Y0u1cY9zPaw5rL8c3ZHvT1W3 >									
	//        <  u =="0.000000000000000001" : ] 000000038958182.762099900000000000 ; 000000060490949.721340200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003B720A5C4D47 >									
	//     < CHEMCHINA_PFII_II_metadata_line_4_____Chemner_Pharma_20240321 >									
	//        < 3HiLRVHSPcWM0u38L4cf8BR72xMQ2qhv0A2Z2O1jk3IRWCis228jf066mb3HCA1X >									
	//        <  u =="0.000000000000000001" : ] 000000060490949.721340200000000000 ; 000000078054810.052456300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005C4D47771A29 >									
	//     < CHEMCHINA_PFII_II_metadata_line_5_____Chemtour_Biotech__Suzhou__org_20240321 >									
	//        < 4880hI5ab7VC2e5l62ehA657S20MekPk6234GS3zS1vthg0WKc5JFv5Uw5kKm75J >									
	//        <  u =="0.000000000000000001" : ] 000000078054810.052456300000000000 ; 000000093964423.475318400000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000771A298F60DA >									
	//     < CHEMCHINA_PFII_II_metadata_line_6_____Chemtour_Biotech__Suzhou__Co__Ltd_20240321 >									
	//        < dvkd4l59D7z98s149M7Bgf0J2eYohn6bE1HY9Ux1p1goI0swyzz64FBM2b752Gu9 >									
	//        <  u =="0.000000000000000001" : ] 000000093964423.475318400000000000 ; 000000112335218.709289000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008F60DAAB68F2 >									
	//     < CHEMCHINA_PFII_II_metadata_line_7_____Chemvon_Biotechnology_Co__Limited_20240321 >									
	//        < fU1hT8v517G3TYlQCdlOf9hN3y61dyfAdhS7u11mye5zUmphS596XXbZ6YEVn6cd >									
	//        <  u =="0.000000000000000001" : ] 000000112335218.709289000000000000 ; 000000132140441.049308000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AB68F2C9A15C >									
	//     < CHEMCHINA_PFII_II_metadata_line_8_____Chengdu_Aslee_Biopharmaceuticals,_inc__20240321 >									
	//        < 077E6M3LiZ8KHsIEb8MjGA2m26637L8o4OtsEA1LQjPUn8Ent1Il7RQy54Z2Ful6 >									
	//        <  u =="0.000000000000000001" : ] 000000132140441.049308000000000000 ; 000000148576212.971557000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C9A15CE2B595 >									
	//     < CHEMCHINA_PFII_II_metadata_line_9_____Chuxiong_Yunzhi_Phytopharmaceutical_Co_Limited_20240321 >									
	//        < 2REknmn245Z5nT0NEE342IN0sd6CY1gS23mQ1k11V9zt6XYu3UfQ2tss3i4KK8zN >									
	//        <  u =="0.000000000000000001" : ] 000000148576212.971557000000000000 ; 000000170553457.432960000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E2B5951043E72 >									
	//     < CHEMCHINA_PFII_II_metadata_line_10_____Conier_Chem_Pharma__Limited_20240321 >									
	//        < 36jGoovq8zpg6N54bf3tvSRK6Vfz3td32iK66xg7IO67rjUO37NVUyidX4u5WM7A >									
	//        <  u =="0.000000000000000001" : ] 000000170553457.432960000000000000 ; 000000190524554.030866000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001043E72122B7A7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFII_II_metadata_line_11_____Cool_Pharm_Ltd_20240321 >									
	//        < 5VNYlyI4gGo5w0gr56a4QjVMG9DuGS6w2NL3hi6BPEjlNxnQTCRAuYkrpHcffCFy >									
	//        <  u =="0.000000000000000001" : ] 000000190524554.030866000000000000 ; 000000212564874.791012000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000122B7A71445927 >									
	//     < CHEMCHINA_PFII_II_metadata_line_12_____Coresyn_Pharmatech_Co__Limited_20240321 >									
	//        < 67a4a22cP614utDDC1AnmZ9mqZlG149wrp7l9nzOIGI3f4FI2Wvt5Om3Cp99faQp >									
	//        <  u =="0.000000000000000001" : ] 000000212564874.791012000000000000 ; 000000235962369.614388000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014459271680CCD >									
	//     < CHEMCHINA_PFII_II_metadata_line_13_____Dalian_Join_King_Fine_Chemical_org_20240321 >									
	//        < 2DwE69Kpen7BK9Eq9a64p7Gbz4j6mk9BDM5Yv87H0HyD3a0HJy0U9KHNL89GEcog >									
	//        <  u =="0.000000000000000001" : ] 000000235962369.614388000000000000 ; 000000257687024.088296000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001680CCD18932FE >									
	//     < CHEMCHINA_PFII_II_metadata_line_14_____Dalian_Join_King_Fine_Chemical_Co_Limited_20240321 >									
	//        < ajSsz8Qh6uX6x3fcs0ALp1si4AkFfuMs5fIR5wiAZ85a0gzZXBTnS7lY42log493 >									
	//        <  u =="0.000000000000000001" : ] 000000257687024.088296000000000000 ; 000000278233365.681756000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018932FE1A88CE9 >									
	//     < CHEMCHINA_PFII_II_metadata_line_15_____Dalian_Richfortune_Chemicals_Co_Limited_20240321 >									
	//        < 0Ypk5GCQCovt9Uo9y8sf2814wgULlGZ97gl3Kqbbi5x6UKW0E136P225g14ueliP >									
	//        <  u =="0.000000000000000001" : ] 000000278233365.681756000000000000 ; 000000298607037.208291000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A88CE91C7A360 >									
	//     < CHEMCHINA_PFII_II_metadata_line_16_____Daming_Changda_Co_Limited__LLBCHEM__20240321 >									
	//        < 1cc9JUF2b6ojMS8VCFKRi08fJwN80D8k19VN67fpUqsJccf798csAUT54duyCW9N >									
	//        <  u =="0.000000000000000001" : ] 000000298607037.208291000000000000 ; 000000321764806.629812000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C7A3601EAF961 >									
	//     < CHEMCHINA_PFII_II_metadata_line_17_____DATO_Chemicals_Co_Limited_20240321 >									
	//        < e3Ut06iPnWBgLh0iE6D2HJpF8VapiZmCN1cvowUsKA5FDoi86caA8qkwA5sTWkcH >									
	//        <  u =="0.000000000000000001" : ] 000000321764806.629812000000000000 ; 000000337817431.534664000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EAF96120377EF >									
	//     < CHEMCHINA_PFII_II_metadata_line_18_____DC_Chemicals_20240321 >									
	//        < hSFfNPcb57L2eTy391srIc01ytIo839vKypokE1KFcpeI25x1WWeUNeOqguP6SAd >									
	//        <  u =="0.000000000000000001" : ] 000000337817431.534664000000000000 ; 000000360333577.060211000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020377EF225D34E >									
	//     < CHEMCHINA_PFII_II_metadata_line_19_____Depont_Molecular_Co_Limited_20240321 >									
	//        < 7cO2EJqyRA5dsS7ICI5DhepsYVslXI3N20g0NULJ3F7TdR8L2aD26WtdMZ49lWHc >									
	//        <  u =="0.000000000000000001" : ] 000000360333577.060211000000000000 ; 000000376021365.408787000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000225D34E23DC359 >									
	//     < CHEMCHINA_PFII_II_metadata_line_20_____DSL_Chemicals_Co_Ltd_20240321 >									
	//        < L0EVG1Xj15GvVnNdkUAp5RY1p7X558GY6xw17EuoL244wik7iy95d1yDAqw6At06 >									
	//        <  u =="0.000000000000000001" : ] 000000376021365.408787000000000000 ; 000000398497757.408562000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023DC3592600F30 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFII_II_metadata_line_21_____Elsa_Biotechnology_org_20240321 >									
	//        < q532ap3L8o5DiRdsZ0qVB7cSrF7552QA7q8E6uleZeZ5PQv3PA69J8c489y8bJX2 >									
	//        <  u =="0.000000000000000001" : ] 000000398497757.408562000000000000 ; 000000415265965.295213000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002600F30279A545 >									
	//     < CHEMCHINA_PFII_II_metadata_line_22_____Elsa_Biotechnology_Co_Limited_20240321 >									
	//        < s98xSmR7w5y88MdDzUhLGS2muqyz02Cxu945Jp5500rsrn7amnXGkDZF6d31an85 >									
	//        <  u =="0.000000000000000001" : ] 000000415265965.295213000000000000 ; 000000438219135.673857000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000279A54529CAB5A >									
	//     < CHEMCHINA_PFII_II_metadata_line_23_____Enze_Chemicals_Co_Limited_20240321 >									
	//        < 5kMeaZc1a8F2guWCk4YYBb4ojz9Je45fb0nFEI91N4zO57G5i2DZ8kR7SF4X1C8i >									
	//        <  u =="0.000000000000000001" : ] 000000438219135.673857000000000000 ; 000000455466948.537387000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029CAB5A2B6FCC7 >									
	//     < CHEMCHINA_PFII_II_metadata_line_24_____EOS_Med_Chem_20240321 >									
	//        < L52PoeYnT8d4kg4ExAdX1de27oV6mFfFy42BNYsDz6h6SJ7g9r076wYdBOFaL1iV >									
	//        <  u =="0.000000000000000001" : ] 000000455466948.537387000000000000 ; 000000472131014.073948000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B6FCC72D06A2D >									
	//     < CHEMCHINA_PFII_II_metadata_line_25_____EOS_Med_Chem_20240321 >									
	//        < y6UjG7P0657f0dT4R19L3ov2Ar0g5v1Ss0v0JETqfc37TqJyg1pu25O2u3kK9DPZ >									
	//        <  u =="0.000000000000000001" : ] 000000472131014.073948000000000000 ; 000000489780057.973804000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D06A2D2EB5856 >									
	//     < CHEMCHINA_PFII_II_metadata_line_26_____ETA_ChemTech_Co_Ltd_20240321 >									
	//        < tZLU8B689BV3l5rgAA402d99f8rrFhsJ0lluDv9QD80DSC0YbDg7bII48Y9UG7w2 >									
	//        <  u =="0.000000000000000001" : ] 000000489780057.973804000000000000 ; 000000506051723.134855000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EB58563042C74 >									
	//     < CHEMCHINA_PFII_II_metadata_line_27_____FEIMING_CHEMICAL_LIMITED_20240321 >									
	//        < 79tO09m95wV5ZeYl5uqQZnu4mbHv9FY2wGNj0rFuVgiU5gCL6ao0UzIKt328GJPs >									
	//        <  u =="0.000000000000000001" : ] 000000506051723.134855000000000000 ; 000000524892481.573485000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003042C74320EC20 >									
	//     < CHEMCHINA_PFII_II_metadata_line_28_____FINETECH_INDUSTRY_LIMITED_20240321 >									
	//        < 257953Q2570QF8yRA0rxLi5s17LQ13k2n0Db55A355j2Lv36a5AhgN3tNCM20jRd >									
	//        <  u =="0.000000000000000001" : ] 000000524892481.573485000000000000 ; 000000543939709.610443000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000320EC2033DFC73 >									
	//     < CHEMCHINA_PFII_II_metadata_line_29_____Finetech_Industry_Limited_20240321 >									
	//        < P4458zOY2drp5Zh6tz6uvb25Bi0xboJ854SEZGFmx6M5K6h0Xi8VP1a3lKM3q2Gl >									
	//        <  u =="0.000000000000000001" : ] 000000543939709.610443000000000000 ; 000000563203655.086787000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033DFC7335B616E >									
	//     < CHEMCHINA_PFII_II_metadata_line_30_____Fluoropharm_org_20240321 >									
	//        < P5bA2yUIbozBPUp5pdHQRFcO1M17XZ4Vo8N7RVIq0Ik7Co8M5MqAgsS4bh9w2t88 >									
	//        <  u =="0.000000000000000001" : ] 000000563203655.086787000000000000 ; 000000578285089.958733000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035B616E372649D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFII_II_metadata_line_31_____Fluoropharm_Co_Limited_20240321 >									
	//        < Lh20y33iYHh1382x3quO5Ok6Akg3WEMOZ1om5LGsNmXpt2mtUw5Qh17sqaR601iR >									
	//        <  u =="0.000000000000000001" : ] 000000578285089.958733000000000000 ; 000000596354742.563248000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000372649D38DF712 >									
	//     < CHEMCHINA_PFII_II_metadata_line_32_____Fond_Chemical_Co_Limited_20240321 >									
	//        < 2FnJB0W1c8cysf1qww6K9D6z5060P1K1ylH8cXNA74pOG9aV0NIU6vK4DX9T56x0 >									
	//        <  u =="0.000000000000000001" : ] 000000596354742.563248000000000000 ; 000000613142676.397207000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038DF7123A794DC >									
	//     < CHEMCHINA_PFII_II_metadata_line_33_____Gansu_Research_Institute_of_Chemical_Industry_20240321 >									
	//        < 78E9CJvpH91OsY361sH8T0d3Ir54d5Aw68S2sbRy941a2k38Gud41TncfaVSn29d >									
	//        <  u =="0.000000000000000001" : ] 000000613142676.397207000000000000 ; 000000635817072.563856000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A794DC3CA2E0B >									
	//     < CHEMCHINA_PFII_II_metadata_line_34_____GL_Biochem__Shanghai__Ltd__20240321 >									
	//        < i72K6lyUhP5Gdd5dGYtATLQCpO7RJUXr6L36lX0hMkEV6P3fHAjO39K7JpvB6c6R >									
	//        <  u =="0.000000000000000001" : ] 000000635817072.563856000000000000 ; 000000657194818.473141000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003CA2E0B3EACCBA >									
	//     < CHEMCHINA_PFII_II_metadata_line_35_____Guangzhou_Topwork_Chemical_Co__Limited_20240321 >									
	//        < 002s1Mn9zcH6ps7eri93Jfq2gNpvoxZqqDv5BzCM2K267L8T6ht3YgF0kQKuB3pc >									
	//        <  u =="0.000000000000000001" : ] 000000657194818.473141000000000000 ; 000000676783312.338124000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003EACCBA408B07B >									
	//     < CHEMCHINA_PFII_II_metadata_line_36_____Hallochem_Pharma_Co_Limited_20240321 >									
	//        < if3XSBg3g156iY93a37p8GfSn0Y6B1xIAGAO2aSPi1SB1Ds0sFGOy58GRnNA9PdN >									
	//        <  u =="0.000000000000000001" : ] 000000676783312.338124000000000000 ; 000000696742121.826889000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000408B07B42724E4 >									
	//     < CHEMCHINA_PFII_II_metadata_line_37_____Hanghzou_Fly_Source_Chemical_Co_Limited_20240321 >									
	//        < 1Y5lWCG4LySRixPifG6942m6JwJUbH3z738x8g3PwCD7U0nBkQ0B726jh6e25zW3 >									
	//        <  u =="0.000000000000000001" : ] 000000696742121.826889000000000000 ; 000000712102762.457560000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042724E443E9524 >									
	//     < CHEMCHINA_PFII_II_metadata_line_38_____Hangzhou_Best_Chemicals_Co__Limited_20240321 >									
	//        < O73X8m8VIpbc2AP65dqRHpkqhrngrd5358mgS7o56UXrWF7viF7qZPNhT03rM117 >									
	//        <  u =="0.000000000000000001" : ] 000000712102762.457560000000000000 ; 000000730904021.346897000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000043E952445B4562 >									
	//     < CHEMCHINA_PFII_II_metadata_line_39_____Hangzhou_Dayangchem_Co__Limited_20240321 >									
	//        < aRsdDAi6s8UyD7Vn7ptU2p3NE7iM83SHrmElGwS122L8zf8sOoOxCBdKsn9MMQK4 >									
	//        <  u =="0.000000000000000001" : ] 000000730904021.346897000000000000 ; 000000749786919.657001000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000045B45624781584 >									
	//     < CHEMCHINA_PFII_II_metadata_line_40_____Hangzhou_Dayangchem_org_20240321 >									
	//        < qoGQ28QGrnKA96rid7Vm2U3ZGX7Ah26FEaIq504vdQq34O7mguNGj03e64VcgWVI >									
	//        <  u =="0.000000000000000001" : ] 000000749786919.657001000000000000 ; 000000766244968.597696000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000047815844913271 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}