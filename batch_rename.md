####To batch rename files:
Last updated: 26 Nov 2018

In general if you know how to use regular expressions (regex), this will be easier to do.  But it's not totally necessary, here are some options: 

1. On a mac, select all the files, right click and choose rename.  It has a find and replace function.  This is probably the easiest way.
2. On terminal on a mac or linux system, use the rename function:
	[http://stackoverflow.com/questions/1086502/rename-multiple-files-in-unix](http://stackoverflow.com/questions/1086502/rename-multiple-files-in-unix "http://stackoverflow.com/questions/1086502/rename-multiple-files-in-unix")
	
```
rename 's/^string_you_want_to_replace/replacement_string/' *myfiles.whatever
```
but there are different versions of the rename function.  It might work like this instead:

```
rename string_you_want_to_replace replacement_string *myfiles.whatever
```



1. Another option is the Bulk Rename Utility software, which is point and click, but still works best if you have knowledge of regular expressions. 
[https://www.bulkrenameutility.co.uk/Download.php](https://www.bulkrenameutility.co.uk/Download.php "https://www.bulkrenameutility.co.uk/Download.php")