function convert_image_files_to_weights()

    # create dictionary with rbg rgb_values
    rgb_values = Dict{String, Any}()

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
    rgb_values, img_overlay = convert2integer(img_mountains, rgb_values, "mountains", 5, img_overlay)
    img_urban = Images.load("src/spatial_image_files/clc_urban.tif")
    rgb_values, img_overlay = convert2integer(img_urban, rgb_values, "urban", 6, img_overlay)
    img_natura2000 = Images.load("src/spatial_image_files/Natura2000.tif")
    rgb_values, img_overlay = convert2integer(img_natura2000, rgb_values, "Natura2000", 7, img_overlay)



    x,y = lonlat_to_webmercator(41.923587777533555, 12.996460091734507)
    

    x0=1500000;
    xmax=7400000;
    y0=900000;
    ymax=5500000;
    resolution=2500;

    id = "03es_11es"	
    #X1 = 3178050 
    #Y1 = 2154895
    X2 = 3355847
    Y2 = 1860692

    X1 = round(x) + x0
    Y1 = round(y) + y0
    


    xpos=[(X1-x0),(X2-x0)] / resolution
    ypos=[(ymax-Y1),(ymax-Y2)] / resolution

    xpos_plot=round.([(X1-x0); (X2-x0)]/resolution .- xmax) #range(1,1);
    ypos_plot=round.([(ymax-Y1); (ymax-Y2)]/resolution .- y0) #- range(2,1);

    nodes_lp=[round.(xpos), round.(ypos)]
    boundaries=[1 size(img_overlay,2); 1 size(img_overlay,1)]

    plot_dictionary = Dict{String, Any}()
    plot_dictionary["overlay_image"] = img_overlay
    plot_dictionary["x_position"] = xpos_plot
    plot_dictionary["y_position"] = ypos_plot

    return rgb_values, nodes_lp, id, boundaries, plot_dictionary
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


function lonlat_to_webmercator(xLon, yLat)

    # Check coordinates are in range
    abs(xLon) <= 180 || throw("Maximum longitude is 180.")
    abs(yLat) < 85.051129 || throw("Web Mercator maximum lattitude is 85.051129. This is the lattitude at which the full map becomes a square.")

    # Ellipsoid semi-major axis for WGS84 (metres)
    # This is the equatorial radius - the Polar radius is 6356752.0
    a = 6378137.0

    # Convert to radians
    λ = xLon * 0.017453292519943295    # λ = xLon * π / 180
    ϕ = yLat * 0.017453292519943295    # ϕ = yLat * π / 180

    # Convert to Web Mercator
    # Note that:
    # atanh(sin(ϕ)) = log(tan(π/4 + ϕ/2)) = 1/2 * log((1 + sin(ϕ)) / (1 - sin(ϕ)))
    x = a * λ
    y = a * atanh(sin(ϕ))

    return x, y
end


function webmercator_to_lonlat(x, y)
    a = 6378137.0
    xLon = x / (a * 0.017453292519943295)
    yLat = asin(tanh(y / a)) / 0.017453292519943295
    return xLon, yLat
end