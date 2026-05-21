library(plotbb)

pdf("test_new_features.pdf", width=12, height=4)

# 1. bb_density
p1 <- bbplot(iris, bb_aes(Sepal.Length, fill = Species)) +
  bb_density(alpha = 0.5) +
  bb_title("Density plot")

# 2. bb_lm with CI
p2 <- bbplot(iris, bb_aes(Petal.Length, Sepal.Length, col = Species)) +
  bb_point() +
  bb_lm(se = TRUE) +
  bb_title("LM with CI")

# 3. facet with nrow=1 and shared Y axis
p3 <- bbplot(iris, bb_aes(Petal.Length, Sepal.Length, col = Species)) +
  bb_point() +
  bb_facet_wrap(~Species, nrow = 1) +
  bb_title("Facet nrow=1 shared Y")

# 4. Legend outside
# To make room for legend outside, we might need to adjust par(mar) manually for now, 
# or bb_theme can do it.
p4 <- bbplot(iris, bb_aes(Petal.Length, Sepal.Length, col = Species)) +
  bb_point() +
  bb_theme(mar = c(5, 4, 4, 8)) +
  bb_legend(outside = TRUE, position = "right") +
  bb_title("Legend Outside")

print(p1)
print(p2)
print(p3)
print(p4)

dev.off()
