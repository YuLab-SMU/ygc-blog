suppressPackageStartupMessages({library(ggplot2); library(ggimage); library(magick); library(patchwork)})
logo <- system.file("extdata/Rlogo.png", package = "ggimage")
info <- image_info(image_read(logo))
W <- info$width; H <- info$height
s <- 2.5 / W   # 图宽 2.5 个数据单位

mk <- function(px, xx, ttl) {
  ggplot(iris, aes(Petal.Length, Petal.Width, colour = Species)) +
    geom_bgimage(logo, pixel = px, x = xx, y = 0, scale = s) +
    geom_point(size = 2) +
    annotate("point", x = xx, y = 0, size = 3, shape = 21, fill = "red", colour = "black") +
    scale_x_continuous(limits = c(0, 7), breaks = 0:7) +
    scale_y_continuous(limits = c(0, 2.6)) +
    coord_fixed() + theme_minimal() +
    labs(title = ttl, x = NULL, y = NULL) +
    theme(legend.position = "none", plot.title = element_text(size = 11))
}

p1 <- mk(c(1, H),  0.75, "左下角钉在 (0.75, 0)")
p2 <- mk(c(W %/% 2, H), 3.5, "底边中点钉在 (3.5, 0)")
p3 <- mk(c(W, H),  6.25, "右下角钉在 (6.25, 0)")
p4 <- mk(c(W %/% 2, H %/% 2), 3.5, "中心钉在 (3.5, 0)")

ggsave("bgimage.png", p1 + p2 + p3 + p4 + patchwork::plot_layout(ncol = 2),
       width = 10, height = 10, dpi = 170)
cat("ok\n")
