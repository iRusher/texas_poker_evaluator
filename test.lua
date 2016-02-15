local texas = require "poker"

local card = texas.card
local lookup = texas.lookup
local evaluater = texas.evaluater

evaluater.setup()

local cards = {
	{card.new('Ah'),card.new('Kh')},
	{card.new('Qc'),card.new('7d')},
	{card.new('Js'),card.new('2c')},
	{card.new('7s'),card.new('5h')}
}

local board = {
	card.new('3h'),card.new('7h'),card.new('5s'),card.new('8c'),card.new('Th')
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