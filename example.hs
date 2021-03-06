
import Control.Monad.MiniKanren

import Data.List
import Data.Tuple

-- To play with this file, either install the MiniKanrenT package, and
-- open it with ghci directly or (preferably) run with:
-- ghci -isrc example.hs

-- This prints out 5 possible lists that have the symbol "tofu" as a member
exampleMember :: IO ()
exampleMember = mapM_ print $ run 5 $ do
  x <- fresh
  membero "tofu" x
  return x

membero :: (MonadKanren m, CanBeTerm a) => a -> LVar Term -> m ()
membero x xs = do
  h <- fresh
  t <- fresh
  xs === (Cons h t)
  conde [ h === x
        , membero x t
        ]
    


-- Now for the classic genealogy example:

-- Prints out a list of all pairs of siblings
exampleSiblings :: IO ()
exampleSiblings = mapM_ print $ 
  -- filter out any duplicates
  nubBy (\a b -> a == b || swap a == b) $ 
  -- filter out any self-siblings
  filter (\a -> swap a /= a) $ 
  runAll $ do
    x <- fresh
    y <- fresh
    sibling x y
    return (x, y)

-- Prints out a list of all the mothers
exampleMothers :: IO ()
exampleMothers = mapM_ print $ nub $ runAll $ do
  m <- fresh
  c <- fresh
  mother m c
  return m

-- Prints out a list of all the fathers
exampleFathers :: IO ()
exampleFathers = mapM_ print $ nub $ runAll $ do
  f <- fresh
  c <- fresh
  father f c
  return f

male :: (MonadKanren m, CanBeTerm a) => a -> m ()
male x = conde
  [ "Bob" === x
  , "Joe" === x
  , "Charlie" === x
  ]

female :: (MonadKanren m, CanBeTerm a) => a -> m ()
female x = conde
  [ "Lisa" === x
  , "Jenny" === x
  , "Andromeda" === x
  ]

parent :: (MonadKanren m, CanBeTerm a, CanBeTerm b) => a -> b -> m ()
parent p c = conde
  [ "Lisa" === p >> "Bob" === c
  , "Lisa" === p >> "Andromeda" === c
  , "Joe" === p >> "Bob" === c
  , "Joe" === p >> "Andromeda" === c
  , "Jenny" === p >> "Lisa" === c
  , "Jenny" === p >> "Charlie" === c
  ]

sibling :: (MonadKanren m, CanBeTerm a, CanBeTerm b) => a -> b -> m ()
sibling x y = do
  p <- fresh
  parent p x
  parent p y

mother :: (MonadKanren m, CanBeTerm a, CanBeTerm b) => a -> b -> m ()
mother m c = do
  female m
  parent m c

father :: (MonadKanren m, CanBeTerm a, CanBeTerm b) => a -> b -> m ()
father m c = do
  male m
  parent m c

