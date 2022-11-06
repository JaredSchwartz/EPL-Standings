# EPL Final Assignment MSBA-615-77 Jared Schwartz

# Load Necessary Libraries
library(tidyverse)
library(lubridate)

EPL_Standings <- function(date,season) {
  # Clean the inputs
  
    # Pull out the the last 5 characters in the user's Season input and remove the / for URL injection
    SeasonString <- str_replace(str_sub(season,-4,-1),"/","")
    
    # Date string input converted to Date object
    FilterDate <- mdy(date)
  
  # Download and read correct csv
  data <- read_csv(url(str_c("https://www.football-data.co.uk/mmz4281/",SeasonString,"/E0.csv")),show_col_types = F)
  
  # Generate dataframe
  Results <- data %>% 
    # Only keep useful columns
    select(Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR) %>% 
    # Clean date
    mutate(Date = dmy(Date)) %>% 
    # Introduce user-provided date filter
    filter(Date <= FilterDate) %>% 
    # Ensure Date order
    arrange(Date) %>% 
    # Add unique match identifier 
    mutate(MatchID = row_number()) %>% 
    # Reshape so team names are in the same column
    pivot_longer(cols = c(HomeTeam,AwayTeam), values_to = "TeamName", names_to = "HomeAway") %>%
    # Reshape so goals are in the same column. 
    rename("HomeTeam" = FTHG, "AwayTeam" = FTAG) %>%
    pivot_longer(cols = c(HomeTeam,AwayTeam), values_to = "MatchGS", names_to = "HomeAway2") %>% 
    # Filter the reshape so the result is effectively an inner join, not a cross join. 
    # This step matches away team with the away points and home team with home points.
    filter(HomeAway == HomeAway2) %>% 
    # Reduce home/away column, compare it to the FTR to get W/L/D, and assign points
    # Also add Outcome column for streak calculation at the end, subbing "T" for "D"
    mutate(
      HomeAway = substr(HomeAway,1,1),
      WinLoss = if_else(FTR == "D",FTR, if_else(HomeAway == FTR,"W","L")),
      MatchPoints = if_else(WinLoss == "W", 3, if_else(WinLoss == "D",1,0)),
      Outcome = if_else(WinLoss == "D", "T",WinLoss),
    ) %>% 
    # Reshape data so W/L/D are in their own columns (reduces code to calculate team's record at the end)
    pivot_wider(names_from = WinLoss, values_from = FTR, values_fn = n_distinct, values_fill = 0) %>% 
    # Calculate goals allowed by taking total match points minus the points the team scored
    group_by(MatchID) %>% 
    mutate(MatchGA = sum(MatchGS)-MatchGS) %>% 
    # Group by team for final summary
    group_by(TeamName) %>%
    # Calculate all the necessary fields + an extra wins column to sort output
    summarize(
      Record = str_c(sum(W),sum(L),sum(D),sep = "-"),
      HomeRec = str_c(sum(W[HomeAway == "H"]),sum(L[HomeAway == "H"]),sum(D[HomeAway == "H"]),sep = "-"),
      AwayRec = str_c(sum(W[HomeAway == "A"]),sum(L[HomeAway == "A"]),sum(D[HomeAway == "A"]),sep = "-"),
      MatchesPlayed = n(),
      Points = sum(MatchPoints),
      PPM = mean(MatchPoints),
      PtPct= Points/(3*MatchesPlayed),
      GS = sum(MatchGS),
      GSM = mean(MatchGS),
      GA = sum(MatchGA),
      GAM = mean(MatchGA),
      wins = sum(W)
    ) %>% 
    # sort output properly then remove extra wins column
    arrange(desc(PPM),desc(wins),desc(GSM),GAM) %>% 
    select(-wins)
  return(Results)
}
EPL_Standings("12/10/2020", "2020/21") 



