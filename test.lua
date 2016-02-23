local texas = require "poker"

local card = texas.card
local lookup = texas.lookup
local evaluater = texas.evaluater

evaluater.setup(lookup)

local cards = {
	{card.new('Ks'),card.new('8d')},
	{card.new('Ah'),card.new('4c')},
	{card.new('Kc'),card.new('5s')},
}

local board = {
	card.new('Kh'),card.new('8h'),card.new('9d'),card.new('3s'),card.new('Ts')
}

local i,p,ps = evaluater.compare(cards,board)
print(i[1],p[4])

for i,v in ipairs(ps) do
	local s = ''
	for j,w in ipairs(v.card) do
		s = s..'  '..card.int_to_str(w)
	end

	s = s .. '  ' .. v.pattern[4]
	print(s)
end


-- local cc = { card.new('Ks'),card.new('8d'),card.new('Kh'),card.new('8h'),card.new('Ts') }
-- local r = evaluater.five(cc)
-- print(r)
-- print(evaluater.get_rank_class(r)[4])


lookup.write_to_disk('/Users/rusherpan/work/server/poker/lookup.txt')

