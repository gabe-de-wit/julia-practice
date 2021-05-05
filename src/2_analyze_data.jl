using Pipe
using DataFrames
using CSV
using Dates

## ----------------- Import

# Three datasets
#   One on victims
#   One on 'ppa' (people proceeded against)
#   One containing yearly borough level population and density figures

victims_import = DataFrame(CSV.File("data/homicide_victims.csv"))
ppa_import = DataFrame(CSV.File("data/homicide_ppa.csv"))

## ----------------- Wrangle

clean_names = x -> @pipe x |>
    lowercase(_) |>
    replace(_, " " => "_") |>
    replace(_, "/" => "_or_")

victims = @pipe victims_import |>
    rename(clean_names, _) |>
    transform(_,
        :recorded_date => (x -> Date.(x, "u Y")) => :recorded_date,
        :sex =>               (x -> replace.(x, "Unrecorded" => missing))             => :sex,
        :method_of_killing => (x -> replace.(x, "Not known/Not Recorded" => missing)) => :method_of_killing
    )

ppa = @pipe ppa_import |>
    rename(clean_names, _) |>
    transform(
        _,
        :proceedings_date => (x -> Date.(replace.(x, "Febraury" => "February"), "U Y")) => :proceedings_date # 'February' was misspelled on one line
    )

## ----------------- Miscellaneous Exploratory Summary Tables

# The majority of women who are murdered have domestic violence indicated in their murder; the rate is lower for men.
# This dataset of victims doesn't have any indicators of other sociocultural factors (e.g. organized crime) implicated in homicides.
domestic_abuse_gender_split = @pipe victims |>
    subset(_, :homicide_offence_type => x -> x .== "Murder") |>
    groupby(_, [:sex, :domestic_abuse]) |>
    combine(_, :count_of_victims => sum => :n_murder_victims) |>
    groupby(_, :sex) |>
    transform(_, :n_murder_victims => (a -> a ./ sum(a)) => :pct_murder_victims)

method_gender_split = @pipe victims |>
    groupby(_, [:sex, :method_of_killing]) |>
    combine(_, :count_of_victims => sum => :n_victims) |>
    groupby(_, :sex) |>
    transform(_, :n_victims => (a -> a ./ sum(a)) => :pct_victims)