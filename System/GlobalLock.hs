module System.GlobalLock
    ( lock
    ) where

import Control.Concurrent.MVar

import System.GlobalLock.Internal

lock :: IO a -> IO a
lock act = get >>= flip withMVar (const act)
