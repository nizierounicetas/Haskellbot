
{-# LANGUAGE OverloadedStrings     #-}

module Main where

import           Bot                         (botStartup)

main :: IO ()
main = do
    putStrLn "Starting bot..."
    botStartup