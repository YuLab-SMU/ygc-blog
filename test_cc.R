library(sclet)
sce <- readRDS("e:/YuNotebooks/01_Development/source/yulab-github/sclet/bookdown/data/pancreas_sub_sce.rds")
res <- RunCellChat(sce, group = "CellType", layer = "logcounts", name = "cellchat_main", species = "mouse", return = "both")
print("CellChat ran successfully!")
