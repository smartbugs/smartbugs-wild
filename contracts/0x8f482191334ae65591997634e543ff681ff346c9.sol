pragma solidity 		^0.4.21	;						
										
	contract	NDD_RBN_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDD_RBN_I_883		"	;
		string	public		symbol =	"	NDD_RBN_I_1subDT		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		3041512824964910000000000000					;	
										
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
	//     < NDD_RBN_I_metadata_line_1_____6938413225 Lab_x >									
	//        < 47y14zI4427oF3xfiXn1l6UO6YwIKbfx589WjL23w6251lKL5WDgh94jPWPTP63Z >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000000F4240 >									
	//     < NDD_RBN_I_metadata_line_2_____9781285179 Lab_y >									
	//        < Gad0guVSXm9V8GSv2H9X3807op54498cL3e0Q3f3cvCv7n2HO7rh1JSLN3FMd0aI >									
	//        <  u =="0.000000000000000001" : ] 000000010000000.000000000000000000 ; 000000020000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000F42401E8480 >									
	//     < NDD_RBN_I_metadata_line_3_____2350035723 Lab_100 >									
	//        < p3VsmgG8m4KKe608RdTGKNoS3e7IaJeSY94XkzwKqZ23E7z41LEoM5jpTrT1ImuY >									
	//        <  u =="0.000000000000000001" : ] 000000020000000.000000000000000000 ; 000000030597294.903190900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001E84802EB011 >									
	//     < NDD_RBN_I_metadata_line_4_____8345745311 Lab_110 >									
	//        < O3xjY3hn7moeUI7VkeIvIJ5f7XGzcIR84HL6V4R06K6BPIfc219PlI6Rz5PfNFxt >									
	//        <  u =="0.000000000000000001" : ] 000000030597294.903190900000000000 ; 000000041670599.423256800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002EB0113F9594 >									
	//     < NDD_RBN_I_metadata_line_5_____5159809609 Lab_410/401 >									
	//        < 6Dgl1vBgTk3RJA4Ayol1J24eb4F9742C4qvZbei30kPs7nSBkDbqB7NWkKECmSd0 >									
	//        <  u =="0.000000000000000001" : ] 000000041670599.423256800000000000 ; 000000055963817.503520000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003F95945564DE >									
	//     < NDD_RBN_I_metadata_line_6_____9881267411 Lab_810/801 >									
	//        < UgzC5Qn0a1tZ9IVJT35qxobSeurS0b5QaTF6DCe9W8W1A3kNywRx5T5GFNFRHPQ0 >									
	//        <  u =="0.000000000000000001" : ] 000000055963817.503520000000000000 ; 000000074550253.664046300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005564DE71C131 >									
	//     < NDD_RBN_I_metadata_line_7_____5159809609 Lab_410_3Y1Y >									
	//        < 3Jt6wABLyHzlPton7j1017l7rWG7LCfk8kx4Vhao778IaKxb5elwXZE68DAx1nU0 >									
	//        <  u =="0.000000000000000001" : ] 000000074550253.664046300000000000 ; 000000095349392.571026200000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000071C131917DDB >									
	//     < NDD_RBN_I_metadata_line_8_____9881267423 Lab_410_5Y1Y >									
	//        < 6p6vl88DBs6krcUrWx9V344I98C1p88A053PvRCegfBCALPiMhSawQ8a0Cx71Fv0 >									
	//        <  u =="0.000000000000000001" : ] 000000095349392.571026200000000000 ; 000000144385518.074832000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000917DDBDC5098 >									
	//     < NDD_RBN_I_metadata_line_9_____2323232323 Lab_410_7Y1Y >									
	//        < 3MhBl1UMc49w14IPxC0n6mA45wgx22611jqyAC0icr0zRnsNeUm0u774y2IqJ02S >									
	//        <  u =="0.000000000000000001" : ] 000000144385518.074832000000000000 ; 000000239053751.434656000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000DC509816CC45F >									
	//     < NDD_RBN_I_metadata_line_10_____2323232323 Lab_810_3Y1Y >									
	//        < Ny95xlRh4krv23yiq0dJDaNcqIg2pPF4oCX0k2Z9G07nw45C3p0dXnl9iN3zt7g3 >									
	//        <  u =="0.000000000000000001" : ] 000000239053751.434656000000000000 ; 000000280094485.218802000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016CC45F1AB63E9 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_RBN_I_metadata_line_11_____2331073380 Lab_810_5Y1Y >									
	//        < Bh35lm26cF1vDx89wKRfbM4fqE811LQVhgZRDz4KdKWvG3Y2LKOFdxA3U73x7TTj >									
	//        <  u =="0.000000000000000001" : ] 000000280094485.218802000000000000 ; 000000391061113.276626000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AB63E9254B63F >									
	//     < NDD_RBN_I_metadata_line_12_____2389358431 Lab_810_7Y1Y >									
	//        < a4hP1i7Qy27aLHAxj61YiYj48T7L2u34s3bMcK1925wuIwx38NVwOnG0BHV71KSd >									
	//        <  u =="0.000000000000000001" : ] 000000391061113.276626000000000000 ; 000001030989119.686490000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000254B63F6252A20 >									
	//     < NDD_RBN_I_metadata_line_13_____2323232323 ro_Lab_110_3Y_1.00 >									
	//        < oUhPLhDjjcEbsA10tG8Ab8uFY47G8NJ75mFIFu66wN6Qk20aSjoVJq0cfL8HPZ46 >									
	//        <  u =="0.000000000000000001" : ] 000001030989119.686490000000000000 ; 000001051022952.136200000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006252A20643BBD7 >									
	//     < NDD_RBN_I_metadata_line_14_____2323232323 ro_Lab_110_5Y_1.00 >									
	//        < Pn90SZ234eB9X87SMoS12j0V0SAPQph4XF55773Oc3bgAmn5S8px7FlLW2Ch54DD >									
	//        <  u =="0.000000000000000001" : ] 000001051022952.136200000000000000 ; 000001075138371.809730000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000643BBD766887ED >									
	//     < NDD_RBN_I_metadata_line_15_____2323232323 ro_Lab_110_5Y_1.10 >									
	//        < ahQAwB57r1ka2hzc2921bKbEa88EHhe3rRZQ257g7G482YNa8WNibUOy69cHYJBi >									
	//        <  u =="0.000000000000000001" : ] 000001075138371.809730000000000000 ; 000001100227446.068790000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000066887ED68ED059 >									
	//     < NDD_RBN_I_metadata_line_16_____2323232323 ro_Lab_110_7Y_1.00 >									
	//        < 9i71pXi78940Q6LTdoN23sDO1RA8a9g2m6oOt58zkd86L9zOXP62998UM8KepjIe >									
	//        <  u =="0.000000000000000001" : ] 000001100227446.068790000000000000 ; 000001127542977.468030000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000068ED0596B87E7A >									
	//     < NDD_RBN_I_metadata_line_17_____2323232323 ro_Lab_210_3Y_1.00 >									
	//        < 1PDtHhIE0612hS7b75CoSXJNRGT3is4AUgBk7R2eEganILSzgNji3L523ee53Fxh >									
	//        <  u =="0.000000000000000001" : ] 000001127542977.468030000000000000 ; 000001138729462.934390000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006B87E7A6C99032 >									
	//     < NDD_RBN_I_metadata_line_18_____2323232323 ro_Lab_210_5Y_1.00 >									
	//        < o2x5a34xgzlgt2q0K5o9eEDb4588yEf44WzJ3i8k9IrEC85j5NK7a0cR31iEdm6j >									
	//        <  u =="0.000000000000000001" : ] 000001138729462.934390000000000000 ; 000001152246770.416200000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006C990326DE3065 >									
	//     < NDD_RBN_I_metadata_line_19_____2323232323 ro_Lab_210_5Y_1.10 >									
	//        < XWKIJau9iZ9DoOkUzmiVHEkb4Hn68iemAwCBV6E6OfPtnMvWdb49EfIjZs9d1Xzq >									
	//        <  u =="0.000000000000000001" : ] 000001152246770.416200000000000000 ; 000001164895880.652980000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006DE30656F17D74 >									
	//     < NDD_RBN_I_metadata_line_20_____2323232323 ro_Lab_210_7Y_1.00 >									
	//        < Nc2thZSNgbx9zwCOs3S8Z8yK3Z0CqY4WO1V97e2oc9y0dria8Mja7YdnWA706s57 >									
	//        <  u =="0.000000000000000001" : ] 000001164895880.652980000000000000 ; 000001182469903.760730000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006F17D7470C4E4E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_RBN_I_metadata_line_21_____2386281206 ro_Lab_310_3Y_1.00 >									
	//        < 2Ey8Rr9D2nh1RyX43gNM0Nhe5rOnqTMJ9JO2HrlN2QRMZUekOoO8497jIX48b6RW >									
	//        <  u =="0.000000000000000001" : ] 000001182469903.760730000000000000 ; 000001193885422.881660000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000070C4E4E71DB97E >									
	//     < NDD_RBN_I_metadata_line_22_____2334594893 ro_Lab_310_5Y_1.00 >									
	//        < kUyGA9pVZh6gEawn3hg81u3hhoh80Lu24m5F25J3GVL54pEtgcr3cJepK5bse437 >									
	//        <  u =="0.000000000000000001" : ] 000001193885422.881660000000000000 ; 000001209012737.912780000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000071DB97E734CE9A >									
	//     < NDD_RBN_I_metadata_line_23_____2346942038 ro_Lab_310_5Y_1.10 >									
	//        < I3943w0AUJtmrK67b3sViTvC3WWmr0i4DcwaJ961b5L1rWGkj3JgYxSkh79z2xHF >									
	//        <  u =="0.000000000000000001" : ] 000001209012737.912780000000000000 ; 000001222419739.240140000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000734CE9A74943B6 >									
	//     < NDD_RBN_I_metadata_line_24_____2323232323 ro_Lab_310_7Y_1.00 >									
	//        < p1K3K1Hz8a42JbSzK9NO6Z1hJnrV24JylA743762h4fPwz1f2qk015qb4g0Wo851 >									
	//        <  u =="0.000000000000000001" : ] 000001222419739.240140000000000000 ; 000001245278500.250360000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000074943B676C24EA >									
	//     < NDD_RBN_I_metadata_line_25_____2323232323 ro_Lab_410_3Y_1.00 >									
	//        < wh93W2ftK2i1ZX5N6IwQj07uhEN34sJby8Ka10oLi49FdTf8uRw7NE8NqmTj60TB >									
	//        <  u =="0.000000000000000001" : ] 000001245278500.250360000000000000 ; 000001256950654.647550000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000076C24EA77DF459 >									
	//     < NDD_RBN_I_metadata_line_26_____2323232323 ro_Lab_410_5Y_1.00 >									
	//        < EFosO821kye53em98I5OXY7QMD2J97MpOn34iMj2M2ax5Xyd7rPXjZ6m541C82X8 >									
	//        <  u =="0.000000000000000001" : ] 000001256950654.647550000000000000 ; 000001274223821.418950000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000077DF4597984FAE >									
	//     < NDD_RBN_I_metadata_line_27_____2323232323 ro_Lab_410_5Y_1.10 >									
	//        < 9j1C1daATa9oDl5ABVyy0WpmiGf3qGkd6Dv7NP5HM7y4TnG8HOGw3W1j435eNWX6 >									
	//        <  u =="0.000000000000000001" : ] 000001274223821.418950000000000000 ; 000001288643070.889690000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007984FAE7AE5033 >									
	//     < NDD_RBN_I_metadata_line_28_____2323232323 ro_Lab_410_7Y_1.00 >									
	//        < mP7UQ6w3b6K55LFyZ1S34O984874mN2b9v3sq244cLEGT2V0RHZly0n6GYj5Mb4C >									
	//        <  u =="0.000000000000000001" : ] 000001288643070.889690000000000000 ; 000001319627613.048570000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007AE50337DD9789 >									
	//     < NDD_RBN_I_metadata_line_29_____2323232323 ro_Lab_810_3Y_1.00 >									
	//        < 6vf04UcC0e20lnpE5Amh4k7wAUOK9eh8Soy1J0EWvJ3328t16Nc6BtIecz76Ep93 >									
	//        <  u =="0.000000000000000001" : ] 000001319627613.048570000000000000 ; 000001332919433.368200000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007DD97897F1DFA7 >									
	//     < NDD_RBN_I_metadata_line_30_____2323232323 ro_Lab_810_5Y_1.00 >									
	//        < Xl389XDnkuzC4o2GNPPGkylRr1kK6F9YfQP2G6yBMAd4FMYcL97201IYqQ44ntaN >									
	//        <  u =="0.000000000000000001" : ] 000001332919433.368200000000000000 ; 000001359215711.270230000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007F1DFA7819FFA3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_RBN_I_metadata_line_31_____2323232323 ro_Lab_810_5Y_1.10 >									
	//        < eooRdKi1kfUu160PC85mE08N8E57g52p8898e5X35veLPKX4quEBai13PQ58io9L >									
	//        <  u =="0.000000000000000001" : ] 000001359215711.270230000000000000 ; 000001377908121.627770000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000819FFA3836855C >									
	//     < NDD_RBN_I_metadata_line_32_____2323232323 ro_Lab_810_7Y_1.00 >									
	//        < dzR8GZ0LX2102bKv6iovTg52EpaHD5196m3VNM7RMKTFsp12Tj764g8lceC260dU >									
	//        <  u =="0.000000000000000001" : ] 000001377908121.627770000000000000 ; 000001523594939.736270000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000836855C914D246 >									
	//     < NDD_RBN_I_metadata_line_33_____2323232323 ro_Lab_411_3Y_1.00 >									
	//        < 7Am39vz6D7i749250L9yXh5jQ512Jl81i80eKuYd256wyaa43370wVRzQPsFP0Q1 >									
	//        <  u =="0.000000000000000001" : ] 000001523594939.736270000000000000 ; 000001536740458.762310000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000914D246928E13E >									
	//     < NDD_RBN_I_metadata_line_34_____2323232323 ro_Lab_411_5Y_1.00 >									
	//        < M40yM0EcX59D50VQ866SKPNU8KBH83mKu4ucjVy8spa30BYG6351cN1076IYfkx0 >									
	//        <  u =="0.000000000000000001" : ] 000001536740458.762310000000000000 ; 000001570535929.621240000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000928E13E95C7299 >									
	//     < NDD_RBN_I_metadata_line_35_____2323232323 ro_Lab_411_5Y_1.10 >									
	//        < L413n2x8PRv1V2Pvum5qqV45EBxw9DY9G5mX4hNHt2cpHPfbQMFcjPAa2u1wHDVY >									
	//        <  u =="0.000000000000000001" : ] 000001570535929.621240000000000000 ; 000001592791271.265270000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000095C729997E6817 >									
	//     < NDD_RBN_I_metadata_line_36_____2323232323 ro_Lab_411_7Y_1.00 >									
	//        < mXK9uBWx3IOpv4elhvUK3ltAC26ROYhhipXmzyBysQAqL9K8a1Cw7bduAevm1LV6 >									
	//        <  u =="0.000000000000000001" : ] 000001592791271.265270000000000000 ; 000001730414513.330030000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000097E6817A50672B >									
	//     < NDD_RBN_I_metadata_line_37_____2323232323 ro_Lab_811_3Y_1.00 >									
	//        < 5086ccfBtLZ66Qy0LHaf5dqMc66CPcYkR70481Z8C2ztXmbrnbdq353Qa82VjacX >									
	//        <  u =="0.000000000000000001" : ] 000001730414513.330030000000000000 ; 000001747501379.883250000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A50672BA6A79BA >									
	//     < NDD_RBN_I_metadata_line_38_____2323232323 ro_Lab_811_5Y_1.00 >									
	//        < 45KHBOzj40fu3iw98i422CHye9toJ9GOpTMItcVb1N422b3oL9L36182Tn462349 >									
	//        <  u =="0.000000000000000001" : ] 000001747501379.883250000000000000 ; 000001855343907.809810000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A6A79BAB0F07B7 >									
	//     < NDD_RBN_I_metadata_line_39_____2323232323 ro_Lab_811_5Y_1.10 >									
	//        < tBAHsGKK7Nos8nlH3sE4ac9hSy6P9uU89Qp17anY30p6ZwhktArt5s7ulFVBckH0 >									
	//        <  u =="0.000000000000000001" : ] 000001855343907.809810000000000000 ; 000001912883548.749300000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000B0F07B7B66D423 >									
	//     < NDD_RBN_I_metadata_line_40_____2323232323 ro_Lab_811_7Y_1.00 >									
	//        < r2DA7Po4002d3439W3X951ighZ5J6999PI9i7553453uWXwOZx6TXUW9ubfVP3b8 >									
	//        <  u =="0.000000000000000001" : ] 000001912883548.749300000000000000 ; 000003041512824.964910000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000B66D4231220FAF2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}