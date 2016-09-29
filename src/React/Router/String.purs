module React.Router.String
  ( stringRouter
  ) where

import Prelude
import React as R
import Data.Either (either)
import Data.Maybe (Maybe(..))
import Routing (matchHash)
import Routing.Match (Match)

type StringRouterProps a =
  { render :: Maybe a -> R.ReactElement
  , match :: Match a
  , route :: String
  }

stringRouter :: forall a. (Maybe a -> R.ReactElement) -> Match a -> String -> R.ReactElement
stringRouter render match route = R.createFactory stringRouterComponent {render: render, match: match, route: route}

stringRouterComponent :: forall a. R.ReactClass (StringRouterProps a)
stringRouterComponent = R.createClass $ R.spec' getInitialState render
  where
    getInitialState :: forall eff. R.GetInitialState (StringRouterProps a) (Maybe a) eff
    getInitialState this = do
      props <- R.getProps this
      pure $ either (const Nothing) Just (matchHash props.match props.route)

    render :: forall eff. R.Render (StringRouterProps a) (Maybe a) eff
    render this = do
      props <- R.getProps this
      state <- R.readState this
      pure (props.render state)
