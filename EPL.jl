using CSV, DataFrames, Statistics, Dates
using Pipe: @pipe

function EPL(date,season)
    filterseason =  replace(last(season,5),"/" => "")
    filterdate = Date(date,dateformat"m/d/y")
    data = CSV.File(download("https://www.football-data.co.uk/mmz4281/$filterseason/E0.csv"), dateformat = "d/m/y") |> DataFrame

    CleanData = data[:,2:7]
    CleanData.MatchID = 1:nrow(CleanData)
    Step1 = @pipe CleanData |> 
        subset(_, :Date => ByRow(x -> x <= filterdate)) |> 
        stack(_,[:HomeTeam,:AwayTeam]) |> 
        rename(_, 
                :FTHG => :HomeTeam, 
                :FTAG => :AwayTeam, 
                :variable => :HomeAway, 
                :value => :TeamName
        ) |> 
        stack(_,[:HomeTeam,:AwayTeam]) |>   
        rename(_,
            :variable => :HomeAway2, 
            :value => :Goals
        ) |> 
        subset(_, [:HomeAway,:HomeAway2] => ByRow((x,y) -> x == y)) |> 
        transform(_, 
            [:FTR,:HomeAway]=> ByRow((x,y) -> if x == "D"; ("T",1) elseif x == first(y,1); ("W",3) else ("L",0) end) => [:WLD,:MatchPoints],
            :HomeAway => ByRow(y -> first(y,1)) => :HomeAway
        ) |> 
        groupby(_,:MatchID) |> 
        transform(_,
            :Goals => sum => :MatchGoals
        ) |> 
        transform(_, 
            [:Goals,:MatchGoals] => ((x,y) -> y - x) => :MatchGA,
            :MatchID => (x -> x=1) => :DummyColumn,
            :WLD => :WLD2
        ) |> 
        unstack(_, :WLD2,:DummyColumn,fill=0)

    Step2 = @pipe Step1 |> 
        groupby(_,[:TeamName,:HomeAway]) |> 
        combine(_,
            [:W,:L,:T] .=> sum .=> [:Wins,:Losses,:Ties]
        ) |> 
        transform(_, 
            [:Wins,:Losses,:Ties] => ByRow((x,y,z) -> string(x,"-",y,"-",z)) => :Record
        ) |> 
        select(_, [:TeamName,:HomeAway,:Record]) |> 
        unstack(_, :HomeAway,:Record)

    Final = @pipe Step1 |> 
        groupby(_,:TeamName) |> 
        combine(_,
            :MatchID => length => :MatchesPlayed,
            [:W,:L,:T,:MatchPoints,:Goals,:MatchGA] .=> sum .=> [:Wins,:Losses,:Ties,:Points,:GS,:GA],
            [:MatchPoints,:Goals,:MatchGA] .=> mean .=> [:PPM,:GSM,:GAM]
        ) |> 
        leftjoin(_, Step2, on= :TeamName) |> 
        select(_,
            [:Wins,:Losses,:Ties] => ByRow((x,y,z) -> string(x,"-",y,"-",z)) => :Record,
            :H => :HomeRec,
            :A => :AwayRec,
            :MatchesPlayed,
            :Points,
            :PPM,
            [:Points,:MatchesPlayed] => ByRow((x,y)-> x/(3*y)) => :PtPct,
            :GS,
            :GSM,
            :GA,
            :GAM
        )
    return(Final)
end
EPL("10/01/2018","2018/19")
