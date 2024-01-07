{-# LANGUAGE OverloadedStrings     #-}
module Bot where

import           Data.Text                        (Text)
import qualified Data.Text                        as Text
import           Data.Maybe
import           System.Environment               (getEnv)
import           Telegram.Bot.API                 as Telegram
import           Telegram.Bot.Simple
import           Telegram.Bot.Simple.UpdateParser (updateMessageText, updateMessageSticker)
import           Telegram.Bot.API.InlineMode.InlineQueryResult
import           Telegram.Bot.API.InlineMode.InputMessageContent (defaultInputTextMessageContent)

type Model = ()

data Action
  = InlineEcho InlineQueryId Text
  | StickerEcho InputFile ChatId
  | Echo Text

echoBot :: BotApp Model Action
echoBot = BotApp
  { botInitialModel = ()
  , botAction = updateToAction
  , botHandler = handleAction
  , botJobs = []
  }

updateToAction :: Update -> Model -> Maybe Action
updateToAction update _
  | isJust $ updateInlineQuery update =  do
      query <- updateInlineQuery update
      let queryId = inlineQueryId query
      let msg =  inlineQueryQuery query
      Just $ InlineEcho queryId msg

  | isJust $ updateMessageSticker update = do
    fileId <- stickerFileId <$> updateMessageSticker update
    chatId <- updateChatId update
    pure $ StickerEcho (InputFileId fileId) chatId

  | otherwise = do 
    let usr = fromJust $ messageFrom $ fromJust $ updateMessage update
    case updateMessageText update of
      Just text -> Just $ Echo $ (Text.concat ["I'm playing tricks on ", (Telegram.userFirstName usr), ": ", (Text.reverse text)])
      Nothing   -> Just $ Echo "Can't answer on this :("


handleAction :: Action -> Model -> Eff Action Model
handleAction action model = case action of
  InlineEcho queryId msg -> model <# do
    let result = (defInlineQueryResultGeneric (InlineQueryResultId msg))
          { inlineQueryResultTitle = Just msg
          , inlineQueryResultInputMessageContent = Just (defaultInputTextMessageContent msg)
          }
        thumbnail = defInlineQueryResultGenericThumbnail result
        article = defInlineQueryResultArticle thumbnail
        answerInlineQueryRequest = defAnswerInlineQuery queryId [article]
    _ <- runTG  answerInlineQueryRequest
    return ()
  StickerEcho file chat -> model <# do
    _ <- runTG
        (defSendSticker (SomeChatId chat) file)
    return ()
  Echo msg -> model <# do
    pure msg

run :: Token -> IO ()
run token = do
  env <- defaultTelegramClientEnv token
  startBot_ echoBot env


botStartup :: IO ()
botStartup = do
  env_token <- getEnv "BOT_TOKEN"
  let token = Token . Text.pack $ env_token
  env <- defaultTelegramClientEnv token
  startBot_ echoBot env
