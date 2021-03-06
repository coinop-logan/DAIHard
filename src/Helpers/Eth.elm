module Helpers.Eth exposing (addressIfNot0x0, getLogAt, httpProviderForFactory, makeViewAddressUrl, makeViewTxUrl, updateCallValue)

import Array
import BigInt exposing (BigInt)
import CommonTypes exposing (..)
import Config
import Eth.Net
import Eth.Sentry.Tx as TxSentry
import Eth.Types exposing (Address, HttpProvider, TxHash, WebsocketProvider)
import Eth.Utils


httpProviderForFactory : FactoryType -> HttpProvider
httpProviderForFactory factoryType =
    case factoryType of
        Token EthDai ->
            "https://mainnet.infura.io/v3/e3eef0e2435349bf9164e6f465bd7cf9"

        Native Eth ->
            "https://mainnet.infura.io/v3/e3eef0e2435349bf9164e6f465bd7cf9"

        Token KovanDai ->
            "https://kovan.infura.io/v3/e3eef0e2435349bf9164e6f465bd7cf9"

        Native Kovan ->
            "https://kovan.infura.io/v3/e3eef0e2435349bf9164e6f465bd7cf9"

        Native XDai ->
            "https://dai.poa.network"


addressIfNot0x0 : Address -> Maybe Address
addressIfNot0x0 addr =
    if addr == Eth.Utils.unsafeToAddress "0x0000000000000000000000000000000000000000" then
        Nothing

    else
        Just addr


getLogAt : Int -> List Eth.Types.Log -> Maybe Eth.Types.Log
getLogAt index logList =
    Array.fromList logList
        |> Array.get index


makeViewTxUrl : FactoryType -> TxHash -> String
makeViewTxUrl factoryType txHash =
    case factoryType of
        Token EthDai ->
            "https://etherscan.io/tx/" ++ Eth.Utils.txHashToString txHash

        Native Eth ->
            "https://etherscan.io/tx/" ++ Eth.Utils.txHashToString txHash

        Token KovanDai ->
            "https://kovan.etherscan.io/tx/" ++ Eth.Utils.txHashToString txHash

        Native Kovan ->
            "https://kovan.etherscan.io/tx/" ++ Eth.Utils.txHashToString txHash

        Native XDai ->
            "https://blockscout.com/poa/dai/tx/" ++ Eth.Utils.txHashToString txHash


makeViewAddressUrl : FactoryType -> Address -> String
makeViewAddressUrl factoryType address =
    case factoryType of
        Token EthDai ->
            "https://etherscan.io/address/" ++ Eth.Utils.addressToString address

        Native Eth ->
            "https://etherscan.io/address/" ++ Eth.Utils.addressToString address

        Token KovanDai ->
            "https://kovan.etherscan.io/address/" ++ Eth.Utils.addressToString address

        Native Kovan ->
            "https://kovan.etherscan.io/address/" ++ Eth.Utils.addressToString address

        Native XDai ->
            "https://blockscout.com/poa/dai/address/" ++ Eth.Utils.addressToString address


updateCallValue : BigInt -> Eth.Types.Call a -> Eth.Types.Call a
updateCallValue value call =
    { call
        | value = Just value
    }
