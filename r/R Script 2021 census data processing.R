library(readr)
library(dplyr)


# Importing the raw 2021 census data
raw_data_long <- read_csv("data/RAW_Census_Profile_2021_Gen3 - Copy.csv")
# Importing the CSV file with SES index, numerator and denominator
num_den <- read_csv("data/SES indexes.csv")

# Convert the raw census data from long to wide
raw_data_wide = as.data.frame(t(raw_data_long))
#Adding column names and removing text rows
df = raw_data_wide %>%
  slice(-2)


colnames(df) = df[1, ]

df = df %>%
  slice(-1)
typeof(df$ID1)


df[df == "x"] <- NA
#Converting column types to numeric
df_2 <- df %>% mutate_at(1:2601, as.numeric)


#Mutate
df_3 = df_2 %>%
  mutate("ONE" = 1)
df_3$ONE

which(colnames(df_3) == "ONE")
num_den["Denominator"][num_den["Denominator"] == 1] <- 2602

#testing the equation outside for loop, where i is set to 1
num<- as.numeric(num_den[1,"Numerator"])
denom<- as.numeric(num_den[1,"Denominator"])
typeof(num)
typeof(denom)

test4<- df_3 %>%
  mutate (var = df_3[,num] / df_3[,denom])
test4$var #and it works!

#now let's try it in a loop where i is in 1:14
testloop = df_3 #creating a copy of df_3
for (i in 1:13)
{num<- as.numeric(num_den[i,"Numerator"])
denom<- as.numeric(num_den[i,"Denominator"])
testloop<- testloop%>%
  mutate (var = testloop[,num] / testloop[,denom])}

print(testloop$ID1)

test5$i = as.data.frame(as.list.data.frame(testloop[,num])/as.list.data.frame(testloop[,denom]))}
test5$i

#Testing to see that I can easily pull the numerator & denom col index from the num_dem file
testloop = df_3

for (i in 1:14)
{num<- num_den[i,"Numerator"]
denom<- num_den[i,"Denominator"]
testloop<- testloop %>%
  mutate(var =testloop[,num]/testloop[,denom])}
typeof(testloop$i)