function convert_image_files_to_weights(bus1, bus2)

    # create dictionary with rbg rgb_values
    rgb_values = Dict{String, Any}()
    boundaries = Dict{String, Any}()
    nodes_lp = Dict{String, Any}()
    plot_dictionary = Dict{String, Any}()

    #To Do add rnage based on input location   
    img_ag = Images.load("src/spatial_image_files/clc_agricultural.tif")
    img_overlay = zeros(size(img_ag))
    rgb_values, img_overlay = convert2integer(img_ag, rgb_values, "agricultural", 1, img_overlay)
    img_sea = Images.load("src/spatial_image_files/sea.tif")
    rgb_values, img_overlay = convert2integer(img_sea, rgb_values, "sea", 2, img_overlay)
    img_grid = Images.load("src/spatial_image_files/grid_225kv_400kv.tif")
    rgb_values, img_overlay = convert2integer(img_grid, rgb_values, "grid", 3, img_overlay)
    img_roads = Images.load("src/spatial_image_files/roads.tif")
    rgb_values, img_overlay = convert2integer(img_roads, rgb_values, "roads", 3, img_overlay)
    img_railroads = Images.load("src/spatial_image_files/railroads.tif")
    rgb_values, img_overlay = convert2integer(img_railroads, rgb_values, "railroads", 3, img_overlay)
    img_nature = Images.load("src/spatial_image_files/clc_natural.tif")
    rgb_values, img_overlay = convert2integer(img_nature, rgb_values, "nature", 4, img_overlay)
    img_mountains = Images.load("src/spatial_image_files/clc_mountains.tif")
    rgb_values, img_overlay = convert2integer(img_mountains, rgb_values, "mountain", 5, img_overlay)
    img_urban = Images.load("src/spatial_image_files/clc_urban.tif")
    rgb_values, img_overlay = convert2integer(img_urban, rgb_values, "urban", 6, img_overlay)
    img_natura2000 = Images.load("src/spatial_image_files/Natura2000.tif")
    rgb_values, img_overlay = convert2integer(img_natura2000, rgb_values, "Natura2000", 7, img_overlay)


    X1,Y1 = convert_latlon_to_etrs89(bus1["longitude"], bus1["latitude"])
    X2,Y2 = convert_latlon_to_etrs89(bus2["longitude"], bus2["latitude"])
    
    # http://www.eea.europa.eu/data-and-maps/data/corine-land-cover-2006-raster-2
    x0=1500000;
    xmax=7400000;
    y0=900000;
    ymax=5500000;
    resolution=2500;

    # Calculate the positions pof the nodes 
    xpos=round.([(X1-x0),(X2-x0)] / resolution)
    ypos=round.([(ymax-Y1),(ymax-Y2)] / resolution)

    # Determine range: Euclidian distance +/- 30%
    d = round(0.3 * sqrt((xpos[1] - xpos[1])^2 + (ypos[1] - ypos[2])^2))
    x_min = min(xpos[1], xpos[2]) - d
    x_max = max(xpos[1], xpos[2]) + d
    y_min = min(ypos[1], ypos[2]) - d
    y_max = max(ypos[1], ypos[2]) + d
   
    boundaries["xmin"] = x_min
    boundaries["xmax"] = x_max
    boundaries["ymin"] = y_min
    boundaries["ymax"] = y_max

    xpos_plot=round.([(X1-x0); (X2-x0)]/resolution .- x_max) #range(1,1);
    ypos_plot=round.([(ymax-Y1); (ymax-Y2)]/resolution .- y_min) #- range(2,1);

    nodes_lp["x1"] = xpos[1]
    nodes_lp["x2"] = xpos[2]
    nodes_lp["y1"] = ypos[1]
    nodes_lp["y2"] = ypos[2]    

    plot_dictionary["overlay_image"] = img_overlay
    plot_dictionary["x_position"] = xpos
    plot_dictionary["y_position"] = ypos

    return rgb_values, nodes_lp, boundaries, plot_dictionary
end


function convert2integer(image, rgb_values, imagename, factor, img_overlay)
    rw = Images.rawview(Images.channelview(image))
    bitarray = (rw  .!==  0x00000000)
    rgb_values[imagename] = ones(size(bitarray)) .* bitarray
    img = findall(x->x==1, rgb_values[imagename])

    for idx = 1:length(img)
        img_overlay[img[idx]] = max(factor,  img_overlay[img[idx]])
    end

    return rgb_values, img_overlay 
end


function convert_latlon_to_etrs89(longitude, latitude)

    # Coordinate transformation based on IOGP Geomatics
    # Guidance Note Number 7, part 2
    # Coordinate Conversions and Transformations including Formulas
    # Section 3.4.2 Lambert Azimuthal Equal Area (EPSG Dataset coordinate operation method code 9820)
    # https://www.iogp.org/bookstore/product/coordinate-conversions-and-transformation-including-formulas/

    # fixed parameters
    a = 6378137.0
    e = 0.081819191
    phi0 = 0.907571211 # rad = 52 degree North
    lambda0 = 0.174532925 # rad = 10 degree East
    FE = 4321000 # False easting in m
    FN = 3210000 # False nortinh in m

    phi = latitude * pi / 180
    lambda = longitude * pi / 180

    q = (1 - e^2) * ((sin(phi) / (1 - e^2 * sin(phi)^2)) - ((1 / (2 * e)) * log((1 - e * sin(phi)) / (1 + e * sin(phi)))))
    q0 = (1 - e^2) * ((sin(phi0) / (1 - e^2 * sin(phi0)^2)) - ((1 / (2 * e)) * log((1 - e * sin(phi0)) / (1 + e * sin(phi0)))))
    qp = (1 - e^2) * ((1 / (1 - e^2)) - ((1 / (2 * e) * log((1 - e) / (1 + e)))))

    Rq = a * (qp / 2)^0.5
    beta = asin(q / qp)
    beta0 = asin(q0 / qp)

    B = Rq * (2 / (1+ sin(beta0) * sin(beta) + (cos(beta0) * cos(beta) * cos(lambda - lambda0))))^0.5
    D = a * (cos(phi0) / (1 - e^2 * sin(phi0)^2)^0.5) / (Rq * cos(beta0))

    E = FE + (B*D) * (cos(beta) * sin(lambda - lambda0))
    N = FN + (B/D) * (cos(beta0) * sin(beta) - (sin(beta0) * cos(beta) * cos(lambda - lambda0)))
    return E, N
end