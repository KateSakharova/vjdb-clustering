nextflow.enable.types = true

process HASH_DEDUP {
    /*
     * Hash-deduplicate input sequences and split into chunks.
     * Wraps: resources/usr/bin/1_prepare_clustering.py
     */

    container 'community.wave.seqera.io/library/biopython_pandas:a2cf2d914972cc52'
    conda "${moduleDir}/../../environment.yml"

    input:
    fasta: Path
    block_size: Integer

    output:
    record(
        fasta_chunks: files("chunks/vjdb1_*.fna.gz"),
        hashed_csv:   file("chunks/vjdb1_hashed_reps.csv")
    )

    script:
    """
    1_prepare_clustering.py --input ${fasta} --outdir chunks --block-size ${block_size}
    """
}
