## Get list of Folders in Google Drive

#### This is a script to be run in google drive.

[How to run a gscript](https://www.youtube.com/watch?v=_bHih4qKk5Y)

Last tested in 2017.  The only thing you have to change is the name of the folder you're interested in getting.  Here it is written as:

	folder_I_want_list_of_contents

Just put the name of the folder you want in its place, keeping the quotes.  Then run the code below.  If you're not sure how to run it, watch [this video](https://www.youtube.com/watch?v=_bHih4qKk5Y).

	// replace your-folder below with the folder for which you want a listing
	function listFolderContents() {
	  var foldername = 'folder_I_want_list_of_contents';
	  var folderlisting = 'listing of folder ' + foldername;
	  
	  var folders = DriveApp.getFoldersByName(foldername)
	  var folder = folders.next();
	  var contents = folder.getFolders();
	  
	  var ss = SpreadsheetApp.create(folderlisting);
	  var sheet = ss.getActiveSheet();
	  sheet.appendRow( ['name', 'link'] );
	  
	  var file;
	  var name;
	  var link;
	  var row;
	  while(contents.hasNext()) {
	    file = contents.next();
	    name = file.getName();
	    link = file.getUrl();
	    sheet.appendRow( [name, link] );     
	  }  
	};