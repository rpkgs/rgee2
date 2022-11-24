n <- 100
lon <- seq(1, 180, length.out = n)
lat <- seq(1, 90, length.out = n)

df <- data.frame(I = 1:n, i = 1:n, lon, lat)
df2sf(df)
