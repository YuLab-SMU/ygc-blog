library(plotbb)

# Example 1: Grouped scatterplot
p1 <- bbplot(iris, bb_aes(Petal.Length, Sepal.Length, col = Species)) +
  bb_point() +
  bb_legend()

# Example 2: lm layer and tweaks
p2 <- bbplot(iris, bb_aes(Petal.Length, Sepal.Length, col = Species)) +
  bb_grid(col = "grey90", lty = "solid") +
  bb_point(pch = 16) +
  bb_lm(bb_aes(group = Species), lwd = 2) +
  bb_scale_col_palette("Dark2") +
  bb_theme(bty = "n") +
  bb_legend()

# Example 3: Themes
p3 <- bbplot(iris, bb_aes(Petal.Length, Sepal.Length, col = Species)) +
  bb_point() +
  bb_lm(bb_aes(group = Species)) +
  bb_theme_minimal() +
  bb_legend()

# Example 5: Facet with continuous color
p5 <- bbplot(iris, bb_aes(Petal.Length, Sepal.Length, col = Sepal.Length)) +
  bb_point(pch = 19) +
  bb_facet_wrap(~Species) +
  bb_scale_col_gradient(low = "lightblue", high = "darkblue") +
  bb_legend() +
  bb_labs(title = "Faceted flowers", sub = "Brought to you by plotbb")

pdf("test_plotbb.pdf")
print(p1)
print(p2)
print(p3)
print(p5)
dev.off()
