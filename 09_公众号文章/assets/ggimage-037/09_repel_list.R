suppressPackageStartupMessages({library(ggplot2); library(ggimage); library(magick)})
fr <- image_read("hamster.gif")
set.seed(20261016); n <- 14
d <- data.frame(x = runif(n, .25, .75), y = runif(n, .25, .75))
d$img <- lapply(seq_len(n), function(i) fr[1 + i %% 5])
p <- ggplot(d, aes(x, y)) +
    scale_x_continuous(limits = c(0, 1), breaks = NULL) +
    scale_y_continuous(limits = c(0, 1), breaks = NULL) +
    theme_bw() + theme(axis.title = element_blank()) +
    geom_image_repel(aes(image = img), width = .18) +
    labs(title = paste0("geom_image_repel() + list 列  [",
                        as.character(packageVersion("ggimage")), "]"))
w <- character(0)
g <- withCallingHandlers(ggplotGrob(p),           # 警告在渲染时才发生
    warning = function(x) { w <<- c(w, conditionMessage(x)); invokeRestart("muffleWarning") })
cat("RESULT 版本:", as.character(packageVersion("ggimage")),
    " 警告数:", length(w), if (length(w)) paste0("[", substr(w[1], 1, 30), "]") else "", "\n")
ggsave(paste0("repel_", sub("\\.$", "", as.character(packageVersion("ggimage"))), ".png"),
       p, width = 4.6, height = 3.8, dpi = 150)
