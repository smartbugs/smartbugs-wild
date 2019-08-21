pragma solidity 		^0.4.8	;						
											
		contract	Ownable		{						
			address	owner	;						
											
			function	Ownable	() {						
				owner	= msg.sender;						
			}								
											
			modifier	onlyOwner	() {						
				require(msg.sender ==		owner	);				
				_;							
			}								
											
			function 	transfertOwnership		(address	newOwner	)	onlyOwner	{	
				owner	=	newOwner	;				
			}								
		}									
											
											
											
		contract	YUZHURALZOLOTO_FORM_01				is	Ownable	{		
											
			string	public	constant	name =	"	YUZHURALZOLOTO_FORM_01		"	;
			string	public	constant	symbol =	"	UZU_01		"	;
			uint32	public	constant	decimals =		18			;
			uint	public		totalSupply =		0			;
											
			mapping (address => uint) balances;								
			mapping (address => mapping(address => uint)) allowed;								
											
			function mint(address _to, uint _value) onlyOwner {								
				assert(totalSupply + _value >= totalSupply && balances[_to] + _value >= balances[_to]);							
				balances[_to] += _value;							
				totalSupply += _value;							
			}								
											
			function balanceOf(address _owner) constant returns (uint balance) {								
				return balances[_owner];							
			}								
											
			function transfer(address _to, uint _value) returns (bool success) {								
				if(balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {							
					balances[msg.sender] -= _value; 						
					balances[_to] += _value;						
					return true;						
				}							
				return false;							
			}								
											
			function transferFrom(address _from, address _to, uint _value) returns (bool success) {								
				if( allowed[_from][msg.sender] >= _value &&							
					balances[_from] >= _value 						
					&& balances[_to] + _value >= balances[_to]) {						
					allowed[_from][msg.sender] -= _value;						
					balances[_from] -= _value;						
					balances[_to] += _value;						
					Transfer(_from, _to, _value);						
					return true;						
				}							
				return false;							
			}								
											
			function approve(address _spender, uint _value) returns (bool success) {								
				allowed[msg.sender][_spender] = _value;							
				Approval(msg.sender, _spender, _value);							
				return true;							
			}								
											
			function allowance(address _owner, address _spender) constant returns (uint remaining) {								
				return allowed[_owner][_spender];							
			}								
											
			event Transfer(address indexed _from, address indexed _to, uint _value);								
			event Approval(address indexed _owner, address indexed _spender, uint _value);								
										
											
											
											
//	1	Possible 1.1 « crédit »					« Défaut obligataire, obilgation (i), nominal »				
//	2	Possible 1.2 « crédit »					« Défaut obligataire, obilgation (i), intérêts »				
//	3	Possible 1.3 « crédit »					« Défaut obligataire, obilgation (iI), nominal »				
//	4	Possible 1.4 « crédit »					« Défaut obligataire, obilgation (ii), intérêts »				
//	5	Possible 1.5 « crédit »					« Assurance-crédit, support = police (i) »				
//	6	Possible 1.6 « crédit »					« Assurance-crédit, support = portefeuille de polices (j) »				
//	7	Possible 1.7 « crédit »					« Assurance-crédit, support = indice de polices (k) »				
//	8	Possible 1.8 « crédit »					« Assurance-crédit export, support = police (i) »				
//	9	Possible 1.9 « crédit »					« Assurance-crédit export, support = portefeuille de polices (j) »				
//	10	Possible 1.10 « crédit »					« Assurance-crédit export, support = indice de polices (k) »				
//	11	Possible 2.1 « liquidité »					« Trésorerie libre »				
//	12	Possible 2.2 « liquidité »					« Capacité temporaire à générer des flux de trésorerie libre »				
//	13	Possible 2.3 « liquidité »					« Capacités structurelles à générer ces flux »				
//	14	Possible 2.4 « liquidité »					« Accès aux découverts à court terme »				
//	15	Possible 2.5 « liquidité »					« Accès aux découverts à moyen terme »				
//	16	Possible 2.6 « liquidité »					« Accès aux financements bancaires »				
//	17	Possible 2.7 « liquidité »					« Accès aux financements institutionnels non-bancaires »				
//	18	Possible 2.8 « liquidité »					« Accès aux financements de pools pair à pair »				
//	19	Possible 2.9 « liquidité »					« IP-Matrice entités »				
//	20	Possible 2.10 « liquidité »					« IP-Matrice juridictions »				
//	21	Possible 3.1 « solvabilité »					« Niveau du ratio de solvabilité »				
//	22	Possible 3.2 « solvabilité »					« Restructuration »				
//	23	Possible 3.3 « solvabilité »					« Redressement »				
//	24	Possible 3.4 « solvabilité »					« Liquidation »				
//	25	Possible 3.5 « solvabilité »					« Déclaration de faillite, statut (i) »				
//	26	Possible 3.6 « solvabilité »					« Déclaration de faillite, statut (ii) »				
//	27	Possible 3.7 « solvabilité »					« Déclaration de faillite, statut (iii) »				
//	28	Possible 3.8 « solvabilité »					« Faillite effective / de fait »				
//	29	Possible 3.9 « solvabilité »					« IP-Matrice entités »				
//	30	Possible 3.10 « solvabilité »					« IP-Matrice juridictions »				
//	31	Possible 4.1 « états financiers »					« Chiffres d'affaires »				
//	32	Possible 4.2 « états financiers »					« Taux de rentabilité »				
//	33	Possible 4.3 « états financiers »					« Eléments bilantiels »				
//	34	Possible 4.4 « états financiers »					« Eléments relatifs aux ngagements hors-bilan »				
//	35	Possible 4.5 « états financiers »					« Eléments relatifs aux engagements hors-bilan : assurances sociales »				
//	36	Possible 4.6 « états financiers »					« Eléments relatifs aux engagements hors-bilan : prestations de rentes »				
//	37	Possible 4.7 « états financiers »					« Capacités de titrisation »				
//	38	Possible 4.8 « états financiers »					« Simulations éléments OBS (i) »				
//	39	Possible 4.9 « états financiers »					« Simulations éléments OBS (ii) »				
//	40	Possible 4.10 « états financiers »					« Simulations éléments OBS (iii) »				
//	41	Possible 5.1 « fonctions marchés »					« Ressources informationnelles brutes »				
//	42	Possible 5.2 « fonctions marchés »					« Ressources prix indicatifs »				
//	43	Possible 5.3 « fonctions marchés »					« Ressources prix fermes »  / « Carnets d'ordres »				
//	44	Possible 5.4 « fonctions marchés »					« Routage »				
//	45	Possible 5.5 « fonctions marchés »					« Négoce »				
//	46	Possible 5.6 « fonctions marchés »					« Places de marché »				
//	47	Possible 5.7 « fonctions marchés »					« Infrastructures matérielles »				
//	48	Possible 5.8 « fonctions marchés »					« Infrastructures logicielles »				
//	49	Possible 5.9 « fonctions marchés »					« Services de maintenance »				
//	50	Possible 5.10 « fonctions marchés »					« Solutions de renouvellement »				
//	51	Possible 6.1 « métiers post-marchés »					« Accès contrepartie centrale »				
//	52	Possible 6.2 « métiers post-marchés »					« Accès garant »				
//	53	Possible 6.3 « métiers post-marchés »					« Accès dépositaire » / « Accès dépositaire-contrepartie centrale »				
//	54	Possible 6.4 « métiers post-marchés »					« Accès chambre de compensation »				
//	55	Possible 6.5 « métiers post-marchés »					« Accès opérateur de règlement-livraison »				
//	56	Possible 6.6 « métiers post-marchés »					« Accès teneur de compte »				
//	57	Possible 6.7 « métiers post-marchés »					« Accès marchés prêts-emprunts de titres »				
//	58	Possible 6.8 « métiers post-marchés »					« Accès rémunération des comptes de devises en dépôt »				
//	59	Possible 6.9 « métiers post-marchés »					« Accès rémunération des comptes d'actifs en dépôt »				
//	60	Possible 6.10 « métiers post-marchés »					« Accès aux mécanismes de dépôt et appels de marge »				
//	61	Possible 7.1 « services financiers annexes »					« Système international de notation / sphère (i) »				
//	62	Possible 7.2 « services financiers annexes »					« Système international de notation / sphère (ii) »				
//	63	Possible 7.3 « services financiers annexes »					« Ressources informationnelles : études et recherches / sphère (i) »				
//	64	Possible 7.4 « services financiers annexes »					« Ressources informationnelles : études et recherches / sphère (ii) »				
//	65	Possible 7.5 « services financiers annexes »					« Eligibilité, groupe (i) »				
//	66	Possible 7.6 « services financiers annexes »					« Eligibilité, groupe (ii) »				
//	67	Possible 7.7 « services financiers annexes »					« Identifiant système de prélèvements programmables »				
//	68	Possible 7.8 « services financiers annexes »					« Ressources actuarielles »				
//	69	Possible 7.9 « services financiers annexes »					« Services fiduciaires »				
//	70	Possible 7.10 « services financiers annexes »					« Standards de prévention et remise sur primes de couverture »				
//	71	Possible 8.1 « services financiers annexes »					« Négoce / front »				
//	72	Possible 8.2 « services financiers annexes »					« Négoce / OTC »				
//	73	Possible 8.3 « services financiers annexes »					« Contrôle / middle »				
//	74	Possible 8.4 « services financiers annexes »					« Autorisation / middle »				
//	75	Possible 8.5 « services financiers annexes »					« Comptabilité / back »				
//	76	Possible 8.6 « services financiers annexes »					« Révision interne »				
//	77	Possible 8.7 « services financiers annexes »					« Révision externe »				
//	78	Possible 8.8 « services financiers annexes »					« Mise en conformité »				
											
											
											
											
//	79	Possible 9.1 « système bancaire »					« National »				
//	80	Possible 9.2 « système bancaire »					« International »				
//	81	Possible 9.3 « système bancaire »					« Holdings-filiales-groupes »				
//	82	Possible 9.4 « système bancaire »					« Système de paiement sphère (i = pro) »				
//	83	Possible 9.5 « système bancaire »					« Système de paiement sphère (ii = v) »				
//	84	Possible 9.6 « système bancaire »					« Système de paiement sphère (iii = neutre) »				
//	85	Possible 9.7 « système bancaire »					« Système d'encaissement sphère (i = pro) »				
//	86	Possible 9.8 « système bancaire »					« Système d'encaissement sphère (ii = v) »				
//	87	Possible 9.9 « système bancaire »					« Système d'encaissement sphère (iii = neutre) »				
//	88	Possible 9.10 « système bancaire »					« Confer <fonctions marché> (*) »				
//	89	Possible 10.1 « système financier »					« Confer <métiers post-marché> (**) »				
//	90	Possible 10.2 « système financier »					« Configuration spécifique Mikolaïev »				
//	91	Possible 10.3 « système financier »					« Configuration spécifique Donetsk »				
//	92	Possible 10.4 « système financier »					« Configuration spécifique Louhansk »				
//	93	Possible 10.5 « système financier »					« Configuration spécifique Sébastopol »				
//	94	Possible 10.6 « système financier »					« Configuration spécifique Kharkiv »				
//	95	Possible 10.7 « système financier »					« Configuration spécifique Makhachkala »				
//	96	Possible 10.8 « système financier »					« Configuration spécifique Apraksin Dvor »				
//	97	Possible 10.9 « système financier »					« Configuration spécifique Chelyabinsk »				
//	98	Possible 10.10 « système financier »					« Configuration spécifique Oziorsk »				
//	99	Possible 11.1 « système monétaire »					« Flux de revenus et transferts courants » / « IP »				
//	100	Possible 11.2 « système monétaire »					« Flux de revenus et transferts courants » / « OP »				
//	101	Possible 11.3 « système monétaire »					« Changes, devise (i) »				
//	102	Possible 11.4 « système monétaire »					« Changes, devise (ii) »				
//	103	Possible 11.5 « système monétaire »					« Instruments monétaires dérivés »				
//	104	Possible 11.6 « système monétaire »					« swaps »				
//	105	Possible 11.7 « système monétaire »					« swaptions »				
//	106	Possible 11.8 « système monétaire »					« solutions croisées chiffrées-fiat »				
//	107	Possible 11.9 « système monétaire »					« solutions de ponts inter-chaînes »				
//	108	Possible 11.10 « système monétaire »					« solutions de sauvegarde inter-chaînes »				
//	109	Possible 12.1 « marché assurantiel & réassurantiel »					« Juridique »				
//	110	Possible 12.2 « marché assurantiel & réassurantiel »					« Responsabilité envers les tiers »				
//	111	Possible 12.3 « marché assurantiel & réassurantiel »					« Sanctions »				
//	112	Possible 12.4 « marché assurantiel & réassurantiel »					« Géopolitique »				
//	113	Possible 12.5 « marché assurantiel & réassurantiel »					« Expropriations »				
//	114	Possible 12.6 « marché assurantiel & réassurantiel »					« Compte séquestre »				
//	115	Possible 12.7 « marché assurantiel & réassurantiel »					« Accès réseau de courtage »				
//	116	Possible 12.8 « marché assurantiel & réassurantiel »					« Accès titrisation »				
//	117	Possible 12.9 « marché assurantiel & réassurantiel »					« Accès syndicats »				
//	118	Possible 12.10 « marché assurantiel & réassurantiel »					« Accès pools mutuels de pair à pair »				
//	119	Possible 13.1 « instruments financiers »					« Matrice : marché primaire / marché secondaire / pools »				
//	120	Possible 13.2 « instruments financiers »					« Schéma de marché non-régulé »				
//	121	Possible 13.3 « instruments financiers »					« Schéma de marché non-organisé »				
//	122	Possible 13.4 « instruments financiers »					« Schéma de marché non-systématique »				
//	123	Possible 13.5 « instruments financiers »					« Schéma de marché contreparties institutionnelles »				
//	124	Possible 13.6 « instruments financiers »					« Schéma de chiffrement financier - Finance / états financiers »				
//	125	Possible 13.7 « instruments financiers »					« Schéma de chiffrement financier - Banque / ratio de crédit»				
//	126	Possible 13.8 « instruments financiers »					« Schéma de chiffrement financier - Assurance / provisions »				
//	127	Possible 13.9 « instruments financiers »					« Schéma de déconsolidation »				
//	128	Possible 13.10 « instruments financiers »					« Actions »				
//	129	Possible 13.11 « instruments financiers »					« Certificats »				
//	130	Possible 13.12 « instruments financiers »					« Droits associés »				
//	131	Possible 13.13 « instruments financiers »					« Obligations »				
//	132	Possible 13.14 « instruments financiers »					« Coupons »				
//	133	Possible 13.15 « instruments financiers »					« Obligations convertibles »				
//	134	Possible 13.16 « instruments financiers »					« Obligations synthétiques »				
//	135	Possible 13.17 « instruments financiers »					« Instruments financiers dérivés classiques / <plain vanilla> »				
//	136	Possible 13.18 « instruments financiers »					« Instruments financiers dérivés sur-mesure, négociés de gré à gré »				
//	137	Possible 13.19 « instruments financiers »					« Produits structurés »				
//	138	Possible 13.20 « instruments financiers »					« Garanties »				
//	139	Possible 13.21 « instruments financiers »					« Cov-lite »				
//	140	Possible 13.22 « instruments financiers »					« Contrats adossés à des droits financiers »				
//	141	Possible 13.23 « instruments financiers »					« Contrats de permutation du risque d'impayé / cds »				
//	142	Possible 13.24 « instruments financiers »					« Contrats de rehaussement »				
//	143	Possible 13.25 « instruments financiers »					« Contrats commerciaux »				
//	144	Possible 13.26 « instruments financiers »					« Indices »				
//	145	Possible 13.27 « instruments financiers »					« Indices OP »				
//	146	Possible 13.28 « instruments financiers »					« Financements (i) »				
//	147	Possible 13.29 « instruments financiers »					« Financements (ii) »				
//	148	Possible 13.30 « instruments financiers »					« Financements (iii) »				
//	149	Empreinte 1.1 « document annexe »					« Couverture relative aux clauses éventuelles de non-réexportation »				
//	150	Empreinte 1.2 « document annexe »					« Couverture SDNs »				
//	151	Empreinte 1.3 « document annexe »					« Couverture investigations du régulateur »				
//	152	Empreinte 1.4 « document annexe »					« Couverture investigations privées »				
//	153	Empreinte 1.5 « document annexe »					« Couverture renseignement civil »				
//	154	Empreinte 1.6 « document annexe »					« Couverture renseignement militaire »				
//	155	Empreinte 1.7 « document annexe »					« Programmes d'apprentissage »				
//	156	Empreinte 1.8 « document annexe »					« Programmes d'apprentissage autonomes en intelligence économique »				
											
}