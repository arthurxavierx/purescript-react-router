module React.Router.History
  ( historyRouter
  , historyRouter'
  , navigateTo
  , link
  ) where

import Prelude
import React as R
import React.DOM as D
import React.DOM.Props as P
import Control.Monad.Eff (Eff)
import DOM (DOM)
import Data.Either (either)
import Data.Maybe (Maybe(..))
import Routing (matchHash)
import Routing.Match (Match)

foreign import navigateTo :: forall eff. String -> Eff (dom :: DOM | eff) Unit

foreign import linkHandler :: forall eff. String -> R.Event -> Eff (dom :: DOM | eff) Unit

foreign import watchHistory :: forall eff. (String -> Eff eff Unit) -> Eff eff Unit

--
link :: String -> Array P.Props -> Array R.ReactElement -> R.ReactElement
link url props children = D.a (props <> [ P.href url, P.onClick (linkHandler url) ]) children

--
type RouterProps a =
  { render :: Maybe a -> R.ReactElement
  , match :: Match a
  }

historyRouter :: forall a. (Maybe a -> R.ReactElement) -> Match a -> R.ReactElement
historyRouter render match = R.createFactory historyRouterComponent {render: render, match: match}

historyRouterComponent :: forall a. R.ReactClass (RouterProps a)
historyRouterComponent = R.createClass $ (R.spec Nothing render) { componentWillMount = componentWillMount }
  where
    componentWillMount :: forall eff. R.ComponentWillMount (RouterProps a) (Maybe a) (dom :: DOM | eff)
    componentWillMount this = do
      props <- R.getProps this
      matchesHistory props.match (\new -> void $ R.writeState this (Just new))

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

historyRouter' :: forall a eff. EventHandler a (dom :: DOM | eff) -> Match a -> R.ReactElement
historyRouter' onChange match = R.createFactory historyRouterComponent' {onChange: onChange, match: match}

historyRouterComponent' :: forall a eff. R.ReactClass (RouterProps' a (dom :: DOM | eff))
historyRouterComponent' = R.createClass $ (R.spec {} render) { componentWillMount = componentWillMount }
  where
    componentWillMount :: forall state. R.ComponentWillMount (RouterProps' a (dom :: DOM | eff)) state (dom :: DOM | eff)
    componentWillMount this = do
      props <- R.getProps this
      matchesHistory props.match (\new -> props.onChange new)

    render :: forall state. R.Render (RouterProps' a (dom :: DOM | eff)) state (dom :: DOM | eff)
    render this = do
      children <- R.getChildren this
      pure $ D.div' children

--
matchesHistory :: forall a eff. Match a -> (a -> Eff eff Unit) -> Eff eff Unit
matchesHistory routing cb = watchHistory $ \new ->
  let mr = matchHash routing
  in either (const $ pure unit) cb $ mr new
