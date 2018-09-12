#@author: Hoofar Pourzand
#This file is copyright protected - do not redistribute
#For R style exercise https://google.github.io/styleguide/Rguide.xml

library(ggplot2)
attach(mtcars)



qplot(wt,mpg, data = mtcars)

transmission = factor(mtcars$am,levels = c(0,1), labels = c("Automatic","Manual"))
mod=lm(wt~mpg,data=mtcars)
qplot(wt,mpg,
      data= mod,
      color=transmission,
      shape=transmission,
      #geom="smooth",
      geom=c("point","smooth"),
      #method="lm", formula=y~x,
      xlab = "Weight (lbt)",
      ylab= "MPG (mile/gallon)",
      main = "Regression Example")
