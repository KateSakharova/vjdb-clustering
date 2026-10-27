nextflow.enable.types = true

process PREPARE_UPDATE {
    /*
     * Hash new sequences against the full existing dataset, check for ID
     * clashes and combine unique new sequences with the existing reps.
     * Wraps: resources/usr/bin/5_prepare_update.py
     */

    container 'community.wave.seqera.io/library/biopython_pandas:a2cf2d914972cc52'
    conda "${moduleDir}/../../environment.yml"

    input:
    new_seqs: Path
    existing_reps: Path
    existing_csv: Path

    output:
    record(
        combined_fasta: file("combined_for_vclust.fna.gz"),
        hashed_csv:     file("new_hashed_reps.csv")
    )

    script:
    """
    5_prepare_update.py \
        --new-seqs ${new_seqs} \
        --existing-reps ${existing_reps} \
        --existing-csv ${existing_csv} \
        --outdir .
    """
}

process FINALIZE_UPDATE {
    /*
     * Remap clusters with stable IDs, report cluster events, write the
     * updated membership CSV and representative FASTA.
     * Wraps: resources/usr/bin/6_finalize_update.py
     */

    container 'community.wave.seqera.io/library/biopython_pandas:a2cf2d914972cc52'
    conda "${moduleDir}/../../environment.yml"

    input:
    leiden_tsv: Path
    new_hashed_csv: Path
    existing_csv: Path
    combined_fasta: Path
    prefix: String

    output:
    record(
        merged_csv:   file("${prefix}_merged_reps.csv"),
        rep_fasta:    file("${prefix}_merged_reps.fna.gz"),
        new_clusters: file("${prefix}_new_clusters.csv"),
        events:       file("${prefix}_cluster_events.tsv")
    )

    script:
    """
    6_finalize_update.py \
        --leiden-tsv ${leiden_tsv} \
        --new-hashed-csv ${new_hashed_csv} \
        --existing-csv ${existing_csv} \
        --combined-fasta ${combined_fasta} \
        --output-prefix ${prefix}
    """
}
