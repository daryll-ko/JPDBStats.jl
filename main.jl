using Dates

import JSON
import DataFrames as DF

include("./Cards.jl")

import .Cards: Card, Review, parse_cards

function convert_timestamp(timestamp)
    return Dates.format(unix2datetime(timestamp) + Hour(8), "U d, yyyy (HH:MM)")
end

function latest_timestamp(reviews)
    latest = 0
    for review in reviews
        latest = max(latest, review.timestamp)
    end
    return latest
end

function tabulate_data(cards)
    rows = [
        (
            word=card.spelling,
            review_frequency=length(card.reviews),
            latest_review=(convert_timestamp ∘ latest_timestamp)(card.reviews)
        ) for card in cards
    ]
    df = DF.DataFrame(rows)
    return df
end

function main()
    open("reviews.json", "r") do f
        df = read(f, String) |> JSON.parse |> (j -> j["cards_vocabulary_jp_en"]) |> parse_cards |> tabulate_data
        display(df[1:10, :])
    end
end

main()
