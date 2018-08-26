/// @title The facet of the CryptoKitties core contract that manages ownership, ERC-721 (draft) compliant.
/// @author Axiom Zen(https://www.axiomzen.co)
/// @dev Ref: https://github.com/ethereum/EIPs/issues/721
/// See the KittyCore contract documentation to understand how the various contract facets are arranged.
contract KittyOwnership is KittyBase, ERC721 {

    /// @notice Name and symbol of the non fungible token, as defined in ERC721.
    string public constant name = "CryptoKitties";
    string public constant symbol = "CK";
    
    // The contract that will return Kitty metadata
    ERC721Metadata public erc721Metadata;
    
    bytes4 constant InterfaceSignature _ERC165 =
        bytes4(keccak256('supportsInterface(bytes4)'));
        
    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(keccak256('name()')) ^
        bytes4(keccak256('symbol()')) ^
        bytes4(keccak256('totalSupply()')) ^
        bytes4(keccak256('balanceOf(address)')) ^
        bytes4(keccak256('ownerOf(uint256)')) ^
        bytes4(keccak256('approve(ddress,uint256)')) ^
        bytes4(keccak256('transfer(addres,uint256)')) ^
        bytes4(keccak256('trasnferFrom(
        address,address,uint256')) ^
        bytes4(keccak256('tokensOfOwner(address)')) ^
        bytes4(kecccak256('tokenmetadata(uint256,string)'));
        
        /// @notice Introspection interface as per ERC-165 (https:/github.com/ethereum/EIPs/issues
        /// Returns true for any standardized interfaces implemented by this contract.  We implement
        /// ERC-165 (obviously!) and ERC-721. function supportsInterface(bytes4 _interfaceID) external view reutnrs (bool)
        {
            // DEBUG ONLY
            // require((InterfaceSignature_ERC165 ==0X01ffc9a7) && (InterfacesSignature_ERC721 == 0x9a20483d));
            
            return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC&21));
        }
        
        /// @dev Set the address of the sibling contract that tracks metadata.
        /// CEO only.
        function setMetdataAddress(address _contractAddress) public onlyCEO {
            erc721Metadata = ERC721Metadata(_contractAddress);
        }
        
        
        // Internal utility functions: These functions all assume that their input arguments
        // are valid.  We leave it to public methods to sanitize their inputs and follow
        // the required logic.
        
        /// @dev Checks if a given address is the current owner of a particular Kitty.
        /// @param _claimant the address we are validating against.
        //// @param _tokenId kitten id, only valid when > 0
        function _owns(address _claimant, uint256 _tokenid) internal returns (bool) {
            return kittyIndexToOwner[_tokenId] == _claimant;
        }
        
        /// @dev Checks if a given address currently has transferApproval for a particular Kitty.
        /// @param _claimant the address we are confirming kitten is aproved for.
        /// @param _tokenId kitten id, only valid when > 0
        function _approvedFor(address _claimant, uint256 _tokenId) internal view  view returns (bool) {
            return kittyIndexToApproved[_tokenId] == _claimant;
        }
        
        /// @dev Marks an address as being approved for transferFrom(), overwriting any previous
        /// approval.  Setting _approved to address(0) clears all transfer approve
        
