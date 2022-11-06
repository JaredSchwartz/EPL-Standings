# EPL-Standings

## Original Project
This was a project given as a part of my R class as a practice in dplyr. The goal was to take two inputs: a season, and a date, to calculate team standings in the English Premier League for the entered season as-of the entered dateusing publically available at [https://www.football-data.co.uk/englandm.php](https://www.football-data.co.uk/englandm.php).

The assignment offered a specific set of output columns to calculate. The challengieng piece was reshaping and organizing the data to make summary calculations possible. In the data source, the data is formatted by match with columns for the home team, away team, home goals, and away goals, as well as displaying the winner of the match, rather than assigining at the team-level. This nescessitated a couple of pivot_longer operations and a filter to match the correct rows together. The result was a much more workable dataset that needed a couple additions, but was then readyf or the summary statistics.

## Now in Julia
I learned about Julia a year or so ago, and was intrigued, but I never had occaision to actually give it a go. I had some additional time recently and decided to try and acomplish the task as the R script, but in Julia.

I know that Julia's multiple dispatch allow for both object-oriented patterns as well as more functional patterns. Personally, I feel hindered by OOP patterns. I much prefer R and dplyr to things like Python Pandas and the like. Thus, my goal for working with the Julia DataFrames package was to make as much use as I could out of the functions provided in the package. This, along with the Pipes.jl library and some keyboard shortcut rearrangement in VSCode allowed for a remarkably dplyr-like experience.

