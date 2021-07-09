#!/usr/bin/python

import argparse
from PIL import Image
from glob import glob
import pandas as pd
from tqdm import tqdm
import os

"""our helper class"""
class Pandas:
    essays = {
        'app': {
            'source': 'EnrollmentrxRx__Enrollment_Opportunity__c.csv',
            'id': 'EnrollmentrxRx__Applicant__c',
            'files': {
                'aboutme.csv': ['About_Me__c'],
                'education.csv': ['Educ_Career_Goals__c', 'Teaching_Experiences__c'],
                'nursing.csv': ['Nursing_Career_Goals__c', 'Nursing_Career_Reasons__c', 'Nursing_Communication_Skills__c', 'Nursing_Crim_Impairment_Expl__c', 'Nursing_Impairments__c', 'Nursing_Other_Questions__c', 'Nursing_Previous_App_Date__c', 'Nursing_Previous_App__c', 'Nursing_Registration_Number__c', 'Nursing_Rigor_Challenge__c', 'Nursing_Self_Motivation__c', 'Nursing_Volunteer_Exp__c', 'Nursing_What_it_offers__c', 'Nursing_What_you_offer__c', 'Nursing_Why_TWU__c'],
                'lifeexp.csv': ['Significant_Life_Experience__c'],
                'extracurr.csv': ['Extracurricular__c'],
                'questions.csv': ['Questions__c'],
                'whyapply.csv': ['Why_Applying__c'],
                'activities.csv': ['Activities__c']
            }
        },
        'contact': {
            'source': 'Contact.csv',
            'id': 'Id',
            'files': {
                'inquiry.csv': ['Comments_Inquiry__c', 'Description']
            }
        }
    }

    """pick random files and move them"""
    def pick_random_files(self, args):
        import random
        import shutil
        g = glob("{}/*".format(args.inputfolder))
        if len(g) >= args.numfiles:
            sample = random.sample(range(1, len(g)), args.numfiles)
            for n in sample:
                fromfile = g[n]
                tofile = "{}/{}".format(args.outputfolder, os.path.basename(fromfile))
                print(fromfile, tofile)
                shutil.copyfile(fromfile, tofile)

    """grab essay fields and save them to files"""
    def grab_essays(self, args):
        #contacts = pd.read_csv("{}/Contact.csv".format(args.inputfolder), encoding='latin-1')
        for o in self.essays.keys(): # Objects
            print("Reading {}".format(o))
            obj = self.essays[o]
            df = pd.read_csv("{}/{}".format(args.inputfolder, obj['source']), encoding='latin-1', low_memory=False)
            idfield = obj['id']
            for f in obj['files'].keys():
                for ff in obj['files'][f]:
                    x = df[['Id', ff]].loc[df[ff].notnull()]
                    if x.size > 0:
                        outpath = "{}/{}".format(args.outputfolder, ff)
                        os.makedirs(outpath, exist_ok=True)
                        for i, row in x.iterrows():
                            filename = "{}/{}.csv".format(outpath, row['Id'])
                            print("Writing {}".format(filename))
                            with open(filename, "w") as outfile:
                                outfile.write(row[ff])

"""parsing and configuration"""
def parse_args():
    desc = "Pandas tasks"
    parser = argparse.ArgumentParser(description=desc)

    parser.add_argument('--task', type=str, default=None, help='Which task?', required=True, choices=['grab_essays', 'pick_random_files'])

    parser.add_argument('--inputfolder', type=str, default=None, help='Input folder')
    parser.add_argument('--inputfile', type=str, default=None, help='Input file')
    parser.add_argument('--outputfolder', type=str, default=None, help='Output folder')
    parser.add_argument('--outputfile', type=str, default=None, help='Output file')
    parser.add_argument('--numfiles', type=int, default=None, help='Number of files')

    return check_args(parser.parse_args())

"""checking arguments"""
def check_args(args):
    return args

if __name__ == '__main__':
    # Parse arguments.
    args = parse_args()
    if args is None:
        print("Problem!")
        exit()

    f = getattr(Pandas(), args.task)
    f(args)

#df.loc[:, ['Id', 'About_Me__c', 'Significant_Life_Experience__c']].loc[df['About_Me__c'].notnull() | df['Significant_Life_Experience__c'].notnull()]
#aboutme = df[['Id', 'About_Me__c']].loc[df['About_Me__c'].notnull()]
#aboutme.set_index('Id').to_csv('aboutme.csv')
#education = df[['Id', 'Educ_Career_Goals__c', 'Teaching_Experiences__c']].loc[(df['Educ_Career_Goals__c'].notnull()) | (df['Teaching_Experiences__c'].notnull())]
#education.set_index('Id').to_csv('essays/education.csv')
#nursing = df[['Id', 'Nursing_Career_Goals__c', 'Nursing_Career_Reasons__c', 'Nursing_Communication_Skills__c', 'Nursing_Crim_Impairment_Expl__c', 'Nursing_Impairments__c', 'Nursing_Other_Questions__c', 'Nursing_Previous_App_Date__c', 'Nursing_Previous_App__c', 'Nursing_Registration_Number__c', 'Nursing_Rigor_Challenge__c', 'Nursing_Section__c', 'Nursing_Self_Motivation__c', 'Nursing_Volunteer_Exp__c', 'Nursing_What_it_offers__c', 'Nursing_What_you_offer__c', 'Nursing_Why_TWU__c']].loc[df['Nursing_Career_Reasons__c'].notnull()]
#nursing.set_index('Id').to_csv('nursing.csv')
#lifeexp = df[['Id', 'Significant_Life_Experience__c']].loc[df['Significant_Life_Experience__c'].notnull()]
#lifeexp.set_index('Id').to_csv('lifeexp.csv')
#extracurr = df[['Id', 'Extracurricular__c']].loc[df['Extracurricular__c'].notnull()]
#extracurr.set_index('Id').to_csv('extracurr.csv')
#questions = df[['Id', 'Questions__c']].loc[df['Questions__c'].notnull()]
#questions.set_index('Id').to_csv('questions.csv')
#whyapply = df[['Id', 'Why_Applying__c']].loc[df['Why_Applying__c'].notnull()]
#whyapply.set_index('Id').to_csv('whyapply.csv')
#essayfields = [item for sublist in essays.values() for item in sublist]
#print(essayfields)
#df1 = df.drop(columns=ignored+essayfields+contactfields+owners+dates)
#df1.columns
#df2 = df1.join(terms_old.set_index('Id'), on='Entrance_Term__c')
#df2 = df2.join(terms_new.set_index('Id'), on='Term_HEDA__c', lsuffix='_old', rsuffix='_new')
#df2 = df2.loc[df2['Term_new'].notnull()]
#df2['Term_semester'] = df2['Term_new'].apply(lambda x: x.split()[0])
#df2['Term_year'] = df2['Term_new'].apply(lambda x: x.split()[1])
#df2.groupby('Term_new')['Id'].nunique()
#x = df2.loc[df2['Term_new'].str.contains('201[4-8]')]
#x.groupby('Term_new')['Id'].nunique()
#pandas_profiling.ProfileReport(x)
#x.loc[x["EnrollmentrxRx__Admissions_Status__c"] == "Closed (File Closed)"].groupby(['Term_year'])['Id'].nunique()
#z = x[[
#    'Id',
#    'Term_new',
#    'EnrollmentrxRx__Admissions_Status__c',
#    'Region_Override__c'
#]].loc[x[
#    'Region_Override__c'
#].notnull()]
#z.set_index('Id').to_csv('z.csv')
#dfc = x.groupby(['EnrollmentrxRx__Applicant__c', 'EnrollmentrxRx__Admissions_Status__c', 'Term_new'])['Id'].nunique().reset_index()
#dfc[:9]
#dfc.loc[dfc['Id'] > 1]
