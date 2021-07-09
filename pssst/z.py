#General imports
import pandas as pd
import numpy as np
from collections import Counter
from math import radians, cos, sin, asin, sqrt
from datetime import date,datetime

#Imports for models 
from sklearn.naive_bayes import BernoulliNB, GaussianNB
from sklearn.svm import LinearSVC, SVC
from sklearn import svm, tree
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
import graphviz

#Imports for scoring
from sklearn.model_selection import train_test_split, cross_val_score, GridSearchCV
from sklearn.metrics import roc_auc_score, accuracy_score, f1_score
import collections

#Imports for encoding the data

from sklearn.preprocessing import OneHotEncoder

##### Data prep

# This dataset includes terms: Spring 2014,Fall 2014,Spring 2015,Fall 2015,Spring 2016,Fall 2016,Spring 2017,Fall 2017,Spring 2018, Fall 2018
def Load_data(Raw_data):
    df = pd.read_csv(Raw_data, encoding = "ISO-8859-1", low_memory = False)
    df.rename(columns = {'Applicant: SIS ID': 'SIS_ID',
                         'Application: ID': 'Application_ID',
                         'Application: Created Date': 'Application_Created_Date',
                         'Applicant: Contact ID': 'Contact_ID',
                         'Applicant: First Name': 'First_Name',
                         'Applicant: Last Name': 'Last_Name',
                         'Latitude (MapAnything)': 'Latitude',
                         'Longitude (MapAnything)': 'Longitude',
                         'Applicant: Gender': 'Gender',
                         'Applicant: # of non-inquiry Undergrad Apps': '#_of_non-inquiry_Undergrad_Apps',
                         'Term (HEDA)': 'Term',
                         'Applicant: Country of Citizenship': 'Country_of_Citizenship',
                         'Applicant: Canada Status': 'Canada_Status',
                         'Applicant: Birthdate': 'Birthdate',
                         'Applicant: Aboriginal Student': 'Aboriginal_Student',
                         'Applying for Financial Aid': 'Applying_for_Financial_Aid',
                         'Application: Application ID': 'Application_ID',
                         'AQ Candidacy ID': 'AQ_Candidacy_ID',
                         'Program Of Interest (HEDA)': 'Program_Of_Interest',
                         'Stream (Account LU)': 'Stream',
                         'National Student Status': 'National_Student_Status',
                         'Highest Stage Reached': 'Highest_Stage_Reached',
                         'Date Inquiry': 'Date_Inquiry',
                         'Date App Started': 'Date_App_Started',
                         'Date App Submitted': 'Date_App_Submitted',
                         'Date App Complete': 'Date_App_Complete',
                         'Date Admit': 'Date_Admit',
                         'Date Deposit': 'Date_Deposit',
                         'Date Pre-Enrolled': 'Date_Pre-Enrolled',
                         'Date Paid': 'Date_Paid',
                         'Date Enrolled': 'Date_Enrolled',
                         'Date File Closed': 'Date_File_Closed',
                         'Applicant: Source Code': 'Source_Code',
                         'Source Code Category': 'Source_Code_Category',
                         'Import Date': 'Import_Date',
                         'Admit GPA': 'Admit_GPA',
                         'Entrance Type': 'Entrance_Type',
                         'Admit Street Line 1': 'Admit_Street',
                         'Admit City': 'Admit_City',
                         'Admit State/Province': 'Admit_State/Province',
                         'Admit Country': 'Admit_Country',
                         'Current Region': 'Current_Region',
                         'File Forwarded Deferred Application': 'File_Forwarded_Deferred_Application',
                         'Closed File Disposition': 'Closed_File_Disposition',
                         'Candidate Decision': 'Candidate_Decision',
                         'School Decision': 'School_Decision'
                        }, inplace = True)
    return df
    
         
# Remove duplicate SIS IDs keeping the most recent application 
def Drop_dupes(df): 
    df.sort_values(by = ['Application_Created_Date'])
    df = df.drop_duplicates(subset = ['Contact_ID'], keep = 'first')
    return df


def Find_current_term(df):
    Year = df['Term'].str.split(' ')
    

# Create distance from campus field
def Haversine(row):
    # convert decimal degrees to radians
    lon1 = row['Longitude']
    lat1 = row['Latitude']
    lon2 = -122.6006468
    lat2 = 49.1409649    
    if pd.notnull(lon1) and pd.notnull(lat1):  
        lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
        # haversine formula 
        dlon = lon2 - lon1 
        dlat = lat2 - lat1 
        a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
        c = 2 * asin(sqrt(a)) 
        r = 6371 # Radius of earth in kilometers. Use 3956 for miles
        return c * r
    else:
        return -1


# Convert dates to datetime type
def Dates_to_datetime(df):
    df['Date_Inquiry'] = pd.to_datetime(df['Date_Inquiry'], dayfirst = True, format = '%d/%m/%Y')
    df['Date_App_Started'] = pd.to_datetime(df['Date_App_Started'], dayfirst = True, format = '%d/%m/%Y')
    df['Date_App_Submitted'] = pd.to_datetime(df['Date_App_Submitted'], dayfirst = True, format = '%d/%m/%Y')
    df['Date_App_Complete'] = pd.to_datetime(df['Date_App_Complete'], dayfirst = True, format = '%d/%m/%Y')
    df['Date_Admit'] = pd.to_datetime(df['Date_Admit'], dayfirst = True, format = '%d/%m/%Y')
    df['Date_Deposit'] = pd.to_datetime(df['Date_Deposit'], dayfirst = True, format = '%d/%m/%Y')
    df['Date_Pre-Enrolled'] = pd.to_datetime(df['Date_Pre-Enrolled'], dayfirst = True, format = '%d/%m/%Y')
    df['Date_Paid'] = pd.to_datetime(df['Date_Paid'], dayfirst = True, format = '%d/%m/%Y')
    df['Date_Enrolled'] = pd.to_datetime(df['Date_Enrolled'], dayfirst = True, format = '%d/%m/%Y')
    df['Birthdate'] = pd.to_datetime(df['Birthdate'], dayfirst = True, format = '%d/%m/%Y')
    df['Application_Created_Date'] = pd.to_datetime(df['Application_Created_Date'], dayfirst = True, format = '%d/%m/%Y')
    return df


# Create fields for Days at "stage"
def Get_relevant_stages(stage, stages):
    first = stages.index(stage)
    if first == len(stages) - 1:
        return [None,None]
    else:
        return ['Date_' + stages[first], 'Date_' + stages[first + 1]]

def Calculate_days_at_stage(row, stage, stages, algo1):
    first, second = algo1(stage, stages)
    if pd.notnull(first) and pd.notnull(row[first]) and pd.notnull(row[second]):
        return (row[second] - row[first]).days
    else:
        return -1

# Convert stage dates to month day
def StageDates_month_day(df):
    df['Date_Inquiry'] = df['Date_Inquiry'].dt.strftime('%B %m')
    df['Date_App_Started'] = df['Date_App_Started'].dt.strftime('%B %m')
    df['Date_App_Submitted'] = df['Date_App_Submitted'].dt.strftime('%B %m')
    df['Date_App_Complete'] = df['Date_App_Complete'].dt.strftime('%B %m')
    df['Date_Admit'] = df['Date_Admit'].dt.strftime('%B %m')
    df['Date_Deposit'] = df['Date_Deposit'].dt.strftime('%B %m')
    df['Date_Pre-Enrolled'] = df['Date_Pre-Enrolled'].dt.strftime('%B %m')
    df['Date_Paid'] = df['Date_Paid'].dt.strftime('%B %m')
    df['Date_Enrolled'] = df['Date_Enrolled'].dt.strftime('%B %m')
    return df


    ['Date_Inquiry'],
    ['Date_App_Started'],
    ['Date_App_Submitted'],
    ['Date_App_Complete'],
    ['Date_Admit'],
    ['Date_Deposit'],
    ['Date_Pre-Enrolled'],
    ['Date_Paid'],
    ['Date_Enrolled'],
    
    

# Take the two GPA fields: Admit GPA and GPA and create one field
def Merge_GPA(row):
    fGPA = pd.isnull(row['GPA']) == True or row['GPA'] == 0
    fAGPA = pd.isnull(row['Admit_GPA']) == True or row['Admit_GPA'] == 0
    if fGPA == True and fAGPA == False:
        return row['Admit_GPA']
    elif fGPA == False:
        return row['GPA']
    else:
        return -1


# Create a field that only contains the term and not the year. This seperates fall from spring students
def Term_season(row):
    fall = 'Fall'
    spring = 'Spring'
    if fall in row['Term']:
        return fall 
    elif spring in row['Term']:
        return spring
    else: 
        return 'error'


# Create a field that calculates the age of the student when their application was created 
def Calculate_age(row):
    if pd.isnull(row['Birthdate']):
        return -1
    else:
        appCreatedDate = row['Application_Created_Date']
        born = row['Birthdate']
        age = appCreatedDate.year - born.year - ((appCreatedDate.month, appCreatedDate.day) < (born.month, born.day))
        return age


def Final_cleaning(df):
    # Replace NaN with Unknown
    df.update(df[['School_Decision',
                  'Candidate_Decision',
                  'Closed_File_Disposition',
                  'Admit_Country',
                  'Admit_State/Province',
                  'Admit_City',
                  'Entrance_Type',
                  'Source_Code',
                  'National_Student_Status',
                  'Stream',
                  'Program_Of_Interest',
                  'Applying_for_Financial_Aid',
                  'Canada_Status',
                  'Country_of_Citizenship',
                  'Gender']].fillna('Unknown'))

    # Include only fields to be analyzed
    df = df.drop(['Birthdate',
                  'Admit_Street',
                  'Longitude',
                  'Latitude',
                  'Application_Created_Date',
                  'Date_File_Closed',
                  'GPA',
                  'Admit_GPA',
                  'Import_Date',
                  'AQ_Candidacy_ID',
                  '#_of_non-inquiry_Undergrad_Apps',
                  'Last_Name',
                  'SIS_ID',
                  'First_Name',
                  'Contact_ID', 
                  'Source_Code_Category',
                  'File_Forwarded_Deferred_Application',
                  'Closed_File_Disposition',
                  'Candidate_Decision',
                  'School_Decision',
                  'Date_Inquiry',
                  'Date_App_Started',
                  'Date_App_Submitted',
                  'Date_App_Complete',
                  'Date_Admit',
                  'Date_Deposit',
                  'Date_Pre-Enrolled',
                  'Date_Paid',
                  'Date_Enrolled',
                  'Days_at_Inquiry',
                  'Days_at_App_Started',
                  'Days_at_App_Submitted',
                  'Days_at_App_Complete',
                  'Days_at_Admit',
                  'Days_at_Deposit',
                  'Days_at_Pre-Enrolled',
                  'Days_at_Paid'
                 ], 
                   axis = 1)
    return df


def Balance_historic_data(df):
    # Balance the historic data between enrolled and non-enrolled
    df['Highest_Stage_Reached'] = df['Highest_Stage_Reached'].map({'App Submitted': 0,
                                                                   'Admit': 0,
                                                                   'App Started': 0,
                                                                   'App Complete': 0,
                                                                   'Deposit': 0,
                                                                   'Pre-Enrolled': 0,
                                                                   'Paid': 0,
                                                                   'Enrolled': 1})

    df_historic = df[df.Term != 'Fall 2018']
    df_current = df[df.Term == 'Fall 2018']
    df_enrolled = df_historic[df_historic.Highest_Stage_Reached == 1]
    df_nonenrolled = df_historic[df_historic.Highest_Stage_Reached == 0]
    
    df_nonenrolled = df_nonenrolled.sample(len(df_enrolled.index))
    df_historic = df_nonenrolled.append(df_enrolled)
    df = df_historic.append(df_current)
    return df


def Encode(df):
    historic = len(df[df.Term != 'Fall 2018'].index)
    current = len(df[df.Term == 'Fall 2018'].index)
    
    df = pd.get_dummies(df)
    
    df_historic, df_current = df.head(historic), df.tail(current)
    df_current = df_current.drop('Highest_Stage_Reached', axis = 1)
    df_target = df_historic['Highest_Stage_Reached']
    df_historic = df_historic.drop('Highest_Stage_Reached', axis = 1)
    
    X_train, X_test, y_train, y_test = train_test_split(df_historic, df_target, test_size = 0.2, random_state = 1)
    
    return X_train, X_test, y_train, y_test, df_current
    
    
##### Models

def fit_predict_score(estimator, X_train, X_test, y_train, y_test, df_current):
    
    clf = estimator()
    clf.fit(X_train, y_train)
    
    Individual_prediction = clf.predict_proba(df_current) if clf.probability else None
    Current_prediction = clf.predict(df_current) 
    Enrolled_prediction = collections.Counter(Current_prediction)
    
    prediction = clf.predict(X_test)
    a = []
    b = []
    c = []
    for i in range(5):
        accuracy = accuracy_score(y_test, prediction)  
        ra_score = roc_auc_score(y_test, prediction)
        f1_Score = f1_score(y_test, prediction)
        
        a.append(accuracy)
        accuracy_grouping = np.array(a)
        b.append(ra_score)
        ra_score_grouping = np.array(b)
        c.append(f1_Score)
        f1_Score_grouping = np.array(c)
    
    CV_Score = cross_val_score(clf, X_train, y_train, cv = 5)
    
    return Individual_prediction, Enrolled_prediction, f1_Score_grouping, accuracy_grouping, ra_score_grouping, CV_Score
    
def NB_Bernoulli(X_train, X_test, y_train, y_test, df_current):
    
    clf = BernoulliNB()
    clf.fit(X_train, y_train)
    
    #### individual values
    Individual_prediction = clf.predict_proba(df_current)
    
    Current_prediction = clf.predict(df_current) 
    Enrolled_prediction = collections.Counter(Current_prediction)
    
    prediction = clf.predict(X_test)
    a = []
    b = []
    c = []
    for i in range(5):
        accuracy = accuracy_score(y_test, prediction)  
        ra_score = roc_auc_score(y_test, prediction)
        f1_Score = f1_score(y_test, prediction)
        
        a.append(accuracy)
        accuracy_grouping = np.array(a)
        b.append(ra_score)
        ra_score_grouping = np.array(b)
        c.append(f1_Score)
        f1_Score_grouping = np.array(c)
    
    CV_Score = cross_val_score(clf, X_train, y_train, cv = 5)
    
    #return Individual_prediction 
    return Enrolled_prediction, f1_Score_grouping, accuracy_grouping, ra_score_grouping, CV_Score


def NB_Gaussian(X_train, X_test, y_train, y_test, df_current):
    clf = GaussianNB()
    clf.fit(X_train, y_train)
    Current_prediction = clf.predict(df_current) 
    Enrolled_prediction = collections.Counter(Current_prediction)
    
    prediction = clf.predict(X_test)
    a = []
    b = []
    c = []
    for i in range(5):
        accuracy = accuracy_score(y_test, prediction)  
        ra_score = roc_auc_score(y_test, prediction)
        f1_Score = f1_score(y_test, prediction)
        
        a.append(accuracy)
        accuracy_grouping = np.array(a)
        b.append(ra_score)
        ra_score_grouping = np.array(b)
        c.append(f1_Score)
        f1_Score_grouping = np.array(c)
    
    CV_Score = cross_val_score(clf, X_train, y_train, cv = 5)
    
    return Enrolled_prediction, f1_Score_grouping, accuracy_grouping, ra_score_grouping, CV_Score

def SVM_Linear(X_train, X_test, y_train, y_test, df_current):
    clf = LinearSVC()
    clf.fit(X_train, y_train)
    Current_prediction = clf.predict(df_current) 
    Enrolled_prediction = collections.Counter(Current_prediction)
     
    prediction = clf.predict(X_test)
    a = []
    b = []
    c = []
    for i in range(5):
        accuracy = accuracy_score(y_test, prediction)  
        ra_score = roc_auc_score(y_test, prediction)
        f1_Score = f1_score(y_test, prediction)
        
        a.append(accuracy)
        accuracy_grouping = np.array(a)
        b.append(ra_score)
        ra_score_grouping = np.array(b)
        c.append(f1_Score)
        f1_Score_grouping = np.array(c)
    
    CV_Score = cross_val_score(clf, X_train, y_train, cv = 5)
    
    return Enrolled_prediction, f1_Score_grouping, accuracy_grouping, ra_score_grouping, CV_Score


def SVM_rbf(X_train, X_test, y_train, y_test, df_current):
    clf = svm.SVC()
    clf.fit(X_train, y_train)
    Current_prediction = clf.predict(df_current) 
    Enrolled_prediction = collections.Counter(Current_prediction)
    
    prediction = clf.predict(X_test)
    a = []
    b = []
    c = []
    for i in range(5):
        accuracy = accuracy_score(y_test, prediction)  
        ra_score = roc_auc_score(y_test, prediction)
        f1_Score = f1_score(y_test, prediction)
        
        a.append(accuracy)
        accuracy_grouping = np.array(a)
        b.append(ra_score)
        ra_score_grouping = np.array(b)
        c.append(f1_Score)
        f1_Score_grouping = np.array(c)
    
    CV_Score = cross_val_score(clf, X_train, y_train, cv = 5)
    
    return Enrolled_prediction, f1_Score_grouping, accuracy_grouping, ra_score_grouping, CV_Score

def Logistic_Regression(X_train, X_test, y_train, y_test, df_current):
    clf = LogisticRegression()
    clf.fit(X_train, y_train, sample_weight = None)
    Current_prediction = clf.predict(df_current) 
    Enrolled_prediction = collections.Counter(Current_prediction)
    
    prediction = clf.predict(X_test)
    a = []
    b = []
    c = []
    for i in range(5):
        accuracy = accuracy_score(y_test, prediction)  
        ra_score = roc_auc_score(y_test, prediction)
        f1_Score = f1_score(y_test, prediction)
        
        a.append(accuracy)
        accuracy_grouping = np.array(a)
        b.append(ra_score)
        ra_score_grouping = np.array(b)
        c.append(f1_Score)
        f1_Score_grouping = np.array(c)
    
    CV_Score = cross_val_score(clf, X_train, y_train, cv = 5)
    
    return Enrolled_prediction, f1_Score_grouping, accuracy_grouping, ra_score_grouping, CV_Score

def Main():
    df = Load_data('ERx_Jul_5_NoSpring.csv')
    df['Distance_From_TWU'] = df.apply(Haversine, axis = 1)
    df = Drop_dupes(df)
    df = Dates_to_datetime(df)
    
    stages = ['Inquiry','App_Started','App_Submitted','App_Complete','Admit','Deposit','Pre-Enrolled','Paid']
    for s in stages:        
        newcolumn = 'Days_at_' + s
        df[newcolumn] = df.apply(Calculate_days_at_stage, stage=s, stages=stages, algo1=Get_relevant_stages, axis = 1)

    df = StageDates_month_day(df)  
    df['Merge_GPA'] = df.apply(Merge_GPA, axis = 1)  
    df['Term_season'] = df.apply(Term_season, axis = 1)    
    df['Age'] = df.apply(Calculate_age, axis = 1) 
    df = Final_cleaning(df)
    df_view_results = Balance_historic_data(df)
    X_train, X_test, y_train, y_test, df_current = Encode(df_view_results)
    
    #Individual_prediction = NB_Bernoulli(X_train, X_test, y_train, y_test, df_current)
    Enrolled_prediction, f1_Score_grouping, accuracy_grouping, ra_score_grouping, CV_Score = NB_Bernoulli(X_train, X_test, y_train, y_test, df_current)
    #Enrolled_prediction, f1_Score_grouping, accuracy_grouping, ra_score_grouping, CV_Score = NB_Gaussian(X_train, X_test, y_train, y_test, df_current)
    #Enrolled_prediction, f1_Score_grouping, accuracy_grouping, ra_score_grouping, CV_Score = SVM_rbf(X_train, X_test, y_train, y_test, df_current)
    #Enrolled_prediction, f1_Score_grouping, accuracy_grouping, ra_score_grouping, CV_Score = SVM_Linear(X_train, X_test, y_train, y_test, df_current)
    #Enrolled_prediction, f1_Score_grouping, accuracy_grouping, ra_score_grouping, CV_Score = Logistic_Regression(X_train, X_test, y_train, y_test, df_current)
    #graph = Decision_tree(X_train, y_train)
    
    #return Individual_prediction
    return df_view_results, Enrolled_prediction, f1_Score_grouping, accuracy_grouping, ra_score_grouping, CV_Score 

#df_view_results, Enrolled_prediction, f1_Score_grouping, accuracy_grouping, ra_score_grouping, CV_Score = Main()
#print("Number of students predicted to enroll: ", Enrolled_prediction, 
#      "\nf1 Score: %0.2f (+/- %0.2f)" % (f1_Score_grouping.mean(), f1_Score_grouping.std() * 2),
#      "\nAccuracy of prediction: %0.2f (+/- %0.2f)" % (accuracy_grouping.mean(), accuracy_grouping.std() * 2), 
#      "\nROC AUC score: %0.2f (+/- %0.2f)" % (ra_score_grouping.mean(), ra_score_grouping.std() * 2),
#      "\nCV_Accuracy: %0.2f (+/- %0.2f)" % (CV_Score.mean(), CV_Score.std() * 2))
#
#df_view_results.to_csv('Results.csv')
#
## graph = Main()
## graph.render("PSSS")
#Individual_prediction = Main()
#np.savetxt('Individual_prediction.csv', Individual_prediction, delimiter = ',')
##Individual_prediction.to_csv('Individual_prediction.csv')


df = Load_data('ERx_Jul_5_NoSpring.csv')
df['Distance_From_TWU'] = df.apply(Haversine, axis = 1)
df = Drop_dupes(df)
df = Dates_to_datetime(df)

stages = ['Inquiry','App_Started','App_Submitted','App_Complete','Admit','Deposit','Pre-Enrolled','Paid']
for s in stages:        
    newcolumn = 'Days_at_' + s
    df[newcolumn] = df.apply(Calculate_days_at_stage, stage=s, stages=stages, algo1=Get_relevant_stages, axis = 1)

df.to_csv('before.csv')
df = StageDates_month_day(df)  
df.to_csv('after.csv')
#df['Merge_GPA'] = df.apply(Merge_GPA, axis = 1)  
#df['Term_season'] = df.apply(Term_season, axis = 1)    
#df['Age'] = df.apply(Calculate_age, axis = 1) 
#df = Final_cleaning(df)
#df_view_results = Balance_historic_data(df)

    
for estimator in [BernoulliNB, GaussianNB, SVC, LinearSVC, LogisticRegression]:
    Individual_prediction, Enrolled_prediction, f1_Score_grouping, accuracy_grouping, ra_score_grouping, CV_Score = fit_predict_score(estimator, X_train, X_test, y_train, y_test, df_current)
    print("Number of students predicted to enroll: ", Enrolled_prediction, 
          "\nf1 Score: %0.2f (+/- %0.2f)" % (f1_Score_grouping.mean(), f1_Score_grouping.std() * 2),
          "\nAccuracy of prediction: %0.2f (+/- %0.2f)" % (accuracy_grouping.mean(), accuracy_grouping.std() * 2), 
          "\nROC AUC score: %0.2f (+/- %0.2f)" % (ra_score_grouping.mean(), ra_score_grouping.std() * 2),
          "\nCV_Accuracy: %0.2f (+/- %0.2f)" % (CV_Score.mean(), CV_Score.std() * 2))
