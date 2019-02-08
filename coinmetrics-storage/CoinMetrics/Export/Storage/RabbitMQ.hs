{-# LANGUAGE OverloadedStrings, ViewPatterns, RecordWildCards #-}

module CoinMetrics.Export.Storage.RabbitMQ
  ( RabbitMQExportStorage()
  ) where

import qualified Data.Aeson as J
import qualified Network.AMQP as AMQP
import qualified Data.Text as T
import qualified Data.Char as C
import qualified Text.Read as T
import Control.Monad
import Control.Exception
import Data.Maybe

import CoinMetrics.Export.Storage
import CoinMetrics.BlockChain

newtype RabbitMQExportStorage = RabbitMQExportStorage ExportStorageOptions


instance ExportStorage RabbitMQExportStorage where
  initExportStorage = return . RabbitMQExportStorage
  writeExportStorageSomeBlocks (RabbitMQExportStorage ExportStorageOptions{..}) params blocks = do
    when (length queueExchange < 2) cantGetNames
    let queueName = queueExchange !! 0
        exchangeName = queueExchange !! 1
    sequence_ $ (handleBlock queueName exchangeName) <$> blocks
    where
      handleBlock queueName exchangeName someBlocks = do
        let encoded = (\(SomeBlocks b) -> J.encode b) <$> someBlocks
            connect = connectToBroker connOpts queueName exchangeName
            mkMessage block = AMQP.newMsg { AMQP.msgBody = block,  AMQP.msgDeliveryMode = Just AMQP.Persistent}
            close conn chan = AMQP.closeChannel chan >> AMQP.closeConnection conn
            send _ chan = sequence_ (AMQP.publishMsg chan exchangeName "export-block" . mkMessage <$> encoded)
        bracket connect (uncurry close) (uncurry send)
      cantGetNames = error "Can't get queue and exchange name"
      connOpts =  parseConnectionOpts . T.pack . esp_destination $ params
      queueExchange = maybe cantGetNames (T.splitOn ":") (listToMaybe eso_tables)

data AmqpConnectionParams = AmqpConnectionParams
  { acpUser :: T.Text
  , acpPass :: T.Text
  , acpPort :: Int
  , acpVhost :: T.Text
  , acpHost :: T.Text
  } deriving (Show)

-- format is: amqp://user:pass@host:10000/vhost
parseConnectionOpts :: T.Text -> AmqpConnectionParams
parseConnectionOpts connStr =
  AmqpConnectionParams{
    acpUser = user,
    acpPass = pass,
    acpVhost = vhost,
    acpHost = host,
    acpPort = fromMaybe (error "Port should be a number") (T.readMaybe $ T.unpack port)
  }
  where
    withoutProto = T.replace "amqp://" "" connStr
    creds = T.splitOn ":" . head . T.splitOn "@" $ withoutProto
    user = creds !! 0
    pass = creds !! 1
    hosts = last . T.splitOn "@" $ withoutProto
    host = T.takeWhile ((/=) ':') hosts
    port = T.takeWhile C.isDigit . T.drop 1 . T.dropWhile ((/=) ':') $ hosts
    vhost = T.dropWhile ((/=) '/') hosts

connectToBroker :: AmqpConnectionParams -> T.Text -> T.Text -> IO (AMQP.Connection, AMQP.Channel)
connectToBroker AmqpConnectionParams{..} queueName exchangeName = do
  conn <- AMQP.openConnection (T.unpack acpHost) acpVhost acpUser acpPass
  chan <- AMQP.openChannel conn
  let queue = AMQP.newQueue {AMQP.queueName = queueName}
      exchange = AMQP.newExchange {AMQP.exchangeName = exchangeName, AMQP.exchangeType = "direct"}
  _ <- AMQP.declareQueue chan queue
  AMQP.bindQueue chan queueName exchangeName "export-block"
  AMQP.declareExchange chan exchange
  pure (conn, chan)