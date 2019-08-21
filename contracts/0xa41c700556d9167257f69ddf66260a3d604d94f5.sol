pragma solidity >=0.4.21 <0.6.0;
/*  CABRONTRAIL - MODULE INSCRIPTION / MISE A JOUR DU RCAI
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

//info_concealed (String ASCII convertie en Hex) = 3 premieres lettres du nom du client - premiere lettre du nom du client - 4 dernières lettres du nom du client - 2 premiers chiffres du code postal du client - 4ème chiffre du code postal du client - 2 premières lettres de la ville du client
//client_full (String ASCII convertie en Hex) =  Identité du client au format PNCEE (NOM;PRENOM pour un particulier RAISON SOCIALE;SIRET pour un professionnel) encodée avec l'alogorithme MD5
//address_full (String ASCII convertie en Hex) = Adresse du client au format PNCEE (NUMERO DE VOIE NOM DE VOIE;CODE POSTAL; VILLE) encodée avec l'alogorithme MD5
//declared_for (String ASCII convertie en Hex) = Adresse de l'obligé dans la blockchain (e.g. MGNS. primary address = 0x62073c7c87c988f2Be0EAF41b5c0481df98e886E)

//status = Code parmi la liste suivante
//BACCARA : Test
//1: Client Non Conforme
//2: Droit Suppression GPDR Client 
//3: Erreur Saisie
//4: -
//5: Entrée en relation sans RCAI
//6: Mise à jour fiche
//7: RCAI Antérieur 
//8: Entrée en Relation Arbitrage sans RCAI
//9: RCAI Bloc Actuel 

//Exemple Entrée en relation de MGNS. avec lettre d'engagement envoyée par mail à M. Lucien Renard, 88 impasse du Colonel De Gaulle, 13001 MARSEILLE
//info_concealed : REN-L-ULLE-13-0-MA -> 0x52454E2D4C2D554C4C452D31332D302D4D410A
//client_full : MD5 ("RENARD;LUCIEN") = 7782b8d28bbc0afd1bfc6f84bcd1bceb -> 0x7782b8d28bbc0afd1bfc6f84bcd1bceb
//adress_full : MD5 ("88 IMPASSE DU COLONEL DE GAULLE;13001;MARSEILLE") = 40d3001c5cb5946d1d62b8b1363ec967 -> 0x40d3001c5cb5946d1d62b8b1363ec967
//declared_for :  0x62073c7c87c988f2Be0EAF41b5c0481df98e886E
//status : 9

contract CARBONTRAIL_RCAI {
    event RCAI(
        bytes32 info_concealed,
        bytes32 client_full, 
        bytes32 address_full,
        address declared_by,
        address declared_for,
        uint status,
        uint timestamp,
        uint block
    );

    function newRCAI(bytes32 info_concealed, bytes32 client_full, bytes32 address_full, address declared_for, uint status) public  {
        emit RCAI(info_concealed, client_full, address_full, msg.sender, declared_for, status, block.timestamp, block.number);
    }

    event URCAI(
        bytes32 client_full, 
        bytes32 address_full,
        address declared_by,
        address declared_for,
        uint status,
        uint timestamp,
        uint block
    );

function updateRCAI(bytes32 client_full, bytes32 address_full, address declared_for, uint status) public  {
        emit URCAI(client_full, address_full, msg.sender, declared_for, status, block.timestamp, block.number);
    }
}