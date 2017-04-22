library(jsonlite)
library(plyr)

#Initializing Google Maps' API url
url <- "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=18.4517443,-70.750141&radius=50000&key=[your key here]"
page <- fromJSON(url) #Scrapping results of first page

r<- NULL #Saving results

#Now looping over to scrape all the results
repeat{
  r <- c(r,page$results$place_id)
  url <- paste0("https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=",page$next_page_token,"&key=[your key here]")
  page <- fromJSON(url)
  print(length(r))
  if(length(page$next_page_token)==0)
    break
}

k <- unique(r) #Removing duplicates

fdata <- NULL #Dataframe to save results

for(i in 1:length(k)) #Looping over results to scrape POI details
  {
  tryCatch(
    {
  url <- paste0("https://maps.googleapis.com/maps/api/place/details/json?placeid=",k[i],"&key=AIzaSyCl64pRcwBkUaqyscGDcQlkNOyHk8gPg0o")
  page <- fromJSON(url)
  
  phone <- page$result$international_phone_number
  if(length(phone)==0)
  {
    phone <- "None"
  }
  name <- page$result$name
  address <- page$result$formatted_address
  
  if(length(page$result$opening_hours$weekday_text)==0)
  {
    schedule <- "NA"
  }
  if(length(page$result$opening_hours$weekday_text)!=0)
  {
    schedule <- as.data.frame(t(page$result$opening_hours$weekday_text))
  }
  
  temp <- cbind.data.frame(name,address,phone,schedule)
  fdata <- rbind.fill(fdata,temp)
    } , error=function(e){})
  print(i)
}

#Saving results
write.table(fdata, "places.txt", sep="\t", col.names = TRUE, quote = FALSE, row.names = FALSE,na="")

res <- as.list(res)
for(i in 1:10)
{

      url <- paste0("https://maps.googleapis.com/maps/api/place/details/json?placeid=",k[i],"&key=AIzaSyCl64pRcwBkUaqyscGDcQlkNOyHk8gPg0o")
      page <- fromJSON(url)
      res[i] <- page$result
}

tryCatch(
  {cbind.data.frame(page$result$name,page$result$international_phone_number,page$result$formatted_address,t(page$result$opening_hours$weekday_text))} , error=function(e){})
