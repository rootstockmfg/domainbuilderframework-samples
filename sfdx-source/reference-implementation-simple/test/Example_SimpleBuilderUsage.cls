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
 *   Example which calls one or moredbf_DomainBuilders in local code.
 * 
 * Purpose:  
 *   The examples in this file represent alternate uses of the SIMPLE implementations of 
 *  dbf_DomainBuilders.
 ************************************************************************/
@IsTest
private class Example_SimpleBuilderUsage {


    /************************************************************************
     * Purpose: This SIMPLE example shows how to create two records in a single sObject.
     * 
     *dbf_DomainBuilder Methods Used:
     *          - persist       : commits the collected data into the org
     *          - getRecord     : returns the sObject underlying a given builder
     ************************************************************************/
    @IsTest
    private static void unrelatedDataCreation_HappyPath() {
        // prepare your data
        dbf_IDomainBuilder acmeWeldingAcct  = new simpleAccountBuilder().AcmeWelding();
        dbf_IDomainBuilder acmeLawncareAcct = new simpleAccountBuilder().AcmeLawncare();

        // persist it to the org
        acmeWeldingAcct.persist(); // only need to persist one builder, all persist when one is called

        // execute your operations against that data
        Test.startTest();
        Test.stopTest();

        sObject acmeLawncareRecord = acmeLawncareAcct.getRecord();

        System.assert(acmeLawncareRecord.Id != null);
    }


    /************************************************************************
     * Purpose: This SIMPLE example shows how to create two sObjects that
     *          are relatable through Master/Child relationships or (lookup)
     *          and associate them to each other.
     *dbf_DomainBuilder Methods Used:
     *          - setParent     : assigns another builder as a referenced parent record
     *          - setChild      : assigns the current builder as the referenced parent in another record
     *          - persist       : commits the collected data into the org
     *          - getRecord     : returns the sObject underlying a given builder
     ************************************************************************/
    @IsTest
    private static void relatedAccountAndContacts_HappyPath(){
        //Create two Accounts to be able to associate to new Contacts
        dbf_IDomainBuilder acctAcmeWelding  =  new simpleAccountBuilder().AcmeWelding();
        dbf_IDomainBuilder acctAcmeLawncare =  new simpleAccountBuilder().AcmeLawncare();

        //Create two new Contacts that do not have accounts associated to them.
        dbf_IDomainBuilder conContact1      = new simpleContactBuilder().contactNoAccount1();
        dbf_IDomainBuilder conContact2      = new simpleContactBuilder().contactNoAccount2();

        //Demonstrates how to add a parent builder to a child builder using the .setParent method.
        //This links contact 1 to the AcmeWelding Account.
        conContact1.setParent(Contact.AccountId, acctAcmeWelding);

        //Demonstrates how to add contact (a child) to the Account (Master) through the .setChild method.
        //This links contact 2 to the AcmeLawncare Account.
        acctAcmeLawncare.setChild(Contact.AccountId, conContact2);

        //It doesn't actually matter which dbf_IDomainBuilder you call the persist method on.  
        conContact1.persist();

        
        //Let's pull back the actual sObjects from the two contact builders to see if valid Id's were created.
        sObject sobjContact1 = conContact1.getRecord();
        sObject sobjContact2 = conContact2.getRecord();

        system.assert(sobjContact1.id != null);
        system.assert(sobjContact2.id != null);
    }

    @isTest
     public static void testBuilderWithDataExisting_HappyPath() {
            Integer totalNumberOfAccountsThatShouldExist = 3;

            String phoneToUse   = '15556747167';
            String emailToUse   = 'help@onmitsu.com';
            
            //Two Accounts Create one Account that will preexist with a phone #
            List<Account> accts = new List<Account>();

            Account act         = new Account(Name = 'AccountWithPhoneNumber', Phone = '+15556747167');
            accts.add(act);

            act                 = new Account(Name = 'SimpleAccount');
            accts.add(act);
            
            insert(accts);

            Id acctExistId      = accts[0].Id;
            Id acctNotExistId   = accts[1].Id;

            system.debug('acctExistId = ' + acctExistId + '   acctNotExistId = ' + acctNotExistId);

            //Create Two contacts One will pre-exist with the email 'help@onmitsu.com'.

            List<Contact> cons  = new List<Contact>();
            Contact con  = new Contact(  LastName   = 'LoveZone', 
                                        accountId   = acctExistId);
            cons.add(con);

            con = new Contact(  LastName    = 'contactWithEmailOnmitsu', 
                                Email       = emailToUse,
                                AccountId   = acctNotExistId);
            cons.add(con);
            insert (cons);

            Id conNonExistId    = cons[0].id;
            Id conExistId       = cons[1].id;

            system.debug('conExistId = ' + conExistId + '   conNonExistId = ' + conNonExistId);

            //Create Two Account Domain Builders (one that will have the phone # identical to one that's saved)
            dbf_IDomainBuilder existDomAccount      = new simpleAccountBuilder().accountWithPhoneNumber();
            dbf_IDomainBuilder nonExistDomAcct      = new simpleAccountBuilder().accountWith72Employees();
            //this has same email but different contact name
            dbf_IDomainBuilder existDOMContact      = new simpleContactBuilder().contactWithEmailOnmitsu();
            dbf_IDomainBuilder nonExistDOMContact   = new simpleContactBuilder().contactNoAccount2();

            //Set Parents as the Account that already exists.
            existDOMContact.setParent(Contact.AccountId, existDomAccount);
            nonExistDOMContact.setParent(Contact.AccountId, existDomAccount);

            existDomAccount.persist();
            Test.startTest();
            integer totalAccts  = [SELECT COUNT() FROM Account];
            integer totalCns    = [SELECT COUNT() FROM Contact];

            Contact emailContact = [SELECT Id, Name,LastName,FirstName, Email, AccountId 
                                    FROM Contact 
                                    WHERE Email = :emailToUse];

            List<Contact> myContacts = [SELECT Id, Name, LastName, FirstName, Email, AccountId
                                        FROM contact ];
                                    
            Test.stopTest();

            system.debug('Contacts :  ' + mycontacts);
            System.debug('Contact Name = ' + emailContact.Name + '   Email = ' + emailContact.Email 
                        + ' LastName ' + emailContact.LastName + '   FirstName = ' + emailcontact.FirstName);
            //There should be a total of three accounts that were created.  Two were created up front
            //and Two were created by builders.  However, one builder was a duplicate of one already 
            //created so we should have three!
            System.Assert(totalNumberOfAccountsThatShouldExist == totalAccts);
           
            System.Assert(totalNumberOfAccountsThatShouldExist == totalCns);
            //Let's make sure the Account Id is the same as the Id we inserted above.
            System.assert(acctExistId == existDomAccount.getRecord().Id);
            //Let's make sure contact Id is the same as the Id we inserted above.
            system.assert(conExistId == existDOMContact.getRecord().Id);
            //Let's make sure the Account Id was set in the account.
            system.debug('EmailContact.AccountId = ' + emailContact.AccountId);
    }

    // internal implementation of an account builder for these tests
    // an ideal implementation would not be an internal class
    class simpleAccountBuilder extends dbf_DomainBuilder {
        public simpleAccountBuilder() {
            super(Account.sObjectType);
            setDiscoverableField(Account.Name);
            setDiscoverableField(Account.NumberOfEmployees);
            setDiscoverableField(Account.Phone);
        }

        // for convenience, you could use static methods for specific instances like this and create new instead of accessing "this"
        // however, for the purposes of this internal class for this unit test, statics are not possible
        public dbf_IDomainBuilder AcmeWelding() {
            return this.set(Account.Name, 'Acme Welding');
        }

        // for convenience, you could use static methods for specific instances like this and create new instead of accessing "this"
        // however, for the purposes of this internal class for this unit test, statics are not possible
        public dbf_IDomainBuilder AcmeLawncare() {
            return this.set(Account.Name, 'Acme Lawncare');
        }
        
        // for convenience, you could use static methods for specific instances like this and create new instead of accessing "this"
        // however, for the purposes of this internal class for this unit test, statics are not possible
        public dbf_IDomainBuilder accountWith72Employees(){
            return this
                    .set(Account.Name, 'Accountwith72Employees')
                    .set(Account.NumberOfEmployees, 72);
        }

        // for convenience, you could use static methods for specific instances like this and create new instead of accessing "this"
        // however, for the purposes of this internal class for this unit test, statics are not possible
        public dbf_IDomainBuilder accountWithPhoneNumber(){
            return this
                    .set(Account.Name, 'AccountWithPhoneNumber')
                    .set(Account.Phone, '+15556747167');
        }
    }

    // internal implementation of an contact builder for these tests
    // an ideal implementation would not be an internal class
    class simpleContactBuilder extends dbf_DomainBuilder {
        public simpleContactBuilder() {
            super(Contact.sObjectType);
            setDiscoverableField(Contact.LastName);
            setDiscoverableField(Contact.FirstName);
            setDiscoverableField(Contact.Email);
        }

        // for convenience, you could use static methods for specific instances like this and create new instead of accessing "this"
        // however, for the purposes of this internal class for this unit test, statics are not possible
        public dbf_IDomainBuilder contactNoAccount1() {
            return this.set(Contact.LastName,'Contact1');
        }

        // for convenience, you could use static methods for specific instances like this and create new instead of accessing "this"
        // however, for the purposes of this internal class for this unit test, statics are not possible
        public dbf_IDomainBuilder contactNoAccount2() {
            return this.set(Contact.LastName, 'Contact2');
        }

        // for convenience, you could use static methods for specific instances like this and create new instead of accessing "this"
        // however, for the purposes of this internal class for this unit test, statics are not possible
         public dbf_IDomainBuilder contactWithEmailOnmitsu(){
            return this
                    .set(Contact.LastName, 'contactWithEmailOnmitsu')
                    .set(Contact.FirstName, 'What')
                    .set(Contact.Email, 'help@onmitsu.com');
        }
    }
}
