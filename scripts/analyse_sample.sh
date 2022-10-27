#Let's download the genome even though we are executing with no parameters

mkdir -p res/genome

existeGenome=$(find 'res/genome/' -maxdepth 1 -name 'ecoli.fasta.gz' | wc -l );
echo "$existeGenome";

if [ "$existeGenome" -eq 1 ]
	 then  echo "Genome has already been downladed, we don´t need to download it again";
else
	wget -O 'res/genome/ecoli.fasta.gz' 'ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz' ;
fi


if [ "$#" -ne 1 ]
then
    echo "Usage: $0 <sampleid>"
    exit 1
fi

sampleid=$1
echo "$sampleid";
echo "Running FastQC..."
mkdir -p out/fastqc
fastqc -o out/fastqc data/${sampleid}_?.fastq.gz
echo

echo "Running cutadapt..."
mkdir -p log/cutadapt
mkdir -p out/cutadapt
cutadapt \
    -m 20 \
    -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
    -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
    -o out/cutadapt/${sampleid}_1.trimmed.fastq.gz \
    -p out/cutadapt/${sampleid}_2.trimmed.fastq.gz data/${sampleid}_1.fastq.gz data/${sampleid}_2.fastq.gz \
    > log/cutadapt/${sampleid}.log
echo

echo "Running STAR index..."
mkdir -p res/genome/star_index
STAR \
    --runThreadN 4 \
    --runMode genomeGenerate \
    --genomeDir res/genome/star_index/ \
    --genomeFastaFiles res/genome/ecoli.fasta \
    --genomeSAindexNbases 9
echo

echo "Running STAR alignment..."
mkdir -p out/star/${sampleid}
STAR \
    --runThreadN 4 \
    --genomeDir res/genome/star_index/ \
    --readFilesIn out/cutadapt/${sampleid}_1.trimmed.fastq.gz out/cutadapt/${sampleid}_2.trimmed.fastq.gz \
    --readFilesCommand zcat \
    --outFileNamePrefix out/star/${sampleid}/
echo
