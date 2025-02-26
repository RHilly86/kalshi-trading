using DataFrames
using CairoMakie
using AlgebraOfGraphics
include("kalshi_api.jl")

ruben_gallego_trades = get_trades("KXVOTECHAVEZDEREMER-26-MKEL", 1000, true)
susan_collins_trades = get_trades("KXVOTEPATEL-26-SC", 1000, true)

yes_spec = 
    data(ruben_gallego_trades) *
    mapping(:created_time, :yes_price) *
    visual(Lines)

no_spec = 
    data(ruben_gallego_trades) *
    mapping(:created_time, :no_price) *
    visual(Lines)

susan_collins_yes = 
    data(susan_collins_trades) *
    mapping(:created_time, :yes_price) *
    visual(Lines)

draw(spec)
draw(no_spec)
draw(susan_collins_yes)