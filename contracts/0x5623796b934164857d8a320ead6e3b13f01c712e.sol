pragma solidity >=0.4.21 <0.6.0;
/*  CARBONTRAIL - MODULE OPESTA
    Copyright (C) MXIX VALTHEFOX FOR MGNS. CAPITAL

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    See https://www.gnu.org/licenses/ for full terms.*/

//------VARIABLES---------

//reference_interne (String ASCII convertie en Hex) = Référence dossier
//fiche (String ASCII convertie en Hex) = Référence fiche_opération_standardisée
//volumekWh(Integer) = Volume de CEE  en kWh CUMAC
//date_engagement(Integer) = Nombre de secondes entre le 1er Janvier 1970 et la date d'engagement de l'opération
//date_facture(Integer) = Nombre de secondes entre le 1er Janvier 1970 et la date de facture
//pro = (String ASCII convertie en Hex) =  Identité du pro au format PNCEE (RAISON SOCIALE;SIREN;ou RAISON SOCIALE;SIREN SOUS TRAITANT;RAISON SOCIALE;SIREN SOUS TRAITANT) encodée avec l'alogorithme MD5
//client_full (String ASCII convertie en Hex) =  Identité du client au format PNCEE (NOM;PRENOM pour un particulier RAISON SOCIALE;SIREN pour un professionnel) encodée avec l'alogorithme MD5
//address_full (String ASCII convertie en Hex) = Adresse de réalisation de l'opération au format PNCEE (NUMERO DE VOIE NOM DE VOIE;CODE POSTAL; VILLE) encodée avec l'alogorithme MD5
//declared_for (String ASCII convertie en Hex) = Adresse de l'obligé dans la blockchain (e.g. MGNS. primary address = 0x62073c7c87c988f2Be0EAF41b5c0481df98e886E)

//nature_bon = Code parmi la liste suivante
//BACCARA : Arbitrage
//1 : Contribution financière (monnaie fiducaire ou cryptomonnaie) 
//2 : Bon d'achat pour des produits de consommation courante
//3 : Prêt bonifié
//4 : Audit ou conseil
//5 : Produit ou service offert
//6 : Opération réalisée sur patrimoine propre


//status = Code parmi la liste suivante
//BACCARA : Test
//1: Annulation Non Conformité
//2: Annulation Droit Suppression GPDR Client 
//3: Annulation Erreur Saisie
//4: -
//5: Documents reçus 
//6: Validé interne
//7: Déposé PNCEE
//8: Arbitrage
//9: Validé PNCEE

//Exemple MGNS. s'engage le 16/01/2019 a poser gratuitement des mousseurs sur les 750 robinets de l'ECOLE DE CIRQUE PITRERIES 2 RUE DE STRASBOURG 83210 SOLLIES PONT SIRET 42493526000036. Posé et facturé par FRANCE MERGUEZ DISTRIBUTION SIRET 34493368400021 le 17/01/2019. ASH numéro MPE400099. Enregistrement dans la blockchain lors du dépot au PNCEE.
//client_full : MD5 ("ECOLE DE CIRQUE PITRERIES;42493526") = 95be74bce973b492a060a4a5e38fb916 -> 0x95be74bce973b492a060a4a5e38fb916
//adress_full : MD5 ("2 RUE DE STRASBOURG;83210;SOLLIES PONT") = c86f2d95804c4af2a1cbf85d64df29e0 -> 0xc86f2d95804c4af2a1cbf85d64df29e0
//pro : MD5 ("FRANCE MERGUEZ DISTRIBUTION;344933684") = 4cf60fe171f7487aedb1c0892f2614eb -> 0x4cf60fe171f7487aedb1c0892f2614eb
//declared_for :  0x62073c7c87c988f2Be0EAF41b5c0481df98e886E
//nature_bon : 5
//status : 7
//reference_interne : MPE400099 -> 0x4D50453430303039390A
//fiche : BAT-EQ-133 -> 0x4241542D45512D3133330A
//volumekWh : 2031750
//date_engagement : 1547659037
//date_facture : 1547745437

contract CARBONTRAIL_OPESTA {
    event OPESTA(
        bytes32 client_full, 
        bytes32 address_full,
        bytes32 pro,
        address declared_by,
        address declared_for,
        uint nature_bon,
        uint status,
        bytes32 reference_interne,
        bytes32 fiche,
        uint volumekWh,
        uint date_engagement,
        uint date_facture,
        uint timestamp,
        uint block
    );

    function newOPESTA(bytes32 client_full, bytes32 address_full, bytes32 pro, address declared_for, uint nature_bon, uint status, bytes32 reference_interne, bytes32 fiche, uint volumekWh, uint date_engagement, uint date_facture) public  {
        emit OPESTA(client_full, address_full, pro, msg.sender, declared_for, nature_bon, status, reference_interne, fiche, volumekWh, date_engagement, date_facture, block.timestamp, block.number);
    }
    
    event UOPESTA(
        bytes32 client_full, 
        bytes32 address_full,
        bytes32 pro,
        address declared_by,
        address declared_for,
        uint nature_bon,
        uint status,
        bytes32 reference_interne,
        bytes32 fiche,
        uint volumekWh,
        uint date_engagement,
        uint date_facture,
        uint timestamp,
        uint block
    );

    function updateOPESTA(bytes32 client_full, bytes32 address_full, bytes32 pro, address declared_for, uint nature_bon, uint status, bytes32 reference_interne, bytes32 fiche, uint volumekWh, uint date_engagement, uint date_facture) public  {
        emit UOPESTA(client_full, address_full, pro, msg.sender, declared_for, nature_bon, status, reference_interne, fiche, volumekWh, date_engagement, date_facture, block.timestamp, block.number);
    }
}