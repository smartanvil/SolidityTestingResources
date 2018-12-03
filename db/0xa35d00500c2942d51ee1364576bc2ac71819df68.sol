/* This source code is part of CACIB DocChain registered trademark
*  It is provided becaused published in the public blockchain of Ethereum.
*  Reusing this code is forbidden without approbation of CACIB first (<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="553c31303415363478363c377b363a38">[email&#160;protected]</a>)
*  Providing this code in public repository is meant to provide clarity to the mechanism by which the DocChain product works
*/
pragma solidity ^0.4.11;

/**
 * The IEthIdentity interface defines fundamental functionnalities
 * that every Ethereum identity in this framework must implement to be 
 * usable with DocChain principles.
 * 
 * The purpose of implementing IEthIdentity interface is to prove its own identity
 * and let others checking whether any proof has been made by its identity.
 */
interface IEthIdentity {
    
    /**
     * Add proof if it does not exist yet
     *  - address: the smart contract address where the identity proof has been stored (see eSignature contract)
     *  - bytes32: the attribute id or proof id for which the identity owner has made a proof
     */
    function addProof(address, bytes32) public returns(bool);
    
    /**
     * Remove proof of a source if existed
     *  - address: the smart contract address where the identity proof has been stored (see eSignature contract)
     *  - bytes32: the attribute id or proof id to be removed
     */
    function removeProof(address, bytes32) public returns(bool);

    /**
     * Check whether the provided address is the controlling wallet (owner) of the identity
     */
    function checkOwner(address) public constant returns(bool);
    
    /**
     * Get the identity owner name
     */
    function getIdentityName() public constant returns(bytes32);
    
}

/**
 * The implementation of IEthIdentity interface.
 * 
 * This is just an implementation of IEthIdentity interface, other implementation
 * may be different. However, the fundamental functionnalities defined in IEthIdentity
 * interface must be fully implemented to be compatible with the framework.
 */
contract EthIdentity is IEthIdentity {
    
    /**
     * The EthIdentity contract is a prudent identity proof of its owner
     * When contract is created, it assigns the sender of creating contract
     * transaction as its owner. 
     * The contract owner can only be changed by the override owner.
     * The override owner can only be changed by the override owner.
     * Although set as private but they can always be read via the getStorageAt. It saves bytecode in the final structure
     */
    address public owner;
    address private override;
    
    /**
     * The identity name is a string for human readability and visibility
     * but is stored as 32 bytes in order to be used between contract calls.
     */
    bytes32 private identityName;
    
    /**
     * Constructor of EthIdentity contract
     * Only execute once.
     * receives the Name of the identity
     */
    function EthIdentity(bytes32 _name) public {
        owner = msg.sender;
        override = msg.sender;
        identityName = _name;
    }
    
    /**
     * Constants for event type & notifications
     */
    uint constant ERROR_EVENT = 119;
    uint constant INFO_EVENT = 115;
    
    /**
     * This event is used for change notification and outputs the following:
     * - event sender (indexed for filter)
     * - event status (indexed for filter)
     * - event message
     */
    event EventNotification(address indexed sender, uint indexed status, bytes32 message);
    
    /**
     * The list of proofs stored by this identity owner
     * The identity owner can store several proofs for a particular source, hence
     * is defined as a mapping list that use the proof value (attribute) as key
     * Hence the attribute value must be unique accross all sources.
     * 
     * For the eSignature contract, the proof is defined as the document id
     * generated by this contract when the document hash is added/signed by an identity owner.
     * For a wider use, it can be any attribute that is stored by this identity owner, but must be a bytes32 for optimisation.
     */
    mapping(bytes32 => address) proofList;
    
    /**
     * Add a proof ONLY if not already present and ONLY by the identity owner
     * 
     * _source: address of the source (e.g. eSignature contract) where the proof has been stored
     * _attribute: a bytes32 representing the attribute at the source identifying the proof
     * 
     * For eSignature case, _attribute is the document id generated when the identity adds/signs the document
     */
    function addProof(address _source, bytes32 _attribute) public onlyBy(owner) returns(bool) {
        // Check input
        require(_source != address(0x0));
        
        // Check proof existence
        bool existed = checkProof(_attribute);
        
        // Returns and do nothing except emitting event if the proof already exists
        if (existed == true) {
            EventNotification(msg.sender, ERROR_EVENT, "Proof already exist");
            return false;
        }
        
        // Add new proof
        proofList[_attribute] = _source;
        
        EventNotification(msg.sender, INFO_EVENT, "New proof added");
        return true;
    }
    
    /**
     * Remove proof of a source ONLY if present and ONLY by the identity owner
     * 
     * _source: address of the source (e.g. eSignature contract) where the proof has been stored
     * _attribute: a bytes32 representing the attribute at the source identifying the proof
     * 
     * For eSignature case, _attribute is the document id generated when the identity adds/signs the document
     */
    function removeProof(address _source, bytes32 _attribute) public onlyBy(owner) returns(bool) {
        // Check proof existence
        bool existed = checkProof(_attribute);
        
        // Return and do nothing except emitting event if the proof does not exist
        if (existed == false) {
            EventNotification(msg.sender, ERROR_EVENT, "Proof not found");
            return false;
        }
        
        // Return and do nothing except emitting event if the source is not correct
        if (proofList[_attribute] != _source) {
            EventNotification(msg.sender, ERROR_EVENT, "Incorrect source");
            return false;
        }
        
        // Delete existing proof
        delete proofList[_attribute];
        
        EventNotification(msg.sender, INFO_EVENT, "Proof removed");
        return true;
    }
    
    /**
     * Check whether the identity owner has stored a proof with a  source
     * Return true if proof is found
     * 
     * _attribute: a string representing the attribute of the source for which the proof has been made
     * 
     * For eSignature case, _attribute is the document id generated when the identity create/sign the document
     */
    function checkProof(bytes32 _attribute) public constant returns(bool) {
        var source = proofList[_attribute];
        // Check if proof source is assigned & matched
        if (source != address(0x0))
            return true;
        // Proof not exists since its source is not matched    
        return false;
    }
    
    /**
     * Check whether the provided address is the controlling wallet of the identity
     * Return true if yes
     */
    function checkOwner(address _check) public constant returns(bool) {
        return _check == owner;
    }
    
    /**
     * Get the identity owner name, usable inside contract call
     */
    function getIdentityName() public constant returns(bytes32) {
        return identityName;
    }
    
    /**
     * Show the name of the identity in string 
     * (for Etherscan read-only function)
     */
    function nameOfIdentity() public constant returns(string) {
        return bytes32ToString(identityName);
    }
    
    /**
     * Get the identity detail information
     */
    function getIdentityInfo() public constant returns(address, address, string) {
        return (override, owner, bytes32ToString(identityName));
    }
    
     /**
     * Only the identity owner can set its name
     */
    function setIdentityName(bytes32 _newName) public onlyBy(owner) returns(bool) {
        identityName = _newName;
        EventNotification(msg.sender, INFO_EVENT, "Set owner name");
        return true;
    }
    
    /**
     * Only the override address is allowed to change the owner address.
     */
    function setOwner(address _newOwner) public onlyBy(override) returns(bool) {
        owner = _newOwner;
        EventNotification(msg.sender, INFO_EVENT, "Set new owner");
        return true;
    }

    /**
     * Only the override address is allowed to change the override address.
     */
    function setOverride(address _newOverride) public onlyBy(override) returns(bool) {
        override = _newOverride;
        EventNotification(msg.sender, INFO_EVENT, "Set new override");
        return true;
    }
    
    /**
     * Convert bytes32 to string. Set modifier pure which means cannot
     * access the contract storage.
     */
    function bytes32ToString(bytes32 data) internal pure returns (string) {
        bytes memory bytesString = new bytes(32);
        for (uint j=0; j<32; j++){
            if (data[j] != 0) {
                bytesString[j] = data[j];
            }
        }
        return string(bytesString);
    }
    
    /**
     * Modifier to make a constraint on who is permitted
     * to execute a function
     */
    modifier onlyBy(address _authorized) {
        assert(msg.sender == _authorized);
        _;
    }
}