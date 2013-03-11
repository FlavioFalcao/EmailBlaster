EmailBlaster
============

A Visual foxpro Email Blaster for Accountmate. Allows you to send in batch the output of Accountmate's crystal reports as pdf files attached to emails. It automatically retrieves the customer's email or fax information from Accountmate's SQL records.

Let's say you want to send a customer his monthly invoice. Before, you had to go into the report's menu, open the "Print Invoice" report, setup the filters, preview the report and from the Crystal Report's preview, choose "Save as PDF", then choose the file, attach it to an email and send it. No problem for a single file, but imagine doing it for 200, 600, 2000 invoices!!

With this application everything is being taken care of with just a few clicks. 

It provides a very detailed Send Log that allows to trace exactly what happened to each job.

All grids are sortable and filterable.

Provides Email and Fax send templates. 

Template Send Grid feature that allows choosing which template to send, according to which report the job comes from.


<strong>Summary</strong>

This add-on allows Accountmate to send email blasts. Simply open the report you wish to send, check the Email Blast checkbox and click Preview. The range of records will be sent to the blaster's outbox.
Then, open the form, review the send-list and click send. Each report will be sent to the corresponsing customer's email or fax (provided it is properly configured).

<strong>Installation</strong>

1 - Run the "Accountmate Email blaster new tables and triggers.sql" script in the "Sql Scripts" folder, against Accountmate's SQL instance . Run it against each company where the application will be used.

2 - Add the application's table views to the system\sample dbc files. To do this, from within Foxpro, open .prg and run it. When prompted for the .dbc file, choose system\sample.dbc. Do it for the following files:
   -scbllist.prg
   -scbllog.prg
   -scblsys.prg
   -scbltmpgrd.prg
   -scbletemp.prg
   -scblftemp.prg
   -scbljbTpe.prg

3- Append records to search tables. To do this, append the records in "\dbf add-ins" folder to amordrby.dbf and amschgrd.dbf respectively.

4- Copy the contents of \forms folder to amsql\forms

5- Copy the contents of \reports folder to amsql\rptmod

6- Add the functions contained in "class  report prg add-ins\classAddIn.prg" to one of the module's class files, like arclass.prg. Then re-compile the later. 

   NOTE!!!!!: This will only work with crystal reports (all reports in the amsql\crystal folder) not the Foxpro Reports.

7- For each report that you want Email Blaster functionality enabled, add a checkbox object (name it anyway you want, like "Blast") and reference it to a variable called llblast. (This is done in amrftr.dbf file)

8- Modify the code of the report's prg (the one you just did in 7) and append at the end the code in "class  report prg add-ins\crreportprgcodeaddin.prg".   For instance, if you modified the "Print Invoice" report, that would be the arinvccr.prg file in amsql\crystal\ar. Re-compile the file. 

9- Add the application's form to Accountmate's menu. That is, append a record to ammenu, placing it in the module and sub-menu of your choice and point it towards scublast.scx

10- Add a column to the SQL customers table arcust and call it cPdfType. Add this to the dbc view. Finally, add a drop-down to the customer maintenance form armcust.scx mapped to that file and include the following pdf options:

 //TO DO Include options


11- You are done!!!


<Strong>Usage</Strong>

First you need to configure the application. Open the Email Blaster form. Choose the "Configuration" tab. Setup smtp. Setup the sender config.  Click "Save"

Suppose you configured the Invoice report following the installation instructions. As a test, choose the customer file for the invoice you want to send. Set the pdf flag (in this case Email only) and fill-in the email field.
Now, open the invoice report form and choose the invoice for that customer. Check the "Blast" checkbox you added in step 7 above. Click "Preview". This will send the job to the Application's outbox.
Open the app's form, the job should appear there. Select the job and click "Send selected". 
After the job is sent, you will see records added to the log grid.
Do the same for a range of customers or a range of dates or whichever set of parameters that will generate the records to send.








