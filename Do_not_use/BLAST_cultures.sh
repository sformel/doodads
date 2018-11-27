#DO NOT USE UNTIL STEVE FIXES AND CLEANS.

#!/bin/bash

#SBATCH --job-name=BLAST_cultures
#SBATCH --output=BLAST_cultures.output
#SBATCH --error=BLAST_cultures.error
#SBATCH --qos=normal
#SBATCH --time=0-24:00:00
#SBATCH --nodes=1
#SBATCH --mem=64000
#SBATCH --mail-type=ALL

#Script to BLAST sequences locally on Cypress (Tulane HPC) as opposed to over the internet or through Geneious.

##taken from: https://github.com/Joseph7e/Assign-Taxonomy-with-BLAST & https://www.linuxquestions.org/questions/linux-newbie-8/how-to-untar-all-tar-files-in-a-directory-98963/

wget 'ftp://ftp.ncbi.nlm.nih.gov/blast/db/nt*.gz'

for i in *.tar.gz; do echo working on $i; tar xvzf $i ; done

## Download NCBI's taxonomic data and GI (GenBank ID) taxonomic
## assignation.

##taken from: https://www.biostars.org/p/13452/#13648

## Variables
NCBI="ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/"
TAXDUMP="taxdump.tar.gz"
TAXID="gi_taxid_nucl.dmp.gz"
NAMES="names.dmp"
NODES="nodes.dmp"
DMP=$(echo {citations,division,gencode,merged,delnodes}.dmp)
USELESS_FILES="${TAXDUMP} ${DMP} gc.prt readme.txt"

## Download taxdump
rm -rf ${USELESS_FILES} "${NODES}" "${NAMES}"
wget "${NCBI}${TAXDUMP}" && \
    tar zxvf "${TAXDUMP}" && \
    rm -rf ${USELESS_FILES}

## Limit search space to scientific names
grep "scientific name" "${NAMES}" > "${NAMES/.dmp/_reduced.dmp}" && \
    rm -f "${NAMES}" && \
    mv "${NAMES/.dmp/_reduced.dmp}" "${NAMES}"

## Download gi_taxid_nucl
rm -f "${TAXID/.gz/}*"
wget "${NCBI}${TAXID}" && \
    gunzip "${TAXID}"

exit 0

##run BLAST and find complete taxonomy/

mkdir blast_out

module load ncbi-blast/2.5.0+

blastn -db ./nt -query all_seqs.fasta -max_target_seqs 20 -outfmt '7 qseqid sseqid sblastnames length pident qstart qend sstart send evalue bitscore sgi sacc staxids' -num_threads 10 -out ./blast_out/blast_results.txt

##make full taxonomy file
cut -d "|" -f 1,2 ./blast_out/blast_results.txt | sed -e '/^$/d' | grep -v "^#" > ./blast_out/prepped_blast.txt
 
cut -d "|" -f 2 ./blast_out/blast_results.txt | sed -e '/^$/d' | grep -v "^#" | while read GI ; do bash get_ncbi_taxonomy.sh "$GI" ; done > ./blast_out/full_tax.txt 

paste -d' ' ./blast_out/prepped_blast.txt ./blast_out/full_tax.txt > ./blast_out/done_tax.txt