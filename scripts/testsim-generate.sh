echo "Processing genome samples..."

for sid in $(ls data/*.fastq.gz | cut -d "_" -f1 | sed 's:data/::' | sort | uniq)
do

echo "$sid";
echo bash scripts/analyse_sample.sh $sid;
bash scripts/analyse_sample.sh "$sid";

done
