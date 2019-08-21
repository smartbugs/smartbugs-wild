pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFV_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFV_II_883		"	;
		string	public		symbol =	"	NDRV_PFV_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1114989768359600000000000000					;	
										
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
	//     < NDRV_PFV_II_metadata_line_1_____talanx primary insurance group_20231101 >									
	//        < vdoYjpLXbayF3uMQOtENEJ4WV1sAc07zmFyeTjZ10MQrw15n7574jO42An46zAKd >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000020948061.312476700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001FF6D6 >									
	//     < NDRV_PFV_II_metadata_line_2_____primary_pensions_20231101 >									
	//        < Mm47Flct6YcR0UNmp2RLHA6mVu207r444u6htq15QJe72mIp6351gviM6asxvR6Z >									
	//        <  u =="0.000000000000000001" : ] 000000020948061.312476700000000000 ; 000000059200166.516078000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001FF6D65A5511 >									
	//     < NDRV_PFV_II_metadata_line_3_____hdi rechtsschutz ag_20231101 >									
	//        < 9TEWyLc76eks0fVj2Bvyiz0OAXh66ORcl23u14M3e18d7ee9qI43Sa1fd2RE84wz >									
	//        <  u =="0.000000000000000001" : ] 000000059200166.516078000000000000 ; 000000074793366.580154400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005A5511722029 >									
	//     < NDRV_PFV_II_metadata_line_4_____Gerling Insurance Of South Africa Ltd_20231101 >									
	//        < 5Sb82PzK82V8US891EzE8gFCi3M8wnwx91Zrd3NoMl4M7ycV2ghRKlFF6C9aV1g4 >									
	//        <  u =="0.000000000000000001" : ] 000000074793366.580154400000000000 ; 000000102604509.168562000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007220299C8FE3 >									
	//     < NDRV_PFV_II_metadata_line_5_____Gerling Global Life Sweden Reinsurance Co LTd_20231101 >									
	//        < m3zIX3Gady6eGCNqucnXgW3snw5a6SUEO9DPEC4xpA9cq32F44P1pARvXdX4Ybbt >									
	//        <  u =="0.000000000000000001" : ] 000000102604509.168562000000000000 ; 000000125824958.143192000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009C8FE3BFFE60 >									
	//     < NDRV_PFV_II_metadata_line_6_____Amtrust Corporate Member Ltd_20231101 >									
	//        < mH7fG4wbv2zctMvjSkk8VGAh86Bv9Qrnbt7IG2t84aTf69cyx5R761j162I4PJ9Z >									
	//        <  u =="0.000000000000000001" : ] 000000125824958.143192000000000000 ; 000000142528707.223323000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BFFE60D97B47 >									
	//     < NDRV_PFV_II_metadata_line_7_____HDI_Gerling Australia Insurance Company Pty Ltd_20231101 >									
	//        < 87A9HEW3Ufj276g9XZ2z5foSzAREGXAle3XgZn3cIk668mTxncn26YUMsdY4b5Ce >									
	//        <  u =="0.000000000000000001" : ] 000000142528707.223323000000000000 ; 000000164279285.877317000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D97B47FAAB99 >									
	//     < NDRV_PFV_II_metadata_line_8_____Gerling Institut GIBA_20231101 >									
	//        < 3MxjqiZac35ej3PRSMZSJs3Y4i5s1eE9H685yCl8q1J5ibf5Hqi53UC8Zl5uo5HI >									
	//        <  u =="0.000000000000000001" : ] 000000164279285.877317000000000000 ; 000000209988289.950637000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FAAB991406AAD >									
	//     < NDRV_PFV_II_metadata_line_9_____Gerling_org_20231101 >									
	//        < N3n7py26zGjakWyq6xQ563mZB59AN9AES5JFJ0pRDFpRJCL4FJR3T4DkTe0PQo60 >									
	//        <  u =="0.000000000000000001" : ] 000000209988289.950637000000000000 ; 000000230167683.342425000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001406AAD15F3540 >									
	//     < NDRV_PFV_II_metadata_line_10_____Gerling_Holdings_20231101 >									
	//        < DHGs6v56X78L3dF9I5DNeYP6vuvh4LXdykdVj8UsM5m45w24higWc5JyCAW8SvR8 >									
	//        <  u =="0.000000000000000001" : ] 000000230167683.342425000000000000 ; 000000251125694.899934000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015F354017F2FF9 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFV_II_metadata_line_11_____Gerling_Pensions_20231101 >									
	//        < Ws7rkYGMGyu8PfEL9B48Nb5G8E0i8EDr5a89doxDyC0700V5uUsFdqQMduNnuEee >									
	//        <  u =="0.000000000000000001" : ] 000000251125694.899934000000000000 ; 000000267296005.860823000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017F2FF9197DC81 >									
	//     < NDRV_PFV_II_metadata_line_12_____talanx international ag_20231101 >									
	//        < UzuZ1aFlyi95AU1F4c857mhQhavejG3lG5HA9YJ1JXb1281Rq1VEQ3t8SE42QmgM >									
	//        <  u =="0.000000000000000001" : ] 000000267296005.860823000000000000 ; 000000285904966.536895000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000197DC811B441A1 >									
	//     < NDRV_PFV_II_metadata_line_13_____tuir warta_20231101 >									
	//        < y297480cFlluLltQZW91nNGrewJVk06v0DpFBtBHVD8eZ4tx279uTJq1RrolnuZ3 >									
	//        <  u =="0.000000000000000001" : ] 000000285904966.536895000000000000 ; 000000313966972.415246000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B441A11DF1359 >									
	//     < NDRV_PFV_II_metadata_line_14_____tuir warta_org_20231101 >									
	//        < OC43fQIh2sjqJlXD0Ozhwg24Vs0DTxU6SSwRFPHxrY1LPg3El4B1zQmG5jYG1SNr >									
	//        <  u =="0.000000000000000001" : ] 000000313966972.415246000000000000 ; 000000350091854.437298000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DF135921632A1 >									
	//     < NDRV_PFV_II_metadata_line_15_____towarzystwo ubezpieczen na zycie warta sa_20231101 >									
	//        < 47d5A7HFtQJ91YCYWIbRarQKg5e7d6lZE6j9aTHg34InP6GtJ6NITjyQ1XsE5295 >									
	//        <  u =="0.000000000000000001" : ] 000000350091854.437298000000000000 ; 000000386811402.705246000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021632A124E3A34 >									
	//     < NDRV_PFV_II_metadata_line_16_____HDI-Gerling Zycie Towarzystwo Ubezpieczen Spolka Akcyjna_20231101 >									
	//        < dsh3B0405egoTc0DW3YRe68RUoiPWyh4G0qQHUu5jc215H5PZO9sLPv75uHUWG4k >									
	//        <  u =="0.000000000000000001" : ] 000000386811402.705246000000000000 ; 000000403682587.709865000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024E3A34267F883 >									
	//     < NDRV_PFV_II_metadata_line_17_____TUiR Warta SA Asset Management Arm_20231101 >									
	//        < XPHcD74vqZ0soYWHQ968ZM56Q0FTtvZa5Bq1jz7f8CoFJctw4JMy9zvxBPa1dA55 >									
	//        <  u =="0.000000000000000001" : ] 000000403682587.709865000000000000 ; 000000424318081.389608000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000267F8832877540 >									
	//     < NDRV_PFV_II_metadata_line_18_____HDI Seguros SA de CV_20231101 >									
	//        < Y1GdZxSrjpiAX0SyxH9VO3GjG1Q45SOAP9qHZgxpzE90qg0O5k0726IFIF35MziM >									
	//        <  u =="0.000000000000000001" : ] 000000424318081.389608000000000000 ; 000000474015292.211947000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028775402D34A39 >									
	//     < NDRV_PFV_II_metadata_line_19_____Towarzystwo Ubezpieczen Europa SA_20231101 >									
	//        < VhtR8V3B1U0R7iXo7QoM83hlQ4CQSBD24AwgVgYdkZ6DAxp0CPnnlG8OnS5aiNbB >									
	//        <  u =="0.000000000000000001" : ] 000000474015292.211947000000000000 ; 000000492700162.912772000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D34A392EFCD00 >									
	//     < NDRV_PFV_II_metadata_line_20_____Towarzystwo Ubezpieczen Na Zycie EUROPA SA_20231101 >									
	//        < fThKA48m4t2bHB600imQ7Mc97X84T849sTJ11HTgrynUk07G89at4j5SU83Xr42F >									
	//        <  u =="0.000000000000000001" : ] 000000492700162.912772000000000000 ; 000000529618313.571578000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EFCD003282227 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFV_II_metadata_line_21_____TU na ycie EUROPA SA_20231101 >									
	//        < y6y3u9tjnqP1s3s89JsUW7pXo20QT8a0nMbe87xOY655ek5kB02Ou81h6xilOW3T >									
	//        <  u =="0.000000000000000001" : ] 000000529618313.571578000000000000 ; 000000546981240.626908000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003282227342A08C >									
	//     < NDRV_PFV_II_metadata_line_22_____Liberty Sigorta_20231101 >									
	//        < DG7l5QkvK8kB6EpvOTe6h798NQ8L9nIi43Tg8PTkYC7lruoVT8MjlPmxNz93ima9 >									
	//        <  u =="0.000000000000000001" : ] 000000546981240.626908000000000000 ; 000000576918298.017996000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000342A08C3704EB6 >									
	//     < NDRV_PFV_II_metadata_line_23_____Aspecta Versicherung Ag_20231101 >									
	//        < TDaG11R07kK2BR3URf4BtNYt86i2oI7V9x9Jnx4wY3uAc91QP4JH2OO1LEm9Pf9L >									
	//        <  u =="0.000000000000000001" : ] 000000576918298.017996000000000000 ; 000000606134633.969438000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003704EB639CE357 >									
	//     < NDRV_PFV_II_metadata_line_24_____HDI Sigorta AS_20231101 >									
	//        < lN080Vcy3e4gvwW441oNvP638K8c5EXiIjhh0Rjhxbf2MlaLb3C1x4F7e0Vr9kW6 >									
	//        <  u =="0.000000000000000001" : ] 000000606134633.969438000000000000 ; 000000634356716.230158000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039CE3573C7F398 >									
	//     < NDRV_PFV_II_metadata_line_25_____HDI Seguros SA_20231101 >									
	//        < r155IA1EH6v46Q77705JOzg8yau2PFo5xLw8O6Ukntt9EwX9V0b7vMU8YF4T4dDt >									
	//        <  u =="0.000000000000000001" : ] 000000634356716.230158000000000000 ; 000000658330833.101963000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C7F3983EC887B >									
	//     < NDRV_PFV_II_metadata_line_26_____Aseguradora Magallanes SA_20231101 >									
	//        < e73B61m4Kix2Z09M04mSU9GGuU9FE9r864CJum8g7177nT749eWn6Cl1fRuAtphj >									
	//        <  u =="0.000000000000000001" : ] 000000658330833.101963000000000000 ; 000000684164319.174844000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003EC887B413F3B0 >									
	//     < NDRV_PFV_II_metadata_line_27_____Asset Management Arm_20231101 >									
	//        < 9JyN47g9oYJMB986W38673HukQ0304yw8g5whPXAStg5o6EM711tL7CM67g6266B >									
	//        <  u =="0.000000000000000001" : ] 000000684164319.174844000000000000 ; 000000715231861.864654000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000413F3B04435B72 >									
	//     < NDRV_PFV_II_metadata_line_28_____HDI Assicurazioni SpA_20231101 >									
	//        < tetWST36p063JmNaxU6fxx8BLh0c38uXj6jz3ZhbW5HQue0xtpNIhtX4N77B7LER >									
	//        <  u =="0.000000000000000001" : ] 000000715231861.864654000000000000 ; 000000755212740.093339000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004435B724805CFA >									
	//     < NDRV_PFV_II_metadata_line_29_____InChiaro Assicurazioni SPA_20231101 >									
	//        < F8Bht61bAUVw7JKuVViT7t4SMj8nSfrtriqJ84n8T6w3PbNjS73p32Kap94ZLBg9 >									
	//        <  u =="0.000000000000000001" : ] 000000755212740.093339000000000000 ; 000000788289407.529929000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004805CFA4B2D58D >									
	//     < NDRV_PFV_II_metadata_line_30_____Inlinea SpA_20231101 >									
	//        < q533RronIHH4670T7R58zDMenST2b97QOq6jajL7QiLy338GI2Bi9bSkloCU4KW7 >									
	//        <  u =="0.000000000000000001" : ] 000000788289407.529929000000000000 ; 000000824244239.145499000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B2D58D4E9B268 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFV_II_metadata_line_31_____Inversiones HDI Limitada_20231101 >									
	//        < o7MQlu623Sr0d26s4XmkZ1X7CBfcQ5C91izvUukDAC6CsL4C1mjQEntR7u302RVt >									
	//        <  u =="0.000000000000000001" : ] 000000824244239.145499000000000000 ; 000000853298998.848257000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004E9B26851607EC >									
	//     < NDRV_PFV_II_metadata_line_32_____HDI Seguros de Garantía y Crédito SA_20231101 >									
	//        < 796KS7tKjZ2ABYeoLw3p2w57qFCxR9ask6Q14C4Acr8C5S5OzP8T9fG4qJbVcqNO >									
	//        <  u =="0.000000000000000001" : ] 000000853298998.848257000000000000 ; 000000878805666.875389000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000051607EC53CF377 >									
	//     < NDRV_PFV_II_metadata_line_33_____HDI Seguros_20231101 >									
	//        < 46u5b7CIm8uR16zO01F1HO10FpAzd29q7200a8QjNt3DS15435HtkOCi77TWTGr7 >									
	//        <  u =="0.000000000000000001" : ] 000000878805666.875389000000000000 ; 000000917255267.386889000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000053CF3775779ED7 >									
	//     < NDRV_PFV_II_metadata_line_34_____HDI Seguros_Holdings_20231101 >									
	//        < 307ot8nKR8cbbewf6rcyI2iuFdkZLPqCQuHf6kYuxQg3Oq1TiB89vTWOZRUs4CuN >									
	//        <  u =="0.000000000000000001" : ] 000000917255267.386889000000000000 ; 000000946913084.583059000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005779ED75A4DFEC >									
	//     < NDRV_PFV_II_metadata_line_35_____Aseguradora Magallanes Peru SA Compania De Seguros_20231101 >									
	//        < O0wl4stqNVQ2i09lN2N5E8JHL35GbX83T0k4KS7woXa92SJ6uNbeaWvA52475Q1W >									
	//        <  u =="0.000000000000000001" : ] 000000946913084.583059000000000000 ; 000000983310744.132807000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005A4DFEC5DC69C2 >									
	//     < NDRV_PFV_II_metadata_line_36_____Saint Honoré Iberia SL_20231101 >									
	//        < yFKkSk95L3IL533IeQv8bt5e0NowygkeV5519l2c3sbe43v697SuR85w04p3T868 >									
	//        <  u =="0.000000000000000001" : ] 000000983310744.132807000000000000 ; 000001016340901.590070000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005DC69C260ED02A >									
	//     < NDRV_PFV_II_metadata_line_37_____HDI Seguros SA_20231101 >									
	//        < 49AJdyDbS43HclG1ItfYi03Z93C195z8o7mbL4444xycGy0I7C0x3Nvdd5Jw7nL1 >									
	//        <  u =="0.000000000000000001" : ] 000001016340901.590070000000000000 ; 000001036022704.955000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000060ED02A62CD85E >									
	//     < NDRV_PFV_II_metadata_line_38_____L_UNION de Paris Cia Uruguaya de Seguros SA_20231101 >									
	//        < KEIvOSZt98V9g5YZTY8KztGNnsgVoE8fLLNB2OPYXFH6YBGJv4o1F3Fh643LoA9l >									
	//        <  u =="0.000000000000000001" : ] 000001036022704.955000000000000000 ; 000001062401906.965110000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000062CD85E65518BF >									
	//     < NDRV_PFV_II_metadata_line_39_____L_UNION_org_20231101 >									
	//        < BitmKsuxsB0aGM7Zaw7qKlh3iXzmFAYMO228SV07j3TW151xKrVf9yJIw40Wao3M >									
	//        <  u =="0.000000000000000001" : ] 000001062401906.965110000000000000 ; 000001084369983.275350000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000065518BF6769E06 >									
	//     < NDRV_PFV_II_metadata_line_40_____Protecciones Esenciales SA_20231101 >									
	//        < 48SOGpG0946kLH8436HlBas2as8wlY6257nXtkZoAxQq5Nr68qps37Sdmnq6qVVq >									
	//        <  u =="0.000000000000000001" : ] 000001084369983.275350000000000000 ; 000001114989768.359600000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006769E066A556E1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}