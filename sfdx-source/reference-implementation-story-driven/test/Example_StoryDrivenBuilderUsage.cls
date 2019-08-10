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

/************************************************************************
 * Description:  
 *   This example shows an implementation of a STORY DRIVEN approach to data using builders, stories and narratives.
 *   This approach is useful for abstraction functional code, business rules and other logic away from data concerns
 *   and is designed to facilitate easier conversations around the need for data, and the type of data needed, in
 *   distributed, or fast moving organizations. This is most comparable to identifying 'personas' in UI/UX design
 *   processes, or some QA automation practices.
 *
 *   Secondarily, the abstraction allows for the creation of dbf_DomainBuilder implementations which rarely, if ever, 
 *   change. Data concerns are handled in Narratives which sit atop, and consume, the underlying dbf_DomainBuilders.
 *   Data concerns change often, and this separation of business logic and data definition allows the builders to
 *   remain stable while the data concerns atop them can shift, change and adapt to suit the needs of your 
 *   organization.
 ************************************************************************/
@IsTest
private class Example_StoryDrivenBuilderUsage {
    private static Integer getRandomNumber(Integer size){
		Double d = math.random() * size;
		return d.intValue();
	}

    private static String saferUserName(String originalName) {
        Integer suffixInt = getRandomNumber(9999);
        String prefix = '000000';
        String newSuffix = prefix + String.valueOf(suffixInt);
        return originalName + '.' + newSuffix.right(6);
    }

    @IsTest
    public static void testOnmitsuStoryCreation(){
        onmitsuCompanyStory testOnmitsuStory = new onmitsuCompanyStory();
        testOnmitsuStory.persist();
        
        Test.startTest();
        
        Opportunity vidOpp = [SELECT Id, name, LeadSource, StageName,
                             NextStep , Account.Id, Account.Name
                             FROM Opportunity 
                             WHERE Name =: 'NEW CDN Possibility'
                             LIMIT : 1];

        
        system.debug('vidOpp.Account.Name = ' + vidOpp.Account.Name);
        system.debug('vidOpp = ' + vidOpp);
        system.assert(vidOpp.Account.Name == 'Onmitsu Kage');
        system.assert(vidOpp.LeadSource == 'Web');
        system.assert(vidOpp.StageName == 'Prospecting');

        Test.stopTest();
    }

    class onmitsuCompanyStory extends dbf_DomainBuilderstory {
        /************************************************************************
        * Override the narrators method from the dbf_DomainBuilderStory this is where builders construction 
        * is orchestrated and chained together to form the data story for Onmitsu Kage
        * In this story we are setting up an 
        *     Account 
        *         Contacts
        *         Opportunity
        *     User
        *         Opportunity
        * In this example two narratives that will be either parents or used in other narratives as 
        * lookup to are created first. Then the narratives that are child or lookingup will be created 
        * and linked to the parent narratives through the relate() to method
        ************************************************************************/
        public override  List<Narrator> narrators() {
            return  (new List<Narrator> {
                //Add an Account for the Onmitsu Company
                narrate()
                    .over(onmitsuAccountNarrative.class),
                //Create the Acme SalesUser Narrative 
                narrate()
                    .over(acmeSalesUserNarrative.class),
                //Create the Onmitsu Kage Employee Contact and assign it to the Onmitsu Accont above
                narrate()
                    .over(onmitsuEmployeeContactNarrative.class)
                    .relate(
                        new dbf_DomainBuilderStory.Relation()
                            .onField(Contact.AccountId)
                            .toNarrative(onmitsuAccountNarrative.class)
                            .whereField(Account.Name)
                            .hasValue('Onmitsu Kage')
                    ),
                //Create the Onmitsu Kage CEO Contact and assign it to the Onmitsu Accont above
                narrate()
                    .over(onmitsuCeoContactNarrative.class)
                    .relate(
                        new dbf_DomainBuilderStory.Relation()
                            .onField(Contact.AccountId)
                            .toNarrative(onmitsuAccountNarrative.class)
                            .whereField(Account.Name)
                            .hasValue('Onmitsu Kage')
                    ),
                //Create an Opportunity and relate it to the Onmitsu Account
                //Create another relation and relate the opportunity owner to the Acme Sales User created above.
                narrate()
                    .over(onmitsuVideoSvcOppNarrative.class)
                    .relate(
                        new dbf_DomainBuilderStory.Relation()
                            .onField(Opportunity.AccountId)
                            .toNarrative(onmitsuAccountNarrative.class)
                            .whereField(Account.Name)
                            .hasValue('Onmitsu Kage')
                    )
                    .relate(
                        new dbf_DomainBuilderStory.Relation()
                            .onField(Opportunity.OwnerId)
                            .toNarrative(acmeSalesUserNarrative.class)
                            .whereField(User.Name)
                            .hasValue('SalesUser Acme')
                    )
                    
            }); 
        }
    }

    class acmeAccountNarrative extends dbf_DomainBuilderNarrative {
        public override Type builderType() { return accountBuilder.class; }
        public override sObjectType sObjectType()     { return(Account.sObjectType); }
        public override dbf_IDomainBuilder build() {
            accountBuilder builder = new accountBuilder();
            builder.accountName('ACME Corp');
            return((dbf_IDomainBuilder) builder);
        }
    }

    class onmitsuAccountNarrative extends dbf_DomainBuilderNarrative {
        //Override the abstract methods from the dbf_DomainBuilderNarrative that
        //this class is inherited from with and put in the necessary functionality.
        public override Type builderType()     { return(accountBuilder.Class); }
        public override sObjectType sObjectType()     { return(Account.sObjectType); }
        public override dbf_IDomainBuilder build() { 
            accountBuilder builder = new accountBuilder();
            builder.accountName('Onmitsu Kage');
            return((dbf_IDomainBuilder) builder);
        }
    }

    class accountBuilder extends dbf_DomainBuilder {
        public accountBuilder() {
            super(Account.sObjectType);
            setDiscoverableField(Account.Name);
        }

        //convenience method
        public accountBuilder accountName(String strAccountName){
            set(Account.Name, strAccountName);
            return this;
        }

        public accountBuilder accountName2(string strAccountName){
            set(Account.Name, strAccountName);
            return this;
        }
    }

    class onmitsuCeoContactNarrative extends dbf_DomainBuilderNarrative {
    //Override abstract methods from the Domain Builder Narrative
        public override Type builderType()     { return(contactBuilder.Class); }
        public override sObjectType sObjectType()     { return(Contact.sObjectType); }
        public override dbf_IDomainBuilder build() { 
            return(new contactBuilder()
                .lastName('Omega')
                .firstName('Alpha')
                .description('CEO Test Build')
                .emailAddress('sometest@email.com'));
        }
    }

    class onmitsuEmployeeContactNarrative extends dbf_DomainBuilderNarrative {
        //Override abstract methods from the Domain Builder Narrative
        public override Type builderType() { return(contactBuilder.Class); }
        public override sObjectType sObjectType()  { return(Contact.sObjectType); }
        public override dbf_IDomainBuilder build() {
            return(new contactBuilder()
                .name('Creme Puffs')
                .firstName('Creme')
                .lastName('Puffs')
                .description('Creme Puffs is our best employee!')
                .emailAddress('helpme@why.com'));
        }
    }

    class contactBuilder extends dbf_DomainBuilder {
        //
        public contactBuilder() {
            Super(Contact.sObjectType);
            setDiscoverableField(Contact.LastName);
        }

        //Convenience Methods
        public contactBuilder name(String value) {
            set(Contact.Name, value);
            return(this);
        }

        public contactBuilder lastName(String strLastName) {
            set(Contact.LastName, strLastName);
            return(this);
        }

        //
        public contactBuilder firstName(String strFirstName) {
            set(Contact.FirstName,strFirstName);
            return(this);
        }

        //
        public contactBuilder emailAddress(String strEmailAddress) {
            set(Contact.Email, strEmailAddress);
            return(this);
        }

        //
        public contactBuilder description(String strDescription){
            set(Contact.description, strDescription);
            return(this);
        }

        //
        public contactBuilder attachParentAccount(dbf_IDomainBuilder iParentAccount){
            setParent(Contact.AccountId, iParentAccount);
            return(this);
        }
    }

    class onmitsuVideoSvcOppNarrative extends dbf_DomainBuilderNarrative {
        //Override abstract methods from the Domain Builder Narrative
        public override Type builderType() { return(opportunityBuilder.Class); }
        public override sObjectType sObjectType()  { return(Opportunity.sObjectType); }
        public override dbf_IDomainBuilder build() {
            return(new opportunityBuilder().oppName('NEW CDN Possibility'));
        }
    }

    class opportunityBuilder extends dbf_DomainBuilder {
        public opportunityBuilder() {
            super(Opportunity.getSObjectType());
            
            //Use the setDiscoverableField to a field in the sObject so that
            //it can be used when the stories and narratives are executed.  This
            //allows multiple narratives to use the same User without creating
            //two copies of the same user.  
            setDiscoverableField(Opportunity.Name);

            //Set defaults right now for all users created.  These defaults can
            //be overwritten by the convenience methods supplied.  Or whoever
            //calls this class to create a user can use the .set(Field,Value)
            //directly since it is exposed from deriving fromdbf_DomainBuilder.
            set(Opportunity.LeadSource, 'Web');
            set(Opportunity.StageName,  'Prospecting');
            set(Opportunity.Type,       'New Customer');
            set(Opportunity.NextStep,   'Find out who the decision makers are');
            set(Opportunity.CloseDate,  Date.today().addDays(21));

        }

        /*****************************************************************
        *   Convience methods allowing for Fluent/Method Chaining 
        ******************************************************************/
        public opportunityBuilder oppLeadSource(String strOpportunityLeadSource) {
            set(Opportunity.LeadSource, strOpportunityLeadSource);
            return(this);
        }

        public opportunityBuilder oppNextStep(String strNextStep) {
            set(Opportunity.NextStep, strNextStep);
            return(this);
        }

        public opportunityBuilder oppStage(String strOpportunityStage) {
            set(Opportunity.StageName, strOpportunityStage);
            return(this);
        }

        public opportunityBuilder oppName(String strOpportunityName) {
            set(Opportunity.Name, strOpportunityName);
            return(this);
        }

        public opportunityBuilder oppType(String strOpportunityType) {
            set(Opportunity.Type, strOpportunityType);
            return(this);
        }
    }

    class acmeSalesUserNarrative  extends dbf_DomainBuilderNarrative {
        public override Type builderType()          { return(userBuilder.Class); }
        public override sObjectType sObjectType()   { return(User.sObjectType); }
        public override dbf_IDomainBuilder build() { 
            //Fluent style is applied here but below in the comments
            //you can see an alternate way of doing it.
            return(new userBuilder()
                .lastName('Acme')
                .firstName('SalesUser' )
                .alias('ACS')
                .communityNickname('ACS')
                .email('CoolSales@AcmeVid.com')
                .userName(saferUserName('CoolSales@AcmeVid.com')) );

            /* ALTERNATE :::...
            userBuilder acmeUser = new userBuilder();
            acmeUser.lastName('Acme');
            acmeUser.firstName('SalesUser' );
            acmeUser.alias('ACS');
            acmeUser.email('CoolSales@AcmeVid.com');
            acmeUser.userName('CoolSales@AcmeVid.com');
            return(acmeUser);
            */
        }
    }

    class onmitsuSupportUserNarrative extends dbf_DomainBuilderNarrative{
        public override Type builderType()     { return(userBuilder.Class); }
        public override sObjectType sObjectType()     { return(User.sObjectType); }
        public override dbf_IDomainBuilder build() { 
            return(new userBuilder()
                .lastName('Support')
                .firstName('Power' )
                .alias('CS')
                .communityNickname('CS')
                .email('CoolSupport@AcmeVid.com')
                .userName(saferUserName('CoolSupport@AcmeVid.com')) );
        }
    }

    class userBuilder extends dbf_DomainBuilder {
        //In the constructor we call the base classes constructor passing
        //the type of Object we wish to make a concrete example of.
        public userBuilder() {
            super(User.getSObjectType());
            
            //Use the setDiscoverableField to a field in the sObject so that
            //it can be used when the stories and narratives are executed.  This
            //allows multiple narratives to use the same User without creating
            //two copies of the same user.  
            setDiscoverableField(User.Name);

            //Just retrieving an Id for the Profile so that we can assign it to a
            //user.
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

            //Set defaults right now for all users created.  These defaults can
            //be overwritten by the convenience methods supplied.  Or whoever
            //calls this class to create a user can use the .set(Field,Value)
            //directly since it is exposed from deriving from dbf_DomainBuilder.

            set(User.TimeZoneSidKey ,       'GMT');
            set(User.LanguageLocaleKey,     'en_US');
            set(User.EmailEncodingKey,      'UTF-8');
            set(User.LocaleSidKey,          'en_US');
            set(User.ProfileId,              p.Id);

        }

        //Convenience methods allowing for Fluent/Method Chaining
        public userBuilder firstName(String userFirstName) {
            set(User.FirstName, userFirstName);
            return(this);
        }

        public userBuilder alias(String userAlias) {
            set(User.Alias,     userAlias);
            return(this);
        }

        public userBuilder communityNickname(String nickname) {
            set(User.CommunityNickname, nickname);
            return(this);
        }

        public userBuilder email(String userEmail) {
            set(User.Email,     userEmail);
            return(this);
        }

        public userBuilder userName(String userUserName) {
            set(User.UserName,  userUserName);
            return(this);
        }

        public userBuilder lastName(String userLastName) {
            set(User.LastName,  userLastName);
            return(this);
        }
    }
}