

process fastqc {
    tag "FASTQC on $sample_id"
    label "fastqc"

    publishDir "${params.output}/QC_analysis/FastQC", mode: 'copy'

    input:
    tuple val(sample_id), path(reads) 

    output:
    path "${sample_id}_fastqc_logs" 


    script:
    """
    mkdir ${sample_id}_fastqc_logs
    fastqc -o ${sample_id}_fastqc_logs -f fastq -q ${reads}
    """
}


process multiqc {
    errorStrategy 'ignore'
    label "fastqc"

    publishDir "${params.output}/QC_analysis/", mode: 'copy',
        saveAs: { filename ->
            if(filename.indexOf("general_stats.txt") > 0) "${params.output}/Results/Stats/$filename"
            else {}

    
    input:
    path 'data*/*' 
    path config

    output:
    path 'multiqc_report.html'
    path 'multiqc_general_stats.txt'

    script:
    """
    cp $config/* .
    multiqc -v .
    mv multiqc_data/multiqc_general_stats.txt .
    """
}
