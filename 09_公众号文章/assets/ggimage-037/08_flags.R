suppressPackageStartupMessages({library(ggplot2); library(ggimage); library(ggiraph)})

medals <- read.table(system.file("extdata/medals.txt", package = "ggimage"),
                     header = TRUE)
w <- reshape(medals, idvar = c("Place", "Country", "code", "Total"),
             timevar = "medal", direction = "wide")
names(w) <- gsub("count\\.", "", names(w))

## 把要用到的十面旗抓到本地
dir.create("flags", showWarnings = FALSE)
host <- "https://raw.githubusercontent.com/fonttools/region-flags/refs/heads/gh-pages/png"
for (cc in unique(w$code))
    magick::image_write(magick::image_read(sprintf("%s/%s.png", host, cc)),
                        file.path("flags", paste0(cc, ".png")), format = "png")

w$image <- sprintf("flags/%s.png", w$code)
w$tip   <- sprintf("%s（%s）\n金 %d ｜ 银 %d ｜ 铜 %d\n共 %d 枚",
                   w$Country, w$code, w$Gold, w$Silver, w$Bronze, w$Total)

p <- ggplot(w, aes(Gold, Total)) +
    geom_image_interactive(aes(image = image, tooltip = tip, data_id = Country),
                           size = .09) +
    scale_x_continuous(breaks = seq(0, 12, 2), limits = c(1, 13)) +
    scale_y_continuous(breaks = seq(0, 30, 10), limits = c(2, 32)) +
    labs(x = "金牌数", y = "奖牌总数", title = "把鼠标放到国旗上") +
    theme_bw(base_size = 13) +
    theme(plot.title = element_text(hjust = .5, size = 15))

html <- girafe(ggobj = p, width_svg = 7.4, height_svg = 4.8,
    options = list(
        opts_hover(css = "filter:drop-shadow(0 0 5px #E07B39);", reactive = TRUE),
        opts_hover_inv(css = "opacity:0.2;"),
        opts_tooltip(opacity = 1, offx = 14,
                     css = "background:#1F2A33;color:#fff;font-size:13px;\
                            line-height:1.7;padding:8px 12px;border-radius:5px;\
                            white-space:pre;")))

htmltools::save_html(html, "flags_interactive.html")
