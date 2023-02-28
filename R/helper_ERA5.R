tidy_ERA5 <- function(img) {
    bands_m = c(
        "total_precipitation_hourly",  # m
        "runoff_hourly",               # m
        "total_evaporation_hourly", "potential_evaporation_hourly",
        "evaporation_from_bare_soil_hourly", "evaporation_from_open_water_surfaces_excluding_oceans_hourly",
        "evaporation_from_the_top_of_canopy_hourly", "evaporation_from_vegetation_transpiration_hourly");
    bands_perc = c(
        # soil volume, 0-7, 7-28, 28-100, 100-289 cm
        "volumetric_soil_water_layer_1", "volumetric_soil_water_layer_2", #m3/m3
        "volumetric_soil_water_layer_3", "volumetric_soil_water_layer_4");

    Tair = img$select('temperature_2m')$rename('T')$subtract(273.15);
    Tdew = img$select('dewpoint_temperature_2m')$rename('Tdew')$subtract(273.15);
    Pa = img$select('surface_pressure')$rename('Pa')$divide(1000); #Pa to kPa
    U10 = img$select(c("u_component_of_wind_10m", "v_component_of_wind_10m"),
                     c('u', 'v'))$
        expression("sqrt(b('u')*b('u') + b('v')*b('v'))");
    U2 = U10$expression("b()*4.87/log(67.8*10-5.42)")$rename("U2")

    # q = ee$Image(pkg_ET$Tdew2q(Tdew, Pa))$rename('q'); # kg/kg
    Rn = img$select(c(
        'surface_net_solar_radiation_hourly', # note = Rns not Rn,
        'surface_net_thermal_radiation_hourly', 
        'surface_solar_radiation_downwards_hourly',
        'surface_thermal_radiation_downwards_hourly'),
        c('Rns', 'Rnl', 'Rs', 'Rl'))$divide(3600); # J m-2 h-1 to W m-2

    img_mm = img$select(bands_m)$multiply(1000 * 24)$ # m/h -> mm/d, hourly to daily
        rename(c('Prcp', 'R', 'ET', 'PET', 'Es', 'ET_water', 'Ei', 'Ec'));
    img_perc = img$select(bands_perc, c('S_l1', 'S_l2', 'S_l3', 'S_l4'));

    time_start = ee$Date(img$get('system:time_start'));
    ans = ee$Image(c(Tair, Tdew, Pa, U2, Rn, img_mm, img_perc))$
        copyProperties(img, img$propertyNames())$
        set('date', time_start$format('yyyy-MM-dd'));
    ee$Image(ans)
}

tidy_ERA5_Rn <- function(img) {
  img_Rn = img$select(c(
    'surface_net_solar_radiation_hourly', # note = Rns not Rn,
    'surface_net_thermal_radiation_hourly', 
    'surface_solar_radiation_downwards_hourly',
    'surface_thermal_radiation_downwards_hourly'),
    c('Rns', 'Rnl', 'Rs', 'Rl'))$divide(3600); # J m-2 h-1 to W m-2
  
  time_start = ee$Date(img$get('system:time_start'));
  ans = img_Rn$
    copyProperties(img, img$propertyNames())$
    set('date', time_start$format('yyyy-MM-dd'));
  ee$Image(ans)
}

aggregate_daily <- function(date_begin, col, bands) {
    date_begin = ee$Date(date_begin)
    date_end = date_begin$advance(1, "day")
    imgcol = col$filterDate(date_begin, date_end) # 不包含最后一个日期

    ind = which(bands != "T") - 1
    img_first = imgcol$first() #%>% ee_properties()
    img = imgcol$select(ind)$mean()
    
    if ("T" %in% bands) {
        img_Tair = aggregate_process(imgcol$select(c("T")), c(0, 0, 0), c("max", "min", "mean"))$
            rename(c("Tmax", "Tmin", "Tavg"))
        img = img$addBands(img_Tair)
    }
    img = ee$Image(img$copyProperties(img_first, img_first$propertyNames()))
    img
}

aggregate_ERA5_daily <- aggregate_daily
