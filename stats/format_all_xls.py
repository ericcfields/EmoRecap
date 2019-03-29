# -*- coding: utf-8 -*-
#Python 3.6
"""
Format all FMUT output spreadsheets in the folder
Useful for quickly formatting all spreadsheets from a Linux cluster run analyses

Author: Eric Fields
Version Date: 15 November 2017
"""

import os
import win32com.client

import sys
sys.path.append(r'C:\Users\ecfne\Documents\Eric\Coding\FMUT_development\FMUT')

from fmut import format_xls

def open_save(file):
    """
    Open input xls file with Excel and resave
    This fixes formatting issues
    """
    #Fix formatting issues by opening and resaving with Excel
    xlApp = win32com.client.Dispatch('Excel.Application')
    workbook = xlApp.Workbooks.Open(file)
    workbook.Save()
    workbook.Close(SaveChanges=False)
    xlApp.Quit()
    
def main(directory=None):
    """
    For files in directory:
        1. Open and resave with Excel
        2. Apply fmut.py spreadsheet formatting
    """
    
    #Default to current working directory
    if directory is None:
        directory = os.getcwd()
    
    #Make sure directory ends with a slash for concatenating with files below
    if not directory.endswith(os.sep):
        directory += os.sep
    
    #Get all spreadsheet files in directory
    xls_files = [directory+file for file in os.listdir(directory) if file.endswith('.xlsx')]
    
    #Apply formatting to each file
    for file in xls_files:    
        open_save(file)    
        format_xls(file)
    
if __name__ == '__main__':
    main(r'Z:\Bowen, Holly\EmoRecap_ERP\EEGLAB_Analysis\DATA\stats\results')
