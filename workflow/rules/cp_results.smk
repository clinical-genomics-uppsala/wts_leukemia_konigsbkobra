__author__ = "Arielle R Munters"
__copyright__ = "Copyright 2022, Arielle R Munters"
__email__ = "arielle.munters@scilifelab.u.se"
__license__ = "GPL-3"


rule cp_arriba:
    input:
        "fusions/arriba/{sample}_R.fusions.tsv",
    output:
        "Results/{project}/{sample}/RNA_fusions/{sample}_R.arriba.tsv",
    shell:
        "cp {input} {output}"


rule cp_star_fusion:
    input:
        "fusions/star_fusion/{sample}_R/star-fusion.fusion_predictions.tsv",
    output:
        "Results/{project}/{sample}/RNA_fusions/{sample}_R.star_fusion.tsv",
    shell:
        "cp {input} {output}"


rule cp_fusioncatcher:
    input:
        "fusions/fusioncatcher/{sample}_R/final-list_candidate-fusion-genes.hg19.txt",
    output:
        "Results/{project}/{sample}/RNA_fusions/{sample}_R.fusioncatcher.txt",
    shell:
        "cp {input} {output}"


rule cp_multiqc:
    input:
        "qc/multiqc/multiqc_RNA.html",
    output:
        "Results/MultiQC_RNA.html",
    shell:
        "cp {input} {output}"



rule cp_spring_archive:
    input:
        "compression/spring/{sample}_{flowcell}_{lane}_{barcode}_{type}.spring",
    output:
        "Archive/{project}/{sample}_{flowcell}_{lane}_{barcode}_{type}.spring",
    shell:
        "cp {input} {output}"
