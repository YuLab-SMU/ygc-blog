suppressPackageStartupMessages({library(ggplot2); library(ggimage); library(magick); library(gganimate)})

## ---- 正文第一段 ----
set.seed(20261015)
d <- data.frame(hour = round(runif(16, 8, 16), 1))
d$mood <- round(pmax(1, pmin(10, 12 - d$hour + rnorm(16, 0, 1.1))), 1)

p0 <- ggplot(d, aes(hour, mood)) +
    geom_abline(slope = -1, intercept = 12, colour = "grey80", linetype = 2) +
    geom_image(aes(image = "hamster.gif"), size = .16) +
    labs(x = "每周工时", y = "心情") +
    theme_bw()
ggsave("dance_frozen.png", p0, width = 5.6, height = 4.2, dpi = 150)

## ---- 正文第二段 ----
fr <- image_read("hamster.gif")
nf <- length(fr)

## 一行一个 (人, 帧)
big <- do.call(rbind, lapply(seq_len(nf), function(k) {
    dd <- d
    dd$frame <- k
    dd$image <- rep(as.list(fr)[k], nrow(dd))
    dd
}))

p <- ggplot(big, aes(hour, mood)) +
    geom_abline(slope = -1, intercept = 12, colour = "grey80", linetype = 2) +
    geom_image(aes(image = image), size = .16) +
    labs(x = "每周工时", y = "心情", title = "帧 {frame} / {nf}") +
    theme_bw() + theme(plot.title = element_text(hjust = .5)) +
    transition_manual(frame)

animate(p, nframes = nf, fps = 5, renderer = gifski_renderer("dance.gif"))

## 帧带
image_append(image_resize(image_read("dance.gif")[seq_len(nf)], "170x")) |>
    image_write("dance_strip.png", format = "png")
