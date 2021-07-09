#!/usr/bin/env python

import pandas as pd

sourcefolder = "/home/jus/notebook/jus/erx/source"

terms_old = pd.read_csv("{}/EnrollmentrxRx__Term__c.csv".format(sourcefolder), parse_dates=True, encoding='latin-1')
terms_old = terms_old[['Id', 'Name']].rename(index=str, columns={"Name": "Term"})
terms_new = pd.read_csv("{}/hed__Term__c.csv".format(sourcefolder), parse_dates=True, encoding='latin-1')
terms_new = terms_new[['Id', 'Name']].rename(index=str, columns={"Name": "Term"})

df = pd.read_csv("{}/Contact.csv".format(sourcefolder), parse_dates=True, encoding='latin-1', low_memory=False)

hundred = [
	'Aboriginal_Identity__c',
	'Aboriginal_Student__c',
	'AccountId',
	'Active_Call_Campaign_Name__c',
	'Active_Live_Event_Campaign_Name__c',
	'Anticipated_HS_Grad_Year__c',
	'Area_of_Study_Txt__c',
	'AssistantName',
	'AssistantPhone',
	'Athletic_Status__c',
	'Athletic_Team__c',
	'Attended_Individual_Visit__c',
	'Attended_Preview_Weekend__c',
	'Birth_Name__c',
	'Birthdate',
	'Canada_Status__c',
	'Candidate_Disqualified__c',
	'Candidate_call_time__c',
	'Coaching_Reference_Contact__c',
	'Comments_Inquiry__c',
	'Competitor__c',
	'Concert_Name__c',
	'Country_of_Citizenship__c',
	'Create_Portal_User2__c',
	'Create_Portal_User__c',
	'CreatedById',
	'CreatedDate',
	'Current_Club_Team__c',
	'Current_Ed_Level__c',
	'Department',
	'Description',
	'DoNotCall',
	'Dominant_Foot__c',
	'ERx_Events__How_did_you_hear_about_us__c',
	'ERx_Forms__Create_Portal_User__c',
	'ERx_Forms__Create_User_with_Profile__c',
	'ERx_Forms__TestClassPicklist__c',
	'ESLI_Student_Number__c',
	'Email',
	'EmailBouncedDate',
	'EmailBouncedReason',
	'Email_Opt_In__c',
	'English_Primary_Language__c',
	'EnrollmentrxRx__Active_Enrollment_Opportunity__c',
	'EnrollmentrxRx__Anticipated_Term_Start_Date__c',
	'EnrollmentrxRx__Create_Touch_Point__c',
	'EnrollmentrxRx__Gender__c',
	'EnrollmentrxRx__Has_EO_Check__c',
	'EnrollmentrxRx__High_School_Code__c',
	'EnrollmentrxRx__High_School_Employer__c',
	'EnrollmentrxRx__High_School__c',
	'EnrollmentrxRx__How_did_you_hear_about_us__c',
	'EnrollmentrxRx__Program_of_Interest__c',
	'EnrollmentrxRx__SIS_ID__c',
	'EnrollmentrxRx__Secondary_Email__c',
	'EnrollmentrxRx__Status_Modified_Date__c',
	'Entrance_Term_HEDA__c',
	'Entrance_Term_Inquiry__c',
	'Expired_Status_Change_Request__c',
	'Fax',
	'FirstName',
	'Grade_Level__c',
	'HasOptedOutOfEmail',
	'HasOptedOutOfFax',
	'HomePhone',
	'Housing_Status__c',
	'Id',
	'Import_Date__c',
	'IsDeleted',
	'Is_Locked_By_Agent__c',
	'Jigsaw',
	'JigsawContactId',
	'LastActivityDate',
	'LastCURequestDate',
	'LastCUUpdateDate',
	'LastModifiedById',
	'LastModifiedDate',
	'LastName',
	'Last_Touch_Point_Date__c',
	'Last_Wrap_Up_Code__c',
	'LeadSource',
	'Level_of_Interest__c',
	'LocationTxt__c',
	'Location_Campus__c',
	'Locked_By_Agent_User__c',
	'MailingCity',
	'MailingCity__c',
	'MailingCountry',
	'MailingCountry__c',
	'MailingGeocodeAccuracy',
	'MailingLatitude',
	'MailingLongitude',
	'MailingPostalCode',
	'MailingState',
	'MailingState_ProvinceTxt__c',
	'MailingState_Province_PL__c',
	'MailingStreet',
	'MailingStreetLine1__c',
	'MailingStreetLine2__c',
	'MailingStreetLine3__c',
	'MailingZip_PostalCode__c',
	'Manual_Ownership_Override__c',
	'MasterRecordId',
	'Middle_Initial__c',
	'Middle_Name__c',
	'MobilePhone',
	'National_Student_Status__c',
	'On_Scotts_List__c',
	'Original_Region__c',
	'OtherCity',
	'OtherCountry',
	'OtherGeocodeAccuracy',
	'OtherLatitude',
	'OtherLongitude',
	'OtherPhone',
	'OtherPostalCode',
	'OtherState',
	'OtherStreet',
	'Other_Relatives_Attend_TWU__c',
	'Other_Relatives_TWU_Relationships__c',
	'OwnerId',
	'Parents_Info_Provided__c',
	'Payment_Received__c',
	'PermCity__c',
	'PermCountry__c',
	'PermState_ProvPL__c',
	'PermState_ProvTxt__c',
	'PermStreetLine1__c',
	'PermStreetLine2__c',
	'PermStreetLine3__c',
	'PermZipPostalCode__c',
	'Perm_Address_Same__c',
	'Phone',
	'Playing_Strengths__c',
	'Playing_Weaknesses__c',
	'Preferred_First_Name__c',
	'Preview_Weekend_Status__c',
	'Primary_Academic_Program__c',
	'Primary_Department__c',
	'Primary_Educational_Institution__c',
	'Primary_Position__c',
	'Primary_Sports_Organization__c',
	'Program_of_Interest_HEDA__c',
	'Program_of_Interest_Text__c',
	'Receive_Texts__c',
	'RecordTypeId',
	'ReportsToId',
	'SE_Student_Rating__c',
	'SE_Student_Top_Barrier__c',
	'Salutation',
	'School_HEDA__c',
	'School_Name_Text__c',
	'School_RFI_Prog_Catalog__c',
	'School_RFI__c',
	'Secondary_Position__c',
	'SendAdmissionsTwupassPasswordResetEmail__c',
	'Siblings_Attended_TWU__c',
	'Siblings__c',
	'Social_Insurance_Number__c',
	'Social_Security_Number__c',
	'Source_Code_Text__c',
	'Source_Code__c',
	'Stream_AQ_ID__c',
	'Stream_HEDA__c',
	'Stream_Inquiry__c',
	'Suffix__c',
	'SystemModstamp',
	'Text_Okay__c',
	'Title',
	'Work_Phone__c',
	'hed__AlternateEmail__c',
	'hed__Citizenship__c',
	'hed__Country_of_Origin__c',
	'hed__Current_Address__c',
	'hed__Deceased__c',
	'hed__Do_Not_Contact__c',
	'hed__Dual_Citizenship__c',
	'hed__Ethnicity__c',
	'hed__Exclude_from_Household_Formal_Greeting__c',
	'hed__Exclude_from_Household_Informal_Greeting__c',
	'hed__Exclude_from_Household_Name__c',
	'hed__FERPA__c',
	'hed__Financial_Aid_Applicant__c',
	'hed__Gender__c',
	'hed__HIPAA_Detail__c',
	'hed__HIPAA__c',
	'hed__Military_Background__c',
	'hed__Military_Service__c',
	'hed__Naming_Exclusions__c',
	'hed__PreferredPhone__c',
	'hed__Preferred_Email__c',
	'hed__Primary_Address_Type__c',
	'hed__Primary_Household__c',
	'hed__Primary_Organization__c',
	'hed__Race__c',
	'hed__Religion__c',
	'hed__Secondary_Address_Type__c',
	'hed__Social_Security_Number__c',
	'hed__UniversityEmail__c',
	'hed__WorkEmail__c',
	'hed__WorkPhone__c',
	'hed__is_Address_Override__c',
	'pi__Needs_Score_Synced__c',
	'pi__Pardot_Last_Scored_At__c',
	'pi__campaign__c',
	'pi__comments__c',
	'pi__conversion_date__c',
	'pi__conversion_object_name__c',
	'pi__conversion_object_type__c',
	'pi__created_date__c',
	'pi__first_activity__c',
	'pi__first_search_term__c',
	'pi__first_search_type__c',
	'pi__first_touch_url__c',
	'pi__grade__c',
	'pi__last_activity__c',
	'pi__notes__c',
	'pi__pardot_hard_bounced__c',
	'pi__score__c',
	'pi__url__c',
	'pi__utm_campaign__c',
	'pi__utm_content__c',
	'pi__utm_medium__c',
	'pi__utm_source__c',
	'pi__utm_term__c'
]

df = df[hundred]

ignored = [
    'Aboriginal_Identity__c',
    'Active_Call_Campaign_Name__c',
    'Active_Live_Event_Campaign_Name__c',
    'Anticipated_HS_Grad_Year__c',
    'Area_of_Study_Txt__c',
    'AssistantName',
    'AssistantPhone',
    'Athletic_Status__c',
    'Athletic_Team__c',
    'Attended_Preview_Weekend__c',
    'Birth_Name__c',
    'Coaching_Reference_Contact__c',
    'Competitor__c',
    'Current_Club_Team__c',
    'Current_Ed_Level__c',
    'Department',
    'Dominant_Foot__c',
    'ERx_Events__How_did_you_hear_about_us__c',
    'ERx_Forms__Create_User_with_Profile__c',
    'ERx_Forms__TestClassPicklist__c',
    'EnrollmentrxRx__Anticipated_Term_Start_Date__c',
    'EnrollmentrxRx__Create_Touch_Point__c',
    'EnrollmentrxRx__Has_EO_Check__c',
    'EnrollmentrxRx__High_School_Code__c',
    'EnrollmentrxRx__High_School_Employer__c',
    'EnrollmentrxRx__High_School__c',
    'EnrollmentrxRx__How_did_you_hear_about_us__c',
    'EnrollmentrxRx__Secondary_Email__c',
    'Expired_Status_Change_Request__c',
    'Fax',
    'HasOptedOutOfFax',
    'IsDeleted',
    'Jigsaw',
    'JigsawContactId',
    'LastCURequestDate',
    'LastCUUpdateDate',
    'Last_Touch_Point_Date__c',
    'LocationTxt__c',
    'Locked_By_Agent_User__c',
    'MailingGeocodeAccuracy',
    'Manual_Ownership_Override__c',
    'MasterRecordId',
    'OtherGeocodeAccuracy',
    'OtherLatitude',
    'OtherLongitude',
    'Playing_Strengths__c',
    'Playing_Weaknesses__c',
    'Primary_Academic_Program__c',
    'Primary_Department__c',
    'Primary_Educational_Institution__c',
    'Primary_Sports_Organization__c',
    'ReportsToId',
    'Title',
    'hed__Citizenship__c',
    'hed__Country_of_Origin__c',
    'hed__Deceased__c',
    'hed__Do_Not_Contact__c',
    'hed__Dual_Citizenship__c',
    'hed__Ethnicity__c',
    'hed__Exclude_from_Household_Formal_Greeting__c',
    'hed__Exclude_from_Household_Informal_Greeting__c',
    'hed__Exclude_from_Household_Name__c',
    'hed__FERPA__c',
    'hed__Financial_Aid_Applicant__c',
    'hed__HIPAA_Detail__c',
    'hed__HIPAA__c',
    'hed__Military_Background__c',
    'hed__Military_Service__c',
    'hed__Naming_Exclusions__c',
    'hed__PreferredPhone__c',
    'hed__Primary_Address_Type__c',
    'hed__Primary_Household__c',
    'hed__Primary_Organization__c',
    'hed__Race__c',
    'hed__Religion__c',
    'hed__Secondary_Address_Type__c',
    'hed__Social_Security_Number__c',
    'hed__UniversityEmail__c',
    'hed__WorkEmail__c',
    'hed__WorkPhone__c',
    'hed__is_Address_Override__c',
    'pi__Needs_Score_Synced__c',
    'pi__grade__c',
    'pi__notes__c',
    'pi__utm_campaign__c',
    'pi__utm_content__c',
    'pi__utm_medium__c',
    'pi__utm_source__c',
    'pi__utm_term__c'
]
essays = {
    'inquiry.csv': ['Comments_Inquiry__c', 'Description']
}
contactfields = [
    'HomePhone',
    'MailingCity',
    'MailingCity__c',
    'MailingCountry',
    'MailingCountry__c',
    'MailingGeocodeAccuracy',
    'MailingPostalCode',
    'MailingState',
    'MailingState_ProvinceTxt__c',
    'MailingState_Province_PL__c',
    'MailingStreet',
    'MailingStreetLine1__c',
    'MailingStreetLine2__c',
    'MailingStreetLine3__c',
    'MailingZip_PostalCode__c',
    'MobilePhone',
    'OtherCity',
    'OtherCountry',
    'OtherPhone',
    'OtherPostalCode',
    'OtherState',
    'OtherStreet',
    'PermCity__c',
    'PermCountry__c',
    'PermState_ProvPL__c',
    'PermState_ProvTxt__c',
    'PermStreetLine1__c',
    'PermStreetLine2__c',
    'PermStreetLine3__c',
    'PermZipPostalCode__c',
    'Perm_Address_Same__c',
    'Phone',
    'Work_Phone__c',
    'hed__AlternateEmail__c',
    'hed__Current_Address__c',
    'hed__Preferred_Email__c',
]
owners = [
    'AccountId',
    'CreatedById',
    'LastModifiedById',
    'OwnerId',
]
dates = [
    'CreatedDate',
    'LastActivityDate',
    'LastModifiedDate',
    'SystemModstamp',
]

essayfields = [item for sublist in essays.values() for item in sublist]

df1 = df.drop(columns=ignored+essayfields+contactfields+owners+dates)

df2 = df1.join(terms_old.set_index('Id'), on='Entrance_Term_HEDA__c')
df2 = df2.join(terms_new.set_index('Id'), on='Entrance_Term_HEDA__c', lsuffix='_old', rsuffix='_new')
df2 = df2.loc[df2['Term_new'].notnull()]

df2['Term_semester'] = df2['Term_new'].apply(lambda x: x.split()[0])
df2['Term_year'] = df2['Term_new'].apply(lambda x: x.split()[1])

z = df2.loc[df2['Term_new'].str.contains('201[4-8]')]
for c in z.columns:
    print('-'*80)
    print(z[c].value_counts())
#z.to_csv("z.csv", index=False)

