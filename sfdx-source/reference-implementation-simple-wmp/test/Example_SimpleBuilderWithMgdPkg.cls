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
 *   Example which calls one or more dbf_DomainBuilders in both local & stubbed 'managed package' code.
 * 
 * Purpose:  
 *   Offers an examples of more complex implementations of the SIMPLE use-case when the need arises
 *   to cross the namespace boundary, typically when consuming a managed package which also contains
 *   dbf_DomainBuilder implementations.
 ************************************************************************/
@IsTest
private class Example_SimpleBuilderWithMgdPkg {
    
    @IsTest 
    private static void UserThroughWrappedBuilder() {
        userBuilderWrapper mrsPacMan  = new userBuilderWrapper()
            .Name('Mrs Pacman')
            .FirstName('Mrs')
            .LastName('Pacman')
            .Alias('Miss')
            .Title('Miz')
            .Username('the.mrs.pacman@whompwhompwhomp.com')
            .Email('the.mrs.pacman@whompwhompwhomp.com')
            .Phone('804-555-1235');
        // LastName, Alias, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, ProfileId, LanguageLocaleKey

        // persist it to the org
        mrsPacMan.persist(); // only need to persist one builder, all persist when one is called

        // execute your operations against that data
        Test.startTest();
        Test.stopTest();


        sObject mrsPacmanRecord = ((dbf_IDomainBuilder)mrsPacMan).getRecord();
        System.assert(mrsPacmanRecord.Id != null);
    }

    class userBuilderWrapper extends dbf_DomainBuilderWrapper {
        public userBuilderWrapper() {
            super(User.sObjectType);
            setDiscoverableField(User.Name);
            setDiscoverableField(User.Email);
            setDiscoverableField(User.Phone);
            setDiscoverableField(User.Username);

            wrappedBuilder = new managedPackageUserBuilder();

            // set default values here through wrappedBuilder
            this.TimeZoneSidKey('America/New_York')
                .LocaleSidKey('en_US')
                .EmailEncodingKey('UTF-8')
                .LanguageLocaleKey('en_US');

            // in a real implementation this profile lookup would happen in a more globally scoped piece of code
            // and would be cached for the duration of this request context.
            // in this test scenario, this sould be fine... though less than ideal
            Profile p = [select id from profile where name='Standard User'];
            this.ProfileId(p.Id);
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

        // convenience method to fluently set User.Name field value
        public userBuilderWrapper Name(String value) {
            wrappedBuilder.withValue(User.Name, value);
            return this;
        }

        // convenience method to fluently set User.Username field value
        public userBuilderWrapper Username(String value) {
            wrappedBuilder.withValue(User.Username, value);
            return this;
        }

        // convenience method to fluently set User.Email field value
        public userBuilderWrapper Email(String value) {
            wrappedBuilder.withValue(User.Email, value);
            return this;
        }

        // convenience method to fluently set User.Phone field value
        public userBuilderWrapper Phone(String value) {
            wrappedBuilder.withValue(User.Phone, value);
            return this;
        }

        // convenience method to fluently set User.Title field value
        public userBuilderWrapper Title(String value) {
            wrappedBuilder.withValue(User.Title, value);
            return this;
        }

        // convenience method to fluently set User.ProfileId field value
        public userBuilderWrapper ProfileId(Id value) {
            wrappedBuilder.withValue(User.ProfileId, value);
            return this;
        }

        // convenience method to fluently set User.Alias field value
        public userBuilderWrapper Alias(String value) {
            wrappedBuilder.withValue(User.Alias, value);
            return this;
        }

        // convenience method to fluently set User.FirstName field value
        public userBuilderWrapper FirstName(String value) {
            wrappedBuilder.withValue(User.FirstName, value);
            return this;
        }

        // convenience method to fluently set User.LastName field value
        public userBuilderWrapper LastName(String value) {
            wrappedBuilder.withValue(User.LastName, value);
            return this;
        }

        // convenience method to fluently set User.TimeZoneSidKey field value
        public userBuilderWrapper TimeZoneSidKey(String value) {
            wrappedBuilder.withValue(User.TimeZoneSidKey, value);
            return this;
        }

        // convenience method to fluently set User.LocaleSidKey field value
        public userBuilderWrapper LocaleSidKey(String value) {
            wrappedBuilder.withValue(User.LocaleSidKey, value);
            return this;
        }

        // convenience method to fluently set User.EmailEncodingKey field value
        public userBuilderWrapper EmailEncodingKey(String value) {
            wrappedBuilder.withValue(User.EmailEncodingKey, value);
            return this;
        }

        // convenience method to fluently set User.LanguageLocaleKey field value
        public userBuilderWrapper LanguageLocaleKey(String value) {
            wrappedBuilder.withValue(User.LanguageLocaleKey, value);
            return this;
        }
    }

    /************************************************************************
    * Description:  
    *   Example dbf_DomainBuilder implementation for the User object.
    *   This example is a stub of what one might find in an external, managed package.
    *   For the purposes of this example, all code accessing this builder are assumed to be in a 
    *   different code-base. For this builder to be visible in the local code, it would have to be
    *   global scoped, and all methods accessed by the local code would have to be global scoped.
    *   
    * 
    * Purpose:  
    *   Offers methods for producing specific user records. Used in SIMPLE examples and unit 
    *   tests which include crossing the namespace boundary to interact with this stub as if it was
    *   hosted by a managed package.
    *
    *   This is an example of a typical, non story-drivendbf_DomainBuilder
    ************************************************************************/
    class managedPackageUserBuilder extends dbf_DomainBuilder {
        // the constructor would be the default entry point to this managed package builder
        // and would establish discoverables and defaults to be used by all subsequence builders or
        // narratives.
        public managedPackageUserBuilder() {
            super(User.sObjectType);
            setDiscoverableField(User.Name);
            // set default values here
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
            // In a normal managed package scenario, this builder would not be part of the same unit of work.
            // however, since we're faking it and only have one dbf_DomainBuilder for classes to extend, this stub
            // ends up inside the same unit of work and causes errors.
            // The unregisterIncludingParents() method helps us prevent that, and keeps the illusion that this
            // builder is in a separate stream.
            // Otherwise, only one line of code would be needed here: return super.getRecord(); 
            return underlyingRecord;
        }
    }
}
