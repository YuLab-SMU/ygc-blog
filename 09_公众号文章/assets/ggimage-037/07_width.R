suppressPackageStartupMessages({library(ggplot2); library(ggimage)})
logo <- system.file("extdata/Rlogo.png", package = "ggimage")
d <- data.frame(x = c(1, 3, 5), y = 1.5, w = c(.16, .24, .32))
ggplot(d, aes(x, y)) +
    geom_hline(yintercept = 1.5, colour = "grey88") +
    geom_image(aes(image = logo, width = w)) +
    geom_text(aes(label = sprintf("width = %.2f", w)), y = .42,
              size = 3.4, colour = "grey40") +
    coord_cartesian(xlim = c(0, 6), ylim = c(.3, 2.7), clip = "off") +
    labs(x = NULL, y = NULL, title = "只给 width，高度按图片自己的比例算") +
    theme_void(base_size = 13) +
    theme(plot.title = element_text(hjust = .5, size = 14))
ggsave("wh_fig.png", last_plot(), width = 6.2, height = 2.5, dpi = 200)
cat("RESULT ok\n")
