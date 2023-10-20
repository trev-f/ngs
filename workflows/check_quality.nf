include { QC_Alignments           } from '../subworkflows/qc_alignments.nf'
include { QC_Reads_Prealign       } from '../subworkflows/qc_reads_prealign.nf'
include { QC_Reads_Raw            } from '../subworkflows/qc_reads_raw.nf'
include { multiqc as multiqc_full } from "../modules/multiqc.nf"

workflow CHECK_QUALITY {
    take:
        reads_raw
        reads_prealign
        trim_log
        alignmentsIndividual
        alignmentsMerged

    main:
        QC_Reads_Raw(
            reads_raw
        )
        ch_multiqc_reads_raw = QC_Reads_Raw.out.multiqc

        QC_Reads_Prealign(
            reads_prealign,
            trim_log
        )
        ch_multiqc_reads_prealign = QC_Reads_Prealign.out.multiqc

        QC_Alignments(
            alignmentsIndividual,
            alignmentsMerged
        )
        ch_multiqc_alignments = QC_Alignments.out.multiqc

        ch_multiqc_full = Channel.empty()
            .concat(ch_multiqc_reads_raw)
            .concat(ch_multiqc_reads_prealign)
            .concat(ch_multiqc_alignments)
            .collect( sort: true )
        multiqc_full(
            ch_multiqc_full,
            file("${projectDir}/assets/multiqc_config.yaml"),
            params.projectTitle
        )
}
