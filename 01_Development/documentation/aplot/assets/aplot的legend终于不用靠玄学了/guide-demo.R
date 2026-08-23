library(ggplot2)
library(pkgload)

pkgload::load_all("e:/YuNotebooks/01_Development/source/mycran/aplot")

out_dir <- "e:/YuNotebooks/01_Development/documentation/aplot/assets/aplot的legend终于不用靠玄学了"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

p_main <- ggplot(mtcars, aes(mpg, disp, colour = factor(cyl))) +
  geom_point(size = 2)

p_top <- ggplot(mtcars, aes(mpg, fill = factor(cyl))) +
  geom_density(alpha = 0.4) +
  theme_minimal(base_size = 11) +
  theme(
    axis.title = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    legend.position = "none"
  )

p_right <- ggplot(mtcars, aes(x = factor(cyl), y = disp, fill = factor(cyl))) +
  geom_boxplot(width = 0.6, alpha = 0.8) +
  theme_minimal(base_size = 11) +
  theme(
    axis.title = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    legend.position = "none"
  )

ap1 <- p_main |>
  insert_top(p_top, height = 0.3) |>
  insert_right(p_right, width = 0.25) |>
  set_guide_area("top-right")

ggsave(file.path(out_dir, "aplot-guide-area-top-right.png"), ap1, width = 8, height = 6, dpi = 300)

p_top_guides <- ggplot(mtcars, aes(mpg, wt, shape = factor(am))) +
  geom_point(size = 2.2) +
  theme_minimal(base_size = 11) +
  theme(
    axis.title = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  )

p_right_guides <- ggplot(mtcars, aes(x = factor(gear), y = disp, fill = factor(gear))) +
  geom_boxplot(width = 0.6, alpha = 0.8) +
  theme_minimal(base_size = 11) +
  theme(
    axis.title = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  )

ap2 <- p_main |>
  insert_top(p_top_guides, height = 0.3) |>
  insert_right(p_right_guides, width = 0.25) |>
  set_guide_area("top-right") |>
  set_guide_layout(
    legend_title_position = "top",
    guides_ncol = 2,
    guides_direction = "horizontal"
  )

ggsave(file.path(out_dir, "aplot-guide-layout-guides-ncol-2.png"), ap2, width = 8, height = 6, dpi = 300)
