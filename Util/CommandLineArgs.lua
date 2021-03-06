--[[
This file is a means to refactor command line argument parsing outside of the
main nn files.

This was loosely adapted from Andrej Karpathy's char-rnn train.lua file
source: https://github.com/karpathy/char-rnn/blob/master/train.lua

Major changes made were:
1. Refactoring to new file for readbility
2. Changing names to match rest of project's naming scheme
3. Adding relevent commandline args for this project.
]]--
local CommandLineArgs = {}

function CommandLineArgs.predictCmdArgs()
  print("Running preditCmdArgs")
  cmd = torch.CmdLine()
  cmd:text()
  cmd:text('Options')

  cmd:option('-checkpoint', '', 'Checkpoint file to sample from.')
  cmd:option('-logfile', '', 'Output directory where chatlogs should be saved.')
  -- parse input params
  return cmd:parse(arg)
end

function CommandLineArgs.trainCmdArgs()
  print("Running trainCmdArgs")
  cmd = torch.CmdLine()
  cmd:text()
  cmd:text('Train a chatbot!')
  cmd:text()
  cmd:text('Options')
  -- data
  cmd:option('-dataDir','data/','Data directory. Should point to tokenized input file')
  cmd:option('-gpuid',0,'which gpu to use. -1 = use CPU')
  cmd:option('-opencl',0,'use OpenCL (instead of CUDA)')
  cmd:option('-batchSize',200,'number of sequences to train on in parallel')
  cmd:option('-trainFrac',0.7,'fraction of data that goes into train set (rest will be in test set)')
  cmd:option('-maxEpochs',50,'number of full passes through the training data')
  cmd:option('-dropout',0.8,'dropout for regularization, used after each RNN hidden layer. 0 = no dropout')
  cmd:option('-maxSeqLength',30,'Max sentence length.')
  cmd:option('-seed',123,'Torch manual random number generator seed.')

  -- model params
  cmd:option('-hiddenSize', 500, 'size of LSTM internal state')
  cmd:option('-numLayers', 2, 'number of layers in the LSTM')
  -- optimization
  cmd:option('-learningRate',0.0001,'Learning rate.')
  cmd:option('-lrDecay',0.97,'Learning rate decay.')
  cmd:option('--momentum', 0.9, 'momentum')
  cmd:option('-gradClip',5,'Clip gradients at this value.')
  cmd:option('-weights', '', 'Initialize network parameters from checkpoint at this path.')
  -- bookkeeping
  cmd:option('-printFreq',1.0,'How often to print out checkpoint info and save (as a percentage of one epoch)')
  cmd:option('-checkpoints', 'cv', 'Output directory where checkpoints get written.')
  cmd:option('-startFrom', '', 'File to initialize training or prediction from.')
  cmd:option('-savefile','chatbot','Filename to autosave the checkpont to. Will be inside checkpoint/')
  cmd:text()
-- parse input params
  return cmd:parse(arg)
end

function CommandLineArgs.generalCmdArgs()
  print("hello world")
end

return CommandLineArgs
