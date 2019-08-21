pragma solidity 		^0.4.21	;						
										
	contract	NBI_PFI_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NBI_PFI_I_883		"	;
		string	public		symbol =	"	NBI_PFI_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		591279523524168000000000000					;	
										
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
	//     < NBI_PFI_I_metadata_line_1_____CHINA_RAILWAY_CORPORATION_20211101 >									
	//        < sgn8sV6wVlFlbARd32n8qxx7oya8X3ZYu548Rq678vk16k4L3c2sGUj1PR5fY411 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000014919340.115987100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000016C3DE >									
	//     < NBI_PFI_I_metadata_line_2_____MoRWPRoC_AB_20211101 >									
	//        < KbWoeD7z0Rt832m9ehx4j619L7Rva19FmuoTKTYuPH04f2ScNY7VK822t21br8CO >									
	//        <  u =="0.000000000000000001" : ] 000000014919340.115987100000000000 ; 000000029724843.127615700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000016C3DE2D5B44 >									
	//     < NBI_PFI_I_metadata_line_3_____MoToPRoC_20211101 >									
	//        < 3gY3rUHG9GmUxd464O5303j6SciDiQ1B672V6d43xlUU78s6i55XyDs9K8qRws7T >									
	//        <  u =="0.000000000000000001" : ] 000000029724843.127615700000000000 ; 000000044647447.915210300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002D5B44442069 >									
	//     < NBI_PFI_I_metadata_line_4_____MoFoPRoC_20211101 >									
	//        < O34i85o1v677FfayF4Ut9RHorRJ73F42Kkq06nELKwgR0ucOV7ULCiv5J5LeQv98 >									
	//        <  u =="0.000000000000000001" : ] 000000044647447.915210300000000000 ; 000000058057435.129725100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004420695896B0 >									
	//     < NBI_PFI_I_metadata_line_5_____CAE_PRoC_20211101 >									
	//        < Wn70AhG5Y1tuB04v579kU3CF16dcOuyF7U6tzlq2F5LUJy3u6Ey41UcD4eiW9d9n >									
	//        <  u =="0.000000000000000001" : ] 000000058057435.129725100000000000 ; 000000071945391.404253700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005896B06DC7AB >									
	//     < NBI_PFI_I_metadata_line_6_____PBoC_20211101 >									
	//        < wHy45aRHWmBH908o5LfN705OvVeq31p1V3776Ra27CP6v47plj20dLVvGUhppbp4 >									
	//        <  u =="0.000000000000000001" : ] 000000071945391.404253700000000000 ; 000000086556918.714937700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006DC7AB84134C >									
	//     < NBI_PFI_I_metadata_line_7_____PRoC_20211101 >									
	//        < xg2IGLxjd1xWc2c3Oq2RYyw5Llu6rlEYUoDIqZed7raU1009hG71Ui1yWieH5dIN >									
	//        <  u =="0.000000000000000001" : ] 000000086556918.714937700000000000 ; 000000099616560.189851800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000084134C9800B8 >									
	//     < NBI_PFI_I_metadata_line_8_____guangzhou_railway_group_20211101 >									
	//        < Nj3jdmB0dfh3nvz82aR3UyqaMQ5HIDeLw9r4yZvhkFZT5324ElSj889JVo9vC35t >									
	//        <  u =="0.000000000000000001" : ] 000000099616560.189851800000000000 ; 000000114880004.528106000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009800B8AF4B00 >									
	//     < NBI_PFI_I_metadata_line_9_____guangzhou_railway_group_Xianghu_20211101 >									
	//        < 1dq5VuVJMnRkElUr0tVlnKgYRRYYACERmlWl7lG7n7gPUjUd3awQg4X3EjdJMJBl >									
	//        <  u =="0.000000000000000001" : ] 000000114880004.528106000000000000 ; 000000129005753.716001000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AF4B00C4D8DF >									
	//     < NBI_PFI_I_metadata_line_10_____guangzhou_railway_group_Yanglao_jin_20211101 >									
	//        < Xpt3IOPW4qz2ft3R0C21lT0n6z2NS68qq0zE69t20aQr97y7e6h5nJ8Lh3n9Ma19 >									
	//        <  u =="0.000000000000000001" : ] 000000129005753.716001000000000000 ; 000000145961145.819904000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C4D8DFDEB813 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NBI_PFI_I_metadata_line_11_____Guangshen Railway Company_20211101 >									
	//        < 9y4Lz1gF8mJa1Xa2543EBCzb6nl0Ygj002ToAJ0p1ByHTz5H9TYpj2832aIqYesM >									
	//        <  u =="0.000000000000000001" : ] 000000145961145.819904000000000000 ; 000000161902881.802619000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DEB813F70B50 >									
	//     < NBI_PFI_I_metadata_line_12_____Guangshen Railway Company_Xianghu_20211101 >									
	//        < HPxj2gpQOd15b2rRRsKdi048YVRTUJVonTj4zHNimxUz2fn4c4jlID78Q8tSXtTs >									
	//        <  u =="0.000000000000000001" : ] 000000161902881.802619000000000000 ; 000000177258181.376097000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F70B5010E797A >									
	//     < NBI_PFI_I_metadata_line_13_____Guangshen Railway Company_Yanglao_jin_20211101 >									
	//        < aq5Ur96r0Erw5wO23ziFZBgIY8K8SyrrSTKKv2ErY8S7eI50h661236B55mvW3rx >									
	//        <  u =="0.000000000000000001" : ] 000000177258181.376097000000000000 ; 000000190846936.484037000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010E797A1233596 >									
	//     < NBI_PFI_I_metadata_line_14_____grc_shenzhen_longgang_pinghu_qun_yi_railway_store_loading_and_unloading_co_20211101 >									
	//        < V60u6p7Ln263Iq5MRrx0NZ52PUW3Z5qZ4psmPHwC8sNBgvKVUUbtpavtSkY93XIt >									
	//        <  u =="0.000000000000000001" : ] 000000190846936.484037000000000000 ; 000000205631498.021892000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001233596139C4CE >									
	//     < NBI_PFI_I_metadata_line_15_____grc_shenzhen_railway_property_management_co_limited_20211101 >									
	//        < nKbT91C5pw85k9q66z6l1pd67S398NcvB9R6ZCRvcvTOfCUt3o6DamvpTJ0cr50d >									
	//        <  u =="0.000000000000000001" : ] 000000205631498.021892000000000000 ; 000000221243105.101275000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000139C4CE1519717 >									
	//     < NBI_PFI_I_metadata_line_16_____grc_dongguan_changsheng_enterprise_co_20211101 >									
	//        < hrv4w8HHy45p095il6aQ4O2lHWtX10x2i3PIm877TmUX85ksHc5WKWe9N27FqMf0 >									
	//        <  u =="0.000000000000000001" : ] 000000221243105.101275000000000000 ; 000000238263495.077982000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000151971716B8FAE >									
	//     < NBI_PFI_I_metadata_line_17_____grc_shenzhen_yuezheng_enterprise_co_ltd_20211101 >									
	//        < TLa98y2G4c64XE9XustTIiQEg1H7AWgV5Qf084D1l1kJ12G3D1mMd8WbcUdUN0TC >									
	//        <  u =="0.000000000000000001" : ] 000000238263495.077982000000000000 ; 000000253549229.447553000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016B8FAE182E2AB >									
	//     < NBI_PFI_I_metadata_line_18_____grc_shenzhen_guangshen_railway_economic_trade_enterprise_co_20211101 >									
	//        < GUY2CgWR55YEwb84moAnxk40h4Ph2Vwnp1Qp0xZd8nc5D5maI8R93O3kwY6Yhqk8 >									
	//        <  u =="0.000000000000000001" : ] 000000253549229.447553000000000000 ; 000000270330087.584632000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000182E2AB19C7DB1 >									
	//     < NBI_PFI_I_metadata_line_19_____grc_shenzhen_fu_yuan_enterprise_development_co_20211101 >									
	//        < 6546FqQLXJS0eeVK9e1pO9Wte9Draa1Bc08634qxj2I47GQdK76K51wz50LKk3AL >									
	//        <  u =="0.000000000000000001" : ] 000000270330087.584632000000000000 ; 000000287072124.060481000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019C7DB11B6098C >									
	//     < NBI_PFI_I_metadata_line_20_____grc_shenzhen_guangshen_railway_travel_service_ltd_20211101 >									
	//        < c2hWZS4m30e3n91H23v3NWC40oVsr1x90X4mR7lpa5p3F1DD27Q8qIHa35vEC632 >									
	//        <  u =="0.000000000000000001" : ] 000000287072124.060481000000000000 ; 000000300800550.678676000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B6098C1CAFC37 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NBI_PFI_I_metadata_line_21_____grc_shenzhen_shenhuasheng_storage_and_transportation_co_limited_20211101 >									
	//        < 41E344kn647WAgs9lEX0E55H1u38cPDGs7H8x69WBIXB89ay207hg76hERWehrus >									
	//        <  u =="0.000000000000000001" : ] 000000300800550.678676000000000000 ; 000000314355736.323460000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CAFC371DFAB36 >									
	//     < NBI_PFI_I_metadata_line_22_____grc_guangzhou_railway_huangpu_service_co_20211101 >									
	//        < D5tUoo13mg2RC0IdYtlgb8f57swb461tsiwSBV2abPNxBm38uD34v28892z33HET >									
	//        <  u =="0.000000000000000001" : ] 000000314355736.323460000000000000 ; 000000330017771.257457000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DFAB361F79131 >									
	//     < NBI_PFI_I_metadata_line_23_____grc_guangzhou_fu_yuan_industrial_development_co_20211101 >									
	//        < 023n944f3pNohVKLSajkkJ15nwih64BSaDGvr6TesvyO9E1B78wqgtuv8K0jg41B >									
	//        <  u =="0.000000000000000001" : ] 000000330017771.257457000000000000 ; 000000345596330.901215000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F7913120F5691 >									
	//     < NBI_PFI_I_metadata_line_24_____grc_changsha_railway_co_20211101 >									
	//        < lz0Xj6N2zBkr050NS0C4NmJ9CQ4j3hLSZ2pn2gUR2x7r1Tx6z7mRtFFs8WcaWUsX >									
	//        <  u =="0.000000000000000001" : ] 000000345596330.901215000000000000 ; 000000358713094.075859000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020F56912235A4D >									
	//     < NBI_PFI_I_metadata_line_25_____grc_shenzhen_nantie_construction_supervision_co_20211101 >									
	//        < gRxN3Sg9IyKLFIAAlg9s4JXw8P9XNE2q6SAJeL5HY2TI6uo9DJpI1xo934pkmZq2 >									
	//        <  u =="0.000000000000000001" : ] 000000358713094.075859000000000000 ; 000000373025273.809115000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002235A4D23930FF >									
	//     < NBI_PFI_I_metadata_line_26_____grc_shenzhen_railway_station_passenger_services_co_20211101 >									
	//        < Mwi2QCg964LgIqvxa4M4vYJJE2ARCn8ZsGqp75GdZ70PgaJg360o0z2sDsjDB0QV >									
	//        <  u =="0.000000000000000001" : ] 000000373025273.809115000000000000 ; 000000389919272.303381000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023930FF252F837 >									
	//     < NBI_PFI_I_metadata_line_27_____grc_shenzhen_jing_ming_industrial_commercial_co_ltd__20211101 >									
	//        < TBZOW3y1jYtt3S74bj4YB8M4U78V3HoQTBKK8j4DOEhBn3iRjX07822PXZDV5DZw >									
	//        <  u =="0.000000000000000001" : ] 000000389919272.303381000000000000 ; 000000406094196.858599000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000252F83726BA68C >									
	//     < NBI_PFI_I_metadata_line_28_____grc_shenzhen_road_multi_modal_transportation_co_limited_20211101 >									
	//        < l0N84oWNgIphwKWc0okYkoRclK2251IytcTTl0xg9S9x5n290u8G3fdbh4WZbBU1 >									
	//        <  u =="0.000000000000000001" : ] 000000406094196.858599000000000000 ; 000000422246259.879267000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026BA68C2844BF2 >									
	//     < NBI_PFI_I_metadata_line_29_____grc_guangzhou_railway_group_yangcheng_railway_enterprise_development_co_20211101 >									
	//        < iJW7p61KZo4Kc12hd6RO2g0s3a3I9yk3Sxjt4S8vIP1M0f2UWF6M5491rtu254Fe >									
	//        <  u =="0.000000000000000001" : ] 000000422246259.879267000000000000 ; 000000436101866.098545000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002844BF2299704B >									
	//     < NBI_PFI_I_metadata_line_30_____grc_guangzhou_dongqun_advertising_company_limited_20211101 >									
	//        < CLBy2O4000C22YruMt6Des087tY6TN5w52A424BkBPAI3f29k8Yu5C7w1gHWHZV2 >									
	//        <  u =="0.000000000000000001" : ] 000000436101866.098545000000000000 ; 000000452837238.033493000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000299704B2B2F98C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NBI_PFI_I_metadata_line_31_____grc_guangzhou_tielian_economy_development_co_ltd_20211101 >									
	//        < s71fV5y2bUBsCwjiZX93XXToxFUtB60O2NKY89q2197oP8E6J74LIO86UCyNk6CV >									
	//        <  u =="0.000000000000000001" : ] 000000452837238.033493000000000000 ; 000000466264380.354459000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B2F98C2C77686 >									
	//     < NBI_PFI_I_metadata_line_32_____cr_guangzhou_group_guangzhou_railway_economic_technology_development_group_co_ltd_20211101 >									
	//        < GHLrs85x74mfps5Nm9314D8B70kUg269EeyqW6V1Ju5NYZ846YujmdEvEqRLkOb7 >									
	//        <  u =="0.000000000000000001" : ] 000000466264380.354459000000000000 ; 000000480788134.063080000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C776862DD9FDD >									
	//     < NBI_PFI_I_metadata_line_33_____guangzhou_railway_economic_tech_dev_group_co_ltd_shenzhen_guang_tie_civil_engineering_co_ltd_20211101 >									
	//        < TXhN8YYO4qDH2i51TlhfJ45J7GV52egDQBTj5E712f3tEgT9I3b23F1H67xz29W0 >									
	//        <  u =="0.000000000000000001" : ] 000000480788134.063080000000000000 ; 000000494760712.912545000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DD9FDD2F2F1E7 >									
	//     < NBI_PFI_I_metadata_line_34_____cr_guangzhou_group_guangdong_sanmao_railway_limited_co_20211101 >									
	//        < 0u63O896q2tmtq6lzTWtDXuZEtmA1PO8K9rTnp922j8hLuh6pz208Birc3lvqRxs >									
	//        <  u =="0.000000000000000001" : ] 000000494760712.912545000000000000 ; 000000508075285.784140000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F2F1E730742E9 >									
	//     < NBI_PFI_I_metadata_line_35_____cr_guangzhou_group_guangmeishan_railway_limited_co_20211101 >									
	//        < 5bw22Lyeq6a4m4x3U7m0LNN79yxMtR31097l1g03aXe1wqqMk1HYiu2yfeJ8H3R5 >									
	//        <  u =="0.000000000000000001" : ] 000000508075285.784140000000000000 ; 000000521271738.203610000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030742E931B65C6 >									
	//     < NBI_PFI_I_metadata_line_36_____cr_guangzhou group guangshen railway enterprise development co._20211101 >									
	//        < NI5HvXdDFun73h985MN7cDaql8pxWLA1x463CY1x4EWl8Vm6Z33bg27KkFxN8RNF >									
	//        <  u =="0.000000000000000001" : ] 000000521271738.203610000000000000 ; 000000534662730.779908000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031B65C632FD4A1 >									
	//     < NBI_PFI_I_metadata_line_37_____cr_guangzhou_group_guangzhou_railway_guangshen_railway_enterprise_development_co_20211101 >									
	//        < W2xTK0kC33EE63OgjDJY44OFZIw651Bke0u89j7b4S3H4e0414m63Ed13NCOYT90 >									
	//        <  u =="0.000000000000000001" : ] 000000534662730.779908000000000000 ; 000000549733680.891238000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032FD4A1346D3B8 >									
	//     < NBI_PFI_I_metadata_line_38_____CRC_CR_Shanghai_group_20211101 >									
	//        < BH7wvW0Pc3JcXspxx3NttYPpVX98rQ5eleIO51O6P9u9zXYca446BSxkU6oQPii0 >									
	//        <  u =="0.000000000000000001" : ] 000000549733680.891238000000000000 ; 000000564794419.254479000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000346D3B835DCED2 >									
	//     < NBI_PFI_I_metadata_line_39_____CRC_CR_Jinan_group_20211101 >									
	//        < Z12ek3Xuq41EGi24q40k3BzO78sZjal6f9ssV8vPp1PuQzb1BLT0P07pW5oxyiu4 >									
	//        <  u =="0.000000000000000001" : ] 000000564794419.254479000000000000 ; 000000578047330.385841000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035DCED237207BD >									
	//     < NBI_PFI_I_metadata_line_40_____cr_Jinan_group_sinorailbohai_train_ferry_co_ltd_20211101 >									
	//        < 8c8PzW8Mbkn2vF58Jz4Ub24I2ExDcbhT94qSP2P99ot436cHr8rO839P0pVwCNZ6 >									
	//        <  u =="0.000000000000000001" : ] 000000578047330.385841000000000000 ; 000000591279523.524168000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037207BD3863890 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}