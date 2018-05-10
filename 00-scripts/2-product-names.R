# download product names (SITC rev 2, HS92/96/02/07) ----------------------

url <- "http://atlas.media.mit.edu/static/db/raw/products_sitc_rev2.tsv.bz2"
bz2 <- paste0(product_dir, "sitc-rev2-product-names.tsv.bz2")
tsv <- paste0(product_dir, "sitc-rev2-product-names.tsv")

if (!file.exists(bz2)) {
  download.file(url, bz2, method = "wget")
}

if (!file.exists(tsv)) {
  system(paste0("7z e ", bz2, " -oc:", product_dir))
}

url <- "http://atlas.media.mit.edu/static/db/raw/products_hs_92.tsv.bz2"
bz2 <- paste0(product_dir, "hs-rev1992-product-names.tsv.bz2")
tsv <- paste0(product_dir, "hs-rev1992-product-names.tsv")

if (!file.exists(bz2)) {
  download.file(url, bz2, method = "wget")
}

if (!file.exists(tsv)) {
  system(paste0("7z e ", bz2, " -oc:", product_dir))
}

url <- "http://atlas.media.mit.edu/static/db/raw/products_hs_96.tsv.bz2"
bz2 <- paste0(product_dir, "hs-rev1996-product-names.tsv.bz2")
tsv <- paste0(product_dir, "hs-rev1996-product-names.tsv")

if (!file.exists(bz2)) {
  download.file(url, bz2, method = "wget")
}

if (!file.exists(tsv)) {
  system(paste0("7z e ", bz2, " -oc:", product_dir))
}

url <- "http://atlas.media.mit.edu/static/db/raw/products_hs_02.tsv.bz2"
bz2 <- paste0(product_dir, "hs-rev2002-product-names.tsv.bz2")
tsv <- paste0(product_dir, "hs-rev2002-product-names.tsv")

if (!file.exists(bz2)) {
  download.file(url, bz2, method = "wget")
}

if (!file.exists(tsv)) {
  system(paste0("7z e ", bz2, " -oc:", product_dir))
}

url <- "http://atlas.media.mit.edu/static/db/raw/products_hs_07.tsv.bz2"
bz2 <- paste0(product_dir, "hs-rev2007-product-names.tsv.bz2")
tsv <- paste0(product_dir, "hs-rev2007-product-names.tsv")

if (!file.exists(bz2)) {
  download.file(url, bz2, method = "wget")
}

if (!file.exists(tsv)) {
  system(paste0("7z e ", bz2, " -oc:", product_dir))
}

# process for R package ---------------------------------------------------

## HS 

rev <- c("92", "96", "02", "07")
year <- c(1992, 1996, 2002, 2007)

for (i in 1:length(rev)) {
  hs <- fromJSON(sprintf("http://atlas.media.mit.edu/attr/hs%s/", rev[i]))
  
  hs <- as_tibble(hs[[1]]) %>%
    select(name, id, color)
  
  hs_groups <- hs %>%
    select(name, id) %>%
    filter(nchar(id) == 2) %>%
    distinct() %>%
    rename(group_name = name, group_id = id)
  
  hs_product_names <- hs %>%
    filter(nchar(id) >= 6) %>%
    mutate(group_id = substr(id, 1, 2)) %>%
    mutate(id = substr(id, 3, nchar(id))) %>%
    rename(product_name = name) %>%
    left_join(hs_groups) %>%
    mutate(
      product_name = iconv(product_name, from = "", to = "ASCII", sub = "byte"),
      group_name = iconv(group_name, from = "", to = "ASCII", sub = "byte")
    ) %>%
    select(product_name, id, group_name, group_id, color)
  
  save(
    hs_product_names,
    file = paste0(product_dir_tidy, sprintf("hs-rev%s-product-names.RData", year[i])),
    compress = "xz"
  )
}

## SITC

sitc <- fromJSON("http://atlas.media.mit.edu/attr/sitc/")

sitc <- as_tibble(sitc[[1]]) %>%
  select(name, id, color)

sitc_groups <- sitc %>%
  select(name, id) %>%
  filter(nchar(id) == 2) %>%
  distinct() %>%
  rename(group_name = name, group_id = id)

sitc_product_names <- sitc %>%
  filter(nchar(id) >= 6) %>%
  mutate(group_id = substr(id, 1, 2)) %>%
  mutate(id = substr(id, 3, nchar(id))) %>%
  rename(product_name = name) %>%
  left_join(sitc_groups) %>%
  mutate(
    product_name = iconv(product_name, from = "", to = "ASCII", sub = "byte"),
    group_name = iconv(group_name, from = "", to = "ASCII", sub = "byte")
  ) %>%
  select(product_name, id, group_name, group_id, color)

save(
  sitc_product_names,
  file = paste0(product_dir_tidy, "sitc-rev2-product-names.RData"),
  compress = "xz"
)
