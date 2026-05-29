library(sclet)
library(CellChat)
sce <- readRDS("e:/YuNotebooks/01_Development/source/yulab-github/sclet-docs/data/pancreas_sub_sce.rds")
res <- RunCellChat(sce, group = "CellType", layer = "logcounts", name = "cellchat_main", species = "mouse", return = "both")
cci_obj <- res$cellchat
print(cci_obj@netP$pathways)
