pragma solidity ^0.4.18;

// File: contracts/Certification.sol

contract Certification  {

  /**
    * Address of certifier contract this certificate belongs to.
    */
  address public certifierAddress;

  string public CompanyName;
  string public Norm;
  string public CertID;
  string public issued;
  string public expires;
  string public Scope;
  string public issuingBody;

  /**
    * Constructor.
    *
    * @param _CompanyName Name of company name the certificate is issued to.
    * @param _Norm The norm.
    * @param _CertID Unique identifier of the certificate.
    * @param _issued Timestamp (Unix epoch) when the certificate was issued.
    * @param _expires Timestamp (Unix epoch) when the certificate will expire.
    * @param _Scope The scope of the certificate.
    * @param _issuingBody The issuer of the certificate.
    */
  function Certification(string _CompanyName,
      string _Norm,
      string _CertID,
      string _issued,
      string _expires,
      string _Scope,
      string _issuingBody) public {

      certifierAddress = msg.sender;

      CompanyName = _CompanyName;
      Norm =_Norm;
      CertID = _CertID;
      issued = _issued;
      expires = _expires;
      Scope = _Scope;
      issuingBody = _issuingBody;
  }

  /**
    * Extinguish this certificate.
    *
    * This can be done the same certifier contract which has created
    * the certificate in the first place only.
    */
  function deleteCertificate() public {
      require(msg.sender == certifierAddress);
      selfdestruct(tx.origin);
  }

}

// File: contracts/Certifier.sol

/**
  * @title   Certification Contract
  * @author  Chainstep GmbH
  *
  * This contract represents the singleton certificate registry.
  */
contract Certifier {

    /** @dev Dictionary of all Certificate Contracts issued by the Certifier.
             Stores the Certification key derived from the sha(CertID) and stores the
             address where the coresponding Certificate is stored. */
    mapping (bytes32 => address) public CertificateAddresses;

    /** @dev Dictionary that stores which addresses are owned by Certification administrators */
    mapping (address => bool) public CertAdmins;

    /** @dev stores the address of the Global Administrator*/
    address public GlobalAdmin;

    event CertificationSet(string _certID, address _certAdrress, uint setTime);
    event CertificationDeleted(string _certID, address _certAdrress, uint delTime);
    event CertAdminAdded(address _certAdmin);
    event CertAdminDeleted(address _certAdmin);
    event GlobalAdminChanged(address _globalAdmin);



    /**
      * Constructor.
      *
      * The creator of this contract becomes the global administrator.
      */
    function Certifier() public {
        GlobalAdmin = msg.sender;
    }

    // Functions

    /**
      * Create a new certificate contract.
      * This can be done by an certificate administrator only.
      *
      * @param _CompanyName Name of company name the certificate is issued to.
      * @param _Norm The norm.
      * @param _CertID Unique identifier of the certificate.
      * @param _issued Timestamp (Unix epoch) when the certificate was issued.
      * @param _expires Timestamp (Unix epoch) when the certificate will expire.
      * @param _Scope The scope of the certificate.
      * @param _issuingBody The issuer of the certificate.
      */
    function setCertificate(string _CompanyName,
                            string _Norm,
                            string _CertID,
                            string _issued,
                            string _expires,
                            string _Scope,
                            string _issuingBody) public onlyCertAdmin {
        bytes32 certKey = getCertKey(_CertID);

        CertificateAddresses[certKey] = new Certification(_CompanyName,
                                                               _Norm,
                                                               _CertID,
                                                               _issued,
                                                               _expires,
                                                               _Scope,
                                                               _issuingBody);
        CertificationSet(_CertID, CertificateAddresses[certKey], now);
    }

    /**
      * Delete an exisiting certificate.
      *
      * This can be done by an certificate administrator only.
      *
      * @param _CertID Unique identifier of the certificate to delete.
      */
    function delCertificate(string _CertID) public onlyCertAdmin {
        bytes32 certKey = getCertKey(_CertID);

        Certification(CertificateAddresses[certKey]).deleteCertificate();
        CertificationDeleted(_CertID, CertificateAddresses[certKey], now);
        delete CertificateAddresses[certKey];
    }

    /**
      * Register a certificate administrator.
      *
      * This can be done by the global administrator only.
      *
      * @param _CertAdmin Address of certificate administrator to be added.
      */
    function addCertAdmin(address _CertAdmin) public onlyGlobalAdmin {
        CertAdmins[_CertAdmin] = true;
        CertAdminAdded(_CertAdmin);
    }

    /**
      * Delete a certificate administrator.
      *
      * This can be done by the global administrator only.
      *
      * @param _CertAdmin Address of certificate administrator to be removed.
      */
    function delCertAdmin(address _CertAdmin) public onlyGlobalAdmin {
        delete CertAdmins[_CertAdmin];
        CertAdminDeleted(_CertAdmin);
    }
    /**
      * Change the address of the global administrator.
      *
      * This can be done by the global administrator only.
      *
      * @param _GlobalAdmin Address of new global administrator to be set.
      */
    function changeGlobalAdmin(address _GlobalAdmin) public onlyGlobalAdmin {
        GlobalAdmin=_GlobalAdmin;
        GlobalAdminChanged(_GlobalAdmin);

    }

    // Constant Functions

    /**
      * Determines the address of a certificate contract.
      *
      * @param _CertID Unique certificate identifier.
      * @return Address of certification contract.
      */
    function getCertAddressByID(string _CertID) public constant returns (address) {
        return CertificateAddresses[getCertKey(_CertID)];
    }

    /**
      * Derives an unique key from a certificate identifier to be used in the
      * global mapping CertificateAddresses.
      *
      * This is necessary due to certificate identifiers are of type string
      * which cannot be used as dictionary keys.
      *
      * @param _CertID The unique certificate identifier.
      * @return The key derived from certificate identifier.
      */
    function getCertKey(string _CertID) public pure returns (bytes32) {
        return sha256(_CertID);
    }


    // Modifiers

    /**
      * Ensure that only the global administrator is able to perform.
      */
    modifier onlyGlobalAdmin () {
        require(msg.sender==GlobalAdmin);
        _;
    }

    /**
      * Ensure that only a certificate administrator is able to perform.
      */
    modifier onlyCertAdmin () {
        require(CertAdmins[msg.sender]);
        _;
    }

}
/**
  * @title   Certificate Contract
  * @author  Chainstep GmbH
  *
  * Each instance of this contract represents a single certificate.
  */