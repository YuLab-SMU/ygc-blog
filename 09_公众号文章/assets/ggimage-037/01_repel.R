suppressPackageStartupMessages({library(ggplot2); library(ggimage); library(aplot); library(patchwork)})
set.seed(20261015)
logo <- system.file("extdata/Rlogo.png", package = "ggimage")
bulb <- system.file("extdata/bulb.png",  package = "ggimage")

n <- 25
d <- data.frame(x = runif(n, .15, .85), y = runif(n, .15, .85))
d$x <- jitter(d$x, amount = .02); d$y <- jitter(d$y, amount = .02)
p <- ggplot(d, aes(x, y)) +
     geom_point(color = "grey70", size = 1) +
     scale_x_continuous(limits = c(0, 1), breaks = NULL) +
     scale_y_continuous(limits = c(0, 1), breaks = NULL) +
     theme_bw() + labs(x = NULL, y = NULL)

p1 <- p + geom_image(image = logo, width = .12) + ggtitle("geom_image()")
p2 <- p + geom_image_repel(image = logo, width = .12) + ggtitle("geom_image_repel()")

out <- plot_list(p1, p2, nrow = 1) + plot_annotation(title = "")
ggsave("repel.png", out, width = 9, height = 4.2, dpi = 200)
cat("ok\n")
