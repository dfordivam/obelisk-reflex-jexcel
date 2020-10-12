{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

module Frontend where

import Control.Monad
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import Language.Javascript.JSaddle (eval, liftJSM)

import Obelisk.Frontend
import Obelisk.Configs
import Obelisk.Route
import Obelisk.Generated.Static

import Reflex.Dom.Core
import Reflex.JExcel
import Control.Lens

import Common.Api
import Common.Route


-- This runs in a monad that can be run on the client or the server.
-- To run code in a pure client or pure server context, use one of the
-- `prerender` functions.
frontend :: Frontend (R FrontendRoute)
frontend = Frontend
  { _frontend_head = do
      el "title" $ text "Obelisk Minimal Example"
      elAttr "link" ("href" =: static @"main.css" <> "type" =: "text/css" <> "rel" =: "stylesheet") blank
      elAttr "script" ("src" =: (static @"jsuites/jsuites.js")) blank
      elAttr "link" ("href" =: static @"jsuites/jsuites.css" <> "type" =: "text/css" <> "rel" =: "stylesheet") blank
      elAttr "script" ("src" =: (static @"jexcel/jexcel.js")) blank
      elAttr "link" ("href" =: static @"jexcel/jexcel.css" <> "type" =: "text/css" <> "rel" =: "stylesheet") blank
  , _frontend_body = do
      el "h1" $ text "Welcome to Obelisk!"
      el "p" $ text $ T.pack commonStuff
      
      -- `prerender` and `prerender_` let you choose a widget to run on the server
      -- during prerendering and a different widget to run on the client with
      -- JavaScript. The following will generate a `blank` widget on the server and
      -- print "Hello, World!" on the client.
      prerender_ blank $ liftJSM $ void $ eval ("console.log('Hello, World!')" :: T.Text)

      elAttr "img" ("src" =: static @"obelisk.jpg") blank
      prerender_ blank $ jexcelBody
      return ()
  }

jexcelBody :: MonadWidget t m => m ()
jexcelBody = do
    -- counter
    bE <- button "next"
    counterD <- count bE
    display counterD

    -- JExcel configuration (Dynamic)
    let jexcelD = buildJExcel <$> counterD

    -- jExcel
    jexcelOutput <- jexcel (JExcelInput htmlId jexcelD)

    -- transform input to output
    let xE' = _jexcelOutput_event jexcelOutput
    let xE = ffilter isSelection xE'
    xD <- holdDyn (OnLoad) xE
    display xD

    return ()

    where
        isSelection :: JExcelEvent -> Bool
        isSelection (OnSelection _ _ ) = True
        isSelection _                  = False

        htmlId  = "excel1"

        defaultJExcel :: JExcel
        defaultJExcel
            = def
            & jExcel_columns ?~ [ def & jExcelColumn_title ?~ "First Name"
                                      & jExcelColumn_width ?~ 300
                                , def & jExcelColumn_title ?~ "Last Name"
                                      & jExcelColumn_width ?~ 80
                                , def & jExcelColumn_title ?~ "Premium"
                                      & jExcelColumn_width ?~ 100
                                , def & jExcelColumn_title ?~ "Zipcode"
                                      & jExcelColumn_width ?~ 100
                                ]

        buildJExcel :: Int -> JExcel
        buildJExcel n = defaultJExcel
                      & jExcel_data ?~ [ ["John" , "Doe"    , T.pack . show $ n  , "90210"]
                                       , ["Jane" , "Doe"    , "$2000"          , "10010"]
                                       , ["Johan", "Though" , "$3000"          , "20020"]
                                       ]
