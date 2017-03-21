configfile: "config.yaml"

include:
    "workflows/counts.Snakefile"

rule targets:
    input:
        expand("data/aligned/{prefix}.sam", prefix="sample1 sample2".split())
