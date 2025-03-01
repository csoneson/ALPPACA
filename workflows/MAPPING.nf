include { SNIPPY                    } from "../modules/SNIPPY.nf"
include { DEDUPLICATE               } from "../modules/SEQKIT.nf"
include { GUBBINS                   } from "../modules/GUBBINS.nf"
include { MASKRC                    } from "../modules/MASKRC.nf"
include { SNPDIST                   } from "../modules/SNPDIST.nf"
include { SNPSITES; SNPSITES_FCONST } from "../modules/SNPSITES.nf"
include { IQTREE; IQTREE_FCONST     } from "../modules/IQTREE.nf"
include { REPORT_MAPPING	    } from "../modules/REPORT.nf"


workflow MAPPING {
	reads_ch = Channel
		.fromPath(params.input)
		.splitCsv(header:true, sep:",")
		.map { file(it.path) }
		.collect()

	ref_ch = Channel
		.fromPath(params.snippyref)

        SNIPPY(reads_ch,
	       ref_ch)

        if (params.deduplicate) {
                DEDUPLICATE(SNIPPY.out.snippy_alignment_ch)
                GUBBINS(DEDUPLICATE.out.seqkit_ch)
                MASKRC(GUBBINS.out.gubbins_ch,
                       DEDUPLICATE.out.seqkit_ch)
		SNPDIST(MASKRC.out.masked_ch)

		if (params.filter_snps) {
                	SNPSITES(MASKRC.out.masked_ch)
                	SNPSITES_FCONST(MASKRC.out.masked_ch)
                	IQTREE_FCONST(SNPSITES.out.snp_sites_aln_ch,
                        	      SNPSITES_FCONST.out.fconst_ch)
                	REPORT_MAPPING(SNIPPY.out.results_ch,
                       	       	       SNPDIST.out.snpdists_results_ch,
                                       IQTREE_FCONST.out.iqtree_results_ch,
                                       IQTREE_FCONST.out.R_tree)
        	}
		if (!params.filter_snps) {
                	IQTREE(MASKRC.out.masked_ch)
                	REPORT_MAPPING(SNIPPY.out.results_ch,
                                       SNPDIST.out.snpdists_results_ch,
                                       IQTREE.out.iqtree_results_ch,
                                       IQTREE.out.R_tree)
        	}
        }

        if (!params.deduplicate) {
                GUBBINS(SNIPPY.out.snippy_alignment_ch)
                MASKRC(GUBBINS.out.gubbins_ch,
                       SNIPPY.out.snippy_alignment_ch)
		SNPDIST(MASKRC.out.masked_ch)

		if (params.filter_snps) {
                	SNPSITES(MASKRC.out.masked_ch)
                        SNPSITES_FCONST(MASKRC.out.masked_ch)
                        IQTREE_FCONST(SNPSITES.out.snp_sites_aln_ch,
                               	      SNPSITES_FCONST.out.fconst_ch)
                        REPORT_MAPPING(SNIPPY.out.results_ch,
                                       SNPDIST.out.snpdists_results_ch,
	                               IQTREE_FCONST.out.iqtree_results_ch,
        	                       IQTREE_FCONST.out.R_tree)
                }
                if (!params.filter_snps) {
                        IQTREE(MASKRC.out.masked_ch)
                        REPORT_MAPPING(SNIPPY.out.results_ch,
                                       SNPDIST.out.snpdists_results_ch,
                                       IQTREE.out.iqtree_results_ch,
                                       IQTREE.out.R_tree)
                }
        }
}
