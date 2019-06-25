## How to make a program module on Cypress

When you install software locally on Cypress, the Tulane supercomputer.

make module per https://wiki.hpc.tulane.edu/trac/wiki/cypress/ModuleCommand and Carl's email.

mkdir /lustre/project/svanbael/steve/moduleFiles/trinity
	nano /lustre/project/svanbael/steve/moduleFiles/trinity/2.8.4

Edit modulerc file

	nano $HOME/.modulerc

	#%Module
	module use /lustre/project/svanbael/steve/moduleFiles
	
	#make sure you load module rc

	source $HOME/.modulerc

	and add it to your bash profile



	#%Module1.0 -*- tcl -*-
	##
	## modulefile
	##

	module-whatis    assembles transcript sequences from Illumina RNA-Seq data
	prepend-path     PATH /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin
	setenv           JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk.x86_64/jre
	setenv           TRINITY_HOME /lustre/project/svanbael/steve/software/Trinity/trinityrnaseq-Trinity-v2.8.4
	setenv           TRINITY_UTIL /lustre/project/svanbael/steve/software/Trinity/trinityrnaseq-Trinity-v2.8.4/util
	module           load samtools/1.5 bowtie2/2.3.3 R/3.5.2-intel jellyfish/2.2.10 salmon/0.12.0 HPC_gridrunner/1.0.2 
	prepend-path     PATH /lustre/project/svanbael/steve/software/Trinity/trinityrnaseq-Trinity-v2.8.4
	prepend-path     PATH /lustre/project/svanbael/steve/software/Trinity/trinityrnaseq-Trinity-v2.8.4/util
	prepend-path		PATH /lustre/project/svanbael/steve/software/Trinity/trinityrnaseq-Trinity-v2.8.4/trinity-plugins/COLLECTL/util


make module file

	mkdir /lustre/project/svanbael/steve/moduleFiles/BUSCO
	nano /lustre/project/svanbael/steve/moduleFiles/BUSCO/3
	
	#%Module1.0 -*- tcl -*-
	##
	## modulefile
	##
	
	module-whatis    BUSCO v3 provides quantitative measures for the assessment of genome assembly, gene set, and transcriptome completeness, based on evolutionarily-informed expectations of gene content from near-universal single-copy orthologs selected from OrthoDB v9.
	prepend-path     PATH /lustre/project/svanbael/steve/software/BUSCO_git/busco/scripts
	prepend-path     PATH /lustre/project/svanbael/steve/software/BUSCO_git/busco/
	module           load ncbi-blast/2.5.0+ HMMER/3.2.1 anaconda3/5.1.0

###### Install HMMER

	wget http://eddylab.org/software/hmmer/hmmer.tar.gz
	tar -xvzf hmmer.tar.gz

	module load gcc/6.3.0
	./configure
	make
	make check

make module file

	mkdir /lustre/project/svanbael/steve/moduleFiles/HMMER
	nano /lustre/project/svanbael/steve/moduleFiles/HMMER/3.2.1
	
	#%Module1.0 -*- tcl -*-
	##
	## modulefile
	##
	
	module-whatis    HMMER is used for searching sequence databases for sequence homologs, and for making sequence alignments.
	prepend-path     PATH /lustre/project/svanbael/steve/software/HMMER/hmmer-3.2.1/src
