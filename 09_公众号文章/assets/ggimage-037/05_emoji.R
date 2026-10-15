suppressPackageStartupMessages({library(ggplot2); library(ggimage)})
set.seed(123)
iris2 <- iris[sample(1:nrow(iris), 30), ]
model <- lm(Petal.Length ~ Sepal.Length, data = iris2)
iris2$fitted <- predict(model)

p <- ggplot(iris2, aes(x = Sepal.Length, y = Petal.Length)) +
  geom_linerange(aes(ymin = fitted, ymax = Petal.Length), colour = "purple") +
  geom_abline(intercept = model$coefficients[1], slope = model$coefficients[2]) +
  geom_emoji(aes(image = ifelse(abs(Petal.Length - fitted) > 0.5, "1f622", "1f600")),
             size = .06) +
  theme_bw() + labs(x = "Sepal.Length", y = "Petal.Length",
                    title = "残差大的点，自己会哭")
ggsave("emoji.png", p, width = 6.5, height = 5, dpi = 200)
cat("ok\n")
