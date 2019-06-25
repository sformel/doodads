##Protocol for assigning taxonomy to cultures

###Van Bael Lab

by Steve Formel

April 19, 2018

___

###Notes

1. This is a more reproducible method than what we were doing previously.  But hopefully someone comes up with something better than this in the future.

2. Probably the easiest thing to go wrong with this protocol is using incorrect filepaths.  Make sure you have replaced my Cypress folder name, steve, with your folder in the filepaths.

3. Up to this point you should have:

		a. Cultured bacteria or fungi
		b. Extracted DNA
		c. Sanger sequenced the sample
		d. Used a program like Mesquite to re-call the bases as PHRED bases
		f. Used a program like Sequencher to edit the sequences.
				i. Edited the forward and reverse read into one 
		   consensus FASTA sequence
				ii. although you could do the following with just the forward or reverse read
		
###Make multifasta sequence

1. Upload all of your sequences to one folder in Cypress via Filezilla.

	a. If you don't have a Cypress account, Sunshine can help you get one.   [Link to Cypress Instructions](https://wiki.hpc.tulane.edu/trac/wiki/cypress/about)
	
2. Log in to Cypress using terminal on a mac or putty on a Windows machine.
3. Navigate to your folder with the sequences.

	a. If you're not certain how to do this, google "cd unix".
	
4. Concatenate all your sequences into one multi-fasta file

		cat *.fasta > all_my_seqs.fasta

###Clustering: Optional

People in our lab have done analysis that was clustered, assigned taxonomy to representatives from the clusters and then statistically analyzed.  Other projects in our lab have assigned taxonomy to every isolate from their project and then statistically analyzed the results using taxonomy as "clusters".  I think you can argue for both, but I prefer to cluster first.
 
####De-novo clustering in QIIME

If you have many isolates, you may want to cluster them at 97% in QIIME 1 or Sequencher.  Here are directions in QIIME 1.  Directions for Sequencher are elsewhere on the Van Bael Google Drive.  I used QIIME because it is a well-cited method (meant for 454, Illumina, and Sanger sequencing) and easily outputs your results.  If you choose to use Sequencher you need to jump through some hoops to get your clusters into a usable format.
		
This is a SLURM script to run on Cypress.  In the Cypress terminal, type:

	nano pick_denovo_otus.sh

And paste this into the editor:

	#!/bin/bash
	
	#SBATCH --job-name=denovo_otus
	#SBATCH --output=denovo_otus.output
	#SBATCH --error=dneovo_otus.error
	#SBATCH --qos=normal
	#SBATCH --time=0-24:00:00
	#SBATCH --nodes=1
	#SBATCH --mem=64000
	#SBATCH --mail-type=ALL
		
	module load qiime/1.9.1
	
	pick_de_novo_otus.py -i /lustre/project/svanbael/steve/all_my_seqs.fasta -o /lustre/project/svanbael/steve/denovo_otus -a -O 20

To exit:
	
	Press the control and x keys	

It will ask you if you want to save it.  
	
	Hit y and then enter.  
			
You should be back in the regular terminal.  To run the job type:

	sbatch pick_denovo_otus.sh

To make sure your job is running type:
	
	squeue -u yourusername
		
You should see something like:
	
	JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
    708647      defq make_ncb  sformel  R       0:06      1 cypress01-059
            
If you don't see anything, it didn't work for some reason.  The job will probably take 30-60 min.  To check that the job has finished type the above code again.  If the job has finished you should see:

	JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)

### Make local ncbi nucleotide database.

This is a slurm script.  You will run it through Cypress.
	
In the Cypress terminal type:
		
	nano make_ncbi_db.sh
			
Copy this code and paste it into the terminal.
	
	#!/bin/bash
	
	#SBATCH --job-name=make_NCBI_db
	#SBATCH --output=make_NCBI_db.output
	#SBATCH --error=make_NCBI_db.error
	#SBATCH --qos=normal
	#SBATCH --time=0-24:00:00
	#SBATCH --nodes=1
	#SBATCH --mem=64000
	#SBATCH --mail-type=ALL
		
	##make directory and download and unzip files
		
	##taken from: https://github.com/Joseph7e/Assign-Taxonomy-with-BLAST & https://www.linuxquestions.org/questions/linux-newbie-8/how-to-untar-all-tar-files-in-a-directory-98963/
	
	mkdir ncbi_nt_database
	cd ncbi_nt_database
		
	wget 'ftp://ftp.ncbi.nlm.nih.gov/blast/db/nt*.gz'
		
	## Download NCBI's taxonomic data and GI (GenBank ID) taxonomic
	## assignation.
		
	wget 'ftp://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz'
		
	for i in *.tar.gz; do echo working on $i; tar xvzf $i ; done
		
	exit 0
	
To exit:
	
	Press the control and x keys	

It will ask you if you want to save it.  
	
	Hit y and then enter.  
			
You should be back in the regular terminal. 

To run the job type:

	sbatch make_ncbi_db.sh

			
###Run BLAST

Make another script to BLAST your sequences.

Make sure that the filepaths in the script match where your ncbi database has been built.  These filepaths must be explicit (i.e. contain the entire path, not a relative path)  *It is also important that your multifasta file is in the same folder as the ncbi database!* You can use Filezilla to move/copy files, or use the Unix command "cp".  



	#!/bin/bash

	#SBATCH --job-name=my_BLAST
	#SBATCH --output=my_BLAST.output
	#SBATCH --error=my_BLAST.error
	#SBATCH --qos=normal
	#SBATCH --time=0-24:00:00
	#SBATCH --nodes=1
	#SBATCH --mem=64000
	#SBATCH --mail-type=ALL
	
	##Local blast on Cypress for culture based sequences
	
	module load ncbi-blast/2.5.0+
	
	blastn -db /lustre/project/svanbael/steve/ncbi_nt_database/nt -query /lustre/project/svanbael/steve/ncbi_nt_database/all_my_seqs.fasta  -num_threads 10 -out /lustre/project/svanbael/steve/my_blast_results.txt

###Run BLAST with output from QIIME denovo OTU picking

If you picked your OTUs in QIIME with the above script, you need to copy the representative sequences of the OTUs to the folder with the ncbi database in it.

	cp /lustre/project/svanbael/steve/denovo_otus/rep_set/all_my_seqs_rep_set.fasta /lustre/project/svanbael/steve/ncbi_nt_database/

Once this is done, use the same script as above to do the BLAST, making sure that filepaths are correct.

###Filter BLAST results in MEGAN

Use Filezilla to transfer your blast results (in the exmaple above, nameed my\_blast\_results.txt) to your computer.  

I have installed MEGAN 6 community edition on one of our computers, but you can also install it on your own computer pretty easily.

[Download MEGAN](https://ab.inf.uni-tuebingen.de/software/megan6/download "Download MEGAN")

*Note that different version of MEGAN use different LCA algorithms!*

####Import BLAST Results 

1. In MEGAN click on File > Import from BLAST
2. Click the folder icon on the right side of the top box.  Find the BLAST results file.
3. It should autodetect that this is a BLASTText file (Format pull down menu) and BlastN format (Mode pulldown menu)
4. If you'd like you can adjust the LCA algorithm (see below) 
5. Click "Apply" in the bottom right corner.
6. It will taker a while to process the info.


####Fine-tuning taxonomy results

The MEGAN results are based of Lowest Common Ancestry (LCA) of some subgroup of the BLAST results.  You refine these by clicking on:

Options > LCA parameters

For the purposes of the algorithm Sanger sequencing is considered a short read, and the weightedLCA algorithm is the one the makers of MEGAN recommend at the time this was written.  The easiest solution is probably to use the default parameters (in terms of writing up your methods) but feel free to do some more reading to fine-tune your results.


######Here are some parameters I have used, based off a messageboard conversation [here](http://megan.informatik.uni-tuebingen.de/t/help-with-the-lca-parameters/88/16).

	weighted LCA algorithm	

	minSupportPercent=0.3
	minSupport=1 
	minScore=170.0 
	maxExpected=0.1 
	minPercentIdentity=0.0 
	topPercent=3.0 
	weightedLCA=true 
	weightedLCAPercent=50.0 
	minComplexity=-1.0 
	pairedReads=false
	useIdentityFilter=true;

####Export Results to Taxonomy Table

1. At the top of MEGAN, click the "Rank..." button and select species.
2. Press "Control" and "a" to select all the nodes on the tree.
2. Click File > Export > Text (CSV) Format
3. Change the top pulldown menu to "readName\_to\_taxonPath"
4. Make sure the middle pulldown menu is "assigned"
5. Click OK and select where you want the file to be saved.
6. Open this file in excel.  If you're not sure how to separate the taxonomy into individual columns, google "Excel text to columns".


####What do ya got?

You should now have a taxonomy table that can be brought into R packages like phyloseq or vegan for analysis.  Or you can use bring it back into QIIME to apply to your sequences by using the "make_otu_table.py" function. 

You're table should be in this format:

	denovo10        k__Bacteria; p__Proteobacteria; c__Gammaproteobacteria; o__Alteromonadales; f__Shewanellaceae; g__Shewanella; s__algae 

where each line is an otu and there is a tab separating the OTU name and the first rank.  Ranks should have a semicolon at the end and a space between them.  I'm not sure if it matters if they have the rank prefix (e.g. k__) before the name.  I also believe all assignments needs to have the same number of ranks, but I haven't tested this.

####Maintaining Records

Make sure you note what day you downloaded the ncbi database for your records.  It changes on a daily basis.

Make sure you keep your MEGAN project as part of your data.  It's the only way to see the Accession numbers of the BLAST hits that contribute to the taxonomic assignment of your sequence.  As far as I can tell, there is no easy way to export these numbers.  Furthermore, the number of hits that contributes to each taxonomic assignment varies (read about the LCA algorithm if you don't understand why) so it would be difficult to easily format the results into a table.

####Last thoughts

The NCBI taxonomy is problematic, and different taxa and entries include different classifications, some of which are unranked.  Ultimately you will decide what taxonomy to include with your sequence when you upload it to genbank upon publication.  For simplicity in your analysis, you probably want to pare down your taxonomy to a traditional KPCOFGS taxonomy in excel.

 


	
		
	
		