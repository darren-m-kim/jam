module App.Button where

import Prelude
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE

luck = 123

greet s = "hi!"

type State
    = { count :: Int }

data Action
    = Increment
    | Decrement

actOn :: Action -> Int
actOn Increment = 123
actOn Decrement = 456

component :: forall q i o m. H.Component q i o m
component =
  H.mkComponent
    { initialState: \_ -> { count: 0 }
    , render
    , eval: H.mkEval H.defaultEval { handleAction = handleAction } }

render :: forall cs m. State -> H.ComponentHTML Action cs m
render state =
  HH.div_
    [ HH.p_
        [ HH.text $ "You've clicked " <> show state.count <> " times!" ]
    , HH.button
        [ HE.onClick \_ -> Increment ]
        [ HH.text "Click me" ] ]

handleAction :: forall cs o m. Action → H.HalogenM State Action cs o m Unit
handleAction = case _ of
  Increment -> H.modify_ \st -> st { count = st.count + 1 }
  Decrement -> H.modify_ \st -> st { count = st.count + 1 }
