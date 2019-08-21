pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXVIII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXVIII_III_883		"	;
		string	public		symbol =	"	RUSS_PFXXXVIII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1014443586386180000000000000					;	
										
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
	//     < RUSS_PFXXXVIII_III_metadata_line_1_____AgroCenter_Ukraine_20251101 >									
	//        < R6403QLaG18Pg9fN8E7l0lgGC2is2TzXPwE4fbS3DKi2A6c07M1L504vf974DdjX >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000018300232.307800600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001BEC87 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_2_____Ural_RemStroiService_20251101 >									
	//        < knrm36d58yzmNOsVRb1Sun2C0JjYVoJiD810ndD004JE5686PXn8gshE10Q63P37 >									
	//        <  u =="0.000000000000000001" : ] 000000018300232.307800600000000000 ; 000000040770878.452519100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001BEC873E3620 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_3_____Kingisepp_RemStroiService_20251101 >									
	//        < 7BuhML4O3CbB9V0961e3E57rKUR21WxVqXSd53p26Yk9B6vX7bs4DX3t4KfnwQVL >									
	//        <  u =="0.000000000000000001" : ] 000000040770878.452519100000000000 ; 000000064037634.604005600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003E362061B6B3 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_4_____Novomoskovsk_RemStroiService_20251101 >									
	//        < HTofWBPG1Vhk6TE48clUCu5Nd3265Ec0Z0Ay4dUgoj4Rx3Q2RwsT2e994FBG14B3 >									
	//        <  u =="0.000000000000000001" : ] 000000064037634.604005600000000000 ; 000000084669819.457299500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000061B6B3813226 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_5_____Nevinnomyssk_RemStroiService_20251101 >									
	//        < 7EfF8hGg0qS8ETFDo7N46HRYQ5f48H7EBrnoIOE6Q8ydV4E13D6W70QVxV74p7G1 >									
	//        <  u =="0.000000000000000001" : ] 000000084669819.457299500000000000 ; 000000103394247.572648000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008132269DC461 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_6_____Volgograd_RemStroiService_20251101 >									
	//        < 2SrL7I6iNYQa3cd3ud63HxoLY9aMFIxVyq42v0rR300h96d6tNzsR1v8c3EA91ei >									
	//        <  u =="0.000000000000000001" : ] 000000103394247.572648000000000000 ; 000000126533589.611217000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009DC461C1132F >									
	//     < RUSS_PFXXXVIII_III_metadata_line_7_____Berezniki_Mechanical_Works_20251101 >									
	//        < 7w6l0EgTq53E4b2K8im3RN9E10XL6PruEREAe4Y20m68E8DFb23Yb1BW4iYcpAXd >									
	//        <  u =="0.000000000000000001" : ] 000000126533589.611217000000000000 ; 000000150559320.642654000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C1132FE5BC3C >									
	//     < RUSS_PFXXXVIII_III_metadata_line_8_____Tulagiprochim_JSC_20251101 >									
	//        < Lariy7GzG9F66K50kOzDiH72s2b2bWZ3qO4hF4bh9TYrbacez0X3yph2133RI3OC >									
	//        <  u =="0.000000000000000001" : ] 000000150559320.642654000000000000 ; 000000180904225.300376000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E5BC3C11409B7 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_9_____TOMS_project_LLC_20251101 >									
	//        < d9N44HBP4NPa1Mb572dZ52iZWn183WVFX7yTFrB265RgGvx8UnnJu728l49Tn45q >									
	//        <  u =="0.000000000000000001" : ] 000000180904225.300376000000000000 ; 000000200845044.501444000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011409B71327718 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_10_____Harvester_Shipmanagement_Ltd_20251101 >									
	//        < vecb0Q2yKL7xDle72f120TbBwCKghC34RwyJsj4gQkTIE2J1r48kPOC60hn24TXK >									
	//        <  u =="0.000000000000000001" : ] 000000200845044.501444000000000000 ; 000000224611548.925615000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001327718156BAE3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVIII_III_metadata_line_11_____EuroChem_Logistics_International_20251101 >									
	//        < pq4f43O17DF93NZgAvdr4K5G5Mh4VMTJbvgz9us3q94zCa2C4Iyr18Ng3sC7zmFo >									
	//        <  u =="0.000000000000000001" : ] 000000224611548.925615000000000000 ; 000000246192473.077246000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000156BAE3177A8EF >									
	//     < RUSS_PFXXXVIII_III_metadata_line_12_____EuroChem_Terminal_Sillamäe_Aktsiaselts_Logistics_20251101 >									
	//        < zNohBDY5uv9550uo92PYh1pN11g1zS2ArCpmKKz113WDBg5SaxFv7cn8I8A2Jy3N >									
	//        <  u =="0.000000000000000001" : ] 000000246192473.077246000000000000 ; 000000266021804.203665000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000177A8EF195EAC4 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_13_____EuroChem_Terminal_Ust_Luga_20251101 >									
	//        < ESu3Mt6l8i08N6oMO31L8J5y063O1W2OYONj0if4D8bkCD4gIZ7Sp3Jvfl258B7Q >									
	//        <  u =="0.000000000000000001" : ] 000000266021804.203665000000000000 ; 000000297708283.938315000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000195EAC41C6444C >									
	//     < RUSS_PFXXXVIII_III_metadata_line_14_____Tuapse_Bulk_Terminal_20251101 >									
	//        < V3cE6j6Kaen3uO9ukCe882Sh2NS0MIH544VCwRMZ49nTn0FcM409EWi2e1RS0vdH >									
	//        <  u =="0.000000000000000001" : ] 000000297708283.938315000000000000 ; 000000325978724.885702000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C6444C1F16770 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_15_____Murmansk_Bulkcargo_Terminal_20251101 >									
	//        < 9f0Zy5O6EV3BVTRJgEjT06e6yFtrmmP1MELVKWSXPD506euEs7kV60tDw04xSnk3 >									
	//        <  u =="0.000000000000000001" : ] 000000325978724.885702000000000000 ; 000000356078392.149240000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F1677021F551F >									
	//     < RUSS_PFXXXVIII_III_metadata_line_16_____Depo_EuroChem_20251101 >									
	//        < HTOQfzK67gPeuj9J87mOXLY32p8L5l13oIHR1W61643no9LJZwtywB8JnVH234DJ >									
	//        <  u =="0.000000000000000001" : ] 000000356078392.149240000000000000 ; 000000387326734.641449000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021F551F24F0381 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_17_____EuroChem_Energo_20251101 >									
	//        < AQT06TpF7LsG6Yy272I9ueIQ5T3S6D5Ah4fWExw1I5Iq32fx76RB4LOu0I3630sp >									
	//        <  u =="0.000000000000000001" : ] 000000387326734.641449000000000000 ; 000000407476893.915111000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024F038126DC2A9 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_18_____EuroChem_Usolsky_Mining_sarl_20251101 >									
	//        < 5ThwXsCVhko655950SIX227497OuT4GKSQ2taAkM0w94b3QWFWLmYu864OI3zDwz >									
	//        <  u =="0.000000000000000001" : ] 000000407476893.915111000000000000 ; 000000434122886.677578000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026DC2A92966B41 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_19_____EuroChem_International_Holding_BV_20251101 >									
	//        < OYJRW45DRWpa0W5VN4JOWQpbNxj58t3FOwT3IKEA3E1g08sdkMU9c093O9dhaAIS >									
	//        <  u =="0.000000000000000001" : ] 000000434122886.677578000000000000 ; 000000465362413.890661000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002966B412C61631 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_20_____Severneft_Urengoy_LLC_20251101 >									
	//        < RQcX69IKyupUAdkwRDH7Qqc1ncancsKLgI8DtXk3mNlBU0pMh2zKAPbDw28t1C96 >									
	//        <  u =="0.000000000000000001" : ] 000000465362413.890661000000000000 ; 000000486714440.193668000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C616312E6AAD4 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVIII_III_metadata_line_21_____Agrinos_AS_20251101 >									
	//        < 96s8Wdk00J77Ii8r4nemM54E2tL1e3odugkVU8ENT6cRt521KwoxbMS6nEK72ijS >									
	//        <  u =="0.000000000000000001" : ] 000000486714440.193668000000000000 ; 000000507803957.278543000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E6AAD4306D8EC >									
	//     < RUSS_PFXXXVIII_III_metadata_line_22_____Hispalense_de_Líquidos_SL_20251101 >									
	//        < ABLaZlj7JSEtxGk7iWWeT29Rw7q2a0kglVMAKCnY14X1ep7y7e27H522wjzeu5xN >									
	//        <  u =="0.000000000000000001" : ] 000000507803957.278543000000000000 ; 000000537944504.918649000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000306D8EC334D692 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_23_____Azottech_LLC_20251101 >									
	//        < hIpovdtvA2BL4HLrLq0P82D8X3GEEnVI7hPvE4PiHEE7UhJ258hzE7o6pA1j0Tll >									
	//        <  u =="0.000000000000000001" : ] 000000537944504.918649000000000000 ; 000000563705935.176902000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000334D69235C25A2 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_24_____EuroChem_Migao_Ltd_20251101 >									
	//        < sDI1eYV2LELHO6ceQQj73LSyk2HAsfHQ1PJYe607n1Kio2odUH3Rbk2nxdkcR4b7 >									
	//        <  u =="0.000000000000000001" : ] 000000563705935.176902000000000000 ; 000000590221539.208861000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035C25A23849B4A >									
	//     < RUSS_PFXXXVIII_III_metadata_line_25_____Thyssen_Schachtbau_EuroChem_Drilling_20251101 >									
	//        < 97DCicY3XZI66CqOLb8Hx5a3VGNds1J6N57KBlFlO292a45Dh5pEoBC9Q2QPf28o >									
	//        <  u =="0.000000000000000001" : ] 000000590221539.208861000000000000 ; 000000625414043.963730000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003849B4A3BA4E5C >									
	//     < RUSS_PFXXXVIII_III_metadata_line_26_____Biochem_Technologies_LLC_20251101 >									
	//        < 0NYvuM15ePwOS4dicl7277TaN2VV954bIG1gSMe8n9d54KlM5qay9wM4nsDfkvVi >									
	//        <  u =="0.000000000000000001" : ] 000000625414043.963730000000000000 ; 000000654959339.870036000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003BA4E5C3E7637E >									
	//     < RUSS_PFXXXVIII_III_metadata_line_27_____EuroChem_Agro_Bulgaria_Ead_20251101 >									
	//        < A9kaWZm26vBB8O3ly71fRQ2P2dK8U7KFLEMuSTautEO3q6N5K6zli61LjDK9bb8p >									
	//        <  u =="0.000000000000000001" : ] 000000654959339.870036000000000000 ; 000000680129595.797486000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E7637E40DCBA0 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_28_____Emerger_Fertilizantes_SA_20251101 >									
	//        < 044730y7f7QB9Yr9gjPz7H4vkqmnwk8vNKx3J7CufT58yZFNGAF145m6eObBsBv1 >									
	//        <  u =="0.000000000000000001" : ] 000000680129595.797486000000000000 ; 000000700610223.923581000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040DCBA042D0BDE >									
	//     < RUSS_PFXXXVIII_III_metadata_line_29_____Agrocenter_EuroChem_Srl_20251101 >									
	//        < Wd3pc7JV4Tff586g9cxIX486ue3V8K803J8r86c430O5ST9BJEDuHBJJLt5j20a0 >									
	//        <  u =="0.000000000000000001" : ] 000000700610223.923581000000000000 ; 000000730480790.601615000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042D0BDE45AA00F >									
	//     < RUSS_PFXXXVIII_III_metadata_line_30_____AgroCenter_Ukraine_LLC_20251101 >									
	//        < r7GU1iNm37ulRQTafum1va5qAFbrGl5J1nA8hC4yOjDB1erK9lW6tIV7oi07Wo8G >									
	//        <  u =="0.000000000000000001" : ] 000000730480790.601615000000000000 ; 000000750288038.997981000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000045AA00F478D944 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVIII_III_metadata_line_31_____EuroChem_Agro_doo_Beograd_20251101 >									
	//        < yk3Z9c0uE11989b0N5sX3Sw7TEC3sMb2b2R95rIt6LpP3K6B9SCZGXjyJ5igXQuP >									
	//        <  u =="0.000000000000000001" : ] 000000750288038.997981000000000000 ; 000000769276320.972471000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000478D944495D290 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_32_____TOMS_project_LLC_20251101 >									
	//        < OOyPf55b9WcGSA5kvZwj94vlKoaw4ag26isw2O5Ev0O4gqn85033d8Sg1GD16VrO >									
	//        <  u =="0.000000000000000001" : ] 000000769276320.972471000000000000 ; 000000797285250.690125000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000495D2904C08F8D >									
	//     < RUSS_PFXXXVIII_III_metadata_line_33_____Agrosphere_20251101 >									
	//        < 039T69eBk6wOwWb55WDkcNe4Pk8FXZyT090Z5qxYiY38mD59F6377veBURm77bSO >									
	//        <  u =="0.000000000000000001" : ] 000000797285250.690125000000000000 ; 000000826778882.019355000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004C08F8D4ED9080 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_34_____Bulkcargo_Terminal_LLC_20251101 >									
	//        < 2ycGFKab1A25eC7fh69i6j2oheYDM3sydD9511Mq6aXnoM7lEOnUz0rux2xZC1e8 >									
	//        <  u =="0.000000000000000001" : ] 000000826778882.019355000000000000 ; 000000846550314.792749000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004ED908050BBBB7 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_35_____AgroCenter_EuroChem_Volgograd_20251101 >									
	//        < 2e3bY2E93nCuny8l8B09xiA7Tk5c7tO15CpW0M6J4Eirar1lwF663Yt4JRB3P3kf >									
	//        <  u =="0.000000000000000001" : ] 000000846550314.792749000000000000 ; 000000878539452.688056000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000050BBBB753C8B79 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_36_____Trading_RUS_LLC_20251101 >									
	//        < 9tp6j5bX49z8J17pK5051j72ra857Z6qB90RZQWEV0KIYtxaE3t3MdMHBp6iK9qr >									
	//        <  u =="0.000000000000000001" : ] 000000878539452.688056000000000000 ; 000000897811629.288034000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000053C8B79559F3AB >									
	//     < RUSS_PFXXXVIII_III_metadata_line_37_____AgroCenter_EuroChem_Krasnodar_LLC_20251101 >									
	//        < lP94Sm1IQvpA4Uehi0clPhqI2eo277DiEa6GMfVXeNKjJ9f5Mam4NBdw8IonHE72 >									
	//        <  u =="0.000000000000000001" : ] 000000897811629.288034000000000000 ; 000000926813515.165664000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000559F3AB5863488 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_38_____AgroCenter_EuroChem_Lipetsk_LLC_20251101 >									
	//        < 6sR9LaVa27u66D3t86Co4IjwWfH0I6tz4OmKC4UEIb91bf2elc3c52dQLKQm5uRT >									
	//        <  u =="0.000000000000000001" : ] 000000926813515.165664000000000000 ; 000000954487608.394134000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000058634885B06EB9 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_39_____AgroCenter_EuroChem_Orel_LLC_20251101 >									
	//        < VohwMlF5ug4A48018NsyWrxsoIQ1bZx5uZ5TUD973Y691N8iSwss3tw5YKLzcOWT >									
	//        <  u =="0.000000000000000001" : ] 000000954487608.394134000000000000 ; 000000979759897.953180000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005B06EB95D6FEB6 >									
	//     < RUSS_PFXXXVIII_III_metadata_line_40_____AgroCenter_EuroChem_Nevinnomyssk_LLC_20251101 >									
	//        < cCzJ6124hppD4yv8O9y3mCs3dpcLv75TZdFo4hS04pUqD3803926t3I4Iv85A7Rr >									
	//        <  u =="0.000000000000000001" : ] 000000979759897.953180000000000000 ; 000001014443586.386180000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005D6FEB660BEB07 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}