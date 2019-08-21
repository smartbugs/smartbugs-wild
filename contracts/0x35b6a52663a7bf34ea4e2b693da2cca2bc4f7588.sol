pragma solidity 		^0.4.21	;						
										
	contract	NDD_NFX_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDD_NFX_I_883		"	;
		string	public		symbol =	"	NDD_NFX_I_1subDT		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		4250507023558140000000000000					;	
										
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
	//     < NDD_NFX_I_metadata_line_1_____6938413225 Lab_x >									
	//        < 6z1KZq1TJ3UFV22e6DyhKo2hZHfIoJoTjbAo2I5725V1UJ4E2o84tw126Dq2Fj1y >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000000F4240 >									
	//     < NDD_NFX_I_metadata_line_2_____9781285179 Lab_y >									
	//        < oIpxFv2Xv300oQ83H01PPWL0M1hrI8E6tb88p6jVO0zG60Z5Cb7f75W20a4i6t69 >									
	//        <  u =="0.000000000000000001" : ] 000000010000000.000000000000000000 ; 000000020000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000F42401E8480 >									
	//     < NDD_NFX_I_metadata_line_3_____2307669142 Lab_100 >									
	//        < KMF3j58kq9ft622SzNVujPezTveN2oWHH9JuwS7341lB2J0VoWJ5uwkt99Wfr3yT >									
	//        <  u =="0.000000000000000001" : ] 000000020000000.000000000000000000 ; 000000030533779.130225600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001E84802E9742 >									
	//     < NDD_NFX_I_metadata_line_4_____2398555257 Lab_110 >									
	//        < S5ha2JnUyob2s85Od3HUrTg8dm2hkiu7nrn9ylDv1Df9ll2h7rox495pKBQIo7S6 >									
	//        <  u =="0.000000000000000001" : ] 000000030533779.130225600000000000 ; 000000041585324.016770200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002E97423F7444 >									
	//     < NDD_NFX_I_metadata_line_5_____2360063539 Lab_410/401 >									
	//        < 2akeCegh3h1mUtPSsH1fu43zNrG83u8V5bm4moVRcM8u6y5EVJWu5rY25s8TPbvx >									
	//        <  u =="0.000000000000000001" : ] 000000041585324.016770200000000000 ; 000000055791503.562948300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003F744455218E >									
	//     < NDD_NFX_I_metadata_line_6_____2347966543 Lab_810/801 >									
	//        < nS7V6Biz4MF2RL2PC4kf9D9oNeIeu7LrYnjyCtXFB3RMRlYTivH2Ex13Dsq74UEh >									
	//        <  u =="0.000000000000000001" : ] 000000055791503.562948300000000000 ; 000000074203862.655304500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000055218E7139E2 >									
	//     < NDD_NFX_I_metadata_line_7_____2372828167 Lab_410_3Y1Y >									
	//        < 1VZ9zlUG2856y15XDP6a125b0e0MQo8DLYUOLZ21adRK9kDj02lf2lwET9z9uD8u >									
	//        <  u =="0.000000000000000001" : ] 000000074203862.655304500000000000 ; 000000094446195.785134700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007139E2901D0C >									
	//     < NDD_NFX_I_metadata_line_8_____2352925922 Lab_410_5Y1Y >									
	//        < 78Q430Dz7zY3o1s4D5XMta6h4C9On1X78hL8Q3mBFe1O57FCmM3J7xX2syeic0MX >									
	//        <  u =="0.000000000000000001" : ] 000000094446195.785134700000000000 ; 000000104446195.785135000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000901D0C9F5F4C >									
	//     < NDD_NFX_I_metadata_line_9_____2323232323 Lab_410_7Y1Y >									
	//        < Gs6C3e8o5d11af4X98dMR0GrnlAI7Ya9b93XIkDH93Z7kahWI1oVUEbuvPGEDXlD >									
	//        <  u =="0.000000000000000001" : ] 000000104446195.785135000000000000 ; 000000114446195.785135000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009F5F4CAEA18C >									
	//     < NDD_NFX_I_metadata_line_10_____2323232323 Lab_810_3Y1Y >									
	//        < 5rn0VZ7KsWSYIBZ0B61TsKUS6YqaeCg0o6MfEuCn8H4BuvX2z07YK7NkbgdJubn1 >									
	//        <  u =="0.000000000000000001" : ] 000000114446195.785135000000000000 ; 000000151515436.518249000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AEA18CE731B8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_NFX_I_metadata_line_11_____2373815513 Lab_810_5Y1Y >									
	//        < 4Ek6mj91a66xtCTeq41CX1NkRJJJlCC7C00J9U58aRxX4B2vsnbs0pK64WZNduyt >									
	//        <  u =="0.000000000000000001" : ] 000000151515436.518249000000000000 ; 000000161515436.518249000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E731B8F673F8 >									
	//     < NDD_NFX_I_metadata_line_12_____2309937022 Lab_810_7Y1Y >									
	//        < x9g0hY48REj5lUq88480BicF2aj8O9kIrscM7ea4R0M2pOp20Ai21NZ927855Qx4 >									
	//        <  u =="0.000000000000000001" : ] 000000161515436.518249000000000000 ; 000000171515436.518249000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F673F8105B638 >									
	//     < NDD_NFX_I_metadata_line_13_____2323232323 ro_Lab_110_3Y_1.00 >									
	//        < 8C5Fe8r7LnV4k61nZMRk1q2dCX6uErnRsIg7z7003R66Qms6jF8JxkaQoZ8v8rk7 >									
	//        <  u =="0.000000000000000001" : ] 000000171515436.518249000000000000 ; 000000191469311.001693000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000105B63812428B3 >									
	//     < NDD_NFX_I_metadata_line_14_____2323232323 ro_Lab_110_5Y_1.00 >									
	//        < Nn3UM058h7k0776cS2i9z3equbb13y15sq2Xizz0F4KZesYnn1he07F0lvllXkmF >									
	//        <  u =="0.000000000000000001" : ] 000000191469311.001693000000000000 ; 000000201469311.001693000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012428B31336AF3 >									
	//     < NDD_NFX_I_metadata_line_15_____2323232323 ro_Lab_110_5Y_1.10 >									
	//        < 8q4e30blu3nb3M7pFE41577CXD32v0si3Qq02ZeK3nSGt4k758F9vMw6UZ194Um9 >									
	//        <  u =="0.000000000000000001" : ] 000000201469311.001693000000000000 ; 000000211469311.001693000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001336AF3142AD33 >									
	//     < NDD_NFX_I_metadata_line_16_____2323232323 ro_Lab_110_7Y_1.00 >									
	//        < U3Pn19g9ugd17yJ77fDz8314BCPjtxdzI81ic1Rzili342Skzg0bt97S1A8R2vPU >									
	//        <  u =="0.000000000000000001" : ] 000000211469311.001693000000000000 ; 000000221469311.001693000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000142AD33151EF73 >									
	//     < NDD_NFX_I_metadata_line_17_____2323232323 ro_Lab_210_3Y_1.00 >									
	//        < 128f4thoT2A0Dil78y93Y2t9yq83jAl9747YIv2ndyGq3LA41j5d1D7sx7Lgz5cx >									
	//        <  u =="0.000000000000000001" : ] 000000221469311.001693000000000000 ; 000000232637948.503747000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000151EF73162FA33 >									
	//     < NDD_NFX_I_metadata_line_18_____2323232323 ro_Lab_210_5Y_1.00 >									
	//        < 35wI33rk3Ew89UUVA2lX56CB2cH8R9C2CexxGNpvMjF142Y13ZU9F3M9u34mpyDU >									
	//        <  u =="0.000000000000000001" : ] 000000232637948.503747000000000000 ; 000000242637948.503747000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000162FA331723C73 >									
	//     < NDD_NFX_I_metadata_line_19_____2323232323 ro_Lab_210_5Y_1.10 >									
	//        < bBYz21GxW4Jo3Te1HF7J5gGM9n3y1941Sc4QWPpDTgp52RTxy5PK5i6jAG0SEm0u >									
	//        <  u =="0.000000000000000001" : ] 000000242637948.503747000000000000 ; 000000252637948.503747000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001723C731817EB3 >									
	//     < NDD_NFX_I_metadata_line_20_____2323232323 ro_Lab_210_7Y_1.00 >									
	//        < WtK6de9MMld9ViN59VDCJpHcnStI86zh1Nk01X5dk4w2nKf7DEnNz5gw48SbE5r9 >									
	//        <  u =="0.000000000000000001" : ] 000000252637948.503747000000000000 ; 000000262637948.503747000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001817EB3190C0F3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_NFX_I_metadata_line_21_____2308602376 ro_Lab_310_3Y_1.00 >									
	//        < IrnyT4F65NWEYJh958e941lt1B82CpqQ7mz6s6G9xM6wM3A18q4V2auMi8Ju7nA1 >									
	//        <  u =="0.000000000000000001" : ] 000000262637948.503747000000000000 ; 000000274023428.449655000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000190C0F31A22067 >									
	//     < NDD_NFX_I_metadata_line_22_____2307363173 ro_Lab_310_5Y_1.00 >									
	//        < SJk3Ed6X6YtwkP5Bw39b824i5nAPtcxOVOMboxod971nL675hAb9217695cyWN29 >									
	//        <  u =="0.000000000000000001" : ] 000000274023428.449655000000000000 ; 000000284023428.449655000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A220671B162A7 >									
	//     < NDD_NFX_I_metadata_line_23_____2399062903 ro_Lab_310_5Y_1.10 >									
	//        < zOG7AzmtkCG8515FJBqvHlqMnJf8JABjS0ak3h912oFGjAA8I6j3C5Svxqkm08np >									
	//        <  u =="0.000000000000000001" : ] 000000284023428.449655000000000000 ; 000000294023428.449655000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B162A71C0A4E7 >									
	//     < NDD_NFX_I_metadata_line_24_____2323232323 ro_Lab_310_7Y_1.00 >									
	//        < 2Nq93U2zwSzulz9S571KcMsfKX77667UJRePdibD114TLq39nVW3Sfwd2rMwJ97t >									
	//        <  u =="0.000000000000000001" : ] 000000294023428.449655000000000000 ; 000000304023428.449655000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C0A4E71CFE727 >									
	//     < NDD_NFX_I_metadata_line_25_____2323232323 ro_Lab_410_3Y_1.00 >									
	//        < zLifv9PaHGO305LdwS0NkXA7L9cf3HxuGVsq54lmB3lTYD0bBX64YY2Fd24lmtx3 >									
	//        <  u =="0.000000000000000001" : ] 000000304023428.449655000000000000 ; 000000315650929.288254000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CFE7271E1A525 >									
	//     < NDD_NFX_I_metadata_line_26_____2323232323 ro_Lab_410_5Y_1.00 >									
	//        < pb23JGkpZCl4s419dPUIVk69DCX164x2L4gEk22fjckSKi1rRL2C16P3l8ZGyb2L >									
	//        <  u =="0.000000000000000001" : ] 000000315650929.288254000000000000 ; 000000325650929.288254000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E1A5251F0E765 >									
	//     < NDD_NFX_I_metadata_line_27_____2323232323 ro_Lab_410_5Y_1.10 >									
	//        < 1vbsBRe9Ysm3zw10XC1DMu0Upf5xCiaVDK4HQAXcI6f860a18S418d97MQ00ek24 >									
	//        <  u =="0.000000000000000001" : ] 000000325650929.288254000000000000 ; 000000335650929.288254000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F0E76520029A5 >									
	//     < NDD_NFX_I_metadata_line_28_____2323232323 ro_Lab_410_7Y_1.00 >									
	//        < ZFN27riaZBR1kzaPlrH12s4HSN5sbrN2306mR9FNv5230ScaO9S5mYLxAdS8IV7j >									
	//        <  u =="0.000000000000000001" : ] 000000335650929.288254000000000000 ; 000000345650929.288254000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020029A520F6BE5 >									
	//     < NDD_NFX_I_metadata_line_29_____2323232323 ro_Lab_810_3Y_1.00 >									
	//        < Jc794U5S37335C7H89bFO0NB9P97FaXqez2CuHyM74j5z651sX4kHvLUPKUuGpU0 >									
	//        <  u =="0.000000000000000001" : ] 000000345650929.288254000000000000 ; 000000358625492.633095000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020F6BE52233815 >									
	//     < NDD_NFX_I_metadata_line_30_____2323232323 ro_Lab_810_5Y_1.00 >									
	//        < JO8z2sZQ06HmydXU65HV4NJI8XykqRrd8408NAx8Q8NAzdfMGV832qRQSA40z5AT >									
	//        <  u =="0.000000000000000001" : ] 000000358625492.633095000000000000 ; 000000368625492.633095000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022338152327A55 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_NFX_I_metadata_line_31_____2389753778 ro_Lab_810_5Y_1.10 >									
	//        < CK22xa4I3kLYLzqMBIM6s5NtyKs2HiiaEiUtx0P0nw9zW1ws9tmxUnN8DcX49Xbg >									
	//        <  u =="0.000000000000000001" : ] 000000368625492.633095000000000000 ; 000000378625492.633095000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002327A55241BC95 >									
	//     < NDD_NFX_I_metadata_line_32_____2369775746 ro_Lab_810_7Y_1.00 >									
	//        < 9BI034bL22IE6lZmms4T5ZF7Q2G9UO872aC775F4Ziag44A9si45hMpKFI7n0267 >									
	//        <  u =="0.000000000000000001" : ] 000000378625492.633095000000000000 ; 000000388625492.633095000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000241BC95250FED5 >									
	//     < NDD_NFX_I_metadata_line_33_____2378591127 ro_Lab_411_3Y_1.00 >									
	//        < y1ywc24SSBg47j86768fBb4e4BRiq9353oSRhX4U04k24gsmL6R4m9AZV2iCr0uv >									
	//        <  u =="0.000000000000000001" : ] 000000388625492.633095000000000000 ; 000000403146563.569965000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000250FED52672720 >									
	//     < NDD_NFX_I_metadata_line_34_____2351495534 ro_Lab_411_5Y_1.00 >									
	//        < d0O0qyJPT5OPO2nfRx38JVOZR7JJf13X6R6NA446C8OiPBjuzgvElDvrj8OSsfo6 >									
	//        <  u =="0.000000000000000001" : ] 000000403146563.569965000000000000 ; 000000439154205.693632000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000267272029E189D >									
	//     < NDD_NFX_I_metadata_line_35_____2368442444 ro_Lab_411_5Y_1.10 >									
	//        < 4OR2fLIrlqlLI8afk1OD8E4G463dnk6SiEmoW9spMCi77B49h9p4npX64Hic2VO7 >									
	//        <  u =="0.000000000000000001" : ] 000000439154205.693632000000000000 ; 000000462461698.728181000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029E189D2C1A91A >									
	//     < NDD_NFX_I_metadata_line_36_____2342580898 ro_Lab_411_7Y_1.00 >									
	//        < Cc6r4yq1yoMw8O20a6u1XoH8bRXRsj5FAeVaPtfF5GD6zXS2twNGm3OVcwxZX1jh >									
	//        <  u =="0.000000000000000001" : ] 000000462461698.728181000000000000 ; 000000685542669.327291000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C1A91A4160E1B >									
	//     < NDD_NFX_I_metadata_line_37_____2316008497 ro_Lab_811_3Y_1.00 >									
	//        < iHQ28F22Rpc9qnD7DIB62Oq2hc8qn33A1Qkbb5S7P2n1s1Iq0mZLvFgmb5NB1U7r >									
	//        <  u =="0.000000000000000001" : ] 000000685542669.327291000000000000 ; 000000707965550.445713000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004160E1B438450B >									
	//     < NDD_NFX_I_metadata_line_38_____1171542239 ro_Lab_811_5Y_1.00 >									
	//        < 3J93643MYYP9jbCCbO493m4mCAg3bG7oSpo6Z3F62gB8wX12YMm77axqkMXH3RR0 >									
	//        <  u =="0.000000000000000001" : ] 000000707965550.445713000000000000 ; 000000965238972.670123000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000438450B5C0D679 >									
	//     < NDD_NFX_I_metadata_line_39_____2323232323 ro_Lab_811_5Y_1.10 >									
	//        < HBT084Csn0q9U2rBM8x8za309ti40319gWE6r663RGPR8N0Aie2B7EYtolS88416 >									
	//        <  u =="0.000000000000000001" : ] 000000965238972.670123000000000000 ; 000001093943784.910270000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005C0D67968539CA >									
	//     < NDD_NFX_I_metadata_line_40_____2323232323 ro_Lab_811_7Y_1.00 >									
	//        < 8sP0lYH801A1SHhpg0NCndGx2S9g6OLCNQd5XyMluoe36e4n07z92AEvONe79HUK >									
	//        <  u =="0.000000000000000001" : ] 000001093943784.910270000000000000 ; 000004250507023.558140000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000068539CA1955C24E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}