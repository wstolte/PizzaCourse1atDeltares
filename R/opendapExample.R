library(XML)
library(RCurl)
library(rlist)


theCatalogue = ("http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.html")

theurl <- getURL(theCatalogue,.opts = list(ssl.verifypeer = FALSE) )
tables <- readHTMLTable(theurl)
tables <- list.clean(tables, fun = is.null, recursive = FALSE)
n.rows <- unlist(lapply(tables, function(t) dim(t)[1]))
head(tables)
tables[[1]]$Dataset[1]


