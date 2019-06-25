FTP between Cypress and VB Lab box.com account

April 10, 2019
by Steve Formel

## FTPS

https://community.box.com/t5/Managing-Content-Troubleshooting/I-m-Having-Trouble-Using-FTP-with-Box/ta-p/323

Connect

	curl -1 -v --disable-epsv --ftp-skip-pasv-ip -u Boggs443@wave.tulane.edu --ftp-ssl ftp://ftp.box.com

Upload Files

	curl -1 -v --disable-epsv --ftp-skip-pasv-ip -u Boggs443@wave.tulane.edu --ftp-ssl --upload-file filename ftp://ftp.box.com/Stephen_Formel/

Upload folders

https://stackoverflow.com/questions/14019890/uploading-all-of-files-in-my-local-directory-with-curl

	find bbduk_bac_human -type f -exec curl -1 -v --ftp-create-dirs -T {} --disable-epsv --ftp-skip-pasv-ip -u Boggs443@wave.tulane.edu --ftp-ssl ftp://ftp.box.com/Stephen_Formel/{} \;

Works but need to run as script because it's still only doing about 20 Mb a second maybe.

You can also include the password in the command (for a script), but then your password will be visible in bash history:

curl -u username:password http://example.com

### How to hide the password

It is safer to do:

	curl --netrc-file my-password-file http://example.com
...as passing plain user/password string on the command line is a bad idea.

The format of the password file is (as per man curl):

	machine <example.com> login <username> password <password>

Note:

Machine name must not include https:// or similar! Just the hostname.
The words 'machine', 'login', and 'password' are just keywords; the actual information is the stuff after those keywords.

So for me:

	machine ftp.box.com	login Boggs443@wave.tulane.edu	password Microbial*1

### Whole script

	named: box_ftp.sh

	#!/bin/bash
	
	#SBATCH --qos=normal
	#SBATCH --job-name box_ftp
	#SBATCH --error box_ftp.error
	#SBATCH --output box_ftp.output
	#SBATCH --time=23:00:00
	#SBATCH --nodes=1
	#SBATCH --mem=64000
	#SBATCH --cpus-per-task=20
	#SBATCH --mail-type=ALL
	#SBATCH --mail-user=sformel@tulane.edu
	
	FP=/lustre/project/svanbael/steve
	
	cd $FP
	
	find test_box_ftp -type f -exec curl --netrc-file test_box_ftp/ftp_pass -1 -v --ftp-create-dirs -T {} --disable-epsv --ftp-skip-pasv-ip --ftp-ssl ftp://ftp.box.com/Stephen_Formel/{} \;

Seemed to work fine.  I will refine later.

### Upload filtered SF1 seqs to box.com, my personal folder

named: SF1_box_ftp.sh

	#!/bin/bash
	
	#SBATCH --qos=normal
	#SBATCH --job-name box_ftp
	#SBATCH --error box_ftp.error
	#SBATCH --output box_ftp.output
	#SBATCH --time=23:00:00
	#SBATCH --nodes=1
	#SBATCH --mem=64000
	#SBATCH --cpus-per-task=20
	#SBATCH --mail-type=ALL
	#SBATCH --mail-user=sformel@tulane.edu
	
	FP=/lustre/project/svanbael/steve/SF1/Data/C101HW18101466/raw_data/trim_out/paired
	
	cd $FP
	
	find bbduk_bac_human -type f -exec curl --netrc-file test_box_ftp/ftp_pass -1 -v --ftp-create-dirs -T {} --disable-epsv --ftp-skip-pasv-ip --ftp-ssl ftp://ftp.box.com/Stephen_Formel/SF1_filtered_seqs{} \;

Except there were errors and not all the files were uploaded.  Argh.

You can find these errors by:

	grep "Error" ftp.error

Make sure the error has a capital E.

	< 551 /Stephen_Formel/SF1_filtered_seqs/bbduk_bac_human/SF1_10.R1.fq: Error on output file.
	< 551 /Stephen_Formel/SF1_filtered_seqs/bbduk_bac_human/SF1_01.R1.fq: Error on output file.
	< 551 /Stephen_Formel/SF1_filtered_seqs/bbduk_bac_human/SF1_37.R2.fq: Error on output file.
	< 551 /Stephen_Formel/SF1_filtered_seqs/bbduk_bac_human/SF1_04.R2.fq: Error on output file.
	< 551 /Stephen_Formel/SF1_filtered_seqs/bbduk_bac_human/SF1_13.R2.fq: Error on output file.
	< 551 /Stephen_Formel/SF1_filtered_seqs/bbduk_bac_human/SF1_04.R1.fq: Error on output file.
	< 551 /Stephen_Formel/SF1_filtered_seqs/bbduk_bac_human/SF1_13.R1.fq: Error on output file.
	< 551 /Stephen_Formel/SF1_filtered_seqs/bbduk_bac_human/SF1_01.R2.fq: Error on output file.
	< 551 /Stephen_Formel/SF1_filtered_seqs/bbduk_bac_human/SF1_37.R1.fq: Error on output file.
	< 551 /Stephen_Formel/SF1_filtered_seqs/bbduk_bac_human/SF1_10.R2.fq: Error on output file.

So I guess I'll upload these individually.

	box_ftp_error_files.sh

	#!/bin/bash

	#SBATCH --qos=normal
	#SBATCH --job-name  box_ftp_error_files
	#SBATCH --error  box_ftp_error_files.error
	#SBATCH --output  box_ftp_error_files.output
	#SBATCH --time=23:00:00
	#SBATCH --nodes=1
	#SBATCH --mem=64000
	#SBATCH --cpus-per-task=20
	#SBATCH --mail-type=ALL
	#SBATCH --mail-user=sformel@tulane.edu
	
	FILELIST='SF1_10.R1.fq SF1_01.R1.fq SF1_37.R2.fq SF1_04.R2.fq SF1_13.R2.fq SF1_04.R1.fq SF1_13.R1.fq SF1_01.R2.fq SF1_37.R1.fq SF1_10.R2.fq'

	FP=/lustre/project/svanbael/steve/SF1/Data/C101HW18101466/raw_data/trim_out/paired/bbduk_bac_human

	for files in $FILELIST
	do
	
	curl -1 -v --disable-epsv --ftp-skip-pasv-ip -u Boggs443@wave.tulane.edu --netrc-file test_box_ftp/ftp_pass --ftp-ssl --upload-file $FP/$files ftp://ftp.box.com/Stephen_Formel/SF1_filtered_seqs/bbduk_bac_human

	done

Gave the same 551 error, which is some kind of indication that box doesn't like the files.  Perhaps these are too large?  Which is silly.

Just found this on the community.box.com messageboard:

	Without the trailing "/" in "ftp://ftp.box.com/<dir>/", a "551 Box: Not Found" error will be generated.

Indeed.  Well the batch upload worked for 38/48 files, so that can't be it.

Try one at a time:

curl -1 -v --disable-epsv --ftp-skip-pasv-ip -u Boggs443@wave.tulane.edu --ftp-ssl --upload-file SF1_10.R1.fq ftp://ftp.box.com/Stephen_Formel/SF1_filtered_seqs/bbduk_bac_human/

### In which I resign myself to using the box.com API

After much reading it seems like the box API, as difficult as it is to grasp (their "absolute beginners guide" is a lesson in how not to write a how-to), is the only way this might work reliably between a linux system like Cypress and box.com
	
https://blog.box.com/the-absolute-beginners-guide-to-the-box-apis

Just to share for laughs, this is their instructions:

	To get started, go to http://developers.box.net and check everything out. Here you'll find the developer documentation, links to the Developers Blog, the developers Forum and information about the various API calls you can make. There's a wealth of information for you to explore, so feel free to poke around for a bit before moving on. Now that you're acclimated, you probably want to build something badass…but how do you do it? 

This is how I'm going to teach my daughter to drive someday:

	Google how to drive a car on the internet.  Now that you're acclimated, here's the keys..."

Ok, enough whining and on with the show:

1. The first thing you'll need is a Developer’s key from the [Project Setup Page](https://www.box.net/developers/services), so head there to create and name your own application.
	1. Note: apparently for our purposes this app setup is meaningless.  The whole point is for us to get a magic authorization code.
2.  Next, copy the API key we generate for you.
	1.  This is magical.  Don't share it with others, don't put it in your script if you can help it.
3.  It's helpful to walk through the basic API call stack in a browser window, so just click the [Get Ticket API Function](http://developers.box.net/w/page/12923936/ApiFunction_get_ticket) page and scroll down to the REST Request.
4. Copy and paste the https://www.box.net/api/… line into a browser bar, and replace the stuff after the equals sign with the top-secret API key you've written down. 
5. After that, load the page on your browser to get a response that contains your very own authentication ticket. 
	1. Depending on your browser, you may need to view source to see the XML that comes back. This is another thing to keep semi-secret! 
	2. Again, I recommend that you cut and paste the ticket part of the response into your text file; I put mine on a separate line from my app_key. 
6. Now you can move to the next step and use that ticket and app_key to get an auth token. Go through the same basic steps:
	1. Navigate to the API function you want to try (get_auth_token)
	2. Copy and paste the https:// part out of the REST Request example
	3. Edit the request to put your own api_key, ticket, and any additional parameters you want to try
	4. Hit return and fetch the response
	5. Once you have an auth_token, you can call any of the other APIs you want, and the pattern to do it is the same. 
	
I suggest you try the get_account_tree with the params[onelevel] set after you’ve uploaded a few files into your Box account. Also good is get_comments, get_collaborators, as well as get_file_info. 

### This next part is hilarious...

You should now have a pretty good idea of how to write your own programs against the Box APIs.

### Ok, stop whining again and try for real

This page for an R package "boxr" is pretty helpful for holding my hand as I "poke around" the box website and figure out the parts of API authorization

https://cran.r-project.org/web/packages/boxr/vignettes/boxr.html

1.  Logged into https://tulane.app.box.com/developers/console
2.  Click create new app
3.  Click Custom App and then click next (bottom of page)
4.  Choose authentication type
	1.  Oh lord shoot me now.
	2.  https://developer.box.com/docs/authentication-types-and-security
	3.  After [poking around](https://community.box.com/t5/Platform-and-Development-Forum/How-to-Download-Upload-files-via-BOX-API-without-user-physically/td-p/46219), I have almost no reason for choosing "OAuth 2 with JWT" except it seems like you don't need a browser to use it.  Which is helpful for people like me trying to programatically upload and download several hundred gigs of data regularly.
 
#### Time for another laugh break:

I just found this in a tutorial:

	This guide will walk you through creating a new JWT application and configuring it within your enterprise.

	Complete the following steps to create and configure a new JWT application

	1. Create and Configure a JWT Application.

Step 1 of the tutorial is to do the thing you're trying to do.  Amazing.

#### Back to bidness

5. Click OAuth 2.0 with JWT (Server Authentication)
6. Click next (bottom of page)
7. Name your app literally anything you would like, it has no bearing on your future.  Don't forget the app development is just the barrels of oil Donkey Kong (box.com) is throwing at us to make it more difficult to access our data.  Once we get the princess (authorization code) we can go cry ourselves to sleep.

8.  After naming it, you will see this:

	Make your first API call and retrieve a list of folders from your personal Box account using a developer token. This token will expire after 60 minutes.

	curl https://api.box.com/2.0/folders/0 -H \
	"Authorization: Bearer 3OCMFMotlyEHlG79jzyUhRVBfCGuFUa4"

9. Execute the curl command from Cypress, or another linux command prompt.
10. It will give you back a messy list, I think it's the file tree of your box.com account
11. Click view your app
12. Now you're in a whole other shit show.  You can do all these things, but do you need to?  I'm not sure.
13. Oh wait, you notice at the top:

Configuration
Configure the authentication and permissions for your app to begin using the Box APIs. Check out our [Getting Started Guide](https://docs.box.com/docs/getting-started-box-platform) for a walkthrough of these settings.

Oh wait, but all they do is send you through a wormhole of hypothetical situations...none of which are "I just want to upload and download a large amount of information regularly"

14. Eventually I found this:

	https://developer.box.com/reference#api-docs-directory

curl https://api.box.com/2.0/shared_items \
-H "Authorization: Bearer <ACCESS_TOKEN>" \
-H "BoxApi: shared_link=https://nihcc.app.box.com/v/ChestXray-NIHCC"


## Start over

1. Made app
2. Selected Standard OAuth 2.0 (User Authentication)
3. Now it request Redirect URI
	1. According to https://cran.r-project.org/web/packages/boxr/vignettes/boxr.html, I should put in http://localhost

Try to download something

	This will give you info about the folder:

	curl https://api.box.com/2.0/shared_items \
	-H "Authorization: Bearer <ACCESS_TOKEN>" \
	-H "BoxApi: shared_link=https://nihcc.app.box.com/v/ChestXray-NIHCC"

# Bah

It also looks like I might need to ask the Tulane box.com admins (whoever they are) to approve my app to get access to my data.  F this baloney.  

Going to try rclone, which is like rsync for cloud storage

https://rclone.org/box/

### Install Rclone

https://rclone.org/install/

	curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip
	unzip rclone-current-linux-amd64.zip
	cd rclone-*-linux-amd64

####### make module file for Rclone

	nano /lustre/project/svanbael/steve/moduleFiles/Rclone/1.47
	
	#%Module1.0 -*- tcl -*-
	##
	## modulefile
	##
	
	module-whatis    Rclone is a command line program to sync files and directories to and from cloud storage
	prepend-path     PATH /lustre/project/svanbael/steve/software/Rclone/rclone-v1.47.0-linux-amd64/

##### Set up a box.com script

https://rclone.org/box/

Note: do not use advanced config
Note: I had to use my mac laptop to get the authorization code since Cypress doesn't have a web browser

named VBlab_box

ultimately:

paste into cypress terminal from mac laptop:

{"access_token":"YhfFlLOb0w7QstdewNpurIyw9yaGjjvv","token_type":"bearer","refresh_token":"EQFLNArhlbArO0htFx0Zq8q0XxIadSoRuOg8Ey6Rrps5QotxwfuU2VSVvM4eHIcu","expiry":"2019-04-13T22:32:48.849677-05:00"}

### It worked!  Try to sync a folder

Once configured you can then use rclone like this,

List directories in top level of your Box

	rclone lsd VBlab_box:

List all the files in your Box

	rclone ls VBlab_box:

To copy a local directory to an Box directory called backup

	rclone copy /lustre/project/svanbael/steve/test_box_ftp/ VBlab_box:Stephen_Formel/SF1_filtered_seqs/test_box_ftp

Heck yeah!  Seems to work fine.

	box_sync.sh

	#!/bin/bash

	#SBATCH --qos=normal
	#SBATCH --job-name  box_sync
	#SBATCH --error  box_sync.error
	#SBATCH --output  box_sync.output
	#SBATCH --time=23:00:00
	#SBATCH --nodes=1
	#SBATCH --mem=64000
	#SBATCH --cpus-per-task=20
	#SBATCH --mail-type=ALL
	#SBATCH --mail-user=sformel@tulane.edu

	module load Rclone/1.47
	
	SF1=/lustre/project/svanbael/steve/SF1

	rclone copy $SF1/Data/C101HW18101466/raw_data/trim_out/paired/bbduk_bac_human/ VBlab_box:Stephen_Formel/SF1/Data/C101HW18101466/raw_data/trim_out/paired/bbduk_bac_human/

Didn't work because apparently box.com has a file size limit of 5 Gb 

	 ERROR : SF1_01.R1.fq: Failed to copy: multipart upload create session failed: Error "file_size_limit_exceeded" (403): File size exceeds the folder owner's file size limit

Fucking box.  What a piece of shit software for Tulane to invest in for data storage.

Ok, I looked in the account setting on box.com (in a web browser) and found a max file of 15Gb, so that's larger than they publish, so clearly tulane is thinking about our problems a little bit.  I guess I need to gzip my files.

So I need to make a new folder with gzipped versions of the fastq files and rclone those.

	gzip *.fq

That took forever, used gnuparallel to do it instead:

gzip.sh

	#!/bin/bash
	
	#SBATCH --qos=normal
	#SBATCH --job-name  gzip
	#SBATCH --error  gzip.error
	#SBATCH --output  gzip.output
	#SBATCH --time=23:00:00
	#SBATCH --nodes=1
	#SBATCH --mem=64000
	#SBATCH --cpus-per-task=20
	#SBATCH --mail-type=ALL
	#SBATCH --mail-user=sformel@tulane.edu
	
	cd /lustre/project/svanbael/steve/SF1/Data/C101HW18101466/raw_data/trim_out/paired/bbduk_bac_human/
	
	module load gnuparallel/20180322
	
	parallel gzip ::: *.fq

I don't have a good sense of how long this would take because I did it in steps, trying out different version along the way.  But probably a few hours.

Then test to make sure the files aren't corrupt:
https://unix.stackexchange.com/questions/359303/check-validity-of-gz-file

	gzip_test.sh

 	#!/bin/bash
	
	#SBATCH --qos=normal
	#SBATCH --job-name  gzip_test
	#SBATCH --error  gzip_test.error
	#SBATCH --output  gzip_test.output
	#SBATCH --time=23:00:00
	#SBATCH --nodes=1
	#SBATCH --mem=64000
	#SBATCH --cpus-per-task=20
	#SBATCH --mail-type=ALL
	#SBATCH --mail-user=sformel@tulane.edu
	
	cd /lustre/project/svanbael/steve/SF1/Data/C101HW18101466/raw_data/trim_out/paired/bbduk_bac_human/
	
	module load gnuparallel/20180322
	
	parallel gunzip -t -v ::: *.fq.gz

took 33 minutes

Everything looks uncorrupted.  Generate new md5 sums

	parallel md5sum ::: *.fq.gz > fq.gz_md5sum.txt

Holy cow that is much faster using parallel.  On an idev node it only took 5 min.

ran box_sync.sh, hopefully it works!  No file is larger than 6Gb


