--[[
The purpose of this file is to enable the train.lua file to
'efficiently' create, load, and save the minibatches
]]
local TableUtils = require "Util.TableUtils"
local StringUtils = require "Util.StringUtils"
local Preprocessor = require "Preprocessor"
local Constants = require "Util.Constants"
require 'lfs'

local MiniBatchLoader = {}

function MiniBatchLoader.createMiniBatches(options)

  print("Max sequence length is ... ".. options.maxSeqLength)
  local batchFiles  = {}

  local dataFiles = {}
  local processedDir = path.join(options.dataDir, Constants.processedFolder)
  print("Loading data...")

  local trainingPairSize = {}

  for file in lfs.dir(processedDir) do
    if not StringUtils.startsWith(file,".") then
      local filePath = path.join(processedDir, file)
      table.insert(dataFiles, filePath)
    end
  end

--This tensor will eventually be overwritten, losing the random pair
  local miniBatches = torch.IntTensor(1,2,options.maxSeqLength)

  for key, value in ipairs(dataFiles) do
    print(value)
    local data = torch.load(value)
    local VocabMapping = require "Util.VocabMapping"
    local mapping = VocabMapping.create(options.dataDir)
    print("Loaded data...")
    local sourceTargetPairs = torch.IntTensor(#data-1, 2, options.maxSeqLength)

    -- Reverse sequences to introduce short-term dependency's (Google's result)
    --Insert training pairs into tensor
    for i=1,#data-1 do
      if not (data[i]:size(1) > options.maxSeqLength) and
        not (data[i + 1]:size(1) > options.maxSeqLength) then

          local source = torch.IntTensor(options.maxSeqLength)
            :fill(-1)
          local target = torch.IntTensor(options.maxSeqLength)
            :fill(-1)
          local sourceIndices = TableUtils.indexTensor(data[i]:size(1))
          local targetIndices = TableUtils.indexTensor(data[i + 1]:size(1))
          source:indexCopy(1, sourceIndices, TableUtils.reverseTensor(data[i]))
          target:indexCopy(1, targetIndices, data[i + 1])
          sourceTargetPairs[i][1] = source
          sourceTargetPairs[i][2] = target
          --= torch.IntTensor({source, target})
      end
    end

    miniBatches =  torch.cat(miniBatches, sourceTargetPairs, 1)
  end
  --Cut off first entry
  miniBatches = miniBatches:sub(2,miniBatches:size(1))
    --save batch sets in appropriate t7 files
    print("Creating minibatch files...")
  --Due to memory constraints of data I have decided to split everything
  --into multiple files

  local batchFile = path.join(options.dataDir,Constants.rawBatchesFolder..Constants.rawBatchesFile)

  local totalNum = miniBatches:size(1)

  local numTrain = math.floor(options.trainFrac * totalNum)
  local numTest = math.floor(options.testFrac * totalNum)
  local numEval = totalNum - numTrain - numTest
  torch.save(batchFile, miniBatches)

end

--[[Reads in tensor files, and gets max seqence length.
While this is inneficient to do so, this method was made to prevent dependency
on the preprocesor.lua file to pass max sequence length forward. Making this design
decision allows for modularity between minibatch creation, and preprocessing the data.
]]
function MiniBatchLoader.getMaxSequenceLength(dataFile)
  local data = torch.load(dataFile)
  local maxLength = 0
  for key, vec in ipairs(data) do
    if vec:size(1) > maxLength then
      maxLength = vec:size(1)
    end
  end
  return maxLength
end

--[[
This function check if we even need to run the minibatchmaker
It assumed if there are batches in the train folder that it
does not need to be run
]]
function MiniBatchLoader.shouldRun(dataDir)
  local batchDataDir = path.join(dataDir, Constants.rawBatchesFolder)
  local batchFile = path.join(batchDataDir, Constants.rawBatchesFile)
  return not path.exists(batchFile)
end

function MiniBatchLoader.loadBatches(dataDir, batchSize, trainFrac,
  evalFrac, testFrac)
  local self = {}
  setmetatable(self, MiniBatchLoader)
  --Checks to ensure user isn't testing us
  assert(evalFrac >= 0 and evalFrac < 1, "evalFrac not between 0 and 1...")
  assert(trainFrac > 0 and trainFrac <= 1, "trainFrac not between 0 and 1...")
  assert(testFrac >= 0 and testFrac < 1, "testFrac not between 0 and 1...")
  assert(testFrac + evalFrac + trainFrac == 1, "eval, train and test don't add up to 1!")

  print("Using ".. trainFrac .. " As percentage of data to train on...")
  print("Using ".. evalFrac .. " As percentage of data to validate on...")
  print("Using " .. testFrac .. " As percentage of data to test on...")
  local saveFolder = path.join(dataDir, Constants.saveFolder )

  self.vocabMapping = torch.load(path.join(saveFolder, Constants.vocabFile))
  self.dicMapping = torch.load(path.join(saveFolder, Constants.dicFile))

  local trainFile = path.join(dataDir, Constants.trainFolder)
  trainFile = path.join(trainFile, Constants.trainFile)

  print('Loading previously allocated minibatches...')

end

function MiniBatchLoader.nextBatch()
end

function MiniBatchLoader.resetPointer()
end

return MiniBatchLoader

--code I will probably need to refer to later:
--local trainFiles = {}
--local testFiles = {}
--local evalFiles = {}
--local trainFile = path.join(dataDir,Constants.trainFolder..Constants.trainFile)
--local testFile = path.join(dataDir,Constants.testFolder..Constants.testFile)
--local evalFile = path.join(dataDir,Constants.evalFolder..Constants.evalFile)
--miniBatches, testBatches, evalBatches = miniBatches:sub(1, numTrain),
--  miniBatches:sub(numTrain + 1, numTrain + numTest),
--  miniBatches:sub(numTrain + numTest + 1,
--   numTrain + numTest + numEval)