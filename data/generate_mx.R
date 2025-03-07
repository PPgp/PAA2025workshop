library(MortCast)
library(data.table)

# create dataset of mx
# reconstruct the schedules using Lee-Carter parameters estimated 
# from the national US mx data, and applied to the corresponding e0.
locs <- fread("wafips.txt")

alle0w <- list("M" = fread("e0M.txt"), "F" = fread("e0F.txt"))

data(mxM1, mxF1, package = "wpp2024")
mxM.us <- subset(mxM1, country_code == 840)[, -(1:3)] # extract US 1x1 mx
mxF.us <- subset(mxF1, country_code == 840)[, -(1:3)]
rownames(mxM.us) <- rownames(mxF.us) <- 0:(nrow(mxM.us) - 1)
us.lcpars <- lileecarter.estimate(mxM.us, mxF.us, nx = 1) 
years <- 1950:2023
mxM <- mxM.us[, as.character(years)]
mxF <- mxF.us[, as.character(years)]
mxMall <- NULL
mxFall <- NULL
for(prov in setdiff(locs$reg_code, 53)){
    pe0M <- subset(alle0w[["M"]], reg_code == prov)[, -(1:3)]
    pe0F <- subset(alle0w[["F"]], reg_code == prov)[, -(1:3)]
    this.mx <- mortcast(unlist(pe0M), unlist(pe0F), lc.pars = us.lcpars)
    mxMall <- rbind(mxMall, cbind(reg_code = prov, age = rownames(mxM), this.mx$male$mx))
    mxFall <- rbind(mxFall, cbind(reg_code = prov, age = rownames(mxF), this.mx$female$mx))
}
write.table(mxMall, file = "mxM.txt", sep = "\t", row.names = FALSE, quote = FALSE)
write.table(mxFall, file = "mxF.txt", sep = "\t", row.names = FALSE, quote = FALSE)