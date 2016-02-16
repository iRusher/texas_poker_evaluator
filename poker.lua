--[[

+--------+--------+--------+--------+
|xxxbbbbb|bbbbbbbb|cdhsrrrr|xxpppppp|
+--------+--------+--------+--------+

p 		= prime number of rank (deuce=2,trey=3,four=5,...,ace=41)
r 		= rank of card (deuce=0,trey=1,four=2,five=3,...,ace=12)
cdhs 	= suit of card (bit turned on based on suit of card)
b 		= bit turned on depending on rank of card

xxxAKQJT 98765432 CDHSrrrr xxPPPPPP
00001000 00000000 01001011 00100101    King of Diamonds
00000000 00001000 00010011 00000111    Five of Spades
00000010 00000000 10001001 00011101    Jack of Clubs

]]



-- 组合C(m,n)
local function combo(t,n)
  local n,max,tn,output = n,#t,{},{}
  for x = 1,n do tn[x],output[x] = x,t[x] end
  tn[n] = tn[n]-1
  return function()
    local t,tn,output,x,n,max = t,tn,output,n,n,max
    while tn[x] == max + x - n do x = x-1 end
    if x == 0 then return nil end
    tn[x] = tn[x] + 1
    output[x] = t[tn[x]]
    for i = x + 1,n do 
      tn[i] = tn[i-1] + 1
      output[i] = t[tn[i]]
    end
    return output
  end
end

-- 表格拷贝
local function tablecopy( t )
	local tt = {}
	for i,v in ipairs(t) do
		table.insert(tt,v)
	end
	return tt
end



local card = {}

card.rank = {
	['2'] = {0, 2,'2'},
	['3'] = {1, 3,'3'},
	['4'] = {2, 5,'4'},
	['5'] = {3, 7,'5'},
	['6'] = {4, 11,'6'},
	['7'] = {5, 13,'7'},
	['8'] = {6, 17,'8'},
	['9'] = {7, 19,'9'},
	['T'] = {8, 23,'T'},  ['10'] = {8,  23,'T'},
	['J'] = {9, 29,'J'},  ['11'] = {9,  29,'J'},
	['Q'] = {10, 31,'Q'}, ['12'] = {10, 31,'Q'},
	['K'] = {11, 37,'K'}, ['13'] = {11, 37,'K'},
	['A'] = {12, 41,'A'}, ['14'] = {12, 41,'A'},
}
card.rank_str = '23456789TJQKA'

card.suit = { s = {1,'♠'}, h = {2,'♥'}, c = {4,'♣'}, d = {8,'♦'} }
card.suit_str = { 
	[1] = 's', 
	[2] = 'h', 
	[4] = 'c', 
	[8] = 'd' 
}
card.suit_pretty = { 
	[1] = '♠', 
	[2] = '♥', 
	[4] = '♣', 
	[8] = '♦' 
}

-- c 是字符串表示， As,表示 黑桃A
function card.new(c)

	local rank_char = string.sub(c,1,1)
	local suit_char = string.sub(c,2)
	

	local rank_int = card.rank[rank_char][1]
	local suit_int = card.suit[suit_char][1]

	local bit_rank = 1 << rank_int << 16
	local bit_suit = suit_int << 12
	local bit_rank_low = rank_int << 8

	local prime = card.rank[rank_char][2]

	-- print(rank_char..' '..suit_char)
	-- print('    xxxA KQJT 9876 5432 cdhs rrrr xxpp pppp')
	-- print("p : "..to_bit_str(prime)..' '..tostring(prime))
	-- print("r : "..to_bit_str(bit_rank_low)..' '..tostring(bit_rank_low))
	-- print("s : "..to_bit_str(bit_suit)..' '..tostring(bit_suit))
	-- print("b : "..to_bit_str(bit_rank)..' '..tostring(bit_rank))
	return bit_rank | bit_suit | bit_rank_low | prime
end

function card.create(rint,sint)
	local rank_int = card.rank[rint][1]
	local suit_int = card.suit[sint][1]

	local bit_rank = 1 << rank_int << 16
	local bit_suit = suit_int << 12
	local bit_rank_low = rank_int << 8

	local prime = card.rank[rank_char][2]
	return bit_rank | bit_suit | bit_rank_low | prime
end


function card.int_to_str(card_int)
	local rank_int = card.get_rank_int(card_int)
	local suit_int = card.get_suit_int(card_int)

	local rank_char = card.rank[tostring(rank_int + 2)][3]
	local suit_char = card.suit_str[suit_int]

	return  rank_char..suit_char

end

-- 2-A 的表示是从0-12
function card.get_rank_int(card_int)
	return ( card_int >> 8 ) & 0xF
end

function card.get_suit_int(card_int)
	return ( card_int >> 12 ) & 0xF 
end

function card.get_bitrank_int(card_int)
	return ( card_int >> 16 ) & 0x1FFFF
end

function card.get_prime(card_int)
	return ( card_int & 0x3F )
end

function card.int_pretty_str(card_int)
	local rank_int = card.get_rank_int(card_int)
	local suit_int = card.get_suit_int(card_int)

	local rank_char = card.rank[tostring(rank_int + 2)][3]
	local suit_pretty = card.suit_pretty[suit_int]

	return '['..rank_char..','..suit_pretty..']'
end

function card.prime_product_from_cards(cards)
	local product = 1
	for _,v in pairs(cards) do
		product = product * card.get_prime(v)
	end
	return product
end

function card.prime_product_from_rankbit(rankbit)

	local i = 0
	local product = 1
	repeat 
		if ((rankbit >> i) & 1) == 1 then
			product = product * card.rank[tostring(i+2)][2]
		end
		i = i + 1
	until i == 13

	return product
	-- body
end

-- int的字节表示
function card.to_bit_str( num )
	local x = ''
	for i = 1,32,1 do
		local sep = ''
		if (i-1)%4 == 0 then sep = ' ' end
		x = tostring(num & 0x1) .. sep .. x
		num = num >> 1
	end
	return x
end


local deck = {}

deck.full_deck = {}

function deck.new()
	deck.full_deck = {}
	deck.get_full_deck()
	deck.shuffle()
	return deck.full_deck
end

function deck.get_full_deck()
	for i=2,14 do
		local card_char = card.rank[tostring(i)][3]
		for k,_ in pairs(card.suit) do
			table.insert(deck.full_deck,card.new(card_char..k))
		end
	end
end

function deck.draw(n)
	local cs = {}
	for i=1,n do
		local c = deck.full_deck[1]
		table.insert(cs,c)
		table.remove(deck.full_deck,1)
	end
end

function deck.shuffle()
	local num = #deck.full_deck
	math.randomseed(os.time())
	for i=1,3 do
		for i = 1,num do
			local r = math.random(1,52)
			local temp = deck.full_deck[i]
			deck.full_deck[i] = deck.full_deck[r]
			deck.full_deck[r] = temp
		end
	end
end

function deck.pretty_str()
	local num = #deck.full_deck
	local ts = ''
	for i,v in ipairs(deck.full_deck) do
		ts = ts .. ' ' ..card.int_pretty_str(v)
		if i%4 == 0 then
			ts = ts ..'\n'
		end
	end
	return ts
end

local lookup = {}

--[[
Number of Distinct Hand Values:

Straight Flush   10 
Four of a Kind   156      [(13 choose 2) * (2 choose 1)]
Full Houses      156      [(13 choose 2) * (2 choose 1)]
Flush            1277     [(13 choose 5) - 10 straight flushes]
Straight         10 
Three of a Kind  858      [(13 choose 3) * (3 choose 1)]
Two Pair         858      [(13 choose 3) * (3 choose 2)]
One Pair         2860     [(13 choose 4) * (4 choose 1)]
High Card      + 1277     [(13 choose 5) - 10 straights]
-------------------------
TOTAL            7462

Here we create a lookup table which maps:
    5 card hand's unique prime product => rank in range [1, 7462]

Examples:
* Royal flush (best hand possible)          => 1
* 7-5-4-3-2 unsuited (worst hand possible)  => 7462
]]


-- rank,look up max rank,eng string,chs string
lookup.pattern = {
	royal_flush 	= {1, 	1,		"Royal Flush",		"皇家同花顺"	},
	straight_flush 	= {2, 	10,		"Straight Flush",	"同花顺"		},
	four_of_a_kind 	= {3, 	166,	"Four of a Kind",	"金刚"		},
	full_house 		= {4, 	322,	"Full House",		"葫芦"		},
	flush 			= {5, 	1599,	"Flush",			"同花"		},
	straight		= {6, 	1609,	"Straight",			"顺子"		},
	three_of_a_kind = {7, 	2467,	"Three of a Kind",	"三条"		},
	two_pair 		= {8, 	3325,	"Two Pair",			"两对"		},
	pair 			= {9, 	6185,	"Pair",				"一对"		},
	high_card 		= {10,	7462,	"High Card",		"高牌"		}
}



lookup.flush_lookup = {}
lookup.unsuited_lookup = {}

lookup.straight_flushes = {
    7936, -- 1111100000000 ,royal flush
    3968, -- 0111110000000 
    1984, -- 0011111000000 
    992,  -- 0001111100000 
    496,  -- 0000111110000 
    248,  -- 0000011111000 
    124,  -- 0000001111100 
    62,   -- 0000000111110 
    31,   -- 0000000011111 
    4111  -- 1000000001111 ,5 high
}

lookup.temp_flush = {}
local function lexi(v)
	local t = (v | ( v -1 )) + 1
	local w = t | ((((t & -t) / (v & -v)) >> 1) - 1)
	return w
end

local i = 1
local function permutation(v)
	if i > 1287 then return end -- 1287 = C(13,5)

	local isNotSF = true -- exclude 10 stright flush
	for _,s in ipairs(lookup.straight_flushes) do
		if (v~s) == 0 then
			isNotSF = false
		end 
	end
	if isNotSF then table.insert(lookup.temp_flush,1,v) end

	local w = lexi(v)
	i = i + 1
	return permutation(w)
end


function lookup.make_flush()
	permutation(0x1f) -- 0000000011111
	-- 同花顺
	local rank = 1
	for k,v in pairs(lookup.straight_flushes) do
		local prime = card.prime_product_from_rankbit(v)
		lookup.flush_lookup[prime] = rank
		rank = rank + 1
	end

	-- 同花
	rank = lookup.pattern.full_house[2] + 1
	for k,v in pairs(lookup.temp_flush) do
		local prime = card.prime_product_from_rankbit(v)
		lookup.flush_lookup[prime] = rank
		rank = rank + 1
	end

end

function lookup.make_straights_and_highcards()
	
	-- 顺子
	local rank = lookup.pattern.flush[2] + 1
	for k,v in pairs(lookup.straight_flushes) do
		local prime = card.prime_product_from_rankbit(v)
		lookup.unsuited_lookup[prime] = rank
		rank = rank + 1
	end

	-- 高牌
	local rank = lookup.pattern.pair[2] + 1
	for k,v in pairs(lookup.temp_flush) do
		local prime = card.prime_product_from_rankbit(v)
		lookup.unsuited_lookup[prime] = rank
		rank = rank + 1
	end
	lookup.temp_flush = nil
end

local function make_int_rank(...)
	local t = {}
	for i=2,14 do
		local include = false
		for j,v in ipairs({...}) do
			if i == v then
				include = true
				break
			end
		end
		if not include then 
			table.insert(t,1,i)
		end
	end
	return t
end

function lookup.make_others()

	local card_r = make_int_rank()
	local rank = lookup.pattern.straight_flush[2] + 1
	-- 金刚
	for i=1,#card_r do
		local single = make_int_rank(card_r[i])
		for j=1,#card_r - 1 do
			-- print(card_r[i],card_r[i],card_r[i],card_r[i],single[j])
			local king_prime =   card.rank[tostring(card_r[i])][2]
			local single_prime = card.rank[tostring(single[j])][2]
			local prime = king_prime * king_prime * king_prime * king_prime * single_prime
			lookup.unsuited_lookup[prime] = rank
			rank = rank + 1
		end
	end

	-- 葫芦
	for i=1,#card_r do
		local single = make_int_rank(card_r[i])
		for j=1,#card_r - 1 do
			-- print(card_r[i],card_r[i],card_r[i],single[j],single[j])
			local king_prime =   card.rank[tostring(card_r[i])][2]
			local single_prime = card.rank[tostring(single[j])][2]
			local prime = king_prime * king_prime * king_prime * single_prime * single_prime
			lookup.unsuited_lookup[prime] = rank
			rank = rank + 1
		end
	end

	rank = lookup.pattern.straight[2] + 1
	-- 三条
	for i=1,#card_r do
		local single = make_int_rank(card_r[i])
		for s in combo(single,2) do
			-- print(card_r[i],card_r[i],card_r[i],s[1],s[2])
			local king_prime =   card.rank[tostring(card_r[i])][2]
			local s1 = card.rank[tostring(s[1])][2]
			local s2 = card.rank[tostring(s[2])][2]
			local prime = king_prime * king_prime * king_prime * s1 * s2
			lookup.unsuited_lookup[prime] = rank
			rank = rank + 1
		end
	end

	-- 两对
	for e in combo(card_r,2) do
		local single = make_int_rank(e[1],e[2])
		for i,s in ipairs(single) do
			-- print(e[1],e[1],e[2],e[2],s,prime)
			local one = card.rank[tostring(e[1])][2]
			local two = card.rank[tostring(e[2])][2]
			local ss  = card.rank[tostring(s)][2]
			local prime = one * one * two * two * ss
			lookup.unsuited_lookup[prime] = rank
			rank = rank + 1
		end
	end

	-- 一对
	for i=1,#card_r do
		local single = make_int_rank(card_r[i])
		for e in combo(single,3) do
			-- print(card_r[i],card_r[i],e[1],e[2],e[3])
			local one = card.rank[tostring(card_r[i])][2]
			local two = card.rank[tostring(e[1])][2]
			local three = card.rank[tostring(e[2])][2]
			local four = card.rank[tostring(e[3])][2]
			local prime = one * one * two * three * four
			lookup.unsuited_lookup[prime] = rank
			rank = rank + 1
		end
	end
end

function lookup.make_all()
	lookup.make_flush()
	lookup.make_straights_and_highcards()
	lookup.make_others()
end

local evaluater = {}

function evaluater.five(cards)
	-- 判断是否同花
	if cards[1] & cards[2] & cards[3] & cards[4] & cards[5] & 0xF000 ~= 0 then 
		local handor = (cards[1] | cards[2] | cards[3] | cards[4] | cards[5]) >> 16
		local prime = card.prime_product_from_rankbit(handor)
		return lookup.flush_lookup[prime]
	else
		local prime = card.prime_product_from_cards(cards)
		return lookup.unsuited_lookup[prime]
	end
end


function evaluater.multi(cards)
	local max_rank = lookup.pattern.high_card[2]
	local max_cards = nil

	for e in combo(cards,5) do
		local rank = evaluater.five(e)
		if rank < max_rank then
			max_rank = rank
			max_cards = tablecopy(e)
		end
	end

	return max_rank,max_cards,evaluater.get_rank_class(max_rank)
end


function evaluater.hand_card(cards)
end

function evaluater.eval(cards,board)
	local count = 0
	if not cards then
		count = #cards
	end
	if not board then
		count = count + #board
	end

	local allcards = {}
	for k,v in pairs(cards) do
		table.insert(allcards,v)
	end

	for k,v in pairs(board) do
		table.insert(allcards,v)
	end

	if #allcards > 2 then
		return evaluater.multi(allcards)
	else
		-- 用作分析之用，最终如果比牌，一定是从C(7,5)
		return evaluater.hand_card(allcards)
	end
end

function evaluater.get_rank_class(rank)

	if rank == lookup.pattern.royal_flush[2] then
		return lookup.pattern.royal_flush
	elseif rank <= lookup.pattern.straight_flush[2] then
		return lookup.pattern.straight_flush
	elseif rank <= lookup.pattern.four_of_a_kind[2] then
		return lookup.pattern.four_of_a_kind
	elseif rank <= lookup.pattern.full_house[2] then
		return lookup.pattern.full_house
	elseif rank <= lookup.pattern.flush[2] then
		return lookup.pattern.flush
	elseif rank <= lookup.pattern.straight[2] then
		return lookup.pattern.straight
	elseif rank <= lookup.pattern.three_of_a_kind[2] then
		return lookup.pattern.three_of_a_kind
	elseif rank <= lookup.pattern.two_pair[2] then
		return lookup.pattern.two_pair
	elseif rank <= lookup.pattern.pair[2] then
		return lookup.pattern.pair
	elseif rank <= lookup.pattern.high_card[2] then
		return lookup.pattern.high_card
	end
end

function evaluater.compare(cards,board)
	local max_rank = lookup.pattern.high_card[2]
	local max_index = {}
	local patterns = {}
	for i,v in ipairs(cards) do
		local rank,card,pattern = evaluater.eval(v,board)
		if rank == max_rank then
			table.insert(max_index,i)
		elseif rank < max_rank then
			max_index = {}
			table.insert(max_index,i)
			max_rank = rank
		end
		table.insert(patterns,i,{pattern = evaluater.get_rank_class(rank), card = card})
	end
	return max_index,evaluater.get_rank_class(max_rank),patterns
end

function evaluater.setup()
	lookup.make_all()
end

-- ------------- TEST for card -------------

-- local c1 = card.new('As')
-- print('    '..to_bit_str(c1))
-- local c2 = card.new('Ks')
-- print('    '..to_bit_str(c2))
-- local c3 = card.new('Qs')
-- print('    '..to_bit_str(c3))
-- local c4 = card.new('Js')
-- print('    '..to_bit_str(c4))
-- local c5 = card.new('Ts')
-- print('    '..to_bit_str(c5))

-- print('....'..to_bit_str( 0xf000 ))
-- local cc = c1 & c2 & c3 & c4 & c5 & 0xf000
-- print('    '..to_bit_str(cc))


-- print(to_bit_str( 0x3f ))

-- print(card.int_pretty_str(c1))
-- print(card.int_pretty_str(c2))
-- print(card.int_pretty_str(c3))
-- print(card.int_pretty_str(c4))

-- print(card.int_pretty_str(c1))
-- print(card.int_pretty_str(c2))
-- print(card.int_pretty_str(c3))
-- print(card.int_pretty_str(c4))

-- local k = card.new('Kc')
-- print(card.int_pretty_str(k))

-- print(card.prime_product_from_rankbit(0x1f00))

-- local c1 = card.new('2s')
-- local c2 = card.new('3d')

-- print(tostring(card.prime_product_from_cards({c1,c2})))


-- local cc = { card.new('Ks'),card.new('8d'),card.new('Kh'),card.new('8h'),card.new('Ts') }
-- print(card.prime_product_from_cards(cc))

-- ------------- TEST for deck -------------

-- deck.get_full_deck()
-- print(deck.pretty_str())
-- deck.shuffle()
-- print(deck.pretty_str())
-- local cs = deck.draw(3)
-- print(deck.pretty_str())

-- ------------- TEST for lookup -------------

-- lookup.make_straights_and_highcards()

-- lookup.make_others()

-- local t = make_int_rank(14,12,13)



-- lookup.make_all()

-- local count = 0
-- for k,v in pairs(lookup.flush_lookup) do
-- 	-- print(tostring(k)..','..tostring(v))
-- 	count = count + 1
-- end
-- for k,v in pairs(lookup.unsuited_lookup) do
-- 	-- print(tostring(k)..','..tostring(v))
-- 	count = count + 1
-- end
-- print('lookup count : ',count)

-- print_r(lookup.flush_lookup)
-- print_r(lookup.unsuited_lookup)

-- ------------- TEST for evaluater -------------

-- local h1 = {card.new('As'),card.new('Ks'),card.new('Qs'),card.new('Js'),card.new('Ts')}
-- local h2 = {card.new('2s'),card.new('3s'),card.new('4s'),card.new('5s'),card.new('7d')}

-- local h1v = evaluater.five(h1)
-- local h2v = evaluater.five(h2)

-- print('h1v:',h1v)
-- print('h2v:',h2v)

-- print(evaluater.get_rank_class(h1v)[4])
-- print(evaluater.get_rank_class(h2v)[4])

-- local cards = {
-- 	{card.new('Ah'),card.new('Kh')},
-- 	{card.new('Qc'),card.new('7d')},
-- 	{card.new('Js'),card.new('2c')},
-- 	{card.new('7s'),card.new('5h')}
-- }

-- local board = {
-- 	card.new('3h'),card.new('7h'),card.new('5s'),card.new('8c'),card.new('Th')
-- }

-- local i,p = evaluater.compare(cards,board)
-- print(i[1],p[4])

-- local cc = { card.new('Ks'),card.new('8d'),card.new('Kh'),card.new('8h'),card.new('Ts') }


-- local r = evaluater.five(cc)
-- print(r)
-- print(evaluater.get_rank_class(r)[4])


local _P = {
	card = card,
	lookup = lookup,
	evaluater = evaluater,
}

return _P