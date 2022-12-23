def lima_demultiplex_input(wildcards):
    return {
        "barcodes": config["barcodes"],
        "subreadset_xml": config["sequencing runs"][wildcards.batch]["seq_files"][int(wildcards.run)]
    }

def lima_demultiplex_output(wildcards):
    return [scratch_dict["lima demul"] / wildcards.batch / wildcards.run / f"lima.{barcode}.bam"
        for barcode in config["sequencing runs"][wildcards.batch]["barcodes"]
    ]

rule demultiplex:
    input:
        lima_demultiplex_input
    output:
        lima_demultiplex_output
    resources:
        partition = 'sched_mit_chisholm',
        mem = '250G',
        ntasks = '20',
        time = '5-0',
        output = lambda w: mk_out("demultiplexing", "demultiplex", wildcards=[w.batch, w.run]),
        error = lambda w: mk_err("demultiplexing", "demultiplex", wildcards=[w.batch, w.run]),
    shell:
        "lima --same --peek-guess --split-named --num-threads {resources.ntasks} {input.subreadset_xml} {input.barcodes} $(dirname {output[0]})/lima.bam"
