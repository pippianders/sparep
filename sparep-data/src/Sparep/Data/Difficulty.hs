{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module Sparep.Data.Difficulty where

import Control.Monad
import Data.Aeson
import Data.Proxy
import qualified Data.Text as T
import Data.Text (Text)
import Data.Validity
import Database.Persist
import Database.Persist.Sql
import GHC.Generics (Generic)

data Difficulty
  = CardIncorrect
  | CardHard
  | CardGood
  | CardEasy
  deriving (Show, Eq, Ord, Generic)

instance Validity Difficulty

renderDifficulty :: Difficulty -> Text
renderDifficulty =
  \case
    CardIncorrect -> "Incorrect"
    CardHard -> "Hard"
    CardGood -> "Good"
    CardEasy -> "Easy"

parseDifficulty :: Text -> Either Text Difficulty
parseDifficulty =
  \case
    "Incorrect" -> Right CardIncorrect
    "Hard" -> Right CardHard
    "Good" -> Right CardGood
    "Correct" -> Right CardGood
    "Easy" -> Right CardEasy
    _ -> Left "Unknown Difficulty"

instance FromJSON Difficulty where
  parseJSON = withText "Difficulty" $ \t ->
    case parseDifficulty t of
      Left err -> fail $ T.unpack err
      Right d -> pure d

instance ToJSON Difficulty where
  toJSON = toJSON . renderDifficulty

instance PersistField Difficulty where
  toPersistValue = toPersistValue . renderDifficulty

  fromPersistValue = fromPersistValue >=> parseDifficulty

instance PersistFieldSql Difficulty where
  sqlType Proxy = sqlType (Proxy :: Proxy Text)
