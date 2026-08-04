@isTest
private class DoctorServiceTest {
    @isTest
    static void testPositive_doctorToOpenClinic() {
        Clinic__c  cln = TestDataFactory.createClinic(true);
        insert cln;
        Doctor__c dr = TestDataFactory.createDoctor(cln.Id);
        Test.startTest();
        insert dr;
        Test.stopTest();
        
        Doctor__c insertedDoctor =
            [SELECT Id, Clinic__c FROM
        Doctor__c WHERE Id = :dr.Id];
        
        System.assertEquals(cln.Id, insertedDoctor.Clinic__c);
    }
    @isTest
    static void testNegative_doctorToOpenClinic() {
        Clinic__c  cln = TestDataFactory.createClinic(false);
        insert cln;
        Doctor__c dr = TestDataFactory.createDoctor(cln.Id);
        Test.startTest();
        try {
            insert dr;
            System.assert(false, 'Expected a DmlException.');
        }
        catch (DmlException e) {
            System.assert(
                e.getMessage().contains(
                'Doctors cannot be assigned to a clinic that is not open for business.'
                )
                );
        }
        Test.stopTest();
    }
    @isTest
    static void testPositive_doctorToOpenClinicUpdate(){
        Clinic__c clinic1 = TestDataFactory.createClinic(true);
        Clinic__c clinic2 = TestDataFactory.createClinic(true);
        
        insert clinic1;
        insert clinic2;
        
        Doctor__c dr = TestDataFactory.createDoctor(clinic1.Id);
        insert dr;
        dr.Clinic__c = clinic2.Id;
        Test.startTest();
        update dr;
        Test.stopTest();
        
        Doctor__c updatedDoctor = [SELECT Clinic__c FROM Doctor__c WHERE Id = :dr.Id];
        System.assertEquals(clinic2.Id, updatedDoctor.Clinic__c);
    }
    
    @isTest
    static void testNegative_doctorToOpenClinicUpdate(){
        Clinic__c clinic1 = TestDataFactory.createClinic(true);
        Clinic__c clinic2 = TestDataFactory.createClinic(false);
        
        insert clinic1;
        insert clinic2;
        
        Doctor__c dr = TestDataFactory.createDoctor(clinic1.Id);
        insert dr;
        dr.Clinic__c = clinic2.Id;
        Test.startTest();
        try {
            update dr;
            System.assert(false, 'Expected a DmlException.');
        }
        catch (DmlException e) {
            System.assert(
                e.getMessage().contains(
                'Doctors cannot be assigned to a clinic that is not open for business.'
                )
                );
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testPositive_DoctorWithoutClinic() {
        
        Doctor__c dr = TestDataFactory.createDoctor(null);
        
        Test.startTest();
        insert dr;
        Test.stopTest();
        
        Doctor__c insertedDoctor =
            [SELECT Id, Clinic__c
     FROM Doctor__c
     WHERE Id = :dr.Id];
        
        System.assertEquals(null, insertedDoctor.Clinic__c);
    }
}