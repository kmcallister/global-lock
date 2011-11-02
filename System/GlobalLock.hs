-- | Provides a single global lock for @'IO'@ actions.
module System.GlobalLock
    ( lock
    ) where

import Control.Concurrent.MVar

import System.GlobalLock.Internal ( get )

-- | Take the global lock for the duration of an @'IO'@ action.
--
-- Two actions executed via @'lock'@ will never run simultaneously.
lock :: IO a -> IO a
lock act = get >>= flip withMVar (const act)
