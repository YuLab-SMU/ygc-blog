suppressPackageStartupMessages({library(ggplot2); library(ggimage); library(magick); library(gganimate)})
logo <- system.file("extdata/Rlogo.png", package = "ggimage")
bulb <- system.file("extdata/bulb.png",  package = "ggimage")

## 1. 源动画：把 logo 逐帧旋转，写成帧文件
nf <- 16
dir.create("frames", showWarnings = FALSE)
angles <- seq(0, 337.5, length.out = nf)
for (i in seq_len(nf)) {
  image_read(logo) |> image_rotate(angles[i]) |>
    image_write(sprintf("frames/rot%02d.png", i), format = "png")
}

## 2. 帧数据表：一行一个 (glyph, frame)
d <- data.frame(
  glyph = rep(c("spin", "move", "bulb"), each = nf),
  frame = rep(seq_len(nf), times = 3),
  x = c(rep(2, nf), seq(1, 5, length.out = nf), rep(4, nf)),
  y = c(rep(3, nf), rep(1, nf), rep(3, nf))
)
d$image <- c(sprintf("frames/rot%02d.png", d$frame[d$glyph == "spin"]),
             rep(logo, nf), rep(bulb, nf))

static <- data.frame(x = 1:5, y = 2)
p <- ggplot(d, aes(x, y)) +
  geom_rect(aes(xmin = 0.5, xmax = 5.5, ymin = 0.5, ymax = 3.5),
            data = data.frame(x = 1), fill = "white", inherit.aes = FALSE) +
  geom_point(data = static, size = 2, colour = "grey40") +
  geom_image(aes(image = image), data = d, size = .16) +
  coord_fixed(xlim = c(0.5, 5.5), ylim = c(0.5, 3.5)) +
  theme_void() +
  transition_manual(frame)

animate(p, nframes = nf, fps = 8, end_pause = 4,
        renderer = gifski_renderer("anim.gif"))

## 3. 静帧拼图：从生成的 GIF 里取 4 帧并排
src <- image_read("anim.gif")
pick <- src[round(seq(1, length(src), length.out = 4))]
image_append(image_resize(pick, "300x")) |> image_write("anim_frames.png", format = "png")
cat("ok\n")
