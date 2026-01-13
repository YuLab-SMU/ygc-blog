tryCatch({
    suppressPackageStartupMessages(library(clusterProfiler))
    suppressPackageStartupMessages(library(DOSE))
    suppressPackageStartupMessages(library(org.Hs.eg.db))
}, error = function(e) {
    cat("Error loading packages: ", e$message, "\n")
    quit(status=1)
})

# Load data
data(geneList, package="DOSE")
de <- names(geneList)[1:100]

# Run enrichKEGG
kk <- enrichKEGG(gene         = de,
                 organism     = 'hsa',
                 pvalueCutoff = 0.05)

if (is.null(kk) || nrow(kk) == 0) {
    cat("No significant enrichment found.\n")
} else {
    # Calculate pairwise term similarity if possible (for interpretation)
    # This helps in grouping terms
    # We will just print the result for the AI to interpret
    
    res_df <- as.data.frame(kk)
    
    # Write full results
    write.csv(res_df, "enrichKEGG_results.csv", row.names=FALSE)
    
    # Print top 20 for immediate context
    cat("\nTop 20 Enriched Terms:\n")
    print(head(res_df[, c("ID", "Description", "p.adjust", "GeneRatio", "bgRatio")], 20))
    
    # Also print genes for the top term to confirm
    cat("\nGenes in top term:\n")
    print(res_df$geneID[1])
}
