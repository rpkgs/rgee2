# // lc08
renameOli <- function(img){
    img$select(
        c("B2", "B3", "B4", "B5", "B6", "B7", "pixel_qa"),
        c("Blue", "Green", "Red", "NIR", "SWIR1", "SWIR2", "pixel_qa"));
}

# Function to get and rename bands of interest from ETM+$
renameEtm <- function(img){
    img$select(
        c("B1", "B2", "B3", "B4", "B5", "B7", "pixel_qa"),
        c("Blue", "Green", "Red", "NIR", "SWIR1", "SWIR2", "pixel_qa"));
}

colFilter <- function(col, roi, start_date, end_date){
    col$filterBounds(roi)$filterDate(start_date, end_date);
}

fmask <- function(img) {
    cloudShadowBitMask = 1 %>% bitwShiftL(3);
    cloudsBitMask = 1 %>% bitwShiftL(5);
    qa = img$select("pixel_qa");
    mask = (
        qa$bitwiseAnd(cloudShadowBitMask)
        $eq(0)
        $And(qa$bitwiseAnd(cloudsBitMask)$eq(0))
    );
    img$updateMask(mask);
}

prepOli <- function(img, apply_fmask = TRUE){
    orig = img;
    img = renameOli(img);
    if (apply_fmask) img = fmask(img);
    ee$Image(img$copyProperties(orig, orig$propertyNames()))$resample("bicubic");
}

prepEtm <- function(img, apply_fmask = TRUE){
    orig = img;
    img = renameEtm(img);
    if (apply_fmask) img = fmask(img);
    ee$Image(img$copyProperties(orig, orig$propertyNames()))$resample("bicubic");
}
