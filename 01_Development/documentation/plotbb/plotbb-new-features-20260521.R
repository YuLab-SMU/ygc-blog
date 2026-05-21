dir.create("e:/YuNotebooks/01_Development/documentation/plotbb/assets/公众号文章-plotbb-新功能-20260521", recursive = TRUE, showWarnings = FALSE)

library(devtools)
load_all("e:/YuNotebooks/01_Development/source/mycran/plotbb", quiet = TRUE)

outdir <- "e:/YuNotebooks/01_Development/documentation/plotbb/assets/公众号文章-plotbb-新功能-20260521"

cols_species <- c(
  setosa = "#4DBA87",
  versicolor = "#F39B6D",
  virginica = "#7A8FD8"
)

cols_width <- c(
  narrow = "#4DBA87",
  wide = "#F39B6D"
)

iris2 <- iris
iris2$Species <- factor(iris2$Species, levels = names(cols_species))
iris2$WidthGroup <- ifelse(
  iris2$Sepal.Width >= stats::median(iris2$Sepal.Width, na.rm = TRUE),
  "wide",
  "narrow"
)
iris2$WidthGroup <- factor(iris2$WidthGroup, levels = c("narrow", "wide"))

png(file.path(outdir, "density-grouped.png"), width = 1800, height = 1200, res = 180)
print(
  bbplot(iris2, bb_aes(Petal.Length, fill = Species)) +
    bb_density(alpha = 0.55) +
    bb_scale_col_manual(cols_species) +
    bb_legend(aesthetic = "fill") +
    bb_title("Petal length distribution") +
    bb_sub("Grouped density in base graphics")
)
dev.off()

png(file.path(outdir, "lm-grouped-ci.png"), width = 1800, height = 1200, res = 180)
print(
  bbplot(iris2, bb_aes(Petal.Length, Sepal.Length, col = Species)) +
    bb_point(pch = 19, cex = 1.1) +
    bb_scale_col_manual(cols_species) +
    bb_lm(bb_aes(group = Species), se = TRUE, lwd = 2) +
    bb_legend() +
    bb_title("Grouped linear fits with confidence bands")
)
dev.off()

png(file.path(outdir, "facet-row-outside-legend.png"), width = 2400, height = 900, res = 180)
print(
  bbplot(iris2, bb_aes(Petal.Length, Sepal.Length, col = WidthGroup)) +
    bb_point(pch = 19, cex = 1.1) +
    bb_scale_col_manual(cols_width) +
    bb_lm(bb_aes(group = WidthGroup), se = TRUE, lwd = 2) +
    bb_facet_wrap(~Species, nrow = 1) +
    bb_legend(outside = TRUE, position = "right") +
    bb_title("One-row facets, shared Y-axis, outside legend") +
    bb_sub("Each panel keeps its own strip title")
)
dev.off()
