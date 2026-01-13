tryCatch({
    suppressPackageStartupMessages(library(clusterProfiler))
    suppressPackageStartupMessages(library(DOSE))
    suppressPackageStartupMessages(library(org.Hs.eg.db))
    suppressPackageStartupMessages(library(enrichplot))
    suppressPackageStartupMessages(library(ggplot2))
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
    # Calculate pairwise term similarity for emapplot
    kk <- pairwise_termsim(kk)

    # 1. Cnetplot: Gene-Concept Network
    # Circular layout usually looks cleaner for many connections
    p1 <- cnetplot(kk, 
                   showCategory = 5, 
                   foldChange = geneList, 
                   circular = TRUE, 
                   colorEdge = TRUE) +
          ggtitle("Gene-Pathway Interaction Network")
    
    ggsave("cnetplot.png", p1, width=12, height=10)
    cat("Saved cnetplot.png\n")

    # 2. Emapplot: Enrichment Map
    p2 <- emapplot(kk, showCategory = 15, cex_label_category=0.8) + 
          ggtitle("Pathway Clustering Map")
          
    ggsave("emapplot.png", p2, width=12, height=10)
    cat("Saved emapplot.png\n")
    
    # 3. Dotplot for summary
    p3 <- dotplot(kk, showCategory=15) + ggtitle("Top Enriched Pathways")
    ggsave("dotplot.png", p3, width=10, height=8)
    cat("Saved dotplot.png\n")

    # Output analysis for text generation
    cat("\n--- Network Analysis Data ---\n")
    
    # Get the top genes that connect multiple pathways (Hub genes)
    gene_sets <- setNames(strsplit(kk@result$geneID, "/"), kk@result$Description)
    all_genes <- unlist(gene_sets)
    gene_counts <- table(all_genes)
    top_hubs <- sort(gene_counts, decreasing=TRUE)[1:10]
    
    cat("Top Hub Genes (connecting multiple pathways):\n")
    print(top_hubs)
    
    # Map Entrez IDs to Symbols for readability
    if(length(top_hubs) > 0) {
        symbols <- tryCatch({
            mapIds(org.Hs.eg.db, keys=names(top_hubs), column="SYMBOL", keytype="ENTREZID")
        }, error=function(e) return(names(top_hubs)))
        cat("Symbols:\n")
        print(symbols)
    }
}
