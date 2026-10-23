# 公众号文章配图：全部来自真实查询
suppressPackageStartupMessages({
  library(gpsadb)
  library(ggplot2)
})

out_dir <- path.expand("~/data/YuNotebooks/09_公众号文章/assets/gpsadb-mcp")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

pal <- list(
  bg = "#F7F4EE", teal = "#2B6777", orange = "#E07B39",
  ink = "#1F2A33", light = "#6B7A85", rule = "#D8D2C6"
)

cjk <- "Noto Sans CJK SC"
if (!cjk %in% systemfonts::system_fonts()$family) cjk <- "sans"

base_theme <- theme_minimal(base_size = 13, base_family = cjk) +
  theme(
    plot.background   = element_rect(fill = pal$bg, colour = NA),
    panel.background  = element_rect(fill = pal$bg, colour = NA),
    panel.grid.major  = element_line(colour = pal$rule, linewidth = 0.3),
    panel.grid.minor  = element_blank(),
    plot.title        = element_text(colour = pal$ink, face = "bold", size = 15),
    plot.subtitle     = element_text(colour = pal$light, size = 10),
    plot.caption      = element_text(colour = pal$light, size = 8),
    axis.text         = element_text(colour = pal$ink),
    axis.title        = element_text(colour = pal$light),
    legend.position   = "none",
    plot.margin       = margin(14, 18, 10, 14)
  )

pretty <- function(x) {
  x <- sub("^HALLMARK_", "", x)
  gsub("_", " ", x)
}

# --- 图 1：GSEA top 10 ------------------------------------------------------
gsea <- gpsadb_gsea("D20305", limit = 10)$data
gsea$label <- factor(pretty(gsea$term), levels = rev(pretty(gsea$term)))
gsea$dir <- ifelse(gsea$nes > 0, "扰动后上调", "扰动后下调")

p1 <- ggplot(gsea, aes(nes, label, fill = dir)) +
  geom_col(width = 0.62) +
  geom_vline(xintercept = 0, colour = pal$rule) +
  scale_fill_manual(values = c("扰动后上调" = pal$teal, "扰动后下调" = pal$orange)) +
  labs(
    title = "D20305 · TP53 敲低后变化的 Hallmark 通路",
    subtitle = "NES 为正表示通路在扰动后上调（Hallmarks 前 10，50 条里 21 条显著）",
    x = "NES", y = NULL
  ) +
  base_theme

ggsave(file.path(out_dir, "gsea.png"), p1, width = 8, height = 4.4, dpi = 300, bg = pal$bg)

# --- 图 2：fastGPSA top 10 --------------------------------------------------
fa <- gpsadb_fastgpsa(dataset_id = "D20305", limit = 10)$data
fa$label <- sprintf("%s · %s · %s", fa$perturbed_gene, fa$cell_line, fa$dataset)
fa$label <- factor(fa$label, levels = rev(fa$label))
fa$dir <- ifelse(fa$gscore < 0, "复现签名", "反转签名")

p2 <- ggplot(fa, aes(gscore, label, fill = dir)) +
  geom_col(width = 0.62) +
  geom_vline(xintercept = 0, colour = pal$rule) +
  scale_fill_manual(values = c("复现签名" = pal$teal, "反转签名" = pal$orange)) +
  labs(
    title = "拿 D20305 的签名去七千个数据集里找",
    subtitle = "gscore = down_es - up_es；负值（复现）按 |gscore| 排序，图中的名次是全库名次",
    x = "gscore", y = NULL,
    caption = "gpsadb_fastgpsa(dataset_id = \"D20305\")"
  ) +
  base_theme

ggsave(file.path(out_dir, "fastgpsa.png"), p2, width = 8, height = 4.4, dpi = 300, bg = pal$bg)

# --- 图 3：CDKN1A 在 12 个 TP53 数据集里的方向 ------------------------------
ids <- gpsadb_search_datasets(perturbed_gene = "TP53", reference_only = TRUE,
                              limit = 200)$data
meta <- ids[, c("id", "cell_line", "method")]
genes <- c("CDKN1A")

rows <- lapply(ids$id[1:12], function(id) {
  d <- gpsadb_de(id, genes = genes)$data
  if (!nrow(d)) return(NULL)
  data.frame(dataset = id, log2fc = d$log2fc[1], padj = d$padj[1])
})
de <- do.call(rbind, rows)
de <- merge(de, meta, by.x = "dataset", by.y = "id")
de <- de[order(de$log2fc), ]
de$label <- sprintf("%s  %s / %s", de$dataset, de$cell_line, de$method)
de$label <- factor(de$label, levels = de$label)
de$dir <- ifelse(de$log2fc > 0, "升高", "降低")

p3 <- ggplot(de, aes(log2fc, label, fill = dir)) +
  geom_col(width = 0.62) +
  geom_vline(xintercept = 0, colour = pal$rule) +
  scale_fill_manual(values = c("升高" = pal$teal, "降低" = pal$orange)) +
  labs(
    title = "同一个下游基因，12 个 TP53 数据集给出两向答案",
    subtitle = "CDKN1A 的 log2fc；D20883 / D20884 同属 GSE131416，一个比亲本、一个比另一个突变克隆",
    x = "log2fc", y = NULL,
    caption = "gpsadb_de(id, genes = \"CDKN1A\")"
  ) +
  base_theme +
  theme(axis.text.y = element_text(size = 9))

ggsave(file.path(out_dir, "cdkn1a.png"), p3, width = 8, height = 4.8, dpi = 300, bg = pal$bg)

cat("figures written to", out_dir, "\n")
print(file.info(file.path(out_dir, c("gsea.png", "fastgpsa.png", "cdkn1a.png")))[, "size"])

# --- 图 4：71 个 TP53 数据集的方法分布 -------------------------------------
all_ids <- gpsadb_search_datasets(perturbed_gene = "TP53", limit = 200)$data
ref_ids <- gpsadb_search_datasets(perturbed_gene = "TP53", reference_only = TRUE,
                                  limit = 200)$data
m <- as.data.frame(table(all_ids$method), stringsAsFactors = FALSE)
names(m) <- c("method", "n")
m$in_ref <- vapply(m$method, function(x) sum(ref_ids$method == x), integer(1))
m <- m[order(m$n), ]
m$method <- factor(m$method, levels = m$method)

p4 <- ggplot(m, aes(n, method)) +
  geom_col(fill = pal$teal, width = 0.6) +
  geom_text(aes(label = sprintf("%d（参考集 %d）", n, in_ref)),
            hjust = -0.15, size = 3.6, colour = pal$light, family = cjk) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.32))) +
  labs(title = "71 个 TP53 数据集，按扰动方法分",
       subtitle = "参考集 63 个；方法分布本身就不均匀，结论得连着方法一起看",
       x = "数据集数", y = NULL,
       caption = "gpsadb_search_datasets(perturbed_gene = \"TP53\")") +
  base_theme +
  theme(panel.grid.major.y = element_blank())

ggsave(file.path(out_dir, "methods.png"), p4, width = 6.4, height = 3.2, dpi = 300, bg = pal$bg)
cat("methods.png written\n")
