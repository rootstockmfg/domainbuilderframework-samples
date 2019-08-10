/**
 * Copyright 2019 
 * The Danville Group dba Rootstock Software
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
 * and associated documentation files (the "Software"), to deal in the Software without restriction, 
 * including without limitation the rights to use, copy, modify, merge, publish, distribute, 
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
 * is furnished to do so, subject to the following conditions:
 * 
 * - The above copyright notice and this permission notice shall be included in 
 *      all copies or substantial portions of the Software.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Rootstock Software, The Danville Group, nor the names of its 
 *      contributors may be used to endorse or promote products derived from this software 
 *      without specific prior written permission.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
 * BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
public inherited sharing class DemoStory extends dbf_DomainBuilderstory {
    public override List<Narrator> narrators() {
        return  (new List<Narrator> {
            //Add an Account for the Twin Peaks Company
            narrate() 
                .over(AccountTwinPeaksNarr.class),
            //Create Contacts and assign them to the Account above
            narrate()
                .over(ContactJosephHendersonNarr.class)
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(Contact.AccountId)
                        .toNarrative(AccountTwinPeaksNarr.class)
                        .whereField(Account.Name)
                        .hasValue('Twin Peaks Construction')
                ),  
            narrate()
                .over(ContactSamanthaHutchinsNarr.class)
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(Contact.AccountId)
                        .toNarrative(AccountTwinPeaksNarr.class)
                        .whereField(Account.Name)
                        .hasValue('Twin Peaks Construction')
                ),
 
            //Add an Account for the Expedited Construction Company
            narrate()
                .over(AccountExpConstrNarr.class),
            //Create Contacts and assign them to the Account above
            narrate()
                .over(ContactRyanJacksonNarr.class)
                .relate(
                    newdbf_DomainBuilderStory.Relation()
                        .onField(Contact.AccountId)
                        .toNarrative(AccountExpConstrNarr.class)
                        .whereField(Account.Name)
                        .hasValue('Expedited Construction')
                ),
            narrate()
                .over(ContactBeverlySheehyNarr.class)
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(Contact.AccountId)
                        .toNarrative(AccountExpConstrNarr.class)
                        .whereField(Account.Name)
                        .hasValue('Expedited Construction')
                ),
            
            //Add an Contractor PriceBook Narrative
            narrate().over(PriceBook2ContractorNarr.class),
            //Create the Government Price Book Narrative 
            narrate().over(PriceBook2GovtNarr.class),

            //Add the five product Narratives
            //Add the Cement Truck Narrative
            narrate().over(Product2CementTruckNarr.class),
            //add the LapTop Narrative
            narrate().over(Product2LaptopNarr.class),
            //Add the Mobile Command Trailer Narrative
            narrate().over(Product2MobileCommandTrailerNarr.class),
            //Add the Safety Vest Narrative
            narrate().over(Product2SafetyVestNarr.class),
            //add the 30' Trash Bin Narrative
            narrate().over(Product2ThirtyFootTrashBinNarr.class),

            //add products to standard pricebook
            narrate()
                .over(PBEStandardCementTruckNarr.class)
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.product2id)
                        .toNarrative(Product2CementTruckNarr.class)
                        .whereField(Product2.Name)
                        .hasValue('Cement Truck')
                ),
            narrate()
                .over(PBEStandardLapTopNarr.class)
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.product2id)
                        .toNarrative(Product2LaptopNarr.class)
                        .whereField(Product2.Name)
                        .hasValue('Laptop')
                ),
            narrate()
                .over(PBEStandardMobileCommandTrailerNarr.class)
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.product2id)
                        .toNarrative(Product2LaptopNarr.class)
                        .whereField(Product2.Name)
                        .hasValue('Mobile Command Trailer')
                ),
            narrate()
                .over(PBEStandardSafetyVestNarr.class)
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.product2id)
                        .toNarrative(Product2LaptopNarr.class)
                        .whereField(Product2.Name)
                        .hasValue('Safety Vest')
                ),
            narrate()
                .over(PBEStandard30FootTrashBinNarr.class)
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.product2id)
                        .toNarrative(Product2LaptopNarr.class)
                        .whereField(Product2.Name)
                        .hasValue('30 foot Trash Bin')
                ),
            
            //Create Price Book Entries for Products in the Contractor Price Book
            //Add the Cement Truck Product to the Contractor Price Book
            narrate()
                .over(PBEContractorCementTruckNarr.class)
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.pricebook2id)
                        .toNarrative(PriceBook2ContractorNarr.class)
                        .whereField(PriceBook2.Name)
                        .hasValue('Contractor Price Book')
                )
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.product2id)
                        .toNarrative(Product2CementTruckNarr.class)
                        .whereField(Product2.Name)
                        .hasValue('Cement Truck')
                ),
            //add Laptop product for contractor pricebook narrative
            narrate()
                .over(PBEContractorLapTopNarr.class)
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.pricebook2id)
                        .toNarrative(PriceBook2ContractorNarr.class)
                        .whereField(PriceBook2.Name)
                        .hasValue('Contractor Price Book')
                )
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.product2id)
                        .toNarrative(Product2LaptopNarr.class)
                        .whereField(Product2.Name)
                        .hasValue('Laptop')
                ),
            //add Mobile Command Trailer product for contractor pricebook narrative
            narrate()
                .over(PBEContractorMobileCommandTrailerNarr.class)
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.pricebook2id)
                        .toNarrative(PriceBook2ContractorNarr.class)
                        .whereField(PriceBook2.Name)
                        .hasValue('Contractor Price Book')
                )
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.product2id)
                        .toNarrative(Product2LaptopNarr.class)
                        .whereField(Product2.Name)
                        .hasValue('Mobile Command Trailer')
                ),  
            //add Safety Vest product for contractor pricebook narrative
            narrate()
                .over(PBEContractorSafetyVestNarr.class)
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.pricebook2id)
                        .toNarrative(PriceBook2ContractorNarr.class)
                        .whereField(PriceBook2.Name)
                        .hasValue('Contractor Price Book')
                )
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.product2id)
                        .toNarrative(Product2LaptopNarr.class)
                        .whereField(Product2.Name)
                        .hasValue('Safety Vest')
                ),  
            //Add 30' Trash Bin to the Contractor Price book narrative
            narrate()
                .over(PBEContractor30FootTrashBinNarr.class)
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.pricebook2id)
                        .toNarrative(PriceBook2ContractorNarr.class)
                        .whereField(PriceBook2.Name)
                        .hasValue('Contractor Price Book')
                )
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.product2id)
                        .toNarrative(Product2LaptopNarr.class)
                        .whereField(Product2.Name)
                        .hasValue('30 foot Trash Bin')
                ),
            //Create Price Book Entries for Products in the Government Price Book
            //Add the Cement Truck Product to the Government Price Book
            narrate()
                .over(PBEGovtCementTruckNarr.class)
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.pricebook2id)
                        .toNarrative(PriceBook2ContractorNarr.class)
                        .whereField(PriceBook2.Name)
                        .hasValue('Government Price Book')
                )
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.product2id)
                        .toNarrative(Product2CementTruckNarr.class)
                        .whereField(Product2.Name)
                        .hasValue('Cement Truck')
                ),
            //add Laptop product for Government pricebook narrative
            narrate()
                .over(PBEGovtLapTopNarr.class)
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.pricebook2id)
                        .toNarrative(PriceBook2ContractorNarr.class)
                        .whereField(PriceBook2.Name)
                        .hasValue('Government Price Book')
                )
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.product2id)
                        .toNarrative(Product2LaptopNarr.class)
                        .whereField(Product2.Name)
                        .hasValue('Laptop')
                ),
            //add Mobile Command Trailer product for Government pricebook narrative
            narrate()
                .over(PBEGovtMobileCommandTrailerNarr.class)
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.pricebook2id)
                        .toNarrative(PriceBook2ContractorNarr.class)
                        .whereField(PriceBook2.Name)
                        .hasValue('Government Price Book')
                )
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.product2id)
                        .toNarrative(Product2LaptopNarr.class)
                        .whereField(Product2.Name)
                        .hasValue('Mobile Command Trailer')
                ),  
            //add Safety Vest product for Government pricebook narrative
            narrate()
                .over(PBEGovtSafetyVestNarr.class)
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.pricebook2id)
                        .toNarrative(PriceBook2ContractorNarr.class)
                        .whereField(PriceBook2.Name)
                        .hasValue('Government Price Book')
                )
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.product2id)
                        .toNarrative(Product2LaptopNarr.class)
                        .whereField(Product2.Name)
                        .hasValue('Safety Vest')
                ),  
            //Add 30' Trash Bin to the Government Price book narrative
            narrate()
                .over(PBEGovt30FootTrashBinNarr.class)
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.pricebook2id)
                        .toNarrative(PriceBook2ContractorNarr.class)
                        .whereField(PriceBook2.Name)
                        .hasValue('Government Price Book')
                )
                .relate(
                    new dbf_DomainBuilderStory.Relation()
                        .onField(PriceBookEntry.product2id)
                        .toNarrative(Product2LaptopNarr.class)
                        .whereField(Product2.Name)
                        .hasValue('30 foot Trash Bin')
                ),

            //Let's add some opportunities
             narrate()
                .over(OppExpeditedBeverlyNarr.class)
                 .relate(
                        new dbf_DomainBuilderStory.Relation()
                            .onField(Opportunity.AccountId)
                            .toNarrative(AccountExpConstrNarr.class)
                            .whereField(Account.Name)
                            .hasValue('Expedited Construction')
                    ),
            narrate()
                .over(OppExpeditedRyanNarr.class)
                 .relate(
                        new dbf_DomainBuilderStory.Relation()
                            .onField(Opportunity.AccountId)
                            .toNarrative(AccountExpConstrNarr.class)
                            .whereField(Account.Name)
                            .hasValue('Expedited Construction')
                    ),
            
            narrate()
                .over(OppTwinPeaksJosephNarr.class)
                 .relate(
                        new dbf_DomainBuilderStory.Relation()
                            .onField(Opportunity.AccountId)
                            .toNarrative(AccountTwinPeaksNarr.class)
                            .whereField(Account.Name)
                            .hasValue('Twin Peaks Construction')
                    ),
            narrate()
                .over(OppTwinPeaksSamanthaNarr.class)
                 .relate(
                        new dbf_DomainBuilderStory.Relation()
                            .onField(Opportunity.AccountId)
                            .toNarrative(AccountTwinPeaksNarr.class)
                            .whereField(Account.Name)
                            .hasValue('Twin Peaks Construction')
                    )
                 
        }); 
    }
}