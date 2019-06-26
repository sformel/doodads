## How to classify microbial cultures 

### Using BLAST and QIIME2

by Steve Formel

Last updated: June 25, 2019

***

**Description:**  When our lab works with cultures, we Sanger sequence the 16S gene for bacteria and ITS DNA for fungi.  This protocol uses the sklearn classifier used by QIIME2, BLAST, and the well curated databases, SILVA (bacteria) and UNITE (fungi) to assign taxonomy to our sequences.  It was used for classification of some sequences in the BC1 project.

Up to this point you should have:

>	a. Cultured bacteria or fungi

>	b. Extracted DNA and done PCR

>	c. Sanger sequenced the sample

>	d. Used a program like Mesquite to re-call the bases as PHRED bases

>	f. Used a program like Sequencher to edit the forward and reverse reads into one consensus FASTA sequence

*Note: You could do the following with just the forward or reverse read, it just would inspire less confidence in the results.*
				
***

# Table of contents
1. [Introduction](#Intro)
2. [Step 1: Clean Data](#Step1)
3. [Step 2: Import seqs into QIIME2](#Step2)
4. [Step 3: Set up reference databases](#Step3)
4. [Step 4: Classify Taxonomy](#Step4)
4. [Step 5: BLAST against same databases](#Step5)
4. [Step 6: Renaming Output](#Step6)
4. [Step 7: Import QIIME2 results into R and clean](#Step7)
4. [Step 8: Import BLAST results into R and clean](#Step8)
4. [Step 9: Put QIIME2 and BLAST results together as csv file](#Step9)

<a name="Intro"></a>

#### Introduction 

##### What you should have already done:

1. cleaned and edited your sequences
2. they should be in a multifasta format
3. upload multifasta file to Cypress (Tulane HPC)
	
	> If you're not sure how to work on Cypress, your PI can get you an account.  Start learning about it [here](https://wiki.hpc.tulane.edu/trac/wiki/cypress/about).
	
3. All sequences must be in the same orientation...but keep reading.
	
	> BLAST automatically looks at forward and reverse complements of the sequences, but for QIIME2, all sequences need to be in the same orientation.
	
	> QIIME2 will autodetect the direction based on the first few hundred sequences.
	
	> If you're not sure if all your sequences are in the same direction, you can make one file from your sequences and the reverse complement of your sequences.  It should be obvious in the taxonomy output which version was found in the database.

##### So, if needed, make a reverse complement of your multifasta on Cypress (the Tulane HPC):

	module load qiime2/2018.2
	vsearch  --fastx_revcomp your_input_sequences.fasta --fastaout  revcomp_of_your_input_sequences.fasta

Add character to fastaID so we now which ones are reversed (and also QIIME2 needs unique IDs)

	sed -i '/^>/ s/$/_RC/' revcomp_of_your_input_sequences.fasta

Put the normal and reverse complement sequences together into one file:

	cat your_input_sequences.fasta revcomp_of_your_input_sequences.fasta > both_sets_of_sequences.fasta

If you do this, the output file ("both\_sets\_of\_sequences.fasta") becomes the input for the next step.

<a name="Step1"></a>
#### Step 1: Clean data 
1.  make sure files are unix formatted:

		sed -i -e 's/\r\+$//'  your_input_sequences.fasta

2. All sequences must be linearized
	
	> Sequencher will format the sequences as wrapped fastas and the classifier has trouble reading that format.
	 

		awk '!/^>/ { printf "%s", $0; n = "\n" } /^>/ { print n $0; n = "" } END { printf "%s", n }' your_input_sequences.fasta > your_output_sequences.fasta

3. Remove ^M character that is created during this process:

		sed -i 's/^M//g' your_output_sequences.fasta

 *Note: When typing the above command, the Control-M should be entered like: Control-V+Control-M, and not as Shift-6-M.*
 
4. Check that it worked:  This command prints a distribution of the sequence lengths.  Make sure it makes sense (i.e. no very long or very short sequences)
	

		awk '{if(NR%2==0) print length($1)}' your_output_sequences.fasta | sort | uniq -c

	This should print a number that is twice as many cultures as you have:
 
		wc -l your_output_sequences.fasta

	This should print the number of cultures that you have:

		grep -c ">" your_output_sequences.fasta

	*Note that if you made reverse complement copies of your seqs, you effectively have twice as many "cultures" to start with, so these numbers should be double what you actually have.*

5. Append a "count" to the end of the fasta ID, so QIIME thinks these fasta sequences have been dereplicated *a la* VSEARCH

		sed -i '/^>/ s/$/;size=1/' your_output_sequences.fasta

<a name="Step2"></a>
#### Step 2: Import seqs into QIIME2 
	module load qiime2/2018.2
	qiime tools import --input-path /path/to/your_output_sequences.fasta --output-path /path/to/your_output.qza --type 'FeatureData[Sequence]'
		
<a name="Step3"></a>		
#### Step 3: Set up reference databases 

##### Important Notes: 

> * Default of confidence parameter (--p-confidence) in classification is 0.7, which works well for 16S data.  For ITS, change it to 0.9, as recommended by Qiime2 developers to provide a balance between recall/precision:
	
> * Bokulich, Nicholas A. et al. “Optimizing Taxonomic Classification of Marker-Gene Amplicon Sequences with QIIME 2’s q2-Feature-Classifier Plugin.” Microbiome 6 (2018): 90. PMC. Web. 12 Oct. 2018.
S and 0.9 for ITS)

> * You also need to specify read orientation (--p-orientation). If all seqs are forward with respect to the reference database (i.e. SILVA or UNITE) then use the option "same".  If they are in the reverse complement relative to the reference database, then use the option "reverse-complement".

> * A few hundred Sanger sequences shouldn't take more than about 30 minutes on a 64 Gb node.

***

1. Download pre-trained classifiers

	> SILVA132 classifier 
	
	> [https://forum.qiime2.org/t/silva-132-classifiers/3698](https://forum.qiime2.org/t/silva-132-classifiers/3698 "https://forum.qiime2.org/t/silva-132-classifiers/3698")

	> *Note: according to above link, classifiers were trained with scikit-learn 0.19.1 by Greg Caporaso, one of the Qiime2 developers.*
	
		wget https://www.dropbox.com/s/5tckx2vhrmf3flp/silva-132-99-nb-classifier.qza
		
	
	> UNITE classifier

	> [https://forum.qiime2.org/t/unite-ver-7-2-2017-12-01-classifiers-for-qiime2-ver-2017-12-available-here/3020](https://forum.qiime2.org/t/unite-ver-7-2-2017-12-01-classifiers-for-qiime2-ver-2017-12-available-here/3020 "https://forum.qiime2.org/t/unite-ver-7-2-2017-12-01-classifiers-for-qiime2-ver-2017-12-available-here/3020")

		wget https://s3-us-west-2.amazonaws.com/qiime2-data/community-contributions-data-resources/2017.12-unite-classifiers/unite-ver7-dynamic-classifier-01.12.2017.qza		
	> *Note: use dynamic classifier as recommended by Qiime2*
	
	> Classified by Sydney Morgan.  Some pertinent information:

	> 1. There are two classifiers available. One uses a 99% threshold for clustering and the other is ‘dynamic,’ meaning it uses either a 97% or 99% threshold (or somewhere in between) based on which is more accurate for certain lineages of fungi (as determined manually by experts in the field).

	> 2. The version of UNITE I used is the most current (version 7.2, release date 2017-12-01). I retrieved it from the following site: https://doi.org/10.15156/BIO/587481 26

	> 3. I used the most current version of QIIME2 to create the classifiers (2017.12), and I followed a protocol posted previously on GitHub, just updating the source files: https://github.com/gregcaporaso/2017.06.23-q2-fungal-tutorial 46

	> 4. The classifiers were created without a “feature-classifier extract-reads” command so they should work well for any primer sets. According to @Nicholas_Bokulich, with fungal ITS data we see a performance decrease when the feature classifier is trained on extracted sequence reads. See this post for more info: https://forum.qiime2.org/t/memoryerror-when-training-unite-ver7-01-12-2017-classifier/2757/2

<a name="Step4"></a>

#### Step 4: Classify Taxonomy 	
example script for SILVA: 

	#!/bin/bash
	
	#SBATCH --job-name=your_job
	#SBATCH --output=your_job.output
	#SBATCH --error=your_job.error
	#SBATCH --qos=normal
	#SBATCH --time=0-24:00:00
	#SBATCH --nodes=1
	#SBATCH --mem=64000
	#SBATCH --mail-type=ALL
	#SBATCH --mail-user=you@tulane.edu
	
	module load qiime2/2018.11
	
	qiime feature-classifier classify-sklearn \
	--i-classifier /path/to/silva-132-99-nb-classifier.qza  \
	--i-reads /path/to/your_input.qza \
	--o-classification /path/to/your_output.qza
	--p-read-orientation same
	--p-confidence 0.7

example script for SILVA: 

	#!/bin/bash
	
	#SBATCH --job-name=your_job
	#SBATCH --output=your_job.output
	#SBATCH --error=your_job.error
	#SBATCH --qos=normal
	#SBATCH --time=0-24:00:00
	#SBATCH --nodes=1
	#SBATCH --mem=64000
	#SBATCH --mail-type=ALL
	#SBATCH --mail-user=you@tulane.edu
	
	module load qiime2/2018.11
	
	qiime feature-classifier classify-sklearn \
	--i-classifier /path/to/unite-ver7-dynamic-classifier-01.12.2017.qza  \
	--i-reads /path/to/your_input.qza \
	--o-classification /path/to/your_output.qza
	--p-read-orientation same
	--p-confidence 0.9		

<a name="Step5"></a>
#### Step 5: BLAST against same databases 
1. Download UNITE reference database

	> UNITE databases are [here](https://unite.ut.ee/repository.php).  The pre-trained classifier used for QIIME2 is not the newest release, but we need to stay consistent.  So below is the ilnk to the same version.

	> download
	
		wget https://files.plutof.ut.ee/doi/B2/07/B2079372C79891519EF815160D4467BBF4AF1288A23E135E666BABF2C5779767.zip

	> unzip
	
		unzip B2079372C79891519EF815160D4467BBF4AF1288A23E135E666BABF2C5779767.zip
		
	> BLAST doesn't like the asterisk in one of the taxa names, remove it:

		perl -i.bak -pe 's/[^[:ascii:]]//g' sh_general_release_dynamic_01.12.2017.fasta

		> Make a blast database
	
		makeblastdb -in sh_general_release_dynamic_01.12.2017.fasta -out UNITE -dbtype nucl
		
2. Download SILVA reference database


	> [explanation of SILVA database](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3531112/) files/types
		
	> You may want to use other SILVA databases, but this is the one that corresponds to the classifier used above in QIIME2.
	
	> download
	
		wget https://ftp.arb-silva.de/release_132/Exports/SILVA_132_SSUParc_tax_silva.fasta.gz

	> unzip
	
		gunzip SILVA_132_SSUParc_tax_silva.fasta.gz

	> get rid of spaces in identifier names.  You could write over the file, but it seems like a good idea to rename it so you'll always have the original at hand, rather than downloading it again.
	
		sed 's/\s/_/g' SILVA_132_SSUParc_tax_silva.fasta > SILVA_cleaned.fasta
	
	> make blast database
	
		makeblastdb -in SILVA_cleaned.fasta -out SILVA -dbtype nucl

3. Example scripts of running BLAST

	> example of blast script for UNITE
	
	> Input is your cleaned and linearized fasta from Step 1.
	
	> If you are interested in what some of the below parameters do, google "blastn options" or in the command line type "blastn --help"
	
		#!/bin/bash
	
		#SBATCH --job-name=UNITE_BLAST
		#SBATCH --output=UNITE_BLAST.output
		#SBATCH --error=UNITE_BLAST.error
		#SBATCH --qos=normal
		#SBATCH --time=0-24:00:00
		#SBATCH --nodes=1
		#SBATCH --mem=64000
		#SBATCH --mail-type=ALL
		#SBATCH --mail-user=yourname@tulane.edu
		
		module load ncbi-blast/2.5.0+
		
		blastn -query /path/to/your_output_sequences.fasta \
		-db UNITE \
		-outfmt 6 \
		-max_target_seqs 10 \
		-num_threads 20 \
		-out your_UNITE_BLAST_output.tsv

	> What the script looks like if you're BLASTing against SILVA.

				#!/bin/bash
	
		#SBATCH --job-name=SILVA_BLAST
		#SBATCH --output=SILVA_BLAST.output
		#SBATCH --error=SILVA_BLAST.error
		#SBATCH --qos=normal
		#SBATCH --time=0-24:00:00
		#SBATCH --nodes=1
		#SBATCH --mem=64000
		#SBATCH --mail-type=ALL
		#SBATCH --mail-user=yourname@tulane.edu
		
		module load ncbi-blast/2.5.0+
		
		blastn -query /path/to/your_output_sequences.fasta \
		-db SILVA \
		-outfmt 6 \
		-max_target_seqs 10 \
		-num_threads 20 \
		-out your_SILVA_BLAST_output.tsv

	
<a name="Step6"></a>

#### Step 6: Renaming Output 

> The output of the qiime2 process is a qza file.  It can be unzipped using the unzip command. The unzipped folder will be named by some hash code.  Inside it will be another folder called data.   Inside data there is a file called "taxonomy.tsv" that can be opened in excel.  After unzipping all the outputs, I renamed the folders and the taxonomy files to reflect the reference database and confidence parameter setting.

>  You can than use Filezilla to put the files on the google drive/ your computer to work in R for the following steps. 

<a name="Step7"></a>
#### Step 7: Import QIIME2 results into R and clean 

##### The following is all run in R.

	library(tidyverse)

Read in QIIME2 data as list of data frames

> use regular expressions in the "pattern" argument to get all of the QIIME2 output files, but not the BLAST output files
	
	files.Q2 <- list.files(path = "./", pattern = "Q2.*tsv", full.names = FALSE)
	tbl.Q2 <- lapply(files.Q2, read.delim, header = TRUE)
	
*Note that you can call each data.frame by indexing the list: tbl.Q2[[1]] = the first data.frame in the list.  You don't have to work with the data frames in a list, but it allows use to drastically simplify your code by using the lapply function to apply a function to every data frame in the list with the same line of code.*

###### Start shaping and cleaning

> break Taxon coumn into the 7 levels of classification

> It's a requirement of QIIME2 that reference databases be classified in a 7 rank scheme.  So if you don't have that in your results, something isn't quite right.	
	
	tbl.Q2 <- lapply(tbl.Q2, 
                     function(x) {
                       x %>%
                         separate(Taxon, paste0("Level", 1:7), ";", fill = "right")}
)


> add the confidence parameter setting.  You may want to play with this setting when you classify the sequences. If you relax it you'll probably more specific classification, although it won't be as reliable. For example, adjusting it from 0.9 to 0.7 for fungi.

	tbl.Q2[[1]]$Conf_setting <- rep(0.5, nrow(tbl.Q2[[1]]))  #classified at confidence = 0.5
	tbl.Q2[[2]]$Conf_setting <- rep(0.7, nrow(tbl.Q2[[2]]))  #classified at confidence = 0.7

> Add the name of the reference database
 	
	tbl.Q2[[1]]$ref_db <- rep("SILVA_132_SSUParc", nrow(tbl.Q2[[1]]))
	tbl.Q2[[2]]$ref_db <- rep("SILVA_132_SSUParc", nrow(tbl.Q2[[2]]))

> name the columns
 
	tbl.Q2 <- lapply(tbl.Q2, setNames, c("Isolate", "Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species", "Confidence", "Conf_setting", "ref_db"))   


> Get rid of level annotation in taxa prefixes

> Some reference databases and classifiers will add a prefix to a taxanomic rank, to make it easy to identify.  For example: D__0\_Bacteria
> To get rid of it, use the substring function.  The last number (6 in this example) is the position of the first character you want to keep.

	tbl.Q2[[1]][,2:8] <- sapply(tbl.Q2[[1]][,2:8], substring, 6)
	tbl.Q2[[2]][,2:8] <- sapply(tbl.Q2[[2]][,2:8], substring, 6)

> put the two data frames into one big data frame before further cleaning-----

	Q2 <- bind_rows(tbl.Q2)

###### Now that we have put our two data frames together we can continue cleaning them as one

> remove Unassigned and unlikely taxonomy

>  For SILVA, sequences that don't classify will be "Unassigned" in the first rank.  For UNITE, they will probably just be assigned to Fungi, with no further classification.  This is how you filter out the forward/reverse complement sequences that didn't match up to the others.  See step 1 if you can't remember what I mean. 

	Q2 <- subset(Q2, !(Kingdom %in% c("Unassigned") | is.na(Phylum)))

> get rid of "size" notation in Isolate number

	Q2$Isolate <- gsub(";.*","", Q2$Isolate, fixed = FALSE)

> Add Other Info

	Q2$Method <- rep("QIIME2_sklearn", nrow(Q2))
	Q2$input_file <- rep("my_input_seqs.fasta", nrow(Q2))

<a name="Step8"></a>
#### Step 8: Import BLAST results into R and clean 

*Notes*
 
* We told the BLAST to output in format 6, but this doesn't include headers.  So we have to add those.  If you use another output format, make sure you adjust the names.
* The SILVA SSU database comes up with hits for some of the fungal isolates, which are ITS sequences.  It's not a bad idea to examine those results, but they probably aren't as useful as the UNITE results since UNITE is ITS specific.
* However, it's important to be aware that SILVA uses a 12 rank taxonomy for Fungi, so regardless you will need to deal with the fact that there are some BLAST hits with 7 taxonomic ranks and some with 12.  
* Also, SILVA and UNITE use different prefixes on their ranked names.  SILVA has a 5 letter prefix (which shouldn't show up in the BLAST results), UNITE has a 3 letter prefix which will definitely be in the BLAST results because it is incorporated into the reference sequence identifier.

> Import BLAST results into list
> Again use regex to help you select the correct files.

	files.BLAST <- list.files(path = "./", pattern = "..*tsv", full.names = FALSE)
	tbl.BLAST <- lapply(files.BLAST, read.delim, header = FALSE)

###### Start shaping and cleaning

> Note that we're breaking the taxonomy into 12 levels here.

	tbl.BLAST <- lapply(tbl.BLAST, 
                     function(x) {
                       x %>%
                         separate(V2, paste0("Level", 1:12), ";", fill = "right")}
)

> break SILVA identifier and first rank into two columns.  The number in the tbl.BLAST list will depend on the order of the BLAST outputs when they were imported (which will depend on your naming conventions because it's alphabetical)

> **The important note here is that we're using "\_" to separate the SILVA identifier and first rank and "K__" to do the same for UNITE.** 

	tbl.BLAST[[1]] <- tbl.BLAST[[1]] %>%
  	separate(Level1, paste0("new", 1:2), "_", fill = "right")

> break UNITE identifier and first rank into two columns
	
	tbl.BLAST[[2]] <- tbl.BLAST[[2]] %>%
  	separate(Level1, paste0("new", 1:2), "k__", fill = "right")

> Add info - again order in the tbl.BLAST list will depend on your file naming conventions

	tbl.BLAST[[1]]$ref_db <- rep("SILVA_132_SSUParc", nrow(tbl.BLAST[[1]]))
	tbl.BLAST[[2]]$ref_db <- rep("UNITE_7.2_20171201", nrow(tbl.BLAST[[2]]))

> Get rid of level annotation in taxa prefixes for UNITE.  Shouldn't need to do for SILVA.

	tbl.BLAST[[2]][,4:9] <- sapply(tbl.BLAST[[2]][,4:9], substring, 4)

> Filter to just Bacterial hits from SILVA and Fungal hits from UNITE because SILVA fungi have extended taxonomy and combine into one data frame.

> again order of databases in the tbl.BLAST list will depend on your file naming conventions

	BLAST <- bind_rows(subset(tbl.BLAST[[1]], 
		new2 %in% c("Bacteria")), 
		subset(tbl.BLAST[[2]], 
		new2 %in% c("Fungi")))

> Get rid of empty taxonomy columns

	BLAST <- BLAST %>%
  		select(-one_of("Level8", "Level9", "Level10", "Level11", "Level12"))

> Add names

	names(BLAST) <- c("Isolate", "refseq_ID" , "Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species", "pct_ident", "align_length", "num_mismatches", "num_gaps", "start_align_query", "end_align_query", "start_align_ref", "end_align_ref",  "e_value", "bitscore", "ref_db")

> Add info

	BLAST$Method <- rep("BLAST", nrow(BLAST))
	BLAST$input_file <- rep("your_input_seqs.fasta", nrow(BLAST))

> Add numbered column to keep track of the order of BLAST hits for each isolate

	BLAST.counted <- BLAST %>% 
  		group_by(Isolate, ref_db) %>% 
    	mutate(BLAST_order = row_number()) %>%
  		as.data.frame()

> Filter to just the top BLAST hit.

> **It's important to understand that the top hit isn't necessarily the best.  You should look at all your BLAST results first.  If you feel the top hit is a good representative of all the hits, then it's convenient to use that one.  If there is a lot of variation in the taxonomy of the the BLAST results, then you'll need to keep that in mind as you analyze your results.  In that case it would probably be best to rely on the QIIME2 results.**

	BLAST.tophit <- subset(BC1.BLAST.counted, BLAST_order==1)

<a name="Step9"></a>
#### Step 9: Put QIIME2 and BLAST results together as csv file 

> Add empty columns named with any BLAST headers that aren't in QIIME2 results to the QIIME2 results

	name_vector <- c("pct_ident", "align_length", "num_mismatches", "num_gaps", "start_align_query", "end_align_query", "start_align_ref", "end_align_ref",  "e_value", "bitscore", "BLAST_order", "refseq_ID")

	Q2[,name_vector] <- NA

> Add empty columns named with any QIIME2 headers that aren't in BLAST results to the BLAST results

	BLAST.tophit[, c("Confidence","Conf_setting")] <- NA

> rearrange columns for binding - they must be in the same order on both data frames

	Q2 <- Q2[,names(BLAST.tophit)]

> Combine two data frames

	tax <- rbind(Q2, BLAST.tophit)

> rearrange columns if desired

> It might make sense to rearrange your columns so that when you open the csv in excel it's easy to look at.  The select function from the dplyr package allows you to do this by listing the column names.  If you're not sure how select works, google it, there are lots of tutorials.

	tax <- tax %>%
  	select(input_file, Method, ref_db, Isolate:Species, Conf_setting, Confidence, pct_ident:bitscore, BLAST_order)

> sort by isolate

> It makes sense to sort your results by Isolate number before you output it.  This means the csv will open with the results sorted by Isolate number so you can compare how the different methods differed in classification.
 
	tax <- arrange(tax, Isolate)

> write to csv file

> This puts the date the file was written in the file name.  It's best not to make many version of the same file, but at least this will give you an unambiguous date of creation

	write.csv(tax, file = paste0("myseqs_CLASSIFIED_", Sys.Date(), ".csv"), row.names = FALSE)
