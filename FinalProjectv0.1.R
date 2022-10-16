# #FINAL PROJECT

#____________________________________________________________________________________________________________________



#_____________________________________________________________________________________________________________________


#We get the directory, and setting the directory where our file is.
dir <-  getwd();
setwd(dir);

#Charging librarys for plots
library(ggplot2)
library(tidyverse)



#We convert our csv data into a data frame, we already saved the file as cvs previously.
df <- data.frame(read.csv("Housing_Data.csv",na.strings = NA,stringsAsFactors = TRUE));
head(df)

#We are looking for Duplicated Values.
summary(df)
anyDuplicated(df)

#We have to treat the duplicated values then.
dups <- duplicated(df) | 
  duplicated(df,fromLast = T);
dups
df[dups,]


#We didn't saw any pattern on the duplicated values, so we are going with default method. From top to bottom
#We remove the duplicated values
df1 <- df[!duplicated(df[dups,]),];
df1
#We check there are no duplicated values
anyDuplicated(df1);


#Now we have to identify the type of missing data.
summary(df1)

countbyrooms <- table(df1$Rooms)
countbyrooms

#We can address missing values by a lot of ways, we will decide to do mean values by category for price.

d1 <- aggregate(df1$Price~df1$Rooms,df1,FUN=mean)
names(d1) <- c("Rooms","Price") 

#We proceed to agregate a colum for mean price by room.
d2 <- merge(df1,d1,by="Rooms");
d2


#Now we assign the mean value to the NA value
d2[is.na(d2$Price.x),5] <- d2[is.na(d2$Price.x),22]; 
#We assure the values were assigned.
d2[is.na(d2$Price.x),]
summary(d2)

#We are gonna return our data frame to original size and names

d2<-d2[1:21];
"Price" <- names(d2[5]);
names(d2) <-  c("Rooms","Suburb","Address","Type","Price","Method",
"SellerG","Date","Distance","Postcode","Bedroom2","Bathroom"     
,"Car","Landsize","BuildingArea","YearBuilt","subregion","Lattitude"  
,"Longtitude","Regionname","Propertycount");

#Now we have assigned the price to our data frame d2, we can proceed with the next missing value.
#We are going to treat latitude and longitude based on the mean on the data because we find out all the properties are in the same city
#Melbourne,Australia


latran <- runif(1,max=38.18,min=37.46)*-1;
lonran <- runif(1,max=145.5,min=144.4);
listlat <- c(runif(length(d2[is.na(d2$Lattitude),18]),max=38.18,min=37.46)*-1);
listlon <- c(runif(length(d2[is.na(d2$Longtitude),19]),max=145.5,min=144.4));

d2[is.na(d2$Lattitude),18] <- listlat
d2[is.na(d2$Longtitude),19] <- listlon
names(d2)

summary(d2)


mapview(d2, xcol = "Longitude", ycol = "Latitude", crs = 4269, grid = FALSE)
ggplo()

#Now we have assigned the price to our data frame d2, we can proceed with the next missing value.
#The next value we are going to treat is Year Built, we are going to use mean and aggregate to solve this problem
dd2 <- round(aggregate(d2$YearBuilt~d2$Propertycount,d2,mean),0)
names(dd2) <- c("Propertycount","YearBuilt")
#We have our average of the year based on the property count, we will proceed to merge the data into a new df.
d3 <- merge(d2,dd2,by = "Propertycount")
d3;


#Now we assign the mean value to the NA value in Year Built
d3[is.na(d3$YearBuilt.x),17] <- d3[is.na(d3$YearBuilt.x),23] 
#We assure the values were assigned.
d3[is.na(d3$YearBuilt.x),]

#We clean out data set so it doesnt become that big
length(df) #Original Data Frame Size
length(d3) #Modified Data Frame Size
d3 <- d3[1:length(df)];

#Now we have a clean darta set ready to keeo working.
d3
vis_miss(d3)


# #Map of the houses
# map <- map_data("world");
# view(map)
# view(d2)
# names(d2)
# d2[22] <- "Australia"
# names(d2) <-  c("Rooms","Suburb","Address","Type","Price","Method",
#                 "SellerG","Date","Distance","Postcode","Bedroom2","Bathroom"     
#                 ,"Car","Landsize","BuildingArea","YearBuilt","subregion","Lattitude"  
#                 ,"Longtitude","Regionname","Propertycount","region");
# 
# mapdata <- na.omit(left_join(map, d2, by="region"))
# View(mapdata)
# map1<-ggplot(mapdata, aes( x = Longtitude, y = Lattitude, group=group)) +
#   geom_polygon(aes(fill = mapdata$Price), color = "black")
# map1





