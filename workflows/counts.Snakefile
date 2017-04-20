rule count_reads:
    "Count the total number of reads in the fastq files"
    input:
        fastqs = config["fastq"]
    output:
        "data/count/report/{sample}_total_number_reads.txt"
    shell:
        "zcat {input.fastqs[0]} | wc -l | tail -1 | grep -Eo '[0-9]+' | awk {{print $1/4}} > {output[0]}"

rule reads_passing_qc:
    "Get the total number of reads passing quality filters"
    input:
        # TODO: replace with function that returns one or two files depending on paired end
        first = "data/trim/{sample}_1.fastq",
        second = "data/trim/{sample}_2.fastq",
    output:
        "data/count/report/{sample}_reads_passing_filter.txt"
    shell:
        "wc -l {input[0]} | tail -1 | grep -Eo '[0-9]+' | awk {{print $1/4}} > {output[0]}"

rule multimapping_reads:
    "Find number of reads mapped to multiple loci"
    input:
        "data/align/{sample}.Log.final.out"
    output:
        "data/count/report/{sample}_reads_mapping_to_multiple_loci.txt"
    shell:
        'grep "Number of reads mapped to multiple loci" {input[0]} | cut -f 2 > {output[0]}'

rule reads_mapping_too_many_places:
    "Find number of reads mapped to too many loci"
    input:
        "data/align/{sample}.Log.final.out"
    output:
        "data/count/report/{sample}_reads_mapping_to_multiple_loci.txt"
    shell:
        'grep "Number of reads mapped to too many loci" {input[0]} | cut -f 2 > {output[0]}'

rule uniquely_mapped_reads:
    "Find reads that are uniquely aligned"
    input:
        "data/align/{sample}.Log.final.out"
    output:
        "data/count/report/{sample}_uniquely_mapped_reads.txt"
    shell:
        'grep "Uniquely mapped reads number" {input[0]} |cut -f 2 > {output[0]}'

rule reads_without_features:
    "Find reads overlapping no features(?)"
    input:
        "data/count/{sample}.int"
    output:
        "data/count/report/{sample}_no_features.txt"
    shell:
        'grep "no_feature" {input[0]} | cut -f 2 > {output[0]}'

rule reads_overlapping_features:
    input:
        "data/count/{sample}.int"
    output:
        "data/count/report/{sample}_features.txt"
    shell:
        'head -n -5 {input[0]} | cut -f 2 | paste -s -d "+" - | bc > {output[0]}'

rule not_aligned:
    input:
        "data/count/{sample}.int"
    output:
        "data/count/report/{sample}_not_aligned.txt"
    shell:
        'grep "not_aligned" {input[0]} | cut -f 2 > {output[0]}'

rule multi_aligned:
    input:
        "data/count/{sample}.int"
    output:
        "data/count/report/{sample}_multi_aligned.txt"
    shell:
        'grep "alignment_not_unique" {input[0]} | cut -f 2 > {output[0]}'

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


"""
%.stats: %.int
	numm=$$(cat $*Log.final.out | grep "Number of reads mapped to multiple loci" |cut -f 2); \
	numt=$$(cat $*Log.final.out | grep "Number of reads mapped to too many loci" |cut -f 2); \
	qc=$$(zcat ../processed/$(subst .int,.trimmed.gz,$<) |echo $$((`wc -l`/4)));\
	um=$$(cat $*Log.final.out | grep "Uniquely mapped reads number" |cut -f 2);\
	mm=$$(echo `expr $$numm + $$numt`);\
	nm=$$(echo `expr $$qc - $$mm - $$um`); \
	( \
	echo -n "Total "; zcat ../raw/$(subst .int,.fastq.gz,$<) |echo $$((`wc -l`/4)); \
	echo -n "QualityFiltered "; echo $$qc; \
	echo -n "SingleAligned "; echo $$um; \
	echo -n "MultiAligned "; echo $$mm; \
	echo -n "NotAligned "; echo $$nm; \
	echo -n "NoFeature(HTSeq) "; cat $< |grep "no_feature"|cut -f 2 ; \
	echo -n "Feature(HTseq) "; cat $< | head -n -5 | cut -f 2 | perl ../scripts/Sum.pl; \
	echo -n "mRNA "; cat $*.mrna | cut -f 2 | perl ../scripts/Sum.pl; \
	#echo -n "NotAligned (HTseq) "; cat $< | grep "not_aligned"|cut -f 2 ; \
	#echo -n "MultiAligned (HTseq) "; cat $< | grep "alignment_not_unique"|cut -f 2 ; \
	) > $@
"""
