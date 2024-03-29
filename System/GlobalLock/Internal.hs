{-# LANGUAGE
    ForeignFunctionInterface #-}

-- | Internals of global locking.
--
-- Use with caution!
module System.GlobalLock.Internal
    ( get
    ) where

import Foreign
import Foreign.C
import Control.Monad
import Control.Concurrent.MVar


{- Importing c_get_global with 'unsafe' decreases locking latency by
   about 50%.  The C function just reads a static variable, so it's
   okay to use 'unsafe'.

   c_set_global must not be imported 'unsafe' because it uses GCC
   atomic-operation builtins which, in the worst case, might call a
   blocking library function. -}

{- If you are copying this file to your own Haskell project, see the
   note in cbits/global.c regarding naming. -}

foreign import ccall unsafe "hs_globalzmlock_get_global"
    c_get_global :: IO (Ptr ())

foreign import ccall "hs_globalzmlock_set_global"
    c_set_global :: Ptr () -> IO CInt


set :: IO ()
set = do
    mv  <- newMVar ()
    ptr <- newStablePtr mv
    ret <- c_set_global (castStablePtrToPtr ptr)
    when (ret == 0) $
        -- The variable was already set; our StablePtr is unused.
        freeStablePtr ptr

-- | Get the single @'MVar'@ used for global locking.
get :: IO (MVar ())
get = do
    p <- c_get_global
    if p == nullPtr
        then set >> get
        else deRefStablePtr (castPtrToStablePtr p)
