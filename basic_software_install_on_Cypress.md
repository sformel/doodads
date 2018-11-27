### How to locally install a program on Cypress (Tulane HPC)
Last updated: 26 Nov 2018

Note: This is an example using the program "mothur".  This might not work for all programs, but should work for many.  In essence you are downloading the software to your directory on Cypress and adding a line to your bash profile (these are directions that Cypress reads when you first log in.  It is how you customize your "space" on the HPC) so that you can call the program and it's functions without having to type out the full path.

#### Installation Instructions [https://www.mothur.org/wiki/Installation](https://www.mothur.org/wiki/Installation "https://www.mothur.org/wiki/Installation")
1. Make a folder for the software in the location you want.  I like to keep all my software in one place so it's easy to find and remove if I don't need it.

	```
	mkdir mothur
	```
2. Enter that folder
	
	```
	cd mothur
	```
3. get the newest version from this page [https://www.mothur.org/wiki/Download_mothur](https://www.mothur.org/wiki/Download_mothur "https://www.mothur.org/wiki/Download_mothur")

	```
	wget https://github.com/mothur/mothur/releases/download/v.1.41.1/Mothur.linux_64.zip
	```

4. unzip the file

	```
	unzip ./Mothur.linux_64.zip
	```
5. Open your bash profile in the nano editor to add the Mothur filepath to your bash profile.

	```
	nano ~/.bash_profile
	```
6. Use the arrow keys to add the following code below anything else that is in your profile, replacing the filepath with correct filepath to your Mothur folder.

	```
	export PATH=$PATH:/lustre/project/steve/software/Mothur
	```
7. Hit the control + c buttons to exit from the nano editor, and say yes to saving the file.

8.  You can either restart the session to activate the installation, or type:

	```
	source ~/.bash_profile
	```    
