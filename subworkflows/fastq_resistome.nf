// Load modules
include { index ; bwa_align } from '../modules/Alignment/bwa'

// resistome
include {plotrarefaction ; runresistome ; runsnp ; resistomeresults ; runrarefaction ; build_dependencies ; snpresults} from '../modules/Resistome/resistome'


workflow FASTQ_RESISTOME_WF {
    take: 
        read_pairs_ch
        amr
        annotation

    main:
        // download resistome and rarefactionanalyzer
        if (file("${baseDir}/bin/AmrPlusPlus_SNP/SNP_Verification.py").isEmpty()){
            build_dependencies()
            resistomeanalyzer = build_dependencies.out.resistomeanalyzer
            rarefactionanalyzer = build_dependencies.out.rarefactionanalyzer
            amrsnp =  build_dependencies.out.amrsnp
        }
        else {
            amrsnp = file("${baseDir}/bin/AmrPlusPlus_SNP/")
            resistomeanalyzer = file("${baseDir}/bin/resistome")
            rarefactionanalyzer = file("${baseDir}/bin/rarefaction")
        }
        // Index
        index(amr)
        // AMR alignment
        bwa_align(amr, index.out, read_pairs_ch )
        // Split sections below for standard and deduped results
        runresistome(bwa_align.out.bwa_sam,amr, annotation, resistomeanalyzer )
        resistomeresults(runresistome.out.resistome_counts.collect())
        runrarefaction(bwa_align.out.bwa_sam, annotation, amr, rarefactionanalyzer)
        plotrarefaction(runrarefaction.out.rarefaction.collect())
        // Add SNP confirmation
        if (params.snp == "Y") {
            runsnp(bwa_align.out.bwa_sam, resistomeresults.out.snp_count_matrix, amrsnp)
            snpresults(runsnp.out.snp_counts.collect(), resistomeresults.out.snp_count_matrix )
        }
        // Add analysis of deduped counts
        if (params.deduped == "Y")
            prefix = "dedup_AMR"
            runresistome(bwa_align.out.bwa_dedup_sam,amr, annotation, resistomeanalyzer )
            resistomeresults(runresistome.out.resistome_counts.collect())
            if (params.snp == "Y") {
                runsnp(bwa_align.out.bwa_dedup_sam, resistomeresults.out.snp_count_matrix,amrsnp) 
                snpresults(runsnp.out.snp_counts.collect(), resistomeresults.out.snp_count_matrix )
            }
        }


