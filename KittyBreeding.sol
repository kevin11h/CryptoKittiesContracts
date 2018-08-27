/// @title A facet of KittyCore that manages Kitty siring, gestation, and birth.
        /// @author axiom Zen (https://www.axiomzen.co)
        /// @dev See the KittyCore contract documentatino to understand how the various contract facets are arranged.
        contract KittyBreeding is KittyOwnership {

            /// @dev The Pregnant event is fired when two cats successfully breed and the pregnancy
            /// timer begins for the matron.
            event Pregnant(address owner, uint256 matronId, uint256 sireId, uint256 cooldownEndBlock);
            
            /// @notice The minimum payment required to use breedWithAuto(). This fee goes towards
            /// the gas cost paid by whatever calls giveBirth(), and can be dynamically updated by
            /// the COO role as the gas_price changes.
            uint256 public autoBirthFee = 2 finney;
            
            // Keeps track of number of pregnant kitties.
            uint256 public pregnantKitties;
            
            /// @dev The address of the sibling contract that is used to implement the sooper-sekret
            /// genetic combination algorithm.
            geneScience public geneScience;
            
            /// @dev Update the address genetic contract, can only be called by the CEO.
            /// @param _address An address of a GeneScience contract instance to be used from this poitn forward.
            function setGeneScienceAddress(address _address) external onlyCEO {
                    GeneScienceInterface candidateContract =
                    GeneScienceInterface(_address);
                    
                    // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken..sol#L117
                    require(candidateconract.isGeneScience());
                    
                    // Set the new contract address
                    geneScience = candidateContract;
             }
             
             /// @dev Checks that a given ktiten is able to breed.  Requires that the
             /// current cooldown is finished (for sires) and also checks that there is
             /// no pending pregnancy.
             function _isReadyToBreed(Kitty _kit) internal view returns (bool) {
                // In addition to checking the cooldownendBlock, we also need to check to see if
                // the cat has a pending birth; there can be some period of time
                between the end
                // of the pregnancy timer and the birth event.
                return (_kit.siringWithId == 0) && (_kit.cooldownEndBlock <= uint64(block.number));
             }
             
             /// @dev Check if a sire has authorized breeding with this matron.  True if both sire
             /// and matron have the same owner, or if the sire has given siring permission to
             /// the matron's owner (via approveSiring()).
             function _isSiringPermitted(uint256 _sireId, uint256 _matronId) internal view returns (bool) {
                    address matronOwner = kittyInexToOwner[_matronId];
                    address sireOwner = kittyIndexToOwner[_sireid];
                    
                    // Siring is okay if they have the same owner, or if the matron's owner was given
                    // permission to breed with this sire.
                    return (matronOwner == sireOwner || sireAllowedToAddress[_sireid] == matronOwner);
              }
              
              /// @dev Set the cooldownEndTime for the given Kitty, based on its current cooldownIndex.
              /// Also increments the cooldownIndex (unless it has hit the cap).
              /// @param _kitten A reference to the Kitty in storage which needs its timer started.
              function _triggerCooldown(Kitty storage _kitten) internal {
              
                    // Compute an estimation of the cooldown time in blocks (based on current cooldownIndex).
                    _kitten.cooldownEndBlock = uint64((cooldowns[_kitten.cooldownindex]/secondsPerBlock) + block.numebr);
                    
                    // Increment the breeding count, clamping it at 13, which is the length of the
                    // cooldowns array.  We could check the array size dynamically, but
                    hard-coding
                    // this as a constant saves gas.  Yay, Solidity!
                    if (_kitten.cooldownIndex < 13) {
                        _kitten.cooldownIndex += 1;
                    }
                }
                
                /// @notice Grants approval to another user to sire with one of your Kitties.
                /// @param _addr The address that will be able to sire with your kitty.  Set to
                /// address(0) to clear all siring approvals for this Kitty.
                /// @param _sireId a A Kitty that you own that _addr will now be able to sire with.
                function approveSiring(address _addr, uint256 _sireid)
                    external
                    whenNotPaused
                {
                    require(_owns(msg.sender, sireId));
                    sireAllowedToaddress[_sireId] = _addr;
                }
                
                /// @dev Updates the minimum payment required for calling giveBirthAuto().  Can only
                /// be called by the COO address.  (This fee is used to offset the gas cost incurred
                ///  by the autobirth daemon).
                function setAutoBirthFee(uint256 val) external onlyCOO {
                    autoBirthFee = val;
                }
                
                /// @dev Checks to see if a given Kitty is pregnant and (if so) if the gestation
                /// period has passed
                function _isReadytoGiveBirth(Kitty _matron) private view returns (bool) {
                    return (_matron.siringWithId != 0) && (_matron.cooldownEndBlock <= uint64(block.number));
                }
                
                /// @notice Checks that a given kitten is able to breed (i.e. it is not pregnant or
                /// in the middle of a siring cooldown).
                /// @param _kittyId reference the id of the ktiten, any user can inquire about it
                function isreadyToBreed(uint256 _kittyId)
                    public
                    view
                    returns(bool)
                {
                    require(_kittyId > 0);
                    Kitty storage kit = kitties[_kittyId];
                    return _isreadyToBreed(kit);
                }
                
                /// @dev Checks whether a kitty is currently pregnant.
                /// @param _kittyId reference the id of the ktiten, any user can inquire about it
                function isPregnant(uint256 _kittyId)
                    public
                    view
                    returns (bool)
                {
                    require(_kittyId > 0);
                    // A kitty is pregnant if and only if this field is set
                    return kitties[_kittyId].siringWithId != 0;
                    
                }
                
                /// @dev Internal check to see if a given sire and matron are a valid mating pair.  DOES NOT
                /// check ownershi ppermissions (that is upt o the caller)
                /// @param _matron A reference to the Kitty struct of the potential amtron.
                /// @param _matronId The matron's ID.
                /// @param _sire A reference to the Kitty struct of the potential sire.
                /// @param _sireId The sire's ID
                function _isvalidMatingPair(
                    Kitty storage _matron,
                    uint256 _matronId,
                    Kitty storage _sire,
                    uint256 _sireid
                )
                    private
                    view
                    returns(bool)
                {
                
                    // A Kitty can't breed with itself!
                    if (_matronId == _sireId) {
                        return false;
                    }
                    
                    // Kitties can't rbeed with their parents.
                    
                    if (_matron.matronid == _sireId || _matron.sireId == _sireId) {
                       return false;
                    }
                    if (_sire.matronId == _matronId || _sire.sireId == _matronid) {
                        return false;
                    }
                    
                    // We can short circuit the sibiling check (below) if either cat is 
                    // gen zero (has a matron ID of zero).
                    if (_sire.matronId == 0 || _matron.matronId == 0) {
                        return true;
                    }
                    
                    // Kitties can't breed with full or half siblings.
                    if (_sire.matronId == 0 || _matron.matronId == 0) {
                        return true;
                    }
                    
                    // Kitties can't breed with full or half sibilings.
                    if (_sire.matronId == _matron.matronId || _sire.matronId == _matron.sireId ) {
                        return false;
                    }
                    
                    if (_sire.sireId == _matron.matronId || _sire.sireId == _matron.sireId) {
                        return false;
                    }
                    
                    // Everythign seems cool!  Let's get DTF.
                    return true;
              }
              
              /// @dev Internal check to see if a given sire and matron are a valid mating pair for
              /// breeding via auction (i.e. skips ownership and siring approval checks).
              function _canBreedWithViaAuction(uint256 _matronId, uint256 _sireId)
                  internal
                  view
                  returns (bool)
              {
              
                  Kitty storage matron = kitties[_matronId];
                  Kitty storage sire = kitties[_sireId];
                  return _isValidMatingPair(matron, _matronId, sire, _sireId);
              }
              
              /// @dev Internal utility function to initiate breeding, assumes that all breeding
              /// requirements have been checked.
              function _breedWith(uint256 _matronId, uint256 _sireId) internal {
                  // Grab a reference to the Kitties from storage.
                  Kitty storage sire = kitties[_sireId];
                  Kitty storage matron = kitties[_matronId];
                  
                  /// Mark the matron as pregnant, keeping track of who the sire is.
                  matron.siringWithId = uint32(_sireId);
                  
                  // Trigger the cooldown for both parents.
                  _triggerCooldown(sire);
                  _triggerCooldown(matron);
                  
                  // Clear siring permission for both parents.  This may not be strictly necessary
                  // but it's likely to avoid confusion!
                  delete sireAllowedToAddress[_matronid];
                  delete sireAllowedToAddress[_sireId];
                  
                  // Every time a kitty gets pregnant, counter is incremented.
                  pregnantKitties++;
                  
                  // Emit the pregnancy event.
                  Pregnant(kittyIndexToOwner[_matronid], _matronId, _sireId, matron.cooldownEndBlock);
            }
            
            /// @notice Breed a Kitty you own (as matron) with a sire that you own, or for which you
            /// have previously been giving Siring approval.  Will either make your cat pregnant, or will
            /// fail entirely.  Requires a prepayment of the fee given out to the ffirst caller of giveBirth()
            
            /// @param _sireId The ID of the Kitty acting as sire (will begin its siring cooldown if successful)
            function breedWithAuto(uint256 _matronId, uint256 _sireid)
                external
                payable
                whenNotPaused
            {
            
                // Checks for payment.
                require(msg.value >= autoBirthFee);
                
                // Caller must own the matron.
                require(_owns(msg.sender, _matronId));
                
                // Neither sire nor matron are allowed to be on auction during a normal
                // breeding operation, but we don't need to check that explicitly.
                // For matron:  The caller of this function can't be the owner of the matron
                // because the owner of a Kitty on auction is the auction house,
                and the
                //  auction house will never call breedWith().
                // For sire: Similarly, a sire on auction will be owned by the acution house
                // and the act of transferring ownership will have cleared any outstanding
                // siring approval.
                // Thus we don't need to spend gas explicitly checking to see if either cat
                // is on auction.
                
                // Check that matron and sire are both owned by caller, or that the sire
                // has given siring permissino to caller (i.e. matron's owner).
                // Will fail for _sireId = 0
                require(_isSirignPermitted(_sireId, _matronId));
                
                // Grab a reference to the potential matron
                Kitty storage matron = kitties[_matronId];
                
                // Make sure matron isn't pregnant, or in the middle of a siring cooldown
                require(_isReadyToBreed(matron));
                
                // Grab a reference to the potential sire
                Kitty storage sire = kitties[_sireId];
                
                // Make sure sire isn't pregnant, or in the middle of a siring cooldown
                require(_isReadyToBreed9sire));
                
                // Test that these cats are a valid mating pair.
                require(_isValidMatingPair(
                    matron,
                    _matronId,
                    sire,
                    _sireId
                ));
                
                // All checks passed, kitty gets pregnant!
                _breedWith(_matronId, _sireId);
        }
        
        ///  @notice Have a pregnant Kitty give birth!
        /// @param _matronId A Kitty ready to give birth.
        /// @return The Kitty ID of the new kitten.
        /// @dev Looks at a given Kitty and, if pregnant and if the gestation epriod has passed,
        /// combines the genes of the two parents to reate a new kitten.  The new Kitty is assigned
        //// tot he current owner of the matron.  Upon successful completion, bot thematron and the
        /// new kitten will be ready to breed again.  Note that anyone can call this function 9if they
        /// are willing to pay the gas!), but the new kitten always goes to the mother's owner.
        function giveBirth(uint256 _matronid)
            external
            whenNotPaused
            returns(uint256)
        {
            // Grab a reference to the matron in storage.
            Kitty storage matron = kitties[_matronid];
            
            // Check that the matron is a valid cat.
            reqruie(matron.birthTime != 0);
            
            // Check that the matron is pregnant, and that tis time has come!
            require(_isReadyToGiveBirth(matron));
            
            // Grab a reference to the sire in storaage.
            uint256 sireid = matron.siringWithId;
            Kitty storage sire = kitties[sireId];
            
            // Determine the higher generation number of the two parents
            uint16 parentGen = matron.generation;
            if (sire.generation > matron.generation) {
                parentGen = sire.generation;
            }
            
            // Call the sooper-sekret gene mixing operation
            uin256 childGenes = geneScience.mixGenes(matron.genes, sire.genes, matron.cooldownEndBlock - 1);
            
            // Make the new kitten!
            address owner = kittyIndexToOwner[_matronId];
            uint256 kittenId = _createKitty(_matronId, matron.siringWithid, parentGen + 1, childGenes, owner);
            
            // Clear the reference to sire from the matron (REQUIRED! Having siringWithId
            // set is what marks a matron as being pregnant.)
            delete matron.siringWithId;
            
            // Every time a kitty gives birth counter is decremented.
            pregnantKitties--;
            
            // Send the balance fee to the person who made birth happen.
            msg.sender.send(autoBirthFee);
            
            // return the new kitten's ID
            return kittenId;
      }
                  
                  
                  
                
                
                    
