#### Using rsync to maintain and update files on Cypress (the Tulane HPC)

Steve got this from Erik Enbody, via Sarah Khalil

Last updated 26, Nov 2018

Installation:  rsync may already be installed on your mac or linux computer.  check by typing "rsync".  If not, start googling to install it.  If you're not familiar with rsync, this is a good place to start:

[https://explainshell.com/explain/1/rsync]()

###### In terminal...

Navigate to the folder you want to sync with the Cypress folder with the cd command.  Or you can set the complete local filepath below with a variable.

###### Set variables in terminal:
`cypress_filepath='/lustre/project/svanbael/steve/SF1/SF1_scripts/'
local_filepath='./'
`
###### if you want to see that they worked:
`echo $cypress_filepath
`

###### to upload to Cypress:
`rsync -avzPhe ssh $local_filepath sformel@cypress1.tulane.edu:$cypress_filepath
`

###### to download from Cypress:
`rsync -avzPhe ssh sformel@cypress1.tulane.edu:$cypress_filepath $local_filepath
`
