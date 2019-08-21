pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXV_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXV_II_883		"	;
		string	public		symbol =	"	RUSS_PFXXV_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		816564412560058000000000000					;	
										
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
	//     < RUSS_PFXXV_II_metadata_line_1_____GAZPROM_20231101 >									
	//        < x8DQGw7XWdEk7R4z9BfI70tq744WpKU0nSx5RLp0C460SpMCizq0n57Pa8sQzkWP >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000019012568.437366600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001D02C9 >									
	//     < RUSS_PFXXV_II_metadata_line_2_____PROM_DAO_20231101 >									
	//        < 563A6w31nLgaN4tRw0b86deI1gUlAq5r61JI6Thi93KJ51NfM143B756gW8ZD0lQ >									
	//        <  u =="0.000000000000000001" : ] 000000019012568.437366600000000000 ; 000000042336835.805236600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001D02C94099D4 >									
	//     < RUSS_PFXXV_II_metadata_line_3_____PROM_DAOPI_20231101 >									
	//        < Nb63Z4qm86o4WUNaxBb6Pv4elp91rgMKSz48mKDvz9NRu34Q4Cg74cg49DG3n920 >									
	//        <  u =="0.000000000000000001" : ] 000000042336835.805236600000000000 ; 000000066051867.073407900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004099D464C983 >									
	//     < RUSS_PFXXV_II_metadata_line_4_____PROM_DAC_20231101 >									
	//        < f5nvO9a292Enaqq5c0gCQTg6icljCp44u0WCl1R2D004V391p9y5RtaI8L9lIDVp >									
	//        <  u =="0.000000000000000001" : ] 000000066051867.073407900000000000 ; 000000089919556.016221300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000064C9838934D4 >									
	//     < RUSS_PFXXV_II_metadata_line_5_____PROM_BIMI_20231101 >									
	//        < 180CmVHq8cjT53m82jJ7Jh2l8COlzOM8JKDm9Q5v47JRf3A4uNrEI6IIA7C1wqJM >									
	//        <  u =="0.000000000000000001" : ] 000000089919556.016221300000000000 ; 000000113096910.545363000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008934D4AC927B >									
	//     < RUSS_PFXXV_II_metadata_line_6_____GAZPROMNEFT_20231101 >									
	//        < 4zir17M9153cewsa258VsGM7wlsVpHgXEZsK92h1oZk1aNcAhv4p0vQ8h30jZ1i2 >									
	//        <  u =="0.000000000000000001" : ] 000000113096910.545363000000000000 ; 000000130364166.384828000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AC927BC6EB81 >									
	//     < RUSS_PFXXV_II_metadata_line_7_____GAZPROMBANK_BD_20231101 >									
	//        < 27Dj9mP9UIQmjSdH6vFp101TY71LjVe8q580w93x3oV835mZ0uImsXGsu6uijNyw >									
	//        <  u =="0.000000000000000001" : ] 000000130364166.384828000000000000 ; 000000153726312.420151000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C6EB81EA9157 >									
	//     < RUSS_PFXXV_II_metadata_line_8_____MEZHEREGIONGAZ_20231101 >									
	//        < 62OYHg3Y3ZebEhqKbH3PS8vN21rij4V5BhlC8t0O7g43J47hr3U4zmXY3Fn821uv >									
	//        <  u =="0.000000000000000001" : ] 000000153726312.420151000000000000 ; 000000176922018.517804000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EA915710DF62A >									
	//     < RUSS_PFXXV_II_metadata_line_9_____SALAVATNEFTEORGSINTEZ_20231101 >									
	//        < X8c9XmYCq6LqVNTlxcufODpCHH94w95Nl0FQ552yY3rXjKu97xGC5LY1Gf7810v5 >									
	//        <  u =="0.000000000000000001" : ] 000000176922018.517804000000000000 ; 000000199972462.893281000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010DF62A131223E >									
	//     < RUSS_PFXXV_II_metadata_line_10_____SAKHALIN_ENERGY_20231101 >									
	//        < 1pvSbb9M52R7k5ePRZJ4YB60v9O1m7KocEZL900qqRoMOryW3acwf18dzO4w2Sh8 >									
	//        <  u =="0.000000000000000001" : ] 000000199972462.893281000000000000 ; 000000219553077.640998000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000131223E14F02EC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXV_II_metadata_line_11_____NORDSTREAM_AG_20231101 >									
	//        < 09vEh1Q7e42P4o2EzDorQKfYzbr2egdIVd5Mt0WL9WuepCTU1o44TxxjY5EjW70J >									
	//        <  u =="0.000000000000000001" : ] 000000219553077.640998000000000000 ; 000000242779917.516117000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014F02EC17273E8 >									
	//     < RUSS_PFXXV_II_metadata_line_12_____NORDSTREAM_DAO_20231101 >									
	//        < vT23x16VvNa1evion6wU7d2FJYF1kNpHbWR6c3VIXKw5H2q4gEhsuhzYJ948E5BS >									
	//        <  u =="0.000000000000000001" : ] 000000242779917.516117000000000000 ; 000000259499970.309359000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017273E818BF72D >									
	//     < RUSS_PFXXV_II_metadata_line_13_____NORDSTREAM_DAOPI_20231101 >									
	//        < 8qkJL1OkEsITxVURLA3TjPks21dDtmy7Y6Gw329WmSpGv5fW1Y6HOhDA5pM9EZ09 >									
	//        <  u =="0.000000000000000001" : ] 000000259499970.309359000000000000 ; 000000278741267.422085000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018BF72D1A9534F >									
	//     < RUSS_PFXXV_II_metadata_line_14_____NORDSTREAM_DAC_20231101 >									
	//        < P5ToE369Wknn0eXKyc1y5bD3xyvgb76dq6qxJEJT08L26oUNTf7F7eOr1UNj28E9 >									
	//        <  u =="0.000000000000000001" : ] 000000278741267.422085000000000000 ; 000000296415931.129853000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A9534F1C44B79 >									
	//     < RUSS_PFXXV_II_metadata_line_15_____NORDSTREAM_BIMI_20231101 >									
	//        < yGKgP5QXfG4Ol48ZEs17R3u0Gq29vhG9V8mIDxQ4SiW9opYhNGCE141rkWTXV3GP >									
	//        <  u =="0.000000000000000001" : ] 000000296415931.129853000000000000 ; 000000316210970.954154000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C44B791E27FE9 >									
	//     < RUSS_PFXXV_II_metadata_line_16_____GASCAP_ORG_20231101 >									
	//        < Jic74I3uFiuxsI6nK5475e5V1pzer1QH8ukDN3R2OM0byqHnhyGR57rSD4mSozTu >									
	//        <  u =="0.000000000000000001" : ] 000000316210970.954154000000000000 ; 000000339756680.646515000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E27FE92066D74 >									
	//     < RUSS_PFXXV_II_metadata_line_17_____GASCAP_DAO_20231101 >									
	//        < duRKuQvqb390qvgUZ233ZKdXb5t8Quob61jr2OvKV6Ix6oKJ59f1lX5M3hTFDCGj >									
	//        <  u =="0.000000000000000001" : ] 000000339756680.646515000000000000 ; 000000357326953.926262000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002066D742213CD7 >									
	//     < RUSS_PFXXV_II_metadata_line_18_____GASCAP_DAOPI_20231101 >									
	//        < 8a1eGBQKkv2IRF7O4B7Sgsx9u72fz0S3NKdzhGXRQTi8mbZpj68q3VObh1b8Tx83 >									
	//        <  u =="0.000000000000000001" : ] 000000357326953.926262000000000000 ; 000000380535404.877852000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002213CD7244A6A4 >									
	//     < RUSS_PFXXV_II_metadata_line_19_____GASCAP_DAC_20231101 >									
	//        < y1Urvgi88FhYgws9yG65Ac0GUoijmReko6CJMv04i0Hqs42941xa94lXy0eB9962 >									
	//        <  u =="0.000000000000000001" : ] 000000380535404.877852000000000000 ; 000000399087282.781701000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000244A6A4260F578 >									
	//     < RUSS_PFXXV_II_metadata_line_20_____GASCAP_BIMI_20231101 >									
	//        < 6D6P6P6vDVna1BWI6bCQB08Sb7hJkGunFSstoF99569FsxQ1PKH8mclu6oO0p3pA >									
	//        <  u =="0.000000000000000001" : ] 000000399087282.781701000000000000 ; 000000415819055.078920000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000260F57827A7D52 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXV_II_metadata_line_21_____GAZ_CAPITAL_SA_20231101 >									
	//        < 89SJCjo49vKGu82W1MM8FWF8XUr49OgyS3eSPvX63RI2G8TWiCsjTzTkzFQRht0U >									
	//        <  u =="0.000000000000000001" : ] 000000415819055.078920000000000000 ; 000000435165366.082324000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027A7D522980279 >									
	//     < RUSS_PFXXV_II_metadata_line_22_____BELTRANSGAZ_20231101 >									
	//        < q8rigoYC5oXZob9WAyPT6a5pR7qDL4L4gmpn9lfbic44bePppg15j209968r532Z >									
	//        <  u =="0.000000000000000001" : ] 000000435165366.082324000000000000 ; 000000454501905.784145000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029802792B583CF >									
	//     < RUSS_PFXXV_II_metadata_line_23_____OVERGAS_20231101 >									
	//        < w0dFQqBik0H52O11KgnRy6tXWR517F2ECOJ3Gkz5j4U958L3h80092hM7Uw6pQ8Q >									
	//        <  u =="0.000000000000000001" : ] 000000454501905.784145000000000000 ; 000000475670137.394515000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B583CF2D5D0A6 >									
	//     < RUSS_PFXXV_II_metadata_line_24_____GAZPROM_MARKETING_TRADING_20231101 >									
	//        < C1x2m3OQL4jh48o1g7QNgqIW3tKKd413FRua20oWdqXx0gog65a2133sdh3iD7cV >									
	//        <  u =="0.000000000000000001" : ] 000000475670137.394515000000000000 ; 000000498438047.562029000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D5D0A62F88E5D >									
	//     < RUSS_PFXXV_II_metadata_line_25_____ROSUKRENERGO_20231101 >									
	//        < KP8V18ikqCW9B25QrGxfUo36cB9tjIvPW7676ccyIYW428mX9F1lFkFk7v8sN7mn >									
	//        <  u =="0.000000000000000001" : ] 000000498438047.562029000000000000 ; 000000521902703.955507000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F88E5D31C5C3E >									
	//     < RUSS_PFXXV_II_metadata_line_26_____TRANSGAZ_VOLGORAD_20231101 >									
	//        < 6I1J702J3SCY3bSr21p653YP2BupJ201V68458iUx81dm9NG76Zf4Vbav73HdrEV >									
	//        <  u =="0.000000000000000001" : ] 000000521902703.955507000000000000 ; 000000546415062.886037000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031C5C3E341C362 >									
	//     < RUSS_PFXXV_II_metadata_line_27_____SPACE_SYSTEMS_20231101 >									
	//        < H8hsGC8j2Pjtz9lbL2zaRZu5qqE90zZh015Bdv7UpIywwICDFdQ2P3iahr3RXbGj >									
	//        <  u =="0.000000000000000001" : ] 000000546415062.886037000000000000 ; 000000563002995.348956000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000341C36235B130C >									
	//     < RUSS_PFXXV_II_metadata_line_28_____MOLDOVAGAZ_20231101 >									
	//        < ba7thoM9Xq5f77G398XM8c730uUT9cZXy1swoEwiYY0zCEpneO9siA33RmY1KiX5 >									
	//        <  u =="0.000000000000000001" : ] 000000563002995.348956000000000000 ; 000000580312165.969735000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035B130C3757C71 >									
	//     < RUSS_PFXXV_II_metadata_line_29_____VOSTOKGAZPROM_20231101 >									
	//        < Hi12q9I863Ge1tn0IP8c71QJ1Oc10Hc8uLG33X12qu5nUOCkqlU7bM5MAmQo2xh9 >									
	//        <  u =="0.000000000000000001" : ] 000000580312165.969735000000000000 ; 000000604305135.338205000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003757C7139A18B2 >									
	//     < RUSS_PFXXV_II_metadata_line_30_____GAZPROM_UK_20231101 >									
	//        < 148Ses7QTgUmOy3vL97hBz906e31L2o1Br8t1mwJdh9uZxk7czmqtF0JPmnmKD0n >									
	//        <  u =="0.000000000000000001" : ] 000000604305135.338205000000000000 ; 000000621909432.771217000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039A18B23B4F55F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXV_II_metadata_line_31_____SOUTHSTREAM_AG_20231101 >									
	//        < 6rZG536ZHKI5x65jFex8OUkHOFyt5LJk9X3Afly2d0Cc56z25t9r5AO5gk9215Q9 >									
	//        <  u =="0.000000000000000001" : ] 000000621909432.771217000000000000 ; 000000640938098.686648000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B4F55F3D1FE72 >									
	//     < RUSS_PFXXV_II_metadata_line_32_____SOUTHSTREAM_DAO_20231101 >									
	//        < uB5zYTyvKRyam72MdV90o9I7KQTf04HWZ6rQ0m3Ae6kGOmC7203pJl0L07gfdieI >									
	//        <  u =="0.000000000000000001" : ] 000000640938098.686648000000000000 ; 000000656403314.135563000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D1FE723E9978B >									
	//     < RUSS_PFXXV_II_metadata_line_33_____SOUTHSTREAM_DAOPI_20231101 >									
	//        < 68JdI757Yq2Z7FIkeS9XosMQ11U3rb7nsxs6cqv368TL1sPKy5458At50655T31J >									
	//        <  u =="0.000000000000000001" : ] 000000656403314.135563000000000000 ; 000000676309669.476572000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E9978B407F777 >									
	//     < RUSS_PFXXV_II_metadata_line_34_____SOUTHSTREAM_DAC_20231101 >									
	//        < I62s6mjtdq8Mmj0h97DKHFCWW5j6k6myPdk4u4b0t39PJZM5M75p54JriT9QY1Zh >									
	//        <  u =="0.000000000000000001" : ] 000000676309669.476572000000000000 ; 000000699834104.102285000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000407F77742BDCB2 >									
	//     < RUSS_PFXXV_II_metadata_line_35_____SOUTHSTREAM_BIMI_20231101 >									
	//        < BC14in15wpldkxJI7X0km93mDYPp9JClb992Db1XQpd8OUcdIjLV18d3poiurM3s >									
	//        <  u =="0.000000000000000001" : ] 000000699834104.102285000000000000 ; 000000716886543.647929000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042BDCB2445E1CE >									
	//     < RUSS_PFXXV_II_metadata_line_36_____GAZPROM_ARMENIA_20231101 >									
	//        < 85b18o10NJXMWQrqiH05UgV8iOpm3bHJf6Ug0jy5H4hA8731xl1OPZ211D51V9HY >									
	//        <  u =="0.000000000000000001" : ] 000000716886543.647929000000000000 ; 000000738579173.949683000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000445E1CE466FB7D >									
	//     < RUSS_PFXXV_II_metadata_line_37_____CHORNOMORNAFTOGAZ_20231101 >									
	//        < p0419070Hok3QF8t3o3XD4e7W13qXr9bUsLYMu7TYka2214H8yO59F8UuQ33JEAu >									
	//        <  u =="0.000000000000000001" : ] 000000738579173.949683000000000000 ; 000000756031754.480233000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000466FB7D4819CE7 >									
	//     < RUSS_PFXXV_II_metadata_line_38_____SHTOKMAN_DEV_AG_20231101 >									
	//        < gNmH39S3n4FM083B26a39GmhdoK8R7ePaB34WIKZJD7W938WO3w6qxGGXnuqh1CX >									
	//        <  u =="0.000000000000000001" : ] 000000756031754.480233000000000000 ; 000000774678802.241599000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004819CE749E10E8 >									
	//     < RUSS_PFXXV_II_metadata_line_39_____VEMEX_20231101 >									
	//        < OhFyy5plHG0gt903vD5RLRM8JLn3ULtD3Ic2DGs0p1e31b0H3tewZNsd14pWYyqy >									
	//        <  u =="0.000000000000000001" : ] 000000774678802.241599000000000000 ; 000000791742806.868253000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049E10E84B81A89 >									
	//     < RUSS_PFXXV_II_metadata_line_40_____BOSPHORUS_GAZ_20231101 >									
	//        < 459MqIEk3TyW3684LxluBIV63KfRC6Sd6BF7MKZS130BJSu9Z4EsoB75xilQ8wge >									
	//        <  u =="0.000000000000000001" : ] 000000791742806.868253000000000000 ; 000000816564412.560058000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B81A894DDFA79 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}