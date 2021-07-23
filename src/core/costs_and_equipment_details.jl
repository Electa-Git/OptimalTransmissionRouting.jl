function calculate_costs_and_losses(input_data; equipment = "ohl")
    equipment_ = join([input_data["technology"],"_",equipment])
    if equipment_ == "ac_ohl"
        costs, equipment_details = ac_ohl_costs_and_losses(input_data)
    elseif equipment_ == "ac_ugc"
        costs, equipment_details = ac_ugc_costs_and_losses(input_data)
    elseif equipment_ == "dc_ohl"
        costs, equipment_details = dc_ohl_costs_and_losses(input_data)
    elseif equipment_ == "dc_ugc"
        costs, equipment_details = dc_ugc_costs_and_losses(input_data)
    end

    return costs, equipment_details
end

function ac_ohl_costs_and_losses(input_data)
    w = 2*pi*50 # frequency
    minimum_distance = sqrt((input_data["start_node"]["x"]-input_data["end_node"]["x"])^2 + (input_data["start_node"]["y"]-input_data["start_node"]["y"])^2)
    Avecorg=[16 25 50 70 95 120 150 170 185 210 230 240 265 300 340 380 435 450 490 550 560 680]
    A = Avecorg[end] # Start with highest cross-section
    C = -0.00003705 * input_data["voltages"]["ac_ohl"]^2 + 0.03257649 * input_data["voltages"]["ac_ohl"] + 5.965161265 # estimate capacitance in nF
    Imax = -0.00170712*A.^2 + 2.64505501*A + 97.70512024 # estimate maximum current
    Ic = w * (C*1e-9) * minimum_distance * (input_data["voltages"]["ac_ohl"] * 1e3) /sqrt(3) # Calculate capacitive current
    I = input_data["power_rating"] * 1e6 / (sqrt(3) * input_data["voltages"]["ac_ohl"] * 1e3) # Calculate transmission current
    n = ceil(I/(2*sqrt(Imax^2-(Ic/2)^2))) # Calculate minimum number of circuits
    nb = ceil(I/(n*sqrt(Imax^2-(Ic/2)^2))) # Calculate minumm number of bundles
    Imax1 = sqrt((I/(n*nb))^2+(Ic/2).^2) # Calculate actual current per conductor
    K1 = -0.00170712
    K2 = 2.64505501
    K3 = 97.70512024 - Imax1;
    A_new = min(679, real((1 / (2*K1) * (-K2 + sqrt(K2^2 - 4 * K1 * K3)))))
    Avec = Avecorg
    Aindex = A_new .< Avec
    if all(Aindex==0)
        A = Avecorg[end]
    else
        A = Avec[length(Avec) - sum(Aindex) + 1]
    end

    costs = Dict{String, Any}()
    costs["investment"] = n * ((60+0.4 * input_data["voltages"]["ac_ohl"] + 0.4 * A * nb^(1/4)) * 1e3)
    costs["installation"] = n * (500*1e3) * sqrt(input_data["voltages"]["ac_ohl"] / 400)
    equipment_details = Dict{String,Any}()
    equipment_details["cross_section"] = A
    equipment_details["circuits"] = n
    equipment_details["bundles"] = nb
    return costs, equipment_details
end

function ac_ugc_costs_and_losses(input_data)
    w = 2*pi*50 # frequency
    minimum_distance = 30;
    Avecorg_offshore = [70 95 120 150 185 240 300 400 500 630 800 1000 1200 1400]
    A_offshore = Avecorg_offshore[end]
    C_offshore = (-1.21*1e-7 * A_offshore^2 + 0.000286276 * A_offshore + 0.08212371) * 1.762251064 * input_data["voltages"]["ac_ugc"]^(-0.45531498) / 0.17
    Imax_offshore = -5.7698e-4 * A_offshore^2 + 1.1793 * A_offshore + 212.33
    Ic_max_offshore = sqrt(2) * Imax_offshore / 2
    maximum_distance = Ic_max_offshore / (w * (C_offshore * 1e-6) * (input_data["voltages"]["ac_ugc"] * 1e3 )/ sqrt(3))
    Ic_offshore = w * (C_offshore * 1e-6) * minimum_distance * (input_data["voltages"]["ac_ugc"] * 1e3) / sqrt(3)
    I_offshore = input_data["power_rating"] * 1e6 /(sqrt(3) * input_data["voltages"]["ac_ugc"] * 1e3)
    n_c_offshore = ceil(I_offshore / (sqrt(Imax_offshore^2-(Ic_offshore/2)^2)))
    Imax1_offshore = sqrt((I_offshore/n_c_offshore)^2+(Ic_offshore/2).^2)
    K1=5.7698e-4
    K2=1.1793;
    K3=212.33-Imax1_offshore;
    Anew_offshore = min(999,real((1/(2*K1).*(-K2+sqrt(K2.^2-4*K1.*K3)))))
    Avec_offshore = Avecorg_offshore
    Aindex = Anew_offshore .< Avec_offshore
    if all(Aindex==0)
        A_offshore = Avecorg_offshore[end]
    else
        A_offshore = Avec_offshore[length(Avec_offshore)-sum(Aindex)+1]
    end
    Q_offshore = sqrt(3) * Ic_offshore * input_data["voltages"]["ac_ugc"] / 1e3
    K1=5.8038;
    K2=0.044525;
    K3=0.0072;

    costs = Dict{String, Any}()
    
    costs["offshore"] = Dict{String, Any}()
    costs["offshore"]["investment"] = 1.3e6 * n_c_offshore * (K1+K2*exp(K3*(sqrt(3) * input_data["voltages"]["ac_ugc"] * Imax1_offshore)/1e6))/8.98+ n_c_offshore * Q_offshore *7e6 /(130*minimum_distance)
    costs["offshore"]["installation"] = 7e5 * (input_data["voltages"]["ac_ugc"]/400)^(1/2)*(n_c_offshore)^0.9

    equipment_details = Dict{String, Any}()
    equipment_details["offshore"] = Dict{String, Any}()
    equipment_details["offshore"]["cross_section"] = A_offshore
    equipment_details["offshore"]["circuits"] = n_c_offshore
    equipment_details["offshore"]["maximum_distance"] = maximum_distance
    equipment_details["offshore"]["circuits"] = n_c_offshore

    ## ONSHORE CABLES 
    Avecorg = [300 400 500 630 800 1000 1200 1400 1600 2000 2500]
    A = Avecorg[end]
    C = 0.2
    Imax = 26.938 * A^(0.521);
    Ic= w * (C * 1e-6)*minimum_distance * (input_data["voltages"]["ac_ugc"] * 1e3) / sqrt(3)
    I = input_data["power_rating"] * 1e6 / (sqrt(3) * input_data["voltages"]["ac_ugc"] * 1e3)
    n_c = ceil(I / (sqrt(Imax^2 - (Ic/2)^2)))
    Imax1 = sqrt((I / n_c)^2 + (Ic/2).^2)
    Anew = (Imax1 / 26.938)^(1/0.521)
    Avec = Avecorg
    Aindex = Anew .< Avec
    if all(Aindex == 0)
        A = Avecorg[end]
    else
        A = Avec[length(Avec)-sum(Aindex)+1]
    end
    Q = sqrt(3) * Ic * input_data["voltages"]["ac_ugc"] / 1e3

    costs["onshore"] = Dict{String, Any}()
    costs["onshore"]["investment"] = 1e6 * ((input_data["voltages"]["ac_ugc"] / 400)^2+ 0.25 * A/2000)*n_c + n_c * Q * 3e6 /(130*minimum_distance) + 0.25e6*(input_data["voltages"]["ac_ugc"]/400)
    costs["onshore"]["installation"] = 1e6 * (input_data["voltages"]["ac_ugc"] / 400)^(1/2)*(n_c)^0.9
    costs["onshore"]["transition"] = 3 * n_c * 1e6 * (input_data["voltages"]["ac_ugc"]/400)^(1/2)

    equipment_details["onshore"] = Dict{String, Any}()
    equipment_details["onshore"]["cross_section"] = A
    equipment_details["onshore"]["circuits"] = n_c

    return costs, equipment_details
end


function dc_ohl_costs_and_losses(input_data)
    Avecorg = [16 25 50 70 95 120 150 170 185 210 230 240 265 300 340 380 435 450 490 550 560 680]
    A = maximum(Avecorg)
    Imax=(-0.00170712*A^2 + 2.64505501 * A +97.70512024) * 1.2
    I =  input_data["power_rating"] * 1e6 / (2 * input_data["voltages"]["dc_ohl"] * 1e3)
    n = ceil(I/(2*Imax))
    nb = ceil(I/(n*Imax))
    Imax1 = I / (n * nb)
    K1 = -0.00170712 * 1.2
    K2 = 2.64505501 * 1.2
    K3 = 97.70512024 * 1.2 - Imax1
    Anew = min(679, real((1/ (2 * K1) * (-K2 + sqrt(K2^2-4 * K1 * K3)))))
    Avec = Avecorg;
    Aindex = Anew .< Avec
    if all(Aindex == 0)
        A = Avecorg[end]
    else
        A = Avec[length(Avec)-sum(Aindex) + 1]
    end

    costs = Dict{String, Any}()
    costs["investment"] = n * (60+0.4 * input_data["voltages"]["dc_ohl"] + 0.4 * A * nb^(1/4)) * 1e3 * 2/3
    costs["installation"] = n * 2/3 * (500*1e3) * sqrt(input_data["voltages"]["dc_ohl"] / 320)
    costs["converter"] = (input_data["power_rating"] /1000) * (0.8 + 0.2 * sqrt(input_data["voltages"]["dc_ohl"]/320)) * 100e6
    equipment_details = Dict{String,Any}()
    equipment_details["cross_section"] = A
    equipment_details["circuits"] = n
    equipment_details["bundles"] = nb
    return costs, equipment_details
end


function dc_ugc_costs_and_losses(input_data)
    Avecorg = [95 120 150 185 240 300 400 500 630 800 1000 1200 1400 1600 1800 2000 2200 2400 2600 2800 3000]
    A = maximum(Avecorg)
    Imax = 25.22218157 * A^(0.57255569)
    I = input_data["power_rating"] * 1e6/(2*input_data["voltages"]["dc_ugc"] *1e3)
    n = ceil(I/Imax)
    Imax1 = I /n
    Anew = (Imax1/25.22218157)^(1/0.57255569)
    Avec = Avecorg
    Aindex = Anew .< Avec
    if all(Aindex == 0)
        A = 3000
    else
        A = Avec[length(Avec)-sum(Aindex)+1]
    end
    
    costs = Dict{String, Any}()
    costs["offshore"] = Dict{String, Any}()
    costs["onshore"] = Dict{String, Any}()

    costs["onshore"]["converter"] = (input_data["power_rating"] /1000) * (0.8 + 0.2 * sqrt(input_data["voltages"]["dc_ugc"] / 320)) * 100e6
    costs["onshore"]["investment"] = n * ((0.0022 * input_data["voltages"]["dc_ugc"] -0.4338) * 1e6 + (0.4906 * input_data["voltages"]["dc_ugc"]^(-0.652)) * input_data["voltages"]["dc_ugc"] * Imax1 * 1e3)/8.94448
    costs["onshore"]["installation"] = n^0.9 * 700000 * (input_data["voltages"]["dc_ugc"]/320)^(1/2)
    costs["onshore"]["transition"] = 2 * n * 1e6 * (input_data["voltages"]["dc_ugc"]/320)^(1/2)

    costs["offshore"]["converter"] = (input_data["power_rating"] /1000) * (0.8 + 0.2 * sqrt(input_data["voltages"]["dc_ugc"]/320)) * 100e6
    costs["offshore"]["investment"] = n * ((0.0022 * input_data["voltages"]["dc_ugc"] - 0.4338) * 1e6 + (0.4906 * input_data["voltages"]["dc_ugc"]^(-0.652)) * input_data["voltages"]["dc_ugc"] * Imax1*1e3)/8.94448
    costs["offshore"]["installation"] = n^0.9 * 1e6 * (input_data["voltages"]["dc_ugc"]/320)^(1/2)
    
    equipment_details = Dict{String, Any}()
    equipment_details["onshore"] = Dict{String, Any}()
    equipment_details["onshore"]["cross_section"] = A
    equipment_details["onshore"]["circuits"] = n

    equipment_details["offshore"] = Dict{String, Any}()
    equipment_details["offshore"]["cross_section"] = A
    equipment_details["offshore"]["circuits"] = n
    equipment_details["offshore"]["maximum_distance"] = 5000 # dummy number
    return costs, equipment_details
end