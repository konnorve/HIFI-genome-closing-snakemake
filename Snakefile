from pathlib import Path

configfile: "config.yaml"

scratch_dir = Path(config["scratch directory"])
scratch_dict = {
    "pacbio": scratch_dir / '1_pacbio_reqs',
    "lima demul": scratch_dir / '2_subreadset_demul',
    "ccs demul": scratch_dir / '3_ccs_demul',
    "combine assemblies": scratch_dir / '4_combine_readsets',
    "assembly": {
        "flye_ccs": scratch_dir / '5_assembly' / 'flye_ccs',
        "flye_subreadset": scratch_dir / '5_assembly' / 'flye_subreadset',
        "metaflye_ccs": scratch_dir / '5_assembly' / 'metaflye_ccs',
        "metaflye_subreadset": scratch_dir / '5_assembly' / 'metaflye_subreadset',
        "canu_ccs": scratch_dir / '5_assembly' / 'canu_ccs',
        "canu_subreadset": scratch_dir / '5_assembly' / 'canu_subreadset',
        "SPAdes": {
            "SPAdes": scratch_dir / '5_assembly' / 'SPAdes' / 'assembly',
            "circulator": scratch_dir / '5_assembly' / 'SPAdes' / 'circulator',
        },
    },
    "kaiju": scratch_dir / '6_kaiju'
}

results_dir = Path(config["results directory"])
results_dict = {
    "all assemblies": results_dir / 'all_methods_all_assemblies',
    "circular assemblies": results_dir / 'all_circ_assemblies',
    "reports": results_dir / 'reports',
}

all_files = [
    scratch_dict["lima demul"] / batch / str(run) / f"lima.{barcode}.bam"
    for batch in config["sequencing runs"].keys()
    for run in range(len(config["sequencing runs"][batch]["seq_files"]))
    for barcode in config["sequencing runs"][batch]["barcodes"]
]

rule all:
    input:
        all_files

rule make_barcode_xml:
    input:
        config["barcodes"]
    output:
        scratch_dict["pacbio"] / "barcodes.xml"
    resources:
        mem_mb=250000,
    threads: 20, 
    log:
        "logs/demultiplexing/make_barcode_xml.log"
    shell:
        "dataset create --type BarcodeSet {output} {input}"

for batch in config["sequencing runs"].keys():
    for run in range(len(config["sequencing runs"][batch]["seq_files"])):
        rule:
            name: f"lima_demultiplex_{batch}_{run}"
            input:
                "barcodes": config["barcodes"],
                "subreadset_xml": config["sequencing runs"][batch]["seq_files"][run]
            output:
                expand(scratch_dict["lima demul"] / f"{batch}" / f"{run}" / "lima.{barcode}.bam", barcode=config["sequencing runs"][batch]["barcodes"])
            resources:
                mem_mb=250000,
            threads: 20, 
            log:
                f"logs/demultiplexing/lima_demultiplex/{batch}.{run}.log"
            shell:
                "lima --same --peek-guess --split-named --num-threads {threads} {input.subreadset_xml} {input.barcodes} $(dirname {output[0]})/lima.bam"

# checkpoint ccs_demultiplex:
    # input:
    #     barcodes = scratch_dict["pacbio"] / "barcodes.xml",
    #     subreadset_xml = config["sequencing runs"][{sample}][{run}]
    # output:
    #     scratch_dict["lima demul"] / {sample} / {run}
    # resources:
    #     mem_mb=250000,
    # threads: 20, 
    # log:
    #     "logs/demultiplexing/make_barcode_xml.log"
    # shell:
    #     "lima --same --peek-guess --split-named --num-threads {threads} {input.subreadset_xml} {input.barcodes} {output.out_dir}/lima.bam"


# rule convert_bam_to_fastq: