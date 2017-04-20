from snakemake import shell

shell.executable('bash')

from utils.helper_functions import trimmed_files

configfile: "config.yaml"

to_include = ["trim/cutadapt", "align/star", "count/htseq"]

for f in to_include:
    include:
        "rules/" + f + ".rules"

rule targets:
    input:
        expand("data/count/{sample}.int", sample="sample1"),
        expand("data/align/{prefix}.Aligned.out.sam", prefix="sample1".split()),
        # expand("data/trim/{sample}_{mate}.fastq", sample="sample1", mate="1 2".split())
        # expand("data/counts/{prefix}.int", prefix="sample1 sample2".split()),

# rule clean:
#     run:
