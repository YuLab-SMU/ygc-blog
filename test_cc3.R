library(sclet)
library(CellChat)
sce <- readRDS("e:/YuNotebooks/01_Development/source/yulab-github/sclet-docs/data/pancreas_sub_sce.rds")
res <- RunCellChat(sce, group = "CellType", layer = "logcounts", name = "cellchat_main", species = "mouse", return = "both")
cci_obj <- res$cellchat

pathways.show <- c("PTN")
vertex.receiver = seq(1,4)
CellChat::netVisual_aggregate(cci_obj, signaling = pathways.show, layout = "circle")
CellChat::netVisual_aggregate(cci_obj, signaling = pathways.show, layout = "chord")
CellChat::netVisual_heatmap(cci_obj, signaling = pathways.show, color.heatmap = "Reds")

group.cellType <- c(rep("Epithelial", 3), rep("Endocrine", 2))
names(group.cellType) <- levels(cci_obj@idents)
CellChat::netVisual_chord_cell(cci_obj, signaling = pathways.show, group = group.cellType, title.name = paste0(pathways.show, " signaling network"))

CellChat::netAnalysis_contribution(cci_obj, signaling = pathways.show)

pairLR <- CellChat::extractEnrichedLR(cci_obj, signaling = pathways.show, geneLR.return = FALSE)
LR.show <- pairLR[1,]
CellChat::netVisual_individual(cci_obj, signaling = pathways.show, pairLR.use = LR.show, layout = "circle")
CellChat::netVisual_individual(cci_obj, signaling = pathways.show, pairLR.use = LR.show, layout = "chord")

CellChat::netVisual_bubble(cci_obj, sources.use = 1:2, targets.use = c(3:5), remove.isolate = FALSE)
print("SUCCESS!")
