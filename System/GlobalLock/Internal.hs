{-# LANGUAGE
    ForeignFunctionInterface #-}
module System.GlobalLock.Internal
    ( get
    ) where

import Foreign
import Foreign.C
import Control.Monad
import Control.Concurrent.MVar

{- Importing c_get_global_ptr with 'unsafe' decreases locking latency
   by about 50%.  It's okay because that function just reads a C
   static global.

   c_set_global_ptr must not be imported 'unsafe' because it uses GCC
   atomic-operation builtins which, in the worst case, might call a
   blocking library function. -}

foreign import ccall unsafe c_get_global_ptr :: IO (Ptr ())
foreign import ccall        c_set_global_ptr :: Ptr () -> IO CInt

set :: IO ()
set = do
    mv  <- newMVar ()
    ptr <- newStablePtr mv
    ret <- c_set_global_ptr (castStablePtrToPtr ptr)
    when (ret == 0) $
        freeStablePtr ptr

get :: IO (MVar ())
get = do
    p <- c_get_global_ptr
    if p /= nullPtr
        then deRefStablePtr (castPtrToStablePtr p)
        else set >> get
