module React.Router where

import Prelude
import React as R
import Control.Monad.Eff (Eff)
import Routing.Match (Match)

type EventHandler a eff = a -> Eff (props :: R.ReactProps, state :: R.ReactState R.ReadWrite, refs :: R.ReactRefs R.Disallowed | eff) Unit

type RouterProps a eff =
  { onChange :: EventHandler a eff
  , match :: Match a
  }

