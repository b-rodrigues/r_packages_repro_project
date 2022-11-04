### Name: condiNumber
### Title: Print matrix condition numbers column-by-column
### Aliases: condiNumber condiNumber.default condiNumber.maxLik
### Keywords: math utilities debugging

### ** Examples

   set.seed(0)
   ## generate a simple multicollinear dataset
   x1 <- runif(100)
   x2 <- runif(100)
   x3 <- x1 + x2 + 0.000001*runif(100) # this is virtually equal to x1 + x2
   x4 <- runif(100)
   y <- x1 + x2 + x3 + x4 + rnorm(100)
   m <- lm(y ~ -1 + x1 + x2 + x3 + x4)
   print(summary(m)) # note the low t-values while R^2 is 0.88.
                     # This hints multicollinearity
   condiNumber(model.matrix(m)) # this _prints_ condition numbers.
                                # note the values 'explode' with x3
   ## we may test the results further:
   print(summary(lm(x3 ~ -1 + x1 + x2))) # Note the high t-values and R^2



