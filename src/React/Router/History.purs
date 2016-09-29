module React.Router.History
  ( historyRouter
  ) where

import Prelude
import React as R
import React.DOM as D
import Control.Monad.Eff (Eff)
import DOM (DOM)
import Data.Either (either)
import React.Router (EventHandler, RouterProps)
import Routing (matchHash)
import Routing.Match (Match)

foreign import watchHistory :: forall eff. (String -> Eff eff Unit) -> Eff eff Unit

historyRouter :: forall a eff. EventHandler a (dom :: DOM | eff) -> Match a -> R.ReactElement
historyRouter onChange match = R.createFactory historyRouterComponent {onChange: onChange, match: match}

historyRouterComponent :: forall a eff. R.ReactClass (RouterProps a (dom :: DOM | eff))
historyRouterComponent = R.createClass $ (R.spec {} render) { componentWillMount = componentWillMount }
  where
    componentWillMount :: forall state. R.ComponentWillMount (RouterProps a (dom :: DOM | eff)) state (dom :: DOM | eff)
    componentWillMount this = do
      props <- R.getProps this
      matchesHistory props.match (\new -> props.onChange new)

    render :: forall state. R.Render (RouterProps a (dom :: DOM | eff)) state (dom :: DOM | eff)
    render this = do
      children <- R.getChildren this
      pure $ D.div' children

matchesHistory :: forall a eff. Match a -> (a -> Eff eff Unit) -> Eff eff Unit
matchesHistory routing cb = watchHistory $ \new ->
  let mr = matchHash routing
  in either (const $ pure unit) cb $ mr new
