suppressPackageStartupMessages({library(ggplot2); library(ggimage); library(magick)})
logo <- system.file("extdata/Rlogo.png", package = "ggimage")

cols <- c("core" = "#3972B5", "data" = "#E07B39", "viz" = "#2B6777", "web" = "#7A4E7D")
imgs <- lapply(cols, function(cl) image_colorize(image_read(logo), 100, cl))

set.seed(7)
n <- 24
d <- data.frame(x = rnorm(n), y = rnorm(n),
                grp = rep(names(cols), each = 6), stringsAsFactors = FALSE)
d$img <- imgs[d$grp]

options(ggimage.keytype = "image")
p <- ggplot(d, aes(x, y, image = img, colour = grp)) +
    geom_image(size = .09) +
    guides(colour = guide_legend(override.aes = list(image = imgs))) +
    scale_colour_manual(values = unname(cols)) +
    theme_void() +
    theme(legend.position = "bottom",
          legend.title = element_blank(),
          legend.key = element_blank(),
          plot.margin = margin(10, 10, 20, 10))
ggsave("listcol.png", p, width = 6, height = 6.6, dpi = 200)
options(ggimage.keytype = NULL)
cat("ok\n")
