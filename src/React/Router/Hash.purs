module React.Router.Hash
  ( hashRouter
  ) where

import Prelude
import React as R
import React.DOM as D
import DOM (DOM)
import React.Router (EventHandler, RouterProps)
import Routing (matches)
import Routing.Match (Match)

hashRouter :: forall a eff. EventHandler a (dom :: DOM | eff) -> Match a -> R.ReactElement
hashRouter onChange match = R.createFactory hashRouterComponent {onChange: onChange, match: match}

hashRouterComponent :: forall a eff. R.ReactClass (RouterProps a (dom :: DOM | eff))
hashRouterComponent = R.createClass $ (R.spec {} render) { componentWillMount = componentWillMount }
  where
    componentWillMount :: forall state. R.ComponentWillMount (RouterProps a (dom :: DOM | eff)) state (dom :: DOM | eff)
    componentWillMount this = do
      props <- R.getProps this
      matches props.match (\_ new -> props.onChange new)

    render :: forall state. R.Render (RouterProps a (dom :: DOM | eff)) state (dom :: DOM | eff)
    render this = do
      props <- R.getProps this
      children <- R.getChildren this
      pure $ D.div' children
