module React.Router.Hash
  ( hashRouter
  , hashRouter'
  ) where

import Prelude
import React as R
import React.DOM as D
import Control.Monad.Eff (Eff)
import DOM (DOM)
import Data.Maybe (Maybe(..))
import Routing (matches)
import Routing.Match (Match)

type RouterProps a =
  { render :: Maybe a -> R.ReactElement
  , match :: Match a
  }

hashRouter :: forall a. (Maybe a -> R.ReactElement) -> Match a -> R.ReactElement
hashRouter render match = R.createFactory hashRouterComponent {render: render, match: match}

hashRouterComponent :: forall a. R.ReactClass (RouterProps a)
hashRouterComponent = R.createClass $ (R.spec Nothing render) { componentWillMount = componentWillMount }
  where
    componentWillMount :: forall eff. R.ComponentWillMount (RouterProps a) (Maybe a) (dom :: DOM | eff)
    componentWillMount this = do
      props <- R.getProps this
      matches props.match (\_ new -> void $ R.writeState this (Just new))

    render :: forall eff. R.Render (RouterProps a) (Maybe a) eff
    render this = do
      props <- R.getProps this
      state <- R.readState this
      pure (props.render state)

--
type EventHandler a eff = a -> Eff (props :: R.ReactProps, state :: R.ReactState R.ReadWrite, refs :: R.ReactRefs R.Disallowed | eff) Unit

type RouterProps' a eff =
  { onChange :: EventHandler a eff
  , match :: Match a
  }

hashRouter' :: forall a eff. EventHandler a (dom :: DOM | eff) -> Match a -> R.ReactElement
hashRouter' onChange match = R.createFactory hashRouterComponent' {onChange: onChange, match: match}

hashRouterComponent' :: forall a eff. R.ReactClass (RouterProps' a (dom :: DOM | eff))
hashRouterComponent' = R.createClass $ (R.spec {} render) { componentWillMount = componentWillMount }
  where
    componentWillMount :: forall state. R.ComponentWillMount (RouterProps' a (dom :: DOM | eff)) state (dom :: DOM | eff)
    componentWillMount this = do
      props <- R.getProps this
      matches props.match (\_ new -> props.onChange new)

    render :: forall state. R.Render (RouterProps' a (dom :: DOM | eff)) state (dom :: DOM | eff)
    render this = do
      props <- R.getProps this
      children <- R.getChildren this
      pure $ D.div' children
