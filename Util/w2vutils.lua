--[[
Taken from: https://github.com/rotmanmi/word2vec.torch/blob/master/w2vutils.lua
]]
torch.setdefaulttensortype('torch.FloatTensor')

opt = {
	binfilename = 'word2vecbin/GoogleNews-vectors-negative300.bin',
	outfilename = 'data/word2vec.t7'
}
local w2vutils = {}
if not paths.filep(opt.outfilename) then
	w2vutils = require('Util.Bin2t7')
else
	w2vutils = torch.load(opt.outfilename)
	print('Done reading word2vec data.')
end

w2vutils.distance = function (self,vec,k)
	local k = k or 1
	--self.zeros = self.zeros or torch.zeros(self.M:size(1));
	local norm = vec:norm(2)
	vec:div(norm)
	local distances = torch.mv(self.M ,vec)
	distances , oldindex = torch.sort(distances,1,true)
	local returnwords = {}
	local returndistances = {}
	for i = 1,k do
		table.insert(returnwords, w2vutils.v2wvocab[oldindex[i]])
		table.insert(returndistances, distances[i])
	end
	return {returndistances, returnwords}
end

w2vutils.word2vec = function (self,word,throwerror)
   local throwerror = throwerror or false
   local ind = self.w2vvocab[word]
   if throwerror then
		assert(ind ~= nil, 'Word does not exist in the dictionary!')
   end
   return self.M[ind]
end

return w2vutils