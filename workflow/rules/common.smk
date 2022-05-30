__author__ = "Martin Rippin"
__copyright__ = "Copyright 2022, Martin Rippin"
__email__ = "martin.rippin@igp.uu.se"
__license__ = "GPL-3"

import pandas as pd
from snakemake.utils import validate
from snakemake.utils import min_version

from hydra_genetics.utils.resources import load_resources
from hydra_genetics.utils.samples import *
from hydra_genetics.utils.units import *

min_version("6.10.0")

### Set and validate config file


configfile: "config.yaml"


validate(config, schema="../schemas/config.schema.yaml")
config = load_resources(config, config["resources"])
validate(config, schema="../schemas/resources.schema.yaml")


### Read and validate samples file

samples = pd.read_table(config["samples"], dtype=str).set_index("sample", drop=False)
validate(samples, schema="../schemas/samples.schema.yaml")

### Read and validate units file

units = (
    pd.read_table(config["units"], dtype=str)
    .set_index(["sample", "type", "flowcell", "lane", "barcode"], drop=False)
    .sort_index()
)
validate(units, schema="../schemas/units.schema.yaml")

### Set wildcard constraints


wildcard_constraints:
    sample="|".join(samples.index),
    unit="N|T|R",


def compile_output_list(wildcards):
    output_list=["qc/multiqc/multiqc_RNA.html"]
    files={
        "star_fusion": [
            "star-fusion.fusion_predictions.tsv",
        ],
        "fusioncatcher": [
            "final-list_candidate-fusion-genes.hg19.txt",
        ],
    }
    output_list.append(
        [
            "fusions/%s/%s_R/%s" % (prefix, sample, suffix)
            for prefix in files.keys()
            for sample in get_samples(samples)
            for suffix in files[prefix]
        ]
    )
    output_list.append(
        [
            "fusions/arriba/%s_R.fusions.tsv" % (sample)
            for sample in get_samples(samples)
        ]
    )
    output_list.append(
        [
            "compression/spring/%s_%s_%s_%s_%s.spring" % (sample, flowcell, lane, barcode, t)
            for sample in get_samples(samples)
            for t in get_unit_types(units, sample)
            for flowcell in set(
                [
                    u.flowcell
                    for u in units.loc[
                        (
                            sample,
                            t,
                        )
                    ]
                    .dropna()
                    .itertuples()
                ]
            )
            for barcode in set(
                [
                    u.barcode
                    for u in units.loc[
                        (
                            sample,
                            t,
                        )
                    ]
                    .dropna()
                    .itertuples()
                ]
            )
            for lane in set(
                [
                    u.lane
                    for u in units.loc[
                        (
                            sample,
                            t,
                        )
                    ]
                    .dropna()
                    .itertuples()
                ]
            )
        ]
    )
    return output_list
