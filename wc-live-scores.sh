#!/bin/bash

API_TOKEN="GetYourApiTokenFrom:https://www.football-data.org/client/register"
BASE_URL="https://api.football-data.org/v4"
MATCHES_URL="$BASE_URL/matches"
CHECK_INTERVAL=60 

if ! command -v jq &> /dev/null || ! command -v notify-send &> /dev/null; then
    echo "Error: jq and notify-send utilities are required."
    exit 1
fi

echo "Monitoring global matches via football-data.org..."

while true; do
    # Fetch today's global matches list
    MAIN_JSON=$(curl -s -H "X-Auth-Token: $API_TOKEN" "$MATCHES_URL")

    # Safeguard against API errors or bad tokens
    if ! echo "$MAIN_JSON" | jq -e '.matches' &> /dev/null; then
        echo "API Connection Error. Retrying in ${CHECK_INTERVAL}s..."
        sleep "$CHECK_INTERVAL"
        continue
    fi

    # Parse primary match properties: Status, Home/Away Teams, Scores, UTC Date, and unique Match ID
    echo "$MAIN_JSON" | jq -r '.matches[] | "\(.status)\t\(.homeTeam.name)\t\(.awayTeam.name)\t\(.score.fullTime.home)\t\(.score.fullTime.away)\t\(.utcDate)\t\(.id)"' | while IFS=$'\t' read -r status home away h_score a_score date match_id; do
        
        [ "$h_score" = "null" ] && h_score=0
        [ "$a_score" = "null" ] && a_score=0

        if [ "$status" = "IN_PLAY" ] || [ "$status" = "PAUSED" ]; then
            DETAIL_JSON=$(curl -s -H "X-Auth-Token: $API_TOKEN" "$BASE_URL/matches/$match_id")
            
            live_minute=$(echo "$DETAIL_JSON" | jq -r '.minute // "Live"')
            [ "$status" = "PAUSED" ] && live_minute="HT"
            
            scorers=$(echo "$DETAIL_JSON" | jq -r --arg h_sc "$h_score" --arg a_sc "$a_score" '
                if .goals and (.goals | length > 0) then
                    [.goals[] | "\(.scorer.name) (\(.minute)’)"] | join(", ")
                elif ($h_sc != "0" or $a_sc != "0") then
                    "Match active (Scorers unavailable on basic tier)"
                else
                    "No goals recorded yet"
                end
            ')

            title="🔴 MATCH LIVE ($live_minute')"
            msg="<b>$home $h_score — $a_score $away</b>\n⚽ $scorers"
            
            notify-send -u critical -t 60000 --hint=int:transient:0 -i "soccer" "$title" "$msg"

        elif [ "$status" = "TIMED" ]; then
            # Handle scheduled upcoming fixtures
            title="📅 UPCOMING FIXTURE"
            local_time=$(date -d "$date" +"%A, %I:%M %p" 2>/dev/null || echo "$date")
            msg="<b>$home vs $away</b>\nKickoff: $local_time"
            
            notify-send -u normal -t 60000 --hint=int:transient:0 -i "appointment-soon" "$title" "$msg"
        fi
    done

    sleep "$CHECK_INTERVAL"
done


