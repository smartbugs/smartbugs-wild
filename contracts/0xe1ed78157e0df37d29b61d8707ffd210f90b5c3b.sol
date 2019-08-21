pragma solidity 		^0.4.21	;							
												
		interface IERC20Token {										
			function totalSupply() public constant returns (uint);									
			function balanceOf(address tokenlender) public constant returns (uint balance);									
			function allowance(address tokenlender, address spender) public constant returns (uint remaining);									
			function transfer(address to, uint tokens) public returns (bool success);									
			function approve(address spender, uint tokens) public returns (bool success);									
			function transferFrom(address from, address to, uint tokens) public returns (bool success);									
												
			event Transfer(address indexed from, address indexed to, uint tokens);									
			event Approval(address indexed tokenlender, address indexed spender, uint tokens);									
		}										
												
		contract	BIPOOH_DAO_32		{							
												
			address	owner	;							
												
			function	BIPOOH_DAO_32		()	public	{				
				owner	= msg.sender;							
			}									
												
			modifier	onlyOwner	() {							
				require(msg.sender ==		owner	);					
				_;								
			}									
												
												
												
		// IN DATA / SET DATA / GET DATA / UINT 256 / PUBLIC / ONLY OWNER / CONSTANT										
												
												
			uint256	Sinistre	=	1000	;					
												
			function	setSinistre	(	uint256	newSinistre	)	public	onlyOwner	{	
				Sinistre	=	newSinistre	;					
			}									
												
			function	getSinistre	()	public	constant	returns	(	uint256	)	{
				return	Sinistre	;						
			}									
												
												
												
		// IN DATA / SET DATA / GET DATA / UINT 256 / PUBLIC / ONLY OWNER / CONSTANT										
												
												
			uint256	Sinistre_effectif	=	1000	;					
												
			function	setSinistre_effectif	(	uint256	newSinistre_effectif	)	public	onlyOwner	{	
				Sinistre_effectif	=	newSinistre_effectif	;					
			}									
												
			function	getSinistre_effectif	()	public	constant	returns	(	uint256	)	{
				return	Sinistre_effectif	;						
			}									
												
												
												
		// IN DATA / SET DATA / GET DATA / UINT 256 / PUBLIC / ONLY OWNER / CONSTANT										
												
												
			uint256	Realisation	=	1000	;					
												
			function	setRealisation	(	uint256	newRealisation	)	public	onlyOwner	{	
				Realisation	=	newRealisation	;					
			}									
												
			function	getRealisation	()	public	constant	returns	(	uint256	)	{
				return	Realisation	;						
			}									
												
												
												
		// IN DATA / SET DATA / GET DATA / UINT 256 / PUBLIC / ONLY OWNER / CONSTANT										
												
												
			uint256	Realisation_effective	=	1000	;					
												
			function	setRealisation_effective	(	uint256	newRealisation_effective	)	public	onlyOwner	{	
				Realisation_effective	=	newRealisation_effective	;					
			}									
												
			function	getRealisation_effective	()	public	constant	returns	(	uint256	)	{
				return	Realisation_effective	;						
			}									
												
												
												
		// IN DATA / SET DATA / GET DATA / UINT 256 / PUBLIC / ONLY OWNER / CONSTANT										
												
												
			uint256	Ouverture_des_droits	=	1000	;					
												
			function	setOuverture_des_droits	(	uint256	newOuverture_des_droits	)	public	onlyOwner	{	
				Ouverture_des_droits	=	newOuverture_des_droits	;					
			}									
												
			function	getOuverture_des_droits	()	public	constant	returns	(	uint256	)	{
				return	Ouverture_des_droits	;						
			}									
												
												
												
		// IN DATA / SET DATA / GET DATA / UINT 256 / PUBLIC / ONLY OWNER / CONSTANT										
												
												
			uint256	Ouverture_effective	=	1000	;					
												
			function	setOuverture_effective	(	uint256	newOuverture_effective	)	public	onlyOwner	{	
				Ouverture_effective	=	newOuverture_effective	;					
			}									
												
			function	getOuverture_effective	()	public	constant	returns	(	uint256	)	{
				return	Ouverture_effective	;						
			}									
												
												
												
			address	public	User_1		=	msg.sender				;
			address	public	User_2		;//	_User_2				;
			address	public	User_3		;//	_User_3				;
			address	public	User_4		;//	_User_4				;
			address	public	User_5		;//	_User_5				;
												
			IERC20Token	public	Police_1		;//	_Police_1				;
			IERC20Token	public	Police_2		;//	_Police_2				;
			IERC20Token	public	Police_3		;//	_Police_3				;
			IERC20Token	public	Police_4		;//	_Police_4				;
			IERC20Token	public	Police_5		;//	_Police_5				;
												
			uint256	public	Standard_1		;//	_Standard_1				;
			uint256	public	Standard_2		;//	_Standard_2				;
			uint256	public	Standard_3		;//	_Standard_3				;
			uint256	public	Standard_4		;//	_Standard_4				;
			uint256	public	Standard_5		;//	_Standard_5				;
												
			function	Admissibilite_1				(				
				address	_User_1		,					
				IERC20Token	_Police_1		,					
				uint256	_Standard_1							
			)									
				public	onlyOwner							
			{									
				User_1		=	_User_1		;			
				Police_1		=	_Police_1		;			
				Standard_1		=	_Standard_1		;			
			}									
												
			function	Admissibilite_2				(				
				address	_User_2		,					
				IERC20Token	_Police_2		,					
				uint256	_Standard_2							
			)									
				public	onlyOwner							
			{									
				User_2		=	_User_2		;			
				Police_2		=	_Police_2		;			
				Standard_2		=	_Standard_2		;			
			}									
												
			function	Admissibilite_3				(				
				address	_User_3		,					
				IERC20Token	_Police_3		,					
				uint256	_Standard_3							
			)									
				public	onlyOwner							
			{									
				User_3		=	_User_3		;			
				Police_3		=	_Police_3		;			
				Standard_3		=	_Standard_3		;			
			}									
												
			function	Admissibilite_4				(				
				address	_User_4		,					
				IERC20Token	_Police_4		,					
				uint256	_Standard_4							
			)									
				public	onlyOwner							
			{									
				User_4		=	_User_4		;			
				Police_4		=	_Police_4		;			
				Standard_4		=	_Standard_4		;			
			}									
												
			function	Admissibilite_5				(				
				address	_User_5		,					
				IERC20Token	_Police_5		,					
				uint256	_Standard_5							
			)									
				public	onlyOwner							
			{									
				User_5		=	_User_5		;			
				Police_5		=	_Police_5		;			
				Standard_5		=	_Standard_5		;			
			}									
			//									
			//									
												
			function	Indemnisation_1				()	public	{		
				require(	msg.sender == User_1			);				
				require(	Police_1.transfer(User_1, Standard_1)			);				
				require(	Sinistre == Sinistre_effectif			);				
				require(	Realisation == Realisation_effective			);				
				require(	Ouverture_des_droits == Ouverture_effective			);				
			}									
												
			function	Indemnisation_2				()	public	{		
				require(	msg.sender == User_2			);				
				require(	Police_2.transfer(User_1, Standard_2)			);				
				require(	Sinistre == Sinistre_effectif			);				
				require(	Realisation == Realisation_effective			);				
				require(	Ouverture_des_droits == Ouverture_effective			);				
			}									
												
			function	Indemnisation_3				()	public	{		
				require(	msg.sender == User_3			);				
				require(	Police_3.transfer(User_1, Standard_3)			);				
				require(	Sinistre == Sinistre_effectif			);				
				require(	Realisation == Realisation_effective			);				
				require(	Ouverture_des_droits == Ouverture_effective			);				
			}									
												
			function	Indemnisation_4				()	public	{		
				require(	msg.sender == User_4			);				
				require(	Police_4.transfer(User_1, Standard_4)			);				
				require(	Sinistre == Sinistre_effectif			);				
				require(	Realisation == Realisation_effective			);				
				require(	Ouverture_des_droits == Ouverture_effective			);				
			}									
												
			function	Indemnisation_5				()	public	{		
				require(	msg.sender == User_5			);				
				require(	Police_5.transfer(User_1, Standard_5)			);				
				require(	Sinistre == Sinistre_effectif			);				
				require(	Realisation == Realisation_effective			);				
				require(	Ouverture_des_droits == Ouverture_effective			);				
			}									
												
												
												
												
//	1	Descriptif										
//	2	Pool de mutualisation d’assurances sociales										
//	3	Forme juridique										
//	4	Pool pair à pair déployé dans un environnement TP/SC-CDC (*)										
//	5	Dénomination										
//	6	« BIPOOH DAO » Génération 3.2.										
//	7	Statut										
//	8	« D.A.O. » (Organisation autonome et décentralisée)										
//	9	Propriétaires & responsables implicites										
//	10	Les Utilisateurs du pool										
//	11	Juridiction (i)										
//	12	Ville de Hefei, Province d’Anhui, République Populaire de Chine										
//	13	Juridiction (ii)										
//	14	Ville de Kunming, Province du Yunnan, République Populaire de Chine										
//	15	Instrument monétaire de référence (i)										
//	16	« ethcny » / « ethrmb »										
//	17	Instrument monétaire de référence (ii)										
//	18	« ethchf »										
//	19	Instrument monétaire de référence (iii)										
//	20	« ethsgd »										
//	21	Devise de référence (i)										
//	22	« CNY » / « RMB »										
//	23	Devise de référence (ii)										
//	24	« CHF »										
//	25	Devise de référence (iii)										
//	26	« SGD »										
//	27	Date de déployement initial										
//	28	15/06/2017										
//	29	Environnement de déployement initial										
//	30	(1 : 15.06.2017-01.08.2017) OTC (Luzern-Zug-Zurich) ; (2 : 01.08.2017-29.04.2018) suite protocolaire sur-couche « 88.2 » 										
//	31	Objet principal (i)										
//	32	Pool de mutualisation										
//	33	Objet principal (ii)										
//	34	Gestionnaire des encaissements / Agent de calcul										
//	35	Objet principal (iii)										
//	36	Distributeur / Agent payeur										
//	37	Objet principal (iv)										
//	38	Dépositaire / Garant										
//	39	Objet principal (v)										
//	40	Administrateur des délégations relatives aux missions de gestion d‘actifs										
//	41	Objet principal (vi)										
//	42	Métiers et fonctions supplémentaires : confer annexes (**)										
//	43	@ de communication additionnelle (i)										
//	44	0xa24794106a6be5d644dd9ace9cbb98478ac289f5										
//	45	@ de communication additionnelle (ii)										
//	46	0x8580dF106C8fF87911d4c2a9c815fa73CAD1cA38										
//	47	@ de publication additionnelle (protocole PP, i)										
//	48	0xf7Aa11C7d092d956FC7Ca08c108a1b2DaEaf3171										
//	49	Entité responsable du développement										
//	50	Programme d’apprentissage autonome « KYOKO » / MS (sign)										
//	51	Entité responsable de l’édition										
//	52	Programme d’apprentissage autonome « KYOKO » / MS (sign)										
//	53	Entité responsable du déployement initial										
//	54	Programme d’apprentissage autonome « KYOKO » / MS (sign)										
//	55	(*) Environnement technologique protocolaire / sous-couche de type « Consensus Distribué et Chiffré »										
//	56	(**) @ Annexes et formulaires : <<<< --------------------------------- >>>> (confer : points 43 à 48)										
//	57	-										
//	58	-										
//	59	-										
//	60	-										
//	61	-										
//	62	-										
//	63	-										
//	64	-										
//	65	-										
//	66	-										
//	67	-										
//	68	-										
//	69	-										
//	70	-										
//	71	-										
//	72	-										
//	73	-										
//	74	-										
//	75	-										
//	76	-										
//	77	-										
//	78	-										
//	79	-										
												
												
												
//	1	« Sans franchise / Plafond (min-max.) de (x_1)* indemnisation de base, à défaut, Forfait (min-max.) de (y_1) » « Assurance-chômage / Assurance complémentaire-chômage »										
//	2	« Sans franchise / Plafond (min-max.) de (x_2)* indemnisation de base, à défaut, Forfait (min-max.) de (y_2) » « Garantie d’accès à la formation / Prise en charge des frais de formation »										
//	3	« Sans franchise / Plafond (min-max.) de (x_3)* indemnisation de base, à défaut, Forfait (min-max.) de (y_3) » « Prise en charge des frais de transport / Prise en charge des frais de repas »										
//	4	« Sans franchise / Plafond (min-max.) de (x_4)* indemnisation de base, à défaut, Forfait (min-max.) de (y_4) » « Assurance complémentaire-chômage pour chômeurs de longue durée »										
//	5	« Sans franchise / Plafond (min-max.) de (x_5)* indemnisation de base, à défaut, Forfait (min-max.) de (y_5) » « Complémentaire chômage sans prestation de chômage de base »										
//	6	« Sans franchise / Plafond (min-max.) de (x_6)* indemnisation de base, à défaut, Forfait (min-max.) de (y_6) » « Travailleur en attente du premier emploi, compl. sans prestation de base »										
//	7	« Sans franchise / Plafond (min-max.) de (x_7)* indemnisation de base, à défaut, Forfait (min-max.) de (y_7) » « Garantie de replacement, police souscrite par le salarié »										
//	8	« Sans franchise / Plafond (min-max.) de (x_8)* indemnisation de base, à défaut, Forfait (min-max.) de (y_8) » « Garantie de replacement, police souscrite par l’employeur »										
//	9	« Sans franchise / Plafond (min-max.) de (x_9)* indemnisation de base, à défaut, Forfait (min-max.) de (y_9) » « Garantie de formation dans le cadre d’un replacement professionnel »										
//	10	« Sans franchise / Plafond (min-max.) de (x_10)* indemnisation de base, à défaut, Forfait (min-max.) de (y_10) » « Prise en charge des frais de transport / Prise en charge des frais de repas »										
//	11	« Sans franchise / Plafond (min-max.) de (x_11)* indemnisation de base, à défaut, Forfait (min-max.) de (y_11) » « Couverture médicale / Couverture médicale complémentaire »										
//	12	« Sans franchise / Plafond (min-max.) de (x_12)* indemnisation de base, à défaut, Forfait (min-max.) de (y_12) » « Extension aux enfants de la police des parents / extension famille »										
//	13	« Sans franchise / Plafond (min-max.) de (x_13)* indemnisation de base, à défaut, Forfait (min-max.) de (y_13) » « Couverture, base et complémentaire des frais liés à la prévention »										
//	14	« Sans franchise / Plafond (min-max.) de (x_14)* indemnisation de base, à défaut, Forfait (min-max.) de (y_14) » « Rabais sur primes si conditions de prévention standard validées »										
//	15	« Sans franchise / Plafond (min-max.) de (x_15)* indemnisation de base, à défaut, Forfait (min-max.) de (y_15) » « Spéicalités (Yeux, Dents, Ouïe, Coeur, autres, selon annexes **) »										
//	16	« Sans franchise / Plafond (min-max.) de (x_16)* indemnisation de base, à défaut, Forfait (min-max.) de (y_16) » « Couverture, base et complémentaire, relatives aux maladies chroniques »										
//	17	« Sans franchise / Plafond (min-max.) de (x_17)* indemnisation de base, à défaut, Forfait (min-max.) de (y_17) » « Couverture, base et complémentaire, relatives aux maladies orphelines »										
//	18	« Sans franchise / Plafond (min-max.) de (x_18)* indemnisation de base, à défaut, Forfait (min-max.) de (y_18) » « Couverture, base et complémentaire, charge ambulatoire »										
//	19	« Sans franchise / Plafond (min-max.) de (x_19)* indemnisation de base, à défaut, Forfait (min-max.) de (y_19) » « Couverture, base et complémentaire, cliniques (cat. 1-3) »										
//	20	« Sans franchise / Plafond (min-max.) de (x_20)* indemnisation de base, à défaut, Forfait (min-max.) de (y_20) » « Incapacités de travail partielle et temporaire »										
//	21	« Sans franchise / Plafond (min-max.) de (x_21)* indemnisation de base, à défaut, Forfait (min-max.) de (y_21) » « Incapacités de travail part. et temp. pour cause d’accident professionnel »										
//	22	« Sans franchise / Plafond (min-max.) de (x_22)* indemnisation de base, à défaut, Forfait (min-max.) de (y_22) » « Incapacité de travail partielle et définitive »										
//	23	« Sans franchise / Plafond (min-max.) de (x_23)* indemnisation de base, à défaut, Forfait (min-max.) de (y_23) » « Incapacité de travail part. et définitive pour cause d’accident professionnel »										
//	24	« Sans franchise / Plafond (min-max.) de (x_24)* indemnisation de base, à défaut, Forfait (min-max.) de (y_24) » « Incapacité de travail, totale et temporaire »										
//	25	« Sans franchise / Plafond (min-max.) de (x_25)* indemnisation de base, à défaut, Forfait (min-max.) de (y_25) » « Incapacité de travail, totale et temp. pour cause d’accident professionnel »										
//	26	« Sans franchise / Plafond (min-max.) de (x_26)* indemnisation de base, à défaut, Forfait (min-max.) de (y_26) » « Incapacité de travail, totale et définitive »										
//	27	« Sans franchise / Plafond (min-max.) de (x_27)* indemnisation de base, à défaut, Forfait (min-max.) de (y_27) » « Incapacité de travail, totale et définitive pour cause d’accident professionnel »										
//	28	« Sans franchise / Plafond (min-max.) de (x_28)* indemnisation de base, à défaut, Forfait (min-max.) de (y_28) » « Rente en cas d’invalidité / Rente complémentaire »										
//	29	« Sans franchise / Plafond (min-max.) de (x_29)* indemnisation de base, à défaut, Forfait (min-max.) de (y_29) » « Caisses de pension et prestations retraite »										
//	30	« Sans franchise / Plafond (min-max.) de (x_30)* indemnisation de base, à défaut, Forfait (min-max.) de (y_30) » « Caisses de pension et prestations retraite complémentaires »										
//	31	« Sans franchise / Plafond (min-max.) de (x_31)* indemnisation de base, à défaut, Forfait (min-max.) de (y_31) » « Garantie d’accès, maison de retraite et instituts semi-médicalisés (cat. 1-3) »										
//	32	« Sans franchise / Plafond (min-max.) de (x_32)* indemnisation de base, à défaut, Forfait (min-max.) de (y_32) » « Maison de retraite faisant l’objet d’un partenariat, public ou privé »										
//	33	« Sans franchise / Plafond (min-max.) de (x_33)* indemnisation de base, à défaut, Forfait (min-max.) de (y_33) » « Assurance-vie, capitalisation »										
//	34	« Sans franchise / Plafond (min-max.) de (x_34)* indemnisation de base, à défaut, Forfait (min-max.) de (y_34) » « Assurance-vie, mutualisation »										
//	35	« Sans franchise / Plafond (min-max.) de (x_35)* indemnisation de base, à défaut, Forfait (min-max.) de (y_35) » « Assurance-vie mixte, capitalisation et mutualisation »										
//	36	« Sans franchise / Plafond (min-max.) de (x_36)* indemnisation de base, à défaut, Forfait (min-max.) de (y_36) » « Couverture contre règlement d’assurance-vie »										
//	37	« Sans franchise / Plafond (min-max.) de (x_37)* indemnisation de base, à défaut, Forfait (min-max.) de (y_37) » « Constitution d’un capital en vue de donations »										
//	38	« Sans franchise / Plafond (min-max.) de (x_38)* indemnisation de base, à défaut, Forfait (min-max.) de (y_38) » « Couverture I & T sur donations »										
//	39	« Sans franchise / Plafond (min-max.) de (x_39)* indemnisation de base, à défaut, Forfait (min-max.) de (y_39) » « Couverture sur évolution I & T sur donations, approche mutuailste »										
//	40	« Sans franchise / Plafond (min-max.) de (x_40)* indemnisation de base, à défaut, Forfait (min-max.) de (y_40) » « Frais d’obsèque / Location / Entretien des places et / ou des strctures »										
//	41	« Sans franchise / Plafond (min-max.) de (x_41)* indemnisation de base, à défaut, Forfait (min-max.) de (y_41) » « Garantie d’établissement, groupe UE / non-groupe UE »										
//	42	« Sans franchise / Plafond (min-max.) de (x_42)* indemnisation de base, à défaut, Forfait (min-max.) de (y_42) » « Garantie de résidence, groupe UE / non-groupe UE »										
//	43	« Sans franchise / Plafond (min-max.) de (x_43)* indemnisation de base, à défaut, Forfait (min-max.) de (y_43) » « Couvertures relatives aux risques d’établissement, zones spéciales (**) »										
//	44	« Sans franchise / Plafond (min-max.) de (x_44)* indemnisation de base, à défaut, Forfait (min-max.) de (y_44) » « Rente famille monoparentale, enfant(s) survivant(s) »										
//	45	« Sans franchise / Plafond (min-max.) de (x_45)* indemnisation de base, à défaut, Forfait (min-max.) de (y_45) » « Rente famille non-monoparentale, enfant(s) survivant(s) »										
//	46	« Sans franchise / Plafond (min-max.) de (x_46)* indemnisation de base, à défaut, Forfait (min-max.) de (y_46) » « R. pour proches parents si prise en charge et tutelle des enfants survivants »										
//	47	« Sans franchise / Plafond (min-max.) de (x_47)* indemnisation de base, à défaut, Forfait (min-max.) de (y_47) » « Couverture médicale, base et complémentaire »										
//	48	« Sans franchise / Plafond (min-max.) de (x_48)* indemnisation de base, à défaut, Forfait (min-max.) de (y_48) » « Constitution et préservation d’un capital / fideicommis »										
//	49	« Sans franchise / Plafond (min-max.) de (x_49)* indemnisation de base, à défaut, Forfait (min-max.) de (y_49) » « Couverture complémentaire / Allocation grossesse / Maternité »										
//	50	« Sans franchise / Plafond (min-max.) de (x_50)* indemnisation de base, à défaut, Forfait (min-max.) de (y_50) » « Couverture complémentaire / Allocation de naissance »										
//	51	« Sans franchise / Plafond (min-max.) de (x_51)* indemnisation de base, à défaut, Forfait (min-max.) de (y_51) » « Couverture complémentaire / Naissances multiples »										
//	52	« Sans franchise / Plafond (min-max.) de (x_52)* indemnisation de base, à défaut, Forfait (min-max.) de (y_52) » « Couverture complémentaire / Allocations familiales »										
//	53	« Sans franchise / Plafond (min-max.) de (x_53)* indemnisation de base, à défaut, Forfait (min-max.) de (y_53) » « Frais de garde d’enfants, structure individuelle / structure collective »										
//	54	« Sans franchise / Plafond (min-max.) de (x_54)* indemnisation de base, à défaut, Forfait (min-max.) de (y_54) » « Hospitalisation d’un enfant de moins de huit ans, dès le premier jour (i) - »										
//	55	« Sans franchise / Plafond (min-max.) de (x_55)* indemnisation de base, à défaut, Forfait (min-max.) de (y_55) » « Hospitalisation d’un enfant de moins de huit ans, dès le cinquième jour (ii) - »										
//	56	« Sans franchise / Plafond (min-max.) de (x_56)* indemnisation de base, à défaut, Forfait (min-max.) de (y_56) » « Pour un parent, à défaut un membre de la famille proche - »										
//	57	« Sans franchise / Plafond (min-max.) de (x_57)* indemnisation de base, à défaut, Forfait (min-max.) de (y_57) » « A défaut, un tiers désigné par le ou les tuteurs légaux - »										
//	58	« Sans franchise / Plafond (min-max.) de (x_58)* indemnisation de base, à défaut, Forfait (min-max.) de (y_58) » « Transport / repas / domicile / lieu d’hospitalisation »										
//	59	« Sans franchise / Plafond (min-max.) de (x_59)* indemnisation de base, à défaut, Forfait (min-max.) de (y_59) » « Hébergement directement sur le lieu d’hospitalisation »										
//	60	« Sans franchise / Plafond (min-max.) de (x_60)* indemnisation de base, à défaut, Forfait (min-max.) de (y_60) » « Frais relatifs à la prise en charge des autres enfants »										
//	61	« Sans franchise / Plafond (min-max.) de (x_61)* indemnisation de base, à défaut, Forfait (min-max.) de (y_61) » « Garde de jour / garde de nuit des autres enfants / Perte partielle ou totale de revenus »										
//	62	« Sans franchise / Plafond (min-max.) de (x_62)* indemnisation de base, à défaut, Forfait (min-max.) de (y_62) » « Enfants + soins spécifiques à domicile - (confer annexe **) »										
//	63	« Sans franchise / Plafond (min-max.) de (x_63)* indemnisation de base, à défaut, Forfait (min-max.) de (y_63) » « Garantie de revenus / Complémentaire revenus »										
//	64	« Sans franchise / Plafond (min-max.) de (x_64)* indemnisation de base, à défaut, Forfait (min-max.) de (y_64) » « Couverture pour incapacité de paiement / dont I & T (approche mutualiste) »										
//	65	« Sans franchise / Plafond (min-max.) de (x_65)* indemnisation de base, à défaut, Forfait (min-max.) de (y_65) » « Financement pour paiement / dont I & T (approche capitalisation) »										
//	66	« Sans franchise / Plafond (min-max.) de (x_66)* indemnisation de base, à défaut, Forfait (min-max.) de (y_66) » « Garantie d’accès à la propriété et / ou acquisition foncière / Apport / Financement / Couverture de taux »										
//	67	« Sans franchise / Plafond (min-max.) de (x_67)* indemnisation de base, à défaut, Forfait (min-max.) de (y_67) » « Garantie relative au prix d’acquisition / dont « à terme » »										
//	68	« Sans franchise / Plafond (min-max.) de (x_68)* indemnisation de base, à défaut, Forfait (min-max.) de (y_68) » « Garantie de la valeur du bien / Garantie de non-saisie »										
//	69	« Sans franchise / Plafond (min-max.) de (x_69)* indemnisation de base, à défaut, Forfait (min-max.) de (y_69) » « Garantie d’accès au marché locatif / plafonnement des loyers / Accès aux aides prévues pour les locataires »										
//	70	« Sans franchise / Plafond (min-max.) de (x_70)* indemnisation de base, à défaut, Forfait (min-max.) de (y_70) » « Garantie de remise de bail / Accès caution de tiers »										
//	71	« Sans franchise / Plafond (min-max.) de (x_71)* indemnisation de base, à défaut, Forfait (min-max.) de (y_71) » « Enlèvements - (confer annexe **) »										
//	72	« Sans franchise / Plafond (min-max.) de (x_72)* indemnisation de base, à défaut, Forfait (min-max.) de (y_72) » « Maison / Trasnports - (confer annexe **) »										
//	73	« Sans franchise / Plafond (min-max.) de (x_73)* indemnisation de base, à défaut, Forfait (min-max.) de (y_73) » « Responsabilité envers les tiers - (confer annexe **) »										
//	74	« Sans franchise / Plafond (min-max.) de (x_74)* indemnisation de base, à défaut, Forfait (min-max.) de (y_74) » « Moyens de communication - (confer annexe **) »										
//	75	« Sans franchise / Plafond (min-max.) de (x_75)* indemnisation de base, à défaut, Forfait (min-max.) de (y_75) » « Liquidités - (confer annexe **) »										
//	76	« Sans franchise / Plafond (min-max.) de (x_76)* indemnisation de base, à défaut, Forfait (min-max.) de (y_76) » « Accès au réseau bancaire / réseau des paiements / Accès aux moyens de paiement / Emetteurs cartes de crédits »										
//	77	« Sans franchise / Plafond (min-max.) de (x_77)* indemnisation de base, à défaut, Forfait (min-max.) de (y_77) » « Accès au crédit / octroie de caution »										
//	78	« Sans franchise / Plafond (min-max.) de (x_78)* indemnisation de base, à défaut, Forfait (min-max.) de (y_78) » « (***) Frais d’écolage ; formation annexe »										
//	79	« Sans franchise / Plafond (min-max.) de (x_79)* indemnisation de base, à défaut, Forfait (min-max.) de (y_79) » « Frais d’écolage : bourses d’étude / Baisse du revenu / Accès au financement / Octroie de caution / Capitalisation »										
												
												
												
//	1	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.1 »					« Tkht3pI91s2m5N0VbK5r7N6mK44fhS7Ugm8wvP2JKpAgh78li0vVYVCjk3Kw12qR »					
//	2	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.2 »					« dA5DJ0yHLqvJVtVdwrdk486e1E8R7a9mmTTn9j255ZCodSF8WjtGwdI94aaJsq52 »					
//	3	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.3 »					« 8hu030G4GPhe7v27elyzZx6V497gvoQJWbWlB3i374ILO0l5j9It6MAvh8C59Ad7 »					
//	4	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.4 »					« ikHoOP49k2bH85lJ3nDfugkl04ke173C87v9HVO8vRTQqn785MELvtFhwA16BVmO »					
//	5	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.5 »					« g3m5DYUjgcw40tFR790sLIyg8NgxcP42pa1gSV3Kv2b0cf8B0Ee1LxmwUh9u6wV5 »					
//	6	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.6 »					« 8QJ7WB3ji1mmRE4Xg2NVae3ihKKQB05T88cvtB6iR3BuZSw42jOvQ8nooz460y6d »					
//	7	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.7 »					« 3022rnLm8iQ9PyLXV0B9k65CX5tk0P6Mp1zt8RuC5New7GtUVYSbK8uDI6Zl34L9 »					
//	8	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.8 »					« 46mY6siI0jo91Xz2xPu4EN28U81P4kTA3Re7iNe956huk36lPj3FhJbx3rYq63Du »					
//	9	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.9 »					« f700H131U0p52IlSY1vIA2cgh98qDsxbt03Akf320CQh4T8cM9wfQgd2mNl0gzfq »					
//	10	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.10 »					« YXAwZJLdo6955Acj8p1dAV3s30PlB2ej44z396kS796wi796q04218BWb8mV6Iak »					
//	11	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.11 »					« Zm2ba9wU1UB1jMRqw7Grsf6DkQ9v21UmoZns20YO9BkTh9c3079rlyrG3nnDi6CS »					
//	12	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.12 »					« 815j8T50I2HZU1XITP9a1eMzJ50b0Q9oaK5ttX3tIn1p5a9J2pJRBwKy138OS8jb »					
//	13	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.13 »					« ol45PZ4tjcy601WJEaX203NF09s1q6AgvH72ggpEz6bG1g7kpeE17B9IYxKXzfj6 »					
//	14	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.14 »					« 4wpqW1KX9q5h6b3UNF7pB12h9d4Txm76iDh3go362qU6qyeUoi4FaQST21m39JNY »					
//	15	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.15 »					« 947zLBpVt5dp5eFHXw3482Kh10T6hrJzj04MhH4hAMFT69ns8dv51zoAg0H7mSLW »					
//	16	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.16 »					« G1t3SQ6SAuPY2b7Iu9r6o9yh0hM33OSvdwO84FQud1i0Q405tiCaGW6WcVnfa6i3 »					
//	17	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.17 »					« jd37CFrajYgMLn4NxXKkwlbS19F7rzPfGkW6wO07hKP086dZrhs481kr5mD5P0Lo »					
//	18	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.18 »					« p6A6tbfb4lH0c2Vc977kmet8r5CN4Q60e89ew0J6NK1buk5ovRmb3cw2svcdfIBi »					
//	19	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.19 »					« gI5X8z332IP1F34F857Y0au1iRsjuRH85r5CTiEBJpOK0qH5R1cd56YtZ2y37S3o »					
//	20	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.20 »					« f1KZ2P21ixY8B8a5I1ZjK89XyOxOl9xM0Zip8UWJCRC5n97smnnRls570OP50LEA »					
//	21	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.21 »					« 72KlR2zMS4Rp7X6jf79R1HveDmVIG27AkP0j4o8UeF7fFM0hZ30WK6BfUlcIRGpc »					
//	22	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.22 »					« EO67wWQ5299jb6gyHDbWJtpQ13H0b208ZnmT0ZWOAsNHnUH41t65YWY7tomMrugr »					
//	23	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.23 »					« o966QHwv60tUO5P85QlxUEch2762lkV1735MmGdp74ZB3VsXzkcU3m1SfN59wXyg »					
//	24	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.24 »					« 21FhZ3Y005VW9kI4kszJ355W0G7M563G6RCgI9h07dfYdnLh9qKjg81kySZD0LH5 »					
//	25	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.25 »					« ixzwLcPz6t83sT8QLwUykoexah41lKXSBLzexx57x67vCU7SOu0D0dwqAp8J41nv »					
//	26	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.26 »					« Vz4K20C73e4o73AJAMsD9sstwn0q93CvvDAvZ4P9yOFi8438vL8B9VG10663H014 »					
//	27	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.27 »					« u7U6xYKGDK907x70Z8Q869rp5rETXq217esiF9gI0UF0zQKe4z736kjVYY340p6v »					
//	28	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.28 »					« 76jEQTx95apQRII2MJj6h9FXFcpYe78190chqINcWQ2WP2hky3quyDmIt2iEt007 »					
//	29	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.29 »					« VhCjaxju1r2gSdLIxyeVLIl9YX4nEX500O039251B01Lhuv7wfWbJjKO0J7BW3M8 »					
//	30	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.30 »					« Y97g7sZ1p6PJ08uosCZ60JJzbk6n8iW40x2fX576lng1Jau0WKplkTp4Ta9xD0e6 »					
//	31	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.31 »					« CUOjV4JIwg50v25J50mHzK0Jw8Ubd1Q5199mdddU6bYpyW0U8W1IhDX2347Tji7L »					
//	32	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.32 »					« Como9931gK07HammIcAfA2nnLRMA89sxN45dq2xK11bapQN25rb2Dze9S690dX4g »					
//	33	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.33 »					« F5It65mGqTRdaH3XfG07p87hC7D3ZeePAo2lexqh97Ga8i76r16eEu4520kMwzDU »					
//	34	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.34 »					« Ez19bpg7B936wGEI4ogb3wmT94kR8oePe8y1a1N8eJjmHC0z5xZL5gaI3MNV04Q4 »					
//	35	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.35 »					« 30iJ76sfG0dIDI3tEnKdb3JrYo2o8YanxO7cZ7LnP4PEpF3KsNHsttrHooE0m5FD »					
//	36	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.36 »					« N83YDsWrOtZJEMNkTL04UrQ5SHpebSl8b6BFyL3i3hM1X508RFGs1iCohv9JQf42 »					
//	37	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.37 »					« 2PtnPXhr3L0sW7KaT90UEN2q7Rq364VXFtALzJo6qJXdxu8z0Cav0O99ptIoAa7p »					
//	38	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.38 »					« H58d5ox8524ZFlDjWd0lv19twXZyUuT1Z1mFAw7309LmALjhvzk89PZ6g5RY42m9 »					
//	39	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.39 »					« 8g6oUwHtv63fZT39QOKc4VNb2s3jP57EnwB2g40h473Uhg75DvYfW8kJa43wULZ1 »					
//	40	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.40 »					« wXhBgqQoihLe0K0X67AoUMm2x7QVdiBHy4qpzqZ9672y2XdMUGW3k88p6bH4HX72 »					
//	41	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.41 »					« lEGc4R3V9z9rq6tGp2TaAHTJ2p650N4N32e0vBKHkV1D78oH430jEDtu620VG1HE »					
//	42	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.42 »					« IUh298K1H44X1KQ80jUmbe05mt7BshbQf5fZTc5fQ1uu7c49z7L5z9B5L4TPgom7 »					
//	43	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.43 »					« Rsb06P4zb1IvVDD71z2VU1X86CDUtLawXi5fVS4Ww7uDiu6JEJwH2bQID6mDQ4cF »					
//	44	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.44 »					« 2Z6gQv3WODVGuUcY5TPu9JZ628r0Qyn820ffIFaP683dO10HSIIGWZL5X52gI17M »					
//	45	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.45 »					« 1u0tQE9Xtzu0sw9ile3f15hhwGp4C7OLcJu5R2unic12IaAE7w6peVvZ7uZvJ578 »					
//	46	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.46 »					« 83kH1zsHMSt3B477EGV1rRywl9ibAvsBs8b0Uh2VRn2r781l61MGphQR44hrG6fT »					
//	47	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.47 »					« sY30H9543kD3bBTGMd93OfQoF33lB7R91O25rF6lGj0Mm3t86v722p361h32Nr4a »					
//	48	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.48 »					« b68n9E5BRu8ro3U8rOgP34jBAocpz1z28w0383p7HwboNmN3y7cvZMO7045q2hgp »					
//	49	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.49 »					« zy1k33rR1BR6RAiEBxHisvLNq3cKAJ1DDiY5w6B0F0Dx86LC08e7fx401Q1F6x6S »					
//	50	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.50 »					« 3VCX22n4Y70we93nZLCdCK166lMa69466eNYQ3hkrLk986y7G3Etv5KGtT3fwMml »					
//	51	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.51 »					« 0mE13YOoxR5OwKwQ52Tf1354P8CUkOK5v797baFcw8u22Z41NSjq8AddmR5b0Uuu »					
//	52	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.52 »					« 1k4J459nk51o43nw2nyDEk9J8ASja8pWAQ5wsQRY05KCfif8MajrzpkYF1gx2Nqn »					
//	53	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.53 »					« YVsXnIWmO2C4J5EaKGkICb2G5TEym6L34UTPF5ph9Zr1MJo1C93j3ImcCQki2i0G »					
//	54	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.54 »					« fItJqWi0Xy6W5x4aljW7sq7lYC8s5BhV61oY42FrAZ0wvM736534LBV35xgJ9Fj9 »					
//	55	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.55 »					« t0HZ1xR2s6k0Xy3uL0405ie8E4b3PJSRqI8aw448wy41dZd62Wlf7AU5087wmMQd »					
//	56	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.56 »					« h2xgARz26138cV8pjDSa7C9yJ121y98GDhR2lpYDVh0014R7h2ad54K4C06I4sCn »					
//	57	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.57 »					« GrPfQwf56N3Mn9n0uhqCBbpe16BP8r3nj9i0ckxJx1BTWY66DL1v99eXc24qFA9p »					
//	58	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.58 »					« VdvmxE0j901F7Te68rZ9N5z5sV200nUeZb6CB6MB163J3TeAP0Sm7W0AUR5b49RT »					
//	59	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.59 »					« DWg74sQ65rhH46pX1LF9A5jSXnbIw81eUR79x3Jo9C69C139HSi88LtM26FM18Yl »					
//	60	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.60 »					« lO8gfg5D6llGlbtGBFZ29aU4TpqI3A9e51gbZyUL69Go7n7LkJMk7J8okR3Yxkhx »					
//	61	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.61 »					« 4M1Gf70DOrm0h93uXU6L519ZVWHAoqTW43LtfvIaYOfXR6NyzXrtQ1Pa18o2g78N »					
//	62	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.62 »					« 0pD0HrPtvwQMS44N9x778eP2W5z77RX36X01R4o656EICG7qOu5b3jk8FHklgL2i »					
//	63	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.63 »					« AJqJ15nn1xonSbq7B9oLtPnfwIqBc70M8cv24UPY0YEb72iU45CDZ2715raw6t8D »					
//	64	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.64 »					« 1Ll4nX7s3yB5159Xuq4buN7q7SUfN5hTWU8D4mn66j86SH1MI73tT9oi4co45xEG »					
//	65	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.65 »					« r4NAj5qfWnAKbJlj3SZ3YS7htyfd1Ugdbqv52BON013bDJk34AB2CaiBnVva5sP8 »					
//	66	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.66 »					« N01iaSoBNMbS7O11n4KduS5R7jd5KPYp7SEKr33kRzBGsaAzHrc4GGURcb7E5OdE »					
//	67	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.67 »					« XhCMl85TbV3D12o6UaAC4NZY9WxzU3h2h8Dy6B0mTeeOz8DizCe9Zs7C45Z2P8b7 »					
//	68	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.68 »					« ey9lDS6oS8mZjCLwKXC9Ba5o45QbWpMkj1WGy74RK6x5iFw899kNVZ2IB8nT9o7R »					
//	69	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.69 »					« TGtpo5t0uR2l0tdr1PRTV177InPa5HjbV23pU4PpKa3y2j7qVZkFBUc2fEIFhn46 »					
//	70	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.70 »					« 089PbZYK6wYwP3SKQ6VES3d620l3521PNX0OzHr0vTw2M7406YFQD4FlHmXe4pUp »					
//	71	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.71 »					« 8euczreXT6H25x30FXZZN6Y3E617S65Fbis1458R0XF367c3GsHQj58jKtz7XLmU »					
//	72	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.72 »					« UHKyLPnxH77Lufl3oH2M8r6armcZdCc1zH2NVWj4y464Rt10lDHUXY92G7kR0eDs »					
//	73	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.73 »					« 14i528BNtU64gkuTa3PP6wlaFUsfDhIeo3HfToNF4Wgi16g7lNFOeJa585CEXWDn »					
//	74	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.74 »					« aH3207jH9b5NupX7ZV0uiNW408Q3jkq65JCMQrz2Nc8l787a81S1e5MT1tk38Emg »					
//	75	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.75 »					« 62e464FI55h23wMsw66KbjZB63hOM818Cqg8Y7yD682Wekh5halpPcd9GN0wTwkr »					
//	76						«  »					
//	77	TOTAL INTERMEDIAIRE = 75 Pools de 100 Utilisateurs « payeurs de primes », « payeurs partiels », « preneurs d’assurances subventionnées ».										
//	78	Soit 75 Pools de 400 Utilisateurs « assurés », « bénéficiaires ». Portefeuille KY&C=K : 7’500 U.										
												
												
												
												
//	1	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.1 »					« 8b9R4OPm55Z0zS33Blq5H3syNJA6I0N0rc8Z594uuFmum72PvX3H5CJ9I1Iar7s0 »					
//	2	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.2 »					« 9Jo73D1p4rcgyd55SK64692neOQlq2Hdkaoq8ZcG241Z1mkH1O8QK89ZEuV10u88 »					
//	3	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.3 »					« p7ssqq4G9MFOe6Gz05Vo3l3egB6G2WvXU5vh016h06bpeEHX6M544dFg91vaqa0i »					
//	4	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.4 »					« 5Q6X2q4NCgAM6ei76wR3450j2X02B1bTF41Mee4oKwh9NSZgr75BoJUtvtpdlN4L »					
//	5	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.5 »					« WV475ivB0zMwa939ELHLR720aVEPD7H97yF5k97K6ksnU79jMfhAFnb9Ve0iMw70 »					
//	6	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.6 »					« T4OdjYWl96x448yO2u4u5uxa1KRY8W4f26N0j2vpaRYf6A5S32kCC73ccwL39eKy »					
//	7	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.7 »					« 4l0N310jadr10jbwf572x1l9KZdCIfEk32wGs23nTM4GkpzqFaMIcImfiWSQ7bVV »					
//	8	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.8 »					« 8Dm27y59g3F5OmhFqM4Nr862Zz486LmNv48azEDIRM9slUZ5cQESiETCIltkQ80O »					
//	9	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.9 »					« GRT1Ec8B6Uz7O5y1mfjSlP6JexGL7B2hBe63NIUO428cS6B81W64yD7p9I2af8fo »					
//	10	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.10 »					« NxO7fuoaC85CPSkoZ4ixKI8Hu22On6pNwC4VCe552lxq569T3e7691dtS0m3YnJF »					
//	11	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.11 »					« 8A0vl8087a6caa6n0SM9suYKHxQyn135Zz4Di8Vtt154BWKbqZKZ4E71Z1y81sq8 »					
//	12	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.12 »					« shAWu43IOR73CKHoTi83RM25994ae8ReGU6v3CYS5j0VPtptLc3Fh8brMPO94nF3 »					
//	13	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.13 »					« V1K647M5jYHQ4vWz619Cy6nr2QX2zw67G761y6Bieb3v301xMxBmofAkTyf54M3z »					
//	14	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.14 »					« TGFp3863oZdFakki49zKHCGiW0RM0dhXVQmUnD1wJhbtlUu9iu03oGuyl9xaI3s4 »					
//	15	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.15 »					« kaikZ7deiI8i97MKU5tvydI760CsX7ObkyXiqMLvAU09la3lCE5iN0fjBsbs603O »					
//	16	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.16 »					« qlc8ZJ28el9DHBynWXU73KcV5paOv4Qd8e7cEv2IfHhp677n3u393E3H6yr0z4r4 »					
//	17	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.17 »					« 68AlHfAh56xWER09e27sSjpvgD9DX8MLtgJ42RUQjpEZm91at38eywf92u6QgJK1 »					
//	18	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.18 »					« 7YwFs24vDtW42aDOs7a2sPox4M6Twm00VJ0672z6Tva0udg5ALOZV8t8D5m0z70o »					
//	19	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.19 »					« TlC7CtfG9WPy30upXclS23d13YbBwlkrtU51nY9QKimtZr2K0R8DLA4iNYi4q500 »					
//	20	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.20 »					« Cq03b3gr0u9915k9Swy6RB54X0r58eOF46n89tqaH3nQuvk5Nlf2Ap3858rap8hh »					
//	21	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.21 »					« dWaNpc3iz7P3K1PuAZ0EjmNPv2sgt4eA9ywR5gm5ng03Z8zrT7OS5yUW3541oGwL »					
//	22	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.22 »					« zY08d1417ZERt3859H227gl2EmAO1MTe9BQNmTjh3cpGXUTFa7O6kHEluJEC787O »					
//	23	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.23 »					« uC7p8v52FxlZGvI1xW2wsJx28ewxCrR2BPN1pYb4ttpM0b0igJB5f4h9vhJx7Q3w »					
//	24	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.24 »					« mD51HL537FnF5FcX96hqQV6DsAcsQbseC1cnPQBf3ew5jVZ646MN6bZJSyuaBqqw »					
//	25	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.25 »					« jtMHwpIs5L27iAw3daIhc16ReXtrKE7tB8Sm78X7I7T1v0F80vZToUNK6039BTYH »					
//	26	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.26 »					« TeQZD0MI3kU4RJr6p3nA57hryI74200Dt1676Xv8I1n427cWkQMHO6661naZ03kW »					
//	27	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.27 »					« J9cfVpp37Z9d98KZ4c3f5pbG80YkAoaXbLB8Ic04OZKJF4TrLB8eMB776X34lV73 »					
//	28	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.28 »					« W2g6yT7C05df35ELytS8Gl0uzb2A8P703mwsu5pjbdFB4u66Mv192V304iIQParP »					
//	29	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.29 »					« QQYkkvjXL39O2C6e8QQ0zC9VctXuaNNwEqjHyqOO5p6xcDx1CNBHu6iLD20lr2M5 »					
//	30	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.30 »					« 0xQLO4l7KC2nDcwo3AQnXM47R8m8EILZUV0QUxkkm8WjtdEuLZnhITITMLct8P4X »					
//	31	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.31 »					« O23kED4ef5cb2LvK62ufaU6lG463l0K1ky8lJtpOAJvPEY1bKaHPJ9Z9qYW0nM59 »					
//	32	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.32 »					« 5S7gJ6nh8Tq4lM8kdXHa902RVzoV6O55Vb6pi1k0auG9az94K3z8f78Hg6j9gyZP »					
//	33	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.33 »					« Ifu5AM52QdNgtndgLI147jwb2BzKqE2O09rdeP3xkibeajSStlyNl27qCtxhdhe2 »					
//	34	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.34 »					« de25160r64cK6YkYAOCV0HJ9eOPWv40Ow8Ulm7Je4ZDuo81OpVArG0JZh1Vo816Y »					
//	35	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.35 »					« T95d785If0Xod2eC5c2VF0J6rhU024nt5f4Y1Y8LM2F224Ou82dUDKt4HrUD97M8 »					
//	36	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.36 »					« k4ZH2Jt8N6ney58042ddt1MdC0aoJqazVH76Rb0lu1c32kAk2q76U972i67D5rv3 »					
//	37	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.37 »					« s5PYig8KFIwJ82a1hB4o3MxEyRh7Q8j38k2ik1x3HjERRsyFeiOW0RAPjtzZCX2j »					
//	38	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.38 »					« gJo8nnDsW0tF7kIK9rabaXTV4FmFt2JUpmwBT21329Vl4ilgQ3aAyL3tx6S5cE36 »					
//	39	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.39 »					« 5O12D8V4l5dsDeKa21DmxwxC96OaC5EcbIM2qVpaWa0T4eHc20lL0Nfz7S455Dy3 »					
//	40	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.40 »					« 1wCyzON8p853dCh4cqvE6t1YPVa4UsAZ332r13l52j0GKQa1ob1Vz7hoCS1GRmt3 »					
//	41	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.41 »					« Mf0117fcOmSr5bvL48vPbMCn3wtXrkNuHNcY62kD9oL51N831fWE2kA5HRp8Q8E0 »					
//	42	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.42 »					« GlbA35eA38p6Wi944rSt3GwBiQo8LR2l91VTFB75hrFd4r87FtEe575EDSgl67cO »					
//	43	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.43 »					« Se7igDw6rP96zmE1SHn510inOLDWCPRvl2wpyfQ59SwMt8nTr1EX83m8LXniLy12 »					
//	44	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.44 »					« LI4l59Y6Vr3yS1Ebq3496OadoW7Lu4r9KiCN431U56daTx1l1QA99iKbsT6b5Nno »					
//	45	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.45 »					« od6RAT85e6tcrcs7pl81fR2hpFfi0r163Cy3p68yVbY3d7BpYXV2ptfe7ueSzPYL »					
//	46	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.46 »					« T0t3Hm2N9sBPHDE096V4qe7aPkWappk8bANJL0SC33a4CmiToUg13YEKPtpi4bkY »					
//	47	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.47 »					« YlE73tkvUbbILtiXX7aQ7tYwp1k0JLt7x9T191519jaLW2y9unVQ1Ddw8586PI94 »					
//	48	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.48 »					« QK15KEC3mY3Dx1ymS7E9732q34Okv9et0FAw4amcYvc49j915364WQHsnn7CVxNm »					
//	49	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.49 »					« 154rtkv5kD9u0KMQ3F7DjQB196V678WN4HihJCkmK74q1l8G2MHW9g80ujoVh5s8 »					
//	50	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.50 »					« bhMCJ791ilysUJ5o5p3Tid0b9T8ls70Rc2XB1Gy4861nHsivTq4sH28NPOT0CGaN »					
//	51	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.51 »					« MrgB7q42aq2w03xbuSiltryn71TaVev3ctOMC967u3u48BArbRxQuK1YM5dE9HLg »					
//	52	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.52 »					« 7flXbe8XxKf5s4pz56Ie44429DVtJjYPh9UIYpflqKy9vQ3fZ1kvixVQfcyDsjgj »					
//	53	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.53 »					« 3LYk1bsD58d2E0RqpT5m320f1Z28C3545M70vI459lCG1o5s05qf3252LGmw8S71 »					
//	54	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.54 »					« s6tH0MvrGByv7hrCq09Ab8d9VjjGa6kaK9MsRF7g5PnTh98hxeh3n13JmlJYr1OT »					
//	55	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.55 »					« J6lu2ITBPnWr8MAHOdRO3yj1zm159zZcXS2n3P23Bu69S5m599D7kDVZ76GSCX2G »					
//	56	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.56 »					« 26Bv5849aR5dpxoHu7w9EgRqdGtv5E0I2m1vaUw8LHVqtAQ0bRjfd9a54wb1VP3a »					
//	57	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.57 »					« eT2mV0mglM1mTeA1GkvC1ymlqSwrchqY7xZ3Ct9pP6vSLZyU5dgvdmpL604fq9ef »					
//	58	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.58 »					« 5K2LmcaIGKchn5M6ZrYBk70OhH3ePiblW2kz17VZ8FkhpBh17sg6c51vJB1kAebH »					
//	59	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.59 »					« 4jAfiM4723nOr0mT249o7lyp9tnWAR20sLBbLZVnjd9Q63Vp1U1IP2c77JNgT0N8 »					
//	60	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.60 »					« 69tg1Oia1Pr3yfbQJ4ZMXKEad1EC8ZNEBtj4wQ669Th4k1i79IFvwYHF9h7i387V »					
//	61	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.61 »					« Y1YZ5gRW2A4KFO4WZQjyGyP1kS75tY2igg933WDqq4cyNfCPNMSP96oxEZtK65r2 »					
//	62	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.62 »					« 75JlvW1uRZOC0Bsg6CSjDVXF6o3f8XN9D9va13XjoQ4LzIJSHnjkQ6lC2vr0aW5n »					
//	63	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.63 »					« CE5KOZ2DRwyOvbtFyBT89Z83HxO01Vn63U40C8agn13h3BCJ0n1oVnntQyNZ8vU4 »					
//	64	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.64 »					« BNXuOND7pmD72W1Eo28ru0xBcZpdrfU81HH7oNMlv24Rdm2tdHEb8Ly96j93tsDp »					
//	65	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.65 »					« W182BQ7SIOD5EfHScplW2mJgZj7b92hl9kP2x81a2Ladd57ApDqn5Sz600fh9cmY »					
//	66	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.66 »					« thgh20K1e9aX2e47pw9d7R2Ng631B9CgBuN8r26b4PFzh5R14IgdT6Jbh213nb8b »					
//	67	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.67 »					« yB7jR1Lp5LfvRfaSH6az1wHDOz6hjYhIHvPT4HMnz4CBKoWjb2nOe9O5sM7lKtiw »					
//	68	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.68 »					« v78i37eEZxjlW1537kxZ8Lo2msXlmQKT8kjSFvKSTRVH2AmoaN1Jxn0Cd8K787F5 »					
//	69	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.69 »					« 8R96Kir2l6DrZ1122we2J7ct8c0995GOPc2g17wKkbgRUbYswi7OKj0G76P02NrV »					
//	70	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.70 »					« rJ0bVSE6Dlpp35x65mqDyW51wJCkK14LchC6PI3Dwa3GSwG3ak347Ivc2lu1n0q1 »					
//	71	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.71 »					« tPDP3bEK2H845W15xNc2J4L572x2YtD2Av8fCv8I5T0iAP3eKmjJP0JK7GTkCox3 »					
//	72	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.72 »					« lp39vC71ZOQwciG4ARY803NlzEW937m5aPUJc9iF5bl3TU19A86o5v6I19347396 »					
//	73	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.73 »					« 1Kffoaq38b59aW6ZEEtf3ThTVRtI7p3KKDhZ6x1sk7VYKJZj8gW3cW88PbfoOg91 »					
//	74	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.74 »					« gL51aZfVkH5o2O1hHN3oYpTJomC70HKHgf32AoI5c48DoIsPSEaKx34Z6257M0H3 »					
//	75	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.75 »					« WfvSoT3dmHWi6Ultitah0dHqbprTA8l9u0Qj5FeY3103y4B7J9SS5o8pUNr90AtB »					
//	76						0					
//	77	TOTAL INTERMEDIAIRE = 75 Pools de 100 Utilisateurs « payeurs de primes », « payeurs partiels », « preneurs d’assurances subventionnées ».										
//	78	Soit 75 Pools de 400 Utilisateurs « assurés », « bénéficiaires ». Portefeuille KY&C=Y : 7’500 U.										
												
												
		}