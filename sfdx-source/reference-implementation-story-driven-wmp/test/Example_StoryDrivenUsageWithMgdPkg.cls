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
 *   change. Data concerns are handled in Narratives which sit atop, and consume, the underlyingdbf_DomainBuilders.
 *   Data concerns change often, and this separation of business logic and data definition allows the builders to
 *   remain stable while the data concerns atop them can shift, change and adapt to suit the needs of your 
 *   organization.
 ************************************************************************/
@IsTest
private class Example_StoryDrivenUsageWithMgdPkg {
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
    public static void testFooStoryCreation(){
        fooCompanyStory testFooStory = new fooCompanyStory();
        testFooStory.persist();
        
        Test.startTest();
        
        Opportunity vidOpp = [SELECT Id, name, LeadSource, StageName,
                             NextStep , Account.Id, Account.Name
                             FROM Opportunity 
                             WHERE Name =: 'NEW CDN Possibility'
                             LIMIT : 1];

        
        system.debug('vidOpp.Account.Name = ' + vidOpp.Account.Name);
        system.debug('vidOpp = ' + vidOpp);
        system.assert(vidOpp.Account.Name == 'Foo Bar');
        system.assert(vidOpp.LeadSource == 'Web');
        system.assert(vidOpp.StageName == 'Prospecting');

        Test.stopTest();
    }

    class fooCompanyStory extends dbf_DomainBuilderstory {
        /************************************************************************
        * Override the narrators method from the dbf_DomainBuilderStory this is where builders construction 
        * is orchestrated and chained together to form the data story for Foo Bar
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
                //Add an Account for the Foo Company
                narrate()
                    .over(fooAccountNarrative.class),
                //Create the Foo SalesUser Narrative 
                narrate()
                    .over(fooSalesUserNarrative.class),
                //Create the Foo Bar Employee Contact and assign it to the Foo Accont above
                narrate()
                    .over(fooEmployeeContactNarrative.class)
                    .relate(
                        new dbf_DomainBuilderStory.Relation()
                            .onField(Contact.AccountId)
                            .toNarrative(fooAccountNarrative.class)
                            .whereField(Account.Name)
                            .hasValue('Foo Bar')
                    ),
                //Create the Foo Bar CEO Contact and assign it to the Foo Accont above
                narrate()
                    .over(fooCeoContactNarrative.class)
                    .relate(
                        new dbf_DomainBuilderStory.Relation()
                            .onField(Contact.AccountId)
                            .toNarrative(fooAccountNarrative.class)
                            .whereField(Account.Name)
                            .hasValue('Foo Bar')
                    ),
                //Create an Opportunity and relate it to the Foo Account
                //Create another relation and relate the opportunity owner to the Foo Sales User created above.
                narrate()
                    .over(fooVideoSvcOppNarrative.class)
                    .relate(
                        new dbf_DomainBuilderStory.Relation()
                            .onField(Opportunity.AccountId)
                            .toNarrative(fooAccountNarrative.class)
                            .whereField(Account.Name)
                            .hasValue('Foo Bar')
                    )
                    .relate(
                        new dbf_DomainBuilderStory.Relation()
                            .onField(Opportunity.OwnerId)
                            .toNarrative(fooSalesUserNarrative.class)
                            .whereField(User.Name)
                            .hasValue('SalesUser2 Foo')
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

    class fooAccountNarrative extends dbf_DomainBuilderNarrative {
        //Override the abstract methods from thedbf_DomainBuilderNarrative that
        //this class is inherited from with and put in the necessary functionality.
        public override Type builderType()     { return(accountBuilder.Class); }
        public override sObjectType sObjectType()     { return(Account.sObjectType); }
        public override dbf_IDomainBuilder build() { 
            accountBuilder builder = new accountBuilder();
            builder.accountName('Foo Bar');
            return((dbf_IDomainBuilder) builder);
        }
    }

    // TODO: wrap the foo account with a wrapper & pretend it is external

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

    class fooCeoContactNarrative extends dbf_DomainBuilderNarrative {
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

    class fooEmployeeContactNarrative extends dbf_DomainBuilderNarrative {
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

    class fooVideoSvcOppNarrative extends dbf_DomainBuilderNarrative {
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
            //directly since it is exposed from deriving from dbf_DomainBuilder.
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

    class fooSalesUserNarrative  extends dbf_DomainBuilderNarrative {
        public override Type builderType()          { return(userBuilderWrapper.Class); }
        public override sObjectType sObjectType()   { return(User.sObjectType); }
        public override dbf_IDomainBuilder build() { 
            //Fluent style is applied here but below in the comments
            //you can see an alternate way of doing it.
            return(new userBuilderWrapper()
                .lastName('Foo')
                .firstName('SalesUser' )
                .alias('FS')
                .communityNickname('FS')
                .email('OutsideSales@FooVid.com')
                .userName(saferUserName('OutsideSales@FooVid.com')) );

            /* ALTERNATE :::...
            userBuilderWrapper acmeUser = new userBuilderWrapper();
            acmeUser.lastName('Foo');
            acmeUser.firstName('SalesUser2' );
            acmeUser.alias('ACS2');
            acmeUser.email('OutsideSales@FooVid.com');
            acmeUser.userName('OutsideSales@FooVid.com');
            return(acmeUser);
            */
        }
    }

    class fooSupportUserNarrative extends dbf_DomainBuilderNarrative{
        public override Type builderType()     { return(userBuilderWrapper.Class); }
        public override sObjectType sObjectType()     { return(User.sObjectType); }
        public override dbf_IDomainBuilder build() { 
            return(new userBuilderWrapper()
                .lastName('Support')
                .firstName('Outside' )
                .alias('SO')
                .communityNickname('SO')
                .email('OutsideSupport@FooVid.com')
                .userName(saferUserName('OutsideSupport@FooVid.com')) );
        }
    }

    class userBuilderWrapper extends dbf_DomainBuilderWrapper {
        public userBuilderWrapper() {
            super(User.sObjectType);
            setDiscoverableField(User.Name);
            setDiscoverableField(User.Email);
            setDiscoverableField(User.Phone);
            setDiscoverableField(User.Username);

            wrappedBuilder = new managedPackageUserBuilder();
        }

        private managedPackageUserBuilder wrappedBuilder;

        public override Object underlyingBuilder() { 
            // this should return an instance from within this class.
            // ideally this instance should be maintained in a private property
            // and should be established in the constructor
            return  (Object) wrappedBuilder; 
        }

        public override SObject underlyingRecord() { 
            // in this example, the underlying builder is an instance of the managed package's own
            // implementation of a dbf_IDomainBuilder and as such, however the getRecord() method on said
            // builder would likely be inaccessible. The mp's builder should provide a method for
            // accessing the sObject. In this example, that is a method named getData()
            return wrappedBuilder.getData(); 
        }

        public userBuilderWrapper withValue(SObjectField field, Object value) {
            // pass the data along to the wrapped builder instance, whatever that may be
            // by using the global method said builder has exposed for this purpose.
            // this is a generic implementation.
            // alternatively, the wrapped builder might implement specific fluent methods such as
            //      withName(), or name()
            // in such a case, this wrapper should ideally expose the same methods which wrap those of
            // the underlying builder using this same pattern of simply casting the value downwards.
            wrappedBuilder.withValue(field, value);
            return this;
        }

        //Convenience methods allowing for Fluent/Method Chaining
        public userBuilderWrapper firstName(String userFirstName) {
            wrappedBuilder.withValue(User.FirstName, userFirstName);
            return(this);
        }

        public userBuilderWrapper alias(String userAlias) {
            wrappedBuilder.withValue(User.Alias,     userAlias);
            return(this);
        }

        public userBuilderWrapper communityNickname(String nickname) {
            wrappedBuilder.withValue(User.CommunityNickname, nickname);
            return(this);
        }

        public userBuilderWrapper email(String userEmail) {
            wrappedBuilder.withValue(User.Email,     userEmail);
            return(this);
        }

        public userBuilderWrapper userName(String userUserName) {
            wrappedBuilder.withValue(User.UserName,  userUserName);
            return(this);
        }

        public userBuilderWrapper lastName(String userLastName) {
            wrappedBuilder.withValue(User.LastName,  userLastName);
            return(this);
        }
    }

    // This is a stubbed "pretend" builder from an external Managed Package
    // It offers a getData method to extract the underlying sObject
    class managedPackageUserBuilder extends dbf_DomainBuilder {
        // the constructor would be the default entry point to this managed package builder
        // and would establish discoverables and defaults to be used by all subsequence builders or
        // narratives.
        public managedPackageUserBuilder() {
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

        // this or another convenience/access method should be available in all managed package 
        // hosted builder in order to easily apply values to the underlying sObject.
        public managedPackageUserBuilder withValue(SObjectField field, Object value) {
            super.set(field, value);
            return this;
        }

        // method for gaining access to the underlying sObject, since getRecord() on
        // the managed package's version ofdbf_DomainBuilder isn't likely to be accessible to the consumers
        // of the package
        public SObject getData() {
            SObject underlyingRecord = super.getRecord();
            unregisterIncludingParents(); // THIS IS REQUIRED for fake/stub external builders.
            // in a normal managed package scenario, this builder would not be part of the same unit of work.
            // however, since we're faking it and only have onedbf_DomainBuilder for classes to extend, this stub
            // ends up inside the same unit of work and causes errors.
            // the unregisterIncludingParents() method helps us prevent that, and keep the illusion that this
            // builder is in a separate stream.
            // otherwise, only one line of code would be needed here: return super.getRecord(); 
            return underlyingRecord;
        }
    }
}