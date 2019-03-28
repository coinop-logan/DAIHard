module Search.Types exposing (FiatTypeAndRange, Model, Msg(..), ResultColumnType(..), SearchInputs, SearchQuery, TokenRange, inputsToQuery, updateFiatTypeInput, updateMaxDaiInput, updateMaxFiatInput, updateMinDaiInput, updateMinFiatInput, updatePaymentMethodInput, updatePaymentMethodTerms, updateTradeCreationInfo, updateTradeParameters, updateTradePaymentMethods, updateTradeState)

import Array exposing (Array)
import BigInt exposing (BigInt)
import CommonTypes exposing (..)
import Contracts.Generated.DAIHardFactory as DHF
import Contracts.Generated.DAIHardTrade as DHT
import Contracts.Types
import Eth.Sentry.Event as EventSentry exposing (EventSentry)
import Eth.Types exposing (Address)
import EthHelpers exposing (EthNode)
import FiatValue exposing (FiatValue)
import Http
import Json.Decode
import PaymentMethods exposing (PaymentMethod)
import String.Extra
import Time
import TokenValue exposing (TokenValue)


type alias Model =
    { ethNode : EthNode
    , eventSentry : EventSentry Msg
    , userInfo : Maybe UserInfo
    , numTrades : Maybe Int
    , openMode : Contracts.Types.OpenMode
    , inputs : SearchInputs
    , showCurrencyDropdown : Bool
    , query : SearchQuery
    , trades : Array Contracts.Types.Trade
    , filterFunc : Time.Posix -> Contracts.Types.FullTradeInfo -> Bool
    , sortFunc : Contracts.Types.FullTradeInfo -> Contracts.Types.FullTradeInfo -> Order
    }


type Msg
    = NumTradesFetched (Result Http.Error BigInt)
    | CreationInfoFetched Int (Result Http.Error DHF.CreatedTrade)
    | ParametersFetched Int (Result Http.Error (Result String Contracts.Types.TradeParameters))
    | StateFetched Int (Result Http.Error (Maybe Contracts.Types.State))
    | OpenedEventDataFetched Int (Result Json.Decode.Error DHT.Opened)
    | EventSentryMsg EventSentry.Msg
    | Refresh Time.Posix
    | MinDaiChanged String
    | MaxDaiChanged String
    | FiatTypeInputChanged String
    | FiatTypeArrowClicked
    | FiatTypeLostFocus
    | OpenCurrencySelector
    | MinFiatChanged String
    | MaxFiatChanged String
    | PaymentMethodInputChanged String
    | ShowCurrencyDropdown Bool
    | AddSearchTerm
    | RemoveTerm String
    | ApplyInputs
    | ResetSearch
    | TradeClicked Int
    | SortBy ResultColumnType Bool
    | NoOp


type alias SearchInputs =
    { minDai : String
    , maxDai : String
    , fiatType : String
    , minFiat : String
    , maxFiat : String
    , paymentMethod : String
    , paymentMethodTerms : List String
    }


updatePaymentMethodInput : String -> SearchInputs -> SearchInputs
updatePaymentMethodInput input inputs =
    { inputs | paymentMethod = input }


updateFiatTypeInput : String -> SearchInputs -> SearchInputs
updateFiatTypeInput input inputs =
    { inputs | fiatType = input }


updateMinDaiInput : String -> SearchInputs -> SearchInputs
updateMinDaiInput input inputs =
    { inputs | minDai = input }


updateMaxDaiInput : String -> SearchInputs -> SearchInputs
updateMaxDaiInput input inputs =
    { inputs | maxDai = input }


updateMinFiatInput : String -> SearchInputs -> SearchInputs
updateMinFiatInput input inputs =
    { inputs | minFiat = input }


updateMaxFiatInput : String -> SearchInputs -> SearchInputs
updateMaxFiatInput input inputs =
    { inputs | maxFiat = input }


updatePaymentMethodTerms : List String -> SearchInputs -> SearchInputs
updatePaymentMethodTerms terms inputs =
    { inputs | paymentMethodTerms = terms }


type alias SearchQuery =
    { dai : TokenRange
    , fiat : FiatTypeAndRange
    , paymentMethodTerms : List String
    }


inputsToQuery : SearchInputs -> SearchQuery
inputsToQuery inputs =
    { dai =
        { min = TokenValue.fromString 18 inputs.minDai
        , max = TokenValue.fromString 18 inputs.maxDai
        }
    , fiat =
        { type_ = String.Extra.nonEmpty inputs.fiatType
        , min = BigInt.fromString inputs.minFiat
        , max = BigInt.fromString inputs.maxFiat
        }
    , paymentMethodTerms =
        inputs.paymentMethodTerms
    }


type alias TokenRange =
    { min : Maybe TokenValue
    , max : Maybe TokenValue
    }


type alias FiatTypeAndRange =
    { type_ : Maybe String
    , min : Maybe BigInt
    , max : Maybe BigInt
    }


type ResultColumnType
    = Expiring
    | TradeAmount
    | Fiat
    | Margin
    | PaymentMethods
    | AutoabortWindow
    | AutoreleaseWindow


updateTradeCreationInfo : Int -> Contracts.Types.TradeCreationInfo -> Model -> Model
updateTradeCreationInfo id creationInfo model =
    case Array.get id model.trades of
        Just trade ->
            let
                newTrade =
                    Contracts.Types.updateCreationInfo creationInfo trade

                newTradeArray =
                    Array.set id
                        newTrade
                        model.trades
            in
            { model | trades = newTradeArray }

        Nothing ->
            let
                _ =
                    Debug.log "updateTradeAddress ran into an out-of-range error" ""
            in
            model


updateTradeParameters : Int -> Contracts.Types.TradeParameters -> Model -> Model
updateTradeParameters id parameters model =
    case Array.get id model.trades of
        Just trade ->
            let
                newTrade =
                    Contracts.Types.updateParameters parameters trade

                newTradeArray =
                    Array.set id
                        newTrade
                        model.trades
            in
            { model | trades = newTradeArray }

        Nothing ->
            let
                _ =
                    Debug.log "updateTTParameters ran into an out-of-range error" ""
            in
            model


updateTradeState : Int -> Contracts.Types.State -> Model -> Model
updateTradeState id state model =
    case Array.get id model.trades of
        Just trade ->
            let
                newTrade =
                    Contracts.Types.updateState state trade

                newTradeArray =
                    Array.set id
                        newTrade
                        model.trades
            in
            { model | trades = newTradeArray }

        Nothing ->
            let
                _ =
                    Debug.log "updateTTState ran into an out-of-range error" ""
            in
            model


updateTradePaymentMethods : Int -> List PaymentMethod -> Model -> Model
updateTradePaymentMethods id methods model =
    case Array.get id model.trades of
        Just trade ->
            let
                newTrade =
                    Contracts.Types.updatePaymentMethods methods trade

                newTradeArray =
                    Array.set id
                        newTrade
                        model.trades
            in
            { model | trades = newTradeArray }

        Nothing ->
            let
                _ =
                    Debug.log "updateTTPaymentMethods ran into an out-of-range error" ""
            in
            model
