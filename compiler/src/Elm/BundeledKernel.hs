{-# LANGUAGE TemplateHaskell #-}
module Elm.BundeledKernel
  ( exists
  , load
  , moduleNames
  )
  where


import qualified Elm.ModuleName as ModuleName
import qualified Elm.Package as Pkg
import qualified Data.Name as Name
import qualified Data.ByteString as BS
import qualified Data.Map.Strict as Map
import System.FilePath ((<.>))
import qualified System.FilePath as FP
import Data.FileEmbed
import Control.Exception (assert)


modules :: Map.Map FilePath BS.ByteString
modules = Map.fromList $ $(embedDir "compiler/src/Elm/BundeledKernel")


toFilePath :: ModuleName.Raw -> FilePath
toFilePath moduleName =
  assert (Name.isKernel moduleName)
  (ModuleName.toFilePath (Name.getKernel moduleName) <.> "js")


exists :: ModuleName.Raw -> Bool
exists moduleName =
  if Name.isKernel moduleName then
    Map.member (toFilePath moduleName) modules
  else
    False


load :: ModuleName.Raw -> Maybe BS.ByteString
load moduleName =
  if Name.isKernel moduleName then
    Map.lookup (toFilePath moduleName) modules
  else
    Nothing


moduleNames :: [ModuleName.Canonical]
moduleNames =
  fmap
    (\(filePath, _) ->
      ModuleName.Canonical
        Pkg.kernel
        (Name.fromChars ("Elm.Kernel." ++ FP.dropExtension filePath))
    )
    (Map.toList modules)
