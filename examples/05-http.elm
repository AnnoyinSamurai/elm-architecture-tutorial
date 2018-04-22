import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode

main : Program Never Model Msg
main =
    Html.program
        { init = init ""
        , view = view
        , update = update
        , subscriptions = subscriptions
    }



type alias Model =
    { topic : String
    , gifUrl: String
    }


init : String -> (Model, Cmd Msg)
init topic =
  ( Model topic ""
  , getRandomGif topic
  )

type Msg
    = GetMore
    | NewGif (Result Http.Error String)
    | Change String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
      GetMore ->
        (model, getRandomGif model.topic)
      NewGif (Ok newTopic) ->
        (Model model.topic newTopic, Cmd.none)
      NewGif (Err _) ->
        (model, Cmd.none)
      Change newTopic ->
        ({model | topic = newTopic}, getRandomGif newTopic)


view : Model -> Html Msg
view model =
    div [style [("padding","20px")]]
      [ h2 [] [text model.topic]
      , input [ placeholder "Gif this", onInput Change ] [text model.topic]
      , button [ onClick GetMore ] [ text "More Please!" ]
      , br [] []
      , br [] []
      , img [src model.gifUrl] []
      ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

getRandomGif : String -> Cmd Msg
getRandomGif topic =
  let
    url =
      "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic
  in
    Http.send NewGif (Http.get url decodeGifUrl)

decodeGifUrl : Decode.Decoder String
decodeGifUrl =
  Decode.at ["data", "image_url"] Decode.string