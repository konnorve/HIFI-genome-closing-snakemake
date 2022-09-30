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

def lima_demultiplex_input(wildcards):
    return {
        "barcodes": config["barcodes"],
        "subreadset_xml": config["sequencing runs"][wildcards.batch]["seq_files"][int(wildcards.run)]
    }

def lima_demultiplex_output(wildcards):
    return [scratch_dict["lima demul"] / wildcards.batch / wildcards.run / f"lima.{barcode}.bam"
        for barcode in config["sequencing runs"][wildcards.batch]["barcodes"]
    ]

rule lima_demultiplex:
    input:
        lima_demultiplex_input
    output:
        expand(scratch_dict["lima demul"] / "{batch}" / "{run}" / "lima.{barcode}.bam", barcode=config["sequencing runs"][wildcards.batch]["barcodes"])
    resources:
        mem_mb=250000,
    threads: 20, 
    log:
        "logs/demultiplexing/lima_demultiplex/{batch}.{run}.log"
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