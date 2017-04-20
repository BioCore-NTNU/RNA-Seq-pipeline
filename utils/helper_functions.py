from snakemake.io import expand

def trimmed_files(sample, paired_end):
    if paired_end:
        files = ["data/trim/{sample}_1.fastq", "data/trim/{sample}_2.fastq"]
    else:
        files = "data/trim/{sample}.fastq"

    return expand(files, sample=sample)
