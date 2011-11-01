import System.GlobalLock

import Data.IORef
import Control.Monad
import Control.Concurrent
import Control.Concurrent.Spawn
import System.Exit
import System.Random

thread :: IORef Int -> IO ()
thread ref = replicateM_ 40 . lock $ do
    v <- readIORef ref
    when (v /= 0) $ do
        putStrLn "ERROR: mutual exclusion violation"
        exitFailure

    atomicModifyIORef ref (\n -> (n+1,()))
    delay <- randomRIO (0,4000)
    threadDelay delay
    atomicModifyIORef ref (\n -> (n-1,()))

main :: IO ()
main = do
    ref <- newIORef 0
    parMapIO_ (const $ thread ref) [0..200]
