pragma solidity 		^0.4.25	;						
										
	contract	CHEMCHINA_PFI_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	CHEMCHINA_PFI_II_883		"	;
		string	public		symbol =	"	CHEMCHINA_PFI_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		776042573866005000000000000					;	
										
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
	//     < CHEMCHINA_PFI_II_metadata_line_1_____001Chemical_20240321 >									
	//        < 77D4H96OKTYVU801VFFYy2j6Nb7a3rT5IG2Bi5MWRZDh081sy1CYp9GCP5Qz9IYJ >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000017787298.482249200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001B242A >									
	//     < CHEMCHINA_PFI_II_metadata_line_2_____3B_Scientific__Wuhan__Corporation_Limited_20240321 >									
	//        < QH8T4D89xia4X82Xr3K01bexK6LbsHMtZB5W28678fBF1t5t62ucqW2ASpf75pdz >									
	//        <  u =="0.000000000000000001" : ] 000000017787298.482249200000000000 ; 000000039588242.991193400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001B242A3C6828 >									
	//     < CHEMCHINA_PFI_II_metadata_line_3_____3Way_Pharm_inc__20240321 >									
	//        < 296fCDt906E5u6q5I94sWSy38EnCtz95A38on7J0H5oaH363n0y0jefhDgU637q9 >									
	//        <  u =="0.000000000000000001" : ] 000000039588242.991193400000000000 ; 000000062663702.508600400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003C68285F9E02 >									
	//     < CHEMCHINA_PFI_II_metadata_line_4_____Acemay_Biochemicals_20240321 >									
	//        < 154W6q89X5nq003IgHdpVQmEpeD430MAlIy7Xu48g55CynOK2HofxiuxyU74Mm7z >									
	//        <  u =="0.000000000000000001" : ] 000000062663702.508600400000000000 ; 000000087323683.331561800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005F9E02853ED0 >									
	//     < CHEMCHINA_PFI_II_metadata_line_5_____Aemon_Chemical_Technology_Co_Limited_20240321 >									
	//        < v8Uw5V3ggwjaCCzC4bpmwPeR5W45L4V11VxPuBOX287243P47mu95yv7T6Rmyazi >									
	//        <  u =="0.000000000000000001" : ] 000000087323683.331561800000000000 ; 000000106681321.576833000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000853ED0A2C864 >									
	//     < CHEMCHINA_PFI_II_metadata_line_6_____AgileBioChem_Co_Limited_20240321 >									
	//        < zBqBKX16k0gj14PPPm0gzWn3H67Lz020oh7Y4992XfS1atZrN4WBTc77tBWs1l4T >									
	//        <  u =="0.000000000000000001" : ] 000000106681321.576833000000000000 ; 000000131371157.781113000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A2C864C874DC >									
	//     < CHEMCHINA_PFI_II_metadata_line_7_____Aktin_Chemicals,_inc__20240321 >									
	//        < RVeB91FFhJ5d3HT0zJ0d3V96Z5Lw31b6hvsPx0p4uE26S95H80dAwZY9Rwr33ZpZ >									
	//        <  u =="0.000000000000000001" : ] 000000131371157.781113000000000000 ; 000000147274166.713922000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C874DCE0B8F9 >									
	//     < CHEMCHINA_PFI_II_metadata_line_8_____Aktin_Chemicals,_org_20240321 >									
	//        < 04qXT35MSDAS7aL40QIX735N24V9ooAG8uoi5BLICD0iByRYFePZwCyiNCekBE2X >									
	//        <  u =="0.000000000000000001" : ] 000000147274166.713922000000000000 ; 000000164261289.772290000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E0B8F9FAA491 >									
	//     < CHEMCHINA_PFI_II_metadata_line_9_____Angene_International_Limited_20240321 >									
	//        < qUO3f7rve8YEBvEOC79vNmReaLXd919ervKnO8Zc02Bk7QXD0KwAHH85X4aG2K97 >									
	//        <  u =="0.000000000000000001" : ] 000000164261289.772290000000000000 ; 000000188883952.408209000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FAA49112036CB >									
	//     < CHEMCHINA_PFI_II_metadata_line_10_____ANSHAN_HIFI_CHEMICALS_Co__Limited_20240321 >									
	//        < rOm6KH4vbRp6i4En4aPesblV17ARal1c5wcLDc3c7KYkOff0RJdzg8Q001csEO34 >									
	//        <  u =="0.000000000000000001" : ] 000000188883952.408209000000000000 ; 000000203931865.293463000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012036CB1372CE3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFI_II_metadata_line_11_____Aromalake_Chemical_Corporation_Limited_20240321 >									
	//        < Aa1G7cR4M6gbbJ1TjXifb2fjPuEXC5y6C6Ip4MEPgA4qi0Y8NWAv6c0ulYd707R1 >									
	//        <  u =="0.000000000000000001" : ] 000000203931865.293463000000000000 ; 000000220931218.918753000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001372CE31511D42 >									
	//     < CHEMCHINA_PFI_II_metadata_line_12_____Aromsyn_Co_Limited_20240321 >									
	//        < 3ILle0BKSCdsb8yODzs62h9qETMWxh7b1F247owcY480Yoba9v0b6i10y6SzLJP7 >									
	//        <  u =="0.000000000000000001" : ] 000000220931218.918753000000000000 ; 000000241776358.803609000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001511D42170EBE4 >									
	//     < CHEMCHINA_PFI_II_metadata_line_13_____Arromax_Pharmatech_Co__Limited_20240321 >									
	//        < DIUirhDV4Ntj4m4x19dd3LzL5GB9W0X1uWNttcJ6K3fdi1i01qsk1N351eWS897U >									
	//        <  u =="0.000000000000000001" : ] 000000241776358.803609000000000000 ; 000000260419073.291749000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000170EBE418D5E33 >									
	//     < CHEMCHINA_PFI_II_metadata_line_14_____Asambly_Chemicals_Co_Limited_20240321 >									
	//        < 3izT1jvHAd4MgEHp25QF8M5Vq054UqHQL2NGFGj8xhaR111vW5xr5Q657XyX45xg >									
	//        <  u =="0.000000000000000001" : ] 000000260419073.291749000000000000 ; 000000275746866.383811000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018D5E331A4C19F >									
	//     < CHEMCHINA_PFI_II_metadata_line_15_____Atomax_Chemicals_Co__Limited_20240321 >									
	//        < UUL769SjJ9yPmYwAa6zmIfEqA0C7bOQ59BHb958MK7Twdp5KCf363faoWNJTVw2G >									
	//        <  u =="0.000000000000000001" : ] 000000275746866.383811000000000000 ; 000000293101698.661451000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A4C19F1BF3CDA >									
	//     < CHEMCHINA_PFI_II_metadata_line_16_____Atomax_Chemicals_org_20240321 >									
	//        < Lm8tK4dtvB9t82TYDd035RpeuexxGkZPV2KuKSYbmpg0p9Ii9kjEyk9AVN129fc0 >									
	//        <  u =="0.000000000000000001" : ] 000000293101698.661451000000000000 ; 000000308476089.516944000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BF3CDA1D6B279 >									
	//     < CHEMCHINA_PFI_II_metadata_line_17_____Beijing_Pure_Chem__Co_Limited_20240321 >									
	//        < kz9Zi4F4s1CtE0T3sKd7350fwvyCSo47i69PKA16Yh6Ec4TbIBWLNsF750W7bne6 >									
	//        <  u =="0.000000000000000001" : ] 000000308476089.516944000000000000 ; 000000328366732.825269000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D6B2791F50C41 >									
	//     < CHEMCHINA_PFI_II_metadata_line_18_____BEIJING_SHLHT_CHEMICAL_TECHNOLOGY_20240321 >									
	//        < Tq7Dj5ymuP6nPHILvLgN3I9ccVa471cpG6OpuzLR422N5LS4z0k70t2LSS21kYb0 >									
	//        <  u =="0.000000000000000001" : ] 000000328366732.825269000000000000 ; 000000343996682.068568000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F50C4120CE5B4 >									
	//     < CHEMCHINA_PFI_II_metadata_line_19_____Beijing_Smart_Chemicals_Co_Limited_20240321 >									
	//        < 5F2Awa8L0Xoz34xXON1IiTsgZ0nN1qb2C9RkUhMK41YLR5Cyut1UjKKvfEh7Cnz1 >									
	//        <  u =="0.000000000000000001" : ] 000000343996682.068568000000000000 ; 000000361151699.341443000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020CE5B422712E2 >									
	//     < CHEMCHINA_PFI_II_metadata_line_20_____Beijing_Stable_Chemical_Co_Limited_20240321 >									
	//        < gzCvQ7l6R1S9ntG3lNJ0679N01yk4toli687E2igxYc5srkp949N5BGkBBXpvWS4 >									
	//        <  u =="0.000000000000000001" : ] 000000361151699.341443000000000000 ; 000000380727506.026307000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022712E2244F1AF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFI_II_metadata_line_21_____Beijing_Sunpu_Biochem___Tech__Co__Limited_20240321 >									
	//        < 1iV4480kEd9SCfEF8U6um35I9We28ZZ0kn7L2c3GNn2lkxD929669eNnljw4wX6T >									
	//        <  u =="0.000000000000000001" : ] 000000380727506.026307000000000000 ; 000000396088163.573415000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000244F1AF25C61F0 >									
	//     < CHEMCHINA_PFI_II_metadata_line_22_____Bellen_Chemistry_Co__Limited_20240321 >									
	//        < Y98L6Yk7s8ZDHo9ZnYeny5flLEDj9ll04on1BH1O8HoKO0YMF19Dpj1cBMJ33Yc3 >									
	//        <  u =="0.000000000000000001" : ] 000000396088163.573415000000000000 ; 000000411976343.595722000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025C61F0274A042 >									
	//     < CHEMCHINA_PFI_II_metadata_line_23_____BEYO_CHEMICAL_Co__Limited_20240321 >									
	//        < 79y9A30C3xdCBnfjna51OG89p1RP2VDLcEcL1xO3RjhM5dv6AUpBPYTqImhGxCRx >									
	//        <  u =="0.000000000000000001" : ] 000000411976343.595722000000000000 ; 000000433031313.443965000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000274A042294C0DB >									
	//     < CHEMCHINA_PFI_II_metadata_line_24_____Beyond_Pharmaceutical_Co_Limited_20240321 >									
	//        < tAjLWlEggegIupL5VlXu1zhp10AO8pOhHs4llJ0rT0bIb670Rmz357pe839KA1Fa >									
	//        <  u =="0.000000000000000001" : ] 000000433031313.443965000000000000 ; 000000454630857.476907000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000294C0DB2B5B62E >									
	//     < CHEMCHINA_PFI_II_metadata_line_25_____Binhai_Gaolou_Chemical_Co_Limited_20240321 >									
	//        < 48T2wD0Vkev2c2wclZgU9TDE81053C31Uj6xK6ROwQS0f2Ty38MKa76E3BrFHs31 >									
	//        <  u =="0.000000000000000001" : ] 000000454630857.476907000000000000 ; 000000479172909.258922000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B5B62E2DB28EB >									
	//     < CHEMCHINA_PFI_II_metadata_line_26_____Binhong_Industry_Co__Limited_20240321 >									
	//        < OnnzFI8qzXHhL04RNwueO4v4X5o19O3o0k8LRbdSrkVrixG6A6re1X67aSN8Ih3t >									
	//        <  u =="0.000000000000000001" : ] 000000479172909.258922000000000000 ; 000000501197717.034730000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DB28EB2FCC45C >									
	//     < CHEMCHINA_PFI_II_metadata_line_27_____BLD_Pharmatech_org_20240321 >									
	//        < E4VTpNSKNC5jOXoJ4CT5p6na3jb4722QE7gmEz52IO321GOMwaBeK0Dl0iaUWC2E >									
	//        <  u =="0.000000000000000001" : ] 000000501197717.034730000000000000 ; 000000519035646.159058000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FCC45C317FC4D >									
	//     < CHEMCHINA_PFI_II_metadata_line_28_____BLD_Pharmatech_Limited_20240321 >									
	//        < pdwWY8Z4m7b3Z5qTvkYJcP1z2QG0y4k7YBd5b60uDjKJl867xHmgTyIGUadeuSs2 >									
	//        <  u =="0.000000000000000001" : ] 000000519035646.159058000000000000 ; 000000538863012.281188000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000317FC4D3363D5D >									
	//     < CHEMCHINA_PFI_II_metadata_line_29_____Bocchem_20240321 >									
	//        < b47VIQos0qBljdZz6sZ10oty2tJeQo466kW35Z6w4dGic4HG5AOc08V3J5bDtB0c >									
	//        <  u =="0.000000000000000001" : ] 000000538863012.281188000000000000 ; 000000554804938.977869000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003363D5D34E90AE >									
	//     < CHEMCHINA_PFI_II_metadata_line_30_____Boroncore_LLC_20240321 >									
	//        < J4EX7kLK964s5758wr6MTE03175409sSKCO0a0UlVL4KuKPcV5P4d21oGWDByk4D >									
	//        <  u =="0.000000000000000001" : ] 000000554804938.977869000000000000 ; 000000572119886.416164000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034E90AE368FC55 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFI_II_metadata_line_31_____BTC_Pharmaceuticals_Co_Limited_20240321 >									
	//        < F5E9fNCjq0jy65ITgYG29eIgqbRXwAk0f5pC7P974ECH800f9DH7v6uaY1Wi0pNK >									
	//        <  u =="0.000000000000000001" : ] 000000572119886.416164000000000000 ; 000000591577235.609597000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000368FC55386ACDC >									
	//     < CHEMCHINA_PFI_II_metadata_line_32_____Cangzhou_Goldlion_Chemicals_Co_Limited_20240321 >									
	//        < EKH2VERJ6N5GOq9MBlF3P4Rtl9RnVz217SL74Is92Od4t29hYxl0105w2yj1b8Ap >									
	//        <  u =="0.000000000000000001" : ] 000000591577235.609597000000000000 ; 000000609490609.411813000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000386ACDC3A20245 >									
	//     < CHEMCHINA_PFI_II_metadata_line_33_____Capot_Chemical_Co_Limited_20240321 >									
	//        < 8DqDCKpFXO21Sg3HG8x6A9310Oq24nYpZ17unnhn80D90wEv38aEb0Jm9M7q12w3 >									
	//        <  u =="0.000000000000000001" : ] 000000609490609.411813000000000000 ; 000000633817221.619603000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A202453C720DA >									
	//     < CHEMCHINA_PFI_II_metadata_line_34_____CBS_TECHNOLOGY_LTD_20240321 >									
	//        < 9U5Bj5Z53lw5TH09Co2WrUMPCgC9P437UG8VF1x2dpkWm323Q4iyNqBCIjs59440 >									
	//        <  u =="0.000000000000000001" : ] 000000633817221.619603000000000000 ; 000000655828586.298937000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C720DA3E8B70B >									
	//     < CHEMCHINA_PFI_II_metadata_line_35_____Changzhou_Carbochem_Co_Limited_20240321 >									
	//        < 0fs7p8xc0iPIW5x135s1NlKy4SAQ7Px4qS61K6Vo1AQODFG58hj77t0D3J9fCfZx >									
	//        <  u =="0.000000000000000001" : ] 000000655828586.298937000000000000 ; 000000672683939.685669000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E8B70B4026F2A >									
	//     < CHEMCHINA_PFI_II_metadata_line_36_____Changzhou_Hengda_Biotechnology_Co__org_20240321 >									
	//        < pc1r95enM8kA6w4Y3WFj71EyTz1caWz60v1y47Jh85zBMgyBJh0M4j336ZJFNk8D >									
	//        <  u =="0.000000000000000001" : ] 000000672683939.685669000000000000 ; 000000696226259.012877000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004026F2A4265B62 >									
	//     < CHEMCHINA_PFI_II_metadata_line_37_____Changzhou_Hengda_Biotechnology_Co__Limited_20240321 >									
	//        < 7qPJbeplbzSLO29ocwbP0OTAFhJ9r0NR1gNnJ24caKZJ0mC8g9jN9k0lC0492b31 >									
	//        <  u =="0.000000000000000001" : ] 000000696226259.012877000000000000 ; 000000718747177.130707000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004265B62448B89E >									
	//     < CHEMCHINA_PFI_II_metadata_line_38_____Changzhou_LanXu_Chemical_Co_Limited_20240321 >									
	//        < jwTiGeUQTd9T9Lnvqfqvn3OrfIPQ1zcZfIqR539sBYh8rc388Cy7M75g5JC5fj2m >									
	//        <  u =="0.000000000000000001" : ] 000000718747177.130707000000000000 ; 000000737285968.994078000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000448B89E4650255 >									
	//     < CHEMCHINA_PFI_II_metadata_line_39_____Changzhou_Standard_Chemicals_Co_Limited_20240321 >									
	//        < uIZ0Rh0C7UGZvP14JPQU8kHF059Hrs6oQ276zLzBiMr2y72PC3L74m0yI8altDcL >									
	//        <  u =="0.000000000000000001" : ] 000000737285968.994078000000000000 ; 000000757840354.032104000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046502554845F63 >									
	//     < CHEMCHINA_PFI_II_metadata_line_40_____CHANGZHOU_WEIJIA_CHEMICAL_Co_Limited_20240321 >									
	//        < Uj0rj3pJWh6PnfgPSzzCNp05Y16f4HnMs64Bx3nmZeQ90m7EXR8ILH3Gt05TT8Rp >									
	//        <  u =="0.000000000000000001" : ] 000000757840354.032104000000000000 ; 000000776042573.866005000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004845F634A025A1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}