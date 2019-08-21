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
												
		contract	BIMI_DAO_31		{							
												
			address	owner	;							
												
			function	BIMI_DAO_31		()	public	{				
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
//	6	« BIMI DAO » Génération 3.1.										
//	7	Statut										
//	8	« D.A.O. » (Organisation autonome et décentralisée)										
//	9	Propriétaires & responsables implicites										
//	10	Les Utilisateurs du pool										
//	11	Juridiction (i)										
//	12	Ville de Timisoara, Judet de Banat, Roumanie										
//	13	Juridiction (ii)										
//	14	Ville de Fagaras, Judet de Brasov, Roumanie										
//	15	Instrument monétaire de référence (i)										
//	16	« ethleu » / « ethlei »										
//	17	Instrument monétaire de référence (ii)										
//	18	« ethchf »										
//	19	Instrument monétaire de référence (iii)										
//	20	« ethlev » / « ethleva »										
//	21	Devise de référence (i)										
//	22	« RON »										
//	23	Devise de référence (ii)										
//	24	« CHF »										
//	25	Devise de référence (iii)										
//	26	« BGN »										
//	27	Date de déployement initial										
//	28	01/07/2016										
//	29	Environnement de déployement initial										
//	30	(1 : 01.07.2016-01.08.2017) OTC (Lausanne) ; (2 : 01.08.2017-27.04.2018) suite protocolaire sur-couche « 88.2 » 										
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
//	56	(**) @ Annexes et formulaires : <<<< 0x2761266eCB115A6d0B7cD77908D26A3A35418b28 >>>>										
												
												
												
												
//	1	Assurance-chômage / Assurance complémentaire-chômage										
//	2	Garantie d’accès à la formation / Prise en charge des frais de formation										
//	3	Prise en charge des frais de transport / Prise en charge des frais de repas										
//	4	Assurance complémentaire-chômage pour chômeurs de longue durée										
//	5	Complémentaire chômage sans prestation de chômage de base										
//	6	Travailleur en attente du premier emploi, compl. sans prestation de base										
//	7	Garantie de replacement, police souscrite par le salarié										
//	8	Garantie de replacement, police souscrite par l’employeur										
//	9	Garantie de formation dans le cadre d’un replacement professionnel										
//	10	Prise en charge des frais de transport / Prise en charge des frais de repas										
//	11	Couverture médicale / Couverture médicale complémentaire										
//	12	Extension aux enfants de la police des parents / extension famille										
//	13	Couverture, base et complémentaire des frais liés à la prévention										
//	14	Rabais sur primes si conditions de prévention standard validées										
//	15	Spéicalités (Yeux, Dents, Ouïe, Coeur, autres, selon annexes **)										
//	16	Couverture, base et complémentaire, relatives aux maladies chroniques										
//	17	Couverture, base et complémentaire, relatives aux maladies orphelines										
//	18	Couverture, base et complémentaire, charge ambulatoire										
//	19	Couverture, base et complémentaire, cliniques (cat. 1-3)										
//	20	Incapacités de travail partielle et temporaire										
//	21	Incapacités de travail part. et temp. pour cause d’accident professionnel										
//	22	Incapacité de travail partielle et définitive										
//	23	Incapacité de travail part. et définitive pour cause d’accident professionnel										
//	24	Incapacité de travail, totale et temporaire										
//	25	Incapacité de travail, totale et temp. pour cause d’accident professionnel										
//	26	Incapacité de travail, totale et définitive										
//	27	Incapacité de travail, totale et définitive pour cause d’accident professionnel										
//	28	Rente en cas d’invalidité / Rente complémentaire										
//	29	Caisses de pension et prestations retraite										
//	30	Caisses de pension et prestations retraite complémentaires										
//	31	Garantie d’accès, maison de retraite et instituts semi-médicalisés (cat. 1-3)										
//	32	Maison de retraite faisant l’objet d’un partenariat, public ou privé										
//	33	Assurance-vie, capitalisation										
//	34	Assurance-vie, mutualisation										
//	35	Assurance-vie mixte, capitalisation et mutualisation										
//	36	Couverture contre règlement d’assurance-vie										
//	37	Constitution d’un capital en vue de donations										
//	38	Couverture I & T sur donations										
//	39	Couverture sur évolution I & T sur donations, approche mutuailste										
//	40	Frais d’obsèque / Location / Entretien des places et / ou des strctures										
//	41	Garantie d’établissement, groupe UE										
//	42	Garantie d’établissement, non-groupe UE										
//	43	Garantie de résidence, groupe UE										
//	44	Garantie de résidence, non-groupe UE										
//	45	Couvertures relatives aux risques d’établissement, zones spéciales (**)										
//	46	Rente famille monoparentale, enfant(s) survivant(s)										
//	47	Rente famille non-monoparentale, enfant(s) survivant(s)										
//	48	R. pour proches parents si prise en charge et tutelle des enfants survivants										
//	49	Orphelins : frais d’écolage (groupe ***)										
//	50	Couverture médicale, base et complémentaire										
//	51	Constitution et préservation d’un capital / fideicommis										
//	52	Couverture complémentaire / Allocation grossesse / Maternité										
//	53	Couverture complémentaire / Allocation de naissance										
//	54	Couverture complémentaire / Naissances multiples										
//	55	Couverture complémentaire / Allocations familiales										
//	56	Frais de garde d’enfants, structure individuelle / structure collective										
//	57	Hospitalisation d’un enfant de moins de huit ans, dès le premier jour (i) -										
//	58	Hospitalisation d’un enfant de moins de huit ans, dès le cinquième jour (ii) -										
//	59	Pour un parent, à défaut un membre de la famille proche -										
//	60	A défaut, un tiers désigné par le ou les tuteurs légaux -										
//	61	Transport / repas / domicile / lieu d’hospitalisation										
//	62	Hébergement directement sur le lieu d’hospitalisation										
//	63	Frais relatifs à la prise en charge des autres enfants										
//	64	Garde de jour / garde de nuit des autres enfants										
//	65	Perte partielle ou totale de revenu										
//	66	Enfants + soins spécifiques à domicile - (confer annexe **)										
//	67	Garantie de revenus / Complémentaire revenus										
//	68	Couverture pour incapacité de paiement / dont I & T (approche mutualiste)										
//	69	Financement pour paiement / dont I & T (approche capitalisation)										
//	70	Garantie d’accès à la propriété et / ou acquisition foncière										
//	71	Garantie d’apport / de financement / couverture de taux										
//	72	Garantie relative au prix d’acquisition / dont « à terme »										
//	73	Garantie de la valeur du bien / Garantie de non-saisie										
//	74	Garantie d’accès au marché locatif / plafonnement des loyers										
//	75	Garantie d’accès aux aides prévues pour les locataires										
//	76	Garantie de remise de bail / Accès caution de tiers										
//	77	Enlèvements - (confer annexe **)										
//	78	Transport - (confer annexe **)										
//	79	Maison - (confer annexe **)										
//	80	Responsabilité envers les tiers - (confer annexe **)										
//	81	Moyens de communication - (confer annexe **)										
//	82	Liquidités - (confer annexe **)										
//	83	Accès au réseau bancaire / réseau des paiements										
//	84	Accès aux moyens de paiement / cartes de crédit										
//	85	Accès au crédit / octroie de caution										
//	86	(***) Frais d’écolage ; formation annexe										
//	87	Frais d’écolage : bourses d’étude										
//	88	Frais d’écolage : baisse du revenu										
//	89	Frais d’écolage : accès au financement / octroie de caution										
//	90	Frais d’écolage : capitalisation										
												
												
												
												
												
												
												
												
												
												
												
												
												
												
												
//	1	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.1 »					« K4Lfos2SURxmKMMP62TC3h8v5QMWx1Sy91NB83sE0w4u1v8yk96k0SUAE2mJJc14 »					
//	2	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.2 »					« c109X3DNPy7V0i7VTNCp0zJhpMLHvBGIwJ43iV4Q80Cx7ht05NB85D55Z8aZv9EK »					
//	3	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.3 »					« 8VvWn3gyO4bWWHM5u35TI5lOenJdMBfP2qmN1tdJ24V81k8y1Daqcd5UQoGJ19x4 »					
//	4	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.4 »					« EJTKvxn0McOSsI8I1G94f0xZ5if70R79ZE4I95zxZ8cpD6W25m53LO51GgqfWlKI »					
//	5	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.5 »					« Y377S1k9spHp0IFh8l0Wi7902SQY69WLpnZz83Yn43N7hdp1bkvSsUTCq1I72XdK »					
//	6	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.6 »					« A6qIyv79o16f1kx4gPd7fmRg5VM4Zp6Oww97SDy5teAuZhaQuw6p16o2IXv8GZf7 »					
//	7	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.7 »					« Plv03Pg6o56y6904nj2J6dH92wtFw065S5028qfUM59Gub6jupBUvvqz54Nyn21K »					
//	8	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.8 »					« 877j5JY9vpkdJbHYOVo62XHrK1YSkX08lq8NOYUNV1cWd11rr94YZvd46JLKZml0 »					
//	9	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.9 »					« JZwUTI442I3bG256A358Z5AuPNEI1D819UbCP54002CR1gW25434dH0OH9Mm6Shz »					
//	10	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.10 »					« 3E62Tji1pjI3V0Zk34PZTltCJb770hJrs78dpLM3F57D4UOWpE6e9Ml5rJ31d8j2 »					
//	11	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.11 »					« E9ldm1TYaCb7LSC16245i7gI4D4DA08h15DTUkV6oJp7zvtGeo4AI2G5RX1Z5Clb »					
//	12	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.12 »					« JnbktRbq9bkV57MPbB638Pr0qRuzisw1k0JRC7dpslp0x9z8G0tX2yl73RmQ2Mmn »					
//	13	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.13 »					« irnB1wYV3m707W2R6HDoJxH0aH0sBCtkOvDIg8vw4xPm5E0Jrxf36Bha7hG2KQ58 »					
//	14	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.14 »					« 9w1mLn2A8m2gEy89TSt3Ft959kOl485J93gkhHaO57j848YJrXSC91DIDp6g5QtV »					
//	15	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.15 »					« 0Pb0xGLPDb536550rnw3qEUPxytG57x55273q2tj28F0ToZUff16M5HDLy4h3K1m »					
//	16	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.16 »					« r9END3u5JhPkI2M931i7rsh3nr28t8nF2D8VSH68MTSh85Uv1xUY0x4rXTb5H0Fa »					
//	17	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.17 »					« 0Mjk2SS1Yo9xWFJwW77HHB0Dr57H44kYGk1EQ1NcDu6697VAIuUr25okY63059oL »					
//	18	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.18 »					« aikQ4Cz0yvsx6MA7wH58UNKV5MvPvGvZ24BuLg1rePx5WI6Qc8qoB5S96qm14eR5 »					
//	19	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.19 »					« puT7uHkOam9KkZ332krDPW3Myln65VlbU0CpPHR6GcjIhvRCO9vLc3j6342Lm4IN »					
//	20	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.20 »					« 76GeCaH39xj2uBY1543zFbbKXp1jqO9lm0uUDVH1tC08szG8d4wKb7aG3Fd38IeB »					
//	21	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.21 »					« a6a08yUTC4vaOqNy0S99Rd5LeRqTd6Ue9P57qUEakgF2401abSpkXwrW0SQqVZMp »					
//	22	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.22 »					« 2Ie2y1AgJdgoSe9bfF455HRD7iBi2JSHz58zt6Ekg786OA425d1w90gy9rG2acH5 »					
//	23	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.23 »					« f818xP8f098013t4f5aCdL09fo5dm8y6n71H5vOL6I0QXxMkrIvpg5kNw9gR1kp4 »					
//	24	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.24 »					« 4TE1sb2FJRgKhx1UmxiNLo222QF5vBa89VV9A7YaQfq9VuyuW0jr3Lwc39wkxsVP »					
//	25	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.25 »					« VHae04Of7wSoMR6Yhh7Ex4eceupZC491C5nmR7h2Y7g2ay03S1e5oloUubNn6quM »					
//	26	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.26 »					« U0q7MHfg79h4moW16zRaG52Y0rFTOYy3HL39bPh9klKJ0L2dpXJ3Ck9uAOI43a15 »					
//	27	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.27 »					« ZwQTTVS0n94D38399NaT38e7VN6RHkiVTa723jpPVp6IUB0edA1h87xy6t52pN0n »					
//	28	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.28 »					« 8LNiPE6pY5mr78D8L70j96r7a3sIx191fg85ixKgZ11lvX4IezQ6q2W1q6Gi1m7H »					
//	29	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.29 »					« 02pSibB8jcu8Zx84isf8Rr2LbSD58h0uEENbhgY44AJdM9rwbmlNc0PWwL92a795 »					
//	30	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.30 »					« EoDwqF8I6v20ZSbzB93d2Vzhl47M8W29Iz1oWds2XvC4jLuPzGxk3fr1Fj8douCU »					
//	31	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.31 »					« O9igDc8VswA1pPtSwWxTUq76I5Ow9IB3V2LqjX4bbl6a75s77K95LKey4XVKJTDF »					
//	32	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.32 »					« wBQnzdg11C9qjGj1b5b8dJPKBLp25D103127hom1I0EcKeEP6Iztfdzq4a8jx4g9 »					
//	33	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.33 »					« 8imo6BWNK4lyAAgM23XkwhSD4Djr6sQ8HCmgr21v04k9l73qsk1daf4ws5UUtjnj »					
//	34	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.34 »					« 507XS543Xn87GQsL0rXtdcQs4k0uze42873c923hR2MfLu2XjT7g3N4ZHwgPtJYc »					
//	35	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.35 »					« VyX3uePy3KfKyGH8yH0LLkkf7hU69n51dYVpNe7Uz1uJ6g4BU8VveJrjI2wf3sli »					
//	36	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.36 »					« 8K6Y7YhCfoMsy8EN740VWEJgrOZ0jce8g30xnx0V7WlUJYZIbYRK3R3Sa0BdOG38 »					
//	37	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.37 »					« 8jktzpc7B63M0h6blNw43889hDucj04gAWKC556s54GzPBz0kB63fv1MQuki4Pa4 »					
//	38	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.38 »					« 9D2qvY1ZP24976iWB8S29dh05UVZDgb21P8gN55mGHI6o3ibQ3U8GT8Uvt30Rem5 »					
//	39	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.39 »					« Lr397VO1uz6Kuel5hotElZ8naY51mwhxB3Qm7AKwD68mb0ftB3Bz209fqfu9h6sk »					
//	40	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.40 »					« 64C66Fm9C1S4ej7rq3O5apYk1f4EkYz8w09Wps3sb06NYsY49bBouy03MkOLirG2 »					
//	41	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.41 »					« mVLF7iS8k7yW0GuNWJTxJ3V3fF0l9b61h7Pq0WgpMpLiGc9xR1DVXol7vDb139PR »					
//	42	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.42 »					« Sl3AE85xdY86ZAVqdX2PO2OshyaZ3CVhwZ59KWWG8lzTm7QxZbsPIYr37bdqFA2A »					
//	43	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.43 »					« 51PH3EP3KnAq53yB1F31eN28MJa4bdV26OYm85SXy7jEH8xvm0aXretr4GCtITIE »					
//	44	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.44 »					« tV3cgn1nwc17J1Vg836YxXUVlEIBGmo8R0eXsUrG62NaQ7axEry95K46JZstcLbb »					
//	45	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.45 »					« 5Q0r3A2Nk6cJ2PX538Bh1jlC7xK6MHWjxvBNatgqZ8UWdzGsjGqu2p2z0yb7aF66 »					
//	46	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.46 »					« 6gxi3b33AZp3TC66Mb0S6sToLbpN4bE513q8pprGJCjQ0IMKCub7RLEyS7aBLuko »					
//	47	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.47 »					« JBwFCi2Bq167kOT52SoGhnLOzsU1QgOysMACvY3stkyazL04gN73Z5p620xsjOpP »					
//	48	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.48 »					« I6A2B3sVDBQ3j2r1I5WDxWGGQOE4z5prYPP4q91z7s0B7OPv9S77JP19s6p1M20U »					
//	49	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.49 »					« c0HU6TnimjCCPixxyN5P34ow2i2lP31O9PWsFWzr9vlYpykLlzfw0qmzRrVY6BSd »					
//	50	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.50 »					« J8AKyfHvl6h5Ub3AxuMK3uH5b4kVa8ii7Wnyf8Sc7j5p1hiWZ6oIaMlrXCJssl4Q »					
//	51	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.51 »					« kU22G7p255yV0PD0g2a8zm22w38BPdm7h4rnZ8aa59S3eN2Rz1LEYimQ2Dqi11uK »					
//	52	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.52 »					« O49FHiAd4RJi66WfLfPP0s83Go9e8jeb55O8H3M2t2CVVZ51evo345Noj53HsyO9 »					
//	53	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.53 »					« 30mx7Azdh89pnEH7e3HFbJ34r9N28Pf1mS6YwZ6fRGdcoq0qSrkv4re25k864Lm8 »					
//	54	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.54 »					« e8l48Cw52kolGlfXaN6g2krBb6mxl1Ms5Gwqsvx9Wslu8J6b1zs9Z56VYSY06513 »					
//	55	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.55 »					« 8leP8XLDw4d2I9W5GI1iNHTg8cF93OjadX8nX11uyMzaE5OSr8E14ynUscCi361i »					
//	56	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.56 »					« Uo0Ig6bF6iD5OT4I403talgnhI7YIHiSYcjl5h48E7S3609SuhF5hlqf3397lc47 »					
//	57	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.57 »					« 2jGRpx6ln4F1UPrqvYN5zsLq7OhE0Y0MHr65YjsltLPocBeRRDMCeZ0Ge99dF4W8 »					
//	58	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.58 »					« YC2KC0L22cq1qCXyKzd53E8A2OwwgCNbXIni15m26M9E30Nml8e39QABR4b9xVe3 »					
//	59	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.59 »					« p2986MuPEqOPT2Xbd4c23Z28I8G613UVU7O2R43n4GsAiL05OQe1k86lk7qA62id »					
//	60	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.60 »					« DTO6gM18ig35eo119898To0413A4TNZR0FROB3GOmhxZl9rFO9oyXY0LmbO27463 »					
//	61	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.61 »					« b4fAslbCMWPuUuR80bV9499Srpzk0167cSq30Py91uDUdf7Z8og6Qt4OqFJ70jfx »					
//	62	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.62 »					« lRsKI10WRIa9BA4325ydJ3Yh5V9fPJ5B51A0JL0dOZ3A54xtscRD3G8gT2HRKUqy »					
//	63	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.63 »					« Q5q85rY3FhimRMJ8B0sjTVMvc4AH2KXD33W6I7778NkJ8U0LmIp5E19BE0g9tV0b »					
//	64	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.64 »					« AS4i8Kbu3ygDqqxLL79xXjA9xCn1W03GcOTamzJ7Crs72771t89o1Ya9qXmAfX24 »					
//	65	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.65 »					« kWx45rSJ901fAN2QURIe8okx4683zc9aX1lM6N3yB36O29bZRMgx9S86FrklIIgF »					
//	66	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.66 »					« 211UyIwq8pBhF83Y35x22X0jBZ3OduO1I8Qa99QpnPCE0X7G989dx5F94689Ccck »					
//	67	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.67 »					« j15szCh0cN4BY676I2Mjjrf5E2JqXB1yjZ9paq84C9MEng2RyF1hj8or4583WgwY »					
//	68	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.68 »					« F58Ohh4Ex39KHe5yt66vEtYsGuPVP2jc9r3nlt2ez10bT8mQ1QjiJzhYk1SKaPT9 »					
//	69	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.69 »					« TspkH4cQ85o6MidAjK8vA8B7XX1Uvp2s4tsedcJ9srSDctcQW871kNM82dI11wQ6 »					
//	70	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.70 »					« X2sTWl5xEIVZ33KBQHe06R2Dof4RRj243xr2nx5xKJNzDZPoSD3vZF07797x2OBD »					
//	71	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.71 »					« 85VQ77tiC5CF5LV67cG03p8Rg3b0N92Hnz1ZPl5l0d35JSdZ62hqMYuNxArFV4BL »					
//	72	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.72 »					« gRlynXNhW2V8baSfcWB8ihq267jQfV4nGWG5H6bLg9rfOmSw4XYDt4MY29aH3O01 »					
//	73	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.73 »					« eesnUWT6Lu0ouNW9WLh6605J8vM1e5DsupGC79fFg4Q6MDjcpJR9B516dctrqN6j »					
//	74	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.74 »					« zO76j844tFlDGiwr38APBq3VCTnaVwXBM3dB9W118w2NT7D49K8e2409L1Q42c77 »					
//	75	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.75 »					« 9P8not516F2491KL6xXF3e93sX0H4290goXAo5LPjYqi65Ic7824nHG1F7S98T4W »					
//	76						«  »					
//	77	TOTAL INTERMEDIAIRE = 75 Pools de 100 Utilisateurs « payeurs de primes », « payeurs partiels », « preneurs d’assurances subventionnées ».										
//	78	Soit 75 Pools de 400 Utilisateurs « assurés », « bénéficiaires ». Portefeuille KY&C=K : 7’500 U.										
												
												
												
												
//	1	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.1 »					« 9DC1lAoaYdLw9Jw2s854j0732U9HBU5Ed875s3pGf2o7yp7TJn7fap7mAHyDuwyo »					
//	2	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.2 »					« v2cnd93th2lGnx1Q2YOKxf874fMvhPZ425Du0GP8yrR75j62XvK6XlQB22R5zX5T »					
//	3	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.3 »					« SXa7uvz7o3arh99mSbNbH91QFkMgP80MX9404WgXdH87z1K3OrNpXQE3A4vG6604 »					
//	4	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.4 »					« B8hT86B63G2kNN9j31x8qZSoCuvLGEZ5mDe9y07s6hQnQaSK1kvYjciLyR5Tlrsf »					
//	5	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.5 »					« aPo99DvB3JFBdL5fx5Iijfc9S6jVW5x4Cg7JZRL817yp3vbakg5DEzU0Z9L1WFqO »					
//	6	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.6 »					« kif1B589hN16Bh2cgHDYztxAcTYyGiYpL394WM425bx114KcMiP7bjvIa0TUcAe0 »					
//	7	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.7 »					« 14EUVhHx4VoQSUIB7J8c9DgRMv037G9kY23TX2HOWDaj2v88KHZ6952PKTT5THO3 »					
//	8	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.8 »					« FHgI32N3V6vQeoLr3ckSz7WFE73HJWWtZD2n6B6h70k6Maiv9G84HdA2dAw66I21 »					
//	9	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.9 »					« LXuO47Ei3QOF2huih3152go3cvR6DIsDN61rGc7m7GtOA2G3lH4ZOH8pKr8dKkLc »					
//	10	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.10 »					« DaQ41m9s5g63fx270iUksi7F8lRbzrCNv4W50ZPl9W9Uln2wD5d1z3B8BkU878ET »					
//	11	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.11 »					« Df6mS6e2W9z66pk0n9kmFdIC238rmStgxLG62Oss7aTKm6a1jEqnA1VeOYr6V06i »					
//	12	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.12 »					« cU0Q348634D4A2nn2mYJwp218NP5w1p4nw5Al0Ab66FeXl0UWnGWG10z9OAk6C8k »					
//	13	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.13 »					« S7ytRV222061gQ0KQxh1TIjOaT77C5TEpBR8QqQ9nqmC5J1JOi3x2zA3yx1SU2F6 »					
//	14	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.14 »					« 1gnv5Fwg7qP2daapWtT5ji08VkibnnqB8OkRd2yh45l80xeJBb2wLh3X3r798e0M »					
//	15	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.15 »					« x1O1Oo12QOvnNX8SX6xUHoBrRMz2lr10v5izMN5VV0p03p5qfJBI3WrZ4r67005h »					
//	16	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.16 »					« lfWkpraXaTuJtyHZ7cgal7i9k160li5A0p13MJm4G4TNzoi6D87BKRl3Sw3ZN92A »					
//	17	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.17 »					« dG6P5dBWHsTR1iAdQIHydr0J5Zxyep77VRfc71qFeLLnBIjF89c3u60oX3ehjW85 »					
//	18	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.18 »					« DI8Wp332T8P3K372aIiGqGnWltBN757lIq5SBdW2dSR3RHkOu8QOu4cV4EhTHN3G »					
//	19	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.19 »					« X60nViEq1Jk7ua3vgQV0mlU6A2nwkft4AAQXc29a3lR16F14UvUw669vgSbcg6Z7 »					
//	20	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.20 »					« vDKD87NNx7RQvThMr3xukC6Nz8IJj2873Fs64u6rE83fMccDavMk0LRAtpNj0PTp »					
//	21	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.21 »					« Q611O1Jy13ZzFsN7g1VS7RxbsQctg6HM6Sg6kY2H5q93T6K9I0SZ7F41Z8p7WQka »					
//	22	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.22 »					« BXjDd151N4eMDT1Av8hn8c6c0MO48e3i41wQG50chCVM8jGv1804fo1fBelqeD1o »					
//	23	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.23 »					« 8G76hLq5zG0r811x3s4mygtu30B7yGxMRIYrFXJIUVY9N95KMDXG3ziZ3VcKC7Y8 »					
//	24	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.24 »					« 4Ml4507nj2qtqFA5zB5wiNLV69uQVKevSu40S51BEraB399c1Oc7JuFE9iZ9ct6O »					
//	25	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.25 »					« Ca1hG0786J5toPFl102bbr1ewLTa26uuSv1lzFTErBDk119yTgABi76P6NICJtW8 »					
//	26	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.26 »					« 887VZ07fcHx6TiSCmcJra0Ne90f20nB2giYA5Ja51otWodZ83rFh88wzy0JQDn36 »					
//	27	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.27 »					« V7Cbn4d5dvOe1g3na52FMgW6SH6XJ7OXf01FCTGUp01DtLnR5RmOy2Glqb6ZGFe2 »					
//	28	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.28 »					« w3J3fGJ8EvEP702Uk75I6ykXdEP5C2F5SxRsT95z736h3sv7BfciSckD93W18gnZ »					
//	29	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.29 »					« yp3nH53Y927E50DzQ5ps7R08gE3BwG4Evj3x6O6YUh7j55gXN9ai1zcuO14c3v5g »					
//	30	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.30 »					« Pl92n91oxPQ2N1o18fF180x7AHJ0R03zLt5Q6c79V8hqaXdJE235va0q2QiG7y2C »					
//	31	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.31 »					« z0V3UVEqAwuQk5WBpjG8Q988NDy24c7bjyExHI1D6zq53O7Lxzd86rVw4k1d61oz »					
//	32	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.32 »					« B9RQkfu5V0oHw718EV4P2kmF0cU20Rdv98ztq81cS364f07BB6QEr10on58fu08o »					
//	33	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.33 »					« Zpudra4ycJ0ViV3x2p9m1lqECM790k5rCo4U271QE53wJmV95es7ilP3l64s7W92 »					
//	34	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.34 »					« B8f51oH10cPZx9mH0ER27On121AwSZ23io1k353Ej58n362P2D7E7A473P0py5jT »					
//	35	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.35 »					« Z3t7Cn9EA5COJ23VB8pyjMgMkJ4k3tUvpOuf7W14IKG94q7PEq6fQ2152C9apd3b »					
//	36	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.36 »					« R62Z4HBD4o3PM3sfG0Dd43nuYu3nVAk4K5QD8CNN6z3Gm4PSLD4733mWeOo7HEOL »					
//	37	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.37 »					« 0OUe9kkdL3g4G44KX51dtoY0RQa66oMZ888Y33Yw5VM07Ui9F6nRu0HN6rS5MPS5 »					
//	38	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.38 »					« N1SbVh7BkOw01QM2GER4m2QN8s4L17xR5z3gyV1Y9TX9LwK4ShZKe0HK3qGlImNO »					
//	39	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.39 »					« RB16Q9m2MK3ICCz5kqMZ6kMal8nV5HdYA68Ih0EnP1nFE08Sxce1v762Io110g3N »					
//	40	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.40 »					« A0IB7bMqg5KccsHW43JkrNK308LK71kmzBq6UnF351X0jXBu8UBTtPnXPmKow3G7 »					
//	41	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.41 »					« e1TL9FHuBrNPMJ5I3i2r32yn4UU1kQ04h0f24ZHu02Z6OME6pW9Nlr1hk9PD9UIs »					
//	42	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.42 »					« ywjLRouQBeHtvGNSN2v7a8o0lRKX2vRy8y8iJyNR32n90dn35722r6aBn5ef32U2 »					
//	43	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.43 »					« e03BVwe3ChVq3c02a73OL3h4zUM7F13n80yHM6zh0PnQxPr3q29YKv7SAfF6L4ME »					
//	44	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.44 »					« e7jPP123uwhQ73C3it10DIgbt87pd8w5OX04d6l0T8b1LLE0q63vv9u7Ez3Yp2bj »					
//	45	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.45 »					« hClLw807T474QWAt20J5Wy0wQ639dwfpBIisazlGJMEEIwPDSSEsy77ENyW72iZ7 »					
//	46	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.46 »					« b1731zwTYoStBOFgOhtHtR5SDAY58KmxD80471M4Cw3Bd55Gv7Ei3NLmyx65AF4q »					
//	47	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.47 »					« C4Jy46TlEbuuFtve29v4VP1MCtGNM8Kso7813qTIy8F9kocF8wr62IQ66j9Z6SNU »					
//	48	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.48 »					« 2Gw17M1m92su19n7XhC5OF676a5jQ9PS0M7Nb417z0LPw8oV7M4pU78On716cbWX »					
//	49	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.49 »					« dltLa5bxbCzQ1N9CI6pz62z6s1C1heCp5fnQ4x88lUo91dwD6i298D734ojnTb9T »					
//	50	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.50 »					« zXYMdjYUp8tyRNBpjQcPgAHqe34y6KDm331ha3p1M9o706bxe78AioP211m1c0m3 »					
//	51	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.51 »					« 63LESK05Am2LcR81u49nje6h2lULVMfDlh772WaNl7yNwvhAnr4HNFafyNT913Xd »					
//	52	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.52 »					« 82U3IJaW3aosi64D71wVcpg7itxzrLQ5gANb4zsMLG3Du9Qo393e287gJw8NQLUo »					
//	53	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.53 »					« 0C854xaGGDTfLWF50uSDI1ZD1Q7IP9rnR2PREhlAF318J96XJ5EFDjOC0VhDK8G6 »					
//	54	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.54 »					« 5hAgd4V8imo1Rh9N54XvYm1S8ClSOyB8g6ZAWZO073Vo8ZohXDGukI93hnpxB9d7 »					
//	55	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.55 »					« O04Y69g4jB2u9i2j9pAsx21j5uVkoUbmwsPx5t26235C96QOQRdCN8Ubd03V4Wp5 »					
//	56	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.56 »					« 9ydFfZpyL5S43v5r20sDSIK6gBhgPys9iUbcG41xj7tG1jGA5VroM2Ye5a1qtZL1 »					
//	57	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.57 »					« NBPt2xzy0qed200YWzr4wk8Vt09aabwcDNcGSQ93akMBKXW7yx07rIMK9NLFvg0P »					
//	58	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.58 »					« M12398c9wA0K22L9x8MRd1T8CjyQ3P0mhI4fn7G4gcT767wDyx9sOG0hcfqW6SOf »					
//	59	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.59 »					« z0ud4859C96siZg3i3it37d63ZUjvy7V9H7U0Pe5W1zdXE7478P0nYJ3NuVbnB7A »					
//	60	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.60 »					« 2nzV5RrrD8G9JGzQ2sU0yj1yN6q4ROkVq2ML6X0HAp10ya345588tb9uV8g0xo4B »					
//	61	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.61 »					« 5hJ73s62a8en903q8W93cjoy2558IC4Z1C1WV070N3e357g6nT5av57iHhfVUGf9 »					
//	62	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.62 »					« d0eI48i2Rm16v70252OSrMnD92k6hPmBPVdno1S2bMzHOZd6Rty41HWA0MmXWv62 »					
//	63	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.63 »					« u4HbHna365168p02gUl75uLv1aqW3ny55forx7a3Tf088jynqkQ5UfcpB8VXMdUT »					
//	64	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.64 »					« JHx7A81Gy79zL2DHv41K7Ajznf1n4r7eBSOjnhPUE8B3Cc4RWjsu4f39eGny7Ic1 »					
//	65	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.65 »					« GR66vO2axuhW5Y4Tv2300v85op10zi1RO34Uy44G3w4C74H44eQvx8Z8i8QQeMR7 »					
//	66	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.66 »					« ku21Fg75JALnLs2P236as31bC7XsfPiEC00fc5Hc6763nepQ5Stvr35d9r9V97qO »					
//	67	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.67 »					« u0se6svRvnMhLv43ORbRq6txD5Hx4r3d7XseuZni086xH36RTzCiT2ROBsp68gv3 »					
//	68	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.68 »					« IaDZaB7W7kNSu14QWk4P8pbI6Oo2Yc6s7JVU17mo9CI21jx7AVCcTk3dd4uQm2u5 »					
//	69	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.69 »					« TUWc07I7083Vc7I531uhTNz1LI1o1W1D8cWw62ipa5mM94o86b9rg7bev8ojWt53 »					
//	70	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.70 »					« qRqUz6tCl4QQoj2U6sQ0b7SN0Pgh6t7vm12iuUBQ3DybuQogr07InWAnps3694N3 »					
//	71	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.71 »					« 677lSO3yZEC06F1kcP22IFsAO8qtSC32769qnsQFyEuNrAL8JwQ98ltW3WSu874V »					
//	72	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.72 »					« r8855d55Fmxy7aG4ITm6Zt9E2P7CTGi1ndJWx3d1k5ID2b397PvYQVAe0PQdFOjd »					
//	73	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.73 »					« 4VgA7Y5g1G1O4L5b38yQ7dR4XG0Ql3v7uT4FdWC8hfZ54st659xKPs5S6WV2L6f6 »					
//	74	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.74 »					« 9Z09KgNZc0m6tEp01pBbmp4bNaHF8J6lHTmU0gEEFB55397yuZ8ZsjXbp4s1QNMR »					
//	75	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.75 »					« jW75P4g63l8crcGMUJa1MbovPBice7KTOhZh8jvdaL7vMqJIvu9J00DjauNPwFQQ »					
//	76						0					
//	77	TOTAL INTERMEDIAIRE = 75 Pools de 100 Utilisateurs « payeurs de primes », « payeurs partiels », « preneurs d’assurances subventionnées ».										
//	78	Soit 75 Pools de 400 Utilisateurs « assurés », « bénéficiaires ». Portefeuille KY&C=Y : 7’500 U.										
												
												
												
		}