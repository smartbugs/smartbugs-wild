pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXI_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXI_I_883		"	;
		string	public		symbol =	"	RUSS_PFXXXI_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		607381777821507000000000000					;	
										
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
	//     < RUSS_PFXXXI_I_metadata_line_1_____MEGAFON_20211101 >									
	//        < EEuFsxt76ngh0lNdiNc2FVIM16RZO3hrr66L2K08So1WIJ20Z6v8bvuytfHs69fo >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000013145652.962213800000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000140F05 >									
	//     < RUSS_PFXXXI_I_metadata_line_2_____EUROSET_20211101 >									
	//        < W6i60M8PjQGltwZTKH6bK9ZLGQ3NsYiZjrV78RNxfPvOh9gB60h2SEZf86UqPu2h >									
	//        <  u =="0.000000000000000001" : ] 000000013145652.962213800000000000 ; 000000028110910.212819700000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000140F052AE4D3 >									
	//     < RUSS_PFXXXI_I_metadata_line_3_____OSTELECOM_20211101 >									
	//        < Qp7b2vIxX8xW6jl1ar1fxWAFmjgxfa28GLjnYCF0BvQ1r57F25rTyTXc91cvN50R >									
	//        <  u =="0.000000000000000001" : ] 000000028110910.212819700000000000 ; 000000044083890.910105800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002AE4D3434445 >									
	//     < RUSS_PFXXXI_I_metadata_line_4_____GARS_TELECOM_20211101 >									
	//        < ZMeZ3lxKxE44741p1Zbx7Nk0Qr177811KwpQ4WeO337L1hWal1pcO81XqTJaga44 >									
	//        <  u =="0.000000000000000001" : ] 000000044083890.910105800000000000 ; 000000060218280.675985700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004344455BE2C4 >									
	//     < RUSS_PFXXXI_I_metadata_line_5_____MEGAFON_INVESTMENT_CYPRUS_LIMITED_20211101 >									
	//        < 91a83300KIC30uvpZ72GhRX6ElMfa8Aa99K4AMA7l86nU2q6W8F5e40N53kzJBk9 >									
	//        <  u =="0.000000000000000001" : ] 000000060218280.675985700000000000 ; 000000075613975.921312400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005BE2C47360B6 >									
	//     < RUSS_PFXXXI_I_metadata_line_6_____YOTA_20211101 >									
	//        < t04CKhViz35VTL09Agwt9oVFmht5BbFo1jC0v1Brae45bNX6SHdPbDp9DLLIyYSH >									
	//        <  u =="0.000000000000000001" : ] 000000075613975.921312400000000000 ; 000000090794501.543672700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007360B68A8A9A >									
	//     < RUSS_PFXXXI_I_metadata_line_7_____YOTA_DAO_20211101 >									
	//        < fF8uxjn7BJXA7ZGUyhn7JyU4Kw2v41sEo83tmjw30Niagh4Gzvxd3MKF4x4P4L3Z >									
	//        <  u =="0.000000000000000001" : ] 000000090794501.543672700000000000 ; 000000105783323.745065000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008A8A9AA1699C >									
	//     < RUSS_PFXXXI_I_metadata_line_8_____YOTA_DAOPI_20211101 >									
	//        < 4ZbcJYbQ274NvL55b2thgAiq42D56drWYK105P9sCRO9Ya6yXkvw307eB8FfFnyh >									
	//        <  u =="0.000000000000000001" : ] 000000105783323.745065000000000000 ; 000000120304298.227635000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A1699CB791DE >									
	//     < RUSS_PFXXXI_I_metadata_line_9_____YOTA_DAC_20211101 >									
	//        < wZT82wT4fT5NVNigz4FSEt4S3Exxc9vSzi0LxrA5HjRuJspTH4585c3VNW2JRWqZ >									
	//        <  u =="0.000000000000000001" : ] 000000120304298.227635000000000000 ; 000000135107584.704163000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B791DECE2866 >									
	//     < RUSS_PFXXXI_I_metadata_line_10_____YOTA_BIMI_20211101 >									
	//        < qOVe51pz4Wvp1uG7Xdy8G9P6foSLY80LwUctPZ1hjhZV02Y3e5995PnRP3z2pgKz >									
	//        <  u =="0.000000000000000001" : ] 000000135107584.704163000000000000 ; 000000148533030.717695000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CE2866E2A4B7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXI_I_metadata_line_11_____KAVKAZ_20211101 >									
	//        < Xj9j23jx8bQE8rhQzD4n15fN4pLJ6Yp8o5245MyLRB3XMwwF7SdY5BZkyjNg2M7i >									
	//        <  u =="0.000000000000000001" : ] 000000148533030.717695000000000000 ; 000000165554048.510317000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E2A4B7FC9D8D >									
	//     < RUSS_PFXXXI_I_metadata_line_12_____KAVKAZ_KZT_20211101 >									
	//        < 1e0t70RHizslgD4KNYaEIsw21tLD53Cd8M9OxT4I66x2zj4FD7V54336nrGJbZLm >									
	//        <  u =="0.000000000000000001" : ] 000000165554048.510317000000000000 ; 000000180426661.772939000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FC9D8D1134F2A >									
	//     < RUSS_PFXXXI_I_metadata_line_13_____KAVKAZ_CHF_20211101 >									
	//        < t4DJb0uIL1NT2OFe84jw2oKYjuz4f9Gb3Jk35fJL19UuNDC4m5Og1chRlEk2DaY7 >									
	//        <  u =="0.000000000000000001" : ] 000000180426661.772939000000000000 ; 000000193723878.829377000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001134F2A1279964 >									
	//     < RUSS_PFXXXI_I_metadata_line_14_____KAVKAZ_USD_20211101 >									
	//        < 83wG7R7P4fosVEZ6bp7B7lO47Wi011s45WObd5obYn2qVQda0h8ydlQ7wE46ymJs >									
	//        <  u =="0.000000000000000001" : ] 000000193723878.829377000000000000 ; 000000210658714.172506000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001279964141708F >									
	//     < RUSS_PFXXXI_I_metadata_line_15_____PETERSTAR_20211101 >									
	//        < 9mK3VPLdItvdLwN374o3Mih8K8mb9Tl33YSObZk85TlrV8uysj4eB73tQ3lWvt37 >									
	//        <  u =="0.000000000000000001" : ] 000000210658714.172506000000000000 ; 000000227796678.178675000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000141708F15B9714 >									
	//     < RUSS_PFXXXI_I_metadata_line_16_____MEGAFON_FINANCE_LLC_20211101 >									
	//        < 67W36Lv4mVxfemKtPXnO5lt58H9u4ulrV4N5aT5qe0Om2j9r91IOOvnwdpRLW8Oz >									
	//        <  u =="0.000000000000000001" : ] 000000227796678.178675000000000000 ; 000000242162875.344402000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015B971417182E0 >									
	//     < RUSS_PFXXXI_I_metadata_line_17_____LEFBORD_INVESTMENTS_LIMITED_20211101 >									
	//        < p6M76ai6J1d03P4c56a3Ta7WLEyU1j6cN6GGwZNQVY71JCJO5a30EpwEZ4Rvbmek >									
	//        <  u =="0.000000000000000001" : ] 000000242162875.344402000000000000 ; 000000257001237.674439000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017182E0188271C >									
	//     < RUSS_PFXXXI_I_metadata_line_18_____TT_MOBILE_20211101 >									
	//        < 1s6mW7W32tRSa9DsuC3J2R0xTYd0l85dwF16Vgoll8YrGUJ7iJDoiV4dumzl7ICd >									
	//        <  u =="0.000000000000000001" : ] 000000257001237.674439000000000000 ; 000000273275928.801633000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000188271C1A0FC69 >									
	//     < RUSS_PFXXXI_I_metadata_line_19_____SMARTS_SAMARA_20211101 >									
	//        < 48BNEeo1W5n74P25hvZGnhHhcb2R2F336VJ8XH96k6LwYsINxDntn2KOKsMXjN2Q >									
	//        <  u =="0.000000000000000001" : ] 000000273275928.801633000000000000 ; 000000288612641.129162000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A0FC691B86350 >									
	//     < RUSS_PFXXXI_I_metadata_line_20_____MEGAFON_NORTH_WEST_20211101 >									
	//        < bcwqeTVu7Gg7cCTt5i1Imz3x16717FwZn55xFMDl5kz8qpi9Nhokq7bKAhv2ZseW >									
	//        <  u =="0.000000000000000001" : ] 000000288612641.129162000000000000 ; 000000304283911.939833000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B863501D04CE7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXI_I_metadata_line_21_____GARS_HOLDING_LIMITED_20211101 >									
	//        < 511xBt2iGJ354vy5xsguLC7p9AE58W7eMwW7I4tQWtI3LZ76APnIu8dT8A1RCPI3 >									
	//        <  u =="0.000000000000000001" : ] 000000304283911.939833000000000000 ; 000000318364665.227888000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D04CE71E5C933 >									
	//     < RUSS_PFXXXI_I_metadata_line_22_____SMARTS_CHEBOKSARY_20211101 >									
	//        < 8DLfwg4GG3h8xFyXphgic8sUOQ875j5LJri9Dd73ZPD8w74BrcQpDf5I8x9J5AQl >									
	//        <  u =="0.000000000000000001" : ] 000000318364665.227888000000000000 ; 000000333776330.176106000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E5C9331FD4D61 >									
	//     < RUSS_PFXXXI_I_metadata_line_23_____MEGAFON_ORG_20211101 >									
	//        < 6Fbx162bhoSA9UMGH64mH2e4ux5V3v3Bpff9GJGmql9t1cjV0gx332q0jc2lkNOT >									
	//        <  u =="0.000000000000000001" : ] 000000333776330.176106000000000000 ; 000000348956094.597671000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FD4D6121476F9 >									
	//     < RUSS_PFXXXI_I_metadata_line_24_____NAKHODKA_TELECOM_20211101 >									
	//        < sL58C4932lT5n2O36rG99k8VOXo27RT0vGG9HnL6H884DvEBlYns3M6Cr2Ms8B1U >									
	//        <  u =="0.000000000000000001" : ] 000000348956094.597671000000000000 ; 000000364556463.441861000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021476F922C44DE >									
	//     < RUSS_PFXXXI_I_metadata_line_25_____NEOSPRINT_20211101 >									
	//        < b98GG0qRB378XiyIB8B9W9KB888d57mFfGi3n278vh4XkBnt8uG747h0AA4NUzdW >									
	//        <  u =="0.000000000000000001" : ] 000000364556463.441861000000000000 ; 000000379134565.501800000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022C44DE2428371 >									
	//     < RUSS_PFXXXI_I_metadata_line_26_____SMARTS_PENZA_20211101 >									
	//        < e2Ftn20lrMgPBDEvHqTQGxN6lZxkC57kta38H0hM5Hh5551470QMWH1F17h9JKw4 >									
	//        <  u =="0.000000000000000001" : ] 000000379134565.501800000000000000 ; 000000396332468.978377000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000242837125CC15F >									
	//     < RUSS_PFXXXI_I_metadata_line_27_____MEGAFON_RETAIL_20211101 >									
	//        < NzX24heM0DjWI3qPT72T526Jm02k6PCLHKuA6uW139uCx5EQYUiRPX48aV25X66r >									
	//        <  u =="0.000000000000000001" : ] 000000396332468.978377000000000000 ; 000000410323246.002712000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025CC15F2721A85 >									
	//     < RUSS_PFXXXI_I_metadata_line_28_____FIRST_TOWER_COMPANY_20211101 >									
	//        < hLTw46NVJ4Cvmg7Yn07uySlZ1GAnZDcXVor8RgU5cTu96Y0ymtOF5imZnV8J42wS >									
	//        <  u =="0.000000000000000001" : ] 000000410323246.002712000000000000 ; 000000425015283.474329000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002721A852888598 >									
	//     < RUSS_PFXXXI_I_metadata_line_29_____MEGAFON_SA_20211101 >									
	//        < nn0JHz6L4dA2U5r0wWtGm7MNDV3SOWH4Jx066S7hkGS679f1gEIqXoTo29LtLVWR >									
	//        <  u =="0.000000000000000001" : ] 000000425015283.474329000000000000 ; 000000438684839.598157000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000288859829D6144 >									
	//     < RUSS_PFXXXI_I_metadata_line_30_____MOBICOM_KHABAROVSK_20211101 >									
	//        < 6BeAqu8vzyXa3ior267t2dhE0TMn8ieSj2h0GX3CodL6tre00y9E7y8k8H3XKsY2 >									
	//        <  u =="0.000000000000000001" : ] 000000438684839.598157000000000000 ; 000000454166471.084865000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029D61442B500C7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXI_I_metadata_line_31_____AQUAFON_GSM_20211101 >									
	//        < 37OKbos3RjxYejf95h29F4B3Z678e4Tn3bm7Hf0Itof5s1XUz678fh3C0E6120xw >									
	//        <  u =="0.000000000000000001" : ] 000000454166471.084865000000000000 ; 000000470328680.098599000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B500C72CDAA24 >									
	//     < RUSS_PFXXXI_I_metadata_line_32_____DIGITAL_BUSINESS_SOLUTIONS_20211101 >									
	//        < 8Uq2yAAQmC0267XfP4LK988Cb5ON5CGo7L0bU4HfQNwI63lSVN93x0CZ2o70qJLm >									
	//        <  u =="0.000000000000000001" : ] 000000470328680.098599000000000000 ; 000000486447139.122727000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CDAA242E6426A >									
	//     < RUSS_PFXXXI_I_metadata_line_33_____KOMBELL_OOO_20211101 >									
	//        < 147ShHXreDo513OBh3XaP7EZb5r3S9n6Z9jM8sujJOjNqmGTVPe2g0Fs6Ob0F52p >									
	//        <  u =="0.000000000000000001" : ] 000000486447139.122727000000000000 ; 000000502879866.978420000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E6426A2FF5573 >									
	//     < RUSS_PFXXXI_I_metadata_line_34_____URALSKI_GSM_ZAO_20211101 >									
	//        < 067JGsqlwTR52wDaL16bw7dQAhEOpIsx9M8dEM8ukdVp89c56v1qjx7782e85MPB >									
	//        <  u =="0.000000000000000001" : ] 000000502879866.978420000000000000 ; 000000516009347.201804000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FF55733135E27 >									
	//     < RUSS_PFXXXI_I_metadata_line_35_____INCORE_20211101 >									
	//        < fh5hbrr4TxzLl1im2OV2NJQXVNc1F4SX2dc93vipntx8Vl2c5taI6btGjQ7GHX5q >									
	//        <  u =="0.000000000000000001" : ] 000000516009347.201804000000000000 ; 000000531431240.138984000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003135E2732AE654 >									
	//     < RUSS_PFXXXI_I_metadata_line_36_____MEGALABS_20211101 >									
	//        < nt2RZ8HZNY7KsKYpjdoqFe46ix9i68G94aD3CnhDO21a3J2es05nU6ulqU6bnB3G >									
	//        <  u =="0.000000000000000001" : ] 000000531431240.138984000000000000 ; 000000546109696.755618000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032AE6543414C1A >									
	//     < RUSS_PFXXXI_I_metadata_line_37_____AQUAPHONE_GSM_20211101 >									
	//        < 4Oh0lm3vQsgj1K8lwf5AGhlR242GneDv9BXN98aDWW72tgqtFvkI70Z4PGq2z5ZQ >									
	//        <  u =="0.000000000000000001" : ] 000000546109696.755618000000000000 ; 000000560612893.970560000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003414C1A3576D69 >									
	//     < RUSS_PFXXXI_I_metadata_line_38_____TC_COMET_20211101 >									
	//        < A80pH9FZYL5zG2xPL6Duj7O67lJ8uiJLUa1p7U6VHQD9xvPqT2c9Kogy3f02e9Mq >									
	//        <  u =="0.000000000000000001" : ] 000000560612893.970560000000000000 ; 000000573866763.598489000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003576D6936BA6B4 >									
	//     < RUSS_PFXXXI_I_metadata_line_39_____DEBTON_INVESTMENTS_LIMITED_20211101 >									
	//        < hqS9jMd8F3Mt0ACsFsgXB9vvZb9zmwv7K8Nfa2R58eAfm5S88B3bHXMHK7EYA54n >									
	//        <  u =="0.000000000000000001" : ] 000000573866763.598489000000000000 ; 000000590621037.523896000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036BA6B43853758 >									
	//     < RUSS_PFXXXI_I_metadata_line_40_____NETBYNET_HOLDING_20211101 >									
	//        < 9m945OGTBhQ33eK53RC99tXd2p8013CgnBVCQ0kS1723vV9bawX5xnKPt9fRwFeA >									
	//        <  u =="0.000000000000000001" : ] 000000590621037.523896000000000000 ; 000000607381777.821507000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000385375839ECA82 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}