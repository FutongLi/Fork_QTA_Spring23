############################
# Tutorial 1: Web Scraping #
############################

## Packages
library(tidyverse) # load our packages here
library(rvest)
library(xml2)

##################
# Importing html #
##################

# We use the read_html() function from rvest to read in the html
bowlers <- "https://stats.espncricinfo.com/ci/content/records/93276.html"

html <- read_html(bowlers)
html

# We can inspect the structure of this html using xml_structure() from xml2
xml_structure(html)
capture.output(xml_structure(html))

# That's quite a big html! maybe we should go back to square 1 and inspect the 
# page...

###################
# Inspecting html #
###################

# On my browser (firefox) I can use ctrl-u to open the html source code. 
# I can also locate a specific element of the html code by inspecting it (right 
# clicking the mouse and selecting "inspect"). See if you can find where the 
# table begins.

################# 
# Querying html #
#################

# There are different ways of querying html documents. The two main methods are 
# xpath and css selectors. Today we'll focus on xpaths, but you may sometimes 
# come across css as well. This website - https://exadel.com/news/how-to-choose-selectors-for-automation-to-make-your-life-a-whole-lot-easier
# gives a good overview of the difference between the two.

# html nodes using html_nodes()
html %>%
  html_nodes() # try searching for the table node

html %>% 
  html_nodes(".ds-table") # try searching using the class (add a dot)

?html_nodes

# xpaths
# To search using xpath selectors, we need to add the xpath argument.
html %>%
  html_nodes(xpath = "//table")


# Here's a useful guide to xpath syntax: https://www.w3schools.com/xml/xpath_syntax.asp

# Try selecting the first node of the table class, and assign it to a new object
tab1 <- html %>%
  html_nodes(xpath = '//table[position()<2]')
#html_nodes(xpath = '/table[position()=1]')
# there is no more elements than 1



# Let's look at the structure of this node. We could use the xml_structure() 
# function, but the html is still too big. Try inspecting the object in the 
# environment window.

# We basically want "thead" and "tbody". How might we get those?
tab2 <- tab1 %>%
  html_nodes(xpath = '//table/thead | //table/tbody')

# this is equal to :
tab2 <- tab1 %>%
  html_nodes(xpath = '//thead | //tbody')

# We now have an object containing 2 lists. With a bit of work we can extract 
# the text we want as a vector:
heads <- tab2[1] %>%
  html_nodes(xpath = "") %>%
  html_text()

body <- tab2[2] %>%
  html_nodes(xpath = "") %>%
  html_text()

# We now have two vectors, one with our categories and one with our data. We 
# could use our R wrangling skills to shape these into a rectangular data.frame. 

# There is an easier way though - the html_table() function. Let's trace back a 
# few steps to our tab1e object...
xml_children(tab1)
# 当你使用 xml_children(tab1) 时，它将返回tab1 中每个节点的直接子节点

# We can see that tab1 has three children. Our categories are stored in the 
# "thead" node, and our data are in the "tbody" node. The html_table() function 
# can parse this type of structure automatically. Try it out, and assign the 
# result to an object.

# html_table() 是 rvest 包中的函数，用于将HTML表格转换为数据框（data frame
dat <- html_table(tab1, header = TRUE) #list  # why input  tab1 rather tab2
# 单括号 [] 也可以用于从列表中提取元素，但它返回的是一个子列表，而不是元素本身。
dat <- html_table(tab1, header = TRUE)[[1]] #extract the dataframe
#这是选取数据库里第一列的值
dat <- html_table(tab1, header = TRUE)[[1]][1]
dat

?html_table
?html_nodes




dat %>%
  filter(grepl("ENG|AUS", Player)) %>%
  ggplot(aes(Balls, Wkts)) +
    geom_text(aes(label = Player)) +
    geom_smooth(method = "lm")

##############################
# Putting it all together... #
##############################

# Now that we've managed to do that for bowlers, try completing all the steps 
# yourselves on a new html - top international batsmen!
batsmen <- "https://stats.espncricinfo.com/ci/content/records/223646.html"

html2 <- read_html(batsmen)
html2


html2 %>% 
  html_nodes(".ds-table")

html2 %>%
  html_nodes(xpath = "//table")

tab3 <- html2 %>%
  html_nodes(xpath = "//table[position()=1]")

tab4 <- tab3 %>%
  html_nodes(xpath = '//thead | //tbody')
tab4

bat <- html_table(tab3, header = TRUE)[[1]]
bat

# Pipeline operator and filter function to select data that gonna be used
bat %>%
  filter(grepl("SR Tendulkar", Player))

bat %>%
  filter(grepl("ENG|AUS", Player)) %>%
  ggplot(aes(Runs, Ave)) +
  geom_text(aes(label = Player)) +
  geom_smooth(method = "lm")
