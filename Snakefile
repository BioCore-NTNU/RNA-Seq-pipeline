from snakemake import shell

shell.executable('bash')

configfile: "config.yaml"

to_include = ["workflows/counts.Snakefile",
              "rules/trim/cutadapt.rules"]

for f in to_include:
    include: f

rule targets:
    input:
        expand("data/trim/{sample}_{mate}.fastq", sample="sample1", mate=[1, 2])
        # expand("data/aligned/{prefix}.Aligned.out.sam", prefix="sample1 sample2".split()),
        # expand("data/counts/{prefix}.int", prefix="sample1 sample2".split()),

# rule clean:
#     run:
