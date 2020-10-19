{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Sparep.API.Data where

import Data.Aeson
import qualified Data.Appendful as Appendful
import Data.Functor.Contravariant
import Data.Int
import qualified Data.Text as T
import Data.Text (Text)
import Data.Validity
import Data.Validity.Text ()
import Database.Persist
import Database.Persist.Sql
import Servant.API.Generic
import Servant.Auth.Server
import Sparep.Client.Data
import Sparep.Data
import Sparep.Server.Data

data RegistrationForm
  = RegistrationForm
      { registrationFormUsername :: Username,
        registrationFormPassword :: Text
      }
  deriving (Show, Eq, Ord, Generic)

instance Validity RegistrationForm

instance ToJSON RegistrationForm where
  toJSON RegistrationForm {..} =
    object
      [ "name" .= registrationFormUsername,
        "password" .= registrationFormPassword
      ]

instance FromJSON RegistrationForm where
  parseJSON =
    withObject "RegistrationForm" $ \o ->
      RegistrationForm <$> o .: "name" <*> o .: "password"

data LoginForm
  = LoginForm
      { loginFormUsername :: Username,
        loginFormPassword :: Text
      }
  deriving (Show, Eq, Ord, Generic)

instance Validity LoginForm

instance FromJSON LoginForm where
  parseJSON = withObject "LoginForm" $ \o ->
    LoginForm <$> o .: "username" <*> o .: "password"

instance ToJSON LoginForm where
  toJSON LoginForm {..} =
    object
      [ "username" .= loginFormUsername,
        "password" .= loginFormPassword
      ]

data AuthCookie
  = AuthCookie
      { authCookieUsername :: Username
      }
  deriving (Show, Eq, Ord, Generic)

instance FromJSON AuthCookie

instance ToJSON AuthCookie

instance FromJWT AuthCookie

instance ToJWT AuthCookie

type SyncRequest = Appendful.SyncRequest ClientRepetitionId ServerRepetitionId Repetition

type SyncResponse = Appendful.SyncResponse ClientRepetitionId ServerRepetitionId Repetition

instance (PersistEntity a, ToBackendKey SqlBackend a) => ToJSONKey (Key a) where
  toJSONKey = contramap fromSqlKey toJSONKey

instance (PersistEntity a, ToBackendKey SqlBackend a) => FromJSONKey (Key a) where
  fromJSONKey = toSqlKey <$> fromJSONKey
