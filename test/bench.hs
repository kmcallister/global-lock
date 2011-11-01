import System.GlobalLock

import Control.Concurrent.MVar
import Criterion.Main

main :: IO ()
main = do
    mVar <- newMVar ()
    defaultMain
        [ bench "bare"   $ (return () :: IO ())
        , bench "MVar"   $ withMVar mVar (const $ return ())
        , bench "global" $ lock (return ()) ]
