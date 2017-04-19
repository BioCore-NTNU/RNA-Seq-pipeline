from subprocess import check_output

files = ["align/star", "count/htseq"]

for f in files:
    include:
        "../rules/" + f + ".rules"


rule count_reads:
    "Count the total number of reads in the fastq files"
    input:
        fastqs = config["fastq"]
    output:
        "data/count/report/{sample}_total_number_reads.txt"
    shell:
        "zcat {input.fastqs[0]} | tail -1 | grep -Eo '[0-9]+' | awk {{print $1/4}} > {output[0]}"

rule


rule report_counts:
    input:
        counts = "data/count/{sample}.int",
        trimmed = "data/qc/{sample}.trimmed",
        align_log = "data/align/{sample}.Log.final.out"
    output:
        "data/logs/{sample}_report.html"
    run:
        number_lines = check_output("zcat {input.fastqs} | tail -1 | grep -Eo '[0-9]+'", shell=True).decode().strip()
        total_number_reads = int(number_lines/4)

        # qc=$$(zcat ../processed/$(subst .int,.trimmed.gz,$<) |echo $$((`wc -l`/4)));\
        quality_control = check_output("")

    	"""Total number of reads: {total_number_reads}
        QualityFiltered "; echo $$qc; \
        SingleAligned "; echo $$um; \
        MultiAligned "; echo $$mm; \
        NotAligned "; echo $$nm; \
        NoFeature(HTSeq) "; cat $< |grep "no_feature"|cut -f 2 ; \
        Feature(HTseq) "; cat $< | head -n -5| cut -f 2 | perl ../scripts/Sum.pl; \
        mRNA "; cat $*.mrna | cut -f 2 | perl ../scripts/Sum.pl; \
        NotAligned (HTseq) "; cat $< | grep "not_aligned"|cut -f 2 ; \
        MultiAligned (HTseq) "; cat $< | grep "alignment_not_unique"|cut -f 2 ; \
        """



# %.stats: %.int
# 	numm=$$(cat $*Log.final.out | grep "Number of reads mapped to multiple loci" |cut -f 2); \
# 	numt=$$(cat $*Log.final.out | grep "Number of reads mapped to too many loci" |cut -f 2); \
# 	qc=$$(zcat ../processed/$(subst .int,.trimmed.gz,$<) |echo $$((`wc -l`/4)));\
# 	um=$$(cat $*Log.final.out | grep "Uniquely mapped reads number" |cut -f 2);\
# 	mm=$$(echo `expr $$numm + $$numt`);\
# 	nm=$$(echo `expr $$qc - $$mm - $$um`); \
# 	( \
# 	echo -n "Total "; zcat ../raw/$(subst .int,.fastq.gz,$<) |echo $$((`wc -l`/4)); \
# 	echo -n "QualityFiltered "; echo $$qc; \
# 	echo -n "SingleAligned "; echo $$um; \
# 	echo -n "MultiAligned "; echo $$mm; \
# 	echo -n "NotAligned "; echo $$nm; \
# 	echo -n "NoFeature(HTSeq) "; cat $< |grep "no_feature"|cut -f 2 ; \
# 	echo -n "Feature(HTseq) "; cat $< | head -n -5| cut -f 2 | perl ../scripts/Sum.pl; \
# 	echo -n "mRNA "; cat $*.mrna | cut -f 2 | perl ../scripts/Sum.pl; \
# 	#echo -n "NotAligned (HTseq) "; cat $< | grep "not_aligned"|cut -f 2 ; \
# 	#echo -n "MultiAligned (HTseq) "; cat $< | grep "alignment_not_unique"|cut -f 2 ; \
# 	) > $@
