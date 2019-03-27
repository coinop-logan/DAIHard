module Images exposing (Image, daiSymbol, downArrow, image, marginSymbol, none, qmarkCircle, toElement, upArrow)

import Element exposing (Attribute, Element)


type Image
    = None
    | Just
        { src : String
        , description : String
        }


toElement : List (Attribute msg) -> Image -> Element msg
toElement attributes image_ =
    case image_ of
        None ->
            Element.none

        Just img ->
            Element.image attributes img


none =
    None


image =
    Just


marginSymbol : Bool -> Bool -> Image
marginSymbol isUp isGreen =
    Just
        { src =
            case ( isUp, isGreen ) of
                ( True, True ) ->
                    "static/img/margin-up-green.svg"

                ( True, False ) ->
                    "static/img/margin-up-red.svg"

                ( False, True ) ->
                    "static/img/margin-down-green.svg"

                ( False, False ) ->
                    "static/img/margin-down-red.svg"
        , description = ""
        }


daiSymbol : Image
daiSymbol =
    Just
        { src = "static/img/dai-symbol.png"
        , description = "DAI"
        }


downArrow : Image
downArrow =
    Just
        { src = "static/img/arrow-down.svg"
        , description = "down"
        }


upArrow : Image
upArrow =
    Just
        { src = "static/img/arrow-up.svg"
        , description = "up"
        }


qmarkCircle : Image
qmarkCircle =
    Just
        { src = "static/img/qmark-circle.svg"
        , description = ""
        }
