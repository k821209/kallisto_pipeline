
SRRIDs     = [x.strip() for x in open('data/samples').readlines()]
SRATK      = "/programs/sratoolkit.2.7.0-ubuntu64/bin/"
OUTDIR     = "NitrogenDef1hr"
INDEX      = "ref/Creinhardtii_281_v5.5.cds_primaryTranscriptOnly" # kallisto index
KALLPATH   = "/programs/kallisto_linux-v0.43.0/"

rule end:
     input : "{out}/abundance.tsv".format(out=OUTDIR)

rule NCBIdownload:
     params : "{SRRID}",SRRID=SRRIDs
     output : "{SRRID}.sra"
     shell  : "python2.7 ncbi_download.py {params}"

rule fastqdump:
     input  : "{SRRID}.sra"
     output : "data/{SRRID}_1.fastq.gz","data/{SRRID}_2.fastq.gz" # paired_end
     params : cmd=SRATK
     shell  : '''{params.cmd}fastq-dump  --origfmt -I  --split-files --gzip {input}
                 mv {wildcards.SRRID}_?.fastq.gz data/
                 rm {input}'''

rule kallidos:
     input  :
              fastq=expand("data/{SRRID}_{replicate}.fastq.gz",SRRID=SRRIDs,replicate=[1,2])
     params : ix=INDEX, cmd=KALLPATH, outdir=OUTDIR
     output : "{out}/abundance.tsv".format(out=OUTDIR)
     shell  : '''{params.cmd}kallisto quant -i {params.ix} -o {params.outdir} {input.fastq}
                 rm {input.fastq}
              '''     


