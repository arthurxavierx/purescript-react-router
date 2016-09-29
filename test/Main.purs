module Test.Counter where

import Prelude
import React.DOM as D
import Control.Alternative ((<|>))
import Control.Monad.Eff.Console (logShow)
import Data.Int (floor)
import Data.Maybe (Maybe(Just))
import React (Render)
import React.Router.Hash (hashRouter)
import React.Router.History (historyRouter)
import React.Router.String (stringRouter)
import Routing.Match (Match)
import Routing.Match.Class (num, str, lit)

data Route
  = Home
  | User String
  | Product Int
  | About

instance showRoute :: Show Route where
  show Home = "Home"
  show (User id) = "User " <> id
  show (Product id) = "Product " <> (show id)
  show About = "About"

match :: Match Route
match =
  Home <$ lit "/"
  <|>
  User <$> (lit "/" *> lit "user" *> str)
  <|>
  Product <$> (lit "/" *> lit "product" *> (floor <$> num))
  <|>
  About <$ (lit "/" *> lit "about")

render :: forall props state eff. Render props state eff
render this = pure $
  D.div'
    [ hashRouter logShow match
    , historyRouter logShow match
    , stringRouter renderScene match "/user/test123"
    ]
  where
    renderScene r =
      case r of
        Just (User id) ->
          D.h2' [D.text $ "This is user " <> id]

        Just (Product id) ->
          D.p' [D.text $ (show id) <> " - product"]

        Just About ->
          D.h1' [D.text "About this test"]

        _ ->
          D.span' [D.text "Home"]
