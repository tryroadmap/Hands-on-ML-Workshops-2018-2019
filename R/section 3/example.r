#@author: Hoofar Pourzand
#This file is copyright protected - do not redistribute
#For R style exercise https://google.github.io/styleguide/Rguide.xml

View(mtcars)

mt1 = mtcars[mtcars$mpg>20,c('gear','mpg')]
View(mt1)

mt2 = aggregate(. ~ gear,mtcars[mtcars$mpg>20,c('gear','mpg')],mean)
View(mt2)

mt3 = subset(aggregate(. ~ gear,mtcars[mtcars$mpg>20,c('gear','mpg')],mean), mpg>25)
View(mt3)
