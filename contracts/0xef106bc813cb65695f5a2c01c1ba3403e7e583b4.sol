pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXVII_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXVII_I_883		"	;
		string	public		symbol =	"	RUSS_PFXXXVII_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		595075367869688000000000000					;	
										
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
	//     < RUSS_PFXXXVII_I_metadata_line_1_____ROSNEFTTRANS_20211101 >									
	//        < 0lH1xkvCSoZDduukLc1Ma8Z69dQlKg7xxpjws4pSgQq9SbxNgTMx4XmS0OvMp5h7 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000016163496.464750700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000018A9DE >									
	//     < RUSS_PFXXXVII_I_metadata_line_2_____ROSNEFT_MARINE_UK_LIMITED_20211101 >									
	//        < Sq80wf4u74lfj91Ngy80flvPUMaw2FHSzDrpbv7B1c0udu7SUXxNeWS771hI24v4 >									
	//        <  u =="0.000000000000000001" : ] 000000016163496.464750700000000000 ; 000000031480446.612094500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000018A9DE30090D >									
	//     < RUSS_PFXXXVII_I_metadata_line_3_____MARINE_ORG_20211101 >									
	//        < xb0bx05ycvz5V9DTo5Wv7683tVP6BW98dYD48381095A1309gxtgfH71dzzyd5ip >									
	//        <  u =="0.000000000000000001" : ] 000000031480446.612094500000000000 ; 000000046222057.151928700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000030090D46877E >									
	//     < RUSS_PFXXXVII_I_metadata_line_4_____ORENBURGNEFT_ORG_20211101 >									
	//        < GC15727qKmA2btC8EE76K7Jq4yIE1goB5xfk1evMq56ufbW64dKCQ4W1irkcDOdF >									
	//        <  u =="0.000000000000000001" : ] 000000046222057.151928700000000000 ; 000000059755438.592576800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000046877E5B2DF8 >									
	//     < RUSS_PFXXXVII_I_metadata_line_5_____ORENBURGNEFT_EUR_20211101 >									
	//        < S1mLay7cgq8Vrfec2zvXV5zvSfT3DgL1J9ov8019lMG4tzJgrI69UUDT7oyH550t >									
	//        <  u =="0.000000000000000001" : ] 000000059755438.592576800000000000 ; 000000075950619.775771200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005B2DF873E436 >									
	//     < RUSS_PFXXXVII_I_metadata_line_6_____KUIBYSHEV_ORG_20211101 >									
	//        < 9Xue4nizbM43WOT4F561F9QqUJobsS13qA22O5Efdc4x2x46NLzFyFqB63jh4FJm >									
	//        <  u =="0.000000000000000001" : ] 000000075950619.775771200000000000 ; 000000090455389.172484900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000073E4368A0623 >									
	//     < RUSS_PFXXXVII_I_metadata_line_7_____SAMARA_ORG_20211101 >									
	//        < 59T960FGryZGFYhUEt4aBX7KNe5NJS4Xt6EkJ6TL16kR273gacWKuueU7MrJ8nY6 >									
	//        <  u =="0.000000000000000001" : ] 000000090455389.172484900000000000 ; 000000104535604.657039000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008A06239F8238 >									
	//     < RUSS_PFXXXVII_I_metadata_line_8_____SARATOV_ORG_20211101 >									
	//        < Hj2F2ES1f864g442QbXJURc313wRi1g4gtXuH07Jj4LD47h807cUqDY2tZF3F2aA >									
	//        <  u =="0.000000000000000001" : ] 000000104535604.657039000000000000 ; 000000118088186.023106000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009F8238B43033 >									
	//     < RUSS_PFXXXVII_I_metadata_line_9_____RYAZAN_ORG_20211101 >									
	//        < dw9fZ7FGXBm85b3sAbS3bZSO89885e8gnMrbU3R72b0I1aBMyumK9243849tbesX >									
	//        <  u =="0.000000000000000001" : ] 000000118088186.023106000000000000 ; 000000132172964.038568000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B43033C9AE10 >									
	//     < RUSS_PFXXXVII_I_metadata_line_10_____NYAGAN_ORG_20211101 >									
	//        < tPJMV23W69VW2gL8hS5o6462M8n7IsgVruGa7U38SAP81x4EbW5FpydoWCo420oM >									
	//        <  u =="0.000000000000000001" : ] 000000132172964.038568000000000000 ; 000000147078839.970549000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C9AE10E06CAC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVII_I_metadata_line_11_____ROSNEFT_MONGOLIA_20211101 >									
	//        < kE9ArQ4oYGdTK0waq51jbUVytS2BhFj13gYRaH35t7OtS2W16EO32j4v2846wIJB >									
	//        <  u =="0.000000000000000001" : ] 000000147078839.970549000000000000 ; 000000160192571.540937000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E06CACF46F39 >									
	//     < RUSS_PFXXXVII_I_metadata_line_12_____ORENBURGNEFT_20211101 >									
	//        < tCuQLIlJfS6uTaP2HqD1YP7ouLeswrCT3g48xg8Xb7TcMOuQ16Y7oQxsxmqmm5VY >									
	//        <  u =="0.000000000000000001" : ] 000000160192571.540937000000000000 ; 000000175049187.426563000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F46F3910B1A97 >									
	//     < RUSS_PFXXXVII_I_metadata_line_13_____KAMTCHATKA_HOLDING_BV_20211101 >									
	//        < UAii1Qzt96Hc725oY1H9BW4FMbqtUqbQzNwxbPpMrXhfYb9Bf75gkICGy0i2KwH1 >									
	//        <  u =="0.000000000000000001" : ] 000000175049187.426563000000000000 ; 000000188406229.822660000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010B1A9711F7C2F >									
	//     < RUSS_PFXXXVII_I_metadata_line_14_____ROSNEFT_SHELL_CASPIAN_VENTURES_LIMITED_20211101 >									
	//        < 951nqWVC48oh653g0XRq6c6X1NQA7iTT27oI1H5Ih5XdsS2Z8hsGqmrb2di3s0O8 >									
	//        <  u =="0.000000000000000001" : ] 000000188406229.822660000000000000 ; 000000203793679.451881000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011F7C2F136F6E8 >									
	//     < RUSS_PFXXXVII_I_metadata_line_15_____KUIBYSHEV_REFINERY_20211101 >									
	//        < 3PX1vMc5tDV9OG7f61Z5eJZ74eFrhhX21nW08dKON103DRd5a6Id1VK9frira1En >									
	//        <  u =="0.000000000000000001" : ] 000000203793679.451881000000000000 ; 000000219187569.192180000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000136F6E814E7425 >									
	//     < RUSS_PFXXXVII_I_metadata_line_16_____SAMARA_TERMINAL_LLC_20211101 >									
	//        < r941p6008m6FTsLM3NIs1hNROYXo3768SDxj1d2Os9AFwT7MXERZJ11BU087MzdM >									
	//        <  u =="0.000000000000000001" : ] 000000219187569.192180000000000000 ; 000000236460700.438485000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014E7425168CF76 >									
	//     < RUSS_PFXXXVII_I_metadata_line_17_____ROSNEFT_FINANCE_SA_20211101 >									
	//        < BZ61GHDhap8Uy338SJGznFI626oCO9eSu4pqL68CU347u6HWTecOJZh9RKd8MMm3 >									
	//        <  u =="0.000000000000000001" : ] 000000236460700.438485000000000000 ; 000000253358681.471893000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000168CF76182983C >									
	//     < RUSS_PFXXXVII_I_metadata_line_18_____YUKOS_MOSKVA_20211101 >									
	//        < oV1I9y7VQ43rH7XLH91xppXOmVB5yq3zGW0DMw678kB7WavMLx860ac95NfK79Wi >									
	//        <  u =="0.000000000000000001" : ] 000000253358681.471893000000000000 ; 000000269858952.482212000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000182983C19BC5A7 >									
	//     < RUSS_PFXXXVII_I_metadata_line_19_____RN_SEVERNAYA_NEFT_20211101 >									
	//        < 6d4kCcgnDN5eSjs8EBu2nySlZx7mAFyp77OAy64RrwJxn43Q5v772d31xBJjw3f5 >									
	//        <  u =="0.000000000000000001" : ] 000000269858952.482212000000000000 ; 000000286881468.028823000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019BC5A71B5BF13 >									
	//     < RUSS_PFXXXVII_I_metadata_line_20_____KARACHAEVO_CHERKESSKNEFTPRODUKT_20211101 >									
	//        < 642N1b45qpho6rfuUiDMqMF4CX0RxmHC2N5kw2hz7tjdtp6S131QzkU4t15qpdKk >									
	//        <  u =="0.000000000000000001" : ] 000000286881468.028823000000000000 ; 000000304035538.731783000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B5BF131CFEBE2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVII_I_metadata_line_21_____RN_BURENIE_LLC_20211101 >									
	//        < FNl2bWXMmYr69JC44a8wVgePR5J34oJdn177Qos358JBIo347eRi1s8N243XSoJ4 >									
	//        <  u =="0.000000000000000001" : ] 000000304035538.731783000000000000 ; 000000317391358.613007000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CFEBE21E44D00 >									
	//     < RUSS_PFXXXVII_I_metadata_line_22_____RN_MOSKVA_20211101 >									
	//        < z90v8W536AYs029E97UxtBXRo0v7U4jCk82nD61nB0MDHqy798Qy13e1AFBZNAPz >									
	//        <  u =="0.000000000000000001" : ] 000000317391358.613007000000000000 ; 000000332293965.659880000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E44D001FB0A55 >									
	//     < RUSS_PFXXXVII_I_metadata_line_23_____BASHNEFT_AB_20211101 >									
	//        < D6rhKyWy0eBO2vtH83z036b45HcKLeC84BpCiLbC41pJjIf3ZCc62i3O665LCz42 >									
	//        <  u =="0.000000000000000001" : ] 000000332293965.659880000000000000 ; 000000347759248.147023000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FB0A55212A375 >									
	//     < RUSS_PFXXXVII_I_metadata_line_24_____TNK_BP_AB_20211101 >									
	//        < 4vV64S3I1NkwmD3Uppbfmv775961Rj7q6rg5w87m5kEd2O0Vf3Mrr58GsLe8wykh >									
	//        <  u =="0.000000000000000001" : ] 000000347759248.147023000000000000 ; 000000361842273.023912000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000212A37522820A3 >									
	//     < RUSS_PFXXXVII_I_metadata_line_25_____IOUGANSKNEFTEGAS_20211101 >									
	//        < Ept8hS0rVIlK7g00J9MPYaonDAWPCcYhM7w1Y6D3XzB1546504kk90noyGBa4Li9 >									
	//        <  u =="0.000000000000000001" : ] 000000361842273.023912000000000000 ; 000000376928080.807661000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022820A323F2588 >									
	//     < RUSS_PFXXXVII_I_metadata_line_26_____RUSS_REGIONAL_DEV_BANK_20211101 >									
	//        < 5xDty5RYsy61d28398LwoJMvi0D5dR120pSL5llp9yizthkrou06w9rup679r1Q7 >									
	//        <  u =="0.000000000000000001" : ] 000000376928080.807661000000000000 ; 000000390095109.883561000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023F25882533CE7 >									
	//     < RUSS_PFXXXVII_I_metadata_line_27_____ANGARSK_PETROCHEM_CO_20211101 >									
	//        < 6302vGbD77v5606N0DGF84QR0FwAJ2ZXClLrD0DD7z83wEaU71e79N77XzT82O9v >									
	//        <  u =="0.000000000000000001" : ] 000000390095109.883561000000000000 ; 000000406838626.010697000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002533CE726CC957 >									
	//     < RUSS_PFXXXVII_I_metadata_line_28_____TNK_NYAGAN_20211101 >									
	//        < 13130108JaoKe4oevZl9Y6mKgzsu0TGuH639oUAXpCEJcyluon345umHIf4Ub8go >									
	//        <  u =="0.000000000000000001" : ] 000000406838626.010697000000000000 ; 000000423321580.113557000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026CC957285EFFE >									
	//     < RUSS_PFXXXVII_I_metadata_line_29_____VERKHNECHONSKNEFTEGAZ_20211101 >									
	//        < j6657W80CTUllB76y9Cdh95ka3V0y89i4VP98tNtDOqP1AyRCtrW697CN49cOh8F >									
	//        <  u =="0.000000000000000001" : ] 000000423321580.113557000000000000 ; 000000436444068.449377000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000285EFFE299F5F7 >									
	//     < RUSS_PFXXXVII_I_metadata_line_30_____VANKORNEFT_20211101 >									
	//        < 50KtnBfUGkXn3tJgUaFTLaJ9R18Grts0v77wMfbe3oRXFq33C0i48UK817Fhuk6V >									
	//        <  u =="0.000000000000000001" : ] 000000436444068.449377000000000000 ; 000000451378321.659633000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000299F5F72B0BFA8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVII_I_metadata_line_31_____ROSNEFT_TRADING_SA_20211101 >									
	//        < gCoxWV99rQ9DI47VPDHZ08mP581O5X3GDlRIX7f5CPEOy2qwY8i7B9ILcivU3Lu4 >									
	//        <  u =="0.000000000000000001" : ] 000000451378321.659633000000000000 ; 000000464541588.921535000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B0BFA82C4D58F >									
	//     < RUSS_PFXXXVII_I_metadata_line_32_____ROSNEFT_VIETNAM_BV_20211101 >									
	//        < 662iDEPGC2duOA4U87CLZF5P309oz784iLR35bP56HB2y0i5f1KMC74H1038J3g0 >									
	//        <  u =="0.000000000000000001" : ] 000000464541588.921535000000000000 ; 000000478660526.157889000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C4D58F2DA60C5 >									
	//     < RUSS_PFXXXVII_I_metadata_line_33_____SARATOV_OIL_REFINERY_20211101 >									
	//        < bS6v9ArIC2aG9c16vc7G5a9on4fpMZ1kD3EGpwJoA40dUn5i2pl1y4uEe5Yn9687 >									
	//        <  u =="0.000000000000000001" : ] 000000478660526.157889000000000000 ; 000000493955000.218293000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DA60C52F1B72C >									
	//     < RUSS_PFXXXVII_I_metadata_line_34_____ITERA_LATVIJA_20211101 >									
	//        < 6E4v0TsGFwmfCSCK76f2GOcl45l02jzbC0f8ZfeQpf598TV55lMxJr52VB5g9Lfs >									
	//        <  u =="0.000000000000000001" : ] 000000493955000.218293000000000000 ; 000000507499619.807930000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F1B72C306620A >									
	//     < RUSS_PFXXXVII_I_metadata_line_35_____EP_ITDA_20211101 >									
	//        < FC5uJWY1jR5wzSSYU8Rlg66IX8ICmdJFlXTO5i8qkj24Q816KQ272xsJDdS8RIXA >									
	//        <  u =="0.000000000000000001" : ] 000000507499619.807930000000000000 ; 000000522195475.798355000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000306620A31CCE9C >									
	//     < RUSS_PFXXXVII_I_metadata_line_36_____RYAZAN_OIL_REFINERY_20211101 >									
	//        < 4PT5Ytg5T10BzGA07xXAY2lSyAce6aSg50NBSIw6U3M29d7zkh57nWg9UeBL3Zbz >									
	//        <  u =="0.000000000000000001" : ] 000000522195475.798355000000000000 ; 000000535703506.245221000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031CCE9C3316B2F >									
	//     < RUSS_PFXXXVII_I_metadata_line_37_____RN_PURNEFTEGAZ_20211101 >									
	//        < CaboLIld7px1S0p6vAQCwvH4G7jo159z363ySu4gj7Qbos2Olem8f6SDdS8o83KI >									
	//        <  u =="0.000000000000000001" : ] 000000535703506.245221000000000000 ; 000000552967741.313886000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003316B2F34BC306 >									
	//     < RUSS_PFXXXVII_I_metadata_line_38_____NOVY_INVESTMENTS_LIMITED_20211101 >									
	//        < My9T34WKx3F05x9oM2ylZ0Z7lHk8sCWpJzI7as9Ir7HhYl6ic28ujIp2NqJ48g62 >									
	//        <  u =="0.000000000000000001" : ] 000000552967741.313886000000000000 ; 000000566474740.198014000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034BC3063605F32 >									
	//     < RUSS_PFXXXVII_I_metadata_line_39_____ROSNEFT_STS_20211101 >									
	//        < 46r7PTP13EV1o7JsAPGKQ33h298I3JQ4camasgh0y5bt4t4e3c4SQRLwV6cuoB8X >									
	//        <  u =="0.000000000000000001" : ] 000000566474740.198014000000000000 ; 000000581920781.143311000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003605F32377F0CE >									
	//     < RUSS_PFXXXVII_I_metadata_line_40_____ROSNEFT_INT_HOLDINGS_LIMITED_20211101 >									
	//        < 1a9OEUl1kHZ6kG9Y4G6nS4TVwqoS180957Zsd1e32g0OIESPJrwJKyd04pV4DsNf >									
	//        <  u =="0.000000000000000001" : ] 000000581920781.143311000000000000 ; 000000595075367.869688000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000377F0CE38C0351 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}