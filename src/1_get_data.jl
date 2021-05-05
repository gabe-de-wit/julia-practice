using Pipe
using HTTP
using CSV


save_dataset_as_csv = function(url::String, path::String)
    if isfile(path) return end
    
    @pipe url |>
        HTTP.request("GET", _) |>
        CSV.File(_.body) |>
        CSV.write(path, _)
end


if isdir("data") return else mkdir("data") end


save_dataset_as_csv(
    "https://data.london.gov.uk/download/mps-homicide-dashboard-data/0b246f3b-d421-4ccc-9602-4f749258f5d7/Homicide%20victims.csv",
    "data/homicide_victims.csv"
)

save_dataset_as_csv(
    "https://data.london.gov.uk/download/mps-homicide-dashboard-data/ac430d66-21ef-44f2-ada2-619f705ef8a1/Homicide%20ppa.csv",
    "data/homicide_ppa.csv"
)

save_dataset_as_csv(
    "https://data.london.gov.uk/download/land-area-and-population-density-ward-and-borough/77e9257d-ad9d-47aa-aeed-59a00741f301/housing-density-borough.csv",
    "data/borough_population.csv"
)